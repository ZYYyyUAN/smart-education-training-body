package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

import java.time.LocalDate;

@Data
public class ExamOverviewDTO {
    private Long id;
    private String title;
    private Long courseId;
    private String courseName;
    private Long teacherId;
    private LocalDate examDate;
    private Integer durationMinutes;
    private Integer completedCount;
    private Integer totalStudents;
}


