package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.StudentLoginLog;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * 学生登录日志服务接口
 */
public interface StudentLoginLogService {
    
    /**
     * 根据学生ID和日期范围查询登录日志
     */
    List<StudentLoginLog> getLoginLogsByStudentIdAndDateRange(Long studentId, LocalDate startDate, LocalDate endDate);
    
    /**
     * 根据学生ID查询近7天的登录统计
     */
    List<Map<String, Object>> getLoginStatsByStudentId(Long studentId, int days);
    
    /**
     * 根据学生ID查询最近登录时间
     */
    String getLastLoginTimeByStudentId(Long studentId);
    
    /**
     * 根据学生ID统计指定日期范围内的登录次数
     */
    int countLoginsByStudentIdAndDateRange(Long studentId, LocalDate startDate, LocalDate endDate);
}


