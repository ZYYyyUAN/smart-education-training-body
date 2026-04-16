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
 * 科大讯飞OCR服务类 - 最终版本
 * 严格按照官方文档实现
 */
@Slf4j
@Service
public class XunfeiOCRServiceFinal {

    @Autowired
    private XunfeiOCRConfig config;

    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * 执行OCR文字识别
     */
    public String performOCR(String imageBase64) throws Exception {
        log.info("开始调用科大讯飞OCR服务 - 最终版本");
        
        try {
            // 生成鉴权URL
            String authUrl = generateAuthUrl();
            
            // 构建请求体
            String requestBody = buildRequestBody(imageBase64);
            
            // 发送HTTP请求
            String response = sendHttpRequest(authUrl, requestBody);
            
            // 解析响应结果
            return parseOCRResponse(response);
            
        } catch (Exception e) {
            log.error("OCR识别失败", e);
            throw new Exception("OCR识别失败: " + e.getMessage());
        }
    }

    /**
     * 构建请求体 - 按照科大讯飞官方格式
     */
    private String buildRequestBody(String imageBase64) throws Exception {
        Map<String, Object> requestData = new HashMap<>();
        
        // common部分
        Map<String, Object> common = new HashMap<>();
        common.put("app_id", config.getAppId());
        requestData.put("common", common);
        
        // business部分
        Map<String, Object> business = new HashMap<>();
        business.put("language", "cn|en");
        business.put("location", "false");
        requestData.put("business", business);
        
        // data部分
        Map<String, Object> data = new HashMap<>();
        data.put("image", imageBase64);
        requestData.put("data", data);
        
        String json = objectMapper.writeValueAsString(requestData);
        log.info("构建的请求体: {}", json);
        return json;
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
     * 发送HTTP请求
     */
    private String sendHttpRequest(String url, String requestBody) throws IOException {
        log.info("发送OCR请求到: {}", url);
        
        java.net.URL apiUrl = new java.net.URL(url);
        java.net.HttpURLConnection connection = (java.net.HttpURLConnection) apiUrl.openConnection();
        
        try {
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "application/json");
            connection.setRequestProperty("Accept", "application/json");
            connection.setRequestProperty("User-Agent", "Mozilla/5.0");
            connection.setDoOutput(true);
            connection.setDoInput(true);
            
            log.info("请求体长度: {}", requestBody.length());
            
            // 发送请求
            try (java.io.OutputStream os = connection.getOutputStream()) {
                byte[] input = requestBody.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
                os.flush();
            }
            
            // 读取响应
            int responseCode = connection.getResponseCode();
            log.info("响应状态码: {}", responseCode);
            
            java.io.BufferedReader reader;
            if (responseCode >= 200 && responseCode < 300) {
                reader = new java.io.BufferedReader(new java.io.InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8));
            } else {
                reader = new java.io.BufferedReader(new java.io.InputStreamReader(connection.getErrorStream(), StandardCharsets.UTF_8));
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
        
        try {
            JsonNode rootNode = objectMapper.readTree(response);
            
            // 检查是否有错误码
            if (rootNode.has("code")) {
                int code = rootNode.get("code").asInt();
                if (code != 0) {
                    String message = rootNode.has("desc") ? rootNode.get("desc").asText() : 
                                   rootNode.has("message") ? rootNode.get("message").asText() : "未知错误";
                    throw new Exception("OCR识别失败: " + message + " (错误代码: " + code + ")");
                }
            }
            
            // 检查响应中的message字段（可能是错误信息）
            if (rootNode.has("message") && !rootNode.has("data")) {
                String message = rootNode.get("message").asText();
                throw new Exception("OCR API错误: " + message);
            }
            
            // 提取识别结果
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
        // 尝试科大讯飞可能的响应格式
        
        // 格式1: data.result
        if (rootNode.has("data")) {
            JsonNode data = rootNode.get("data");
            if (data.has("result")) {
                JsonNode result = data.get("result");
                
                // result可能是字符串
                if (result.isTextual()) {
                    return result.asText();
                }
                
                // result可能是对象包含text
                if (result.has("text")) {
                    return result.get("text").asText();
                }
                
                // result可能是数组
                if (result.isArray()) {
                    StringBuilder textBuilder = new StringBuilder();
                    for (JsonNode item : result) {
                        if (item.has("words")) {
                            textBuilder.append(item.get("words").asText()).append("\n");
                        } else if (item.has("text")) {
                            textBuilder.append(item.get("text").asText()).append("\n");
                        } else if (item.isTextual()) {
                            textBuilder.append(item.asText()).append("\n");
                        }
                    }
                    return textBuilder.toString().trim();
                }
            }
        }
        
        // 格式2: result直接在根节点
        if (rootNode.has("result")) {
            JsonNode result = rootNode.get("result");
            if (result.isTextual()) {
                return result.asText();
            }
            if (result.has("text")) {
                return result.get("text").asText();
            }
        }
        
        // 格式3: text直接在根节点
        if (rootNode.has("text")) {
            return rootNode.get("text").asText();
        }
        
        // 格式4: words字段
        if (rootNode.has("words")) {
            return rootNode.get("words").asText();
        }
        
        return null;
    }
}
