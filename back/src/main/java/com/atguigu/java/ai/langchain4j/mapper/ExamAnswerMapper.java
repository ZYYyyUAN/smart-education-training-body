package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.ExamAnswer;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/**
 * 考试答案Mapper
 */
@Mapper
public interface ExamAnswerMapper extends BaseMapper<ExamAnswer> {
}
