# -*- coding: utf-8 -*-
"""
健康检查和基础路由
"""
from fastapi import APIRouter

from app.dependencies.database import get_db_connection
from app.config import CLIENT_ID, CLIENT_SECRET

router = APIRouter(tags=["基础"])


@router.get("/")
async def root():
    """根路由"""
    return {
        "message": "基准测试评分平台",
        "version": "2.0.0",
        "docs": "/docs",
        "auth": "/api/v1/auth/login"
    }


@router.get("/health")
async def health_check():
    """健康检查"""
    try:
        db = get_db_connection()
        cursor = db.cursor()
        cursor.execute("SELECT 1 as test")
        result = cursor.fetchone()
        cursor.close()
        db.close()
        return {
            "status": "healthy",
            "database": "connected",
            "oauth_configured": bool(CLIENT_ID and CLIENT_SECRET)
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(e)
        }
