# -*- coding: utf-8 -*-
"""
应用配置设置
"""

from typing import List, Optional
from pydantic import validator
from pydantic_settings import BaseSettings, SettingsConfigDict
import secrets
from loguru import logger


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="allow"
    )
    """应用配置类"""

    # 应用基础配置
    APP_NAME: str = "基准测试评分平台"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    # 数据库配置
    DATABASE_URL: Optional[str] = None
    DB_HOST: str = "127.0.0.1"
    DB_PORT: int = 3306
    DB_USER: str = "root"
    DB_PASSWORD: str = ""
    DB_NAME: str = "benchmark"

    # 额外的OAuth字段（用于兼容旧配置）
    LINUXDO_AUTHORIZATION_ENDPOINT: Optional[str] = None
    LINUXDO_TOKEN_ENDPOINT: Optional[str] = None
    LINUXDO_USER_ENDPOINT: Optional[str] = None

    # OAuth配置（兼容多种命名）
    OAUTH_CLIENT_ID: Optional[str] = None
    OAUTH_CLIENT_SECRET: Optional[str] = None
    OAUTH_CALLBACK_URL: Optional[str] = None

    @validator("DATABASE_URL", pre=True)
    def assemble_db_connection(cls, v: Optional[str], values: dict) -> str:
        """组装数据库连接字符串"""
        if isinstance(v, str):
            return v
        return (
            f"mysql+pymysql://{values.get('DB_USER')}:"
            f"{values.get('DB_PASSWORD')}@"
            f"{values.get('DB_HOST')}:"
            f"{values.get('DB_PORT')}/"
            f"{values.get('DB_NAME')}"
        )

    # JWT 配置
    SECRET_KEY: str = secrets.token_urlsafe(32)
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # linux.do OAuth 配置
    LINUXDO_CLIENT_ID: str = ""
    LINUXDO_CLIENT_SECRET: str = ""
    LINUXDO_REDIRECT_URI: str = "http://localhost:8000/auth/linuxdo/callback"

    # linux.do OAuth 端点
    LINUXDO_AUTH_URL: str = "https://linux.do/auth/oauth2/authorize"
    LINUXDO_TOKEN_URL: str = "https://linux.do/auth/oauth2/token"
    LINUXDO_USER_INFO_URL: str = "https://linux.do/api/u/me.json"

    # CORS 配置 - 允许所有域名
    ALLOWED_ORIGINS: str = "*"

    # 日志配置
    LOG_LEVEL: str = "INFO"
    LOG_FILE: str = "logs/app.log"

    # API 限制
    MAX_RESULTS_PER_USER: int = 10
    MAX_UPLOAD_SIZE: int = 10 * 1024 * 1024  # 10MB

    # 排行榜配置
    LEADERBOARD_PAGE_SIZE: int = 20
    LEADERBOARD_CACHE_TTL: int = 300  # 5分钟

    # Mock 登录开关（仅用于开发环境，生产环境必须关闭）
    ENABLE_MOCK_LOGIN: bool = False

    def get_logger(self, name: str = None):
        """获取日志记录器"""
        if name:
            return logger.bind(name=name)
        return logger

    @property
    def is_development(self) -> bool:
        """是否为开发环境"""
        return self.DEBUG

    @property
    def cors_origins(self) -> List[str]:
        """获取 CORS 允许的源"""
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",")]


# 创建全局配置实例
settings = Settings()