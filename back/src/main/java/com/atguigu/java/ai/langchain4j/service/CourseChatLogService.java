package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.ChatMessageRequest;
import com.atguigu.java.ai.langchain4j.entity.ChatMessageResponse;

import java.util.List;

/**
 * 课程聊天记录Service接口
 */
public interface CourseChatLogService {
    
    /**
     * 保存聊天消息
     * @param request 聊天消息请求
     * @return 保存的消息ID
     */
    Long saveChatMessage(ChatMessageRequest request);
    
    /**
     * 获取课程聊天记录
     * @param courseId 课程ID
     * @param limit 限制条数
     * @param offset 偏移量
     * @return 聊天记录列表
     */
    List<ChatMessageResponse> getChatHistory(Long courseId, Integer limit, Integer offset);
    
    /**
     * 获取课程聊天统计
     * @param courseId 课程ID
     * @return 统计信息
     */
    ChatStatistics getChatStatistics(Long courseId);
    
    /**
     * 删除聊天记录
     * @param messageId 消息ID
     * @return 是否删除成功
     */
    boolean deleteChatMessage(Long messageId);
    
    /**
     * 聊天统计信息
     */
    class ChatStatistics {
        private Long totalMessages;
        private Long uniqueSenders;
        private String firstMessageTime;
        private String lastMessageTime;
        
        // getters and setters
        public Long getTotalMessages() { return totalMessages; }
        public void setTotalMessages(Long totalMessages) { this.totalMessages = totalMessages; }
        
        public Long getUniqueSenders() { return uniqueSenders; }
        public void setUniqueSenders(Long uniqueSenders) { this.uniqueSenders = uniqueSenders; }
        
        public String getFirstMessageTime() { return firstMessageTime; }
        public void setFirstMessageTime(String firstMessageTime) { this.firstMessageTime = firstMessageTime; }
        
        public String getLastMessageTime() { return lastMessageTime; }
        public void setLastMessageTime(String lastMessageTime) { this.lastMessageTime = lastMessageTime; }
    }
}
