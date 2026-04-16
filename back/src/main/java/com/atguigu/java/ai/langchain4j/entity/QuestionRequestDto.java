package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

@Data
public class QuestionRequestDto {
    private Long studentId;     // 学生ID（可用于个性化）
    private Long courseId;      // 所属课程ID
    private String questionType; // 题型，如 "short_answer" / "choice" / "programming"
    private String knowledgePoint; // 用户指定的知识点关键词，如“嵌入式处理器结构”
    private Integer count = 1;     // 希望生成多少道题（默认1）
}
