-- 扩展 course_chat_log 表以支持不同类型的消息
-- 添加新字段来支持消息类型、文件名、文件大小、语音时长等

ALTER TABLE `course_chat_log` 
ADD COLUMN `message_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'text' COMMENT '消息类型：text(文本)、sticker(表情包)、image(图片)、file(文件)、voice(语音)' AFTER `message`,
ADD COLUMN `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件名' AFTER `message_type`,
ADD COLUMN `file_size` bigint NULL DEFAULT NULL COMMENT '文件大小(字节)' AFTER `file_name`,
ADD COLUMN `duration` int NULL DEFAULT NULL COMMENT '语音时长(秒)' AFTER `file_size`,
ADD COLUMN `sender_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '发送者姓名' AFTER `sender_id`;

-- 更新现有记录的消息类型
UPDATE `course_chat_log` SET `message_type` = 'text' WHERE `message_type` IS NULL OR `message_type` = '';

-- 添加索引以提高查询性能
CREATE INDEX `idx_course_sent_at` ON `course_chat_log` (`course_id`, `sent_at` DESC);
CREATE INDEX `idx_message_type` ON `course_chat_log` (`message_type`);

-- 示例数据（可选）
INSERT INTO `course_chat_log` (`course_id`, `sender_id`, `sender_name`, `message`, `message_type`, `sent_at`) VALUES
(1, 1, '张老师', '大家好！欢迎来到课程群聊', 'text', NOW() - INTERVAL 1 HOUR),
(1, 2, '李同学', '老师好！', 'text', NOW() - INTERVAL 30 MINUTE),
(1, 3, '王同学', '大家好！', 'text', NOW() - INTERVAL 15 MINUTE);
