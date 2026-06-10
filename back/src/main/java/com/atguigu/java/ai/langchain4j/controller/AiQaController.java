package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.assistant.XiaozhiAgent;
import com.atguigu.java.ai.langchain4j.entity.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import java.util.Map;
import java.util.List;
import java.util.Arrays;

@Tag(name = "AI问答")
@RestController
@RequestMapping("/ai-qa")
@Slf4j
public class AiQaController {

    @Autowired
    private XiaozhiAgent xiaozhiAgent;

    @Operation(summary = "AI智能问答 - 流式响应")
    @PostMapping(value = "/chat", produces = "text/plain;charset=UTF-8")
    public Flux<String> aiChat(@RequestBody Map<String, String> request) {
        log.info("收到AI问答请求，问题: {}", request.get("question"));
        
        String question = request.getOrDefault("question", "");
        
        // 使用普通聊天功能回答问题
        return xiaozhiAgent.chat(1L, question);
    }

    @Operation(summary = "获取快速问题建议")
    @PostMapping("/quick-questions")
    public Result<List<String>> getQuickQuestions(@RequestBody Map<String, String> request) {
        log.info("获取快速问题建议，文档类型: {}", request.get("documentType"));
        
        String documentType = request.getOrDefault("documentType", "general");
        String fileName = request.getOrDefault("fileName", "");
        
        try {
            List<String> quickQuestions = xiaozhiAgent.generateQuickQuestions(documentType, fileName);
            return Result.ok(quickQuestions);
        } catch (Exception e) {
            log.error("生成快速问题失败", e);
            // 返回默认快速问题
            List<String> defaultQuestions = Arrays.asList(
                "📋 总结文档要点",
                "🔍 解释关键概念", 
                "💡 提供学习建议",
                "📊 分析数据内容"
            );
            return Result.ok(defaultQuestions);
        }
    }

    @Operation(summary = "基于文档内容的智能问答")
    @PostMapping(value = "/document-qa", produces = "text/plain;charset=UTF-8")
    public Flux<String> documentQa(@RequestBody Map<String, String> request) {
        log.info("收到文档问答请求，问题: {}", request.get("question"));
        
        String question = request.getOrDefault("question", "");
        String documentContent = request.getOrDefault("documentContent", "");
        String fileName = request.getOrDefault("fileName", "");
        String chatHistory = request.getOrDefault("chatHistory", "");
        
        try {
            return xiaozhiAgent.answerDocumentBasedQuestion(
                question,
                documentContent,
                fileName
            );
        } catch (Exception e) {
            log.error("文档问答失败", e);
            return Flux.just("抱歉，处理您的问题时遇到了错误：" + e.getMessage());
        }
    }

    @Operation(summary = "测试AI问答连接")
    @GetMapping("/test")
    public Result<String> testConnection() {
        log.info("测试AI问答连接");
        return Result.ok("AI问答服务连接正常");
    }
}