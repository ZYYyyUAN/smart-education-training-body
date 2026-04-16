package com.atguigu.java.ai.langchain4j.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class ExamForm {
    private Long id;
    private Long teacherId;
    private Long courseId;
    private String title;
    private String description;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate examDate;
    private Integer durationMinutes;
    private List<Long> questionIds;
}


