-- 聊天记录数据库初始化脚本
-- 请确保在xiaozhi数据库中执行

USE xiaozhi;

-- 检查course_chat_log表是否存在，如果不存在则创建
CREATE TABLE IF NOT EXISTS `course_chat_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_id` bigint NOT NULL,
  `sender_id` bigint NOT NULL,
  `sender_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '发送者姓名',
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `message_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'text' COMMENT '消息类型：text(文本)、sticker(表情包)、image(图片)、file(文件)、voice(语音)',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件名',
  `file_size` bigint NULL DEFAULT NULL COMMENT '文件大小(字节)',
  `duration` int NULL DEFAULT NULL COMMENT '语音时长(秒)',
  `sent_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_id`(`course_id` ASC) USING BTREE,
  INDEX `idx_sender_id`(`sender_id` ASC) USING BTREE,
  INDEX `idx_course_sent_at`(`course_id`, `sent_at` DESC) USING BTREE,
  INDEX `idx_message_type`(`message_type`) USING BTREE,
  CONSTRAINT `fk_course_chat_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_course_chat_sender` FOREIGN KEY (`sender_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- 如果表已存在，添加缺失的字段
ALTER TABLE `course_chat_log` 
ADD COLUMN IF NOT EXISTS `message_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'text' COMMENT '消息类型：text(文本)、sticker(表情包)、image(图片)、file(文件)、voice(语音)' AFTER `message`,
ADD COLUMN IF NOT EXISTS `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件名' AFTER `message_type`,
ADD COLUMN IF NOT EXISTS `file_size` bigint NULL DEFAULT NULL COMMENT '文件大小(字节)' AFTER `file_name`,
ADD COLUMN IF NOT EXISTS `duration` int NULL DEFAULT NULL COMMENT '语音时长(秒)' AFTER `file_size`,
ADD COLUMN IF NOT EXISTS `sender_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '发送者姓名' AFTER `sender_id`;

-- 添加索引（如果不存在）
CREATE INDEX IF NOT EXISTS `idx_course_sent_at` ON `course_chat_log` (`course_id`, `sent_at` DESC);
CREATE INDEX IF NOT EXISTS `idx_message_type` ON `course_chat_log` (`message_type`);

-- 更新现有记录的消息类型
UPDATE `course_chat_log` SET `message_type` = 'text' WHERE `message_type` IS NULL OR `message_type` = '';

-- 插入一些测试数据
INSERT INTO `course_chat_log` (`course_id`, `sender_id`, `sender_name`, `message`, `message_type`, `sent_at`) VALUES
(1, 1, '张老师', '大家好！欢迎来到课程群聊', 'text', NOW() - INTERVAL 1 HOUR),
(1, 2, '李同学', '老师好！', 'text', NOW() - INTERVAL 30 MINUTE),
(1, 3, '王同学', '大家好！', 'text', NOW() - INTERVAL 15 MINUTE),
(1, 1, '张老师', '今天我们来学习新的知识点', 'text', NOW() - INTERVAL 10 MINUTE),
(1, 2, '李同学', '好的老师！', 'text', NOW() - INTERVAL 5 MINUTE),
(1, 3, '王同学', '😊', 'sticker', NOW() - INTERVAL 3 MINUTE),
(1, 1, '张老师', '有什么问题可以随时问我', 'text', NOW() - INTERVAL 1 MINUTE);

-- 显示表结构
DESCRIBE course_chat_log;

-- 显示测试数据
SELECT 
    id,
    course_id,
    sender_name,
    message,
    message_type,
    file_name,
    file_size,
    duration,
    sent_at
FROM course_chat_log 
WHERE course_id = 1 
ORDER BY sent_at DESC;
