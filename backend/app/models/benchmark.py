# -*- coding: utf-8 -*-
"""
基准测试结果模型
"""
from sqlalchemy import Column, BigInteger, String, Integer, DECIMAL, Text, Boolean, TIMESTAMP, ForeignKey, Enum
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.models.base import Base
import enum


class DeviceType(str, enum.Enum):
    """设备类型枚举"""
    server = 'server'
    consumer = 'consumer'
    unknown = 'unknown'


class BenchmarkResult(Base):
    """基准测试结果表"""
    __tablename__ = 'benchmark_results'

    # 主键和外键
    id = Column(BigInteger, primary_key=True, autoincrement=True, comment='结果ID')
    user_id = Column(BigInteger, ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True, comment='用户ID')
    username = Column(String(100), nullable=False, index=True, comment='用户名（冗余字段）')

    # 系统信息
    cpu_model = Column(String(255), nullable=True, comment='CPU型号')
    cpu_cores = Column(Integer, nullable=True, comment='逻辑核心数')
    memory_gb = Column(DECIMAL(10, 2), nullable=True, comment='内存大小(GB)')

    # 设备类型分类
    device_type = Column(Enum(DeviceType), default=DeviceType.unknown, nullable=True, comment='设备类型')
    device_type_confidence = Column(DECIMAL(3, 2), default=0.00, nullable=True, comment='设备类型置信度')
    device_type_manually_corrected = Column(Boolean, default=False, nullable=True, comment='是否手动修正')

    # 性能数据
    phase1_wall_time = Column(DECIMAL(15, 6), nullable=True, comment='Phase 1 耗时(秒)')
    phase2_wall_time = Column(DECIMAL(15, 6), nullable=True, comment='Phase 2 耗时(秒)')
    overall_wall_time = Column(DECIMAL(15, 6), nullable=True, index=True, comment='总耗时(秒)')

    # 计算得出的性能指标
    throughput_keys_per_sec = Column(BigInteger, nullable=True, comment='Phase 1 吞吐量(密钥/秒)')
    performance_score = Column(DECIMAL(15, 6), nullable=True, index=True, comment='综合性能分数')

    # 元数据
    raw_result_text = Column(Text, nullable=True, comment='原始基准测试结果文本')
    ip_address = Column(String(45), nullable=True, comment='提交者IP地址')
    user_agent = Column(Text, nullable=True, comment='用户代理字符串')
    submission_source = Column(String(50), default='web', nullable=True, comment='提交来源')
    is_verified = Column(Boolean, default=False, nullable=True, index=True, comment='是否已验证通过')
    notes = Column(Text, nullable=True, comment='备注信息')

    # 时间戳
    submitted_at = Column(TIMESTAMP, default=lambda: datetime.now(timezone.utc), nullable=False, index=True, comment='提交时间')
    updated_at = Column(TIMESTAMP, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False, comment='更新时间')

    # 关系
    user = relationship('User', back_populates='benchmark_results')

    def __repr__(self):
        return f"<BenchmarkResult(id={self.id}, username='{self.username}', overall_time={self.overall_wall_time})>"

    def to_dict(self):
        """转换为字典"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'username': self.username,
            'cpu_model': self.cpu_model,
            'cpu_cores': self.cpu_cores,
            'memory_gb': float(self.memory_gb) if self.memory_gb else None,
            'device_type': self.device_type.value if self.device_type else None,
            'device_type_confidence': float(self.device_type_confidence) if self.device_type_confidence else None,
            'device_type_manually_corrected': self.device_type_manually_corrected,
            'phase1_wall_time': float(self.phase1_wall_time) if self.phase1_wall_time else None,
            'phase2_wall_time': float(self.phase2_wall_time) if self.phase2_wall_time else None,
            'overall_wall_time': float(self.overall_wall_time) if self.overall_wall_time else None,
            'throughput_keys_per_sec': self.throughput_keys_per_sec,
            'performance_score': float(self.performance_score) if self.performance_score else None,
            'raw_result_text': self.raw_result_text,
            'ip_address': self.ip_address,
            'user_agent': self.user_agent,
            'submission_source': self.submission_source,
            'is_verified': self.is_verified,
            'notes': self.notes,
            'submitted_at': self.submitted_at.isoformat() if self.submitted_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
