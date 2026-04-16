package com.atguigu.java.ai.langchain4j.entity.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 试卷预览VO
 */
@Data
public class ExamPreviewVO {
    
    private Long examId;
    
    private String examTitle;
    
    private String examDescription;
    
    private Integer totalQuestions;
    
    private Integer timeLimitMinutes;
    
    private BigDecimal qualityScore;
    
    private String status;
    
    private LocalDateTime createdAt;
    
    private List<QuestionPreviewVO> questions;
    
    private QualityAssessmentVO qualityAssessment;
    
    @Data
    public static class QuestionPreviewVO {
        private Long questionId;
        private String type;
        private String content;
        private String answer;
        private String knowledgePoint;
        private Integer difficultyLevel;
        private Integer estimatedTimeMinutes;
        private String aiSelectionReason;
        private Integer questionOrder;
    }
    
    @Data
    public static class QualityAssessmentVO {
        private BigDecimal overallScore;
        private BigDecimal difficultyBalance;
        private BigDecimal knowledgeCoverage;
        private BigDecimal timeDistribution;
        private BigDecimal questionDiversity;
        private String suggestions;
    }
}
