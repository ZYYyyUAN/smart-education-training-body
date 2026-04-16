package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.entity.QuestionBank;
import com.atguigu.java.ai.langchain4j.mapper.QuestionBankMapper;
import com.atguigu.java.ai.langchain4j.entity.QuestionBankCategory;
import com.atguigu.java.ai.langchain4j.mapper.QuestionBankCategoryMapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/test")
public class TestController {
    
    @Autowired
    private QuestionBankMapper questionBankMapper;
    
    @Autowired
    private QuestionBankCategoryMapper questionBankCategoryMapper;
    
    @GetMapping("/questions")
    public Map<String, Object> testQuestions() {
        // 查询所有题目
        List<QuestionBank> allQuestions = questionBankMapper.selectList(new QueryWrapper<>());
        
        // 查询所有题库分类
        List<QuestionBankCategory> allCategories = questionBankCategoryMapper.selectList(new QueryWrapper<>());
        
        Map<String, Object> result = new HashMap<>();
        result.put("totalQuestions", allQuestions.size());
        result.put("totalCategories", allCategories.size());
        result.put("questions", allQuestions);
        result.put("categories", allCategories);
        
        return result;
    }
    
    @GetMapping("/questions/course/101")
    public Map<String, Object> testQuestionsByCourse() {
        // 查询课程101的题目
        QueryWrapper<QuestionBank> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("course_id", 101);
        List<QuestionBank> questions = questionBankMapper.selectList(queryWrapper);
        
        Map<String, Object> result = new HashMap<>();
        result.put("count", questions.size());
        result.put("questions", questions);
        
        return result;
    }
}