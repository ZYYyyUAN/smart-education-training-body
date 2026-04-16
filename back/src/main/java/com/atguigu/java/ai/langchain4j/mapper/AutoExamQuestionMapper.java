package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.AutoExamQuestion;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 试卷题目关联Mapper
 */
@Mapper
public interface AutoExamQuestionMapper extends BaseMapper<AutoExamQuestion> {
    
    /**
     * 根据试卷ID查询题目列表
     */
    List<AutoExamQuestion> selectByExamId(@Param("examId") Long examId);
    
    /**
     * 根据题目ID查询试卷题目列表
     */
    List<AutoExamQuestion> selectByQuestionBankId(@Param("questionBankId") Long questionBankId);
    
    /**
     * 根据试卷ID删除所有题目
     */
    int deleteByExamId(@Param("examId") Long examId);
    
    /**
     * 根据题目ID删除所有试卷题目
     */
    int deleteByQuestionBankId(@Param("questionBankId") Long questionBankId);
    
    /**
     * 删除某张试卷中的指定题目
     */
    int deleteByExamAndQuestion(@Param("examId") Long examId, @Param("questionBankId") Long questionBankId);
    
    /**
     * 更新题目的排序序号
     */
    int updateQuestionOrder(@Param("id") Long id, @Param("questionOrder") Integer questionOrder);
    
    /**
     * 批量插入试卷题目
     */
    int insertBatch(@Param("questions") List<AutoExamQuestion> questions);
}
