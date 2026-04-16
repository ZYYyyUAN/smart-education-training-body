package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.entity.QuestionBank;
import com.atguigu.java.ai.langchain4j.entity.QuestionBankCategory;
import com.atguigu.java.ai.langchain4j.entity.Result;
import com.atguigu.java.ai.langchain4j.service.QuestionGeneratorService;
import com.atguigu.java.ai.langchain4j.mapper.QuestionBankMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Collections;

/**
 * 题目生成控制器
 */
@Slf4j
@RestController
@RequestMapping("/question-generator")
@Tag(name = "题目生成", description = "AI智能题目生成功能")
public class QuestionGeneratorController {
    
    @Autowired
    private QuestionGeneratorService questionGeneratorService;
    @Autowired
    private QuestionBankMapper questionBankMapper;
    
    /**
     * 根据知识点生成题目
     */
    @PostMapping("/generate")
    @Operation(summary = "生成题目", description = "根据知识点批量生成题目")
    public Result<List<QuestionBank>> generateQuestions(@RequestBody QuestionGenerationRequest request) {
        log.info("生成题目请求: {}", request);
        return questionGeneratorService.generateQuestions(
            request.getCourseId(),
            request.getKnowledgePoints(),
            request.getQuestionCount(),
            request.getQuestionTypeDistribution(),
            request.getDifficultyDistribution(),
            request.getCategoryId(),
            request.getTeacherId()
        );
    }
    
    /**
     * 生成单个题目
     */
    @PostMapping("/generate-single")
    @Operation(summary = "生成单个题目", description = "生成单个题目")
    public Result<QuestionBank> generateSingleQuestion(@RequestBody SingleQuestionRequest request) {
        log.info("生成单个题目请求: {}", request);
        return questionGeneratorService.generateSingleQuestion(
            request.getKnowledgePoint(),
            request.getQuestionType(),
            request.getDifficultyLevel(),
            request.getCategoryId(),
            request.getTeacherId()
        );
    }
    
    /**
     * 保存题目到题库
     */
    @PostMapping("/save")
    @Operation(summary = "保存题目", description = "将生成的题目保存到题库")
    public Result<String> saveQuestionsToBank(@RequestBody SaveQuestionsRequest request) {
        log.info("保存题目请求: {}", request);
        return questionGeneratorService.saveQuestionsToBank(request.getQuestions(), request.getCategoryId());
    }
    
    /**
     * 获取题库分类列表
     */
    @GetMapping("/categories")
    @Operation(summary = "获取题库分类", description = "获取所有题库分类，并附带各分类题目数量（可按课程过滤）")
    public Result<List<Map<String, Object>>> getQuestionBankCategories(@RequestParam(name = "courseId", required = false) Long courseId) {
        Result<List<QuestionBankCategory>> base = questionGeneratorService.getQuestionBankCategories();
        List<QuestionBankCategory> categories = base.getData();
        if (categories == null) {
            return Result.ok(Collections.emptyList());
        }
        List<Map<String, Object>> list = new java.util.ArrayList<>();
        for (QuestionBankCategory c : categories) {
            if (courseId != null && c.getCourseId() != null && !c.getCourseId().equals(courseId)) {
                continue; // 只展示当前课程的分类
            }
            Map<String, Object> m = new java.util.HashMap<>();
            m.put("id", c.getId());
            m.put("courseId", c.getCourseId());
            m.put("name", c.getName());
            m.put("description", c.getDescription());
            m.put("color", c.getColor());
            m.put("icon", c.getIcon());
            m.put("sortOrder", c.getSortOrder());
            m.put("isActive", c.getIsActive());
            long count = (courseId != null)
                    ? questionBankMapper.countByCourseAndCategory(courseId, c.getId())
                    : questionBankMapper.countByCategoryId(c.getId());
            m.put("questionCount", count);
            list.add(m);
        }
        return Result.ok(list);
    }
    
    /**
     * 创建题库分类
     */
    @PostMapping("/categories")
    @Operation(summary = "创建题库分类", description = "创建新的题库分类")
    public Result<QuestionBankCategory> createCategory(@RequestBody QuestionBankCategory category) {
        log.info("创建题库分类请求: {}", category);
        return questionGeneratorService.createCategory(category);
    }
    
    /**
     * 更新题库分类
     */
    @PutMapping("/categories/{id}")
    @Operation(summary = "更新题库分类", description = "更新题库分类信息")
    public Result<QuestionBankCategory> updateCategory(@PathVariable(name = "id") Long id, @RequestBody QuestionBankCategory category) {
        log.info("更新题库分类请求: id={}, category={}", id, category);
        category.setId(id);
        return questionGeneratorService.updateCategory(category);
    }
    
    /**
     * 删除题库分类
     */
    @DeleteMapping("/categories/{id}")
    @Operation(summary = "删除题库分类", description = "删除题库分类")
    public Result<String> deleteCategory(@PathVariable(name = "id") Long id,
                                         @RequestParam(name = "force", required = false, defaultValue = "false") boolean force,
                                         @RequestParam(name = "reassignTo", required = false) Long reassignTo) {
        log.info("删除题库分类请求: id={}, force={}, reassignTo={}", id, force, reassignTo);
        if (Boolean.TRUE.equals(force) && reassignTo != null) {
            // 先把题目迁移到目标分类
            int moved = 0;
            try {
                moved = questionBankMapper.reassignCategory(id, reassignTo);
            } catch (Exception ignore) {}
            log.info("已将 {} 条题目迁移到分类 {}", moved, reassignTo);
        }
        return questionGeneratorService.deleteCategory(id);
    }
    
    // 请求DTO类
    public static class QuestionGenerationRequest {
        private Long courseId;
        private List<String> knowledgePoints;
        private Integer questionCount;
        private Map<String, Integer> questionTypeDistribution;
        private Map<String, Double> difficultyDistribution;
        private Long categoryId;
        private Long teacherId;
        
        // getters and setters
        public Long getCourseId() { return courseId; }
        public void setCourseId(Long courseId) { this.courseId = courseId; }
        public List<String> getKnowledgePoints() { return knowledgePoints; }
        public void setKnowledgePoints(List<String> knowledgePoints) { this.knowledgePoints = knowledgePoints; }
        public Integer getQuestionCount() { return questionCount; }
        public void setQuestionCount(Integer questionCount) { this.questionCount = questionCount; }
        public Map<String, Integer> getQuestionTypeDistribution() { return questionTypeDistribution; }
        public void setQuestionTypeDistribution(Map<String, Integer> questionTypeDistribution) { this.questionTypeDistribution = questionTypeDistribution; }
        public Map<String, Double> getDifficultyDistribution() { return difficultyDistribution; }
        public void setDifficultyDistribution(Map<String, Double> difficultyDistribution) { this.difficultyDistribution = difficultyDistribution; }
        public Long getCategoryId() { return categoryId; }
        public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }
        public Long getTeacherId() { return teacherId; }
        public void setTeacherId(Long teacherId) { this.teacherId = teacherId; }
    }
    
    public static class SingleQuestionRequest {
        private String knowledgePoint;
        private String questionType;
        private String difficultyLevel;
        private Long categoryId;
        private Long teacherId;
        
        // getters and setters
        public String getKnowledgePoint() { return knowledgePoint; }
        public void setKnowledgePoint(String knowledgePoint) { this.knowledgePoint = knowledgePoint; }
        public String getQuestionType() { return questionType; }
        public void setQuestionType(String questionType) { this.questionType = questionType; }
        public String getDifficultyLevel() { return difficultyLevel; }
        public void setDifficultyLevel(String difficultyLevel) { this.difficultyLevel = difficultyLevel; }
        public Long getCategoryId() { return categoryId; }
        public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }
        public Long getTeacherId() { return teacherId; }
        public void setTeacherId(Long teacherId) { this.teacherId = teacherId; }
    }
    
    public static class SaveQuestionsRequest {
        private List<QuestionBank> questions;
        private Long categoryId;
        
        // getters and setters
        public List<QuestionBank> getQuestions() { return questions; }
        public void setQuestions(List<QuestionBank> questions) { this.questions = questions; }
        public Long getCategoryId() { return categoryId; }
        public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }
    }
}
