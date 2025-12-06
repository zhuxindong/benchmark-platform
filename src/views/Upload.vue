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
.upload {
  min-height: 100vh;
  padding: 2rem 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.container {
  max-width: 800px;
  margin: 0 auto;
  padding: 0 1rem;
}

.user-info {
  margin-bottom: 2rem;
}

.user-card {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1.5rem;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
}

.user-avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid #667eea;
}

.user-details {
  flex: 1;
}

.user-details h3 {
  margin: 0 0 0.3rem 0;
  color: #333;
  font-size: 1.4rem;
}

.user-details p {
  margin: 0;
  color: #666;
  font-size: 1rem;
}

.user-actions {
  display: flex;
  gap: 1rem;
}

.detail-btn, .home-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 0.8rem 1.5rem;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.detail-btn:hover, .home-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
}

.parse-card {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  padding: 2.5rem;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.card-header {
  text-align: center;
  margin-bottom: 2.5rem;
}

.card-header h2 {
  color: #333;
  font-size: 2rem;
  margin-bottom: 0.8rem;
  font-weight: 700;
}

.card-header p {
  color: #666;
  font-size: 1.1rem;
  line-height: 1.6;
}

.input-section {
  margin-bottom: 2rem;
}

.input-section label {
  display: block;
  font-weight: 600;
  color: #333;
  margin-bottom: 0.8rem;
  font-size: 1.1rem;
}

.benchmark-textarea {
  width: 100%;
  padding: 1.2rem;
  border: 2px solid #e1e5e9;
  border-radius: 12px;
  font-size: 1rem;
  font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
  line-height: 1.6;
  resize: vertical;
  transition: all 0.3s ease;
  background: #f8f9fa;
}

.benchmark-textarea:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
  background: white;
}

.button-section {
  text-align: center;
  margin-bottom: 1.5rem;
}

.parse-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 1rem 3rem;
  border-radius: 25px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
  min-width: 200px;
}

.parse-button:hover:not(.disabled) {
  transform: translateY(-2px);
  box-shadow: 0 15px 40px rgba(102, 126, 234, 0.4);
}

.parse-button.disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.error-message {
  background: #ff6b6b;
  color: white;
  padding: 1rem;
  border-radius: 12px;
  text-align: center;
  font-weight: 600;
  box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
}

.success-message {
  background: #51cf66;
  color: white;
  padding: 1rem;
  border-radius: 12px;
  text-align: center;
  font-weight: 600;
  box-shadow: 0 4px 15px rgba(81, 207, 102, 0.3);
}

@media (max-width: 768px) {
  .user-card {
    flex-direction: column;
    text-align: center;
  }

  .user-actions {
    width: 100%;
    justify-content: center;
  }

  .parse-card {
    padding: 2rem 1.5rem;
  }

  .card-header h2 {
    font-size: 1.8rem;
  }

  .benchmark-textarea {
    padding: 1rem;
  }

  .parse-button {
    width: 100%;
  }
}
</style>