package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.OperationLog;
import jakarta.servlet.http.HttpServletRequest;

import java.util.List;

/**
 * 操作日志服务接口
 */
public interface OperationLogService {
    /**
     * 记录操作日志
     * @param operationLog 操作日志对象
     * @return 是否成功
     */
    boolean saveOperationLog(OperationLog operationLog);

    /**
     * 记录操作日志（简化方法）
     * @param userId 用户ID
     * @param username 用户名
     * @param operationType 操作类型
     * @param tableName 表名
     * @param recordId 记录ID
     * @param operationDesc 操作描述
     * @param request HTTP请求对象
     * @return 是否成功
     */
    boolean logOperation(Long userId, String username, OperationLog.OperationType operationType, 
                        String tableName, Long recordId, String operationDesc, HttpServletRequest request);

    /**
     * 记录操作日志（带状态）
     * @param userId 用户ID
     * @param username 用户名
     * @param operationType 操作类型
     * @param tableName 表名
     * @param recordId 记录ID
     * @param operationDesc 操作描述
     * @param status 操作状态
     * @param errorMessage 错误信息
     * @param request HTTP请求对象
     * @return 是否成功
     */
    boolean logOperation(Long userId, String username, OperationLog.OperationType operationType,
                        String tableName, Long recordId, String operationDesc,
                        OperationLog.Status status, String errorMessage, HttpServletRequest request);

    /**
     * 获取操作日志列表
     * @param limit 限制数量
     * @return 操作日志列表
     */
    List<OperationLog> getRecentLogs(int limit);

    /**
     * 根据用户ID获取操作日志
     * @param userId 用户ID
     * @param limit 限制数量
     * @return 操作日志列表
     */
    List<OperationLog> getLogsByUserId(Long userId, int limit);
}

