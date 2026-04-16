package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.assistant.XiaozhiAgent;
import com.atguigu.java.ai.langchain4j.entity.PracticeLog;
import com.atguigu.java.ai.langchain4j.entity.Student;
import com.atguigu.java.ai.langchain4j.entity.StudentAnalysisReport;
import com.atguigu.java.ai.langchain4j.mapper.PracticeLogMapper;
import com.atguigu.java.ai.langchain4j.mapper.StudentAnalysisReportMapper;
import com.atguigu.java.ai.langchain4j.mapper.StudentMapper;
import com.atguigu.java.ai.langchain4j.service.AnalysisService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class AnalysisServiceImpl implements AnalysisService {

    @Autowired
    private PracticeLogMapper practiceLogMapper;

    @Autowired
    private StudentAnalysisReportMapper reportMapper;

    @Autowired
    private StudentMapper studentMapper;

    @Autowired
    private XiaozhiAgent xiaozhiAgent;

    @Override
    public StudentAnalysisReport analyzeStudent(Long studentId, Long courseId) {
        List<PracticeLog> logs = practiceLogMapper.findByStudentAndCourse(studentId, courseId);

        StringBuilder analysisInput = new StringBuilder();
        for (PracticeLog log : logs) {
            analysisInput.append("【题目】").append(log.getQuestionId())
                    .append("\n【学生答案】").append(log.getAnswerText())
                    .append("\n【是否正确】")
                    .append(Boolean.TRUE.equals(log.getIsCorrect()) ? "正确" : "错误")
                    .append("\n【错误原因】")
                    .append(log.getErrorReason() == null ? "无" : log.getErrorReason())
                    .append("\n\n");
        }


        String result = xiaozhiAgent.analyzeOverall(analysisInput.toString());

        // 简单切割结构（你也可以用 JSON 结构或更规范的格式）
        String[] parts = result.split("【教学建议】");
        StudentAnalysisReport report = new StudentAnalysisReport();
        report.setStudentId(studentId);
        report.setCourseId(courseId);
        report.setKnowledgeAnalysis(parts[0].replace("【知识掌握情况】", "").trim());
        report.setTeachingSuggestion(parts.length > 1 ? parts[1].trim() : "无");

        reportMapper.insert(report);
        return report;
    }

    @Override
    public List<Student> getStudentsByCourseId(Long courseId) {
        return studentMapper.findByCourseId(courseId);
    }
    
    @Override
    public List<Map<String, Object>> getWeakKnowledgePoints(Long studentId, Long courseId) {
        return studentMapper.findWeakKnowledgePoints(studentId, courseId);
    }
    
    @Override
    public List<Map<String, Object>> getAssignmentScores(Long studentId, Long courseId) {
        return studentMapper.findAssignmentScores(studentId, courseId);
    }
    
    @Override
    public List<Map<String, Object>> getAssignmentDetail(Long assignmentId, Long studentId) {
        return studentMapper.findAssignmentDetail(assignmentId, studentId);
    }
    
    @Override
    public List<String> getCourseKnowledgePoints(Long courseId) {
        return studentMapper.findCourseKnowledgePoints(courseId);
    }
}
