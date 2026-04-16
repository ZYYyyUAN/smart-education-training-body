# 聊天记录功能部署指南

## 问题诊断

你遇到的 `404 Not Found` 错误通常是由以下原因造成的：

1. **SpringBoot应用未启动**
2. **API路径不正确**
3. **数据库表未创建**
4. **CORS跨域问题**

## 解决步骤

### 1. 启动SpringBoot应用

```bash
# 进入项目目录
cd java-ai-langchain4j

# 启动应用
mvn spring-boot:run
```

确保看到类似以下输出：
```
Started XiaozhiApp in X.XXX seconds
```

### 2. 初始化数据库

在MySQL中执行数据库初始化脚本：

```bash
# 方法1：使用命令行
mysql -u root -p xiaozhi < init_chat_database.sql

# 方法2：在MySQL Workbench或其他客户端中执行
# 打开 init_chat_database.sql 文件并执行
```

### 3. 测试API连接

使用提供的测试页面：

1. 打开 `test_api.html` 文件
2. 确保SpringBoot应用在 `http://localhost:8080` 运行
3. 点击测试按钮验证API功能

### 4. 检查API路径

正确的API路径应该是：
- 保存消息：`POST http://localhost:8080/api/chat/save`
- 获取历史：`GET http://localhost:8080/api/chat/history?courseId=1`
- 获取统计：`GET http://localhost:8080/api/chat/stats/1`

### 5. 前端配置

确保前端代码中的API路径正确：

```javascript
// 在 WeChatGroupChat.vue 中
const response = await fetch('http://localhost:8080/api/chat/save', {
  // ...
});
```

## 常见问题解决

### 问题1：404 Not Found

**原因**：应用未启动或路径错误
**解决**：
1. 检查应用是否在8080端口运行
2. 确认API路径为 `/api/chat/*`
3. 检查Controller是否正确注册

### 问题2：CORS错误

**原因**：跨域请求被阻止
**解决**：Controller已添加 `@CrossOrigin(origins = "*")`

### 问题3：数据库连接错误

**原因**：数据库配置错误或表不存在
**解决**：
1. 检查 `application.properties` 中的数据库配置
2. 执行 `init_chat_database.sql` 创建表

### 问题4：字段映射错误

**原因**：实体类字段与数据库字段不匹配
**解决**：确保使用了正确的字段名映射

## 验证步骤

### 1. 检查应用状态

访问 `http://localhost:8080` 确认应用运行

### 2. 测试API

使用curl命令测试：

```bash
# 测试保存消息
curl -X POST http://localhost:8080/api/chat/save \
  -H "Content-Type: application/json" \
  -d '{
    "courseId": 1,
    "senderName": "测试用户",
    "messageType": "text",
    "messageContent": "测试消息"
  }'

# 测试获取历史
curl http://localhost:8080/api/chat/history?courseId=1
```

### 3. 检查数据库

```sql
-- 检查表是否存在
SHOW TABLES LIKE 'course_chat_log';

-- 检查数据
SELECT * FROM course_chat_log WHERE course_id = 1;
```

## 完整测试流程

1. **启动应用**：`mvn spring-boot:run`
2. **初始化数据库**：执行 `init_chat_database.sql`
3. **测试API**：使用 `test_api.html` 或curl命令
4. **测试前端**：启动前端应用并测试聊天功能

## 日志查看

如果仍有问题，查看应用日志：

```bash
# 查看启动日志
tail -f logs/spring.log

# 或在控制台查看输出
```

## 联系支持

如果按照以上步骤仍无法解决问题，请提供：

1. 应用启动日志
2. 数据库连接状态
3. API测试结果
4. 错误信息截图
