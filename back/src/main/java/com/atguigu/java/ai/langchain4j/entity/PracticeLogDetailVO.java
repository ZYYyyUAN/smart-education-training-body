package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

import java.util.Date;

@Data
public class PracticeLogDetailVO {
    private Long id;
    private Long studentId;
    private String studentName;
    private Long questionId;
    private String questionContent;
    private String questionType;
    private String knowledgePoint;
    private String answerText;
    private Boolean isCorrect;
    private String errorReason;
    private Integer score;
    private String correctAnswer;
    private Date submittedAt;
}