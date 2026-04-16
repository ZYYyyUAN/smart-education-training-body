package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
@Data
public class AssignmentWithStatusDTO {
    private Long assignmentId;
    private Long courseId;
    private String title;
    private String description;
    private LocalDate dueDate;  // 截止日期
    private boolean submitted;  // 是否提交过
    private LocalDateTime submittedAt;  // 提交时间，如果提交过
    private Integer score;  // 作业得分，可空
    private boolean isOverdue;  // 是否已截止（未提交且超过截止时间）

    // getters and setters
}