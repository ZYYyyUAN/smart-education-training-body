package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

@Data
public class GenerateSimilarRequest {
    private Long questionId; // 学生点击的原题 ID
    private int count = 3;   // 默认生成一题
}