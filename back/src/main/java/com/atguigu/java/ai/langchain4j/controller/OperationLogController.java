package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.entity.OperationLog;
import com.atguigu.java.ai.langchain4j.entity.Result;
import com.atguigu.java.ai.langchain4j.service.OperationLogService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 操作日志控制器
 */
@RestController
@RequestMapping("/xiaozhi/operation-log")
@Slf4j
public class OperationLogController {

    @Autowired
    private OperationLogService operationLogService;

    /**
     * 获取最近的操作日志
     * @param limit 限制数量，默认20
     * @return 操作日志列表
     */
    @GetMapping("/recent")
    public Result<List<OperationLog>> getRecentLogs(@RequestParam(value = "limit", defaultValue = "20") int limit) {
        try {
            log.info("获取最近的操作日志，限制数量: {}", limit);
            List<OperationLog> logs = operationLogService.getRecentLogs(limit);
            log.info("获取操作日志成功，共{}条", logs.size());
            return Result.ok(logs);
        } catch (Exception e) {
            log.error("获取操作日志异常", e);
            return Result.error("获取操作日志失败:" + e.getMessage());
        }
    }

    /**
     * 根据用户ID获取操作日志
     * @param userId 用户ID
     * @param limit 限制数量，默认20
     * @return 操作日志列表
     */
    @GetMapping("/user/{userId}")
    public Result<List<OperationLog>> getLogsByUserId(
            @PathVariable("userId") Long userId,
            @RequestParam(value = "limit", defaultValue = "20") int limit) {
        try {
            log.info("获取用户操作日志: userId={}, limit={}", userId, limit);
            List<OperationLog> logs = operationLogService.getLogsByUserId(userId, limit);
            log.info("获取用户操作日志成功，共{}条", logs.size());
            return Result.ok(logs);
        } catch (Exception e) {
            log.error("获取用户操作日志异常", e);
            return Result.error("获取操作日志失败:" + e.getMessage());
        }
    }
}

