<template>
  <div class="oauth-callback">
    <div class="container">
      <div class="callback-card">
        <div v-if="processing" class="processing">
          <div class="spinner"></div>
          <h2>正在处理登录...</h2>
          <p>请稍候，正在验证您的授权信息</p>
        </div>

        <div v-else-if="error" class="error">
          <div class="error-icon">❌</div>
          <h2>登录失败</h2>
          <p>{{ error }}</p>
          <button @click="goToHome" class="retry-button">返回首页</button>
        </div>

        <div v-else-if="success" class="success">
          <div class="success-icon">✅</div>
          <h2>登录成功！</h2>
          <p>欢迎回来，{{ user?.username }}</p>
          <div v-if="redirecting" class="redirecting">
            <div class="spinner"></div>
            <p>正在跳转...</p>
          </div>
          <button v-else @click="checkAndRedirect" class="continue-button">继续</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { authState, handleOAuthCallback } from '../stores/auth.js'
import apiService from '../services/api.js'

const router = useRouter()
const processing = ref(true)
const error = ref(null)
const success = ref(false)
const user = ref(null)
const redirecting = ref(false)

onMounted(async () => {
  try {
    // 处理OAuth回调
    const result = await handleOAuthCallback()

    if (result && result.success) {
      processing.value = false
      success.value = true
      user.value = result.user

      // 2秒后开始检查并重定向
      setTimeout(() => {
        checkAndRedirect()
      }, 2000)
    } else {
      processing.value = false
      error.value = result?.error || '登录失败'
    }
  } catch (err) {
    processing.value = false
    error.value = err.message || '处理登录回调时发生错误'
    console.error('OAuth回调处理失败:', err)
  }
})

const checkAndRedirect = async () => {
  try {
    redirecting.value = true

    // 清理URL中的OAuth参数，避免影响后续页面
    window.history.replaceState({}, document.title, window.location.pathname)

    // 检查用户是否已有基准测试结果
    const response = await apiService.get('/benchmarks/my-result')

    if (response.success) {
      if (response.data) {
        // 用户已有结果，跳转到详情页
        router.push('/detail')
      } else {
        // 用户没有结果，跳转到上传页面
        router.push('/upload')
      }
    } else {
      // API调用失败，默认跳转到上传页面
      router.push('/upload')
    }
  } catch (error) {
    console.error('检查用户状态失败:', error)
    // 出错时默认跳转到上传页面
    router.push('/upload')
  }
}

const goToHome = () => {
  router.push('/')
}
</script>

<style scoped>
/* ========================================
    OAuth Callback - Apple Design System
   ======================================== */

.oauth-callback {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 24px;
  background: var(--bg-body); /* Global light gray */
}

.container {
  width: 100%;
  max-width: 440px;
}

.callback-card {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  padding: 48px 32px;
  box-shadow: var(--shadow-sm);
  border: 1px solid rgba(0,0,0,0.05);
  text-align: center;
  backdrop-filter: none;
}

.processing, .error, .success {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
}

/* Spinner */
.spinner {
  width: 48px;
  height: 48px;
  border: 4px solid #E5E5EA;
  border-top: 4px solid var(--color-blue);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }

/* Icons */
.error-icon, .success-icon {
  font-size: 56px;
  line-height: 1;
  margin-bottom: 8px;
}

h2 {
  color: var(--text-primary);
  font-size: 24px;
  font-weight: 700;
  margin: 0;
  letter-spacing: -0.01em;
}

p {
  color: var(--text-secondary);
  font-size: 16px;
  margin: 0;
  line-height: 1.5;
}

/* Buttons */
.retry-button {
  background: #E5E5EA;
  color: var(--text-primary);
  border: none;
  padding: 12px 32px;
  border-radius: 999px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.retry-button:hover {
  background: #D1D1D6;
}

.continue-button {
  background: var(--color-blue);
  color: white;
  border: none;
  padding: 12px 40px;
  border-radius: 999px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.continue-button:hover {
  background: var(--color-blue-hover);
  transform: scale(1.02);
}

@media (max-width: 600px) {
  .callback-card {
    padding: 40px 24px;
  }
}
</style>
