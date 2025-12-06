# -*- coding: utf-8 -*-
"""
排行榜API路由
"""

from fastapi import APIRouter, Query, HTTPException, status, Depends
from sqlalchemy.orm import Session
from typing import Optional, List

from app.core.database import get_db
from app.core.auth import get_current_user_from_token, OptionalAuth
from app.models.user import User
from app.services.benchmark_service import BenchmarkService
from loguru import logger

router = APIRouter()


def get_benchmark_service(db: Session = Depends(get_db)) -> BenchmarkService:
    """获取基准测试服务实例"""
    return BenchmarkService(db)


@router.get("/")
async def get_leaderboard(
    device_type: Optional[str] = Query(None, description="设备类型: server, consumer"),
    page: int = Query(1, ge=1, description="页码"),
    limit: int = Query(20, ge=1, le=100, description="每页数量"),
    service: BenchmarkService = Depends(get_benchmark_service)
):
    """获取排行榜"""
    try:
        if device_type and device_type not in ["server", "consumer"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="无效的设备类型，必须是 'server', 'consumer' 或不指定"
            )

        leaderboard_data, total = service.get_leaderboard(
            device_type=device_type,
            page=page,
            limit=limit
        )

        pages = (total + limit - 1) // limit if total > 0 else 1

        return {
            "success": True,
            "data": {
                "leaderboard": leaderboard_data,
                "pagination": {
                    "page": page,
                    "limit": limit,
                    "total": total,
                    "pages": pages,
                    "has_next": page < pages,
                    "has_prev": page > 1
                },
                "filter": {
                    "device_type": device_type
                }
            },
            "message": "排行榜获取成功"
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"获取排行榜失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="获取排行榜失败"
        )


@router.get("/statistics")
async def get_statistics(
    service: BenchmarkService = Depends(get_benchmark_service)
):
    """获取排行榜统计信息"""
    try:
        stats = service.get_statistics()
        return {
            "success": True,
            "data": stats,
            "message": "统计信息获取成功"
        }

    except Exception as e:
        logger.error(f"获取统计信息失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="获取统计信息失败"
        )


@router.get("/my-rank")
async def get_my_rank(
    device_type: Optional[str] = Query(None, description="设备类型: server, consumer"),
    current_user: User = Depends(get_current_user_from_token),
    service: BenchmarkService = Depends(get_benchmark_service)
):
    """获取我的排名"""
    try:
        if device_type and device_type not in ["server", "consumer"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="无效的设备类型，必须是 'server', 'consumer' 或不指定"
            )

        # 获取排行榜数据
        leaderboard_data, total = service.get_leaderboard(
            device_type=device_type,
            page=1,
            limit=1000  # 获取更多数据用于查找排名
        )

        # 查找当前用户的排名
        my_rank = None
        my_result = None
        for idx, result in enumerate(leaderboard_data):
            if result['user_id'] == current_user.id:
                my_rank = result['rank']
                my_result = result
                break

        return {
            "success": True,
            "data": {
                "rank": my_rank,
                "result": my_result,
                "total_participants": total,
                "device_type": device_type
            },
            "message": "排名获取成功" if my_rank else "暂无排名数据"
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"获取我的排名失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="获取我的排名失败"
        )


@router.get("/device-types")
async def get_device_types():
    """获取支持的设备类型列表"""
    return {
        "success": True,
        "data": [
            {
                "value": "server",
                "label": "服务器级",
                "description": "Xeon, EPYC, Opteron等服务器处理器"
            },
            {
                "value": "consumer",
                "label": "消费级",
                "description": "Core i7, Ryzen, Apple M系列等消费级处理器"
            }
        ],
        "message": "设备类型列表获取成功"
    }