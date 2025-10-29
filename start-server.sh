#!/bin/bash

# 服务器直接运行脚本（不用 Docker）

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================"
echo -e "  启动 AI 心理干预预测系统"
echo -e "========================================${NC}"
echo ""

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 未安装"
    echo "安装: yum install python3 python3-pip -y"
    exit 1
fi

# 安装依赖
echo -e "${GREEN}1. 安装 Python 依赖...${NC}"
cd backend
pip3 install -r requirements.txt --user

# 返回项目根目录
cd ..

# 创建日志目录
mkdir -p logs

# 启动后端
echo ""
echo -e "${GREEN}2. 启动后端服务（端口 8000）...${NC}"
nohup python3 backend/main.py > logs/backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > backend.pid

echo ""
echo -e "${GREEN}========================================"
echo -e "  ✓ 服务启动成功！"
echo -e "========================================${NC}"
echo ""
echo "后端 PID: $BACKEND_PID"
echo "后端日志: logs/backend.log"
echo ""
echo "测试后端: curl http://localhost:8000/api/users"
echo "前端文件: frontend/index.html"
echo ""
echo "停止服务: kill \$(cat backend.pid)"
echo ""
