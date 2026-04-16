package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.PrivateMessage;

import java.util.List;

public interface PrivateMessageService {
    
    /**
     * 根据接收者ID获取私信列表
     */
    List<PrivateMessage> getMessagesByReceiverId(Long receiverId);
    
    /**
     * 根据接收者ID获取未读私信数量
     */
    Integer getUnreadCountByReceiverId(Long receiverId);
    
    /**
     * 标记私信为已读
     */
    boolean markAsRead(Long messageId);
    
    /**
     * 删除私信
     */
    boolean deleteMessage(Long messageId);
    
    /**
     * 发送私信
     */
    boolean sendMessage(PrivateMessage message);
}
