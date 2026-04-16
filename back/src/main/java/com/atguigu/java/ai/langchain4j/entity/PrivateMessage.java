package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("private_message")
public class PrivateMessage {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long senderId;
    
    private String senderName;
    
    private String senderAvatar;
    
    private Long receiverId;
    
    private String receiverName;
    
    private String subject;
    
    private String content;
    
    private Integer isRead;
    
    private Integer isImportant;
    
    private String courseName;
    
    private LocalDateTime sendTime;
    
    private LocalDateTime readTime;
    
    private String messageType;
    
    private String status;
    
    private LocalDateTime createTime;
    
    private LocalDateTime updateTime;
}
