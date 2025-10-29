# 📋 项目概览

## 🎯 项目名称

**AI 心理干预效果预测系统** - 专业版 v2.0

---

## 📁 文件结构

```
ai-intervention-predictor/
├── 📄 README.md              # 主文档（完整部署指南）
├── 📄 .env.example           # 环境变量模板
├── 📄 docker-compose.yml     # Docker 编排配置
├── 📄 nginx.conf             # Nginx 反向代理配置
│
├── 🔧 manage.sh              # 统一管理脚本（启动/停止/状态）
├── 🔧 start-server.sh        # 启动服务脚本
├── 🔧 stop-server.sh         # 停止服务脚本
├── 🔧 switch_ai.sh           # AI 配置切换脚本
│
├── 📦 pack-docker.sh         # Docker 部署打包脚本
├── 📦 pack-simple.sh         # 直接部署打包脚本
│
├── �� backend/               # 后端代码
│   ├── main.py              # FastAPI 主应用
│   ├── ai_service.py        # AI 服务（支持多模型）
│   ├── database.py          # 数据库操作
│   ├── config.py            # 配置管理
│   └── requirements.txt     # Python 依赖
│
├── 📂 frontend/              # 前端代码
│   └── index.html           # 单页面应用（响应式设计）
│
├── 📂 database/              # 数据库脚本
│   ├── schema.sql           # 数据库表结构
│   ├── mock_data.sql        # 模拟数据（200个用户）
│   └── README.md            # 数据库说明
│
├── 📂 docs/                  # 文档资料
│   └── PPT演示文稿内容.pptx # 项目演示 PPT
│
└── 📂 logs/                  # 日志目录（自动生成）
```

---

## 🚀 部署方式

### 1️⃣ 本地开发

**快速启动**：
```bash
# 一键启动（推荐）
./manage.sh start

# 查看状态
./manage.sh status

# 停止服务
./manage.sh stop
```

**手动启动**：
```bash
cd backend
python3 main.py
```

**访问**：
- 前端：直接打开 `frontend/index.html`
- 后端：http://localhost:8000
- API文档：http://localhost:8000/docs

---

### 2️⃣ Docker 部署（推荐）

**优势**：
- ✅ 环境隔离
- ✅ 一键部署
- ✅ 资源限制
- ✅ 自动重启

**步骤**：
```bash
# 1. 打包
./pack-docker.sh

# 2. 上传到服务器
scp ../ai-intervention-predictor-docker.tar.gz root@服务器IP:/home/

# 3. 服务器解压并启动
cd /home && tar -xzf ai-intervention-predictor-docker.tar.gz
mv ai-intervention-predictor-docker ai-predictor
cd ai-predictor
nano .env  # 修改数据库和 API Key
docker-compose up -d
```

**访问**：
- 前端：http://服务器IP:3000
- 后端：http://服务器IP:3001

**详细文档**：见 `README.md` 的 "🐳 Docker 部署" 章节

---

### 3️⃣ 直接服务器部署

**适用场景**：无 Docker 环境的传统服务器

**步骤**：
```bash
# 1. 打包
./pack-simple.sh

# 2. 上传并解压
scp ../ai-intervention-predictor-simple.tar.gz root@服务器IP:/home/
cd /home && tar -xzf ai-intervention-predictor-simple.tar.gz
cd ai-intervention-predictor

# 3. 安装依赖
yum install python3 nginx mysql -y  # CentOS
apt install python3 nginx mysql-client -y  # Ubuntu

# 4. 启动服务
./start-server.sh
```

**详细文档**：见 `README.md` 的 "🚀 服务器部署" 章节

---

## 🔧 配置说明

### 环境变量（`.env` 文件）

**必须配置**：
```bash
DB_HOST=数据库IP          # 本地：127.0.0.1 / Docker：172.17.0.1
DB_PASSWORD=数据库密码
AI_API_KEY=你的AI_API_Key  # 必须替换
```

**可选配置**：
- `AI_PROVIDER`: 切换 AI 提供商（siliconflow/deepseek/openai/ollama）
- `AI_MODEL`: AI 模型名称
- `DB_NAME`: 数据库名称（默认：ai_predictor）

**快速切换 AI**：
```bash
./switch_ai.sh
```

---

## 📊 核心功能

1. **AI 效果预测** - 基于前3周数据预测8周后效果
2. **风险识别** - 自动分类低/中/高风险用户
3. **个性化建议** - AI 生成针对性干预方案
4. **数据可视化** - Chart.js 趋势图表
5. **响应式设计** - 适配手机/平板/电脑
6. **多量表支持** - GAD-7 / PHQ-9 / PSS
7. **演示配置** - 自定义量表和批量生成数据

---

## 🛠️ 管理工具

| 工具 | 用途 | 命令 |
|------|------|------|
| `manage.sh` | 统一管理 | `./manage.sh {start\|stop\|restart\|status\|logs}` |
| `switch_ai.sh` | 切换 AI | `./switch_ai.sh` |
| `pack-docker.sh` | Docker 打包 | `./pack-docker.sh` |
| `pack-simple.sh` | 直接部署打包 | `./pack-simple.sh` |

---

## 📖 文档索引

- **主文档**：`README.md` - 完整的安装、配置、部署指南
- **数据库文档**：`database/README.md` - 数据库结构说明
- **Docker配置**：`docker-compose.yml` - Docker 编排配置（含详细注释）
- **Nginx配置**：`nginx.conf` - 反向代理配置

---

## 🎯 快速链接

**本地开发**：
```bash
./manage.sh start
```

**Docker部署**：
```bash
./pack-docker.sh
# 详见 README.md 第 564-867 行
```

**直接部署**：
```bash
./pack-simple.sh
# 详见 README.md 第 395-563 行
```

**AI配置切换**：
```bash
./switch_ai.sh
# 详见 README.md 第 222-268 行
```

---

## 📞 技术支持

- **项目文档**：`README.md`
- **常见问题**：`README.md` 第 869+ 行
- **Docker问题**：`README.md` 第 748-865 行

---

## ✅ 已清理文件

以下冗余文件已删除：
- ❌ `nginx-simple.conf` - 已合并到 `nginx.conf`
- ❌ `server.log` / `server.pid` - 运行时生成
- ❌ `部署成功.md` - 临时文档
- ❌ 其他临时 `.md` 文档 - 已整合到 `README.md`

---

## 🎉 项目状态

✅ **代码完整** - 前端、后端、数据库脚本齐全  
✅ **文档完善** - README 包含所有部署方式  
✅ **工具齐全** - 管理脚本、打包脚本、切换脚本  
✅ **已生产部署** - Docker 在服务器 `101.42.230.29` 运行中  
✅ **文件清理** - 已删除所有冗余文件  

**当前版本**：v2.0 专业版  
**最后更新**：2025-10-28
