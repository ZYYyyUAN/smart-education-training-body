package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.StudentAnalysisReport;
import org.apache.ibatis.annotations.*;

@Mapper
public interface StudentAnalysisReportMapper {

    @Insert("""
       INSERT INTO student_analysis_report(student_id, course_id, knowledge_analysis, teaching_suggestion, created_at)
       VALUES(#{studentId}, #{courseId}, #{knowledgeAnalysis}, #{teachingSuggestion}, NOW())
       
    """)
    void insert(StudentAnalysisReport report);
}
