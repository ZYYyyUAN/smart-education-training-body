package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

@Data
public class QuestionGenerateRequest {
    private Long courseId;
    private String objective;  // 教学目标描述
    private Long teacherId;
}