package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.Notification;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface NotificationMapper extends BaseMapper<Notification> {
    
    /**
     * 获取所有通知（广播通知）
     */
    List<Notification> selectAllNotifications();
    
    /**
     * 获取指定用户的通知列表
     */
    List<Notification> selectByReceiverId(@Param("receiverId") Long receiverId);
    
    /**
     * 获取用户的所有通知（包括广播通知和专属通知）
     */
    List<Notification> selectUserNotifications(@Param("userId") Long userId);
    
    /**
     * 标记通知为已读
     */
    int markAsRead(@Param("notificationId") Long notificationId, 
                   @Param("userId") Long userId, 
                   @Param("readTime") LocalDateTime readTime);
    
    /**
     * 获取用户未读通知数量
     */
    Integer getUnreadCountByUserId(@Param("userId") Long userId);
    
    /**
     * 插入通知
     */
    int insertNotification(Notification notification);
}
