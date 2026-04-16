package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

@Data
public class QuestionDto {
    private Long id;              // 题目ID
    private Long courseId;        // 所属课程ID
    private String type;          // 题型：short_answer / choice / programming
    private String content;       // 题干
    private String answer;        // 标准答案（可选返回，视场景而定）
    private String knowledgePoint; // 所属知识点
    private String difficulty;    // 难度（如果数据库有，可加）
    private Long createdBy;       // 创建者ID
    private String createdByName; // 创建者姓名（可选，用于展示）
    private String createTime;    // 创建时间字符串格式（如 "2025-07-14 12:00"）
}
