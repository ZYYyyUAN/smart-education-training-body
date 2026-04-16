package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.PrivateMessage;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface PrivateMessageMapper extends BaseMapper<PrivateMessage> {
    
    /**
     * 根据接收者ID查询私信列表
     */
    @Select("SELECT * FROM private_message WHERE receiver_id = #{receiverId} ORDER BY send_time DESC")
    List<PrivateMessage> selectByReceiverId(Long receiverId);
    
    /**
     * 根据接收者ID查询未读私信数量
     */
    @Select("SELECT COUNT(*) FROM private_message WHERE receiver_id = #{receiverId} AND is_read = 0")
    Integer countUnreadByReceiverId(Long receiverId);
}
