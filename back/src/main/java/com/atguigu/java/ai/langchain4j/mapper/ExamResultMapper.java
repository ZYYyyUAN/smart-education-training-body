package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.ExamResult;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 考试结果Mapper
 */
@Mapper
public interface ExamResultMapper extends BaseMapper<ExamResult> {
    
    /**
     * 根据考试ID和学生ID查询考试结果
     */
    @Select("SELECT * FROM exam_result WHERE exam_id = #{examId} AND student_id = #{studentId}")
    ExamResult selectByExamAndStudent(@Param("examId") Long examId, @Param("studentId") Long studentId);
}
