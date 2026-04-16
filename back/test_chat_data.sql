-- 测试聊天记录数据
-- 确保course_chat_log表已经扩展了相应的字段

-- 插入测试聊天记录
INSERT INTO `course_chat_log` (`course_id`, `sender_id`, `sender_name`, `message`, `message_type`, `sent_at`) VALUES
(1, 1, '张老师', '大家好！欢迎来到课程群聊', 'text', NOW() - INTERVAL 1 HOUR),
(1, 2, '李同学', '老师好！', 'text', NOW() - INTERVAL 30 MINUTE),
(1, 3, '王同学', '大家好！', 'text', NOW() - INTERVAL 15 MINUTE),
(1, 1, '张老师', '今天我们来学习新的知识点', 'text', NOW() - INTERVAL 10 MINUTE),
(1, 2, '李同学', '好的老师！', 'text', NOW() - INTERVAL 5 MINUTE),
(1, 3, '王同学', '😊', 'sticker', NOW() - INTERVAL 3 MINUTE),
(1, 1, '张老师', '有什么问题可以随时问我', 'text', NOW() - INTERVAL 1 MINUTE);

-- 插入一些表情包消息
INSERT INTO `course_chat_log` (`course_id`, `sender_id`, `sender_name`, `message`, `message_type`, `sent_at`) VALUES
(1, 2, '李同学', 'https://via.placeholder.com/100x100/FF6B6B/white?text=😊', 'sticker', NOW() - INTERVAL 2 MINUTE),
(1, 3, '王同学', 'https://via.placeholder.com/100x100/4ECDC4/white?text=😂', 'sticker', NOW() - INTERVAL 1 MINUTE);

-- 插入一些文件消息
INSERT INTO `course_chat_log` (`course_id`, `sender_id`, `sender_name`, `message`, `message_type`, `file_name`, `file_size`, `sent_at`) VALUES
(1, 1, '张老师', 'https://example.com/files/lecture.pdf', 'file', 'lecture.pdf', 1024000, NOW() - INTERVAL 30 SECOND);

-- 插入一些语音消息
INSERT INTO `course_chat_log` (`course_id`, `sender_id`, `sender_name`, `message`, `message_type`, `duration`, `sent_at`) VALUES
(1, 2, '李同学', 'https://example.com/audio/voice1.wav', 'voice', 15, NOW() - INTERVAL 15 SECOND);

-- 查询测试数据
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
