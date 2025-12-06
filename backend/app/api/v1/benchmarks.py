# -*- coding: utf-8 -*-
"""
基准测试结果API路由
"""

from fastapi import APIRouter, HTTPException, status, Depends, Request
from sqlalchemy.orm import Session
from typing import List, Optional

from app.core.database import get_db
from app.core.auth import get_current_user_from_token, OptionalAuth
from app.models.user import User
from app.schemas.benchmark import (
    BenchmarkResultCreate, BenchmarkResultResponse, BenchmarkResultList,
    BenchmarkResultUpdate
)
from app.services.benchmark_service import BenchmarkService
from loguru import logger

router = APIRouter()


def get_benchmark_service(db: Session = Depends(get_db)) -> BenchmarkService:
    """获取基准测试服务实例"""
    return BenchmarkService(db)


@router.post("/submit", response_model=BenchmarkResultResponse)
async def submit_benchmark(
    benchmark_data: BenchmarkResultCreate,
    request: Request,
    current_user: User = Depends(get_current_user_from_token),
    service: BenchmarkService = Depends(get_benchmark_service)
):
    """提交基准测试结果"""
    try:
        # 检查用户提交���制
        can_submit, verified_count = service.check_user_submission_limit(current_user.id)
        if not can_submit:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"每个用户最多只能提交 {service.max_results_per_user} 条已验证的基准测试结果，当前已提交 {verified_count} 条"
            )

        # 获取客户端信息
        client_ip = request.client.host
        user_agent = request.headers.get("user-agent")

        # 创建基准测试结果
        result = service.create_benchmark_result(
            user_id=current_user.id,
            username=current_user.username,
            benchmark_data=benchmark_data,
            ip_address=client_ip,
            user_agent=user_agent,
            raw_text=benchmark_data.raw_result_text
        )

        logger.info(f"用户 {current_user.username} 提交了基准测试结果，ID: {result.id}")
        return result

    except ValueError as e:
        # 处理用户提交限制错误
        logger.warning(f"用户 {current_user.username} 提交失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"提交基准测试结果失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="提交基准测试结果失败"
        )


@router.get("/my-results", response_model=BenchmarkResultList)
async def get_my_results(
    current_user: User = Depends(get_current_user_from_token),
    page: int = 1,
    limit: int = 20,
    service: BenchmarkService = Depends(get_benchmark_service)
):
    """获取当前用户的基准测试结果"""
    try:
        if page < 1:
            page = 1
        if limit < 1 or limit > 100:
            limit = 20

        results, total = service.get_user_results(current_user.id, page, limit)
        pages = (total + limit - 1) // limit

        return BenchmarkResultList(
            results=results,
            total=total,
            page=page,
            limit=limit,
            pages=pages
        )

    except Exception as e:
        logger.error(f"获取用户基准测试结果失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="获取基准测试结果失败"
        )


@router.get("/leaderboard")
async def get_leaderboard(
    device_type: Optional[str] = Query(None, description="设备类型: server, consumer"),
    page: int = Query(1, ge=1, description="页码"),
    limit: int = Query(20, ge=1, le=100, description="每页数量"),
    service: BenchmarkService = Depends(get_benchmark_service)
):
    """获取排行榜数据"""
    try:
        from app.services.benchmark_service import DeviceType
        from app.schemas.leaderboard import LeaderboardResponse

        # 转换设备类型字符串为枚举
        device_type_enum = None
        if device_type:
            try:
                device_type_enum = DeviceType(device_type)
            except ValueError:
                device_type_enum = None

        result = service.get_leaderboard(
            device_type=device_type_enum,
            page=page,
            limit=limit
        )

        return LeaderboardResponse(
            success=True,
            data=result
        )

    except Exception as e:
        logger.error(f"获取排行榜失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="获取排行榜失败"
        )


@router.get("/{result_id}", response_model=BenchmarkResultResponse)
async def get_benchmark_result(
    result_id: int,
    service: BenchmarkService = Depends(get_benchmark_service)
):
    """获取特定基准测试结果"""
    try:
        result = service.get_result_by_id(result_id)

        if not result:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="基准测试结果不存在"
            )

        return result

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"获取基准测试结果失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="获取基准测试结果失败"
        )


@router.put("/{result_id}", response_model=BenchmarkResultResponse)
async def update_benchmark_result(
    result_id: int,
    update_data: BenchmarkResultUpdate,
    current_user: User = Depends(get_current_user_from_token),
    service: BenchmarkService = Depends(get_benchmark_service)
):
    """更新基准测试结果"""
    try:
        result = service.update_result(result_id, current_user.id, update_data)

        if not result:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="基准测试结果不存在或无权限修改"
            )

        logger.info(f"用户 {current_user.username} 更新基准测试结果 {result_id}")
        return result

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"更新基准测试结果失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="更新基准测试结果失败"
        )


@router.delete("/{result_id}")
async def delete_benchmark_result(
    result_id: int,
    current_user: User = Depends(get_current_user_from_token),
    service: BenchmarkService = Depends(get_benchmark_service)
):
    """删除基准测试结果"""
    try:
        success = service.delete_result(result_id, current_user.id)

        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="基准测试结果不存在或无权限删除"
            )

        logger.info(f"用户 {current_user.username} 删除基准测试结果 {result_id}")
        return {"message": "基准测试结果已删除"}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"删除基准测试结果失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="删除基准测试结果失败"
        )


@router.put("/{result_id}/device-type")
async def update_device_type(
    result_id: int,
    request: Request,
    current_user: User = Depends(get_current_user_from_token),
    service: BenchmarkService = Depends(get_benchmark_service)
):
    """更新基准测试结果的设备类型"""
    try:
        body = await request.json()
        device_type = body.get("device_type")

        if device_type not in ["server", "consumer", "unknown"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="无效的设备类型，必须是 'server', 'consumer' 或 'unknown'"
            )

        result = service.update_device_type(result_id, current_user.id, device_type)

        if not result:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="基准测试结果不存在或无权限修改"
            )

        logger.info(f"用户 {current_user.username} 修正了基准测试结果 {result_id} 的设备类型为 {device_type}")
        return {
            "message": "设备类型更新成功",
            "device_type": result.device_type.value,
            "device_type_label": result.device_type_label,
            "device_type_confidence": float(result.device_type_confidence),
            "manually_corrected": result.device_type_manually_corrected
        }

    except ValueError as e:
        # 处理设备类型修正限制错误
        logger.warning(f"用户 {current_user.username} 修正设备类型失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"更新设备类型失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="更新设备类型失败"
        )


@router.post("/parse")
async def parse_benchmark_text(
    request: Request,
    service: BenchmarkService = Depends(get_benchmark_service)
):
    """解析基准测试结果文本"""
    try:
        body = await request.json()
        text = body.get("text", "")

        if not text:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="缺少基准测试结果文本"
            )

        parsed_data = service.parse_benchmark_text(text)

        if not parsed_data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="无法解析基准测试结果文本"
            )

        return {
            "success": True,
            "data": parsed_data,
            "message": "解析成功"
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"解析基准测试文本失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="解析基准测试结果失败"
        )