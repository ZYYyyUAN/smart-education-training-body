package com.atguigu.java.ai.langchain4j.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Web MVC配置类，统一管理CORS配置和拦截器
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns("http://localhost:*", "http://127.0.0.1:*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD")
                .allowedHeaders("Origin", "X-Requested-With", "Content-Type", "Accept", "Authorization", "token")
                .allowCredentials(true)
                .maxAge(3600);
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new JwtAuthInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns(
                    "/auth/login", "/auth/register", "/auth/test",
                    "/captcha", "/captcha/image",
                    "/chat", "/chat/save", "/chat/history", "/chat/stats",
                    "/user/*/avatar", "/user/avatar", "/user/avatars", "/user/profile",
                    "/v3/api-docs/**", "/swagger-ui/**", "/doc.html", "/webjars/**",
                    "/api/test/**",  // 添加测试端点到排除路径
                    "/error", "/favicon.ico"
                );
    }
}


