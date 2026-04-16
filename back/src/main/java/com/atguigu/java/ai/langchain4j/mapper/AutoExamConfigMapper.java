package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.AutoExamConfig;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 自动组卷配置Mapper
 */
@Mapper
public interface AutoExamConfigMapper extends BaseMapper<AutoExamConfig> {
    
    /**
     * 根据课程ID和教师ID查询配置列表
     */
    List<AutoExamConfig> selectByCourseAndTeacher(@Param("courseId") Long courseId, @Param("teacherId") Long teacherId);
    
    /**
     * 根据课程ID查询活跃配置
     */
    List<AutoExamConfig> selectActiveByCourseId(@Param("courseId") Long courseId);
}
