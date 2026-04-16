package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class ExamWithStatusDTO {
    private Long examId;
    private Long courseId;
    private String title;
    private String description;
    private LocalDate examDate;
    private Integer durationMinutes;
    private Boolean submitted;
    private LocalDateTime submittedAt;
    private Integer score;
}


