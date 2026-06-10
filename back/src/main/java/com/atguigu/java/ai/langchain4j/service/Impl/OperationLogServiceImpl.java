package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.OperationLog;
import com.atguigu.java.ai.langchain4j.mapper.OperationLogMapper;
import com.atguigu.java.ai.langchain4j.service.OperationLogService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 操作日志服务实现类
 */
@Slf4j
@Service
public class OperationLogServiceImpl extends ServiceImpl<OperationLogMapper, OperationLog> implements OperationLogService {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public boolean saveOperationLog(OperationLog operationLog) {
        try {
            if (operationLog == null) {
                log.warn("操作日志对象为null，无法保存");
                return false;
            }
            
            if (operationLog.getOperationTime() == null) {
                operationLog.setOperationTime(LocalDateTime.now());
            }
            if (operationLog.getStatus() == null) {
                operationLog.setStatus(OperationLog.Status.SUCCESS.getCode());
            }
            if (operationLog.getUserId() == null) {
                operationLog.setUserId(0L);
            }
            if (operationLog.getUsername() == null || operationLog.getUsername().isEmpty()) {
                operationLog.setUsername("系统管理员");
            }
            
            log.info("💾 保存操作日志: userId={}, username={}, operationType={}, tableName={}, desc={}", 
                    operationLog.getUserId(), operationLog.getUsername(), 
                    operationLog.getOperationType(), operationLog.getTableName(), 
                    operationLog.getOperationDesc());
            
            boolean result = save(operationLog);
            log.info("💾 操作日志保存结果: {}", result ? "成功" : "失败");
            return result;
        } catch (Exception e) {
            log.error("❌ 保存操作日志失败", e);
            return false;
        }
    }

    @Override
    public boolean logOperation(Long userId, String username, OperationLog.OperationType operationType,
                                String tableName, Long recordId, String operationDesc, HttpServletRequest request) {
        return logOperation(userId, username, operationType, tableName, recordId, operationDesc,
                OperationLog.Status.SUCCESS, null, request);
    }

    @Override
    public boolean logOperation(Long userId, String username, OperationLog.OperationType operationType,
                                String tableName, Long recordId, String operationDesc,
                                OperationLog.Status status, String errorMessage, HttpServletRequest request) {
        try {
            // 使用不同于 @Slf4j 日志变量名的本地变量，避免名称冲突
            OperationLog opLog = new OperationLog();
            // 如果userId为null，设置为0表示系统操作
            opLog.setUserId(userId != null ? userId : 0L);
            // 如果username为null或空，使用默认值
            opLog.setUsername(username != null && !username.isEmpty() ? username : "系统管理员");
            opLog.setOperationType(operationType.getCode());
            opLog.setTableName(tableName);
            opLog.setRecordId(recordId);
            opLog.setOperationDesc(operationDesc);
            opLog.setStatus(status != null ? status.getCode() : OperationLog.Status.SUCCESS.getCode());
            opLog.setErrorMessage(errorMessage);
            opLog.setOperationTime(LocalDateTime.now());

            if (request != null) {
                opLog.setRequestMethod(request.getMethod());
                opLog.setRequestUrl(request.getRequestURI());
                opLog.setIpAddress(getClientIpAddress(request));
                opLog.setUserAgent(request.getHeader("User-Agent"));

                // 获取请求参数
                try {
                    Map<String, String[]> parameterMap = request.getParameterMap();
                    if (parameterMap != null && !parameterMap.isEmpty()) {
                        Map<String, Object> params = new HashMap<>();
                        parameterMap.forEach((key, values) -> {
                            if (values.length == 1) {
                                params.put(key, values[0]);
                            } else {
                                params.put(key, values);
                             }
                        });
                        opLog.setRequestParams(objectMapper.writeValueAsString(params));
                    }
                } catch (Exception e) {
                    log.warn("获取请求参数失败", e);
                }
            }

            return saveOperationLog(opLog);
        } catch (Exception e) {
            log.error("记录操作日志失败", e);
            return false;
        }
    }

    @Override
    public List<OperationLog> getRecentLogs(int limit) {
        try {
            LambdaQueryWrapper<OperationLog> wrapper = new LambdaQueryWrapper<>();
            wrapper.orderByDesc(OperationLog::getOperationTime);
            Page<OperationLog> page = new Page<>(1, Math.max(1, limit));
            Page<OperationLog> result = page(page, wrapper);
            return result.getRecords();
        } catch (Exception e) {
            log.error("获取操作日志失败", e);
            return List.of();
        }
    }

    @Override
    public List<OperationLog> getLogsByUserId(Long userId, int limit) {
        try {
            LambdaQueryWrapper<OperationLog> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(OperationLog::getUserId, userId);
            wrapper.orderByDesc(OperationLog::getOperationTime);
            Page<OperationLog> page = new Page<>(1, Math.max(1, limit));
            Page<OperationLog> result = page(page, wrapper);
            return result.getRecords();
        } catch (Exception e) {
            log.error("根据用户ID获取操作日志失败", e);
            return List.of();
        }
    }

    /**
     * 获取客户端IP地址
     */
    private String getClientIpAddress(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        // 如果是多级代理，取第一个IP
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }
}

