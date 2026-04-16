package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

@Data
public class EvaluationResult {
    private int score;        // 评分（0-100）
    private String feedback;  // 简要反馈（包含错误指出和建议）
}
