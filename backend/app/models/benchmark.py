# -*- coding: utf-8 -*-
"""
基准测试结果模型
"""

from sqlalchemy import Column, Integer, String, DateTime, Text, Boolean, DECIMAL, BIGINT, ForeignKey, Enum
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.core.database import Base
import enum


class DeviceType(enum.Enum):
    """设备类型枚举"""
    SERVER = "server"
    CONSUMER = "consumer"
    UNKNOWN = "unknown"


class BenchmarkResult(Base):
    """基准测试结果模型"""
    __tablename__ = "benchmark_results"

    id = Column(BIGINT, primary_key=True, index=True, comment="结果ID")
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True, comment="用户ID")
    username = Column(String(100), nullable=False, index=True, comment="提交时的用户名")

    # 系统信息
    cpu_model = Column(String(255), nullable=True, comment="CPU型号")
    cpu_cores = Column(Integer, nullable=True, comment="逻辑核心数")
    memory_gb = Column(DECIMAL(10, 2), nullable=True, comment="内存大小(GB)")

    # 设备类型信息
    device_type = Column(Enum(DeviceType), default=DeviceType.UNKNOWN, nullable=False, comment="设备类型: server(服务器级), consumer(消费级), unknown(未知)")
    device_type_confidence = Column(DECIMAL(3, 2), default=0.00, nullable=False, comment="设备类型识别置信度 (0.00-1.00)")
    device_type_manually_corrected = Column(Boolean, default=False, nullable=False, comment="设备类型是否被用户手动修正")

    # 性能数据
    phase1_wall_time = Column(DECIMAL(15, 6), nullable=True, comment="Phase 1 耗时(秒)")
    phase2_wall_time = Column(DECIMAL(15, 6), nullable=True, comment="Phase 2 耗时(秒)")
    overall_wall_time = Column(DECIMAL(15, 6), nullable=True, index=True, comment="总耗时(秒)")

    # 计算得出的性能指标
    throughput_keys_per_sec = Column(BIGINT, nullable=True, comment="Phase 1 吞吐量(密钥/秒)")
    performance_score = Column(DECIMAL(15, 6), nullable=True, index=True, comment="综合性能分数")

    # 元数据
    raw_result_text = Column(Text, nullable=True, comment="原始基准测试结果文本")
    ip_address = Column(String(45), nullable=True, comment="提交者IP地址")
    user_agent = Column(Text, nullable=True, comment="用户代理字符串")
    submission_source = Column(String(50), default="web", comment="提交来源: web, api, cli")
    is_verified = Column(Boolean, default=False, index=True, comment="是否已验证通过")
    notes = Column(Text, nullable=True, comment="备注信息")

    # 时间戳
    submitted_at = Column(DateTime(timezone=True), server_default=func.now(), index=True, comment="提交时间")
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), comment="更新时间")

    # 关联关系
    user = relationship("User", back_populates="benchmark_results")

    def __repr__(self):
        return f"<BenchmarkResult(id={self.id}, username='{self.username}', overall_time={self.overall_wall_time})>"

    @property
    def formatted_time(self) -> str:
        """格式化总耗时显示"""
        if self.overall_wall_time:
            return f"{float(self.overall_wall_time):.3f}s"
        return "N/A"

    @property
    def formatted_cpu_info(self) -> str:
        """格式化CPU信息显示"""
        parts = []
        if self.cpu_model:
            parts.append(self.cpu_model)
        if self.cpu_cores:
            parts.append(f"{self.cpu_cores}核")
        if self.memory_gb:
            parts.append(f"{self.memory_gb}GB")
        return " | ".join(parts) if parts else "未知"

    @property
    def device_type_label(self) -> str:
        """获取设备类型的中文标签"""
        labels = {
            DeviceType.SERVER: "服务器级",
            DeviceType.CONSUMER: "消费级",
            DeviceType.UNKNOWN: "未知"
        }
        return labels.get(self.device_type, "未知")

    @property
    def confidence_level(self) -> str:
        """获取置信度级别描述"""
        confidence = float(self.device_type_confidence) if self.device_type_confidence else 0.0
        if confidence >= 0.9:
            return "高"
        elif confidence >= 0.7:
            return "中"
        elif confidence >= 0.5:
            return "低"
        else:
            return "未知"

    def can_be_corrected_by_user(self) -> bool:
        """判断设备类型是否可以被用户手动修正"""
        # 如果置信度低于0.7，允许用户修正
        # 如果是手动修正过的，也允许再次修正
        return (self.device_type_confidence < 0.7) or self.device_type_manually_corrected

    def auto_classify_device_type(self) -> None:
        """自动分类设备类型"""
        from app.utils.device_classifier import get_device_type_with_confidence

        if self.cpu_model:
            device_type_str, confidence = get_device_type_with_confidence(self.cpu_model)

            # 更新设备类型
            if device_type_str == 'server':
                self.device_type = DeviceType.SERVER
            elif device_type_str == 'consumer':
                self.device_type = DeviceType.CONSUMER
            else:
                self.device_type = DeviceType.UNKNOWN

            self.device_type_confidence = confidence