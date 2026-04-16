package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 操作日志实体类
 */
@Data
@TableName("operation_log")
public class OperationLog implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 操作用户ID
     */
    @TableField("user_id")
    private Long userId;

    /**
     * 操作用户名
     */
    private String username;

    /**
     * 操作类型：CREATE(新增)、UPDATE(更新)、DELETE(删除)、QUERY(查询)
     */
    @TableField("operation_type")
    private String operationType;

    /**
     * 操作的表名
     */
    @TableField("table_name")
    private String tableName;

    /**
     * 操作的记录ID
     */
    @TableField("record_id")
    private Long recordId;

    /**
     * 操作描述
     */
    @TableField("operation_desc")
    private String operationDesc;

    /**
     * HTTP请求方法：GET、POST、PUT、DELETE
     */
    @TableField("request_method")
    private String requestMethod;

    /**
     * 请求URL
     */
    @TableField("request_url")
    private String requestUrl;

    /**
     * 请求参数（JSON格式）
     */
    @TableField("request_params")
    private String requestParams;

    /**
     * 操作IP地址
     */
    @TableField("ip_address")
    private String ipAddress;

    /**
     * 用户代理
     */
    @TableField("user_agent")
    private String userAgent;

    /**
     * 操作时间
     */
    @TableField("operation_time")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime operationTime;

    /**
     * 操作状态：SUCCESS(成功)、FAILED(失败)
     */
    private String status;

    /**
     * 错误信息（如果操作失败）
     */
    @TableField("error_message")
    private String errorMessage;

    /**
     * 操作类型枚举
     */
    public enum OperationType {
        CREATE("CREATE", "新增"),
        UPDATE("UPDATE", "更新"),
        DELETE("DELETE", "删除"),
        QUERY("QUERY", "查询");

        private final String code;
        private final String desc;

        OperationType(String code, String desc) {
            this.code = code;
            this.desc = desc;
        }

        public String getCode() {
            return code;
        }

        public String getDesc() {
            return desc;
        }
    }

    /**
     * 操作状态枚举
     */
    public enum Status {
        SUCCESS("SUCCESS", "成功"),
        FAILED("FAILED", "失败");

        private final String code;
        private final String desc;

        Status(String code, String desc) {
            this.code = code;
            this.desc = desc;
        }

        public String getCode() {
            return code;
        }

        public String getDesc() {
            return desc;
        }
    }
}

