# -*- coding: utf-8 -*-
"""
认证依赖注入
"""
import pymysql
from fastapi import HTTPException, status, Request, Depends
from typing import Optional
from app.dependencies.jwt_utils import verify_token
from app.dependencies.database import get_db_connection


def get_current_user_from_token(request: Request):
    """从请求中获取当前用户"""
    # 首先尝试从cookie获取token
    token = request.cookies.get("auth_token")

    if not token:
        # 如果cookie中没有，尝试从Authorization header获取（向后兼容）
        authorization = request.headers.get("authorization")
        if authorization and authorization.startswith("Bearer "):
            token = authorization.split(" ")[1]

    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="缺少认证令牌"
        )

    payload = verify_token(token)

    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="无效的认证令牌"
        )

    user_id = payload.get("user_id")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="令牌中缺少用户信息"
        )

    # 从数据库获取用户信息
    try:
        db = get_db_connection()
        cursor = db.cursor(pymysql.cursors.DictCursor)
        cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
        user = cursor.fetchone()
        cursor.close()
        db.close()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="用户不存在"
            )

        return user
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"数据库错误: {str(e)}"
        )
