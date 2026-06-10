package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.entity.OperationLog;
import com.atguigu.java.ai.langchain4j.entity.Result;
import com.atguigu.java.ai.langchain4j.entity.User;
import com.atguigu.java.ai.langchain4j.service.OperationLogService;
import com.atguigu.java.ai.langchain4j.service.UserService;
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
        OperationLog.Status status = OperationLog.Status.SUCCESS;
        String errMsg = null;

        try {
            if (userId == null) return Result.error(400, "用户ID必填");
            if (user == null) return Result.error(400, "用户信息不能为空");

            log.info("更新用户: userId={}", userId);

            User existingUser = userService.getById(userId);
            if (existingUser == null) {
                return Result.error(404, "用户不存在");
            }

            user.setId(userId);
            if (user.getReal_name() != null && user.getRealName() == null) user.setRealName(user.getReal_name());
            if (user.getUserClass() != null && user.getClassName() == null) user.setClassName(user.getUserClass());
            if (user.getPassword() == null || user.getPassword().trim().isEmpty()) user.setPassword(null);

            boolean success = userService.updateById(user);
            if (!success) return Result.error("用户更新失败");

            log.info("用户更新成功: userId={}", userId);
            logUserOp(request, userId, OperationLog.OperationType.UPDATE,
                    String.format("更新用户: %s (ID: %d)", existingUser.getUsername(), userId),
                    status, errMsg, existingUser.getId(), existingUser.getUsername());
            return Result.ok("用户更新成功");

        } catch (Exception e) {
            log.error("更新用户异常: userId={}", userId, e);
            logUserOp(request, userId, OperationLog.OperationType.UPDATE, "更新用户失败",
                    OperationLog.Status.FAILED, e.getMessage(), 0L, "系统管理员");
            return Result.error("更新用户失败:" + e.getMessage());
        }
    }

    @DeleteMapping("/{userId}")
    public Result<String> deleteUser(@PathVariable("userId") Long userId, HttpServletRequest request) {
        OperationLog.Status status = OperationLog.Status.SUCCESS;
        String errMsg = null;
        User deletedUser = null;

        try {
            if (userId == null) return Result.error(400, "用户ID必填");
            log.info("删除用户: userId={}", userId);

            User user = userService.getById(userId);
            if (user == null) return Result.error(404, "用户不存在");

            deletedUser = user;
            boolean success = userService.removeById(userId);
            if (!success) return Result.error("用户删除失败");

            log.info("用户删除成功: userId={}, username={}", userId, user.getUsername());
            logUserOp(request, userId, OperationLog.OperationType.DELETE,
                    String.format("删除用户: %s (ID: %d)", user.getUsername(), userId),
                    status, errMsg, 0L, "系统管理员");
            return Result.ok("用户删除成功");

        } catch (Exception e) {
            log.error("删除用户异常: userId={}", userId, e);
            String desc = deletedUser != null
                    ? String.format("删除用户: %s (ID: %d)", deletedUser.getUsername(), userId) : "删除用户失败";
            logUserOp(request, userId, OperationLog.OperationType.DELETE, desc,
                    OperationLog.Status.FAILED, e.getMessage(), 0L, "系统管理员");
            return Result.error("删除用户失败:" + e.getMessage());
        }
    }

    private void logUserOp(HttpServletRequest request, Long userId,
            OperationLog.OperationType opType, String desc,
            OperationLog.Status status, String errMsg,
            Long fallbackUserId, String fallbackUsername) {
        try {
            Long opUserId = getCurrentUserId(request);
            String opUsername = getCurrentUsername(request);
            if (opUserId == null) opUserId = fallbackUserId;
            if (opUsername == null || "未知用户".equals(opUsername)) opUsername = fallbackUsername;
            operationLogService.logOperation(opUserId, opUsername, opType,
                    "user", userId, desc, status, errMsg, request);
        } catch (Exception e) {
            log.warn("记录操作日志失败", e);
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


