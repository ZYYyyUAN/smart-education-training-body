package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.Course;
import com.atguigu.java.ai.langchain4j.mapper.CourseMapper;
import com.atguigu.java.ai.langchain4j.service.CourseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CourseServiceImpl implements CourseService {

    @Autowired
    private CourseMapper courseMapper;

    @Override
    public boolean createCourse(Course course) {
        return courseMapper.insert(course) > 0;
    }



    @Override
    public List<Course> getAllCourses() {
        return courseMapper.selectList(null);
    }

    @Override
    public Course getCourseById(Long id) {
        return courseMapper.findById(id);
    }

    @Override
    public void updateCourse(Course course) {
        courseMapper.update(course);
    }

    @Override
    public void deleteCourse(Long id) {
        courseMapper.delete(id);
    }
    @Override
    public List<Course> getCoursesByTeacherId(Long teacherId) {
        return courseMapper.selectByTeacherId(teacherId);
    }
}
