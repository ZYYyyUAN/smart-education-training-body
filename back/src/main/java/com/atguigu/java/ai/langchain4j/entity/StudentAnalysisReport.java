package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

// StudentAnalysisReport.java
@Data
@TableName("student_analysis_report")
public class StudentAnalysisReport {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long studentId;

    private Long courseId;

    @TableField("knowledge_analysis")
    private String knowledgeAnalysis;

    @TableField("teaching_suggestion")
    private String teachingSuggestion;

    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}