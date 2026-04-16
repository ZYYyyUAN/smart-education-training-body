package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

import java.util.Date;

@Data
public class LessonPlan {
    private Long id;
    private Long courseId;
    private Long teacherId;
    private String planTitle;
    private String content;
    private Date createdAt;
}
