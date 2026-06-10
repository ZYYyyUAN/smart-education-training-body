// init.js
// 切换到目标数据库
db = db.getSiblingDB('chat_memory_db4');

// 创建用户（增加异常捕获防止重复执行时报错）
try {
    db.createUser({
        user: MONGO_USER,       // 使用从命令行注入的变量
        pwd: MONGO_PASSWORD,    // 使用从命令行注入的变量
        roles: [{ role: 'readWrite', db: 'chat_memory_db4' }]
    });
    print("User '" + MONGO_USER + "' created successfully.");
} catch (e) {
    if (e.codeName === "DuplicateKey" || e.code === 51003) {
        print("User '" + MONGO_USER + "' already exists, skipping creation.");
    } else {
        throw e; 
    }
}

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

// 插入初始数据（仅当集合为空时插入）
if (db.chat_sessions.countDocuments() === 0) {
    db.chat_sessions.insertOne({
        sessionId: "init_session_001", userId: 1, courseId: 101,
        courseName: "数据结构与算法", createTime: new Date(),
        lastActiveTime: new Date(), messageCount: 0, status: "active"
    });
    print("Initial chat session inserted.");
}

if (db.user_memories.countDocuments() === 0) {
    db.user_memories.insertOne({
        userId: 1, type: "preference", content: "用户偏好设置",
        timestamp: new Date(), metadata: { language: "zh-CN", learningStyle: "visual" }
    });
    print("Initial user memory inserted.");
}

print("MongoDB initialization completed successfully!");