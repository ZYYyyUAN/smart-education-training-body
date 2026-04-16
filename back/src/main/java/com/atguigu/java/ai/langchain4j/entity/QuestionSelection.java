package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

/**
 * 题目选择结果
 */
@Data
public class QuestionSelection {
    private Long questionId;
    private String reason;
    private Integer difficulty;
    private Integer estimatedTime;
    private String knowledgePoint;
    private String aiSelectionReason;
}
