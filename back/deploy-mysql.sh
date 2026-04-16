#!/bin/bash

# MySQL数据库单独部署脚本
# 使用方法: ./deploy-mysql.sh [start|stop|restart|status|logs|connect]

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

# 启动MySQL
start_mysql() {
    log_step "启动MySQL数据库..."
    
    # 检查端口是否被占用
    if netstat -tlnp 2>/dev/null | grep -q ":3306 "; then
        log_warn "端口3306已被占用，请检查是否有其他MySQL服务运行"
        netstat -tlnp | grep ":3306"
        read -p "是否继续？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # 启动MySQL容器
    docker-compose -f docker-compose-mysql.yml up -d
    
    log_info "等待MySQL启动..."
    sleep 10
    
    # 检查容器状态
    if docker-compose -f docker-compose-mysql.yml ps | grep -q "Up"; then
        log_info "MySQL容器启动成功"
    else
        log_error "MySQL容器启动失败"
        docker-compose -f docker-compose-mysql.yml logs mysql
        exit 1
    fi
    
    # 等待数据库完全启动
    log_info "等待数据库完全启动..."
    for i in {1..30}; do
        if docker-compose -f docker-compose-mysql.yml exec mysql mysqladmin ping -h localhost --silent; then
            log_info "MySQL数据库已就绪"
            break
        fi
        echo -n "."
        sleep 2
    done
    
    # 检查数据库初始化
    check_database_init
}

# 停止MySQL
stop_mysql() {
    log_step "停止MySQL数据库..."
    docker-compose -f docker-compose-mysql.yml down
    log_info "MySQL数据库已停止"
}

# 重启MySQL
restart_mysql() {
    log_step "重启MySQL数据库..."
    docker-compose -f docker-compose-mysql.yml restart
    log_info "MySQL数据库已重启"
}

# 检查MySQL状态
check_status() {
    log_step "检查MySQL状态..."
    
    # 检查容器状态
    docker-compose -f docker-compose-mysql.yml ps
    
    # 检查数据库连接
    if docker-compose -f docker-compose-mysql.yml exec mysql mysqladmin ping -h localhost --silent; then
        log_info "MySQL数据库连接正常"
    else
        log_warn "MySQL数据库连接失败"
    fi
    
    # 检查数据库和表
    check_database_init
}

# 检查数据库初始化
check_database_init() {
    log_info "检查数据库初始化状态..."
    
    # 检查数据库是否存在
    DB_EXISTS=$(docker-compose -f docker-compose-mysql.yml exec mysql mysql -u root -proot123456 -e "SHOW DATABASES LIKE 'xiaozhi';" -s 2>/dev/null | wc -l)
    
    if [ "$DB_EXISTS" -gt 0 ]; then
        log_info "数据库 'xiaozhi' 已存在"
        
        # 检查表数量
        TABLE_COUNT=$(docker-compose -f docker-compose-mysql.yml exec mysql mysql -u root -proot123456 -e "USE xiaozhi; SHOW TABLES;" -s 2>/dev/null | wc -l)
        log_info "数据库中有 $TABLE_COUNT 个表"
        
        if [ "$TABLE_COUNT" -gt 0 ]; then
            log_info "数据库初始化完成"
        else
            log_warn "数据库为空，可能需要手动初始化"
        fi
    else
        log_warn "数据库 'xiaozhi' 不存在"
    fi
}

# 连接MySQL
connect_mysql() {
    log_step "连接到MySQL数据库..."
    docker-compose -f docker-compose-mysql.yml exec mysql mysql -u root -proot123456
}

# 查看日志
view_logs() {
    log_step "查看MySQL日志..."
    docker-compose -f docker-compose-mysql.yml logs -f mysql
}

# 备份数据库
backup_database() {
    log_step "备份数据库..."
    BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
    docker-compose -f docker-compose-mysql.yml exec mysql mysqldump -u root -proot123456 xiaozhi > "$BACKUP_FILE"
    log_info "数据库已备份到: $BACKUP_FILE"
}

# 恢复数据库
restore_database() {
    if [ -z "$1" ]; then
        log_error "请指定备份文件路径"
        echo "使用方法: $0 restore <backup_file>"
        exit 1
    fi
    
    log_step "恢复数据库..."
    docker-compose -f docker-compose-mysql.yml exec -T mysql mysql -u root -proot123456 xiaozhi < "$1"
    log_info "数据库恢复完成"
}

# 显示帮助信息
show_help() {
    echo "MySQL数据库部署脚本"
    echo ""
    echo "使用方法: $0 [命令]"
    echo ""
    echo "可用命令:"
    echo "  start     - 启动MySQL数据库"
    echo "  stop      - 停止MySQL数据库"
    echo "  restart   - 重启MySQL数据库"
    echo "  status    - 检查MySQL状态"
    echo "  connect   - 连接到MySQL数据库"
    echo "  logs      - 查看MySQL日志"
    echo "  backup    - 备份数据库"
    echo "  restore   - 恢复数据库"
    echo "  help      - 显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 start              # 启动MySQL"
    echo "  $0 status             # 检查状态"
    echo "  $0 connect            # 连接数据库"
    echo "  $0 backup             # 备份数据库"
    echo "  $0 restore backup.sql # 恢复数据库"
}

# 主函数
main() {
    case "${1:-help}" in
        start)
            check_docker
            start_mysql
            ;;
        stop)
            stop_mysql
            ;;
        restart)
            restart_mysql
            ;;
        status)
            check_status
            ;;
        connect)
            connect_mysql
            ;;
        logs)
            view_logs
            ;;
        backup)
            backup_database
            ;;
        restore)
            restore_database "$2"
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


