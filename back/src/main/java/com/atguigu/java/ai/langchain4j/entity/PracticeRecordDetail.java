package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class PracticeRecordDetail {
    private Long id;
    private Long practiceRecordId;
    private Long questionId;
    private String questionType;
    private String questionContent;
    private String knowledgePoint; // 添加知识点字段
    private String userAnswer;
    private String correctAnswer;
    private Integer score;
    private Boolean isCorrect;
    private LocalDateTime createTime;
} 