package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class PracticeLogVO {
    private Long logId;
    private String questionContent;
    private String studentAnswer;
    private Boolean isCorrect;
    private String errorReason;
    private Integer score;
    private LocalDateTime submittedAt;
}
