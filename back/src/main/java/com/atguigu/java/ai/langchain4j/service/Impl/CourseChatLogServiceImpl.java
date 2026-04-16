package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.ChatMessageRequest;
import com.atguigu.java.ai.langchain4j.entity.ChatMessageResponse;
import com.atguigu.java.ai.langchain4j.entity.CourseChatLog;
import com.atguigu.java.ai.langchain4j.mapper.CourseChatLogMapper;
import com.atguigu.java.ai.langchain4j.service.CourseChatLogService;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 课程聊天记录Service实现类
 */
@Slf4j
@Service
public class CourseChatLogServiceImpl implements CourseChatLogService {
    
    @Autowired
    private CourseChatLogMapper courseChatLogMapper;
    
    @Override
    public Long saveChatMessage(ChatMessageRequest request) {
        log.info("保存聊天消息: courseId={}, senderName={}, messageType={}", 
                request.getCourseId(), request.getSenderName(), request.getMessageType());
        
        CourseChatLog chatLog = new CourseChatLog();
        chatLog.setCourseId(request.getCourseId());
        chatLog.setSenderId(request.getSenderId());
        chatLog.setSenderName(request.getSenderName());
        chatLog.setMessage(request.getMessageContent());
        chatLog.setMessageType(request.getMessageType() != null ? request.getMessageType() : "text");
        chatLog.setFileName(request.getFileName());
        chatLog.setFileSize(request.getFileSize());
        chatLog.setDuration(request.getDuration());
        chatLog.setSentAt(request.getSentAt() != null ? request.getSentAt() : LocalDateTime.now());
        
        courseChatLogMapper.insert(chatLog);
        
        log.info("聊天消息保存成功，消息ID: {}", chatLog.getId());
        return chatLog.getId();
    }
    
    @Override
    public List<ChatMessageResponse> getChatHistory(Long courseId, Integer limit, Integer offset) {
        log.info("获取聊天记录: courseId={}, limit={}, offset={}", courseId, limit, offset);
        
        // 设置默认值
        limit = limit != null ? limit : 50;
        offset = offset != null ? offset : 0;
        
        List<CourseChatLog> chatLogs = courseChatLogMapper.selectByCourseId(courseId, limit, offset);
        
        List<ChatMessageResponse> responses = chatLogs.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
        
        log.info("获取到 {} 条聊天记录", responses.size());
        return responses;
    }
    
    @Override
    public ChatStatistics getChatStatistics(Long courseId) {
        log.info("获取聊天统计: courseId={}", courseId);
        
        ChatStatistics statistics = new ChatStatistics();
        
        // 统计总消息数
        Long totalMessages = courseChatLogMapper.countByCourseId(courseId);
        statistics.setTotalMessages(totalMessages);
        
        // 统计不同发送者数量
        Long uniqueSenders = courseChatLogMapper.countDistinctSendersByCourseId(courseId);
        statistics.setUniqueSenders(uniqueSenders);
        
        // 获取第一条和最后一条消息时间
        QueryWrapper<CourseChatLog> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("course_id", courseId);
        
        // 第一条消息
        queryWrapper.orderByAsc("sent_at").last("LIMIT 1");
        CourseChatLog firstMessage = courseChatLogMapper.selectOne(queryWrapper);
        if (firstMessage != null) {
            statistics.setFirstMessageTime(firstMessage.getSentAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        }
        
        // 最后一条消息
        queryWrapper.clear();
        queryWrapper.eq("course_id", courseId).orderByDesc("sent_at").last("LIMIT 1");
        CourseChatLog lastMessage = courseChatLogMapper.selectOne(queryWrapper);
        if (lastMessage != null) {
            statistics.setLastMessageTime(lastMessage.getSentAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        }
        
        log.info("聊天统计: 总消息数={}, 发送者数={}", totalMessages, uniqueSenders);
        return statistics;
    }
    
    @Override
    public boolean deleteChatMessage(Long messageId) {
        log.info("删除聊天消息: messageId={}", messageId);
        
        int result = courseChatLogMapper.deleteById(messageId);
        boolean success = result > 0;
        
        log.info("删除聊天消息结果: {}", success ? "成功" : "失败");
        return success;
    }
    
    /**
     * 转换为响应DTO
     */
    private ChatMessageResponse convertToResponse(CourseChatLog chatLog) {
        ChatMessageResponse response = new ChatMessageResponse();
        response.setId(chatLog.getId());
        response.setSenderName(chatLog.getSenderName());
        response.setSenderAvatar(chatLog.getSenderAvatar()); // 添加头像字段
        response.setMessage(chatLog.getMessage());
        response.setMessageType(chatLog.getMessageType());
        response.setFileName(chatLog.getFileName());
        response.setFileSize(chatLog.getFileSize());
        response.setDuration(chatLog.getDuration());
        response.setSentAt(chatLog.getSentAt());
        return response;
    }
}
