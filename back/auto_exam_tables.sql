-- 自动组卷系统数据库表结构
-- 基于现有xiaozhi数据库扩展

-- 1. 自动组卷配置表
CREATE TABLE `auto_exam_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_id` bigint NOT NULL,
  `teacher_id` bigint NOT NULL,
  `config_name` varchar(100) NOT NULL COMMENT '配置名称',
  `total_questions` int NOT NULL COMMENT '总题数',
  `question_distribution` json NOT NULL COMMENT '题型分布配置',
  `difficulty_distribution` json NOT NULL COMMENT '难度分布配置',
  `knowledge_point_weights` json NOT NULL COMMENT '知识点权重配置',
  `time_limit_minutes` int DEFAULT 120 COMMENT '考试时长',
  `ai_prompt_template` text COMMENT 'AI提示词模板',
  `is_active` tinyint(1) DEFAULT 1 COMMENT '是否启用',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_course_teacher` (`course_id`, `teacher_id`),
  CONSTRAINT `auto_exam_config_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auto_exam_config_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='自动组卷配置表';

-- 2. 自动生成的试卷表
CREATE TABLE `auto_generated_exam` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `config_id` bigint NOT NULL,
  `exam_title` varchar(200) NOT NULL,
  `exam_description` text,
  `generation_strategy` varchar(50) NOT NULL COMMENT '生成策略',
  `ai_model_used` varchar(50) NOT NULL COMMENT '使用的AI模型',
  `generation_prompt` text COMMENT '生成时使用的提示词',
  `generation_metadata` json COMMENT '生成元数据',
  `quality_score` decimal(3,2) COMMENT '试卷质量评分',
  `status` enum('draft','generated','reviewed','published','archived') DEFAULT 'draft',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` datetime,
  `published_at` datetime,
  `created_by` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_config` (`config_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `auto_generated_exam_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `auto_exam_config` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auto_generated_exam_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='自动生成试卷表';

-- 3. 试卷题目关联表
CREATE TABLE `auto_exam_question` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `exam_id` bigint NOT NULL,
  `question_bank_id` bigint NOT NULL,
  `question_order` int NOT NULL COMMENT '题目顺序',
  `section_type` varchar(50) COMMENT '题目分组',
  `difficulty_level` int COMMENT '难度等级',
  `knowledge_point_id` bigint COMMENT '关联知识点',
  `ai_selection_reason` text COMMENT 'AI选择该题的原因',
  `estimated_time_minutes` int COMMENT '预估答题时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_exam` (`exam_id`),
  KEY `idx_question` (`question_bank_id`),
  KEY `idx_knowledge_point` (`knowledge_point_id`),
  UNIQUE KEY `uk_exam_question` (`exam_id`, `question_bank_id`),
  CONSTRAINT `auto_exam_question_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `auto_generated_exam` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `auto_exam_question_ibfk_2` FOREIGN KEY (`question_bank_id`) REFERENCES `question_bank` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auto_exam_question_ibfk_3` FOREIGN KEY (`knowledge_point_id`) REFERENCES `knowledge_point` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='试卷题目关联表';

-- 4. 组卷历史记录表
CREATE TABLE `exam_generation_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `config_id` bigint NOT NULL,
  `generation_type` varchar(50) NOT NULL COMMENT '生成类型',
  `request_params` json NOT NULL COMMENT '请求参数',
  `ai_response` text COMMENT 'AI响应内容',
  `generation_time_ms` int COMMENT '生成耗时(毫秒)',
  `success` tinyint(1) DEFAULT 1,
  `error_message` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `created_by` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_config` (`config_id`),
  KEY `idx_created` (`created_at`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `exam_generation_log_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `auto_exam_config` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `exam_generation_log_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='组卷历史记录表';

-- 5. 试卷质量评估表
CREATE TABLE `exam_quality_assessment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `exam_id` bigint NOT NULL,
  `overall_score` decimal(3,2) NOT NULL COMMENT '总体评分',
  `difficulty_balance` decimal(3,2) COMMENT '难度平衡性',
  `knowledge_coverage` decimal(3,2) COMMENT '知识点覆盖率',
  `time_distribution` decimal(3,2) COMMENT '时间分布合理性',
  `question_diversity` decimal(3,2) COMMENT '题目多样性',
  `assessment_details` json COMMENT '详细评估数据',
  `assessed_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `assessed_by` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_exam` (`exam_id`),
  KEY `idx_assessed_by` (`assessed_by`),
  CONSTRAINT `exam_quality_assessment_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `auto_generated_exam` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `exam_quality_assessment_ibfk_2` FOREIGN KEY (`assessed_by`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='试卷质量评估表';

-- 插入一些示例配置数据
INSERT INTO `auto_exam_config` (`course_id`, `teacher_id`, `config_name`, `total_questions`, `question_distribution`, `difficulty_distribution`, `knowledge_point_weights`, `time_limit_minutes`) VALUES
(101, 1, '嵌入式系统基础测试', 20, '{"choice": 10, "short_answer": 7, "programming": 3}', '{"easy": 0.2, "medium": 0.5, "hard": 0.3}', '{"1": 0.3, "2": 0.2, "3": 0.2, "4": 0.1, "5": 0.1, "6": 0.1}', 90),
(101, 1, '嵌入式系统综合测试', 30, '{"choice": 15, "short_answer": 10, "programming": 5}', '{"easy": 0.1, "medium": 0.4, "hard": 0.5}', '{"1": 0.2, "2": 0.2, "3": 0.2, "4": 0.15, "5": 0.15, "6": 0.1}', 120);

-- 6. 题库分类表
CREATE TABLE `question_bank_category` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT '分类名称',
  `description` text COMMENT '分类描述',
  `color` varchar(20) COMMENT '分类颜色',
  `icon` varchar(50) COMMENT '分类图标',
  `sort_order` int DEFAULT 0 COMMENT '排序',
  `is_active` tinyint(1) DEFAULT 1 COMMENT '是否启用',
  `created_by` bigint COMMENT '创建人',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='题库分类表';

-- 7. 为question_bank表添加新字段
ALTER TABLE `question_bank` 
ADD COLUMN `difficulty_level` varchar(20) DEFAULT 'medium' COMMENT '难度等级: easy, medium, hard' AFTER `knowledge_point`,
ADD COLUMN `category_id` bigint COMMENT '题库分类ID' AFTER `difficulty_level`,
ADD COLUMN `estimated_time_minutes` int COMMENT '预估答题时间(分钟)' AFTER `category_id`,
ADD COLUMN `tags` varchar(500) COMMENT '题目标签，用逗号分隔' AFTER `estimated_time_minutes`,
ADD COLUMN `is_ai_generated` tinyint(1) DEFAULT 0 COMMENT '是否AI生成' AFTER `tags`,
ADD COLUMN `generation_prompt` text COMMENT 'AI生成提示词' AFTER `is_ai_generated`,
ADD COLUMN `quality_score` decimal(5,2) COMMENT '题目质量评分' AFTER `generation_prompt`,
ADD INDEX `idx_difficulty` (`difficulty_level`),
ADD INDEX `idx_category` (`category_id`),
ADD INDEX `idx_ai_generated` (`is_ai_generated`),
ADD CONSTRAINT `question_bank_ibfk_category` FOREIGN KEY (`category_id`) REFERENCES `question_bank_category` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT;

-- 8. 插入默认题库分类
INSERT INTO `question_bank_category` (`name`, `description`, `color`, `icon`, `sort_order`, `created_by`) VALUES
('基础题库', '基础知识点题目', '#409EFF', 'el-icon-document', 1, 1),
('进阶题库', '进阶知识点题目', '#67C23A', 'el-icon-star', 2, 1),
('综合题库', '综合应用题目', '#E6A23C', 'el-icon-trophy', 3, 1),
('模拟题库', '模拟考试题目', '#F56C6C', 'el-icon-medal', 4, 1),
('AI生成题库', 'AI自动生成题目', '#909399', 'el-icon-magic-stick', 5, 1);
