# -*- coding: utf-8 -*-
"""
排行榜相关的数据验证模式
"""

from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class LeaderboardEntry(BaseModel):
    """排行榜条目"""
    rank_position: int = Field(..., ge=1, description="排名位置")
    username: str = Field(..., description="用户名")
    user_id: int = Field(..., description="用户ID")
    avatar_url: Optional[str] = Field(None, description="头像URL")
    cpu_model: Optional[str] = Field(None, description="CPU型号")
    cpu_cores: Optional[int] = Field(None, description="核心数")
    memory_gb: Optional[float] = Field(None, description="内存大小")
    overall_wall_time: float = Field(..., gt=0, description="总耗时(秒)")
    phase1_wall_time: Optional[float] = Field(None, description="Phase 1 耗时")
    phase2_wall_time: Optional[float] = Field(None, description="Phase 2 耗时")
    performance_score: Optional[float] = Field(None, description="性能分数")
    submitted_at: datetime = Field(..., description="提交时间")

    class Config:
        from_attributes = True


class LeaderboardResponse(BaseModel):
    """排行榜响应"""
    entries: List[LeaderboardEntry]
    total_users: int
    current_page: int
    total_pages: int
    page_size: int
    last_updated: datetime


class MyRankResponse(BaseModel):
    """我的排名响应"""
    username: str
    rank_position: Optional[int] = None
    total_users: int
    best_time: Optional[float] = None
    percentile: Optional[float] = None  # 百分位
    nearby_users: List[LeaderboardEntry] = []  # 附近的用户


class RankingStats(BaseModel):
    """排名统计"""
    total_users: int
    active_users_24h: int
    submissions_today: int
    avg_completion_time: Optional[float] = None
    fastest_time: Optional[float] = None
    slowest_time: Optional[float] = None