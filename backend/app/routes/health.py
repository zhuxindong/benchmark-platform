# -*- coding: utf-8 -*-
"""
健康检查和基础路由 - 使用 ORM
"""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text

from app.dependencies.database import get_db
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
async def health_check(db: Session = Depends(get_db)):
    """健康检查"""
    try:
        # 使用 ORM 测试数据库连接
        result = db.execute(text("SELECT 1 as test")).fetchone()
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
