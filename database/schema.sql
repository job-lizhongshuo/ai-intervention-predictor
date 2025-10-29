-- ============================================
-- AI 心理干预效果预测系统 - 数据库结构
-- 基于 Ganyu 优化精简版
-- 创建日期: 2025-10-28
-- ============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS ai_predictor DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE ai_predictor;

-- ============================================
-- 1. 用户表（精简版）
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    user_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    name VARCHAR(50) NOT NULL COMMENT '姓名',
    age INT NOT NULL COMMENT '年龄',
    gender TINYINT NOT NULL COMMENT '性别：1=男, 2=女',
    project_id BIGINT DEFAULT 1 COMMENT '项目ID',
    status TINYINT DEFAULT 1 COMMENT '状态：0=进行中, 1=已完成',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ============================================
-- 2. 测评数据表（核心表）
-- ============================================
CREATE TABLE IF NOT EXISTS assessments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    scale_name VARCHAR(50) NOT NULL COMMENT '量表名称：GAD-7焦虑, PHQ-9抑郁',
    stage_type TINYINT NOT NULL COMMENT '阶段：1=前测, 4=后测',
    score DECIMAL(5,2) NOT NULL COMMENT '得分',
    test_date DATETIME NOT NULL COMMENT '测评日期',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_stage (user_id, stage_type),
    INDEX idx_scale (scale_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测评数据表';

-- ============================================
-- 3. 学习记录表（用于预测特征）
-- ============================================
CREATE TABLE IF NOT EXISTS learning_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    week_number INT NOT NULL COMMENT '第几周（1-8）',
    checkin_count INT DEFAULT 0 COMMENT '本周打卡次数',
    study_duration INT DEFAULT 0 COMMENT '本周总学习时长（分钟）',
    completed BOOLEAN DEFAULT FALSE COMMENT '是否完成本周任务',
    log_date DATE NOT NULL COMMENT '记录日期',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_week (user_id, week_number),
    UNIQUE KEY uk_user_week (user_id, week_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习记录表';

-- ============================================
-- 4. 预测记录表（保存预测历史）
-- ============================================
CREATE TABLE IF NOT EXISTS predictions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '预测ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    pre_score DECIMAL(5,2) NOT NULL COMMENT '前测分数',
    predicted_score DECIMAL(5,2) NOT NULL COMMENT '预测后测分数',
    predicted_improvement DECIMAL(5,2) NOT NULL COMMENT '预测改善幅度',
    confidence DECIMAL(3,2) NOT NULL COMMENT '置信度（0-1）',
    risk_level VARCHAR(20) NOT NULL COMMENT '风险等级：low/medium/high',
    suggestions TEXT COMMENT 'AI建议（JSON格式）',
    actual_score DECIMAL(5,2) DEFAULT NULL COMMENT '实际后测分数（后续填入）',
    prediction_accuracy DECIMAL(5,2) DEFAULT NULL COMMENT '预测准确度',
    model_version VARCHAR(50) DEFAULT 'v1.0' COMMENT '模型版本',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '预测时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user (user_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预测记录表';

-- ============================================
-- 5. 模型性能表（追踪模型表现）
-- ============================================
CREATE TABLE IF NOT EXISTS model_performance (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    model_version VARCHAR(50) NOT NULL COMMENT '模型版本',
    total_predictions INT DEFAULT 0 COMMENT '总预测次数',
    accurate_predictions INT DEFAULT 0 COMMENT '准确预测次数',
    accuracy_rate DECIMAL(5,2) DEFAULT 0 COMMENT '准确率',
    avg_error DECIMAL(5,2) DEFAULT 0 COMMENT '平均误差',
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
    UNIQUE KEY uk_version (model_version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='模型性能表';

-- ============================================
-- 插入初始模型性能记录
-- ============================================
INSERT INTO model_performance (model_version, total_predictions, accurate_predictions, accuracy_rate, avg_error)
VALUES ('v1.0', 0, 0, 0.00, 0.00);

