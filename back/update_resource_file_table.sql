/*
 更新 resource_file 表结构
 添加缺失的字段：download_count 和 is_ingested
  
 使用方法：
 1. 如果字段已存在，会报错但可以忽略（字段已存在）
 2. 如果字段不存在，会成功添加
 3. 执行后请检查是否有错误，如果只是"字段已存在"的错误可以忽略
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 为 resource_file 表添加缺失的字段
-- ----------------------------

-- 添加 download_count 字段（下载次数）
-- 如果字段已存在，会报错，但可以忽略
ALTER TABLE `resource_file` 
ADD COLUMN `download_count` int NULL DEFAULT 0 COMMENT '下载次数' AFTER `uploaded_at`;

-- 添加 is_ingested 字段（是否已入库）
-- 如果字段已存在，会报错，但可以忽略
ALTER TABLE `resource_file` 
ADD COLUMN `is_ingested` tinyint(1) NULL DEFAULT 0 COMMENT '是否已入库（0-未入库，1-已入库）' AFTER `download_count`;

-- 更新现有数据的默认值
UPDATE `resource_file` SET `download_count` = 0 WHERE `download_count` IS NULL;
UPDATE `resource_file` SET `is_ingested` = 0 WHERE `is_ingested` IS NULL;

SET FOREIGN_KEY_CHECKS = 1;
