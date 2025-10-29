# 🧠 AI 心理干预效果预测系统

> 基于人工智能的心理干预效果评估与预测平台 | 专业版 v2.0

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-green.svg)](https://fastapi.tiangolo.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📖 目录

- [项目简介](#-项目简介)
- [核心功能](#-核心功能)
- [快速启动](#-快速启动)
- [技术架构](#️-技术架构)
- [环境配置](#-环境配置)
- [AI配置切换](#-ai配置切换)
- [响应式设计](#-响应式设计)
- [管理命令](#-管理命令)
- [服务器部署](#-服务器部署)
- [常见问题](#-常见问题)
- [演示说明](#-演示说明)

---

## 🎯 项目简介

本系统利用AI大语言模型（Qwen/DeepSeek）对青少年焦虑心理干预效果进行智能预测与评估。

### **核心价值**

- ✅ **提前预测** - 仅需前3周数据，即可预测8周后干预效果
- ✅ **AI专家分析** - 大语言模型提供专业级评估报告
- ✅ **个性化建议** - 针对每个用户生成具体干预建议
- ✅ **风险预警** - 实时识别高风险用户，及时调整方案
- ✅ **数据可视化** - Chart.js图表展示干预进度趋势

### **应用场景**

- 🏫 学校心理干预项目效果评估
- 🏥 医院心理治疗方案优化
- 🔬 心理学研究数据分析
- 💼 心理咨询机构效果跟踪

---

## ✨ 核心功能

### 1️⃣ **AI效果预测**
- 预测后测分数区间（最小值/最可能值/最大值）
- 预测改善幅度和改善率（百分比）
- AI置信度评估（0-100%）

### 2️⃣ **智能分析**
- 当前干预进展评价（良好/一般/较差）
- 风险等级评估（低/中/高风险）
- 学习参与度分析（打卡率、学习时长）

### 3️⃣ **专业建议**
- AI生成个性化干预建议（3-5条）
- 学习频率优化建议
- 中期评估时间建议

### 4️⃣ **数据可视化**
- 焦虑分数趋势曲线（GAD-7量表）
- 学习活跃度曲线（双Y轴对比）
- 实时统计面板（总用户/完成率/改善率/成功率）

---

## 🚀 快速启动

### **一键启动（推荐）**

```bash
cd /Users/caoziyang/Desktop/work/ai-intervention-predictor
./manage.sh start
```

**自动完成：**
- ✅ 检查并释放端口8000
- ✅ 后台启动后端服务
- ✅ 自动打开前端页面
- ✅ 服务稳定运行

**等待3-5秒，浏览器会自动打开系统页面！**

---

## 🛠️ 技术架构

### **整体架构**

```
┌─────────────────────────────────────────┐
│           前端（纯静态页面）             │
│  - HTML + CSS + JavaScript              │
│  - Chart.js 数据可视化                  │
│  - 响应式设计                           │
└───────────────┬─────────────────────────┘
                │ HTTP API
┌───────────────▼─────────────────────────┐
│           后端（FastAPI）                │
│  - RESTful API                          │
│  - AI服务调用                           │
│  - 数据库操作                           │
└───────────────┬─────────────────────────┘
                │
        ┌───────┴────────┐
        │                │
┌───────▼─────┐  ┌──────▼──────┐
│ MySQL数据库 │  │ AI大语言模型 │
│ - 用户数据  │  │ - Qwen 2.5  │
│ - 评估记录  │  │ - SiliconFlow│
│ - 学习日志  │  │   API       │
└─────────────┘  └─────────────┘
```

### **技术栈**

| 层级 | 技术 | 说明 |
|------|------|------|
| **前端** | HTML5 + CSS3 + JavaScript | 单页面应用 |
| **可视化** | Chart.js 4.4 | 趋势图表 |
| **后端** | Python 3.8+ FastAPI | 高性能Web框架 |
| **AI模型** | Qwen2.5-7B-Instruct | 通义千问大模型 |
| **API服务** | SiliconFlow | 国内免费AI推理平台 |
| **数据库** | MySQL 8.0 | 关系型数据库 |
| **ORM** | PyMySQL | Python MySQL驱动 |

### **项目结构**

```
ai-intervention-predictor/
├── manage.sh              # ⭐ 一键管理脚本
├── server.pid             # 服务进程ID（自动生成）
├── server.log             # 服务日志（自动生成）
│
├── backend/               # 后端代码
│   ├── main.py           # FastAPI主应用
│   ├── ai_service.py     # AI服务（支持多种模型）
│   ├── database.py       # 数据库操作
│   ├── config.py         # 配置管理
│   ├── .env              # 环境变量（需手动创建）
│   └── requirements.txt  # Python依赖
│
├── frontend/              # 前端代码
│   └── index.html        # 单页面应用（包含所有功能）
│
├── database/              # 数据库脚本
│   ├── schema.sql        # 数据库表结构
│   ├── mock_data.sql     # 模拟数据（100个用户）
│   └── README.md         # 数据库说明
│
└── README.md             # 本文档
```

---

## 🔧 环境配置

### **1. 安装Python依赖**

```bash
cd backend
pip3 install -r requirements.txt
```

**依赖列表：**
```
fastapi>=0.104.0
uvicorn[standard]>=0.24.0
pydantic>=2.0.0
pymysql>=1.1.0
openai>=1.0.0
python-dotenv>=1.0.0
```

### **2. 配置环境变量**

创建 `backend/.env` 文件：

```bash
# 数据库配置
DB_HOST=你的数据库IP          # 例如：192.168.1.100
DB_PORT=3306
DB_USER=root
DB_PASSWORD=你的数据库密码
DB_NAME=ai_predictor

# AI配置（已配好，可直接使用）
AI_PROVIDER=siliconflow
AI_API_KEY=sk-cyqaibkxefnxbrxubqrdagxwblqhsenytrwomlnseqhbmace
AI_BASE_URL=https://api.siliconflow.cn/v1
AI_MODEL=Qwen/Qwen2.5-7B-Instruct
```

### **3. 初始化数据库**

**方式1：本地数据库**
```bash
# 1. 创建数据库
mysql -u root -p
CREATE DATABASE ai_predictor DEFAULT CHARACTER SET utf8mb4;

# 2. 导入表结构
mysql -u root -p ai_predictor < database/schema.sql

# 3. 导入模拟数据
mysql -u root -p ai_predictor < database/mock_data.sql
```

**方式2：远程数据库**
```bash
# 将以下命令在远程MySQL服务器上执行：
# 参考 database/README.md
```

---

## 🎨 AI配置切换

### **快速切换 AI 提供商**

系统支持多种 AI 提供商，只需编辑一个 `.env` 文件即可切换：

```bash
# 编辑配置文件
nano .env
```

### **方法1：手动切换（推荐）**

**步骤**：
1. 找到想用的 AI 配置（如 DeepSeek）
2. 取消对应4行的注释（删除 `#`）
3. 注释掉其他配置（保留 API Key）

**示例：**
```bash
# 当前使用 SiliconFlow
AI_PROVIDER=siliconflow
AI_MODEL=Qwen/Qwen2.5-7B-Instruct
AI_API_KEY=sk-your-key
AI_BASE_URL=https://api.siliconflow.cn/v1

# 其他配置保持注释
#AI_PROVIDER=deepseek
#AI_MODEL=deepseek-chat
#AI_API_KEY=sk-your-deepseek-key
#AI_BASE_URL=https://api.deepseek.com
```

### **方法2：使用脚本**

```bash
./switch_ai.sh
```

选择数字，自动切换配置并重启服务。

### **支持的 AI 提供商**

| 提供商 | 成本 | 速度 | 说明 |
|--------|------|------|------|
| **SiliconFlow** | 有免费额度 | ⭐⭐⭐⭐ | 推荐，国内快速 |
| **DeepSeek** | ~¥0.001/1K | ⭐⭐⭐⭐⭐ | 便宜快速 |
| **Ollama** | 免费 | ⭐⭐⭐ | 本地运行 |
| **OpenAI** | 贵 | ⭐⭐⭐⭐⭐ | GPT-4，效果最好 |
| **通义千问** | 中等 | ⭐⭐⭐⭐ | 阿里云 |

**切换后重启服务：**
```bash
./manage.sh restart
```

---

## 📱 响应式设计

### **多设备支持**

前端页面完全响应式，支持所有设备：
- 📱 手机（375px+）
- 📱 平板（768px+）
- 💻 笔记本（1024px+）
- 🖥️ 台式机（1400px+）

### **响应式断点**

| 屏幕宽度 | 布局 | 优化 |
|---------|------|------|
| **> 1200px** | 多列 | 完整功能 |
| **768-1200px** | 单/双列 | 紧凑布局 |
| **480-768px** | 单列 | 优化字体 |
| **< 480px** | 单列 | 最小布局 |

### **移动端优化**

- ✅ 系统简介 - 单列显示，字体自适应
- ✅ 用户列表 - 上下布局，触摸优化
- ✅ 预测区域 - 单列网格，防溢出
- ✅ 配置面板 - 全屏显示，表单优化
- ✅ 图表 - 横向滚动，触摸缩放

### **测试响应式**

```bash
# 浏览器测试
1. F12 打开开发者工具
2. Ctrl+Shift+M 切换设备模式
3. 选择设备：iPhone、iPad等
```

---

## 🎮 管理命令

我们提供了便捷的 `manage.sh` 脚本管理整个系统：

### **启动服务**
```bash
./manage.sh start
```
- ✅ 自动检测并释放端口
- ✅ 后台启动后端服务
- ✅ 自动打开前端页面

### **停止服务**
```bash
./manage.sh stop
```
- ✅ 优雅停止后端进程
- ✅ 释放端口8000
- ✅ 清理PID文件

### **重启服务**
```bash
./manage.sh restart
```
- ✅ 先停止再启动
- ✅ 适合代码更新后重启

### **查看状态**
```bash
./manage.sh status
```

**示例输出：**
```
=========================================
  AI心理干预效果预测系统 - 服务状态
=========================================
[SUCCESS] 服务状态: 运行中
PID: 12345
端口: 8000
运行时间: 00:15:32
内存使用: 45.23 MB
[SUCCESS] API服务: 正常
=========================================
```

### **查看日志**
```bash
# 查看最后50行（默认）
./manage.sh logs

# 查看最后100行
./manage.sh logs 100

# 实时查看（按Ctrl+C退出）
./manage.sh logs
```

### **清理日志**
```bash
./manage.sh clean
```

---

## 🚀 服务器部署

### **环境要求**

- **操作系统**：Ubuntu 20.04+ / CentOS 7+
- **内存**：2GB+ （推荐 4GB）
- **Python**：3.8+
- **MySQL**：5.7+
- **Nginx**：推荐用于生产环境

---

### **一键部署步骤**

#### 1️⃣ 本地打包

```bash
./pack-simple.sh
```

#### 2️⃣ 上传到服务器

```bash
scp ../ai-intervention-predictor-simple.tar.gz root@你的服务器IP:/home/
```

#### 3️⃣ 服务器上解压

```bash
cd /home
rm -rf ai-intervention-predictor
mkdir ai-intervention-predictor && cd ai-intervention-predictor
tar -xzf ../ai-intervention-predictor-simple.tar.gz
```

#### 4️⃣ 安装系统依赖

```bash
# CentOS/RHEL
yum install python3 python3-pip nginx mysql -y

# Ubuntu/Debian
apt install python3 python3-pip nginx mysql-client -y
```

#### 5️⃣ 导入数据库

```bash
mysql -uai_predictor -pxR6NaN3HC4pDRsNB ai_predictor < database/schema.sql
mysql -uai_predictor -pxR6NaN3HC4pDRsNB ai_predictor < database/mock_data.sql
```

#### 6️⃣ 配置 Nginx（可选）

```bash
cp nginx-simple.conf /etc/nginx/conf.d/ai-predictor.conf
# 修改配置中的路径
nano /etc/nginx/conf.d/ai-predictor.conf
nginx -t && systemctl restart nginx
```

#### 7️⃣ 启动服务

```bash
mkdir -p logs
./start-server.sh
```

#### 8️⃣ 访问系统

```
http://你的服务器IP
```

---

### **服务管理命令**

```bash
# 启动服务
./start-server.sh

# 停止服务
./stop-server.sh

# 重启服务
./stop-server.sh && ./start-server.sh

# 查看日志
tail -f logs/backend.log

# 查看运行状态
ps aux | grep "python3 backend/main.py"
```

---

### **生产环境建议**

#### 使用 Systemd 管理（推荐）

创建服务文件：

```bash
sudo nano /etc/systemd/system/ai-predictor.service
```

内容：

```ini
[Unit]
Description=AI Mental Health Prediction System
After=network.target mysql.service

[Service]
Type=simple
User=root
WorkingDirectory=/home/ai-intervention-predictor
ExecStart=/usr/bin/python3 backend/main.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

管理服务：

```bash
# 启动服务
sudo systemctl start ai-predictor
sudo systemctl enable ai-predictor

# 查看状态
sudo systemctl status ai-predictor

# 查看日志
sudo journalctl -u ai-predictor -f
```

---

### **Nginx 反向代理配置**

配置文件已包含在 `nginx-simple.conf` 中：

```nginx
server {
    listen 80;
    server_name _;

    # 前端静态文件
    location / {
        root /home/ai-intervention-predictor/frontend;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # 后端 API 代理
    location /api/ {
        proxy_pass http://127.0.0.1:8000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

### **配置文件说明**

`.env` 文件已包含在部署包中，默认配置：

- **数据库地址**：`127.0.0.1`（本地）
- **AI 提供商**：SiliconFlow
- **时区**：`Asia/Shanghai`

如需修改，编辑 `.env` 文件后重启服务即可。

---

## 🐳 Docker 部署（推荐）

Docker 部署更加简单、稳定，适合生产环境。

### **环境要求**

- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **外部 MySQL**: 5.7+ （不包含在 Docker 中）
- **服务器内存**: 2GB+

---

### **快速部署步骤**

#### 1️⃣ 本地打包

```bash
# 生成 Docker 部署包
./pack-docker.sh
```

输出文件：`../ai-intervention-predictor-docker.tar.gz`

---

#### 2️⃣ 上传到服务器

```bash
scp ../ai-intervention-predictor-docker.tar.gz root@你的服务器IP:/home/
```

---

#### 3️⃣ 服务器解压

```bash
cd /home
rm -rf ai-intervention-predictor-docker ai-predictor
tar -xzf ai-intervention-predictor-docker.tar.gz
mv ai-intervention-predictor-docker ai-predictor
cd ai-predictor
```

---

#### 4️⃣ 配置环境变量

**修改 `.env` 文件**：

```bash
nano .env
```

**关键配置**：

```bash
# 数据库地址（Docker 容器连接宿主机 MySQL）
DB_HOST=172.17.0.1  # Docker 默认网关 IP
DB_PORT=3306
DB_USER=ai_predictor
DB_PASSWORD=你的数据库密码
DB_NAME=ai_predictor

# AI 配置（必须替换为真实 API Key）
AI_PROVIDER=siliconflow
AI_API_KEY=你的_SiliconFlow_API_Key
AI_BASE_URL=https://api.siliconflow.cn/v1
AI_MODEL=Qwen/Qwen2.5-7B-Instruct
```

💡 **提示**：
- `172.17.0.1` 是 Docker 默认网关，用于容器访问宿主机
- 确保 MySQL 允许远程连接（`bind-address = 0.0.0.0`）
- 确保防火墙开放 3306 端口

---

#### 5️⃣ 导入数据库

```bash
mysql -uai_predictor -p你的密码 ai_predictor < database/schema.sql
mysql -uai_predictor -p你的密码 ai_predictor < database/mock_data.sql
```

---

#### 6️⃣ 启动 Docker 容器

```bash
docker-compose up -d
```

**查看启动状态**：

```bash
docker-compose ps
```

**预期输出**：

```
NAME                   STATUS          PORTS
ai-predictor-backend   Up 20 seconds   0.0.0.0:3001->8000/tcp
ai-predictor-nginx     Up 20 seconds   0.0.0.0:3000->80/tcp
```

---

#### 7️⃣ 访问系统

- **前端页面**: `http://你的服务器IP:3000`
- **后端 API**: `http://你的服务器IP:3001/api/users`
- **API 文档**: `http://你的服务器IP:3001/docs`

---

### **Docker 管理命令**

```bash
# 查看运行状态
docker-compose ps

# 查看日志
docker-compose logs -f               # 所有日志
docker-compose logs -f backend       # 后端日志
docker-compose logs -f nginx         # Nginx 日志

# 重启服务
docker-compose restart               # 重启所有
docker-compose restart backend       # 只重启后端

# 停止服务
docker-compose down

# 更新代码后重新部署
docker-compose down
# 上传新代码
docker-compose up -d

# 查看资源占用
docker stats
```

---

### **文件结构说明**

```
ai-predictor/
├── docker-compose.yml    # Docker 编排配置
├── nginx.conf            # Nginx 反向代理配置
├── .env                  # 环境变量配置（需修改）
├── backend/              # 后端代码（挂载到容器）
├── frontend/             # 前端代码（挂载到容器）
├── database/             # 数据库脚本
└── logs/                 # 日志目录（持久化）
```

---

### **端口映射说明**

| 服务 | 容器端口 | 宿主机端口 | 说明 |
|------|---------|----------|------|
| Nginx | 80 | 3000 | 前端页面 |
| Nginx | 443 | 3443 | HTTPS（可选） |
| Backend | 8000 | 3001 | 后端 API |

**防火墙配置**：

```bash
# 开放端口
firewall-cmd --permanent --add-port=3000/tcp
firewall-cmd --permanent --add-port=3001/tcp
firewall-cmd --reload

# 或使用 iptables
iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
iptables -A INPUT -p tcp --dport 3001 -j ACCEPT
```

---

### **常见问题（Docker）**

#### ❌ 问题1：数据库连接失败

**错误信息**：
```
Can't connect to MySQL server on '172.17.0.1'
```

**解决方案**：

```bash
# 1. 检查 MySQL 是否允许远程连接
mysql -u root -p
mysql> SELECT user, host FROM mysql.user WHERE user='ai_predictor';
# 应该有 host='%' 的记录

# 2. 修改 MySQL 配置
nano /etc/my.cnf
# 确保：bind-address = 0.0.0.0

# 3. 重启 MySQL
systemctl restart mysqld

# 4. 测试连接
docker exec -it ai-predictor-backend sh
ping 172.17.0.1
telnet 172.17.0.1 3306
```

---

#### ❌ 问题2：前端请求 localhost 错误

**原因**：前端代码硬编码了 `http://localhost:8000`

**解决方案**：前端已使用相对路径 `/api/`，由 Nginx 反向代理

**验证**：

```bash
# 检查前端代码
grep -n "localhost:8000" frontend/index.html
# 应该返回空

# 检查 Nginx 配置
docker exec ai-predictor-nginx cat /etc/nginx/nginx.conf | grep "proxy_pass"
# 应该有：proxy_pass http://backend:8000/api/
```

---

#### ❌ 问题3：Docker 镜像拉取慢

**解决方案**：配置国内镜像源

```bash
# 编辑 Docker 配置
sudo nano /etc/docker/daemon.json
```

添加：

```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://registry.docker-cn.com"
  ]
}
```

重启 Docker：

```bash
sudo systemctl restart docker
```

---

#### ❌ 问题4：依赖安装慢

**原因**：每次启动都重新安装依赖

**解决方案**：使用 pip 缓存（已配置）

检查 `docker-compose.yml` 中的卷挂载：

```yaml
volumes:
  pip-cache:
    driver: local
```

---

### **更新部署流程**

```bash
# 1. 本地修改代码后重新打包
./pack-docker.sh

# 2. 上传到服务器
scp ../ai-intervention-predictor-docker.tar.gz root@服务器IP:/home/

# 3. 服务器上更新
cd /home/ai-predictor
docker-compose down           # 停止容器
cd /home
rm -rf ai-predictor-docker
tar -xzf ai-intervention-predictor-docker.tar.gz
mv ai-intervention-predictor-docker ai-predictor
cd ai-predictor
docker-compose up -d          # 启动容器

# 4. 查看日志确认
docker-compose logs -f backend
```

---

## ❓ 常见问题

### **Q1: 提示 "Permission denied"**
```bash
# 添加执行权限
chmod +x manage.sh
```

### **Q2: 端口8000被占用**
```bash
# 脚本会自动释放，如果还有问题：
lsof -ti:8000 | xargs kill -9
```

### **Q3: 页面一直自动刷新**
**原因：** 使用了 Live Server（VS Code插件）

**解决：**
1. 关闭 Live Server 页面
2. 使用正确的方式打开：
```bash
./manage.sh restart
# 或
open frontend/index.html
```

**检查地址栏：**
- ✅ 正确：`file:///Users/.../index.html`
- ❌ 错误：`http://127.0.0.1:5500/...` (Live Server)

### **Q4: AI建议不生成或返回错误**
**检查：**
```bash
cd backend
python3 -c "from config import AI_API_KEY; print('API Key:', AI_API_KEY[:20]+'...' if AI_API_KEY else '未配置')"
```

如果未配置，请检查 `.env` 文件。

### **Q5: 数据库连接失败**
**检查配置：**
1. `.env` 文件中的数据库配置
2. MySQL服务是否运行
3. 数据库 `ai_predictor` 是否已创建
4. 用户权限是否正确

---

## 🎬 演示说明

### **演示前准备（30秒）**

```bash
# 一键重启
cd /Users/caoziyang/Desktop/work/ai-intervention-predictor
./manage.sh restart

# 等待3-5秒，浏览器自动打开
```

### **演示流程**

#### **1. 系统介绍（1分钟）**

指向页面上的**系统简介面板**：
> "这是一个基于AI的心理干预效果预测系统，核心功能是：只需前3周数据就能预测8周后的干预效果，帮助研究者及时发现高风险用户。"

#### **2. 数据展示（1分钟）**

指向**顶部统计卡片**：
> "系统已跟踪100个用户，其中80人已完成，平均改善率29.6%，成功率（改善≥25%）达到65%。"

#### **3. AI预测演示（2分钟）**

**步骤1：** 点击左侧用户列表中的"张明"

**步骤2：** 等待AI分析（3-5秒）

**步骤3：** 指向结果面板：
- **基本信息** - 用户数据和学习表现
- **AI预测分数** - 渐变紫色卡片，展示预测结果
- **专业建议** - AI生成的3-5条个性化建议
- **AI专业分析** - 详细的文字评估报告
- **进度趋势图** - Chart.js可视化图表

#### **4. 对比演示（1分钟）**

点击不同类型的用户：
- **高打卡率用户**（1-20号）- 预测效果好，低风险
- **中等打卡率用户**（21-40号）- 预测效果一般
- **低打卡率用户**（41-60号）- 预测效果差，高风险

> "您看，AI会根据不同用户的具体情况生成不同的建议，这不是写死的规则，而是Qwen大语言模型实时生成的专业评估。"

### **演示话术**

#### **开场白**
> "这个系统解决的核心问题是：传统心理干预需要8周才能看到效果，但我们的AI系统只需要前3周的数据，就能提前预测最终效果，这样研究者可以及时调整干预方案，提高成功率。"

#### **技术亮点**
> "系统使用了三大核心技术：
> 1. **AI大语言模型** - Qwen2.5，国产免费，效果媲美GPT-4
> 2. **Python FastAPI** - 高性能后端框架
> 3. **实时数据可视化** - Chart.js图表，趋势一目了然"

#### **商业价值**
> "这个系统有三大商业价值：
> 1. **提前预测** - 节省时间成本，提高干预成功率20%+
> 2. **智能化** - AI自动生成专业报告，节省人力成本
> 3. **可商业化** - 可以直接卖给学校、医院、心理机构"

#### **学术价值**
> "从学术角度：
> 1. 可以用于心理学研究的数据分析
> 2. 提供AI辅助的干预效果评估
> 3. 支持发表论文的数据支持"

---

## 📊 系统特色

### **🎯 AI技术**
- ✅ 真实的AI大语言模型（Qwen2.5-7B）
- ✅ 每个用户建议不同（个性化）
- ✅ 专业心理学术语（社会适应能力、自我效能感）
- ✅ 降级方案（AI失败时使用规则引擎）

### **📈 数据可视化**
- ✅ Chart.js双曲线图（焦虑分数 + 学习活跃度）
- ✅ 实时统计面板（4个核心指标）
- ✅ 响应式设计（支持不同屏幕）
- ✅ 渐变色UI（现代化界面）

### **🔒 稳定可靠**
- ✅ 错误处理完善（友好提示）
- ✅ 数据验证（防止错误输入）
- ✅ 日志记录（便于调试）
- ✅ 进程管理（一键启停）

---

## 📝 开发说明

### **本地开发**

```bash
# 1. 启动后端（前台运行，便于调试）
cd backend
python3 main.py

# 2. 打开前端
open frontend/index.html
```

### **修改代码后重启**

```bash
./manage.sh restart
```

### **查看实时日志**

```bash
./manage.sh logs
```

---

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

MIT License

---

## 👨‍💻 作者

心理学 AI 研究团队

---

## 🎉 快速开始

**只需一行命令：**

```bash
./manage.sh start
```

**3秒后，开始体验AI心理干预预测！** 🚀

---

**祝使用愉快！如有问题，请查看上方[常见问题](#-常见问题)或查看日志：`./manage.sh logs`**
