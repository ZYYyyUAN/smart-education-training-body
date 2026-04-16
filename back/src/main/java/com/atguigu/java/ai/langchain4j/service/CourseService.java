package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.Course;

import java.util.List;

public interface CourseService {
    boolean createCourse(Course course);

    List<Course> getAllCourses();
    Course getCourseById(Long id);
    void updateCourse(Course course);
    void deleteCourse(Long id);
    List<Course> getCoursesByTeacherId(Long teacherId);
}
