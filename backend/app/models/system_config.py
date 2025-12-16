# -*- coding: utf-8 -*-
"""
系统配置模型
"""
from sqlalchemy import Column, Integer, String, Text, TIMESTAMP
from datetime import datetime, timezone
from app.models.base import Base


class SystemConfig(Base):
    """系统配置表"""
    __tablename__ = 'system_config'

    id = Column(Integer, primary_key=True, autoincrement=True, comment='配置ID')
    config_key = Column(String(100), unique=True, nullable=False, index=True, comment='配置键')
    config_value = Column(Text, nullable=True, comment='配置值')
    config_type = Column(String(20), default='string', nullable=True, comment='配置类型')
    description = Column(String(255), nullable=True, comment='配置描述')
    created_at = Column(TIMESTAMP, default=lambda: datetime.now(timezone.utc), nullable=False, comment='创建时间')
    updated_at = Column(TIMESTAMP, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False, comment='更新时间')

    def __repr__(self):
        return f"<SystemConfig(key='{self.config_key}', value='{self.config_value}')>"

    def to_dict(self):
        """转换为字典"""
        return {
            'id': self.id,
            'config_key': self.config_key,
            'config_value': self.config_value,
            'config_type': self.config_type,
            'description': self.description,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
