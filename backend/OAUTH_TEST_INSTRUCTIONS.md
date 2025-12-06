# 🧪 linux.do OAuth 认证测试指南

## ✅ 测试环境状态

- **OAuth配置**: ✅ 已配置
  - Client ID: `YOUR_CLIENT_ID` (请从环境变量 `OAUTH_CLIENT_ID` 获取)
  - Client Secret: `YOUR_CLIENT_SECRET` (请从环境变量 `OAUTH_CLIENT_SECRET` 获取)
  - 回调URL: `http://localhost:8000/auth/callback`
  
  **注意**: 真实的 OAuth 凭据应存储在 `.env` 文件中，不要提交到版本控制系统。

- **测试服务器**: ✅ 运行中
  - URL: http://localhost:8000
  - API文档: http://localhost:8000/docs

## 🚀 测试步骤

### 1. 获取登录URL

```bash
curl http://localhost:8000/auth/login
```

这将返回一个包含授权URL的响应，例如：

```json
{
  "authorization_url": "https://linux.do/auth/oauth2_authorize?client_id=YOUR_CLIENT_ID&redirect_uri=http%3A%2F%2Flocalhost%3A8000%2Fauth%2Fcallback&response_type=code&scope=read&state=GENERATED_STATE",
  "state": "GENERATED_STATE",
  "redirect_uri": "http://localhost:8000/auth/callback"
}
```

### 2. 用户授权

1. **复制 `authorization_url`** 到浏览器中打开
2. **登录 linux.do** (如果尚未登录)
3. **点击"授权"** 允许应用访问你的基本信息
4. **重定向到回调URL**: `http://localhost:8000/auth/callback?code=xxx&state=xxx`

### 3. 查看认证结果

授权成功后，浏览器会显示类似这样的响应：

```json
{
  "success": true,
  "message": "认证成功",
  "user": {
    "id": 12345,
    "username": "your_linuxdo_username",
    "email": "your_email@example.com",
    "avatar_template": "https://linux.do/user_avatar/your_linuxdo_username/{size}/12345.png",
    "trust_level": 1
  },
  "token_info": {
    "token_type": "bearer",
    "scope": "read"
  }
}
```

## 🧪 手动测试令牌交换

如果需要手动测试令牌交换，可以使用：

```bash
curl -X POST http://localhost:8000/auth/exchange-code \
  -H "Content-Type: application/json" \
  -d '{"code": "YOUR_AUTHORIZATION_CODE_HERE"}'
```

## 📊 预期结果

成功的OAuth认证应该显示：

1. ✅ **用户信息获取成功**
   - 用户名
   - 用户ID (Discourse内部ID)
   - 邮箱地址
   - 头像URL
   - 信任等级

2. ✅ **令牌信息正确**
   - Token类型: `bearer`
   - Scope: `read`

## 🔍 故障排查

### 常见错误及解决方案

1. **"client_id 无效"**
   - 检查 Client ID 是否正确
   - 确认在 linux.do 后台注册的应用是否激活

2. **"redirect_uri 不匹配"**
   - 确认回调URL完全匹配注册时的设置
   - 注意协议 (http vs https)

3. **"access_denied"**
   - 用户拒绝了授权请求
   - 重新访问授权URL并同意授权

4. **网络错误**
   - 检查网络连接
   - 确认能够访问 linux.do

### 调试技巧

1. **查看服务器日志**:
   ```bash
   # 服务器正在运行中，查看控制台输出
   curl http://localhost:8000/logs
   ```

2. **检查回调URL参数**:
   - 确认 `code` 参数存在
   - 确认 `state` 参数与生成时一致

3. **验证配置**:
   ```bash
   curl http://localhost:8000/auth/config
   ```

## 📱 完整流程测试

1. **获取登录URL**: `GET /auth/login`
2. **用户授权**: 浏览器访问授权URL
3. **处理回调**: 自动重定向到 `/auth/callback`
4. **获取用户信息**: 系统自动调用 linux.do API
5. **显示结果**: 返回用户信息和令牌信息

## 🎯 成功标志

如果看到以下内容，说明OAuth认证配置正确：

- ✅ 授权URL能够正常生成
- ✅ 能够重定向到linux.do进行授权
- ✅ 授权后能够获取到用户信息
- ✅ 用户信息包含有效的用户名和ID

## 📞 下一步

OAuth认证测试成功后，我们可以：

1. **集成到完整系统**: 将认证服务集成到完整的FastAPI应用
2. **实现前端登录**: 在Vue.js前端实现登录按钮和用户状态管理
3. **保护API端点**: 使用JWT令牌保护基准测试提交等API

你现在可以访问授权URL进行测试！