package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.Notification;

import java.util.List;

public interface NotificationService {
    
    /**
     * 根据接收者ID获取通知列表
     */
    List<Notification> getNotificationsByReceiverId(Long receiverId);
    
    /**
     * 获取所有广播通知
     */
    List<Notification> getAllBroadcastNotifications();
    
    /**
     * 获取用户的所有通知（包括广播通知和专属通知）
     */
    List<Notification> getUserNotifications(Long userId);
    
    /**
     * 标记通知为已读
     */
    boolean markAsRead(Long notificationId, Long userId);
    
    /**
     * 发送通知
     */
    boolean sendNotification(Notification notification);
    
    /**
     * 删除通知
     */
    boolean deleteNotification(Long notificationId);
    
    /**
     * 获取用户未读通知数量
     */
    Integer getUnreadCountByUserId(Long userId);
    
    /**
     * 创建新通知
     */
    boolean createNotification(Notification notification);
}
