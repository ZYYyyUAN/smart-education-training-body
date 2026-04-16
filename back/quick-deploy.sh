#!/bin/bash

# 智能教育系统快速部署脚本
# 适用于服务器 81.70.21.208

echo "🚀 智能教育系统快速部署开始..."

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "❌ 请使用root用户运行此脚本"
    exit 1
fi

# 1. 安装Docker和Docker Compose
echo "📦 安装Docker和Docker Compose..."
curl -fsSL https://get.docker.com | bash -s docker
systemctl start docker
systemctl enable docker

curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 2. 配置防火墙
echo "🔥 配置防火墙..."
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload

# 3. 创建项目目录
echo "📁 创建项目目录..."
mkdir -p /opt/smart-education
cd /opt/smart-education

# 4. 提示用户上传项目文件
echo "📤 请将项目文件上传到 /opt/smart-education 目录"
echo "可以使用以下命令："
echo "scp -r /path/to/your/project/* root@81.70.21.208:/opt/smart-education/"
echo ""
read -p "项目文件上传完成后，按回车键继续..."

# 5. 配置环境变量
echo "⚙️ 配置环境变量..."
if [ ! -f ".env" ]; then
    if [ -f "env.example" ]; then
        cp env.example .env
        echo "✅ 已创建.env文件，请编辑配置信息"
        echo "⚠️  重要：请编辑.env文件，填入正确的API密钥和OSS配置"
        read -p "配置完成后按回车键继续..."
    else
        echo "❌ 未找到env.example文件"
        exit 1
    fi
fi

# 6. 给脚本执行权限
echo "🔧 设置脚本权限..."
chmod +x deploy.sh

# 7. 启动服务
echo "🚀 启动服务..."
./deploy.sh start

# 8. 检查服务状态
echo "🔍 检查服务状态..."
sleep 10
./deploy.sh status

echo ""
echo "🎉 部署完成！"
echo ""
echo "📋 访问地址："
echo "   应用首页: http://81.70.21.208"
echo "   API文档: http://81.70.21.208/doc.html"
echo "   健康检查: http://81.70.21.208:8080/actuator/health"
echo ""
echo "🛠️ 常用命令："
echo "   查看日志: ./deploy.sh logs"
echo "   重启服务: ./deploy.sh restart"
echo "   停止服务: ./deploy.sh stop"
echo ""
echo "📖 详细文档: 查看 DOCKER_DEPLOYMENT_GUIDE.md"


