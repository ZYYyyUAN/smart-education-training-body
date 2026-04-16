package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.entity.ChatMessageRequest;
import com.atguigu.java.ai.langchain4j.entity.ChatMessageResponse;
import com.atguigu.java.ai.langchain4j.entity.Result;
import com.atguigu.java.ai.langchain4j.service.CourseChatLogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 聊天记录控制器
 */
@Slf4j
@Tag(name = "聊天记录管理")
@RestController
@RequestMapping("/chat")
public class ChatController {
    
    @Autowired
    private CourseChatLogService courseChatLogService;
    
    @Operation(summary = "保存聊天消息")
    @PostMapping("/save")
    public Result<Long> saveChatMessage(@RequestBody ChatMessageRequest request) {
        log.info("收到保存聊天消息请求: {}", request);
        
        try {
            // 参数验证
            if (request.getCourseId() == null) {
                return Result.error("课程ID不能为空");
            }
            if (request.getSenderName() == null || request.getSenderName().trim().isEmpty()) {
                return Result.error("发送者姓名不能为空");
            }
            if (request.getMessageContent() == null || request.getMessageContent().trim().isEmpty()) {
                return Result.error("消息内容不能为空");
            }
            
            Long messageId = courseChatLogService.saveChatMessage(request);
            return Result.ok(messageId);
            
        } catch (Exception e) {
            log.error("保存聊天消息失败", e);
            return Result.error("保存聊天消息失败: " + e.getMessage());
        }
    }
    
    @Operation(summary = "获取聊天记录")
    @GetMapping("/history")
    public Result<List<ChatMessageResponse>> getChatHistory(
            @Parameter(description = "课程ID") @RequestParam(name = "courseId") Long courseId,
            @Parameter(description = "限制条数，默认50") @RequestParam(name = "limit", defaultValue = "50") Integer limit,
            @Parameter(description = "偏移量，默认0") @RequestParam(name = "offset", defaultValue = "0") Integer offset) {
        
        log.info("获取聊天记录请求: courseId={}, limit={}, offset={}", courseId, limit, offset);
        
        try {
            if (courseId == null) {
                return Result.error("课程ID不能为空");
            }
            
            List<ChatMessageResponse> history = 
                    courseChatLogService.getChatHistory(courseId, limit, offset);
            
            return Result.ok(history);
            
        } catch (Exception e) {
            log.error("获取聊天记录失败", e);
            return Result.error("获取聊天记录失败: " + e.getMessage());
        }
    }
    
    @Operation(summary = "获取聊天统计")
    @GetMapping("/stats/{courseId}")
    public Result<CourseChatLogService.ChatStatistics> getChatStatistics(
            @Parameter(description = "课程ID") @PathVariable Long courseId) {
        
        log.info("获取聊天统计请求: courseId={}", courseId);
        
        try {
            if (courseId == null) {
                return Result.error("课程ID不能为空");
            }
            
            CourseChatLogService.ChatStatistics statistics = courseChatLogService.getChatStatistics(courseId);
            return Result.ok(statistics);
            
        } catch (Exception e) {
            log.error("获取聊天统计失败", e);
            return Result.error("获取聊天统计失败: " + e.getMessage());
        }
    }
    
    @Operation(summary = "删除聊天消息")
    @DeleteMapping("/delete/{messageId}")
    public Result<String> deleteChatMessage(
            @Parameter(description = "消息ID") @PathVariable Long messageId) {
        
        log.info("删除聊天消息请求: messageId={}", messageId);
        
        try {
            if (messageId == null) {
                return Result.error("消息ID不能为空");
            }
            
            boolean success = courseChatLogService.deleteChatMessage(messageId);
            
            if (success) {
                return Result.ok("聊天消息删除成功");
            } else {
                return Result.error("聊天消息删除失败，消息可能不存在");
            }
            
        } catch (Exception e) {
            log.error("删除聊天消息失败", e);
            return Result.error("删除聊天消息失败: " + e.getMessage());
        }
    }
}
