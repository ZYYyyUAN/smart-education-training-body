package com.atguigu.java.ai.langchain4j.entity.dto;

import lombok.Data;
import java.util.List;
import java.util.Map;

/**
 * 试卷生成请求DTO
 */
@Data
public class ExamGenerationRequest {
    
    private Long courseId;
    
    private Long teacherId;
    
    private String examTitle;
    
    private String examDescription;
    
    private Integer totalQuestions;
    
    private Map<String, Integer> questionDistribution; // 题型分布
    
    private Map<String, Double> difficultyDistribution; // 难度分布
    
    private Map<String, Double> knowledgePointWeights; // 知识点权重
    
    private Integer timeLimitMinutes;
    
    private String generationStrategy; // 生成策略
    
    private String aiPromptTemplate; // 自定义AI提示词
    
    private java.util.List<String> selectedKnowledgePoints; // 选中的知识点列表
    
    private Long categoryId; // 题库分类ID
}
