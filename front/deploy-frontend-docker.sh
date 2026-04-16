#!/bin/bash

echo "🚀 开始部署智能教育系统前端应用..."

# 进入应用目录
cd /opt/smart-education-front/

# 停止并删除旧容器
echo "🛑 停止旧容器..."
docker stop smart-education-front 2>/dev/null || true
docker rm smart-education-front 2>/dev/null || true

# 构建Docker镜像
echo "🔨 构建前端Docker镜像..."
docker build -t smart-education-front .

# 检查镜像是否构建成功
if [ $? -eq 0 ]; then
    echo "✅ 前端镜像构建成功！"
else
    echo "❌ 前端镜像构建失败！"
    exit 1
fi

# 运行容器
echo "🚀 启动前端应用容器..."
docker run -d \
  --name smart-education-front \
  -p 80:80 \
  smart-education-front

# 等待应用启动
echo "⏳ 等待前端应用启动..."
sleep 5

# 检查容器状态
echo "📊 检查容器状态..."
docker ps | grep smart-education-front

# 查看应用日志
echo "📋 查看应用日志..."
docker logs smart-education-front

echo "🎉 前端部署完成！"
echo "🌐 前端访问地址: http://81.70.21.208"
echo "📱 应用功能: 智能教育系统前端界面"


