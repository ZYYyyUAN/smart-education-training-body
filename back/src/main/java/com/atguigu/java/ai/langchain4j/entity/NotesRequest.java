package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

@Data
public class NotesRequest {
    private String title;
    private String content;
    private String optimizationType;
}
