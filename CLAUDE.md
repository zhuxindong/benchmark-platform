# 基准测试评分平台 - Claude 开发文档

## 项目概述

这是一个基于 FastAPI + Vue.js 的基准测试评分平台，支持用户提交基准测试结果并查看排行榜。平台集成了 linux.do OAuth 认证，并具备设备类型自动分类功能。

## 技术栈

### 后端
- **框架**: FastAPI 0.104.1
- **数据库**: MySQL 8.0+
- **ORM**: SQLAlchemy 2.0.23 (基础查询) + PyMySQL 1.1.0
- **认证**: 基于 linux.do OAuth 2.0
- **语言**: Python 3.11

### 前端
- **框架**: Vue.js 3.5.25
- **构建工具**: Vite 5.4.21
- **路由**: Vue Router 4.6.3
- **包管理器**: pnpm

### 部署
- **容器化**: Docker
- **架构**: 单容器部署，前后端在同一容器内

## 核心功能

### 1. 用户认证系统
- 基于 linux.do OAuth 2.0 的用户登录
- JWT token 认证机制
- 用户信息自动同步

### 2. 基准测试管理
- 用户可提交基准测试结果
- 每个用户限制最多 3 条记录
- 自动数据验证和处理

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

## 项目结构

```
benchmark-platform/
├── backend/                    # 后端代码
│   ├── app/
│   │   ├── __init__.py
│   │   ├── api/v1/            # API 路由
│   │   │   ├── auth.py         # 认证相关API
│   │   │   ├── benchmarks.py   # 基准测试API
│   │   │   ├── leaderboard.py  # 排行榜API
│   │   │   └── users.py        # 用户API
│   │   ├── core/               # 核心配置
│   │   │   ├── auth.py         # 认证逻辑
│   │   │   ├── config.py       # 配置管理
│   │   │   ├── database.py     # 数据库连接
│   │   │   └── logging.py      # 日志配置
│   │   ├── models/             # 数据模型
│   │   │   ├── user.py         # 用户模型
│   │   │   └── benchmark.py    # 基准测试模型
│   │   ├── services/           # 业务逻辑
│   │   │   ├── auth_service.py # 认证服务
│   │   │   └── benchmark_service.py # 基准测试服务
│   │   ├── schemas/            # API 模式
│   │   │   ├── user.py         # 用户模式
│   │   │   ├── benchmark.py    # 基准测试模式
│   │   │   └── leaderboard.py  # 排行榜模式
│   │   └── utils/              # 工具函数
│   │       └── device_classifier.py # 设备类型分类器
│   ├── app_main.py             # 主应用入口
│   ├── init.sql                # 数据库初始化脚本
│   ├── database_migration.sql  # 数据库迁移脚本
│   ├── requirements.txt        # Python依赖
│   └── .env                    # 环境变量配置
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
├── index.html                  # HTML 模板
├── vite.config.js              # Vite 配置
├── package.json                # 前端依赖配置
├── pnpm-lock.yaml              # 锁定依赖版本
├── Dockerfile                  # Docker 构建配置
└── docker-compose.yml          # Docker Compose 配置
```

## 数据库设计

### 核心表结构

#### users 表 - 用户信息
- `id`: 用户唯一标识
- `username`: linux.do 用户名
- `user_id`: linux.do 用户ID
- `email`: 邮箱地址
- `avatar_url`: 头像URL

#### benchmark_results 表 - 基准测试结果
- `id`: 结果唯一标识
- `user_id`: 关联用户ID
- `cpu_model`: CPU型号
- `cpu_cores`: CPU核心数
- `memory_gb`: 内存大小(GB)
- `phase1_wall_time`: Phase 1 耗时
- `phase2_wall_time`: Phase 2 耗时
- `overall_wall_time`: 总耗时
- `device_type`: 设备类型 (server/consumer/unknown)
- `device_type_confidence`: 设备类型置信度
- `is_verified`: 是否已验证
- `submitted_at`: 提交时间

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

## API 端点

### 认证相关
- `GET /api/v1/auth/login` - OAuth登录跳转
- `GET /api/v1/auth/linuxdo/callback` - OAuth回调
- `GET /api/v1/auth/me` - 获取当前用户信息

### 基准测试相关
- `POST /api/v1/benchmarks/parse` - 解析基准测试结果
- `POST /api/v1/benchmarks/submit` - 提交基准测试结果
- `GET /api/v1/benchmarks/my-result` - 获取用户提交结果
- `PUT /api/v1/benchmarks/{id}` - 更新基准测试结果
- `DELETE /api/v1/benchmarks/{id}` - 删除基准测试结果
- `GET /api/v1/benchmarks/{id}` - 获取基准测试详情

### 排行榜相关
- `GET /api/v1/benchmarks/leaderboard` - 获取排行榜
  - 参数: `device_type` (server/consumer), `page`, `limit`

## 环境配置

### 环境变量

```bash
# 数据库配置
DATABASE_URL=mysql://user:password@host:port/database

# OAuth配置
OAUTH_CLIENT_ID=your_oauth_client_id
OAUTH_CLIENT_SECRET=your_oauth_client_secret
OAUTH_CALLBACK_URL=http://your_domain.com/api/v1/auth/linuxdo/callback

# 应用配置
SECRET_KEY=your-secret-key
ALLOWED_ORIGINS=*
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
     -e OAUTH_CLIENT_ID="your_client_id" \
     -e OAUTH_CLIENT_SECRET="your_client_secret" \
     -e OAUTH_CALLBACK_URL="http://your_domain.com/api/v1/auth/linuxdo/callback" \
     benchmark-platform:latest
   ```

### 访问地址
- 前端界面: http://localhost:3100
- API文档: http://localhost:8000/docs
- API服务: http://localhost:8000

## 开发指南

### 本地开发

1. **后端开发**:
   ```bash
   cd backend
   pip install -r requirements.txt
   python app_main.py
   ```

2. **前端开发**:
   ```bash
   pnpm install
   pnpm dev
   ```

### 数据库迁移

首次运行需要执行数据库迁移：
```bash
mysql -u root -p < backend/init.sql
mysql -u root -p < backend/database_migration.sql
```

## 主要特性

### ✅ 已实现功能
- [x] OAuth 用户认证 (linux.do)
- [x] 基准测试结果提交
- [x] 用户记录限制 (每用户最多3条)
- [x] 设备类型自动分类
- [x] 分类排行榜 (服务器级/消费级)
- [x] 手动设备类型校正
- [x] 分页排行榜显示
- [x] 用户记录编辑和删除功能
- [x] CORS 支持
- [x] Docker 容器化部署

### 🔧 配置说明

#### 设备类型分类器
- 位置: `backend/app/utils/device_classifier.py`
- 支持自定义关键词匹配规则
- 提供置信度评分机制
- 可通过管理接口手动校正

#### OAuth 配置
需要在 linux.do 申请 OAuth 应用，获取 Client ID 和 Client Secret。

## 注意事项

1. **生产环境**:
   - 修改默认的 SECRET_KEY
   - 配置正确的数据库连接
   - 设置正确的 OAuth 回调地址
   - 配置适当的 CORS 域名

2. **数据库**:
   - 确保使用 MySQL 8.0+
   - 运行数据库迁移脚本
   - 定期备份数据

3. **性能**:
   - 排行榜已优化分页查询
   - 使用适当的数据库索引
   - 考虑定期生成排行榜快照

## 故障排除

### 常见问题

1. **数据库连接失败**: 检查 DATABASE_URL 格式和数据库服务状态
2. **OAuth 回调失败**: 确认回调地址配置正确
3. **设备类型分类错误**: 检查 CPU 型号匹配规则
4. **前端无法访问**: 检查 Vite 代理配置
5. **删除/编辑功能权限错误**: 确保用户只能操作自己的记录，检查用户ID映射

---

**最后更新**: 2025-12-05
**版本**: 5.0
**维护者**: Claude Code Development Team