#!/bin/bash
# AI 配置快速切换脚本 - 自动切换配置

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  AI 配置切换工具${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# 显示当前配置
if [ -f .env ]; then
    current_provider=$(grep "^AI_PROVIDER=" .env | cut -d'=' -f2)
    current_model=$(grep "^AI_MODEL=" .env | cut -d'=' -f2)
    echo -e "${GREEN}当前配置：${NC}"
    echo -e "  提供商: ${YELLOW}$current_provider${NC}"
    echo -e "  模型:   ${YELLOW}$current_model${NC}"
    echo ""
fi

echo "请选择 AI 配置："
echo ""
echo -e "  ${YELLOW}1)${NC} Ollama 本地 (免费)"
echo -e "  ${YELLOW}2)${NC} DeepSeek API (便宜快速)"
echo -e "  ${YELLOW}3)${NC} SiliconFlow (国内加速)"
echo -e "  ${YELLOW}4)${NC} OpenAI GPT-4"
echo -e "  ${YELLOW}5)${NC} 通义千问"
echo -e "  ${YELLOW}6)${NC} 手动编辑 .env"
echo -e "  ${YELLOW}0)${NC} 退出"
echo ""
read -p "请输入选项 [0-6]: " choice

# 先注释掉所有 AI 配置
comment_all_ai_config() {
    sed -i.bak \
        -e 's/^AI_PROVIDER=/#AI_PROVIDER=/' \
        -e 's/^AI_MODEL=/#AI_MODEL=/' \
        -e 's/^AI_API_KEY=/#AI_API_KEY=/' \
        -e 's/^AI_BASE_URL=/#AI_BASE_URL=/' \
        .env
    rm .env.bak 2>/dev/null || true
}

# 取消指定提供商的注释
uncomment_provider() {
    local provider=$1
    local in_section=0
    local temp_file=$(mktemp)
    
    while IFS= read -r line; do
        # 检测是否进入对应的配置区域
        if [[ $line == *"方式"* ]] && [[ $line == *"$provider"* ]]; then
            in_section=1
            echo "$line"
        # 检测是否进入下一个配置区域
        elif [[ $line == *"方式"* ]] && [[ $in_section -eq 1 ]]; then
            in_section=0
            echo "$line"
        # 如果在目标区域内，取消注释
        elif [[ $in_section -eq 1 ]] && [[ $line == \#AI_* ]]; then
            echo "${line:1}"  # 去掉开头的 #
        else
            echo "$line"
        fi
    done < .env > "$temp_file"
    
    mv "$temp_file" .env
}

case $choice in
    1)
        provider="Ollama"
        echo ""
        echo -e "${GREEN}✓${NC} 切换到 Ollama"
        echo -e "${YELLOW}提示：${NC}请确保已运行 ${BLUE}ollama serve${NC}"
        
        comment_all_ai_config
        uncomment_provider "Ollama"
        ;;
    2)
        provider="DeepSeek"
        echo ""
        echo -e "${GREEN}✓${NC} 切换到 DeepSeek API"
        
        # 检查是否有 API Key
        has_key=$(grep -A 3 "方式.*DeepSeek" .env | grep "AI_API_KEY=" | grep -v "sk-your-" || true)
        if [ -z "$has_key" ]; then
            echo -e "${RED}⚠️  未检测到 DeepSeek API Key${NC}"
            read -p "请输入 DeepSeek API Key: " api_key
            if [ -n "$api_key" ]; then
                # 更新 API Key
                sed -i.bak "/方式.*DeepSeek/,/方式[^DeepSeek]/s|AI_API_KEY=.*|AI_API_KEY=$api_key|" .env
                rm .env.bak 2>/dev/null || true
            fi
        fi
        
        comment_all_ai_config
        uncomment_provider "DeepSeek"
        ;;
    3)
        provider="SiliconFlow"
        echo ""
        echo -e "${GREEN}✓${NC} 切换到 SiliconFlow"
        
        comment_all_ai_config
        uncomment_provider "SiliconFlow"
        ;;
    4)
        provider="OpenAI"
        echo ""
        echo -e "${GREEN}✓${NC} 切换到 OpenAI GPT-4"
        
        # 检查是否有 API Key
        has_key=$(grep -A 3 "方式.*OpenAI" .env | grep "AI_API_KEY=" | grep -v "sk-your-" || true)
        if [ -z "$has_key" ]; then
            echo -e "${RED}⚠️  未检测到 OpenAI API Key${NC}"
            read -p "请输入 OpenAI API Key: " api_key
            if [ -n "$api_key" ]; then
                sed -i.bak "/方式.*OpenAI/,/方式[^OpenAI]/s|AI_API_KEY=.*|AI_API_KEY=$api_key|" .env
                rm .env.bak 2>/dev/null || true
            fi
        fi
        
        comment_all_ai_config
        uncomment_provider "OpenAI"
        ;;
    5)
        provider="通义千问"
        echo ""
        echo -e "${GREEN}✓${NC} 切换到通义千问"
        
        # 检查是否有 API Key
        has_key=$(grep -A 3 "方式.*通义千问" .env | grep "AI_API_KEY=" | grep -v "sk-your-" || true)
        if [ -z "$has_key" ]; then
            echo -e "${RED}⚠️  未检测到通义千问 API Key${NC}"
            read -p "请输入通义千问 API Key: " api_key
            if [ -n "$api_key" ]; then
                sed -i.bak "/方式.*通义千问/,/方式[^通义千问]/s|AI_API_KEY=.*|AI_API_KEY=$api_key|" .env
                rm .env.bak 2>/dev/null || true
            fi
        fi
        
        comment_all_ai_config
        uncomment_provider "通义千问"
        ;;
    6)
        echo ""
        echo -e "${GREEN}✓${NC} 打开编辑器"
        ${EDITOR:-nano} .env
        echo -e "${GREEN}完成！${NC}"
        exit 0
        ;;
    0)
        exit 0
        ;;
    *)
        echo -e "${RED}✗${NC} 无效选项"
        exit 1
        ;;
esac

# 显示新配置
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}新配置已生效：${NC}"
echo -e "${CYAN}========================================${NC}"
new_provider=$(grep "^AI_PROVIDER=" .env | cut -d'=' -f2)
new_model=$(grep "^AI_MODEL=" .env | cut -d'=' -f2)
new_url=$(grep "^AI_BASE_URL=" .env | cut -d'=' -f2)
echo -e "  提供商: ${YELLOW}$new_provider${NC}"
echo -e "  模型:   ${YELLOW}$new_model${NC}"
echo -e "  URL:    ${YELLOW}$new_url${NC}"
echo ""

# 询问是否重启服务
read -p "是否重启后端服务？[y/N]: " restart
if [[ $restart =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BLUE}正在重启服务...${NC}"
    
    if [ -f server.pid ]; then
        old_pid=$(cat server.pid)
        kill $old_pid 2>/dev/null || true
        echo -e "${GREEN}✓${NC} 已停止旧服务 (PID: $old_pid)"
        sleep 2
    fi
    
    nohup python3 backend/main.py > server.log 2>&1 &
    new_pid=$!
    echo $new_pid > server.pid
    sleep 2
    
    if ps -p $new_pid > /dev/null 2>&1; then
        echo -e "${GREEN}✓ 服务已启动 (PID: $new_pid)${NC}"
        echo -e "  日志: ${BLUE}tail -f server.log${NC}"
    else
        echo -e "${RED}✗ 服务启动失败${NC}"
        echo "  查看日志: tail server.log"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}完成！${NC}"
