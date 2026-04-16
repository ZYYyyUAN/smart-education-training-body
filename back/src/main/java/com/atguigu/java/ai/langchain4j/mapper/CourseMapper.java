package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.Course;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface CourseMapper extends BaseMapper<Course> {
    @Select("SELECT * FROM course")
    List<Course> findAll();

    @Select("SELECT * FROM course WHERE id = #{id}")
    Course findById(Long id);

    @Update("UPDATE course SET course_name = #{courseName}, course_image = #{courseImage}, teaching_goal = #{teachingGoal}, teaching_principle = #{teachingPrinciple}, course_background = #{courseBackground}, course_intro = #{courseIntro} WHERE id = #{id}")
    void update(Course course);

    @Delete("DELETE FROM course WHERE id = #{id}")
    void delete(Long id);
    // 自定义方法：根据教师 ID 查询课程
    @Select("SELECT * FROM course WHERE teacher_id = #{teacherId}")
    List<Course> selectByTeacherId(Long teacherId);
}
