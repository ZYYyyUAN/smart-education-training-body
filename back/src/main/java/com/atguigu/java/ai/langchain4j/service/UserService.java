package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.User;

public interface UserService {
    boolean register(User user);
    User login(String username, String password);
    
    /**
     * 用户登录并记录登录日志
     * @param username 用户名
     * @param password 密码
     * @return 用户信息
     */
    User loginWithLog(String username, String password);

    // 直接暴露通用方法，便于简单更新
    User getById(Long id);
    boolean updateById(User user);
    boolean removeById(Long id);

    // 新增：按真实姓名获取用户
    User getByRealName(String realName);
    // 新增：批量按真实姓名获取用户头像映射
    java.util.Map<String, String> getAvatarMapByRealNames(java.util.Collection<String> realNames);
    java.util.List<User> getTeachersByPointsRanking();
    // 获取所有用户列表
    java.util.List<User> getAllUsers();

    /**
     * 根据角色获取用户列表（管理端用）
     */
    java.util.List<User> getUsersByRole(String role);
}
