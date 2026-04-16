# AI阅读器后端接口集成指南

## 概述

本文档描述了AI阅读器各功能模块的后端接口设计和前端集成方法。

## 新增的控制器

### 1. AiQaController - AI问答控制器
**路径**: `/ai-qa`

#### 主要接口：
- `POST /ai-qa/chat` - AI智能问答（流式响应）
- `POST /ai-qa/quick-questions` - 获取快速问题建议
- `POST /ai-qa/document-qa` - 基于文档的问答
- `POST /ai-qa/analyze-history` - 问答历史分析

### 2. AiNotesController - AI学习笔记控制器
**路径**: `/ai-notes`

#### 主要接口：
- `POST /ai-notes/generate` - AI生成学习笔记（流式响应）
- `POST /ai-notes/optimize` - AI优化笔记内容
- `POST /ai-notes/summary` - 生成笔记摘要
- `POST /ai-notes/tags` - 生成笔记标签
- `POST /ai-notes/knowledge-points` - 提取知识点

### 3. MindMapController - 笔记导图控制器
**路径**: `/mind-map`

#### 主要接口：
- `POST /mind-map/generate` - AI生成思维导图结构
- `POST /mind-map/optimize` - 优化思维导图
- `POST /mind-map/node-details` - 生成节点详情（流式响应）
- `POST /mind-map/expand-branch` - 扩展思维导图分支

### 4. ResourcesController - 相关资源控制器
**路径**: `/resources`

#### 主要接口：
- `POST /resources/recommend` - AI智能推荐相关资源
- `POST /resources/search-keywords` - 生成资源搜索关键词
- `POST /resources/analyze-content` - 资源内容分析
- `POST /resources/generate-tags` - 生成资源标签

## 实体类

### 请求实体：
- `QaRequest` - 问答请求
- `QaChatRequest` - 聊天问答请求
- `NotesRequest` - 笔记请求
- `NotesGenerateRequest` - 笔记生成请求
- `MindMapRequest` - 思维导图请求
- `ResourceSearchRequest` - 资源搜索请求

## XiaozhiAgent 新增提示词

### AI问答相关：
- `answerDocumentQuestion()` - 基于文档的智能问答
- `generateQuickQuestions()` - 生成快速问题建议
- `analyzeQaHistory()` - 问答历史分析

### AI学习笔记相关：
- `generateStudyNotes()` - 生成学习笔记
- `optimizeNotes()` - 优化笔记内容
- `generateNotesTags()` - 生成笔记标签
- `extractKnowledgePoints()` - 提取知识点

### 思维导图相关：
- `generateMindMapStructure()` - 生成思维导图结构
- `generateMindMapNodeDetails()` - 生成节点详情
- `expandMindMapBranch()` - 扩展思维导图分支

### 相关资源推荐：
- `recommendRelatedResources()` - 推荐相关资源
- `generateResourceSearchKeywords()` - 生成搜索关键词
- `analyzeResourceRelevance()` - 分析资源相关性

## 前端集成要点

### 1. API调用示例
```javascript
// AI问答
const response = await fetch('/ai-qa/chat', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    question: "用户问题",
    documentContent: "文档内容",
    fileName: "文件名"
  })
});

// 处理流式响应
const reader = response.body.getReader();
const decoder = new TextDecoder();
while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  const chunk = decoder.decode(value, { stream: true });
  // 处理响应片段
}
```

### 2. 错误处理
所有接口都包含统一的错误处理机制，前端需要检查响应状态并处理错误情况。

### 3. 流式响应处理
支持流式响应的接口（如AI问答、笔记生成）需要使用ReadableStream处理实时数据。

## 部署注意事项

1. 确保所有新增的Controller都被Spring Boot扫描到
2. 验证XiaozhiAgent中的新方法能正常调用
3. 测试各个接口的响应格式和错误处理
4. 确认前端路由代理配置正确

## 测试建议

1. 使用Swagger UI测试各个接口
2. 验证流式响应的正确性
3. 测试错误场景的处理
4. 确认前后端数据格式匹配

---

*本文档会随着功能的完善而更新*
