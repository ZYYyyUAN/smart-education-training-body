# 智能教育系统 Docker 部署指南

## 📋 部署概览

本指南将帮助你在服务器 `81.70.21.208` 上部署智能教育系统，使用 Docker 容器化技术。

### 🏗️ 系统架构

```
服务器 (81.70.21.208)
├── Spring Boot 应用 (端口: 8080)
├── MySQL 数据库 (端口: 3306)
├── MongoDB 数据库 (端口: 27017)
└── Nginx 反向代理 (端口: 80/443)
```

## 🚀 快速开始

### 1. 服务器环境准备

```bash
# 连接到服务器
ssh root@81.70.21.208

# 更新系统
yum update -y

# 安装Docker
curl -fsSL https://get.docker.com | bash -s docker
systemctl start docker
systemctl enable docker

# 安装Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 验证安装
docker --version
docker-compose --version
```

### 2. 项目部署

```bash
# 创建项目目录
mkdir -p /opt/smart-education
cd /opt/smart-education

# 上传项目文件（使用scp或git clone）
# 假设项目文件已上传到服务器

# 配置环境变量
cp env.example .env
# 编辑 .env 文件，填入正确的配置信息
vim .env

# 给部署脚本执行权限
chmod +x deploy.sh

# 启动服务
./deploy.sh start
```

## ⚙️ 详细配置

### 环境变量配置

编辑 `.env` 文件，配置以下关键参数：

```bash
# 数据库配置
MYSQL_ROOT_PASSWORD=your_mysql_root_password
MYSQL_DATABASE=xiaozhi
MYSQL_USER=xiaozhi
MYSQL_PASSWORD=your_mysql_password

# MongoDB配置
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=your_mongo_password
MONGO_DATABASE=chat_memory_db4

# AI服务配置（重要！）
TONGYI_API_KEY=sk-your-tongyi-api-key
XUNFEI_APP_ID=your-xunfei-app-id
XUNFEI_API_KEY=your-xunfei-api-key
XUNFEI_API_SECRET=your-xunfei-api-secret

# 阿里云OSS配置（重要！）
ALIYUN_OSS_ENDPOINT=oss-cn-beijing.aliyuncs.com
ALIYUN_OSS_ACCESS_KEY_ID=your-aliyun-access-key-id
ALIYUN_OSS_ACCESS_KEY_SECRET=your-aliyun-access-key-secret
ALIYUN_OSS_BUCKET_NAME=your-bucket-name
```

### 防火墙配置

```bash
# 开放必要端口
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload

# 检查端口状态
firewall-cmd --list-ports
```

## 🛠️ 部署命令

### 基本操作

```bash
# 启动所有服务
./deploy.sh start

# 停止所有服务
./deploy.sh stop

# 重启所有服务
./deploy.sh restart

# 查看服务状态
./deploy.sh status

# 查看服务日志
./deploy.sh logs

# 清理Docker资源
./deploy.sh cleanup
```

### 手动操作

```bash
# 构建应用
mvn clean package -DskipTests

# 启动服务
docker-compose up -d

# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs -f app

# 进入容器
docker-compose exec app bash
docker-compose exec mysql mysql -u root -p
```

## 📊 服务监控

### 健康检查

```bash
# 检查应用健康状态
curl http://81.70.21.208:8080/actuator/health

# 检查数据库连接
docker-compose exec mysql mysqladmin ping -h localhost
docker-compose exec mongodb mongosh --eval "db.runCommand('ping')"
```

### 日志查看

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f app
docker-compose logs -f mysql
docker-compose logs -f mongodb
docker-compose logs -f nginx
```

## 🔧 故障排除

### 常见问题

1. **服务启动失败**
   ```bash
   # 检查端口占用
   netstat -tlnp | grep :8080
   netstat -tlnp | grep :3306
   
   # 检查Docker状态
   docker-compose ps
   docker-compose logs
   ```

2. **数据库连接失败**
   ```bash
   # 检查数据库容器状态
   docker-compose exec mysql mysql -u root -p
   docker-compose exec mongodb mongosh
   ```

3. **应用无法访问**
   ```bash
   # 检查防火墙
   firewall-cmd --list-ports
   
   # 检查Nginx配置
   docker-compose exec nginx nginx -t
   ```

### 日志分析

```bash
# 查看应用错误日志
docker-compose logs app | grep ERROR

# 查看数据库错误日志
docker-compose logs mysql | grep ERROR

# 查看Nginx访问日志
docker-compose logs nginx | grep "GET\|POST"
```

## 🔄 更新部署

### 应用更新

```bash
# 1. 停止服务
./deploy.sh stop

# 2. 更新代码
git pull origin main

# 3. 重新构建
./deploy.sh build

# 4. 启动服务
./deploy.sh start
```

### 数据库备份

```bash
# MySQL备份
docker-compose exec mysql mysqldump -u root -p xiaozhi > backup_$(date +%Y%m%d_%H%M%S).sql

# MongoDB备份
docker-compose exec mongodb mongodump --db chat_memory_db4 --out /backup/$(date +%Y%m%d_%H%M%S)
```

## 📈 性能优化

### 数据库优化

```bash
# MySQL配置优化
# 在docker-compose.yml中调整MySQL配置
environment:
  MYSQL_INNODB_BUFFER_POOL_SIZE: 256M
  MYSQL_INNODB_LOG_FILE_SIZE: 64M
```

### 应用优化

```bash
# JVM参数优化
# 在Dockerfile中调整JAVA_OPTS
ENV JAVA_OPTS="-Xms1g -Xmx2g -XX:+UseG1GC"
```

## 🔐 安全配置

### SSL证书配置

```bash
# 1. 获取SSL证书
# 将证书文件放在 nginx/ssl/ 目录下
# cert.pem - 证书文件
# key.pem - 私钥文件

# 2. 启用HTTPS配置
# 取消注释docker-compose.yml中的HTTPS配置
```

### 访问控制

```bash
# 配置Nginx访问控制
# 在nginx/conf.d/smart-education.conf中添加
location /admin {
    allow 192.168.1.0/24;
    deny all;
    proxy_pass http://smart_education_backend;
}
```

## 📞 技术支持

如果遇到问题，请检查：

1. **服务状态**: `./deploy.sh status`
2. **服务日志**: `./deploy.sh logs`
3. **网络连接**: `ping 81.70.21.208`
4. **端口开放**: `telnet 81.70.21.208 80`

## 🎯 访问地址

部署完成后，可以通过以下地址访问：

- **应用首页**: http://81.70.21.208
- **API文档**: http://81.70.21.208/doc.html
- **健康检查**: http://81.70.21.208:8080/actuator/health

---

**注意**: 请确保所有环境变量都已正确配置，特别是AI服务的API密钥和阿里云OSS配置，否则应用可能无法正常工作。


