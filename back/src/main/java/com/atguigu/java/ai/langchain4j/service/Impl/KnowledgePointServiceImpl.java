package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.KnowledgePoint;
import com.atguigu.java.ai.langchain4j.mapper.KnowledgePointMapper;
import com.atguigu.java.ai.langchain4j.service.KnowledgePointService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class KnowledgePointServiceImpl implements KnowledgePointService {

    @Autowired
    private KnowledgePointMapper knowledgePointMapper;

    @Override
    public List<KnowledgePoint> getByChapterId(Long chapterId) {
        return knowledgePointMapper.selectByChapterId(chapterId);
    }

    @Override
    public void create(KnowledgePoint kp) {
        if (kp.getChapterId() == null) {
            throw new IllegalArgumentException("chapterId 不能为空");
        }
        int n = knowledgePointMapper.insert(kp);
        if (n != 1) {
            throw new IllegalStateException("创建知识点失败");
        }
    }

    @Override
    public void update(KnowledgePoint kp) {
        if (kp.getId() == null) {
            throw new IllegalArgumentException("id 不能为空");
        }
        int n = knowledgePointMapper.update(kp);
        if (n != 1) {
            throw new IllegalStateException("更新知识点失败");
        }
    }

    @Override
    public void delete(Long id) {
        int n = knowledgePointMapper.delete(id);
        if (n != 1) {
            throw new IllegalStateException("删除知识点失败");
        }
    }
}


