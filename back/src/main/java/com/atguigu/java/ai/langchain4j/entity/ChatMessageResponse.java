package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 聊天消息响应DTO
 */
@Data
public class ChatMessageResponse {
    
    /**
     * 消息ID
     */
    private Long id;
    
    /**
     * 发送者姓名
     */
    private String senderName;
    
    /**
     * 发送者头像URL
     */
    private String senderAvatar;
    
    /**
     * 消息内容
     */
    private String message;
    
    /**
     * 消息类型
     */
    private String messageType;
    
    /**
     * 文件名
     */
    private String fileName;
    
    /**
     * 文件大小
     */
    private Long fileSize;
    
    /**
     * 语音时长
     */
    private Integer duration;
    
    /**
     * 发送时间
     */
    private LocalDateTime sentAt;
}
