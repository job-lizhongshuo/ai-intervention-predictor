"""
AI服务 - 支持多种后端（DeepSeek API / Ollama）
"""
from openai import OpenAI
from config import AI_PROVIDER, AI_API_KEY, AI_BASE_URL, AI_MODEL
import json
from typing import Dict


class AIService:
    def __init__(self):
        self.provider = AI_PROVIDER
        self.model = AI_MODEL
        
        # 初始化客户端（支持DeepSeek/OpenAI/Ollama/SiliconFlow等）
        if self.provider in ['deepseek', 'openai', 'ollama', 'siliconflow', 'qwen']:
            self.client = OpenAI(
                api_key=AI_API_KEY if self.provider != 'ollama' else 'ollama',
                base_url=AI_BASE_URL
            )
        else:
            # 默认使用OpenAI兼容格式
            self.client = OpenAI(
                api_key=AI_API_KEY,
                base_url=AI_BASE_URL
            )
    
    def evaluate_intervention(self, user_data: Dict) -> Dict:
        """
        AI评估干预效果
        
        Args:
            user_data: 用户数据字典
        
        Returns:
            评估结果字典
        """
        prompt = self._build_evaluation_prompt(user_data)
        
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "你是一位资深的心理干预效果评估专家，拥有20年临床经验。"
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=0.3,
                max_tokens=1500
            )
            
            # 解析返回结果
            result_text = response.choices[0].message.content
            
            # 尝试解析JSON
            try:
                result = json.loads(result_text)
            except:
                # 如果不是JSON，用规则提取
                result = self._parse_text_response(result_text, user_data)
            
            return result
            
        except Exception as e:
            print(f"AI调用失败: {e}")
            # 降级：使用规则引擎
            return self._fallback_evaluation(user_data)
    
    def _build_evaluation_prompt(self, user_data: Dict) -> str:
        """构建评估prompt"""
        return f"""
请作为心理干预效果评估专家，分析以下用户的干预情况：

【用户信息】
- 姓名：{user_data.get('name', '未知')}
- 年龄：{user_data.get('age', '未知')}岁
- 性别：{'男' if user_data.get('gender') == 1 else '女'}

【测评数据】
- 前测焦虑分数：{user_data.get('pre_score', 0)}分（GAD-7量表，满分21分）
- 后测分数：{user_data.get('post_score', '未完成')}

【学习数据】
- 已完成周数：{user_data.get('weeks_completed', 0)}周（共8周）
- 总打卡次数：{user_data.get('total_checkins', 0)}次
- 打卡率：{user_data.get('checkin_rate', 0) * 100:.0f}%
- 平均学习时长：{user_data.get('avg_study_duration', 0)}分钟/次
- 周完成率：{user_data.get('completion_rate', 0) * 100:.0f}%

【参考标准】
- GAD-7评分：0-4分轻度，5-9分轻中度，10-14分中度，15-21分重度
- 打卡率：>80%良好，60-80%一般，<60%较差
- 临床显著改善：分数下降≥25%或下降≥5分

请提供专业评估，以JSON格式返回：
{{
    "predicted_score_min": 预测后测最低分,
    "predicted_score_max": 预测后测最高分,
    "predicted_score_most_likely": 最可能的后测分数,
    "predicted_improvement": 预测改善幅度,
    "predicted_improvement_rate": 预测改善率（百分比）,
    "current_progress": "当前进展评价（良好/一般/较差）",
    "risk_level": "风险等级（low/medium/high）",
    "confidence": 置信度（0-1之间的小数）,
    "suggestions": [
        "具体建议1",
        "具体建议2",
        "具体建议3"
    ],
    "analysis": "详细分析说明（100-200字）"
}}

注意：
1. 如果已有后测数据，就评估实际效果
2. 如果没有后测数据，根据前3周数据预测
3. 打卡率越高，预测改善效果越好
4. 前测分数越高，改善空间越大
5. 给出的建议要具体可操作
"""
    
    def _parse_text_response(self, text: str, user_data: Dict) -> Dict:
        """解析文本响应（如果AI没返回JSON）"""
        # 简单规则解析
        pre_score = user_data.get('pre_score', 15)
        checkin_rate = user_data.get('checkin_rate', 0.5)
        weeks = user_data.get('weeks_completed', 0)
        
        # 基于打卡率估算改善率
        if checkin_rate >= 0.8:
            improvement_rate = 0.45
            progress = "良好"
            risk = "low"
        elif checkin_rate >= 0.6:
            improvement_rate = 0.30
            progress = "一般"
            risk = "medium"
        else:
            improvement_rate = 0.15
            progress = "较差"
            risk = "high"
        
        improvement = pre_score * improvement_rate
        predicted_score = max(3, pre_score - improvement)
        
        # 生成人类可读的分析文本
        analysis_parts = []
        analysis_parts.append(f"该用户前测GAD-7分数为{pre_score:.1f}分，")
        
        if checkin_rate >= 0.8:
            analysis_parts.append(f"打卡率达到{checkin_rate*100:.0f}%，学习表现优秀。")
        elif checkin_rate >= 0.6:
            analysis_parts.append(f"打卡率为{checkin_rate*100:.0f}%，学习参与度一般。")
        else:
            analysis_parts.append(f"打卡率仅{checkin_rate*100:.0f}%，需要加强督促。")
        
        analysis_parts.append(f"基于当前数据，预测8周后分数约为{predicted_score:.1f}分，改善率约{improvement_rate*100:.0f}%。")
        
        if risk == "low":
            analysis_parts.append("干预进展顺利，建议保持当前方案。")
        elif risk == "medium":
            analysis_parts.append("存在一定风险，建议关注用户状态。")
        else:
            analysis_parts.append("风险较高，建议及时调整干预强度。")
        
        return {
            "predicted_score_min": round(predicted_score - 1, 1),
            "predicted_score_max": round(predicted_score + 1, 1),
            "predicted_score_most_likely": round(predicted_score, 1),
            "predicted_improvement": round(improvement, 1),
            "predicted_improvement_rate": round(improvement_rate * 100, 1),
            "current_progress": progress,
            "risk_level": risk,
            "confidence": 0.75,
            "suggestions": [
                "保持当前学习频率" if checkin_rate >= 0.7 else "建议提高打卡率",
                "建议第6周进行中期评估",
                "可以增加放松训练"
            ],
            "analysis": "".join(analysis_parts)
        }
    
    def _fallback_evaluation(self, user_data: Dict) -> Dict:
        """降级方案：规则引擎"""
        pre_score = user_data.get('pre_score', 15)
        checkin_rate = user_data.get('checkin_rate', 0.5)
        weeks = user_data.get('weeks_completed', 0)
        
        # 规则1：打卡率影响
        if checkin_rate >= 0.8:
            improvement_rate = 0.45
            progress = "良好"
            risk = "low"
        elif checkin_rate >= 0.6:
            improvement_rate = 0.30
            progress = "一般"
            risk = "medium"
        else:
            improvement_rate = 0.15
            progress = "较差"
            risk = "high"
        
        # 规则2：基线分数影响
        if pre_score >= 15:
            improvement_rate *= 1.1
        elif pre_score <= 8:
            improvement_rate *= 0.8
        
        # 计算预测
        improvement = pre_score * improvement_rate
        predicted_score = max(3, pre_score - improvement)
        
        # 生成建议
        suggestions = []
        if checkin_rate < 0.7:
            suggestions.append("建议提高打卡率，增加学习频率")
        else:
            suggestions.append("保持当前良好的学习习惯")
        
        if weeks >= 3:
            suggestions.append("建议第6周进行中期测评")
        
        suggestions.append("可以尝试增加正念呼吸练习")
        
        # 生成详细分析
        analysis_parts = []
        
        # 基线评估
        if pre_score >= 15:
            analysis_parts.append(f"该用户前测GAD-7分数为{pre_score:.1f}分，属于重度焦虑水平，具有较大的改善空间。")
        elif pre_score >= 10:
            analysis_parts.append(f"该用户前测GAD-7分数为{pre_score:.1f}分，属于中度焦虑水平。")
        else:
            analysis_parts.append(f"该用户前测GAD-7分数为{pre_score:.1f}分，属于轻度焦虑水平。")
        
        # 学习表现评估
        if checkin_rate >= 0.8:
            analysis_parts.append(f"用户打卡率达到{checkin_rate*100:.0f}%，学习积极性非常高，这对干预效果有显著的正向影响。")
        elif checkin_rate >= 0.6:
            analysis_parts.append(f"用户打卡率为{checkin_rate*100:.0f}%，学习参与度一般，建议加强督促和激励。")
        else:
            analysis_parts.append(f"用户打卡率仅为{checkin_rate*100:.0f}%，学习参与度较低，这可能影响最终效果，建议及时干预。")
        
        # 预测结果
        analysis_parts.append(f"基于当前数据，预测8周后GAD-7分数约为{predicted_score:.1f}分，预期改善幅度约{improvement:.1f}分（改善率{improvement_rate*100:.0f}%）。")
        
        # 风险评估
        if risk == "low":
            analysis_parts.append("目前干预进展顺利，风险等级较低，建议继续保持。")
        elif risk == "medium":
            analysis_parts.append("目前存在一定风险，建议关注用户状态，适时调整干预方案。")
        else:
            analysis_parts.append("目前风险等级较高，建议立即加强干预力度或考虑其他辅助措施。")
        
        return {
            "predicted_score_min": round(predicted_score - 1, 1),
            "predicted_score_max": round(predicted_score + 1, 1),
            "predicted_score_most_likely": round(predicted_score, 1),
            "predicted_improvement": round(improvement, 1),
            "predicted_improvement_rate": round(improvement_rate * 100, 1),
            "current_progress": progress,
            "risk_level": risk,
            "confidence": 0.70,
            "suggestions": suggestions,
            "analysis": " ".join(analysis_parts)
        }


# 全局AI服务实例
ai_service = AIService()

