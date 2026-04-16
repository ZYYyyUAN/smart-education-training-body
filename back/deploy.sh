#!/bin/bash

# 智能教育系统Docker部署脚本
# 使用方法: ./deploy.sh [start|stop|restart|build|logs]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose未安装，请先安装Docker Compose"
        exit 1
    fi
    
    log_info "Docker环境检查通过"
}

# 检查环境变量文件
check_env() {
    if [ ! -f ".env" ]; then
        log_warn "未找到.env文件，正在创建..."
        if [ -f "env.example" ]; then
            cp env.example .env
            log_warn "请编辑.env文件，填入正确的配置信息"
            log_warn "特别是AI服务的API密钥和阿里云OSS配置"
            read -p "按回车键继续，或Ctrl+C退出编辑配置..."
        else
            log_error "未找到env.example文件"
            exit 1
        fi
    fi
    log_info "环境变量文件检查通过"
}

# 构建应用
build_app() {
    log_step "开始构建Spring Boot应用..."
    
    # 检查Maven是否安装
    if ! command -v mvn &> /dev/null; then
        log_error "Maven未安装，请先安装Maven"
        exit 1
    fi
    
    # 清理并编译
    log_info "清理项目..."
    mvn clean
    
    log_info "编译项目..."
    mvn compile
    
    log_info "打包项目..."
    mvn package -DskipTests
    
    log_info "应用构建完成"
}

# 启动服务
start_services() {
    log_step "启动所有服务..."
    
    # 创建必要的目录
    mkdir -p nginx/ssl
    mkdir -p uploads
    
    # 启动服务
    docker-compose up -d
    
    log_info "等待服务启动..."
    sleep 10
    
    # 检查服务状态
    check_services
}

# 停止服务
stop_services() {
    log_step "停止所有服务..."
    docker-compose down
    log_info "所有服务已停止"
}

# 重启服务
restart_services() {
    log_step "重启所有服务..."
    docker-compose restart
    log_info "所有服务已重启"
}

# 检查服务状态
check_services() {
    log_step "检查服务状态..."
    
    # 检查容器状态
    docker-compose ps
    
    # 检查应用健康状态
    log_info "检查应用健康状态..."
    if curl -f http://localhost:8080/actuator/health &> /dev/null; then
        log_info "应用健康检查通过"
    else
        log_warn "应用健康检查失败，请查看日志"
    fi
    
    # 检查数据库连接
    log_info "检查数据库连接..."
    if docker-compose exec mysql mysqladmin ping -h localhost &> /dev/null; then
        log_info "MySQL数据库连接正常"
    else
        log_warn "MySQL数据库连接失败"
    fi
    
    if docker-compose exec mongodb mongosh --eval "db.runCommand('ping')" &> /dev/null; then
        log_info "MongoDB数据库连接正常"
    else
        log_warn "MongoDB数据库连接失败"
    fi
}

# 查看日志
view_logs() {
    log_step "查看服务日志..."
    docker-compose logs -f
}

# 清理资源
cleanup() {
    log_step "清理Docker资源..."
    docker-compose down -v
    docker system prune -f
    log_info "清理完成"
}

# 显示帮助信息
show_help() {
    echo "智能教育系统Docker部署脚本"
    echo ""
    echo "使用方法: $0 [命令]"
    echo ""
    echo "可用命令:"
    echo "  start     - 启动所有服务"
    echo "  stop      - 停止所有服务"
    echo "  restart   - 重启所有服务"
    echo "  build     - 构建应用"
    echo "  logs      - 查看服务日志"
    echo "  status    - 检查服务状态"
    echo "  cleanup   - 清理Docker资源"
    echo "  help      - 显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 start    # 启动服务"
    echo "  $0 logs     # 查看日志"
    echo "  $0 status   # 检查状态"
}

# 主函数
main() {
    case "${1:-help}" in
        start)
            check_docker
            check_env
            build_app
            start_services
            ;;
        stop)
            stop_services
            ;;
        restart)
            restart_services
            ;;
        build)
            check_docker
            build_app
            ;;
        logs)
            view_logs
            ;;
        status)
            check_services
            ;;
        cleanup)
            cleanup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"


