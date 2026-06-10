 package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.assistant.XiaozhiAgent;
import com.atguigu.java.ai.langchain4j.entity.DocumentSummaryRequest;
import com.atguigu.java.ai.langchain4j.entity.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import reactor.core.publisher.Flux;
import org.springframework.web.multipart.MultipartFile;
import java.util.HashMap;
import java.util.Map;
import com.atguigu.java.ai.langchain4j.service.XunfeiOCRServiceOfficial;
import org.apache.commons.codec.binary.Base64;

@Tag(name = "AI阅读器")
@RestController
@RequestMapping("/ai-reader")
@Slf4j
public class AiReaderController {

    @Autowired
    private XiaozhiAgent xiaozhiAgent;

    @Autowired
    private XunfeiOCRServiceOfficial xunfeiOCRServiceOfficial;

    @Operation(summary = "生成文档内容概括")
    @PostMapping(value = "/generate-summary", produces = "text/plain;charset=UTF-8")
    public Flux<String> generateDocumentSummary(@RequestBody DocumentSummaryRequest request) {
        log.info("收到文档概括请求，文件名: {}", request.getFileName());
        
        // 参数验证
        if (request.getFileName() == null || request.getFileName().trim().isEmpty()) {
            log.error("文件名为空");
            return Flux.just("错误：文件名不能为空");
        }
        
        if (request.getContent() == null || request.getContent().trim().isEmpty()) {
            log.error("文档内容为空");
            return Flux.just("错误：文档内容不能为空");
        }
        
        try {
            log.info("调用AI生成文档概括，参数 - 文件名: {}, 文档长度: {}", 
                request.getFileName(), request.getContent().length());
            
            return xiaozhiAgent.generateDocumentSummary(request.getFileName(), request.getContent())
                .doOnError(error -> {
                    log.error("AI生成文档概括流处理错误", error);
                }).onErrorResume(error -> {
                    log.error("AI生成文档概括失败，返回错误信息", error);
                    return Flux.just("AI生成文档概括失败: " + error.getMessage());
                });
        } catch (Exception e) {
            log.error("AI生成文档概括调用失败", e);
            return Flux.just("AI生成文档概括调用失败: " + e.getMessage());
        }
    }

    @Operation(summary = "生成文档内容摘要")
    @PostMapping(value = "/generate-digest", produces = "text/plain;charset=UTF-8")
    public Flux<String> generateDocumentDigest(@RequestBody DocumentSummaryRequest request) {
        log.info("收到文档摘要请求，文件名: {}", request.getFileName());
        
        // 参数验证
        if (request.getFileName() == null || request.getFileName().trim().isEmpty()) {
            log.error("文件名为空");
            return Flux.just("错误：文件名不能为空");
        }
        
        if (request.getContent() == null || request.getContent().trim().isEmpty()) {
            log.error("文档内容为空");
            return Flux.just("错误：文档内容不能为空");
        }
        
        try {
            log.info("调用AI生成文档摘要，参数 - 文件名: {}, 文档长度: {}", 
                request.getFileName(), request.getContent().length());
            
            return xiaozhiAgent.generateDocumentDigest(request.getFileName(), request.getContent())
                .doOnError(error -> {
                    log.error("AI生成文档摘要流处理错误", error);
                }).onErrorResume(error -> {
                    log.error("AI生成文档摘要失败，返回错误信息", error);
                    return Flux.just("AI生成文档摘要失败: " + error.getMessage());
                });
        } catch (Exception e) {
            log.error("AI生成文档摘要调用失败", e);
            return Flux.just("AI生成文档摘要调用失败: " + e.getMessage());
        }
    }

    @Operation(summary = "测试编码API")
    @GetMapping(value = "/test-encoding", produces = "text/plain;charset=UTF-8")
    public String testEncoding() {
        log.info("测试编码API被调用");
        
        // 返回一个简单的字符串，测试编码
        return "这是一个测试编码的API。测试中文显示是否正常。包含一些特殊字符：！@#￥%……&*（）测试完成！";
    }

    @Operation(summary = "测试编码API - 带响应头")
    @GetMapping(value = "/test-encoding-headers", produces = "text/plain;charset=UTF-8")
    public String testEncodingWithHeaders() {
        log.info("测试编码API（带响应头）被调用");
        
        // 返回一个简单的字符串，测试编码
        return "这是一个测试编码的API（带响应头）。测试中文显示是否正常。包含一些特殊字符：！@#￥%……&*（）测试完成！";
    }

    @Operation(summary = "测试AI阅读器 - 简单文本")
    @GetMapping(value = "/test-ai-reader-simple", produces = "text/plain;charset=UTF-8")
    public String testAiReaderSimple() {
        log.info("测试AI阅读器简单接口被调用");
        
        // 模拟AI生成的内容
        return """
            这是一个测试AI阅读器的简单接口。
            
            文档内容概括：
            1. 嵌入式系统开发教学大纲
            2. 课程目标明确，理论与实践相结合
            3. 教学内容由浅入深，循序渐进
            4. 通过课程项目提升综合应用能力
            
            测试完成！中文显示应该正常。
            """;
    }

    @Operation(summary = "测试AI阅读器 - 模拟流式响应")
    @GetMapping(value = "/test-ai-reader-stream", produces = "text/plain;charset=UTF-8")
    public Flux<String> testAiReaderStream() {
        log.info("测试AI阅读器流式接口被调用");
        
        // 模拟AI流式生成的内容
        return Flux.just(
            "这是一个测试AI阅读器的流式接口。\n\n",
            "文档内容概括：\n",
            "1. 嵌入式系统开发教学大纲\n",
            "2. 课程目标明确，理论与实践相结合\n",
            "3. 教学内容由浅入深，循序渐进\n",
            "4. 通过课程项目提升综合应用能力\n\n",
            "测试完成！中文显示应该正常。"
        ).delayElements(java.time.Duration.ofMillis(300));
    }

    @Operation(summary = "测试真实流式输出")
    @GetMapping(value = "/test-real-stream", produces = "text/plain;charset=UTF-8")
    public Flux<String> testRealStream() {
        log.info("测试真实流式输出接口被调用");
        
        // 创建一个真正的流式输出，每个字符都有延迟
        String text = "这是一个真正的流式输出测试。我们将逐字符输出，模拟AI模型的真实流式响应。每个字符之间都有100毫秒的延迟，这样你就能看到真正的流式效果了。";
        
        return Flux.fromArray(text.split(""))
                .delayElements(java.time.Duration.ofMillis(100))
                .map(character -> character.equals(" ") ? " " : character);
    }

    @Operation(summary = "测试AI模型流式输出")
    @PostMapping(value = "/test-ai-stream", produces = "text/plain;charset=UTF-8")
    public Flux<String> testAiModelStream(@RequestBody DocumentSummaryRequest request) {
        log.info("测试AI模型流式输出接口被调用");
        
        try {
            // 直接调用AI模型，看看是否真的流式输出
            log.info("开始调用AI模型...");
            Flux<String> result = xiaozhiAgent.generateDocumentSummary(request.getFileName(), request.getContent());
            log.info("AI模型调用完成，返回Flux");
            return result;
        } catch (Exception e) {
            log.error("AI模型调用失败", e);
            return Flux.just("AI模型调用失败: " + e.getMessage());
        }
    }

    @Operation(summary = "OCR图片文字识别")
    @PostMapping(value = "/ocr", consumes = "multipart/form-data", produces = "application/json")
    public ResponseEntity<Map<String, Object>> performOCR(@RequestParam("image") MultipartFile image) {
        log.info("OCR接口被调用，文件名: {}", image.getOriginalFilename());

        Map<String, Object> response = new HashMap<>();

        try {
            String imageBase64 = validateImageAndEncode(image);
            log.info("图片已转换为Base64");

            String ocrText = xunfeiOCRServiceOfficial.performOCR(imageBase64);

            response.put("success", true);
            response.put("text", ocrText);
            response.put("message", "OCR识别成功");
            log.info("OCR识别完成，识别文字长度: {}", ocrText.length());

            return ResponseEntity.ok(response);

        } catch (IllegalArgumentException e) {
            log.warn("图片校验失败: {}", e.getMessage());
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        } catch (Exception e) {
            log.error("OCR识别失败", e);
            response.put("success", false);
            response.put("message", "OCR识别失败: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }

    @Operation(summary = "OCR图片文字识别 - 返回完整坐标信息")
    @PostMapping(value = "/ocr-with-coordinates", consumes = "multipart/form-data", produces = "application/json")
    public ResponseEntity<Map<String, Object>> performOCRWithCoordinates(@RequestParam("image") MultipartFile image) {
        log.info("OCR完整接口被调用，文件名: {}", image.getOriginalFilename());

        Map<String, Object> response = new HashMap<>();

        try {
            String imageBase64 = validateImageAndEncode(image);
            log.info("图片已转换为Base64");

            String ocrResult = xunfeiOCRServiceOfficial.performOCRWithCoordinates(imageBase64);

            response.put("success", true);
            response.put("result", ocrResult);
            response.put("message", "OCR识别成功");
            log.info("OCR识别完成，返回完整结果");

            return ResponseEntity.ok(response);

        } catch (IllegalArgumentException e) {
            log.warn("图片校验失败: {}", e.getMessage());
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        } catch (Exception e) {
            log.error("OCR识别失败", e);
            response.put("success", false);
            response.put("message", "OCR识别失败: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 校验图片文件类型和大小，返回Base64编码字符串
     */
    private String validateImageAndEncode(MultipartFile image) throws Exception {
        String contentType = image.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("请上传有效的图片文件");
        }
        if (image.getSize() > 4 * 1024 * 1024) {
            throw new IllegalArgumentException("图片文件过大，请上传小于4MB的图片");
        }
        byte[] imageBytes = image.getBytes();
        String imageBase64 = Base64.encodeBase64String(imageBytes);
        log.info("图片已转换为Base64，大小: {} bytes", imageBytes.length);
        return imageBase64;
    }

}
