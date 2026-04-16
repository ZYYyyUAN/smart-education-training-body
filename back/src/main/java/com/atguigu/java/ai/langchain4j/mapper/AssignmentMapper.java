package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.Assignment;
import com.atguigu.java.ai.langchain4j.entity.AssignmentWithStatusDTO;
import com.atguigu.java.ai.langchain4j.entity.AssignmentOverviewDTO;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface AssignmentMapper extends BaseMapper<Assignment> {

    @Select("SELECT * FROM assignment WHERE course_id = #{courseId}")
    List<Assignment> selectByCourseId(Long courseId);

    /**
     * 查询学生加入课程的所有作业，并左关联查询是否提交
     */
    @Select("SELECT a.id AS assignmentId, a.course_id AS courseId, a.title, a.description, a.due_date AS dueDate, " +
            "CASE WHEN s.id IS NULL THEN FALSE ELSE TRUE END AS submitted, s.submitted_at AS submittedAt, s.score, " +
            "CASE WHEN s.id IS NULL AND a.due_date < CURDATE() THEN TRUE ELSE FALSE END AS isOverdue " +
            "FROM assignment a " +
            "INNER JOIN student_course sc ON a.course_id = sc.course_id " +
            "LEFT JOIN assignment_submission s ON a.id = s.assignment_id AND s.student_id = #{studentId} " +
            "WHERE sc.student_id = #{studentId} " +
            "ORDER BY a.due_date DESC")
    List<AssignmentWithStatusDTO> selectAssignmentsWithSubmissionStatus(@Param("studentId") Long studentId);

    List<Assignment> selectUpcomingAssignments(@Param("studentId") Long studentId, @Param("days")int daysAhead);
    @Select("SELECT * FROM assignment WHERE teacher_id = #{teacherId}")
    List<Assignment> selectByTeacherId(Long teacherId);
    
    /**
     * 查询某学生的所有作业（通过学生所在课程）
     */
    @Select("SELECT DISTINCT a.* FROM assignment a " +
            "INNER JOIN student_course sc ON a.course_id = sc.course_id " +
            "WHERE sc.student_id = #{studentId} " +
            "ORDER BY a.due_date DESC")
    List<Assignment> selectByStudentId(@Param("studentId") Long studentId);
    
    /**
     * 获取所有作业概览（含完成人数/完成率）
     */
    @Select("SELECT a.id, a.title, a.course_id AS courseId, c.course_name AS courseName, " +
            "a.teacher_id AS teacherId, a.description, a.due_date AS dueDate, " +
            "(SELECT COUNT(*) FROM assignment_submission s WHERE s.assignment_id = a.id AND s.submitted_at IS NOT NULL) AS completedCount, " +
            "(SELECT COUNT(*) FROM student_course sc WHERE sc.course_id = a.course_id) AS totalStudents " +
            "FROM assignment a " +
            "LEFT JOIN course c ON c.id = a.course_id " +
            "ORDER BY a.due_date DESC")
    List<AssignmentOverviewDTO> selectAllAssignmentsOverview();
    
    /**
     * 根据教师ID获取作业概览
     */
    @Select("SELECT a.id, a.title, a.course_id AS courseId, c.course_name AS courseName, " +
            "a.teacher_id AS teacherId, a.description, a.due_date AS dueDate, " +
            "(SELECT COUNT(*) FROM assignment_submission s WHERE s.assignment_id = a.id AND s.submitted_at IS NOT NULL) AS completedCount, " +
            "(SELECT COUNT(*) FROM student_course sc WHERE sc.course_id = a.course_id) AS totalStudents " +
            "FROM assignment a " +
            "LEFT JOIN course c ON c.id = a.course_id " +
            "WHERE a.teacher_id = #{teacherId} " +
            "ORDER BY a.due_date DESC")
    List<AssignmentOverviewDTO> selectOverviewByTeacherId(@Param("teacherId") Long teacherId);
    
    /**
     * 根据课程ID获取作业概览
     */
    @Select("SELECT a.id, a.title, a.course_id AS courseId, c.course_name AS courseName, " +
            "a.teacher_id AS teacherId, a.description, a.due_date AS dueDate, " +
            "(SELECT COUNT(*) FROM assignment_submission s WHERE s.assignment_id = a.id AND s.submitted_at IS NOT NULL) AS completedCount, " +
            "(SELECT COUNT(*) FROM student_course sc WHERE sc.course_id = a.course_id) AS totalStudents " +
            "FROM assignment a " +
            "LEFT JOIN course c ON c.id = a.course_id " +
            "WHERE a.course_id = #{courseId} " +
            "ORDER BY a.due_date DESC")
    List<AssignmentOverviewDTO> selectOverviewByCourseId(@Param("courseId") Long courseId);
    
    /**
     * 根据学生ID获取作业概览
     */
    @Select("SELECT DISTINCT a.id, a.title, a.course_id AS courseId, c.course_name AS courseName, " +
            "a.teacher_id AS teacherId, a.description, a.due_date AS dueDate, " +
            "(SELECT COUNT(*) FROM assignment_submission s WHERE s.assignment_id = a.id AND s.submitted_at IS NOT NULL) AS completedCount, " +
            "(SELECT COUNT(*) FROM student_course sc WHERE sc.course_id = a.course_id) AS totalStudents " +
            "FROM assignment a " +
            "INNER JOIN student_course sc ON a.course_id = sc.course_id " +
            "LEFT JOIN course c ON c.id = a.course_id " +
            "WHERE sc.student_id = #{studentId} " +
            "ORDER BY a.due_date DESC")
    List<AssignmentOverviewDTO> selectOverviewByStudentId(@Param("studentId") Long studentId);
    
    /**
     * 调用存储过程删除作业（先删除关联题目，再删除作业记录）
     * @param assignmentId 作业ID
     */
    @Update("CALL sp_delete_assignment(#{assignmentId})")
    void deleteAssignmentByProcedure(@Param("assignmentId") Long assignmentId);
}

