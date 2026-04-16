package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

@Data
public class CreateAnswerRequest {
    private Integer questionId;
    private Integer userId;
    private String content;
} 