package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("notification")
public class Notification {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String title;
    
    private String content;
    
    private Long senderId;
    
    private String senderName;
    
    private Long receiverId;
    
    private String receiverName;
    
    private Integer isImportant;
    
    private String courseName;
    
    private String notificationType;
    
    private LocalDateTime sendTime;
    
    private LocalDateTime readTime;
    
    private String status;
    
    private LocalDateTime createTime;
    
    private LocalDateTime updateTime;
}
