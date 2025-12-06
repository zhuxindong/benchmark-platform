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
.oauth-callback {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.container {
  width: 100%;
  max-width: 500px;
}

.callback-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  padding: 3rem 2rem;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  border: 1px solid rgba(255, 255, 255, 0.2);
  text-align: center;
}

.processing, .error, .success {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-icon, .success-icon {
  font-size: 4rem;
  line-height: 1;
}

h2 {
  color: #333;
  font-size: 1.5rem;
  margin: 0;
}

p {
  color: #666;
  font-size: 1.1rem;
  margin: 0;
  max-width: 300px;
  line-height: 1.5;
}

.retry-button {
  background: #ff6b6b;
  color: white;
  border: none;
  padding: 0.8rem 2rem;
  border-radius: 25px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.retry-button:hover {
  background: #ff5252;
  transform: translateY(-2px);
}

.continue-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 0.8rem 2rem;
  border-radius: 25px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
}

.continue-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 15px 40px rgba(102, 126, 234, 0.4);
}

@media (max-width: 600px) {
  .callback-card {
    margin: 0 1rem;
    padding: 2rem 1.5rem;
  }

  h2 {
    font-size: 1.3rem;
  }

  p {
    font-size: 1rem;
  }
}
</style>