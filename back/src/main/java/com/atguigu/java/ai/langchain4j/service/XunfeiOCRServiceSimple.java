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
 * 科大讯飞OCR服务类 - 简化版本
 * 基于科大讯飞官方文档示例
 */
@Slf4j
@Service
public class XunfeiOCRServiceSimple {

    @Autowired
    private XunfeiOCRConfig config;

    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * 执行OCR文字识别 - 简化版本
     * @param imageBase64 图片的Base64编码
     * @return 识别出的文字内容
     */
    public String performOCR(String imageBase64) throws Exception {
        log.info("开始调用科大讯飞OCR服务 - 简化版本");
        
        try {
            // 生成鉴权URL
            String authUrl = generateAuthUrl();
            
            // 发送HTTP请求
            String response = sendHttpRequest(authUrl, imageBase64);
            
            // 解析响应结果
            return parseOCRResponse(response);
            
        } catch (Exception e) {
            log.error("OCR识别失败", e);
            throw new Exception("OCR识别失败: " + e.getMessage());
        }
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
        
        log.info("签名原始字符串: {}", signatureOrigin);
        
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
     * 发送HTTP请求 - 使用JSON格式
     */
    private String sendHttpRequest(String url, String imageBase64) throws IOException {
        log.info("发送OCR请求到: {}", url);
        
        java.net.URL apiUrl = new java.net.URL(url);
        java.net.HttpURLConnection connection = (java.net.HttpURLConnection) apiUrl.openConnection();
        
        try {
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "application/json");
            connection.setRequestProperty("Accept", "application/json");
            connection.setDoOutput(true);
            
            // 构建JSON数据 - 根据科大讯飞文档格式
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("image", imageBase64);
            
            String jsonData = objectMapper.writeValueAsString(requestBody);
            log.info("JSON数据长度: {}", jsonData.length());
            
            // 发送请求
            try (java.io.OutputStream os = connection.getOutputStream()) {
                byte[] input = jsonData.getBytes(StandardCharsets.UTF_8);
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
     * 解析OCR响应结果 - 简化版本
     */
    private String parseOCRResponse(String response) throws Exception {
        log.info("解析OCR响应结果");
        
        try {
            JsonNode rootNode = objectMapper.readTree(response);
            
            // 先尝试检查是否有错误
            if (rootNode.has("code")) {
                int code = rootNode.get("code").asInt();
                if (code != 0) {
                    String message = rootNode.has("desc") ? rootNode.get("desc").asText() : 
                                   rootNode.has("message") ? rootNode.get("message").asText() : "未知错误";
                    throw new Exception("OCR识别失败: " + message + " (错误代码: " + code + ")");
                }
            }
            
            // 尝试提取文字内容 - 根据科大讯飞可能的响应格式
            String ocrText = extractTextFromResponse(rootNode);
            if (ocrText != null && !ocrText.trim().isEmpty()) {
                log.info("OCR识别成功，识别文字长度: {}", ocrText.length());
                return ocrText;
            }
            
            throw new Exception("OCR响应中未找到识别结果");
            
        } catch (Exception e) {
            log.error("解析OCR响应失败", e);
            throw new Exception("解析OCR响应失败: " + e.getMessage() + "。原始响应: " + response);
        }
    }
    
    /**
     * 从响应中提取文字内容
     */
    private String extractTextFromResponse(JsonNode rootNode) {
        // 尝试多种可能的响应格式
        
        // 格式1: data.result.text
        if (rootNode.has("data")) {
            JsonNode data = rootNode.get("data");
            if (data.has("result")) {
                JsonNode result = data.get("result");
                if (result.has("text")) {
                    return result.get("text").asText();
                }
                // 如果result是数组
                if (result.isArray()) {
                    StringBuilder textBuilder = new StringBuilder();
                    for (JsonNode item : result) {
                        if (item.has("words")) {
                            textBuilder.append(item.get("words").asText()).append("\n");
                        } else if (item.has("text")) {
                            textBuilder.append(item.get("text").asText()).append("\n");
                        }
                    }
                    return textBuilder.toString().trim();
                }
            }
        }
        
        // 格式2: result.text
        if (rootNode.has("result")) {
            JsonNode result = rootNode.get("result");
            if (result.has("text")) {
                return result.get("text").asText();
            }
        }
        
        // 格式3: text直接在根节点
        if (rootNode.has("text")) {
            return rootNode.get("text").asText();
        }
        
        return null;
    }
}
