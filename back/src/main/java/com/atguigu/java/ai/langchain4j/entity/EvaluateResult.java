package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

@Data
public class EvaluateResult {
    private Integer score;
    private Boolean isCorrect;
    private String errorReason;
}