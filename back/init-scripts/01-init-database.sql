/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306_2
 Source Server Type    : MySQL
 Source Server Version : 80036
 Source Host           : localhost:3306
 Source Schema         : xiaozhi

 Target Server Type    : MySQL
 Target Server Version : 80036
 File Encoding         : 65001

 Date: 25/09/2025 11:24:16
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for answer
-- ----------------------------
DROP TABLE IF EXISTS `answer`;
CREATE TABLE `answer`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `user_id` int NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `question_id`(`question_id` ASC) USING BTREE,
  CONSTRAINT `answer_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `question` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of answer
-- ----------------------------
INSERT INTO `answer` VALUES (1, 1, 1, '使用 v-model 实现组件与数据的绑定', '2025-08-06 22:51:19');
INSERT INTO `answer` VALUES (2, 1, 2, '原理是语法糖 + 响应式', '2025-08-06 22:51:19');
INSERT INTO `answer` VALUES (3, 2, 2, 'created、mounted、updated、destroyed', '2025-08-06 22:51:19');
INSERT INTO `answer` VALUES (4, 1, 1, '有点难', '2025-08-06 23:23:02');
INSERT INTO `answer` VALUES (5, 3, 1, '快来回我', '2025-08-06 23:23:06');
INSERT INTO `answer` VALUES (6, 1, 1, '有人回复我吗', '2025-08-06 23:23:09');
INSERT INTO `answer` VALUES (7, 1, 1, '6', '2025-08-06 23:23:12');
INSERT INTO `answer` VALUES (8, 5, 1, '我也不知道', '2025-08-07 00:17:11');
INSERT INTO `answer` VALUES (9, 1, 1, '有点难', '2025-08-07 10:00:38');
INSERT INTO `answer` VALUES (10, 1, 1, '6666', '2025-08-07 14:49:14');
INSERT INTO `answer` VALUES (11, 2, 1, '不知道', '2025-08-07 14:49:25');
INSERT INTO `answer` VALUES (12, 6, 1, 'nihao', '2025-08-07 18:22:16');
INSERT INTO `answer` VALUES (13, 7, 1, 'fdsfaf', '2025-08-24 19:22:44');
INSERT INTO `answer` VALUES (14, 8, 1, '神经病', '2025-08-28 12:36:36');
INSERT INTO `answer` VALUES (15, 8, 1, '666', '2025-09-08 13:49:39');
INSERT INTO `answer` VALUES (16, 8, 1, '你好', '2025-09-18 13:19:11');
INSERT INTO `answer` VALUES (17, 2, 1, '111', '2025-09-18 16:19:16');
INSERT INTO `answer` VALUES (18, 2, 1, '111', '2025-09-18 16:23:05');
INSERT INTO `answer` VALUES (19, 2, 1, '111', '2025-09-18 16:25:39');
INSERT INTO `answer` VALUES (20, 2, 1, '1111', '2025-09-18 16:29:31');

-- ----------------------------
-- Table structure for assignment
-- ----------------------------
DROP TABLE IF EXISTS `assignment`;
CREATE TABLE `assignment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '作业ID',
  `course_id` bigint NOT NULL COMMENT '课程ID',
  `teacher_id` bigint NOT NULL COMMENT '教师ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '作业标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '作业说明',
  `due_date` datetime NULL DEFAULT NULL COMMENT '截止时间',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `course_id`(`course_id` ASC) USING BTREE,
  INDEX `user_id`(`teacher_id` ASC) USING BTREE,
  CONSTRAINT `course_id` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `user_id` FOREIGN KEY (`teacher_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 46 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of assignment
-- ----------------------------
INSERT INTO `assignment` VALUES (43, 101, 2, '嵌入式作业1', '请大家仔细完成', '2025-09-19 00:00:00', '2025-09-17 19:50:56');
INSERT INTO `assignment` VALUES (44, 101, 2, '111', '222', '2025-09-23 00:00:00', '2025-09-18 15:37:58');
INSERT INTO `assignment` VALUES (45, 101, 2, '111', '222', '2025-09-19 00:00:00', '2025-09-18 16:02:48');
INSERT INTO `assignment` VALUES (46, 101, 2, '111', '222', '2025-09-22 00:00:00', '2025-09-19 22:02:25');

-- ----------------------------
-- Table structure for assignment_question
-- ----------------------------
DROP TABLE IF EXISTS `assignment_question`;
CREATE TABLE `assignment_question`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `assignment_id` bigint NOT NULL,
  `question_id` bigint NOT NULL,
  `sort_order` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `assignment_id`(`assignment_id` ASC) USING BTREE,
  INDEX `question_id`(`question_id` ASC) USING BTREE,
  CONSTRAINT `assignment_question_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `assignment` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `assignment_question_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `question_bank` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 95 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of assignment_question
-- ----------------------------
INSERT INTO `assignment_question` VALUES (91, 43, 1076, 0);
INSERT INTO `assignment_question` VALUES (92, 43, 1092, 0);
INSERT INTO `assignment_question` VALUES (93, 44, 1076, 0);
INSERT INTO `assignment_question` VALUES (94, 45, 1076, 0);
INSERT INTO `assignment_question` VALUES (95, 46, 1076, 0);

-- ----------------------------
-- Table structure for assignment_submission
-- ----------------------------
DROP TABLE IF EXISTS `assignment_submission`;
CREATE TABLE `assignment_submission`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `assignment_id` bigint NOT NULL,
  `student_id` bigint NOT NULL,
  `submitted_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '学生提交的答案JSON或文字',
  `score` int NULL DEFAULT NULL COMMENT 'AI评分结果',
  `is_late` tinyint(1) NULL DEFAULT 0 COMMENT '是否迟交',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `assignment_id`(`assignment_id` ASC) USING BTREE,
  INDEX `student_id`(`student_id` ASC) USING BTREE,
  CONSTRAINT `assignment_id` FOREIGN KEY (`assignment_id`) REFERENCES `assignment` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `student_id` FOREIGN KEY (`student_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 32 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of assignment_submission
-- ----------------------------
INSERT INTO `assignment_submission` VALUES (29, 43, 1, '2025-09-17 19:51:14', NULL, NULL, 0);
INSERT INTO `assignment_submission` VALUES (30, 44, 1, '2025-09-18 16:43:04', NULL, NULL, 0);
INSERT INTO `assignment_submission` VALUES (31, 45, 1, '2025-09-19 21:59:31', NULL, NULL, 0);
INSERT INTO `assignment_submission` VALUES (32, 46, 1, '2025-09-19 22:14:59', NULL, NULL, 0);

-- ----------------------------
-- Table structure for assignment_submission_detail
-- ----------------------------
DROP TABLE IF EXISTS `assignment_submission_detail`;
CREATE TABLE `assignment_submission_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `submission_id` bigint NOT NULL COMMENT '对应 assignment_submission 的 ID',
  `question_id` bigint NOT NULL COMMENT '题目ID',
  `answer_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '学生答案',
  `score` int NULL DEFAULT NULL COMMENT 'AI评分',
  `is_correct` tinyint(1) NULL DEFAULT NULL COMMENT '是否正确，0-错，1-对',
  `error_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误原因',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_submission_id`(`submission_id` ASC) USING BTREE,
  CONSTRAINT `submission_id` FOREIGN KEY (`submission_id`) REFERENCES `assignment_submission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 40 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '学生作业每题提交详情表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of assignment_submission_detail
-- ----------------------------
INSERT INTO `assignment_submission_detail` VALUES (37, 29, 1076, '11111', 0, 0, '学生答案为\'11111\'，与标准答案内容完全无关，未回答嵌入式系统的定义');
INSERT INTO `assignment_submission_detail` VALUES (38, 29, 1092, '1111111111', 0, 0, '学生答案为无意义的数字串，与题目要求无关');
INSERT INTO `assignment_submission_detail` VALUES (39, 30, 1076, '111', 0, 0, '学生答案为\'111\'，与标准答案内容完全不符，未回答嵌入式系统的定义，属于无效作答');
INSERT INTO `assignment_submission_detail` VALUES (40, 32, 1076, '222', 0, 0, '学生答案为\'222\'，与标准答案无关，内容完全错误');

-- ----------------------------
-- Table structure for auto_exam_config
-- ----------------------------
DROP TABLE IF EXISTS `auto_exam_config`;
CREATE TABLE `auto_exam_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_id` bigint NOT NULL,
  `teacher_id` bigint NOT NULL,
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置名称',
  `total_questions` int NOT NULL COMMENT '总题数',
  `question_distribution` json NOT NULL COMMENT '题型分布配置',
  `difficulty_distribution` json NOT NULL COMMENT '难度分布配置',
  `knowledge_point_weights` json NOT NULL COMMENT '知识点权重配置',
  `time_limit_minutes` int NULL DEFAULT 120 COMMENT '考试时长',
  `ai_prompt_template` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'AI提示词模板',
  `is_active` tinyint(1) NULL DEFAULT 1 COMMENT '是否启用',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_teacher`(`course_id` ASC, `teacher_id` ASC) USING BTREE,
  INDEX `auto_exam_config_ibfk_2`(`teacher_id` ASC) USING BTREE,
  CONSTRAINT `auto_exam_config_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auto_exam_config_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '自动组卷配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auto_exam_config
-- ----------------------------
INSERT INTO `auto_exam_config` VALUES (1, 101, 1, '嵌入式系统基础测试', 20, '{\"choice\": 10, \"programming\": 3, \"short_answer\": 7}', '{\"easy\": 0.2, \"hard\": 0.3, \"medium\": 0.5}', '{\"1\": 0.3, \"2\": 0.2, \"3\": 0.2, \"4\": 0.1, \"5\": 0.1, \"6\": 0.1}', 90, NULL, 1, '2025-09-10 10:25:08', '2025-09-10 10:25:08');
INSERT INTO `auto_exam_config` VALUES (2, 101, 1, '嵌入式系统综合测试', 30, '{\"choice\": 15, \"programming\": 5, \"short_answer\": 10}', '{\"easy\": 0.1, \"hard\": 0.5, \"medium\": 0.4}', '{\"1\": 0.2, \"2\": 0.2, \"3\": 0.2, \"4\": 0.15, \"5\": 0.15, \"6\": 0.1}', 120, NULL, 1, '2025-09-10 10:25:08', '2025-09-10 10:25:08');

-- ----------------------------
-- Table structure for auto_exam_question
-- ----------------------------
DROP TABLE IF EXISTS `auto_exam_question`;
CREATE TABLE `auto_exam_question`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `exam_id` bigint NOT NULL,
  `question_bank_id` bigint NOT NULL,
  `question_order` int NOT NULL COMMENT '题目顺序',
  `section_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '题目分组',
  `difficulty_level` int NULL DEFAULT NULL COMMENT '难度等级',
  `knowledge_point_id` bigint NULL DEFAULT NULL COMMENT '关联知识点',
  `ai_selection_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'AI选择该题的原因',
  `estimated_time_minutes` int NULL DEFAULT NULL COMMENT '预估答题时间',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_exam_question`(`exam_id` ASC, `question_bank_id` ASC) USING BTREE,
  INDEX `idx_exam`(`exam_id` ASC) USING BTREE,
  INDEX `idx_question`(`question_bank_id` ASC) USING BTREE,
  INDEX `idx_knowledge_point`(`knowledge_point_id` ASC) USING BTREE,
  CONSTRAINT `auto_exam_question_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `auto_generated_exam` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `auto_exam_question_ibfk_2` FOREIGN KEY (`question_bank_id`) REFERENCES `question_bank` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auto_exam_question_ibfk_3` FOREIGN KEY (`knowledge_point_id`) REFERENCES `knowledge_point` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 304 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '试卷题目关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auto_exam_question
-- ----------------------------

-- ----------------------------
-- Table structure for auto_generated_exam
-- ----------------------------
DROP TABLE IF EXISTS `auto_generated_exam`;
CREATE TABLE `auto_generated_exam`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `config_id` bigint NOT NULL,
  `exam_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `exam_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `generation_strategy` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '生成策略',
  `ai_model_used` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '使用的AI模型',
  `generation_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '生成时使用的提示词',
  `generation_metadata` json NULL COMMENT '生成元数据',
  `quality_score` decimal(3, 2) NULL DEFAULT NULL COMMENT '试卷质量评分',
  `status` enum('draft','generated','reviewed','published','archived') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'draft',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` datetime NULL DEFAULT NULL,
  `published_at` datetime NULL DEFAULT NULL,
  `created_by` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_config`(`config_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_by`(`created_by` ASC) USING BTREE,
  CONSTRAINT `auto_generated_exam_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `auto_exam_config` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auto_generated_exam_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '自动生成试卷表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auto_generated_exam
-- ----------------------------

-- ----------------------------
-- Table structure for chapter
-- ----------------------------
DROP TABLE IF EXISTS `chapter`;
CREATE TABLE `chapter`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '章节ID',
  `course_id` bigint NOT NULL COMMENT '所属课程ID',
  `chapter_title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '章节标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '章节内容（可选）',
  `created_at` date NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `course_id`(`course_id` ASC) USING BTREE,
  CONSTRAINT `chapter_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of chapter
-- ----------------------------
INSERT INTO `chapter` VALUES (1, 101, '嵌入式系统概述', NULL, NULL);
INSERT INTO `chapter` VALUES (2, 101, '嵌入式处理器架构', NULL, NULL);
INSERT INTO `chapter` VALUES (3, 101, '嵌入式软件开发', NULL, NULL);
INSERT INTO `chapter` VALUES (4, 101, '实时操作系统', NULL, NULL);
INSERT INTO `chapter` VALUES (5, 101, '嵌入式系统通信', NULL, NULL);
INSERT INTO `chapter` VALUES (6, 101, '嵌入式系统调试与测试', NULL, NULL);

-- ----------------------------
-- Table structure for course
-- ----------------------------
DROP TABLE IF EXISTS `course`;
CREATE TABLE `course`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `teacher_id` bigint NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `course_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'default.jpg' COMMENT '课程封面图',
  `teaching_goal` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '教学目标',
  `teaching_principle` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '教学原则',
  `course_background` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '课程背景',
  `course_intro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '课程介绍',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `teacher_id`(`teacher_id` ASC) USING BTREE,
  CONSTRAINT `teacher_id` FOREIGN KEY (`teacher_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 105 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course
-- ----------------------------
INSERT INTO `course` VALUES (101, '嵌入式开发进阶', '硬件底层驱动与实时系统开发实战', 2, '2025-07-12 16:38:43', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/7c2d7145-f40d-40cf-ab21-1581a55c5ea3-p111.png', '做好嵌入式开发', '教会嵌入式基础，嵌入式进阶，嵌入式编程', '', NULL);
INSERT INTO `course` VALUES (102, '计算机网络', '网络协议原理及组网应用实践', 2, '2025-07-13 20:58:20', '\r\nhttps://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/JiWang.png', '使学生掌握计算机网络体系结构、关键协议原理及组网技术，具备网络设计、故障排查和安全防护的实践能力。', '理论实践并重，以协议体系为核心，通过案例分析和实验操作培养解决实际网络问题的能力。', NULL, NULL);

-- ----------------------------
-- Table structure for course_chat_log
-- ----------------------------
DROP TABLE IF EXISTS `course_chat_log`;
CREATE TABLE `course_chat_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_id` bigint NOT NULL,
  `sender_id` bigint NULL DEFAULT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `sent_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `message_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'text' COMMENT '消息类型',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件名',
  `file_size` bigint NULL DEFAULT NULL COMMENT '文件大小(字节)',
  `duration` int NULL DEFAULT NULL COMMENT '语音时长(秒)',
  `sender_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '发送者姓名',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_id`(`course_id` ASC) USING BTREE,
  INDEX `idx_sender_id`(`sender_id` ASC) USING BTREE,
  CONSTRAINT `fk_course_chat_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_course_chat_sender` FOREIGN KEY (`sender_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 286 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of course_chat_log
-- ----------------------------
INSERT INTO `course_chat_log` VALUES (232, 102, 1, '❤️', '2025-08-30 20:01:37', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (233, 102, 2, '😂', '2025-08-30 20:01:54', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (235, 102, 1, '😊', '2025-08-30 20:02:14', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (236, 101, 3, '😊', '2025-08-30 20:03:22', 'text', NULL, NULL, NULL, '梁本华');
INSERT INTO `course_chat_log` VALUES (237, 101, 2, '😂', '2025-08-30 20:03:37', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (238, 101, 1, '😂', '2025-08-30 20:04:05', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (239, 101, 1, '🎉', '2025-08-30 20:04:12', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (240, 102, 1, '😂', '2025-08-30 20:04:57', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (241, 101, 1, '😊', '2025-08-30 20:24:54', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (242, 101, 2, '❤️', '2025-08-30 20:25:05', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (243, 101, 3, '😂', '2025-08-30 20:25:28', 'text', NULL, NULL, NULL, '梁本华');
INSERT INTO `course_chat_log` VALUES (244, 101, 1, '😂', '2025-08-30 23:00:02', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (245, 101, 2, '😊', '2025-08-31 15:02:54', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (246, 101, 1, '😊', '2025-08-31 15:03:39', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (247, 101, 1, '😊', '2025-08-31 18:44:33', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (248, 101, 2, '😂', '2025-08-31 20:57:09', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (249, 101, 2, '😊', '2025-08-31 21:01:23', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (250, 101, 2, '😂', '2025-08-31 21:07:54', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (251, 101, 2, '😊', '2025-08-31 21:27:22', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (252, 101, 2, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/cbf22d49-ece0-4009-b312-041ddd503424-《中国大学生计算机设计大赛 作品报告（人工智能实践赛，2025版）》.docx', '2025-08-31 21:27:42', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (253, 101, 2, '这是今晚作业', '2025-08-31 21:27:50', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (254, 101, 1, '😂', '2025-08-31 21:28:20', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (255, 101, 1, '😊', '2025-09-01 15:22:39', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (256, 101, 2, '😊', '2025-09-01 16:29:03', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (257, 101, 1, '😊', '2025-09-01 16:29:47', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (258, 101, 2, '😊', '2025-09-02 10:32:27', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (259, 101, 2, '😊', '2025-09-02 10:32:47', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (260, 101, 2, '😊', '2025-09-02 10:35:04', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (261, 101, 1, '😂', '2025-09-02 10:35:14', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (262, 101, 1, '😊', '2025-09-09 15:23:30', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (263, 101, 1, '约吗', '2025-09-13 00:05:59', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (264, 101, 1, '😊', '2025-09-15 20:00:06', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (265, 101, 2, '你好', '2025-09-16 15:41:34', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (266, 101, 1, '😊', '2025-09-16 15:44:07', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (267, 101, 1, '❤️', '2025-09-16 15:47:03', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (268, 101, 1, '❤️', '2025-09-16 15:47:22', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (269, 101, 1, '你好', '2025-09-16 15:49:29', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (270, 101, 3, '你好', '2025-09-16 15:50:38', 'text', NULL, NULL, NULL, '梁本华');
INSERT INTO `course_chat_log` VALUES (271, 101, 1, '你好', '2025-09-16 15:52:07', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (272, 101, 1, '❤️', '2025-09-16 15:53:35', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (273, 101, 1, '年后', '2025-09-16 15:55:08', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (274, 101, 1, '你好', '2025-09-16 15:55:12', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (275, 101, 1, '😊', '2025-09-16 15:56:33', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (276, 101, 2, '😊', '2025-09-16 16:00:26', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (277, 101, 1, '😊', '2025-09-16 17:26:05', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (278, 101, 2, '😊', '2025-09-17 14:41:52', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (279, 101, 2, '6', '2025-09-18 10:13:14', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (280, 101, 2, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/a2716347-75cd-43e8-98a6-342e100ff066-嵌入式开发进阶_2025-09-17.docx', '2025-09-18 15:47:13', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (281, 101, 2, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/ba3d038a-8ca2-4095-80a4-b5140484c121-voice_1758181643257.wav', '2025-09-18 15:47:23', 'voice', NULL, NULL, 3, '老师');
INSERT INTO `course_chat_log` VALUES (282, 101, 2, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/58e5ae92-61da-40f3-9598-7dae6e8afedf-嵌入式开发进阶_2025-09-17.docx', '2025-09-18 15:48:58', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (283, 101, 2, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/f3970579-727b-4131-97b2-d727442447b8-嵌入式开发进阶_2025-09-17.docx', '2025-09-18 15:49:50', 'text', NULL, NULL, NULL, '老师');
INSERT INTO `course_chat_log` VALUES (284, 101, 2, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/26cbc094-d8e8-4f45-b00c-09035dd68eea-voice_1758181792847.wav', '2025-09-18 15:49:53', 'voice', NULL, NULL, 1, '老师');
INSERT INTO `course_chat_log` VALUES (285, 101, 1, '😊', '2025-09-18 16:48:47', 'text', NULL, NULL, NULL, '张政');
INSERT INTO `course_chat_log` VALUES (286, 101, 1, '😊', '2025-09-18 16:51:00', 'text', NULL, NULL, NULL, '张政');

-- ----------------------------
-- Table structure for exam
-- ----------------------------
DROP TABLE IF EXISTS `exam`;
CREATE TABLE `exam`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_id` bigint NOT NULL,
  `teacher_id` bigint NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `exam_date` date NOT NULL,
  `duration_minutes` int NOT NULL DEFAULT 60,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam
-- ----------------------------
INSERT INTO `exam` VALUES (18, 101, 2, '嵌入式', NULL, '2025-09-19', 60, '2025-09-18 16:03:53');

-- ----------------------------
-- Table structure for exam_answer
-- ----------------------------
DROP TABLE IF EXISTS `exam_answer`;
CREATE TABLE `exam_answer`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `exam_result_id` bigint NOT NULL COMMENT '考试结果ID',
  `question_id` bigint NOT NULL COMMENT '题目ID',
  `student_answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '学生答案',
  `correct_answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '正确答案',
  `is_correct` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否正确',
  `score` decimal(5, 2) NOT NULL DEFAULT 0.00 COMMENT '得分',
  `ai_feedback` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI对这道题的批阅反馈',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_exam_result_id`(`exam_result_id` ASC) USING BTREE,
  INDEX `idx_question_id`(`question_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 662 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '考试答案表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_answer
-- ----------------------------
INSERT INTO `exam_answer` VALUES (1, 1, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (2, 1, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (3, 1, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (4, 1, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (5, 1, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (6, 1, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (7, 1, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (8, 1, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (9, 1, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (10, 1, 1102, '', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (11, 1, 1120, '', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (12, 1, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (13, 1, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (14, 1, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (15, 1, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (16, 1, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (17, 1, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (18, 1, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (19, 1, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:13');
INSERT INTO `exam_answer` VALUES (20, 2, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (21, 2, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (22, 2, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (23, 2, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (24, 2, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (25, 2, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (26, 2, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (27, 2, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (28, 2, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (29, 2, 1102, '', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (30, 2, 1120, '', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (31, 2, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (32, 2, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (33, 2, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (34, 2, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (35, 2, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (36, 2, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (37, 2, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (38, 2, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:54:39');
INSERT INTO `exam_answer` VALUES (39, 3, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (40, 3, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (41, 3, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (42, 3, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (43, 3, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (44, 3, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (45, 3, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (46, 3, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (47, 3, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (48, 3, 1102, '', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (49, 3, 1120, '', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (50, 3, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (51, 3, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (52, 3, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (53, 3, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (54, 3, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (55, 3, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (56, 3, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (57, 3, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:42');
INSERT INTO `exam_answer` VALUES (58, 4, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (59, 4, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (60, 4, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (61, 4, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (62, 4, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (63, 4, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (64, 4, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (65, 4, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (66, 4, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (67, 4, 1102, '', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (68, 4, 1120, '', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (69, 4, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (70, 4, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (71, 4, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (72, 4, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (73, 4, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (74, 4, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (75, 4, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (76, 4, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 1, 7.50, '代码基本正确，但有以下改进建议：1. 变量命名可以更规范；2. 可以添加更多注释；3. 算法效率可以进一步优化。', '2025-09-12 18:58:48');
INSERT INTO `exam_answer` VALUES (77, 5, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (78, 5, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (79, 5, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (80, 5, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (81, 5, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (82, 5, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (83, 5, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (84, 5, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (85, 5, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (86, 5, 1102, '', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (87, 5, 1120, '', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (88, 5, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (89, 5, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (90, 5, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (91, 5, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (92, 5, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (93, 5, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (94, 5, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (95, 5, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:04');
INSERT INTO `exam_answer` VALUES (96, 6, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (97, 6, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (98, 6, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (99, 6, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (100, 6, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (101, 6, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (102, 6, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (103, 6, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (104, 6, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (105, 6, 1102, '', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (106, 6, 1120, '', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (107, 6, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (108, 6, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (109, 6, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (110, 6, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (111, 6, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (112, 6, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (113, 6, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (114, 6, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:09:19');
INSERT INTO `exam_answer` VALUES (115, 7, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (116, 7, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (117, 7, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (118, 7, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (119, 7, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (120, 7, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (121, 7, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (122, 7, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (123, 7, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (124, 7, 1102, '', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (125, 7, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 1, 6.40, '代码基本正确！得分：6.4分。建议：可以进一步优化代码结构和注释。', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (126, 7, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (127, 7, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (128, 7, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (129, 7, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (130, 7, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (131, 7, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (132, 7, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (133, 7, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:30');
INSERT INTO `exam_answer` VALUES (134, 8, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (135, 8, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (136, 8, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (137, 8, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (138, 8, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (139, 8, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (140, 8, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (141, 8, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (142, 8, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (143, 8, 1102, '', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (144, 8, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 1, 6.40, '代码基本正确！得分：6.4分。建议：可以进一步优化代码结构和注释。', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (145, 8, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (146, 8, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (147, 8, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (148, 8, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (149, 8, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (150, 8, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (151, 8, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (152, 8, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:11:42');
INSERT INTO `exam_answer` VALUES (153, 9, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (154, 9, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (155, 9, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (156, 9, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (157, 9, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (158, 9, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (159, 9, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (160, 9, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (161, 9, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (162, 9, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.64, '代码需要改进，得分：0.6分。建议：请参考标准答案，重新编写代码。', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (163, 9, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 1, 6.40, '代码基本正确！得分：6.4分。建议：可以进一步优化代码结构和注释。', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (164, 9, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (165, 9, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (166, 9, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (167, 9, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (168, 9, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (169, 9, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (170, 9, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (171, 9, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:05');
INSERT INTO `exam_answer` VALUES (172, 10, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (173, 10, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (174, 10, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (175, 10, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (176, 10, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (177, 10, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (178, 10, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (179, 10, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (180, 10, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (181, 10, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.64, '代码需要改进，得分：0.6分。建议：请参考标准答案，重新编写代码。', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (182, 10, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 1, 6.40, '代码基本正确！得分：6.4分。建议：可以进一步优化代码结构和注释。', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (183, 10, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (184, 10, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (185, 10, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (186, 10, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (187, 10, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (188, 10, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (189, 10, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (190, 10, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:12:24');
INSERT INTO `exam_answer` VALUES (191, 11, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (192, 11, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (193, 11, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (194, 11, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (195, 11, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (196, 11, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (197, 11, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (198, 11, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (199, 11, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (200, 11, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 1.00, '代码需要改进，得分：1.0分。建议：请参考标准答案，重新编写代码。', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (201, 11, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 1, 6.00, '代码基本正确！得分：6.0分。建议：可以进一步优化代码结构和注释。', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (202, 11, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (203, 11, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (204, 11, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (205, 11, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (206, 11, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (207, 11, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (208, 11, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (209, 11, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:13');
INSERT INTO `exam_answer` VALUES (210, 12, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (211, 12, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (212, 12, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (213, 12, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (214, 12, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (215, 12, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (216, 12, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (217, 12, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (218, 12, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (219, 12, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 1.00, '代码需要改进，得分：1.0分。建议：请参考标准答案，重新编写代码。', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (220, 12, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 1, 6.00, '代码基本正确！得分：6.0分。建议：可以进一步优化代码结构和注释。', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (221, 12, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (222, 12, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (223, 12, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (224, 12, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (225, 12, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (226, 12, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (227, 12, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (228, 12, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:19:29');
INSERT INTO `exam_answer` VALUES (229, 13, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (230, 13, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (231, 13, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (232, 13, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (233, 13, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (234, 13, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (235, 13, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (236, 13, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (237, 13, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (238, 13, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 1.00, '代码需要改进，得分：1.0分。建议：请参考标准答案，重新编写代码。', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (239, 13, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 1, 6.00, '代码基本正确！得分：6.0分。建议：可以进一步优化代码结构和注释。', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (240, 13, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (241, 13, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (242, 13, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (243, 13, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (244, 13, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (245, 13, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (246, 13, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (247, 13, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:20:21');
INSERT INTO `exam_answer` VALUES (248, 14, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:28:23');
INSERT INTO `exam_answer` VALUES (249, 14, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:28:23');
INSERT INTO `exam_answer` VALUES (250, 14, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:28:23');
INSERT INTO `exam_answer` VALUES (251, 14, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:28:23');
INSERT INTO `exam_answer` VALUES (252, 14, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:28:23');
INSERT INTO `exam_answer` VALUES (253, 14, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:28:23');
INSERT INTO `exam_answer` VALUES (254, 14, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:28:23');
INSERT INTO `exam_answer` VALUES (255, 14, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:28:23');
INSERT INTO `exam_answer` VALUES (256, 14, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:28:23');
INSERT INTO `exam_answer` VALUES (257, 14, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, '代码需要改进，得分：0.0分。建议：请参考标准答案，重新编写代码。', '2025-09-12 19:28:23');
INSERT INTO `exam_answer` VALUES (258, 14, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 1, 6.00, '代码基本正确！得分：6.0分。建议：可以进一步优化代码结构和注释。', '2025-09-12 19:28:23');
INSERT INTO `exam_answer` VALUES (259, 14, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:28:23');
INSERT INTO `exam_answer` VALUES (260, 14, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:28:23');
INSERT INTO `exam_answer` VALUES (261, 14, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:28:24');
INSERT INTO `exam_answer` VALUES (262, 14, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:28:24');
INSERT INTO `exam_answer` VALUES (263, 14, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:28:24');
INSERT INTO `exam_answer` VALUES (264, 14, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:28:24');
INSERT INTO `exam_answer` VALUES (265, 14, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:28:24');
INSERT INTO `exam_answer` VALUES (266, 14, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:28:24');
INSERT INTO `exam_answer` VALUES (267, 15, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (268, 15, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (269, 15, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (270, 15, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (271, 15, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (272, 15, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (273, 15, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (274, 15, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (275, 15, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (276, 15, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, 'AI批阅服务暂时不可用，请稍后重试', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (277, 15, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, 'AI批阅服务暂时不可用，请稍后重试', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (278, 15, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (279, 15, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (280, 15, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (281, 15, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (282, 15, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (283, 15, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (284, 15, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (285, 15, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:48');
INSERT INTO `exam_answer` VALUES (286, 16, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (287, 16, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (288, 16, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (289, 16, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (290, 16, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (291, 16, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (292, 16, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (293, 16, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (294, 16, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (295, 16, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, 'AI批阅服务暂时不可用，请稍后重试', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (296, 16, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (297, 16, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (298, 16, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (299, 16, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (300, 16, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (301, 16, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (302, 16, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (303, 16, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (304, 16, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:32:57');
INSERT INTO `exam_answer` VALUES (305, 17, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (306, 17, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (307, 17, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (308, 17, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (309, 17, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (310, 17, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (311, 17, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (312, 17, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (313, 17, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (314, 17, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (315, 17, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (316, 17, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (317, 17, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (318, 17, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (319, 17, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (320, 17, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (321, 17, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (322, 17, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (323, 17, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:33:34');
INSERT INTO `exam_answer` VALUES (324, 18, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (325, 18, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (326, 18, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (327, 18, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (328, 18, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (329, 18, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (330, 18, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (331, 18, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (332, 18, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (333, 18, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (334, 18, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (335, 18, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (336, 18, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (337, 18, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (338, 18, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (339, 18, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (340, 18, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (341, 18, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (342, 18, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:00');
INSERT INTO `exam_answer` VALUES (343, 19, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (344, 19, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (345, 19, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (346, 19, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (347, 19, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (348, 19, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (349, 19, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (350, 19, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (351, 19, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (352, 19, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (353, 19, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (354, 19, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (355, 19, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (356, 19, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (357, 19, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (358, 19, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (359, 19, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (360, 19, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (361, 19, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:36:12');
INSERT INTO `exam_answer` VALUES (362, 20, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (363, 20, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (364, 20, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (365, 20, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (366, 20, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (367, 20, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (368, 20, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (369, 20, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (370, 20, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (371, 20, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (372, 20, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (373, 20, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (374, 20, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (375, 20, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (376, 20, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (377, 20, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (378, 20, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (379, 20, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (380, 20, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:39:21');
INSERT INTO `exam_answer` VALUES (381, 21, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (382, 21, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (383, 21, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (384, 21, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (385, 21, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (386, 21, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (387, 21, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (388, 21, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (389, 21, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (390, 21, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (391, 21, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (392, 21, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (393, 21, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (394, 21, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (395, 21, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (396, 21, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (397, 21, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (398, 21, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (399, 21, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:41:04');
INSERT INTO `exam_answer` VALUES (400, 22, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (401, 22, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (402, 22, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (403, 22, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (404, 22, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (405, 22, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (406, 22, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (407, 22, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (408, 22, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (409, 22, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (410, 22, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (411, 22, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (412, 22, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (413, 22, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (414, 22, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (415, 22, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (416, 22, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (417, 22, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (418, 22, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:44:29');
INSERT INTO `exam_answer` VALUES (419, 23, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (420, 23, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (421, 23, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (422, 23, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (423, 23, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (424, 23, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (425, 23, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (426, 23, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (427, 23, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (428, 23, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (429, 23, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (430, 23, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (431, 23, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (432, 23, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (433, 23, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (434, 23, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (435, 23, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (436, 23, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (437, 23, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:45:17');
INSERT INTO `exam_answer` VALUES (438, 24, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (439, 24, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (440, 24, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (441, 24, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (442, 24, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (443, 24, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (444, 24, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (445, 24, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (446, 24, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (447, 24, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (448, 24, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (449, 24, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (450, 24, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (451, 24, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (452, 24, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (453, 24, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (454, 24, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (455, 24, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (456, 24, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:08');
INSERT INTO `exam_answer` VALUES (457, 25, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (458, 25, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (459, 25, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (460, 25, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (461, 25, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (462, 25, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (463, 25, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (464, 25, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (465, 25, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (466, 25, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (467, 25, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, 'AI响应格式错误', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (468, 25, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (469, 25, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (470, 25, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (471, 25, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (472, 25, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (473, 25, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (474, 25, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (475, 25, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:48:41');
INSERT INTO `exam_answer` VALUES (476, 26, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (477, 26, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (478, 26, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (479, 26, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (480, 26, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (481, 26, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (482, 26, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (483, 26, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (484, 26, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (485, 26, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, '{\"', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (486, 26, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, '{\"', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (487, 26, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (488, 26, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (489, 26, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (490, 26, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (491, 26, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (492, 26, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (493, 26, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (494, 26, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:52:25');
INSERT INTO `exam_answer` VALUES (495, 27, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:53:16');
INSERT INTO `exam_answer` VALUES (496, 27, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (497, 27, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (498, 27, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (499, 27, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (500, 27, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (501, 27, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (502, 27, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (503, 27, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (504, 27, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, '{\"', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (505, 27, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, '{\"', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (506, 27, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (507, 27, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (508, 27, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (509, 27, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (510, 27, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (511, 27, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (512, 27, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (513, 27, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:53:17');
INSERT INTO `exam_answer` VALUES (514, 28, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:55:34');
INSERT INTO `exam_answer` VALUES (515, 28, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (516, 28, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (517, 28, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (518, 28, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (519, 28, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (520, 28, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (521, 28, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (522, 28, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (523, 28, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, '{\"', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (524, 28, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, '{\"', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (525, 28, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (526, 28, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (527, 28, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (528, 28, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (529, 28, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (530, 28, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (531, 28, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (532, 28, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:55:35');
INSERT INTO `exam_answer` VALUES (533, 29, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (534, 29, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (535, 29, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (536, 29, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (537, 29, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (538, 29, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (539, 29, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (540, 29, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (541, 29, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (542, 29, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, '{\"', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (543, 29, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, '{\"', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (544, 29, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (545, 29, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (546, 29, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (547, 29, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (548, 29, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (549, 29, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (550, 29, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (551, 29, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:56:50');
INSERT INTO `exam_answer` VALUES (552, 30, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (553, 30, 1113, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (554, 30, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (555, 30, 1126, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (556, 30, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (557, 30, 1137, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (558, 30, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (559, 30, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (560, 30, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (561, 30, 1102, '就收到回复框上开发赛咖啡粉快速离开房间', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, '代码需要改进，得分：0.0分。建议：请参考标准答案，重新编写代码。', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (562, 30, 1120, '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 1, 6.00, '代码基本正确！得分：6.0分。建议：可以进一步优化代码结构和注释。', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (563, 30, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (564, 30, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (565, 30, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (566, 30, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (567, 30, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (568, 30, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (569, 30, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (570, 30, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 19:57:19');
INSERT INTO `exam_answer` VALUES (571, 31, 1112, 'B', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (572, 31, 1113, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (573, 31, 1124, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (574, 31, 1126, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (575, 31, 1127, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (576, 31, 1137, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (577, 31, 1138, 'C', 'C', 1, 10.00, '回答正确！', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (578, 31, 1139, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (579, 31, 1143, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (580, 31, 1102, '', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (581, 31, 1120, '', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (582, 31, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (583, 31, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (584, 31, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (585, 31, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (586, 31, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (587, 31, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (588, 31, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (589, 31, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:00:34');
INSERT INTO `exam_answer` VALUES (590, 32, 1076, '1', '嵌入式系统是一种以应用为中心、以计算机技术为基础，并且软硬件可裁剪，适用于对功能、可靠性、成本、体积及功耗有严格要求的专用计算机系统。', 0, 0.00, '回答不完整，得分：0.0分。建议：请参考标准答案，重新组织语言。', '2025-09-12 20:11:48');
INSERT INTO `exam_answer` VALUES (591, 32, 1077, '1', '工业控制、消费电子、医疗设备、汽车电子、航空航天等。', 0, 0.00, '回答不完整，得分：0.0分。建议：请参考标准答案，重新组织语言。', '2025-09-12 20:11:48');
INSERT INTO `exam_answer` VALUES (592, 32, 1078, '1', '嵌入式系统按功能可分为独立运行型系统（如智能手表）、从属型系统（如家用电器中的控制模块）和网络连接型系统（如智能摄像头）。', 0, 0.00, '回答不完整，得分：0.0分。建议：请参考标准答案，重新组织语言。', '2025-09-12 20:11:48');
INSERT INTO `exam_answer` VALUES (593, 33, 1082, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 20:29:35');
INSERT INTO `exam_answer` VALUES (594, 33, 1108, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 20:29:35');
INSERT INTO `exam_answer` VALUES (595, 33, 1083, '', '实时性是指系统在限定时间内对外部事件做出响应的能力。在嵌入式系统中，实时性至关重要，因为许多嵌入式应用（如工业控制、医疗设备）要求及时响应，否则可能导致严重后果。', 0, 0.00, '未提交答案，请认真作答。', '2025-09-12 20:29:35');
INSERT INTO `exam_answer` VALUES (596, 33, 1115, '', '嵌入式操作系统负责管理硬件资源和提供软件运行环境，其特点包括实时性、低资源占用、可移植性、稳定性和可靠性。', 0, 0.00, '未提交答案，请认真作答。', '2025-09-12 20:29:35');
INSERT INTO `exam_answer` VALUES (597, 33, 1117, '', '交叉编译工具链用于在宿主机上生成目标机可运行的代码。主要组件包括编译器、链接器、汇编器和调试器。', 0, 0.00, '未提交答案，请认真作答。', '2025-09-12 20:29:35');
INSERT INTO `exam_answer` VALUES (598, 34, 1082, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 20:34:32');
INSERT INTO `exam_answer` VALUES (599, 34, 1108, 'A', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 20:34:32');
INSERT INTO `exam_answer` VALUES (600, 34, 1083, '', '实时性是指系统在限定时间内对外部事件做出响应的能力。在嵌入式系统中，实时性至关重要，因为许多嵌入式应用（如工业控制、医疗设备）要求及时响应，否则可能导致严重后果。', 0, 0.00, '未提交答案，请认真作答。', '2025-09-12 20:34:32');
INSERT INTO `exam_answer` VALUES (601, 34, 1115, '', '嵌入式操作系统负责管理硬件资源和提供软件运行环境，其特点包括实时性、低资源占用、可移植性、稳定性和可靠性。', 0, 0.00, '未提交答案，请认真作答。', '2025-09-12 20:34:32');
INSERT INTO `exam_answer` VALUES (602, 34, 1117, '', '交叉编译工具链用于在宿主机上生成目标机可运行的代码。主要组件包括编译器、链接器、汇编器和调试器。', 0, 0.00, '未提交答案，请认真作答。', '2025-09-12 20:34:32');
INSERT INTO `exam_answer` VALUES (603, 35, 1112, 'C', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (604, 35, 1113, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (605, 35, 1124, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (606, 35, 1126, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (607, 35, 1127, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (608, 35, 1137, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (609, 35, 1138, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (610, 35, 1139, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (611, 35, 1143, '', 'A', 0, 0.00, '回答错误，正确答案是：A', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (612, 35, 1102, '', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (613, 35, 1120, '', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (614, 35, 1121, '', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (615, 35, 1122, '', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (616, 35, 1123, '', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (617, 35, 1132, '', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (618, 35, 1133, '', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (619, 35, 1150, '', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (620, 35, 1152, '', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (621, 35, 1153, '', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-12 20:36:59');
INSERT INTO `exam_answer` VALUES (622, 36, 1086, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (623, 36, 1087, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (624, 36, 1090, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (625, 36, 1104, 'A', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (626, 36, 1105, '', 'D', 0, 0.00, '回答错误，正确答案是：D', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (627, 36, 1106, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (628, 36, 1107, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (629, 36, 1141, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (630, 36, 1142, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (631, 36, 1154, '', 'D', 0, 0.00, '回答错误，正确答案是：D', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (632, 36, 1155, '', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (633, 36, 1079, '', 'int isEmbeddedSystem(int isDedicated, int isResourceLimited, int hasRealTimeRequirements) {\n  return isDedicated && isResourceLimited && hasRealTimeRequirements;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (634, 36, 1092, '', '嵌入式系统是为特定功能设计的专用计算机系统，通常具有实时性、资源受限、可靠性高和功耗低等特点。', 0, 0.00, '未提交答案，请认真作答。', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (635, 36, 1094, '', '#define SET_BIT(reg, bit) ((reg) |= (1 << (bit)))\nint main() {\n    volatile unsigned int *reg = (unsigned int *)0x40000000;\n    SET_BIT(*reg, 5);\n    return 0;\n}', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (636, 36, 1114, '', '嵌入式系统是以应用为中心，以计算机技术为基础，软硬件可裁剪，适用于对功能、可靠性、成本等有严格要求的专用计算机系统。主要应用于工业控制、消费电子、医疗设备、汽车电子等领域。', 0, 0.00, '未提交答案，请认真作答。', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (637, 36, 1115, '', '嵌入式操作系统负责管理硬件资源和提供软件运行环境，其特点包括实时性、低资源占用、可移植性、稳定性和可靠性。', 0, 0.00, '未提交答案，请认真作答。', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (638, 36, 1117, '', '交叉编译工具链用于在宿主机上生成目标机可运行的代码。主要组件包括编译器、链接器、汇编器和调试器。', 0, 0.00, '未提交答案，请认真作答。', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (639, 36, 1160, '', 'Flash Memory是非易失性存储器，可以擦除和重新编程，适合存储固件，如引导程序和操作系统镜像。', 0, 0.00, '未提交答案，请认真作答。', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (640, 36, 1161, '', '指令集架构（ISA）定义了处理器能够执行的指令集合，以及这些指令如何操作硬件资源。', 0, 0.00, '未提交答案，请认真作答。', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (641, 36, 1163, '', 'ADD R2, R0, R1', 0, 0.00, '未提交代码，请认真完成编程题。', '2025-09-13 00:09:30');
INSERT INTO `exam_answer` VALUES (642, 37, 1082, 'B', 'B', 1, 10.00, '回答正确！', '2025-09-13 15:14:35');
INSERT INTO `exam_answer` VALUES (643, 37, 1109, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-13 15:14:35');
INSERT INTO `exam_answer` VALUES (644, 37, 1142, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-13 15:14:35');
INSERT INTO `exam_answer` VALUES (645, 38, 1082, 'B', 'B', 1, 100.00, '回答正确！', '2025-09-13 15:29:04');
INSERT INTO `exam_answer` VALUES (646, 38, 1109, 'A', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-13 15:29:04');
INSERT INTO `exam_answer` VALUES (647, 38, 1142, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-13 15:29:04');
INSERT INTO `exam_answer` VALUES (648, 39, 1077, 'ddd', '工业控制、消费电子、医疗设备、汽车电子、航空航天等。', 0, 0.00, '回答不完整，得分：0.0分。建议：请参考标准答案，重新组织语言。', '2025-09-15 19:58:21');
INSERT INTO `exam_answer` VALUES (649, 39, 1078, 'dd', '嵌入式系统按功能可分为独立运行型系统（如智能手表）、从属型系统（如家用电器中的控制模块）和网络连接型系统（如智能摄像头）。', 0, 0.00, '回答不完整，得分：0.0分。建议：请参考标准答案，重新组织语言。', '2025-09-15 19:58:21');
INSERT INTO `exam_answer` VALUES (650, 40, 1090, 'B', 'B', 1, 100.00, '回答正确！', '2025-09-17 14:38:26');
INSERT INTO `exam_answer` VALUES (651, 40, 1104, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-17 14:38:26');
INSERT INTO `exam_answer` VALUES (652, 40, 1155, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-17 14:38:26');
INSERT INTO `exam_answer` VALUES (653, 40, 1157, '', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-17 14:38:26');
INSERT INTO `exam_answer` VALUES (654, 40, 1167, 'B', 'C', 0, 0.00, '回答错误，正确答案是：C', '2025-09-17 14:38:26');
INSERT INTO `exam_answer` VALUES (655, 40, 1080, '2211', 'typedef struct {\n  char type[20];\n  int isRealTime;\n  int isMicrocontrollerBased;\n} EmbeddedSystem;\n\nvoid printEmbeddedSystem(EmbeddedSystem sys) {\n  printf(\"Type: %s\\n\", sys.type);\n  printf(\"Real-time: %s\\n\", sys.isRealTime ? \"Yes\" : \"No\");\n  printf(\"Microcontroller-based: %s\\n\", sys.isMicrocontrollerBased ? \"Yes\" : \"No\");\n}', 0, 0.00, '代码需要改进，得分：0.0分。建议：请参考标准答案，重新编写代码。', '2025-09-17 14:38:26');
INSERT INTO `exam_answer` VALUES (656, 40, 1161, '11', '指令集架构（ISA）定义了处理器能够执行的指令集合，以及这些指令如何操作硬件资源。', 0, 0.00, '回答不完整，得分：0.0分。建议：请参考标准答案，重新组织语言。', '2025-09-17 14:38:26');
INSERT INTO `exam_answer` VALUES (657, 40, 1163, '11', 'ADD R2, R0, R1', 0, 0.00, '代码需要改进，得分：0.0分。建议：请参考标准答案，重新编写代码。', '2025-09-17 14:38:26');
INSERT INTO `exam_answer` VALUES (658, 41, 1081, 'C', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-18 16:43:29');
INSERT INTO `exam_answer` VALUES (659, 41, 1082, 'D', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-18 16:43:29');
INSERT INTO `exam_answer` VALUES (660, 41, 1086, 'A', 'B', 0, 0.00, '回答错误，正确答案是：B', '2025-09-18 16:43:29');
INSERT INTO `exam_answer` VALUES (661, 41, 1076, '', '嵌入式系统是一种以应用为中心、以计算机技术为基础，并且软硬件可裁剪，适用于对功能、可靠性、成本、体积及功耗有严格要求的专用计算机系统。', 0, 0.00, '未提交答案，请认真作答。', '2025-09-18 16:43:29');
INSERT INTO `exam_answer` VALUES (662, 41, 1077, '', '工业控制、消费电子、医疗设备、汽车电子、航空航天等。', 0, 0.00, '未提交答案，请认真作答。', '2025-09-18 16:43:29');

-- ----------------------------
-- Table structure for exam_generation_log
-- ----------------------------
DROP TABLE IF EXISTS `exam_generation_log`;
CREATE TABLE `exam_generation_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `config_id` bigint NOT NULL,
  `generation_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '生成类型',
  `request_params` json NOT NULL COMMENT '请求参数',
  `ai_response` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'AI响应内容',
  `generation_time_ms` int NULL DEFAULT NULL COMMENT '生成耗时(毫秒)',
  `success` tinyint(1) NULL DEFAULT 1,
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_config`(`config_id` ASC) USING BTREE,
  INDEX `idx_created`(`created_at` ASC) USING BTREE,
  INDEX `idx_created_by`(`created_by` ASC) USING BTREE,
  CONSTRAINT `exam_generation_log_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `auto_exam_config` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `exam_generation_log_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '组卷历史记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_generation_log
-- ----------------------------

-- ----------------------------
-- Table structure for exam_paper
-- ----------------------------
DROP TABLE IF EXISTS `exam_paper`;
CREATE TABLE `exam_paper`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `course_id` bigint NOT NULL,
  `teacher_id` bigint NOT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `course_id`(`course_id` ASC) USING BTREE,
  INDEX `teacher_id`(`teacher_id` ASC) USING BTREE,
  CONSTRAINT `exam_paper_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `exam_paper_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_paper
-- ----------------------------

-- ----------------------------
-- Table structure for exam_quality_assessment
-- ----------------------------
DROP TABLE IF EXISTS `exam_quality_assessment`;
CREATE TABLE `exam_quality_assessment`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `exam_id` bigint NOT NULL,
  `overall_score` decimal(3, 2) NOT NULL COMMENT '总体评分',
  `difficulty_balance` decimal(3, 2) NULL DEFAULT NULL COMMENT '难度平衡性',
  `knowledge_coverage` decimal(3, 2) NULL DEFAULT NULL COMMENT '知识点覆盖率',
  `time_distribution` decimal(3, 2) NULL DEFAULT NULL COMMENT '时间分布合理性',
  `question_diversity` decimal(3, 2) NULL DEFAULT NULL COMMENT '题目多样性',
  `assessment_details` json NULL COMMENT '详细评估数据',
  `assessed_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `assessed_by` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_exam`(`exam_id` ASC) USING BTREE,
  INDEX `idx_assessed_by`(`assessed_by` ASC) USING BTREE,
  CONSTRAINT `exam_quality_assessment_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `auto_generated_exam` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `exam_quality_assessment_ibfk_2` FOREIGN KEY (`assessed_by`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '试卷质量评估表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_quality_assessment
-- ----------------------------

-- ----------------------------
-- Table structure for exam_question
-- ----------------------------
DROP TABLE IF EXISTS `exam_question`;
CREATE TABLE `exam_question`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `exam_id` bigint NOT NULL,
  `question_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `exam_id`(`exam_id` ASC) USING BTREE,
  INDEX `question_id`(`question_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 105 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_question
-- ----------------------------
INSERT INTO `exam_question` VALUES (1, 1, 1076);
INSERT INTO `exam_question` VALUES (2, 1, 1077);
INSERT INTO `exam_question` VALUES (3, 1, 1078);
INSERT INTO `exam_question` VALUES (29, 9, 1083);
INSERT INTO `exam_question` VALUES (30, 9, 1082);
INSERT INTO `exam_question` VALUES (31, 9, 1108);
INSERT INTO `exam_question` VALUES (32, 9, 1117);
INSERT INTO `exam_question` VALUES (33, 9, 1115);
INSERT INTO `exam_question` VALUES (34, 10, 1102);
INSERT INTO `exam_question` VALUES (35, 10, 1120);
INSERT INTO `exam_question` VALUES (36, 10, 1121);
INSERT INTO `exam_question` VALUES (37, 10, 1122);
INSERT INTO `exam_question` VALUES (38, 10, 1132);
INSERT INTO `exam_question` VALUES (39, 10, 1150);
INSERT INTO `exam_question` VALUES (40, 10, 1152);
INSERT INTO `exam_question` VALUES (41, 10, 1153);
INSERT INTO `exam_question` VALUES (42, 10, 1123);
INSERT INTO `exam_question` VALUES (43, 10, 1133);
INSERT INTO `exam_question` VALUES (44, 10, 1112);
INSERT INTO `exam_question` VALUES (45, 10, 1124);
INSERT INTO `exam_question` VALUES (46, 10, 1137);
INSERT INTO `exam_question` VALUES (47, 10, 1127);
INSERT INTO `exam_question` VALUES (48, 10, 1138);
INSERT INTO `exam_question` VALUES (49, 10, 1113);
INSERT INTO `exam_question` VALUES (50, 10, 1139);
INSERT INTO `exam_question` VALUES (51, 10, 1126);
INSERT INTO `exam_question` VALUES (52, 10, 1143);
INSERT INTO `exam_question` VALUES (53, 11, 1154);
INSERT INTO `exam_question` VALUES (54, 11, 1106);
INSERT INTO `exam_question` VALUES (55, 11, 1141);
INSERT INTO `exam_question` VALUES (56, 11, 1155);
INSERT INTO `exam_question` VALUES (57, 11, 1087);
INSERT INTO `exam_question` VALUES (58, 11, 1079);
INSERT INTO `exam_question` VALUES (59, 11, 1160);
INSERT INTO `exam_question` VALUES (60, 11, 1092);
INSERT INTO `exam_question` VALUES (61, 11, 1090);
INSERT INTO `exam_question` VALUES (62, 11, 1105);
INSERT INTO `exam_question` VALUES (63, 11, 1094);
INSERT INTO `exam_question` VALUES (64, 11, 1142);
INSERT INTO `exam_question` VALUES (65, 11, 1086);
INSERT INTO `exam_question` VALUES (66, 11, 1107);
INSERT INTO `exam_question` VALUES (67, 11, 1117);
INSERT INTO `exam_question` VALUES (68, 11, 1163);
INSERT INTO `exam_question` VALUES (69, 11, 1161);
INSERT INTO `exam_question` VALUES (70, 11, 1115);
INSERT INTO `exam_question` VALUES (71, 11, 1104);
INSERT INTO `exam_question` VALUES (72, 11, 1114);
INSERT INTO `exam_question` VALUES (73, 12, 1082);
INSERT INTO `exam_question` VALUES (74, 12, 1109);
INSERT INTO `exam_question` VALUES (75, 12, 1142);
INSERT INTO `exam_question` VALUES (76, 13, 1082);
INSERT INTO `exam_question` VALUES (77, 13, 1109);
INSERT INTO `exam_question` VALUES (78, 13, 1142);
INSERT INTO `exam_question` VALUES (79, 14, 1077);
INSERT INTO `exam_question` VALUES (80, 14, 1078);
INSERT INTO `exam_question` VALUES (81, 15, 1141);
INSERT INTO `exam_question` VALUES (82, 15, 1109);
INSERT INTO `exam_question` VALUES (83, 15, 1083);
INSERT INTO `exam_question` VALUES (84, 15, 1108);
INSERT INTO `exam_question` VALUES (85, 15, 1142);
INSERT INTO `exam_question` VALUES (86, 15, 1151);
INSERT INTO `exam_question` VALUES (87, 15, 1107);
INSERT INTO `exam_question` VALUES (88, 15, 1081);
INSERT INTO `exam_question` VALUES (89, 15, 1115);
INSERT INTO `exam_question` VALUES (90, 15, 1082);
INSERT INTO `exam_question` VALUES (91, 15, 1117);
INSERT INTO `exam_question` VALUES (92, 16, 1155);
INSERT INTO `exam_question` VALUES (93, 16, 1104);
INSERT INTO `exam_question` VALUES (94, 16, 1080);
INSERT INTO `exam_question` VALUES (95, 16, 1157);
INSERT INTO `exam_question` VALUES (96, 16, 1167);
INSERT INTO `exam_question` VALUES (97, 16, 1090);
INSERT INTO `exam_question` VALUES (98, 16, 1163);
INSERT INTO `exam_question` VALUES (99, 16, 1161);
INSERT INTO `exam_question` VALUES (100, 17, 1076);
INSERT INTO `exam_question` VALUES (101, 18, 1076);
INSERT INTO `exam_question` VALUES (102, 18, 1081);
INSERT INTO `exam_question` VALUES (103, 18, 1077);
INSERT INTO `exam_question` VALUES (104, 18, 1082);
INSERT INTO `exam_question` VALUES (105, 18, 1086);

-- ----------------------------
-- Table structure for exam_question_link
-- ----------------------------
DROP TABLE IF EXISTS `exam_question_link`;
CREATE TABLE `exam_question_link`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `exam_id` bigint NOT NULL,
  `question_id` bigint NOT NULL,
  `sort_order` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `exam_id`(`exam_id` ASC) USING BTREE,
  INDEX `question_id`(`question_id` ASC) USING BTREE,
  CONSTRAINT `exam_question_link_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `exam_paper` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `exam_question_link_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `question_bank` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_question_link
-- ----------------------------

-- ----------------------------
-- Table structure for exam_result
-- ----------------------------
DROP TABLE IF EXISTS `exam_result`;
CREATE TABLE `exam_result`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `exam_id` bigint NOT NULL COMMENT '考试ID',
  `student_id` bigint NOT NULL COMMENT '学生ID',
  `total_questions` int NOT NULL COMMENT '总题数',
  `correct_answers` int NOT NULL COMMENT '正确题数',
  `wrong_answers` int NOT NULL COMMENT '错误题数',
  `score` decimal(5, 2) NOT NULL COMMENT '得分',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'submitted' COMMENT '状态：submitted-已提交，graded-已批阅，reviewed-已审核',
  `ai_feedback` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI批阅反馈',
  `submitted_at` datetime NOT NULL COMMENT '提交时间',
  `graded_at` datetime NULL DEFAULT NULL COMMENT '批阅时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_exam_id`(`exam_id` ASC) USING BTREE,
  INDEX `idx_student_id`(`student_id` ASC) USING BTREE,
  INDEX `idx_submitted_at`(`submitted_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '考试结果表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_result
-- ----------------------------
INSERT INTO `exam_result` VALUES (34, 9, 1, 5, 0, 5, 0.00, 'graded', '考试批阅完成！\n\n总分：0.0分\n正确率：0.0% (0/5题)\n\n💪 不及格！建议系统性地重新学习相关课程内容。', '2025-09-12 20:34:32', '2025-09-12 20:34:32', '2025-09-12 20:34:32');
INSERT INTO `exam_result` VALUES (35, 10, 1, 19, 0, 19, 0.00, 'graded', '考试批阅完成！\n\n总分：0.0分\n正确率：0.0% (0/19题)\n\n💪 不及格！建议系统性地重新学习相关课程内容。', '2025-09-12 20:36:59', '2025-09-12 20:36:59', '2025-09-12 20:36:59');
INSERT INTO `exam_result` VALUES (36, 11, 1, 20, 2, 18, 20.00, 'graded', '考试批阅完成！\n\n总分：20.0分\n正确率：10.0% (2/20题)\n\n💪 不及格！建议系统性地重新学习相关课程内容。', '2025-09-13 00:09:30', '2025-09-13 00:09:30', '2025-09-13 00:09:30');
INSERT INTO `exam_result` VALUES (37, 13, 1, 3, 1, 2, 10.00, 'graded', '考试批阅完成！\n\n总分：10.0分\n正确率：33.3% (1/3题)\n\n💪 不及格！建议系统性地重新学习相关课程内容。', '2025-09-13 15:14:35', '2025-09-13 15:14:35', '2025-09-13 15:14:35');
INSERT INTO `exam_result` VALUES (38, 12, 1, 3, 1, 2, 33.00, 'graded', '考试批阅完成！\n\n总分：33.0分\n正确率：33.3% (1/3题)\n\n💪 不及格！建议系统性地重新学习相关课程内容。', '2025-09-13 15:29:04', '2025-09-13 15:29:04', '2025-09-13 15:29:04');
INSERT INTO `exam_result` VALUES (39, 14, 1, 2, 0, 2, 0.00, 'graded', '考试批阅完成！\n\n总分：0.0分\n正确率：0.0% (0/2题)\n\n💪 不及格！建议系统性地重新学习相关课程内容。', '2025-09-15 19:58:21', '2025-09-15 19:58:21', '2025-09-15 19:58:21');
INSERT INTO `exam_result` VALUES (40, 16, 1, 8, 1, 7, 13.00, 'graded', '考试批阅完成！\n\n总分：13.0分\n正确率：12.5% (1/8题)\n\n💪 不及格！建议系统性地重新学习相关课程内容。', '2025-09-17 14:38:26', '2025-09-17 14:38:26', '2025-09-17 14:38:26');
INSERT INTO `exam_result` VALUES (41, 18, 1, 5, 0, 5, 0.00, 'graded', '考试批阅完成！\n\n总分：0.0分\n正确率：0.0% (0/5题)\n\n💪 不及格！建议系统性地重新学习相关课程内容。', '2025-09-18 16:43:29', '2025-09-18 16:43:29', '2025-09-18 16:43:29');

-- ----------------------------
-- Table structure for exam_submission
-- ----------------------------
DROP TABLE IF EXISTS `exam_submission`;
CREATE TABLE `exam_submission`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `exam_id` bigint NOT NULL,
  `student_id` bigint NOT NULL,
  `started_at` datetime NULL DEFAULT NULL,
  `submitted_at` datetime NULL DEFAULT NULL,
  `score` int NULL DEFAULT NULL,
  `proctoring_snapshots` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_submission
-- ----------------------------

-- ----------------------------
-- Table structure for exam_submission_detail
-- ----------------------------
DROP TABLE IF EXISTS `exam_submission_detail`;
CREATE TABLE `exam_submission_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `submission_id` bigint NOT NULL,
  `question_id` bigint NOT NULL,
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `correct` tinyint(1) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `submission_id`(`submission_id` ASC) USING BTREE,
  INDEX `question_id`(`question_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_submission_detail
-- ----------------------------

-- ----------------------------
-- Table structure for gen_table
-- ----------------------------
DROP TABLE IF EXISTS `gen_table`;
CREATE TABLE `gen_table`  (
  `table_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '表名称',
  `table_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '表描述',
  `sub_table_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '子表关联的外键名',
  `class_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '实体类名称',
  `tpl_category` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作）',
  `tpl_web_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '前端模板类型（element-ui模版 element-plus模版）',
  `package_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成功能名',
  `function_author` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成功能作者',
  `gen_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
  `gen_path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
  `options` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '其它生成选项',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`table_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '代码生成业务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table
-- ----------------------------
INSERT INTO `gen_table` VALUES (1, 'user', '人员管理', NULL, NULL, 'User', 'crud', 'element-plus', 'com.ruoyi.user', 'user', 'user', '人员管理', 'zhangzheng', '0', '/', '{\"parentMenuId\":4}', 'admin', '2025-07-15 16:32:21', '', '2025-07-15 17:35:44', NULL);
INSERT INTO `gen_table` VALUES (2, 'resource_file', '课件资源', NULL, NULL, 'ResourceFile', 'crud', 'element-plus', 'com.ruoyi.file', 'file', 'file', '课件管理', 'zhangzheng', '0', '/', '{\"parentMenuId\":2007}', 'admin', '2025-07-15 18:21:37', '', '2025-07-15 18:55:54', NULL);
INSERT INTO `gen_table` VALUES (3, 'course', '课程管理', NULL, NULL, 'Course', 'crud', 'element-plus', 'com.ruoyi.course', 'daping', 'daping', '智教大屏', 'ruoyi', '0', '/', '{\"parentMenuId\":2020}', 'admin', '2025-07-15 18:38:13', '', '2025-07-15 22:04:06', NULL);
INSERT INTO `gen_table` VALUES (4, 'assignment', '作业练习管理', NULL, NULL, 'Assignment', 'crud', 'element-plus', 'com.ruoyi.assignment', 'assignment', 'assignment', '作业练习管理', 'zhangzheng', '0', '/', '{\"parentMenuId\":2007}', 'admin', '2025-07-15 21:12:47', '', '2025-07-15 21:20:04', NULL);
INSERT INTO `gen_table` VALUES (5, 'question_bank', '题目管理', NULL, NULL, 'QuestionBank', 'crud', 'element-plus', 'com.ruoyi.bank', 'bank', 'bank', '练习管理', 'zhangzheng', '0', '/', '{\"parentMenuId\":2007}', 'admin', '2025-07-16 13:46:33', '', '2025-07-16 14:53:17', NULL);

-- ----------------------------
-- Table structure for gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS `gen_table_column`;
CREATE TABLE `gen_table_column`  (
  `column_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_id` bigint NULL DEFAULT NULL COMMENT '归属表编号',
  `column_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列名称',
  `column_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'JAVA类型',
  `java_field` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'JAVA字段名',
  `is_pk` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否主键（1是）',
  `is_increment` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否自增（1是）',
  `is_required` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否必填（1是）',
  `is_insert` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否为插入字段（1是）',
  `is_edit` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否编辑字段（1是）',
  `is_list` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否列表字段（1是）',
  `is_query` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否查询字段（1是）',
  `query_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
  `html_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  `dict_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `sort` int NULL DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '代码生成业务表字段' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table_column
-- ----------------------------
INSERT INTO `gen_table_column` VALUES (1, 1, 'id', NULL, 'bigint', 'Long', 'id', '1', '1', '0', '0', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-07-15 16:32:21', '', '2025-07-15 17:35:44');
INSERT INTO `gen_table_column` VALUES (2, 1, 'username', '用户名', 'varchar(50)', 'String', 'username', '0', '0', '1', '1', '1', '1', '1', 'LIKE', 'input', '', 2, 'admin', '2025-07-15 16:32:21', '', '2025-07-15 17:35:44');
INSERT INTO `gen_table_column` VALUES (3, 1, 'password', '密码', 'varchar(255)', 'String', 'password', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'input', '', 3, 'admin', '2025-07-15 16:32:21', '', '2025-07-15 17:35:44');
INSERT INTO `gen_table_column` VALUES (4, 1, 'role', '角色', 'enum(\'admin\',\'teacher\',\'student\')', 'String', 'role', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'select', '', 4, 'admin', '2025-07-15 16:32:21', '', '2025-07-15 17:35:44');
INSERT INTO `gen_table_column` VALUES (5, 1, 'real_name', '姓名', 'varchar(50)', 'String', 'realName', '0', '0', '1', '1', '1', '1', '1', 'LIKE', 'input', '', 5, 'admin', '2025-07-15 16:32:21', '', '2025-07-15 17:35:44');
INSERT INTO `gen_table_column` VALUES (6, 1, 'email', '邮箱', 'varchar(100)', 'String', 'email', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'input', '', 6, 'admin', '2025-07-15 16:32:21', '', '2025-07-15 17:35:44');
INSERT INTO `gen_table_column` VALUES (7, 1, 'created_at', '创建时间', 'datetime', 'Date', 'createdAt', '0', '0', '0', '0', '0', '1', '0', 'EQ', 'datetime', '', 7, 'admin', '2025-07-15 16:32:21', '', '2025-07-15 17:35:44');
INSERT INTO `gen_table_column` VALUES (8, 1, 'last_login', '最后登录时间', 'datetime', 'Date', 'lastLogin', '0', '0', '0', '0', '0', '1', '0', 'EQ', 'datetime', '', 8, 'admin', '2025-07-15 16:32:21', '', '2025-07-15 17:35:44');
INSERT INTO `gen_table_column` VALUES (9, 2, 'id', NULL, 'bigint', 'Long', 'id', '1', '1', '0', '0', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-07-15 18:21:37', '', '2025-07-15 18:55:54');
INSERT INTO `gen_table_column` VALUES (10, 2, 'course_id', '学科名', 'bigint', 'Long', 'courseId', '0', '0', '0', '0', '0', '0', '1', 'EQ', 'input', '', 2, 'admin', '2025-07-15 18:21:37', '', '2025-07-15 18:55:54');
INSERT INTO `gen_table_column` VALUES (11, 2, 'teacher_id', NULL, 'bigint', 'Long', 'teacherId', '0', '0', '0', '0', '0', '0', '0', 'EQ', 'input', '', 3, 'admin', '2025-07-15 18:21:37', '', '2025-07-15 18:55:54');
INSERT INTO `gen_table_column` VALUES (12, 2, 'file_name', '文件名', 'varchar(100)', 'String', 'fileName', '0', '0', '0', '0', '0', '1', '1', 'LIKE', 'input', '', 4, 'admin', '2025-07-15 18:21:37', '', '2025-07-15 18:55:54');
INSERT INTO `gen_table_column` VALUES (13, 2, 'file_path', '文件路径', 'varchar(255)', 'String', 'filePath', '0', '0', '0', '0', '0', '1', '0', 'EQ', 'input', '', 5, 'admin', '2025-07-15 18:21:37', '', '2025-07-15 18:55:54');
INSERT INTO `gen_table_column` VALUES (14, 2, 'uploaded_at', '创建时间', 'datetime', 'Date', 'uploadedAt', '0', '0', '0', '0', '0', '1', '0', 'EQ', 'datetime', '', 6, 'admin', '2025-07-15 18:21:37', '', '2025-07-15 18:55:54');
INSERT INTO `gen_table_column` VALUES (15, 3, 'id', NULL, 'bigint', 'Long', 'id', '1', '1', '0', '0', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-07-15 18:38:13', '', '2025-07-15 22:04:06');
INSERT INTO `gen_table_column` VALUES (16, 3, 'course_name', '课程名', 'varchar(100)', 'String', 'courseName', '0', '0', '1', '1', '1', '1', '1', 'LIKE', 'input', '', 2, 'admin', '2025-07-15 18:38:13', '', '2025-07-15 22:04:06');
INSERT INTO `gen_table_column` VALUES (17, 3, 'description', '课程描述', 'text', 'String', 'description', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'textarea', '', 3, 'admin', '2025-07-15 18:38:13', '', '2025-07-15 22:04:06');
INSERT INTO `gen_table_column` VALUES (18, 3, 'teacher_id', '创建人', 'bigint', 'Long', 'teacherId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 4, 'admin', '2025-07-15 18:38:13', '', '2025-07-15 22:04:06');
INSERT INTO `gen_table_column` VALUES (19, 3, 'created_at', '创建时间', 'datetime', 'Date', 'createdAt', '0', '0', '0', '0', '0', '1', '0', 'EQ', 'datetime', '', 5, 'admin', '2025-07-15 18:38:13', '', '2025-07-15 22:04:06');
INSERT INTO `gen_table_column` VALUES (20, 3, 'course_image', '课程封面图', 'varchar(255)', 'String', 'courseImage', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'imageUpload', '', 6, 'admin', '2025-07-15 18:38:13', '', '2025-07-15 22:04:06');
INSERT INTO `gen_table_column` VALUES (21, 3, 'teaching_goal', '教学目标', 'text', 'String', 'teachingGoal', '0', '0', '0', '1', '1', '0', '0', 'EQ', 'textarea', '', 7, 'admin', '2025-07-15 18:38:13', '', '2025-07-15 22:04:06');
INSERT INTO `gen_table_column` VALUES (22, 3, 'teaching_principle', '教学原则', 'text', 'String', 'teachingPrinciple', '0', '0', '0', '1', '1', '0', '0', 'EQ', 'textarea', '', 8, 'admin', '2025-07-15 18:38:13', '', '2025-07-15 22:04:06');
INSERT INTO `gen_table_column` VALUES (23, 3, 'course_background', '课程背景', 'text', 'String', 'courseBackground', '0', '0', '0', '1', '1', '0', '0', 'EQ', 'textarea', '', 9, 'admin', '2025-07-15 18:38:13', '', '2025-07-15 22:04:06');
INSERT INTO `gen_table_column` VALUES (24, 3, 'course_intro', '课程介绍', 'text', 'String', 'courseIntro', '0', '0', '0', '1', '1', '0', '0', 'EQ', 'textarea', '', 10, 'admin', '2025-07-15 18:38:13', '', '2025-07-15 22:04:06');
INSERT INTO `gen_table_column` VALUES (25, 4, 'id', '作业ID', 'bigint', 'Long', 'id', '1', '1', '0', '0', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-07-15 21:12:47', '', '2025-07-15 21:20:04');
INSERT INTO `gen_table_column` VALUES (26, 4, 'course_id', '课程ID', 'bigint', 'Long', 'courseId', '0', '0', '1', '1', '1', '0', '1', 'EQ', 'select', '', 2, 'admin', '2025-07-15 21:12:47', '', '2025-07-15 21:20:04');
INSERT INTO `gen_table_column` VALUES (27, 4, 'teacher_id', '教师ID', 'bigint', 'Long', 'teacherId', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'input', '', 3, 'admin', '2025-07-15 21:12:47', '', '2025-07-15 21:20:04');
INSERT INTO `gen_table_column` VALUES (28, 4, 'title', '作业标题', 'varchar(100)', 'String', 'title', '0', '0', '1', '1', '1', '1', '1', 'LIKE', 'input', '', 4, 'admin', '2025-07-15 21:12:47', '', '2025-07-15 21:20:04');
INSERT INTO `gen_table_column` VALUES (29, 4, 'description', '作业说明', 'text', 'String', 'description', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'textarea', '', 5, 'admin', '2025-07-15 21:12:47', '', '2025-07-15 21:20:04');
INSERT INTO `gen_table_column` VALUES (30, 4, 'due_date', '截止时间', 'datetime', 'Date', 'dueDate', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'datetime', '', 6, 'admin', '2025-07-15 21:12:47', '', '2025-07-15 21:20:04');
INSERT INTO `gen_table_column` VALUES (31, 4, 'created_at', '创建时间', 'datetime', 'Date', 'createdAt', '0', '0', '0', '0', '0', '1', '0', 'EQ', 'datetime', '', 7, 'admin', '2025-07-15 21:12:47', '', '2025-07-15 21:20:04');
INSERT INTO `gen_table_column` VALUES (32, 5, 'id', NULL, 'bigint', 'Long', 'id', '1', '1', '0', '0', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-07-16 13:46:33', '', '2025-07-16 14:53:17');
INSERT INTO `gen_table_column` VALUES (33, 5, 'course_id', '学科名', 'bigint', 'Long', 'courseId', '0', '0', '1', '1', '1', '0', '1', 'EQ', 'input', '', 2, 'admin', '2025-07-16 13:46:33', '', '2025-07-16 14:53:17');
INSERT INTO `gen_table_column` VALUES (34, 5, 'type', '题目类型', 'enum(\'choice\',\'short_answer\',\'programming\')', 'String', 'type', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'select', 'quertion_type', 3, 'admin', '2025-07-16 13:46:33', '', '2025-07-16 14:53:17');
INSERT INTO `gen_table_column` VALUES (35, 5, 'content', '题目内容', 'text', 'String', 'content', '0', '0', '1', '1', '1', '1', '1', 'LIKE', 'editor', '', 4, 'admin', '2025-07-16 13:46:33', '', '2025-07-16 14:53:17');
INSERT INTO `gen_table_column` VALUES (36, 5, 'answer', '题目答案', 'text', 'String', 'answer', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'textarea', '', 5, 'admin', '2025-07-16 13:46:33', '', '2025-07-16 14:53:17');
INSERT INTO `gen_table_column` VALUES (37, 5, 'knowledge_point', '知识点', 'varchar(255)', 'String', 'knowledgePoint', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'input', '', 6, 'admin', '2025-07-16 13:46:33', '', '2025-07-16 14:53:17');
INSERT INTO `gen_table_column` VALUES (38, 5, 'created_by', NULL, 'bigint', 'Long', 'createdBy', '0', '0', '0', '0', '0', '0', '0', 'EQ', 'input', '', 7, 'admin', '2025-07-16 13:46:33', '', '2025-07-16 14:53:17');
INSERT INTO `gen_table_column` VALUES (39, 5, 'created_at', '创建时间', 'datetime', 'Date', 'createdAt', '0', '0', '0', '0', '0', '1', '0', 'EQ', 'datetime', '', 8, 'admin', '2025-07-16 13:46:33', '', '2025-07-16 14:53:17');

-- ----------------------------
-- Table structure for knowledge_doc
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_doc`;
CREATE TABLE `knowledge_doc`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_id` bigint NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `file_size` int NULL DEFAULT NULL,
  `uploaded_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_file_path`(`file_path` ASC) USING BTREE,
  INDEX `idx_course_id`(`course_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of knowledge_doc
-- ----------------------------
INSERT INTO `knowledge_doc` VALUES (1, 102, '计算机网络期末考试真题.docx', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/a9dae44a-e0e4-4b08-a8ee-1cf442e12638-计算机网络期末考试真题.docx', 11590, '2025-09-03 20:07:13');
INSERT INTO `knowledge_doc` VALUES (2, 102, '计算机网络知识点汇总.pdf', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/3ffe4a09-a5c1-4ba8-bf57-114f989ef01c-计算机网络知识点汇总.pdf', 105335, '2025-09-03 20:08:08');
INSERT INTO `knowledge_doc` VALUES (3, 101, 'cp07-样章示例-TensorFlow.js应用开发.docx', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/95ff1eb3-8398-4922-aff3-2a703de47ba5-cp07-样章示例-TensorFlow.js应用开发.docx', 1025232, '2025-09-03 20:08:23');
INSERT INTO `knowledge_doc` VALUES (4, 101, '嵌入式系统开发教学大纲.docx', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/d1d452b9-c8f5-40b3-86df-364e5b9fe4fe-嵌入式系统开发教学大纲.docx', 42544, '2025-09-03 20:08:27');
INSERT INTO `knowledge_doc` VALUES (5, 101, 'cp08-样章示例-TensorFlow Lite.docx', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/eeeaf179-ebe9-428f-9044-b95f37432122-cp08-样章示例-TensorFlow Lite.docx', 1621363, '2025-09-03 20:22:29');
INSERT INTO `knowledge_doc` VALUES (6, 101, '嵌入式开发进阶_2025-09-17.docx', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/1316c916-1c66-4cac-8f1a-4eb5840932cf-嵌入式开发进阶_2025-09-17.docx', 9110, '2025-09-18 15:24:25');
INSERT INTO `knowledge_doc` VALUES (12, 101, '嵌入式开发进阶_2025-09-17.docx', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/0e9ceace-1948-4ef9-ada4-be512b1e64be-嵌入式开发进阶_2025-09-17.docx', 9110, '2025-09-18 15:27:16');

-- ----------------------------
-- Table structure for knowledge_point
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_point`;
CREATE TABLE `knowledge_point`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '知识点ID',
  `chapter_id` bigint NOT NULL COMMENT '所属章节ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '知识点标题',
  `detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '详细描述',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `chapter_id`(`chapter_id` ASC) USING BTREE,
  CONSTRAINT `knowledge_point_ibfk_1` FOREIGN KEY (`chapter_id`) REFERENCES `chapter` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of knowledge_point
-- ----------------------------
INSERT INTO `knowledge_point` VALUES (1, 1, '嵌入式系统定义', '嵌入式系统的基本概念和特点', '2025-07-27 20:53:58');
INSERT INTO `knowledge_point` VALUES (2, 1, '嵌入式系统分类', '不同类型的嵌入式系统介绍', '2025-07-27 20:53:58');
INSERT INTO `knowledge_point` VALUES (3, 2, '处理器架构类型', '常见的嵌入式处理器架构', '2025-07-27 20:53:58');
INSERT INTO `knowledge_point` VALUES (4, 2, '存储器结构', '嵌入式系统中的存储器层次', '2025-07-27 20:53:58');
INSERT INTO `knowledge_point` VALUES (5, 3, '嵌入式操作系统', '实时操作系统及其特点', '2025-07-27 20:53:58');
INSERT INTO `knowledge_point` VALUES (6, 3, '交叉编译工具链', '嵌入式软件开发的编译工具', '2025-07-27 20:53:58');
INSERT INTO `knowledge_point` VALUES (7, 3, '调试与仿真', '嵌入式软件的调试方法', '2025-07-27 20:53:58');
INSERT INTO `knowledge_point` VALUES (8, 4, '实时操作系统内核', 'RTOS的内核结构和机制', '2025-07-27 20:53:58');
INSERT INTO `knowledge_point` VALUES (9, 4, '任务调度', '多任务调度算法与实现', '2025-07-27 20:53:58');
INSERT INTO `knowledge_point` VALUES (10, 4, '中断管理', '中断的响应与处理机制', '2025-07-27 20:53:58');
INSERT INTO `knowledge_point` VALUES (11, 5, '串口通信', '基于UART的通信原理', '2025-07-27 20:53:58');
INSERT INTO `knowledge_point` VALUES (12, 5, '总线通信', '常用总线协议（I2C、SPI）介绍', '2025-07-27 20:53:58');
INSERT INTO `knowledge_point` VALUES (13, 5, '无线通信基础', '嵌入式系统中的无线通信技术', '2025-07-27 20:53:58');
INSERT INTO `knowledge_point` VALUES (14, 6, '硬件调试工具', '示波器、逻辑分析仪使用', '2025-07-27 20:53:58');
INSERT INTO `knowledge_point` VALUES (15, 6, '软件调试技术', '断点调试、单步执行', '2025-07-27 20:53:58');
INSERT INTO `knowledge_point` VALUES (16, 6, '测试方法', '单元测试与集成测试', '2025-07-27 20:53:58');

-- ----------------------------
-- Table structure for lesson_plan
-- ----------------------------
DROP TABLE IF EXISTS `lesson_plan`;
CREATE TABLE `lesson_plan`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_id` bigint NOT NULL,
  `teacher_id` bigint NOT NULL,
  `plan_title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `course_id`(`course_id` ASC) USING BTREE,
  INDEX `teacher_id`(`teacher_id` ASC) USING BTREE,
  CONSTRAINT `lesson_plan_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `lesson_plan_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of lesson_plan
-- ----------------------------
INSERT INTO `lesson_plan` VALUES (1, 101, 2, '嵌入式开发怎么学', '【教学目标】\n1. 掌握嵌入式系统的基本组成、工作原理；\n2. 理解嵌入式处理器与常见开发平台的使用方法；\n3. 培养学生进行嵌入式系统应用开发的能力。\n\n【教学内容与知识点分布】\n- 第1次课：嵌入式系统概述（概念、应用领域）\n- 第2次课：嵌入式处理器结构（ARM架构等）\n- 第3次课：嵌入式操作系统（RTOS基本功能）\n- 第4次课：I/O接口基础（GPIO、UART等）\n- 第5次课：通信协议（I2C、SPI等）\n- 第6次课：软件开发工具与调试方法（Keil、JTAG）\n- 第7次课：项目实训设计讲解\n- 第8次课：项目实训实现与总结（STM32温度系统）\n\n【教学方式】\n- 理论讲授 + 实验操作 + 项目驱动学习', '2025-07-13 13:32:01');
INSERT INTO `lesson_plan` VALUES (2, 101, 2, '嵌入式开发怎么学', '【教学目标】\n1. 掌握嵌入式系统的基本组成、工作原理；\n2. 理解嵌入式处理器与常见开发平台的使用方法；\n3. 培养学生进行嵌入式系统应用开发的能力。\n\n【教学内容与知识点分布】\n- 第1次课：嵌入式系统概述（概念、应用领域）\n- 第2次课：嵌入式处理器结构（ARM架构等）\n- 第3次课：嵌入式操作系统（RTOS基本功能）\n- 第4次课：I/O接口基础（GPIO、UART等）\n- 第5次课：通信协议（I2C、SPI等）\n- 第6次课：软件开发工具与调试方法（Keil、JTAG）\n- 第7次课：项目实训设计讲解\n- 第8次课：项目实训实现与总结（STM32温度系统）\n\n【教学方式】\n- 理论讲授 + 实验操作 + 项目驱动学习', '2025-07-15 19:22:11');

-- ----------------------------
-- Table structure for notification
-- ----------------------------
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知内容',
  `sender_id` bigint NOT NULL COMMENT '发送者ID',
  `sender_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '发送者姓名',
  `receiver_id` bigint NULL DEFAULT NULL COMMENT '接收者ID（为空表示广播通知）',
  `receiver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '接收者姓名',
  `is_important` tinyint(1) NULL DEFAULT 0 COMMENT '是否重要 0-普通 1-重要',
  `course_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '课程名称',
  `notification_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'notification' COMMENT '通知类型',
  `send_time` datetime NOT NULL COMMENT '发送时间',
  `read_time` datetime NULL DEFAULT NULL COMMENT '阅读时间',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'sent' COMMENT '通知状态',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_receiver_id`(`receiver_id` ASC) USING BTREE,
  INDEX `idx_sender_id`(`sender_id` ASC) USING BTREE,
  INDEX `idx_send_time`(`send_time` ASC) USING BTREE,
  INDEX `idx_notification_type`(`notification_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通知表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notification
-- ----------------------------
INSERT INTO `notification` VALUES (1, '【重要提醒】期末学习考试提醒', '亲爱的同学们：目前已陆续有学校进入考试阶段，请同学们合理安排复习时间，做好充分准备。', 2, '张磊', NULL, NULL, 1, '数据结构', 'notification', '2025-09-01 08:00:00', NULL, 'sent', '2025-09-02 10:21:58', '2025-09-02 10:21:58');
INSERT INTO `notification` VALUES (2, '【系统通知】学习平台功能更新公告', '为了提供更好的学习体验，我们对学习平台进行了功能更新。新增了智能推荐系统。', 4, '若依', NULL, NULL, 0, '系统通知', 'notification', '2025-09-01 10:00:00', NULL, 'sent', '2025-09-02 10:21:58', '2025-09-02 10:21:58');
INSERT INTO `notification` VALUES (3, '【课程通知】数据结构实验课安排', '各位同学，本周的数据结构实验课将安排在周三下午2:00-4:00，地点在计算机实验室A201。', 2, '张磊', NULL, NULL, 0, '数据结构', 'notification', '2025-09-01 11:30:00', NULL, 'sent', '2025-09-02 10:21:58', '2025-09-02 10:21:58');
INSERT INTO `notification` VALUES (4, '【个人通知】作业提交提醒', '张政同学，你的数据结构作业《栈和队列的应用》还未提交，截止时间为明天晚上23:59。', 2, '张磊', 1, '张政', 1, '数据结构', 'notification', '2025-09-01 15:00:00', NULL, 'sent', '2025-09-02 10:21:58', '2025-09-02 10:21:58');
INSERT INTO `notification` VALUES (5, '【个人通知】成绩查询通知', '梁本华同学，你的数据结构期中考试成绩已发布，请登录系统查看详细成绩。', 2, '张磊', 3, '梁本华', 0, '数据结构', 'notification', '2025-09-01 16:00:00', '2025-09-01 16:30:00', 'sent', '2025-09-02 10:21:58', '2025-09-02 10:21:58');
INSERT INTO `notification` VALUES (6, '【个人通知】学习进度提醒', '小贝同学，你的学习进度需要加快，建议每天至少完成2小时的课程学习。', 2, '张磊', 9, '小贝', 0, '数据结构', 'notification', '2025-09-01 17:00:00', NULL, 'sent', '2025-09-02 10:21:58', '2025-09-02 10:21:58');
INSERT INTO `notification` VALUES (7, '【系统维护】平台维护通知', '系统将于本周六凌晨2:00-4:00进行维护升级，期间可能影响正常使用。', 4, '若依', NULL, NULL, 1, '系统通知', 'notification', '2025-09-01 18:00:00', NULL, 'sent', '2025-09-02 10:21:58', '2025-09-02 10:21:58');
INSERT INTO `notification` VALUES (8, '【教师通知】教学计划更新', '张磊老师，下学期的教学计划已更新，请查看并确认课程安排。', 4, '若依', 2, '张磊', 0, '教学管理', 'notification', '2025-09-01 19:00:00', NULL, 'sent', '2025-09-02 10:21:58', '2025-09-02 10:21:58');

-- ----------------------------
-- Table structure for notification_read_record
-- ----------------------------
DROP TABLE IF EXISTS `notification_read_record`;
CREATE TABLE `notification_read_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `notification_id` bigint NOT NULL COMMENT '通知ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `read_time` datetime NOT NULL COMMENT '阅读时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_notification_user`(`notification_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_read_time`(`read_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通知阅读记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notification_read_record
-- ----------------------------
INSERT INTO `notification_read_record` VALUES (1, 7, 1, '2025-09-16 22:50:22', '2025-09-02 10:27:14');
INSERT INTO `notification_read_record` VALUES (3, 4, 1, '2025-09-02 10:29:35', '2025-09-02 10:27:16');
INSERT INTO `notification_read_record` VALUES (6, 2, 1, '2025-09-02 10:29:45', '2025-09-02 10:29:44');
INSERT INTO `notification_read_record` VALUES (7, 1, 1, '2025-09-02 10:29:55', '2025-09-02 10:29:45');
INSERT INTO `notification_read_record` VALUES (10, 9, 1, '2025-09-02 10:45:14', '2025-09-02 10:45:07');

-- ----------------------------
-- Table structure for practice_log
-- ----------------------------
DROP TABLE IF EXISTS `practice_log`;
CREATE TABLE `practice_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL,
  `question_id` bigint NOT NULL,
  `answer_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `is_correct` tinyint(1) NOT NULL,
  `score` int NOT NULL,
  `error_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `submitted_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 29 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of practice_log
-- ----------------------------
INSERT INTO `practice_log` VALUES (1, 1, 1001, 'B', 0, 0, '概念理解错误', '2025-08-07 13:08:12');
INSERT INTO `practice_log` VALUES (2, 1, 1001, 'C', 0, 0, '混淆概念', '2025-08-07 13:08:12');
INSERT INTO `practice_log` VALUES (3, 1, 1001, 'A', 1, 100, NULL, '2025-08-07 13:08:12');
INSERT INTO `practice_log` VALUES (4, 1, 1002, 'B', 0, 0, '特点掌握不全面', '2025-08-07 13:08:12');
INSERT INTO `practice_log` VALUES (5, 1, 1002, 'A', 1, 100, NULL, '2025-08-07 13:08:12');
INSERT INTO `practice_log` VALUES (6, 1, 1003, 'A', 0, 0, '架构特点理解错误', '2025-08-07 13:08:12');
INSERT INTO `practice_log` VALUES (7, 1, 1003, 'B', 0, 0, '混淆架构特点', '2025-08-07 13:08:12');
INSERT INTO `practice_log` VALUES (8, 1, 1003, 'C', 1, 100, NULL, '2025-08-07 13:08:12');
INSERT INTO `practice_log` VALUES (9, 1, 1004, 'B', 0, 0, '功能理解不全面', '2025-08-07 13:08:12');
INSERT INTO `practice_log` VALUES (10, 1, 1004, 'A', 1, 100, NULL, '2025-08-07 13:08:12');
INSERT INTO `practice_log` VALUES (11, 1, 1005, 'A', 0, 0, '流程理解错误', '2025-08-07 13:08:12');
INSERT INTO `practice_log` VALUES (12, 1, 1005, 'B', 1, 100, NULL, '2025-08-07 13:08:12');
INSERT INTO `practice_log` VALUES (13, 1, 79, '666', 0, 0, '学生答案\'666\'与题目要求的GPIO控制代码完全无关，未提供有效实现LED闪烁的代码内容', NULL);
INSERT INTO `practice_log` VALUES (14, 1, 1006, '666', 0, 0, '学生答案\'666\'与题目要求完全不符，未选择任何选项，未给出有效答案', NULL);
INSERT INTO `practice_log` VALUES (15, 2, 5, '错误答案', 0, 0, NULL, '2025-08-04 10:45:00');
INSERT INTO `practice_log` VALUES (16, 1, 79, 'nishi ', 0, 0, '学生答案无法解析，内容不完整或无效', NULL);
INSERT INTO `practice_log` VALUES (17, 1, 1013, '66', 0, 0, '学生答案内容不完整或无效，未能回答问题', NULL);
INSERT INTO `practice_log` VALUES (18, 1, 1055, '不知道', 0, 0, '学生未作答，答案为空', NULL);
INSERT INTO `practice_log` VALUES (19, 1, 1055, '666', 0, 0, '学生答案\'666\'与题目要求无关，未作答交叉编译的定义及其在嵌入式开发中的应用。', NULL);
INSERT INTO `practice_log` VALUES (20, 1, 1055, '212', 0, 0, '学生答案\'212\'与题目要求无关，未作答交叉编译的定义及其在嵌入式开发中的应用。', NULL);
INSERT INTO `practice_log` VALUES (21, 1, 1053, '2121', 0, 0, '学生答案\'2121\'与题目要求无关，未列举任何有效的分类依据。', NULL);
INSERT INTO `practice_log` VALUES (22, 1, 1077, '1111', 0, 0, '答案内容与题目要求无关，未列举任何有效的嵌入式系统应用领域', NULL);
INSERT INTO `practice_log` VALUES (23, 1, 1078, '11111111', 0, 0, '答案与题目无关内容完全错误', NULL);
INSERT INTO `practice_log` VALUES (24, 1, 1069, '1111', 0, 0, '学生答案未提供有效程序代码，仅输入了数字1111，不符合题目要求。', NULL);
INSERT INTO `practice_log` VALUES (25, 1, 1076, '1111', 0, 0, '答案与标准答案不符，未正确描述嵌入式系统的定义', NULL);
INSERT INTO `practice_log` VALUES (26, 1, 1076, '11111', 0, 0, '学生答案为\'11111\'，与标准答案内容完全无关，未回答嵌入式系统的定义', NULL);
INSERT INTO `practice_log` VALUES (27, 1, 1092, '1111111111', 0, 0, '学生答案为无意义的数字串，与题目要求无关', NULL);
INSERT INTO `practice_log` VALUES (28, 1, 1076, '111', 0, 0, '学生答案为\'111\'，与标准答案内容完全不符，未回答嵌入式系统的定义，属于无效作答', NULL);
INSERT INTO `practice_log` VALUES (29, 1, 1076, '222', 0, 0, '学生答案为\'222\'，与标准答案无关，内容完全错误', NULL);

-- ----------------------------
-- Table structure for practice_record
-- ----------------------------
DROP TABLE IF EXISTS `practice_record`;
CREATE TABLE `practice_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL COMMENT '学生ID',
  `course_id` bigint NOT NULL COMMENT '课程ID',
  `total_questions` int NOT NULL COMMENT '总题目数',
  `correct_count` int NOT NULL COMMENT '正确题目数',
  `wrong_count` int NOT NULL COMMENT '错误题目数',
  `unanswered_count` int NOT NULL COMMENT '未答题目数',
  `accuracy_rate` int NOT NULL COMMENT '正确率',
  `practice_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '练习类型',
  `practice_date` datetime NOT NULL COMMENT '练习时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_student_id`(`student_id` ASC) USING BTREE,
  INDEX `idx_course_id`(`course_id` ASC) USING BTREE,
  INDEX `idx_practice_date`(`practice_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 51 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '练习记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of practice_record
-- ----------------------------
INSERT INTO `practice_record` VALUES (1, 1, 101, 5, 3, 2, 0, 60, 'Choice Practice', '2024-01-15 10:30:00', '2025-08-07 13:54:19', '2025-08-07 13:54:19');
INSERT INTO `practice_record` VALUES (2, 1, 101, 5, 4, 1, 0, 80, 'Choice Practice', '2024-01-14 14:20:00', '2025-08-07 13:54:19', '2025-08-07 13:54:19');
INSERT INTO `practice_record` VALUES (3, 1, 101, 5, 2, 3, 0, 40, 'Choice Practice', '2024-01-13 09:15:00', '2025-08-07 13:54:19', '2025-08-07 13:54:19');
INSERT INTO `practice_record` VALUES (15, 1, 101, 1, 0, 1, 0, 0, 'AI自动出题', '2025-08-07 05:56:46', '2025-08-07 13:56:46', '2025-08-07 13:56:46');
INSERT INTO `practice_record` VALUES (16, 1, 101, 1, 0, 1, 0, 0, 'AI自动出题', '2025-08-07 06:10:45', '2025-08-07 14:10:45', '2025-08-07 14:10:45');
INSERT INTO `practice_record` VALUES (17, 1, 101, 2, 1, 1, 0, 50, 'AI自动出题', '2025-08-07 06:25:15', '2025-08-07 14:25:15', '2025-08-07 14:25:15');
INSERT INTO `practice_record` VALUES (18, 1, 101, 2, 1, 1, 0, 50, 'AI自动出题', '2025-08-07 07:08:23', '2025-08-07 15:08:23', '2025-08-07 15:08:23');
INSERT INTO `practice_record` VALUES (19, 1, 101, 3, 2, 1, 0, 67, 'AI自动出题', '2025-08-07 07:11:31', '2025-08-07 15:11:31', '2025-08-07 15:11:31');
INSERT INTO `practice_record` VALUES (20, 1, 101, 5, 1, 4, 0, 20, 'AI自动出题', '2025-08-07 07:13:03', '2025-08-07 15:13:03', '2025-08-07 15:13:03');
INSERT INTO `practice_record` VALUES (21, 1, 101, 2, 0, 2, 0, 0, 'AI自动出题', '2025-08-07 08:19:06', '2025-08-07 16:19:06', '2025-08-07 16:19:06');
INSERT INTO `practice_record` VALUES (22, 1, 101, 2, 0, 3, -1, 0, '训练薄弱题', '2025-08-07 08:32:42', '2025-08-07 16:32:42', '2025-08-07 16:32:42');
INSERT INTO `practice_record` VALUES (23, 1, 101, 3, 0, 3, 0, 0, '训练薄弱题', '2025-08-07 08:54:57', '2025-08-07 16:54:57', '2025-08-07 16:54:57');
INSERT INTO `practice_record` VALUES (24, 1, 101, 2, 0, 2, 0, 0, 'AI自动出题', '2025-08-07 09:33:31', '2025-08-07 17:33:31', '2025-08-07 17:33:31');
INSERT INTO `practice_record` VALUES (25, 1, 101, 2, 0, 2, 0, 0, '训练薄弱题', '2025-08-07 09:35:44', '2025-08-07 17:35:44', '2025-08-07 17:35:44');
INSERT INTO `practice_record` VALUES (26, 1, 101, 2, 1, 1, 0, 50, '训练薄弱题', '2025-08-08 16:28:54', '2025-08-09 00:28:54', '2025-08-09 00:28:54');
INSERT INTO `practice_record` VALUES (27, 1, 101, 2, 0, 2, 0, 0, 'AI自动出题', '2025-08-09 14:21:51', '2025-08-09 22:21:51', '2025-08-09 22:21:51');
INSERT INTO `practice_record` VALUES (28, 1, 101, 2, 0, 2, 0, 0, '训练薄弱题', '2025-08-09 14:23:37', '2025-08-09 22:23:37', '2025-08-09 22:23:37');
INSERT INTO `practice_record` VALUES (29, 1, 101, 1, 0, 2, -1, 0, 'AI自动出题', '2025-08-09 14:43:36', '2025-08-09 22:43:36', '2025-08-09 22:43:36');
INSERT INTO `practice_record` VALUES (30, 1, 101, 1, 0, 1, 0, 0, 'AI自动出题', '2025-08-09 14:45:41', '2025-08-09 22:45:41', '2025-08-09 22:45:41');
INSERT INTO `practice_record` VALUES (31, 1, 101, 2, 0, 2, 0, 0, 'AI自动出题', '2025-08-10 15:22:39', '2025-08-10 23:22:39', '2025-08-10 23:22:39');
INSERT INTO `practice_record` VALUES (32, 1, 101, 1, 0, 1, 0, 0, 'AI自动出题', '2025-08-10 15:26:23', '2025-08-10 23:26:23', '2025-08-10 23:26:23');
INSERT INTO `practice_record` VALUES (33, 1, 101, 1, 0, 1, 0, 0, 'AI自动出题', '2025-08-10 15:45:07', '2025-08-10 23:45:07', '2025-08-10 23:45:07');
INSERT INTO `practice_record` VALUES (34, 1, 101, 2, 2, 0, 0, 100, '训练薄弱题', '2025-08-10 15:46:03', '2025-08-10 23:46:03', '2025-08-10 23:46:03');
INSERT INTO `practice_record` VALUES (35, 1, 101, 1, 0, 1, 0, 0, 'AI自动出题', '2025-08-27 07:05:50', '2025-08-27 15:05:50', '2025-08-27 15:05:50');
INSERT INTO `practice_record` VALUES (36, 3, 101, 3, 1, 2, 0, 33, 'AI自动出题', '2025-09-02 07:05:21', '2025-09-02 15:05:21', '2025-09-02 15:05:21');
INSERT INTO `practice_record` VALUES (37, 9, 101, 1, 0, 1, 0, 0, 'AI自动出题', '2025-09-08 05:06:08', '2025-09-08 13:06:08', '2025-09-08 13:06:08');
INSERT INTO `practice_record` VALUES (38, 9, 101, 1, 0, 1, 0, 0, 'AI自动出题', '2025-09-08 05:14:03', '2025-09-08 13:14:03', '2025-09-08 13:14:03');
INSERT INTO `practice_record` VALUES (39, 1, 101, 1, 0, 1, 0, 0, 'AI自动出题', '2025-09-08 12:25:10', '2025-09-08 20:25:10', '2025-09-08 20:25:10');
INSERT INTO `practice_record` VALUES (40, 1, 101, 1, 1, 0, 0, 100, 'AI自动出题', '2025-09-08 12:28:09', '2025-09-08 20:28:10', '2025-09-08 20:28:10');
INSERT INTO `practice_record` VALUES (41, 1, 101, 1, 1, 0, 0, 100, 'AI自动出题', '2025-09-09 08:07:10', '2025-09-09 16:07:10', '2025-09-09 16:07:10');
INSERT INTO `practice_record` VALUES (42, 1, 101, 2, 1, 1, 0, 50, 'AI自动出题', '2025-09-09 14:30:05', '2025-09-09 22:30:05', '2025-09-09 22:30:05');
INSERT INTO `practice_record` VALUES (43, 1, 101, 1, 0, 1, 0, 0, 'AI自动出题', '2025-09-09 16:40:24', '2025-09-10 00:40:24', '2025-09-10 00:40:24');
INSERT INTO `practice_record` VALUES (44, 1, 101, 2, 1, 1, 0, 50, 'AI自动出题', '2025-09-10 01:58:04', '2025-09-10 09:58:04', '2025-09-10 09:58:04');
INSERT INTO `practice_record` VALUES (45, 1, 101, 2, 2, 1, -1, 100, 'AI自动出题', '2025-09-11 00:35:33', '2025-09-11 08:35:33', '2025-09-11 08:35:33');
INSERT INTO `practice_record` VALUES (46, 1, 101, 1, 0, 1, 0, 0, 'AI自动出题', '2025-09-13 07:43:36', '2025-09-13 15:43:36', '2025-09-13 15:43:36');
INSERT INTO `practice_record` VALUES (47, 1, 101, 2, 1, 3, -2, 50, 'AI自动出题', '2025-09-13 08:52:23', '2025-09-13 16:52:23', '2025-09-13 16:52:23');
INSERT INTO `practice_record` VALUES (48, 1, 101, 2, 1, 1, 0, 50, 'AI自动出题', '2025-09-17 05:42:01', '2025-09-17 13:42:01', '2025-09-17 13:42:01');
INSERT INTO `practice_record` VALUES (49, 1, 101, 3, 2, 1, 0, 67, 'AI自动出题', '2025-09-18 14:27:45', '2025-09-18 22:27:45', '2025-09-18 22:27:45');
INSERT INTO `practice_record` VALUES (50, 1, 101, 1, 0, 1, 0, 0, 'AI自动出题', '2025-09-18 14:29:42', '2025-09-18 22:29:42', '2025-09-18 22:29:42');
INSERT INTO `practice_record` VALUES (51, 1, 101, 1, 1, 0, 0, 100, 'AI自动出题', '2025-09-18 14:32:56', '2025-09-18 22:32:56', '2025-09-18 22:32:56');

-- ----------------------------
-- Table structure for practice_record_detail
-- ----------------------------
DROP TABLE IF EXISTS `practice_record_detail`;
CREATE TABLE `practice_record_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `practice_record_id` bigint NOT NULL COMMENT '练习记录ID',
  `question_id` bigint NOT NULL COMMENT '题目ID',
  `question_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '题目类型',
  `question_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '题目内容',
  `knowledge_point` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '知识点',
  `user_answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '用户答案',
  `correct_answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '正确答案',
  `score` int NOT NULL COMMENT '得分',
  `is_correct` tinyint(1) NOT NULL COMMENT '是否正确',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_practice_record_id`(`practice_record_id` ASC) USING BTREE,
  INDEX `idx_question_id`(`question_id` ASC) USING BTREE,
  CONSTRAINT `practice_record_detail_ibfk_1` FOREIGN KEY (`practice_record_id`) REFERENCES `practice_record` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 108 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '练习记录详情表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of practice_record_detail
-- ----------------------------
INSERT INTO `practice_record_detail` VALUES (29, 1, 1006, 'choice', 'What is an embedded system? A. Computer system designed for specific applications B. General purpose computer system C. Server system D. Personal computer system', '', 'A', 'A', 100, 1, '2025-08-07 13:54:19');
INSERT INTO `practice_record_detail` VALUES (30, 1, 1007, 'choice', 'What are the characteristics of embedded systems? A. High specialization, real-time performance, high reliability B. High generality, complex functions C. Large size, high power consumption D. Expensive', '嵌入式软件开发的编译工具', 'B', 'A', 0, 0, '2025-08-07 13:54:19');
INSERT INTO `practice_record_detail` VALUES (31, 1, 1008, 'choice', 'What are the characteristics of ARM architecture? A. Complex instruction set B. High power consumption design C. Reduced instruction set, low power consumption D. 32-bit only', 'ARM Processor Architecture', 'C', 'C', 100, 1, '2025-08-07 13:54:19');
INSERT INTO `practice_record_detail` VALUES (32, 1, 1009, 'choice', 'What are the main functions of RTOS? A. Real-time task scheduling, interrupt management, memory management B. Graphical interface display C. Network communication D. File management', 'Real-time Operating System', 'B', 'A', 0, 0, '2025-08-07 13:54:19');
INSERT INTO `practice_record_detail` VALUES (33, 1, 1010, 'choice', 'What is the basic process of interrupt handling? A. Directly execute interrupt service routine B. Save context, execute interrupt service routine, restore context C. Ignore interrupt D. Restart system', 'Interrupt Handling Mechanism', 'B', 'B', 100, 1, '2025-08-07 13:54:19');
INSERT INTO `practice_record_detail` VALUES (34, 2, 1006, 'choice', 'What is an embedded system? A. Computer system designed for specific applications B. General purpose computer system C. Server system D. Personal computer system', '嵌入式软件开发的编译工具', 'A', 'A', 100, 1, '2025-08-07 13:54:19');
INSERT INTO `practice_record_detail` VALUES (35, 2, 1007, 'choice', 'What are the characteristics of embedded systems? A. High specialization, real-time performance, high reliability B. High generality, complex functions C. Large size, high power consumption D. Expensive', '嵌入式软件开发的编译工具', 'A', 'A', 100, 1, '2025-08-07 13:54:19');
INSERT INTO `practice_record_detail` VALUES (36, 2, 1008, 'choice', 'What are the characteristics of ARM architecture? A. Complex instruction set B. High power consumption design C. Reduced instruction set, low power consumption D. 32-bit only', 'ARM Processor Architecture', 'A', 'C', 0, 0, '2025-08-07 13:54:19');
INSERT INTO `practice_record_detail` VALUES (37, 2, 1009, 'choice', 'What are the main functions of RTOS? A. Real-time task scheduling, interrupt management, memory management B. Graphical interface display C. Network communication D. File management', 'Real-time Operating System', 'A', 'A', 100, 1, '2025-08-07 13:54:19');
INSERT INTO `practice_record_detail` VALUES (38, 2, 1010, 'choice', 'What is the basic process of interrupt handling? A. Directly execute interrupt service routine B. Save context, execute interrupt service routine, restore context C. Ignore interrupt D. Restart system', 'Interrupt Handling Mechanism', 'B', 'B', 100, 1, '2025-08-07 13:54:19');
INSERT INTO `practice_record_detail` VALUES (39, 3, 1006, 'choice', 'What is an embedded system? A. Computer system designed for specific applications B. General purpose computer system C. Server system D. Personal computer system', '嵌入式软件开发的编译工具', 'B', 'A', 0, 0, '2025-08-07 13:54:19');
INSERT INTO `practice_record_detail` VALUES (40, 3, 1007, 'choice', 'What are the characteristics of embedded systems? A. High specialization, real-time performance, high reliability B. High generality, complex functions C. Large size, high power consumption D. Expensive', '嵌入式软件开发的编译工具', 'C', 'A', 0, 0, '2025-08-07 13:54:19');
INSERT INTO `practice_record_detail` VALUES (41, 3, 1008, 'choice', 'What are the characteristics of ARM architecture? A. Complex instruction set B. High power consumption design C. Reduced instruction set, low power consumption D. 32-bit only', 'ARM Processor Architecture', 'C', 'C', 100, 1, '2025-08-07 13:54:19');
INSERT INTO `practice_record_detail` VALUES (42, 3, 1009, 'choice', 'What are the main functions of RTOS? A. Real-time task scheduling, interrupt management, memory management B. Graphical interface display C. Network communication D. File management', 'Real-time Operating System', 'A', 'A', 100, 1, '2025-08-07 13:54:19');
INSERT INTO `practice_record_detail` VALUES (43, 3, 1010, 'choice', 'What is the basic process of interrupt handling? A. Directly execute interrupt service routine B. Save context, execute interrupt service routine, restore context C. Ignore interrupt D. Restart system', 'Interrupt Handling Mechanism', 'A', 'B', 0, 0, '2025-08-07 13:54:19');
INSERT INTO `practice_record_detail` VALUES (44, 15, 0, 'choice', '以下哪种存储器结构在嵌入式处理器中常用于提高指令访问速度？', '嵌入式系统基础', '0', 'C', 0, 0, '2025-08-07 13:56:46');
INSERT INTO `practice_record_detail` VALUES (45, 16, 0, 'choice', '嵌入式系统最显著的特点是？A. 高性能计算能力 B. 面向特定应用并高效执行 C. 支持多种外设 D. 具备大容量存储', '嵌入式系统基础', '0', 'B', 0, 0, '2025-08-07 14:10:45');
INSERT INTO `practice_record_detail` VALUES (46, 17, 0, 'choice', '以下哪种处理器架构因其低功耗和高性能特点广泛用于嵌入式系统？A. x86 B. ARM C. MIPS D. PowerPC', '嵌入式系统基础', '0', 'B', 0, 0, '2025-08-07 14:25:15');
INSERT INTO `practice_record_detail` VALUES (47, 17, 1, 'choice', '在嵌入式处理器中，以下哪种存储器结构用于存储系统启动时的初始指令？A. RAM B. Cache C. ROM D. 寄存器', '嵌入式系统基础', '2', 'C', 100, 1, '2025-08-07 14:25:15');
INSERT INTO `practice_record_detail` VALUES (48, 18, 0, 'choice', '以下哪种处理器架构常用于高性能嵌入式系统中？A. AVR B. ARM C. 8051 D. PIC', '嵌入式处理器架构/处理器架构类型', '1', 'B', 100, 1, '2025-08-07 15:08:23');
INSERT INTO `practice_record_detail` VALUES (49, 18, 1, 'choice', '嵌入式系统中，存储器结构通常采用分级设计的主要目的是？A. 增加存储容量 B. 提高访问速度并降低功耗 C. 简化硬件设计 D. 减少芯片面积', '嵌入式处理器架构/存储器结构', '2', 'B', 0, 0, '2025-08-07 15:08:23');
INSERT INTO `practice_record_detail` VALUES (50, 19, 0, 'choice', '实时操作系统（RTOS）内核的核心功能是？A. 提供图形用户界面 B. 管理任务调度与资源分配 C. 实现网络通信协议 D. 控制外部存储设备', '实时操作系统/实时操作系统内核', '1', 'B', 100, 1, '2025-08-07 15:11:31');
INSERT INTO `practice_record_detail` VALUES (51, 19, 1, 'choice', '在实时操作系统内核中，以下哪项机制用于实现任务之间的同步？A. 中断屏蔽 B. 信号量 C. 动态内存分配 D. 文件系统管理', '实时操作系统/实时操作系统内核', '3', 'B', 0, 0, '2025-08-07 15:11:31');
INSERT INTO `practice_record_detail` VALUES (52, 19, 2, 'choice', '实时操作系统内核中，任务通常处于以下哪种状态组合？A. 就绪、运行、阻塞 B. 启动、暂停、关闭 C. 输入、处理、输出 D. 初始化、运行、销毁', '实时操作系统/实时操作系统内核', '0', 'A', 100, 1, '2025-08-07 15:11:31');
INSERT INTO `practice_record_detail` VALUES (53, 20, 0, 'choice', '实时操作系统（RTOS）内核的核心功能是？A. 提供图形用户界面 B. 管理任务调度与资源分配 C. 实现网络通信协议 D. 控制外部存储设备', '实时操作系统/实时操作系统内核', '3', 'B', 0, 0, '2025-08-07 15:13:03');
INSERT INTO `practice_record_detail` VALUES (54, 20, 1, 'choice', '在实时操作系统内核中，以下哪项机制用于实现任务之间的同步？A. 中断屏蔽 B. 信号量 C. 动态内存分配 D. 文件系统管理', '实时操作系统/实时操作系统内核', '2', 'B', 0, 0, '2025-08-07 15:13:03');
INSERT INTO `practice_record_detail` VALUES (55, 20, 2, 'choice', '实时操作系统内核中，任务通常处于以下哪种状态组合？A. 就绪、运行、阻塞 B. 启动、暂停、关闭 C. 输入、处理、输出 D. 初始化、运行、销毁', '实时操作系统/实时操作系统内核', '0', 'A', 100, 1, '2025-08-07 15:13:03');
INSERT INTO `practice_record_detail` VALUES (56, 20, 3, 'choice', '在RTOS中，可剥夺型调度器的主要优势是？A. 节省内存空间 B. 提高系统吞吐量 C. 增强任务响应实时性 D. 简化任务管理', '实时操作系统/实时操作系统内核', '1', 'C', 0, 0, '2025-08-07 15:13:03');
INSERT INTO `practice_record_detail` VALUES (57, 20, 4, 'choice', 'RTOS内核中，以下哪项机制可以防止多个任务同时访问共享资源？A. 中断服务程序 B. 任务优先级反转 C. 互斥锁 D. 时间片轮转', '实时操作系统/实时操作系统内核', '3', 'C', 0, 0, '2025-08-07 15:13:03');
INSERT INTO `practice_record_detail` VALUES (58, 21, 0, 'choice', '在实时操作系统中，以下哪项是任务调度的基本依据？A. 任务的堆栈大小 B. 任务优先级 C. 任务的创建顺序 D. 任务的内存占用', '实时操作系统/实时操作系统内核', '2', 'B', 0, 0, '2025-08-07 16:19:06');
INSERT INTO `practice_record_detail` VALUES (59, 21, 1, 'choice', '嵌入式处理器中，采用高速缓存（Cache）的主要目的是？A. 增加存储容量 B. 降低功耗 C. 提高数据访问速度 D. 简化内存管理', '嵌入式处理器架构/存储器结构', '0', 'C', 0, 0, '2025-08-07 16:19:06');
INSERT INTO `practice_record_detail` VALUES (60, 22, 0, 'choice', '在实时操作系统中，以下哪项是优先级反转问题的解决方案？A. 使用信号量 B. 引入优先级继承机制 C. 增加任务堆栈大小 D. 减少任务数量', '实时操作系统/实时操作系统内核', '0', 'B', 0, 0, '2025-08-07 16:32:42');
INSERT INTO `practice_record_detail` VALUES (61, 22, 1, 'choice', '实时操作系统中，任务切换的核心机制依赖于以下哪项？A. 中断服务程序 B. 寄存器上下文保存与恢复 C. 内存管理单元 D. 片上外设访问控制', '实时操作系统/实时操作系统内核', '0', 'B', 0, 0, '2025-08-07 16:32:42');
INSERT INTO `practice_record_detail` VALUES (62, 23, 0, 'choice', '在实时操作系统中，以下哪项是任务调度的基本单位？A. 进程 B. 线程 C. 函数 D. 模块', '实时操作系统/实时操作系统内核', '0', 'B', 0, 0, '2025-08-07 16:54:57');
INSERT INTO `practice_record_detail` VALUES (63, 23, 1, 'choice', 'RTOS中，以下哪项机制用于处理任务等待外部事件的情况？A. 中断 B. 信号量 C. 内存池 D. 文件系统', '实时操作系统/实时操作系统内核', '0', 'B', 0, 0, '2025-08-07 16:54:57');
INSERT INTO `practice_record_detail` VALUES (64, 23, 2, 'choice', '以下哪种调度算法最适合硬实时系统？A. 先来先服务（FCFS） B. 时间片轮转 C. 最早截止时间优先（EDF） D. 短作业优先（SJF）', '实时操作系统/实时操作系统内核', '1', 'C', 0, 0, '2025-08-07 16:54:57');
INSERT INTO `practice_record_detail` VALUES (65, 24, 0, 'choice', '以下哪个选项最能体现嵌入式系统的特点？A. 通用性强 B. 面向特定应用 C. 需要大量图形处理能力 D. 主要用于个人计算机', '嵌入式系统概述/嵌入式系统概述', '0', 'B', 0, 0, '2025-08-07 17:33:31');
INSERT INTO `practice_record_detail` VALUES (66, 24, 1, 'choice', '根据功能复杂度分类，以下哪一类属于中等复杂度的嵌入式系统？A. 微波炉控制器 B. 智能手机 C. 简易电子钟 D. 电子计算器', '嵌入式系统概述/嵌入式系统分类', '0', 'B', 0, 0, '2025-08-07 17:33:31');
INSERT INTO `practice_record_detail` VALUES (67, 25, 0, 'choice', '以下哪个选项最能体现嵌入式系统的特点？A. 通用性强 B. 面向特定应用 C. 需要大量图形处理能力 D. 主要用于个人计算机', '嵌入式系统概述/嵌入式系统概述', '0', 'B', 0, 0, '2025-08-07 17:35:44');
INSERT INTO `practice_record_detail` VALUES (68, 25, 1, 'choice', '根据功能复杂度分类，以下哪一类属于中等复杂度的嵌入式系统？A. 微波炉控制器 B. 智能手机 C. 简易电子钟 D. 电子计算器', '嵌入式系统概述/嵌入式系统分类', '0', 'B', 0, 0, '2025-08-07 17:35:44');
INSERT INTO `practice_record_detail` VALUES (69, 26, 0, 'choice', '在实时操作系统中，以下哪项是任务调度的基本依据？A. 任务的堆栈大小 B. 任务优先级 C. 任务的创建顺序 D. 任务的内存占用', '实时操作系统/实时操作系统内核', '0', 'B', 0, 0, '2025-08-09 00:28:54');
INSERT INTO `practice_record_detail` VALUES (70, 26, 1, 'choice', '以下哪项机制用于解决实时系统中任务因等待资源而阻塞的问题？A. 优先级继承 B. 时间片轮转 C. 动态内存分配 D. 线程同步', '实时操作系统/实时操作系统内核', '0', 'A', 100, 1, '2025-08-09 00:28:54');
INSERT INTO `practice_record_detail` VALUES (71, 27, 0, 'choice', '以下哪种处理器架构广泛应用于高性能嵌入式系统中？A. AVR B. ARM C. PIC D. x86', '嵌入式处理器架构/处理器架构类型', '0', 'B', 0, 0, '2025-08-09 22:21:51');
INSERT INTO `practice_record_detail` VALUES (72, 27, 1, 'choice', '在嵌入式系统中，以下哪种处理器类型最适合低功耗应用场景？A. CISC架构处理器 B. x86架构处理器 C. RISC架构处理器 D. VLIW架构处理器', '嵌入式处理器架构/处理器架构类型', '0', 'C', 0, 0, '2025-08-09 22:21:51');
INSERT INTO `practice_record_detail` VALUES (73, 28, 0, 'choice', '以下哪种处理器架构广泛应用于高性能嵌入式系统中？A. AVR B. ARM C. PIC D. x86', '嵌入式处理器架构/处理器架构类型', '3', 'B', 0, 0, '2025-08-09 22:23:37');
INSERT INTO `practice_record_detail` VALUES (74, 28, 1, 'choice', '在嵌入式系统中，以下哪种处理器类型最适合低功耗应用场景？A. CISC架构处理器 B. x86架构处理器 C. RISC架构处理器 D. VLIW架构处理器', '嵌入式处理器架构/处理器架构类型', '1', 'C', 0, 0, '2025-08-09 22:23:37');
INSERT INTO `practice_record_detail` VALUES (75, 29, 0, 'choice', '在实时操作系统中，以下哪项是优先级反转问题的解决方案？A. 时间片轮转 B. 优先级继承 C. 中断屏蔽 D. 动态优先级调整', '实时操作系统/任务调度', '0', 'B', 0, 0, '2025-08-09 22:43:36');
INSERT INTO `practice_record_detail` VALUES (76, 30, 0, 'short_answer', '简要说明RISC架构与CISC架构的主要区别。', '嵌入式处理器架构/处理器架构类型', '6', 'RISC架构强调指令集的精简和执行速度，采用固定长度指令，硬件复杂度低，适合嵌入式和高性能计算场景；CISC架构则强调指令功能的丰富性，指令长度不固定，硬件复杂度较高，常见于通用计算机系统。', 0, 0, '2025-08-09 22:45:41');
INSERT INTO `practice_record_detail` VALUES (77, 31, 0, 'choice', '以下哪个属于嵌入式系统的典型应用？A. 台式计算机 B. 智能手机 C. 工业控制设备 D. 服务器', '嵌入式系统概述/嵌入式系统概述', '0', 'C', 0, 0, '2025-08-10 23:22:39');
INSERT INTO `practice_record_detail` VALUES (78, 31, 1, 'choice', '根据应用领域划分，以下哪项不属于嵌入式系统的分类？A. 军用嵌入式系统 B. 工业控制嵌入式系统 C. 通用服务器系统 D. 医疗嵌入式系统', '嵌入式系统概述/嵌入式系统分类', '1', 'C', 0, 0, '2025-08-10 23:22:39');
INSERT INTO `practice_record_detail` VALUES (79, 32, 0, 'short_answer', '简述嵌入式系统的定义及其主要分类。', '嵌入式系统概述/嵌入式系统概述', '不知道', '嵌入式系统是指用于特定任务并嵌入到大型设备中的计算机系统。其主要分类包括按应用领域划分的军用、工业控制、消费电子类嵌入式系统，以及按实时性划分的实时和非实时嵌入式系统。', 0, 0, '2025-08-10 23:26:23');
INSERT INTO `practice_record_detail` VALUES (80, 33, 0, 'short_answer', '简述嵌入式处理器的常见架构类型及其特点，并说明存储器结构在嵌入式系统中的作用。', '嵌入式处理器架构/处理器架构类型', '666', '常见的嵌入式处理器架构包括ARM、MIPS、PowerPC和RISC-V，其特点包括低功耗、高性能和高集成度。存储器结构在嵌入式系统中用于支持程序执行、数据存储和缓存，通常包括ROM、RAM、Flash和高速缓存。', 0, 0, '2025-08-10 23:45:07');
INSERT INTO `practice_record_detail` VALUES (81, 34, 0, 'choice', '实时操作系统内核的核心任务是？A. 提供图形界面 B. 实现任务调度与资源分配 C. 支持通用计算 D. 管理用户账户', '实时操作系统/实时操作系统内核', '1', 'B', 100, 1, '2025-08-10 23:46:03');
INSERT INTO `practice_record_detail` VALUES (82, 34, 1, 'choice', '以下哪种处理器架构广泛用于嵌入式系统？A. x86 B. ARM C. SPARC D. Itanium', '嵌入式处理器架构/处理器架构类型', '1', 'B', 100, 1, '2025-08-10 23:46:03');
INSERT INTO `practice_record_detail` VALUES (83, 35, 0, 'choice', '以下哪个描述最符合嵌入式系统的定义？A. 一种通用计算机系统，主要用于办公和娱乐 B. 嵌入其他设备中以实现特定功能的专用计算机系统 C. 一种大型计算机系统，用于处理复杂的数据计算 D. 一种基于云平台的分布式计算系统', '嵌入式系统概述/嵌入式系统概述', '0', 'B', 0, 0, '2025-08-27 15:05:50');
INSERT INTO `practice_record_detail` VALUES (84, 36, 0, 'choice', '以下哪个描述最符合嵌入式系统的定义？A. 一种通用计算机系统，主要用于办公和娱乐 B. 嵌入其他设备中以实现特定功能的专用计算机系统 C. 一种大型计算机系统，用于处理复杂的数据计算 D. 一种基于云平台的分布式计算系统', '嵌入式系统概述/嵌入式系统概述', '0', 'B', 0, 0, '2025-09-02 15:05:21');
INSERT INTO `practice_record_detail` VALUES (85, 36, 1, 'choice', '下列哪一项是嵌入式系统的典型应用？A. 台式计算机 B. 笔记本电脑 C. 智能手机 D. 服务器', '嵌入式系统概述/嵌入式系统概述', '0', 'C', 0, 0, '2025-09-02 15:05:21');
INSERT INTO `practice_record_detail` VALUES (86, 36, 2, 'choice', '根据功能复杂度，嵌入式系统可以分为哪几类？A. 单机系统、网络系统 B. 操作系统、应用系统 C. 独立系统、分布式系统 D. 低端系统、中端系统、高端系统', '嵌入式系统概述/嵌入式系统分类', '3', 'D', 100, 1, '2025-09-02 15:05:21');
INSERT INTO `practice_record_detail` VALUES (87, 37, 0, 'choice', '以下哪一项是嵌入式系统的典型特征？A. 高通用性 B. 可运行多种操作系统 C. 专用性强 D. 体积大', '嵌入式系统概述/嵌入式系统概述', '1', 'C', 0, 0, '2025-09-08 13:06:08');
INSERT INTO `practice_record_detail` VALUES (88, 38, 0, 'choice', '以下哪种工具常用于嵌入式系统的硬件调试？A. Wireshark B. GDB C. JTAG D. Minicom', '嵌入式系统调试与测试/硬件调试工具', '1', 'C', 0, 0, '2025-09-08 13:14:03');
INSERT INTO `practice_record_detail` VALUES (89, 39, 0, 'choice', '在实时操作系统中，中断管理的主要作用是什么？A. 提高系统美观性 B. 实现任务间通信 C. 响应外部异步事件 D. 降低系统功耗', '实时操作系统/中断管理', '1', 'C', 0, 0, '2025-09-08 20:25:10');
INSERT INTO `practice_record_detail` VALUES (90, 40, 0, 'choice', '在实时操作系统中，任务调度的主要目标是什么？A. 提高系统美观性 B. 实现任务按时执行与资源合理分配 C. 减少内存占用 D. 增加任务数量', '实时操作系统/任务调度', '1', 'B', 100, 1, '2025-09-08 20:28:10');
INSERT INTO `practice_record_detail` VALUES (91, 41, 0, 'choice', '以下哪一项属于嵌入式系统的典型应用场景？A. 台式计算机操作系统 B. 智能手机 C. 工业控制设备 D. 云计算服务器', '嵌入式系统概述/嵌入式系统概述', '2', 'C', 100, 1, '2025-09-09 16:07:10');
INSERT INTO `practice_record_detail` VALUES (92, 42, 0, 'choice', '在嵌入式软件开发中，使用交叉编译工具链的主要原因是什么？A. 提高目标机的运行速度 B. 在目标机上直接编译生成代码 C. 在主机上生成适用于目标机的可执行代码 D. 减少目标机的内存占用', '嵌入式软件开发/交叉编译工具链', '2', 'C', 100, 1, '2025-09-09 22:30:05');
INSERT INTO `practice_record_detail` VALUES (93, 42, 1, 'choice', '以下哪项是嵌入式操作系统的主要功能？A. 提供图形用户界面 B. 管理硬件资源并提供任务调度 C. 支持大规模数据存储 D. 实现网络通信的物理连接', '嵌入式软件开发/嵌入式操作系统', '3', 'B', 0, 0, '2025-09-09 22:30:05');
INSERT INTO `practice_record_detail` VALUES (94, 43, 0, 'choice', '以下哪种设备最有可能使用嵌入式系统？A. 台式电脑 B. 笔记本电脑 C. 智能手表 D. 服务器', '嵌入式系统概述/嵌入式系统概述', '3', 'C', 0, 0, '2025-09-10 00:40:24');
INSERT INTO `practice_record_detail` VALUES (95, 44, 0, 'choice', '以下哪个设备最有可能使用嵌入式系统？A. 台式电脑 B. 笔记本电脑 C. 智能手表 D. 服务器', '嵌入式系统概述/嵌入式系统概述', '1', 'C', 0, 0, '2025-09-10 09:58:04');
INSERT INTO `practice_record_detail` VALUES (96, 44, 1, 'choice', '下列哪项属于嵌入式系统的典型特征？A. 高功耗 B. 通用性强 C. 实时性要求高 D. 用户可任意修改系统', '嵌入式系统概述/嵌入式系统分类', '2', 'C', 100, 1, '2025-09-10 09:58:04');
INSERT INTO `practice_record_detail` VALUES (97, 45, 0, 'choice', '以下哪种嵌入式处理器架构属于精简指令集（RISC）架构？A. Intel x86 B. ARM Cortex-M C. Motorola 68k D. AMD Ryzen', '嵌入式处理器架构/处理器架构类型', '1', 'B', 100, 1, '2025-09-11 08:35:33');
INSERT INTO `practice_record_detail` VALUES (98, 45, 1, 'choice', '在嵌入式系统中，哈佛结构的主要特点是？A. 指令和数据共享存储空间 B. 指令和数据分开存储 C. 使用单一总线传输指令和数据 D. 采用多级缓存结构', '嵌入式处理器架构/存储器结构', '1', 'B', 0, 0, '2025-09-11 08:35:33');
INSERT INTO `practice_record_detail` VALUES (99, 46, 0, 'choice', '以下哪个属于嵌入式系统的应用领域？\nA. 个人电脑操作系统\nB. 互联网服务器集群\nC. 工业自动化控制系统\nD. 通用数据库管理系统', '嵌入式系统概述/嵌入式系统分类', '1', 'C', 0, 0, '2025-09-13 15:43:36');
INSERT INTO `practice_record_detail` VALUES (100, 47, 0, 'choice', '以下哪个不属于嵌入式系统的典型应用？\nA. 智能手机\nB. 工业控制设备\nC. 台式计算机\nD. 家用电器控制器', '嵌入式系统概述/嵌入式系统概述', '2', 'C', 0, 0, '2025-09-13 16:52:23');
INSERT INTO `practice_record_detail` VALUES (101, 47, 1, 'choice', '根据功能复杂度，嵌入式系统可分为哪几类？\nA. 单机系统、网络系统、分布式系统\nB. 小型嵌入式系统、中型嵌入式系统、复杂嵌入式系统\nC. 实时系统、非实时系统、混合实时系统\nD. 硬件系统、软件系统、固件系统', '嵌入式系统概述/嵌入式系统分类', '2', 'B', 0, 0, '2025-09-13 16:52:23');
INSERT INTO `practice_record_detail` VALUES (102, 48, 0, 'choice', '嵌入式系统的定义是什么？\nA. 通用计算机系统\nB. 嵌入在设备中用于执行特定功能的计算机系统\nC. 大型服务器系统\nD. 个人电脑系统', '嵌入式系统概述/嵌入式系统概述', '1', 'B', 100, 1, '2025-09-17 13:42:01');
INSERT INTO `practice_record_detail` VALUES (103, 48, 1, 'choice', '以下哪项属于嵌入式系统的分类？\nA. 台式机\nB. 超级计算机\nC. 实时嵌入式系统\nD. 云计算平台', '嵌入式系统概述/嵌入式系统分类', '3', 'C', 0, 0, '2025-09-17 13:42:01');
INSERT INTO `practice_record_detail` VALUES (104, 49, 0, 'choice', '以下哪种处理器架构常用于嵌入式系统？\nA. x86\nB. ARM\nC. RISC-V\nD. 以上都是', '嵌入式处理器架构/处理器架构类型', '2', 'D', 0, 0, '2025-09-18 22:27:45');
INSERT INTO `practice_record_detail` VALUES (105, 49, 1, 'choice', '在嵌入式系统中，哈佛架构的特点是什么？\nA. 指令和数据共享同一存储空间\nB. 使用单一总线进行指令和数据传输\nC. 指令存储和数据存储分开，具有独立的地址空间\nD. 仅适用于大型服务器系统', '嵌入式处理器架构/存储器结构', '2', 'C', 100, 1, '2025-09-18 22:27:45');
INSERT INTO `practice_record_detail` VALUES (106, 49, 2, 'choice', '下列哪项是冯·诺依曼架构的主要特征？\nA. 指令和数据存储在不同的存储器中\nB. 具有独立的程序存储器和数据存储器访问路径\nC. 程序和数据存放在同一存储空间中\nD. 不支持实时处理', '嵌入式处理器架构/存储器结构', '2', 'C', 100, 1, '2025-09-18 22:27:45');
INSERT INTO `practice_record_detail` VALUES (107, 50, 0, 'choice', '下列哪种架构在嵌入式系统中广泛使用，因其低功耗和高效率特点？\nA. CISC\nB. VLIW\nC. ARM\nD. x86_64', '嵌入式处理器架构/处理器架构类型', '1', 'C', 0, 0, '2025-09-18 22:29:42');
INSERT INTO `practice_record_detail` VALUES (108, 51, 0, 'choice', '下列哪一项是嵌入式系统与通用计算机的主要区别？\nA. 使用相同的操作系统\nB. 具有更强的通用计算能力\nC. 针对特定功能进行设计\nD. 不需要硬件定制', '嵌入式系统概述/嵌入式系统概述', '2', 'C', 100, 1, '2025-09-18 22:32:56');

-- ----------------------------
-- Table structure for private_message
-- ----------------------------
DROP TABLE IF EXISTS `private_message`;
CREATE TABLE `private_message`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `sender_id` bigint NOT NULL COMMENT '发送者ID',
  `sender_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '发送者姓名',
  `sender_avatar` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发送者头像',
  `receiver_id` bigint NOT NULL COMMENT '接收者ID',
  `receiver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '接收者姓名',
  `subject` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '私信主题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '私信内容',
  `is_read` tinyint(1) NULL DEFAULT 0 COMMENT '是否已读 0-未读 1-已读',
  `is_important` tinyint(1) NULL DEFAULT 0 COMMENT '是否重要 0-普通 1-重要',
  `course_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '课程名称',
  `send_time` datetime NOT NULL COMMENT '发送时间',
  `read_time` datetime NULL DEFAULT NULL COMMENT '阅读时间',
  `message_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'private_message' COMMENT '消息类型',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'sent' COMMENT '消息状态',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_receiver_id`(`receiver_id` ASC) USING BTREE,
  INDEX `idx_sender_id`(`sender_id` ASC) USING BTREE,
  INDEX `idx_send_time`(`send_time` ASC) USING BTREE,
  INDEX `idx_is_read`(`is_read` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '私信表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of private_message
-- ----------------------------
INSERT INTO `private_message` VALUES (1, 2, '张磊', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/eabea5d7-ba89-40bd-9488-84812d32440f-2232.jpg_wh300.jpg', 1, '张政', '关于作业提交的问题', '张政同学你好，我看到你的数据结构作业还没有提交，请问是遇到了什么困难吗？', 1, 0, '数据结构', '2025-09-01 10:30:00', '2025-09-02 10:22:39', 'private_message', 'sent', '2025-09-02 10:21:58', '2025-09-02 10:22:38');
INSERT INTO `private_message` VALUES (2, 2, '张磊', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/eabea5d7-ba89-40bd-9488-84812d32440f-2232.jpg_wh300.jpg', 3, '梁本华', '课程资料更新通知', '梁本华同学，本周的数据结构课程资料已经更新，请及时下载查看。', 0, 1, '数据结构', '2025-09-01 14:20:00', NULL, 'private_message', 'sent', '2025-09-02 10:21:58', '2025-09-02 10:21:58');
INSERT INTO `private_message` VALUES (3, 2, '张磊', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/eabea5d7-ba89-40bd-9488-84812d32440f-2232.jpg_wh300.jpg', 9, '小贝', '学术讨论邀请', '小贝同学，下周三下午有一个关于人工智能的学术讨论会，如果你感兴趣的话可以参加。', 1, 0, '数据结构', '2025-09-01 16:45:00', '2025-09-01 17:30:00', 'private_message', 'sent', '2025-09-02 10:21:58', '2025-09-02 10:21:58');
INSERT INTO `private_message` VALUES (4, 1, '张政', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/30adab86-8619-4ee8-a1a8-cda477791f0b-20190926141024_uleti.jpg', 3, '梁本华', '关于算法题目的讨论', '梁本华，我在做动态规划那几道题时遇到了一些问题，能请教一下你的思路吗？', 0, 0, '数据结构', '2025-09-01 20:15:00', NULL, 'private_message', 'sent', '2025-09-02 10:21:58', '2025-09-02 10:21:58');
INSERT INTO `private_message` VALUES (5, 3, '梁本华', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/7a6f34ab-f425-4791-bde5-c9dc23e9674c-OIP-C.webp', 1, '张政', '回复：算法题目讨论', '当然可以！动态规划确实比较难理解，我们可以一起讨论一下。', 1, 0, '数据结构', '2025-09-01 21:00:00', '2025-09-01 21:30:00', 'private_message', 'sent', '2025-09-02 10:21:58', '2025-09-02 10:21:58');
INSERT INTO `private_message` VALUES (6, 9, '小贝', NULL, 1, '张政', '学习小组邀请', '张政，我们几个同学想组建一个学习小组，一起复习数据结构，你要不要加入？', 1, 0, '数据结构', '2025-09-01 22:10:00', '2025-09-02 10:22:41', 'private_message', 'sent', '2025-09-02 10:21:58', '2025-09-02 10:22:40');
INSERT INTO `private_message` VALUES (7, 4, '若依', NULL, 2, '张磊', '教学评估通知', '张磊老师，本学期的教学评估即将开始，请准备好相关材料。', 0, 1, '系统通知', '2025-09-01 09:00:00', NULL, 'private_message', 'sent', '2025-09-02 10:21:58', '2025-09-02 10:21:58');
INSERT INTO `private_message` VALUES (8, 2, '老师', NULL, 1, '张政', '6', '6', 1, 0, '嵌入式开发进阶', '2025-09-02 11:59:12', '2025-09-02 11:59:21', 'private_message', 'sent', '2025-09-02 11:59:12', '2025-09-02 11:59:21');

-- ----------------------------
-- Table structure for qrtz_blob_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_blob_triggers`;
CREATE TABLE `qrtz_blob_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `blob_data` blob NULL COMMENT '存放持久化Trigger对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_blob_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Blob类型的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_blob_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_calendars
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_calendars`;
CREATE TABLE `qrtz_calendars`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '日历名称',
  `calendar` blob NOT NULL COMMENT '存放持久化calendar对象',
  PRIMARY KEY (`sched_name`, `calendar_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '日历信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_calendars
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_cron_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_cron_triggers`;
CREATE TABLE `qrtz_cron_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `cron_expression` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'cron表达式',
  `time_zone_id` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '时区',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_cron_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Cron类型的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_cron_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_fired_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_fired_triggers`;
CREATE TABLE `qrtz_fired_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `entry_id` varchar(95) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度器实例id',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度器实例名',
  `fired_time` bigint NOT NULL COMMENT '触发的时间',
  `sched_time` bigint NOT NULL COMMENT '定时器制定的时间',
  `priority` int NOT NULL COMMENT '优先级',
  `state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务组名',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否并发',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否接受恢复执行',
  PRIMARY KEY (`sched_name`, `entry_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '已触发的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_fired_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_job_details
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_job_details`;
CREATE TABLE `qrtz_job_details`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务组名',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '相关介绍',
  `job_class_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '执行任务类名称',
  `is_durable` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否持久化',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否并发',
  `is_update_data` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否更新数据',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否接受恢复执行',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '任务详细信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_job_details
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_locks
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_locks`;
CREATE TABLE `qrtz_locks`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `lock_name` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '悲观锁名称',
  PRIMARY KEY (`sched_name`, `lock_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '存储的悲观锁信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_locks
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_paused_trigger_grps
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_paused_trigger_grps`;
CREATE TABLE `qrtz_paused_trigger_grps`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  PRIMARY KEY (`sched_name`, `trigger_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '暂停的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_paused_trigger_grps
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_scheduler_state
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_scheduler_state`;
CREATE TABLE `qrtz_scheduler_state`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '实例名称',
  `last_checkin_time` bigint NOT NULL COMMENT '上次检查时间',
  `checkin_interval` bigint NOT NULL COMMENT '检查间隔时间',
  PRIMARY KEY (`sched_name`, `instance_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '调度器状态表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_scheduler_state
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simple_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simple_triggers`;
CREATE TABLE `qrtz_simple_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `repeat_count` bigint NOT NULL COMMENT '重复的次数统计',
  `repeat_interval` bigint NOT NULL COMMENT '重复的间隔时间',
  `times_triggered` bigint NOT NULL COMMENT '已经触发的次数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simple_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '简单触发器的信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_simple_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simprop_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simprop_triggers`;
CREATE TABLE `qrtz_simprop_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `str_prop_1` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第一个参数',
  `str_prop_2` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第二个参数',
  `str_prop_3` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第三个参数',
  `int_prop_1` int NULL DEFAULT NULL COMMENT 'int类型的trigger的第一个参数',
  `int_prop_2` int NULL DEFAULT NULL COMMENT 'int类型的trigger的第二个参数',
  `long_prop_1` bigint NULL DEFAULT NULL COMMENT 'long类型的trigger的第一个参数',
  `long_prop_2` bigint NULL DEFAULT NULL COMMENT 'long类型的trigger的第二个参数',
  `dec_prop_1` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第一个参数',
  `dec_prop_2` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第二个参数',
  `bool_prop_1` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第一个参数',
  `bool_prop_2` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第二个参数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simprop_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '同步机制的行锁表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_simprop_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_triggers`;
CREATE TABLE `qrtz_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器的名字',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器所属组的名字',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_job_details表job_name的外键',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_job_details表job_group的外键',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '相关介绍',
  `next_fire_time` bigint NULL DEFAULT NULL COMMENT '上一次触发时间（毫秒）',
  `prev_fire_time` bigint NULL DEFAULT NULL COMMENT '下一次触发时间（默认为-1表示不触发）',
  `priority` int NULL DEFAULT NULL COMMENT '优先级',
  `trigger_state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器状态',
  `trigger_type` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器的类型',
  `start_time` bigint NOT NULL COMMENT '开始时间',
  `end_time` bigint NULL DEFAULT NULL COMMENT '结束时间',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '日程表名称',
  `misfire_instr` smallint NULL DEFAULT NULL COMMENT '补偿执行的策略',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  INDEX `sched_name`(`sched_name` ASC, `job_name` ASC, `job_group` ASC) USING BTREE,
  CONSTRAINT `qrtz_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `job_name`, `job_group`) REFERENCES `qrtz_job_details` (`sched_name`, `job_name`, `job_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '触发器详细信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for question
-- ----------------------------
DROP TABLE IF EXISTS `question`;
CREATE TABLE `question`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `course_id` int NOT NULL,
  `user_id` int NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of question
-- ----------------------------
INSERT INTO `question` VALUES (1, 101, 1, 'Vue 如何实现双向绑定？', '2025-08-06 22:51:19');
INSERT INTO `question` VALUES (2, 101, 2, 'Vue 的生命周期有哪些？', '2025-08-06 22:51:19');
INSERT INTO `question` VALUES (3, 101, 1, '嵌入式开发好难', NULL);
INSERT INTO `question` VALUES (4, 101, 1, '3', '2025-08-06 23:42:51');
INSERT INTO `question` VALUES (5, 101, 1, '嵌入式怎么学啊\n', '2025-08-07 00:17:03');
INSERT INTO `question` VALUES (6, 101, 1, 'qqq', '2025-08-07 18:21:59');
INSERT INTO `question` VALUES (7, 101, 1, 'lll', '2025-08-24 19:22:39');
INSERT INTO `question` VALUES (8, 101, 9, '好男', '2025-08-27 17:06:00');
INSERT INTO `question` VALUES (9, 101, 1, '111', '2025-09-11 08:33:39');
INSERT INTO `question` VALUES (10, 101, 1, '不会啊', '2025-09-18 13:19:02');
INSERT INTO `question` VALUES (15, 101, 1, '嵌入式如何学习？', '2025-09-18 16:29:26');

-- ----------------------------
-- Table structure for question_attachment
-- ----------------------------
DROP TABLE IF EXISTS `question_attachment`;
CREATE TABLE `question_attachment`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `file_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `question_id`(`question_id` ASC) USING BTREE,
  CONSTRAINT `question_attachment_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `question` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of question_attachment
-- ----------------------------
INSERT INTO `question_attachment` VALUES (3, 3, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/95ff1eb3-8398-4922-aff3-2a703de47ba5-cp07-样章示例-TensorFlow.js应用开发.docx', 'cp07-样章示例-TensorFlow.js应用开发.docx');
INSERT INTO `question_attachment` VALUES (4, 4, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/d1d452b9-c8f5-40b3-86df-364e5b9fe4fe-嵌入式系统开发教学大纲.docx', '嵌入式系统开发教学大纲.docx');
INSERT INTO `question_attachment` VALUES (5, 5, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/d1d452b9-c8f5-40b3-86df-364e5b9fe4fe-嵌入式系统开发教学大纲.docx', '嵌入式系统开发教学大纲.docx');
INSERT INTO `question_attachment` VALUES (6, 6, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/d1d452b9-c8f5-40b3-86df-364e5b9fe4fe-嵌入式系统开发教学大纲.docx', '嵌入式系统开发教学大纲.docx');
INSERT INTO `question_attachment` VALUES (7, 7, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/d1d452b9-c8f5-40b3-86df-364e5b9fe4fe-嵌入式系统开发教学大纲.docx', '嵌入式系统开发教学大纲.docx');
INSERT INTO `question_attachment` VALUES (8, 8, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/95ff1eb3-8398-4922-aff3-2a703de47ba5-cp07-样章示例-TensorFlow.js应用开发.docx', 'cp07-样章示例-TensorFlow.js应用开发.docx');
INSERT INTO `question_attachment` VALUES (9, 9, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/95ff1eb3-8398-4922-aff3-2a703de47ba5-cp07-样章示例-TensorFlow.js应用开发.docx', 'cp07-样章示例-TensorFlow.js应用开发.docx');
INSERT INTO `question_attachment` VALUES (10, 10, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/d1d452b9-c8f5-40b3-86df-364e5b9fe4fe-嵌入式系统开发教学大纲.docx', '嵌入式系统开发教学大纲.docx');
INSERT INTO `question_attachment` VALUES (15, 15, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/d1d452b9-c8f5-40b3-86df-364e5b9fe4fe-嵌入式系统开发教学大纲.docx', '嵌入式系统开发教学大纲.docx');

-- ----------------------------
-- Table structure for question_bank
-- ----------------------------
DROP TABLE IF EXISTS `question_bank`;
CREATE TABLE `question_bank`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_id` bigint NOT NULL,
  `type` enum('choice','short_answer','programming') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `knowledge_point` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `difficulty_level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'medium' COMMENT '难度等级: easy, medium, hard',
  `category_id` bigint NULL DEFAULT NULL COMMENT '题库分类ID',
  `estimated_time_minutes` int NULL DEFAULT NULL COMMENT '预估答题时间(分钟)',
  `tags` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '题目标签，用逗号分隔',
  `is_ai_generated` tinyint(1) NULL DEFAULT 0 COMMENT '是否AI生成',
  `generation_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'AI生成提示词',
  `quality_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '题目质量评分',
  `created_by` bigint NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `course_id`(`course_id` ASC) USING BTREE,
  INDEX `created_by`(`created_by` ASC) USING BTREE,
  INDEX `idx_difficulty`(`difficulty_level` ASC) USING BTREE,
  INDEX `idx_category`(`category_id` ASC) USING BTREE,
  INDEX `idx_ai_generated`(`is_ai_generated` ASC) USING BTREE,
  CONSTRAINT `question_bank_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `question_bank_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `question_bank_ibfk_category` FOREIGN KEY (`category_id`) REFERENCES `question_bank_category` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1213 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of question_bank
-- ----------------------------
INSERT INTO `question_bank` VALUES (1069, 101, 'programming', '编写一个简单的C语言程序，模拟一个嵌入式系统中LED的控制逻辑。要求：定义LED状态（开/关），并实现切换LED状态的函数。', '#include <stdio.h>\n\ntypedef enum {\n    OFF,\n    ON\n} LEDState;\n\nLEDState ledState = OFF;\n\nvoid toggleLED() {\n    ledState = (ledState == OFF) ? ON : OFF;\n    printf(\"LED is now %s\\n\", ledState == ON ? \"ON\" : \"OFF\");\n}\n\nint main() {\n    toggleLED();\n    toggleLED();\n    return 0;\n}', '嵌入式系统概述', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-10 23:30:34');
INSERT INTO `question_bank` VALUES (1076, 101, 'short_answer', '简述嵌入式系统的基本定义。', '嵌入式系统是一种以应用为中心、以计算机技术为基础，并且软硬件可裁剪，适用于对功能、可靠性、成本、体积及功耗有严格要求的专用计算机系统。', '嵌入式系统概述', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 08:13:52');
INSERT INTO `question_bank` VALUES (1077, 101, 'short_answer', '列举三种嵌入式系统的典型应用领域。', '工业控制、消费电子、医疗设备、汽车电子、航空航天等。', '嵌入式系统分类', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 08:13:52');
INSERT INTO `question_bank` VALUES (1078, 101, 'short_answer', '简要说明嵌入式系统按功能分类的常见类型。', '嵌入式系统按功能可分为独立运行型系统（如智能手表）、从属型系统（如家用电器中的控制模块）和网络连接型系统（如智能摄像头）。', '嵌入式系统分类', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 08:13:52');
INSERT INTO `question_bank` VALUES (1079, 101, 'programming', '编写一个C语言函数，用于判断某个设备是否属于嵌入式系统（假设判断标准为是否为专用设备，是否资源受限，是否实时性要求高）。函数原型：int isEmbeddedSystem(int isDedicated, int isResourceLimited, int hasRealTimeRequirements)。', 'int isEmbeddedSystem(int isDedicated, int isResourceLimited, int hasRealTimeRequirements) {\n  return isDedicated && isResourceLimited && hasRealTimeRequirements;\n}', '嵌入式系统概述', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 08:13:52');
INSERT INTO `question_bank` VALUES (1080, 101, 'programming', '编写一个C语言结构体，用于表示嵌入式系统的分类信息，包括系统类型（独立型/从属型/网络型）、是否实时系统、是否基于微控制器。并编写一个函数打印结构体信息。', 'typedef struct {\n  char type[20];\n  int isRealTime;\n  int isMicrocontrollerBased;\n} EmbeddedSystem;\n\nvoid printEmbeddedSystem(EmbeddedSystem sys) {\n  printf(\"Type: %s\\n\", sys.type);\n  printf(\"Real-time: %s\\n\", sys.isRealTime ? \"Yes\" : \"No\");\n  printf(\"Microcontroller-based: %s\\n\", sys.isMicrocontrollerBased ? \"Yes\" : \"No\");\n}', '嵌入式系统分类', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 08:13:52');
INSERT INTO `question_bank` VALUES (1081, 101, 'choice', '在嵌入式系统中，交叉编译工具链的主要作用是什么？\nA. 在目标设备上直接编译代码\nB. 在宿主机上生成目标设备可运行的代码\nC. 调试嵌入式程序\nD. 模拟嵌入式硬件环境', 'B', '交叉编译工具链', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 14:06:48');
INSERT INTO `question_bank` VALUES (1082, 101, 'choice', '在嵌入式系统调试中，以下哪项工具最常用于仿真硬件环境？\nA. GDB\nB. QEMU\nC. GCC\nD. Makefile', 'B', '调试与仿真', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 14:06:52');
INSERT INTO `question_bank` VALUES (1083, 101, 'short_answer', '嵌入式操作系统中，实时性是什么意思？为什么它在嵌入式系统中如此重要？', '实时性是指系统在限定时间内对外部事件做出响应的能力。在嵌入式系统中，实时性至关重要，因为许多嵌入式应用（如工业控制、医疗设备）要求及时响应，否则可能导致严重后果。', '嵌入式操作系统', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 14:06:54');
INSERT INTO `question_bank` VALUES (1086, 101, 'choice', '下列关于嵌入式系统的描述中，哪一项是正确的？\nA. 嵌入式系统是一种通用计算设备\nB. 嵌入式系统主要用于执行特定功能\nC. 嵌入式系统不需要实时性\nD. 嵌入式系统仅用于消费电子产品', 'B', '嵌入式系统概述', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:15:32');
INSERT INTO `question_bank` VALUES (1087, 101, 'choice', '以下哪一种分类方式是基于嵌入式系统的功能复杂度进行划分的？\nA. 独立型系统和网络型系统\nB. 小型嵌入式系统、中型嵌入式系统、复杂嵌入式系统\nC. 实时系统和非实时系统\nD. 工业控制系统和消费电子系统', 'B', '嵌入式系统分类', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:15:32');
INSERT INTO `question_bank` VALUES (1088, 101, 'choice', '以下哪种处理器架构是精简指令集（RISC）的典型代表？\nA. x86\nB. ARM\nC. PowerPC\nD. MIPS', 'B', '处理器架构类型', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:15:32');
INSERT INTO `question_bank` VALUES (1089, 101, 'choice', '在嵌入式系统中，哪种存储器用于存储运行时的程序数据？\nA. ROM\nB. Flash Memory\nC. RAM\nD. Cache', 'C', '存储器结构', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:15:32');
INSERT INTO `question_bank` VALUES (1090, 101, 'choice', 'ARM处理器采用哪种指令集架构？\nA. CISC\nB. RISC\nC. MISC\nD. VLIW', 'B', '处理器架构类型', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:15:32');
INSERT INTO `question_bank` VALUES (1091, 101, 'choice', '以下哪种存储器是嵌入式系统中最常用于存储固件的？\nA. RAM\nB. ROM\nC. Flash Memory\nD. Cache', 'C', '存储器结构', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:15:32');
INSERT INTO `question_bank` VALUES (1092, 101, 'short_answer', '请简要描述嵌入式系统的主要特点。', '嵌入式系统是为特定功能设计的专用计算机系统，通常具有实时性、资源受限、可靠性高和功耗低等特点。', '嵌入式系统概述', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:15:32');
INSERT INTO `question_bank` VALUES (1093, 101, 'programming', '编写一个C语言函数，将一个数组的前n个元素初始化为0。\n函数原型：void init_array(int *arr, int n)', 'void init_array(int *arr, int n) {\n    for (int i = 0; i < n; i++) {\n        arr[i] = 0;\n    }\n}', '嵌入式系统概述', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:15:32');
INSERT INTO `question_bank` VALUES (1094, 101, 'programming', '在嵌入式开发中，如何用C语言设置一个32位寄存器的第5位？请编写代码实现。', '#define SET_BIT(reg, bit) ((reg) |= (1 << (bit)))\nint main() {\n    volatile unsigned int *reg = (unsigned int *)0x40000000;\n    SET_BIT(*reg, 5);\n    return 0;\n}', '处理器架构类型', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:15:32');
INSERT INTO `question_bank` VALUES (1095, 101, 'programming', '请用C语言实现一个简单的内存拷贝函数memcpy，用于嵌入式系统环境。', 'void *my_memcpy(void *dest, const void *src, size_t n) {\n    char *d = (char *)dest;\n    const char *s = (const char *)src;\n    for (size_t i = 0; i < n; i++) {\n        d[i] = s[i];\n    }\n    return dest;\n}', '存储器结构', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:15:32');
INSERT INTO `question_bank` VALUES (1096, 101, 'choice', '实时操作系统（RTOS）内核的主要功能包括以下哪一项？\nA. 提供图形用户界面\nB. 管理硬件资源和任务调度\nC. 支持高级语言编译\nD. 提供网络浏览器功能', 'B', '实时操作系统内核', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:33:23');
INSERT INTO `question_bank` VALUES (1097, 101, 'choice', '在RTOS中，哪种调度算法通常用于确保任务的实时性？\nA. 先来先服务（FCFS）\nB. 时间片轮转（RR）\nC. 优先级驱动调度\nD. 最短作业优先（SJF）', 'C', '任务调度', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:33:23');
INSERT INTO `question_bank` VALUES (1098, 101, 'choice', '中断管理中，中断嵌套的主要作用是什么？\nA. 提高中断响应时间\nB. 降低中断处理的复杂性\nC. 允许更高优先级的中断打断当前中断处理\nD. 避免中断丢失', 'C', '中断管理', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:33:23');
INSERT INTO `question_bank` VALUES (1099, 101, 'choice', '在RTOS中，任务的状态不包括以下哪一项？\nA. 就绪态\nB. 等待态\nC. 编译态\nD. 运行态', 'C', '实时操作系统内核', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:33:23');
INSERT INTO `question_bank` VALUES (1100, 101, 'short_answer', '简述RTOS中任务调度器的主要作用。', '任务调度器负责根据调度算法决定哪个任务应该在CPU上运行，确保系统满足实时性和任务优先级的要求。', '任务调度', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:33:23');
INSERT INTO `question_bank` VALUES (1101, 101, 'short_answer', '在中断管理中，为什么需要使用中断屏蔽机制？', '中断屏蔽机制用于防止低优先级中断打断高优先级中断的处理，避免中断嵌套带来的不可预测性，提高系统稳定性。', '中断管理', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:33:23');
INSERT INTO `question_bank` VALUES (1102, 101, 'programming', '编写一个RTOS任务函数，用于每100毫秒切换一次LED状态（开→关→开→关）。', 'void ledTask(void *pvParameters) {\n    while (1) {\n        toggleLED();\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}', '任务调度', 'medium', 10, NULL, NULL, 0, NULL, NULL, 1, '2025-09-11 16:33:23');
INSERT INTO `question_bank` VALUES (1103, 101, 'choice', '实时操作系统（RTOS）内核的主要功能包括以下哪一项？\nA. 提供图形用户界面\nB. 管理硬件资源和任务调度\nC. 支持高级语言编译\nD. 提供网络浏览器功能', 'B', '实时操作系统内核', 'easy', 10, 3, 'RTOS,内核功能', 1, NULL, NULL, 1, '2025-09-11 16:40:52');
INSERT INTO `question_bank` VALUES (1104, 101, 'choice', '嵌入式系统的主要特征是什么？\nA. 高性能计算\nB. 通用性\nC. 实时性和专用性\nD. 多用户支持', 'C', '嵌入式系统概述', 'easy', 10, 2, '嵌入式系统', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1105, 101, 'choice', '以下哪种处理器架构常用于嵌入式系统？\nA. x86\nB. ARM\nC. PowerPC\nD. 以上都是', 'D', '处理器架构类型', 'medium', 10, 3, '处理器架构', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1106, 101, 'choice', '在嵌入式系统中，哪种存储器通常用于存储程序代码？\nA. RAM\nB. ROM\nC. Cache\nD. 寄存器', 'B', '存储器结构', 'easy', 10, 2, '存储器结构', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1107, 101, 'choice', '以下哪个是嵌入式操作系统？\nA. Windows 10\nB. Linux\nC. FreeRTOS\nD. macOS', 'C', '嵌入式操作系统', 'medium', 10, 3, '嵌入式操作系统', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1108, 101, 'choice', '交叉编译工具链的主要作用是？\nA. 提高代码可读性\nB. 在宿主机上编译目标机可运行的代码\nC. 优化编译速度\nD. 生成调试信息', 'B', '交叉编译工具链', 'medium', 10, 3, '交叉编译', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1109, 101, 'choice', 'JTAG主要用于嵌入式系统的？\nA. 编译\nB. 存储管理\nC. 调试与仿真\nD. 通信', 'C', '调试与仿真', 'medium', 10, 3, '调试与仿真', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1110, 101, 'choice', '实时操作系统的核心特征是？\nA. 多任务支持\nB. 高吞吐量\nC. 确定性响应时间\nD. 低内存占用', 'C', '实时操作系统内核', 'medium', 10, 3, '实时操作系统', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1111, 101, 'choice', '以下哪种调度算法常用于实时系统？\nA. 先来先服务（FCFS）\nB. 时间片轮转\nC. 最早截止时间优先（EDF）\nD. 短作业优先（SJF）', 'C', '任务调度', 'hard', 10, 4, '任务调度', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1112, 101, 'choice', '串口通信中，波特率表示？\nA. 数据传输速率\nB. 电压水平\nC. 数据位数\nD. 奇偶校验方式', 'A', '串口通信', 'easy', 10, 2, '串口通信', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1113, 101, 'choice', 'CAN总线属于以下哪种类型？\nA. 并行总线\nB. 串行总线\nC. 无线通信\nD. 存储总线', 'B', '总线通信', 'medium', 10, 3, '总线通信', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1114, 101, 'short_answer', '简述嵌入式系统的定义和主要应用场景。', '嵌入式系统是以应用为中心，以计算机技术为基础，软硬件可裁剪，适用于对功能、可靠性、成本等有严格要求的专用计算机系统。主要应用于工业控制、消费电子、医疗设备、汽车电子等领域。', '嵌入式系统概述', 'medium', 10, 5, '嵌入式系统', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1115, 101, 'short_answer', '简述嵌入式操作系统的作用和特点。', '嵌入式操作系统负责管理硬件资源和提供软件运行环境，其特点包括实时性、低资源占用、可移植性、稳定性和可靠性。', '嵌入式操作系统', 'medium', 10, 5, '嵌入式操作系统', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1116, 101, 'short_answer', '简述中断管理在嵌入式系统中的作用。', '中断管理用于处理外部事件或异常情况，确保系统能够及时响应关键任务，提高系统的实时性和效率。', '中断管理', 'medium', 10, 5, '中断管理', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1117, 101, 'short_answer', '解释交叉编译工具链的作用，并列举其主要组件。', '交叉编译工具链用于在宿主机上生成目标机可运行的代码。主要组件包括编译器、链接器、汇编器和调试器。', '交叉编译工具链', 'hard', 10, 6, '交叉编译', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1118, 101, 'short_answer', '简述无线通信在嵌入式系统中的常见应用场景。', '无线通信广泛应用于物联网设备、智能家居、工业自动化、穿戴设备、远程监控等领域。', '无线通信基础', 'easy', 10, 4, '无线通信', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1119, 101, 'short_answer', '列举三种常用的硬件调试工具及其功能。', '1. 示波器：用于观察信号波形；2. 逻辑分析仪：用于捕捉和分析数字信号；3. JTAG调试器：用于嵌入式系统的在线调试。', '硬件调试工具', 'medium', 10, 5, '硬件调试', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1120, 101, 'programming', '编写一个C语言函数，实现通过串口发送字符串的功能。假设串口初始化已完成。', '#include <stdio.h>\n\nvoid sendString(char *str) {\n    while (*str) {\n        sendChar(*str++); // 假设sendChar函数已实现\n    }\n}', '串口通信', 'medium', 10, 8, '串口通信, 编程', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1121, 101, 'programming', '编写一个简单的任务调度函数，使用轮转调度算法调度三个任务。', '#include <stdio.h>\n\n#define NUM_TASKS 3\n\nvoid task1() { printf(\"Running Task 1\\n\"); }\nvoid task2() { printf(\"Running Task 2\\n\"); }\nvoid task3() { printf(\"Running Task 3\\n\"); }\n\nvoid roundRobinScheduler() {\n    void (*tasks[NUM_TASKS])() = {task1, task2, task3};\n    for (int i = 0; i < NUM_TASKS; i++) {\n        tasks[i]();\n    }\n}\n\nint main() {\n    roundRobinScheduler();\n    return 0;\n}', '任务调度', 'hard', 10, 10, '任务调度, 编程', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1122, 101, 'programming', '编写一个C语言函数，实现简单的中断服务程序（ISR），并在主程序中注册该中断。', '#include <stdio.h>\n\nvoid interruptServiceRoutine() {\n    printf(\"Interrupt occurred!\\n\");\n}\n\nvoid registerInterrupt(void (*handler)()) {\n    // 模拟中断注册\n    printf(\"Registering interrupt handler\\n\");\n    // 假设触发中断的代码在这里\n    handler();\n}\n\nint main() {\n    registerInterrupt(interruptServiceRoutine);\n    return 0;\n}', '中断管理', 'hard', 10, 10, '中断管理, 编程', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1123, 101, 'programming', '编写一个C语言程序，模拟通过I2C总线读取温度传感器数据。', '#include <stdio.h>\n\n// 模拟I2C读取函数\nint i2cRead(int address, int reg) {\n    // 模拟返回温度数据\n    return 25; // 假设温度为25°C\n}\n\nint main() {\n    int temperature = i2cRead(0x48, 0x00);\n    printf(\"Temperature: %d°C\\n\", temperature);\n    return 0;\n}', '总线通信', 'medium', 10, 8, '总线通信, 编程', 1, NULL, NULL, 1, '2025-09-11 16:47:16');
INSERT INTO `question_bank` VALUES (1124, 101, 'choice', '以下哪种通信方式是全双工的？\nA. I2C总线\nB. SPI总线\nC. UART串口\nD. CAN总线', 'C', '串口通信', 'medium', 10, 2, '通信方式,全双工', 1, NULL, NULL, 1, '2025-09-11 16:53:08');
INSERT INTO `question_bank` VALUES (1126, 101, 'choice', '蓝牙通信属于以下哪种技术类别？\nA. 蜂窝网络\nB. 短距离无线通信\nC. 工业总线\nD. 有线局域网', 'B', '无线通信基础', 'easy', 10, 1, '蓝牙,无线通信', 1, NULL, NULL, 1, '2025-09-11 16:53:08');
INSERT INTO `question_bank` VALUES (1127, 101, 'choice', 'CAN总线中，用于仲裁的字段是？\nA. 数据场\nB. 控制场\nC. 标识符场\nD. CRC场', 'C', '总线通信', 'hard', 10, 3, 'CAN总线,仲裁', 1, NULL, NULL, 1, '2025-09-11 16:53:08');
INSERT INTO `question_bank` VALUES (1128, 101, 'choice', '在串口通信中，波特率表示什么？\nA. 数据位数\nB. 数据传输速率\nC. 校验方式\nD. 停止位数量', 'B', '串口通信', 'easy', 10, 1, '波特率,串口通信', 1, NULL, NULL, 1, '2025-09-11 16:53:08');
INSERT INTO `question_bank` VALUES (1129, 101, 'short_answer', '请简要说明UART通信中起始位和停止位的作用。', '起始位用于通知接收端数据帧的开始，停止位用于标识数据帧的结束，确保接收端正确解析数据。', '串口通信', 'medium', 10, 5, 'UART,起始位,停止位', 1, NULL, NULL, 1, '2025-09-11 16:53:08');
INSERT INTO `question_bank` VALUES (1130, 101, 'short_answer', '简述I2C总线通信中主设备和从设备之间的交互过程。', '主设备通过发送地址选择从设备，随后进行数据传输。数据传输过程中，主设备控制时钟信号，并通过应答机制确保数据正确接收。', '总线通信', 'medium', 10, 6, 'I2C,主从设备', 1, NULL, NULL, 1, '2025-09-11 16:53:08');
INSERT INTO `question_bank` VALUES (1131, 101, 'short_answer', '列举三种常见的无线通信技术，并简要说明其应用场景。', '蓝牙：用于短距离设备互联，如耳机、手环；Wi-Fi：用于高速互联网接入；ZigBee：用于低功耗物联网设备通信。', '无线通信基础', 'medium', 10, 7, '无线通信,WiFi,蓝牙,ZigBee', 1, NULL, NULL, 1, '2025-09-11 16:53:08');
INSERT INTO `question_bank` VALUES (1132, 101, 'programming', '编写一段C语言代码，实现通过UART发送字符串\"Hello World\"的功能。假设已定义函数uart_send_char(char c)用于发送单个字符。', '#include <stdio.h>\n\nvoid uart_send_string(const char *str) {\n    while (*str) {\n        uart_send_char(*str++);\n    }\n}\n\nint main() {\n    uart_send_string(\"Hello World\");\n    return 0;\n}', '串口通信', 'hard', 10, 15, 'C语言,串口通信', 1, NULL, NULL, 1, '2025-09-11 16:53:08');
INSERT INTO `question_bank` VALUES (1133, 101, 'programming', '使用SPI协议，编写一个函数实现向从设备发送一个字节的数据（假设函数原型为void spi_write_byte(uint8_t data)）。', '#include <stdint.h>\n\nvoid spi_write_byte(uint8_t data) {\n    // 假设SPI寄存器已定义\n    SPI_DATA_REGISTER = data;  // 写入数据寄存器\n    while (!(SPI_STATUS_REGISTER & SPI_FLAG_TXE));  // 等待发送完成\n}', '总线通信', 'hard', 10, 18, 'SPI,编程', 1, NULL, NULL, 1, '2025-09-11 16:53:08');
INSERT INTO `question_bank` VALUES (1134, 101, 'choice', '在嵌入式系统中，以下哪种调试工具可以用来查看和修改内存中的数据？\nA. 示波器\nB. 逻辑分析仪\nC. GDB\nD. JTAG调试器', 'D', '硬件调试工具', 'medium', 10, 3, '调试工具,嵌入式开发', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1135, 101, 'choice', '在嵌入式软件调试中，以下哪种技术可以用来检测内存泄漏？\nA. 静态代码分析\nB. 动态代码分析\nC. 单元测试\nD. 集成测试', 'B', '软件调试技术', 'medium', 10, 3, '调试技术,内存管理', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1136, 101, 'choice', '下列哪种测试方法通常用于验证嵌入式系统的功能是否符合需求？\nA. 性能测试\nB. 单元测试\nC. 集成测试\nD. 系统测试', 'D', '测试方法', 'easy', 10, 2, '测试方法,功能验证', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1137, 101, 'choice', '在嵌入式系统中，串口通信中常用的协议是？\nA. SPI\nB. I2C\nC. UART\nD. CAN', 'C', '串口通信', 'easy', 10, 2, '串口通信,协议', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1138, 101, 'choice', '以下哪种总线通信协议适合长距离传输？\nA. I2C\nB. UART\nC. RS-485\nD. SPI', 'C', '总线通信', 'medium', 10, 3, '总线通信,协议', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1139, 101, 'choice', '在无线通信中，蓝牙协议工作在哪个频段？\nA. 900 MHz\nB. 2.4 GHz\nC. 5 GHz\nD. 868 MHz', 'B', '无线通信基础', 'medium', 10, 3, '无线通信,协议', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1140, 101, 'choice', '在嵌入式系统中，以下哪种操作系统最适合实时性要求高的场景？\nA. Linux\nB. Android\nC. FreeRTOS\nD. Windows', 'C', '嵌入式操作系统', 'medium', 10, 3, '操作系统,实时性', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1141, 101, 'choice', '交叉编译工具链的主要作用是？\nA. 在目标设备上编译代码\nB. 在主机上编译目标设备可运行的代码\nC. 优化代码性能\nD. 进行静态分析', 'B', '交叉编译工具链', 'easy', 10, 2, '交叉编译,开发工具', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1142, 101, 'choice', '在嵌入式仿真中，GDB Server的主要作用是？\nA. 编译代码\nB. 调试目标设备上的程序\nC. 生成可执行文件\nD. 分析代码覆盖率', 'B', '调试与仿真', 'medium', 10, 3, '调试工具,仿真', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1143, 101, 'choice', '在实时操作系统中，任务调度的优先级调度算法属于哪种类型？\nA. 抢占式调度\nB. 非抢占式调度\nC. 时间片轮转调度\nD. 静态调度', 'A', '任务调度', 'medium', 10, 3, '任务调度,RTOS', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1144, 101, 'short_answer', '请简述JTAG调试接口的主要功能。', 'JTAG接口主要用于硬件调试，可以访问和控制嵌入式设备的内部寄存器、内存以及执行单步调试操作。', '硬件调试工具', 'medium', 10, 5, '调试工具,JTAG', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1145, 101, 'short_answer', '简述静态代码分析与动态代码分析的区别。', '静态代码分析是在不运行代码的情况下分析代码结构和潜在错误，而动态代码分析则是在代码运行时进行监控和分析。', '软件调试技术', 'medium', 10, 5, '调试技术,代码分析', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1146, 101, 'short_answer', '请列举三种常见的嵌入式系统测试方法，并简要说明其作用。', '单元测试：测试单个模块的功能；集成测试：验证多个模块组合后的功能；系统测试：验证整个系统是否满足需求。', '测试方法', 'medium', 10, 5, '测试方法,系统验证', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1147, 101, 'short_answer', '简述UART通信的基本原理。', 'UART通过异步串行通信方式，将数据按位发送和接收，使用起始位、数据位和停止位来标识数据帧。', '串口通信', 'medium', 10, 5, '串口通信,协议', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1148, 101, 'short_answer', '请简要说明CAN总线的特点及其适用场景。', 'CAN总线具有高可靠性和抗干扰能力，适用于工业控制、汽车电子等需要高可靠通信的场景。', '总线通信', 'medium', 10, 5, '总线通信,CAN', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1149, 101, 'short_answer', '请简述中断管理在嵌入式系统中的主要作用。', '中断管理用于响应外部或内部事件，暂停当前任务处理，优先处理紧急任务，提高系统实时性和效率。', '中断管理', 'medium', 10, 5, '中断管理,系统设计', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1150, 101, 'programming', '编写一个简单的C语言程序，实现通过UART发送字符串\"Hello World\"。', '#include <stdio.h>\n#include \"uart.h\"\n\nint main() {\n    uart_init();\n    uart_send_string(\"Hello World\\n\");\n    return 0;\n}', '串口通信', 'medium', 10, 10, '串口通信,编程', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1151, 101, 'programming', '请编写一个FreeRTOS任务，每100毫秒切换一次LED状态。', '#include \"FreeRTOS.h\"\n#include \"task.h\"\n#include \"gpio.h\"\n\nvoid vLEDTask(void *pvParameters) {\n    while (1) {\n        gpio_toggle(LED_PIN);\n        vTaskDelay(pdMS_TO_TICKS(100));\n    }\n}\n\nint main() {\n    xTaskCreate(vLEDTask, \"LED Task\", 100, NULL, 1, NULL);\n    vTaskStartScheduler();\n    return 0;\n}', '嵌入式操作系统', 'medium', 10, 10, 'RTOS,任务调度', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1152, 101, 'programming', '请编写一个简单的程序，使用I2C协议读取温度传感器的数据。', '#include \"i2c.h\"\n#include \"temperature_sensor.h\"\n\nint main() {\n    i2c_init();\n    uint8_t data[2];\n    i2c_read(TEMP_SENSOR_ADDR, data, 2);\n    int16_t temperature = (data[0] << 8) | data[1];\n    printf(\"Temperature: %d\\n\", temperature);\n    return 0;\n}', '总线通信', 'hard', 10, 10, 'I2C,传感器通信', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1153, 101, 'programming', '请编写一个使用中断的C程序，当按键按下时触发中断并切换LED状态。', '#include \"gpio.h\"\n#include \"interrupt.h\"\n\nvoid button_isr() {\n    gpio_toggle(LED_PIN);\n}\n\nint main() {\n    gpio_init(LED_PIN, OUTPUT);\n    gpio_init(BUTTON_PIN, INPUT);\n    interrupt_attach(BUTTON_PIN, button_isr);\n    while (1);\n    return 0;\n}', '中断管理', 'hard', 10, 10, '中断管理,GPIO', 1, NULL, NULL, 1, '2025-09-12 16:02:03');
INSERT INTO `question_bank` VALUES (1154, 101, 'choice', '以下哪种处理器架构属于RISC架构？\nA. x86\nB. ARM\nC. MIPS\nD. Both B and C', 'D', '处理器架构类型', 'easy', 10, 3, 'RISC, ARM, MIPS', 1, NULL, NULL, 1, '2025-09-13 00:07:48');
INSERT INTO `question_bank` VALUES (1155, 101, 'choice', '以下哪种存储器类型是嵌入式系统中最常用于存储程序代码的？\nA. RAM\nB. ROM\nC. Flash Memory\nD. Cache', 'C', '存储器结构', 'easy', 10, 3, 'Flash Memory, 存储器', 1, NULL, NULL, 1, '2025-09-13 00:07:48');
INSERT INTO `question_bank` VALUES (1156, 101, 'choice', '在ARM Cortex-M系列处理器中，以下哪个寄存器用于保存当前程序计数器的值？\nA. R0\nB. SP\nC. LR\nD. PC', 'D', '处理器架构类型', 'medium', 10, 4, 'ARM, 寄存器', 1, NULL, NULL, 1, '2025-09-13 00:07:48');
INSERT INTO `question_bank` VALUES (1157, 101, 'choice', '下列关于哈佛架构的描述，哪一项是正确的？\nA. 数据和指令共享同一个存储器\nB. 数据和指令使用独立的存储器\nC. 仅用于大型计算机\nD. 比冯·诺依曼架构更简单', 'B', '处理器架构类型', 'medium', 10, 4, '哈佛架构, 冯·诺依曼架构', 1, NULL, NULL, 1, '2025-09-13 00:07:48');
INSERT INTO `question_bank` VALUES (1158, 101, 'choice', '以下哪种机制可以提高嵌入式系统中处理器访问存储器的速度？\nA. 增加RAM容量\nB. 使用Cache\nC. 使用Flash Memory\nD. 使用ROM', 'B', '存储器结构', 'medium', 10, 4, 'Cache, 存储器', 1, NULL, NULL, 1, '2025-09-13 00:07:48');
INSERT INTO `question_bank` VALUES (1159, 101, 'short_answer', '简要说明冯·诺依曼架构和哈佛架构的主要区别。', '冯·诺依曼架构使用同一个存储器来存储指令和数据，而哈佛架构使用独立的存储器分别存储指令和数据。', '处理器架构类型', 'medium', 10, 6, '架构对比', 1, NULL, NULL, 1, '2025-09-13 00:07:48');
INSERT INTO `question_bank` VALUES (1160, 101, 'short_answer', '解释嵌入式系统中为什么Flash Memory常用于存储固件。', 'Flash Memory是非易失性存储器，可以擦除和重新编程，适合存储固件，如引导程序和操作系统镜像。', '存储器结构', 'medium', 10, 6, 'Flash Memory, 固件', 1, NULL, NULL, 1, '2025-09-13 00:07:48');
INSERT INTO `question_bank` VALUES (1161, 101, 'short_answer', '什么是处理器的指令集架构（ISA）？', '指令集架构（ISA）定义了处理器能够执行的指令集合，以及这些指令如何操作硬件资源。', '处理器架构类型', 'hard', 10, 8, 'ISA, 架构', 1, NULL, NULL, 1, '2025-09-13 00:07:48');
INSERT INTO `question_bank` VALUES (1162, 101, 'programming', '编写一个C语言函数，用于交换两个变量的值，使用指针实现。', 'void swap(int *a, int *b) {\n    int temp = *a;\n    *a = *b;\n    *b = temp;\n}', '处理器架构类型', 'medium', 10, 10, '指针, 交换变量', 1, NULL, NULL, 1, '2025-09-13 00:07:48');
INSERT INTO `question_bank` VALUES (1163, 101, 'programming', '编写一个ARM汇编程序片段，将寄存器R0和R1的值相加，并将结果存储到R2中。', 'ADD R2, R0, R1', '处理器架构类型', 'hard', 10, 12, 'ARM汇编, 寄存器', 1, NULL, NULL, 1, '2025-09-13 00:07:48');
INSERT INTO `question_bank` VALUES (1165, 101, 'choice', 'ARM处理器架构的指令集属于以下哪种类型？\nA. CISC\nB. RISC\nC. MISC\nD. VLIW', 'B', '处理器架构类型', 'medium', 10, 4, 'ARM, 指令集', 1, NULL, NULL, 1, '2025-09-13 17:27:06');
INSERT INTO `question_bank` VALUES (1167, 101, 'choice', '在嵌入式系统中，哪一种存储器需要定期刷新以保持数据？\nA. Flash\nB. ROM\nC. DRAM\nD. SRAM', 'C', '存储器结构', 'medium', 10, 4, '存储器, DRAM', 1, NULL, NULL, 1, '2025-09-13 17:27:06');
INSERT INTO `question_bank` VALUES (1168, 101, 'choice', 'ARM Cortex-M系列处理器主要面向哪种应用场景？\nA. 高性能计算\nB. 通用服务器\nC. 实时嵌入式系统\nD. 桌面操作系统', 'C', '处理器架构类型', 'medium', 10, 4, 'ARM Cortex-M, 嵌入式', 1, NULL, NULL, 1, '2025-09-13 17:27:06');
INSERT INTO `question_bank` VALUES (1169, 101, 'short_answer', '简要说明RISC架构相较于CISC架构的主要优势。', 'RISC架构简化了指令集，减少了执行每条指令所需的周期数，提高了执行效率，同时更容易实现流水线处理。', '处理器架构类型', 'medium', 10, 6, 'RISC, CISC, 架构比较', 1, NULL, NULL, 1, '2025-09-13 17:27:06');
INSERT INTO `question_bank` VALUES (1172, 101, 'programming', '请编写一段ARM汇编代码，实现两个32位整数的加法，并将结果保存到寄存器R2中。假设第一个数保存在R0中，第二个数保存在R1中。', 'ADD R2, R0, R1', '处理器架构类型', 'hard', 10, 10, 'ARM, 汇编编程', 1, NULL, NULL, 1, '2025-09-13 17:27:06');
INSERT INTO `question_bank` VALUES (1173, 101, 'programming', '编写一段C语言代码，模拟嵌入式系统中对Flash存储器进行写入操作的基本流程（假设Flash写入函数为flash_write(uint32_t address, uint32_t data)）。', '#include <stdint.h>\n\nvoid write_to_flash(uint32_t address, uint32_t data) {\n    // 检查地址是否合法\n    if (address >= FLASH_START && address <= FLASH_END) {\n        flash_write(address, data);\n    }\n}\n\nint main() {\n    uint32_t address = 0x08000000;\n    uint32_t data = 0x12345678;\n    write_to_flash(address, data);\n    return 0;\n}', '存储器结构', 'medium', 10, 10, 'Flash, C编程, 嵌入式', 1, NULL, NULL, 1, '2025-09-13 17:27:06');
INSERT INTO `question_bank` VALUES (1174, 101, 'choice', '以下哪项是对嵌入式系统的正确描述？\nA. 用于通用计算任务的系统\nB. 专门设计用于执行特定功能的计算机系统\nC. 仅用于大型服务器的系统\nD. 专为互联网数据处理设计的系统', 'B', '嵌入式系统概述', 'easy', 13, 2, '嵌入式系统定义', 1, NULL, NULL, 1, '2025-09-17 14:32:15');
INSERT INTO `question_bank` VALUES (1175, 101, 'choice', '以下哪种分类是基于功能复杂度的嵌入式系统分类？\nA. 实时系统和非实时系统\nB. 微控制器系统和微处理器系统\nC. 小型嵌入式系统、中型嵌入式系统、复杂嵌入式系统\nD. 有操作系统和无操作系统嵌入式系统', 'C', '嵌入式系统分类', 'medium', 13, 3, '嵌入式系统分类', 1, NULL, NULL, 1, '2025-09-17 14:32:15');
INSERT INTO `question_bank` VALUES (1176, 101, 'choice', '以下哪种处理器架构广泛应用于嵌入式领域？\nA. x86架构\nB. ARM架构\nC. SPARC架构\nD. MIPS架构', 'B', '处理器架构类型', 'medium', 13, 3, '处理器架构', 1, NULL, NULL, 1, '2025-09-17 14:32:15');
INSERT INTO `question_bank` VALUES (1177, 101, 'choice', '在嵌入式系统中，以下哪项是存储器的主要特点？\nA. 存储容量无限\nB. 需要持续供电才能保留数据\nC. 高速且容量大\nD. 容量有限且需要优化使用', 'D', '存储器结构', 'easy', 13, 2, '存储器特点', 1, NULL, NULL, 1, '2025-09-17 14:32:15');
INSERT INTO `question_bank` VALUES (1178, 101, 'choice', '以下哪种存储器通常用于嵌入式系统中的程序存储？\nA. RAM\nB. ROM\nC. Cache\nD. 虚拟内存', 'B', '存储器结构', 'medium', 13, 3, '程序存储器', 1, NULL, NULL, 1, '2025-09-17 14:32:15');
INSERT INTO `question_bank` VALUES (1179, 101, 'short_answer', '请简述嵌入式系统的主要特点。', '嵌入式系统通常具有专用性、资源受限性、实时性要求高、可靠性要求高以及功耗低等特点。', '嵌入式系统概述', 'medium', 13, 5, '嵌入式系统特点', 1, NULL, NULL, 1, '2025-09-17 14:32:15');
INSERT INTO `question_bank` VALUES (1180, 101, 'short_answer', '列举三种嵌入式系统的常见应用领域。', '工业自动化、智能家居、汽车电子、医疗设备、消费电子产品等。', '嵌入式系统分类', 'easy', 13, 4, '嵌入式应用', 1, NULL, NULL, 1, '2025-09-17 14:32:15');
INSERT INTO `question_bank` VALUES (1181, 101, 'short_answer', '简要说明ARM架构在嵌入式系统中广泛应用的原因。', 'ARM架构具有低功耗、高性能、可扩展性强、授权灵活等优点，适合嵌入式系统的应用需求。', '处理器架构类型', 'hard', 13, 6, 'ARM架构优势', 1, NULL, NULL, 1, '2025-09-17 14:32:15');
INSERT INTO `question_bank` VALUES (1182, 101, 'programming', '编写一段C代码，实现将一个32位整数写入指定内存地址（例如：0x20000000）。', 'int *ptr = (int *)0x20000000;\n*ptr = 0x12345678;', '存储器结构', 'medium', 13, 10, '内存操作', 1, NULL, NULL, 1, '2025-09-17 14:32:15');
INSERT INTO `question_bank` VALUES (1183, 101, 'programming', '编写一个简单的嵌入式C函数，实现对GPIO引脚的置位和清零操作（假设寄存器地址为0x40020000）。', '#define GPIO_BASE 0x40020000\n#define GPIO_SET (*(volatile unsigned int *)(GPIO_BASE + 0x18))\n#define GPIO_CLEAR (*(volatile unsigned int *)(GPIO_BASE + 0x28))\n\nvoid set_gpio_pin(int pin) {\n    GPIO_SET = (1 << pin);\n}\n\nvoid clear_gpio_pin(int pin) {\n    GPIO_CLEAR = (1 << pin);\n}', '处理器架构类型', 'hard', 13, 15, 'GPIO操作', 1, NULL, NULL, 1, '2025-09-17 14:32:15');
INSERT INTO `question_bank` VALUES (1184, 101, 'choice', '下列哪一项不属于嵌入式系统的基本特征？\nA. 专用性强\nB. 实时性要求高\nC. 具备通用操作系统如Windows\nD. 资源受限', 'C', '嵌入式系统概述', 'medium', 10, 3, '基础概念,特征识别', 1, NULL, NULL, 1, '2025-09-17 23:28:08');
INSERT INTO `question_bank` VALUES (1185, 101, 'choice', '以下哪种设备最可能使用深度嵌入式系统？\nA. 智能手机\nB. 工业PLC控制器\nC. 笔记本电脑\nD. 台式服务器', 'B', '嵌入式系统分类', 'medium', 10, 4, '系统分类,应用场景', 1, NULL, NULL, 1, '2025-09-17 23:28:08');
INSERT INTO `question_bank` VALUES (1186, 101, 'choice', '关于嵌入式系统的定义，下列说法正确的是？\nA. 所有带处理器的设备都是嵌入式系统\nB. 嵌入式系统是专为通用计算任务设计的计算机系统\nC. 嵌入式系统是以应用为中心、软硬件可裁剪的专用计算机系统\nD. 嵌入式系统必须配备图形用户界面', 'C', '嵌入式系统概述', 'easy', 10, 2, '定义理解,核心概念', 1, NULL, NULL, 1, '2025-09-17 23:28:08');
INSERT INTO `question_bank` VALUES (1187, 101, 'choice', '下列哪一类嵌入式系统通常具有实时操作系统（RTOS）支持？\nA. 家用洗衣机控制板\nB. 电子计算器\nC. 简易LED闪烁电路\nD. 普通U盘控制器', 'A', '嵌入式系统分类', 'medium', 10, 3, '实时系统,分类判断', 1, NULL, NULL, 1, '2025-09-17 23:28:08');
INSERT INTO `question_bank` VALUES (1188, 101, 'choice', '嵌入式系统与通用计算机的主要区别在于？\nA. 是否使用C语言编程\nB. 是否连接互联网\nC. 是否以特定应用为核心进行设计\nD. 是否具备键盘和显示器', 'C', '嵌入式系统概述', 'easy', 10, 2, '对比分析,本质区别', 1, NULL, NULL, 1, '2025-09-17 23:28:08');
INSERT INTO `question_bank` VALUES (1189, 101, 'short_answer', '简述嵌入式系统的三个主要特点。', '1. 以应用为中心；2. 软硬件可裁剪；3. 资源受限（如功耗、存储、处理能力）；4. 实时性要求高（答出任意三点即可）', '嵌入式系统概述', 'medium', 10, 5, '特点归纳,概念掌握', 1, NULL, NULL, 1, '2025-09-17 23:28:08');
INSERT INTO `question_bank` VALUES (1190, 101, 'short_answer', '请列举两种常见的嵌入式系统分类方式。', '1. 按实时性分为实时系统和非实时系统；2. 按是否使用操作系统分为裸机系统和基于操作系统的系统；3. 按应用领域分为工业控制、消费电子、汽车电子等（答出任意两种即可）', '嵌入式系统分类', 'medium', 10, 5, '分类方法,知识结构', 1, NULL, NULL, 1, '2025-09-17 23:28:08');
INSERT INTO `question_bank` VALUES (1191, 101, 'short_answer', '为什么大多数嵌入式系统需要考虑低功耗设计？', '因为许多嵌入式设备依赖电池供电，且常部署在难以更换电源的环境中，因此必须优化功耗以延长运行时间并提高可靠性。', '嵌入式系统概述', 'hard', 10, 6, '设计考量,实际应用', 1, NULL, NULL, 1, '2025-09-17 23:28:08');
INSERT INTO `question_bank` VALUES (1192, 101, 'programming', '编写一段C语言代码，实现一个简单的嵌入式系统初始化函数，包含关闭看门狗定时器、初始化系统时钟为72MHz，并设置GPIOA第5引脚为输出模式（假设使用STM32系列微控制器，无需包含头文件）。', 'void system_init() {\n    // 关闭看门狗\n    IWDG->KR = 0x0000CCCC;\n    IWDG->KR = 0x00005555;\n    IWDG->KR = 0x0000AAAA;\n\n    // 配置系统时钟为72MHz（假定HSE启用）\n    RCC->CR |= RCC_CR_HSEON;\n    while(!(RCC->CR & RCC_CR_HSERDY));\n    RCC->CFGR &= ~RCC_CFGR_SW;\n    RCC->CFGR |= RCC_CFGR_SW_PLL;\n    RCC->CFGR &= ~RCC_CFGR_PLLSRC;\n    RCC->CFGR |= RCC_CFGR_PLLSRC_HSE;\n    RCC->CFGR &= ~RCC_CFGR_PLLMULL;\n    RCC->CFGR |= RCC_CFGR_PLLMULL9; // 9×8MHz=72MHz\n    RCC->CR |= RCC_CR_PLLON;\n    while(!(RCC->CR & RCC_CR_PLLRDY));\n    RCC->CFGR |= RCC_CFGR_SW_PLL;\n\n    // 初始化GPIOA第5引脚为推挽输出\n    RCC->APB2ENR |= RCC_APB2ENR_IOPAEN;\n    GPIOA->CRL &= ~GPIO_CRL_MODE5;\n    GPIOA->CRL |= GPIO_CRL_MODE5_1;\n    GPIOA->CRL &= ~GPIO_CRL_CNF5;\n}', '嵌入式系统概述', 'hard', 10, 12, '代码实现,硬件初始化', 1, NULL, NULL, 1, '2025-09-17 23:28:08');
INSERT INTO `question_bank` VALUES (1193, 101, 'programming', '设计一个用于嵌入式环境的简单任务调度结构体，并编写一个函数schedule_task，该函数接收任务函数指针和执行周期（单位：ms），将其注册到调度器中（只需框架设计，不需完整RTOS实现）。', 'typedef struct {\n    void (*task_func)();\n    uint32_t period_ms;\n    uint32_t last_exec_time;\n    int active;\n} Task;\n\n#define MAX_TASKS 10\nTask task_list[MAX_TASKS];\nint task_count = 0;\n\nint schedule_task(void (*func)(), uint32_t period) {\n    if (task_count >= MAX_TASKS) return -1;\n    task_list[task_count].task_func = func;\n    task_list[task_count].period_ms = period;\n    task_list[task_count].last_exec_time = 0;\n    task_list[task_count].active = 1;\n    task_count++;\n    return 0;\n}', '嵌入式系统分类', 'hard', 10, 14, '系统架构,任务调度', 1, NULL, NULL, 1, '2025-09-17 23:28:08');
INSERT INTO `question_bank` VALUES (1194, 101, 'choice', '下列哪一项不属于嵌入式系统的特点？\nA. 专用性强\nB. 实时性要求高\nC. 通用操作系统支持完整桌面应用\nD. 资源受限（如内存、处理器性能）', 'C', '嵌入式系统概述', 'medium', 10, 2, '特点,判断', 1, NULL, NULL, 1, '2025-09-17 23:47:46');
INSERT INTO `question_bank` VALUES (1195, 101, 'choice', '以下哪种设备最可能使用深度嵌入式系统？\nA. 智能手机\nB. 工业PLC控制器\nC. 笔记本电脑\nD. 台式服务器', 'B', '嵌入式系统分类', 'medium', 10, 3, '分类,应用场景', 1, NULL, NULL, 1, '2025-09-17 23:47:46');
INSERT INTO `question_bank` VALUES (1196, 101, 'choice', '嵌入式系统的典型应用领域不包括：\nA. 消费电子\nB. 航空航天\nC. 大型科学计算集群\nD. 医疗设备', 'C', '嵌入式系统概述', 'easy', 10, 2, '应用领域', 1, NULL, NULL, 1, '2025-09-17 23:47:46');
INSERT INTO `question_bank` VALUES (1197, 101, 'choice', '下列关于嵌入式系统与通用计算机的区别，描述正确的是：\nA. 嵌入式系统通常运行Windows或Linux完整发行版\nB. 通用计算机强调专用性和低功耗设计\nC. 嵌入式系统软硬件可裁剪以满足特定需求\nD. 通用计算机主要用于单一功能控制任务', 'C', '嵌入式系统概述', 'medium', 10, 3, '对比,特性', 1, NULL, NULL, 1, '2025-09-17 23:47:46');
INSERT INTO `question_bank` VALUES (1198, 101, 'choice', '根据复杂度划分，以下哪类嵌入式系统通常包含实时操作系统（RTOS）？\nA. 无操作系统的小型单片机系统\nB. 中高端嵌入式系统\nC. 纯机械控制装置\nD. 模拟电路组成的定时器', 'B', '嵌入式系统分类', 'hard', 10, 4, '分类,RTOS', 1, NULL, NULL, 1, '2025-09-17 23:47:46');
INSERT INTO `question_bank` VALUES (1199, 101, 'short_answer', '简述嵌入式系统的基本定义。', '嵌入式系统是以应用为中心，以计算机技术为基础，软硬件可裁剪，对功能、可靠性、成本、体积、功耗等有严格要求的专用计算机系统。', '嵌入式系统概述', 'easy', 10, 5, '定义,简答', 1, NULL, NULL, 1, '2025-09-17 23:47:46');
INSERT INTO `question_bank` VALUES (1200, 101, 'short_answer', '请列举三种常见的嵌入式系统分类方式。', '按性能分类（低端/中高端）、按实时性分类（实时/非实时）、按用途分类（工业控制、消费电子、汽车电子等）。', '嵌入式系统分类', 'medium', 10, 6, '分类方法,列举', 1, NULL, NULL, 1, '2025-09-17 23:47:46');
INSERT INTO `question_bank` VALUES (1201, 101, 'short_answer', '为什么大多数嵌入式系统需要考虑功耗问题？', '因为许多嵌入式设备依赖电池供电或部署在难以更换电源的环境中，低功耗设计有助于延长工作时间、减少散热和提高可靠性。', '嵌入式系统概述', 'medium', 10, 5, '功耗,设计考量', 1, NULL, NULL, 1, '2025-09-17 23:47:46');
INSERT INTO `question_bank` VALUES (1202, 101, 'programming', '编写一段C语言代码，模拟一个简单的嵌入式系统初始化流程，包括系统时钟配置、GPIO初始化和中断使能。假设使用伪函数clock_init(), gpio_init(), enable_irq()。', '#include <stdio.h>\n\nvoid clock_init();\nvoid gpio_init();\nvoid enable_irq();\n\nint main() {\n    clock_init();     // 配置系统时钟\n    gpio_init();      // 初始化GPIO端口\n    enable_irq();     // 使能全局中断\n    \n    while(1) {\n        // 主循环\n    }\n    return 0;\n}', '嵌入式系统概述', 'medium', 10, 10, '初始化,C语言', 1, NULL, NULL, 1, '2025-09-17 23:47:46');
INSERT INTO `question_bank` VALUES (1203, 101, 'programming', '设计一个结构体来表示不同类型的嵌入式系统，包含字段：type（如\'Industrial\', \'Consumer\', \'Automotive\'）、hasRTOS（布尔值）、cpuSpeedMHz（整数）。并创建两个实例分别代表工业控制系统和消费电子产品。', '#include <stdio.h>\n\nstruct EmbeddedSystem {\n    char type[20];\n    int hasRTOS; // 1表示true，0表示false\n    int cpuSpeedMHz;\n};\n\nint main() {\n    struct EmbeddedSystem industrial = {\"Industrial\", 1, 800};\n    struct EmbeddedSystem consumer = {\"Consumer\", 1, 1200};\n\n    printf(\"Type: %s, RTOS: %s, Speed: %d MHz\\n\", \n           industrial.type, industrial.hasRTOS ? \"yes\" : \"no\", industrial.cpuSpeedMHz);\n    printf(\"Type: %s, RTOS: %s, Speed: %d MHz\\n\", \n           consumer.type, consumer.hasRTOS ? \"yes\" : \"no\", consumer.cpuSpeedMHz);\n    \n    return 0;\n}', '嵌入式系统分类', 'hard', 10, 15, '结构体,分类建模,C语言', 1, NULL, NULL, 1, '2025-09-17 23:47:46');
INSERT INTO `question_bank` VALUES (1204, 101, 'choice', '以下哪项不属于嵌入式系统的特点？\nA. 专用性强\nB. 实时性要求高\nC. 通用操作系统支持完整桌面应用\nD. 资源受限（如内存、处理器性能）', 'C', '嵌入式系统概述', 'medium', 10, 3, '特点,嵌入式系统', 1, NULL, NULL, 1, '2025-09-17 23:54:45');
INSERT INTO `question_bank` VALUES (1205, 101, 'choice', '下列哪种设备最可能使用实时嵌入式系统？\nA. 智能手表\nB. 工业机器人控制器\nC. 家用洗衣机\nD. 数码相框', 'B', '嵌入式系统分类', 'easy', 10, 2, '实时系统,分类', 1, NULL, NULL, 1, '2025-09-17 23:54:45');
INSERT INTO `question_bank` VALUES (1206, 101, 'choice', '关于嵌入式系统的定义，以下描述最准确的是：\nA. 所有带微处理器的电子设备都是嵌入式系统\nB. 嵌入式系统是专为运行Linux而设计的计算机系统\nC. 嵌入式系统是用于执行特定功能的专用计算机系统，通常嵌入在更大的设备中\nD. 嵌入式系统必须具备网络连接能力', 'C', '嵌入式系统概述', 'easy', 10, 2, '定义,概述', 1, NULL, NULL, 1, '2025-09-17 23:54:45');
INSERT INTO `question_bank` VALUES (1207, 101, 'choice', '下列哪一类嵌入式系统对时间响应的要求最为严格？\nA. 非实时系统\nB. 软实时系统\nC. 硬实时系统\nD. 批处理系统', 'C', '嵌入式系统分类', 'medium', 10, 3, '实时性,分类', 1, NULL, NULL, 1, '2025-09-17 23:54:45');
INSERT INTO `question_bank` VALUES (1208, 101, 'choice', '以下哪个应用场景不适合采用嵌入式系统？\nA. 自动驾驶汽车中的传感器数据处理\nB. 医疗设备中的生命体征监测\nC. 大型数据中心的虚拟机管理平台\nD. 智能家居中的温控器', 'C', '嵌入式系统概述', 'medium', 10, 3, '应用场景,概述', 1, NULL, NULL, 1, '2025-09-17 23:54:45');
INSERT INTO `question_bank` VALUES (1209, 101, 'short_answer', '简述嵌入式系统与通用计算机的主要区别。', '嵌入式系统通常是为特定任务设计的专用系统，资源受限，强调实时性和可靠性；而通用计算机面向多种应用，具有丰富的外设和强大的计算能力，运行通用操作系统。', '嵌入式系统概述', 'medium', 10, 6, '对比,概述', 1, NULL, NULL, 1, '2025-09-17 23:54:45');
INSERT INTO `question_bank` VALUES (1210, 101, 'short_answer', '请列举三种常见的嵌入式系统分类方式。', '按实时性可分为硬实时、软实时和非实时系统；按用途可分为工业控制类、消费电子类、汽车电子类等；按处理器架构可分为基于ARM、MIPS、RISC-V等的系统。', '嵌入式系统分类', 'medium', 10, 6, '分类方式,类型', 1, NULL, NULL, 1, '2025-09-17 23:54:45');
INSERT INTO `question_bank` VALUES (1211, 101, 'short_answer', '为什么大多数嵌入式系统不使用完整的桌面操作系统（如Windows）？', '因为桌面操作系统资源消耗大、启动慢、缺乏实时性支持，且功能冗余，不适合资源受限和高实时性要求的嵌入式环境。', '嵌入式系统概述', 'hard', 10, 8, '操作系统选择,资源限制', 1, NULL, NULL, 1, '2025-09-17 23:54:45');
INSERT INTO `question_bank` VALUES (1212, 101, 'programming', '编写一段C语言代码，模拟一个简单的嵌入式温度监控系统。要求：定义一个结构体TemperatureSensor，包含sensor_id、current_temp、is_active字段；实现一个函数check_temperature，当温度超过设定阈值（如75°C）时返回1（表示报警），否则返回0。', '#include <stdio.h>\ntypedef struct {\n    int sensor_id;\n    float current_temp;\n    int is_active;\n} TemperatureSensor;\n\nint check_temperature(TemperatureSensor *sensor) {\n    if (sensor->is_active && sensor->current_temp > 75.0) {\n        return 1;\n    }\n    return 0;\n}', '嵌入式系统概述', 'medium', 10, 12, 'C语言,结构体,嵌入式模拟', 1, NULL, NULL, 1, '2025-09-17 23:54:45');
INSERT INTO `question_bank` VALUES (1213, 101, 'programming', '在嵌入式系统中，常需根据设备类型执行不同操作。请使用枚举和switch语句编写一个函数device_handler，接收设备类型（如SENSOR、ACTUATOR、CONTROLLER），并输出对应的操作提示（例如：\'Handling sensor data...\'）。', '#include <stdio.h>\ntypedef enum {\n    SENSOR,\n    ACTUATOR,\n    CONTROLLER\n} DeviceType;\n\nvoid device_handler(DeviceType type) {\n    switch(type) {\n        case SENSOR:\n            printf(\"Handling sensor data...\\n\");\n            break;\n        case ACTUATOR:\n            printf(\"Activating actuator...\\n\");\n            break;\n        case CONTROLLER:\n            printf(\"Processing control logic...\\n\");\n            break;\n        default:\n            printf(\"Unknown device type\\n\");\n    }\n}', '嵌入式系统分类', 'hard', 10, 15, '枚举,控制流,设备分类', 1, NULL, NULL, 1, '2025-09-17 23:54:45');

-- ----------------------------
-- Table structure for question_bank_category
-- ----------------------------
DROP TABLE IF EXISTS `question_bank_category`;
CREATE TABLE `question_bank_category`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '分类描述',
  `color` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类颜色',
  `icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类图标',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `is_active` tinyint(1) NULL DEFAULT 1 COMMENT '是否启用',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `course_id` int NULL DEFAULT NULL COMMENT '课程名',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_created_by`(`created_by` ASC) USING BTREE,
  INDEX `idx_sort_order`(`sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '题库分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of question_bank_category
-- ----------------------------
INSERT INTO `question_bank_category` VALUES (10, '嵌入式开发基础题库', '测试版', NULL, NULL, 0, 1, NULL, '2025-09-10 19:06:05', '2025-09-10 20:37:31', 101);
INSERT INTO `question_bank_category` VALUES (11, '计算机网络期末题库', '计网期末题库\n', NULL, NULL, 0, 1, NULL, '2025-09-10 22:06:00', '2025-09-10 22:06:00', 102);
INSERT INTO `question_bank_category` VALUES (12, '计算机网络期末考试题库', '1111', NULL, NULL, 0, 1, NULL, '2025-09-11 08:01:00', '2025-09-11 08:01:00', 102);
INSERT INTO `question_bank_category` VALUES (13, '嵌入式开发期末测试卷', '无', NULL, NULL, 0, 1, NULL, '2025-09-16 15:34:52', '2025-09-16 15:34:52', 101);
INSERT INTO `question_bank_category` VALUES (14, '计算机网络期中测试题', '111', NULL, NULL, 0, 1, NULL, '2025-09-16 15:37:58', '2025-09-16 15:37:58', 102);
INSERT INTO `question_bank_category` VALUES (15, '计算机网络期中题库', '111', NULL, NULL, 0, 1, NULL, '2025-09-17 14:29:07', '2025-09-17 14:29:07', 102);

-- ----------------------------
-- Table structure for resource_file
-- ----------------------------
DROP TABLE IF EXISTS `resource_file`;
CREATE TABLE `resource_file`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_id` bigint NOT NULL,
  `teacher_id` bigint NOT NULL,
  `file_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `uploaded_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `course_id`(`course_id` ASC) USING BTREE,
  INDEX `teacher_id`(`teacher_id` ASC) USING BTREE,
  CONSTRAINT `resource_file_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `resource_file_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 33 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of resource_file
-- ----------------------------
INSERT INTO `resource_file` VALUES (4, 101, 2, 'cp07-样章示例-TensorFlow.js应用开发.docx', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/95ff1eb3-8398-4922-aff3-2a703de47ba5-cp07-样章示例-TensorFlow.js应用开发.docx', '2025-07-20 11:20:36');
INSERT INTO `resource_file` VALUES (5, 101, 2, '嵌入式系统开发教学大纲.docx', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/d1d452b9-c8f5-40b3-86df-364e5b9fe4fe-嵌入式系统开发教学大纲.docx', '2025-07-20 11:26:56');
INSERT INTO `resource_file` VALUES (23, 102, 2, '计算机网络知识点汇总.pdf', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/3ffe4a09-a5c1-4ba8-bf57-114f989ef01c-计算机网络知识点汇总.pdf', '2025-09-03 19:25:20');
INSERT INTO `resource_file` VALUES (24, 102, 2, '计算机网络期末考试真题.docx', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/a9dae44a-e0e4-4b08-a8ee-1cf442e12638-计算机网络期末考试真题.docx', '2025-09-03 19:34:58');
INSERT INTO `resource_file` VALUES (25, 101, 2, 'cp08-样章示例-TensorFlow Lite.docx', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/eeeaf179-ebe9-428f-9044-b95f37432122-cp08-样章示例-TensorFlow Lite.docx', '2025-09-03 20:22:16');
INSERT INTO `resource_file` VALUES (33, 101, 2, '嵌入式开发进阶_2025-09-17.docx', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/0e9ceace-1948-4ef9-ada4-be512b1e64be-嵌入式开发进阶_2025-09-17.docx', '2025-09-18 15:27:10');

-- ----------------------------
-- Table structure for stat_overview
-- ----------------------------
DROP TABLE IF EXISTS `stat_overview`;
CREATE TABLE `stat_overview`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `active_teachers` int NULL DEFAULT NULL,
  `active_students` int NULL DEFAULT NULL,
  `total_questions` int NULL DEFAULT NULL,
  `avg_correct_rate` float NULL DEFAULT NULL,
  `top_error_topics` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of stat_overview
-- ----------------------------

-- ----------------------------
-- Table structure for student_analysis_report
-- ----------------------------
DROP TABLE IF EXISTS `student_analysis_report`;
CREATE TABLE `student_analysis_report`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `student_id` bigint NOT NULL COMMENT '学生ID',
  `course_id` bigint NOT NULL COMMENT '课程ID',
  `knowledge_analysis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '知识掌握情况分析',
  `teaching_suggestion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '教学建议',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `student_id`(`student_id` ASC) USING BTREE,
  INDEX `course_id`(`course_id` ASC) USING BTREE,
  CONSTRAINT `student_analysis_report_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `student_analysis_report_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of student_analysis_report
-- ----------------------------
INSERT INTO `student_analysis_report` VALUES (1, 1, 101, '该生对嵌入式系统的基本概念理解存在明显偏差，未能准确区分嵌入式系统与通用操作系统（如Linux），也未把握其核心特征如“裁剪优化”、“专用性”和“资源受限”，反映出基础知识掌握不牢，理解不够深入。', '应强化嵌入式系统定义及其应用场景的教学，通过具体实例帮助学生建立正确认知；重点讲解与通用系统的区别，突出“裁剪”“适配硬件”“实时性”等关键词；鼓励学生多做练习并参与互动，提升表达的准确性与逻辑性。', '2025-07-13 16:58:57');
INSERT INTO `student_analysis_report` VALUES (2, 1, 101, '该生对嵌入式系统相关概念理解较薄弱，尤其在嵌入式Linux的定义、嵌入式系统的组成及应用场景方面存在较大不足。多次出现答非所问或完全无关答案（如“666”、“666546”），说明缺乏基本理解或学习态度存在问题。但在部分问题中已能掌握核心内容，如正确回答出“嵌入式Linux是针对嵌入式设备裁剪优化的Linux系统”，表明具备一定基础但需加强巩固。', '应重点加强对该生基础知识的辅导，尤其是嵌入式系统与嵌入式Linux的核心概念、特点及其应用的理解。建议通过多轮练习与讲解相结合的方式，帮助其建立清晰的知识框架；同时鼓励学生积极参与课堂互动和课后练习，提升学习主动性与专注度。对于重复出现无效作答的情况，应进行个别沟通了解原因，防止学习脱节。', '2025-07-15 19:24:28');
INSERT INTO `student_analysis_report` VALUES (3, 1, 101, '该生对嵌入式Linux的基本概念有一定理解，能够正确回答相关定义问题。但在编程类题目上表现较差，多次提交无效或错误答案，反映出C语言编程基础薄弱，尤其在编写和表达程序代码方面存在明显不足。此外，在选择题中也出现了因理解偏差导致的错误，如误判嵌入式系统特征。整体来看，学生对理论性知识点掌握尚可，但实践能力尤其是编程应用能力亟待提升。', '建议加强C语言编程的基础训练，重点讲解变量定义、程序结构及常见语法规范，并通过大量实例练习提高学生的代码书写与逻辑思维能力。在嵌入式相关内容的教学中，应结合软硬件操作场景进行深入解析，帮助学生建立理论与实践之间的联系。同时，建议增加课堂互动与作业反馈，及时纠正学生的理解误区，强化关键知识点的巩固与应用能力。', '2025-07-17 19:51:38');
INSERT INTO `student_analysis_report` VALUES (4, 1, 101, '该生在嵌入式系统理论基础知识方面表现良好，能够正确回答“嵌入式Linux”的定义问题，说明具备一定的概念理解能力。但在编程类题目上存在明显短板，多次提交无效、错误或格式不正确的C语言程序，反映出C语言基础薄弱，特别是变量定义、语法结构和代码书写规范掌握不牢。此外，在选择题中出现对嵌入式系统特征理解偏差的情况，说明对知识点的综合理解和辨析能力较弱。', '建议强化C语言编程的基础训练，重点讲解变量、指针、函数及基本语法结构，并通过大量编程练习提升代码编写能力与调试技巧。在嵌入式系统教学中，应加强理论与实践结合，设计更多基于GPIO控制、寄存器操作等具体场景的编程任务，提高学生的动手能力。同时，建议通过错题讲解和知识点回顾，帮助学生厘清易混淆概念（如嵌入式系统特征），提升综合理解与应用能力。', '2025-07-17 20:00:04');
INSERT INTO `student_analysis_report` VALUES (5, 1, 101, '该生在嵌入式系统的基础理论知识方面掌握较好，能够准确回答“嵌入式Linux”的定义问题，体现出对核心概念有一定的理解能力。但在编程类题目中表现较差，多次提交无效、格式错误或与题目无关的答案，反映出其在C语言编程方面存在明显薄弱环节，尤其是程序结构、语法规范和代码编写能力不足。此外，在选择题中也暴露出对嵌入式系统特征理解不准确的问题，说明对知识点的辨析和综合掌握仍需加强。', '建议加强C语言编程基础教学，重点训练变量定义、基本语法结构、函数调用及指针操作等内容，通过大量编程实例和调试练习提升学生代码编写能力与逻辑思维能力。在嵌入式系统教学中，应结合具体应用场景（如GPIO控制、寄存器配置等）进行实践训练，帮助学生将理论知识转化为实际操作能力。同时，建议通过专项讲解和错题分析，强化学生对易混淆知识点的理解与记忆，提升综合应用能力。', '2025-07-17 20:12:16');
INSERT INTO `student_analysis_report` VALUES (6, 1, 102, '该生在嵌入式系统的基础理论知识方面表现良好，能够多次正确回答“嵌入式Linux”的定义问题，说明对基本概念有清晰的理解。然而，在编程类题目中存在严重问题，多次提交无效、错误格式或完全不相关的答案（如数字或符号），表明其C语言基础薄弱，缺乏基本的程序设计能力和语法规范意识。此外，在选择题中出现对嵌入式系统特征理解错误的情况，反映出学生对知识点掌握不够扎实，存在记忆偏差和理解不清的问题。', '应重点加强该生的C语言编程基础训练，从变量定义、控制结构、函数使用等基础内容入手，逐步提升编程能力。建议采用“讲练结合”的方式，通过大量简单实例练习帮助其建立编程思维。在嵌入式课程教学中，应强化GPIO控制、寄存器操作等典型应用场景的实践训练，增强学生的动手能力和理论联系实际的能力。同时，建议开展知识点梳理与错题讲解，帮助其纠正理解偏差，提高综合判断与应用能力。', '2025-07-17 20:15:31');
INSERT INTO `student_analysis_report` VALUES (7, 1, 102, '该生在基础理论方面表现稳定，能够准确理解和回答关于“嵌入式Linux”的定义问题，体现出对核心概念的掌握较为扎实。但在编程类题目中表现极差，多次提交格式错误、内容无关或完全不符合要求的答案，说明其在C语言编程方面存在严重薄弱环节，缺乏基本的语法知识和编程逻辑能力。此外，在选择题中出现对嵌入式系统特征理解错误，表明其对知识点的辨析和综合掌握仍不够深入。', '建议从C语言基础语法入手，强化变量、运算符、控制结构、函数等基础编程知识的教学，通过大量简单、有针对性的编程练习帮助学生建立编程思维。在嵌入式教学中，应增加GPIO控制、寄存器访问等典型应用场景的编程训练，提升学生的动手能力和代码实现能力。同时，建议开展错题分析和知识点回顾课程，帮助学生厘清易混淆概念，提高综合理解和应用能力。', '2025-07-17 20:21:39');
INSERT INTO `student_analysis_report` VALUES (8, 1, 102, '该生在基础理论知识方面掌握较好，能够多次准确回答“嵌入式Linux”的定义问题，体现出对核心概念的理解较为清晰。但在编程类题目中表现极不理想，频繁提交无效内容、格式错误或与题目无关的答案，说明其在C语言编程方面存在严重薄弱环节，缺乏基本的语法掌握和程序逻辑思维能力。此外，在选择题中也暴露出对嵌入式系统特征理解偏差的问题，反映出知识点掌握不牢、辨析能力较弱。', '建议从C语言基础入手，系统性地强化变量定义、程序结构、运算符使用、函数调用等基本编程技能的训练，帮助学生建立正确的编程思维模式。在教学过程中应增加编程练习的频次，采用由浅入深的方式引导学生逐步掌握嵌入式开发中常用的编程技巧，如GPIO控制、寄存器配置等。同时，建议开展知识点归纳与错题讲解，帮助学生查漏补缺，提升对易混淆概念的理解和记忆，增强综合应用能力。', '2025-07-17 20:21:39');
INSERT INTO `student_analysis_report` VALUES (9, 1, 102, '该生在理论类题目中表现较好，能够准确回答“嵌入式Linux”的定义问题，说明对嵌入式系统的基本概念有一定理解。但在编程类题目中表现较差，多次提交无效内容（如数字、符号或不完整代码），反映出其C语言基础薄弱，缺乏基本的编程思维和代码书写能力。同时，在部分选择题中也出现错误，如对嵌入式系统特征判断错误，说明对知识点的理解不够全面、准确，存在记忆混淆和辨析能力不足的问题。', '建议加强对该生C语言编程基础的训练，从变量、运算符、控制结构、函数等基础语法入手，逐步提升其编程能力和代码规范意识。教学中应结合嵌入式开发典型场景（如GPIO控制、中断处理等）进行实例教学，提高学生对理论知识的实际应用能力。同时，建议通过错题讲评、知识点对比讲解等方式，帮助学生厘清易混淆内容，强化理解和记忆，提升综合解题能力。', '2025-07-17 20:21:44');
INSERT INTO `student_analysis_report` VALUES (10, 1, 102, '该生在理论知识方面对嵌入式系统的核心概念有一定掌握，如能够多次正确回答“嵌入式Linux”的定义，体现出对基础内容的理解能力。但在编程类题目中表现较差，频繁提交无效、格式错误或与题目无关的内容，反映出其C语言编程基础严重薄弱，缺乏基本的语法掌握和程序逻辑构建能力。此外，在部分选择题中出现理解偏差和判断错误，说明其对知识点的掌握不够扎实，存在记忆不清和辨析能力不足的问题。', '建议强化该生的C语言基础教学，从变量、控制语句、函数、指针等核心语法入手，通过大量简单编程练习培养其编程思维和代码规范意识。在嵌入式课程教学中，应结合典型应用场景（如LED控制、按键检测等GPIO操作）进行项目式训练，提升其动手能力和理论联系实际的能力。同时，建议加强错题分析与知识点对比讲解，帮助学生加深理解、纠正误区，提升综合应用与解题能力。', '2025-07-17 20:21:56');
INSERT INTO `student_analysis_report` VALUES (11, 1, 101, '该生在嵌入式系统的基础理论知识掌握上表现稳定，多次正确回答“嵌入式Linux”的定义，说明具备一定的概念理解能力。但在编程类题目中表现极不理想，多次提交无效内容（如数字、符号、不完整代码等），反映出其C语言基础非常薄弱，缺乏基本的语法掌握和编程思维。此外，在选择题中出现对嵌入式系统特征理解错误，表明其对知识点的辨析能力不足，存在理解偏差。', '建议从C语言基础语法入手，强化变量、运算符、控制结构、函数、指针等核心内容的学习与训练，通过大量简单、针对性强的编程练习帮助其建立编程思维。在嵌入式教学中，应结合具体应用实例（如LED闪烁、按键控制等GPIO操作）进行项目式教学，增强学生的动手能力和理论联系实际的能力。同时，建议定期进行错题回顾和知识点梳理，帮助学生纠正错误理解，提升综合判断与应用能力。', '2025-07-17 20:22:45');
INSERT INTO `student_analysis_report` VALUES (12, 1, 101, '该生在嵌入式系统的基础理论方面掌握较好，能够多次正确回答“嵌入式Linux”的定义，说明具备扎实的概念理解能力。但在编程类题目中表现极差，频繁提交无效内容（如数字、符号或不完整代码），反映出其C语言基础严重薄弱，缺乏基本语法掌握与程序设计思维。此外，在选择题中出现对知识点理解偏差的情况，表明其综合辨析能力和记忆准确性仍需提升。', '建议从C语言基础语法入手，强化变量、控制结构、函数、指针等核心内容的教学，并通过大量简单编程练习逐步建立学生的逻辑思维和代码规范意识。在嵌入式课程中，应结合典型应用场景（如LED控制、按键检测等GPIO操作）进行项目化教学，提升其实操能力。同时，建议开展错题讲评与知识点对比讲解，帮助学生厘清易混淆概念，提升整体理解和应用水平。', '2025-07-17 20:23:34');
INSERT INTO `student_analysis_report` VALUES (13, 1, 101, '该生在嵌入式系统的基础理论方面掌握较好，能够多次正确回答“嵌入式Linux”的定义，说明具备扎实的概念理解能力。但在编程类题目中表现极差，频繁提交无效内容（如数字、符号或不完整代码），反映出其C语言基础严重薄弱，缺乏基本语法掌握与程序设计能力。此外，在选择题和简答题中也出现理解偏差和判断错误，说明其对知识点的综合运用能力不足。', '建议从C语言基础语法入手，强化变量、运算符、控制结构、函数等核心内容的教学，并通过大量简单、有针对性的编程练习帮助学生逐步建立编程思维。在嵌入式课程教学中，应结合典型应用场景（如LED控制、GPIO操作等）进行项目式训练，提升学生的动手能力和代码编写能力。同时，建议加强错题讲评与知识点对比讲解，帮助学生厘清易混淆内容，提升理解与应用能力。', '2025-07-17 20:33:02');
INSERT INTO `student_analysis_report` VALUES (14, 1, 101, '该生在嵌入式系统的基础理论方面表现稳定，多次正确回答“嵌入式Linux”的定义，说明具备扎实的概念理解能力。但在编程类题目中表现极不理想，频繁提交无效内容（如数字、符号或不完整代码），反映出其C语言基础严重薄弱，缺乏基本语法掌握和程序设计思维。此外，在部分选择题与简答题中也出现理解偏差与答题混乱的情况，表明其对知识点的综合辨析能力和应用能力较弱。', '建议从C语言基础语法入手，重点强化变量、控制结构、函数等核心内容的教学，并通过大量简单编程练习逐步提升学生的逻辑思维与代码书写能力。在嵌入式课程教学中，应结合实际开发场景（如LED闪烁、按键检测等GPIO操作）进行案例式教学，增强学生动手能力与知识应用能力。同时，建议加强错题讲解与知识点梳理，帮助学生纠正误区、巩固基础，提升整体学习效果。', '2025-07-17 20:33:08');
INSERT INTO `student_analysis_report` VALUES (15, 1, 101, '该生在部分基础知识上表现出一定理解能力，如对“嵌入式Linux是针对嵌入式设备裁剪优化的Linux系统”这一概念掌握准确，且多次作答均正确。但整体来看，学生在编程题和理解题上存在较大短板，尤其是对题目要求缺乏理解，编程题作答混乱（如输入无关数字或格式错误），显示出对C语言编程基础、嵌入式系统原理及特征掌握不牢。此外，选择题的错误也反映出对嵌入式系统基本特性的判断不清，未能掌握关键知识点。', '建议加强对学生编程基础的训练，尤其是C语言在嵌入式开发中的应用，采用“从简到难”的编程练习方式，提升代码书写与逻辑思维能力。同时，通过实例讲解和课堂互动，帮助学生深入理解嵌入式系统的核心概念与特征。对于理解能力较弱的题目，建议增加随堂测验和即时反馈机制，及时纠正错误认知。鼓励学生多动手实践，结合开发板进行程序烧录与调试，强化理论与实践结合能力。', '2025-07-19 12:05:01');
INSERT INTO `student_analysis_report` VALUES (16, 1, 101, '该生在部分基础概念题上表现良好，例如对“嵌入式Linux”的基本定义有一定理解，能够正确回答相关选择题和简答题。但在编程题、复杂简答题和部分选择题上表现较差，频繁出现无关答案（如数字“6”“8”“6666”等），说明其对嵌入式系统的核心原理、应用场景、开发流程及编程实践掌握不牢，存在明显的理解偏差和答题敷衍现象。', '建议加强对学生的基础概念讲解，尤其是嵌入式系统的基本特征、应用场景、开发流程等内容。同时应注重编程能力的训练，通过课堂练习、小项目、代码演示等方式提高学生的动手能力和规范答题意识。对于态度不端正的情况，建议加强课堂监督、设置阶段性测试与互动问答，激发学习积极性。', '2025-07-20 12:42:34');
INSERT INTO `student_analysis_report` VALUES (17, 1, 101, '该生对部分基础概念（如嵌入式Linux的定义）掌握较好，能够正确作答多次重复题目。但在编程题、应用题和部分选择题中表现较差，频繁出现无效答案（如数字、乱码等），显示出对嵌入式系统原理、编程实践、应用场景理解不深，存在答题敷衍、基础薄弱的问题。', '建议加强学生对嵌入式系统核心概念的理解，特别是系统架构、通信接口、编程实践等方面。在教学中增加互动环节，如随堂测试、小组练习、代码实操等，帮助学生巩固知识。同时，针对其答题不认真情况，建议进行个别辅导或设置作业提交门槛，提升学习积极性与参与度。', '2025-07-21 13:45:40');
INSERT INTO `student_analysis_report` VALUES (18, 1, 101, '该生在部分嵌入式基础知识上具备一定的理解能力，如对“嵌入式Linux”的定义回答正确，说明其对基础概念有一定认知。但整体学习情况不容乐观，存在大量重复错误，表现为随意作答（如数字“6”“8”“666”等）、答案内容与题目无关、程序题未提供有效代码、选择题理解偏差等问题，反映出学生对嵌入式系统的核心知识掌握不牢，编程能力薄弱，学习态度有待端正。', '建议教师对该生进行一对一辅导，强化基础知识讲解，尤其是嵌入式系统的基本概念、特点与应用场景。加强编程基础训练，提升C语言与嵌入式开发相关的实操能力。同时，引导学生端正学习态度，增强课堂参与度，通过阶段性小测验和任务激励其主动学习。对于易错知识点应重点讲解并布置针对性练习，帮助其逐步建立系统化的知识体系。', '2025-07-30 22:39:11');
INSERT INTO `student_analysis_report` VALUES (19, 1, 101, '该生在本题中未给出有效答案，反映出对题目要求理解不清或对相关知识点掌握不牢固，可能存在学习态度不端正或对课程内容缺乏兴趣的情况。', '建议教师针对该生进行个别沟通，了解其作答原因，引导其端正学习态度，并结合具体知识点进行补充讲解与练习，帮助其建立学习信心与兴趣。', '2025-08-10 17:06:14');
INSERT INTO `student_analysis_report` VALUES (20, 1, 101, '该生在本题中未按照题目要求作答，答案“666”与题目内容无关，反映出其对题目所涉及知识点理解薄弱，或存在学习态度不端正的问题，缺乏对课程内容的基本掌握和参与积极性。', '建议教师与该生进行沟通，了解其作答动机及学习状态，针对性加强基础知识的辅导与引导，激发其学习兴趣；同时可通过布置基础性练习任务，帮助其逐步建立学习信心与规范意识。', '2025-08-10 17:06:19');
INSERT INTO `student_analysis_report` VALUES (21, 1, 101, '该生在本题作答中未提供符合题目要求的有效答案，反映出其对题干内容理解存在较大偏差，基础知识掌握不牢固，或存在应付作答的情况，缺乏对相关知识点的基本认知和学习积极性。', '建议教师对该生进行个别辅导，深入了解其学习状态与困难，针对性强化基础知识讲解与练习，培养其规范作答意识；同时可通过引导式提问和案例教学，激发其学习兴趣与参与度，逐步提升学习效果。', '2025-08-10 17:06:25');
INSERT INTO `student_analysis_report` VALUES (22, 1, 101, '该生对当前课程内容掌握较差，存在多次无效作答、未作答或答案与题目无关的情况，反映出对知识点理解不深、学习态度不积极或存在学习困难。', '建议加强基础知识讲解与练习，引导学生建立学习兴趣与信心；针对易错知识点进行专项辅导；鼓励学生多参与课堂互动与课后练习，逐步提升理解与应用能力。', '2025-09-04 16:13:08');
INSERT INTO `student_analysis_report` VALUES (23, 1, 101, '该生对所涉及题目未能给出有效作答，多次出现“666”、“不知道”等无效答案，反映出对相关知识点掌握薄弱，甚至存在未参与实际学习的可能，学习态度或基础理解存在一定问题。', '建议从基础知识点入手，进行一对一辅导或补充讲解；引导学生明确学习目标，增强学习主动性；通过布置简单易完成的任务逐步建立学习信心；必要时与学生沟通了解具体困难，提供针对性帮助。', '2025-09-04 16:22:36');
INSERT INTO `student_analysis_report` VALUES (24, 1, 101, '该生在嵌入式开发相关知识点的理解上存在明显不足，多次未作答或给出无效答案，反映出对课程内容掌握薄弱，缺乏基本概念理解与应用能力。', '建议从基础概念入手强化学习，如嵌入式系统定义、交叉编译原理、处理器分类等；增加课后练习与互动问答，引导学生逐步建立系统性认知；鼓励参与实操练习，提升学习兴趣与主动性。', '2025-09-09 16:03:41');
INSERT INTO `student_analysis_report` VALUES (25, 1, 101, '该生在作答过程中多次提交“1111”等无意义数字串，答案与题目要求严重不符，暴露出对嵌入式系统的基本概念、应用领域及编程实现等内容缺乏基本理解，知识掌握极为薄弱，尚未建立起嵌入式系统相关知识框架。', '建议从嵌入式系统的基础概念入手，强化定义、特点及典型应用领域的讲解，采用实例引导和可视化教学手段提升学生的认知兴趣；同时加强答题规范训练，引导学生理解题意并使用专业术语作答，避免无效输入；可布置基础练习题并进行一对一辅导，逐步建立知识体系。', '2025-09-18 22:36:52');
INSERT INTO `student_analysis_report` VALUES (26, 1, 101, '该生在多次作答中均以“1111”等无意义数字作答，未展示任何与嵌入式系统定义、应用领域或编程实现相关的有效内容，反映出其对核心概念缺乏基本认知，知识掌握程度极低，存在严重的学习脱节或态度问题。', '建议首先排查学生是否存在学习动机或注意力问题，强化基础知识点的讲解与引导，采用图文结合、实物演示等方式帮助建立嵌入式系统的整体认知；同时进行一对一辅导，从简答题和选择题入手，逐步培养答题规范与思维逻辑，避免机械输入；可设置阶段性小目标，提升参与感与学习信心。', '2025-09-18 22:39:28');
INSERT INTO `student_analysis_report` VALUES (27, 1, 101, '该生在多道题目中均以“1111”等重复数字作答，答案与题目要求完全无关，暴露出其对嵌入式系统的基本概念、应用领域及编程实现毫无掌握，缺乏基本知识框架，存在严重知识空白或学习态度问题。', '建议首先与学生沟通了解其作答动机，排除应付心理或注意力缺失问题；从最基础的概念入手，通过实例讲解、多媒体辅助和动手实验增强理解；强化答题规范训练，引导其使用完整语句回答简答与编程题；安排基础补习任务，逐步建立知识点联系，提升学习参与度与有效性。', '2025-09-18 22:42:22');

-- ----------------------------
-- Table structure for student_course
-- ----------------------------
DROP TABLE IF EXISTS `student_course`;
CREATE TABLE `student_course`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL,
  `course_id` bigint NOT NULL,
  `joined_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_student_course`(`student_id` ASC, `course_id` ASC) USING BTREE,
  INDEX `fk_course`(`course_id` ASC) USING BTREE,
  CONSTRAINT `fk_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_student` FOREIGN KEY (`student_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of student_course
-- ----------------------------
INSERT INTO `student_course` VALUES (1, 1, 101, '2025-07-14 19:31:11');
INSERT INTO `student_course` VALUES (4, 1, 102, '2025-07-17 10:42:38');
INSERT INTO `student_course` VALUES (5, 9, 101, '2025-08-27 16:11:12');
INSERT INTO `student_course` VALUES (6, 3, 101, '2025-08-29 16:15:07');
INSERT INTO `student_course` VALUES (7, 10, 102, '2025-09-16 17:04:24');

-- ----------------------------
-- Table structure for student_feedback
-- ----------------------------
DROP TABLE IF EXISTS `student_feedback`;
CREATE TABLE `student_feedback`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL,
  `course_id` bigint NOT NULL,
  `question_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `answer_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `student_id`(`student_id` ASC) USING BTREE,
  INDEX `course_id`(`course_id` ASC) USING BTREE,
  CONSTRAINT `student_feedback_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `student_feedback_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of student_feedback
-- ----------------------------

-- ----------------------------
-- Table structure for student_login_log
-- ----------------------------
DROP TABLE IF EXISTS `student_login_log`;
CREATE TABLE `student_login_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL,
  `login_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_time`(`login_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 279 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of student_login_log
-- ----------------------------
INSERT INTO `student_login_log` VALUES (1, 1, '2025-08-09 08:00:00');
INSERT INTO `student_login_log` VALUES (2, 2, '2025-08-09 08:15:00');
INSERT INTO `student_login_log` VALUES (3, 3, '2025-08-09 09:30:00');
INSERT INTO `student_login_log` VALUES (4, 4, '2025-08-09 10:45:00');
INSERT INTO `student_login_log` VALUES (5, 5, '2025-08-09 11:20:00');
INSERT INTO `student_login_log` VALUES (6, 1, '2025-08-09 14:00:00');
INSERT INTO `student_login_log` VALUES (7, 2, '2025-08-09 15:30:00');
INSERT INTO `student_login_log` VALUES (8, 3, '2025-08-09 16:15:00');
INSERT INTO `student_login_log` VALUES (9, 4, '2025-08-09 19:45:00');
INSERT INTO `student_login_log` VALUES (10, 5, '2025-08-09 20:30:00');
INSERT INTO `student_login_log` VALUES (11, 1, '2025-08-08 08:30:00');
INSERT INTO `student_login_log` VALUES (12, 2, '2025-08-08 09:15:00');
INSERT INTO `student_login_log` VALUES (13, 3, '2025-08-08 14:45:00');
INSERT INTO `student_login_log` VALUES (14, 4, '2025-08-08 16:20:00');
INSERT INTO `student_login_log` VALUES (15, 1, '2025-08-07 10:00:00');
INSERT INTO `student_login_log` VALUES (16, 2, '2025-08-07 15:30:00');
INSERT INTO `student_login_log` VALUES (17, 5, '2025-08-07 19:15:00');
INSERT INTO `student_login_log` VALUES (18, 3, '2025-08-06 09:45:00');
INSERT INTO `student_login_log` VALUES (19, 4, '2025-08-06 14:20:00');
INSERT INTO `student_login_log` VALUES (20, 1, '2025-08-05 11:30:00');
INSERT INTO `student_login_log` VALUES (21, 2, '2025-08-05 16:45:00');
INSERT INTO `student_login_log` VALUES (22, 5, '2025-08-04 13:15:00');
INSERT INTO `student_login_log` VALUES (23, 3, '2025-08-03 10:30:00');
INSERT INTO `student_login_log` VALUES (24, 1, '2025-08-09 20:44:48');
INSERT INTO `student_login_log` VALUES (25, 1, '2025-08-09 22:17:51');
INSERT INTO `student_login_log` VALUES (26, 1, '2025-08-09 22:31:36');
INSERT INTO `student_login_log` VALUES (27, 1, '2025-08-10 19:27:54');
INSERT INTO `student_login_log` VALUES (28, 1, '2025-08-10 19:38:36');
INSERT INTO `student_login_log` VALUES (29, 1, '2025-08-10 20:45:12');
INSERT INTO `student_login_log` VALUES (30, 1, '2025-08-10 21:27:59');
INSERT INTO `student_login_log` VALUES (31, 1, '2025-08-10 21:29:19');
INSERT INTO `student_login_log` VALUES (32, 1, '2025-08-10 22:32:26');
INSERT INTO `student_login_log` VALUES (33, 1, '2025-08-10 22:48:16');
INSERT INTO `student_login_log` VALUES (34, 1, '2025-08-10 22:50:12');
INSERT INTO `student_login_log` VALUES (35, 1, '2025-08-10 22:52:54');
INSERT INTO `student_login_log` VALUES (36, 1, '2025-08-10 22:53:46');
INSERT INTO `student_login_log` VALUES (37, 1, '2025-08-10 23:08:15');
INSERT INTO `student_login_log` VALUES (38, 1, '2025-08-10 23:13:21');
INSERT INTO `student_login_log` VALUES (39, 1, '2025-08-10 23:14:30');
INSERT INTO `student_login_log` VALUES (40, 1, '2025-08-10 23:16:34');
INSERT INTO `student_login_log` VALUES (41, 1, '2025-08-10 23:19:24');
INSERT INTO `student_login_log` VALUES (42, 1, '2025-08-11 01:00:11');
INSERT INTO `student_login_log` VALUES (43, 1, '2025-08-12 21:35:16');
INSERT INTO `student_login_log` VALUES (44, 1, '2025-08-12 22:20:16');
INSERT INTO `student_login_log` VALUES (45, 1, '2025-08-12 22:50:55');
INSERT INTO `student_login_log` VALUES (46, 1, '2025-08-13 11:11:56');
INSERT INTO `student_login_log` VALUES (47, 3, '2025-08-13 13:09:36');
INSERT INTO `student_login_log` VALUES (48, 1, '2025-08-13 19:17:11');
INSERT INTO `student_login_log` VALUES (49, 1, '2025-08-13 19:40:31');
INSERT INTO `student_login_log` VALUES (50, 1, '2025-08-14 10:32:23');
INSERT INTO `student_login_log` VALUES (51, 1, '2025-08-18 15:14:33');
INSERT INTO `student_login_log` VALUES (52, 1, '2025-08-18 15:33:28');
INSERT INTO `student_login_log` VALUES (53, 1, '2025-08-20 20:10:54');
INSERT INTO `student_login_log` VALUES (54, 1, '2025-08-21 10:29:57');
INSERT INTO `student_login_log` VALUES (55, 1, '2025-08-21 18:03:43');
INSERT INTO `student_login_log` VALUES (56, 1, '2025-08-21 18:51:30');
INSERT INTO `student_login_log` VALUES (57, 1, '2025-08-21 19:00:47');
INSERT INTO `student_login_log` VALUES (58, 1, '2025-08-21 19:07:56');
INSERT INTO `student_login_log` VALUES (59, 1, '2025-08-21 21:03:59');
INSERT INTO `student_login_log` VALUES (60, 1, '2025-08-22 11:27:32');
INSERT INTO `student_login_log` VALUES (61, 1, '2025-08-22 12:22:49');
INSERT INTO `student_login_log` VALUES (62, 1, '2025-08-22 15:53:16');
INSERT INTO `student_login_log` VALUES (63, 1, '2025-08-22 18:43:41');
INSERT INTO `student_login_log` VALUES (64, 1, '2025-08-22 18:58:09');
INSERT INTO `student_login_log` VALUES (65, 1, '2025-08-22 18:59:42');
INSERT INTO `student_login_log` VALUES (66, 1, '2025-08-22 19:59:18');
INSERT INTO `student_login_log` VALUES (67, 1, '2025-08-22 20:03:14');
INSERT INTO `student_login_log` VALUES (68, 1, '2025-08-23 13:58:31');
INSERT INTO `student_login_log` VALUES (69, 1, '2025-08-23 16:01:41');
INSERT INTO `student_login_log` VALUES (70, 1, '2025-08-23 20:03:26');
INSERT INTO `student_login_log` VALUES (71, 1, '2025-08-23 22:59:48');
INSERT INTO `student_login_log` VALUES (72, 1, '2025-08-23 23:14:02');
INSERT INTO `student_login_log` VALUES (73, 1, '2025-08-24 19:09:05');
INSERT INTO `student_login_log` VALUES (74, 1, '2025-08-25 11:19:58');
INSERT INTO `student_login_log` VALUES (75, 1, '2025-08-26 13:53:37');
INSERT INTO `student_login_log` VALUES (76, 1, '2025-08-26 16:37:25');
INSERT INTO `student_login_log` VALUES (77, 1, '2025-08-26 16:37:32');
INSERT INTO `student_login_log` VALUES (78, 1, '2025-08-26 16:43:36');
INSERT INTO `student_login_log` VALUES (79, 1, '2025-08-26 16:46:43');
INSERT INTO `student_login_log` VALUES (80, 1, '2025-08-26 16:46:47');
INSERT INTO `student_login_log` VALUES (81, 1, '2025-08-26 16:46:47');
INSERT INTO `student_login_log` VALUES (82, 1, '2025-08-26 16:46:48');
INSERT INTO `student_login_log` VALUES (83, 1, '2025-08-26 16:46:53');
INSERT INTO `student_login_log` VALUES (84, 1, '2025-08-26 16:46:56');
INSERT INTO `student_login_log` VALUES (85, 1, '2025-08-26 16:50:27');
INSERT INTO `student_login_log` VALUES (86, 1, '2025-08-26 16:58:46');
INSERT INTO `student_login_log` VALUES (87, 1, '2025-08-26 17:06:43');
INSERT INTO `student_login_log` VALUES (88, 1, '2025-08-26 17:28:06');
INSERT INTO `student_login_log` VALUES (89, 1, '2025-08-26 17:33:34');
INSERT INTO `student_login_log` VALUES (90, 1, '2025-08-26 17:45:18');
INSERT INTO `student_login_log` VALUES (91, 1, '2025-08-26 19:34:01');
INSERT INTO `student_login_log` VALUES (92, 1, '2025-08-26 22:33:08');
INSERT INTO `student_login_log` VALUES (93, 1, '2025-08-27 10:29:52');
INSERT INTO `student_login_log` VALUES (94, 1, '2025-08-27 11:36:52');
INSERT INTO `student_login_log` VALUES (95, 9, '2025-08-27 13:51:05');
INSERT INTO `student_login_log` VALUES (96, 1, '2025-08-27 13:51:32');
INSERT INTO `student_login_log` VALUES (97, 1, '2025-08-27 14:01:25');
INSERT INTO `student_login_log` VALUES (98, 1, '2025-08-27 14:19:57');
INSERT INTO `student_login_log` VALUES (99, 1, '2025-08-27 14:26:18');
INSERT INTO `student_login_log` VALUES (100, 1, '2025-08-27 14:35:14');
INSERT INTO `student_login_log` VALUES (101, 1, '2025-08-27 14:50:07');
INSERT INTO `student_login_log` VALUES (102, 9, '2025-08-27 14:50:39');
INSERT INTO `student_login_log` VALUES (103, 1, '2025-08-27 14:51:05');
INSERT INTO `student_login_log` VALUES (104, 1, '2025-08-27 15:04:29');
INSERT INTO `student_login_log` VALUES (105, 9, '2025-08-27 15:13:22');
INSERT INTO `student_login_log` VALUES (106, 1, '2025-08-27 15:38:29');
INSERT INTO `student_login_log` VALUES (107, 9, '2025-08-27 15:56:24');
INSERT INTO `student_login_log` VALUES (108, 1, '2025-08-27 16:08:34');
INSERT INTO `student_login_log` VALUES (109, 9, '2025-08-27 16:08:48');
INSERT INTO `student_login_log` VALUES (110, 1, '2025-08-27 16:17:07');
INSERT INTO `student_login_log` VALUES (111, 1, '2025-08-27 16:21:55');
INSERT INTO `student_login_log` VALUES (112, 1, '2025-08-27 16:38:09');
INSERT INTO `student_login_log` VALUES (113, 9, '2025-08-27 16:43:23');
INSERT INTO `student_login_log` VALUES (114, 1, '2025-08-27 17:08:58');
INSERT INTO `student_login_log` VALUES (115, 9, '2025-08-27 17:14:46');
INSERT INTO `student_login_log` VALUES (116, 1, '2025-08-27 17:26:19');
INSERT INTO `student_login_log` VALUES (117, 1, '2025-08-27 20:48:27');
INSERT INTO `student_login_log` VALUES (118, 9, '2025-08-27 20:49:38');
INSERT INTO `student_login_log` VALUES (119, 1, '2025-08-27 22:13:29');
INSERT INTO `student_login_log` VALUES (120, 9, '2025-08-27 22:27:55');
INSERT INTO `student_login_log` VALUES (121, 1, '2025-08-28 11:49:25');
INSERT INTO `student_login_log` VALUES (122, 9, '2025-08-28 11:59:46');
INSERT INTO `student_login_log` VALUES (123, 1, '2025-08-28 12:27:44');
INSERT INTO `student_login_log` VALUES (124, 1, '2025-08-28 16:29:48');
INSERT INTO `student_login_log` VALUES (125, 9, '2025-08-28 22:07:33');
INSERT INTO `student_login_log` VALUES (126, 1, '2025-08-28 22:08:02');
INSERT INTO `student_login_log` VALUES (127, 1, '2025-08-28 23:57:56');
INSERT INTO `student_login_log` VALUES (128, 1, '2025-08-29 11:58:11');
INSERT INTO `student_login_log` VALUES (129, 1, '2025-08-29 12:24:29');
INSERT INTO `student_login_log` VALUES (130, 1, '2025-08-29 15:17:23');
INSERT INTO `student_login_log` VALUES (131, 1, '2025-08-29 15:22:34');
INSERT INTO `student_login_log` VALUES (132, 1, '2025-08-29 15:46:26');
INSERT INTO `student_login_log` VALUES (133, 1, '2025-08-29 16:01:20');
INSERT INTO `student_login_log` VALUES (134, 1, '2025-08-29 16:13:09');
INSERT INTO `student_login_log` VALUES (135, 3, '2025-08-29 16:14:47');
INSERT INTO `student_login_log` VALUES (136, 1, '2025-08-29 16:39:27');
INSERT INTO `student_login_log` VALUES (137, 1, '2025-08-29 17:08:10');
INSERT INTO `student_login_log` VALUES (138, 1, '2025-08-29 19:55:51');
INSERT INTO `student_login_log` VALUES (139, 1, '2025-08-30 00:17:17');
INSERT INTO `student_login_log` VALUES (140, 1, '2025-08-30 09:56:29');
INSERT INTO `student_login_log` VALUES (141, 3, '2025-08-30 09:59:02');
INSERT INTO `student_login_log` VALUES (142, 1, '2025-08-30 19:38:12');
INSERT INTO `student_login_log` VALUES (143, 9, '2025-08-30 19:48:22');
INSERT INTO `student_login_log` VALUES (144, 3, '2025-08-30 19:50:08');
INSERT INTO `student_login_log` VALUES (145, 9, '2025-08-30 20:06:05');
INSERT INTO `student_login_log` VALUES (146, 1, '2025-08-30 20:37:33');
INSERT INTO `student_login_log` VALUES (147, 1, '2025-08-30 20:39:38');
INSERT INTO `student_login_log` VALUES (148, 1, '2025-08-30 22:30:01');
INSERT INTO `student_login_log` VALUES (149, 1, '2025-08-31 15:01:27');
INSERT INTO `student_login_log` VALUES (150, 1, '2025-08-31 17:51:23');
INSERT INTO `student_login_log` VALUES (151, 1, '2025-08-31 17:54:30');
INSERT INTO `student_login_log` VALUES (152, 1, '2025-08-31 18:54:28');
INSERT INTO `student_login_log` VALUES (153, 1, '2025-08-31 21:08:27');
INSERT INTO `student_login_log` VALUES (154, 1, '2025-08-31 21:11:23');
INSERT INTO `student_login_log` VALUES (155, 1, '2025-08-31 21:25:32');
INSERT INTO `student_login_log` VALUES (156, 1, '2025-08-31 22:02:28');
INSERT INTO `student_login_log` VALUES (157, 1, '2025-09-01 13:55:29');
INSERT INTO `student_login_log` VALUES (158, 1, '2025-09-01 15:03:28');
INSERT INTO `student_login_log` VALUES (159, 1, '2025-09-01 15:21:54');
INSERT INTO `student_login_log` VALUES (160, 1, '2025-09-01 16:29:34');
INSERT INTO `student_login_log` VALUES (161, 1, '2025-09-01 18:45:57');
INSERT INTO `student_login_log` VALUES (162, 1, '2025-09-01 20:31:54');
INSERT INTO `student_login_log` VALUES (163, 1, '2025-09-01 21:51:40');
INSERT INTO `student_login_log` VALUES (164, 1, '2025-09-01 22:01:07');
INSERT INTO `student_login_log` VALUES (165, 1, '2025-09-01 22:50:00');
INSERT INTO `student_login_log` VALUES (166, 1, '2025-09-01 22:50:13');
INSERT INTO `student_login_log` VALUES (167, 1, '2025-09-01 23:24:45');
INSERT INTO `student_login_log` VALUES (168, 1, '2025-09-01 23:25:59');
INSERT INTO `student_login_log` VALUES (169, 1, '2025-09-02 09:47:01');
INSERT INTO `student_login_log` VALUES (170, 1, '2025-09-02 14:09:36');
INSERT INTO `student_login_log` VALUES (171, 1, '2025-09-02 14:31:41');
INSERT INTO `student_login_log` VALUES (172, 3, '2025-09-02 15:03:21');
INSERT INTO `student_login_log` VALUES (173, 1, '2025-09-02 16:55:00');
INSERT INTO `student_login_log` VALUES (174, 1, '2025-09-02 16:56:11');
INSERT INTO `student_login_log` VALUES (175, 3, '2025-09-02 17:53:34');
INSERT INTO `student_login_log` VALUES (176, 1, '2025-09-02 22:02:10');
INSERT INTO `student_login_log` VALUES (177, 1, '2025-09-02 22:20:33');
INSERT INTO `student_login_log` VALUES (178, 1, '2025-09-02 23:05:27');
INSERT INTO `student_login_log` VALUES (179, 1, '2025-09-03 18:54:27');
INSERT INTO `student_login_log` VALUES (180, 1, '2025-09-03 22:51:44');
INSERT INTO `student_login_log` VALUES (181, 1, '2025-09-03 23:09:13');
INSERT INTO `student_login_log` VALUES (182, 1, '2025-09-04 09:40:15');
INSERT INTO `student_login_log` VALUES (183, 1, '2025-09-04 11:36:02');
INSERT INTO `student_login_log` VALUES (184, 1, '2025-09-04 15:55:19');
INSERT INTO `student_login_log` VALUES (185, 1, '2025-09-04 23:05:05');
INSERT INTO `student_login_log` VALUES (186, 1, '2025-09-07 22:21:06');
INSERT INTO `student_login_log` VALUES (187, 1, '2025-09-08 12:03:39');
INSERT INTO `student_login_log` VALUES (188, 9, '2025-09-08 12:40:24');
INSERT INTO `student_login_log` VALUES (189, 1, '2025-09-08 12:42:25');
INSERT INTO `student_login_log` VALUES (190, 9, '2025-09-08 12:51:18');
INSERT INTO `student_login_log` VALUES (191, 1, '2025-09-05 12:56:16');
INSERT INTO `student_login_log` VALUES (192, 1, '2025-09-06 12:56:28');
INSERT INTO `student_login_log` VALUES (193, 1, '2025-09-08 13:09:38');
INSERT INTO `student_login_log` VALUES (194, 1, '2025-09-08 13:49:08');
INSERT INTO `student_login_log` VALUES (195, 1, '2025-09-08 18:48:23');
INSERT INTO `student_login_log` VALUES (196, 1, '2025-09-09 12:28:08');
INSERT INTO `student_login_log` VALUES (197, 1, '2025-09-09 14:31:40');
INSERT INTO `student_login_log` VALUES (198, 1, '2025-09-09 15:21:52');
INSERT INTO `student_login_log` VALUES (199, 1, '2025-09-09 19:02:07');
INSERT INTO `student_login_log` VALUES (200, 1, '2025-09-09 23:45:54');
INSERT INTO `student_login_log` VALUES (201, 1, '2025-09-10 01:15:39');
INSERT INTO `student_login_log` VALUES (202, 1, '2025-09-10 09:51:33');
INSERT INTO `student_login_log` VALUES (203, 1, '2025-09-10 10:51:08');
INSERT INTO `student_login_log` VALUES (204, 1, '2025-09-10 17:09:33');
INSERT INTO `student_login_log` VALUES (205, 1, '2025-09-11 08:32:46');
INSERT INTO `student_login_log` VALUES (206, 1, '2025-09-11 13:02:39');
INSERT INTO `student_login_log` VALUES (207, 1, '2025-09-12 14:10:02');
INSERT INTO `student_login_log` VALUES (208, 1, '2025-09-12 20:05:57');
INSERT INTO `student_login_log` VALUES (209, 1, '2025-09-12 22:27:10');
INSERT INTO `student_login_log` VALUES (210, 1, '2025-09-12 23:55:59');
INSERT INTO `student_login_log` VALUES (211, 1, '2025-09-13 09:39:51');
INSERT INTO `student_login_log` VALUES (212, 1, '2025-09-13 15:14:15');
INSERT INTO `student_login_log` VALUES (213, 1, '2025-09-13 15:35:48');
INSERT INTO `student_login_log` VALUES (214, 1, '2025-09-13 16:19:17');
INSERT INTO `student_login_log` VALUES (215, 1, '2025-09-14 12:31:07');
INSERT INTO `student_login_log` VALUES (216, 1, '2025-09-14 12:34:31');
INSERT INTO `student_login_log` VALUES (217, 1, '2025-09-14 14:29:25');
INSERT INTO `student_login_log` VALUES (218, 1, '2025-09-14 14:33:38');
INSERT INTO `student_login_log` VALUES (219, 1, '2025-09-14 14:38:42');
INSERT INTO `student_login_log` VALUES (220, 1, '2025-09-14 15:27:37');
INSERT INTO `student_login_log` VALUES (221, 1, '2025-09-14 18:53:16');
INSERT INTO `student_login_log` VALUES (222, 1, '2025-09-15 19:57:24');
INSERT INTO `student_login_log` VALUES (223, 1, '2025-09-16 11:01:53');
INSERT INTO `student_login_log` VALUES (224, 1, '2025-09-16 15:42:11');
INSERT INTO `student_login_log` VALUES (225, 1, '2025-09-16 15:48:26');
INSERT INTO `student_login_log` VALUES (226, 1, '2025-09-16 15:48:56');
INSERT INTO `student_login_log` VALUES (227, 3, '2025-09-16 15:50:09');
INSERT INTO `student_login_log` VALUES (228, 1, '2025-09-16 16:36:12');
INSERT INTO `student_login_log` VALUES (229, 10, '2025-09-16 16:37:47');
INSERT INTO `student_login_log` VALUES (230, 10, '2025-09-16 16:37:58');
INSERT INTO `student_login_log` VALUES (231, 10, '2025-09-16 16:38:26');
INSERT INTO `student_login_log` VALUES (232, 10, '2025-09-16 16:39:01');
INSERT INTO `student_login_log` VALUES (233, 10, '2025-09-16 16:39:20');
INSERT INTO `student_login_log` VALUES (234, 10, '2025-09-16 16:41:02');
INSERT INTO `student_login_log` VALUES (235, 10, '2025-09-16 16:42:57');
INSERT INTO `student_login_log` VALUES (236, 10, '2025-09-16 16:44:17');
INSERT INTO `student_login_log` VALUES (237, 10, '2025-09-16 16:44:33');
INSERT INTO `student_login_log` VALUES (238, 10, '2025-09-16 16:46:26');
INSERT INTO `student_login_log` VALUES (239, 1, '2025-09-16 16:46:48');
INSERT INTO `student_login_log` VALUES (240, 10, '2025-09-16 16:47:42');
INSERT INTO `student_login_log` VALUES (241, 10, '2025-09-16 16:49:28');
INSERT INTO `student_login_log` VALUES (242, 10, '2025-09-16 16:50:02');
INSERT INTO `student_login_log` VALUES (243, 10, '2025-09-16 16:50:28');
INSERT INTO `student_login_log` VALUES (244, 10, '2025-09-16 16:52:34');
INSERT INTO `student_login_log` VALUES (245, 9, '2025-09-16 16:53:07');
INSERT INTO `student_login_log` VALUES (246, 10, '2025-09-16 16:54:49');
INSERT INTO `student_login_log` VALUES (247, 10, '2025-09-16 16:56:42');
INSERT INTO `student_login_log` VALUES (248, 10, '2025-09-16 16:57:15');
INSERT INTO `student_login_log` VALUES (249, 10, '2025-09-16 16:57:44');
INSERT INTO `student_login_log` VALUES (250, 10, '2025-09-16 17:00:56');
INSERT INTO `student_login_log` VALUES (251, 10, '2025-09-16 17:01:22');
INSERT INTO `student_login_log` VALUES (252, 10, '2025-09-16 17:02:27');
INSERT INTO `student_login_log` VALUES (253, 10, '2025-09-16 17:02:57');
INSERT INTO `student_login_log` VALUES (254, 11, '2025-09-16 17:09:13');
INSERT INTO `student_login_log` VALUES (255, 1, '2025-09-16 17:10:41');
INSERT INTO `student_login_log` VALUES (256, 1, '2025-09-16 17:36:17');
INSERT INTO `student_login_log` VALUES (257, 1, '2025-09-16 21:16:48');
INSERT INTO `student_login_log` VALUES (258, 1, '2025-09-16 22:17:38');
INSERT INTO `student_login_log` VALUES (259, 1, '2025-09-17 11:19:11');
INSERT INTO `student_login_log` VALUES (260, 1, '2025-09-17 13:21:28');
INSERT INTO `student_login_log` VALUES (261, 1, '2025-09-17 13:31:49');
INSERT INTO `student_login_log` VALUES (262, 1, '2025-09-17 14:36:33');
INSERT INTO `student_login_log` VALUES (263, 1, '2025-09-17 14:46:28');
INSERT INTO `student_login_log` VALUES (264, 1, '2025-09-17 18:54:54');
INSERT INTO `student_login_log` VALUES (265, 1, '2025-09-17 21:12:25');
INSERT INTO `student_login_log` VALUES (266, 1, '2025-09-18 09:54:01');
INSERT INTO `student_login_log` VALUES (267, 1, '2025-09-18 10:22:08');
INSERT INTO `student_login_log` VALUES (268, 1, '2025-09-18 11:49:53');
INSERT INTO `student_login_log` VALUES (269, 1, '2025-09-18 13:15:41');
INSERT INTO `student_login_log` VALUES (270, 1, '2025-09-18 13:33:06');
INSERT INTO `student_login_log` VALUES (271, 1, '2025-09-18 16:00:52');
INSERT INTO `student_login_log` VALUES (272, 1, '2025-09-18 20:47:46');
INSERT INTO `student_login_log` VALUES (273, 1, '2025-09-18 22:12:31');
INSERT INTO `student_login_log` VALUES (274, 1, '2025-09-18 22:35:43');
INSERT INTO `student_login_log` VALUES (275, 1, '2025-09-18 23:36:26');
INSERT INTO `student_login_log` VALUES (276, 1, '2025-09-19 19:19:52');
INSERT INTO `student_login_log` VALUES (277, 1, '2025-09-19 19:59:06');
INSERT INTO `student_login_log` VALUES (278, 1, '2025-09-19 21:57:10');
INSERT INTO `student_login_log` VALUES (279, 1, '2025-09-19 22:14:11');
INSERT INTO `student_login_log` VALUES (280, 1, '2025-09-24 23:25:03');
INSERT INTO `student_login_log` VALUES (281, 1, '2025-09-24 23:28:27');

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `config_id` int NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '参数配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', '2025-07-15 16:08:15', '', NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO `sys_config` VALUES (2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'admin', '2025-07-15 16:08:15', '', NULL, '初始化密码 123456');
INSERT INTO `sys_config` VALUES (3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', '2025-07-15 16:08:15', '', NULL, '深色主题theme-dark，浅色主题theme-light');
INSERT INTO `sys_config` VALUES (4, '账号自助-验证码开关', 'sys.account.captchaEnabled', 'true', 'Y', 'admin', '2025-07-15 16:08:15', '', NULL, '是否开启验证码功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (5, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', 'admin', '2025-07-15 16:08:15', '', NULL, '是否开启注册用户功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (6, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', 'admin', '2025-07-15 16:08:15', '', NULL, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');
INSERT INTO `sys_config` VALUES (7, '用户管理-初始密码修改策略', 'sys.account.initPasswordModify', '1', 'Y', 'admin', '2025-07-15 16:08:15', '', NULL, '0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框');
INSERT INTO `sys_config` VALUES (8, '用户管理-账号密码更新周期', 'sys.account.passwordValidateDays', '0', 'Y', 'admin', '2025-07-15 16:08:15', '', NULL, '密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框');

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `dept_id` bigint NOT NULL AUTO_INCREMENT COMMENT '部门id',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父部门id',
  `ancestors` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门名称',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `leader` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 109 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '部门表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES (100, 0, '0', '若依科技', 0, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-07-15 16:08:15', '', NULL);
INSERT INTO `sys_dept` VALUES (101, 100, '0,100', '深圳总公司', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-07-15 16:08:15', '', NULL);
INSERT INTO `sys_dept` VALUES (102, 100, '0,100', '长沙分公司', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-07-15 16:08:15', '', NULL);
INSERT INTO `sys_dept` VALUES (103, 101, '0,100,101', '研发部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-07-15 16:08:15', '', NULL);
INSERT INTO `sys_dept` VALUES (104, 101, '0,100,101', '市场部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-07-15 16:08:15', '', NULL);
INSERT INTO `sys_dept` VALUES (105, 101, '0,100,101', '测试部门', 3, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-07-15 16:08:15', '', NULL);
INSERT INTO `sys_dept` VALUES (106, 101, '0,100,101', '财务部门', 4, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-07-15 16:08:15', '', NULL);
INSERT INTO `sys_dept` VALUES (107, 101, '0,100,101', '运维部门', 5, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-07-15 16:08:15', '', NULL);
INSERT INTO `sys_dept` VALUES (108, 102, '0,100,102', '市场部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-07-15 16:08:15', '', NULL);
INSERT INTO `sys_dept` VALUES (109, 102, '0,100,102', '财务部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-07-15 16:08:15', '', NULL);

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `dict_code` bigint NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int NULL DEFAULT 0 COMMENT '字典排序',
  `dict_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 102 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典数据表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES (1, 1, '男', '0', 'sys_user_sex', '', '', 'Y', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '性别男');
INSERT INTO `sys_dict_data` VALUES (2, 2, '女', '1', 'sys_user_sex', '', '', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '性别女');
INSERT INTO `sys_dict_data` VALUES (3, 3, '未知', '2', 'sys_user_sex', '', '', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '性别未知');
INSERT INTO `sys_dict_data` VALUES (4, 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '显示菜单');
INSERT INTO `sys_dict_data` VALUES (5, 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '隐藏菜单');
INSERT INTO `sys_dict_data` VALUES (6, 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (7, 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (8, 1, '正常', '0', 'sys_job_status', '', 'primary', 'Y', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (9, 2, '暂停', '1', 'sys_job_status', '', 'danger', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (10, 1, '默认', 'DEFAULT', 'sys_job_group', '', '', 'Y', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '默认分组');
INSERT INTO `sys_dict_data` VALUES (11, 2, '系统', 'SYSTEM', 'sys_job_group', '', '', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '系统分组');
INSERT INTO `sys_dict_data` VALUES (12, 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '系统默认是');
INSERT INTO `sys_dict_data` VALUES (13, 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '系统默认否');
INSERT INTO `sys_dict_data` VALUES (14, 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '通知');
INSERT INTO `sys_dict_data` VALUES (15, 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '公告');
INSERT INTO `sys_dict_data` VALUES (16, 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (17, 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '关闭状态');
INSERT INTO `sys_dict_data` VALUES (18, 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '其他操作');
INSERT INTO `sys_dict_data` VALUES (19, 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '新增操作');
INSERT INTO `sys_dict_data` VALUES (20, 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '修改操作');
INSERT INTO `sys_dict_data` VALUES (21, 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '删除操作');
INSERT INTO `sys_dict_data` VALUES (22, 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '授权操作');
INSERT INTO `sys_dict_data` VALUES (23, 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '导出操作');
INSERT INTO `sys_dict_data` VALUES (24, 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '导入操作');
INSERT INTO `sys_dict_data` VALUES (25, 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '强退操作');
INSERT INTO `sys_dict_data` VALUES (26, 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '生成操作');
INSERT INTO `sys_dict_data` VALUES (27, 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '清空操作');
INSERT INTO `sys_dict_data` VALUES (28, 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (29, 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (100, 0, '选择题', 'choice', 'quertion_type', NULL, 'default', 'N', '0', 'admin', '2025-07-16 13:52:40', 'admin', '2025-07-16 15:11:52', NULL);
INSERT INTO `sys_dict_data` VALUES (101, 2, '简答题', 'short_answer', 'quertion_type', NULL, 'default', 'N', '0', 'admin', '2025-07-16 13:53:14', 'admin', '2025-07-16 15:12:00', NULL);
INSERT INTO `sys_dict_data` VALUES (102, 3, '编程题', 'programming', 'quertion_type', NULL, 'default', 'N', '0', 'admin', '2025-07-16 13:53:34', 'admin', '2025-07-16 15:12:09', NULL);

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `dict_id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `dict_type`(`dict_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (1, '用户性别', 'sys_user_sex', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '用户性别列表');
INSERT INTO `sys_dict_type` VALUES (2, '菜单状态', 'sys_show_hide', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '菜单状态列表');
INSERT INTO `sys_dict_type` VALUES (3, '系统开关', 'sys_normal_disable', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '系统开关列表');
INSERT INTO `sys_dict_type` VALUES (4, '任务状态', 'sys_job_status', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '任务状态列表');
INSERT INTO `sys_dict_type` VALUES (5, '任务分组', 'sys_job_group', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '任务分组列表');
INSERT INTO `sys_dict_type` VALUES (6, '系统是否', 'sys_yes_no', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '系统是否列表');
INSERT INTO `sys_dict_type` VALUES (7, '通知类型', 'sys_notice_type', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '通知类型列表');
INSERT INTO `sys_dict_type` VALUES (8, '通知状态', 'sys_notice_status', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '通知状态列表');
INSERT INTO `sys_dict_type` VALUES (9, '操作类型', 'sys_oper_type', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '操作类型列表');
INSERT INTO `sys_dict_type` VALUES (10, '系统状态', 'sys_common_status', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '登录状态列表');
INSERT INTO `sys_dict_type` VALUES (100, '题目类型', 'quertion_type', '0', 'admin', '2025-07-16 13:51:57', '', NULL, NULL);

-- ----------------------------
-- Table structure for sys_job
-- ----------------------------
DROP TABLE IF EXISTS `sys_job`;
CREATE TABLE `sys_job`  (
  `job_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'DEFAULT' COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调用目标字符串',
  `cron_expression` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'cron执行表达式',
  `misfire_policy` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '3' COMMENT '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
  `concurrent` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '是否并发执行（0允许 1禁止）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1暂停）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注信息',
  PRIMARY KEY (`job_id`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时任务调度表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job
-- ----------------------------
INSERT INTO `sys_job` VALUES (1, '系统默认（无参）', 'DEFAULT', 'ryTask.ryNoParams', '0/10 * * * * ?', '3', '1', '1', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_job` VALUES (2, '系统默认（有参）', 'DEFAULT', 'ryTask.ryParams(\'ry\')', '0/15 * * * * ?', '3', '1', '1', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_job` VALUES (3, '系统默认（多参）', 'DEFAULT', 'ryTask.ryMultipleParams(\'ry\', true, 2000L, 316.50D, 100)', '0/20 * * * * ?', '3', '1', '1', 'admin', '2025-07-15 16:08:15', '', NULL, '');

-- ----------------------------
-- Table structure for sys_job_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_job_log`;
CREATE TABLE `sys_job_log`  (
  `job_log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务日志ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调用目标字符串',
  `job_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '日志信息',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '执行状态（0正常 1失败）',
  `exception_info` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '异常信息',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`job_log_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时任务调度日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS `sys_logininfor`;
CREATE TABLE `sys_logininfor`  (
  `info_id` bigint NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户账号',
  `ipaddr` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作系统',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '提示消息',
  `login_time` datetime NULL DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`) USING BTREE,
  INDEX `idx_sys_logininfor_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_logininfor_lt`(`login_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 167 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统访问记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_logininfor
-- ----------------------------
INSERT INTO `sys_logininfor` VALUES (100, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '1', '验证码已失效', '2025-07-15 16:30:15');
INSERT INTO `sys_logininfor` VALUES (101, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-15 16:30:18');
INSERT INTO `sys_logininfor` VALUES (102, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-15 17:32:49');
INSERT INTO `sys_logininfor` VALUES (103, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-15 19:58:07');
INSERT INTO `sys_logininfor` VALUES (104, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-15 21:54:57');
INSERT INTO `sys_logininfor` VALUES (105, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 11:43:53');
INSERT INTO `sys_logininfor` VALUES (106, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 12:46:40');
INSERT INTO `sys_logininfor` VALUES (107, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '退出成功', '2025-07-16 12:49:40');
INSERT INTO `sys_logininfor` VALUES (108, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 12:49:51');
INSERT INTO `sys_logininfor` VALUES (109, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '退出成功', '2025-07-16 12:51:10');
INSERT INTO `sys_logininfor` VALUES (110, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 12:51:30');
INSERT INTO `sys_logininfor` VALUES (111, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '退出成功', '2025-07-16 12:52:30');
INSERT INTO `sys_logininfor` VALUES (112, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 12:52:37');
INSERT INTO `sys_logininfor` VALUES (113, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '退出成功', '2025-07-16 12:53:12');
INSERT INTO `sys_logininfor` VALUES (114, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 12:53:18');
INSERT INTO `sys_logininfor` VALUES (115, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 13:24:43');
INSERT INTO `sys_logininfor` VALUES (116, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 13:26:36');
INSERT INTO `sys_logininfor` VALUES (117, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 14:41:30');
INSERT INTO `sys_logininfor` VALUES (118, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 14:51:44');
INSERT INTO `sys_logininfor` VALUES (119, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 15:02:10');
INSERT INTO `sys_logininfor` VALUES (120, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '退出成功', '2025-07-16 16:06:10');
INSERT INTO `sys_logininfor` VALUES (121, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 16:06:16');
INSERT INTO `sys_logininfor` VALUES (122, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 16:07:40');
INSERT INTO `sys_logininfor` VALUES (123, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '退出成功', '2025-07-16 16:15:38');
INSERT INTO `sys_logininfor` VALUES (124, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 16:16:18');
INSERT INTO `sys_logininfor` VALUES (125, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 16:18:55');
INSERT INTO `sys_logininfor` VALUES (126, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '退出成功', '2025-07-16 16:25:22');
INSERT INTO `sys_logininfor` VALUES (127, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 16:25:32');
INSERT INTO `sys_logininfor` VALUES (128, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '退出成功', '2025-07-16 16:26:29');
INSERT INTO `sys_logininfor` VALUES (129, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 16:26:33');
INSERT INTO `sys_logininfor` VALUES (130, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '退出成功', '2025-07-16 16:26:55');
INSERT INTO `sys_logininfor` VALUES (131, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-16 16:27:01');
INSERT INTO `sys_logininfor` VALUES (132, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-20 16:01:03');
INSERT INTO `sys_logininfor` VALUES (133, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '退出成功', '2025-07-20 16:01:09');
INSERT INTO `sys_logininfor` VALUES (134, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-20 16:01:16');
INSERT INTO `sys_logininfor` VALUES (135, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-20 16:19:48');
INSERT INTO `sys_logininfor` VALUES (136, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '退出成功', '2025-07-20 16:23:38');
INSERT INTO `sys_logininfor` VALUES (137, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-20 16:25:05');
INSERT INTO `sys_logininfor` VALUES (138, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '退出成功', '2025-07-20 16:27:40');
INSERT INTO `sys_logininfor` VALUES (139, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-20 16:28:15');
INSERT INTO `sys_logininfor` VALUES (140, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-20 16:29:48');
INSERT INTO `sys_logininfor` VALUES (141, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-20 16:30:16');
INSERT INTO `sys_logininfor` VALUES (142, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-20 16:31:25');
INSERT INTO `sys_logininfor` VALUES (143, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '1', '验证码错误', '2025-07-20 16:34:14');
INSERT INTO `sys_logininfor` VALUES (144, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-20 16:34:36');
INSERT INTO `sys_logininfor` VALUES (145, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-21 15:03:21');
INSERT INTO `sys_logininfor` VALUES (146, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '退出成功', '2025-07-21 15:03:26');
INSERT INTO `sys_logininfor` VALUES (147, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-07-21 15:03:51');
INSERT INTO `sys_logininfor` VALUES (148, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-08-09 15:55:39');
INSERT INTO `sys_logininfor` VALUES (149, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-08-09 16:35:16');
INSERT INTO `sys_logininfor` VALUES (150, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-08-09 16:49:39');
INSERT INTO `sys_logininfor` VALUES (151, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '1', '验证码错误', '2025-08-09 19:54:47');
INSERT INTO `sys_logininfor` VALUES (152, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-08-09 19:54:54');
INSERT INTO `sys_logininfor` VALUES (153, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '1', '验证码错误', '2025-08-09 22:56:29');
INSERT INTO `sys_logininfor` VALUES (154, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '1', '验证码错误', '2025-08-09 22:56:29');
INSERT INTO `sys_logininfor` VALUES (155, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-08-09 22:56:34');
INSERT INTO `sys_logininfor` VALUES (156, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '1', '验证码错误', '2025-08-09 23:05:09');
INSERT INTO `sys_logininfor` VALUES (157, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-08-09 23:05:17');
INSERT INTO `sys_logininfor` VALUES (158, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-08-10 00:07:51');
INSERT INTO `sys_logininfor` VALUES (159, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-08-10 09:55:13');
INSERT INTO `sys_logininfor` VALUES (160, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '1', '验证码错误', '2025-08-10 21:43:10');
INSERT INTO `sys_logininfor` VALUES (161, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-08-10 21:43:18');
INSERT INTO `sys_logininfor` VALUES (162, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '退出成功', '2025-08-10 22:24:41');
INSERT INTO `sys_logininfor` VALUES (163, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '1', '验证码错误', '2025-08-10 22:24:50');
INSERT INTO `sys_logininfor` VALUES (164, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-08-10 22:24:53');
INSERT INTO `sys_logininfor` VALUES (165, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-08-10 23:47:52');
INSERT INTO `sys_logininfor` VALUES (166, 'admin', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '退出成功', '2025-08-10 23:48:04');
INSERT INTO `sys_logininfor` VALUES (167, 'ry', '127.0.0.1', '内网IP', 'Chrome 13', 'Windows 10', '0', '登录成功', '2025-08-10 23:48:30');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜单名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父菜单ID',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路由参数',
  `route_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '路由名称',
  `is_frame` int NULL DEFAULT 1 COMMENT '是否为外链（0是 1否）',
  `is_cache` int NULL DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2032 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '系统管理', 0, 1, 'system', NULL, '', '', 1, 0, 'M', '0', '0', '', 'system', 'admin', '2025-07-15 16:08:15', '', NULL, '系统管理目录');
INSERT INTO `sys_menu` VALUES (2, '系统监控', 0, 2, 'monitor', NULL, '', '', 1, 0, 'M', '0', '0', '', 'monitor', 'admin', '2025-07-15 16:08:15', '', NULL, '系统监控目录');
INSERT INTO `sys_menu` VALUES (3, '系统工具', 0, 3, 'tool', NULL, '', '', 1, 0, 'M', '0', '0', '', 'tool', 'admin', '2025-07-15 16:08:15', '', NULL, '系统工具目录');
INSERT INTO `sys_menu` VALUES (4, '若依官网', 0, 4, 'http://ruoyi.vip', NULL, '', '', 0, 0, 'M', '0', '0', '', 'guide', 'admin', '2025-07-15 16:08:15', '', NULL, '若依官网地址');
INSERT INTO `sys_menu` VALUES (100, '用户管理', 1, 1, 'user', 'system/user/index', '', '', 1, 0, 'C', '0', '0', 'system:user:list', 'user', 'admin', '2025-07-15 16:08:15', '', NULL, '用户管理菜单');
INSERT INTO `sys_menu` VALUES (101, '角色管理', 1, 2, 'role', 'system/role/index', '', '', 1, 0, 'C', '0', '0', 'system:role:list', 'peoples', 'admin', '2025-07-15 16:08:15', '', NULL, '角色管理菜单');
INSERT INTO `sys_menu` VALUES (102, '菜单管理', 1, 3, 'menu', 'system/menu/index', '', '', 1, 0, 'C', '0', '0', 'system:menu:list', 'tree-table', 'admin', '2025-07-15 16:08:15', '', NULL, '菜单管理菜单');
INSERT INTO `sys_menu` VALUES (103, '部门管理', 1, 4, 'dept', 'system/dept/index', '', '', 1, 0, 'C', '0', '0', 'system:dept:list', 'tree', 'admin', '2025-07-15 16:08:15', '', NULL, '部门管理菜单');
INSERT INTO `sys_menu` VALUES (104, '岗位管理', 1, 5, 'post', 'system/post/index', '', '', 1, 0, 'C', '0', '0', 'system:post:list', 'post', 'admin', '2025-07-15 16:08:15', '', NULL, '岗位管理菜单');
INSERT INTO `sys_menu` VALUES (105, '字典管理', 1, 6, 'dict', 'system/dict/index', '', '', 1, 0, 'C', '0', '0', 'system:dict:list', 'dict', 'admin', '2025-07-15 16:08:15', '', NULL, '字典管理菜单');
INSERT INTO `sys_menu` VALUES (106, '参数设置', 1, 7, 'config', 'system/config/index', '', '', 1, 0, 'C', '0', '0', 'system:config:list', 'edit', 'admin', '2025-07-15 16:08:15', '', NULL, '参数设置菜单');
INSERT INTO `sys_menu` VALUES (107, '通知公告', 1, 8, 'notice', 'system/notice/index', '', '', 1, 0, 'C', '0', '0', 'system:notice:list', 'message', 'admin', '2025-07-15 16:08:15', '', NULL, '通知公告菜单');
INSERT INTO `sys_menu` VALUES (108, '日志管理', 1, 9, 'log', '', '', '', 1, 0, 'M', '0', '0', '', 'log', 'admin', '2025-07-15 16:08:15', '', NULL, '日志管理菜单');
INSERT INTO `sys_menu` VALUES (109, '在线用户', 2, 1, 'online', 'monitor/online/index', '', '', 1, 0, 'C', '0', '0', 'monitor:online:list', 'online', 'admin', '2025-07-15 16:08:15', '', NULL, '在线用户菜单');
INSERT INTO `sys_menu` VALUES (110, '定时任务', 2, 2, 'job', 'monitor/job/index', '', '', 1, 0, 'C', '0', '0', 'monitor:job:list', 'job', 'admin', '2025-07-15 16:08:15', '', NULL, '定时任务菜单');
INSERT INTO `sys_menu` VALUES (111, '数据监控', 2, 3, 'druid', 'monitor/druid/index', '', '', 1, 0, 'C', '0', '0', 'monitor:druid:list', 'druid', 'admin', '2025-07-15 16:08:15', '', NULL, '数据监控菜单');
INSERT INTO `sys_menu` VALUES (112, '服务监控', 2, 4, 'server', 'monitor/server/index', '', '', 1, 0, 'C', '0', '0', 'monitor:server:list', 'server', 'admin', '2025-07-15 16:08:15', '', NULL, '服务监控菜单');
INSERT INTO `sys_menu` VALUES (113, '缓存监控', 2, 5, 'cache', 'monitor/cache/index', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis', 'admin', '2025-07-15 16:08:15', '', NULL, '缓存监控菜单');
INSERT INTO `sys_menu` VALUES (114, '缓存列表', 2, 6, 'cacheList', 'monitor/cache/list', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis-list', 'admin', '2025-07-15 16:08:15', '', NULL, '缓存列表菜单');
INSERT INTO `sys_menu` VALUES (115, '表单构建', 3, 1, 'build', 'tool/build/index', '', '', 1, 0, 'C', '0', '0', 'tool:build:list', 'build', 'admin', '2025-07-15 16:08:15', '', NULL, '表单构建菜单');
INSERT INTO `sys_menu` VALUES (116, '代码生成', 3, 2, 'gen', 'tool/gen/index', '', '', 1, 0, 'C', '0', '0', 'tool:gen:list', 'code', 'admin', '2025-07-15 16:08:15', '', NULL, '代码生成菜单');
INSERT INTO `sys_menu` VALUES (117, '系统接口', 3, 3, 'swagger', 'tool/swagger/index', '', '', 1, 0, 'C', '0', '0', 'tool:swagger:list', 'swagger', 'admin', '2025-07-15 16:08:15', '', NULL, '系统接口菜单');
INSERT INTO `sys_menu` VALUES (500, '操作日志', 108, 1, 'operlog', 'monitor/operlog/index', '', '', 1, 0, 'C', '0', '0', 'monitor:operlog:list', 'form', 'admin', '2025-07-15 16:08:15', '', NULL, '操作日志菜单');
INSERT INTO `sys_menu` VALUES (501, '登录日志', 108, 2, 'logininfor', 'monitor/logininfor/index', '', '', 1, 0, 'C', '0', '0', 'monitor:logininfor:list', 'logininfor', 'admin', '2025-07-15 16:08:15', '', NULL, '登录日志菜单');
INSERT INTO `sys_menu` VALUES (1000, '用户查询', 100, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1001, '用户新增', 100, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1002, '用户修改', 100, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1003, '用户删除', 100, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1004, '用户导出', 100, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:export', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1005, '用户导入', 100, 6, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:import', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1006, '重置密码', 100, 7, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1007, '角色查询', 101, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:query', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1008, '角色新增', 101, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:add', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1009, '角色修改', 101, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1010, '角色删除', 101, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1011, '角色导出', 101, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:export', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1012, '菜单查询', 102, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1013, '菜单新增', 102, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1014, '菜单修改', 102, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1015, '菜单删除', 102, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1016, '部门查询', 103, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1017, '部门新增', 103, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1018, '部门修改', 103, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1019, '部门删除', 103, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1020, '岗位查询', 104, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:query', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1021, '岗位新增', 104, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:add', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1022, '岗位修改', 104, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1023, '岗位删除', 104, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1024, '岗位导出', 104, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:export', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1025, '字典查询', 105, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:query', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1026, '字典新增', 105, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:add', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1027, '字典修改', 105, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1028, '字典删除', 105, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1029, '字典导出', 105, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:export', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1030, '参数查询', 106, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:query', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1031, '参数新增', 106, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:add', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1032, '参数修改', 106, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:edit', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1033, '参数删除', 106, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:remove', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1034, '参数导出', 106, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:export', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1035, '公告查询', 107, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:query', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1036, '公告新增', 107, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:add', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1037, '公告修改', 107, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1038, '公告删除', 107, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1039, '操作查询', 500, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:query', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1040, '操作删除', 500, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:remove', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1041, '日志导出', 500, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:export', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1042, '登录查询', 501, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:query', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1043, '登录删除', 501, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:remove', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1044, '日志导出', 501, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:export', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1045, '账户解锁', 501, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:unlock', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1046, '在线查询', 109, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1047, '批量强退', 109, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1048, '单条强退', 109, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1049, '任务查询', 110, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:query', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1050, '任务新增', 110, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:add', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1051, '任务修改', 110, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:edit', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1052, '任务删除', 110, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:remove', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1053, '状态修改', 110, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:changeStatus', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1054, '任务导出', 110, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:export', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1055, '生成查询', 116, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1056, '生成修改', 116, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1057, '生成删除', 116, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1058, '导入代码', 116, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1059, '预览代码', 116, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1060, '生成代码', 116, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code', '#', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2000, '人员管理', 2006, 1, 'user', 'user/user/index', NULL, '', 1, 0, 'C', '0', '0', 'user:user:list', '#', 'admin', '2025-07-15 17:39:26', 'admin', '2025-07-15 17:43:49', '人员管理菜单');
INSERT INTO `sys_menu` VALUES (2001, '人员管理查询', 2000, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'user:user:query', '#', 'admin', '2025-07-15 17:39:26', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2002, '人员管理新增', 2000, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'user:user:add', '#', 'admin', '2025-07-15 17:39:26', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2003, '人员管理修改', 2000, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'user:user:edit', '#', 'admin', '2025-07-15 17:39:26', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2004, '人员管理删除', 2000, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'user:user:remove', '#', 'admin', '2025-07-15 17:39:26', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2005, '人员管理导出', 2000, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'user:user:export', '#', 'admin', '2025-07-15 17:39:26', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2006, '人员管理', 0, 2, '/people', NULL, NULL, '', 1, 0, 'M', '0', '0', NULL, 'people', 'admin', '2025-07-15 17:43:24', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2007, '课件资源管理', 0, 2, '/resource', NULL, NULL, '', 1, 0, 'M', '0', '0', '', 'international', 'admin', '2025-07-15 18:13:44', 'admin', '2025-07-15 18:16:52', '');
INSERT INTO `sys_menu` VALUES (2008, '课件管理', 2007, 1, 'file', 'file/file/index', NULL, '', 1, 0, 'C', '0', '0', 'file:file:list', '#', 'admin', '2025-07-15 20:07:17', '', NULL, '课件管理菜单');
INSERT INTO `sys_menu` VALUES (2009, '课件管理查询', 2008, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'file:file:query', '#', 'admin', '2025-07-15 20:07:17', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2010, '课件管理新增', 2008, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'file:file:add', '#', 'admin', '2025-07-15 20:07:17', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2011, '课件管理修改', 2008, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'file:file:edit', '#', 'admin', '2025-07-15 20:07:17', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2012, '课件管理删除', 2008, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'file:file:remove', '#', 'admin', '2025-07-15 20:07:17', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2013, '课件管理导出', 2008, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'file:file:export', '#', 'admin', '2025-07-15 20:07:17', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2014, '作业管理', 2007, 1, 'assignment', 'assignment/assignment/index', NULL, '', 1, 0, 'C', '0', '0', 'assignment:assignment:list', '#', 'admin', '2025-07-15 21:20:40', 'admin', '2025-07-16 14:05:17', '作业练习管理菜单');
INSERT INTO `sys_menu` VALUES (2015, '作业练习管理查询', 2014, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'assignment:assignment:query', '#', 'admin', '2025-07-15 21:20:40', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2016, '作业练习管理新增', 2014, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'assignment:assignment:add', '#', 'admin', '2025-07-15 21:20:40', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2017, '作业练习管理修改', 2014, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'assignment:assignment:edit', '#', 'admin', '2025-07-15 21:20:40', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2018, '作业练习管理删除', 2014, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'assignment:assignment:remove', '#', 'admin', '2025-07-15 21:20:40', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2019, '作业练习管理导出', 2014, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'assignment:assignment:export', '#', 'admin', '2025-07-15 21:20:40', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2020, '智教大屏', 0, 2, '/daping', NULL, NULL, '', 1, 0, 'M', '0', '0', '', 'education', 'admin', '2025-07-15 21:55:57', 'admin', '2025-07-15 21:57:09', '');
INSERT INTO `sys_menu` VALUES (2021, '智教大屏', 2020, 1, 'daping', 'daping/daping/index', NULL, '', 1, 0, 'C', '0', '0', 'daping:daping:list', '#', 'admin', '2025-07-15 22:07:30', '', NULL, '智教大屏菜单');
INSERT INTO `sys_menu` VALUES (2022, '智教大屏查询', 2021, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'daping:daping:query', '#', 'admin', '2025-07-15 22:07:30', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2023, '智教大屏新增', 2021, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'daping:daping:add', '#', 'admin', '2025-07-15 22:07:30', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2024, '智教大屏修改', 2021, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'daping:daping:edit', '#', 'admin', '2025-07-15 22:07:30', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2025, '智教大屏删除', 2021, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'daping:daping:remove', '#', 'admin', '2025-07-15 22:07:30', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2026, '智教大屏导出', 2021, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'daping:daping:export', '#', 'admin', '2025-07-15 22:07:30', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2027, '题目管理', 2007, 1, 'bank', 'bank/bank/index', NULL, '', 1, 0, 'C', '0', '0', 'bank:bank:list', '#', 'admin', '2025-07-16 14:04:31', 'admin', '2025-08-09 17:48:39', '练习管理菜单');
INSERT INTO `sys_menu` VALUES (2028, '练习管理查询', 2027, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'bank:bank:query', '#', 'admin', '2025-07-16 14:04:31', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2029, '练习管理新增', 2027, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'bank:bank:add', '#', 'admin', '2025-07-16 14:04:31', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2030, '练习管理修改', 2027, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'bank:bank:edit', '#', 'admin', '2025-07-16 14:04:31', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2031, '练习管理删除', 2027, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'bank:bank:remove', '#', 'admin', '2025-07-16 14:04:31', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2032, '练习管理导出', 2027, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'bank:bank:export', '#', 'admin', '2025-07-16 14:04:31', '', NULL, '');

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice`  (
  `notice_id` int NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `notice_title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告标题',
  `notice_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告类型（1通知 2公告）',
  `notice_content` longblob NULL COMMENT '公告内容',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通知公告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_notice
-- ----------------------------
INSERT INTO `sys_notice` VALUES (1, '温馨提醒：2018-07-01 若依新版本发布啦', '2', 0xE696B0E78988E69CACE58685E5AEB9, '0', 'admin', '2025-07-15 16:08:15', '', NULL, '管理员');
INSERT INTO `sys_notice` VALUES (2, '维护通知：2018-07-01 若依系统凌晨维护', '1', 0xE7BBB4E68AA4E58685E5AEB9, '0', 'admin', '2025-07-15 16:08:15', '', NULL, '管理员');

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log`  (
  `oper_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '模块标题',
  `business_type` int NULL DEFAULT 0 COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求方式',
  `operator_type` int NULL DEFAULT 0 COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '返回参数',
  `status` int NULL DEFAULT 0 COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint NULL DEFAULT 0 COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`) USING BTREE,
  INDEX `idx_sys_oper_log_bt`(`business_type` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_ot`(`oper_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 189 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
INSERT INTO `sys_oper_log` VALUES (100, '代码生成', 6, 'com.ruoyi.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '127.0.0.1', '内网IP', '{\"tables\":\"user\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 16:32:21', 56);
INSERT INTO `sys_oper_log` VALUES (101, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"user\",\"className\":\"User\",\"columns\":[{\"capJavaField\":\"Id\",\"columnId\":1,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 16:32:21\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":false,\"isIncrement\":\"1\",\"isInsert\":\"0\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":1,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Username\",\"columnComment\":\"用户名\",\"columnId\":2,\"columnName\":\"username\",\"columnType\":\"varchar(50)\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 16:32:21\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"username\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"LIKE\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":1,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Password\",\"columnComment\":\"密码\",\"columnId\":3,\"columnName\":\"password\",\"columnType\":\"varchar(255)\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 16:32:21\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"1\",\"javaField\":\"password\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":false,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":1,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Role\",\"columnComment\":\"角色\",\"columnId\":4,\"columnName\":\"role\",\"columnType\":\"enum(\'admin\',\'teacher\',\'student\')\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 16:32:21\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"select\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"role\",\"javaType\":\"', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 17:35:44', 57);
INSERT INTO `sys_oper_log` VALUES (102, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"user\"}', NULL, 0, NULL, '2025-07-15 17:35:48', 353);
INSERT INTO `sys_oper_log` VALUES (103, '菜单管理', 1, 'com.ruoyi.web.controller.system.SysMenuController.add()', 'POST', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createBy\":\"admin\",\"icon\":\"people\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuName\":\"人员管理\",\"menuType\":\"M\",\"orderNum\":2,\"params\":{},\"parentId\":0,\"path\":\"/people\",\"status\":\"0\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 17:43:25', 13);
INSERT INTO `sys_oper_log` VALUES (104, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"user/user/index\",\"createTime\":\"2025-07-15 17:39:26\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2000,\"menuName\":\"人员管理\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":2006,\"path\":\"user\",\"perms\":\"user:user:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 17:43:49', 8);
INSERT INTO `sys_oper_log` VALUES (105, '人员管理', 1, 'com.ruoyi.user.controller.UserController.add()', 'POST', 1, 'admin', '研发部门', '/user/user', '127.0.0.1', '内网IP', '{\"email\":\"2289749024@qq.com\",\"id\":3,\"params\":{},\"realName\":\"梁本华\",\"role\":\"student\",\"username\":\"liangbenhua\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 17:56:48', 75);
INSERT INTO `sys_oper_log` VALUES (106, '菜单管理', 1, 'com.ruoyi.web.controller.system.SysMenuController.add()', 'POST', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createBy\":\"admin\",\"icon\":\"international\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuName\":\"课件资源管理\",\"menuType\":\"M\",\"orderNum\":3,\"params\":{},\"parentId\":0,\"path\":\"/resource\",\"status\":\"0\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 18:13:44', 11);
INSERT INTO `sys_oper_log` VALUES (107, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2025-07-15 18:13:44\",\"icon\":\"international\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2007,\"menuName\":\"课件资源管理\",\"menuType\":\"M\",\"orderNum\":2,\"params\":{},\"parentId\":0,\"path\":\"/resource\",\"perms\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 18:16:52', 9);
INSERT INTO `sys_oper_log` VALUES (108, '代码生成', 6, 'com.ruoyi.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '127.0.0.1', '内网IP', '{\"tables\":\"resource_file\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 18:21:37', 35);
INSERT INTO `sys_oper_log` VALUES (109, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"file\",\"className\":\"ResourceFile\",\"columns\":[{\"capJavaField\":\"Id\",\"columnId\":9,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:21:37\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":false,\"isIncrement\":\"1\",\"isInsert\":\"0\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":2,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"学科名\",\"columnId\":10,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:21:37\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":false,\"insert\":false,\"isEdit\":\"0\",\"isIncrement\":\"0\",\"isInsert\":\"0\",\"isList\":\"0\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"0\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":false,\"sort\":2,\"superColumn\":false,\"tableId\":2,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"TeacherId\",\"columnId\":11,\"columnName\":\"teacher_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:21:37\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":false,\"insert\":false,\"isEdit\":\"0\",\"isIncrement\":\"0\",\"isInsert\":\"0\",\"isList\":\"0\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"0\",\"javaField\":\"teacherId\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":false,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":3,\"superColumn\":false,\"tableId\":2,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"FileName\",\"columnComment\":\"文件名\",\"columnId\":12,\"columnName\":\"file_name\",\"columnType\":\"varchar(100)\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:21:37\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":false,\"insert\":false,\"isEdit\":\"0\",\"isIncrement\":\"0\",\"isInsert\":\"0\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"0\",\"javaField\":\"fileName\",\"javaType\":\"String\",\"list\":true,', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 18:30:58', 26);
INSERT INTO `sys_oper_log` VALUES (110, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"resource_file\"}', NULL, 0, NULL, '2025-07-15 18:31:00', 122);
INSERT INTO `sys_oper_log` VALUES (111, '人员管理', 2, 'com.ruoyi.user.controller.UserController.edit()', 'PUT', 1, 'admin', '研发部门', '/user/user', '127.0.0.1', '内网IP', '{\"createdAt\":\"2025-07-12\",\"email\":\"2289749024@qq.com\",\"id\":1,\"params\":{},\"realName\":\"张政\",\"role\":\"student\",\"username\":\"zhnagzheng\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 18:34:50', 13);
INSERT INTO `sys_oper_log` VALUES (112, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"file\",\"className\":\"ResourceFile\",\"columns\":[{\"capJavaField\":\"Id\",\"columnId\":9,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:21:37\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":false,\"isIncrement\":\"1\",\"isInsert\":\"0\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":2,\"updateBy\":\"\",\"updateTime\":\"2025-07-15 18:30:58\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"学科名\",\"columnId\":10,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:21:37\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":false,\"insert\":false,\"isEdit\":\"0\",\"isIncrement\":\"0\",\"isInsert\":\"0\",\"isList\":\"0\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"0\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":false,\"sort\":2,\"superColumn\":false,\"tableId\":2,\"updateBy\":\"\",\"updateTime\":\"2025-07-15 18:30:58\",\"usableColumn\":false},{\"capJavaField\":\"TeacherId\",\"columnId\":11,\"columnName\":\"teacher_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:21:37\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":false,\"insert\":false,\"isEdit\":\"0\",\"isIncrement\":\"0\",\"isInsert\":\"0\",\"isList\":\"0\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"0\",\"javaField\":\"teacherId\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":false,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":3,\"superColumn\":false,\"tableId\":2,\"updateBy\":\"\",\"updateTime\":\"2025-07-15 18:30:58\",\"usableColumn\":false},{\"capJavaField\":\"FileName\",\"columnComment\":\"文件名\",\"columnId\":12,\"columnName\":\"file_name\",\"columnType\":\"varchar(100)\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:21:37\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":false,\"insert\":false,\"isEdit\":\"0\",\"isIncrement\":\"0\",\"isInsert\":\"0\",\"isLi', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 18:36:57', 14);
INSERT INTO `sys_oper_log` VALUES (113, '代码生成', 6, 'com.ruoyi.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '127.0.0.1', '内网IP', '{\"tables\":\"course\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 18:38:13', 39);
INSERT INTO `sys_oper_log` VALUES (114, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"course\",\"className\":\"Course\",\"columns\":[{\"capJavaField\":\"Id\",\"columnId\":15,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:38:13\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":false,\"isIncrement\":\"1\",\"isInsert\":\"0\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":3,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"CourseName\",\"columnComment\":\"课程名\",\"columnId\":16,\"columnName\":\"course_name\",\"columnType\":\"varchar(100)\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:38:13\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseName\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"LIKE\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":3,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Description\",\"columnComment\":\"课程描述\",\"columnId\":17,\"columnName\":\"description\",\"columnType\":\"text\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:38:13\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"textarea\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"1\",\"javaField\":\"description\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":false,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":3,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"TeacherId\",\"columnComment\":\"创建人\",\"columnId\":18,\"columnName\":\"teacher_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:38:13\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"teacherId\",\"', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 18:45:37', 25);
INSERT INTO `sys_oper_log` VALUES (115, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"course\"}', NULL, 0, NULL, '2025-07-15 18:45:41', 43);
INSERT INTO `sys_oper_log` VALUES (116, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"file\",\"className\":\"ResourceFile\",\"columns\":[{\"capJavaField\":\"Id\",\"columnId\":9,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:21:37\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":false,\"isIncrement\":\"1\",\"isInsert\":\"0\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":2,\"updateBy\":\"\",\"updateTime\":\"2025-07-15 18:36:57\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"学科名\",\"columnId\":10,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:21:37\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":false,\"insert\":false,\"isEdit\":\"0\",\"isIncrement\":\"0\",\"isInsert\":\"0\",\"isList\":\"0\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"0\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":false,\"sort\":2,\"superColumn\":false,\"tableId\":2,\"updateBy\":\"\",\"updateTime\":\"2025-07-15 18:36:57\",\"usableColumn\":false},{\"capJavaField\":\"TeacherId\",\"columnId\":11,\"columnName\":\"teacher_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:21:37\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":false,\"insert\":false,\"isEdit\":\"0\",\"isIncrement\":\"0\",\"isInsert\":\"0\",\"isList\":\"0\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"0\",\"javaField\":\"teacherId\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":false,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":3,\"superColumn\":false,\"tableId\":2,\"updateBy\":\"\",\"updateTime\":\"2025-07-15 18:36:57\",\"usableColumn\":false},{\"capJavaField\":\"FileName\",\"columnComment\":\"文件名\",\"columnId\":12,\"columnName\":\"file_name\",\"columnType\":\"varchar(100)\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:21:37\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":false,\"insert\":false,\"isEdit\":\"0\",\"isIncrement\":\"0\",\"isInsert\":\"0\",\"isLi', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 18:55:54', 18);
INSERT INTO `sys_oper_log` VALUES (117, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"resource_file\"}', NULL, 0, NULL, '2025-07-15 18:56:16', 25);
INSERT INTO `sys_oper_log` VALUES (118, '课件管理', 5, 'com.ruoyi.file.controller.ResourceFileController.export()', 'POST', 1, 'admin', '研发部门', '/file/file/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"id\":\"101\",\"pageNum\":\"1\",\"courseId\":\"101\"}', NULL, 0, NULL, '2025-07-15 21:01:50', 1046);
INSERT INTO `sys_oper_log` VALUES (119, '课件管理', 5, 'com.ruoyi.file.controller.ResourceFileController.export()', 'POST', 1, 'admin', '研发部门', '/file/file/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"id\":\"101\",\"pageNum\":\"1\",\"courseId\":\"101\"}', NULL, 0, NULL, '2025-07-15 21:08:26', 62);
INSERT INTO `sys_oper_log` VALUES (120, '课件管理', 5, 'com.ruoyi.file.controller.ResourceFileController.export()', 'POST', 1, 'admin', '研发部门', '/file/file/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"id\":\"101\",\"pageNum\":\"1\",\"courseId\":\"101\"}', NULL, 0, NULL, '2025-07-15 21:10:19', 56);
INSERT INTO `sys_oper_log` VALUES (121, '代码生成', 6, 'com.ruoyi.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '127.0.0.1', '内网IP', '{\"tables\":\"assignment\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 21:12:47', 81);
INSERT INTO `sys_oper_log` VALUES (122, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"assignment\",\"className\":\"Assignment\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"作业ID\",\"columnId\":25,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 21:12:47\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":false,\"isIncrement\":\"1\",\"isInsert\":\"0\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":4,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"课程ID\",\"columnId\":26,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 21:12:47\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"select\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"0\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":4,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"TeacherId\",\"columnComment\":\"教师ID\",\"columnId\":27,\"columnName\":\"teacher_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 21:12:47\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"1\",\"javaField\":\"teacherId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":false,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":4,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Title\",\"columnComment\":\"作业标题\",\"columnId\":28,\"columnName\":\"title\",\"columnType\":\"varchar(100)\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 21:12:47\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"titl', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 21:20:04', 50);
INSERT INTO `sys_oper_log` VALUES (123, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"assignment\"}', NULL, 0, NULL, '2025-07-15 21:20:12', 142);
INSERT INTO `sys_oper_log` VALUES (124, '菜单管理', 1, 'com.ruoyi.web.controller.system.SysMenuController.add()', 'POST', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createBy\":\"admin\",\"icon\":\"education\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuName\":\"智教大屏\",\"menuType\":\"M\",\"orderNum\":1,\"params\":{},\"parentId\":0,\"path\":\"/daping\",\"status\":\"0\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 21:55:57', 17);
INSERT INTO `sys_oper_log` VALUES (125, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2025-07-15 21:55:57\",\"icon\":\"education\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2020,\"menuName\":\"智教大屏\",\"menuType\":\"M\",\"orderNum\":2,\"params\":{},\"parentId\":0,\"path\":\"/daping\",\"perms\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 21:56:18', 9);
INSERT INTO `sys_oper_log` VALUES (126, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2025-07-15 21:55:57\",\"icon\":\"education\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2020,\"menuName\":\"智教大屏\",\"menuType\":\"M\",\"orderNum\":3,\"params\":{},\"parentId\":0,\"path\":\"/daping\",\"perms\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 21:56:47', 7);
INSERT INTO `sys_oper_log` VALUES (127, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2025-07-15 21:55:57\",\"icon\":\"education\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2020,\"menuName\":\"智教大屏\",\"menuType\":\"M\",\"orderNum\":2,\"params\":{},\"parentId\":0,\"path\":\"/daping\",\"perms\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 21:57:09', 8);
INSERT INTO `sys_oper_log` VALUES (128, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"daping\",\"className\":\"Course\",\"columns\":[{\"capJavaField\":\"Id\",\"columnId\":15,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:38:13\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":false,\"isIncrement\":\"1\",\"isInsert\":\"0\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":3,\"updateBy\":\"\",\"updateTime\":\"2025-07-15 18:45:37\",\"usableColumn\":false},{\"capJavaField\":\"CourseName\",\"columnComment\":\"课程名\",\"columnId\":16,\"columnName\":\"course_name\",\"columnType\":\"varchar(100)\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:38:13\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseName\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"LIKE\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":3,\"updateBy\":\"\",\"updateTime\":\"2025-07-15 18:45:37\",\"usableColumn\":false},{\"capJavaField\":\"Description\",\"columnComment\":\"课程描述\",\"columnId\":17,\"columnName\":\"description\",\"columnType\":\"text\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:38:13\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"textarea\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"1\",\"javaField\":\"description\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":false,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":3,\"updateBy\":\"\",\"updateTime\":\"2025-07-15 18:45:37\",\"usableColumn\":false},{\"capJavaField\":\"TeacherId\",\"columnComment\":\"创建人\",\"columnId\":18,\"columnName\":\"teacher_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-15 18:38:13\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncre', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-15 22:04:06', 43);
INSERT INTO `sys_oper_log` VALUES (129, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"course\"}', NULL, 0, NULL, '2025-07-15 22:04:16', 65);
INSERT INTO `sys_oper_log` VALUES (130, '菜单管理', 3, 'com.ruoyi.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/4', '127.0.0.1', '内网IP', '4', '{\"msg\":\"菜单已分配,不允许删除\",\"code\":601}', 0, NULL, '2025-07-16 12:32:37', 59);
INSERT INTO `sys_oper_log` VALUES (131, '菜单管理', 3, 'com.ruoyi.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/4', '127.0.0.1', '内网IP', '4', '{\"msg\":\"菜单已分配,不允许删除\",\"code\":601}', 0, NULL, '2025-07-16 12:32:43', 3);
INSERT INTO `sys_oper_log` VALUES (132, '菜单管理', 3, 'com.ruoyi.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/4', '127.0.0.1', '内网IP', '4', '{\"msg\":\"菜单已分配,不允许删除\",\"code\":601}', 0, NULL, '2025-07-16 12:32:49', 2);
INSERT INTO `sys_oper_log` VALUES (133, '角色管理', 1, 'com.ruoyi.web.controller.system.SysRoleController.add()', 'POST', 1, 'admin', '研发部门', '/system/role', '127.0.0.1', '内网IP', '{\"admin\":false,\"createBy\":\"admin\",\"deptCheckStrictly\":true,\"deptIds\":[],\"flag\":false,\"menuCheckStrictly\":true,\"menuIds\":[2006,2000,2001,2002,2003,2004,2005,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025,2026],\"params\":{},\"roleId\":100,\"roleKey\":\"adminmin\",\"roleName\":\"管理员\",\"roleSort\":3,\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 12:45:34', 47);
INSERT INTO `sys_oper_log` VALUES (134, '角色管理', 4, 'com.ruoyi.web.controller.system.SysRoleController.selectAuthUserAll()', 'PUT', 1, 'admin', '研发部门', '/system/role/authUser/selectAll', '127.0.0.1', '内网IP', '{\"roleId\":\"100\",\"userIds\":\"2\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 12:47:36', 5);
INSERT INTO `sys_oper_log` VALUES (135, '角色管理', 4, 'com.ruoyi.web.controller.system.SysRoleController.cancelAuthUser()', 'PUT', 1, 'admin', '研发部门', '/system/role/authUser/cancel', '127.0.0.1', '内网IP', '{\"roleId\":2,\"userId\":2}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 12:52:21', 13);
INSERT INTO `sys_oper_log` VALUES (136, '人员管理', 1, 'com.ruoyi.user.controller.UserController.add()', 'POST', 1, 'admin', '研发部门', '/user/user', '127.0.0.1', '内网IP', '{\"email\":\"123456@qq.com\",\"id\":4,\"params\":{},\"realName\":\"若依\",\"role\":\"admin\",\"username\":\"ry\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 13:30:20', 30);
INSERT INTO `sys_oper_log` VALUES (137, '代码生成', 6, 'com.ruoyi.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '127.0.0.1', '内网IP', '{\"tables\":\"question_bank\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 13:46:33', 96);
INSERT INTO `sys_oper_log` VALUES (138, '字典类型', 1, 'com.ruoyi.web.controller.system.SysDictTypeController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/type', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"dictName\":\"题目类型\",\"dictType\":\"quertion_type\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 13:51:57', 8);
INSERT INTO `sys_oper_log` VALUES (139, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"choice\",\"dictSort\":0,\"dictType\":\"quertion_type\",\"dictValue\":\"选择题\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 13:52:40', 7);
INSERT INTO `sys_oper_log` VALUES (140, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"short_answer\",\"dictSort\":2,\"dictType\":\"quertion_type\",\"dictValue\":\"简答题\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 13:53:14', 5);
INSERT INTO `sys_oper_log` VALUES (141, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"programming\",\"dictSort\":0,\"dictType\":\"quertion_type\",\"dictValue\":\"编程题\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 13:53:34', 5);
INSERT INTO `sys_oper_log` VALUES (142, '字典数据', 2, 'com.ruoyi.web.controller.system.SysDictDataController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2025-07-16 13:53:34\",\"default\":false,\"dictCode\":102,\"dictLabel\":\"programming\",\"dictSort\":3,\"dictType\":\"quertion_type\",\"dictValue\":\"编程题\",\"isDefault\":\"N\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\",\"updateBy\":\"admin\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 13:53:41', 5);
INSERT INTO `sys_oper_log` VALUES (143, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"bank\",\"className\":\"QuestionBank\",\"columns\":[{\"capJavaField\":\"Id\",\"columnId\":32,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-16 13:46:33\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":false,\"isIncrement\":\"1\",\"isInsert\":\"0\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":5,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnId\":33,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-16 13:46:33\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"0\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":5,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Type\",\"columnId\":34,\"columnName\":\"type\",\"columnType\":\"enum(\'choice\',\'short_answer\',\'programming\')\",\"createBy\":\"admin\",\"createTime\":\"2025-07-16 13:46:33\",\"dictType\":\"quertion_type\",\"edit\":true,\"htmlType\":\"select\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"type\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":5,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Content\",\"columnId\":35,\"columnName\":\"content\",\"columnType\":\"text\",\"createBy\":\"admin\",\"createTime\":\"2025-07-16 13:46:33\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"editor\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"content\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"que', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 14:02:49', 48);
INSERT INTO `sys_oper_log` VALUES (144, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"question_bank\"}', NULL, 0, NULL, '2025-07-16 14:02:55', 533);
INSERT INTO `sys_oper_log` VALUES (145, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"assignment/assignment/index\",\"createTime\":\"2025-07-15 21:20:40\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2014,\"menuName\":\"作业管理\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":2007,\"path\":\"assignment\",\"perms\":\"assignment:assignment:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 14:05:17', 32);
INSERT INTO `sys_oper_log` VALUES (146, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"bank\",\"className\":\"QuestionBank\",\"columns\":[{\"capJavaField\":\"Id\",\"columnId\":32,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-16 13:46:33\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":false,\"isIncrement\":\"1\",\"isInsert\":\"0\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":5,\"updateBy\":\"\",\"updateTime\":\"2025-07-16 14:02:49\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"学科名\",\"columnId\":33,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-07-16 13:46:33\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"0\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":5,\"updateBy\":\"\",\"updateTime\":\"2025-07-16 14:02:49\",\"usableColumn\":false},{\"capJavaField\":\"Type\",\"columnComment\":\"题目类型\",\"columnId\":34,\"columnName\":\"type\",\"columnType\":\"enum(\'choice\',\'short_answer\',\'programming\')\",\"createBy\":\"admin\",\"createTime\":\"2025-07-16 13:46:33\",\"dictType\":\"quertion_type\",\"edit\":true,\"htmlType\":\"select\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"type\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":5,\"updateBy\":\"\",\"updateTime\":\"2025-07-16 14:02:49\",\"usableColumn\":false},{\"capJavaField\":\"Content\",\"columnComment\":\"题目内容\",\"columnId\":35,\"columnName\":\"content\",\"columnType\":\"text\",\"createBy\":\"admin\",\"createTime\":\"2025-07-16 13:46:33\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"editor\",\"increment\":false,\"insert\":true,\"isEdit\":', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 14:53:17', 43);
INSERT INTO `sys_oper_log` VALUES (147, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"question_bank\"}', NULL, 0, NULL, '2025-07-16 14:53:20', 162);
INSERT INTO `sys_oper_log` VALUES (148, '练习管理', 2, 'com.ruoyi.bank.controller.QuestionBankController.edit()', 'PUT', 1, 'admin', '研发部门', '/bank/bank', '127.0.0.1', '内网IP', '{\"answer\":\"嵌入式Linux是针对嵌入式设备裁剪优化的Linux系统。\",\"content\":\"<p><em>什么是嵌入式Linux？</em></p>\",\"courseId\":101,\"createdAt\":\"2025-07-12 16:38:43\",\"createdBy\":2,\"id\":1,\"knowledgePoint\":\"嵌入式基础\",\"params\":{},\"type\":\"short_answer\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 14:57:31', 19);
INSERT INTO `sys_oper_log` VALUES (149, '练习管理', 2, 'com.ruoyi.bank.controller.QuestionBankController.edit()', 'PUT', 1, 'admin', '研发部门', '/bank/bank', '127.0.0.1', '内网IP', '{\"answer\":\"嵌入式Linux是针对嵌入式设备裁剪优化的Linux系统。\",\"content\":\"<p>什么是嵌入式Linux？</p>\",\"courseId\":101,\"createdAt\":\"2025-07-12 16:38:43\",\"createdBy\":2,\"id\":1,\"knowledgePoint\":\"嵌入式基础\",\"params\":{},\"type\":\"short_answer\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 14:57:38', 5);
INSERT INTO `sys_oper_log` VALUES (150, '练习管理', 2, 'com.ruoyi.bank.controller.QuestionBankController.edit()', 'PUT', 1, 'admin', '研发部门', '/bank/bank', '127.0.0.1', '内网IP', '{\"answer\":\"嵌入式Linux是针对嵌入式设备裁剪优化的Linux系统。\",\"content\":\"<p>什么是嵌入式Linux？</p>\",\"courseId\":101,\"createdAt\":\"2025-07-12 16:38:43\",\"createdBy\":2,\"id\":1,\"knowledgePoint\":\"嵌入式基础\",\"params\":{},\"type\":\"short_answer\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 14:57:48', 3);
INSERT INTO `sys_oper_log` VALUES (151, '字典数据', 2, 'com.ruoyi.web.controller.system.SysDictDataController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2025-07-16 13:52:40\",\"default\":false,\"dictCode\":100,\"dictLabel\":\"选择题\",\"dictSort\":0,\"dictType\":\"quertion_type\",\"dictValue\":\"choice\",\"isDefault\":\"N\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\",\"updateBy\":\"admin\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 15:11:52', 13);
INSERT INTO `sys_oper_log` VALUES (152, '字典数据', 2, 'com.ruoyi.web.controller.system.SysDictDataController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2025-07-16 13:53:14\",\"default\":false,\"dictCode\":101,\"dictLabel\":\"简答题\",\"dictSort\":2,\"dictType\":\"quertion_type\",\"dictValue\":\"short_answer\",\"isDefault\":\"N\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\",\"updateBy\":\"admin\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 15:12:01', 14);
INSERT INTO `sys_oper_log` VALUES (153, '字典数据', 2, 'com.ruoyi.web.controller.system.SysDictDataController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2025-07-16 13:53:34\",\"default\":false,\"dictCode\":102,\"dictLabel\":\"编程题\",\"dictSort\":3,\"dictType\":\"quertion_type\",\"dictValue\":\"programming\",\"isDefault\":\"N\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\",\"updateBy\":\"admin\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 15:12:09', 11);
INSERT INTO `sys_oper_log` VALUES (154, '角色管理', 2, 'com.ruoyi.web.controller.system.SysRoleController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/role', '127.0.0.1', '内网IP', '{\"admin\":false,\"createTime\":\"2025-07-16 12:45:34\",\"dataScope\":\"1\",\"delFlag\":\"0\",\"deptCheckStrictly\":true,\"flag\":false,\"menuCheckStrictly\":true,\"menuIds\":[2006,2000,2001,2002,2003,2004,2005,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2027,2028,2029,2030,2031,2032,2020,2021,2022,2023,2024,2025,2026],\"params\":{},\"roleId\":100,\"roleKey\":\"adminmin\",\"roleName\":\"管理员\",\"roleSort\":3,\"status\":\"0\",\"updateBy\":\"admin\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-16 16:26:51', 64);
INSERT INTO `sys_oper_log` VALUES (155, '课件管理', 5, 'com.ruoyi.file.controller.ResourceFileController.export()', 'POST', 1, 'ry', '测试部门', '/file/file/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\"}', NULL, 0, NULL, '2025-07-20 16:01:44', 568);
INSERT INTO `sys_oper_log` VALUES (156, '作业练习管理', 2, 'com.ruoyi.assignment.controller.AssignmentController.edit()', 'PUT', 1, 'ry', '测试部门', '/assignment/assignment', '127.0.0.1', '内网IP', '{\"courseId\":101,\"createdAt\":\"2025-07-17\",\"description\":\"快写\",\"dueDate\":\"2025-07-25\",\"id\":3,\"params\":{},\"teacherId\":2,\"title\":\"嵌入式基础66\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-20 16:02:06', 15);
INSERT INTO `sys_oper_log` VALUES (157, '练习管理', 5, 'com.ruoyi.bank.controller.QuestionBankController.export()', 'POST', 1, 'ry', '测试部门', '/bank/bank/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"type\":\"choice\",\"pageNum\":\"1\",\"courseId\":\"101\"}', NULL, 0, NULL, '2025-07-20 16:03:48', 64);
INSERT INTO `sys_oper_log` VALUES (158, '人员管理', 2, 'com.ruoyi.user.controller.UserController.edit()', 'PUT', 1, 'ry', '测试部门', '/user/user', '127.0.0.1', '内网IP', '{\"createdAt\":\"2025-07-15\",\"email\":\"2289749024@qq.com\",\"id\":3,\"params\":{},\"realName\":\"梁本华\",\"role\":\"student\",\"username\":\"liangbenhua1\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-20 16:20:18', 16);
INSERT INTO `sys_oper_log` VALUES (159, '人员管理', 2, 'com.ruoyi.user.controller.UserController.edit()', 'PUT', 1, 'ry', '测试部门', '/user/user', '127.0.0.1', '内网IP', '{\"createdAt\":\"2025-07-15\",\"email\":\"2289749024@qq.com\",\"id\":3,\"params\":{},\"realName\":\"梁本华\",\"role\":\"student\",\"username\":\"liangbenhua\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-20 16:20:26', 4);
INSERT INTO `sys_oper_log` VALUES (160, '课件管理', 5, 'com.ruoyi.file.controller.ResourceFileController.export()', 'POST', 1, 'ry', '测试部门', '/file/file/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\",\"courseId\":\"101\"}', NULL, 0, NULL, '2025-07-20 16:20:49', 49);
INSERT INTO `sys_oper_log` VALUES (161, '人员管理', 2, 'com.ruoyi.user.controller.UserController.edit()', 'PUT', 1, 'ry', '测试部门', '/user/user', '127.0.0.1', '内网IP', '{\"createdAt\":\"2025-07-12\",\"email\":\"2289749024@qq.com\",\"id\":1,\"params\":{},\"realName\":\"张政\",\"role\":\"student\",\"username\":\"zz1\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-20 16:25:30', 6);
INSERT INTO `sys_oper_log` VALUES (162, '课件管理', 5, 'com.ruoyi.file.controller.ResourceFileController.export()', 'POST', 1, 'ry', '测试部门', '/file/file/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\",\"courseId\":\"101\"}', NULL, 0, NULL, '2025-07-20 16:25:50', 36);
INSERT INTO `sys_oper_log` VALUES (163, '作业练习管理', 2, 'com.ruoyi.assignment.controller.AssignmentController.edit()', 'PUT', 1, 'ry', '测试部门', '/assignment/assignment', '127.0.0.1', '内网IP', '{\"courseId\":101,\"createdAt\":\"2025-07-17\",\"description\":\"快写\",\"dueDate\":\"2025-07-25\",\"id\":3,\"params\":{},\"teacherId\":2,\"title\":\"嵌入式基础667\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-20 16:26:06', 4);
INSERT INTO `sys_oper_log` VALUES (164, '练习管理', 5, 'com.ruoyi.bank.controller.QuestionBankController.export()', 'POST', 1, 'ry', '测试部门', '/bank/bank/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"type\":\"short_answer\",\"pageNum\":\"1\",\"courseId\":\"101\"}', NULL, 0, NULL, '2025-07-20 16:26:30', 47);
INSERT INTO `sys_oper_log` VALUES (165, '人员管理', 2, 'com.ruoyi.user.controller.UserController.edit()', 'PUT', 1, 'ry', '测试部门', '/user/user', '127.0.0.1', '内网IP', '{\"createdAt\":\"2025-07-12\",\"email\":\"2289749024@qq.com\",\"id\":1,\"params\":{},\"realName\":\"张政\",\"role\":\"student\",\"username\":\"zz12\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-20 16:28:32', 5);
INSERT INTO `sys_oper_log` VALUES (166, '课件管理', 5, 'com.ruoyi.file.controller.ResourceFileController.export()', 'POST', 1, 'ry', '测试部门', '/file/file/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\",\"courseId\":\"101\"}', NULL, 0, NULL, '2025-07-20 16:28:49', 30);
INSERT INTO `sys_oper_log` VALUES (167, '练习管理', 5, 'com.ruoyi.bank.controller.QuestionBankController.export()', 'POST', 1, 'ry', '测试部门', '/bank/bank/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"type\":\"choice\",\"pageNum\":\"1\",\"courseId\":\"101\"}', NULL, 0, NULL, '2025-07-20 16:29:14', 37);
INSERT INTO `sys_oper_log` VALUES (168, '人员管理', 2, 'com.ruoyi.user.controller.UserController.edit()', 'PUT', 1, 'ry', '测试部门', '/user/user', '127.0.0.1', '内网IP', '{\"createdAt\":\"2025-07-12\",\"email\":\"2289749024@qq.com\",\"id\":1,\"params\":{},\"realName\":\"张政\",\"role\":\"student\",\"username\":\"zz123\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-20 16:30:29', 5);
INSERT INTO `sys_oper_log` VALUES (169, '课件管理', 5, 'com.ruoyi.file.controller.ResourceFileController.export()', 'POST', 1, 'ry', '测试部门', '/file/file/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\",\"courseId\":\"101\"}', NULL, 0, NULL, '2025-07-20 16:30:41', 29);
INSERT INTO `sys_oper_log` VALUES (170, '人员管理', 2, 'com.ruoyi.user.controller.UserController.edit()', 'PUT', 1, 'ry', '测试部门', '/user/user', '127.0.0.1', '内网IP', '{\"createdAt\":\"2025-07-12\",\"email\":\"2289749024@qq.com\",\"id\":1,\"params\":{},\"realName\":\"张政\",\"role\":\"student\",\"username\":\"zz1234\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-20 16:31:39', 7);
INSERT INTO `sys_oper_log` VALUES (171, '课件管理', 5, 'com.ruoyi.file.controller.ResourceFileController.export()', 'POST', 1, 'ry', '测试部门', '/file/file/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\",\"courseId\":\"101\"}', NULL, 0, NULL, '2025-07-20 16:32:00', 26);
INSERT INTO `sys_oper_log` VALUES (172, '练习管理', 5, 'com.ruoyi.bank.controller.QuestionBankController.export()', 'POST', 1, 'ry', '测试部门', '/bank/bank/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"type\":\"choice\",\"pageNum\":\"1\",\"courseId\":\"101\"}', NULL, 0, NULL, '2025-07-20 16:32:31', 44);
INSERT INTO `sys_oper_log` VALUES (173, '人员管理', 2, 'com.ruoyi.user.controller.UserController.edit()', 'PUT', 1, 'ry', '测试部门', '/user/user', '127.0.0.1', '内网IP', '{\"createdAt\":\"2025-07-12\",\"email\":\"2289749024@qq.com\",\"id\":1,\"params\":{},\"realName\":\"张政\",\"role\":\"student\",\"username\":\"zz12345\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-07-20 16:34:49', 6);
INSERT INTO `sys_oper_log` VALUES (174, '课件管理', 5, 'com.ruoyi.file.controller.ResourceFileController.export()', 'POST', 1, 'ry', '测试部门', '/file/file/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\",\"courseId\":\"101\"}', NULL, 0, NULL, '2025-07-20 16:34:59', 23);
INSERT INTO `sys_oper_log` VALUES (175, '练习管理', 5, 'com.ruoyi.bank.controller.QuestionBankController.export()', 'POST', 1, 'ry', '测试部门', '/bank/bank/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"type\":\"choice\",\"pageNum\":\"1\",\"courseId\":\"101\"}', NULL, 0, NULL, '2025-07-20 16:35:25', 35);
INSERT INTO `sys_oper_log` VALUES (176, '练习管理', 5, 'com.ruoyi.bank.controller.QuestionBankController.export()', 'POST', 1, 'ry', '测试部门', '/bank/bank/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\"}', NULL, 0, NULL, '2025-07-21 15:13:02', 491);
INSERT INTO `sys_oper_log` VALUES (177, '课件管理', 5, 'com.ruoyi.file.controller.ResourceFileController.export()', 'POST', 1, 'admin', '研发部门', '/file/file/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\"}', NULL, 0, NULL, '2025-08-09 15:57:34', 449);
INSERT INTO `sys_oper_log` VALUES (178, '课件资源打包下载', 5, 'com.ruoyi.file.controller.ResourceFileController.exportResources()', 'POST', 1, 'admin', '研发部门', '/file/file/exportResources', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"ids\":\"4\",\"pageNum\":\"1\"}', NULL, 0, NULL, '2025-08-09 16:09:13', 9);
INSERT INTO `sys_oper_log` VALUES (179, '课件资源打包下载', 5, 'com.ruoyi.file.controller.ResourceFileController.exportResources()', 'POST', 1, 'admin', '研发部门', '/file/file/exportResources', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"ids\":\"5,4\",\"pageNum\":\"1\"}', NULL, 0, NULL, '2025-08-09 16:09:47', 6);
INSERT INTO `sys_oper_log` VALUES (180, '课件管理', 3, 'com.ruoyi.file.controller.ResourceFileController.remove()', 'DELETE', 1, 'admin', '研发部门', '/file/file/11', '127.0.0.1', '内网IP', '[11]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-08-09 16:16:40', 13);
INSERT INTO `sys_oper_log` VALUES (181, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"bank/bank/index\",\"createTime\":\"2025-07-16 14:04:31\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2027,\"menuName\":\"题目管理\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":2007,\"path\":\"bank\",\"perms\":\"bank:bank:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-08-09 17:48:40', 14);
INSERT INTO `sys_oper_log` VALUES (182, '课件管理', 5, 'com.ruoyi.file.controller.ResourceFileController.export()', 'POST', 1, 'admin', '研发部门', '/file/file/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\"}', NULL, 0, NULL, '2025-08-09 22:26:16', 999);
INSERT INTO `sys_oper_log` VALUES (183, '作业练习管理', 5, 'com.ruoyi.assignment.controller.AssignmentController.export()', 'POST', 1, 'admin', '研发部门', '/assignment/assignment/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\"}', NULL, 0, NULL, '2025-08-09 22:27:04', 72);
INSERT INTO `sys_oper_log` VALUES (184, '作业练习管理', 5, 'com.ruoyi.assignment.controller.AssignmentController.export()', 'POST', 1, 'admin', '研发部门', '/assignment/assignment/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\"}', NULL, 0, NULL, '2025-08-09 22:27:26', 45);
INSERT INTO `sys_oper_log` VALUES (185, '作业练习管理', 5, 'com.ruoyi.assignment.controller.AssignmentController.export()', 'POST', 1, 'admin', '研发部门', '/assignment/assignment/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\"}', NULL, 0, NULL, '2025-08-09 23:51:10', 271);
INSERT INTO `sys_oper_log` VALUES (186, '人员管理', 2, 'com.ruoyi.user.controller.UserController.edit()', 'PUT', 1, 'admin', '研发部门', '/user/user', '127.0.0.1', '内网IP', '{\"createdAt\":\"2025-07-15\",\"email\":\"家里蹲大学\",\"id\":3,\"params\":{},\"realName\":\"梁本华\",\"role\":\"student\",\"username\":\"liangbenhua\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-08-10 11:01:27', 55);
INSERT INTO `sys_oper_log` VALUES (187, '人员管理', 2, 'com.ruoyi.user.controller.UserController.edit()', 'PUT', 1, 'admin', '研发部门', '/user/user', '127.0.0.1', '内网IP', '{\"createdAt\":\"2025-07-16\",\"email\":\"家里蹲大学\",\"id\":4,\"params\":{},\"realName\":\"若依\",\"role\":\"admin\",\"username\":\"ry\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-08-10 11:01:34', 9);
INSERT INTO `sys_oper_log` VALUES (188, '人员管理', 2, 'com.ruoyi.user.controller.UserController.edit()', 'PUT', 1, 'admin', '研发部门', '/user/user', '127.0.0.1', '内网IP', '{\"createdAt\":\"2025-07-12\",\"email\":\"家里蹲大学\",\"id\":2,\"params\":{},\"realName\":\"猪猪侠\",\"role\":\"teacher\",\"username\":\"hanmeimei\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-08-10 11:01:42', 5);
INSERT INTO `sys_oper_log` VALUES (189, '人员管理', 2, 'com.ruoyi.user.controller.UserController.edit()', 'PUT', 1, 'admin', '研发部门', '/user/user', '127.0.0.1', '内网IP', '{\"createdAt\":\"2025-07-12\",\"email\":\"家里蹲大学\",\"id\":1,\"params\":{},\"realName\":\"张政\",\"role\":\"student\",\"username\":\"lilei\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-08-10 11:01:49', 8);

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post`  (
  `post_id` bigint NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
  `post_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '岗位编码',
  `post_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '岗位名称',
  `post_sort` int NOT NULL COMMENT '显示顺序',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '岗位信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_post
-- ----------------------------
INSERT INTO `sys_post` VALUES (1, 'ceo', '董事长', 1, '0', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_post` VALUES (2, 'se', '项目经理', 2, '0', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_post` VALUES (3, 'hr', '人力资源', 3, '0', 'admin', '2025-07-15 16:08:15', '', NULL, '');
INSERT INTO `sys_post` VALUES (4, 'user', '普通员工', 4, '0', 'admin', '2025-07-15 16:08:15', '', NULL, '');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色权限字符串',
  `role_sort` int NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  `menu_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '部门树选择项是否关联显示',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '超级管理员');
INSERT INTO `sys_role` VALUES (2, '普通角色', 'common', 2, '2', 1, 1, '0', '0', 'admin', '2025-07-15 16:08:15', '', NULL, '普通角色');
INSERT INTO `sys_role` VALUES (100, '管理员', 'adminmin', 3, '1', 1, 1, '0', '0', 'admin', '2025-07-16 12:45:34', 'admin', '2025-07-16 16:26:51', NULL);

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE `sys_role_dept`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `dept_id` bigint NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`, `dept_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色和部门关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_dept
-- ----------------------------
INSERT INTO `sys_role_dept` VALUES (2, 100);
INSERT INTO `sys_role_dept` VALUES (2, 101);
INSERT INTO `sys_role_dept` VALUES (2, 105);

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色和菜单关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES (2, 1);
INSERT INTO `sys_role_menu` VALUES (2, 2);
INSERT INTO `sys_role_menu` VALUES (2, 3);
INSERT INTO `sys_role_menu` VALUES (2, 4);
INSERT INTO `sys_role_menu` VALUES (2, 100);
INSERT INTO `sys_role_menu` VALUES (2, 101);
INSERT INTO `sys_role_menu` VALUES (2, 102);
INSERT INTO `sys_role_menu` VALUES (2, 103);
INSERT INTO `sys_role_menu` VALUES (2, 104);
INSERT INTO `sys_role_menu` VALUES (2, 105);
INSERT INTO `sys_role_menu` VALUES (2, 106);
INSERT INTO `sys_role_menu` VALUES (2, 107);
INSERT INTO `sys_role_menu` VALUES (2, 108);
INSERT INTO `sys_role_menu` VALUES (2, 109);
INSERT INTO `sys_role_menu` VALUES (2, 110);
INSERT INTO `sys_role_menu` VALUES (2, 111);
INSERT INTO `sys_role_menu` VALUES (2, 112);
INSERT INTO `sys_role_menu` VALUES (2, 113);
INSERT INTO `sys_role_menu` VALUES (2, 114);
INSERT INTO `sys_role_menu` VALUES (2, 115);
INSERT INTO `sys_role_menu` VALUES (2, 116);
INSERT INTO `sys_role_menu` VALUES (2, 117);
INSERT INTO `sys_role_menu` VALUES (2, 500);
INSERT INTO `sys_role_menu` VALUES (2, 501);
INSERT INTO `sys_role_menu` VALUES (2, 1000);
INSERT INTO `sys_role_menu` VALUES (2, 1001);
INSERT INTO `sys_role_menu` VALUES (2, 1002);
INSERT INTO `sys_role_menu` VALUES (2, 1003);
INSERT INTO `sys_role_menu` VALUES (2, 1004);
INSERT INTO `sys_role_menu` VALUES (2, 1005);
INSERT INTO `sys_role_menu` VALUES (2, 1006);
INSERT INTO `sys_role_menu` VALUES (2, 1007);
INSERT INTO `sys_role_menu` VALUES (2, 1008);
INSERT INTO `sys_role_menu` VALUES (2, 1009);
INSERT INTO `sys_role_menu` VALUES (2, 1010);
INSERT INTO `sys_role_menu` VALUES (2, 1011);
INSERT INTO `sys_role_menu` VALUES (2, 1012);
INSERT INTO `sys_role_menu` VALUES (2, 1013);
INSERT INTO `sys_role_menu` VALUES (2, 1014);
INSERT INTO `sys_role_menu` VALUES (2, 1015);
INSERT INTO `sys_role_menu` VALUES (2, 1016);
INSERT INTO `sys_role_menu` VALUES (2, 1017);
INSERT INTO `sys_role_menu` VALUES (2, 1018);
INSERT INTO `sys_role_menu` VALUES (2, 1019);
INSERT INTO `sys_role_menu` VALUES (2, 1020);
INSERT INTO `sys_role_menu` VALUES (2, 1021);
INSERT INTO `sys_role_menu` VALUES (2, 1022);
INSERT INTO `sys_role_menu` VALUES (2, 1023);
INSERT INTO `sys_role_menu` VALUES (2, 1024);
INSERT INTO `sys_role_menu` VALUES (2, 1025);
INSERT INTO `sys_role_menu` VALUES (2, 1026);
INSERT INTO `sys_role_menu` VALUES (2, 1027);
INSERT INTO `sys_role_menu` VALUES (2, 1028);
INSERT INTO `sys_role_menu` VALUES (2, 1029);
INSERT INTO `sys_role_menu` VALUES (2, 1030);
INSERT INTO `sys_role_menu` VALUES (2, 1031);
INSERT INTO `sys_role_menu` VALUES (2, 1032);
INSERT INTO `sys_role_menu` VALUES (2, 1033);
INSERT INTO `sys_role_menu` VALUES (2, 1034);
INSERT INTO `sys_role_menu` VALUES (2, 1035);
INSERT INTO `sys_role_menu` VALUES (2, 1036);
INSERT INTO `sys_role_menu` VALUES (2, 1037);
INSERT INTO `sys_role_menu` VALUES (2, 1038);
INSERT INTO `sys_role_menu` VALUES (2, 1039);
INSERT INTO `sys_role_menu` VALUES (2, 1040);
INSERT INTO `sys_role_menu` VALUES (2, 1041);
INSERT INTO `sys_role_menu` VALUES (2, 1042);
INSERT INTO `sys_role_menu` VALUES (2, 1043);
INSERT INTO `sys_role_menu` VALUES (2, 1044);
INSERT INTO `sys_role_menu` VALUES (2, 1045);
INSERT INTO `sys_role_menu` VALUES (2, 1046);
INSERT INTO `sys_role_menu` VALUES (2, 1047);
INSERT INTO `sys_role_menu` VALUES (2, 1048);
INSERT INTO `sys_role_menu` VALUES (2, 1049);
INSERT INTO `sys_role_menu` VALUES (2, 1050);
INSERT INTO `sys_role_menu` VALUES (2, 1051);
INSERT INTO `sys_role_menu` VALUES (2, 1052);
INSERT INTO `sys_role_menu` VALUES (2, 1053);
INSERT INTO `sys_role_menu` VALUES (2, 1054);
INSERT INTO `sys_role_menu` VALUES (2, 1055);
INSERT INTO `sys_role_menu` VALUES (2, 1056);
INSERT INTO `sys_role_menu` VALUES (2, 1057);
INSERT INTO `sys_role_menu` VALUES (2, 1058);
INSERT INTO `sys_role_menu` VALUES (2, 1059);
INSERT INTO `sys_role_menu` VALUES (2, 1060);
INSERT INTO `sys_role_menu` VALUES (100, 2000);
INSERT INTO `sys_role_menu` VALUES (100, 2001);
INSERT INTO `sys_role_menu` VALUES (100, 2002);
INSERT INTO `sys_role_menu` VALUES (100, 2003);
INSERT INTO `sys_role_menu` VALUES (100, 2004);
INSERT INTO `sys_role_menu` VALUES (100, 2005);
INSERT INTO `sys_role_menu` VALUES (100, 2006);
INSERT INTO `sys_role_menu` VALUES (100, 2007);
INSERT INTO `sys_role_menu` VALUES (100, 2008);
INSERT INTO `sys_role_menu` VALUES (100, 2009);
INSERT INTO `sys_role_menu` VALUES (100, 2010);
INSERT INTO `sys_role_menu` VALUES (100, 2011);
INSERT INTO `sys_role_menu` VALUES (100, 2012);
INSERT INTO `sys_role_menu` VALUES (100, 2013);
INSERT INTO `sys_role_menu` VALUES (100, 2014);
INSERT INTO `sys_role_menu` VALUES (100, 2015);
INSERT INTO `sys_role_menu` VALUES (100, 2016);
INSERT INTO `sys_role_menu` VALUES (100, 2017);
INSERT INTO `sys_role_menu` VALUES (100, 2018);
INSERT INTO `sys_role_menu` VALUES (100, 2019);
INSERT INTO `sys_role_menu` VALUES (100, 2020);
INSERT INTO `sys_role_menu` VALUES (100, 2021);
INSERT INTO `sys_role_menu` VALUES (100, 2022);
INSERT INTO `sys_role_menu` VALUES (100, 2023);
INSERT INTO `sys_role_menu` VALUES (100, 2024);
INSERT INTO `sys_role_menu` VALUES (100, 2025);
INSERT INTO `sys_role_menu` VALUES (100, 2026);
INSERT INTO `sys_role_menu` VALUES (100, 2027);
INSERT INTO `sys_role_menu` VALUES (100, 2028);
INSERT INTO `sys_role_menu` VALUES (100, 2029);
INSERT INTO `sys_role_menu` VALUES (100, 2030);
INSERT INTO `sys_role_menu` VALUES (100, 2031);
INSERT INTO `sys_role_menu` VALUES (100, 2032);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户昵称',
  `user_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '00' COMMENT '用户类型（00系统用户）',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '手机号码',
  `sex` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '密码',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '账号状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `pwd_update_date` datetime NULL DEFAULT NULL COMMENT '密码最后更新时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 103, 'admin', '若依', '00', 'ry@163.com', '15888888888', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2025-08-10 23:47:53', '2025-07-15 16:08:15', 'admin', '2025-07-15 16:08:15', '', '2025-08-10 23:47:52', '管理员');
INSERT INTO `sys_user` VALUES (2, 105, 'ry', '若依', '00', 'ry@qq.com', '15666666666', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2025-08-10 23:48:31', '2025-07-15 16:08:15', 'admin', '2025-07-15 16:08:15', '', '2025-08-10 23:48:30', '测试员');

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE `sys_user_post`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `post_id` bigint NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`, `post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户与岗位关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_post
-- ----------------------------
INSERT INTO `sys_user_post` VALUES (1, 1);
INSERT INTO `sys_user_post` VALUES (2, 2);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户和角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);
INSERT INTO `sys_user_role` VALUES (2, 100);

-- ----------------------------
-- Table structure for teacher_login_log
-- ----------------------------
DROP TABLE IF EXISTS `teacher_login_log`;
CREATE TABLE `teacher_login_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `teacher_id` bigint NOT NULL,
  `login_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_time`(`login_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 122 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of teacher_login_log
-- ----------------------------
INSERT INTO `teacher_login_log` VALUES (1, 1, '2025-08-09 08:30:00');
INSERT INTO `teacher_login_log` VALUES (2, 1, '2025-08-09 14:15:00');
INSERT INTO `teacher_login_log` VALUES (3, 2, '2025-08-09 09:45:00');
INSERT INTO `teacher_login_log` VALUES (4, 2, '2025-08-09 15:20:00');
INSERT INTO `teacher_login_log` VALUES (5, 3, '2025-08-09 10:10:00');
INSERT INTO `teacher_login_log` VALUES (6, 1, '2025-08-09 16:30:00');
INSERT INTO `teacher_login_log` VALUES (7, 1, '2025-08-08 09:00:00');
INSERT INTO `teacher_login_log` VALUES (8, 2, '2025-08-08 10:30:00');
INSERT INTO `teacher_login_log` VALUES (9, 1, '2025-08-07 08:45:00');
INSERT INTO `teacher_login_log` VALUES (10, 3, '2025-08-07 11:15:00');
INSERT INTO `teacher_login_log` VALUES (11, 2, '2025-08-06 09:30:00');
INSERT INTO `teacher_login_log` VALUES (12, 1, '2025-08-05 14:00:00');
INSERT INTO `teacher_login_log` VALUES (13, 3, '2025-08-04 10:45:00');
INSERT INTO `teacher_login_log` VALUES (14, 2, '2025-08-09 20:45:25');
INSERT INTO `teacher_login_log` VALUES (15, 2, '2025-08-10 11:36:01');
INSERT INTO `teacher_login_log` VALUES (16, 2, '2025-08-10 11:36:27');
INSERT INTO `teacher_login_log` VALUES (17, 2, '2025-08-10 11:42:28');
INSERT INTO `teacher_login_log` VALUES (18, 2, '2025-08-10 12:29:40');
INSERT INTO `teacher_login_log` VALUES (19, 2, '2025-08-10 16:54:18');
INSERT INTO `teacher_login_log` VALUES (20, 2, '2025-08-10 21:30:53');
INSERT INTO `teacher_login_log` VALUES (21, 2, '2025-08-10 22:00:53');
INSERT INTO `teacher_login_log` VALUES (22, 2, '2025-08-10 22:06:21');
INSERT INTO `teacher_login_log` VALUES (23, 2, '2025-08-10 22:18:25');
INSERT INTO `teacher_login_log` VALUES (24, 2, '2025-08-10 22:56:13');
INSERT INTO `teacher_login_log` VALUES (25, 2, '2025-08-10 23:01:55');
INSERT INTO `teacher_login_log` VALUES (26, 2, '2025-08-17 17:13:54');
INSERT INTO `teacher_login_log` VALUES (27, 2, '2025-08-18 12:56:52');
INSERT INTO `teacher_login_log` VALUES (28, 2, '2025-08-18 12:56:52');
INSERT INTO `teacher_login_log` VALUES (29, 2, '2025-08-20 18:03:44');
INSERT INTO `teacher_login_log` VALUES (30, 2, '2025-08-21 17:17:56');
INSERT INTO `teacher_login_log` VALUES (31, 2, '2025-08-21 18:22:56');
INSERT INTO `teacher_login_log` VALUES (32, 2, '2025-08-21 18:52:59');
INSERT INTO `teacher_login_log` VALUES (33, 2, '2025-08-21 19:07:25');
INSERT INTO `teacher_login_log` VALUES (34, 2, '2025-08-22 11:47:30');
INSERT INTO `teacher_login_log` VALUES (35, 2, '2025-08-22 13:37:15');
INSERT INTO `teacher_login_log` VALUES (36, 2, '2025-08-22 15:55:43');
INSERT INTO `teacher_login_log` VALUES (37, 2, '2025-08-22 18:40:47');
INSERT INTO `teacher_login_log` VALUES (38, 2, '2025-08-23 22:56:45');
INSERT INTO `teacher_login_log` VALUES (39, 2, '2025-08-23 23:12:55');
INSERT INTO `teacher_login_log` VALUES (40, 2, '2025-08-26 13:54:29');
INSERT INTO `teacher_login_log` VALUES (41, 2, '2025-08-26 16:50:41');
INSERT INTO `teacher_login_log` VALUES (42, 2, '2025-08-26 16:50:47');
INSERT INTO `teacher_login_log` VALUES (43, 2, '2025-08-26 16:50:47');
INSERT INTO `teacher_login_log` VALUES (44, 2, '2025-08-26 16:50:47');
INSERT INTO `teacher_login_log` VALUES (45, 2, '2025-08-26 16:50:48');
INSERT INTO `teacher_login_log` VALUES (46, 2, '2025-08-26 16:59:21');
INSERT INTO `teacher_login_log` VALUES (47, 2, '2025-08-27 11:19:29');
INSERT INTO `teacher_login_log` VALUES (48, 2, '2025-08-27 15:04:11');
INSERT INTO `teacher_login_log` VALUES (49, 2, '2025-08-28 16:13:33');
INSERT INTO `teacher_login_log` VALUES (50, 2, '2025-08-28 23:56:46');
INSERT INTO `teacher_login_log` VALUES (51, 2, '2025-08-29 11:58:53');
INSERT INTO `teacher_login_log` VALUES (52, 2, '2025-08-29 15:17:58');
INSERT INTO `teacher_login_log` VALUES (53, 2, '2025-08-29 16:02:01');
INSERT INTO `teacher_login_log` VALUES (54, 2, '2025-08-29 16:34:06');
INSERT INTO `teacher_login_log` VALUES (55, 2, '2025-08-29 16:34:20');
INSERT INTO `teacher_login_log` VALUES (56, 2, '2025-08-29 16:45:39');
INSERT INTO `teacher_login_log` VALUES (57, 2, '2025-08-29 23:59:03');
INSERT INTO `teacher_login_log` VALUES (58, 2, '2025-08-30 19:51:40');
INSERT INTO `teacher_login_log` VALUES (59, 2, '2025-08-30 20:18:03');
INSERT INTO `teacher_login_log` VALUES (60, 2, '2025-08-31 15:02:09');
INSERT INTO `teacher_login_log` VALUES (61, 2, '2025-08-31 18:51:50');
INSERT INTO `teacher_login_log` VALUES (62, 2, '2025-08-31 20:53:36');
INSERT INTO `teacher_login_log` VALUES (63, 2, '2025-08-31 21:02:36');
INSERT INTO `teacher_login_log` VALUES (64, 2, '2025-08-31 21:11:51');
INSERT INTO `teacher_login_log` VALUES (65, 2, '2025-08-31 21:20:52');
INSERT INTO `teacher_login_log` VALUES (66, 2, '2025-08-31 21:21:14');
INSERT INTO `teacher_login_log` VALUES (67, 2, '2025-09-01 13:56:11');
INSERT INTO `teacher_login_log` VALUES (68, 2, '2025-09-01 15:04:53');
INSERT INTO `teacher_login_log` VALUES (69, 2, '2025-09-01 16:28:54');
INSERT INTO `teacher_login_log` VALUES (70, 2, '2025-09-01 18:48:49');
INSERT INTO `teacher_login_log` VALUES (71, 2, '2025-09-01 20:32:35');
INSERT INTO `teacher_login_log` VALUES (72, 2, '2025-09-02 10:31:51');
INSERT INTO `teacher_login_log` VALUES (73, 2, '2025-09-02 19:42:38');
INSERT INTO `teacher_login_log` VALUES (74, 2, '2025-09-03 18:56:34');
INSERT INTO `teacher_login_log` VALUES (75, 2, '2025-09-04 10:28:44');
INSERT INTO `teacher_login_log` VALUES (76, 2, '2025-09-08 12:04:09');
INSERT INTO `teacher_login_log` VALUES (77, 2, '2025-09-09 14:37:41');
INSERT INTO `teacher_login_log` VALUES (78, 2, '2025-09-09 15:31:43');
INSERT INTO `teacher_login_log` VALUES (79, 2, '2025-09-10 10:06:56');
INSERT INTO `teacher_login_log` VALUES (80, 2, '2025-09-10 11:39:44');
INSERT INTO `teacher_login_log` VALUES (81, 2, '2025-09-10 17:53:41');
INSERT INTO `teacher_login_log` VALUES (82, 2, '2025-09-10 18:19:40');
INSERT INTO `teacher_login_log` VALUES (83, 2, '2025-09-10 18:27:06');
INSERT INTO `teacher_login_log` VALUES (84, 2, '2025-09-11 07:59:23');
INSERT INTO `teacher_login_log` VALUES (85, 2, '2025-09-11 10:01:05');
INSERT INTO `teacher_login_log` VALUES (86, 2, '2025-09-11 13:03:49');
INSERT INTO `teacher_login_log` VALUES (87, 2, '2025-09-11 16:13:58');
INSERT INTO `teacher_login_log` VALUES (88, 2, '2025-09-12 14:12:43');
INSERT INTO `teacher_login_log` VALUES (89, 2, '2025-09-13 00:06:37');
INSERT INTO `teacher_login_log` VALUES (90, 2, '2025-09-13 09:40:51');
INSERT INTO `teacher_login_log` VALUES (91, 2, '2025-09-13 14:01:17');
INSERT INTO `teacher_login_log` VALUES (92, 2, '2025-09-13 16:05:25');
INSERT INTO `teacher_login_log` VALUES (93, 2, '2025-09-13 16:07:12');
INSERT INTO `teacher_login_log` VALUES (94, 2, '2025-09-13 16:08:18');
INSERT INTO `teacher_login_log` VALUES (95, 2, '2025-09-13 16:08:43');
INSERT INTO `teacher_login_log` VALUES (96, 2, '2025-09-13 16:09:25');
INSERT INTO `teacher_login_log` VALUES (97, 2, '2025-09-13 16:14:01');
INSERT INTO `teacher_login_log` VALUES (98, 2, '2025-09-13 17:25:45');
INSERT INTO `teacher_login_log` VALUES (99, 2, '2025-09-14 12:38:36');
INSERT INTO `teacher_login_log` VALUES (100, 2, '2025-09-14 14:48:39');
INSERT INTO `teacher_login_log` VALUES (101, 2, '2025-09-14 15:27:54');
INSERT INTO `teacher_login_log` VALUES (102, 2, '2025-09-14 18:53:56');
INSERT INTO `teacher_login_log` VALUES (103, 2, '2025-09-15 20:11:33');
INSERT INTO `teacher_login_log` VALUES (104, 2, '2025-09-16 11:07:50');
INSERT INTO `teacher_login_log` VALUES (105, 2, '2025-09-16 15:35:49');
INSERT INTO `teacher_login_log` VALUES (106, 2, '2025-09-16 17:11:36');
INSERT INTO `teacher_login_log` VALUES (107, 2, '2025-09-16 21:17:47');
INSERT INTO `teacher_login_log` VALUES (108, 2, '2025-09-16 23:15:03');
INSERT INTO `teacher_login_log` VALUES (109, 2, '2025-09-16 23:17:12');
INSERT INTO `teacher_login_log` VALUES (110, 2, '2025-09-17 14:26:32');
INSERT INTO `teacher_login_log` VALUES (111, 2, '2025-09-17 14:42:50');
INSERT INTO `teacher_login_log` VALUES (112, 2, '2025-09-17 19:11:22');
INSERT INTO `teacher_login_log` VALUES (113, 2, '2025-09-17 21:02:59');
INSERT INTO `teacher_login_log` VALUES (114, 2, '2025-09-18 09:54:47');
INSERT INTO `teacher_login_log` VALUES (115, 12, '2025-09-18 10:15:15');
INSERT INTO `teacher_login_log` VALUES (116, 2, '2025-09-18 10:16:29');
INSERT INTO `teacher_login_log` VALUES (117, 2, '2025-09-18 15:02:28');
INSERT INTO `teacher_login_log` VALUES (118, 2, '2025-09-18 16:02:24');
INSERT INTO `teacher_login_log` VALUES (119, 2, '2025-09-19 19:16:08');
INSERT INTO `teacher_login_log` VALUES (120, 2, '2025-09-19 20:04:54');
INSERT INTO `teacher_login_log` VALUES (121, 2, '2025-09-19 22:01:22');
INSERT INTO `teacher_login_log` VALUES (122, 2, '2025-09-19 22:11:44');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `role` enum('admin','teacher','student') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login` datetime NULL DEFAULT NULL,
  `sex` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `class` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `school` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `avatar_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL(阿里云OSS)',
  `study_score` int NULL DEFAULT 0 COMMENT '学习积分（练习次数*4 + 登录天数*2 + 连续登录奖励）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  INDEX `idx_study_score`(`study_score` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'lilei', '123456', 'student', '张政', '2289749024', '2025-07-12 00:00:00', '2025-08-30 20:19:48', '男', '软件234', '家里蹲大学', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/30adab86-8619-4ee8-a1a8-cda477791f0b-20190926141024_uleti.jpg', 154);
INSERT INTO `user` VALUES (2, 'hanmeimei', '123456', 'teacher', '张磊', '2289749024', '2025-07-12 00:00:00', '2025-08-30 20:19:52', '男', NULL, '家里蹲大学', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/eabea5d7-ba89-40bd-9488-84812d32440f-2232.jpg_wh300.jpg', 45);
INSERT INTO `user` VALUES (3, 'liangbenhua', '123456', 'student', '梁本华', '2289749024', '2025-07-15 00:00:00', '2025-08-30 20:20:08', '男', '软件234', '家里蹲大学', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/7a6f34ab-f425-4791-bde5-c9dc23e9674c-OIP-C.webp', 6);
INSERT INTO `user` VALUES (4, 'ry', 'admin123', 'admin', '若依', '2289749024', '2025-07-16 00:00:00', NULL, '男', NULL, NULL, NULL, 0);
INSERT INTO `user` VALUES (9, '山治123', '123456', 'student', '小贝', '2289749024@qq.com', '2025-08-27 13:48:12', NULL, '男', '软件234', NULL, 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/c4f18d55-bfbc-4499-92ea-7ca0be7fef37-20200202160442_P3hVe.jpeg', 10);
INSERT INTO `user` VALUES (10, '小蛇123', '123456', 'student', '云金蛇', '19563497993@qq.com', '2025-09-16 16:37:34', NULL, '女', '软件234', '家里蹲大学', 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/ac8c4277-93c8-46a5-8f94-9277b26c1058-%E7%BB%98%E5%88%B6%E5%8D%A1%E9%80%9A%E7%94%BB.png', 2);
INSERT INTO `user` VALUES (11, 'zipi', '123456', 'student', '紫皮', '18993728974@qq.com', '2025-09-16 17:08:48', NULL, '男', '软件234', '家里蹲大学', NULL, 2);
INSERT INTO `user` VALUES (12, 'jjj', '123456', 'teacher', '王刚', 'chenxij_jhy@163.com', '2025-09-18 10:15:04', NULL, '男', NULL, '家里蹲大学', NULL, 0);

SET FOREIGN_KEY_CHECKS = 1;


