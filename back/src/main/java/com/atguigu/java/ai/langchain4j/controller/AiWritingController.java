package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.assistant.XiaozhiAgent;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;

/**
 * AI写作助手控制器
 */
@Tag(name = "AI写作助手")
@RestController
@RequestMapping("/ai-writing")
@Slf4j
public class AiWritingController {

    @Autowired
    private XiaozhiAgent xiaozhiAgent;

    @Operation(summary = "测试接口")
    @GetMapping("/test")
    public String test() {
        log.info("AI写作接口测试");
        return "{\"status\": \"success\", \"message\": \"AI写作接口正常工作\"}";
    }

    @Operation(summary = "AI识别 - 分析主题和内容要求")
    @PostMapping("/analyze-requirement")
    public String analyzeWritingRequirement(@RequestBody AnalyzeRequirementRequest request) {
        log.info("收到AI识别请求，主题: {}, 内容要求: {}", request.getTopic(), request.getContentRequirement());
        
        try {
            // 验证必要参数
            if (request.getTopic() == null || request.getTopic().trim().isEmpty()) {
                log.error("主题参数为空");
                return "{\"error\": \"主题参数不能为空\"}";
            }
            
            Long memoryId = System.currentTimeMillis();
            String result = xiaozhiAgent.analyzeWritingRequirement(memoryId, request.getTopic(), request.getContentRequirement());
            log.info("AI识别返回结果: {}", result);
            return result;
            
        } catch (Exception e) {
            log.error("AI识别失败，详细错误: {}", e.getMessage(), e);
            return "{\"error\": \"AI识别失败: " + e.getMessage() + "\"}";
        }
    }

    @Operation(summary = "生成大纲标题")
    @PostMapping("/generate-outline-titles")
    public String generateOutlineTitles(@RequestBody GenerateOutlineTitlesRequest request) {
        log.info("收到标题生成请求，主题: {}, 文档类型: {}, 关键要点: {}, 内容要求: {}", 
                 request.getTopic(), request.getDocumentType(), request.getKeyPoints(), request.getContentRequirement());
        
        try {
            // 验证必要参数
            if (request.getTopic() == null || request.getTopic().trim().isEmpty()) {
                log.error("主题参数为空");
                return "[{\"error\": \"主题参数不能为空\"}]";
            }
            
            if (request.getDocumentType() == null || request.getDocumentType().trim().isEmpty()) {
                log.error("文档类型参数为空");
                return "[{\"error\": \"文档类型参数不能为空\"}]";
            }
            
            Long memoryId = System.currentTimeMillis();
            String result = xiaozhiAgent.generateOutlineTitles(
                memoryId,
                request.getTopic(), 
                request.getDocumentType(), 
                request.getKeyPoints(), 
                request.getContentRequirement()
            );
            
            log.info("AI返回的标题生成结果: {}", result);
            return result;
            
        } catch (Exception e) {
            log.error("标题生成失败，详细错误: {}", e.getMessage(), e);
            return "[{\"error\": \"标题生成失败: " + e.getMessage() + "\"}]";
        }
    }

    @Operation(summary = "生成完整文档")
    @PostMapping(value = "/generate-full-document", produces = "text/plain;charset=UTF-8")
    public Flux<String> generateFullDocument(@RequestBody GenerateFullDocumentRequest request) {
        log.info("收到全文生成请求，主题: {}, 文档类型: {}", request.getTopic(), request.getDocumentType());
        log.info("请求详情 - 大纲标题: {}, 内容要求: {}, 预估字数: {}, 写作风格: {}", 
                request.getOutlineTitles(), request.getContentRequirement(), 
                request.getEstimatedWordCount(), request.getWritingStyle());
        
        // 🛡️ 输入验证
        if (request.getTopic() == null || request.getTopic().trim().isEmpty()) {
            log.error("主题不能为空");
            return Flux.just("错误：主题不能为空");
        }
        
        if (request.getDocumentType() == null || request.getDocumentType().trim().isEmpty()) {
            log.error("文档类型不能为空");
            return Flux.just("错误：文档类型不能为空");
        }
        
        if (request.getOutlineTitles() == null || request.getOutlineTitles().trim().isEmpty()) {
            log.error("大纲标题不能为空");
            return Flux.just("错误：请先生成大纲标题");
        }
        
        // 设置默认值
        String contentRequirement = request.getContentRequirement() != null ? 
            request.getContentRequirement() : "请生成详细、专业的内容";
        String estimatedWordCount = request.getEstimatedWordCount() != null ? 
            request.getEstimatedWordCount() : "2000字左右";
        String writingStyle = request.getWritingStyle() != null ? 
            request.getWritingStyle() : "专业、准确";
        
        try {
            log.info("开始调用AI服务生成全文");
            // 生成一个独立的memoryId用于全文生成
            Long memoryId = System.currentTimeMillis();
            log.info("使用memoryId: {}", memoryId);
            
            return xiaozhiAgent.generateFullDocument(
                memoryId,
                request.getTopic().trim(),
                request.getDocumentType().trim(),
                request.getOutlineTitles().trim(),
                contentRequirement.trim(),
                estimatedWordCount.trim(),
                writingStyle.trim()
            ).onErrorReturn("生成过程中出现错误，请重新尝试。");
        } catch (Exception e) {
            log.error("全文生成失败", e);
            return Flux.just("抱歉，全文生成失败，请稍后重试。错误详情：" + e.getMessage());
        }
    }

    @Operation(summary = "生成单个标题内容")
    @PostMapping(value = "/generate-title-content", produces = "text/plain;charset=UTF-8")
    public Flux<String> generateTitleContent(@RequestBody GenerateTitleContentRequest request) {
        log.info("收到单标题内容生成请求，标题: {}", request.getCurrentTitle());
        
        try {
            return xiaozhiAgent.generateTitleContent(
                request.getTopic(),
                request.getCurrentTitle(),
                request.getTitleDescription(),
                request.getContextInfo(),
                request.getWordCountRequirement()
            );
        } catch (Exception e) {
            log.error("单标题内容生成失败", e);
            return Flux.just("抱歉，内容生成失败，请稍后重试。");
        }
    }

    @Operation(summary = "智能补充标题建议")
    @PostMapping("/suggest-additional-titles")
    public String suggestAdditionalTitles(@RequestBody SuggestAdditionalTitlesRequest request) {
        log.info("收到标题补充建议请求，主题: {}", request.getTopic());
        
        try {
            return xiaozhiAgent.suggestAdditionalTitles(
                request.getTopic(),
                request.getDocumentType(),
                request.getExistingTitles(),
                request.getContentRequirement()
            );
        } catch (Exception e) {
            log.error("标题补充建议失败", e);
            return "[{\"error\": \"标题建议生成失败，请稍后重试\"}]";
        }
    }

    // ===== 请求实体类 =====

    /**
     * AI识别请求实体
     */
    public static class AnalyzeRequirementRequest {
        private String topic;
        private String contentRequirement;

        // Getters and Setters
        public String getTopic() {
            return topic;
        }

        public void setTopic(String topic) {
            this.topic = topic;
        }

        public String getContentRequirement() {
            return contentRequirement;
        }

        public void setContentRequirement(String contentRequirement) {
            this.contentRequirement = contentRequirement;
        }
    }

    /**
     * 生成大纲标题请求实体
     */
    public static class GenerateOutlineTitlesRequest {
        private String topic;
        private String documentType;
        private String keyPoints;
        private String contentRequirement;

        // Getters and Setters
        public String getTopic() {
            return topic;
        }

        public void setTopic(String topic) {
            this.topic = topic;
        }

        public String getDocumentType() {
            return documentType;
        }

        public void setDocumentType(String documentType) {
            this.documentType = documentType;
        }

        public String getKeyPoints() {
            return keyPoints;
        }

        public void setKeyPoints(String keyPoints) {
            this.keyPoints = keyPoints;
        }

        public String getContentRequirement() {
            return contentRequirement;
        }

        public void setContentRequirement(String contentRequirement) {
            this.contentRequirement = contentRequirement;
        }
    }

    /**
     * 生成完整文档请求实体
     */
    public static class GenerateFullDocumentRequest {
        private String topic;
        private String documentType;
        private String outlineTitles;
        private String contentRequirement;
        private String estimatedWordCount;
        private String writingStyle;

        // Getters and Setters
        public String getTopic() {
            return topic;
        }

        public void setTopic(String topic) {
            this.topic = topic;
        }

        public String getDocumentType() {
            return documentType;
        }

        public void setDocumentType(String documentType) {
            this.documentType = documentType;
        }

        public String getOutlineTitles() {
            return outlineTitles;
        }

        public void setOutlineTitles(String outlineTitles) {
            this.outlineTitles = outlineTitles;
        }

        public String getContentRequirement() {
            return contentRequirement;
        }

        public void setContentRequirement(String contentRequirement) {
            this.contentRequirement = contentRequirement;
        }

        public String getEstimatedWordCount() {
            return estimatedWordCount;
        }

        public void setEstimatedWordCount(String estimatedWordCount) {
            this.estimatedWordCount = estimatedWordCount;
        }

        public String getWritingStyle() {
            return writingStyle;
        }

        public void setWritingStyle(String writingStyle) {
            this.writingStyle = writingStyle;
        }
    }

    /**
     * 生成单个标题内容请求实体
     */
    public static class GenerateTitleContentRequest {
        private String topic;
        private String currentTitle;
        private String titleDescription;
        private String contextInfo;
        private String wordCountRequirement;

        // Getters and Setters
        public String getTopic() {
            return topic;
        }

        public void setTopic(String topic) {
            this.topic = topic;
        }

        public String getCurrentTitle() {
            return currentTitle;
        }

        public void setCurrentTitle(String currentTitle) {
            this.currentTitle = currentTitle;
        }

        public String getTitleDescription() {
            return titleDescription;
        }

        public void setTitleDescription(String titleDescription) {
            this.titleDescription = titleDescription;
        }

        public String getContextInfo() {
            return contextInfo;
        }

        public void setContextInfo(String contextInfo) {
            this.contextInfo = contextInfo;
        }

        public String getWordCountRequirement() {
            return wordCountRequirement;
        }

        public void setWordCountRequirement(String wordCountRequirement) {
            this.wordCountRequirement = wordCountRequirement;
        }
    }

    /**
     * 智能补充标题建议请求实体
     */
    public static class SuggestAdditionalTitlesRequest {
        private String topic;
        private String documentType;
        private String existingTitles;
        private String contentRequirement;

        // Getters and Setters
        public String getTopic() {
            return topic;
        }

        public void setTopic(String topic) {
            this.topic = topic;
        }

        public String getDocumentType() {
            return documentType;
        }

        public void setDocumentType(String documentType) {
            this.documentType = documentType;
        }

        public String getExistingTitles() {
            return existingTitles;
        }

        public void setExistingTitles(String existingTitles) {
            this.existingTitles = existingTitles;
        }

        public String getContentRequirement() {
            return contentRequirement;
        }

        public void setContentRequirement(String contentRequirement) {
            this.contentRequirement = contentRequirement;
        }
    }
}