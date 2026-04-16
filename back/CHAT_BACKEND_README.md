# 聊天记录后端功能实现

## 概述

本文档说明如何在SpringBoot后端中实现聊天记录的持久化功能，包括保存、查询、统计和删除聊天消息。

## 功能特性

- ✅ 支持多种消息类型：文本、表情包、图片、文件、语音
- ✅ 按课程隔离聊天记录
- ✅ 分页查询聊天历史
- ✅ 聊天统计功能
- ✅ 消息删除功能
- ✅ 完整的错误处理和日志记录

## 文件结构

```
src/main/java/com/atguigu/java/ai/langchain4j/
├── entity/
│   ├── CourseChatLog.java          # 聊天记录实体类
│   ├── ChatMessageRequest.java     # 聊天消息请求DTO
│   └── ChatMessageResponse.java    # 聊天消息响应DTO
├── mapper/
│   └── CourseChatLogMapper.java    # 数据访问层接口
├── service/
│   ├── CourseChatLogService.java   # 业务逻辑接口
│   └── Impl/
│       └── CourseChatLogServiceImpl.java  # 业务逻辑实现
├── controller/
│   └── ChatController.java         # REST API控制器
└── resources/mapper/
    └── CourseChatLogMapper.xml     # MyBatis映射文件
```

## API接口

### 1. 保存聊天消息

**POST** `/api/chat/save`

**请求体：**
```json
{
  "courseId": 1,
  "senderName": "张老师",
  "messageType": "text",
  "messageContent": "大家好！",
  "fileName": null,
  "fileSize": null,
  "duration": null,
  "sentAt": "2024-01-01T10:00:00"
}
```

**响应：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": 123
}
```

### 2. 获取聊天记录

**GET** `/api/chat/history?courseId=1&limit=50&offset=0`

**响应：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "id": 123,
      "senderName": "张老师",
      "message": "大家好！",
      "messageType": "text",
      "fileName": null,
      "fileSize": null,
      "duration": null,
      "sentAt": "2024-01-01T10:00:00"
    }
  ]
}
```

### 3. 获取聊天统计

**GET** `/api/chat/stats/1`

**响应：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "totalMessages": 100,
    "uniqueSenders": 15,
    "firstMessageTime": "2024-01-01 09:00:00",
    "lastMessageTime": "2024-01-01 10:00:00"
  }
}
```

### 4. 删除聊天消息

**DELETE** `/api/chat/delete/123`

**响应：**
```json
{
  "code": 200,
  "message": "聊天消息删除成功",
  "data": null
}
```

## 数据库表结构

确保 `course_chat_log` 表已经扩展了以下字段：

```sql
ALTER TABLE `course_chat_log` 
ADD COLUMN `message_type` varchar(20) NOT NULL DEFAULT 'text' COMMENT '消息类型',
ADD COLUMN `file_name` varchar(255) NULL COMMENT '文件名',
ADD COLUMN `file_size` bigint NULL COMMENT '文件大小(字节)',
ADD COLUMN `duration` int NULL COMMENT '语音时长(秒)',
ADD COLUMN `sender_name` varchar(100) NOT NULL COMMENT '发送者姓名';
```

## 部署步骤

### 1. 数据库更新

执行数据库表结构更新脚本：

```bash
# 在MySQL中执行
mysql -u your_username -p xiaozhi < chat_table_update.sql
```

### 2. 插入测试数据

```bash
# 插入测试数据
mysql -u your_username -p xiaozhi < test_chat_data.sql
```

### 3. 启动应用

```bash
# 在项目根目录执行
mvn spring-boot:run
```

### 4. 测试API

使用Postman或curl测试API接口：

```bash
# 测试保存聊天消息
curl -X POST http://localhost:8080/api/chat/save \
  -H "Content-Type: application/json" \
  -d '{
    "courseId": 1,
    "senderName": "测试用户",
    "messageType": "text",
    "messageContent": "测试消息"
  }'

# 测试获取聊天记录
curl http://localhost:8080/api/chat/history?courseId=1&limit=10

# 测试获取聊天统计
curl http://localhost:8080/api/chat/stats/1
```

## 消息类型说明

### 1. 文本消息 (text)
- `messageType`: "text"
- `messageContent`: 文本内容
- 其他字段: null

### 2. 表情包消息 (sticker)
- `messageType`: "sticker"
- `messageContent`: 表情包图片URL
- 其他字段: null

### 3. 图片消息 (image)
- `messageType`: "image"
- `messageContent`: 图片URL
- `fileName`: 文件名
- `fileSize`: 文件大小
- `duration`: null

### 4. 文件消息 (file)
- `messageType`: "file"
- `messageContent`: 文件URL
- `fileName`: 文件名
- `fileSize`: 文件大小
- `duration`: null

### 5. 语音消息 (voice)
- `messageType`: "voice"
- `messageContent`: 语音文件URL
- `fileName`: null
- `fileSize`: null
- `duration`: 语音时长(秒)

## 前端集成

前端已经更新了相应的API调用代码，确保：

1. 发送消息时调用 `/api/chat/save` 接口
2. 页面加载时调用 `/api/chat/history` 接口
3. 正确处理API响应格式

## 性能优化

### 1. 数据库索引
```sql
-- 添加复合索引提高查询性能
CREATE INDEX `idx_course_sent_at` ON `course_chat_log` (`course_id`, `sent_at` DESC);
CREATE INDEX `idx_message_type` ON `course_chat_log` (`message_type`);
```

### 2. 分页查询
- 默认每页50条记录
- 支持offset分页
- 按时间倒序排列

### 3. 缓存策略
- 可以考虑使用Redis缓存热门课程的聊天记录
- 实现聊天记录的增量更新

## 注意事项

1. **文件存储**: 语音、图片、文件等需要上传到文件服务器，数据库中只存储URL
2. **权限控制**: 确保只有课程参与者可以查看和发送消息
3. **数据清理**: 定期清理过期的聊天记录，避免数据库过大
4. **备份策略**: 定期备份聊天记录数据
5. **隐私保护**: 注意用户隐私保护，遵守相关法律法规

## 错误处理

所有API都包含完整的错误处理：

- 参数验证错误
- 数据库操作错误
- 系统异常处理
- 详细的错误日志记录

## 日志记录

使用SLF4J进行日志记录，包括：

- API请求日志
- 业务操作日志
- 错误异常日志
- 性能监控日志

## 测试

1. 单元测试：测试Service层业务逻辑
2. 集成测试：测试API接口功能
3. 性能测试：测试大量数据的处理能力
4. 压力测试：测试并发访问性能
