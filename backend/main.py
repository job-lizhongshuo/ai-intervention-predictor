"""
FastAPI 主应用
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
from database import db
from ai_service import ai_service
import traceback

app = FastAPI(
    title="AI心理干预效果预测系统",
    description="基于AI的心理干预效果评估与预测",
    version="1.0.0"
)

# 允许跨域
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ========== 数据模型 ==========

class PredictionRequest(BaseModel):
    user_id: int


class PredictionResponse(BaseModel):
    success: bool
    data: Optional[dict] = None
    message: Optional[str] = None


class UserListResponse(BaseModel):
    success: bool
    data: List[dict]
    total: int


class CreateUserRequest(BaseModel):
    name: str
    age: int
    gender: int  # 1=男, 2=女
    pre_score: Optional[float] = None
    post_score: Optional[float] = None
    scale_name: Optional[str] = "GAD-7"
    weeks_completed: Optional[int] = None
    total_checkins: Optional[int] = None
    checkin_rate: Optional[float] = None
    avg_study_duration: Optional[float] = None
    completion_rate: Optional[float] = None


class CreateUserResponse(BaseModel):
    success: bool
    data: Optional[dict] = None
    message: Optional[str] = None


# ========== API接口 ==========

@app.get("/")
def root():
    """根路径"""
    return {
        "name": "AI心理干预效果预测系统",
        "version": "1.0.0",
        "status": "running",
        "endpoints": {
            "predict": "/api/predict",
            "users": "/api/users"
        }
    }


@app.get("/api/health")
def health_check():
    """健康检查"""
    return {"status": "healthy"}


@app.post("/api/predict", response_model=PredictionResponse)
def predict_intervention_effect(request: PredictionRequest):
    """
    预测干预效果
    
    Args:
        request: 包含user_id的请求
    
    Returns:
        预测结果
    """
    try:
        # 1. 获取用户完整数据
        user_data = db.get_complete_user_data(request.user_id)
        
        if not user_data:
            raise HTTPException(status_code=404, detail=f"用户ID {request.user_id} 不存在")
        
        if not user_data.get('pre_score'):
            raise HTTPException(status_code=400, detail="该用户没有前测数据")
        
        # 2. 调用AI进行评估
        ai_result = ai_service.evaluate_intervention(user_data)
        
        # 3. 组装返回数据
        response_data = {
            "user_info": {
                "user_id": user_data['user_id'],
                "name": user_data['name'],
                "age": user_data['age'],
                "gender": "男" if user_data['gender'] == 1 else "女"
            },
            "assessment_data": {
                "pre_score": user_data['pre_score'],
                "post_score": user_data.get('post_score'),
                "has_post_test": user_data.get('post_score') is not None
            },
            "learning_data": {
                "weeks_completed": user_data['weeks_completed'],
                "total_checkins": user_data['total_checkins'],
                "checkin_rate": user_data['checkin_rate'],
                "avg_study_duration": user_data['avg_study_duration'],
                "completion_rate": user_data['completion_rate']
            },
            "ai_prediction": ai_result
        }
        
        # 4. 保存预测记录
        try:
            db.save_prediction(request.user_id, {
                "pre_score": user_data['pre_score'],
                "predicted_score": ai_result['predicted_score_most_likely'],
                "predicted_improvement": ai_result['predicted_improvement'],
                "confidence": ai_result['confidence'],
                "risk_level": ai_result['risk_level'],
                "suggestions": ai_result['suggestions']
            })
        except Exception as e:
            print(f"保存预测记录失败: {e}")
        
        return PredictionResponse(
            success=True,
            data=response_data,
            message="预测成功"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"预测失败: {e}")
        print(traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"预测失败: {str(e)}")


@app.get("/api/users", response_model=UserListResponse)
def get_users(status: Optional[int] = None):
    """
    获取用户列表
    
    Args:
        status: 用户状态（0=进行中, 1=已完成）
    
    Returns:
        用户列表
    """
    try:
        users = db.get_all_users_summary(status)
        
        # 处理数据
        for user in users:
            user['gender_text'] = "男" if user['gender'] == 1 else "女"
            user['status_text'] = "已完成" if user['status'] == 1 else "进行中"
            
            # 如果有前测和后测，计算改善
            if user.get('pre_score') and user.get('post_score'):
                improvement = float(user['pre_score']) - float(user['post_score'])
                improvement_rate = (improvement / float(user['pre_score'])) * 100
                user['improvement'] = round(improvement, 1)
                user['improvement_rate'] = round(improvement_rate, 1)
        
        return UserListResponse(
            success=True,
            data=users,
            total=len(users)
        )
        
    except Exception as e:
        print(f"获取用户列表失败: {e}")
        raise HTTPException(status_code=500, detail=f"获取用户列表失败: {str(e)}")


@app.get("/api/user/{user_id}")
def get_user_detail(user_id: int):
    """获取用户详情"""
    try:
        user_data = db.get_complete_user_data(user_id)
        
        if not user_data:
            raise HTTPException(status_code=404, detail="用户不存在")
        
        return {
            "success": True,
            "data": user_data
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/users", response_model=CreateUserResponse)
def create_user(request: CreateUserRequest):
    """
    创建新用户（演示配置功能）
    
    自动生成学习记录数据
    """
    try:
        import random
        from datetime import datetime, timedelta
        
        # 准备用户数据
        user_data = {
            'name': request.name,
            'age': request.age,
            'gender': request.gender,
            'pre_score': request.pre_score,
            'post_score': request.post_score,
            'scale_name': request.scale_name or 'GAD-7',
            'status': 1 if request.post_score else 0
        }
        
        # 生成学习记录（如果提供了依从性数据）
        if request.weeks_completed:
            learning_logs = []
            weeks = request.weeks_completed
            checkin_rate = request.checkin_rate or 0.7
            avg_duration = request.avg_study_duration or 30
            completion_rate = request.completion_rate or 0.8
            
            for week in range(1, weeks + 1):
                # 每周的打卡次数（目标3次，根据打卡率调整）
                checkin_count = max(1, int(3 * checkin_rate + random.uniform(-0.5, 0.5)))
                
                # 学习时长（基于平均值加随机波动）
                duration = max(10, int(avg_duration + random.uniform(-10, 10)))
                
                # 是否完成（基于完成率）
                completed = random.random() < completion_rate
                
                # 记录日期（从现在往前推算）
                log_date = (datetime.now() - timedelta(weeks=weeks-week)).strftime('%Y-%m-%d')
                
                learning_logs.append({
                    'week_number': week,
                    'checkin_count': checkin_count,
                    'study_duration': duration,
                    'completed': completed,
                    'log_date': log_date
                })
            
            user_data['learning_logs'] = learning_logs
        
        # 创建用户
        user_id = db.create_user(user_data)
        
        # 获取完整用户数据
        complete_data = db.get_complete_user_data(user_id)
        
        return CreateUserResponse(
            success=True,
            data=complete_data,
            message=f"用户创建成功，ID: {user_id}"
        )
        
    except Exception as e:
        print(f"创建用户失败: {e}")
        print(traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"创建用户失败: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    from config import HOST, PORT
    
    print(f"""
    ╔══════════════════════════════════════════╗
    ║   AI 心理干预效果预测系统 v1.0           ║
    ╚══════════════════════════════════════════╝
    
    🚀 服务启动中...
    📡 API地址: http://{HOST}:{PORT}
    📚 文档地址: http://{HOST}:{PORT}/docs
    
    """)
    
    # 生产环境关闭热重载，避免页面自动刷新
    # 开发时可以改为 reload=True
    uvicorn.run("main:app", host=HOST, port=PORT, reload=False)

