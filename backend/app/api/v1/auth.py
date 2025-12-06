# -*- coding: utf-8 -*-
"""
认证相关API路由
"""

from fastapi import APIRouter, HTTPException, status, Depends, Request, Response
from sqlalchemy.orm import Session
from typing import Optional
from urllib.parse import urlencode

from app.core.database import get_db
from app.services.auth_service import LinuxDoAuthService, jwt_service
from app.schemas.user import UserResponse
from app.core.logging import setup_logging
from loguru import logger
from pydantic import BaseModel

setup_logging()

router = APIRouter()


class CallbackRequest(BaseModel):
    """OAuth 回调请求"""
    code: str
    state: Optional[str] = None


class LoginResponse(BaseModel):
    """登录响应"""
    authorization_url: str
    state: str


@router.get("/login", response_model=LoginResponse)
async def login(db: Session = Depends(get_db)):
    """获取 linux.do 登录URL"""
    try:
        auth_service = LinuxDoAuthService(db)
        state = "temp_state_" + str(hash("benchmark_platform"))

        if not auth_service.client_id:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="linux.do OAuth 未配置，请联系管理员"
            )

        authorization_url = auth_service.get_authorization_url(state)

        logger.info("生成登录URL")
        return LoginResponse(
            authorization_url=authorization_url,
            state=state
        )

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"生成登录URL失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="生成登录URL失败"
        )


@router.post("/linuxdo/callback", response_model=dict)
async def linuxdo_callback(
    request: CallbackRequest,
    db: Session = Depends(get_db)
):
    """linux.do OAuth 回调处理"""
    try:
        auth_service = LinuxDoAuthService(db)

        # 认证用户
        user = await auth_service.authenticate_user(request.code)

        # 生成JWT令牌
        access_token = jwt_service.create_user_token(user)

        logger.info(f"用户 {user.username} 登录成功")

        return {
            "success": True,
            "message": "登录成功",
            "access_token": access_token,
            "token_type": "bearer",
            "user": UserResponse.from_orm(user).dict()
        }

    except ValueError as e:
        logger.error(f"OAuth回调失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"认证失败: {str(e)}"
        )
    except Exception as e:
        logger.error(f"OAuth回调异常: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="认证处理失败"
        )


@router.get("/linuxdo/callback")
async def linuxdo_callback_get(
    code: Optional[str] = None,
    state: Optional[str] = None,
    error: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """处理GET方式的OAuth回调（浏览器重定向）"""
    if error:
        logger.error(f"OAuth授权失败: {error}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"授权失败: {error}"
        )

    if not code:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="缺少授权码"
        )

    try:
        auth_service = LinuxDoAuthService(db)
        user = await auth_service.authenticate_user(code)
        access_token = jwt_service.create_user_token(user)

        # 这里可以重定向到前端页面，并将token作为参数传递
        # 暂时返回JSON响应
        return {
            "success": True,
            "message": "登录成功",
            "access_token": access_token,
            "token_type": "bearer",
            "user": UserResponse.from_orm(user).dict()
        }

    except ValueError as e:
        logger.error(f"OAuth回调失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"认证失败: {str(e)}"
        )
    except Exception as e:
        logger.error(f"OAuth回调异常: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="认证处理失败"
        )


@router.post("/me", response_model=UserResponse)
async def get_current_user_info(
    request: Request,
    db: Session = Depends(get_db)
):
    """获取当前登录用户信息"""
    try:
        # 从请求头获取token
        authorization = request.headers.get("authorization")
        if not authorization or not authorization.startswith("Bearer "):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="缺少认证令牌"
            )

        token = authorization.split(" ")[1]

        # 验证token
        payload = jwt_service.verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="无效的认证令牌"
            )

        # 获取用户信息
        user_id = payload.get("user_id")
        from app.models.user import User
        user = db.query(User).filter(User.id == user_id).first()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="用户不存在"
            )

        return UserResponse.from_orm(user)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"获取用户信息失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="获取用户信息失败"
        )


@router.post("/logout")
async def logout():
    """登出（客户端删除token即可）"""
    return {
        "success": True,
        "message": "登出成功"
    }


@router.get("/verify-token")
async def verify_token(
    request: Request,
    db: Session = Depends(get_db)
):
    """验证token是否有效"""
    try:
        authorization = request.headers.get("authorization")
        if not authorization or not authorization.startswith("Bearer "):
            return {"valid": False, "message": "缺少认证令牌"}

        token = authorization.split(" ")[1]
        payload = jwt_service.verify_token(token)

        if not payload:
            return {"valid": False, "message": "无效令牌"}

        # 检查用户是否存在
        user_id = payload.get("user_id")
        from app.models.user import User
        user = db.query(User).filter(User.id == user_id).first()

        if not user:
            return {"valid": False, "message": "用户不存在"}

        return {
            "valid": True,
            "message": "令牌有效",
            "user": {
                "id": user.id,
                "username": user.username,
                "user_id": user.user_id
            }
        }

    except Exception as e:
        logger.error(f"验证令牌失败: {e}")
        return {"valid": False, "message": "验证失败"}