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
 * 科大讯飞OCR服务类 - 严格按照官方文档实现
 * 参考科大讯飞OCR官方API文档
 */
@Slf4j
@Service
public class XunfeiOCRServiceCorrect {

    @Autowired
    private XunfeiOCRConfig config;

    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * 执行OCR文字识别 - 按照官方文档
     * @param imageBase64 图片的Base64编码
     * @return 识别出的文字内容
     */
    public String performOCR(String imageBase64) throws Exception {
        log.info("开始调用科大讯飞OCR服务 - 严格按照官方文档");
        
        try {
            // 生成鉴权URL
            String authUrl = generateAuthUrl();
            
            // 构建请求体 - 严格按照官方文档格式
            String requestBody = buildOfficialRequestBody(imageBase64);
            
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
     * 构建请求体 - 严格按照科大讯飞官方文档格式
     */
    private String buildOfficialRequestBody(String imageBase64) throws Exception {
        Map<String, Object> requestData = new HashMap<>();
        
        // common部分 - 公共参数
        Map<String, String> common = new HashMap<>();
        common.put("app_id", config.getAppId());
        requestData.put("common", common);
        
        // business部分 - 业务参数
        Map<String, String> business = new HashMap<>();
        business.put("language", "cn|en");
        business.put("domain", "universal");
        requestData.put("business", business);
        
        // data部分 - 业务数据
        Map<String, String> data = new HashMap<>();
        data.put("status", "0");
        data.put("format", "webp");
        data.put("encoding", "raw");
        data.put("image", imageBase64);
        requestData.put("data", data);
        
        String json = objectMapper.writeValueAsString(requestData);
        log.info("构建的官方格式请求体结构: common -> app_id, business -> language/domain, data -> status/format/encoding/image");
        log.info("请求体长度: {}", json.length());
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
     * 发送HTTP请求 - 使用标准JSON格式
     */
    private String sendHttpRequest(String url, String requestBody) throws IOException {
        log.info("发送OCR请求到: {}", url);
        
        java.net.URL apiUrl = new java.net.URL(url);
        java.net.HttpURLConnection connection = (java.net.HttpURLConnection) apiUrl.openConnection();
        
        try {
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "application/json");
            connection.setRequestProperty("Accept", "application/json");
            connection.setRequestProperty("User-Agent", "Java/1.8");
            connection.setDoOutput(true);
            connection.setDoInput(true);
            connection.setConnectTimeout(10000);
            connection.setReadTimeout(30000);
            
            log.info("发送官方格式请求体...");
            
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
     * 解析OCR响应结果 - 按照科大讯飞官方响应格式
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
            
            // 尝试提取文字内容 - 按照科大讯飞官方响应格式
            String ocrText = extractTextFromOfficialResponse(rootNode);
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
     * 从响应中提取文字内容 - 按照科大讯飞官方响应格式
     */
    private String extractTextFromOfficialResponse(JsonNode rootNode) {
        // 科大讯飞OCR官方响应格式: payload.result.text
        if (rootNode.has("payload")) {
            JsonNode payload = rootNode.get("payload");
            if (payload.has("result")) {
                JsonNode result = payload.get("result");
                
                // result可能是Base64编码的数据，需要解码
                if (result.has("text")) {
                    String textBase64 = result.get("text").asText();
                    try {
                        // 尝试Base64解码
                        byte[] decodedBytes = Base64.decodeBase64(textBase64);
                        String decodedText = new String(decodedBytes, StandardCharsets.UTF_8);
                        log.info("成功解码Base64文本内容");
                        return decodedText;
                    } catch (Exception e) {
                        // 如果解码失败，可能本身就是普通文本
                        log.info("Base64解码失败，使用原始文本");
                        return textBase64;
                    }
                }
                
                // 直接字符串格式
                if (result.isTextual()) {
                    return result.asText();
                }
            }
        }
        
        return null;
    }
}
