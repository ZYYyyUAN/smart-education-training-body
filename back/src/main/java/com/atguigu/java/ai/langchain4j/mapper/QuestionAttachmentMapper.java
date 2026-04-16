package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.QuestionAttachment;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import java.util.List;

@Mapper
public interface QuestionAttachmentMapper extends BaseMapper<QuestionAttachment> {

    @Select("SELECT * FROM question_attachment WHERE question_id = #{questionId}")
    List<QuestionAttachment> selectByQuestionId(Integer questionId);
} 