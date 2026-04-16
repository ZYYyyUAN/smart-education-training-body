# 🤖 AI问答服务完整指南

## 📋 概述

AI问答服务是智能教育平台的核心功能之一，提供基于文档内容的智能问答、快速问题生成、对话历史分析等功能。

## 🏗️ 架构设计

### 后端架构
- **控制器**: `AiQaController.java` - 处理所有AI问答相关的HTTP请求
- **AI代理**: `XiaozhiAgent.java` - 包含AI问答的提示词和方法定义
- **实体类**: `QaRequest.java`, `QaChatRequest.java` - 请求数据模型

### 前端架构
- **主页面**: `ai_reader_view.vue` - AI阅读器主界面
- **问答组件**: 集成在AI阅读器的"AI问答"标签页中
- **API调用**: 使用fetch进行HTTP请求和流式响应处理

## 🚀 功能特性

### 1. 智能问答 (AI Chat)
- **流式响应**: 实时显示AI生成的回答
- **上下文理解**: 基于文档内容进行问答
- **对话历史**: 支持多轮对话，保持上下文连贯性
- **错误处理**: 完善的错误提示和重试机制

### 2. 快速问题生成 (Quick Questions)
- **动态生成**: 根据文档类型和内容生成相关问题
- **类型识别**: 自动识别PDF、Word、图片等文档类型
- **一键提问**: 点击快速问题直接开始问答

### 3. 对话历史分析 (History Analysis)
- **学习分析**: 分析用户的学习关注点和理解程度
- **智能建议**: 提供个性化的学习建议
- **统计信息**: 显示问答次数和对话状态

### 4. 界面优化
- **实时状态**: 显示AI思考状态和问答统计
- **清空对话**: 支持清空对话历史重新开始
- **响应式设计**: 适配不同屏幕尺寸

## 🔧 技术实现

### 后端接口

#### 1. AI智能问答
```java
@PostMapping(value = "/chat", produces = "text/plain;charset=UTF-8")
public Flux<String> aiChat(@RequestBody QaChatRequest request)
```
- **功能**: 基于文档内容进行智能问答
- **特点**: 流式响应，支持实时显示
- **参数**: 问题、文档内容、文件名、对话历史

#### 2. 快速问题生成
```java
@PostMapping("/quick-questions")
public Result<List<String>> getQuickQuestions(@RequestBody Map<String, String> request)
```
- **功能**: 根据文档类型生成快速问题
- **返回**: 问题列表，带有emoji图标
- **参数**: 文档类型、文件名

#### 3. 对话历史分析
```java
@PostMapping("/analyze-history")
public Result<Map<String, Object>> analyzeQaHistory(@RequestBody Map<String, Object> request)
```
- **功能**: 分析用户的问答历史
- **返回**: 学习分析报告和建议
- **参数**: 对话历史、文档名称

### 前端实现

#### 1. 流式响应处理
```javascript
// 处理流式响应
const reader = response.body.getReader();
const decoder = new TextDecoder('utf-8');
let fullResponse = '';

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  const chunk = decoder.decode(value, { stream: true });
  if (chunk.trim()) {
    currentTypingMessage.value += chunk;
    fullResponse += chunk;
  }
}
```

#### 2. 动态快速问题加载
```javascript
const loadQuickQuestions = async () => {
  const documentType = getDocumentType();
  
  const response = await fetch('/ai-qa/quick-questions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      documentType: documentType,
      fileName: fileMeta.value.name
    })
  });
  
  if (response.ok) {
    const result = await response.json();
    if (result.success && result.data) {
      quickQuestions.value = result.data;
    }
  }
};
```

#### 3. 对话历史管理
```javascript
// 清空对话历史
const clearChatHistory = () => {
  if (confirm('确定要清空所有对话记录吗？')) {
    chatMessages.value = [/* 初始欢迎消息 */];
  }
};

// 分析对话历史
const analyzeQaHistory = async () => {
  const validMessages = chatMessages.value.filter(msg => msg.role !== 'system');
  const chatHistory = validMessages.map(msg => ({
    role: msg.role,
    content: msg.content,
    timestamp: msg.timestamp
  }));
  
  const response = await fetch('/ai-qa/analyze-history', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      chatHistory: chatHistory,
      documentName: fileMeta.value.name
    })
  });
};
```

## 🎯 AI提示词设计

### 1. 智能问答提示词
```java
@UserMessage("""
请基于以下文档内容回答用户的问题：

文档内容：{{documentContent}}
用户问题：{{question}}
文档名称：{{fileName}}

要求：
1. 答案必须基于文档内容，不要编造信息
2. 如果文档中没有相关信息，请明确说明
3. 回答要准确、详细，有条理
4. 使用中文回答，语言自然流畅
5. 可以适当引用文档中的原文
6. 如果问题涉及多个方面，请分点回答

请开始回答：
""")
```

### 2. 快速问题生成提示词
```java
@UserMessage("""
基于以下信息生成4-6个快速问题建议：

文档类型：{{documentType}}
文档名称：{{fileName}}

要求：
1. 问题要有针对性，适合该文档类型
2. 问题要有层次性，从浅到深
3. 包含不同类型的问题（概括、分析、应用等）
4. 每个问题前加上合适的emoji图标
5. 问题要简洁明了，便于用户选择

请严格按照以下JSON数组格式返回：
["📋 问题1", "🔍 问题2", "💡 问题3", "📊 问题4"]
""")
```

### 3. 历史分析提示词
```java
@UserMessage("""
请分析以下问答历史，总结用户的学习情况和关注点：

问答历史：{{chatHistory}}
文档名称：{{documentName}}

要求：
1. 分析用户主要关注的知识点
2. 评估用户的理解程度
3. 识别学习难点和疑惑点
4. 提供针对性的学习建议
5. 语言简洁明了，有条理

分析格式：
【主要关注点】xxx
【理解程度】xxx
【学习难点】xxx
【学习建议】xxx
""")
```

## 🔧 配置和部署

### 1. 后端配置
在`vite.config.js`中添加代理配置：
```javascript
'/ai-qa': {
  target: 'http://localhost:8080',
  changeOrigin: true
}
```

### 2. 依赖要求
- Spring Boot 2.7+
- Langchain4j
- Reactor (用于流式响应)
- Vue 3 (前端)

### 3. 环境变量
确保AI模型相关的环境变量已正确配置：
- OpenAI API Key (如果使用OpenAI)
- 其他AI服务的配置

## 🧪 测试

### 1. 使用测试页面
访问 `test_ai_qa_service.html` 进行完整功能测试：
- 连接测试
- 快速问题生成测试
- AI问答测试（包括流式响应）
- 对话历史分析测试

### 2. 手动测试步骤
1. 启动后端服务 (端口8080)
2. 启动前端服务 (端口5173)
3. 上传文档到AI阅读器
4. 切换到"AI问答"标签页
5. 测试各项功能

### 3. API测试
使用Postman或curl测试各个API端点：
```bash
# 测试连接
curl -X GET http://localhost:8080/ai-qa/test

# 测试快速问题
curl -X POST http://localhost:8080/ai-qa/quick-questions \
  -H "Content-Type: application/json" \
  -d '{"documentType":"pdf","fileName":"test.pdf"}'

# 测试AI问答
curl -X POST http://localhost:8080/ai-qa/chat \
  -H "Content-Type: application/json" \
  -d '{"question":"这个文档讲什么？","documentContent":"测试内容","fileName":"test.pdf"}'
```

## 🐛 常见问题

### 1. 流式响应不工作
- 检查网络连接
- 确认后端API返回正确的Content-Type
- 检查前端fetch配置

### 2. 快速问题不更新
- 确认文档类型识别正确
- 检查API调用是否成功
- 验证返回数据格式

### 3. AI回答质量问题
- 检查提示词设计
- 确认文档内容提取正确
- 调整AI模型参数

## 📈 性能优化

### 1. 缓存策略
- 快速问题结果缓存
- 文档内容提取结果缓存
- API响应缓存

### 2. 并发处理
- 使用Reactor处理并发请求
- 限制同时进行的AI请求数量
- 实现请求队列管理

### 3. 前端优化
- 虚拟滚动处理长对话
- 防抖处理用户输入
- 懒加载历史消息

## 🔮 未来扩展

### 1. 功能扩展
- 语音问答支持
- 多语言问答
- 图表数据解读
- 批量文档问答

### 2. 技术升级
- WebSocket实时通信
- AI模型本地部署
- 向量数据库集成
- 知识图谱支持

---

*本文档会随着功能的完善而持续更新*
