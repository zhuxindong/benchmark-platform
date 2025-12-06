# 🚀 基准测试评分平台 - 后端

基于 FastAPI 的现代化基准测试评分平台后端服务。

## 📋 功能特性

- ✨ **FastAPI 框架**: 高性能异步 Web 框架
- 🗄️ **MySQL 数据库**: 支持基准测试结果存储和排行榜
- 🔐 **OAuth 认证**: 集成 linux.do 认证系统
- 📊 **排行榜系统**: 实时计算和缓存排行榜
- 📝 **API 文档**: 自动生成的 OpenAPI 文档
- 🔍 **日志系统**: 完整的日志记录和错误追踪

## 🛠️ 技术栈

- **Web 框架**: FastAPI + Uvicorn
- **数据库**: MySQL + SQLAlchemy ORM
- **认证**: JWT + OAuth2
- **数据验证**: Pydantic
- **日志**: Loguru
- **HTTP 客户端**: HTTPX + AIOHTTP

## 🚀 快速开始

### 1. 安装依赖

```bash
pip install -r requirements.txt
```

### 2. 配置环境变量

复制 `.env` 文件并根据需要修改配置：

```bash
cp .env.example .env
```

主要配置项：
- `DATABASE_URL`: 数据库连接字符串
- `SECRET_KEY`: JWT 密钥
- `LINUXDO_CLIENT_ID`: linux.do OAuth 客户端ID
- `LINUXDO_CLIENT_SECRET`: linux.do OAuth 客户端密钥

### 3. 初始化数据库

```bash
python test_connection.py --init
```

### 4. 启动开发服务器

```bash
# 方法1: 使用启动脚本
python run.py start

# 方法2: 直接启动
python main.py

# 方法3: 使用 uvicorn
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 5. 测试数据库连接

```bash
python run.py test-db
```

## 📖 API 文档

启动服务器后访问：

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json

## 📂 项目结构

```
backend/
├── app/
│   ├── api/v1/              # API 路由
│   │   ├── auth.py         # 认证相关
│   │   ├── benchmarks.py   # 基准测试
│   │   ├── users.py        # 用户管理
│   │   └── leaderboard.py  # 排行榜
│   ├── core/               # 核心模块
│   │   ├── config.py       # 配置管理
│   │   ├── database.py     # 数据库连接
│   │   └── logging.py      # 日志配置
│   ├── models/             # 数据模型
│   │   ├── user.py         # 用户模型
│   │   └── benchmark.py    # 基准测试模型
│   └── services/           # 业务逻辑服务
├── main.py                 # 应用入口
├── run.py                  # 启动脚本
├── test_connection.py      # 数据库测试工具
├── init.sql               # 数据库初始化脚本
├── requirements.txt       # Python 依赖
└── .env                   # 环境变量配置
```

## 🔧 开发工具

### 代码格式化

```bash
# 使用 black 格式化代码
black app/ main.py run.py

# 使用 ruff 检查代码质量
ruff check app/ main.py run.py
```

### 运行测试

```bash
pytest tests/
```

### 数据库迁移

```bash
# 生成迁移文件
alembic revision --autogenerate -m "描述"

# 执行迁移
alembic upgrade head
```

## 📊 API 端点

### 认证 (`/api/v1/auth`)
- `GET /login` - 获取登录URL
- `GET /linuxdo/callback` - OAuth回调
- `POST /logout` - 登出

### 基准测试 (`/api/v1/benchmarks`)
- `POST /submit` - 提交基准测试结果
- `GET /my-results` - 获取我的结果
- `GET /{result_id}` - 获取特定结果

### 用户 (`/api/v1/users`)
- `GET /me` - 获取当前用户信息

### 排行榜 (`/api/v1/leaderboard`)
- `GET /` - 获取排行榜
- `GET /my-rank` - 获取我的排名

## 🔒 认证流程

1. 用户点击登录，重定向到 linux.do OAuth
2. 用户在 linux.do 授权后，回调到后端
3. 后端获取访问令牌和用户信息
4. 创建或更新用户记录
5. 生成 JWT 令牌返回给前端

## 📝 日志系统

日志文件位置：
- `logs/app.log` - 主日志文件
- `logs/error.log` - 错误日志文件

日志级别：DEBUG, INFO, WARNING, ERROR, CRITICAL

## 🚀 部署

### Docker 部署

```bash
# 构建镜像
docker build -t benchmark-platform-backend .

# 运行容器
docker run -p 8000:8000 benchmark-platform-backend
```

### 环境变量

生产环境需要设置的关键环境变量：

```bash
DATABASE_URL=mysql+pymysql://user:password@host:port/database
SECRET_KEY=your-production-secret-key
DEBUG=false
LINUXDO_CLIENT_ID=your-linuxdo-client-id
LINUXDO_CLIENT_SECRET=your-linuxdo-client-secret
```

## 🤝 开发规范

- 使用 Python 3.8+ 类型注解
- 遵循 PEP 8 代码风格
- 所有函数和类都有文档字符串
- 使用 Pydantic 进行数据验证
- 异步处理数据库操作

## 🐛 问题排查

### 数据库连接问题
1. 检查 MySQL 服务是否运行
2. 验证数据库连接配置
3. 确认数据库和表已创建

### OAuth 认证问题
1. 检查 linux.do 应用配置
2. 验证回调 URL 设置
3. 确认客户端ID和密钥正确

## 📄 许可证

MIT License