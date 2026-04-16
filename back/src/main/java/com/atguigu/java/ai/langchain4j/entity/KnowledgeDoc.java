package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

import java.util.Date;

@Data
public class KnowledgeDoc {
    private Long id;
    private Long courseId;
    private String fileName;
    private String filePath;
    private Integer fileSize;
    private Date uploadedAt;
}
