# -*- coding: utf-8 -*-
"""
应用配置
"""
import os
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

#OAuth 配置
CLIENT_ID = os.getenv("OAUTH_CLIENT_ID")
CLIENT_SECRET = os.getenv("OAUTH_CLIENT_SECRET")
REDIRECT_URI = os.getenv("OAUTH_CALLBACK_URL", "http://localhost:8000/api/v1/auth/linuxdo/callback")

# OAuth端点
AUTHORIZATION_ENDPOINT = os.getenv("OAUTH_AUTHORIZATION_ENDPOINT", "https://connect.linux.do/oauth2/authorize")
TOKEN_ENDPOINT = os.getenv("OAUTH_TOKEN_ENDPOINT", "https://connect.linux.do/oauth2/token")
USER_ENDPOINT = os.getenv("OAUTH_USER_ENDPOINT", "https://connect.linux.do/api/user")

# CORS配置
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "*").split(",") if os.getenv("ALLOWED_ORIGINS") else [
    "http://localhost:3000",
    "http://localhost:8000",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:8000",
    "*"  # 开发环境允许所有来源，生产环境请移除
]

# Mock登录开关（仅用于开发环境，生产环境必须关闭）
ENABLE_MOCK_LOGIN = os.getenv("ENABLE_MOCK_LOGIN", "false").lower() in ("true", "1", "yes")

# 前端URL获取函数
def get_frontend_url():
    """获取前端URL

    通过 FRONTEND_URL 环境变量配置：
    - 开发模式: FRONTEND_URL=http://localhost:3000
    - 生产模式: 不设置（默认与后端同域）
    """
    frontend_url = os.getenv("FRONTEND_URL")
    if frontend_url:
        return frontend_url.rstrip('/')

    # 默认：从回调URL提取域名（生产模式，前后端同域）
    from urllib.parse import urlparse
    parsed = urlparse(REDIRECT_URI)
    return f"{parsed.scheme}://{parsed.netloc}"
