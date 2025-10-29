#!/bin/bash
# Docker 部署包打包脚本

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}======================================"
echo -e "  打包 Docker 部署文件"
echo -e "======================================${NC}"
echo ""

# 打包文件
PACKAGE_NAME="ai-intervention-predictor-docker.tar.gz"
DIR_NAME="ai-intervention-predictor-docker"

# 获取当前脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="$OUTPUT_DIR/$PACKAGE_NAME"

echo -e "${GREEN}正在打包...${NC}"

# 创建临时目录结构（兼容 macOS 和 Linux）
TEMP_DIR="/tmp/${DIR_NAME}_$$"
mkdir -p "$TEMP_DIR/$DIR_NAME"

# 复制文件到临时目录
echo "复制文件..."
cp -r "$SCRIPT_DIR/backend" "$TEMP_DIR/$DIR_NAME/"
cp -r "$SCRIPT_DIR/frontend" "$TEMP_DIR/$DIR_NAME/"
cp -r "$SCRIPT_DIR/database" "$TEMP_DIR/$DIR_NAME/"
[ -f "$SCRIPT_DIR/Dockerfile" ] && cp "$SCRIPT_DIR/Dockerfile" "$TEMP_DIR/$DIR_NAME/"
cp "$SCRIPT_DIR/docker-compose.yml" "$TEMP_DIR/$DIR_NAME/"
cp "$SCRIPT_DIR/nginx.conf" "$TEMP_DIR/$DIR_NAME/"
[ -f "$SCRIPT_DIR/.dockerignore" ] && cp "$SCRIPT_DIR/.dockerignore" "$TEMP_DIR/$DIR_NAME/"
cp "$SCRIPT_DIR/.env" "$TEMP_DIR/$DIR_NAME/"
cp "$SCRIPT_DIR/env.docker.example" "$TEMP_DIR/$DIR_NAME/"
[ -f "$SCRIPT_DIR/deploy-docker.sh" ] && cp "$SCRIPT_DIR/deploy-docker.sh" "$TEMP_DIR/$DIR_NAME/"
cp "$SCRIPT_DIR/README-Docker.md" "$TEMP_DIR/$DIR_NAME/"

# 清理不需要的文件
find "$TEMP_DIR/$DIR_NAME" -name "*.pyc" -delete 2>/dev/null
find "$TEMP_DIR/$DIR_NAME" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find "$TEMP_DIR/$DIR_NAME" -name ".DS_Store" -delete 2>/dev/null || true
find "$TEMP_DIR/$DIR_NAME" -name "*.log" -delete 2>/dev/null || true

# 打包
cd "$TEMP_DIR"
tar -czf "$PACKAGE_NAME" "$DIR_NAME"

# 移动到输出目录
mv "$PACKAGE_NAME" "$OUTPUT_FILE"

# 清理临时目录
rm -rf "$TEMP_DIR"
cd "$SCRIPT_DIR" > /dev/null

echo ""
echo -e "${GREEN}======================================"
echo -e "  ✓ 打包完成！"
echo -e "======================================${NC}"
echo ""
echo -e "文件名: ${BLUE}$PACKAGE_NAME${NC}"
echo -e "位置:   ${BLUE}$OUTPUT_FILE${NC}"
echo ""

# 显示文件大小
SIZE=$(du -h "$OUTPUT_FILE" | awk '{print $1}')
echo -e "大小:   ${BLUE}$SIZE${NC}"
echo ""

echo -e "${GREEN}使用方法：${NC}"
echo ""
echo "1. 上传到服务器："
echo -e "   ${BLUE}scp $OUTPUT_FILE root@101.42.230.29:/home/${NC}"
echo ""
echo "2. 解压并部署："
echo -e "   ${BLUE}cd /home${NC}"
echo -e "   ${BLUE}tar -xzf $PACKAGE_NAME${NC}"
echo -e "   ${BLUE}cd ai-intervention-predictor-docker${NC}"
echo ""
echo "3. （可选）修改配置："
echo -e "   ${BLUE}nano .env${NC}"
echo -e "   ${BLUE}# 如需修改数据库 IP 或 AI_API_KEY${NC}"
echo ""
echo "4. 导入数据库："
echo -e "   ${BLUE}mysql -uai_predictor -pxR6NaN3HC4pDRsNB ai_predictor < database/schema.sql${NC}"
echo -e "   ${BLUE}mysql -uai_predictor -pxR6NaN3HC4pDRsNB ai_predictor < database/mock_data.sql${NC}"
echo ""
echo "5. 启动服务："
echo -e "   ${BLUE}docker-compose up -d${NC}"
echo ""
echo "6. 访问："
echo -e "   ${BLUE}http://101.42.230.29:3000${NC}"
echo ""
echo -e "${GREEN}完成！${NC}"

