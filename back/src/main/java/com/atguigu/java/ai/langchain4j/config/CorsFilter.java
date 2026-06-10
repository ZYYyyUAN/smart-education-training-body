package com.atguigu.java.ai.langchain4j.config;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * CORS过滤器，确保CORS配置优先级最高
 * 注意：此过滤器已被WebMvcConfig中的CORS配置替代，暂时注释掉
 */
// @Component
// @Order(Ordered.HIGHEST_PRECEDENCE)
public class CorsFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletResponse response = (HttpServletResponse) res;
        HttpServletRequest request = (HttpServletRequest) req;

        // 设置CORS头
        // 动态设置允许的源，支持多个源
        String origin = request.getHeader("Origin");
        if (origin != null && (
            origin.equals("http://localhost:5173") || 
            origin.equals("http://localhost:3000") ||
            origin.equals("http://127.0.0.1:5173") ||
            origin.equals("http://127.0.0.1:3000")
        )) {
            response.setHeader("Access-Control-Allow-Origin", origin);
        }
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, HEAD");
        response.setHeader("Access-Control-Max-Age", "3600");
        response.setHeader("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization, token");

        // 对于OPTIONS预检请求，直接返回200
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void init(FilterConfig filterConfig) {
        // 初始化
    }

    @Override
    public void destroy() {
        // 销毁
    }
}
