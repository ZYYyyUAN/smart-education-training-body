# 小智 AI — 智能教育实训平台（后端）

基于 Spring Boot 3 + LangChain4j + 通义千问的 AI 辅助教学系统，为高校师生提供 RAG 课程问答、AI 出题组卷、AI 批改、学情分析和知识图谱能力。

## 技术栈

| 分类 | 技术 | 用途 |
|---|---|---|
| 框架 | Spring Boot 3.2 + MyBatis-Plus 3.5 | Web 服务 + ORM |
| AI 框架 | LangChain4j 1.0.0-beta3 | Agent / RAG / Memory / Tool |
| 对话模型 | 通义千问 qwen-plus | 对话生成、出题、批改、学情分析 |
| 向量化 | 通义千问 text-embedding-v4 (1024维) | 文档 Embedding |
| 向量存储 | Pinecone Serverless (AWS us-east-1) | 相似度检索 |
| 对话记忆 | MongoDB 7 | AI 对话历史（滑动窗口） |
| 知识图谱 | Neo4j | 知识点依赖关系 |
| 对象存储 | 阿里云 OSS | 课件 PDF/DOCX、头像 |
| 语音 | 讯飞 TTS / IAT / OCR | 语音合成 + 识别 + 图片 OCR |
| 数据库 | MySQL 8 | 用户 / 课程 / 考试 / 作业 / 题库 |
| 文档 | Knife4j (Swagger) | API 文档 |
| 部署 | Docker Compose | 一键部署 |

## 系统架构

```
前端 (Vue 3 + Pinia)
  │  HTTP REST + SSE (流式) + WebSocket (语音)
  ▼
Spring Boot 3.2
  ├── 24 Controller    → 认证 / 学生端 / 教师端 / 管理端
  ├── 37 Service       → 业务逻辑 + AI Agent 调用
  ├── Mapper (XML)     → MyBatis-Plus 数据访问
  └── LangChain4j 框架层
       ├── XiaozhiAgent     → RAG 对话 + 工具调用
       ├── EmbeddingStore   → Pinecone 向量存储
       ├── DocumentSplitter → recursive(3000, 100)
       └── ChatMemory       → MongoDB 对话记忆
  │
  ▼
MySQL    MongoDB    Pinecone    Neo4j    OSS    讯飞语音
```

## 核心功能

### RAG 课程知识库问答
教师上传 PDF/DOCX → OSS 存储 → 点击入库 → 解析纯文本 → 递归切块(3000/100) → text-embedding-v4 向量化 → Pinecone 按课程 Namespace 存储。学生提问 → 问题向量化 → Pinecone 检索 Top-3 → 拼接对话历史 → qwen-plus 流式生成回答 → SSE 推前端。

### AI 智能出题 & 自动组卷
教师设定知识点 + 题型分布 + 难度比例 → AI 批量生成题目存入题库分类。组卷时按条件采样题库 + AI 补全 → 组装试卷 → 预览/调整/发布 → 学生作答。

### AI 批改 & 学情分析
学生提交答案 → 对比标准答案 → AI 逐题评分 + 反馈。学情报告聚合登录趋势、作业/考试成绩、逐题作答详情 → 文本格式化 → LLM 诊断薄弱知识点 → 个性化建议。

### 学习积分 & 排行榜
积分 = 练习次数 × 4 + 登录天数 × 2 + 连续登录奖励(每5天+10)。课程排行榜 + 全站总排行，积分自动更新。

### 语音交互 & OCR
文字→语音(TTS)通过 WebSocket 推送前端播放。语音→文字(IAT)送 AI 生成回答。图片 OCR 识别课本/笔记文字。

### 知识图谱
Neo4j 存储知识点节点 + 前置依赖边，前端可视化交互式图谱。

## 快速开始

### 环境要求

- JDK 17
- Maven 3.6+
- MySQL 8.0
- MongoDB 7.0
- Neo4j (可选，知识图谱功能需要)
- Pinecone API Key（[注册获取](https://www.pinecone.io/)）
- 通义千问 API Key（[阿里云 DashScope](https://dashscope.aliyun.com/)）
- 阿里云 OSS（课件存储）

### 本地开发

```bash
# 1. 克隆项目
git clone <repo-url>
cd smart-education-training-body-back

# 2. 配置环境变量（开发环境有默认值，可以不设）
# 生产环境必须设置以下变量：
#   DB_URL, DB_USERNAME, DB_PASSWORD
#   MONGODB_URI
#   TONGYI_API_KEY
#   PINECONE_API_KEY
#   ALIYUN_OSS_ACCESS_KEY_ID, ALIYUN_OSS_ACCESS_KEY_SECRET, ALIYUN_OSS_BUCKET_NAME

# 3. 初始化数据库
# 执行 init-scripts/01-init-database.sql 创建表结构和种子数据
# （注意：种子数据含默认账户，生产环境请修改密码）

# 4. 编译运行
mvn clean compile
mvn spring-boot:run

# 5. 访问 API 文档
# http://localhost:8080/doc.html
```

### Docker 部署

```bash
# 1. 配置 .env 文件（参考 .env.example）
cp .env.example .env
# 编辑 .env 填入实际值

# 2. 启动所有服务
docker-compose up -d

# 3. 仅启动数据库（应用本地运行）
docker-compose -f docker-compose-mysql.yml up -d
```

## 项目结构

```
src/main/java/com/atguigu/java/ai/langchain4j/
├── XiaozhiApp.java              # 启动入口
├── assistant/                   # AI Agent 接口定义
│   └── XiaozhiAgent.java        # 对话/出题/批改/摘要 Agent
├── bean/                        # 数据传输 Bean
├── config/                      # 配置类
│   ├── EmbeddingStoreConfig     # Pinecone 向量存储配置
│   ├── XiaozhiAgentConfig       # RAG + ChatMemory 配置
│   ├── QwenModelConfig          # 通义千问模型 Bean
│   ├── CorsConfig / WebConfig   # CORS + Web MVC
│   └── KaptchaConfig            # 验证码
├── controller/                  # 24 个 REST Controller
│   ├── AuthController           # 登录注册
│   ├── StudentController        # 学生端（对话/作业/考试/积分）
│   ├── TeacherController        # 教师端（课程/资源/作业/出题）
│   ├── AutoExamController       # AI 自动组卷
│   ├── AiReaderController       # AI 阅读器（OCR + 摘要）
│   └── ...
├── entity/                      # 实体 + DTO + 请求体
├── intercepter/                 # 拦截器
├── mapper/                      # MyBatis Mapper 接口
├── neo4jentity/                 # Neo4j 实体
├── neo4jservice/                # Neo4j 服务
├── repository/                  # 数据仓库层
├── service/                     # 37 个 Service 接口
│   └── Impl/                    # 实现类
├── store/                       # MongoDB 对话记忆存储
├── tools/                       # AI Tool（讯飞 IAT 等）
└── util/                        # 工具类（JWT/OSS/文件）

src/main/resources/
├── application.properties       # 开发环境配置
├── application-prod.properties  # 生产环境配置（纯环境变量注入）
├── xiaozhi-course.txt           # RAG 课程问答 Prompt 模板
├── xiaozhi-xuexi.txt            # AI 助教 System Prompt 模板
├── mapper/                      # MyBatis XML 映射文件
├── audio/                       # 音频资源
└── lib/                         # 本地依赖库
```

## 环境变量

参考 `.env.example` 文件，关键变量：

| 变量 | 说明 |
|---|---|
| `DB_URL` | MySQL 连接串 |
| `DB_USERNAME` / `DB_PASSWORD` | 数据库凭证 |
| `MONGODB_URI` | MongoDB 连接串 |
| `TONGYI_API_KEY` | 通义千问 API Key（生成 + 向量化共用） |
| `PINECONE_API_KEY` | Pinecone API Key（核心强依赖） |
| `ALIYUN_OSS_ACCESS_KEY_ID` / `ALIYUN_OSS_ACCESS_KEY_SECRET` | 阿里云 OSS 凭证 |
| `ALIYUN_OSS_BUCKET_NAME` | OSS Bucket 名称 |
| `JWT_SECRET` | JWT 签名密钥 |
| `XFYUN_APP_ID` / `XFYUN_API_KEY` | 讯飞语音凭证 |

## 默认账户

开发环境种子数据包含以下账户（密码均为 `123456`）：

| 用户名 | 角色 |
|---|---|
| `lilei` | student |
| `hanmeimei` | teacher |
| `ry` | admin |

生产环境部署前请修改默认密码或删除这些账户。

## API 文档

启动后访问 `http://localhost:8080/doc.html` 查看 Knife4j 生成的 API 文档。

主要接口分组：
- 用户登录与注册 (`/auth`)
- 硅谷小智学生端 (`/xiaozhi/student`)
- 硅谷小智教师端 (`/xiaozhi/teacher`)
- 自动组卷 (`/auto-exam`)
- AI 阅读器 (`/ai-reader`)
- AI 问答 (`/ai-qa`)
- 知识图谱 (`/graph`)
