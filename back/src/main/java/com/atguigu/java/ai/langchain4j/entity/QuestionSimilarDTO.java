package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

@Data
public class QuestionSimilarDTO {
    private String type;
    private String content;
    private String answer;
    private String knowledgePoint;
}
