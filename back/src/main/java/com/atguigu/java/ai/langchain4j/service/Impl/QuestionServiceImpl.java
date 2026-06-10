package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.assistant.XiaozhiAgent;
import com.atguigu.java.ai.langchain4j.entity.*;
import com.atguigu.java.ai.langchain4j.util.QuestionParser;
import com.atguigu.java.ai.langchain4j.mapper.QuestionBankMapper;
import com.atguigu.java.ai.langchain4j.mapper.AutoExamQuestionMapper;
import com.atguigu.java.ai.langchain4j.mapper.ExamQuestionMapper;
import com.atguigu.java.ai.langchain4j.service.QuestionService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
public class QuestionServiceImpl implements QuestionService {

    @Autowired
    private XiaozhiAgent xiaozhiAgent;

    @Autowired
    private QuestionBankMapper questionBankMapper;
    
    @Autowired
    private AutoExamQuestionMapper autoExamQuestionMapper;

    @Autowired
    private ExamQuestionMapper examQuestionMapper;

    public  List<QuestionBank> generateQuestions(QuestionGenerateRequest request) {
        String prompt = buildPrompt(request);

        // 此时直接返回字符串，无需 Flux 处理
        String rawResult = xiaozhiAgent.generateQuestions(prompt);
        System.out.println("大模型返回内容：");
        System.out.println(rawResult);

        String cleaned = preprocessModelOutput(rawResult);
        System.out.println("预处理后字符串：" + cleaned);

        List<QuestionBank> parsed = parseQuestions(cleaned, request.getCourseId());

        return parsed;
    }

    private String buildPrompt(QuestionGenerateRequest request) {
        if (StringUtils.hasText(request.getObjective())) {
            return "根据以下教学目标生成多样化考核题目，并包含答案与知识点：" + request.getObjective();
        } else {
            return "为课程ID为 " + request.getCourseId() + " 生成相关考核题目，题型包括简答题、选择题、编程题，包含答案和知识点";
        }
    }

    private String preprocessModelOutput(String raw) {
        // 1. 先替换所有换行、制表符、多个空格为单个空格
        String cleaned = raw.replaceAll("[\\r\\n\\t]+", " ")
                .replaceAll("\\s{2,}", " ")
                .trim();

        // 2. 修正关键字格式，比如把“【 题型】”变成“【题型】”，同理其他字段
        cleaned = cleaned.replaceAll("【\\s*", "【")
                .replaceAll("\\s*】", "】");

        // 3. 把序号后的点号与数字之间多余空格清理掉，保持"1. "格式
        cleaned = cleaned.replaceAll("(\\d+)\\s*\\.\\s*", "$1. ");

        return cleaned;
    }

    private List<QuestionBank> parseQuestions(String result, Long courseId) {
        // TODO：解析大模型返回文本为结构化题目对象
        // 示例结构：
        // 1. 题目类型：简答题
        //    内容：什么是嵌入式系统？
        //    答案：嵌入式系统是...
        //    知识点：系统概述

        // 假设你设计 parse 方法将文本转换为 List<QuestionBank>
        return QuestionParser.parse(result, courseId);
    }

    @Override
    public Result<?> create(QuestionBank question) {
        question.setCreatedAt(LocalDateTime.now());
        questionBankMapper.insert(question);
        return Result.ok("创建成功");
    }

    @Override
    public Result<?> update(QuestionBank question) {
        questionBankMapper.updateById(question);
        return Result.ok("更新成功");
    }

    @Override
    public Result<?> delete(Long id) {
        try {
            // 先检查题目是否被自动组卷/正式试卷引用
            List<AutoExamQuestion> autoExamQuestions = autoExamQuestionMapper.selectByQuestionBankId(id);
            if (!autoExamQuestions.isEmpty()) {
                return Result.error("无法删除题目，该题目已被自动生成试卷引用，请先删除相关试卷或改用强制删除");
            }
            
            List<ExamQuestion> examQuestions = examQuestionMapper.selectByQuestionId(id);
            if (examQuestions != null && !examQuestions.isEmpty()) {
                return Result.error("无法删除题目，该题目已被正式考试引用，请先删除或调整相关考试，再执行删除");
            }
            
            // 删除题目
            questionBankMapper.deleteById(id);
            return Result.ok("删除成功");
        } catch (Exception e) {
            log.error("删除题目失败: id={}", id, e);
            return Result.error("删除失败: " + e.getMessage());
        }
    }

    @Override
    public Result<?> forceDelete(Long id) {
        try {
            // 先清理引用再删除题目
            autoExamQuestionMapper.deleteByQuestionBankId(id);
            questionBankMapper.deleteById(id);
            return Result.ok("强制删除成功");
        } catch (Exception e) {
            log.error("强制删除题目失败: id={}", id, e);
            return Result.error("强制删除失败: " + e.getMessage());
        }
    }

    @Override
    public Result<QuestionBank> getById(Long id) {
        return Result.ok(questionBankMapper.selectById(id));
    }

    @Override
    public Result<List<QuestionBank>> listByCourse(Long courseId) {
        return Result.ok(questionBankMapper.selectByCourseId(courseId));
    }

    @Override
    public QuestionBank selectById(Long questionId) {
        return questionBankMapper.selectById(questionId);
    }


    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public List<QuestionDto> generateQuestionsByRequirement(QuestionRequestDto request) {
        String json = xiaozhiAgent.generateQuestionsByRequirement(
                request.getQuestionType(),
                request.getKnowledgePoint(),
                request.getCount()
        );

        try {
            // 清理 JSON 中的换行符和特殊字符
            String cleanedJson = cleanJsonForParsing(json);
            return objectMapper.readValue(cleanedJson, new TypeReference<List<QuestionDto>>() {});
        } catch (Exception e) {
            log.error("JSON 解析失败，原始内容：{}", json, e);
            throw new RuntimeException("题目生成失败，返回格式不合法", e);
        }
    }

    /**
     * 清理 JSON 字符串，处理换行符和特殊字符
     */
    private String cleanJsonForParsing(String json) {
        if (json == null) {
            return "";
        }
        
        // 1. 移除可能的 markdown 代码块标记
        String cleaned = json.replaceAll("```json\\s*", "").replaceAll("```\\s*", "");
        
        // 2. 处理字符串值中的换行符 - 将换行符转义为 \\n
        // 这个正则表达式匹配 JSON 字符串值中的换行符
        cleaned = cleaned.replaceAll("(\"[^\"]*?)\\n([^\"]*?\")", "$1\\\\n$2");
        
        // 3. 处理字符串值中的回车符
        cleaned = cleaned.replaceAll("(\"[^\"]*?)\\r([^\"]*?\")", "$1\\\\r$2");
        
        // 4. 处理字符串值中的制表符
        cleaned = cleaned.replaceAll("(\"[^\"]*?)\\t([^\"]*?\")", "$1\\\\t$2");
        
        // 5. 移除 JSON 外部的换行符和空白字符
        cleaned = cleaned.trim();
        
        log.debug("JSON 清理前：{}", json);
        log.debug("JSON 清理后：{}", cleaned);
        
        return cleaned;
    }

    public List<Long> saveGeneratedQuestions(SaveQuestionsRequestDto request) {
        List<QuestionBank> entities = request.getQuestions().stream().map(q -> {
            QuestionBank qb = new QuestionBank();
            qb.setCourseId(request.getCourseId());
            qb.setType(q.getType());
            qb.setContent(q.getContent());
            qb.setAnswer(q.getAnswer());
            qb.setKnowledgePoint(q.getKnowledgePoint());
            qb.setCreatedBy(request.getCreatedBy());
            qb.setCategoryId(request.getCategoryId());
            return qb;
        }).collect(Collectors.toList());

        questionBankMapper.insertBatch(entities); // 需手动写 insertBatch
        return entities.stream().map(QuestionBank::getId).collect(Collectors.toList());
    }

    @Override
    public List<QuestionDto> getByCreateId(Long createdBy) {
        return questionBankMapper.selectByCreateId(createdBy);
    }

    @Override
    public void saveBatch(List<QuestionBank> questionList) {
        if (questionList == null || questionList.isEmpty()) {
            throw new IllegalArgumentException("题目列表不能为空");
        }
        questionBankMapper.insertBatch(questionList);
    }

    @Override
    public List<QuestionBank> list() {
       return questionBankMapper.list();
    }

    @Override
    public PageResponse<QuestionBank> page(int page, int pageSize) {
        if (page < 1) page = 1;
        if (pageSize <= 0) pageSize = 10;
        int offset = (page - 1) * pageSize;
        long total = questionBankMapper.countAll();
        List<QuestionBank> records = questionBankMapper.pageAll(offset, pageSize);
        return new PageResponse<>(records, total, page, pageSize);
    }

    @Override
    public List<QuestionBank> getQuestionsByExamId(Long examId) {
        return questionBankMapper.selectByExamId(examId);
    }

    @Override
    public List<QuestionBank> listByCategory(Long categoryId) {
        return questionBankMapper.selectByCategoryId(categoryId);
    }

    @Override
    public PageResponse<QuestionBank> pageByCategory(Long categoryId, int page, int pageSize) {
        if (page < 1) page = 1;
        if (pageSize <= 0) pageSize = 10;
        int offset = (page - 1) * pageSize;
        long total = questionBankMapper.countByCategoryId(categoryId);
        List<QuestionBank> records = questionBankMapper.pageByCategoryId(categoryId, offset, pageSize);
        return new PageResponse<>(records, total, page, pageSize);
    }
    
    @Override
    public List<QuestionBank> getQuestionsByIds(List<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return Collections.emptyList();
        }
        return questionBankMapper.selectByIdList(ids);
    }

}
