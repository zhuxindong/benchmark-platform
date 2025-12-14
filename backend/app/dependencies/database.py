# -*- coding: utf-8 -*-
"""
数据库连接依赖
"""
import pymysql
import os
import re
from typing import Generator

# 数据库配置 - 从环境变量读取
DATABASE_URL = os.getenv("DATABASE_URL")
if DATABASE_URL:
    # 解析 DATABASE_URL 格式: mysql://user:password@host:port/database
    pattern = r'mysql://([^:]+):([^@]+)@([^:]+):(\d+)/(.+)'
    match = re.match(pattern, DATABASE_URL)
    if match:
        DB_CONFIG = {
            'host': match.group(3),
            'port': int(match.group(4)),
            'user': match.group(1),
            'password': match.group(2),
            'database': match.group(5),
            'charset': 'utf8mb4'
        }
    else:
        raise ValueError("Invalid DATABASE_URL format")
else:
    # 从单独的环境变量读取
    DB_CONFIG = {
        'host': os.getenv("DB_HOST", "127.0.0.1"),
        'port': int(os.getenv("DB_PORT", "3306")),
        'user': os.getenv("DB_USER", "root"),
        'password': os.getenv("DB_PASSWORD", ""),
        'database': os.getenv("DB_NAME", "benchmark_platform"),
        'charset': 'utf8mb4'
    }


def get_db_connection():
    """获取数据库连接"""
    try:
        conn = pymysql.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"数据库连接失败: {e}")
        raise


def get_db() -> Generator:
    """依赖注入：获取数据库连接"""
    conn = get_db_connection()
    try:
        yield conn
    finally:
        conn.close()
