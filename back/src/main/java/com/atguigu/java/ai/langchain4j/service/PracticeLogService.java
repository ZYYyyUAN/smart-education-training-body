package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.PracticeLog;
import com.atguigu.java.ai.langchain4j.entity.PracticeLogDetailVO;
import com.atguigu.java.ai.langchain4j.entity.PracticeLogVO;
import com.atguigu.java.ai.langchain4j.entity.PracticeRecordRequest;
import com.atguigu.java.ai.langchain4j.entity.QuestionBank;
import java.util.List;
import java.util.Map;

/**
 * 练习日志服务接口
 */
public interface PracticeLogService {
    
    // 原有方法
    List<PracticeLogVO> getLogsForStudent(Long studentId);
    
    QuestionBank getQuestionById(Long questionId);
    
    PracticeLogDetailVO getPracticeLogDetail(Long id);
    
    void savePracticeRecord(PracticeRecordRequest request);
    
    Map<String, Object> getPracticeHistory(Long studentId, Integer page, Integer size, String courseId, String sortBy, String startDate, String endDate);
    
    List<Map<String, Object>> getWeakPointsRanking(Long studentId, Long courseId, Integer limit);
    
    List<Map<String, Object>> getWeakPointsRankingFromPracticeRecord(Long studentId, Long courseId, Integer limit);
    
    // 新增方法
    /**
     * 根据学生ID计算平均正确率
     */
    double calculateAccuracyByStudentId(Long studentId);
    
    /**
     * 根据学生ID查询练习日志
     */
    List<PracticeLog> getByStudentId(Long studentId);
    
    /**
     * 根据学生ID和课程ID计算正确率
     */
    double calculateAccuracyByStudentIdAndCourseId(Long studentId, Long courseId);
    
    /**
     * 根据学生ID统计总题目数和正确题目数
     */
    Map<String, Integer> getQuestionStatsByStudentId(Long studentId);
}