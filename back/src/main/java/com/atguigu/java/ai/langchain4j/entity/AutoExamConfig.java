package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 自动组卷配置实体
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("auto_exam_config")
public class AutoExamConfig {
    
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    
    private Long courseId;
    
    private Long teacherId;
    
    private String configName;
    
    private Integer totalQuestions;
    
    private String questionDistribution; // JSON格式存储题型分布
    
    private String difficultyDistribution; // JSON格式存储难度分布
    
    private String knowledgePointWeights; // JSON格式存储知识点权重
    
    private Integer timeLimitMinutes;
    
    private String aiPromptTemplate;
    
    private Boolean isActive;
    
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;
}
