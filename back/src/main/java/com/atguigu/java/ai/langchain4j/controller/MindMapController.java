package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.assistant.XiaozhiAgent;
import com.atguigu.java.ai.langchain4j.entity.MindMapRequest;
import com.atguigu.java.ai.langchain4j.entity.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;

@Tag(name = "思维导图")
@RestController
@RequestMapping("/mind-map")
@Slf4j
public class MindMapController {

    @Autowired
    private XiaozhiAgent xiaozhiAgent;

    @Operation(summary = "生成思维导图")
    @PostMapping("/generate")
    public Result<Map<String, Object>> generateMindMap(@RequestBody MindMapRequest request) {
        log.info("收到思维导图生成请求，文件名: {}, 导图类型: {}", request.getFileName(), request.getMapType());
        
        try {
            // 验证请求参数
            if (request.getDocumentContent() == null || request.getDocumentContent().trim().isEmpty()) {
                return Result.error("文档内容不能为空");
            }
            
            if (request.getFileName() == null || request.getFileName().trim().isEmpty()) {
                return Result.error("文件名不能为空");
            }
            
            // 设置默认导图类型
            if (request.getMapType() == null || request.getMapType().trim().isEmpty()) {
                request.setMapType("hierarchical");
            }
            
            // 调用AI生成思维导图
            String mindMapDataString = xiaozhiAgent.generateMindMapStructure(
                request.getFileName(),
                request.getDocumentContent(),
                request.getMapType()
            );
            
            log.info("AI返回的思维导图数据: {}", mindMapDataString);
            
            // 构建返回结果
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("fileName", request.getFileName());
            responseData.put("generatedAt", System.currentTimeMillis());
            responseData.put("mindMapData", mindMapDataString);
            responseData.put("mapType", request.getMapType());
            
            return Result.ok(responseData);
            
        } catch (Exception e) {
            log.error("生成思维导图失败", e);
            return Result.error("生成思维导图失败: " + e.getMessage());
        }
    }

    @Operation(summary = "测试思维导图服务连接")
    @GetMapping("/test")
    public Result<String> testConnection() {
        log.info("测试思维导图服务连接");
        return Result.ok("思维导图服务连接正常");
    }
}