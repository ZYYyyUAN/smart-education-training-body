package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.QuestionBank;
import com.atguigu.java.ai.langchain4j.entity.dto.ExamSubmissionRequest;
import com.atguigu.java.ai.langchain4j.service.AIGradingService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * AI批阅服务实现
 */
@Slf4j
@Service
public class AIGradingServiceImpl implements AIGradingService {
    
    @Override
    public Map<String, Object> gradeExam(ExamSubmissionRequest submission, List<QuestionBank> questions) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> questionResults = new ArrayList<>();
        
        int totalQuestions = questions.size();
        int correctAnswers = 0;
        int wrongAnswers = 0;
        double totalScore = 0.0;
        
        // 创建题目ID到题目的映射
        Map<Long, QuestionBank> questionMap = new HashMap<>();
        for (QuestionBank q : questions) {
            questionMap.put(q.getId(), q);
        }
        
        // 批阅每道题
        for (ExamSubmissionRequest.QuestionAnswer answer : submission.getAnswers()) {
            QuestionBank question = questionMap.get(answer.getQuestionId());
            if (question == null) {
                log.warn("题目不存在: {}", answer.getQuestionId());
                continue;
            }
            
            Map<String, Object> questionResult = gradeQuestion(question, answer.getAnswer());
            questionResult.put("questionId", answer.getQuestionId());
            questionResult.put("studentAnswer", answer.getAnswer());
            questionResults.add(questionResult);
            
            Boolean isCorrect = (Boolean) questionResult.get("isCorrect");
            Double score = (Double) questionResult.get("score");
            
            if (isCorrect != null && isCorrect) {
                correctAnswers++;
            } else {
                wrongAnswers++;
            }
            
            if (score != null) {
                // 每道题满分100分，总分按题目数量平均分配
                double normalizedScore = score / totalQuestions;
                totalScore += normalizedScore;
            }
        }
        
        result.put("totalQuestions", totalQuestions);
        result.put("correctAnswers", correctAnswers);
        result.put("wrongAnswers", wrongAnswers);
        result.put("score", (double) Math.round(totalScore)); // 四舍五入为整数，确保是Double类型
        result.put("questionResults", questionResults);
        
        return result;
    }
    
    @Override
    public Map<String, Object> gradeQuestion(QuestionBank question, String studentAnswer) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            if (question.getType().equals("choice") || question.getType().equals("true_false")) {
                // 选择题和判断题：直接比较答案
                boolean isCorrect = question.getAnswer().trim().equalsIgnoreCase(studentAnswer.trim());
                result.put("isCorrect", isCorrect);
                result.put("score", isCorrect ? 100.0 : 0.0);
                result.put("aiFeedback", isCorrect ? "回答正确！" : "回答错误，正确答案是：" + question.getAnswer());
                
            } else if (question.getType().equals("short_answer")) {
                // 简答题：使用AI进行语义评分
                result = gradeShortAnswerWithAI(question, studentAnswer);
                
            } else if (question.getType().equals("programming")) {
                // 编程题：使用AI进行代码评分
                result = gradeProgrammingWithAI(question, studentAnswer);
                
            } else {
                // 其他类型题目
                result.put("isCorrect", false);
                result.put("score", 0.0);
                result.put("aiFeedback", "不支持的题目类型");
            }
            
        } catch (Exception e) {
            log.error("批阅题目失败", e);
            result.put("isCorrect", false);
            result.put("score", 0.0);
            result.put("aiFeedback", "批阅过程中出现错误");
        }
        
        return result;
    }
    
    /**
     * 使用AI批阅简答题
     */
    private Map<String, Object> gradeShortAnswerWithAI(QuestionBank question, String studentAnswer) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 检查学生是否提交了答案
            if (studentAnswer == null || studentAnswer.trim().isEmpty()) {
                result.put("isCorrect", false);
                result.put("score", 0.0);
                result.put("aiFeedback", "未提交答案，请认真作答。");
                return result;
            }
            
            // 记录批阅信息
            log.info("批阅简答题 - 题目ID: {}, 学生答案长度: {}", question.getId(), studentAnswer.length());
            
            // 模拟AI批阅结果（基于答案长度和内容进行简单判断）
            double score = calculateSimpleScore(studentAnswer, question.getAnswer());
            boolean isCorrect = score >= 60.0;
            
            result.put("isCorrect", isCorrect);
            result.put("score", score);
            
            if (isCorrect) {
                result.put("aiFeedback", String.format("回答正确！得分：%.1f分。建议：可以更加详细地阐述观点。", score));
            } else {
                result.put("aiFeedback", String.format("回答不完整，得分：%.1f分。建议：请参考标准答案，重新组织语言。", score));
            }
            
        } catch (Exception e) {
            log.error("AI批阅简答题失败", e);
            result.put("isCorrect", false);
            result.put("score", 0.0);
            result.put("aiFeedback", "AI批阅服务暂时不可用");
        }
        
        return result;
    }
    
    /**
     * 使用AI批阅编程题
     */
    private Map<String, Object> gradeProgrammingWithAI(QuestionBank question, String studentAnswer) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 检查学生是否提交了代码
            if (studentAnswer == null || studentAnswer.trim().isEmpty()) {
                result.put("isCorrect", false);
                result.put("score", 0.0);
                result.put("aiFeedback", "未提交代码，请认真完成编程题。");
                return result;
            }
            
            // 记录批阅信息
            log.info("批阅编程题 - 题目ID: {}, 学生代码长度: {}", question.getId(), studentAnswer.length());
            
            // 模拟AI批阅结果（基于代码长度和内容进行简单判断）
            double score = calculateProgrammingScore(studentAnswer, question.getAnswer());
            boolean isCorrect = score >= 60.0;
            
            result.put("isCorrect", isCorrect);
            result.put("score", score);
            
            if (isCorrect) {
                result.put("aiFeedback", String.format("代码基本正确！得分：%.1f分。建议：可以进一步优化代码结构和注释。", score));
            } else {
                result.put("aiFeedback", String.format("代码需要改进，得分：%.1f分。建议：请参考标准答案，重新编写代码。", score));
            }
            
        } catch (Exception e) {
            log.error("AI批阅编程题失败", e);
            result.put("isCorrect", false);
            result.put("score", 0.0);
            result.put("aiFeedback", "AI批阅服务暂时不可用");
        }
        
        return result;
    }
    
    /**
     * 计算简答题分数（简单算法）
     */
    private double calculateSimpleScore(String studentAnswer, String correctAnswer) {
        if (studentAnswer == null || studentAnswer.trim().isEmpty()) {
            return 0.0;
        }
        
        studentAnswer = studentAnswer.trim().toLowerCase();
        correctAnswer = correctAnswer.trim().toLowerCase();
        
        // 检查是否为乱答（包含明显无关的词汇）
        if (isNonsenseAnswer(studentAnswer)) {
            return 0.0;
        }
        
        // 简单的关键词匹配评分
        String[] correctKeywords = correctAnswer.split("\\s+");
        String[] studentKeywords = studentAnswer.split("\\s+");
        
        int matchCount = 0;
        for (String keyword : correctKeywords) {
            if (keyword.length() > 2) { // 只考虑长度大于2的关键词
                for (String studentKeyword : studentKeywords) {
                    if (studentKeyword.contains(keyword) || keyword.contains(studentKeyword)) {
                        matchCount++;
                        break;
                    }
                }
            }
        }
        
        // 基于匹配度计算分数，提高匹配要求
        double matchRatio = (double) matchCount / correctKeywords.length;
        
        // 只有匹配度达到一定阈值才给分
        if (matchRatio < 0.3) { // 匹配度低于30%直接0分
            return 0.0;
        }
        
        // 计算原始分数并四舍五入为整数（100分制）
        double rawScore = matchRatio * 100;
        return Math.min(100.0, rawScore);
    }
    
    /**
     * 判断是否为乱答
     */
    private boolean isNonsenseAnswer(String answer) {
        // 检查是否包含明显无关的词汇
        String[] nonsenseWords = {
            "咖啡", "房间", "回复", "开发", "快速", "离开", "收到", "框上",
            "吃饭", "睡觉", "游戏", "电影", "音乐", "购物", "旅游", "工作",
            "今天", "明天", "昨天", "早上", "晚上", "中午", "下午"
        };
        
        for (String word : nonsenseWords) {
            if (answer.contains(word)) {
                return true;
            }
        }
        
        // 检查答案长度是否过短（可能是乱答）
        if (answer.length() < 5) {
            return true;
        }
        
        // 检查是否包含大量重复字符
        if (answer.matches(".*(.)\\1{3,}.*")) {
            return true;
        }
        
        return false;
    }
    
    /**
     * 计算编程题分数（简单算法）
     */
    private double calculateProgrammingScore(String studentCode, String correctCode) {
        if (studentCode == null || studentCode.trim().isEmpty()) {
            return 0.0;
        }
        
        studentCode = studentCode.trim();
        correctCode = correctCode.trim();
        
        // 检查是否为乱答（包含明显无关的词汇）
        if (isNonsenseAnswer(studentCode)) {
            return 0.0;
        }
        
        // 检查是否包含基本的编程结构
        int structureScore = 0;
        if (studentCode.contains("public") || studentCode.contains("private") || studentCode.contains("protected")) {
            structureScore += 2; // 访问修饰符
        }
        if (studentCode.contains("class") || studentCode.contains("interface")) {
            structureScore += 2; // 类定义
        }
        if (studentCode.contains("if") || studentCode.contains("for") || studentCode.contains("while")) {
            structureScore += 2; // 控制结构
        }
        if (studentCode.contains("return")) {
            structureScore += 2; // 返回值
        }
        if (studentCode.contains("//") || studentCode.contains("/*")) {
            structureScore += 1; // 注释
        }
        if (studentCode.contains(";")) {
            structureScore += 1; // 语句结束符
        }
        
        // 如果没有任何编程结构，直接0分
        if (structureScore == 0) {
            return 0.0;
        }
        
        // 基于代码长度和结构相似度计算分数
        double lengthRatio = Math.min(1.0, (double) studentCode.length() / Math.max(1, correctCode.length()));
        
        // 综合评分并四舍五入为整数（100分制）
        double structureRatio = Math.min(1.0, structureScore / 10.0);
        double rawScore = (lengthRatio * 0.4 + structureRatio * 0.6) * 100;
        return Math.min(100.0, rawScore);
    }
}
