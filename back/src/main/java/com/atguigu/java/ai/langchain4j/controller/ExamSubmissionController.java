package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.entity.Result;
import com.atguigu.java.ai.langchain4j.entity.dto.ExamSubmissionRequest;
import com.atguigu.java.ai.langchain4j.service.ExamSubmissionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 考试提交控制器
 */
@Slf4j
@RestController
@RequestMapping("/exam")
@Tag(name = "考试提交", description = "考试提交和AI批阅相关接口")
public class ExamSubmissionController {
    
    @Autowired
    private ExamSubmissionService examSubmissionService;
    
    @PostMapping("/submit")
    @Operation(summary = "提交考试", description = "提交考试答案并进行AI批阅")
    public Result<Map<String, Object>> submitExam(@RequestBody ExamSubmissionRequest request) {
        log.info("收到考试提交请求: examId={}, studentId={}", request.getExamId(), request.getStudentId());
        return examSubmissionService.submitExam(request);
    }
}
