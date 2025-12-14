# -*- coding: utf-8 -*-
"""
JWT工具模块
"""
import os
from datetime import datetime, timedelta, timezone
from typing import Optional
from jose import jwt, JWTError

# JWT配置
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-here")
ALGORITHM = "HS256"


def create_jwt_token(data: dict) -> str:
    """创建标准JWT令牌"""
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(hours=24)
    to_encode.update({"exp": expire})

    # 使用python-jose创建标准JWT token
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def verify_token(token: str) -> Optional[dict]:
    """验证JWT令牌"""
    try:
        # 使用python-jose解码和验证JWT token
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError as e:
        print(f"DEBUG: JWT验证失败: {e}")
        return None
    except Exception as e:
        print(f"DEBUG: Token验证异常: {e}")
        return None
