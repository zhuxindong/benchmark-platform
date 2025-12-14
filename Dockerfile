# 基准测试评分平台 Dockerfile
FROM python:3.11-slim

# 设置工作目录
WORKDIR /app

# 更换为国内镜像源
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources && \
    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 复制requirements文件
COPY backend/requirements.txt .

# 配置pip国内源并安装Python依赖
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir \
    pymysql==1.1.0 \
    sqlalchemy==2.0.23 \
    fastapi==0.104.1 \
    uvicorn[standard]==0.24.0 \
    python-dotenv==1.0.0 \
    pydantic==2.4.2 \
    pydantic-settings==2.0.3 \
    python-multipart==0.0.6 \
    passlib[bcrypt]==1.7.4 \
    python-jose[cryptography]==3.3.0 \
    httpx==0.25.2 \
    mysql-connector-python==8.2.0 \
    loguru==0.7.2 \
    PyMySQL==1.1.0 \
    email-validator==2.1.0 \
    mysqlclient==2.2.0

# 复制后端代码
COPY backend/ ./backend/

# 复制前端代码
COPY src/ ./src/
COPY index.html ./
COPY vite.config.js ./
COPY package.json ./
COPY pnpm-lock.yaml ./

# 安装Node.js和pnpm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm config set registry https://registry.npmmirror.com && \
    npm install -g pnpm

# 安装前端依赖
RUN pnpm config set registry https://registry.npmmirror.com && \
    pnpm install --frozen-lockfile

# 环境变量
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# 暴露端口
EXPOSE 8000 3000

# 启动命令 - 同时启动前端开发服务器和后端API（完整功能版本）
CMD ["sh", "-c", "pnpm dev & python backend/app_main.py & wait"]