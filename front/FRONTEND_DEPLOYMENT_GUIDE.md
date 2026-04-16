# 智能教育系统前端部署指南

## 📋 部署步骤

### 1. 准备服务器环境

```bash
# 在服务器上创建前端目录
mkdir -p /opt/smart-education-front
cd /opt/smart-education-front
```

### 2. 上传前端代码

```bash
# 在本地执行，上传前端代码到服务器
scp -r xiaozhi-front/* root@81.70.21.208:/opt/smart-education-front/
```

### 3. 部署前端应用

```bash
# 在服务器上执行
cd /opt/smart-education-front
chmod +x deploy-frontend-docker.sh
./deploy-frontend-docker.sh
```

## 🔧 手动部署步骤

如果自动脚本失败，可以手动执行：

```bash
# 1. 构建前端镜像
docker build -t smart-education-front .

# 2. 运行前端容器
docker run -d \
  --name smart-education-front \
  -p 80:80 \
  smart-education-front

# 3. 查看状态
docker ps
docker logs smart-education-front
```

## 🌐 访问地址

- **前端应用**: http://81.70.21.208
- **后端API**: http://81.70.21.208:8080
- **API文档**: http://81.70.21.208:8080/doc.html

## 🔍 故障排除

### 检查容器状态
```bash
docker ps | grep smart-education-front
```

### 查看应用日志
```bash
docker logs smart-education-front
```

### 检查Nginx配置
```bash
docker exec -it smart-education-front nginx -t
```

### 重启容器
```bash
docker restart smart-education-front
```

## 📊 服务架构

```
用户浏览器
    ↓
Nginx (端口80) - 前端静态文件 + API代理
    ↓
Spring Boot (端口8080) - 后端API服务
    ↓
MySQL (端口3306) + MongoDB (端口27017) - 数据库
```

## 🎯 功能特性

- ✅ Vue3 + Vite 现代化前端框架
- ✅ 响应式设计，支持移动端
- ✅ Nginx反向代理，API自动转发
- ✅ Gzip压缩，提升加载速度
- ✅ 静态资源缓存优化
- ✅ 安全头配置


