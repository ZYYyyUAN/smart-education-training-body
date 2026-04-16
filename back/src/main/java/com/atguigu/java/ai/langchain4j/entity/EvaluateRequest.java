package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

@Data
public class EvaluateRequest {
    private Long memoryId;
    private Long questionId;     // 👈 通过题库ID查询题干和标准答案
    private String answer;       // 学生作答内容
}