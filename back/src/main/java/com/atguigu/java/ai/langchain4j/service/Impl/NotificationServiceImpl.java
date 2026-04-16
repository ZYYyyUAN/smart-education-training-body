package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.Notification;
import com.atguigu.java.ai.langchain4j.mapper.NotificationMapper;
import com.atguigu.java.ai.langchain4j.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class NotificationServiceImpl implements NotificationService {
    
    @Autowired
    private NotificationMapper notificationMapper;
    
    @Override
    public List<Notification> getNotificationsByReceiverId(Long receiverId) {
        return notificationMapper.selectByReceiverId(receiverId);
    }
    
    @Override
    public List<Notification> getAllBroadcastNotifications() {
        return notificationMapper.selectAllNotifications();
    }
    
    @Override
    public List<Notification> getUserNotifications(Long userId) {
        return notificationMapper.selectUserNotifications(userId);
    }
    
    @Override
    public boolean markAsRead(Long notificationId, Long userId) {
        return notificationMapper.markAsRead(notificationId, userId, LocalDateTime.now()) > 0;
    }
    
    @Override
    public boolean sendNotification(Notification notification) {
        notification.setSendTime(LocalDateTime.now());
        notification.setStatus("sent");
        notification.setCreateTime(LocalDateTime.now());
        notification.setUpdateTime(LocalDateTime.now());
        return notificationMapper.insertNotification(notification) > 0;
    }
    
    @Override
    public boolean deleteNotification(Long notificationId) {
        return notificationMapper.deleteById(notificationId) > 0;
    }
    
    @Override
    public Integer getUnreadCountByUserId(Long userId) {
        return notificationMapper.getUnreadCountByUserId(userId);
    }
    
    @Override
    public boolean createNotification(Notification notification) {
        notification.setCreateTime(LocalDateTime.now());
        notification.setUpdateTime(LocalDateTime.now());
        return notificationMapper.insertNotification(notification) > 0;
    }
}

