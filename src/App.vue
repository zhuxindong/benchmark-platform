<template>
  <div class="app">
    <nav class="navbar">
      <div class="navbar-content">
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
            <button v-if="isMockLoginEnabled" @click="handleMockLogin" class="mock-login-btn" title="本地测试用Mock登录">
              🧪 Mock登录
            </button>
            <button @click="handleUpload" class="upload-btn">
              📤 上传数据
            </button>
          </div>
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

// Mock登录开关 - 从环境变量读取
const isMockLoginEnabled = computed(() => {
  return import.meta.env.VITE_ENABLE_MOCK_LOGIN === 'true'
})

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

// 处理Mock登录
const handleMockLogin = async () => {
  const username = prompt('请输入用户名（用于本地测试）:', 'test_user')
  if (!username) return
  
  const email = prompt('请输入邮箱（可选）:', 'test@example.com')
  
  try {
    const result = await authActions.mockLogin(username, email)
    if (result.success) {
      console.log('Mock登录成功:', result.user)
      // 可以选择跳转到首页或刷新
      router.push('/')
    }
  } catch (error) {
    console.error('Mock登录失败:', error)
  }
}
</script>

<style>
/* ========================================
    Apple Design System v2.0
   ======================================== */

:root {
  /* Colors */
  --bg-body: #F5F5F7;
  --bg-card: #FFFFFF;
  --bg-primary: #FFFFFF;
  
  /* Typography Colors */
  --text-primary: #1D1D1F;    /* Almost Black */
  --text-secondary: #86868B;  /* Apple Gray */
  --text-tertiary: #6E6E73;
  --text-link: #0066CC;       /* Classic Apple Blue */
  
  /* System Colors */
  --color-blue: #0071E3;      /* Apple Interaction Blue */
  --color-blue-hover: #0077ED;
  --color-green: #34C759;
  --color-red: #FF3B30;
  --color-orange: #FF9500;
  --color-gray: #E8E8ED;
  
  /* Borders & Dividers */
  --border-light: rgba(0, 0, 0, 0.08);
  --border-subtle: rgba(0, 0, 0, 0.04);
  
  /* Shadows (Super Smooth) */
  --shadow-sm: 0 2px 5px rgba(0, 0, 0, 0.02), 0 0 1px rgba(0,0,0,0.06);
  --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.06), 0 0 1px rgba(0,0,0,0.06);
  --shadow-lg: 0 12px 24px rgba(0, 0, 0, 0.08), 0 0 1px rgba(0,0,0,0.06);
  
  /* Layout */
  --nav-height: 52px;
  --max-width: 980px;         /* Apple standard content width */
  --radius-sm: 8px;
  --radius-md: 12px;
  --radius-lg: 18px;          /* Premium card radius */
  --radius-full: 9999px;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

body {
  background-color: var(--bg-body);
  color: var(--text-primary);
  line-height: 1.47059;
  font-weight: 400;
  min-height: 100vh;
}

.app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* ========================================
   Premium Navigation Bar
   ======================================== */

/* ========================================
   Premium Navigation Bar
   ======================================== */

.navbar {
  height: var(--nav-height);
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border-bottom: 1px solid rgba(0, 0, 0, 0.08);
  position: sticky;
  top: 0;
  z-index: 9999;
}

.navbar-content {
  max-width: 1400px; /* Increased wide screen support */
  margin: 0 auto;
  height: 100%;
  padding: 0 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.nav-left h1 {
  font-size: 17px;
  font-weight: 600;
  color: var(--text-primary);
  display: flex;
  align-items: center;
  gap: 8px;
  letter-spacing: -0.01em;
}

.nav-right, .nav-actions, .auth-buttons {
  display: flex;
  align-items: center;
  gap: 16px; /* Consistent gap */
}

/* Optimized Buttons */
.upload-btn {
  background: var(--color-blue);
  color: white;
  padding: 6px 14px;
  border-radius: 100px;
  font-size: 13px;
  font-weight: 500;
  height: 30px;
  line-height: Icon;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: all 0.2s cubic-bezier(0.25, 0.1, 0.25, 1);
}

.upload-btn:hover {
  background: var(--color-blue-hover);
  transform: translateY(-0.5px);
  box-shadow: 0 2px 8px rgba(0, 113, 227, 0.2);
}

.mock-login-btn {
  font-size: 13px;
  font-weight: 500;
  color: var(--text-primary);
  padding: 6px 14px;
  background: rgba(0,0,0,0.04);
  border-radius: 100px;
  height: 30px;
  display: flex;
  align-items: center;
  transition: background 0.2s;
}

.mock-login-btn:hover {
  background: rgba(0,0,0,0.08);
}

/* User Menu - Compact Horizontal Layout */
.user-menu {
  display: flex;
  align-items: center;
  gap: 12px;
  padding-left: 12px;
  border-left: 1px solid rgba(0,0,0,0.1);
  margin-left: 4px;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: default;
}

.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  object-fit: cover;
  box-shadow: 0 0 0 1px rgba(0,0,0,0.05);
}

.user-info {
  display: flex;
  flex-direction: column;
  justify-content: center;
  line-height: 1.1;
}

.username {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-primary);
}

.logout-link {
  font-size: 11px;
  color: var(--text-tertiary);
  background: none;
  border: none;
  padding: 0;
  cursor: pointer;
  text-align: left;
}

.logout-link:hover {
  color: var(--color-red);
  text-decoration: underline;
}

/* Responsive */
@media (max-width: 768px) {
  .navbar-content {
    padding: 0 16px;
  }
  
  .user-menu {
    border-left: none;
    padding-left: 0;
  }
  
  .username, .logout-link span {
    display: none;
  }
}

/* ========================================
   Refined Buttons
   ======================================== */

button {
  border: none;
  background: none;
  cursor: pointer;
  font-family: inherit;
}

/* Primary Button (Pill Shape) */
.btn-primary {
  background: var(--color-blue);
  color: white;
  padding: 6px 16px;
  font-size: 13px;
  font-weight: 500;
  border-radius: var(--radius-full);
  transition: all 0.2s ease;
}

.btn-primary:hover {
  background: var(--color-blue-hover);
}

.btn-primary:active {
  transform: scale(0.98);
}

/* Secondary Button (Gray) */
.btn-secondary {
  background: rgba(0, 0, 0, 0.05);
  color: var(--text-primary);
  padding: 6px 16px;
  font-size: 13px;
  font-weight: 500;
  border-radius: var(--radius-full);
  transition: all 0.2s ease;
}

.btn-secondary:hover {
  background: rgba(0, 0, 0, 0.1);
}

/* Link Style Button */
.btn-link {
  color: var(--text-link);
  font-size: 13px;
  font-weight: 400;
}

.btn-link:hover {
  text-decoration: underline;
}

/* ========================================
   Specific App Buttons
   ======================================== */

.upload-btn {
  background: var(--color-blue);
  color: white;
  padding: 6px 16px;
  border-radius: var(--radius-full);
  font-size: 13px;
  font-weight: 500;
  transition: all 0.2s;
}

.upload-btn:hover {
  background: var(--color-blue-hover);
}

.login-btn {
  color: white;
  background: #111;
  padding: 6px 16px;
  border-radius: var(--radius-full);
  font-size: 13px;
}

.mock-login-btn {
  color: var(--text-primary);
  font-size: 13px;
  background: #F5F5F7;
  padding: 6px 16px;
  border-radius: var(--radius-full);
  border: 1px solid rgba(0,0,0,0.1);
}

.mock-login-btn:hover {
  background: #E8E8ED;
}

/* ========================================
   User Menu
   ======================================== */

.user-menu {
  display: flex;
  align-items: center;
  gap: 12px;
}

.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  object-fit: cover;
  border: 1px solid rgba(0,0,0,0.1);
  cursor: pointer;
}

.user-info {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 0;
}

.username {
  font-size: 13px;
  font-weight: 500;
  color: var(--text-primary);
}

.logout-btn {
  font-size: 11px;
  color: var(--text-tertiary);
  margin-top: 1px;
}

.logout-btn:hover {
  color: var(--color-red);
}

/* ========================================
   Layout Helpers
   ======================================== */

.main-content {
  flex: 1;
  width: 100%;
  max-width: var(--max-width);
  margin: 0 auto;
  padding: 40px 22px;
}

/* ========================================
   Toast & Modal
   ======================================== */

.auth-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(50, 50, 50, 0.4);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 10000;
}

.auth-loading {
  background: rgba(255, 255, 255, 0.9);
  padding: 32px 48px;
  border-radius: var(--radius-lg);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  box-shadow: 0 20px 40px rgba(0,0,0,0.2);
}

.spinner {
  width: 32px;
  height: 32px;
  border: 3px solid rgba(0,0,0,0.1);
  border-top: 3px solid var(--text-primary);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }

/* Mobile */
@media (max-width: 768px) {
  .navbar-content {
    padding: 0 16px;
  }
}
</style>
