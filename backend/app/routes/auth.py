# -*- coding: utf-8 -*-
"""
认证相关路由 - 使用 ORM
"""
from fastapi import APIRouter, HTTPException, status, Depends, Request
from fastapi.responses import JSONResponse, RedirectResponse
from pydantic import BaseModel
from typing import Optional
from datetime import datetime, timezone, timedelta
import httpx
import secrets
from urllib.parse import urlencode
from sqlalchemy.orm import Session

from app.dependencies.database import get_db
from app.dependencies.jwt_utils import create_jwt_token, verify_token
from app.dependencies.auth import get_current_user_from_token
from app.models import User
from app.config import (
    CLIENT_ID, CLIENT_SECRET, REDIRECT_URI,
    AUTHORIZATION_ENDPOINT, TOKEN_ENDPOINT, USER_ENDPOINT,
    ENABLE_MOCK_LOGIN,
    get_frontend_url
)

router = APIRouter(prefix="/api/v1/auth", tags=["认证"])


class CallbackRequest(BaseModel):
    code: str
    state: Optional[str] = None


class LoginResponse(BaseModel):
    authorization_url: str
    state: str


class MockLoginRequest(BaseModel):
    username: str
    email: Optional[str] = None


@router.get("/login", response_model=LoginResponse)
async def login():
    """获取登录URL"""
    if not CLIENT_ID:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="OAuth 未配置"
        )

    state = "benchmark_" + secrets.token_urlsafe(16)

    params = {
        "client_id": CLIENT_ID,
        "redirect_uri": REDIRECT_URI,
        "response_type": "code",
        "scope": "read",
        "state": state
    }

    auth_url = AUTHORIZATION_ENDPOINT
    authorization_url = f"{auth_url}?{urlencode(params)}"

    return LoginResponse(
        authorization_url=authorization_url,
        state=state
    )


@router.post("/linuxdo/callback")
async def linuxdo_callback_post(request: CallbackRequest, db: Session = Depends(get_db)):
    """处理OAuth回调 - POST方法"""
    return await _process_oauth_callback(request.code, db)


@router.get("/linuxdo/callback")
async def linuxdo_callback_get(code: str, state: str = None, db: Session = Depends(get_db)):
    """处理OAuth回调 - GET方法"""
    return await _process_oauth_callback(code, db)


async def _process_oauth_callback(code: str, db: Session):
    """处理OAuth回调的通用逻辑"""
    try:
        # 交换访问令牌
        token_url = TOKEN_ENDPOINT
        data = {
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "code": code,
            "grant_type": "authorization_code",
            "redirect_uri": REDIRECT_URI
        }

        headers = {"Content-Type": "application/x-www-form-urlencoded"}

        async with httpx.AsyncClient() as client:
            response = await client.post(token_url, data=data, headers=headers)
            response.raise_for_status()
            token_data = response.json()

        # 获取用户信息
        access_token = token_data.get("access_token")
        if not access_token:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="未获取到访问令牌"
            )

        user_info_url = USER_ENDPOINT
        headers = {
            "Authorization": f"Bearer {access_token}",
            "User-Agent": "Benchmark-Platform/1.0"
        }

        async with httpx.AsyncClient() as client:
            response = await client.get(user_info_url, headers=headers)
            response.raise_for_status()
            user_data = response.json()

        # linux.do API 直接返回用户信息
        user = user_data
        if not user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="无法获取用户信息"
            )

        # 查找或创建用户 - 使用 ORM
        linux_do_user_id = str(user.get("id"))
        username = user.get("username")

        existing_user = db.query(User).filter(
            (User.user_id == linux_do_user_id) | (User.username == username)
        ).first()

        if existing_user:
            # 更新现有用户
            existing_user.username = username
            existing_user.email = user.get("email")
            existing_user.avatar_url = user.get("avatar_template", "").replace("{size}", "120")
            existing_user.updated_at = datetime.now(timezone.utc)
            user_record = existing_user
        else:
            # 创建新用户
            user_record = User(
                username=username,
                user_id=linux_do_user_id,
                email=user.get("email"),
                avatar_url=user.get("avatar_template", "").replace("{size}", "120"),
                created_at=datetime.now(timezone.utc),
                updated_at=datetime.now(timezone.utc)
            )
            db.add(user_record)

        db.commit()
        db.refresh(user_record)

        # 创建JWT令牌
        token_data = {
            "user_id": int(user_record.id),
            "username": str(user_record.username),
            "user_do_id": str(user_record.user_id)
        }
        access_token = create_jwt_token(token_data)

        # 重定向到前端OAuth回调页面
        frontend_url = f"{get_frontend_url()}/oauth/callback"
        redirect_params = f"?success=true&username={user_record.username}&user_id={user_record.id}&user_do_id={user_record.user_id}&avatar_url={user_record.avatar_url or ''}&email={user_record.email or ''}"

        response = RedirectResponse(url=f"{frontend_url}{redirect_params}", status_code=302)
        # 设置cookie
        response.set_cookie(
            key="auth_token",
            value=access_token,
            max_age=24*60*60,
            expires=datetime.now(timezone.utc) + timedelta(hours=24),
            path="/",
            domain=None,
            secure=False,  # 生产环境应设为True
            httponly=True,
            samesite="lax"
        )
        return response

    except httpx.HTTPStatusError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"OAuth认证失败: {e.response.text}"
        )
    except Exception as e:
        import traceback
        error_detail = f"认证处理失败: {str(e)}\n详细错误: {traceback.format_exc()}"
        print(error_detail)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"认证处理失败: {str(e)}"
        )


@router.get("/me")
async def get_current_user_info(current_user: User = Depends(get_current_user_from_token)):
    """获取当前用户信息"""
    return {
        "id": current_user.id,
        "username": current_user.username,
        "user_id": current_user.user_id,
        "email": current_user.email,
        "avatar_url": current_user.avatar_url,
        "created_at": current_user.created_at.isoformat() if current_user.created_at else None
    }


@router.post("/logout")
async def logout():
    """登出"""
    response = JSONResponse(content={"success": True, "message": "登出成功"})
    response.delete_cookie(
        key="auth_token",
        path="/",
        samesite="lax"
    )
    return response


@router.post("/mock-login")
async def mock_login(request: MockLoginRequest, db: Session = Depends(get_db)):
    """Mock登录 - 仅用于本地测试"""
    if not ENABLE_MOCK_LOGIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Mock登录功能已禁用"
        )

    try:
        # 查找现有用户
        existing_user = db.query(User).filter(User.username == request.username).first()

        if existing_user:
            # 更新现有用户
            if request.email:
                existing_user.email = request.email
            existing_user.updated_at = datetime.now(timezone.utc)
            user_record = existing_user
        else:
            # 创建新用户
            mock_user_id = f"mock_{secrets.token_urlsafe(8)}"
            user_record = User(
                username=request.username,
                user_id=mock_user_id,
                email=request.email,
                avatar_url=f"https://ui-avatars.com/api/?name={request.username}&background=667eea&color=fff",
                created_at=datetime.now(timezone.utc),
                updated_at=datetime.now(timezone.utc)
            )
            db.add(user_record)

        db.commit()
        db.refresh(user_record)

        token_data = {
            "user_id": int(user_record.id),
            "username": str(user_record.username),
            "user_do_id": str(user_record.user_id)
        }
        access_token = create_jwt_token(token_data)

        response = JSONResponse(content={
            "success": True,
            "message": "Mock登录成功",
            "user": {
                "id": user_record.id,
                "username": user_record.username,
                "user_id": user_record.user_id,
                "email": user_record.email,
                "avatar_url": user_record.avatar_url
            }
        })

        response.set_cookie(
            key="auth_token",
            value=access_token,
            max_age=24*60*60,
            expires=datetime.now(timezone.utc) + timedelta(hours=24),
            path="/",
            domain=None,
            secure=False,
            httponly=True,
            samesite="lax"
        )

        return response

    except Exception as e:
        import traceback
        error_detail = f"Mock登录失败: {str(e)}\n{traceback.format_exc()}"
        print(error_detail)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Mock登录失败: {str(e)}"
        )


@router.get("/verify-token")
async def verify_token_endpoint(request: Request):
    """验证令牌"""
    try:
        authorization = request.headers.get("authorization")
        if not authorization or not authorization.startswith("Bearer "):
            return {"valid": False, "message": "缺少认证令牌"}

        token = authorization.split(" ")[1]
        payload = verify_token(token)

        if not payload:
            return {"valid": False, "message": "无效令牌"}

        return {
            "valid": True,
            "message": "令牌有效",
            "user": {
                "id": payload.get("user_id"),
                "username": payload.get("username")
            }
        }

    except Exception as e:
        return {"valid": False, "message": f"验证失败: {str(e)}"}
