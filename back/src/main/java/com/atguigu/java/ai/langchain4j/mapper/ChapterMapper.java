package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.Chapter;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface ChapterMapper {
    @Insert("INSERT INTO chapter (course_id, chapter_title, content, created_at) " +
            "VALUES (#{courseId}, #{chapterTitle}, #{content}, NOW())")
    int insert(Chapter chapter);

    @Select("SELECT * FROM chapter WHERE course_id = #{courseId}")
    List<Chapter> findByCourseId(Long courseId);

    @Select("SELECT * FROM chapter WHERE id = #{id}")
    Chapter findById(Long id);

    @Update("UPDATE chapter SET chapter_title = #{chapterTitle}, content = #{content} WHERE id = #{id}")
    void update(Chapter chapter);
    @Delete("DELETE FROM chapter WHERE id = #{id}")
    void delete(Long id);

    @Select("SELECT * FROM chapter WHERE course_id = #{courseId}")
    List<Chapter> selectByCourseId(@Param("courseId") Long courseId);
}
