#!/bin/bash

echo "🚀 在服务器上构建前端应用..."

# 进入应用目录
cd /opt/smart-education-front/

# 停止并删除旧容器
echo "🛑 停止旧容器..."
docker stop smart-education-front 2>/dev/null || true
docker rm smart-education-front 2>/dev/null || true

# 使用Docker构建，在容器内解决依赖问题
echo "🔨 使用Docker构建前端应用..."
docker run --rm -v $(pwd):/app -w /app node:18-alpine sh -c "
  echo '📦 清理依赖...'
  rm -rf node_modules package-lock.json
  
  echo '🔧 配置npm镜像源...'
  npm config set registry https://registry.npmmirror.com
  npm config set timeout 300000
  
  echo '📥 重新安装依赖...'
  npm install --legacy-peer-deps
  
  echo '🔧 修复 Rollup 依赖...'
  npm install @rollup/rollup-linux-x64-musl --save-dev
  
  echo '🔧 修复依赖冲突...'
  npm install dayjs@1.11.10 --save
  
  echo '🔧 确保 crypto-js 依赖...'
  npm install crypto-js@4.2.0 --save
  
  echo '🏗️ 构建应用...'
  npm run build
  
  echo '✅ 构建完成！'
"

# 检查构建结果
if [ -d "dist" ]; then
    echo "✅ 构建成功！dist目录已生成"
    
    # 使用nginx服务静态文件
    echo "🚀 启动nginx容器..."
    docker run -d \
      --name smart-education-front \
      -p 80:80 \
      -v $(pwd)/dist:/usr/share/nginx/html \
      -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf \
      nginx:alpine
    
    echo "🎉 前端部署完成！"
    echo "🌐 访问地址: http://81.70.21.208"
else
    echo "❌ 构建失败！"
    exit 1
fi
