# -*- coding: utf-8 -*-
"""
ORM 模型
"""
from app.models.base import Base
from app.models.user import User
from app.models.benchmark import BenchmarkResult, DeviceType
from app.models.leaderboard import LeaderboardSnapshot
from app.models.system_config import SystemConfig

__all__ = [
    'Base',
    'User',
    'BenchmarkResult',
    'DeviceType',
    'LeaderboardSnapshot',
    'SystemConfig'
]
