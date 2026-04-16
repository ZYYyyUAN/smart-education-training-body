package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

import java.util.List;

@Data
public class SaveQuestionsRequestDto {
    private Long courseId;
    private Long createdBy;
    private Long categoryId; // 题库分类（用于前端选择题库类型后归类保存）
    private List<QuestionDto> questions;
}