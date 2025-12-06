# 📋 linux.do OAuth 认证配置指南

## 🔍 认证系统概述

本系统集成了 linux.do OAuth2 认证，基于标准的 Discourse 论坛 OAuth2 实现。用户可以通过其 linux.do 账号登录我们的基准测试平台。

## 🚀 配置步骤

### 1. 在 linux.do 注册 OAuth 应用

首先需要在 linux.do 社区注册一个 OAuth 应用：

1. **访问 linux.do 管理后台**
   - 登录你的 linux.do 管理员账号
   - 访问：`https://linux.do/admin` 或相应的管理路径

2. **创建 OAuth 应用**
   - 找到 "API" 或 "OAuth" 相关设置
   - 创建新的 OAuth 应用
   - 填写应用信息：
     - **应用名称**: 基准测试评分平台
     - **应用描述**: 用于展示和排名基准测试结果的平台
     - **回调URL**: `http://localhost:8000/api/v1/auth/linuxdo/callback`
     - **权限范围**: `read` (读取用户基本信息)

3. **获取客户端凭据**
   - 记录 `Client ID` 和 `Client Secret`

### 2. 配置环境变量

将获取的凭据配置到 `.env` 文件中：

```bash
# linux.do OAuth配置
LINUXDO_CLIENT_ID=your-linuxdo-client-id
LINUXDO_CLIENT_SECRET=your-linuxdo-client-secret
LINUXDO_REDIRECT_URI=http://localhost:8000/api/v1/auth/linuxdo/callback
```

### 3. 重启应用

配置完成后重启后端应用：

```bash
cd backend
python main.py
```

## 🔧 OAuth 端点

本系统使用以下标准的 Discourse OAuth2 端点：

- **授权URL**: `https://linux.do/auth/oauth2_authorize`
- **令牌URL**: `https://linux.do/auth/oauth2_token`
- **用户信息URL**: `https://linux.do/api/u/me.json`

## 📱 API 使用流程

### 1. 获取登录URL

```http
GET /api/v1/auth/login
```

响应：
```json
{
  "authorization_url": "https://linux.do/auth/oauth2_authorize?...",
  "state": "random_state_string"
}
```

### 2. 用户授权

用户访问授权URL，在 linux.do 上确认授权。

### 3. 处理回调

```http
GET /api/v1/auth/linuxdo/callback?code=xxx&state=xxx
```

或

```http
POST /api/v1/auth/linuxdo/callback
Content-Type: application/json

{
  "code": "authorization_code",
  "state": "random_state_string"
}
```

响应：
```json
{
  "success": true,
  "message": "登录成功",
  "access_token": "jwt_token_here",
  "token_type": "bearer",
  "user": {
    "id": 1,
    "username": "linuxdo_username",
    "user_id": "discourse_user_id",
    "email": "user@example.com",
    "avatar_url": "https://linux.do/...",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### 4. 使用令牌

在受保护的 API 请求中包含令牌：

```http
Authorization: Bearer jwt_token_here
```

## 🛡️ 受保护的API

以下 API 需要用户认证：

- `POST /api/v1/benchmarks/submit` - 提交基准测试结果
- `GET /api/v1/benchmarks/my-results` - 获取我的结果
- `PUT /api/v1/benchmarks/{id}` - 更新结果
- `DELETE /api/v1/benchmarks/{id}` - 删除结果
- `GET /api/v1/users/me` - 获取用户信息
- `GET /api/v1/users/profile` - 获取用户档案

## 🔍 令牌验证

验证当前令牌是否有效：

```http
GET /api/v1/auth/verify-token
Authorization: Bearer jwt_token_here
```

## 🚪 登出

```http
POST /api/v1/auth/logout
```

（客户端需要删除存储的令牌）

## ⚠️ 注意事项

1. **生产环境配置**
   - 确保回调URL是可访问的公网地址
   - 使用 HTTPS 而不是 HTTP
   - 定期轮换客户端密钥

2. **安全考虑**
   - 令牌有效期：30分钟（可配置）
   - 每个用户最多10个基准测试结果
   - 所有API请求都有速率限制

3. **调试模式**
   - 开发环境下可以使用临时的测试凭据
   - 查看日志文件获取详细的认证信息

## 🐛 故障排查

### 常见错误

1. **"linux.do OAuth 未配置"**
   - 检查 `.env` 文件中的 `LINUXDO_CLIENT_ID` 是否设置

2. **"获取访问令牌失败"**
   - 验证客户端密钥是否正确
   - 检查回调URL是否匹配注册的应用

3. **"获取用户信息失败"**
   - 确认用户已在 linux.do 授权
   - 检查网络连接和防火墙设置

### 日志位置

认证相关的日志记录在：
- 控制台输出
- `logs/app.log`
- `logs/error.log`

## 📞 技术支持

如果遇到问题：

1. 查看 linux.do 的官方文档
2. 检查 Discourse OAuth2 配置指南
3. 联系开发团队获取支持

## 🔗 相关链接

- [Discourse OAuth2 文档](https://meta.discourse.org/t/discourse-oauth2/25645)
- [linux.do 社区](https://linux.do)
- [FastAPI OAuth2 指南](https://fastapi.tiangolo.com/tutorial/security/oauth2-jwt/)