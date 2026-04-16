package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.Question;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import java.util.List;

@Mapper
public interface QuestionMapper extends BaseMapper<Question> {

    @Select("SELECT q.*, u.real_name as userName, u.email as userUniversity, " +
            "(SELECT COUNT(*) FROM answer a WHERE a.question_id = q.id) as answerCount " +
            "FROM question q " +
            "LEFT JOIN user u ON q.user_id = u.id " +
            "WHERE q.course_id = #{courseId} " +
            "ORDER BY q.create_time DESC")
    List<Question> selectQuestionsByCourseId(Integer courseId);
} 