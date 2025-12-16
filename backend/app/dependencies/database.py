# -*- coding: utf-8 -*-
"""
数据库连接依赖 - 使用 SQLAlchemy 连接池
"""
import os
import re
from typing import Generator
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import QueuePool

# 数据库配置 - 从环境变量读取
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    # 从单独的环境变量读取
    host = os.getenv("DB_HOST", "127.0.0.1")
    port = os.getenv("DB_PORT", "3306")
    user = os.getenv("DB_USER", "root")
    password = os.getenv("DB_PASSWORD", "")
    database = os.getenv("DB_NAME", "benchmark_platform")
    DATABASE_URL = f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}"

# 确保使用 pymysql 驱动
if DATABASE_URL and DATABASE_URL.startswith("mysql://"):
    DATABASE_URL = DATABASE_URL.replace("mysql://", "mysql+pymysql://", 1)

# 创建数据库引擎（带连接池）
engine = create_engine(
    DATABASE_URL,
    poolclass=QueuePool,
    pool_size=10,              # 连接池大小
    max_overflow=20,           # 超过pool_size后最多创建的连接数
    pool_timeout=30,           # 获取连接的超时时间
    pool_recycle=3600,         # 连接回收时间（秒）
    pool_pre_ping=True,        # 连接前检查连接是否有效
    echo=False,                # 不打印SQL语句（生产环境）
    connect_args={
        'charset': 'utf8mb4'
    }
)

# 创建 Session 工厂
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db() -> Generator[Session, None, None]:
    """
    依赖注入：获取数据库会话

    使用方法:
        @app.get("/items")
        def read_items(db: Session = Depends(get_db)):
            items = db.query(Item).all()
            return items
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
