package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.*;
import com.atguigu.java.ai.langchain4j.mapper.PracticeLogMapper;
import com.atguigu.java.ai.langchain4j.mapper.PracticeRecordMapper;
import com.atguigu.java.ai.langchain4j.mapper.QuestionBankMapper;
import com.atguigu.java.ai.langchain4j.service.PracticeLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class PracticeLogServiceImpl implements PracticeLogService {
    @Autowired
    private PracticeLogMapper practiceLogMapper;
    
    @Autowired
    private PracticeRecordMapper practiceRecordMapper;

    @Override
    public List<PracticeLogVO> getLogsForStudent(Long studentId) {
        return practiceLogMapper.getPracticeLogsByStudentId(studentId);
    }


    @Autowired
    private QuestionBankMapper questionBankMapper;
    public QuestionBank getQuestionById(Long questionId) {
        return questionBankMapper.selectById(questionId);
    }


    public PracticeLogDetailVO getPracticeLogDetail(Long id) {
        // 查询练习记录
        PracticeLog practiceLog = practiceLogMapper.selectById(id);
        // 查询题目信息
        QuestionBank question = questionBankMapper.selectById(practiceLog.getQuestionId());
        // 查询学生信息
        // 构建返回对象
        PracticeLogDetailVO detail = new PracticeLogDetailVO();
        detail.setId(practiceLog.getId());
        detail.setStudentId(practiceLog.getStudentId());
        detail.setQuestionId(practiceLog.getQuestionId());
        detail.setQuestionContent(question.getContent());
        detail.setQuestionType(question.getType());
        detail.setKnowledgePoint(question.getKnowledgePoint());
        detail.setAnswerText(practiceLog.getAnswerText());
        detail.setIsCorrect(practiceLog.getIsCorrect());
        detail.setErrorReason(practiceLog.getErrorReason());
        detail.setScore(practiceLog.getScore());
        detail.setCorrectAnswer(question.getAnswer());
        return detail;
    }

    @Override
    @Transactional
    public void savePracticeRecord(PracticeRecordRequest request) {
        // 创建主记录
        PracticeRecord record = new PracticeRecord();
        record.setStudentId(request.getStudentId());
        record.setCourseId(request.getCourseId());
        record.setTotalQuestions(request.getTotalQuestions());
        record.setCorrectCount(request.getCorrectCount());
        record.setWrongCount(request.getWrongCount());
        record.setUnansweredCount(request.getUnansweredCount());
        record.setAccuracyRate(request.getAccuracyRate());
        record.setPracticeType(request.getPracticeType());
        // 处理日期格式
        String practiceDateStr = request.getPracticeDate();
        if (practiceDateStr.endsWith("Z")) {
            practiceDateStr = practiceDateStr.replace("Z", "");
        }
        record.setPracticeDate(LocalDateTime.parse(practiceDateStr));
        record.setCreateTime(LocalDateTime.now());
        record.setUpdateTime(LocalDateTime.now());
        
        // 保存主记录
        practiceRecordMapper.insertPracticeRecord(record);
        
        // 保存题目详情
        if (request.getQuestionDetails() != null) {
            for (PracticeRecordRequest.QuestionDetail detail : request.getQuestionDetails()) {
                PracticeRecordDetail recordDetail = new PracticeRecordDetail();
                recordDetail.setPracticeRecordId(record.getId());
                recordDetail.setQuestionId(detail.getQuestionId());
                recordDetail.setQuestionType(detail.getQuestionType());
                recordDetail.setQuestionContent(detail.getQuestionContent());
                recordDetail.setKnowledgePoint(detail.getKnowledgePoint()); // 保存知识点
                recordDetail.setUserAnswer(detail.getUserAnswer());
                recordDetail.setCorrectAnswer(detail.getCorrectAnswer());
                recordDetail.setScore(detail.getScore());
                recordDetail.setIsCorrect(detail.getIsCorrect());
                recordDetail.setCreateTime(LocalDateTime.now());
                
                practiceRecordMapper.insertPracticeRecordDetail(recordDetail);
            }
        }
    }

    @Override
    public Map<String, Object> getPracticeHistory(Long studentId, Integer page, Integer size, String courseId, String sortBy, String startDate, String endDate) {
        // 计算偏移量
        int offset = (page - 1) * size;
        
        // 获取记录列表
        List<PracticeRecord> records = practiceRecordMapper.getPracticeRecordsByStudentId(
            studentId, offset, size, courseId, sortBy, startDate, endDate);
        
        // 为每个记录加载题目详情
        for (PracticeRecord record : records) {
            List<PracticeRecordDetail> details = practiceRecordMapper.getPracticeRecordDetails(record.getId());
            // 将详情转换为前端需要的格式
            List<Map<String, Object>> questionDetails = new ArrayList<>();
            for (PracticeRecordDetail detail : details) {
                Map<String, Object> questionDetail = new HashMap<>();
                questionDetail.put("questionId", detail.getQuestionId());
                questionDetail.put("questionType", detail.getQuestionType());
                questionDetail.put("questionContent", detail.getQuestionContent());
                questionDetail.put("knowledgePoint", detail.getKnowledgePoint()); // 添加知识点
                questionDetail.put("userAnswer", detail.getUserAnswer());
                questionDetail.put("correctAnswer", detail.getCorrectAnswer());
                questionDetail.put("score", detail.getScore());
                questionDetail.put("isCorrect", detail.getIsCorrect());
                questionDetails.add(questionDetail);
            }
            record.setQuestionDetails(questionDetails);
        }
        
        // 获取总记录数
        int total = practiceRecordMapper.countPracticeRecordsByStudentId(
            studentId, courseId, startDate, endDate);
        
        // 构建返回结果
        Map<String, Object> result = new HashMap<>();
        result.put("records", records);
        result.put("total", total);
        result.put("page", page);
        result.put("size", size);
        
        return result;
    }

    @Override
    public List<Map<String, Object>> getWeakPointsRanking(Long studentId, Long courseId, Integer limit) {
        return practiceLogMapper.getWeakPointsRanking(studentId, courseId, limit);
    }
    
    @Override
    public List<Map<String, Object>> getWeakPointsRankingFromPracticeRecord(Long studentId, Long courseId, Integer limit) {
        return practiceLogMapper.getWeakPointsRankingFromPracticeRecord(studentId, courseId, limit);
    }
    
    // 新增方法实现
    
    @Override
    public double calculateAccuracyByStudentId(Long studentId) {
        try {
            System.out.println("DEBUG: 开始计算学生正确率，学生ID: " + studentId);
            
            // 查询该学生的总题目数和正确题目数
            Map<String, Integer> stats = getQuestionStatsByStudentId(studentId);
            int totalQuestions = stats.get("totalQuestions");
            int correctQuestions = stats.get("correctQuestions");
            
            System.out.println("DEBUG: 学生" + studentId + "的题目统计 - 总题目数: " + totalQuestions + ", 正确题目数: " + correctQuestions);
            
            if (totalQuestions == 0) {
                System.out.println("DEBUG: 学生" + studentId + "没有题目记录，返回0.0");
                return 0.0; // 没有题目记录，返回0
            }
            
            // 计算正确率
            double accuracy = Math.round((double) correctQuestions / totalQuestions * 10000) / 100.0;
            System.out.println("DEBUG: 学生" + studentId + "的平均正确率: " + accuracy + "%");
            
            return accuracy;
        } catch (Exception e) {
            // 记录错误日志
            System.err.println("计算学生正确率失败: " + e.getMessage());
            e.printStackTrace();
            return 0.0;
        }
    }
    
    @Override
    public List<PracticeLog> getByStudentId(Long studentId) {
        try {
            // 这里应该调用mapper查询该学生的所有练习日志
            // 暂时返回空列表，因为需要实现具体的mapper方法
            return new ArrayList<>();
        } catch (Exception e) {
            System.err.println("查询学生练习日志失败: " + e.getMessage());
            return new ArrayList<>();
        }
    }
    
    @Override
    public double calculateAccuracyByStudentIdAndCourseId(Long studentId, Long courseId) {
        try {
            // 查询该学生在指定课程的总题目数和正确题目数
            // 这里需要实现具体的mapper方法
            // 暂时返回0，表示没有记录
            return 0.0;
        } catch (Exception e) {
            System.err.println("计算学生课程正确率失败: " + e.getMessage());
            return 0.0;
        }
    }
    
    @Override
    public Map<String, Integer> getQuestionStatsByStudentId(Long studentId) {
        try {
            System.out.println("DEBUG: 开始查询学生题目统计，学生ID: " + studentId);
            
            // 真正查询数据库中的题目统计
            Map<String, Object> result = practiceLogMapper.getQuestionStatsByStudentId(studentId);
            
            System.out.println("DEBUG: 数据库查询结果: " + result);
            
            Map<String, Integer> stats = new HashMap<>();
            if (result != null) {
                // 处理数据库返回的结果
                Object totalQuestionsObj = result.get("totalQuestions");
                Object correctQuestionsObj = result.get("correctQuestions");
                
                int totalQuestions = totalQuestionsObj != null ? ((Number) totalQuestionsObj).intValue() : 0;
                int correctQuestions = correctQuestionsObj != null ? ((Number) correctQuestionsObj).intValue() : 0;
                
                stats.put("totalQuestions", totalQuestions);
                stats.put("correctQuestions", correctQuestions);
                
                System.out.println("DEBUG: 处理后的统计结果 - 总题目数: " + totalQuestions + ", 正确题目数: " + correctQuestions);
            } else {
                stats.put("totalQuestions", 0);
                stats.put("correctQuestions", 0);
                System.out.println("DEBUG: 数据库查询结果为空，使用默认值");
            }
            
            return stats;
        } catch (Exception e) {
            System.err.println("查询学生题目统计失败: " + e.getMessage());
            e.printStackTrace();
            Map<String, Integer> stats = new HashMap<>();
            stats.put("totalQuestions", 0);
            stats.put("correctQuestions", 0);
            return stats;
        }
    }
}