/*
 Navicat Premium Data Transfer
 Date: 05/01/2026
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
  INDEX `student_id`(`student_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
-- Import Data (Enriched for demo)
-- ----------------------------
-- Student 1
INSERT INTO `student_login_log` (`student_id`, `login_time`) VALUES (1, NOW() - INTERVAL 1 DAY), (1, NOW() - INTERVAL 2 DAY), (1, NOW() - INTERVAL 3 DAY);
INSERT INTO `assignment_submission` (`assignment_id`, `student_id`, `submitted_at`, `score`) VALUES (43, 1, NOW() - INTERVAL 5 DAY, 85), (44, 1, NOW() - INTERVAL 2 DAY, 92);
INSERT INTO `exam_submission` (`exam_id`, `student_id`, `submitted_at`, `score`) VALUES (1, 1, NOW() - INTERVAL 10 DAY, 88);

-- Student 2
INSERT INTO `student_login_log` (`student_id`, `login_time`) VALUES (2, NOW()), (2, NOW() - INTERVAL 1 DAY);
INSERT INTO `assignment_submission` (`assignment_id`, `student_id`, `submitted_at`, `score`) VALUES (43, 2, NOW() - INTERVAL 4 DAY, 76);

-- Student 3
INSERT INTO `student_login_log` (`student_id`, `login_time`) VALUES (3, NOW() - INTERVAL 5 DAY);
INSERT INTO `exam_submission` (`exam_id`, `student_id`, `submitted_at`, `score`) VALUES (1, 3, NOW() - INTERVAL 10 DAY, 95);

SET FOREIGN_KEY_CHECKS = 1;
