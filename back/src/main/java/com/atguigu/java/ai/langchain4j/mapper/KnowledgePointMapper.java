package com.atguigu.java.ai.langchain4j.mapper;


import com.atguigu.java.ai.langchain4j.entity.KnowledgePoint;
import org.apache.ibatis.annotations.*;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface KnowledgePointMapper {
    @Select("SELECT * FROM knowledge_point WHERE chapter_id = #{chapterId}")
    List<KnowledgePoint> selectByChapterId(@Param("chapterId") Long chapterId);

    @Select("SELECT kp.* FROM knowledge_point kp " +
            "JOIN chapter c ON kp.chapter_id = c.id " +
            "WHERE c.course_id = #{courseId}")
    List<KnowledgePoint> selectByCourseId(@Param("courseId") Long courseId);

    @Insert("INSERT INTO knowledge_point (chapter_id, title) VALUES (#{chapterId}, #{title})")
    int insert(KnowledgePoint kp);

    @Update("UPDATE knowledge_point SET title = #{title} WHERE id = #{id}")
    int update(KnowledgePoint kp);

    @Delete("DELETE FROM knowledge_point WHERE id = #{id}")
    int delete(@Param("id") Long id);
}