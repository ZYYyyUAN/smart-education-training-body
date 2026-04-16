package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.ExamQuestion;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface ExamQuestionMapper extends BaseMapper<ExamQuestion> {

    @Insert({
        "<script>",
        "INSERT INTO exam_question (exam_id, question_id) VALUES",
        "<foreach collection='questionIds' item='qid' separator=','>",
        "(#{examId}, #{qid})",
        "</foreach>",
        "</script>"
    })
    int insertBatch(@Param("examId") Long examId, @Param("questionIds") List<Long> questionIds);

    @Delete("DELETE FROM exam_question WHERE exam_id = #{examId}")
    void deleteByExamId(@Param("examId") Long examId);
    
    @Insert("INSERT INTO exam_question (exam_id, question_id) VALUES (#{examId}, #{questionId})")
    int insertExamQuestion(@Param("examId") Long examId, @Param("questionId") Long questionId);


    @Select("SELECT * FROM exam_question WHERE question_id = #{questionId}")
    List<ExamQuestion> selectByQuestionId(@Param("questionId") Long questionId);
}


