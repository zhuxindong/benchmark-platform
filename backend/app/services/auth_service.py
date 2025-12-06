# -*- coding: utf-8 -*-
"""
认证服务 - 支持 linux.do OAuth2 认证
"""

import httpx
from typing import Optional, Dict, Any
from urllib.parse import urlencode
import secrets
from datetime import datetime, timedelta, timezone
import json

from sqlalchemy.orm import Session
from app.models.user import User
from app.core.config import settings
from loguru import logger


class LinuxDoAuthService:
    """linux.do OAuth2 认证服务"""

    def __init__(self, db: Session):
        self.db = db
        self.client_id = settings.LINUXDO_CLIENT_ID
        self.client_secret = settings.LINUXDO_CLIENT_SECRET
        self.redirect_uri = settings.LINUXDO_REDIRECT_URI

        # linux.do OAuth2 端点 (基于 Discourse 标准实现)
        self.auth_url = "https://linux.do/auth/oauth2_authorize"
        self.token_url = "https://linux.do/auth/oauth2_token"
        self.user_info_url = "https://linux.do/api/u/me.json"

    def get_authorization_url(self, state: Optional[str] = None) -> str:
        """获取授权URL"""
        if not state:
            state = secrets.token_urlsafe(32)

        params = {
            "client_id": self.client_id,
            "redirect_uri": self.redirect_uri,
            "response_type": "code",
            "scope": "read",
            "state": state
        }

        logger.info(f"生成授权URL，state: {state}")
        return f"{self.auth_url}?{urlencode(params)}"

    async def exchange_code_for_token(self, code: str) -> Dict[str, Any]:
        """用授权码换取访问令牌"""
        if not self.client_id or not self.client_secret:
            raise ValueError("未配置 linux.do OAuth 客户端ID和密钥")

        data = {
            "client_id": self.client_id,
            "client_secret": self.client_secret,
            "code": code,
            "grant_type": "authorization_code",
            "redirect_uri": self.redirect_uri
        }

        headers = {
            "Content-Type": "application/x-www-form-urlencoded"
        }

        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    self.token_url,
                    data=data,
                    headers=headers,
                    timeout=30.0
                )
                response.raise_for_status()

                token_data = response.json()
                logger.info("成功获取访问令牌")
                return token_data

        except httpx.HTTPStatusError as e:
            logger.error(f"获取访问令牌失败: {e.response.text}")
            raise ValueError(f"获取访问令牌失败: {e.response.status_code}")
        except Exception as e:
            logger.error(f"获取访问令牌异常: {e}")
            raise ValueError(f"获取访问令牌异常: {str(e)}")

    async def get_user_info(self, access_token: str) -> Dict[str, Any]:
        """获取用户信息"""
        headers = {
            "Authorization": f"Bearer {access_token}",
            "User-Agent": "Benchmark-Platform/1.0"
        }

        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    self.user_info_url,
                    headers=headers,
                    timeout=30.0
                )
                response.raise_for_status()

                user_data = response.json()
                logger.info(f"成功获取用户信息: {user_data.get('user', {}).get('username', 'unknown')}")
                return user_data

        except httpx.HTTPStatusError as e:
            logger.error(f"获取用户信息失败: {e.response.text}")
            raise ValueError(f"获取用户信息失败: {e.response.status_code}")
        except Exception as e:
            logger.error(f"获取用户信息异常: {e}")
            raise ValueError(f"获取用户信息异常: {str(e)}")

    def parse_discourse_user_info(self, user_data: Dict[str, Any]) -> Dict[str, Any]:
        """解析 Discourse 用户信息"""
        user = user_data.get("user", {})

        return {
            "user_id": str(user.get("id", "")),
            "username": user.get("username", ""),
            "email": user.get("email", ""),
            "avatar_url": user.get("avatar_template", "").replace("{size}", "120"),
            "created_at": user.get("created_at"),
            "last_seen_at": user.get("last_seen_at"),
            "trust_level": user.get("trust_level", 0)
        }

    def find_or_create_user(self, user_info: Dict[str, Any]) -> User:
        """查找或创建用户"""
        user_id = user_info.get("user_id")
        username = user_info.get("username")

        if not user_id or not username:
            raise ValueError("用户信息不完整")

        # 查找现有用户
        user = self.db.query(User).filter(
            (User.user_id == user_id) | (User.username == username)
        ).first()

        if user:
            # 更新用户信息
            user.username = username
            user.email = user_info.get("email")
            user.avatar_url = user_info.get("avatar_url")
            user.updated_at = datetime.now(timezone.utc)
            logger.info(f"更新用户信息: {username}")
        else:
            # 创建新用户
            user = User(
                user_id=user_id,
                username=username,
                email=user_info.get("email"),
                avatar_url=user_info.get("avatar_url"),
                created_at=datetime.now(timezone.utc),
                updated_at=datetime.now(timezone.utc)
            )
            self.db.add(user)
            logger.info(f"创建新用户: {username}")

        self.db.commit()
        self.db.refresh(user)
        return user

    async def authenticate_user(self, code: str) -> User:
        """完整的用户认证流程"""
        try:
            # 1. 用授权码换取访问令牌
            token_data = await self.exchange_code_for_token(code)
            access_token = token_data.get("access_token")

            if not access_token:
                raise ValueError("未获取到访问令牌")

            # 2. 获取用户信息
            user_data = await self.get_user_info(access_token)

            # 3. 解析用户信息
            parsed_user_info = self.parse_discourse_user_info(user_data)

            # 4. 查找或创建用户
            user = self.find_or_create_user(parsed_user_info)

            logger.info(f"用户认证成功: {user.username}")
            return user

        except Exception as e:
            logger.error(f"用户认证失败: {e}")
            raise


class JWTService:
    """JWT 令牌服务"""

    def __init__(self):
        self.secret_key = settings.SECRET_KEY
        self.algorithm = settings.ALGORITHM
        self.expire_minutes = settings.ACCESS_TOKEN_EXPIRE_MINUTES

    def create_access_token(self, data: Dict[str, Any]) -> str:
        """创建访问令牌"""
        try:
            from jose import jwt

            to_encode = data.copy()
            expire = datetime.now(timezone.utc) + timedelta(minutes=self.expire_minutes)
            to_encode.update({"exp": expire, "type": "access"})

            encoded_jwt = jwt.encode(
                to_encode,
                self.secret_key,
                algorithm=self.algorithm
            )
            return encoded_jwt

        except Exception as e:
            logger.error(f"创建JWT令牌失败: {e}")
            raise ValueError("创建访问令牌失败")

    def verify_token(self, token: str) -> Optional[Dict[str, Any]]:
        """验证访问令牌"""
        try:
            from jose import jwt, JWTError

            payload = jwt.decode(
                token,
                self.secret_key,
                algorithms=[self.algorithm]
            )
            return payload

        except JWTError as e:
            logger.warning(f"JWT令牌验证失败: {e}")
            return None
        except Exception as e:
            logger.error(f"JWT令牌验证异常: {e}")
            return None

    def create_user_token(self, user: User) -> str:
        """为用户创建访问令牌"""
        token_data = {
            "user_id": user.id,
            "username": user.username,
            "user_do_id": user.user_id
        }
        return self.create_access_token(token_data)


# 全局服务实例
jwt_service = JWTService()