package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.Student;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface StudentMapper {
    // 使用现有的student_course表查询学生
    // 从user表获取学生信息，通过student_course表关联课程
    @Select("SELECT u.id, u.real_name as name, '家里蹲大学' as school, '计算机学院' as college, '男' as gender, '软件234' as className, DATE_FORMAT(u.created_at, '%Y-%m-%d') as registerDate " +
            "FROM user u " +
            "INNER JOIN student_course sc ON u.id = sc.student_id " +
            "WHERE sc.course_id = #{courseId} AND u.role = 'student'")
    List<Student> findByCourseId(@Param("courseId") Long courseId);
    
    // 简化信息：用于排行榜（包含头像）
    @Select("SELECT u.id AS id, COALESCE(u.real_name, u.username) AS name, u.avatar_url AS avatarUrl " +
            "FROM user u " +
            "INNER JOIN student_course sc ON u.id = sc.student_id " +
            "WHERE sc.course_id = #{courseId} AND u.role = 'student'")
    List<Map<String, Object>> findBasicByCourseId(@Param("courseId") Long courseId);

    // 查询学生当前课程下的薄弱知识点（错的最多的5个）
    @Select("SELECT prd.knowledge_point, COUNT(*) as error_count " +
            "FROM practice_record pr " +
            "INNER JOIN practice_record_detail prd ON pr.id = prd.practice_record_id " +
            "WHERE pr.student_id = #{studentId} AND pr.course_id = #{courseId} " +
            "AND prd.is_correct = 0 AND prd.knowledge_point IS NOT NULL " +
            "GROUP BY prd.knowledge_point " +
            "ORDER BY error_count DESC " +
            "LIMIT 5")
    List<Map<String, Object>> findWeakKnowledgePoints(@Param("studentId") Long studentId, @Param("courseId") Long courseId);
    
    // 查询学生当前课程下的作业得分情况
    @Select("SELECT a.id as assignment_id, a.title, DATE_FORMAT(a.due_date, '%Y-%m-%d %H:%i:%s') as due_date, " +
            "DATE_FORMAT(ass.submitted_at, '%Y-%m-%d %H:%i:%s') as submitted_at, ass.score, " +
            "CASE WHEN ass.score IS NOT NULL THEN CONCAT(ass.score, '分') ELSE '待评分' END as score_display " +
            "FROM assignment a " +
            "INNER JOIN assignment_submission ass ON a.id = ass.assignment_id AND ass.student_id = #{studentId} " +
            "WHERE a.course_id = #{courseId} " +
            "ORDER BY a.due_date DESC")
    List<Map<String, Object>> findAssignmentScores(@Param("studentId") Long studentId, @Param("courseId") Long courseId);
    
    // 查询学生作业详情（每道题的回答情况）
    @Select("SELECT COALESCE(aq.sort_order, ROW_NUMBER() OVER (ORDER BY aq.question_id)) as sort_order, " +
            "qb.content as question_content, " +
            "COALESCE(asd.answer_text, '未作答') as answer_text, " +
            "COALESCE(asd.score, 0) as score, " +
            "COALESCE(asd.is_correct, 0) as is_correct, " +
            "COALESCE(asd.error_reason, '') as error_reason, " +
            "CASE WHEN asd.is_correct = 1 THEN '正确' ELSE '错误' END as status " +
            "FROM assignment_question aq " +
            "INNER JOIN question_bank qb ON aq.question_id = qb.id " +
            "LEFT JOIN assignment_submission ass ON ass.assignment_id = #{assignmentId} AND ass.student_id = #{studentId} " +
            "LEFT JOIN assignment_submission_detail asd ON asd.submission_id = ass.id AND asd.question_id = qb.id " +
            "WHERE aq.assignment_id = #{assignmentId} " +
            "ORDER BY COALESCE(aq.sort_order, aq.question_id)")
    List<Map<String, Object>> findAssignmentDetail(@Param("assignmentId") Long assignmentId, @Param("studentId") Long studentId);
    
    // 查询课程下的所有知识点
    @Select("SELECT DISTINCT kp.title as knowledge_point " +
            "FROM chapter c " +
            "INNER JOIN knowledge_point kp ON c.id = kp.chapter_id " +
            "WHERE c.course_id = #{courseId} AND kp.title IS NOT NULL AND kp.title != '' " +
            "ORDER BY kp.title")
    List<String> findCourseKnowledgePoints(@Param("courseId") Long courseId);
}


