package com.atguigu.java.ai.langchain4j.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * 科大讯飞OCR配置类
 */
@Data
@Component
@ConfigurationProperties(prefix = "xunfei.ocr")
public class XunfeiOCRConfig {
    
    /**
     * 科大讯飞APPID
     */
    private String appId = "7bbdbf61";
    
    /**
     * 科大讯飞APIKey
     */
    private String apiKey = "2767e52f178a3a51fffcaf59938b7cbf";
    
    /**
     * 科大讯飞APISecret
     */
    private String apiSecret = "YWRlMTg2YjM5MGI4YWVlYjllZjJhZTc0";
    
    /**
     * OCR接口地址
     */
    private String apiUrl = "https://api.xf-yun.com/v1/private/sf8e6aca1";
    
    /**
     * 请求主机
     */
    private String host = "api.xf-yun.com";
}
