package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

@Data
public class ResourceSearchRequest {
    private String fileName;
    private String documentContent;
    private String resourceType; // document, exercise, courseware, video
    private String subject; // math, chinese, english, science, etc.
    private String gradeLevel;
}
