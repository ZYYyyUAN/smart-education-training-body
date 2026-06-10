package com.atguigu.java.ai.langchain4j.util;

import com.google.gson.Gson;
import okhttp3.*;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.File;
import java.io.FileInputStream;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

public class IatModelZhMain extends WebSocketListener {

    private static final String hostUrl = "https://iat.xf-yun.com/v1";
    private static final String appid = System.getenv().getOrDefault("XFYUN_IAT_APP_ID",
            System.getProperty("xfyun.iat.app-id", "0c4a31f7"));
    private static final String apiSecret = System.getenv().getOrDefault("XFYUN_IAT_API_SECRET",
            System.getProperty("xfyun.iat.api-secret", "NDQ1YWEwYWJlMzU2ZjNhYWEyN2M0YWMw"));
    private static final String apiKey = System.getenv().getOrDefault("XFYUN_IAT_API_KEY",
            System.getProperty("xfyun.iat.api-key", "e62a7fb9f6df329179a58312aa13a418"));

    private static final Gson gson = new Gson();

    private final File audioFile;
    private final CountDownLatch latch = new CountDownLatch(1);
    private final StringBuilder finalResult = new StringBuilder();

    // 构造传入音频文件
    public IatModelZhMain(File audioFile) {
        this.audioFile = audioFile;
    }

    // 启动识别，返回识别结果
    public String startRecognition() throws Exception {
        String authUrl = getAuthUrl(hostUrl, apiKey, apiSecret);
        String wsUrl = authUrl.replace("https://", "wss://");

        OkHttpClient client = new OkHttpClient.Builder()
                .readTimeout(0, TimeUnit.MILLISECONDS)  // 不超时
                .build();

        Request request = new Request.Builder().url(wsUrl).build();
        WebSocket webSocket = client.newWebSocket(request, this);

        // 启动新线程发送音频数据
        new Thread(() -> {
            try (FileInputStream fs = new FileInputStream(audioFile)) {
                int frameSize = 1280; // 40ms音频数据大小
                int interval = 40;    // 40ms发一次
                int status = 0;       // 0：第一帧，1：中间帧，2：最后一帧
                int seq = 0;
                byte[] buffer = new byte[frameSize];
                boolean lastFrameSent = false;

                while (!lastFrameSent) {
                    seq++;
                    int len = fs.read(buffer);
                    if (len == -1) {
                        status = 2; // 读完了最后一帧
                    }
                    String audioBase64 = (len > 0) ? Base64.getEncoder().encodeToString(Arrays.copyOf(buffer, len)) : "";

                    String json = buildJson(appid, status, seq, audioBase64);
                    webSocket.send(json);

                    if (status == 2) {
                        lastFrameSent = true;
                    } else if (status == 0) {
                        status = 1; // 发送完第一帧切换到中间帧
                    }

                    Thread.sleep(interval);
                }

                System.out.println("所有音频发送完毕...");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();

        latch.await(); // 等待识别完成
        return finalResult.toString();
    }

    // 构造发送给讯飞的json数据
    private String buildJson(String appid, int status, int seq, String audioBase64) {
        return "{\n" +
                "  \"header\": {\"app_id\": \"" + appid + "\", \"status\": " + status + "},\n" +
                "  \"parameter\": {\n" +
                "    \"iat\": {\n" +
                "      \"domain\": \"slm\",\n" +
                "      \"language\": \"zh_cn\",\n" +
                "      \"accent\": \"mandarin\",\n" +
                "      \"eos\": 6000,\n" +
                "      \"vinfo\": 1,\n" +
                "      \"dwa\": \"wpgs\",\n" +
                "      \"result\": {\"encoding\": \"utf8\", \"compress\": \"raw\", \"format\": \"json\"}\n" +
                "    }\n" +
                "  },\n" +
                "  \"payload\": {\n" +
                "    \"audio\": {\n" +
                "      \"encoding\": \"raw\",\n" +
                "      \"sample_rate\": 16000,\n" +
                "      \"channels\": 1,\n" +
                "      \"bit_depth\": 16,\n" +
                "      \"seq\": " + seq + ",\n" +
                "      \"status\": " + status + ",\n" +
                "      \"audio\": \"" + audioBase64 + "\"\n" +
                "    }\n" +
                "  }\n" +
                "}";
    }

    private final StringBuilder builder = new StringBuilder();

    @Override
    public void onMessage(WebSocket webSocket, String text) {
        JsonParse jsonParse = gson.fromJson(text, JsonParse.class);
        if (jsonParse == null || jsonParse.header.code != 0) {
            return;
        }

        if (jsonParse.payload != null && jsonParse.payload.result != null && jsonParse.payload.result.text != null) {
            byte[] decodedBytes = Base64.getDecoder().decode(jsonParse.payload.result.text);
            String decodeRes = new String(decodedBytes, StandardCharsets.UTF_8);
            JsonParseText jsonParseText = gson.fromJson(decodeRes, JsonParseText.class);

            StringBuilder currentSegment = new StringBuilder();
            for (Ws ws : jsonParseText.ws) {
                for (Cw cw : ws.cw) {
                    currentSegment.append(cw.w);
                }
            }

            if ("apd".equals(jsonParseText.pgs)) {
                builder.append(currentSegment);
            } else if ("rpl".equals(jsonParseText.pgs)) {
                int start = jsonParseText.rg.get(0);
                int end = jsonParseText.rg.get(1) + 1;

                // ⭐️ 关键修复点：必须确保 builder 长度足够，防止非法索引
                if (start >= 0 && end <= builder.length()) {
                    builder.replace(start, end, currentSegment.toString());
                } else if (start >= 0) {
                    // 超出长度的情况：直接截断并追加
                    builder.setLength(start);
                    builder.append(currentSegment);
                }
            } else {
                // 没有pgs字段，直接追加
                builder.append(currentSegment);
            }

            // ⭐️ 正确的结束逻辑
            if (jsonParse.payload.result.status == 2) {
                finalResult.setLength(0);  // 清空原有
                finalResult.append(builder.toString());  // 最终拼接一次即可
                latch.countDown();
                webSocket.close(1000, "识别完成");
            }
        }
    }


    @Override
    public void onFailure(WebSocket webSocket, Throwable t, Response response) {
        System.err.println("WebSocket 连接失败");
        if (response != null) {
            System.err.println("响应码：" + response.code());
        }
        t.printStackTrace();
        latch.countDown();
    }

    @Override
    public void onOpen(WebSocket webSocket, Response response) {
        System.out.println("WebSocket 连接成功");
    }

    // 签名生成，生成带签名的鉴权URL
    public static String getAuthUrl(String hostUrl, String apiKey, String apiSecret) throws Exception {
        URL url = new URL(hostUrl);
        SimpleDateFormat sdf = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.US);
        sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
        String date = sdf.format(new Date());

        StringBuilder builder = new StringBuilder();
        builder.append("host: ").append(url.getHost()).append("\n");
        builder.append("date: ").append(date).append("\n");
        builder.append("GET ").append(url.getPath()).append(" HTTP/1.1");

        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKeySpec spec = new SecretKeySpec(apiSecret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        mac.init(spec);
        byte[] hash = mac.doFinal(builder.toString().getBytes(StandardCharsets.UTF_8));
        String signature = Base64.getEncoder().encodeToString(hash);

        String authorization = String.format(
                "api_key=\"%s\", algorithm=\"%s\", headers=\"host date request-line\", signature=\"%s\"",
                apiKey, "hmac-sha256", signature);

        String authBase64 = Base64.getEncoder().encodeToString(authorization.getBytes(StandardCharsets.UTF_8));

        return hostUrl + "?authorization=" + java.net.URLEncoder.encode(authBase64, "UTF-8")
                + "&date=" + java.net.URLEncoder.encode(date, "UTF-8")
                + "&host=" + java.net.URLEncoder.encode(url.getHost(), "UTF-8");
    }

    // 内部 JSON 类

    static class JsonParse {
        Header header;
        Payload payload;
    }

    static class Header {
        int code;
        String message;
        String sid;
        int status;
    }

    static class Payload {
        Result result;
    }

    static class Result {
        String text;
        int status;
    }

    static class JsonParseText {
        List<Ws> ws;
        String pgs;        // 标识是追加(apd)还是替换(rpl)
        List<Integer> rg;  // 替换范围（起始索引、结束索引）
    }

    static class Ws {
        List<Cw> cw;
    }

    static class Cw {
        String w;
    }
}
