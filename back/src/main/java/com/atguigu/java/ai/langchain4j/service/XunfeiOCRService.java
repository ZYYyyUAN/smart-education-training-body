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
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * 科大讯飞OCR服务类
 */
@Slf4j
@Service
public class XunfeiOCRService {

    @Autowired
    private XunfeiOCRConfig config;

    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * 执行OCR文字识别
     * @param imageBase64 图片的Base64编码
     * @return 识别出的文字内容
     */
    public String performOCR(String imageBase64) throws Exception {
        log.info("开始调用科大讯飞OCR服务");
        
        // 构建请求参数
        String requestData = buildRequestData(imageBase64);
        
        // 生成鉴权URL
        String authUrl = generateAuthUrl();
        
        // 发送HTTP请求
        String response = sendHttpRequest(authUrl, requestData);
        
        // 解析响应结果
        return parseOCRResponse(response);
    }

    /**
     * 构建请求数据
     * 根据科大讯飞官方文档重新构建正确的请求格式
     */
    private String buildRequestData(String imageBase64) {
        // 根据科大讯飞OCR文档，直接使用base64编码的图片数据
        // 请求体就是图片的base64编码字符串
        log.info("构建的请求数据为base64图片，长度: {}", imageBase64.length());
        return imageBase64;
    }

    /**
     * 生成鉴权URL
     */
    private String generateAuthUrl() throws Exception {
        // 获取当前时间戳
        SimpleDateFormat sdf = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.US);
        sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
        String date = sdf.format(new Date());
        
        // 构建签名原始字符串
        String signatureOrigin = "host: " + config.getHost() + "\n";
        signatureOrigin += "date: " + date + "\n";
        signatureOrigin += "POST /v1/private/sf8e6aca1 HTTP/1.1";
        
        // 使用HMAC-SHA256计算签名
        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKeySpec secretKeySpec = new SecretKeySpec(config.getApiSecret().getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        mac.init(secretKeySpec);
        byte[] signatureBytes = mac.doFinal(signatureOrigin.getBytes(StandardCharsets.UTF_8));
        String signature = Base64.encodeBase64String(signatureBytes);
        
        // 构建authorization
        String authorizationOrigin = "api_key=\"" + config.getApiKey() + "\", algorithm=\"hmac-sha256\", headers=\"host date request-line\", signature=\"" + signature + "\"";
        String authorization = Base64.encodeBase64String(authorizationOrigin.getBytes(StandardCharsets.UTF_8));
        
        // 构建完整URL
        String url = config.getApiUrl() + "?authorization=" + URLEncoder.encode(authorization, StandardCharsets.UTF_8);
        url += "&date=" + URLEncoder.encode(date, StandardCharsets.UTF_8);
        url += "&host=" + URLEncoder.encode(config.getHost(), StandardCharsets.UTF_8);
        
        log.info("生成的鉴权URL: {}", url);
        return url;
    }

    /**
     * 发送HTTP请求
     */
    private String sendHttpRequest(String url, String requestData) throws IOException {
        log.info("发送OCR请求到: {}", url);
        
        // 使用Java内置的HttpURLConnection发送请求
        java.net.URL apiUrl = new java.net.URL(url);
        java.net.HttpURLConnection connection = (java.net.HttpURLConnection) apiUrl.openConnection();
        
        try {
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            connection.setRequestProperty("Accept", "application/json");
            connection.setDoOutput(true);
            
            // 发送请求数据 - 科大讯飞OCR需要发送base64编码的图片数据
            String postData = "image=" + URLEncoder.encode(requestData, StandardCharsets.UTF_8);
            log.info("请求数据长度: {}", postData.length());
            
            try (java.io.OutputStream os = connection.getOutputStream()) {
                byte[] input = postData.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }
            
            // 读取响应
            int responseCode = connection.getResponseCode();
            log.info("响应状态码: {}", responseCode);
            
            java.io.BufferedReader reader;
            if (responseCode >= 200 && responseCode < 300) {
                reader = new java.io.BufferedReader(new java.io.InputStreamReader(connection.getInputStream()));
            } else {
                reader = new java.io.BufferedReader(new java.io.InputStreamReader(connection.getErrorStream()));
            }
            
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
            reader.close();
            
            String responseText = response.toString();
            log.info("OCR响应: {}", responseText);
            
            return responseText;
            
        } finally {
            connection.disconnect();
        }
    }

    /**
     * 解析OCR响应结果
     */
    private String parseOCRResponse(String response) throws Exception {
        log.info("解析OCR响应结果");
        
        JsonNode rootNode = objectMapper.readTree(response);
        
        // 检查响应状态 - 科大讯飞可能使用code字段
        JsonNode codeNode = rootNode.get("code");
        if (codeNode != null) {
            int code = codeNode.asInt();
            if (code != 0) {
                String message = rootNode.has("desc") ? rootNode.get("desc").asText() : "未知错误";
                throw new Exception("OCR识别失败: " + message);
            }
        }
        
        // 检查data字段中的状态
        JsonNode data = rootNode.get("data");
        if (data != null) {
            JsonNode status = data.get("status");
            if (status != null && status.asInt() != 0) {
                String message = data.has("message") ? data.get("message").asText() : "识别失败";
                throw new Exception("OCR识别失败: " + message);
            }
            
            // 提取识别结果 - 科大讯飞OCR结果通常在data.result中
            JsonNode result = data.get("result");
            if (result != null) {
                // 如果result是数组，提取所有文字
                if (result.isArray()) {
                    StringBuilder textBuilder = new StringBuilder();
                    for (JsonNode item : result) {
                        if (item.has("words")) {
                            textBuilder.append(item.get("words").asText()).append("\n");
                        }
                    }
                    String ocrText = textBuilder.toString().trim();
                    log.info("OCR识别成功，识别文字长度: {}", ocrText.length());
                    return ocrText;
                } else if (result.has("text")) {
                    // 如果result是对象且有text字段
                    String ocrText = result.get("text").asText();
                    log.info("OCR识别成功，识别文字长度: {}", ocrText.length());
                    return ocrText;
                }
            }
        }
        
        throw new Exception("OCR响应格式错误，无法提取识别结果。响应内容: " + response);
    }
}
