package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.AssignmentSubmission;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 作业提交Mapper接口
 * 
 * 该接口提供作业提交相关的数据访问方法，用于学情信息管理模块。
 * 主要功能包括：
 * - 作业提交记录的查询
 * - 班级作业提交数量统计（用于计算完成率）
 * - 班级作业平均成绩计算
 * 
 * @author 张政
 * @date 2024
 */
@Mapper
public interface AssignmentSubmissionMapper extends BaseMapper<AssignmentSubmission> {
    
    /**
     * 根据作业ID和学生ID查询作业提交记录
     * 
     * @param assignmentId 作业ID
     * @param studentId 学生ID
     * @return 作业提交记录，如果不存在返回null
     */
    @Select("SELECT * FROM assignment_submission WHERE assignment_id = #{assignmentId} AND student_id = #{studentId} LIMIT 1")
    AssignmentSubmission selectByAssignmentAndStudent(Long assignmentId, Long studentId);

    /**
     * 根据作业ID获取提交记录ID
     * 
     * @param assignmentId 作业ID
     * @return 提交记录ID
     */
    @Select("SELECT id FROM assignment_submission WHERE assignment_id = #{assignmentId} LIMIT 1")
    Long getSubmissionIdByAssignmentId(Long assignmentId);
    
    /**
     * 统计班级学生在指定课程的作业提交数量
     * 
     * 用于计算班级作业完成率时的分子（已提交作业数）。
     * 如果courseId为null，则统计该班级在所有课程的作业提交总数。
     * 
     * @param classId 班级ID
     * @param courseId 课程ID，如果为null则统计所有课程
     * @return 提交的作业数量
     */
    @Select("<script>" +
            "SELECT COUNT(DISTINCT asub.id) " +
            "FROM assignment_submission asub " +
            "INNER JOIN assignment a ON asub.assignment_id = a.id " +
            "INNER JOIN user u ON asub.student_id = u.id " +
            "WHERE u.class_id = #{classId} AND u.role = 'student' " +
            "<if test='courseId != null'>" +
            "AND a.course_id = #{courseId} " +
            "</if>" +
            "</script>")
    Long countSubmissionsByClassAndCourse(@Param("classId") Long classId, @Param("courseId") Long courseId);
    
    /**
     * 计算班级学生在指定课程的作业平均成绩
     * 
     * 只统计已评分的作业（score IS NOT NULL）。
     * 如果courseId为null，则计算该班级在所有课程的作业平均成绩。
     * 
     * @param classId 班级ID
     * @param courseId 课程ID，如果为null则计算所有课程
     * @return 平均成绩，如果没有数据返回null
     */
    @Select("<script>" +
            "SELECT AVG(asub.score) " +
            "FROM assignment_submission asub " +
            "INNER JOIN assignment a ON asub.assignment_id = a.id " +
            "INNER JOIN user u ON asub.student_id = u.id " +
            "WHERE u.class_id = #{classId} AND u.role = 'student' AND asub.score IS NOT NULL " +
            "<if test='courseId != null'>" +
            "AND a.course_id = #{courseId} " +
            "</if>" +
            "</script>")
    Double getAverageScoreByClassAndCourse(@Param("classId") Long classId, @Param("courseId") Long courseId);
}
