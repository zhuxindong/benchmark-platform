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
    """获取前端URL"""
    # 优先使用环境变量中的FRONTEND_URL（用于开发环境前后端端口不同的情况）
    frontend_url = os.getenv("FRONTEND_URL")
    if frontend_url:
        return frontend_url.rstrip('/')

    # 否则从OAUTH_CALLBACK_URL中提取域名（用于生产环境前后端同域的情况）
    callback_url = REDIRECT_URI
    if callback_url:
        from urllib.parse import urlparse
        parsed = urlparse(callback_url)
        return f"{parsed.scheme}://{parsed.netloc}"

    # 兜底默认值
    return "http://localhost:3000"
