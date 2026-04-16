package com.atguigu.java.ai.langchain4j.config;

import com.atguigu.java.ai.langchain4j.entity.User;
import com.atguigu.java.ai.langchain4j.mapper.UserMapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.concurrent.ConcurrentHashMap;
import java.util.*;
@Component
public class GroupChatHandler extends TextWebSocketHandler {

    @Autowired
    private UserMapper userMapper;
    
    private final ObjectMapper objectMapper = new ObjectMapper();

    // 存储每门课程的连接（courseId -> 用户列表）
    private static final Map<Long, Set<WebSocketSession>> courseSessions = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        Long courseId = Long.parseLong(Objects.requireNonNull(session.getAttributes().get("courseId")).toString());
        courseSessions.putIfAbsent(courseId, Collections.newSetFromMap(new ConcurrentHashMap<>()));
        courseSessions.get(courseId).add(session);
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        Long courseId = Long.parseLong(session.getAttributes().get("courseId").toString());
        
        try {
            // 解析消息内容
            JsonNode messageNode = objectMapper.readTree(message.getPayload());
            
            // 获取发送者ID
            String senderIdStr = messageNode.path("senderId").asText();
            if (senderIdStr != null && !senderIdStr.isEmpty()) {
                Long senderId = Long.parseLong(senderIdStr);
                
                // 查询用户头像
                User user = userMapper.selectById(senderId);
                if (user != null && user.getAvatarUrl() != null) {
                    // 创建新的消息对象，添加头像信息
                    ObjectNode enhancedMessage = (ObjectNode) messageNode;
                    enhancedMessage.put("senderAvatar", user.getAvatarUrl());
                    
                    // 创建新的TextMessage
                    TextMessage enhancedTextMessage = new TextMessage(enhancedMessage.toString());
                    
                    // 广播增强后的消息
                    for (WebSocketSession s : courseSessions.getOrDefault(courseId, Collections.emptySet())) {
                        if (s.isOpen()) s.sendMessage(enhancedTextMessage);
                    }
                    return;
                }
            }
        } catch (Exception e) {
            // 如果处理失败，记录错误但继续使用原始消息
            System.err.println("处理WebSocket消息时出错: " + e.getMessage());
        }
        
        // 如果无法获取头像或处理失败，使用原始消息广播
        for (WebSocketSession s : courseSessions.getOrDefault(courseId, Collections.emptySet())) {
            if (s.isOpen()) s.sendMessage(message);
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        Long courseId = Long.parseLong(session.getAttributes().get("courseId").toString());
        courseSessions.getOrDefault(courseId, new HashSet<>()).remove(session);
    }
}
