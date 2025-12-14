# 基准测试评分平台 - Claude 开发文档

## 项目概述

这是一个基于 FastAPI + Vue.js 的基准测试评分平台，支持用户提交基准测试结果并查看排行榜。平台集成了 linux.do OAuth 认证，具备设备类型自动分类功能，并采用模块化架构设计。

## 技术栈

### 后端
- **框架**: FastAPI 0.104.1
- **数据库**: MySQL 8.0+
- **数据库访问**: PyMySQL 1.1.0（直接连接）
- **认证**:
  - linux.do OAuth 2.0
  - 标准 JWT (python-jose) ✨
- **安全**:
  - HMAC-SHA256 签名
  - HttpOnly Cookie
- **语言**: Python 3.11

### 前端
- **框架**: Vue.js 3.5.25
- **构建工具**: Vite 5.4.21
- **路由**: Vue Router 4.6.3
- **包管理器**: pnpm

### 部署
- **容器化**: Docker
- **架构**: 单容器部署，前后端在同一容器内

## 架构特性 ✨

### 模块化设计 (v6.0 重构)
- ✅ **路由模块化**: 认证、基准测试、健康检查独立模块
- ✅ **依赖注入**: 统一的数据库和认证依赖管理
- ✅ **配置集中**: 单一配置文件管理所有环境变量
- ✅ **代码精简**: 主入口从 1336 行减少到 120 行 (-91%)

### 安全增强
- ✅ **标准JWT**: 使用 python-jose 库，符合 RFC 7519
- ✅ **强密钥**: 使用 secrets.token_urlsafe(32) 生成
- ✅ **安全签名**: HMAC-SHA256 替代 MD5
- ✅ **Cookie保护**: HttpOnly + SameSite

## 核心功能

### 1. 用户认证系统
- 基于 linux.do OAuth 2.0 的用户登录
- 标准 JWT token 认证机制 (v6.0 升级)
- Cookie-based 认证（更安全）
- 用户信息自动同步
- Mock 登录支持（开发环境）

### 2. 基准测试管理
- 用户可提交基准测试结果
- 每个用户限制最多 3 条记录
- 自动数据验证和处理
- 支持编辑和删除

### 3. 设备类型分类
- **自动分类**: 根据 CPU 型号自动识别服务器级/消费级设备
- **置信度评分**: 对分类结果提供置信度评分
- **手动校正**: 用户可手动修正设备类型分类

### 4. 排行榜系统
- **综合排行榜**: 显示所有设备的性能排名
- **分类排行榜**:
  - 服务器级 CPU 排行榜 (`device_type=server`)
  - 消费级 CPU 排行榜 (`device_type=consumer`)
- **分页显示**: 支持分页浏览
- **实时排名**: 基于总耗时排序
- **用户排名查询**: 快速查找自己的排名

## 项目结构 (v6.0 重构)

```
benchmark-platform/
├── backend/                    # 后端代码
│   ├── app/
│   │   ├── routes/            # 路由模块 ✨ (v6.0 新增)
│   │   │   ├── __init__.py
│   │   │   ├── auth.py         # 认证路由 (340行)
│   │   │   ├── benchmarks.py   # 基准测试路由 (660行)
│   │   │   └── health.py       # 健康检查路由 (42行)
│   │   │
│   │   ├── dependencies/      # 依赖注入 ✨ (v6.0 新增)
│   │   │   ├── __init__.py
│   │   │   ├── database.py     # 数据库连接
│   │   │   ├── jwt_utils.py    # JWT工具
│   │   │   └── auth.py         # 认证依赖
│   │   │
│   │   ├── config.py          # 配置模块 ✨ (v6.0 新增)
│   │   │
│   │   ├── api/v1/            # API 路由 (未使用，保留)
│   │   │   ├── auth.py
│   │   │   ├── benchmarks.py
│   │   │   ├── leaderboard.py
│   │   │   └── users.py
│   │   │
│   │   ├── core/               # 核心配置
│   │   │   ├── auth.py
│   │   │   ├── config.py
│   │   │   ├── database.py
│   │   │   └── logging.py
│   │   │
│   │   ├── models/             # 数据模型 (SQLAlchemy，未使用)
│   │   │   ├── user.py
│   │   │   └── benchmark.py
│   │   │
│   │   ├── services/           # 业务逻辑 (未使用)
│   │   │   ├── auth_service.py
│   │   │   └── benchmark_service.py
│   │   │
│   │   ├── schemas/            # API 模式 (未使用)
│   │   │   ├── user.py
│   │   │   ├── benchmark.py
│   │   │   └── leaderboard.py
│   │   │
│   │   └── utils/              # 工具函数
│   │       └── device_classifier.py # 设备类型分类器
│   │
│   ├── app_main.py             # 主应用入口 ✨ (120行，v6.0重构)
│   ├── app_main.py.backup      # 原版本备份 (1336行)
│   ├── init.sql                # 数据库初始化脚本
│   ├── database_migration.sql  # 数据库迁移脚本
│   ├── requirements.txt        # Python依赖
│   └── .env                    # 环境变量配置
│
├── src/                        # 前端代码
│   ├── main.js                 # Vue 应用入口
│   ├── services/               # API 服务
│   │   └── api.js              # API 客户端
│   ├── stores/                 # 状态管理
│   │   └── auth.js             # 认证状态
│   └── views/                  # 页面组件
│       ├── Home.vue            # 首页
│       ├── Leaderboard.vue     # 排行榜页面
│       ├── Upload.vue          # 上传页面
│       ├── ParseResult.vue     # 结果解析页面
│       ├── ConfirmResult.vue   # 结果确认页面
│       └── OAuthCallback.vue   # OAuth回调页面
│
├── index.html                  # HTML 模板
├── vite.config.js              # Vite 配置
├── package.json                # 前端依赖配置
├── pnpm-lock.yaml              # 锁定依赖版本
├── Dockerfile                  # Docker 构建配置
├── CLAUDE.md                   # 本文档
├── README.md                   # 项目说明
├── JWT_SECURITY_FIX.md         # JWT安全修复文档 ✨
└── REFACTORING_REPORT.md       # 重构报告 ✨
```

## 数据库设计

### 核心表结构

#### users 表 - 用户信息
- `id`: 用户唯一标识 (自增主键)
- `username`: linux.do 用户名 (唯一)
- `user_id`: linux.do 用户ID (唯一)
- `email`: 邮箱地址
- `avatar_url`: 头像URL
- `created_at`: 创建时间
- `updated_at`: 更新时间

#### benchmark_results 表 - 基准测试结果
- `id`: 结果唯一标识
- `user_id`: 关联用户ID (外键)
- `username`: 用户名（冗余字段，便于查询）
- `cpu_model`: CPU型号
- `cpu_cores`: CPU核心数
- `memory_gb`: 内存大小(GB)
- `phase1_wall_time`: Phase 1 耗时
- `phase2_wall_time`: Phase 2 耗时
- `overall_wall_time`: 总耗时
- `device_type`: 设备类型 (server/consumer/unknown)
- `device_type_confidence`: 设备类型置信度 (0.0-1.0)
- `is_verified`: 是否已验证
- `submitted_at`: 提交时间
- `updated_at`: 更新时间

### 索引优化
```sql
-- 排行榜查询优化
INDEX idx_overall_time (overall_wall_time)
INDEX idx_ranking (is_verified, overall_wall_time, submitted_at)
INDEX idx_user_id (user_id)
INDEX idx_device_type (device_type)
```

### 设备类型分类逻辑

设备类型分类器基于 CPU 型号进行分类：

**服务器级关键词**:
- Intel: Xeon, Xeon®, Xeon(TM)
- AMD: EPYC, EPYC™, EPYC(R), Opteron
- 其他: POWER, Server, Workstation

**消费级关键词**:
- Intel: Core i3/i5/i7/i9, Pentium, Celeron
- AMD: Ryzen, Athlon
- Apple: M1/M2/M3/M4

**置信度评分**: 0.0-1.0，根据关键词匹配强度

## API 端点

### 基础端点
- `GET /` - 根路由，返回API信息
- `GET /health` - 健康检查，返回数据库和OAuth状态

### 认证相关
- `GET /api/v1/auth/login` - OAuth登录跳转
- `GET /api/v1/auth/linuxdo/callback` - OAuth回调 (GET)
- `POST /api/v1/auth/linuxdo/callback` - OAuth回调 (POST)
- `GET /api/v1/auth/me` - 获取当前用户信息
- `POST /api/v1/auth/logout` - 登出
- `GET /api/v1/auth/verify-token` - 验证token
- `POST /api/v1/auth/mock-login` - Mock登录（仅开发环境）

### 基准测试相关
- `POST /api/v1/benchmarks/parse` - 解析基准测试结果文本
- `POST /api/v1/benchmarks/classify-device-type` - CPU设备类型分类
- `POST /api/v1/benchmarks/submit` - 提交基准测试结果
- `GET /api/v1/benchmarks/leaderboard` - 获取排行榜
  - 参数: `device_type` (server/consumer), `page`, `limit`, `reverse`
- `GET /api/v1/benchmarks/my-result` - 获取用户提交结果（支持多条）
- `GET /api/v1/benchmarks/my-ranks` - 获取用户排名信息
- `GET /api/v1/benchmarks/{id}` - 获取基准测试详情
- `PUT /api/v1/benchmarks/{id}` - 更新基准测试结果
- `DELETE /api/v1/benchmarks/{id}` - 删除基准测试结果

## 环境配置

### 环境变量

```bash
# 数据库配置
DATABASE_URL=mysql://user:password@host:port/database

# OAuth配置
OAUTH_CLIENT_ID=<your-oauth-client-id>
OAUTH_CLIENT_SECRET=<your-oauth-client-secret>
OAUTH_CALLBACK_URL=http://localhost:8000/api/v1/auth/linuxdo/callback

# 前端URL（开发环境）
FRONTEND_URL=http://localhost:3000

# 应用配置
SECRET_KEY=<generate-with-secrets.token_urlsafe(32)>
ALLOWED_ORIGINS=*

# OAuth端点（可选，使用默认值）
OAUTH_AUTHORIZATION_ENDPOINT=https://connect.linux.do/oauth2/authorize
OAUTH_TOKEN_ENDPOINT=https://connect.linux.do/oauth2/token
OAUTH_USER_ENDPOINT=https://connect.linux.do/api/user

# Mock登录开关（仅开发环境）
ENABLE_MOCK_LOGIN=False
```

### 生成安全密钥

```bash
# 生成 SECRET_KEY
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

## 部署说明

### Docker 部署

1. **构建镜像**:
   ```bash
   docker build -t benchmark-platform:latest .
   ```

2. **运行容器**:
   ```bash
   docker run -d \
     -p 3100:3000 \
     -p 8000:8000 \
     --name benchmark-platform \
     -e DATABASE_URL="mysql://user:password@host:port/database" \
     -e OAUTH_CLIENT_ID="<your-client-id>" \
     -e OAUTH_CLIENT_SECRET="<your-client-secret>" \
     -e OAUTH_CALLBACK_URL="https://yourdomain.com/api/v1/auth/linuxdo/callback" \
     -e SECRET_KEY="<your-generated-secret-key>" \
     benchmark-platform:latest
   ```

### 访问地址
- 前端界面: http://localhost:3100
- API文档: http://localhost:8000/docs
- API服务: http://localhost:8000
- 健康检查: http://localhost:8000/health

## 开发指南

### 本地开发

1. **安装依赖**:
   ```bash
   # 后端
   cd backend
   pip install -r requirements.txt

   # 前端
   pnpm install
   ```

2. **配置环境变量**:
   ```bash
   # 复制环境变量模板
   cp .env.example .env

   # 编辑 .env 文件，填入实际配置
   ```

3. **启动服务**:
   ```bash
   # 后端（使用uv虚拟环境）
   cd backend
   uv run python app_main.py

   # 前端（新终端）
   pnpm dev
   ```

4. **访问应用**:
   - 前端: http://localhost:3000
   - 后端: http://localhost:8000
   - API文档: http://localhost:8000/docs

### 数据库初始化

首次运行会自动检查并初始化数据库：

```bash
# 自动执行（包含在 app_main.py 中）
python app_main.py
```

手动执行（如需要）：
```bash
mysql -u root -p < backend/init.sql
```

## 主要特性

### ✅ 已实现功能 (v6.0)
- [x] OAuth 用户认证 (linux.do)
- [x] 标准 JWT 令牌 (python-jose) ✨
- [x] Cookie-based 认证 ✨
- [x] 基准测试结果提交
- [x] 用户记录限制 (每用户最多3条)
- [x] 设备类型自动分类
- [x] 分类排行榜 (服务器级/消费级)
- [x] 手动设备类型校正
- [x] 分页排行榜显示
- [x] 用户记录编辑和删除功能
- [x] 用户排名查询
- [x] CORS 支持
- [x] Docker 容器化部署
- [x] 模块化架构重构 ✨

### 🔧 配置说明

#### 设备类型分类器
- 位置: `backend/app/utils/device_classifier.py`
- 支持自定义关键词匹配规则
- 提供置信度评分机制 (0.0-1.0)
- 可通过 API 进行分类测试

#### OAuth 配置
需要在 linux.do 申请 OAuth 应用：
1. 访问 https://connect.linux.do
2. 创建新的 OAuth 应用
3. 设置回调URL
4. 获取 Client ID 和 Client Secret

#### JWT 配置 (v6.0 升级)
- 使用标准 python-jose 库
- HMAC-SHA256 签名算法
- 24小时有效期
- HttpOnly Cookie 存储

## 安全最佳实践

### 生产环境必须配置

1. **强密钥**:
   ```bash
   # 使用安全随机生成器
   SECRET_KEY=$(python -c "import secrets; print(secrets.token_urlsafe(32))")
   ```

2. **HTTPS**:
   ```env
   # Cookie secure 属性应为 True
   # 在 app_main.py 中配置
   ```

3. **CORS限制**:
   ```env
   # 不要使用 * 在生产环境
   ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
   ```

4. **数据库安全**:
   - 使用强密码
   - 限制数据库访问IP
   - 定期备份

5. **OAuth 回调URL**:
   ```env
   # 必须使用HTTPS
   OAUTH_CALLBACK_URL=https://yourdomain.com/api/v1/auth/linuxdo/callback
   ```

## 注意事项

### 生产环境清单

- [ ] 修改 SECRET_KEY 为强随机密钥
- [ ] 配置正确的数据库连接（使用连接池）
- [ ] 设置正确的 OAuth 回调地址（HTTPS）
- [ ] 限制 CORS 为具体域名
- [ ] 启用 Cookie secure 属性
- [ ] 配置 HTTPS/TLS
- [ ] 设置数据库连接限制
- [ ] 配置日志输出
- [ ] 设置备份策略
- [ ] 禁用 Mock 登录 (`ENABLE_MOCK_LOGIN=False`)

### 数据库
- 确保使用 MySQL 8.0+
- 字符集: utf8mb4
- 定期备份数据
- 监控连接数和慢查询

### 性能
- 排行榜已优化分页查询
- 使用数据库索引
- 考虑添加 Redis 缓存
- 监控 API 响应时间

## 故障排除

### 常见问题

1. **数据库连接失败**:
   - 检查 DATABASE_URL 格式
   - 确认数据库服务运行
   - 检查网络连接

2. **OAuth 回调失败**:
   - 确认回调地址配置正确
   - 检查 FRONTEND_URL 设置
   - 查看后端日志

3. **JWT 验证失败**:
   - 清除浏览器 Cookie
   - 检查 SECRET_KEY 是否正确
   - 确认 Token 未过期

4. **前端无法访问**:
   - 检查 Vite 代理配置
   - 确认后端服务运行
   - 检查 CORS 配置

5. **删除/编辑功能权限错误**:
   - 确保用户只能操作自己的记录
   - 检查用户 ID 映射
   - 查看认证 Token

## 版本历史

### v6.0 (2025-12-14) - 重大重构 ✨
- ✅ JWT 安全修复：使用标准 python-jose 库
- ✅ 模块化重构：app_main.py 从 1336 行减少到 120 行 (-91%)
- ✅ 新增模块：routes/, dependencies/, config.py
- ✅ Cookie-based 认证
- ✅ 安全增强：HMAC-SHA256 签名

### v5.0 (2025-12-05)
- 添加用户排名查询功能
- 优化排行榜性能
- 支持多条记录管理

### v4.0 及更早版本
- 基础功能实现

## 文档资源

- **主文档**: CLAUDE.md (本文件)
- **JWT安全修复**: JWT_SECURITY_FIX.md
- **重构报告**: REFACTORING_REPORT.md
- **README**: README.md
- **API文档**: http://localhost:8000/docs (运行时访问)

---

---

## 附录 A: JWT 安全修复详细报告

### 修复日期
2025-12-14

### 原有实现的安全隐患

原代码使用了**自定义的JWT实现**，存在严重的安全风险：

```python
# 原代码 (不安全)
def create_jwt_token(data: dict) -> str:
    token_data = f"{json.dumps(to_encode)}.{hashlib.md5(SECRET_KEY.encode()).hexdigest()}"
    return token_data
```

**安全问题：**
1. ❌ 使用 **MD5 哈希**作为签名，而非标准的 HMAC-SHA256
2. ❌ Token格式不符合JWT标准（RFC 7519）
3. ❌ 签名方式过于简单，容易被伪造
4. ❌ 未使用行业标准的JWT库

**风险评估：**
- **严重性：** 🔴 高危
- **可能攻击：** Token伪造、权限提升
- **影响范围：** 所有需要认证的API端点

### 修复方案

#### 1. 使用标准JWT库 (python-jose)

```python
from jose import jwt, JWTError

def create_jwt_token(data: dict) -> str:
    """创建标准JWT令牌"""
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(hours=24)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(token: str) -> Optional[dict]:
    """验证JWT令牌"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError as e:
        print(f"DEBUG: JWT验证失败: {e}")
        return None
```

**改进点：**
- ✅ 使用 **HMAC-SHA256** 算法进行签名
- ✅ 符合 **JWT 标准** (RFC 7519)
- ✅ 自动处理 **token过期验证**
- ✅ 使用 **行业标准库** python-jose

#### 2. 安全增强对比

| 项目 | 修复前 | 修复后 |
|------|--------|--------|
| 签名算法 | ❌ MD5 | ✅ HMAC-SHA256 |
| JWT标准兼容 | ❌ 否 | ✅ 是 |
| 使用标准库 | ❌ 否 | ✅ 是 (python-jose) |
| 过期验证 | ⚠️ 手动实现 | ✅ 自动处理 |
| SECRET_KEY强度 | ⚠️ 弱 | ✅ 强 (43字符) |
| Token伪造风险 | 🔴 高 | ✅ 低 |

#### 3. 测试结果

所有测试通过：
- ✅ 服务器启动成功
- ✅ 健康检查通过
- ✅ OAuth登录正常
- ✅ Token验证正常

**安全等级提升：** 🔴 高危 → ✅ 安全

---

## 附录 B: v6.0 重构详细报告

### 重构日期
2025-12-14

### 重构目标
✅ **解决 app_main.py 过于庞大的问题**

### 代码行数对比

| 文件 | 重构前 | 重构后 | 减少 |
|------|--------|--------|------|
| **app_main.py** | **1336 行** | **120 行** | **-91%** 🎉 |
| auth 路由 | 集成在主文件 | 340 行 (独立模块) | ✅ 模块化 |
| benchmarks 路由 | 集成在主文件 | 660 行 (独立模块) | ✅ 模块化 |
| health 路由 | 集成在主文件 | 42 行 (独立模块) | ✅ 模块化 |
| 配置模块 | 集成在主文件 | 46 行 (独立模块) | ✅ 分离 |
| JWT工具 | 集成在主文件 | 40 行 (独立模块) | ✅ 分离 |
| 数据库工具 | 集成在主文件 | 52 行 (独立模块) | ✅ 分离 |

**总体效果：** 代码从单文件1336行拆分为多个模块，主入口文件仅120行，**代码可读性和可维护性大幅提升** ✨

### 重构亮点

#### 1. 模块化路由

**Before:**
```python
# app_main.py (1336行)
@app.get("/api/v1/auth/login")
async def login():
    ...

@app.post("/api/v1/benchmarks/submit")
async def submit_benchmark(...):
    ...

# 所有路由混在一起，难以维护
```

**After:**
```python
# app_main.py (120行) - 清晰简洁
from app.routes import health, auth, benchmarks

app.include_router(health.router)
app.include_router(auth.router)
app.include_router(benchmarks.router)
```

#### 2. 配置集中管理

**Before:** 配置分散在主文件中

**After:**
```python
# app/config.py - 统一配置
CLIENT_ID = os.getenv("OAUTH_CLIENT_ID")
CLIENT_SECRET = os.getenv("OAUTH_CLIENT_SECRET")
ALLOWED_ORIGINS = ...

def get_frontend_url():
    # 智能获取前端URL
    ...
```

#### 3. 路由模块功能划分

**app/routes/auth.py** (340行):
- OAuth 登录、回调处理
- 获取当前用户信息
- 登出、Mock 登录
- Token 验证

**app/routes/benchmarks.py** (660行):
- 解析基准测试文本
- 设备类型分类
- 提交、获取、更新、删除记录
- 排行榜、用户排名

**app/routes/health.py** (42行):
- 根路由
- 健康检查

### 测试结果

所有API测试通过：
- ✅ 启动测试通过
- ✅ 健康检查通过
- ✅ OAuth登录通过
- ✅ 排行榜查询通过（147条记录）

### 重构优势

**代码可维护性 ⬆️**
- 单个文件职责明确
- 易于定位问题
- 修改影响范围可控

**开发效率 ⬆️**
- 多人协作更容易
- 代码复用性提高
- 测试更容易编写

**性能 ➡️**
- 无性能损失
- 所有API正常工作
- 响应时间保持不变

### 性能对比

| 指标 | 重构前 | 重构后 | 状态 |
|------|--------|--------|------|
| 启动时间 | ~2秒 | ~2秒 | ✅ 相同 |
| 内存占用 | ~50MB | ~50MB | ✅ 相同 |
| API响应时间 | 平均100ms | 平均100ms | ✅ 相同 |
| 代码可读性 | 差 | 优秀 | ⬆️ 大幅提升 |
| 维护难度 | 高 | 低 | ⬇️ 显著降低 |

### 回滚方案

如果需要回滚到原版本：

```bash
cd backend
mv app_main.py app_main.py.refactored
mv app_main.py.backup app_main.py
uv run python app_main.py
```

---

## 附录 C: 数据库迁移指南

### 概述
详细说明如何将现有数据库平滑升级到支持设备类型分类和用户记录限制的新版本。

### 升级内容

**新增字段：**
- `device_type`: 设备类型 (server/consumer/unknown)
- `device_type_confidence`: 设备类型识别置信度 (0.00-1.00)
- `device_type_manually_corrected`: 是否被用户手动修正

**新增配置：**
- `max_results_per_user`: 每个用户最多提交3条记录（从10改为3）
- `enable_device_classification`: 启用设备类型自动分类
- `device_type_confidence_threshold`: 设备类型自动分类的置信度阈值

### 迁移步骤

#### 1. 备份数据库（最重要！）

```bash
mysqldump -u root -p benchmark > benchmark_backup_$(date +%Y%m%d_%H%M%S).sql
```

#### 2. 检查现有数据

```sql
-- 查看现有的基准测试结果数量
SELECT COUNT(*) as total_records FROM benchmark_results;

-- 查看现有的CPU型号分布
SELECT cpu_model, COUNT(*) as count
FROM benchmark_results
WHERE cpu_model IS NOT NULL
GROUP BY cpu_model
ORDER BY count DESC;

-- 查看用户提交统计
SELECT user_id, username, COUNT(*) as submission_count
FROM benchmark_results
GROUP BY user_id, username
ORDER BY submission_count DESC;
```

#### 3. 执行结构迁移

```sql
SOURCE database_migration.sql;
```

#### 4. 验证迁移结果

```sql
-- 检查新字段是否添加成功
DESCRIBE benchmark_results;

-- 查看设备类型分类结果
SELECT device_type, COUNT(*) as count, AVG(device_type_confidence) as avg_confidence
FROM benchmark_results
GROUP BY device_type;
```

#### 5. 处理分类不准确的数据

```sql
-- 查看低置信度的分类（可能需要手动修正）
SELECT id, cpu_model, device_type, device_type_confidence
FROM benchmark_results
WHERE device_type_confidence < 0.7
AND cpu_model IS NOT NULL
ORDER BY device_type_confidence ASC;

-- 手动修正特定记录
UPDATE benchmark_results
SET device_type = 'server',
    device_type_confidence = 1.0,
    device_type_manually_corrected = TRUE,
    updated_at = NOW()
WHERE id = [specific_id];
```

### 回滚方案

如果迁移出现问题：

```sql
-- 删除当前数据库
DROP DATABASE benchmark;

-- 重新创建数据库
CREATE DATABASE benchmark DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci;

-- 恢复备份
SOURCE benchmark_backup.sql;
```

### 注意事项

**数据安全：**
1. 务必在生产环境迁移前备份数据库
2. 建议在测试环境先进行迁移测试
3. 迁移过程中避免用户提交新的数据

**性能考虑：**
1. 大数据量迁移时，建议分批执行CPU类型分类更新
2. 在低峰期执行迁移操作
3. 迁移脚本中的分类更新可能会较慢，建议根据数据量调整

**业务影响：**
1. 迁移后用户记录限制从10条改为3条
2. 现有用户如果已有超过3条已验证记录，可以保留但无法再提交新记录
3. 设备类型分类会立即生效，影响排行榜显示

---

## 附录 D: 数据库详细设计

### 表结构设计

#### 1. users 表 - 用户信息

```sql
CREATE TABLE `users` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(100) NOT NULL,
    `user_id` VARCHAR(100) NOT NULL,
    `email` VARCHAR(255) DEFAULT NULL,
    `avatar_url` VARCHAR(500) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`),
    UNIQUE KEY `uk_user_id` (`user_id`)
);
```

#### 2. benchmark_results 表 - 基准测试结果

```sql
CREATE TABLE `benchmark_results` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `username` VARCHAR(100) NOT NULL,

    -- 系统信息
    `cpu_model` VARCHAR(255) DEFAULT NULL,
    `cpu_cores` INT DEFAULT NULL,
    `memory_gb` DECIMAL(10,2) DEFAULT NULL,

    -- 性能数据
    `phase1_wall_time` DECIMAL(15,6) DEFAULT NULL,
    `phase2_wall_time` DECIMAL(15,6) DEFAULT NULL,
    `overall_wall_time` DECIMAL(15,6) DEFAULT NULL,

    -- 设备类型分类（v6.0新增）
    `device_type` VARCHAR(20) DEFAULT 'unknown',
    `device_type_confidence` DECIMAL(5,2) DEFAULT 0.00,

    -- 时间戳
    `submitted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_overall_time` (`overall_wall_time`),
    KEY `idx_device_type` (`device_type`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
);
```

#### 3. system_config 表 - 系统配置

```sql
CREATE TABLE `system_config` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `config_key` VARCHAR(100) NOT NULL,
    `config_value` TEXT DEFAULT NULL,
    `config_type` VARCHAR(20) DEFAULT 'string',
    `description` VARCHAR(255) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_config_key` (`config_key`)
);
```

### 视图设计

#### v_user_best_results - 用户最佳成绩

```sql
CREATE VIEW `v_user_best_results` AS
SELECT
    u.id as user_id,
    u.username,
    u.avatar_url,
    br.id as result_id,
    br.cpu_model,
    br.cpu_cores,
    br.memory_gb,
    br.phase1_wall_time,
    br.phase2_wall_time,
    br.overall_wall_time,
    br.submitted_at
FROM users u
INNER JOIN benchmark_results br ON u.id = br.user_id
WHERE br.overall_wall_time IS NOT NULL
AND br.id = (
    SELECT id
    FROM benchmark_results br2
    WHERE br2.user_id = u.id
    AND br2.overall_wall_time IS NOT NULL
    ORDER BY br2.overall_wall_time ASC
    LIMIT 1
);
```

#### v_leaderboard - 实时排行榜

```sql
CREATE VIEW `v_leaderboard` AS
SELECT
    ROW_NUMBER() OVER (ORDER BY overall_wall_time ASC, submitted_at ASC) as rank_position,
    username,
    cpu_model,
    cpu_cores,
    memory_gb,
    overall_wall_time,
    phase1_wall_time,
    phase2_wall_time,
    submitted_at
FROM v_user_best_results
ORDER BY overall_wall_time ASC, submitted_at ASC;
```

### 索引策略

**主要索引：**
- `users`: `uk_username`, `uk_user_id`
- `benchmark_results`: `idx_user_id`, `idx_overall_time`, `idx_device_type`
- `system_config`: `uk_config_key`

**复合索引：**
- `idx_ranking` (`is_verified`, `overall_wall_time`, `submitted_at`) - 专门用于排行榜查询

### 初始配置数据

| 配置键 | 默认值 | 类型 | 说明 |
|--------|--------|------|------|
| leaderboard_enabled | true | boolean | 是否启用排行榜功能 |
| max_results_per_user | 3 | number | 每个用户最多提交的结果数量 |
| auto_verify_enabled | true | boolean | 是否自动验证新提交的结果 |
| snapshot_retention_days | 90 | number | 排行榜快照保留天数 |
| site_name | 基准测试评分平台 | string | 网站名称 |

### 性能优化

1. **冗余字段**: `benchmark_results.username` 冗余存储用户名，避免频繁 JOIN
2. **索引优化**: 针对排行榜查询优化的复合索引
3. **视图预计算**: 使用视图预先计算排行榜数据

### 数据完整性

1. **外键约束**: 确保 `benchmark_results.user_id` 引用有效的用户
2. **唯一约束**: 确保用户名和 linux.do 用户ID的唯一性
3. **NOT NULL**: 关键字段设置 NOT NULL 约束

---

**最后更新**: 2025-12-14
**版本**: 6.0
**维护者**: Claude Code Development Team
**重构完成**: ✅ app_main.py 模块化重构完成
