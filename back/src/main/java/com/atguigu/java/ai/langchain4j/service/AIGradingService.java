package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.QuestionBank;
import com.atguigu.java.ai.langchain4j.entity.dto.ExamSubmissionRequest;

import java.util.List;
import java.util.Map;

/**
 * AI批阅服务接口
 */
public interface AIGradingService {
    
    /**
     * 批阅考试答案
     */
    Map<String, Object> gradeExam(ExamSubmissionRequest submission, List<QuestionBank> questions);
    
    /**
     * 批阅单个题目
     */
    Map<String, Object> gradeQuestion(QuestionBank question, String studentAnswer);
}
