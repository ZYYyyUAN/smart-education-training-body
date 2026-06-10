// MongoDB初始化脚本
// 创建数据库和集合
// 注意：生产环境应通过环境变量注入凭据，而不是在此硬编码

// 切换到目标数据库
db = db.getSiblingDB('chat_memory_db4');

// 从环境变量读取凭据，开发环境使用默认值
var mongoUser = _getEnv('MONGO_USER') || 'xiaozhi';
var mongoPassword = _getEnv('MONGO_PASSWORD');
if (!mongoPassword) {
    // 开发环境默认密码（生产环境请通过 MONGO_PASSWORD 环境变量覆盖）
    print('WARNING: MONGO_PASSWORD not set, using dev default');
    mongoPassword = 'xiaozhi123';
}

// 创建用户（如果需要认证）
db.createUser({
  user: mongoUser,
  pwd: mongoPassword,
  roles: [
    {
      role: 'readWrite',
      db: 'chat_memory_db4'
    }
  ]
});

// 创建聊天记录集合
db.createCollection('chat_sessions');
db.createCollection('chat_messages');
db.createCollection('user_memories');
db.createCollection('course_memories');

// 创建索引
db.chat_sessions.createIndex({ "userId": 1, "sessionId": 1 });
db.chat_sessions.createIndex({ "createTime": 1 });

db.chat_messages.createIndex({ "sessionId": 1, "timestamp": 1 });
db.chat_messages.createIndex({ "userId": 1, "timestamp": 1 });

db.user_memories.createIndex({ "userId": 1 });
db.user_memories.createIndex({ "type": 1, "timestamp": 1 });

db.course_memories.createIndex({ "courseId": 1, "userId": 1 });
db.course_memories.createIndex({ "timestamp": 1 });

// 插入初始数据
db.chat_sessions.insertOne({
  sessionId: "init_session_001",
  userId: 1,
  courseId: 101,
  courseName: "数据结构与算法",
  createTime: new Date(),
  lastActiveTime: new Date(),
  messageCount: 0,
  status: "active"
});

db.user_memories.insertOne({
  userId: 1,
  type: "preference",
  content: "用户偏好设置",
  timestamp: new Date(),
  metadata: {
    language: "zh-CN",
    learningStyle: "visual"
  }
});

print("MongoDB初始化完成！");
