package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.Course;

import java.util.List;

public interface StudentCourseService {
    boolean joinCourse(Long studentId, Long courseId);
    List<Course> getMyCourses(Long studentId);
    boolean dropCourse(Long studentId, Long courseId);
}