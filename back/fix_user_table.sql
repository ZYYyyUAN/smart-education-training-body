-- Fix user table schema mismatch
-- Add missing 'sex' column to user table

USE xiaozhi;

-- Add the missing sex column to the user table
ALTER TABLE `user` 
ADD COLUMN IF NOT EXISTS `sex` VARCHAR(10) DEFAULT NULL COMMENT '性别' AFTER `last_login`;

-- Show the updated table structure
DESCRIBE `user`;

-- Optional: Update existing records with default values if needed
-- UPDATE `user` SET `sex` = '未设置' WHERE `sex` IS NULL;

SELECT 'User table schema fix completed successfully!' as message;
