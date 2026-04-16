/*
 Navicat Premium Data Transfer
 Date: 05/01/2026
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for sys_class
-- ----------------------------
DROP TABLE IF EXISTS `sys_class`;
CREATE TABLE `sys_class` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '班级名称',
  `teacher_id` bigint NULL DEFAULT NULL COMMENT '班主任ID',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Data transfer for sys_class (from user.class)
-- ----------------------------
INSERT IGNORE INTO `sys_class` (`name`)
SELECT DISTINCT `class` FROM `user` WHERE `class` IS NOT NULL AND `class` != '';

-- ----------------------------
-- Update user table structure
-- ----------------------------
-- Check if class_id exists (simplified: just try add and ignore error if strict mode off, or assume it doesn't exist)
-- For this environment, I will use a procedure or just direct ALTER assuming it's not there.
-- Given I can't run complex procedures easily, I will just run ALTER. If it fails it might be because it exists.
ALTER TABLE `user` ADD COLUMN `class_id` bigint NULL DEFAULT NULL COMMENT '班级ID' AFTER `class`;

-- ----------------------------
-- Update user.class_id based on user.class
-- ----------------------------
UPDATE `user` u
JOIN `sys_class` c ON u.class = c.name
SET u.class_id = c.id
WHERE u.class_id IS NULL;

SET FOREIGN_KEY_CHECKS = 1;
