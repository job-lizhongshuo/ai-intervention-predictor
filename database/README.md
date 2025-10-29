# 数据库初始化说明

## 快速开始

### 1. 创建数据库和表结构

```bash
mysql -u root -p < schema.sql
```

### 2. 导入Mock数据

```bash
mysql -u root -p < mock_data.sql
```

## 数据说明

### 用户数据（100个）

- **已完成用户（80个）**：有完整的前测和后测数据
  - 效果好（1-20）：打卡率 80-90%，改善 45-50%
  - 效果中等（21-40）：打卡率 60-70%，改善 25-35%
  - 效果差（41-60）：打卡率 30-50%，改善 10-20%
  - 混合情况（61-80）：各种情况

- **进行中用户（20个）**：只有前测和前3周数据，用于演示预测

### 数据特点

1. **真实性**：模拟了真实干预场景的数据分布
2. **多样性**：包含各种效果水平的用户
3. **完整性**：有完整的8周学习记录
4. **可验证性**：可以用已完成用户验证预测准确率

## 数据验证

### 查看数据统计

```sql
USE ai_predictor;

-- 用户统计
SELECT 
    status,
    COUNT(*) as count
FROM users
GROUP BY status;

-- 测评数据统计
SELECT 
    scale_name,
    stage_type,
    COUNT(*) as count,
    AVG(score) as avg_score
FROM assessments
GROUP BY scale_name, stage_type;

-- 学习记录统计
SELECT 
    week_number,
    AVG(checkin_count) as avg_checkins,
    AVG(study_duration) as avg_duration
FROM learning_logs
GROUP BY week_number
ORDER BY week_number;
```

### 查看示例用户

```sql
-- 查看一个完整的用户数据
SELECT 
    u.user_id,
    u.name,
    u.age,
    (SELECT score FROM assessments WHERE user_id = u.user_id AND stage_type = 1) as pre_score,
    (SELECT score FROM assessments WHERE user_id = u.user_id AND stage_type = 4) as post_score,
    (SELECT SUM(checkin_count) FROM learning_logs WHERE user_id = u.user_id) as total_checkins
FROM users u
WHERE u.user_id = 1;
```

## 数据库连接配置

### Python 连接示例

```python
import pymysql

connection = pymysql.connect(
    host='localhost',
    user='root',
    password='your_password',
    database='ai_predictor',
    charset='utf8mb4'
)
```

### 环境变量配置

```bash
# .env 文件
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=ai_predictor
```

