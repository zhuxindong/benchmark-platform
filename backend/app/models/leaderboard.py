# -*- coding: utf-8 -*-
"""
排行榜快照模型
"""
from sqlalchemy import Column, BigInteger, Integer, String, Date, DECIMAL, TIMESTAMP, Enum
from datetime import datetime, timezone
from app.models.base import Base
from app.models.benchmark import DeviceType


class LeaderboardSnapshot(Base):
    """排行榜快照表"""
    __tablename__ = 'leaderboard_snapshots'

    id = Column(BigInteger, primary_key=True, autoincrement=True, comment='快照ID')
    snapshot_date = Column(Date, nullable=False, index=True, comment='快照日期')
    rank_position = Column(Integer, nullable=False, comment='排名位置')
    user_id = Column(BigInteger, nullable=False, index=True, comment='用户ID')
    username = Column(String(100), nullable=False, comment='用户名')
    benchmark_result_id = Column(BigInteger, nullable=False, comment='基准测试结果ID')
    overall_wall_time = Column(DECIMAL(15, 6), nullable=False, comment='总耗时(秒)')
    performance_score = Column(DECIMAL(15, 6), nullable=False, comment='性能分数')
    device_type = Column(Enum(DeviceType), default=DeviceType.unknown, nullable=True, comment='设备类型')
    cpu_model = Column(String(255), nullable=True, comment='CPU型号')
    created_at = Column(TIMESTAMP, default=lambda: datetime.now(timezone.utc), nullable=False, comment='创建时间')

    def __repr__(self):
        return f"<LeaderboardSnapshot(id={self.id}, date={self.snapshot_date}, rank={self.rank_position})>"

    def to_dict(self):
        """转换为字典"""
        return {
            'id': self.id,
            'snapshot_date': self.snapshot_date.isoformat() if self.snapshot_date else None,
            'rank_position': self.rank_position,
            'user_id': self.user_id,
            'username': self.username,
            'benchmark_result_id': self.benchmark_result_id,
            'overall_wall_time': float(self.overall_wall_time) if self.overall_wall_time else None,
            'performance_score': float(self.performance_score) if self.performance_score else None,
            'device_type': self.device_type.value if self.device_type else None,
            'cpu_model': self.cpu_model,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
