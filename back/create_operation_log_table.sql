-- 创建操作日志表
-- 用于记录用户的增删改查操作

USE xiaozhi;

-- 创建操作日志表
CREATE TABLE IF NOT EXISTS `operation_log` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '操作用户ID',
    `username` VARCHAR(50) NOT NULL COMMENT '操作用户名',
    `operation_type` VARCHAR(20) NOT NULL COMMENT '操作类型：CREATE(新增)、UPDATE(更新)、DELETE(删除)、QUERY(查询)',
    `table_name` VARCHAR(50) NOT NULL COMMENT '操作的表名',
    `record_id` BIGINT COMMENT '操作的记录ID',
    `operation_desc` VARCHAR(500) COMMENT '操作描述',
    `request_method` VARCHAR(10) COMMENT 'HTTP请求方法：GET、POST、PUT、DELETE',
    `request_url` VARCHAR(500) COMMENT '请求URL',
    `request_params` TEXT COMMENT '请求参数（JSON格式）',
    `ip_address` VARCHAR(50) COMMENT '操作IP地址',
    `user_agent` VARCHAR(500) COMMENT '用户代理',
    `operation_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    `status` VARCHAR(20) DEFAULT 'SUCCESS' COMMENT '操作状态：SUCCESS(成功)、FAILED(失败)',
    `error_message` TEXT COMMENT '错误信息（如果操作失败）',
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_operation_type` (`operation_type`),
    INDEX `idx_table_name` (`table_name`),
    INDEX `idx_operation_time` (`operation_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- 查看表结构
DESCRIBE `operation_log`;

SELECT 'Operation log table created successfully!' as message;

