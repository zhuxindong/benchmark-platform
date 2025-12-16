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

# 静态文件服务（生产模式）
import os
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

dist_path = os.path.join(os.path.dirname(__file__), "..", "dist")
if os.path.exists(dist_path):
    print(f"[INFO] 检测到 dist 目录，启用静态文件服务")

    # MIME类型映射
    import mimetypes
    mimetypes.add_type('application/javascript', '.js')
    mimetypes.add_type('text/css', '.css')
    mimetypes.add_type('image/svg+xml', '.svg')

    # Serve静态资源（CSS, JS等）
    app.mount("/assets", StaticFiles(directory=os.path.join(dist_path, "assets")), name="assets")

    # SPA路由：所有非API/assets请求返回index.html
    @app.get("/{full_path:path}")
    async def serve_spa(full_path: str):
        # 排除 assets 路径（由 StaticFiles 处理）
        if full_path.startswith("assets"):
            from fastapi import HTTPException
            raise HTTPException(status_code=404)
        # 尝试返回静态文件
        file_path = os.path.join(dist_path, full_path)
        if os.path.exists(file_path) and os.path.isfile(file_path):
            return FileResponse(file_path)
        # 否则返回index.html（SPA路由）
        return FileResponse(os.path.join(dist_path, "index.html"))
else:
    print(f"[INFO] 未检测到 dist 目录，使用开发模式（需要单独运行前端）")


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
