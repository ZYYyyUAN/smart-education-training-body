package com.atguigu.java.ai.langchain4j.service;

public interface LoginLogService {
    
    /**
     * 记录学生登录日志
     * @param studentId 学生ID
     */
    void recordStudentLogin(Long studentId);
    
    /**
     * 记录老师登录日志
     * @param teacherId 老师ID
     */
    void recordTeacherLogin(Long teacherId);
}
