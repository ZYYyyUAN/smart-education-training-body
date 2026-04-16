package com.atguigu.java.ai.langchain4j.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class AssignmentForm {
    private Long id;
    private Long teacherId;
    private Long courseId;
    private String title;
    private String description;
    private List<Long> questionIds;

    private LocalDate dueDate;  // 👈 前端传入的截止时间
}
