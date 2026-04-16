package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.Course;
import com.atguigu.java.ai.langchain4j.entity.StudentCourse;
import com.atguigu.java.ai.langchain4j.mapper.CourseMapper;
import com.atguigu.java.ai.langchain4j.mapper.StudentCourseMapper;
import com.atguigu.java.ai.langchain4j.service.StudentCourseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class StudentCourseServiceImpl implements StudentCourseService {

    @Autowired
    private StudentCourseMapper studentCourseMapper;
    @Autowired
    private CourseMapper courseMapper;

    @Override
    public boolean joinCourse(Long studentId, Long courseId) {
        if (courseMapper.selectById(courseId) == null) return false;

        if (studentCourseMapper.exists(studentId, courseId) > 0) return false;

        StudentCourse sc = new StudentCourse();
        sc.setStudentId(studentId);
        sc.setCourseId(courseId);
        sc.setJoinedAt(LocalDateTime.now());
        studentCourseMapper.insert(sc);
        return true;
    }



    public List<Course> getMyCourses(Long studentId) {
        return studentCourseMapper.findCoursesByStudentId(studentId);
    }


    public boolean dropCourse(Long studentId, Long courseId) {
        return studentCourseMapper.dropCourse(studentId, courseId) > 0;
    }
}
