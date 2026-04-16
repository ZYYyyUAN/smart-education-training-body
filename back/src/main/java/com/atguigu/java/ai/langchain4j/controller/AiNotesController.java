package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.assistant.XiaozhiAgent;
import com.atguigu.java.ai.langchain4j.entity.NotesGenerateRequest;
import com.atguigu.java.ai.langchain4j.entity.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import java.util.List;
import java.util.Map;

@Tag(name = "AI学习笔记")
@RestController
@RequestMapping("/ai-notes-generation")
@Slf4j
public class AiNotesController {

    @Autowired
    private XiaozhiAgent xiaozhiAgent;

    @Operation(summary = "AI生成学习笔记")
    @PostMapping(value = "/generate", produces = "text/plain;charset=UTF-8")
    public Flux<String> generateNotes(@RequestBody NotesGenerateRequest request) {
        log.info("收到AI学习笔记生成请求，文件名: {}", request.getFileName());
        
        try {
            // 验证请求参数
            if (request.getFileName() == null || request.getFileName().trim().isEmpty()) {
                log.error("文件名不能为空");
                return Flux.just("错误：文件名不能为空");
            }
            
            if (request.getDocumentContent() == null || request.getDocumentContent().trim().isEmpty()) {
                log.error("文档内容不能为空");
                return Flux.just("错误：文档内容不能为空");
            }
            
            log.info("开始调用AI服务生成学习笔记，文档内容长度: {}", request.getDocumentContent().length());
            
            return xiaozhiAgent.generateStudyNotes(
                request.getFileName().trim(),
                request.getDocumentContent().trim()
            ).onErrorReturn("生成学习笔记过程中出现错误，请重新尝试。");
            
        } catch (Exception e) {
            log.error("AI学习笔记生成失败", e);
            return Flux.just("抱歉，AI学习笔记生成失败，请稍后重试。错误详情：" + e.getMessage());
        }
    }

    @Operation(summary = "AI优化笔记内容")
    @PostMapping(value = "/optimize", produces = "text/plain;charset=UTF-8")
    public Flux<String> optimizeNotes(@RequestBody Map<String, String> request) {
        log.info("收到笔记优化请求，标题: {}", request.get("title"));
        
        try {
            String title = request.getOrDefault("title", "");
            String content = request.getOrDefault("content", "");
            String optimizationType = request.getOrDefault("optimizationType", "structure");
            
            if (title.trim().isEmpty() || content.trim().isEmpty()) {
                return Flux.just("错误：标题和内容不能为空");
            }
            
            return xiaozhiAgent.optimizeNotes(title, content, optimizationType)
                .onErrorReturn("优化笔记过程中出现错误，请重新尝试。");
            
        } catch (Exception e) {
            log.error("笔记优化失败", e);
            return Flux.just("抱歉，笔记优化失败，请稍后重试。");
        }
    }

    @Operation(summary = "生成笔记摘要")
    @PostMapping("/summary")
    public Result<String> generateSummary(@RequestBody Map<String, String> request) {
        log.info("收到笔记摘要生成请求，标题: {}", request.get("title"));
        
        try {
            String title = request.getOrDefault("title", "");
            String content = request.getOrDefault("content", "");
            
            if (title.trim().isEmpty() || content.trim().isEmpty()) {
                return Result.error("标题和内容不能为空");
            }
            
            String summary = xiaozhiAgent.generateNotesSummary(title, content);
            return Result.ok(summary);
            
        } catch (Exception e) {
            log.error("生成笔记摘要失败", e);
            return Result.error("生成笔记摘要失败：" + e.getMessage());
        }
    }

    @Operation(summary = "生成笔记标签")
    @PostMapping("/tags")
    public Result<List<String>> generateTags(@RequestBody Map<String, String> request) {
        log.info("收到笔记标签生成请求，标题: {}", request.get("title"));
        
        try {
            String title = request.getOrDefault("title", "");
            String content = request.getOrDefault("content", "");
            
            if (title.trim().isEmpty() || content.trim().isEmpty()) {
                return Result.error("标题和内容不能为空");
            }
            
            List<String> tags = xiaozhiAgent.generateNotesTags(title, content);
            return Result.ok(tags);
            
        } catch (Exception e) {
            log.error("生成笔记标签失败", e);
            return Result.error("生成笔记标签失败：" + e.getMessage());
        }
    }

    @Operation(summary = "提取知识点")
    @PostMapping("/knowledge-points")
    public Result<String> extractKnowledgePoints(@RequestBody Map<String, String> request) {
        log.info("收到知识点提取请求，标题: {}", request.get("title"));
        
        try {
            String title = request.getOrDefault("title", "");
            String content = request.getOrDefault("content", "");
            
            if (title.trim().isEmpty() || content.trim().isEmpty()) {
                return Result.error("标题和内容不能为空");
            }
            
            String knowledgePoints = xiaozhiAgent.extractKnowledgePoints(title, content);
            return Result.ok(knowledgePoints);
            
        } catch (Exception e) {
            log.error("提取知识点失败", e);
            return Result.error("提取知识点失败：" + e.getMessage());
        }
    }

    @Operation(summary = "测试AI学习笔记连接")
    @GetMapping("/test")
    public Result<String> testConnection() {
        log.info("测试AI学习笔记连接");
        return Result.ok("AI学习笔记服务连接正常");
    }
}
