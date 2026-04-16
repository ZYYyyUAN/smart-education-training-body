package com.atguigu.java.ai.langchain4j.mapper;


import com.atguigu.java.ai.langchain4j.entity.KnowledgeDoc;
import com.atguigu.java.ai.langchain4j.entity.LessonPlan;
import com.atguigu.java.ai.langchain4j.entity.ResourceFile;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.*;
@Mapper
public interface ResourceMapper extends BaseMapper<ResourceFile> {
    @Insert("INSERT INTO resource_file(course_id, teacher_id, file_name, file_path) VALUES(#{courseId}, #{teacherId}, #{fileName}, #{filePath})")
    void insertResource(ResourceFile file);

    @Insert("INSERT INTO knowledge_doc(course_id, file_name, file_path, file_size) VALUES(#{courseId}, #{fileName}, #{filePath}, #{fileSize})")
    void insertKnowledge(KnowledgeDoc doc);

    @Select("SELECT COUNT(1) FROM knowledge_doc WHERE file_path = #{filePath}")
    int countKnowledgeByFilePath(@Param("filePath") String filePath);

    @Insert("INSERT INTO lesson_plan(course_id, teacher_id, plan_title, content) VALUES(#{courseId}, #{teacherId}, #{planTitle}, #{content})")
    void insertLessonPlan(LessonPlan plan);

    @Update("UPDATE resource_file SET is_ingested = 1 WHERE id = #{resourceId}")
    void updateIngestedStatus(@Param("resourceId") Long resourceId);

    @Update("UPDATE resource_file SET is_ingested = 0 WHERE id = #{resourceId}")
    void cancelIngestedStatus(@Param("resourceId") Long resourceId);

    @Update("UPDATE resource_file SET file_name = #{fileName} WHERE id = #{resourceId}")
    void updateFileName(@Param("resourceId") Long resourceId, @Param("fileName") String fileName);
}