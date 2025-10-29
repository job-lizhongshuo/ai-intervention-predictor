#!/bin/bash

# AI心理干预效果预测系统 - 管理脚本
# 使用方法: ./manage.sh {start|stop|restart|status|logs}

# 配置
PROJECT_DIR="/Users/caoziyang/Desktop/work/ai-intervention-predictor"
BACKEND_DIR="${PROJECT_DIR}/backend"
FRONTEND_FILE="${PROJECT_DIR}/frontend/index.html"
PID_FILE="${PROJECT_DIR}/server.pid"
LOG_FILE="${PROJECT_DIR}/server.log"
PORT=8000

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查进程是否运行
is_running() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            return 0
        else
            rm -f "$PID_FILE"
            return 1
        fi
    fi
    return 1
}

# 启动服务
start() {
    log_info "正在启动 AI心理干预效果预测系统..."
    
    # 检查是否已经运行
    if is_running; then
        log_warning "服务已经在运行中 (PID: $(cat $PID_FILE))"
        return 1
    fi
    
    # 检查端口是否被占用
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        log_warning "端口 $PORT 已被占用，正在尝试释放..."
        lsof -ti:$PORT | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
    
    # 切换到后端目录
    cd "$BACKEND_DIR" || {
        log_error "无法进入后端目录: $BACKEND_DIR"
        exit 1
    }
    
    # 检查Python和依赖
    if ! command -v python3 &> /dev/null; then
        log_error "未找到 python3，请先安装 Python 3"
        exit 1
    fi
    
    # 启动后端服务（后台运行）
    log_info "启动后端服务..."
    nohup python3 main.py > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    
    # 等待服务启动
    sleep 3
    
    # 检查是否成功启动
    if is_running; then
        log_success "后端服务启动成功！"
        log_info "服务地址: http://localhost:$PORT"
        log_info "API文档: http://localhost:$PORT/docs"
        log_info "PID: $(cat $PID_FILE)"
        log_info "日志文件: $LOG_FILE"
        
        # 自动打开前端页面
        log_info "正在打开前端页面..."
        sleep 1
        open "$FRONTEND_FILE"
        log_success "系统启动完成！"
    else
        log_error "后端服务启动失败，请查看日志: $LOG_FILE"
        rm -f "$PID_FILE"
        exit 1
    fi
}

# 停止服务
stop() {
    log_info "正在停止服务..."
    
    if ! is_running; then
        log_warning "服务未运行"
        return 0
    fi
    
    PID=$(cat "$PID_FILE")
    log_info "停止进程 PID: $PID"
    
    # 尝试优雅停止
    kill "$PID" 2>/dev/null
    
    # 等待进程结束
    for i in {1..10}; do
        if ! ps -p "$PID" > /dev/null 2>&1; then
            break
        fi
        sleep 1
    done
    
    # 如果还在运行，强制结束
    if ps -p "$PID" > /dev/null 2>&1; then
        log_warning "进程未响应，强制结束..."
        kill -9 "$PID" 2>/dev/null
    fi
    
    # 清理PID文件
    rm -f "$PID_FILE"
    
    # 确保端口释放
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        log_info "清理端口 $PORT..."
        lsof -ti:$PORT | xargs kill -9 2>/dev/null || true
    fi
    
    log_success "服务已停止"
}

# 重启服务
restart() {
    log_info "正在重启服务..."
    stop
    sleep 2
    start
}

# 查看状态
status() {
    echo "========================================="
    echo "  AI心理干预效果预测系统 - 服务状态"
    echo "========================================="
    
    if is_running; then
        PID=$(cat "$PID_FILE")
        log_success "服务状态: 运行中"
        echo "PID: $PID"
        echo "端口: $PORT"
        echo "运行时间: $(ps -o etime= -p $PID)"
        echo "内存使用: $(ps -o rss= -p $PID | awk '{printf "%.2f MB", $1/1024}')"
        
        # 测试API连通性
        if curl -s http://localhost:$PORT/ > /dev/null 2>&1; then
            log_success "API服务: 正常"
        else
            log_error "API服务: 异常"
        fi
    else
        log_warning "服务状态: 未运行"
    fi
    
    echo "========================================="
}

# 查看日志
logs() {
    if [ ! -f "$LOG_FILE" ]; then
        log_warning "日志文件不存在: $LOG_FILE"
        return 1
    fi
    
    # 默认显示最后50行
    LINES=${1:-50}
    
    log_info "显示最后 $LINES 行日志 (按 Ctrl+C 退出)"
    echo "========================================="
    tail -n "$LINES" -f "$LOG_FILE"
}

# 清理日志
clean() {
    log_info "正在清理日志文件..."
    
    if [ -f "$LOG_FILE" ]; then
        > "$LOG_FILE"
        log_success "日志已清理"
    else
        log_info "无需清理"
    fi
}

# 主函数
case "${1}" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    logs)
        logs "${2}"
        ;;
    clean)
        clean
        ;;
    *)
        echo "AI心理干预效果预测系统 - 管理脚本"
        echo ""
        echo "使用方法: $0 {start|stop|restart|status|logs|clean}"
        echo ""
        echo "命令说明："
        echo "  start    - 启动服务（后端+前端）"
        echo "  stop     - 停止服务"
        echo "  restart  - 重启服务"
        echo "  status   - 查看服务状态"
        echo "  logs [n] - 查看日志（默认最后50行）"
        echo "  clean    - 清理日志文件"
        echo ""
        echo "示例："
        echo "  $0 start          # 启动服务"
        echo "  $0 logs 100       # 查看最后100行日志"
        echo ""
        exit 1
        ;;
esac

exit 0

