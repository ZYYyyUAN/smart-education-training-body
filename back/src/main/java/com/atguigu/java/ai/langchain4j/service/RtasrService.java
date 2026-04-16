package com.atguigu.java.ai.langchain4j.service;
import cn.xfyun.api.RtasrClient;
import cn.xfyun.model.response.rtasr.RtasrResponse;
import cn.xfyun.service.rta.AbstractRtasrWebSocketListener;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.atguigu.java.ai.langchain4j.util.MicrophoneRecorderUtil;
import okhttp3.Response;
import okhttp3.WebSocket;
import org.apache.commons.codec.binary.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import okio.ByteString;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.Nullable;
import javax.sound.sampled.LineUnavailableException;
import java.io.IOException;
import java.io.InputStream;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.security.SignatureException;
import java.util.concurrent.CountDownLatch;

@Service
public class RtasrService {

    private static final Logger logger = LoggerFactory.getLogger(RtasrService.class);

    @Value("${xfyun.app-id}")
    private String appId;

    @Value("${xfyun.api-key}")
    private String apiKey;

    private StringBuffer finalResult;
    private CountDownLatch latch;

    /**
     * 调用科大讯飞实时转写服务
     */
    public String startMicrophoneRecognition() {
        finalResult = new StringBuffer();
        MicrophoneRecorderUtil recorder = null;
        PipedInputStream in = null;
        PipedOutputStream out = null;

        try {
            in = new PipedInputStream(1280);
            out = new PipedOutputStream(in);
            recorder = new MicrophoneRecorderUtil();
            recorder.startRecording(out);

            RtasrClient client = new RtasrClient.Builder()
                    .signature(appId, apiKey)
                    .build();

            latch = new CountDownLatch(1);

            client.send(in, new AbstractRtasrWebSocketListener() {
                @Override
                public void onSuccess(WebSocket webSocket, String text) {
                    RtasrResponse response = JSONObject.parseObject(text, RtasrResponse.class);
                    String temp = handleAndReturnContent(response.getData());
                    logger.info("识别中: {}", finalResult + temp);
                }

                @Override
                public void onFail(WebSocket webSocket, Throwable t, @Nullable Response response) {
                    logger.error("连接失败", t);
                    latch.countDown();
                }

                @Override
                public void onBusinessFail(WebSocket webSocket, String text) {
                    logger.error("业务错误：{}", text);
                    latch.countDown();
                }

                @Override
                public void onClosing(WebSocket webSocket, int code, String reason) {
                    latch.countDown();
                }

                @Override
                public void onClosed() {
                    latch.countDown();
                }
            });

            logger.info("录音中（10秒），请开始说话...");
            Thread.sleep(5000); // 实际使用建议由前端控制
            client.sendEnd();

            latch.await();
            return finalResult.toString();

        } catch (Exception e) {
            throw new RuntimeException("实时识别失败", e);
        } finally {
            if (recorder != null) recorder.stopRecording();
        }
    }

    private String handleAndReturnContent(String message) {
        StringBuilder tempResult = new StringBuilder();
        try {
            JSONObject messageObj = JSON.parseObject(message);
            JSONObject cn = messageObj.getJSONObject("cn");
            JSONObject st = cn.getJSONObject("st");
            JSONArray rtArr = st.getJSONArray("rt");
            for (int i = 0; i < rtArr.size(); i++) {
                JSONArray wsArr = rtArr.getJSONObject(i).getJSONArray("ws");
                for (int j = 0; j < wsArr.size(); j++) {
                    JSONArray cwArr = wsArr.getJSONObject(j).getJSONArray("cw");
                    for (int k = 0; k < cwArr.size(); k++) {
                        tempResult.append(cwArr.getJSONObject(k).getString("w"));
                    }
                }
            }

            String type = st.getString("type");
            if (StringUtils.equals("1", type)) {
                return tempResult.toString();
            } else if (StringUtils.equals("0", type)) {
                finalResult.append(tempResult);
                return "";
            } else {
                return tempResult.toString();
            }
        } catch (Exception e) {
            return message;
        }
    }
    public String recognizeFromInputStream(InputStream inputStream) {
        finalResult = new StringBuffer();
        PipedInputStream pipedInput = null;
        PipedOutputStream pipedOutput = null;

        try {
            // 🔧 初始化用于桥接 inputStream 的管道流
            pipedInput = new PipedInputStream(1024 * 8);
            pipedOutput = new PipedOutputStream(pipedInput);

            // 🔧 启动线程，将 inputStream 数据写入 pipedOutput
            InputStream finalInputStream = inputStream;
            PipedOutputStream finalPipedOutput = pipedOutput;
            new Thread(() -> {
                try {
                    byte[] buffer = new byte[1024];
                    int len;
                    while ((len = finalInputStream.read(buffer)) != -1) {
                        finalPipedOutput.write(buffer, 0, len);
                        finalPipedOutput.flush();
                    }
                    finalPipedOutput.close(); // 结束后关闭
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }).start();

            // ✅ 初始化讯飞 client
            RtasrClient client = new RtasrClient.Builder()
                    .signature(appId, apiKey)
                    .build();

            latch = new CountDownLatch(1);

            // ✅ 发送 pipedInput 到科大讯飞进行识别
            client.send(pipedInput, new AbstractRtasrWebSocketListener() {
                @Override
                public void onSuccess(WebSocket webSocket, String text) {
                    RtasrResponse response = JSONObject.parseObject(text, RtasrResponse.class);
                    String temp = handleAndReturnContent(response.getData());
                    logger.info("识别中: {}", finalResult + temp);
                }

                @Override
                public void onFail(WebSocket webSocket, Throwable t, @Nullable Response response) {
                    logger.error("连接失败", t);
                    latch.countDown();
                }

                @Override
                public void onBusinessFail(WebSocket webSocket, String text) {
                    logger.error("业务错误：{}", text);
                    latch.countDown();
                }

                @Override
                public void onClosing(WebSocket webSocket, int code, String reason) {
                    latch.countDown();
                }

                @Override
                public void onClosed() {
                    latch.countDown();
                }
            });

            // 🔒 等待识别结束
            latch.await();
            return finalResult.toString();

        } catch (Exception e) {
            throw new RuntimeException("从 InputStream 识别失败", e);
        } finally {
            try {
                if (pipedInput != null) pipedInput.close();
            } catch (IOException ignored) {
            }
        }
    }

}
