package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.Exam;
import com.atguigu.java.ai.langchain4j.entity.ExamOverviewDTO;
import com.atguigu.java.ai.langchain4j.entity.ExamWithStatusDTO;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ExamMapper extends BaseMapper<Exam> {
    @Select("SELECT * FROM exam WHERE course_id = #{courseId}")
    List<Exam> selectByCourseId(Long courseId);

    @Select("SELECT * FROM exam WHERE teacher_id = #{teacherId}")
    List<Exam> selectByTeacherId(Long teacherId);

    @Select("SELECT e.id, e.title, e.course_id AS courseId, c.course_name AS courseName, e.teacher_id AS teacherId, e.exam_date AS examDate, e.duration_minutes AS durationMinutes, " +
            "(SELECT COUNT(*) FROM exam_submission s WHERE s.exam_id = e.id AND s.submitted_at IS NOT NULL) AS completedCount, " +
            "(SELECT COUNT(*) FROM student_course sc WHERE sc.course_id = e.course_id) AS totalStudents " +
            "FROM exam e LEFT JOIN course c ON c.id = e.course_id WHERE e.teacher_id = #{teacherId}")
    List<ExamOverviewDTO> selectOverviewByTeacher(Long teacherId);
    
    /**
     * 获取所有考试概览（含完成人数/完成率）
     */
    @Select("SELECT e.id, e.title, e.course_id AS courseId, c.course_name AS courseName, e.teacher_id AS teacherId, e.exam_date AS examDate, e.duration_minutes AS durationMinutes, " +
            "(SELECT COUNT(*) FROM exam_submission s WHERE s.exam_id = e.id AND s.submitted_at IS NOT NULL) AS completedCount, " +
            "(SELECT COUNT(*) FROM student_course sc WHERE sc.course_id = e.course_id) AS totalStudents " +
            "FROM exam e LEFT JOIN course c ON c.id = e.course_id " +
            "ORDER BY e.exam_date DESC")
    List<ExamOverviewDTO> selectAllExamsOverview();
    
    /**
     * 根据课程ID获取考试概览
     */
    @Select("SELECT e.id, e.title, e.course_id AS courseId, c.course_name AS courseName, e.teacher_id AS teacherId, e.exam_date AS examDate, e.duration_minutes AS durationMinutes, " +
            "(SELECT COUNT(*) FROM exam_submission s WHERE s.exam_id = e.id AND s.submitted_at IS NOT NULL) AS completedCount, " +
            "(SELECT COUNT(*) FROM student_course sc WHERE sc.course_id = e.course_id) AS totalStudents " +
            "FROM exam e LEFT JOIN course c ON c.id = e.course_id " +
            "WHERE e.course_id = #{courseId} " +
            "ORDER BY e.exam_date DESC")
    List<ExamOverviewDTO> selectOverviewByCourse(@Param("courseId") Long courseId);

    @Select("SELECT e.* FROM exam e INNER JOIN student_course sc ON sc.course_id = e.course_id " +
            "WHERE sc.student_id = #{studentId} AND e.exam_date BETWEEN CURRENT_DATE() AND DATE_ADD(CURRENT_DATE(), INTERVAL #{days} DAY) " +
            "AND NOT EXISTS (SELECT 1 FROM exam_result er WHERE er.exam_id = e.id AND er.student_id = #{studentId}) " +
            "ORDER BY e.exam_date ASC")
    List<Exam> selectUpcomingByStudent(@Param("studentId") Long studentId, @Param("days") int days);

    @Select("SELECT e.id AS examId, e.course_id AS courseId, e.title, e.description, e.exam_date AS examDate, e.duration_minutes AS durationMinutes, " +
            "CASE WHEN er.id IS NULL THEN FALSE ELSE TRUE END AS submitted, er.submitted_at AS submittedAt, er.score " +
            "FROM exam e INNER JOIN student_course sc ON sc.course_id = e.course_id " +
            "LEFT JOIN exam_result er ON er.exam_id = e.id AND er.student_id = #{studentId} " +
            "WHERE sc.student_id = #{studentId} AND e.course_id = #{courseId} " +
            "ORDER BY e.exam_date DESC")
    List<ExamWithStatusDTO> selectExamsWithStatus(@Param("studentId") Long studentId, @Param("courseId") Long courseId);
    
    /**
     * 使用存储过程删除考试（包含所有关联数据）
     */
    @Update("CALL sp_delete_exam(#{examId})")
    void deleteExamByProcedure(@Param("examId") Long examId);
}


