package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.entity.OperationLog;
import com.atguigu.java.ai.langchain4j.entity.Result;
import com.atguigu.java.ai.langchain4j.entity.User;
import com.atguigu.java.ai.langchain4j.service.OperationLogService;
import com.atguigu.java.ai.langchain4j.service.UserService;
import com.atguigu.java.ai.langchain4j.util.JwtUtil;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import io.swagger.v3.oas.annotations.Operation;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/xiaozhi/user")
@Slf4j
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private OperationLogService operationLogService;

    @PostMapping("/avatar")
    public Result<String> updateAvatar(@RequestBody UpdateAvatarRequest req) {
        try {
            if (req == null || req.getUserId() == null || req.getAvatarUrl() == null || req.getAvatarUrl().isBlank()) {
                return Result.error(400, "参数不完整");
            }
            User u = userService.getById(req.getUserId());
            if (u == null) return Result.error(404, "用户不存在");
            u.setAvatarUrl(req.getAvatarUrl());
            boolean ok = userService.updateById(u);
            return ok ? Result.ok("更新成功") : Result.error("更新失败");
        } catch (Exception e) {
            log.error("更新头像异常", e);
            return Result.error("更新头像失败:" + e.getMessage());
        }
    }

    @Data
    public static class UpdateAvatarRequest {
        private Long userId;
        private String avatarUrl;
    }

    @GetMapping("/avatar")
    public Result<String> getAvatarByUserId(@RequestParam("userId") Long userId) {
        try {
            if (userId == null) return Result.error(400, "userId必填");
            User u = userService.getById(userId);
            if (u == null) return Result.error(404, "用户不存在");
            return Result.ok(u.getAvatarUrl());
        } catch (Exception e) {
            log.error("查询头像异常", e);
            return Result.error("查询失败:" + e.getMessage());
        }
    }

    @GetMapping("/{userId}/avatar")
    public Result<AvatarResponse> getUserAvatar(@PathVariable("userId") Long userId) {
        try {
            if (userId == null) return Result.error(400, "userId必填");
            User u = userService.getById(userId);
            if (u == null) return Result.error(404, "用户不存在");
            
            AvatarResponse response = new AvatarResponse();
            response.setAvatarUrl(u.getAvatarUrl());
            response.setUserId(u.getId());
            response.setUserName(u.getRealName());
            
            return Result.ok(response);
        } catch (Exception e) {
            log.error("查询用户头像异常", e);
            return Result.error("查询失败:" + e.getMessage());
        }
    }

    @Data
    public static class AvatarResponse {
        private Long userId;
        private String userName;
        private String avatarUrl;
    }

    @GetMapping("/profile")
    public Result<UserProfileResponse> getCurrentUserProfile(@RequestParam(value = "userId", required = false) Long userId) {
        try {
            // 如果传入了userId参数，使用传入的userId
            // 否则从JWT token中获取当前用户ID（这里暂时使用参数）
            Long currentUserId = userId;
            
            if (currentUserId == null) {
                return Result.error(400, "缺少用户ID参数");
            }
            
            User user = userService.getById(currentUserId);
            if (user == null) {
                return Result.error(404, "用户不存在");
            }
            
            UserProfileResponse response = new UserProfileResponse();
            response.setUserId(user.getId());
            response.setUsername(user.getUsername());
            response.setRealName(user.getRealName());
            response.setRole(user.getRole());
            response.setAvatarUrl(user.getAvatarUrl());
            
            return Result.ok(response);
        } catch (Exception e) {
            log.error("获取用户信息异常", e);
            return Result.error("获取用户信息失败:" + e.getMessage());
        }
    }


    @GetMapping("/{userId}/points")
    public Result<Integer> getUserPoints(@PathVariable("userId") Long userId) {
        try {
            if (userId == null) return Result.error(400, "userId必填");
            User user = userService.getById(userId);
            if (user == null) return Result.error(404, "用户不存在");

            Integer points = user.getStudyScore() != null ? user.getStudyScore() : 0;
            log.info("获取用户积分: userId={}, points={}", userId, points);
            return Result.ok(points);
        } catch (Exception e) {
            log.error("查询用户积分异常", e);
            return Result.error("查询失败:" + e.getMessage());
        }
    }

    @Data
    public static class UserProfileResponse {
        private Long userId;
        private String username;
        private String realName;
        private String role;
        private String avatarUrl;
    }

    @GetMapping("/avatars")
    public Result<java.util.Map<String, String>> getAvatarsByNames(@RequestParam("names") String names) {
        try {
            if (names == null || names.isBlank()) return Result.ok(java.util.Collections.emptyMap());
            java.util.Set<String> set = new java.util.HashSet<>();
            for (String n : names.split(",")) {
                String s = n.trim();
                if (!s.isEmpty()) set.add(s);
            }
            java.util.Map<String, String> map = userService.getAvatarMapByRealNames(set);
            return Result.ok(map);
        } catch (Exception e) {
            log.error("批量查询头像异常", e);
            return Result.error("查询失败:" + e.getMessage());
        }
    }

    @GetMapping("/{userId}")
    public Result<User> getUserById(@PathVariable("userId") Long userId) {
        try {
            if (userId == null) return Result.error(400, "userId必填");
            User user = userService.getById(userId);
            if (user == null) return Result.error(404, "用户不存在");
            return Result.ok(user);
        } catch (Exception e) {
            log.error("查询用户信息异常", e);
            return Result.error("查询失败:" + e.getMessage());
        }
    }
    @GetMapping("/teachers/ranking")
    public Result<List<User>> getTeachersRanking() {
        try {
            log.info("获取教师积分排行榜");

            // 获取所有教师用户，按积分降序排列
            List<User> teachers = userService.getTeachersByPointsRanking();

            log.info("教师积分排行榜查询成功，共{}位教师", teachers.size());
            return Result.ok(teachers);
        } catch (Exception e) {
            log.error("查询教师积分排行榜异常", e);
            return Result.error("查询失败:" + e.getMessage());
        }
    }

    @GetMapping("/list")
    public Result<List<User>> getAllUsers(HttpServletRequest request) {
        try {
            log.info("获取所有用户列表");
            List<User> users = userService.getAllUsers();
            log.info("获取所有用户列表成功，共{}位用户", users.size());

            // 查询操作不记录日志

            return Result.ok(users);
        } catch (Exception e) {
            log.error("获取所有用户列表异常", e);
            return Result.error("查询失败:" + e.getMessage());
        }
    }

    @PutMapping("/{userId}")
    public Result<String> updateUser(@PathVariable("userId") Long userId, @RequestBody User user, HttpServletRequest request) {
        OperationLog.Status logStatus = OperationLog.Status.SUCCESS;
        String errorMessage = null;

        try {
            if (userId == null) {
                return Result.error(400, "用户ID必填");
            }
            if (user == null) {
                return Result.error(400, "用户信息不能为空");
            }

            log.info("更新用户: userId={}", userId);

            // 检查用户是否存在
            User existingUser = userService.getById(userId);
            if (existingUser == null) {
                logStatus = OperationLog.Status.FAILED;
                errorMessage = "用户不存在";
                return Result.error(404, errorMessage);
            }

            // 设置用户ID
            user.setId(userId);

            // 处理字段映射：real_name -> realName
            if (user.getReal_name() != null && user.getRealName() == null) {
                user.setRealName(user.getReal_name());
            }

            // 处理班级字段映射：userClass -> className
            if (user.getUserClass() != null && user.getClassName() == null) {
                user.setClassName(user.getUserClass());
            }

            // 如果密码为空，不更新密码
            if (user.getPassword() == null || user.getPassword().trim().isEmpty()) {
                user.setPassword(null); // 设置为null，MyBatis-Plus会忽略null字段
            }

            // 更新用户信息
            boolean success = userService.updateById(user);

            if (success) {
                log.info("用户更新成功: userId={}", userId);

                // 记录操作日志
                try {
                    Long currentUserId = getCurrentUserId(request);
                    String username = getCurrentUsername(request);
                    log.info("🔍 获取当前用户信息: userId={}, username={}", currentUserId, username);

                    // 如果无法获取当前用户信息，使用被操作的用户信息
                    if (currentUserId == null) {
                        currentUserId = existingUser.getId();
                        log.info("⚠️ 无法获取操作者ID，使用被操作用户ID: {}", currentUserId);
                    }
                    if (username == null || "未知用户".equals(username)) {
                        username = existingUser.getUsername();
                        log.info("⚠️ 无法获取操作者用户名，使用被操作用户名: {}", username);
                    }
                    String desc = String.format("更新用户: %s (ID: %d)", existingUser.getUsername(), userId);
                    log.info("📝 准备记录操作日志: userId={}, username={}, desc={}", currentUserId, username, desc);
                    boolean logResult = operationLogService.logOperation(currentUserId, username, OperationLog.OperationType.UPDATE,
                            "user", userId, desc, logStatus, errorMessage, request);
                    log.info("📝 操作日志记录结果: {}", logResult ? "成功" : "失败");
                } catch (Exception e) {
                    log.error("❌ 记录操作日志失败", e);
                }

                return Result.ok("用户更新成功");
            } else {
                log.warn("用户更新失败: userId={}", userId);
                logStatus = OperationLog.Status.FAILED;
                errorMessage = "更新失败";
                return Result.error("用户更新失败");
            }
        } catch (Exception e) {
            log.error("更新用户异常: userId={}", userId, e);
            logStatus = OperationLog.Status.FAILED;
            errorMessage = e.getMessage();

            // 记录失败的操作日志
            try {
                Long currentUserId = getCurrentUserId(request);
                String username = getCurrentUsername(request);
                if (currentUserId == null) {
                    currentUserId = 0L;
                }
                if (username == null || "未知用户".equals(username)) {
                    username = "系统管理员";
                }
                operationLogService.logOperation(currentUserId, username, OperationLog.OperationType.UPDATE,
                        "user", userId, "更新用户失败", logStatus, errorMessage, request);
            } catch (Exception ex) {
                log.warn("记录操作日志失败", ex);
            }

            return Result.error("更新用户失败:" + e.getMessage());
        }
    }

    @DeleteMapping("/{userId}")
    public Result<String> deleteUser(@PathVariable("userId") Long userId, HttpServletRequest request) {
        OperationLog.Status logStatus = OperationLog.Status.SUCCESS;
        String errorMessage = null;
        User deletedUser = null;

        try {
            if (userId == null) {
                return Result.error(400, "用户ID必填");
            }

            log.info("删除用户: userId={}", userId);

            // 检查用户是否存在
            User user = userService.getById(userId);
            if (user == null) {
                logStatus = OperationLog.Status.FAILED;
                errorMessage = "用户不存在";
                return Result.error(404, errorMessage);
            }

            deletedUser = user; // 保存用户信息用于日志

            // 删除用户
            boolean success = userService.removeById(userId);

            if (success) {
                log.info("用户删除成功: userId={}, username={}", userId, user.getUsername());

                // 记录操作日志
                try {
                    Long currentUserId = getCurrentUserId(request);
                    String username = getCurrentUsername(request);
                    log.info("🔍 获取当前用户信息: userId={}, username={}", currentUserId, username);

                    // 如果无法获取当前用户信息，使用默认值
                    if (currentUserId == null) {
                        // 无法获取操作者ID，记录为系统操作
                        currentUserId = 0L;
                        log.info("⚠️ 无法获取操作者ID，使用默认值: {}", currentUserId);
                    }
                    if (username == null || "未知用户".equals(username)) {
                        username = "系统管理员";
                        log.info("⚠️ 无法获取操作者用户名，使用默认值: {}", username);
                    }
                    String desc = String.format("删除用户: %s (ID: %d)", user.getUsername(), userId);
                    log.info("📝 准备记录操作日志: userId={}, username={}, desc={}", currentUserId, username, desc);
                    boolean logResult = operationLogService.logOperation(currentUserId, username, OperationLog.OperationType.DELETE,
                            "user", userId, desc, logStatus, errorMessage, request);
                    log.info("📝 操作日志记录结果: {}", logResult ? "成功" : "失败");
                } catch (Exception e) {
                    log.error("❌ 记录操作日志失败", e);
                }

                return Result.ok("用户删除成功");
            } else {
                log.warn("用户删除失败: userId={}", userId);
                logStatus = OperationLog.Status.FAILED;
                errorMessage = "删除失败";
                return Result.error("用户删除失败");
            }
        } catch (Exception e) {
            log.error("删除用户异常: userId={}", userId, e);
            logStatus = OperationLog.Status.FAILED;
            errorMessage = e.getMessage();

            // 记录失败的操作日志
            try {
                Long currentUserId = getCurrentUserId(request);
                String username = getCurrentUsername(request);
                if (currentUserId == null) {
                    currentUserId = 0L;
                }
                if (username == null || "未知用户".equals(username)) {
                    username = "系统管理员";
                }
                String desc = deletedUser != null ?
                    String.format("删除用户: %s (ID: %d)", deletedUser.getUsername(), userId) :
                    "删除用户失败";
                operationLogService.logOperation(currentUserId, username, OperationLog.OperationType.DELETE,
                        "user", userId, desc, logStatus, errorMessage, request);
            } catch (Exception ex) {
                log.warn("记录操作日志失败", ex);
            }

            return Result.error("删除用户失败:" + e.getMessage());
        }
    }

    /**
     * 从请求中获取当前用户ID
     */
    private Long getCurrentUserId(HttpServletRequest request) {
        try {
            Claims claims = (Claims) request.getAttribute("jwtClaims");
            if (claims != null) {
                // 尝试从subject获取
                String userIdStr = claims.getSubject();
                if (userIdStr != null && !userIdStr.isEmpty()) {
                    try {
                        return Long.parseLong(userIdStr);
                    } catch (NumberFormatException e) {
                        // subject不是数字，继续尝试其他方式
                    }
                }
                // 尝试从claims中的uid获取
                Object uid = claims.get("uid");
                if (uid != null) {
                    if (uid instanceof Long) {
                        return (Long) uid;
                    } else if (uid instanceof Integer) {
                        return ((Integer) uid).longValue();
                    } else if (uid instanceof String) {
                        return Long.parseLong((String) uid);
                    }
                }
            }
        } catch (Exception e) {
            log.debug("获取当前用户ID失败", e);
        }
        return null;
    }

    /**
     * 从请求中获取当前用户名
     */
    private String getCurrentUsername(HttpServletRequest request) {
        try {
            Claims claims = (Claims) request.getAttribute("jwtClaims");
            if (claims != null) {
                String username = claims.get("username", String.class);
                if (username != null && !username.isEmpty()) {
                    return username;
                }
            }
        } catch (Exception e) {
            log.debug("获取当前用户名失败", e);
        }
        return "未知用户";
    }

    @GetMapping("/list-by-role")
    @Operation(summary = "根据角色获取用户列表")
    public Result<List<User>> getUsersByRole(@RequestParam("role") String role) {
        try {
            List<User> users = userService.getUsersByRole(role);
            return Result.ok(users);
        } catch (Exception e) {
            log.error("查询用户列表异常", e);
            return Result.error("查询失败:" + e.getMessage());
        }
    }
}


