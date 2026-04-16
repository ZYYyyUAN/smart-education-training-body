package com.atguigu.java.ai.langchain4j.config;

import com.atguigu.java.ai.langchain4j.entity.Result;
import com.atguigu.java.ai.langchain4j.util.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.MediaType;
import org.springframework.web.servlet.HandlerInterceptor;

import java.nio.charset.StandardCharsets;

public class JwtAuthInterceptor implements HandlerInterceptor {
        private static final String[] WHITELIST = new String[]{
            "/auth/login", "/auth/register", "/auth/test",
            "/captcha", "/captcha/image",
            "/chat", "/chat/save", "/chat/history", "/chat/stats",
            "/v3/api-docs", "/swagger-ui",
            "/api/test",  // 添加测试端点到白名单
            "/ai-reader",  // 添加AI阅读器API到白名单
            "/api/xiaozhi",  // 添加小智API到白名单
            "/xiaozhi"  // 添加小智API到白名单（兼容不同路径格式）
        };

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 允许OPTIONS预检请求通过
        if ("OPTIONS".equals(request.getMethod())) {
            return true;
        }
        
        String path = request.getRequestURI();
        for (String open : WHITELIST) {
            if (path.startsWith(open)) return true;
        }

        // Accept token from Authorization: Bearer xxx or header 'token'
        String auth = request.getHeader("Authorization");
        String token = null;
        if (auth != null && auth.startsWith("Bearer ")) {
            token = auth.substring(7);
        }
        if (token == null) token = request.getHeader("token");
        if (token == null || token.isBlank()) {
            write401(response, "未提供令牌");
            return false;
        }
        try {
            if (JwtUtil.isExpired(token)) {
                write401(response, "令牌已过期");
                return false;
            }
            Claims claims = JwtUtil.parseToken(token);
            request.setAttribute("jwtClaims", claims);
            return true;
        } catch (Exception e) {
            write401(response, "令牌无效");
            return false;
        }
    }

    private void write401(HttpServletResponse response, String message) throws Exception {
        response.setStatus(401);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        Result<String> body = Result.error(401, message);
        new ObjectMapper().writeValue(response.getWriter(), body);
    }
}


