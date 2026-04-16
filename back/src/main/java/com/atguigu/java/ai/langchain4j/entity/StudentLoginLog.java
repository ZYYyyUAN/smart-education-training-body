package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;

import java.time.LocalDateTime;

/**
 * 学生登录日志实体类
 */
@Data
@TableName("student_login_log")
public class StudentLoginLog {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 学生ID
     */
    private Long studentId;
    
    /**
     * 登录时间
     */
    private LocalDateTime loginTime;
    
    /**
     * 以下字段在当前数据库表中不存在，为兼容历史设计，标记为 exist = false，避免查询时报错
     */

    /**
     * IP地址
     */
    @TableField(exist = false)
    private String ipAddress;

    /**
     * 用户代理
     */
    @TableField(exist = false)
    private String userAgent;

    /**
     * 登录状态（1-成功，0-失败）
     */
    @TableField(exist = false)
    private Integer status;

    /**
     * 创建时间
     */
    @TableField(exist = false)
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    @TableField(exist = false)
    private LocalDateTime updateTime;
}


