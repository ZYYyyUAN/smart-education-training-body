package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.Course;
import com.atguigu.java.ai.langchain4j.entity.StudentCourse;
import org.apache.ibatis.annotations.*;

import java.util.List;
import java.util.Map;

/**
 * 学生选课Mapper接口
 * 
 * 该接口提供学生选课相关的数据访问方法，用于学情信息管理模块。
 * 主要功能包括：
 * - 学生选课记录的增删查
 * - 班级选课分布统计
 * - 班级和课程的选课学生数量统计
 * 
 * @author 张政
 * @date 2024
 */
@Mapper
public interface StudentCourseMapper {

    /**
     * 插入学生选课记录
     * 
     * @param studentCourse 学生选课实体对象
     */
    @Insert("INSERT INTO student_course (student_id, course_id, joined_at) VALUES (#{studentId}, #{courseId}, NOW())")
    void insert(StudentCourse studentCourse);

    /**
     * 检查学生是否已选某课程
     * 
     * @param studentId 学生ID
     * @param courseId 课程ID
     * @return 如果已选返回1，否则返回0
     */
    @Select("SELECT COUNT(*) FROM student_course WHERE student_id = #{studentId} AND course_id = #{courseId}")
    int exists(@Param("studentId") Long studentId, @Param("courseId") Long courseId);
    
    /**
     * 查询学生所选的所有课程
     * 
     * @param studentId 学生ID
     * @return 学生所选课程列表
     */
    @Select("SELECT c.* FROM course c " +
            "JOIN student_course sc ON c.id = sc.course_id " +
            "WHERE sc.student_id = #{studentId}")
    List<Course> findCoursesByStudentId(Long studentId);

    /**
     * 学生退选课程
     * 
     * @param studentId 学生ID
     * @param courseId 课程ID
     * @return 影响的行数
     */
    @Delete("DELETE FROM student_course WHERE student_id = #{studentId} AND course_id = #{courseId}")
    int dropCourse(@Param("studentId") Long studentId, @Param("courseId") Long courseId);
    
    /**
     * 统计班级学生的选课分布
     * 
     * 返回指定班级所有学生选课情况的统计信息，包括：
     * - 每个课程的ID和名称
     * - 每个课程的选课学生数量
     * 
     * 结果按选课学生数量降序排列，用于班级概览中的科目分布展示。
     * 
     * @param classId 班级ID
     * @return 课程分布列表，每个元素包含：
     *         - courseId: 课程ID
     *         - courseName: 课程名称
     *         - studentCount: 选课学生数量
     */
    @Select("SELECT " +
            "c.id AS courseId, " +
            "c.course_name AS courseName, " +
            "COUNT(DISTINCT sc.student_id) AS studentCount " +
            "FROM student_course sc " +
            "INNER JOIN course c ON sc.course_id = c.id " +
            "WHERE sc.student_id IN " +
            "(SELECT id FROM user WHERE class_id = #{classId} AND role = 'student') " +
            "GROUP BY c.id, c.course_name " +
            "ORDER BY studentCount DESC")
    List<Map<String, Object>> getCourseDistributionByClassId(@Param("classId") Long classId);
    
    /**
     * 统计班级中选指定课程的学生数量
     * 
     * 用于计算班级在指定课程的作业/考试完成率时，确定分母（选课学生数）。
     * 
     * @param classId 班级ID
     * @param courseId 课程ID
     * @return 选课学生数量
     */
    @Select("SELECT COUNT(DISTINCT sc.student_id) " +
            "FROM student_course sc " +
            "INNER JOIN user u ON sc.student_id = u.id " +
            "WHERE u.class_id = #{classId} AND u.role = 'student' AND sc.course_id = #{courseId}")
    Long countStudentsByClassAndCourse(@Param("classId") Long classId, @Param("courseId") Long courseId);
}
