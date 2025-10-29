"""
配置文件
"""
import os
from pathlib import Path

# 尝试加载 .env 文件（本地开发用）
try:
    from dotenv import load_dotenv
    env_path = Path(__file__).parent.parent / '.env'
    if env_path.exists():
        load_dotenv(dotenv_path=env_path)
        print(f"✓ 已加载 .env 文件: {env_path}")
    else:
        print(f"⚠ .env 文件不存在，使用环境变量: {env_path}")
except ImportError:
    print("⚠ python-dotenv 未安装，直接使用环境变量")

# 数据库配置（直接从环境变量读取，Docker 环境中由 docker-compose.yml 注入）
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "127.0.0.1"),
    "port": int(os.getenv("DB_PORT", 3306)),
    "user": os.getenv("DB_USER", "ai_predictor"),
    "password": os.getenv("DB_PASSWORD", "xR6NaN3HC4pDRsNB"),
    "database": os.getenv("DB_NAME", "ai_predictor"),
    "charset": "utf8mb4"
}

# 打印配置（调试用）
print(f"📊 数据库配置: host={DB_CONFIG['host']}, user={DB_CONFIG['user']}, database={DB_CONFIG['database']}")

# AI配置
AI_PROVIDER = os.getenv("AI_PROVIDER", "siliconflow")
AI_API_KEY = os.getenv("AI_API_KEY", "")
AI_BASE_URL = os.getenv("AI_BASE_URL", "https://api.siliconflow.cn/v1")
AI_MODEL = os.getenv("AI_MODEL", "Qwen/Qwen2.5-7B-Instruct")

# 服务配置
HOST = "0.0.0.0"
PORT = 8000

