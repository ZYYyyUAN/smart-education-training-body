-- 创建考试结果表
CREATE TABLE IF NOT EXISTS `exam_result` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `exam_id` bigint NOT NULL COMMENT '考试ID',
  `student_id` bigint NOT NULL COMMENT '学生ID',
  `total_questions` int NOT NULL COMMENT '总题数',
  `correct_answers` int NOT NULL COMMENT '正确题数',
  `wrong_answers` int NOT NULL COMMENT '错误题数',
  `score` decimal(5,2) NOT NULL COMMENT '得分',
  `status` varchar(20) NOT NULL DEFAULT 'submitted' COMMENT '状态：submitted-已提交，graded-已批阅，reviewed-已审核',
  `ai_feedback` text COMMENT 'AI批阅反馈',
  `submitted_at` datetime NOT NULL COMMENT '提交时间',
  `graded_at` datetime COMMENT '批阅时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_exam_id` (`exam_id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_submitted_at` (`submitted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='考试结果表';

-- 创建考试答案表
CREATE TABLE IF NOT EXISTS `exam_answer` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `exam_result_id` bigint NOT NULL COMMENT '考试结果ID',
  `question_id` bigint NOT NULL COMMENT '题目ID',
  `student_answer` text COMMENT '学生答案',
  `correct_answer` text COMMENT '正确答案',
  `is_correct` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否正确',
  `score` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '得分',
  `ai_feedback` text COMMENT 'AI对这道题的批阅反馈',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_exam_result_id` (`exam_result_id`),
  KEY `idx_question_id` (`question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='考试答案表';
