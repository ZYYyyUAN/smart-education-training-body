// 后端API示例代码 - 聊天记录管理
// 这些代码需要在你的后端项目中实现

// 1. 保存聊天记录
app.post('/api/chat/save', async (req, res) => {
  try {
    const {
      courseId,
      senderName,
      messageType,
      messageContent,
      fileName,
      fileSize,
      duration,
      sentAt
    } = req.body;

    // 验证必填字段
    if (!courseId || !senderName || !messageContent) {
      return res.status(400).json({ error: '缺少必填字段' });
    }

    // 插入数据库
    const query = `
      INSERT INTO course_chat_log 
      (course_id, sender_name, message, message_type, file_name, file_size, duration, sent_at) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const result = await db.execute(query, [
      courseId,
      senderName,
      messageContent,
      messageType || 'text',
      fileName || null,
      fileSize || null,
      duration || null,
      sentAt || new Date()
    ]);

    res.json({ 
      success: true, 
      id: result.insertId,
      message: '聊天记录保存成功' 
    });

  } catch (error) {
    console.error('保存聊天记录失败:', error);
    res.status(500).json({ error: '保存聊天记录失败' });
  }
});

// 2. 加载聊天记录
app.get('/api/chat/history', async (req, res) => {
  try {
    const { courseId, limit = 50, offset = 0 } = req.query;

    if (!courseId) {
      return res.status(400).json({ error: '缺少课程ID' });
    }

    // 查询聊天记录
    const query = `
      SELECT 
        id,
        sender_name,
        message,
        message_type,
        file_name,
        file_size,
        duration,
        sent_at
      FROM course_chat_log 
      WHERE course_id = ? 
      ORDER BY sent_at DESC 
      LIMIT ? OFFSET ?
    `;

    const [rows] = await db.execute(query, [courseId, parseInt(limit), parseInt(offset)]);

    // 反转数组，使最新的消息在最后
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
    console.error('加载聊天记录失败:', error);
    res.status(500).json({ error: '加载聊天记录失败' });
  }
});

// 3. 删除聊天记录（可选）
app.delete('/api/chat/delete/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const query = 'DELETE FROM course_chat_log WHERE id = ?';
    await db.execute(query, [id]);

    res.json({ success: true, message: '聊天记录删除成功' });

  } catch (error) {
    console.error('删除聊天记录失败:', error);
    res.status(500).json({ error: '删除聊天记录失败' });
  }
});

// 4. 获取课程聊天统计（可选）
app.get('/api/chat/stats/:courseId', async (req, res) => {
  try {
    const { courseId } = req.params;

    const query = `
      SELECT 
        COUNT(*) as total_messages,
        COUNT(DISTINCT sender_name) as unique_senders,
        MIN(sent_at) as first_message,
        MAX(sent_at) as last_message
      FROM course_chat_log 
      WHERE course_id = ?
    `;

    const [rows] = await db.execute(query, [courseId]);

    res.json(rows[0]);

  } catch (error) {
    console.error('获取聊天统计失败:', error);
    res.status(500).json({ error: '获取聊天统计失败' });
  }
});

// 数据库连接配置示例
const mysql = require('mysql2/promise');

const dbConfig = {
  host: 'localhost',
  user: 'your_username',
  password: 'your_password',
  database: 'xiaozhi',
  charset: 'utf8mb4'
};

const db = mysql.createPool(dbConfig);

module.exports = {
  saveChatMessage: async (chatData) => {
    // 实现保存聊天记录的逻辑
  },
  loadChatHistory: async (courseId, limit = 50) => {
    // 实现加载聊天记录的逻辑
  }
};
