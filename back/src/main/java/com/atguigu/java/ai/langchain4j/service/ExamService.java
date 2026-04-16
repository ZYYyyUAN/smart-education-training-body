package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.Exam;
import com.atguigu.java.ai.langchain4j.entity.ExamForm;
import com.atguigu.java.ai.langchain4j.entity.Result;
import com.atguigu.java.ai.langchain4j.entity.ExamOverviewDTO;
import com.atguigu.java.ai.langchain4j.entity.ExamWithStatusDTO;

import java.util.List;

public interface ExamService {
    void createExam(ExamForm form);
    Result<?> updateExam(ExamForm form);
    Result<?> deleteExam(Long examId);
    List<Exam> getExamsByCourse(Long courseId);
    List<Exam> getExamsByTeacherId(Long teacherId);
    List<ExamOverviewDTO> getExamOverviewByTeacher(Long teacherId);
    List<Exam> getUpcomingExams(Long studentId, int days);
    List<ExamWithStatusDTO> getExamsWithStatus(Long studentId, Long courseId);
    
    /**
     * 管理端更新考试（只更新基本信息，不包含题目）
     */
    Result<?> updateExamForAdmin(com.atguigu.java.ai.langchain4j.entity.AdminExamUpdateForm form);
    
    /**
     * 获取所有考试概览（含完成人数/完成率）
     */
    List<ExamOverviewDTO> getAllExamsOverview();
    
    /**
     * 根据课程ID获取考试概览
     */
    List<ExamOverviewDTO> getExamsOverviewByCourse(Long courseId);
    
    /**
     * 根据教师ID获取考试概览
     */
    List<ExamOverviewDTO> getExamsOverviewByTeacher(Long teacherId);
}


