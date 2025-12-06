# -*- coding: utf-8 -*-
"""
用户相关的数据验证模式
"""

from pydantic import BaseModel, Field, EmailStr
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    """用户基础模式"""
    username: str = Field(..., min_length=1, max_length=100, description="用户名")
    user_id: str = Field(..., min_length=1, max_length=100, description="外部用户ID")
    email: Optional[EmailStr] = Field(None, description="邮箱地址")
    avatar_url: Optional[str] = Field(None, max_length=500, description="头像URL")


class UserCreate(UserBase):
    """创建用户"""
    pass


class UserUpdate(BaseModel):
    """更新用户信息"""
    email: Optional[EmailStr] = Field(None, description="邮箱地址")
    avatar_url: Optional[str] = Field(None, max_length=500, description="头像URL")


class UserResponse(UserBase):
    """用户响应"""
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class UserWithStats(UserResponse):
    """带统计信息的用户响应"""
    total_results: int = Field(0, description="总提交次数")
    best_overall_time: Optional[float] = Field(None, description="最佳总耗时")
    current_rank: Optional[int] = Field(None, description="当前排名")


class UserProfile(UserResponse):
    """用户档案"""
    total_results: int
    best_result: Optional[dict] = None
    recent_results: list[dict] = []
    rank_info: dict = {}