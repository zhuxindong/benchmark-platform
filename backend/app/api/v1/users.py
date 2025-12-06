# -*- coding: utf-8 -*-
"""
用户相关API路由
"""

from fastapi import APIRouter, HTTPException, status, Depends
from app.core.auth import get_current_user_from_token
from app.models.user import User
from app.schemas.user import UserResponse, UserProfile
from loguru import logger

router = APIRouter()


@router.get("/me", response_model=UserResponse)
async def get_current_user(current_user: User = Depends(get_current_user_from_token)):
    """获取当前用户信息"""
    return UserResponse.from_orm(current_user)


@router.get("/profile", response_model=UserProfile)
async def get_user_profile(current_user: User = Depends(get_current_user_from_token)):
    """获取用户档案"""
    from app.services.benchmark_service import BenchmarkService
    from app.core.database import get_db
    from sqlalchemy.orm import Session

    db = next(get_db())
    try:
        service = BenchmarkService(db)

        # 获取用户统计信息
        results, total = service.get_user_results(current_user.id, 1, 10)

        # 获取最佳成绩
        best_result = None
        if results:
            best_result = service.db.query(service.db.query().__class__).filter(
                # 这里需要实现获取最佳成绩的逻辑
                # 暂时返回第一个结果
            ).first()

        profile = UserProfile(
            **UserResponse.from_orm(current_user).dict(),
            total_results=total,
            best_result=best_result.dict() if best_result else None,
            recent_results=[result.dict() for result in results[:5]],
            rank_info={}
        )

        return profile

    finally:
        db.close()