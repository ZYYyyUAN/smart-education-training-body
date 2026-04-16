package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.CourseChatLog;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 课程聊天记录Mapper接口
 */
@Mapper
public interface CourseChatLogMapper extends BaseMapper<CourseChatLog> {
    
    /**
     * 根据课程ID查询聊天记录
     * @param courseId 课程ID
     * @param limit 限制条数
     * @param offset 偏移量
     * @return 聊天记录列表
     */
    List<CourseChatLog> selectByCourseId(@Param("courseId") Long courseId, 
                                        @Param("limit") Integer limit, 
                                        @Param("offset") Integer offset);
    
    /**
     * 根据课程ID统计消息数量
     * @param courseId 课程ID
     * @return 消息数量
     */
    Long countByCourseId(@Param("courseId") Long courseId);
    
    /**
     * 根据课程ID统计不同发送者数量
     * @param courseId 课程ID
     * @return 发送者数量
     */
    Long countDistinctSendersByCourseId(@Param("courseId") Long courseId);
}
