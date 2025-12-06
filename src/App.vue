<template>
  <div class="app">
    <nav class="navbar">
      <div class="nav-left">
        <h1>🚀 基准测试评分平台</h1>
      </div>
      <div class="nav-right">
        <div v-if="isLoggedIn" class="nav-actions">
          <button @click="handleUpload" class="upload-btn">
            📤 上传数据
          </button>
          <div class="user-menu">
            <img
              :src="currentUser?.avatar_url || `https://ui-avatars.com/api/?name=${currentUser?.username || 'User'}&background=667eea&color=fff&size=120`"
              :alt="currentUser?.username"
              class="avatar"
              @error="handleAvatarError"
            />
            <div class="user-info">
              <span class="username">{{ currentUser?.username }}</span>
              <button @click="handleLogout" class="logout-btn">登出</button>
            </div>
          </div>
        </div>
        <div v-else class="auth-buttons">
          <button @click="handleUpload" class="upload-btn">
            📤 上传数据
          </button>
        </div>
      </div>
    </nav>
    <main class="main-content">
      <router-view />
    </main>

    <!-- 认证加载状态 -->
    <div v-if="authState.loading" class="auth-overlay">
      <div class="auth-loading">
        <div class="spinner"></div>
        <p>正在验证...</p>
      </div>
    </div>

    <!-- 认证错误提示 -->
    <div v-if="authState.error" class="auth-error-toast">
      <div class="toast-content">
        <span class="error-icon">⚠️</span>
        <span>{{ authState.error }}</span>
        <button @click="clearError" class="close-btn">✕</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { authState, authActions, initializeAuth } from './stores/auth.js'

const router = useRouter()

// 计算属性
const isLoggedIn = computed(() => authState.isAuthenticated)
const currentUser = computed(() => authState.user)
const authError = computed(() => authState.error)

onMounted(() => {
  // 初始化认证状态
  initializeAuth()

  // 检查当前路由是否包含OAuth回调参数
  if (window.location.search.includes('code=')) {
    router.push('/oauth/callback')
  }
})

// 处理登录
const handleLogin = async () => {
  try {
    await authActions.startOAuthLogin()
  } catch (error) {
    console.error('登录失败:', error)
  }
}

// 处理登出
const handleLogout = async () => {
  try {
    await authActions.logout()
    router.push('/')
  } catch (error) {
    console.error('登出失败:', error)
  }
}

// 清除错误
const clearError = () => {
  authActions.clearError()
}

// 处理头像加载错误
const handleAvatarError = (event) => {
  // 如果图片加载失败，设置为纯色背景
  event.target.style.display = 'none'
  const parent = event.target.parentElement
  if (parent && !parent.querySelector('.avatar-fallback')) {
    const fallback = document.createElement('div')
    fallback.className = 'avatar-fallback'
    fallback.style.cssText = `
      width: 40px;
      height: 40px;
      border-radius: 50%;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-weight: bold;
      font-size: 14px;
      border: 2px solid #667eea;
    `
    fallback.textContent = (currentUser.value?.username || 'U').charAt(0).toUpperCase()
    parent.insertBefore(fallback, event.target)
  }
}

// 处理上传按钮点击
const handleUpload = async () => {
  // 检查用户是否已登录
  if (!authState.isAuthenticated) {
    // 如果未登录，跳转到OAuth登录
    try {
      await authActions.startOAuthLogin()
    } catch (error) {
      console.error('登录失败:', error)
    }
  } else {
    // 如果已登录，直接跳转到上传页面
    router.push('/upload')
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
}

.app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.navbar {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  padding: 1rem 2rem;
  box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.nav-left h1 {
  color: #333;
  font-size: 1.5rem;
  margin: 0;
}

.nav-right {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.nav-actions {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.upload-btn {
  background: linear-gradient(135deg, #51cf66 0%, #40c057 100%);
  color: white;
  border: none;
  padding: 0.8rem 1.5rem;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(81, 207, 102, 0.3);
}

.upload-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(81, 207, 102, 0.4);
}

.user-menu {
  display: flex;
  align-items: center;
  gap: 0.8rem;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #667eea;
}

.user-info {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 0.3rem;
}

.username {
  font-size: 0.9rem;
  color: #333;
  font-weight: 600;
}

.logout-btn {
  background: #ff6b6b;
  color: white;
  border: none;
  padding: 0.3rem 0.8rem;
  border-radius: 15px;
  font-size: 0.8rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.logout-btn:hover {
  background: #ff5252;
}

.auth-buttons {
  display: flex;
  gap: 1rem;
}

.login-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 0.8rem 2rem;
  border-radius: 25px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.login-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.main-content {
  flex: 1;
  padding: 2rem;
}

.auth-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.auth-loading {
  background: rgba(255, 255, 255, 0.95);
  padding: 2rem;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.auth-loading .spinner {
  width: 32px;
  height: 32px;
  border: 3px solid #f3f3f3;
  border-top: 3px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.auth-error-toast {
  position: fixed;
  top: 80px;
  right: 20px;
  background: #ff6b6b;
  color: white;
  padding: 1rem 1.5rem;
  border-radius: 8px;
  box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
  z-index: 1001;
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

.toast-content {
  display: flex;
  align-items: center;
  gap: 0.8rem;
}

.close-btn {
  background: none;
  border: none;
  color: white;
  font-size: 1.2rem;
  cursor: pointer;
  padding: 0;
  margin: 0;
  line-height: 1;
}

@media (max-width: 768px) {
  .navbar {
    padding: 1rem;
    flex-direction: column;
    gap: 1rem;
  }

  .nav-left h1 {
    font-size: 1.3rem;
  }

  .username {
    font-size: 0.8rem;
  }

  .main-content {
    padding: 1rem;
  }

  .auth-error-toast {
    right: 10px;
    left: 10px;
    width: calc(100% - 20px);
  }
}
</style>