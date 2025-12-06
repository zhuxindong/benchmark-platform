# -*- coding: utf-8 -*-
"""
认证中间件和工具函数
"""

from functools import wraps
from typing import Optional, Callable
from fastapi import HTTPException, status, Depends, Request
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.services.auth_service import jwt_service
from app.models.user import User
from loguru import logger


def get_current_user_from_token(
    request: Request,
    db: Session = Depends(get_db)
) -> User:
    """从请求中提取当前用户"""
    try:
        # 从请求头获取token
        authorization = request.headers.get("authorization")
        if not authorization or not authorization.startswith("Bearer "):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="缺少认证令牌",
                headers={"WWW-Authenticate": "Bearer"}
            )

        token = authorization.split(" ")[1]

        # 验证token
        payload = jwt_service.verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="无效的认证令牌",
                headers={"WWW-Authenticate": "Bearer"}
            )

        # 获取用户信息
        user_id = payload.get("user_id")
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="令牌中缺少用户信息",
                headers={"WWW-Authenticate": "Bearer"}
            )

        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="用户不存在",
                headers={"WWW-Authenticate": "Bearer"}
            )

        return user

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"认证失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="认证失败",
            headers={"WWW-Authenticate": "Bearer"}
        )


# 依赖注入函数
CurrentUser = Depends(get_current_user_from_token)


def require_auth(func: Callable) -> Callable:
    """装饰器：要求用户认证"""
    @wraps(func)
    async def wrapper(*args, **kwargs):
        # 这个装饰器主要用于在非依赖注入的场景中使用
        # 在FastAPI中更推荐使用CurrentUser依赖注入
        return await func(*args, **kwargs)
    return wrapper


class OptionalAuth:
    """可选认证依赖"""
    def __init__(self, auto_error: bool = False):
        self.auto_error = auto_error

    def __call__(
        self,
        request: Request,
        db: Session = Depends(get_db)
    ) -> Optional[User]:
        try:
            return get_current_user_from_token(request, db)
        except HTTPException:
            if self.auto_error:
                raise
            return None


# 创建可选认证依赖
OptionalCurrentUser = OptionalAuth(auto_error=False)