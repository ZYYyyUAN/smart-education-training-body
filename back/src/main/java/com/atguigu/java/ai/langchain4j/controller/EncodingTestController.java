package com.atguigu.java.ai.langchain4j.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.nio.charset.StandardCharsets;

@Tag(name = "编码测试")
@RestController
@RequestMapping("/encoding-test")
@Slf4j
public class EncodingTestController {

    @Operation(summary = "测试编码 - 使用ResponseEntity")
    @GetMapping("/test-response-entity")
    public ResponseEntity<String> testEncodingWithResponseEntity() {
        log.info("测试编码API（ResponseEntity）被调用");
        
        String content = "这是一个测试编码的API（ResponseEntity）。测试中文显示是否正常。包含一些特殊字符：！@#￥%……&*（）测试完成！";
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.TEXT_PLAIN);
        headers.set(HttpHeaders.CONTENT_TYPE, "text/plain; charset=UTF-8");
        
        return ResponseEntity.ok()
                .headers(headers)
                .body(content);
    }

    @Operation(summary = "测试编码 - 使用字节数组")
    @GetMapping(value = "/test-bytes", produces = "text/plain;charset=UTF-8")
    public byte[] testEncodingWithBytes() {
        log.info("测试编码API（字节数组）被调用");
        
        String content = "这是一个测试编码的API（字节数组）。测试中文显示是否正常。包含一些特殊字符：！@#￥%……&*（）测试完成！";
        
        return content.getBytes(StandardCharsets.UTF_8);
    }

    @Operation(summary = "测试编码 - 简单字符串")
    @GetMapping(value = "/test-simple", produces = "text/plain;charset=UTF-8")
    public String testEncodingSimple() {
        log.info("测试编码API（简单字符串）被调用");
        
        return "这是一个测试编码的API（简单字符串）。测试中文显示是否正常。包含一些特殊字符：！@#￥%……&*（）测试完成！";
    }

    @Operation(summary = "测试编码 - 返回HTML")
    @GetMapping(value = "/test-html", produces = "text/html;charset=UTF-8")
    public String testEncodingHtml() {
        log.info("测试编码API（HTML）被调用");
        
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <title>编码测试</title>
            </head>
            <body>
                <h1>编码测试结果</h1>
                <p>这是一个测试编码的API（HTML）。测试中文显示是否正常。</p>
                <p>包含一些特殊字符：！@#￥%……&*（）</p>
                <p>测试完成！</p>
            </body>
            </html>
            """;
    }
}
