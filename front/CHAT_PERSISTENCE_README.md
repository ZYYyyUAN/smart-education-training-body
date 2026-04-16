# 聊天记录持久化实现指南

## 概述

本文档说明如何实现聊天记录的持久化保存，将聊天消息存储到数据库中，支持不同类型的消息（文本、表情包、图片、文件、语音）。

## 数据库表结构

### 扩展 course_chat_log 表

执行 `chat_table_update.sql` 脚本来扩展现有的 `course_chat_log` 表：

```sql
ALTER TABLE `course_chat_log` 
ADD COLUMN `message_type` varchar(20) NOT NULL DEFAULT 'text' COMMENT '消息类型',
ADD COLUMN `file_name` varchar(255) NULL COMMENT '文件名',
ADD COLUMN `file_size` bigint NULL COMMENT '文件大小(字节)',
ADD COLUMN `duration` int NULL COMMENT '语音时长(秒)',
ADD COLUMN `sender_name` varchar(100) NOT NULL COMMENT '发送者姓名';
```

### 表字段说明

- `id`: 主键
- `course_id`: 课程ID（外键关联course表）
- `sender_id`: 发送者ID（外键关联user表）
- `sender_name`: 发送者姓名
- `message`: 消息内容
- `message_type`: 消息类型（text/sticker/image/file/voice）
- `file_name`: 文件名（用于文件和图片）
- `file_size`: 文件大小（字节）
- `duration`: 语音时长（秒）
- `sent_at`: 发送时间

## 前端实现

### 1. 保存聊天记录

在 `WeChatGroupChat.vue` 中已经添加了 `saveChatMessage` 函数：

```javascript
const saveChatMessage = async (message) => {
  try {
    const chatData = {
      courseId: props.courseId,
      senderName: message.sender,
      messageType: message.type || 'text',
      messageContent: message.content,
      fileName: message.fileName || null,
      fileSize: message.fileSize || null,
      duration: message.duration || null,
      sentAt: message.timestamp
    }

    const response = await fetch('/api/chat/save', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(chatData)
    })

    if (!response.ok) {
      throw new Error('保存聊天记录失败')
    }
  } catch (error) {
    console.error('保存聊天记录失败:', error)
  }
}
```

### 2. 加载聊天记录

添加了 `loadChatHistory` 函数来加载历史聊天记录：

```javascript
const loadChatHistory = async () => {
  try {
    const response = await fetch(`/api/chat/history?courseId=${props.courseId}`)
    
    if (response.ok) {
      const history = await response.json()
      messages.value = history.map(msg => ({
        id: msg.id,
        sender: msg.senderName,
        type: msg.messageType,
        content: msg.messageContent,
        fileName: msg.fileName,
        fileSize: msg.fileSize,
        duration: msg.duration,
        timestamp: new Date(msg.sentAt)
      }))
      scrollToBottom()
    }
  } catch (error) {
    console.error('加载聊天记录失败:', error)
  }
}
```

## 后端API实现

### 1. 保存聊天记录 API

```javascript
app.post('/api/chat/save', async (req, res) => {
  try {
    const { courseId, senderName, messageType, messageContent, fileName, fileSize, duration, sentAt } = req.body;

    const query = `
      INSERT INTO course_chat_log 
      (course_id, sender_name, message, message_type, file_name, file_size, duration, sent_at) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const result = await db.execute(query, [
      courseId, senderName, messageContent, messageType || 'text',
      fileName || null, fileSize || null, duration || null, sentAt || new Date()
    ]);

    res.json({ success: true, id: result.insertId });
  } catch (error) {
    res.status(500).json({ error: '保存聊天记录失败' });
  }
});
```

### 2. 加载聊天记录 API

```javascript
app.get('/api/chat/history', async (req, res) => {
  try {
    const { courseId, limit = 50, offset = 0 } = req.query;

    const query = `
      SELECT id, sender_name, message, message_type, file_name, file_size, duration, sent_at
      FROM course_chat_log 
      WHERE course_id = ? 
      ORDER BY sent_at DESC 
      LIMIT ? OFFSET ?
    `;

    const [rows] = await db.execute(query, [courseId, parseInt(limit), parseInt(offset)]);
    const messages = rows.reverse().map(row => ({
      id: row.id,
      senderName: row.sender_name,
      message: row.message,
      messageType: row.message_type,
      fileName: row.file_name,
      fileSize: row.file_size,
      duration: row.duration,
      sentAt: row.sent_at
    }));

    res.json(messages);
  } catch (error) {
    res.status(500).json({ error: '加载聊天记录失败' });
  }
});
```

## 消息类型支持

### 1. 文本消息 (text)
- 存储普通文本内容
- `message` 字段存储文本内容
- `message_type` 为 'text'

### 2. 表情包消息 (sticker)
- 存储表情包图片URL
- `message` 字段存储图片URL
- `message_type` 为 'sticker'

### 3. 图片消息 (image)
- 存储图片URL和文件信息
- `message` 字段存储图片URL
- `file_name` 存储文件名
- `file_size` 存储文件大小
- `message_type` 为 'image'

### 4. 文件消息 (file)
- 存储文件URL和文件信息
- `message` 字段存储文件URL
- `file_name` 存储文件名
- `file_size` 存储文件大小
- `message_type` 为 'file'

### 5. 语音消息 (voice)
- 存储语音文件URL和时长信息
- `message` 字段存储语音文件URL
- `duration` 存储语音时长（秒）
- `message_type` 为 'voice'

## 部署步骤

### 1. 数据库更新
```bash
# 执行SQL脚本更新表结构
mysql -u your_username -p xiaozhi < chat_table_update.sql
```

### 2. 后端API实现
- 将 `chat_api_example.js` 中的代码集成到你的后端项目
- 确保数据库连接配置正确
- 实现错误处理和日志记录

### 3. 前端集成
- 前端代码已经更新完成
- 确保API端点路径正确
- 测试各种消息类型的保存和加载

## 性能优化建议

### 1. 数据库索引
```sql
-- 添加复合索引提高查询性能
CREATE INDEX `idx_course_sent_at` ON `course_chat_log` (`course_id`, `sent_at` DESC);
CREATE INDEX `idx_message_type` ON `course_chat_log` (`message_type`);
```

### 2. 分页加载
- 实现分页加载聊天记录，避免一次性加载过多数据
- 默认加载最近50条消息
- 支持滚动加载更多历史消息

### 3. 缓存策略
- 对频繁访问的聊天记录进行缓存
- 使用Redis缓存热门课程的聊天记录

## 注意事项

1. **文件存储**: 语音、图片、文件等需要上传到文件服务器，数据库中只存储URL
2. **权限控制**: 确保只有课程参与者可以查看和发送消息
3. **数据清理**: 定期清理过期的聊天记录，避免数据库过大
4. **备份策略**: 定期备份聊天记录数据
5. **隐私保护**: 注意用户隐私保护，遵守相关法律法规

## 测试

1. 测试各种消息类型的发送和保存
2. 测试聊天记录的加载和显示
3. 测试不同课程的聊天记录隔离
4. 测试大量消息的性能表现
5. 测试错误处理和异常情况
