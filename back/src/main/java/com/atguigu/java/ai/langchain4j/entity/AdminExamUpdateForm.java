package com.atguigu.java.ai.langchain4j.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDate;

/**
 * 管理端更新考试表单（只包含基本信息，不包含题目）
 */
@Data
public class AdminExamUpdateForm {
    private Long id;
    private Long courseId;
    private Long teacherId;
    private String title;
    private String description;
    
    @JsonFormat(pattern = "yyyy-MM-dd", timezone = "Asia/Shanghai")
    private LocalDate examDate;
    
    private Integer durationMinutes;
}
