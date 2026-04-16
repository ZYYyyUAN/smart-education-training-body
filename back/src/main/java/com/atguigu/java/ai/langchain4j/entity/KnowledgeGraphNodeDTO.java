package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

import java.util.List;

@Data
public class KnowledgeGraphNodeDTO {
    private Long id;
    private String name;
    private List<KnowledgeGraphNodeDTO> children;
}
