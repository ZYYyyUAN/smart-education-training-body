package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.Answer;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import java.util.List;

@Mapper
public interface AnswerMapper extends BaseMapper<Answer> {

    @Select("SELECT a.*, u.real_name as userName, u.email as userUniversity " +
            "FROM answer a " +
            "LEFT JOIN user u ON a.user_id = u.id " +
            "WHERE a.question_id = #{questionId} " +
            "ORDER BY a.create_time ASC")
    List<Answer> selectAnswersByQuestionId(Integer questionId);
} 