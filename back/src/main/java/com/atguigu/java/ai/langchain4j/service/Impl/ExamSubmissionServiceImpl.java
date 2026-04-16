package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.*;
import com.atguigu.java.ai.langchain4j.entity.dto.ExamSubmissionRequest;
import com.atguigu.java.ai.langchain4j.mapper.*;
import com.atguigu.java.ai.langchain4j.service.AIGradingService;
import com.atguigu.java.ai.langchain4j.service.ExamSubmissionService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 考试提交服务实现
 */
@Slf4j
@Service
public class ExamSubmissionServiceImpl implements ExamSubmissionService {
    
    @Autowired
    private ExamResultMapper examResultMapper;
    
    @Autowired
    private ExamAnswerMapper examAnswerMapper;
    
    @Autowired
    private QuestionBankMapper questionBankMapper;
    
    @Autowired
    private AIGradingService aiGradingService;
    
    @Override
    @Transactional
    public Result<Map<String, Object>> submitExam(ExamSubmissionRequest request) {
        try {
            log.info("开始处理考试提交: examId={}, studentId={}", request.getExamId(), request.getStudentId());
            
            // 1. 检查是否已经提交过
            ExamResult existingResult = examResultMapper.selectByExamAndStudent(request.getExamId(), request.getStudentId());
            if (existingResult != null) {
                return Result.error("您已经提交过此考试，不能重复提交");
            }
            
            // 2. 获取考试题目
            List<QuestionBank> questions = questionBankMapper.selectByExamId(request.getExamId());
            if (questions.isEmpty()) {
                return Result.error("考试题目不存在");
            }
            
            // 2. 使用AI进行批阅
            Map<String, Object> gradingResult = aiGradingService.gradeExam(request, questions);
            
            // 3. 保存考试结果
            ExamResult examResult = new ExamResult();
            examResult.setExamId(request.getExamId());
            examResult.setStudentId(request.getStudentId());
            examResult.setTotalQuestions((Integer) gradingResult.get("totalQuestions"));
            examResult.setCorrectAnswers((Integer) gradingResult.get("correctAnswers"));
            examResult.setWrongAnswers((Integer) gradingResult.get("wrongAnswers"));
            examResult.setScore((Double) gradingResult.get("score"));
            examResult.setStatus("graded");
            examResult.setSubmittedAt(LocalDateTime.now());
            examResult.setGradedAt(LocalDateTime.now());
            examResult.setCreatedAt(LocalDateTime.now());
            
            // 生成AI总体反馈
            String aiFeedback = generateOverallFeedback(gradingResult);
            examResult.setAiFeedback(aiFeedback);
            
            examResultMapper.insert(examResult);
            
            // 4. 保存每道题的答案和批阅结果
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> questionResults = (List<Map<String, Object>>) gradingResult.get("questionResults");
            
            for (Map<String, Object> questionResult : questionResults) {
                ExamAnswer examAnswer = new ExamAnswer();
                examAnswer.setExamResultId(examResult.getId());
                examAnswer.setQuestionId((Long) questionResult.get("questionId"));
                examAnswer.setStudentAnswer((String) questionResult.get("studentAnswer"));
                examAnswer.setIsCorrect((Boolean) questionResult.get("isCorrect"));
                examAnswer.setScore((Double) questionResult.get("score"));
                examAnswer.setAiFeedback((String) questionResult.get("aiFeedback"));
                examAnswer.setCreatedAt(LocalDateTime.now());
                
                // 设置正确答案
                for (QuestionBank q : questions) {
                    if (q.getId().equals(examAnswer.getQuestionId())) {
                        examAnswer.setCorrectAnswer(q.getAnswer());
                        break;
                    }
                }
                
                examAnswerMapper.insert(examAnswer);
            }
            
            // 5. 构建返回结果
            Map<String, Object> result = new HashMap<>();
            result.put("examResultId", examResult.getId());
            result.put("totalQuestions", examResult.getTotalQuestions());
            result.put("correctAnswers", examResult.getCorrectAnswers());
            result.put("wrongAnswers", examResult.getWrongAnswers());
            result.put("score", examResult.getScore());
            result.put("aiFeedback", examResult.getAiFeedback());
            result.put("questionResults", questionResults);
            
            log.info("考试提交处理完成: examResultId={}, score={}", examResult.getId(), examResult.getScore());
            return Result.ok(result);
            
        } catch (Exception e) {
            log.error("处理考试提交失败", e);
            return Result.error("提交考试失败: " + e.getMessage());
        }
    }
    
    /**
     * 生成AI总体反馈
     */
    private String generateOverallFeedback(Map<String, Object> gradingResult) {
        Integer totalQuestions = (Integer) gradingResult.get("totalQuestions");
        Integer correctAnswers = (Integer) gradingResult.get("correctAnswers");
        Double score = (Double) gradingResult.get("score");
        
        double percentage = (double) correctAnswers / totalQuestions * 100;
        
        StringBuilder feedback = new StringBuilder();
        feedback.append("考试批阅完成！\n\n");
        feedback.append(String.format("总分：%.1f分\n", score));
        feedback.append(String.format("正确率：%.1f%% (%d/%d题)\n\n", percentage, correctAnswers, totalQuestions));
        
        if (percentage >= 90) {
            feedback.append("🎉 优秀！你的表现非常出色，继续保持！");
        } else if (percentage >= 80) {
            feedback.append("👍 良好！你的表现不错，还有提升空间。");
        } else if (percentage >= 70) {
            feedback.append("📚 中等！建议多复习相关知识点。");
        } else if (percentage >= 60) {
            feedback.append("⚠️ 及格！需要加强学习，建议重新复习。");
        } else {
            feedback.append("💪 不及格！建议系统性地重新学习相关课程内容。");
        }
        
        return feedback.toString();
    }
}
