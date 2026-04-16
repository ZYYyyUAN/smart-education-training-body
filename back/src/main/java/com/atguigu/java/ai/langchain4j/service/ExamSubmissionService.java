package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.dto.ExamSubmissionRequest;
import com.atguigu.java.ai.langchain4j.entity.Result;

import java.util.Map;

/**
 * 考试提交服务接口
 */
public interface ExamSubmissionService {
    
    /**
     * 提交考试答案并进行AI批阅
     */
    Result<Map<String, Object>> submitExam(ExamSubmissionRequest request);
}
