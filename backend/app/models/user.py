# -*- coding: utf-8 -*-
"""
用户模型
"""

from sqlalchemy import Column, Integer, String, DateTime, Text, Boolean
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.core.database import Base


class User(Base):
    """用户模型"""
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True, comment="用户ID")
    username = Column(String(100), unique=True, index=True, nullable=False, comment="linux.do 用户名")
    user_id = Column(String(100), unique=True, index=True, nullable=False, comment="linux.do 用户ID")
    email = Column(String(255), nullable=True, comment="邮箱地址")
    avatar_url = Column(String(500), nullable=True, comment="头像URL")
    created_at = Column(DateTime(timezone=True), server_default=func.now(), comment="创建时间")
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), comment="更新时间")

    # 关联关系
    benchmark_results = relationship("BenchmarkResult", back_populates="user", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<User(username='{self.username}', user_id='{self.user_id}')>"