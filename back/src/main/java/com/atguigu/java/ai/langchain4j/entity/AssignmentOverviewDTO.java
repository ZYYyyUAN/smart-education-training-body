package com.atguigu.java.ai.langchain4j.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDate;

/**
 * 作业概览DTO（含完成人数/完成率）
 */
@Data
public class AssignmentOverviewDTO {
    private Long id;
    private String title;
    private Long courseId;
    private String courseName;
    private Long teacherId;
    private String description;
    
    @JsonFormat(pattern = "yyyy-MM-dd", timezone = "Asia/Shanghai")
    private LocalDate dueDate;
    
    private Integer completedCount;  // 完成人数
    private Integer totalStudents;   // 总学生数
}
