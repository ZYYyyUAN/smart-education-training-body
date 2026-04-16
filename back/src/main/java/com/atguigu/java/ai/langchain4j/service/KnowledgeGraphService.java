package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.KnowledgeGraphNodeDTO;

public interface KnowledgeGraphService {
    KnowledgeGraphNodeDTO buildKnowledgeGraph(Long courseId);
}
