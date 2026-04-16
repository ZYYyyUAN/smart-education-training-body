package com.atguigu.java.ai.langchain4j.service.Impl;

import com.alibaba.dashscope.exception.ApiException;
import com.atguigu.java.ai.langchain4j.assistant.XiaozhiAgent;
import com.atguigu.java.ai.langchain4j.entity.*;
import com.atguigu.java.ai.langchain4j.mapper.AssignmentSubmissionMapper;
import com.atguigu.java.ai.langchain4j.service.AssignmentSubmissionDetailService;
import com.atguigu.java.ai.langchain4j.service.AssignmentSubmissionService;
import com.atguigu.java.ai.langchain4j.service.PracticeService;
import com.atguigu.java.ai.langchain4j.service.QuestionService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;

import java.time.LocalDateTime;

@Service
public class AssignmentSubmissionServiceImpl implements AssignmentSubmissionService {

    @Autowired
    private AssignmentSubmissionMapper submissionMapper;

    @Autowired
    private AssignmentSubmissionDetailService detailService;

    @Autowired
    private PracticeService practiceLogService;

    @Autowired
    private QuestionService questionBankService;

    @Autowired
    private XiaozhiAgent xiaozhiAgent;

    @Override
    public Long saveSubmission(SubmitAssignmentRequest request) {
        // 1. 检查是否已经提交过
        AssignmentSubmission existingSubmission = submissionMapper.selectByAssignmentAndStudent(request.getAssignmentId(), request.getStudentId());
        if (existingSubmission != null) {
            throw new RuntimeException("您已经提交过此作业，不能重复提交");
        }
        
        // 2. 保存主表
        AssignmentSubmission submission = new AssignmentSubmission();
        submission.setAssignmentId(request.getAssignmentId());
        submission.setStudentId(request.getStudentId());
        submission.setSubmittedAt(LocalDateTime.now());

        // 是否迟交判断（需要查作业截止时间）
        // TODO: 可选，判断逻辑
        submission.setIsLate(false); // 暂时设为 false

        submissionMapper.insert(submission); // 插入后会自动回填 ID（需要配置主键回填）

        Long submissionId = submission.getId();

        // 2. 循环每道题，调用 AI 评分
        for (SubmitAssignmentRequest.Detail reqDetail : request.getDetails()) {
            Long questionId = reqDetail.getQuestionId();
            String studentAnswer = reqDetail.getAnswerText();

            QuestionBank question = questionBankService.selectById(questionId);
            String questionText = question.getContent();
            String correctAnswer = question.getAnswer();

            // 调用 AI 评分（带重试机制）
            String aiFeedback = callAiWithRetry(questionText, studentAnswer, correctAnswer);
            System.out.println("🧠 AI 返回结果：" + aiFeedback);

            // 解析 AI 返回结果（你可以自己设定结构体，比如用 JSON 格式返回 score、isCorrect、errorReason）
            AiEvaluationResult eval = AiEvaluationResult.parse(aiFeedback);

            // 保存 detail
            AssignmentSubmissionDetail detail = new AssignmentSubmissionDetail();
            detail.setSubmissionId(submissionId);
            detail.setQuestionId(questionId);
            detail.setAnswerText(studentAnswer);
            detail.setScore(eval.getScore());
            detail.setIsCorrect(eval.getIsCorrect());
            detail.setErrorReason(eval.getErrorReason());

            detailService.saveDetail(detail);

            // 额外写入 practice_log
            practiceLogService.saveLog(submission.getStudentId(), questionId, studentAnswer, eval);
        }

        return submissionId;
    }

    /**
     * 带重试机制的AI调用
     */
    @Retryable(
        value = {ApiException.class, RuntimeException.class},
        maxAttempts = 3,
        backoff = @Backoff(delay = 2000, multiplier = 2, maxDelay = 10000)
    )
    private String callAiWithRetry(String questionText, String studentAnswer, String correctAnswer) {
        try {
            return xiaozhiAgent.evaluatePracticeSync(questionText, studentAnswer, correctAnswer);
        } catch (ApiException e) {
            // 检查是否是限流错误
            if (e.getMessage() != null && e.getMessage().contains("Too many requests")) {
                System.out.println("⚠️ API限流，正在重试... 错误信息: " + e.getMessage());
                throw e; // 重新抛出异常以触发重试
            }
            // 其他API错误直接抛出
            throw new RuntimeException("AI评分服务异常: " + e.getMessage(), e);
        } catch (Exception e) {
            System.out.println("⚠️ AI调用异常，正在重试... 错误信息: " + e.getMessage());
            throw new RuntimeException("AI评分服务异常: " + e.getMessage(), e);
        }
    }

    @Override
    public Long getSubmissionIdByAssignmentId(Long assignmentId) {
        Long submissionId = submissionMapper.getSubmissionIdByAssignmentId(assignmentId);
        return submissionId;
    }

    @Override
    public AssignmentSubmission getSubmissionById(Long submissionId) {
        return submissionMapper.selectById(submissionId);
    }


}
