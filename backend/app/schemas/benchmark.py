# -*- coding: utf-8 -*-
"""
基准测试结果的数据验证模式
"""

from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime


class BenchmarkResultBase(BaseModel):
    """基准测试结果基础模式"""
    # 系统信息
    cpu_model: Optional[str] = Field(None, description="CPU型号")
    cpu_cores: Optional[int] = Field(None, ge=1, le=256, description="逻辑核心数")
    memory_gb: Optional[float] = Field(None, ge=0.1, le=1024, description="内存大小(GB)")

    # 性能数据
    phase1_wall_time: Optional[float] = Field(None, ge=0.001, description="Phase 1 耗时(秒)")
    phase2_wall_time: Optional[float] = Field(None, ge=0.001, description="Phase 2 耗时(秒)")
    overall_wall_time: Optional[float] = Field(None, ge=0.001, description="总耗时(秒)")

    # 原始数据
    raw_result_text: Optional[str] = Field(None, max_length=10000, description="原始基准测试结果文本")

    @validator('phase1_wall_time', 'phase2_wall_time', 'overall_wall_time')
    def validate_times(cls, v):
        """验证时间数据精度"""
        if v is not None:
            # 确保最多6位小数
            return round(v, 6)
        return v

    @validator('cpu_model')
    def validate_cpu_model(cls, v):
        """验证CPU型号"""
        if v:
            return v.strip()[:255]  # 限制长度
        return v


class BenchmarkResultCreate(BenchmarkResultBase):
    """创建基准测试结果"""
    pass


class BenchmarkResultUpdate(BaseModel):
    """更新基准测试结果"""
    cpu_model: Optional[str] = Field(None, description="CPU型号")
    cpu_cores: Optional[int] = Field(None, ge=1, le=256, description="逻辑核心数")
    memory_gb: Optional[float] = Field(None, ge=0.1, le=1024, description="内存大小(GB)")
    phase1_wall_time: Optional[float] = Field(None, ge=0.001, description="Phase 1 耗时(秒)")
    phase2_wall_time: Optional[float] = Field(None, ge=0.001, description="Phase 2 耗时(秒)")
    overall_wall_time: Optional[float] = Field(None, ge=0.001, description="总耗时(秒)")
    notes: Optional[str] = Field(None, max_length=1000, description="备注信息")


class BenchmarkResultResponse(BenchmarkResultBase):
    """基准测试结果响应"""
    id: int
    user_id: int
    username: str
    throughput_keys_per_sec: Optional[int] = None
    performance_score: Optional[float] = None
    ip_address: Optional[str] = None
    submission_source: str
    is_verified: bool
    notes: Optional[str] = None
    submitted_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class BenchmarkResultList(BaseModel):
    """基准测试结果列表"""
    results: list[BenchmarkResultResponse]
    total: int
    page: int
    limit: int
    pages: int