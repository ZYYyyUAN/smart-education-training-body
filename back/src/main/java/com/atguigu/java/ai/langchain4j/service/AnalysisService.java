package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.StudentAnalysisReport;
import com.atguigu.java.ai.langchain4j.entity.Student;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;

@Service
public interface AnalysisService {
   StudentAnalysisReport analyzeStudent(Long studentId, Long courseId);
   // 新增：根据课程ID获取学生列表（若你已有独立的StudentService，可迁移到对应Service）
   List<Student> getStudentsByCourseId(Long courseId);
   
   // 新增：获取学生薄弱知识点
   List<Map<String, Object>> getWeakKnowledgePoints(Long studentId, Long courseId);
   
   // 新增：获取学生作业得分情况
   List<Map<String, Object>> getAssignmentScores(Long studentId, Long courseId);
   
   // 新增：获取学生作业详情
   List<Map<String, Object>> getAssignmentDetail(Long assignmentId, Long studentId);
   
   // 获取课程下的所有知识点
   List<String> getCourseKnowledgePoints(Long courseId);
}
