package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 聊天消息请求DTO
 */
@Data
public class ChatMessageRequest {
    
    /**
     * 课程ID
     */
    private Long courseId;
    
    /**
     * 发送者ID
     */
    private Long senderId;
    
    /**
     * 发送者姓名
     */
    private String senderName;
    
    /**
     * 消息类型
     */
    private String messageType;
    
    /**
     * 消息内容
     */
    private String messageContent;
    
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
