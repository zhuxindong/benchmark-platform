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

**最后更新**: 2025-12-14
**版本**: 6.0
**维护者**: Claude Code Development Team
**重构完成**: ✅ app_main.py 模块化重构完成
