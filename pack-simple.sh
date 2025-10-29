#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}======================================"
echo -e "  打包服务器部署文件（无 Docker）"
echo -e "======================================${NC}"

PACKAGE_NAME="ai-intervention-predictor-simple.tar.gz"

# 打包
tar -czf ../$PACKAGE_NAME \
    --exclude='node_modules' \
    --exclude='.git' \
    --exclude='*.log' \
    --exclude='*.pid' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.DS_Store' \
    --exclude='logs/*' \
    --exclude='docs/*.pptx' \
    --exclude='.specstory' \
    --exclude='docker-compose.yml' \
    --exclude='Dockerfile' \
    --exclude='.dockerignore' \
    --exclude='*docker*' \
    backend/ \
    frontend/ \
    database/ \
    .env \
    start-server.sh \
    stop-server.sh \
    nginx-simple.conf \
    README.md

echo ""
echo -e "${GREEN}======================================"
echo -e "  ✓ 打包完成！"
echo -e "======================================${NC}"
echo ""
echo -e "文件: ${BLUE}../$PACKAGE_NAME${NC}"
echo -e "大小: ${BLUE}$(du -h ../$PACKAGE_NAME | awk '{print $1}')${NC}"
echo ""
echo -e "${GREEN}部署步骤：${NC}"
echo ""
echo "1. 上传："
echo -e "   ${BLUE}scp ../$PACKAGE_NAME root@101.42.230.29:/home/${NC}"
echo ""
echo "2. 服务器上解压："
echo -e "   ${BLUE}cd /home && rm -rf ai-intervention-predictor${NC}"
echo -e "   ${BLUE}mkdir ai-intervention-predictor && cd ai-intervention-predictor${NC}"
echo -e "   ${BLUE}tar -xzf ../$PACKAGE_NAME${NC}"
echo ""
echo "3. 安装系统依赖："
echo -e "   ${BLUE}yum install python3 python3-pip nginx mysql -y${NC}"
echo ""
echo "4. 导入数据库："
echo -e "   ${BLUE}mysql -uai_predictor -pxR6NaN3HC4pDRsNB ai_predictor < database/schema.sql${NC}"
echo -e "   ${BLUE}mysql -uai_predictor -pxR6NaN3HC4pDRsNB ai_predictor < database/mock_data.sql${NC}"
echo ""
echo "5. 配置 Nginx："
echo -e "   ${BLUE}cp nginx-simple.conf /etc/nginx/conf.d/ai-predictor.conf${NC}"
echo -e "   ${BLUE}nginx -t && systemctl restart nginx${NC}"
echo ""
echo "6. 启动服务："
echo -e "   ${BLUE}./start-server.sh${NC}"
echo ""
echo "7. 访问："
echo -e "   ${BLUE}http://101.42.230.29${NC}"
echo ""
