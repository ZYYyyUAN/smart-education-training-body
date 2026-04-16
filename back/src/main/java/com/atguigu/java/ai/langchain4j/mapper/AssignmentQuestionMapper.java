package com.atguigu.java.ai.langchain4j.mapper;


import com.atguigu.java.ai.langchain4j.entity.AssignmentQuestion;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AssignmentQuestionMapper extends BaseMapper<AssignmentQuestion> {
    int insertBatch(@Param("assignmentId") Long assignmentId, @Param("questionIds") List<Long> questionIds);

    void deleteByAssignmentId(Long assignmentId);

    // 可扩展：通过 assignmentId 查询题目列表等
}
