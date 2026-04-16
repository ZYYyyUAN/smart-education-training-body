package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.assistant.QuestionGeneratorAgent;
import com.atguigu.java.ai.langchain4j.entity.*;
import com.atguigu.java.ai.langchain4j.mapper.QuestionBankMapper;
import com.atguigu.java.ai.langchain4j.mapper.QuestionBankCategoryMapper;
import com.atguigu.java.ai.langchain4j.service.CourseService;
import com.atguigu.java.ai.langchain4j.service.QuestionGeneratorService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

/**
 * 题目生成服务实现
 */
@Slf4j
@Service
public class QuestionGeneratorServiceImpl implements QuestionGeneratorService {
    
    @Autowired
    private QuestionGeneratorAgent questionGeneratorAgent;
    
    @Autowired
    private QuestionBankMapper questionBankMapper;
    
    @Autowired
    private QuestionBankCategoryMapper questionBankCategoryMapper;
    
    @Autowired
    private CourseService courseService;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @Override
    @Transactional
    public Result<List<QuestionBank>> generateQuestions(Long courseId, 
                                                       List<String> knowledgePoints, 
                                                       Integer questionCount,
                                                       Map<String, Integer> questionTypeDistribution,
                                                       Map<String, Double> difficultyDistribution,
                                                       Long categoryId,
                                                       Long teacherId) {
        try {
            // 1. 获取课程信息
            Course course = courseService.getCourseById(courseId);
            if (course == null) {
                return Result.error("课程不存在");
            }
            
            // 2. 调用AI生成题目
            String aiResponse = questionGeneratorAgent.generateQuestions(
                courseId,
                course.getCourseName(),
                String.join(", ", knowledgePoints),
                questionCount,
                objectMapper.writeValueAsString(questionTypeDistribution),
                objectMapper.writeValueAsString(difficultyDistribution),
                60 // 默认预估时间
            );
            
            // 3. 解析AI响应
            QuestionGenerationResult result = parseQuestionGenerationResponse(aiResponse);
            
            // 4. 转换为QuestionBank对象
            List<QuestionBank> questions = convertToQuestionBank(result.getQuestions(), courseId, categoryId, teacherId);
            
            return Result.ok(questions);
            
        } catch (Exception e) {
            log.error("生成题目失败", e);
            return Result.error("生成题目失败: " + e.getMessage());
        }
    }
    
    @Override
    public Result<QuestionBank> generateSingleQuestion(String knowledgePoint,
                                                     String questionType,
                                                     String difficultyLevel,
                                                     Long categoryId,
                                                     Long teacherId) {
        try {
            // 调用AI生成单个题目
            String aiResponse = questionGeneratorAgent.generateSingleQuestion(
                knowledgePoint,
                questionType,
                difficultyLevel,
                30 // 默认预估时间
            );
            
            // 解析AI响应
            SingleQuestionResult result = parseSingleQuestionResponse(aiResponse);
            
            // 转换为QuestionBank对象
            QuestionBank question = convertToQuestionBank(result, categoryId, teacherId);
            
            return Result.ok(question);
            
        } catch (Exception e) {
            log.error("生成单个题目失败", e);
            return Result.error("生成单个题目失败: " + e.getMessage());
        }
    }
    
    @Override
    @Transactional
    public Result<String> saveQuestionsToBank(List<QuestionBank> questions, Long categoryId) {
        try {
            // 设置分类ID
            questions.forEach(q -> q.setCategoryId(categoryId));
            
            // 批量插入
            questionBankMapper.insertBatch(questions);
            
            return Result.ok("题目保存成功，共保存 " + questions.size() + " 道题目");
            
        } catch (Exception e) {
            log.error("保存题目到题库失败", e);
            return Result.error("保存题目失败: " + e.getMessage());
        }
    }
    
    @Override
    public Result<List<QuestionBankCategory>> getQuestionBankCategories() {
        try {
            List<QuestionBankCategory> categories = questionBankCategoryMapper.selectList(null);
            return Result.ok(categories);
        } catch (Exception e) {
            log.error("获取题库分类失败", e);
            return Result.error("获取题库分类失败: " + e.getMessage());
        }
    }
    
    @Override
    @Transactional
    public Result<QuestionBankCategory> createCategory(QuestionBankCategory category) {
        try {
            category.setCreatedAt(LocalDateTime.now());
            category.setUpdatedAt(LocalDateTime.now());
            questionBankCategoryMapper.insert(category);
            return Result.ok(category);
        } catch (Exception e) {
            log.error("创建题库分类失败", e);
            return Result.error("创建题库分类失败: " + e.getMessage());
        }
    }
    
    @Override
    @Transactional
    public Result<QuestionBankCategory> updateCategory(QuestionBankCategory category) {
        try {
            category.setUpdatedAt(LocalDateTime.now());
            questionBankCategoryMapper.updateById(category);
            return Result.ok(category);
        } catch (Exception e) {
            log.error("更新题库分类失败", e);
            return Result.error("更新题库分类失败: " + e.getMessage());
        }
    }
    
    @Override
    @Transactional
    public Result<String> deleteCategory(Long categoryId) {
        try {
            questionBankCategoryMapper.deleteById(categoryId);
            return Result.ok("删除成功");
        } catch (Exception e) {
            log.error("删除题库分类失败", e);
            return Result.error("删除题库分类失败: " + e.getMessage());
        }
    }
    
    /**
     * 解析题目生成响应
     */
    private QuestionGenerationResult parseQuestionGenerationResponse(String aiResponse) {
        try {
            return objectMapper.readValue(aiResponse, QuestionGenerationResult.class);
        } catch (Exception e) {
            log.error("解析题目生成响应失败", e);
            throw new RuntimeException("解析AI响应失败", e);
        }
    }
    
    /**
     * 解析单个题目响应
     */
    private SingleQuestionResult parseSingleQuestionResponse(String aiResponse) {
        try {
            return objectMapper.readValue(aiResponse, SingleQuestionResult.class);
        } catch (Exception e) {
            log.error("解析单个题目响应失败", e);
            throw new RuntimeException("解析AI响应失败", e);
        }
    }
    
    /**
     * 转换为QuestionBank对象
     */
    private List<QuestionBank> convertToQuestionBank(List<GeneratedQuestion> questions, Long courseId, Long categoryId, Long teacherId) {
        List<QuestionBank> questionBanks = new ArrayList<>();
        
        for (GeneratedQuestion q : questions) {
            QuestionBank questionBank = new QuestionBank();
            questionBank.setCourseId(courseId);
            questionBank.setType(q.getType());
            questionBank.setContent(q.getContent());
            questionBank.setAnswer(q.getAnswer());
            questionBank.setKnowledgePoint(q.getKnowledgePoint());
            questionBank.setDifficultyLevel(q.getDifficultyLevel());
            questionBank.setCategoryId(categoryId);
            questionBank.setEstimatedTimeMinutes(q.getEstimatedTimeMinutes());
            questionBank.setTags(q.getTags());
            questionBank.setIsAiGenerated(true);
            questionBank.setQualityScore(q.getQualityScore());
            questionBank.setCreatedBy(teacherId);
            questionBank.setCreatedAt(LocalDateTime.now());
            
            questionBanks.add(questionBank);
        }
        
        return questionBanks;
    }
    
    /**
     * 转换为QuestionBank对象（单个）
     */
    private QuestionBank convertToQuestionBank(SingleQuestionResult result, Long categoryId, Long teacherId) {
        QuestionBank questionBank = new QuestionBank();
        questionBank.setType(result.getType());
        questionBank.setContent(result.getContent());
        questionBank.setAnswer(result.getAnswer());
        questionBank.setKnowledgePoint(result.getKnowledgePoint());
        questionBank.setDifficultyLevel(result.getDifficultyLevel());
        questionBank.setCategoryId(categoryId);
        questionBank.setEstimatedTimeMinutes(result.getEstimatedTimeMinutes());
        questionBank.setTags(result.getTags());
        questionBank.setIsAiGenerated(true);
        questionBank.setQualityScore(result.getQualityScore());
        questionBank.setCreatedBy(teacherId);
        questionBank.setCreatedAt(LocalDateTime.now());
        
        return questionBank;
    }
    
    // 内部类定义
    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class QuestionGenerationResult {
        private List<GeneratedQuestion> questions;
        private GenerationSummary generationSummary;
        private QualityAssessment qualityAssessment;
        
        // getters and setters
        public List<GeneratedQuestion> getQuestions() { return questions; }
        public void setQuestions(List<GeneratedQuestion> questions) { this.questions = questions; }
        public GenerationSummary getGenerationSummary() { return generationSummary; }
        public void setGenerationSummary(GenerationSummary generationSummary) { this.generationSummary = generationSummary; }
        public QualityAssessment getQualityAssessment() { return qualityAssessment; }
        public void setQualityAssessment(QualityAssessment qualityAssessment) { this.qualityAssessment = qualityAssessment; }
    }
    
    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class GeneratedQuestion {
        private String type;
        private String content;
        private String answer;
        private String knowledgePoint;
        private String difficultyLevel;
        private Integer estimatedTimeMinutes;
        private String tags;
        private List<String> options;
        private Double qualityScore;
        
        // getters and setters
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public String getContent() { return content; }
        public void setContent(String content) { this.content = content; }
        public String getAnswer() { return answer; }
        public void setAnswer(String answer) { this.answer = answer; }
        public String getKnowledgePoint() { return knowledgePoint; }
        public void setKnowledgePoint(String knowledgePoint) { this.knowledgePoint = knowledgePoint; }
        public String getDifficultyLevel() { return difficultyLevel; }
        public void setDifficultyLevel(String difficultyLevel) { this.difficultyLevel = difficultyLevel; }
        public Integer getEstimatedTimeMinutes() { return estimatedTimeMinutes; }
        public void setEstimatedTimeMinutes(Integer estimatedTimeMinutes) { this.estimatedTimeMinutes = estimatedTimeMinutes; }
        public String getTags() { return tags; }
        public void setTags(String tags) { this.tags = tags; }
        public List<String> getOptions() { return options; }
        public void setOptions(List<String> options) { this.options = options; }
        public Double getQualityScore() { return qualityScore; }
        public void setQualityScore(Double qualityScore) { this.qualityScore = qualityScore; }
    }
    
    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class GenerationSummary {
        private Integer totalQuestions;
        private Map<String, Integer> typeDistribution;
        private Map<String, Integer> difficultyDistribution;
        private List<String> knowledgePointCoverage;
        
        // getters and setters
        public Integer getTotalQuestions() { return totalQuestions; }
        public void setTotalQuestions(Integer totalQuestions) { this.totalQuestions = totalQuestions; }
        public Map<String, Integer> getTypeDistribution() { return typeDistribution; }
        public void setTypeDistribution(Map<String, Integer> typeDistribution) { this.typeDistribution = typeDistribution; }
        public Map<String, Integer> getDifficultyDistribution() { return difficultyDistribution; }
        public void setDifficultyDistribution(Map<String, Integer> difficultyDistribution) { this.difficultyDistribution = difficultyDistribution; }
        public List<String> getKnowledgePointCoverage() { return knowledgePointCoverage; }
        public void setKnowledgePointCoverage(List<String> knowledgePointCoverage) { this.knowledgePointCoverage = knowledgePointCoverage; }
    }
    
    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class QualityAssessment {
        private Object overallScore;
        private Object difficultyBalance;
        private Object knowledgeCoverage;
        private String suggestions;
        
        // getters and setters
        public Object getOverallScore() { return overallScore; }
        public void setOverallScore(Object overallScore) { this.overallScore = overallScore; }
        public Object getDifficultyBalance() { return difficultyBalance; }
        public void setDifficultyBalance(Object difficultyBalance) { this.difficultyBalance = difficultyBalance; }
        public Object getKnowledgeCoverage() { return knowledgeCoverage; }
        public void setKnowledgeCoverage(Object knowledgeCoverage) { this.knowledgeCoverage = knowledgeCoverage; }
        public String getSuggestions() { return suggestions; }
        public void setSuggestions(String suggestions) { this.suggestions = suggestions; }
    }
    
    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class SingleQuestionResult {
        private String type;
        private String content;
        private String answer;
        private String knowledgePoint;
        private String difficultyLevel;
        private Integer estimatedTimeMinutes;
        private String tags;
        private List<String> options;
        private String explanation;
        private Double qualityScore;
        
        // getters and setters
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public String getContent() { return content; }
        public void setContent(String content) { this.content = content; }
        public String getAnswer() { return answer; }
        public void setAnswer(String answer) { this.answer = answer; }
        public String getKnowledgePoint() { return knowledgePoint; }
        public void setKnowledgePoint(String knowledgePoint) { this.knowledgePoint = knowledgePoint; }
        public String getDifficultyLevel() { return difficultyLevel; }
        public void setDifficultyLevel(String difficultyLevel) { this.difficultyLevel = difficultyLevel; }
        public Integer getEstimatedTimeMinutes() { return estimatedTimeMinutes; }
        public void setEstimatedTimeMinutes(Integer estimatedTimeMinutes) { this.estimatedTimeMinutes = estimatedTimeMinutes; }
        public String getTags() { return tags; }
        public void setTags(String tags) { this.tags = tags; }
        public List<String> getOptions() { return options; }
        public void setOptions(List<String> options) { this.options = options; }
        public String getExplanation() { return explanation; }
        public void setExplanation(String explanation) { this.explanation = explanation; }
        public Double getQualityScore() { return qualityScore; }
        public void setQualityScore(Double qualityScore) { this.qualityScore = qualityScore; }
    }
}
