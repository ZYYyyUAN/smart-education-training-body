package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 课程聊天记录实体类
 */
@Data
@TableName("course_chat_log")
public class CourseChatLog {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
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
     * 发送者头像URL
     */
    private String senderAvatar;
    
    /**
     * 消息内容
     */
    private String message;
    
    /**
     * 消息类型：text(文本)、sticker(表情包)、image(图片)、file(文件)、voice(语音)
     */
    private String messageType;
    
    /**
     * 文件名
     */
    private String fileName;
    
    /**
     * 文件大小(字节)
     */
    private Long fileSize;
    
    /**
     * 语音时长(秒)
     */
    private Integer duration;
    
    /**
     * 发送时间
     */
    private LocalDateTime sentAt;
}
