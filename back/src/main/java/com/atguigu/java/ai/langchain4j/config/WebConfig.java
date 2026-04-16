//package com.atguigu.java.ai.langchain4j.config;
//
//import com.atguigu.java.ai.langchain4j.intercepter.JwtInterceptor;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
//import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
//
//@Configuration
//public class WebConfig implements WebMvcConfigurer {
//    @Autowired
//    private JwtInterceptor jwtInterceptor;
//
//    @Override
//    public void addInterceptors(InterceptorRegistry registry) {
//        registry.addInterceptor(jwtInterceptor)
//            .addPathPatterns("/api/**") // 拦截路径
//            .excludePathPatterns("/api/login", "/api/register"); // 放行路径
//    }
//}
