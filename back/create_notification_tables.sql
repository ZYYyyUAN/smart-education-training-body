-- 创建私信表
CREATE TABLE IF NOT EXISTS `private_message` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `sender_id` bigint(20) NOT NULL COMMENT '发送者ID',
  `sender_name` varchar(100) NOT NULL COMMENT '发送者姓名',
  `sender_avatar` varchar(500) DEFAULT NULL COMMENT '发送者头像',
  `receiver_id` bigint(20) NOT NULL COMMENT '接收者ID',
  `receiver_name` varchar(100) NOT NULL COMMENT '接收者姓名',
  `subject` varchar(200) NOT NULL COMMENT '私信主题',
  `content` text NOT NULL COMMENT '私信内容',
  `is_read` tinyint(1) DEFAULT 0 COMMENT '是否已读 0-未读 1-已读',
  `is_important` tinyint(1) DEFAULT 0 COMMENT '是否重要 0-普通 1-重要',
  `course_name` varchar(100) DEFAULT NULL COMMENT '课程名称',
  `send_time` datetime NOT NULL COMMENT '发送时间',
  `read_time` datetime DEFAULT NULL COMMENT '阅读时间',
  `message_type` varchar(50) DEFAULT 'private_message' COMMENT '消息类型',
  `status` varchar(50) DEFAULT 'sent' COMMENT '消息状态',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_receiver_id` (`receiver_id`),
  KEY `idx_sender_id` (`sender_id`),
  KEY `idx_send_time` (`send_time`),
  KEY `idx_is_read` (`is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='私信表';

-- 插入测试数据
INSERT INTO `private_message` (`sender_id`, `sender_name`, `receiver_id`, `receiver_name`, `subject`, `content`, `is_read`, `is_important`, `course_name`, `send_time`, `message_type`, `status`) VALUES
(1, '张老师', 101, '张三', '关于作业提交的问题', '同学你好，我看到你的作业还没有提交，请问是遇到了什么困难吗？如果有问题可以随时联系我。', 0, 0, '数据结构', NOW(), 'private_message', 'sent'),
(1, '张老师', 102, '李四', '课程资料更新通知', '本周的课程资料已经更新，包括新的练习题和参考答案，请及时下载查看。', 0, 1, '数据结构', NOW(), 'private_message', 'sent'),
(2, '李助教', 101, '张三', '学术讨论邀请', '下周三下午有一个关于人工智能在教育中应用的学术讨论会，如果你感兴趣的话可以参加。', 1, 0, '数据结构', NOW(), 'private_message', 'sent');
