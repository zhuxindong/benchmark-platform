# 🚀 基准测试评分平台

一个基于 Vue.js + FastAPI + MySQL 的现代化基准测试评分平台，集成 linux.do OAuth 认证，支持设备类型自动分类和分类排行榜。

[![FastAPI](https://img.shields.io/badge/FastAPI-0.104.1-009688?logo=fastapi)](https://fastapi.tiangolo.com/)
[![Vue.js](https://img.shields.io/badge/Vue.js-3.5.25-42b883?logo=vue.js)](https://vuejs.org/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479a1?logo=mysql)](https://www.mysql.com/)

## ✨ 功能特性

- 🔐 **OAuth 认证**: 集成 linux.do 一键登录
- 📊 **智能解析**: 自动解析基准测试结果文本
- 🎯 **设备分类**: AI 自动识别服务器级/消费级设备
- 🏆 **分类排行榜**: 按设备类型独立排名
- 👤 **用户管理**: 每用户最多 3 条记录
- 📱 **响应式设计**: 支持桌面和移动端
- 🐳 **容器化部署**: 一键 Docker 部署

## 🎯 在线演示

- **生产环境**: https://benchmark.zhile.in
- **API 文档**: https://benchmark.zhile.in/docs

## 🚀 快速开始

### 方法一：Docker 部署（推荐）

```bash
# 1. 拉取镜像
docker pull zhuxindong/benchmark-platform:latest

# 2. 运行容器
docker run -d \
  -p 3100:3000 \
  -p 8000:8000 \
  --name benchmark-platform \
  -e DATABASE_URL="mysql://用户名:密码@数据库地址:3306/数据库名" \
  -e OAUTH_CLIENT_ID="你的OAuth客户端ID" \
  -e OAUTH_CLIENT_SECRET="你的OAuth客户端密钥" \
  -e OAUTH_CALLBACK_URL="http://你的域名/api/v1/auth/linuxdo/callback" \
  -e SECRET_KEY="$(python -c 'import secrets; print(secrets.token_urlsafe(32))')" \
  zhuxindong/benchmark-platform:latest

# 3. 访问应用
# 前端: http://localhost:3100
# API: http://localhost:8000/docs
```

### 方法二：本地开发

#### 前置要求
- Node.js 16+ 和 pnpm
- Python 3.11+
- MySQL 8.0+

#### 启动后端
```bash
cd backend
pip install -r requirements.txt
# 或使用 uv 虚拟环境
uv run python app_main.py
```

#### 启动前端
```bash
pnpm install
pnpm dev
```

访问地址：
- 前端: http://localhost:3000
- API 文档: http://localhost:8000/docs
- 健康检查: http://localhost:8000/health

## ⚙️ 环境变量配置

创建 `.env` 文件：

```bash
# 数据库配置
DATABASE_URL=mysql://root:password@localhost:3306/benchmark

# OAuth 配置（在 linux.do 申请）
OAUTH_CLIENT_ID=你的客户端ID
OAUTH_CLIENT_SECRET=你的客户端密钥
OAUTH_CALLBACK_URL=http://localhost:8000/api/v1/auth/linuxdo/callback

# 前端 URL（开发环境）
FRONTEND_URL=http://localhost:3000

# JWT 密钥（生成强随机密钥）
SECRET_KEY=$(python -c "import secrets; print(secrets.token_urlsafe(32))")

# CORS 配置
ALLOWED_ORIGINS=*  # 生产环境请设置具体域名
```

### 如何申请 linux.do OAuth

1. 访问 https://connect.linux.do
2. 创建新的 OAuth 应用
3. 设置回调 URL
4. 获取 Client ID 和 Client Secret

## 📖 使用说明

### 1. 提交基准测试结果

在首页粘贴您的基准测试结果：

```
=== System Information ===
  CPU             : AMD Ryzen 7 6800H with Radeon Graphics
  Cores_logical   : 16
  Memory          : 7.8 GB

[Phase 1] HMAC brute-force started
  wall_time       : 64.642 s

[Phase 2] LLL float benchmark
  wall_time       : 71.761 s

[Overall] total wall_time: 136.405 s
```

### 2. 自动设备分类

系统会自动识别设备类型：
- 🖥️ **服务器级**: Intel Xeon, AMD EPYC 等
- 💻 **消费级**: Intel Core i5/i7/i9, AMD Ryzen 等

置信度评分：
- 高置信度 (>0.7): 自动分类准确
- 低置信度 (<0.7): 建议手动校正

### 3. 查看排行榜

- **综合排行榜**: 所有设备混合排名
- **服务器榜**: 仅服务器级 CPU
- **消费级榜**: 仅消费级 CPU

## 📂 项目结构

```
benchmark-platform/
├── src/                      # 前端源码 (Vue.js)
│   ├── views/                # 页面组件
│   ├── services/             # API 服务
│   └── stores/               # 状态管理
├── backend/                  # 后端源码 (FastAPI)
│   ├── app/                  # 应用模块
│   │   ├── routes/           # 路由模块 ✨
│   │   ├── dependencies/     # 依赖注入 ✨
│   │   ├── config.py         # 配置管理 ✨
│   │   └── utils/            # 工具函数
│   ├── app_main.py           # 主入口 (120行) ✨
│   └── init.sql              # 数据库初始化
├── Dockerfile                # Docker 构建配置
├── docker-compose.yml        # Docker Compose 配置
└── README.md                 # 本文档

✨ = v6.0 重构新增/优化
```

## 🔧 开发文档

详细的开发文档请参考：
- **开发指南**: [CLAUDE.md](./CLAUDE.md)
- **后端文档**: [backend/README.md](./backend/README.md)
- **JWT 安全修复**: [JWT_SECURITY_FIX.md](./JWT_SECURITY_FIX.md)
- **重构报告**: [REFACTORING_REPORT.md](./REFACTORING_REPORT.md)

## 🐳 生产环境部署

### Docker Compose（推荐）

创建 `docker-compose.yml`:

```yaml
version: '3.8'

services:
  app:
    image: zhuxindong/benchmark-platform:latest
    ports:
      - "3100:3000"
      - "8000:8000"
    environment:
      - DATABASE_URL=mysql://root:password@mysql:3306/benchmark
      - OAUTH_CLIENT_ID=${OAUTH_CLIENT_ID}
      - OAUTH_CLIENT_SECRET=${OAUTH_CLIENT_SECRET}
      - OAUTH_CALLBACK_URL=https://yourdomain.com/api/v1/auth/linuxdo/callback
      - SECRET_KEY=${SECRET_KEY}
      - ALLOWED_ORIGINS=https://yourdomain.com
    restart: unless-stopped
    depends_on:
      - mysql

  mysql:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=password
      - MYSQL_DATABASE=benchmark
    volumes:
      - mysql_data:/var/lib/mysql
    restart: unless-stopped

volumes:
  mysql_data:
```

启动：
```bash
docker-compose up -d
```

### 生产环境清单

- [ ] 使用 HTTPS（配置 SSL 证书）
- [ ] 设置强随机 SECRET_KEY
- [ ] 限制 CORS 为具体域名
- [ ] 配置数据库连接池
- [ ] 设置定期数据库备份
- [ ] 配置日志收集和监控
- [ ] 启用 Cookie secure 属性

## 🛡️ 安全说明

### 生产环境必须配置

1. **强密钥**
   ```bash
   SECRET_KEY=$(python -c "import secrets; print(secrets.token_urlsafe(32))")
   ```

2. **HTTPS**
   - 使用反向代理（Nginx/Caddy）配置 SSL
   - Cookie secure 属性设为 True

3. **CORS 限制**
   ```env
   ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
   ```

4. **数据库安全**
   - 使用强密码
   - 限制访问 IP
   - 定期备份

## 📊 API 端点

### 认证
- `GET /api/v1/auth/login` - 获取 OAuth 登录 URL
- `POST /api/v1/auth/linuxdo/callback` - OAuth 回调处理
- `GET /api/v1/auth/me` - 获取当前用户信息

### 基准测试
- `POST /api/v1/benchmarks/parse` - 解析测试结果
- `POST /api/v1/benchmarks/submit` - 提交测试结果
- `GET /api/v1/benchmarks/leaderboard` - 获取排行榜
- `GET /api/v1/benchmarks/my-result` - 获取我的记录
- `GET /api/v1/benchmarks/my-ranks` - 获取我的排名

完整 API 文档: http://localhost:8000/docs

## 🐛 故障排除

### 常见问题

1. **数据库连接失败**
   ```bash
   # 检查数据库连接
   curl http://localhost:8000/health
   ```

2. **OAuth 认证失败**
   - 确认回调 URL 完全匹配
   - 检查 Client ID 和 Secret
   - 查看后端日志

3. **前端无法访问**
   - 检查端口占用
   - 确认 CORS 配置
   - 查看浏览器控制台

### 调试命令

```bash
# 查看容器日志
docker logs -f benchmark-platform

# 进入容器调试
docker exec -it benchmark-platform /bin/bash

# 检查服务状态
docker ps
curl http://localhost:8000/health
```

## 📝 版本历史

### v6.0 (2025-12-14) ✨
- JWT 安全升级（python-jose + HMAC-SHA256）
- 模块化重构（app_main.py: 1336 → 120 行）
- Cookie-based 认证
- 新增路由模块、依赖注入、配置管理

### v5.0 (2025-12-05)
- 用户排名查询功能
- 多记录管理
- 设备类型分类

## 🤝 贡献指南

欢迎贡献代码！请先阅读：
- [开发文档](./CLAUDE.md)
- [后端文档](./backend/README.md)

提交 Pull Request 前请确保：
- 代码通过 lint 检查
- 添加必要的测试
- 更新相关文档

## 📄 许可证

MIT License

## 🙏 致谢

- [FastAPI](https://fastapi.tiangolo.com/) - 现代化的 Python Web 框架
- [Vue.js](https://vuejs.org/) - 渐进式 JavaScript 框架
- [linux.do](https://linux.do) - OAuth 认证支持

---

**最后更新**: 2025-12-14
**当前版本**: v6.0
**维护者**: Claude Code Development Team
