package com.atguigu.java.ai.langchain4j.mapper;


import com.atguigu.java.ai.langchain4j.entity.QuestionBank;
import com.atguigu.java.ai.langchain4j.entity.QuestionDto;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface QuestionBankMapper extends BaseMapper<QuestionBank> {

    @Select("SELECT * FROM question_bank WHERE id IN (SELECT question_id FROM assignment_question WHERE assignment_id = #{assignmentId})")
    List<QuestionBank> selectByAssignmentId(Long assignmentId);

    @Select("SELECT qb.* FROM question_bank qb INNER JOIN exam_question eq ON eq.question_id = qb.id WHERE eq.exam_id = #{examId}")
    List<QuestionBank> selectByExamId(Long examId);

    List<QuestionBank> selectByCourseId(Long courseId);

    void insertBatch(List<QuestionBank> entities);

    @Select("SELECT id, course_id as courseId, type, content, answer, " +
            "knowledge_point as knowledgePoint, created_by as createdBy, " +
            "created_at as createdAt FROM question_bank " +
            "WHERE created_by = #{createdBy} " +
            "ORDER BY created_at DESC")
    List<QuestionDto> selectByCreateId(@Param("createdBy") Long createdBy);


    @Select("SELECT * FROM question_bank")
    List<QuestionBank> list();

    @Select("SELECT COUNT(*) FROM question_bank")
    long countAll();

    @Select("SELECT * FROM question_bank ORDER BY created_at DESC LIMIT #{limit} OFFSET #{offset}")
    List<QuestionBank> pageAll(@Param("offset") int offset, @Param("limit") int limit);

    @Select("SELECT * FROM question_bank WHERE category_id = #{categoryId} ORDER BY created_at DESC")
    List<QuestionBank> selectByCategoryId(@Param("categoryId") Long categoryId);

    @Select("SELECT COUNT(*) FROM question_bank WHERE category_id = #{categoryId}")
    long countByCategoryId(@Param("categoryId") Long categoryId);

    @Select("SELECT * FROM question_bank WHERE category_id = #{categoryId} ORDER BY created_at DESC LIMIT #{limit} OFFSET #{offset}")
    List<QuestionBank> pageByCategoryId(@Param("categoryId") Long categoryId,
                                        @Param("offset") int offset,
                                        @Param("limit") int limit);

    @org.apache.ibatis.annotations.Update("UPDATE question_bank SET category_id = #{newCategoryId} WHERE category_id = #{oldCategoryId}")
    int reassignCategory(@Param("oldCategoryId") Long oldCategoryId, @Param("newCategoryId") Long newCategoryId);

    @Select("SELECT COUNT(*) FROM question_bank WHERE course_id = #{courseId}")
    long countByCourseId(@Param("courseId") Long courseId);

    @Select("SELECT COUNT(*) FROM question_bank WHERE course_id = #{courseId} AND category_id = #{categoryId}")
    long countByCourseAndCategory(@Param("courseId") Long courseId, @Param("categoryId") Long categoryId);

    List<QuestionBank> selectByIds(@Param("ids") List<Long> ids);

    // 其他自定义方法
}
