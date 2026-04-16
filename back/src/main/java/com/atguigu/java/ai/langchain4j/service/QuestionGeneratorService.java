package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.QuestionBank;
import com.atguigu.java.ai.langchain4j.entity.QuestionBankCategory;
import com.atguigu.java.ai.langchain4j.entity.Result;

import java.util.List;
import java.util.Map;

/**
 * 题目生成服务接口
 */
public interface QuestionGeneratorService {
    
    /**
     * 根据知识点生成题目
     */
    Result<List<QuestionBank>> generateQuestions(Long courseId, 
                                                List<String> knowledgePoints, 
                                                Integer questionCount,
                                                Map<String, Integer> questionTypeDistribution,
                                                Map<String, Double> difficultyDistribution,
                                                Long categoryId,
                                                Long teacherId);
    
    /**
     * 生成单个题目
     */
    Result<QuestionBank> generateSingleQuestion(String knowledgePoint,
                                              String questionType,
                                              String difficultyLevel,
                                              Long categoryId,
                                              Long teacherId);
    
    /**
     * 保存生成的题目到题库
     */
    Result<String> saveQuestionsToBank(List<QuestionBank> questions, Long categoryId);
    
    /**
     * 获取题库分类列表
     */
    Result<List<QuestionBankCategory>> getQuestionBankCategories();
    
    /**
     * 创建题库分类
     */
    Result<QuestionBankCategory> createCategory(QuestionBankCategory category);
    
    /**
     * 更新题库分类
     */
    Result<QuestionBankCategory> updateCategory(QuestionBankCategory category);
    
    /**
     * 删除题库分类
     */
    Result<String> deleteCategory(Long categoryId);
}
