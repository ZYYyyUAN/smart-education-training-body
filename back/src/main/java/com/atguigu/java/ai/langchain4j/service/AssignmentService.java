package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.*;

import java.util.List;

public interface AssignmentService {
    void createAssignment(AssignmentForm form);

    Result<?> deleteAssignment(Long assignmentId);
    Result<?> updateAssignment(AssignmentForm form);
    
    /**
     * 管理端更新作业（只更新基本信息，不包含题目）
     */
    Result<?> updateAssignmentForAdmin(AdminAssignmentUpdateForm form);
    
    List<Assignment> getAssignmentsByCourse(Long courseId);
    AssignmentDetailDTO getAssignmentDetail(Long assignmentId);

    List<AssignmentWithStatusDTO> getAssignmentsByStudentId(Long studentId);
    List<Assignment> getUpcomingAssignments(Long studentId, int daysAhead);

    List<Assignment> getAssignmentsByTeacherId(Long teacherId);
    
    /**
     * 获取所有作业概览（含完成人数/完成率）
     */
    List<AssignmentOverviewDTO> getAllAssignmentsOverview();
    
    /**
     * 根据教师ID获取作业概览
     */
    List<AssignmentOverviewDTO> getAssignmentsOverviewByTeacherId(Long teacherId);
    
    /**
     * 根据课程ID获取作业概览
     */
    List<AssignmentOverviewDTO> getAssignmentsOverviewByCourseId(Long courseId);
    
    /**
     * 根据学生ID获取作业概览
     */
    List<AssignmentOverviewDTO> getAssignmentsOverviewByStudentId(Long studentId);
}
