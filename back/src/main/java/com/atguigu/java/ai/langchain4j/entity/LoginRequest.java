package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

@Data
public class LoginRequest {
    private String username;
    private String password;
    private String captcha; // user entered captcha
    private String captchaKey; // from cookie or header if frontend passes
}