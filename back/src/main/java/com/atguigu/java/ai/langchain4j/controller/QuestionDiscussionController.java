package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.entity.*;
import com.atguigu.java.ai.langchain4j.service.QuestionDiscussionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "问答讨论模块")
@RestController
@RequestMapping("/questions")
public class QuestionDiscussionController {

    @Autowired
    private QuestionDiscussionService questionDiscussionService;

    @Operation(summary = "获取课程下所有问答讨论")
    @GetMapping
    public Result<List<Question>> getQuestionsByCourseId(@RequestParam("courseId") Integer courseId) {
        try {
            List<Question> questions = questionDiscussionService.getQuestionsByCourseId(courseId);
            return Result.ok(questions);
        } catch (Exception e) {
            return Result.error("获取问答讨论失败: " + e.getMessage());
        }
    }

    @Operation(summary = "创建新问题")
    @PostMapping
    public Result<String> createQuestion(@RequestBody CreateQuestionRequest request) {
        try {
            boolean success = questionDiscussionService.createQuestion(request);
            if (success) {
                return Result.ok("问题发布成功");
            } else {
                return Result.error("问题发布失败");
            }
        } catch (Exception e) {
            return Result.error("问题发布失败: " + e.getMessage());
        }
    }

    @Operation(summary = "获取问题详情及所有回答")
    @GetMapping("/answers")
    public Result<QuestionDetailDTO> getQuestionDetail(@RequestParam("questionId") Integer questionId) {
        try {
            QuestionDetailDTO detail = questionDiscussionService.getQuestionDetail(questionId);
            if (detail != null) {
                return Result.ok(detail);
            } else {
                return Result.error("问题不存在");
            }
        } catch (Exception e) {
            return Result.error("获取问题详情失败: " + e.getMessage());
        }
    }

    @Operation(summary = "创建回答")
    @PostMapping("/createAnswer")
    public Result<String> createAnswer(@RequestBody CreateAnswerRequest request) {
        try {
            boolean success = questionDiscussionService.createAnswer(request);
            if (success) {
                return Result.ok("回答发布成功");
            } else {
                return Result.error("回答发布失败");
            }
        } catch (Exception e) {
            return Result.error("回答发布失败: " + e.getMessage());
        }
    }
} 