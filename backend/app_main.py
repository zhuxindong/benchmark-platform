#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
基准测试评分平台 - 主应用入口（重构版）
版本: 2.0.0
"""
import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

# 导入配置
from app.config import ALLOWED_ORIGINS

# 导入路由
from app.routes import health, auth, benchmarks

# 创建FastAPI应用
app = FastAPI(
    title="基准测试评分平台",
    description="集成 linux.do OAuth 认证的基准测试平台",
    version="2.0.0"
)

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册路由
app.include_router(health.router)
app.include_router(auth.router)
app.include_router(benchmarks.router)


# 数据库初始化检查
def check_database_exists():
    """检查数据库和表是否存在，如果不存在则初始化"""
    import pymysql
    import re
    from app.dependencies.database import DB_CONFIG

    try:
        # 连接到MySQL服务器
        temp_config = DB_CONFIG.copy()
        database_name = temp_config.pop('database', None)

        conn = pymysql.connect(**temp_config)
        cursor = conn.cursor()

        # 创建数据库
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{database_name}` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
        cursor.execute(f"USE `{database_name}`")

        # 检查users表是否存在
        cursor.execute("SHOW TABLES LIKE 'users'")
        users_exists = cursor.fetchone()

        if not users_exists:
            print("数据库表不存在，开始初始化...")
            init_script_path = os.path.join(os.path.dirname(__file__), 'init.sql')
            if os.path.exists(init_script_path):
                with open(init_script_path, 'r', encoding='utf-8') as f:
                    init_sql = f.read()
                    # 移除创建数据库的语句
                    init_sql = re.sub(r'CREATE DATABASE.*?;', '', init_sql, flags=re.MULTILINE | re.DOTALL)
                    init_sql = re.sub(r'USE `[^`]+`;', '', init_sql, flags=re.MULTILINE)

                    # 分割并执行SQL语句
                    statements = [s.strip() for s in init_sql.split(';') if s.strip()]
                    for statement in statements:
                        if statement:
                            cursor.execute(statement)
                print("数据库初始化完成")
            else:
                print("警告: init.sql文件不存在，跳过数据库初始化")
        else:
            print("数据库表已存在")

        cursor.close()
        conn.close()

    except Exception as e:
        print(f"数据库检查/初始化失败: {e}")
        raise


if __name__ == "__main__":
    import uvicorn

    print("=" * 60)
    print("Starting Benchmark Platform (Refactored Version)")
    print("=" * 60)
    print(f"Version: 2.0.0")
    print(f"API Documentation: http://localhost:8000/docs")
    print(f"Health Check: http://localhost:8000/health")
    print(f"Login: http://localhost:8000/api/v1/auth/login")
    print("=" * 60)

    # 检查和初始化数据库
    print("检查数据库状态...")
    try:
        check_database_exists()
        print("[OK] 数据库检查完成")
    except Exception as e:
        print(f"[ERROR] 数据库初始化失败: {e}")
        print("请检查数据库连接配置")

    print("=" * 60)
    print("Starting server...")
    print("=" * 60)

    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
