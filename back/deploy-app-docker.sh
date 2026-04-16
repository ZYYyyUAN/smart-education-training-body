#!/bin/bash

echo "🚀 开始部署智能教育系统后端应用..."

# 进入应用目录
cd /opt/smart-education/

# 停止并删除旧容器
echo "🛑 停止旧容器..."
docker stop smart-education-app 2>/dev/null || true
docker rm smart-education-app 2>/dev/null || true

# 停止JAR进程（如果还在运行）
echo "🛑 停止JAR进程..."
pkill -f java-ai-langchain4j-1.0-SNAPSHOT.jar 2>/dev/null || true

# 构建Docker镜像
echo "🔨 构建Docker镜像..."
docker build -t smart-education-app .

# 检查镜像是否构建成功
if [ $? -eq 0 ]; then
    echo "✅ 镜像构建成功！"
else
    echo "❌ 镜像构建失败！"
    exit 1
fi

# 运行容器
echo "🚀 启动应用容器..."
docker run -d \
  --name smart-education-app \
  -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  smart-education-app

# 等待应用启动
echo "⏳ 等待应用启动..."
sleep 10

# 检查容器状态
echo "📊 检查容器状态..."
docker ps | grep smart-education-app

# 查看应用日志
echo "📋 查看应用日志..."
docker logs smart-education-app

echo "🎉 部署完成！"
echo "🌐 应用访问地址: http://81.70.21.208:8080"
echo "📚 API文档地址: http://81.70.21.208:8080/doc.html"


