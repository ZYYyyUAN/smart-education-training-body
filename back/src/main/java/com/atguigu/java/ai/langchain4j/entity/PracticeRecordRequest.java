package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;
import java.util.List;

@Data
public class PracticeRecordRequest {
    private Long studentId;
    private Long courseId;
    private Integer totalQuestions;
    private Integer correctCount;
    private Integer wrongCount;
    private Integer unansweredCount;
    private Integer accuracyRate;
    private String practiceType;
    private String practiceDate;
    private List<QuestionDetail> questionDetails;

    @Data
    public static class QuestionDetail {
        private Long questionId;
        private String questionType;
        private String questionContent;
        private String knowledgePoint; // 添加知识点字段
        private String userAnswer;
        private String correctAnswer;
        private Integer score;
        private Boolean isCorrect;
    }
} 