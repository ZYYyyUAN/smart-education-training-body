package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.KnowledgePoint;

import java.util.List;

public interface KnowledgePointService {
    List<KnowledgePoint> getByChapterId(Long chapterId);
    void create(KnowledgePoint kp);
    void update(KnowledgePoint kp);
    void delete(Long id);
}


