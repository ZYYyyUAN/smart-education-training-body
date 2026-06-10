package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.entity.Result;
import com.atguigu.java.ai.langchain4j.entity.StudentLoginLog;
import com.atguigu.java.ai.langchain4j.entity.TeacherLoginLog;
import com.atguigu.java.ai.langchain4j.mapper.StudentLoginLogMapper;
import com.atguigu.java.ai.langchain4j.mapper.TeacherLoginLogMapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@Tag(name = "登录记录管理")
@RestController
@RequestMapping("/xiaozhi/login-log")
@Slf4j
public class LoginLogController {

    @Autowired
    private StudentLoginLogMapper studentLoginLogMapper;
    
    @Autowired
    private TeacherLoginLogMapper teacherLoginLogMapper;

    @Operation(summary = "查询学生登录记录")
    @GetMapping("/student")
    public Result<Page<StudentLoginLog>> getStudentLoginLogs(
            @RequestParam(defaultValue = "1") int current,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long studentId) {
        
        Page<StudentLoginLog> page = new Page<>(current, size);
        QueryWrapper<StudentLoginLog> queryWrapper = new QueryWrapper<>();
        
        if (studentId != null) {
            queryWrapper.eq("student_id", studentId);
        }
        
        queryWrapper.orderByDesc("login_time");
        Page<StudentLoginLog> result = studentLoginLogMapper.selectPage(page, queryWrapper);
        
        return Result.ok(result);
    }

    @Operation(summary = "查询老师登录记录")
    @GetMapping("/teacher")
    public Result<Page<TeacherLoginLog>> getTeacherLoginLogs(
            @RequestParam(value = "current", defaultValue = "1") int current,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "teacherId", required = false) Long teacherId) {

        Page<TeacherLoginLog> page = new Page<>(current, size);
        QueryWrapper<TeacherLoginLog> queryWrapper = new QueryWrapper<>();

        if (teacherId != null) {
            queryWrapper.eq("teacher_id", teacherId);
        }

        queryWrapper.orderByDesc("login_time");
        Page<TeacherLoginLog> result = teacherLoginLogMapper.selectPage(page, queryWrapper);

        return Result.ok(result);
    }


    @Operation(summary = "获取最近的学生登录记录")
    @GetMapping("/student/recent")
    public Result<List<StudentLoginLog>> getRecentStudentLogins(
            @RequestParam(defaultValue = "10") int limit) {

        QueryWrapper<StudentLoginLog> queryWrapper = new QueryWrapper<>();
        queryWrapper.orderByDesc("login_time");

        Page<StudentLoginLog> page = new Page<>(1, Math.max(1, limit));
        Page<StudentLoginLog> result = studentLoginLogMapper.selectPage(page, queryWrapper);
        return Result.ok(result.getRecords());
    }

    @Operation(summary = "获取最近的老师登录记录")
    @GetMapping("/teacher/recent")
    public Result<List<TeacherLoginLog>> getRecentTeacherLogins(
            @RequestParam(defaultValue = "10") int limit) {

        QueryWrapper<TeacherLoginLog> queryWrapper = new QueryWrapper<>();
        queryWrapper.orderByDesc("login_time");

        Page<TeacherLoginLog> page = new Page<>(1, Math.max(1, limit));
        Page<TeacherLoginLog> result = teacherLoginLogMapper.selectPage(page, queryWrapper);
        return Result.ok(result.getRecords());
    }

    @Operation(summary = "统计学生周一到周日的登录次数")
    @GetMapping("/student/weekly")
    public Result<Map<String, Integer>> getStudentWeeklyLoginStats() {
        try {
            QueryWrapper<StudentLoginLog> queryWrapper = new QueryWrapper<>();
            // 不限制时间范围，统计所有记录
            List<StudentLoginLog> logs = studentLoginLogMapper.selectList(queryWrapper);
            
            // 初始化周一到周日的计数数组（索引0=周一，1=周二，...，6=周日）
            int[] counts = new int[7];
            
            // 统计每天的登录次数
            for (StudentLoginLog log : logs) {
                if (log.getLoginTime() != null) {
                    int dayOfWeek = log.getLoginTime().getDayOfWeek().getValue(); // 1=Monday, 7=Sunday
                    // 转换为数组索引：Monday(1)->0, Tuesday(2)->1, ..., Sunday(7)->6
                    int index = dayOfWeek - 1;
                    counts[index]++;
                }
            }
            
            // 构建返回结果
            Map<String, Integer> result = new LinkedHashMap<>();
            result.put("周一", counts[0]);
            result.put("周二", counts[1]);
            result.put("周三", counts[2]);
            result.put("周四", counts[3]);
            result.put("周五", counts[4]);
            result.put("周六", counts[5]);
            result.put("周日", counts[6]);
            
            log.info("学生周登录统计: {}", result);
            return Result.ok(result);
        } catch (Exception e) {
            log.error("统计学生周登录次数失败", e);
            return Result.error("统计失败: " + e.getMessage());
        }
    }

    @Operation(summary = "统计教师周一到周日的登录次数")
    @GetMapping("/teacher/weekly")
    public Result<Map<String, Integer>> getTeacherWeeklyLoginStats() {
        try {
            QueryWrapper<TeacherLoginLog> queryWrapper = new QueryWrapper<>();
            // 不限制时间范围，统计所有记录
            List<TeacherLoginLog> logs = teacherLoginLogMapper.selectList(queryWrapper);
            
            // 初始化周一到周日的计数数组（索引0=周一，1=周二，...，6=周日）
            int[] counts = new int[7];
            
            // 统计每天的登录次数
            for (TeacherLoginLog log : logs) {
                if (log.getLoginTime() != null) {
                    int dayOfWeek = log.getLoginTime().getDayOfWeek().getValue(); // 1=Monday, 7=Sunday
                    // 转换为数组索引：Monday(1)->0, Tuesday(2)->1, ..., Sunday(7)->6
                    int index = dayOfWeek - 1;
                    counts[index]++;
                }
            }
            
            // 构建返回结果
            Map<String, Integer> result = new LinkedHashMap<>();
            result.put("周一", counts[0]);
            result.put("周二", counts[1]);
            result.put("周三", counts[2]);
            result.put("周四", counts[3]);
            result.put("周五", counts[4]);
            result.put("周六", counts[5]);
            result.put("周日", counts[6]);
            
            log.info("教师周登录统计: {}", result);
            return Result.ok(result);
        } catch (Exception e) {
            log.error("统计教师周登录次数失败", e);
            return Result.error("统计失败: " + e.getMessage());
        }
    }
}
