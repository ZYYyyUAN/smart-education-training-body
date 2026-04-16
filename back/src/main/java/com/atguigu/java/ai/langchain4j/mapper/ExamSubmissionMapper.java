package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.ExamSubmission;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

/**
 * 考试提交Mapper接口
 * 
 * 该接口提供考试提交相关的数据访问方法，用于学情信息管理模块。
 * 主要功能包括：
 * - 考试提交记录的查询（包含考试和课程信息）
 * - 班级考试提交数量统计（用于计算完成率）
 * - 班级考试平均成绩计算
 * 
 * @author 张政
 * @date 2024
 */
@Mapper
public interface ExamSubmissionMapper extends BaseMapper<ExamSubmission> {
    
    /**
     * 查询学生的考试提交记录，包含考试标题和课程信息
     * 
     * 使用LEFT JOIN关联exam和course表，一次性获取完整的考试信息。
     * 结果按提交时间倒序排列，最新的记录在前。
     * 
     * @param studentId 学生ID
     * @return 考试提交记录列表，每个元素包含：
     *         - id: 提交记录ID
     *         - examId: 考试ID
     *         - studentId: 学生ID
     *         - submittedAt: 提交时间
     *         - score: 成绩
     *         - examTitle: 考试标题
     *         - courseId: 课程ID
     *         - courseName: 课程名称
     */
    @Select("SELECT " +
            "es.id, " +
            "es.exam_id AS examId, " +
            "es.student_id AS studentId, " +
            "es.submitted_at AS submittedAt, " +
            "es.score, " +
            "e.title AS examTitle, " +
            "e.course_id AS courseId, " +
            "c.course_name AS courseName " +
            "FROM exam_submission es " +
            "LEFT JOIN exam e ON es.exam_id = e.id " +
            "LEFT JOIN course c ON e.course_id = c.id " +
            "WHERE es.student_id = #{studentId} " +
            "ORDER BY es.submitted_at DESC")
    List<Map<String, Object>> selectWithExamInfo(@Param("studentId") Long studentId);
    
    /**
     * 统计班级学生在指定课程的考试提交数量
     * 
     * 用于计算班级考试完成率时的分子（已提交考试数）。
     * 如果courseId为null，则统计该班级在所有课程的考试提交总数。
     * 
     * @param classId 班级ID
     * @param courseId 课程ID，如果为null则统计所有课程
     * @return 提交的考试数量
     */
    @Select("<script>" +
            "SELECT COUNT(DISTINCT esub.id) " +
            "FROM exam_submission esub " +
            "INNER JOIN exam e ON esub.exam_id = e.id " +
            "INNER JOIN user u ON esub.student_id = u.id " +
            "WHERE u.class_id = #{classId} AND u.role = 'student' " +
            "<if test='courseId != null'>" +
            "AND e.course_id = #{courseId} " +
            "</if>" +
            "</script>")
    Long countSubmissionsByClassAndCourse(@Param("classId") Long classId, @Param("courseId") Long courseId);
    
    /**
     * 计算班级学生在指定课程的考试平均成绩
     * 
     * 只统计已评分的考试（score IS NOT NULL）。
     * 如果courseId为null，则计算该班级在所有课程的考试平均成绩。
     * 
     * @param classId 班级ID
     * @param courseId 课程ID，如果为null则计算所有课程
     * @return 平均成绩，如果没有数据返回null
     */
    @Select("<script>" +
            "SELECT AVG(esub.score) " +
            "FROM exam_submission esub " +
            "INNER JOIN exam e ON esub.exam_id = e.id " +
            "INNER JOIN user u ON esub.student_id = u.id " +
            "WHERE u.class_id = #{classId} AND u.role = 'student' AND esub.score IS NOT NULL " +
            "<if test='courseId != null'>" +
            "AND e.course_id = #{courseId} " +
            "</if>" +
            "</script>")
    Double getAverageScoreByClassAndCourse(@Param("classId") Long classId, @Param("courseId") Long courseId);
}
