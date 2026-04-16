package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.entity.PrivateMessage;
import com.atguigu.java.ai.langchain4j.entity.Notification;
import com.atguigu.java.ai.langchain4j.service.PrivateMessageService;
import com.atguigu.java.ai.langchain4j.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/notifications")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3000", "http://127.0.0.1:5173", "http://127.0.0.1:3000"}, allowCredentials = "true")
public class NotificationController {
    
    @Autowired
    private PrivateMessageService privateMessageService;
    
    @Autowired
    private NotificationService notificationService;
    
    /**
     * 发送通知（教师发送给学生的通知将保存为私信）
     */
    @PostMapping("/send")
    public Map<String, Object> sendNotification(@RequestBody Map<String, Object> request) {
        try {
            log.info("收到发送通知请求: {}", request);
            
            // 参数验证
            if (request == null || request.isEmpty()) {
                return createErrorResponse(400, "请求参数不能为空");
            }
            
            String title = (String) request.get("title");
            String content = (String) request.get("content");
            Long senderId = getLongValue(request.get("senderId"));
            String senderName = (String) request.get("senderName");
            Long receiverId = getLongValue(request.get("receiverId"));
            String receiverName = (String) request.get("receiverName");
            
            if (!StringUtils.hasText(title) || !StringUtils.hasText(content)) {
                return createErrorResponse(400, "标题和内容不能为空");
            }
            
            if (senderId == null) {
                return createErrorResponse(400, "发送者ID不能为空");
            }
            
            if (receiverId == null) {
                return createErrorResponse(400, "接收者ID不能为空");
            }
            
            // 教师发送给学生的通知保存为私信
            PrivateMessage privateMessage = new PrivateMessage();
            privateMessage.setSubject(title);
            privateMessage.setContent(content);
            privateMessage.setSenderId(senderId);
            privateMessage.setSenderName(senderName);
            privateMessage.setReceiverId(receiverId);
            privateMessage.setReceiverName(receiverName);
            privateMessage.setIsImportant(getIsImportantValue(request.get("isImportant")));
            privateMessage.setCourseName((String) request.get("courseName"));
            privateMessage.setMessageType("notification");
            privateMessage.setStatus("active");
            privateMessage.setIsRead(0); // 0表示未读
            
            // 发送私信
            boolean success = privateMessageService.sendMessage(privateMessage);
            
            if (success) {
                return createSuccessResponse("通知发送成功", true);
            } else {
                return createErrorResponse(500, "通知发送失败");
            }
            
        } catch (Exception e) {
            log.error("发送通知异常", e);
            return createErrorResponse(500, "发送通知异常: " + e.getMessage());
        }
    }
    
    /**
     * 获取学生的私信列表
     */
    @GetMapping("/student/{studentId}/messages")
    public Map<String, Object> getStudentMessages(@PathVariable("studentId") Long studentId) {
        try {
            log.info("获取学生 {} 的私信列表", studentId);
            
            // 参数验证
            if (studentId == null || studentId <= 0) {
                return createErrorResponse(400, "学生ID不能为空或无效");
            }
            
            // 从数据库查询私信列表
            List<PrivateMessage> messages = privateMessageService.getMessagesByReceiverId(studentId);
            
            return createSuccessResponse("获取私信列表成功", messages);
            
        } catch (Exception e) {
            log.error("获取私信列表异常", e);
            return createErrorResponse(500, "获取私信列表异常: " + e.getMessage());
        }
    }
    
    /**
     * 标记私信为已读
     */
    @PutMapping("/messages/{messageId}/read")
    public Map<String, Object> markMessageAsRead(@PathVariable("messageId") Long messageId) {
        try {
            log.info("标记私信 {} 为已读", messageId);
            
            // 参数验证
            if (messageId == null || messageId <= 0) {
                return createErrorResponse(400, "消息ID不能为空或无效");
            }
            
            // 调用Service标记为已读
            boolean success = privateMessageService.markAsRead(messageId);
            
            if (success) {
                return createSuccessResponse("标记已读成功", true);
            } else {
                return createErrorResponse(500, "标记已读失败");
            }
            
        } catch (Exception e) {
            log.error("标记已读异常", e);
            return createErrorResponse(500, "标记已读异常: " + e.getMessage());
        }
    }
    
    /**
     * 删除私信
     */
    @DeleteMapping("/messages/{messageId}")
    public Map<String, Object> deleteMessage(@PathVariable("messageId") Long messageId) {
        try {
            log.info("删除私信 {}", messageId);
            
            // 调用Service删除私信
            boolean success = privateMessageService.deleteMessage(messageId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("code", success ? 200 : 500);
            response.put("message", success ? "删除私信成功" : "删除私信失败");
            response.put("data", success);
            response.put("timestamp", System.currentTimeMillis());
            
            return response;
            
        } catch (Exception e) {
            log.error("删除私信异常", e);
            Map<String, Object> response = new HashMap<>();
            response.put("code", 500);
            response.put("message", "删除私信异常: " + e.getMessage());
            response.put("data", false);
            response.put("timestamp", System.currentTimeMillis());
            return response;
        }
    }
    
    /**
     * 获取未读私信数量
     */
    @GetMapping("/student/{studentId}/unread-count")
    public Map<String, Object> getUnreadMessageCount(@PathVariable("studentId") Long studentId) {
        try {
            log.info("获取学生 {} 的未读私信数量", studentId);
            
            // 从数据库查询未读私信数量
            Integer unreadCount = privateMessageService.getUnreadCountByReceiverId(studentId);
            
            return createSuccessResponse("获取未读数量成功", unreadCount != null ? unreadCount : 0);
            
        } catch (Exception e) {
            log.error("获取未读数量异常", e);
            return createErrorResponse(500, "获取未读数量异常: " + e.getMessage());
        }
    }
    
    /**
     * 获取学生的通知列表
     */
    @GetMapping("/student/{studentId}/notifications")
    public Map<String, Object> getStudentNotifications(@PathVariable("studentId") Long studentId) {
        try {
            log.info("获取学生 {} 的通知列表", studentId);
            
            // 从数据库查询通知列表
            List<Notification> notifications = notificationService.getUserNotifications(studentId);
            
            return createSuccessResponse("获取通知列表成功", notifications);
            
        } catch (Exception e) {
            log.error("获取通知列表异常", e);
            return createErrorResponse(500, "获取通知列表异常: " + e.getMessage());
        }
    }
    
    /**
     * 标记通知为已读
     */
    @PutMapping("/notifications/{notificationId}/read")
    public Map<String, Object> markNotificationAsRead(@PathVariable("notificationId") Long notificationId, @RequestParam("userId") Long userId) {
        try {
            log.info("标记通知 {} 为已读，用户ID: {}", notificationId, userId);
            
            // 调用Service标记为已读
            boolean success = notificationService.markAsRead(notificationId, userId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("code", success ? 200 : 500);
            response.put("message", success ? "标记已读成功" : "标记已读失败");
            response.put("data", success);
            response.put("timestamp", System.currentTimeMillis());
            
            return response;
            
        } catch (Exception e) {
            log.error("标记通知已读异常", e);
            Map<String, Object> response = new HashMap<>();
            response.put("code", 500);
            response.put("message", "标记通知已读异常: " + e.getMessage());
            response.put("data", false);
            response.put("timestamp", System.currentTimeMillis());
            return response;
        }
    }
    
    /**
     * 获取学生未读通知数量
     */
    @GetMapping("/student/{studentId}/notification-unread-count")
    public Map<String, Object> getUnreadNotificationCount(@PathVariable("studentId") Long studentId) {
        try {
            log.info("获取学生 {} 的未读通知数量", studentId);
            
            // 从数据库查询未读通知数量
            Integer unreadCount = notificationService.getUnreadCountByUserId(studentId);
            
            return createSuccessResponse("获取未读通知数量成功", unreadCount != null ? unreadCount : 0);
            
        } catch (Exception e) {
            log.error("获取未读通知数量异常", e);
            return createErrorResponse(500, "获取未读通知数量异常: " + e.getMessage());
        }
    }
    
    /**
     * 发送私信
     */
    @PostMapping("/messages/send")
    public Map<String, Object> sendMessage(@RequestBody Map<String, Object> request) {
        try {
            log.info("收到发送私信请求: {}", request);
            
            // 参数验证
            if (request == null || request.isEmpty()) {
                return createErrorResponse(400, "请求参数不能为空");
            }
            
            Long senderId = getLongValue(request.get("senderId"));
            String senderName = (String) request.get("senderName");
            String senderAvatar = (String) request.get("senderAvatar");
            Long receiverId = getLongValue(request.get("receiverId"));
            String receiverName = (String) request.get("receiverName");
            String subject = (String) request.get("subject");
            String content = (String) request.get("content");
            
            if (senderId == null || receiverId == null) {
                return createErrorResponse(400, "发送者和接收者ID不能为空");
            }
            
            if (!StringUtils.hasText(content)) {
                return createErrorResponse(400, "消息内容不能为空");
            }
            
            // 创建私信对象
            PrivateMessage message = new PrivateMessage();
            message.setSenderId(senderId);
            message.setSenderName(senderName);
            message.setSenderAvatar(senderAvatar);
            message.setReceiverId(receiverId);
            message.setReceiverName(receiverName);
            message.setSubject(subject);
            message.setContent(content);
            message.setIsImportant(getIsImportantValue(request.get("isImportant")));
            message.setCourseName((String) request.get("courseName"));
            
            // 发送私信
            boolean success = privateMessageService.sendMessage(message);
            
            if (success) {
                return createSuccessResponse("私信发送成功", true);
            } else {
                return createErrorResponse(500, "私信发送失败");
            }
            
        } catch (Exception e) {
            log.error("发送私信异常", e);
            return createErrorResponse(500, "发送私信异常: " + e.getMessage());
        }
    }
    
    /**
     * 创建通知
     */
    @PostMapping("/create")
    public Map<String, Object> createNotification(@RequestBody Map<String, Object> request) {
        try {
            log.info("收到创建通知请求: {}", request);
            
            // 参数验证
            if (request == null || request.isEmpty()) {
                return createErrorResponse(400, "请求参数不能为空");
            }
            
            String title = (String) request.get("title");
            String content = (String) request.get("content");
            Long senderId = getLongValue(request.get("senderId"));
            String senderName = (String) request.get("senderName");
            Long receiverId = getLongValue(request.get("receiverId"));
            String receiverName = (String) request.get("receiverName");
            
            if (!StringUtils.hasText(title) || !StringUtils.hasText(content)) {
                return createErrorResponse(400, "标题和内容不能为空");
            }
            
            // 创建通知对象
            Notification notification = new Notification();
            notification.setTitle(title);
            notification.setContent(content);
            notification.setSenderId(senderId);
            notification.setSenderName(senderName);
            notification.setReceiverId(receiverId);
            notification.setReceiverName(receiverName);
            notification.setNotificationType((String) request.getOrDefault("notificationType", "general"));
            notification.setIsImportant(getIsImportantValue(request.get("isImportant")));
            notification.setCourseName((String) request.get("courseName"));
            
            // 创建通知
            boolean success = notificationService.createNotification(notification);
            
            if (success) {
                return createSuccessResponse("通知创建成功", true);
            } else {
                return createErrorResponse(500, "通知创建失败");
            }
            
        } catch (Exception e) {
            log.error("创建通知异常", e);
            return createErrorResponse(500, "创建通知异常: " + e.getMessage());
        }
    }
    
    /**
     * 删除通知
     */
    @DeleteMapping("/notifications/{notificationId}")
    public Map<String, Object> deleteNotification(@PathVariable("notificationId") Long notificationId) {
        try {
            log.info("删除通知 {}", notificationId);
            
            // 参数验证
            if (notificationId == null || notificationId <= 0) {
                return createErrorResponse(400, "通知ID不能为空或无效");
            }
            
            // 调用Service删除通知
            boolean success = notificationService.deleteNotification(notificationId);
            
            if (success) {
                return createSuccessResponse("删除通知成功", true);
            } else {
                return createErrorResponse(500, "删除通知失败");
            }
            
        } catch (Exception e) {
            log.error("删除通知异常", e);
            return createErrorResponse(500, "删除通知异常: " + e.getMessage());
        }
    }
    
    /**
     * 安全地获取Integer类型的isImportant值
     * 支持Boolean、Integer、String类型转换
     */
    private Integer getIsImportantValue(Object isImportantObj) {
        if (isImportantObj instanceof Boolean) {
            return ((Boolean) isImportantObj) ? 1 : 0;
        } else if (isImportantObj instanceof Integer) {
            return (Integer) isImportantObj;
        } else if (isImportantObj instanceof String) {
            try {
                return Integer.parseInt((String) isImportantObj);
            } catch (NumberFormatException e) {
                return 0;
            }
        }
        return 0; // 默认值
    }
    
    /**
     * 创建成功响应
     */
    private Map<String, Object> createSuccessResponse(String message, Object data) {
        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", message);
        response.put("data", data);
        response.put("timestamp", System.currentTimeMillis());
        return response;
    }
    
    /**
     * 创建错误响应
     */
    private Map<String, Object> createErrorResponse(int code, String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("code", code);
        response.put("message", message);
        response.put("data", null);
        response.put("timestamp", System.currentTimeMillis());
        return response;
    }
    
    /**
     * 安全地获取Long值
     */
    private Long getLongValue(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Long) {
            return (Long) value;
        }
        if (value instanceof Integer) {
            return ((Integer) value).longValue();
        }
        if (value instanceof String) {
            try {
                return Long.parseLong((String) value);
            } catch (NumberFormatException e) {
                return null;
            }
        }
        return null;
    }
}
