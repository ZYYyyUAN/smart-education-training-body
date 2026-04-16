package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.User;
import com.atguigu.java.ai.langchain4j.mapper.UserMapper;
import com.atguigu.java.ai.langchain4j.service.LoginLogService;
import com.atguigu.java.ai.langchain4j.service.UserService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Autowired
    private LoginLogService loginLogService;

    @Override
    public boolean register(User user) {
        try {
            log.info("开始注册用户: {}", user.getUsername());
            
            // 检查用户名是否已存在
            User exist = lambdaQuery().eq(User::getUsername, user.getUsername()).one();
            if (exist != null) {
                log.warn("用户名已存在: {}, 用户ID: {}", user.getUsername(), exist.getId());
                return false;
            }
            
            log.info("用户名检查通过，开始设置默认值");
            
            // 设置默认值
            if (user.getRole() == null || user.getRole().isEmpty()) {
                user.setRole("student");
                log.info("设置默认角色: student");
            }
            if (user.getSex() == null || user.getSex().isEmpty()) {
                user.setSex("男"); // 默认性别
                log.info("设置默认性别: 男");
            }
            
            // 处理字段映射
            if (user.getReal_name() != null && user.getRealName() == null) {
                user.setRealName(user.getReal_name());
                log.info("字段映射: real_name -> realName: {}", user.getReal_name());
            }
            
            // 处理班级字段映射：userClass -> className
            if (user.getUserClass() != null && user.getClassName() == null) {
                user.setClassName(user.getUserClass());
                log.info("字段映射: userClass -> className: {}", user.getUserClass());
            }

            // 设置默认学校（如果没有提供）
            if (user.getSchool() == null || user.getSchool().isEmpty()) {
                user.setSchool("智教实训通学院"); // 默认学校名称
                log.info("设置默认学校: {}", user.getSchool());
            }
            
            // 设置创建时间
            user.setCreatedAt(java.time.LocalDateTime.now());
            log.info("设置创建时间: {}", user.getCreatedAt());
            
            // 注意：这里应该对密码进行加密，暂时保持明文（生产环境需要加密）
            // user.setPassword(passwordEncoder.encode(user.getPassword()));
            
            log.info("准备保存用户到数据库: {}", user);
            boolean result = save(user);
            
            if (result) {
                log.info("用户注册成功: {}, 用户ID: {}", user.getUsername(), user.getId());
            } else {
                log.error("用户注册失败: {}", user.getUsername());
            }
            return result;
            
        } catch (Exception e) {
            log.error("用户注册异常: {}", user.getUsername(), e);
            return false;
        }
    }

    @Override
    public User login(String username, String password) {
        try {
            log.info("🔍 开始验证用户登录: username=[{}], password_length=[{}]", username, password != null ? password.length() : 0);
            log.info("开始验证用户登录: username={}", username);

            User user = lambdaQuery().eq(User::getUsername, username).one();
            if (user == null) {
                log.warn("❌ 用户不存在: username=[{}]", username);

                // 调试：查看数据库中所有用户名
                List<User> allUsers = lambdaQuery().select(User::getUsername).list();
                log.info("🔍 数据库中现有用户名: {}", allUsers.stream().map(User::getUsername).collect(java.util.stream.Collectors.toList()));
                return null;
            }
            
            log.info("✅ 用户存在: username=[{}], id=[{}], role=[{}]", username, user.getId(), user.getRole());

            // 详细的密码比较调试
            String dbPassword = user.getPassword();
            log.info("🔍 密码比较调试:");
            log.info("   输入密码: [{}] (长度: {})", password, password != null ? password.length() : 0);
            log.info("   数据库密码: [{}] (长度: {})", dbPassword, dbPassword != null ? dbPassword.length() : 0);
            log.info("   密码字节比较: 输入={}, 数据库={}",
                password != null ? java.util.Arrays.toString(password.getBytes()) : "null",
                dbPassword != null ? java.util.Arrays.toString(dbPassword.getBytes()) : "null");
            
            if (user.getPassword().equals(password)) {
                log.info("✅ 密码验证成功: username=[{}]", username);
                return user;
            } else {
                log.warn("❌ 密码验证失败: username=[{}]", username);
                log.warn("   期望密码: [{}]", dbPassword);
                log.warn("   实际密码: [{}]", password);
                return null;
            }
        } catch (Exception e) {
            log.error("❌ 登录验证异常: username=[{}]", username, e);
            return null;
        }
    }

    @Override
    public User loginWithLog(String username, String password) {
        User user = login(username, password);
        if (user != null) {
            // 根据用户角色记录不同的登录日志
            try {
                if ("student".equals(user.getRole())) {
                    loginLogService.recordStudentLogin(user.getId());
                } else if ("teacher".equals(user.getRole())) {
                    loginLogService.recordTeacherLogin(user.getId());
                }
                log.info("用户登录成功并记录日志，用户名: {}, 角色: {}", username, user.getRole());
            } catch (Exception e) {
                log.error("记录登录日志失败，用户名: {}", username, e);
                // 登录日志记录失败不影响登录成功
            }
        }
        return user;
    }

    // 直接暴露底层通用方法（委托给 MyBatis-Plus ServiceImpl）
    @Override
    public User getById(Long id) {
        return super.getById(id);
    }

    @Override
    public boolean updateById(User user) {
        return super.updateById(user);
    }

    @Override
    public boolean removeById(Long id) {
        return super.removeById(id);
    }

    @Override
    public User getByRealName(String realName) {
        if (realName == null || realName.isEmpty()) return null;
        return lambdaQuery().eq(User::getRealName, realName).one();
    }

    @Override
    public java.util.Map<String, String> getAvatarMapByRealNames(java.util.Collection<String> realNames) {
        java.util.Map<String, String> map = new java.util.HashMap<>();
        if (realNames == null || realNames.isEmpty()) return map;
        lambdaQuery().in(User::getRealName, realNames).list().forEach(u -> {
            map.put(u.getRealName(), u.getAvatarUrl());
        });
        return map;
    }
    @Override
    public java.util.List<User> getTeachersByPointsRanking() {
        try {
            log.info("开始查询教师积分排行榜");

            // 查询所有教师用户，按积分降序排列
            java.util.List<User> teachers = lambdaQuery()
                    .eq(User::getRole, "teacher")
                    .orderByDesc(User::getStudyScore)
                    .list();

            log.info("教师积分排行榜查询完成，共{}位教师", teachers.size());
            return teachers;
        } catch (Exception e) {
            log.error("查询教师积分排行榜异常", e);
            return new java.util.ArrayList<>();
        }
    }

    @Override
    public java.util.List<User> getAllUsers() {
        try {
            log.info("开始查询所有用户列表");
            java.util.List<User> users = list();
            log.info("查询所有用户完成，共{}位用户", users.size());
            return users;
        } catch (Exception e) {
            log.error("查询所有用户异常", e);
            return new java.util.ArrayList<>();
        }
    }

    @Override
    public java.util.List<User> getUsersByRole(String role) {
        try {
            return lambdaQuery()
                    .eq(User::getRole, role)
                    .orderByDesc(User::getCreatedAt)
                    .list();
        } catch (Exception e) {
            log.error("查询用户列表异常", e);
            return new java.util.ArrayList<>();
        }
    }
}
