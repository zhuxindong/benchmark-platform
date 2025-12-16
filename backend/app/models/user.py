# -*- coding: utf-8 -*-
"""
用户模型
"""
from sqlalchemy import Column, BigInteger, String, TIMESTAMP
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.models.base import Base


class User(Base):
    """用户信息表"""
    __tablename__ = 'users'

    id = Column(BigInteger, primary_key=True, autoincrement=True, comment='用户ID')
    username = Column(String(100), unique=True, nullable=False, index=True, comment='linux.do 用户名')
    user_id = Column(String(100), unique=True, nullable=False, index=True, comment='linux.do 用户ID')
    email = Column(String(255), nullable=True, comment='邮箱地址')
    avatar_url = Column(String(500), nullable=True, comment='头像URL')
    created_at = Column(TIMESTAMP, default=lambda: datetime.now(timezone.utc), nullable=False, index=True, comment='创建时间')
    updated_at = Column(TIMESTAMP, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False, comment='更新时间')

    # 关系
    benchmark_results = relationship('BenchmarkResult', back_populates='user', cascade='all, delete-orphan')

    def __repr__(self):
        return f"<User(id={self.id}, username='{self.username}')>"

    def to_dict(self):
        """转换为字典"""
        return {
            'id': self.id,
            'username': self.username,
            'user_id': self.user_id,
            'email': self.email,
            'avatar_url': self.avatar_url,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
