package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 试卷题目关联实体
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("auto_exam_question")
public class AutoExamQuestion {
    
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    
    private Long examId;
    
    private Long questionBankId;
    
    private Integer questionOrder;
    
    private String sectionType;
    
    private Integer difficultyLevel;
    
    private Long knowledgePointId;
    
    private String aiSelectionReason;
    
    private Integer estimatedTimeMinutes;
    
    private LocalDateTime createdAt;
}
