package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 题库分类实体
 */
@Data
@TableName("question_bank_category")
public class QuestionBankCategory {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    // 所属课程，用于将题库分类绑定到具体课程
    private Long courseId;
    
    private String name;
    
    private String description;
    
    private String color;
    
    private String icon;
    
    private Integer sortOrder;
    
    private Boolean isActive;
    
    private Long createdBy;
    
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;
}
