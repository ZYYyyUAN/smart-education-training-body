package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

@Data
public class SaveQuestionRequestDto {
    private Long courseId;        // 课程ID
    private String type;          // 题型，如 short_answer、choice、programming
    private String content;       // 题干
    private String answer;        // 标准答案
    private String knowledgePoint; // 知识点（同 question_bank 表中字段）
    private Long createdBy;       // 创建人ID（学生或教师，通常是 AI 代理使用者）
}
