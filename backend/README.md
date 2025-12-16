# 🚀 基准测试评分平台 - 后端 API

基于 FastAPI 的高性能基准测试评分平台后端服务，采用模块化架构设计。

[![FastAPI](https://img.shields.io/badge/FastAPI-0.104.1-009688?logo=fastapi)](https://fastapi.tiangolo.com/)
[![Python](https://img.shields.io/badge/Python-3.11+-3776ab?logo=python)](https://www.python.org/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479a1?logo=mysql)](https://www.mysql.com/)

## ✨ 架构特性 (v7.0)

### 模块化设计
- ✅ **路由模块化**: auth、benchmarks、health 独立路由
- ✅ **依赖注入**: 统一的数据库和认证依赖管理
- ✅ **配置集中**: 单一配置文件管理所有环境变量
- ✅ **代码精简**: 主入口从 1336 行减少到 105 行 (-92%)

### 数据库优化 (v7.0)
- ✅ **SQLAlchemy ORM**: 全面迁移到 ORM，提升代码可维护性
- ✅ **连接池**: QueuePool (pool_size=10, max_overflow=20)
- ✅ **统一查询**: 所有端点使用 ORM 查询

### 安全增强
- ✅ **标准 JWT**: 使用 python-jose 库，符合 RFC 7519
- ✅ **强密钥**: 使用 secrets.token_urlsafe(32) 生成
- ✅ **安全签名**: HMAC-SHA256 替代 MD5
- ✅ **Cookie 保护**: HttpOnly + SameSite

## 📋 功能特性

- 🔐 **OAuth 认证**: linux.do OAuth 2.0 集成
- 🎯 **智能解析**: 正则表达式自动解析基准测试结果
- 🖥️ **设备分类**: AI 自动识别服务器级/消费级 CPU
- 📊 **排行榜系统**: 支持分类排行、分页、倒序
- 👤 **用户管理**: 每用户最多 3 条记录
- 📝 **完整 CRUD**: 支持创建、读取、更新、删除操作
- 🔍 **用户排名**: 快速查询个人在各榜单中的排名
- 📚 **API 文档**: 自动生成的 OpenAPI 文档

## 🛠️ 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| FastAPI | 0.104.1 | Web 框架 |
| SQLAlchemy | 2.0.23 | ORM 框架 ✨ (v7.0) |
| python-jose | 3.3.0 | JWT 认证 |
| PyMySQL | 1.1.0 | 数据库驱动 |
| Uvicorn | 0.24.0 | ASGI 服务器 |
| Pydantic | 2.4.2 | 数据验证 |
| httpx | 0.25.0 | HTTP 客户端 |

## 🚀 快速开始

### 安装依赖

```bash
# 使用 pip
pip install -r requirements.txt

# 或使用 uv（推荐）
uv sync
```

### 配置环境变量

创建 `.env` 文件：

```bash
# 数据库配置
DATABASE_URL=mysql://root:password@localhost:3306/benchmark

# OAuth 配置
OAUTH_CLIENT_ID=你的客户端ID
OAUTH_CLIENT_SECRET=你的客户端密钥
OAUTH_CALLBACK_URL=http://localhost:8000/api/v1/auth/linuxdo/callback

# 前端 URL（开发环境）
FRONTEND_URL=http://localhost:3000

# JWT 密钥（生成强随机密钥）
SECRET_KEY=生成的随机密钥

# CORS 配置
ALLOWED_ORIGINS=*

# OAuth 端点（可选，使用默认值）
OAUTH_AUTHORIZATION_ENDPOINT=https://connect.linux.do/oauth2/authorize
OAUTH_TOKEN_ENDPOINT=https://connect.linux.do/oauth2/token
OAUTH_USER_ENDPOINT=https://connect.linux.do/api/user
```

### 生成 SECRET_KEY

```bash
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

### 初始化数据库

首次运行会自动检查并创建数据库表：

```bash
uv run python app_main.py
```

手动初始化（如需要）：

```bash
mysql -u root -p < init.sql
```

### 启动服务

```bash
# 方法 1: 使用 uv（推荐）
uv run python app_main.py

# 方法 2: 直接运行
python app_main.py

# 方法 3: 使用 uvicorn
uvicorn app_main:app --host 0.0.0.0 --port 8000 --reload
```

访问地址：
- **API 文档**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **健康检查**: http://localhost:8000/health

## 📂 项目结构 (v6.0 重构)

```
backend/
├── app/
│   ├── routes/                 # 路由模块 ✨
│   │   ├── __init__.py
│   │   ├── auth.py             # 认证路由 (340行)
│   │   ├── benchmarks.py       # 基准测试路由 (660行)
│   │   └── health.py           # 健康检查路由 (42行)
│   │
│   ├── dependencies/           # 依赖注入 ✨
│   │   ├── __init__.py
│   │   ├── database.py         # 数据库连接 (52行)
│   │   ├── jwt_utils.py        # JWT 工具 (40行)
│   │   └── auth.py             # 认证依赖 (62行)
│   │
│   ├── config.py               # 配置模块 ✨ (46行)
│   │
│   ├── utils/                  # 工具模块
│   │   └── device_classifier.py  # 设备类型分类器
│   │
│   ├── core/                   # 核心模块（待整合）
│   ├── models/                 # 数据模型（待整合）
│   ├── schemas/                # API 模式（待整合）
│   └── services/               # 业务逻辑（待整合）
│
├── app_main.py                 # 主入口 ✨ (105行)
├── init.sql                    # 数据库初始化脚本
├── requirements.txt            # Python 依赖
├── .env                        # 环境变量配置
└── README.md                   # 本文档

✨ = v6.0 重构新增/优化
```

## 📊 API 端点详解

### 基础端点

#### 根路由
```http
GET /
```
返回 API 基本信息和版本号。

#### 健康检查
```http
GET /health
```
返回服务健康状态、数据库连接状态、OAuth 配置状态。

### 认证相关 (`/api/v1/auth`)

#### 1. 获取登录 URL
```http
GET /api/v1/auth/login
```

响应：
```json
{
  "authorization_url": "https://connect.linux.do/oauth2/authorize?...",
  "state": "benchmark_随机字符串"
}
```

#### 2. OAuth 回调处理
```http
GET /api/v1/auth/linuxdo/callback?code=xxx&state=xxx
POST /api/v1/auth/linuxdo/callback
```

响应：
```json
{
  "success": true,
  "message": "登录成功",
  "user": {
    "id": 1,
    "username": "用户名",
    "avatar_url": "头像URL"
  }
}
```

**注意**: 登录成功后会通过 Cookie 设置 `auth_token`（HttpOnly）

#### 3. 获取当前用户
```http
GET /api/v1/auth/me
Authorization: Bearer <token>
或 Cookie: auth_token=<token>
```

#### 4. 登出
```http
POST /api/v1/auth/logout
```

#### 5. 验证 Token
```http
GET /api/v1/auth/verify-token
Authorization: Bearer <token>
```

#### 6. Mock 登录（仅开发）
```http
POST /api/v1/auth/mock-login
Content-Type: application/json

{
  "username": "test_user"
}
```

### 基准测试相关 (`/api/v1/benchmarks`)

#### 1. 解析基准测试文本
```http
POST /api/v1/benchmarks/parse
Content-Type: application/json

{
  "text": "基准测试结果文本..."
}
```

响应：
```json
{
  "success": true,
  "data": {
    "cpu_model": "AMD Ryzen 7 6800H",
    "cpu_cores": 16,
    "memory_gb": 7.8,
    "phase1_wall_time": 64.642,
    "phase2_wall_time": 71.761,
    "overall_wall_time": 136.405
  }
}
```

#### 2. 设备类型分类
```http
POST /api/v1/benchmarks/classify-device-type
Content-Type: application/json

{
  "cpu_model": "Intel Xeon E5-2680 v4"
}
```

响应：
```json
{
  "success": true,
  "data": {
    "cpu_model": "Intel Xeon E5-2680 v4",
    "device_type": "server",
    "device_type_confidence": 0.95,
    "classification_text": "设备类型: SERVER (置信度: 0.95)"
  }
}
```

#### 3. 提交基准测试结果
```http
POST /api/v1/benchmarks/submit
Authorization: Bearer <token>
Content-Type: application/json

{
  "cpu_model": "AMD Ryzen 7 6800H",
  "cpu_cores": 16,
  "memory_gb": 7.8,
  "phase1_wall_time": 64.642,
  "phase2_wall_time": 71.761,
  "overall_wall_time": 136.405,
  "device_type": "consumer",
  "device_type_confidence": 0.9
}
```

**限制**: 每用户最多 3 条记录

#### 4. 获取排行榜
```http
GET /api/v1/benchmarks/leaderboard?device_type=server&page=1&limit=20&reverse=false
```

参数：
- `device_type`: 可选，`server` 或 `consumer`
- `page`: 页码，默认 1
- `limit`: 每页数量，默认 20
- `reverse`: 倒序排列，默认 false

#### 5. 获取我的记录
```http
GET /api/v1/benchmarks/my-result
Authorization: Bearer <token>
```

#### 6. 获取我的排名
```http
GET /api/v1/benchmarks/my-ranks?device_type=server&reverse=false
Authorization: Bearer <token>
```

返回用户所有记录在排行榜中的排名信息。

#### 7. 获取记录详情
```http
GET /api/v1/benchmarks/{benchmark_id}
Authorization: Bearer <token>
```

#### 8. 更新记录
```http
PUT /api/v1/benchmarks/{benchmark_id}
Authorization: Bearer <token>
Content-Type: application/json

{
  "cpu_model": "更新后的CPU型号",
  "cpu_cores": 16,
  ...
}
```

#### 9. 删除记录
```http
DELETE /api/v1/benchmarks/{benchmark_id}
Authorization: Bearer <token>
```

## 🗄️ 数据库设计

### users 表
```sql
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    user_id VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) DEFAULT NULL,
    avatar_url VARCHAR(500) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### benchmark_results 表
```sql
CREATE TABLE benchmark_results (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    username VARCHAR(100) NOT NULL,
    cpu_model VARCHAR(255) DEFAULT NULL,
    cpu_cores INT DEFAULT NULL,
    memory_gb DECIMAL(10,2) DEFAULT NULL,
    phase1_wall_time DECIMAL(15,6) DEFAULT NULL,
    phase2_wall_time DECIMAL(15,6) DEFAULT NULL,
    overall_wall_time DECIMAL(15,6) DEFAULT NULL,
    device_type VARCHAR(20) DEFAULT 'unknown',
    device_type_confidence DECIMAL(5,2) DEFAULT 0.00,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### 索引
```sql
CREATE INDEX idx_user_id ON benchmark_results(user_id);
CREATE INDEX idx_overall_time ON benchmark_results(overall_wall_time);
CREATE INDEX idx_device_type ON benchmark_results(device_type);
```

## 🔐 OAuth 认证流程

### 1. 配置 OAuth 应用

访问 https://connect.linux.do 创建 OAuth 应用：

**应用信息**：
- **应用名称**: 基准测试评分平台
- **回调 URL**: `http://localhost:8000/api/v1/auth/linuxdo/callback`
- **权限范围**: `read`

获取 Client ID 和 Client Secret 后配置到 `.env` 文件。

### 2. 认证流程

```
用户点击登录
    ↓
GET /api/v1/auth/login
    ↓
返回 authorization_url
    ↓
浏览器重定向到 linux.do
    ↓
用户授权
    ↓
回调到 /api/v1/auth/linuxdo/callback
    ↓
后端获取 access_token
    ↓
获取用户信息
    ↓
创建/更新用户记录
    ↓
生成 JWT token
    ↓
设置 HttpOnly Cookie
    ↓
重定向到前端
```

### 3. Token 验证

每个受保护的 API 会通过以下方式验证身份：
1. 优先检查 Cookie 中的 `auth_token`
2. 如果没有，检查 `Authorization: Bearer <token>` 头
3. 验证 JWT 签名和过期时间
4. 从数据库查询用户信息

## 🖥️ 设备类型分类器

### 分类逻辑

**服务器级关键词**:
```python
server_keywords = [
    'xeon', 'xeon®', 'xeon(tm)',
    'epyc', 'epyc™', 'epyc(r)',
    'opteron', 'power', 'server', 'workstation'
]
```

**消费级关键词**:
```python
consumer_keywords = [
    'core i3', 'core i5', 'core i7', 'core i9',
    'pentium', 'celeron',
    'ryzen', 'athlon',
    'apple m1', 'apple m2', 'apple m3', 'apple m4'
]
```

### 置信度计算

- **匹配到服务器级关键词**: 0.9 - 0.95
- **匹配到消费级关键词**: 0.85 - 0.9
- **未匹配**: 0.5（默认为 unknown）

### 使用示例

```python
from app.utils.device_classifier import DeviceTypeClassifier

classifier = DeviceTypeClassifier()
device_type, confidence = classifier.classify_cpu("Intel Xeon E5-2680 v4")
# device_type: "server"
# confidence: 0.95
```

## 🔧 开发指南

### 添加新的路由

1. 在 `app/routes/` 创建新的路由文件
2. 定义 APIRouter
3. 在 `app_main.py` 中注册路由

示例：
```python
# app/routes/new_feature.py
from fastapi import APIRouter

router = APIRouter(prefix="/api/v1/new-feature", tags=["新功能"])

@router.get("/")
async def get_feature():
    return {"message": "新功能"}

# app_main.py
from app.routes import new_feature
app.include_router(new_feature.router)
```

### 添加新的依赖

在 `app/dependencies/` 创建依赖文件：

```python
# app/dependencies/my_dependency.py
from fastapi import Depends

async def get_my_dependency():
    return "依赖数据"

# 使用
from app.dependencies.my_dependency import get_my_dependency

@router.get("/")
async def endpoint(data = Depends(get_my_dependency)):
    return {"data": data}
```

### 代码规范

- 使用 Python 3.11+ 类型注解
- 遵循 PEP 8 代码风格
- 所有函数添加文档字符串
- 使用 Pydantic 进行数据验证

## 🧪 测试

### 健康检查测试
```bash
curl http://localhost:8000/health
```

### OAuth 登录测试
```bash
# 1. 获取登录 URL
curl http://localhost:8000/api/v1/auth/login

# 2. 访问 authorization_url（浏览器）
# 3. 授权后自动回调
```

### API 测试
```bash
# 解析基准测试
curl -X POST http://localhost:8000/api/v1/benchmarks/parse \
  -H "Content-Type: application/json" \
  -d '{"text": "..."}'

# 获取排行榜
curl http://localhost:8000/api/v1/benchmarks/leaderboard?limit=10
```

## 🐛 故障排除

### 数据库连接失败
```bash
# 1. 检查 MySQL 服务
systemctl status mysql  # Linux
mysql.server status      # macOS

# 2. 验证连接
mysql -h localhost -u root -p

# 3. 检查数据库是否存在
mysql> SHOW DATABASES LIKE 'benchmark';
```

### OAuth 认证失败

常见错误：
1. **client_id 无效**: 检查 OAUTH_CLIENT_ID 配置
2. **redirect_uri 不匹配**: 确保回调 URL 完全一致
3. **access_denied**: 用户拒绝授权

调试方法：
```bash
# 查看后端日志
uv run python app_main.py

# 检查 OAuth 配置
curl http://localhost:8000/health
```

### JWT 验证失败

1. **Token 过期**: 重新登录获取新 Token
2. **签名错误**: 检查 SECRET_KEY 是否正确
3. **Cookie 未设置**: 检查浏览器 Cookie 设置

## 📝 环境变量说明

| 变量名 | 必需 | 默认值 | 说明 |
|--------|------|--------|------|
| `DATABASE_URL` | ✅ | - | MySQL 连接字符串 |
| `OAUTH_CLIENT_ID` | ✅ | - | linux.do OAuth Client ID |
| `OAUTH_CLIENT_SECRET` | ✅ | - | linux.do OAuth Client Secret |
| `OAUTH_CALLBACK_URL` | ✅ | - | OAuth 回调 URL |
| `SECRET_KEY` | ✅ | - | JWT 签名密钥 |
| `FRONTEND_URL` | ❌ | 从回调URL提取 | 前端 URL |
| `ALLOWED_ORIGINS` | ❌ | `*` | CORS 允许的源 |
| `OAUTH_AUTHORIZATION_ENDPOINT` | ❌ | linux.do 默认 | OAuth 授权端点 |
| `OAUTH_TOKEN_ENDPOINT` | ❌ | linux.do 默认 | OAuth Token 端点 |
| `OAUTH_USER_ENDPOINT` | ❌ | linux.do 默认 | OAuth 用户信息端点 |
| `ENABLE_MOCK_LOGIN` | ❌ | `False` | 启用 Mock 登录 |

## 🚀 部署

### 生产环境配置

```bash
# 强密钥
SECRET_KEY=$(python -c "import secrets; print(secrets.token_urlsafe(32))")

# HTTPS 回调
OAUTH_CALLBACK_URL=https://yourdomain.com/api/v1/auth/linuxdo/callback

# 限制 CORS
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# 禁用 Mock 登录
ENABLE_MOCK_LOGIN=False
```

### Docker 部署

参考项目根目录的 `README.md` 和 `Dockerfile`。

## 📚 相关文档

- **项目 README**: [../README.md](../README.md)
- **开发文档**: [../CLAUDE.md](../CLAUDE.md)
- **JWT 安全修复**: [../JWT_SECURITY_FIX.md](../JWT_SECURITY_FIX.md)
- **重构报告**: [../REFACTORING_REPORT.md](../REFACTORING_REPORT.md)
- **API 文档**: http://localhost:8000/docs (运行时访问)

## 📝 版本历史

### v7.0 (2025-12-16) ✨
- **ORM 迁移**：全面迁移到 SQLAlchemy ORM
- **连接池优化**：QueuePool (pool_size=10, max_overflow=20)
- **代码清理**：移除 PyMySQL 直接连接和备份文件
- **性能提升**：统一使用 ORM 查询，提升可维护性

### v6.0 (2025-12-14) ✨
- JWT 安全升级（python-jose + HMAC-SHA256）
- 模块化重构（app_main.py: 1336 → 120 行）
- 新增路由模块 (routes/)
- 新增依赖注入 (dependencies/)
- 新增配置管理 (config.py)
- Cookie-based 认证
- 环境变量智能处理

### v5.0 (2025-12-05)
- 用户排名查询
- 多记录管理
- 设备类型分类

## 📄 许可证

MIT License

---

**最后更新**: 2025-12-16
**当前版本**: v7.0
**维护者**: Claude Code Development Team
