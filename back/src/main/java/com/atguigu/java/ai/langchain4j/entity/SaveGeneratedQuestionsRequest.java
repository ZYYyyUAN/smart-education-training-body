package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

import java.util.List;

@Data
public class SaveGeneratedQuestionsRequest {
    private Long teacherId;
    private Long courseId;
    private List<QuestionBank> questions;
}
