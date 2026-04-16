package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.PracticeRecord;
import com.atguigu.java.ai.langchain4j.entity.PracticeRecordDetail;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PracticeRecordMapper {
    
    void insertPracticeRecord(PracticeRecord record);
    
    void insertPracticeRecordDetail(PracticeRecordDetail detail);
    
    List<PracticeRecord> getPracticeRecordsByStudentId(
        @Param("studentId") Long studentId,
        @Param("offset") Integer offset,
        @Param("size") Integer size,
        @Param("courseId") String courseId,
        @Param("sortBy") String sortBy,
        @Param("startDate") String startDate,
        @Param("endDate") String endDate
    );
    
    int countPracticeRecordsByStudentId(
        @Param("studentId") Long studentId,
        @Param("courseId") String courseId,
        @Param("startDate") String startDate,
        @Param("endDate") String endDate
    );
    
    List<PracticeRecordDetail> getPracticeRecordDetails(@Param("practiceRecordId") Long practiceRecordId);
} 
 