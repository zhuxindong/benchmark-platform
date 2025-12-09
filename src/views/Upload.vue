<template>
  <div class="upload">
    <div class="container">
      <!-- 用户信息 -->
      <div v-if="currentUser" class="user-info">
        <div class="user-card">
          <img
            :src="currentUser.avatar_url || `https://ui-avatars.com/api/?name=${currentUser.username}&background=667eea&color=fff&size=120`"
            :alt="currentUser.username"
            class="user-avatar"
            @error="handleAvatarError"
          />
          <div class="user-details">
            <h3>{{ currentUser.username }}</h3>
            <p>上传基准测试结果</p>
          </div>
          <div class="user-actions">
            <button @click="goToDetail" class="detail-btn">查看我的结果</button>
            <button @click="goHome" class="home-btn">返回首页</button>
          </div>
        </div>
      </div>

      <div class="parse-card">
        <div class="card-header">
          <h2>📊 基准测试结果解析</h2>
          <p>请粘贴您的基准测试结果文本，系统将自动解析并在下一步确认后上传到排行榜</p>
        </div>

        <div class="input-section">
          <label for="benchmark-input">基准测试结果：</label>
          <textarea
            id="benchmark-input"
            v-model="benchmarkText"
            placeholder="请粘贴基准测试结果文本..."
            rows="15"
            class="benchmark-textarea"
          ></textarea>
        </div>

        <div class="button-section">
          <button
            @click="parseBenchmark"
            :disabled="!benchmarkText.trim()"
            class="parse-button"
            :class="{ disabled: !benchmarkText.trim() }"
          >
            <span v-if="!isParsing">🔍 解析数据</span>
            <span v-else>⏳ 解析中...</span>
          </button>
        </div>

        <div v-if="error" class="error-message">
          ❌ {{ error }}
        </div>

        <div v-if="success" class="success-message">
          ✅ {{ success }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { authState } from '../stores/auth.js'
import apiService from '../services/api.js'

const router = useRouter()
const route = useRoute()
const benchmarkText = ref('')
const isParsing = ref(false)
const error = ref('')
const success = ref('')
const currentUser = computed(() => authState.user)

onMounted(() => {
  // 检查用户是否已登录
  if (!authState.isAuthenticated) {
    // 如果未登录，跳转到首页触发登录
    router.push('/')
    return
  }

  // 如果从确认页面返回，恢复原始文本
  if (route.query.text) {
    benchmarkText.value = decodeURIComponent(route.query.text)
  }
})

const parseBenchmark = async () => {
  try {
    isParsing.value = true
    error.value = ''
    success.value = ''

    // 首先解析文本
    const parseResponse = await apiService.post('/benchmarks/parse', {
      text: benchmarkText.value
    })

    if (!parseResponse.success) {
      throw new Error(parseResponse.message || '解析失败')
    }

    const parsedData = parseResponse.data

    // 跳转到确认页面，传递解析数据和原始文本
    router.push({
      path: '/confirm',
      query: {
        data: encodeURIComponent(JSON.stringify(parsedData)),
        text: encodeURIComponent(benchmarkText.value)
      }
    })

  } catch (err) {
    console.error('解析失败:', err)
    error.value = err.message || '解析失败，请检查输入格式'
  } finally {
    isParsing.value = false
  }
}

const goToDetail = () => {
  router.push('/detail')
}

const goHome = () => {
  router.push('/')
}

const handleAvatarError = (event) => {
  // 隐藏失败的图片，创建回退头像
  event.target.style.display = 'none'
  const parent = event.target.parentElement
  if (parent && !parent.querySelector('.avatar-fallback')) {
    const fallback = document.createElement('div')
    fallback.className = 'avatar-fallback'
    fallback.style.cssText = `
      width: 60px;
      height: 60px;
      border-radius: 50%;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-weight: bold;
      font-size: 20px;
      border: 3px solid #667eea;
      flex-shrink: 0;
    `
    fallback.textContent = (currentUser.value?.username || 'U').charAt(0).toUpperCase()
    parent.insertBefore(fallback, event.target)
  }
}
</script>

<style scoped>
/* ========================================
   🍎 Apple-Style Upload Page
   ======================================== */

.upload {
  min-height: 100vh;
  padding: 48px 0;
  background: #F5F5F7;
}

.container {
  max-width: 800px;
  margin: 0 auto;
  padding: 0 24px;
}

/* User Info Card */
.user-info {
  margin-bottom: 24px;
}

.user-card {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  border: 1px solid #E5E5EA;
}

.user-avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #E5E5EA;
}

.user-details {
  flex: 1;
}

.user-details h3 {
  margin: 0 0 6px 0;
  color: #1D1D1F;
  font-size: 21px;
  font-weight: 700;
}

.user-details p {
  margin: 0;
  color: #6E6E73;
  font-size: 15px;
  font-weight: 500;
}

.user-actions {
  display: flex;
  gap: 12px;
}

.detail-btn, .home-btn {
  background: #007AFF;
  color: #FFFFFF;
  border: none;
  padding: 10px 20px;
  border-radius: 10px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 2px 8px rgba(0, 122, 255, 0.3);
}

.detail-btn:hover, .home-btn:hover {
  background: #0051D5;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.4);
}

/* Parse Card */
.parse-card {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  border: 1px solid #E5E5EA;
}

.card-header {
  text-align: center;
  margin-bottom: 32px;
}

.card-header h2 {
  color: #1D1D1F;
  font-size: 32px;
  margin-bottom: 12px;
  font-weight: 700;
  letter-spacing: -0.5px;
}

.card-header p {
  color: #6E6E73;
  font-size: 17px;
  line-height: 1.5;
  font-weight: 400;
}

/* Input Section */
.input-section {
  margin-bottom: 24px;
}

.input-section label {
  display: block;
  font-weight: 600;
  color: #1D1D1F;
  margin-bottom: 12px;
  font-size: 17px;
}

.benchmark-textarea {
  width: 100%;
  padding: 16px;
  border: 1px solid #E5E5EA;
  border-radius: 12px;
  font-size: 15px;
  font-family: 'SF Mono', 'Monaco', 'Consolas', monospace;
  line-height: 1.6;
  resize: vertical;
  transition: all 0.2s ease;
  background: #FAFAFA;
  color: #1D1D1F;
}

.benchmark-textarea::placeholder {
  color: #86868B;
}

.benchmark-textarea:focus {
  outline: none;
  border-color: #007AFF;
  box-shadow: 0 0 0 4px rgba(0, 122, 255, 0.1);
  background: #FFFFFF;
}

/* Button Section */
.button-section {
  text-align: center;
  margin-bottom: 24px;
}

.parse-button {
  background: #007AFF;
  color: #FFFFFF;
  border: none;
  padding: 14px 48px;
  border-radius: 12px;
  font-size: 17px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 16px rgba(0, 122, 255, 0.3);
  min-width: 200px;
}

.parse-button:hover:not(.disabled) {
  background: #0051D5;
  transform: translateY(-1px);
  box-shadow: 0 6px 20px rgba(0, 122, 255, 0.4);
}

.parse-button:active:not(.disabled) {
  transform: translateY(0);
}

.parse-button.disabled {
  opacity: 0.4;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

/* Messages */
.error-message {
  background: #FF3B30;
  color: #FFFFFF;
  padding: 16px 20px;
  border-radius: 12px;
  text-align: center;
  font-weight: 600;
  font-size: 15px;
  box-shadow: 0 4px 16px rgba(255, 59, 48, 0.3);
}

.success-message {
  background: #34C759;
  color: #FFFFFF;
  padding: 16px 20px;
  border-radius: 12px;
  text-align: center;
  font-weight: 600;
  font-size: 15px;
  box-shadow: 0 4px 16px rgba(52, 199, 89, 0.3);
}

/* Responsive */
@media (max-width: 768px) {
  .upload {
    padding: 24px 0;
  }

  .container {
    padding: 0 16px;
  }

  .user-card {
    flex-direction: column;
    text-align: center;
    padding: 24px 20px;
  }

  .user-actions {
    width: 100%;
    flex-direction: column;
  }

  .detail-btn, .home-btn {
    width: 100%;
  }

  .parse-card {
    padding: 24px 20px;
  }

  .card-header h2 {
    font-size: 28px;
  }

  .benchmark-textarea {
    padding: 14px;
    font-size: 14px;
  }

  .parse-button {
    width: 100%;
  }
}
</style>
.upload {
  min-height: 100vh;
  padding: 2rem 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
