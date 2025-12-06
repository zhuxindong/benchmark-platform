# 🚀 基准测试评分平台

一个基于 Vue.js + FastAPI + MySQL 的基准测试评分平台，集成 linux.do OAuth 认证。

## 📋 功能特性

- ✨ **结果解析**: 自动解析基准测试结果文本
- 📝 **数据确认**: 结构化显示解析结果，支持用户修改
- 🔐 **OAuth 认证**: 集成 Linux.do OAuth 登录
- 📊 **排行榜**: 实时基准测试排名展示
- 👥 **用户管理**: 用户注册和信息管理
- 🎨 **美观界面**: 现代化的响应式设计
- 📱 **移动适配**: 支持移动端访问

## 🛠️ 技术栈

- **前端**: Vue 3 (Composition API) + Vite + Vue Router
- **后端**: FastAPI + Uvicorn
- **数据库**: MySQL 8.0
- **认证**: OAuth2 (Linux.do)
- **容器化**: Docker

## 🚀 快速开始

### 本地开发

1. **克隆项目**
```bash
git clone <repository-url>
cd benchmark-platform
```

2. **后端启动**
```bash
cd backend
python app_main.py
```

3. **前端启动**
```bash
pnpm dev
```

访问地址：
- 前端页面: http://localhost:3000
- API 文档: http://localhost:8000/docs
- API 服务: http://localhost:8000

### Docker 部署

#### 方法 1：使用预构建镜像

```bash
# 拉取镜像
docker pull yourusername/benchmark-platform:latest

# 运行容器
docker run -d \
  -p 3000:3000 \
  -p 8000:8000 \
  --name benchmark-platform \
  -e DATABASE_URL="mysql://用户名:密码@数据库地址:3306/benchmark" \
  -e OAUTH_CLIENT_ID="你的OAuth客户端ID" \
  -e OAUTH_CLIENT_SECRET="你的OAuth客户端密钥" \
  -e OAUTH_CALLBACK_URL="http://localhost:8000/api/v1/auth/linuxdo/callback" \
  yourusername/benchmark-platform:latest
```

#### 方法 2：从源码构建

```bash
# 克隆项目
git clone <repository-url>
cd benchmark-platform

# 构建镜像
docker build -t benchmark-platform .

# 运行容器
docker run -d \
  -p 3000:3000 \
  -p 8000:8000 \
  --name benchmark-platform \
  -e DATABASE_URL="mysql://用户名:密码@数据库地址:3306/benchmark" \
  -e OAUTH_CLIENT_ID="你的OAuth客户端ID" \
  -e OAUTH_CLIENT_SECRET="你的OAuth客户端密钥" \
  -e OAUTH_CALLBACK_URL="http://localhost:8000/api/v1/auth/linuxdo/callback" \
  benchmark-platform
```

## ⚙️ 环境变量配置

### 必需的环境变量

| 变量名 | 描述 | 示例值 |
|--------|------|--------|
| `DATABASE_URL` | MySQL 数据库连接字符串 | `mysql://root:password@192.168.1.100:3306/benchmark` |
| `OAUTH_CLIENT_ID` | Linux.do OAuth 客户端 ID | `xxx` |
| `OAUTH_CLIENT_SECRET` | Linux.do OAuth 客户端密钥 | `xxx` |
| `OAUTH_CALLBACK_URL` | OAuth 回调地址 | `http://localhost:8000/api/v1/auth/linuxdo/callback` |

### 可选的环境变量

| 变量名 | 描述 | 默认值 |
|--------|------|--------|
| `ALLOWED_ORIGINS` | CORS 允许的源（逗号分隔） | `*` |
| `VITE_ALLOWED_HOSTS` | 前端开发服务器允许的主机（逗号分隔），设为 `all` 允许所有域名 | `all` |

## 🐳 Docker 运行示例

### 基本运行

```bash
docker run -d \
  -p 3000:3000 \
  -p 8000:8000 \
  --name benchmark-platform \
  -e DATABASE_URL="mysql://root:root@192.168.198.91:3306/benchmark" \
  -e OAUTH_CLIENT_ID="xxx" \
  -e OAUTH_CLIENT_SECRET="xxx" \
  -e OAUTH_CALLBACK_URL="http://localhost:8000/api/v1/auth/linuxdo/callback" \
  yourusername/benchmark-platform:latest
```

### 生产环境运行

```bash
docker run -d \
  -p 3000:3000 \
  -p 8000:8000 \
  --name benchmark-platform \
  --restart unless-stopped \
  -e DATABASE_URL="mysql://prod_user:strong_password@db.example.com:3306/benchmark" \
  -e OAUTH_CLIENT_ID="your_prod_oauth_id" \
  -e OAUTH_CLIENT_SECRET="your_prod_oauth_secret" \
  -e OAUTH_CALLBACK_URL="https://yourdomain.com/api/v1/auth/linuxdo/callback" \
  -e ALLOWED_ORIGINS="https://yourdomain.com,https://www.yourdomain.com" \
  yourusername/benchmark-platform:latest
```

### Docker Compose 部署

创建 `docker-compose.yml` 文件：

```yaml
version: '3.8'

services:
  benchmark-platform:
    image: yourusername/benchmark-platform:latest
    ports:
      - "3000:3000"
      - "8000:8000"
    environment:
      - DATABASE_URL=mysql://root:password@mysql:3306/benchmark
      - OAUTH_CLIENT_ID=your_oauth_client_id
      - OAUTH_CLIENT_SECRET=your_oauth_client_secret
      - OAUTH_CALLBACK_URL=http://localhost:8000/api/v1/auth/linuxdo/callback
    depends_on:
      - mysql
    networks:
      - app-network

  mysql:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=password
      - MYSQL_DATABASE=benchmark
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - app-network

networks:
  app-network:

volumes:
  mysql_data:
```

运行：

```bash
docker-compose up -d
```

## 📖 使用说明

### 1. 解析基准测试结果

在首页的大文本框中粘贴您的基准测试结果，格式如下：

```
=== System Information ===
  CPU             : AMD Ryzen 7 6800H with Radeon Graphics
  Cores_logical   : 16
  Memory          : 7.8 GB

[Phase 1] HMAC brute-force started
[Phase 1] Summary
  KEY_BITS        : 28 (key_space = 2^28 = 268435456)
  workers         : 16
  wall_time       : 64.642 s
  throughput      : 4,152,645 keys/s
  true_key_int    : 199716959 (0xBE7705F)
  success         : True
[Phase 1] finished in 64.643 s

[Phase 2] LLL float benchmark (short vector recovery) started
[Phase 2] Summary
  DIM_LLL         : 180
  workers         : 16
  reps_per_worker : 1
  total_attacks   : 16
  total_success   : 16
  wall_time       : 71.761 s
  avg_attack_time : 71.099638 s
  all_success     : True
[Phase 2] finished in 71.762 s

[Overall] total wall_time: 136.405 s
```

### 2. 确认结构化数据

系统会自动解析以下信息：

- **系统信息**: CPU 型号、核心数、内存大小
- **Phase 1**: HMAC 暴力破解耗时
- **Phase 2**: LLL 浮点基准测试耗时
- **总体信息**: 总执行时间

用户可以修改任何字段，确认无误后点击提交。

## 📂 项目结构

```
benchmark-platform/
├── src/
│   ├── views/
│   │   ├── Home.vue              # 首页 - 解析器
│   │   ├── ParseResult.vue       # 解析结果确认页
│   │   ├── Leaderboard.vue       # 排行榜页面
│   │   ├── BenchmarkDetail.vue  # 基准测试详情页
│   │   └── Upload.vue            # 上传页面
│   ├── App.vue                   # 主应用组件
│   └── main.js                   # 应用入口
├── backend/
│   ├── app_main.py              # FastAPI 主应用
│   ├── requirements.txt         # Python 依赖
│   └── init.sql                  # 数据库初始化脚本
├── Dockerfile                   # Docker 构建文件
├── docker-compose.yml          # Docker Compose 配置
├── index.html                   # HTML 模板
├── vite.config.js              # Vite 配置
└── package.json                # 项目配置
```

## 🎨 界面特色

- **渐变背景**: 紫色渐变营造科技感
- **毛玻璃效果**: 半透明卡片设计
- **响应式布局**: 适配桌面和移动端
- **平滑动画**: 按钮和输入框的交互动效

## 🔧 开发说明

### 构建生产版本

```bash
pnpm build
```

### 数据库初始化

容器启动时会自动检查数据库表是否存在，如果不存在会自动创建表结构。

### 日志查看

```bash
# 查看容器日志
docker logs benchmark-platform

# 实时查看日志
docker logs -f benchmark-platform
```

## 🐛 故障排除

### 常见问题

1. **数据库连接失败**
   - 检查 DATABASE_URL 格式是否正确
   - 确认数据库服务器是否可访问
   - 验证用户名和密码是否正确

2. **OAuth 认证失败**
   - 检查 OAUTH_CLIENT_ID 和 OAUTH_CLIENT_SECRET
   - 确认 OAUTH_CALLBACK_URL 与在 Linux.do 注册的回调地址一致

3. **前端无法访问**
   - 确认 3000 端口没有被占用
   - 检查防火墙设置

### 调试命令

```bash
# 进入容器调试
docker exec -it benchmark-platform /bin/bash

# 检查服务状态
docker ps

# 查看容器资源使用
docker stats benchmark-platform
```

## 🔄 API 文档

部署成功后，可以通过以下地址访问：

- **前端页面**: http://localhost:3000
- **API 文档**: http://localhost:8000/docs
- **API 服务**: http://localhost:8000

## 🐳 推送到 Docker Hub

```bash
# 1. 先登录 Docker Hub
docker login

# 2. 给镜像打标签（替换 yourusername 为你的 Docker Hub 用户名）
docker tag benchmark-platform yourusername/benchmark-platform:latest

# 3. 推送镜像
docker push yourusername/benchmark-platform:latest
```

## 📝 许可证

[请添加许可证信息]