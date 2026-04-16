package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.assistant.XiaozhiAgent;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;

/**
 * 教师AI助手控制器
 */
@Tag(name = "教师AI助手")
@RestController
@Slf4j
public class TeacherAssistantController {

    @Autowired
    private XiaozhiAgent xiaozhiAgent;

    @Operation(summary = "教师AI助手对话")
    @PostMapping(value = "/teacher-assistant", produces = "text/plain;charset=UTF-8")
    public Flux<String> teacherAssistant(@RequestBody TeacherAssistantRequest request) {
        log.info("收到教师AI助手请求，memoryId: {}, message: {}", request.getMemoryId(), request.getUserMessage());
        
        try {
            // 调用XiaozhiAgent的teacherAssistant方法
            return xiaozhiAgent.teacherAssistant(request.getMemoryId(), request.getUserMessage());
        } catch (Exception e) {
            log.error("教师AI助手响应失败", e);
            return Flux.just("抱歉，AI助手暂时无法响应，请稍后重试。");
        }
    }

    /**
     * 教师AI助手请求实体
     */
    public static class TeacherAssistantRequest {
        private Long memoryId;
        private String userMessage;

        // Getters and Setters
        public Long getMemoryId() {
            return memoryId;
        }

        public void setMemoryId(Long memoryId) {
            this.memoryId = memoryId;
        }

        public String getUserMessage() {
            return userMessage;
        }

        public void setUserMessage(String userMessage) {
            this.userMessage = userMessage;
        }
    }
}

