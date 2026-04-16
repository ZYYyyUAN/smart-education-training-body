package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.config.XunfeiOCRConfig;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.codec.binary.Base64;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * 科大讯飞OCR服务类 - 严格按照官方Java Demo实现
 * 参考科大讯飞官方Java Demo: UniversalCharacterRecognition.java
 */
@Slf4j
@Service
public class XunfeiOCRServiceOfficial {

    @Autowired
    private XunfeiOCRConfig config;

    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * 执行OCR文字识别 - 严格按照官方Demo
     * @param imageBase64 图片的Base64编码
     * @return 识别出的文字内容
     */
    public String performOCR(String imageBase64) throws Exception {
        log.info("开始调用科大讯飞OCR服务 - 严格按照官方Demo");
        
        try {
            // 发送请求
            String response = doRequest(imageBase64);
            
            // 解析响应结果
            return parseOCRResponse(response);
            
        } catch (Exception e) {
            log.error("OCR识别失败", e);
            throw new Exception("OCR识别失败: " + e.getMessage());
        }
    }

    /**
     * 执行OCR文字识别 - 返回包含坐标信息的完整结果
     * @param imageBase64 图片的Base64编码
     * @return 包含坐标信息的OCR结果
     */
    public String performOCRWithCoordinates(String imageBase64) throws Exception {
        log.info("开始调用科大讯飞OCR服务 - 返回完整结果");
        
        try {
            // 发送请求
            String response = doRequest(imageBase64);
            
            // 解析响应结果，返回完整的JSON
            return parseOCRResponseWithCoordinates(response);
            
        } catch (Exception e) {
            log.error("OCR识别失败", e);
            throw new Exception("OCR识别失败: " + e.getMessage());
        }
    }

    /**
     * 请求主方法 - 严格按照官方Demo
     * @param imageBase64 图片Base64编码
     * @return 返回服务结果
     * @throws Exception 异常
     */
    public String doRequest(String imageBase64) throws Exception {
        URL realUrl = new URL(buildRequestUrl());
        HttpURLConnection httpURLConnection = (HttpURLConnection) realUrl.openConnection();
        httpURLConnection.setDoInput(true);
        httpURLConnection.setDoOutput(true);
        httpURLConnection.setRequestMethod("POST");
        httpURLConnection.setRequestProperty("Content-type", "application/json");
        
        OutputStream out = httpURLConnection.getOutputStream();
        String params = buildParam(imageBase64);
        log.info("请求参数: {}", params);
        out.write(params.getBytes(StandardCharsets.UTF_8));
        out.flush();
        
        InputStream is = null;
        try {
            is = httpURLConnection.getInputStream();
        } catch (Exception e) {
            is = httpURLConnection.getErrorStream();
            throw new Exception("make request error: code is " + httpURLConnection.getResponseMessage() + " " + readAllBytes(is));
        }
        return readAllBytes(is);
    }

    /**
     * 处理请求URL - 严格按照官方Demo
     * 封装鉴权参数等
     * @return 处理后的URL
     */
    public String buildRequestUrl() {
        try {
            String requestUrl = config.getApiUrl();
            // 替换调schema前缀 ，原因是URL库不支持解析包含ws,wss schema的url
            String httpRequestUrl = requestUrl.replace("ws://", "http://").replace("wss://", "https://");
            URL url = new URL(httpRequestUrl);
            
            // 获取当前日期并格式化
            SimpleDateFormat format = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.US);
            format.setTimeZone(TimeZone.getTimeZone("GMT"));
            String date = format.format(new Date());
            String host = url.getHost();
            
            StringBuilder builder = new StringBuilder("host: ").append(host).append("\n").//
                    append("date: ").append(date).append("\n").//
                    append("POST ").append(url.getPath()).append(" HTTP/1.1");
            
            log.info("签名原始字符串: {}", builder.toString());
            
            Mac mac = Mac.getInstance("hmacsha256");
            SecretKeySpec spec = new SecretKeySpec(config.getApiSecret().getBytes(StandardCharsets.UTF_8), "hmacsha256");
            mac.init(spec);
            byte[] hexDigits = mac.doFinal(builder.toString().getBytes(StandardCharsets.UTF_8));
            String sha = Base64.encodeBase64String(hexDigits);
            
            String authorization = String.format("api_key=\"%s\", algorithm=\"%s\", headers=\"%s\", signature=\"%s\"", 
                    config.getApiKey(), "hmac-sha256", "host date request-line", sha);
            String authBase = Base64.encodeBase64String(authorization.getBytes(StandardCharsets.UTF_8));
            
            String finalUrl = String.format("%s?authorization=%s&host=%s&date=%s", 
                    requestUrl, URLEncoder.encode(authBase, StandardCharsets.UTF_8), 
                    URLEncoder.encode(host, StandardCharsets.UTF_8), 
                    URLEncoder.encode(date, StandardCharsets.UTF_8));
            
            log.info("生成的鉴权URL: {}", finalUrl);
            return finalUrl;
            
        } catch (Exception e) {
            throw new RuntimeException("assemble requestUrl error: " + e.getMessage());
        }
    }

    /**
     * 组装请求参数 - 严格按照官方Demo
     * @param imageBase64 图片Base64编码
     * @return 参数字符串
     */
    private String buildParam(String imageBase64) {
        String param = "{" +
                "    \"header\": {" +
                "        \"app_id\": \"" + config.getAppId() + "\"," +
                "        \"status\": 3" +
                "    }," +
                "    \"parameter\": {" +
                "        \"sf8e6aca1\": {" +
                "            \"category\": \"ch_en_public_cloud\"," +
                "            \"result\": {" +
                "                \"encoding\": \"utf8\"," +
                "                \"compress\": \"raw\"," +
                "                \"format\": \"json\"" +
                "            }" +
                "        }" +
                "    }," +
                "    \"payload\": {" +
                "        \"sf8e6aca1_data_1\": {" +
                "            \"encoding\": \"jpg\"," +
                "            \"status\": " + 3 + "," +
                "            \"image\": \"" + imageBase64 + "\"" +
                "        }" +
                "    }" +
                "}";
        return param;
    }

    /**
     * 读取流数据 - 严格按照官方Demo
     * @param is 流
     * @return 字符串
     * @throws IOException 异常
     */
    private String readAllBytes(InputStream is) throws IOException {
        byte[] b = new byte[1024];
        StringBuilder sb = new StringBuilder();
        int len = 0;
        while ((len = is.read(b)) != -1) {
            sb.append(new String(b, 0, len, StandardCharsets.UTF_8));
        }
        return sb.toString();
    }

    /**
     * 解析OCR响应结果 - 提取纯文本内容
     */
    private String parseOCRResponse(String response) throws Exception {
        log.info("解析OCR响应结果");
        
        try {
            JsonNode rootNode = objectMapper.readTree(response);
            
            // 检查header中的错误码
            if (rootNode.has("header")) {
                JsonNode header = rootNode.get("header");
                if (header.has("code")) {
                    int code = header.get("code").asInt();
                    if (code != 0) {
                        String message = header.has("message") ? header.get("message").asText() : "未知错误";
                        String sid = header.has("sid") ? header.get("sid").asText() : "";
                        throw new Exception("OCR识别失败: " + message + " (错误代码: " + code + ", SID: " + sid + ")");
                    }
                }
            }
            
            // 按照官方Demo格式解析：payload.result.text
            if (rootNode.has("payload")) {
                JsonNode payload = rootNode.get("payload");
                if (payload.has("result")) {
                    JsonNode result = payload.get("result");
                    if (result.has("text")) {
                        String textBase64 = result.get("text").asText();
                        // 按照官方Demo，需要Base64解码
                        try {
                            byte[] decodedBytes = Base64.decodeBase64(textBase64);
                            String decodedText = new String(decodedBytes, StandardCharsets.UTF_8);
                            
                            // 解析JSON格式的OCR结果，提取纯文本
                            String pureText = extractPureTextFromOCRResult(decodedText);
                            
                            log.info("OCR识别成功，识别文字长度: {}", pureText.length());
                            return pureText;
                        } catch (Exception e) {
                            log.info("Base64解码失败，使用原始文本");
                            return textBase64;
                        }
                    }
                }
            }
            
            throw new Exception("OCR响应中未找到识别结果");
            
        } catch (Exception e) {
            log.error("解析OCR响应失败", e);
            throw new Exception("解析OCR响应失败: " + e.getMessage() + "。原始响应: " + response);
        }
    }
    
    /**
     * 从OCR JSON结果中提取纯文本内容
     */
    private String extractPureTextFromOCRResult(String jsonText) throws Exception {
        try {
            JsonNode rootNode = objectMapper.readTree(jsonText);
            StringBuilder textBuilder = new StringBuilder();
            
            // 解析pages数组
            if (rootNode.has("pages") && rootNode.get("pages").isArray()) {
                JsonNode pages = rootNode.get("pages");
                
                for (JsonNode page : pages) {
                    // 解析lines数组
                    if (page.has("lines") && page.get("lines").isArray()) {
                        JsonNode lines = page.get("lines");
                        
                        for (JsonNode line : lines) {
                            // 解析words数组
                            if (line.has("words") && line.get("words").isArray()) {
                                JsonNode words = line.get("words");
                                
                                for (JsonNode word : words) {
                                    if (word.has("content")) {
                                        String content = word.get("content").asText();
                                        textBuilder.append(content);
                                    }
                                }
                            }
                            // 每行结束后添加换行符
                            textBuilder.append("\n");
                        }
                    }
                }
            }
            
            String result = textBuilder.toString().trim();
            log.info("提取纯文本成功，长度: {}", result.length());
            return result;
            
        } catch (Exception e) {
            log.error("解析OCR JSON结果失败，返回原始文本", e);
            // 如果解析失败，返回原始文本
            return jsonText;
        }
    }

    /**
     * 解析OCR响应结果 - 返回包含坐标信息的完整JSON
     */
    private String parseOCRResponseWithCoordinates(String response) throws Exception {
        log.info("解析OCR响应结果 - 返回完整JSON");
        
        try {
            JsonNode rootNode = objectMapper.readTree(response);
            
            // 检查header中的错误码
            if (rootNode.has("header")) {
                JsonNode header = rootNode.get("header");
                if (header.has("code")) {
                    int code = header.get("code").asInt();
                    if (code != 0) {
                        String message = header.has("message") ? header.get("message").asText() : "未知错误";
                        String sid = header.has("sid") ? header.get("sid").asText() : "";
                        throw new Exception("OCR识别失败: " + message + " (错误代码: " + code + ", SID: " + sid + ")");
                    }
                }
            }
            
            // 按照官方Demo格式解析：payload.result.text
            if (rootNode.has("payload")) {
                JsonNode payload = rootNode.get("payload");
                if (payload.has("result")) {
                    JsonNode result = payload.get("result");
                    if (result.has("text")) {
                        String textBase64 = result.get("text").asText();
                        // 按照官方Demo，需要Base64解码
                        try {
                            byte[] decodedBytes = Base64.decodeBase64(textBase64);
                            String decodedText = new String(decodedBytes, StandardCharsets.UTF_8);
                            
                            log.info("OCR识别成功，返回完整JSON结果");
                            return decodedText;
                        } catch (Exception e) {
                            log.info("Base64解码失败，使用原始文本");
                            return textBase64;
                        }
                    }
                }
            }
            
            throw new Exception("OCR响应中未找到识别结果");
            
        } catch (Exception e) {
            log.error("解析OCR响应失败", e);
            throw new Exception("解析OCR响应失败: " + e.getMessage() + "。原始响应: " + response);
        }
    }
}
