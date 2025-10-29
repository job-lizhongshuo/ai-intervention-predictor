"""
数据库操作
"""
import pymysql
from config import DB_CONFIG
from typing import Dict, List, Optional


class Database:
    def __init__(self):
        self.config = DB_CONFIG
    
    def get_connection(self):
        """获取数据库连接"""
        return pymysql.connect(**self.config)
    
    def get_user_info(self, user_id: int) -> Optional[Dict]:
        """获取用户基本信息"""
        conn = self.get_connection()
        try:
            with conn.cursor(pymysql.cursors.DictCursor) as cursor:
                sql = """
                SELECT 
                    user_id,
                    name,
                    age,
                    gender,
                    status
                FROM users
                WHERE user_id = %s
                """
                cursor.execute(sql, (user_id,))
                return cursor.fetchone()
        finally:
            conn.close()
    
    def get_assessment_scores(self, user_id: int) -> Dict:
        """获取用户测评分数"""
        conn = self.get_connection()
        try:
            with conn.cursor(pymysql.cursors.DictCursor) as cursor:
                sql = """
                SELECT 
                    stage_type,
                    score,
                    test_date
                FROM assessments
                WHERE user_id = %s
                ORDER BY stage_type
                """
                cursor.execute(sql, (user_id,))
                results = cursor.fetchall()
                
                scores = {
                    'pre_score': None,
                    'post_score': None
                }
                
                for row in results:
                    if row['stage_type'] == 1:  # 前测
                        scores['pre_score'] = float(row['score'])
                    elif row['stage_type'] == 4:  # 后测
                        scores['post_score'] = float(row['score'])
                
                return scores
        finally:
            conn.close()
    
    def get_learning_stats(self, user_id: int) -> Dict:
        """获取学习统计数据"""
        conn = self.get_connection()
        try:
            with conn.cursor(pymysql.cursors.DictCursor) as cursor:
                sql = """
                SELECT 
                    COUNT(DISTINCT week_number) as weeks_completed,
                    SUM(checkin_count) as total_checkins,
                    AVG(study_duration) as avg_study_duration,
                    SUM(CASE WHEN completed = 1 THEN 1 ELSE 0 END) as completed_weeks
                FROM learning_logs
                WHERE user_id = %s
                """
                cursor.execute(sql, (user_id,))
                result = cursor.fetchone()
                
                if result and result['weeks_completed']:
                    # 计算打卡率（假设每周目标3次）
                    expected_checkins = result['weeks_completed'] * 3
                    checkin_rate = result['total_checkins'] / expected_checkins if expected_checkins > 0 else 0
                    
                    return {
                        'weeks_completed': result['weeks_completed'],
                        'total_checkins': result['total_checkins'],
                        'checkin_rate': round(checkin_rate, 2),
                        'avg_study_duration': round(float(result['avg_study_duration'] or 0), 1),
                        'completion_rate': round(result['completed_weeks'] / result['weeks_completed'], 2)
                    }
                else:
                    return {
                        'weeks_completed': 0,
                        'total_checkins': 0,
                        'checkin_rate': 0,
                        'avg_study_duration': 0,
                        'completion_rate': 0
                    }
        finally:
            conn.close()
    
    def get_complete_user_data(self, user_id: int) -> Optional[Dict]:
        """获取用户完整数据（用于AI分析）"""
        user_info = self.get_user_info(user_id)
        if not user_info:
            return None
        
        scores = self.get_assessment_scores(user_id)
        learning_stats = self.get_learning_stats(user_id)
        
        return {
            **user_info,
            **scores,
            **learning_stats
        }
    
    def save_prediction(self, user_id: int, prediction_data: Dict) -> int:
        """保存预测结果"""
        conn = self.get_connection()
        try:
            with conn.cursor() as cursor:
                sql = """
                INSERT INTO predictions (
                    user_id,
                    pre_score,
                    predicted_score,
                    predicted_improvement,
                    confidence,
                    risk_level,
                    suggestions,
                    model_version
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """
                cursor.execute(sql, (
                    user_id,
                    prediction_data['pre_score'],
                    prediction_data['predicted_score'],
                    prediction_data['predicted_improvement'],
                    prediction_data['confidence'],
                    prediction_data['risk_level'],
                    str(prediction_data['suggestions']),
                    prediction_data.get('model_version', 'v1.0')
                ))
                conn.commit()
                return cursor.lastrowid
        finally:
            conn.close()
    
    def get_all_users_summary(self, status: Optional[int] = None) -> List[Dict]:
        """获取所有用户概况"""
        conn = self.get_connection()
        try:
            with conn.cursor(pymysql.cursors.DictCursor) as cursor:
                sql = """
                SELECT 
                    u.user_id,
                    u.name,
                    u.age,
                    u.gender,
                    u.status,
                    (SELECT score FROM assessments WHERE user_id = u.user_id AND stage_type = 1 LIMIT 1) as pre_score,
                    (SELECT score FROM assessments WHERE user_id = u.user_id AND stage_type = 4 LIMIT 1) as post_score
                FROM users u
                """
                
                if status is not None:
                    sql += " WHERE u.status = %s"
                    cursor.execute(sql, (status,))
                else:
                    cursor.execute(sql)
                
                return cursor.fetchall()
        finally:
            conn.close()
    
    def create_user(self, user_data: Dict) -> int:
        """创建新用户并返回用户ID"""
        conn = self.get_connection()
        try:
            with conn.cursor() as cursor:
                # 1. 插入用户基本信息
                sql = """
                INSERT INTO users (name, age, gender, status, project_id)
                VALUES (%s, %s, %s, %s, %s)
                """
                cursor.execute(sql, (
                    user_data['name'],
                    user_data['age'],
                    user_data['gender'],
                    user_data.get('status', 0),  # 默认进行中
                    user_data.get('project_id', 1)
                ))
                user_id = cursor.lastrowid
                
                # 2. 插入前测数据（如果有）
                if user_data.get('pre_score'):
                    sql = """
                    INSERT INTO assessments (user_id, scale_name, stage_type, score, test_date)
                    VALUES (%s, %s, %s, %s, NOW())
                    """
                    cursor.execute(sql, (
                        user_id,
                        user_data.get('scale_name', 'GAD-7'),
                        1,  # 前测
                        user_data['pre_score']
                    ))
                
                # 3. 插入后测数据（如果有）
                if user_data.get('post_score'):
                    sql = """
                    INSERT INTO assessments (user_id, scale_name, stage_type, score, test_date)
                    VALUES (%s, %s, %s, %s, NOW())
                    """
                    cursor.execute(sql, (
                        user_id,
                        user_data.get('scale_name', 'GAD-7'),
                        4,  # 后测
                        user_data['post_score']
                    ))
                    # 如果有后测，设置状态为已完成
                    cursor.execute("UPDATE users SET status = 1 WHERE user_id = %s", (user_id,))
                
                # 4. 插入学习记录（如果有）
                if user_data.get('learning_logs'):
                    for log in user_data['learning_logs']:
                        sql = """
                        INSERT INTO learning_logs 
                        (user_id, week_number, checkin_count, study_duration, completed, log_date)
                        VALUES (%s, %s, %s, %s, %s, %s)
                        """
                        cursor.execute(sql, (
                            user_id,
                            log['week_number'],
                            log['checkin_count'],
                            log['study_duration'],
                            log['completed'],
                            log['log_date']
                        ))
                
                conn.commit()
                return user_id
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            conn.close()


# 全局数据库实例
db = Database()

