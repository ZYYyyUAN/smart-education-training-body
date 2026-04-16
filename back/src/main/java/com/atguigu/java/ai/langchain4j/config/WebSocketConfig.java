package com.atguigu.java.ai.langchain4j.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

/**
 * WebSocket配置类
 * 配置群聊和音频WebSocket端点
 */
@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    @Autowired
    private GroupChatHandler groupChatHandler;
    
    @Autowired
    private AudioWebSocketHandler audioWebSocketHandler;
    
    @Autowired
    private CourseHandshakeInterceptor courseHandshakeInterceptor;

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        // 注册群聊WebSocket处理器
        registry.addHandler(groupChatHandler, "/ws/chat")
                .addInterceptors(courseHandshakeInterceptor)
                .setAllowedOrigins("*"); // 允许所有来源，生产环境应该限制具体域名
        
        // 注册音频WebSocket处理器
        registry.addHandler(audioWebSocketHandler, "/ws/audio")
                .setAllowedOrigins("*"); // 允许所有来源，生产环境应该限制具体域名
    }
}
