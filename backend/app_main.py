#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
基准测试评分平台 - 主应用入口（重构版）
版本: 2.0.0
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

# 导入配置
from app.config import ALLOWED_ORIGINS

# 导入路由
from app.routes import health, auth, benchmarks

# 导入数据库初始化
from app.dependencies.database_init import check_database_exists

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
