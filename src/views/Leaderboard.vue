<template>
  <div class="leaderboard">
    <div class="container">
      <div class="header">
        <h1>🏆 基准测试排行榜</h1>
        <p>展示最快的基准测试结果，按总耗时排序</p>

        <!-- 设备类型选择器 -->
        <div class="device-type-selector">
          <label class="selector-label">设备类型：</label>
          <div class="device-type-buttons">
            <button
              @click="selectDeviceType(null)"
              :class="['device-btn', { active: selectedDeviceType === null }]"
            >
              全部
            </button>
            <button
              @click="selectDeviceType('server')"
              :class="['device-btn', { active: selectedDeviceType === 'server' }]"
            >
              服务器级
            </button>
            <button
              @click="selectDeviceType('consumer')"
              :class="['device-btn', { active: selectedDeviceType === 'consumer' }]"
            >
              消费级
            </button>
          </div>
        </div>
      </div>

      <div v-if="loading" class="loading">
        <div class="spinner"></div>
        <p>正在加载排行榜数据...</p>
      </div>

      <div v-else-if="error" class="error">
        <div class="error-icon">❌</div>
        <h2>加载失败</h2>
        <p>{{ error }}</p>
        <button @click="loadLeaderboard" class="retry-button">重试</button>
      </div>

      <div v-else-if="leaderboard.length === 0" class="empty">
        <div class="empty-icon">📊</div>
        <h2>暂无数据</h2>
        <p>还没有人上传基准测试结果</p>
        <button @click="handleUpload" class="upload-button">成为第一个上传者</button>
      </div>

      <div v-else class="leaderboard-content">
        <div class="leaderboard-table">
          <div class="table-header">
            <div class="rank-header">排名</div>
            <div class="user-header">用户</div>
            <div class="hardware-header">硬件配置</div>
            <div class="device-header">设备类型</div>
            <div class="time-header">总耗时(秒)</div>
          </div>

          <div v-for="(entry, index) in leaderboard" :key="entry.id || index" class="table-row" :class="{ 'top-three': entry.rank <= 3 }">
            <div class="rank-cell">
              <span v-if="entry.rank === 1" class="medal gold">🥇</span>
              <span v-else-if="entry.rank === 2" class="medal silver">🥈</span>
              <span v-else-if="entry.rank === 3" class="medal bronze">🥉</span>
              <span v-else class="rank-number">#{{ entry.rank }}</span>
            </div>

            <div class="user-cell">
              <img
                :src="entry.avatar_url || `https://ui-avatars.com/api/?name=${entry.username}&background=667eea&color=fff&size=80`"
                :alt="entry.username"
                class="user-avatar"
                @error="handleAvatarError"
              />
              <span class="username">{{ entry.username }}</span>
            </div>

            <div class="hardware-cell">
              <div class="hardware-info">
                <div class="cpu-model" :title="entry.cpu_model">
                  {{ entry.cpu_model || '未知CPU' }}
                </div>
                <div class="specs">
                  <span v-if="entry.cpu_cores">{{ entry.cpu_cores }}核</span>
                  <span v-if="entry.memory_gb">{{ entry.memory_gb }}GB</span>
                </div>
              </div>
            </div>

            <div class="device-cell">
              <div class="device-info">
                <span class="device-type" :class="getDeviceTypeClass(entry.device_type)">
                  {{ getDeviceTypeLabel(entry.device_type) }}
                </span>
                <div v-if="entry.device_type_confidence" class="confidence">
                  置信度: {{ formatConfidence(entry.device_type_confidence) }}
                </div>
              </div>
            </div>

            <div class="time-cell">
              <div class="overall-time">
                {{ formatTime(entry.overall_wall_time) }}
              </div>
              <div v-if="entry.phase1_wall_time && entry.phase2_wall_time" class="phase-times">
                <small>阶段1: {{ formatTime(entry.phase1_wall_time) }}</small>
                <small>阶段2: {{ formatTime(entry.phase2_wall_time) }}</small>
              </div>
            </div>
          </div>
        </div>

        <div v-if="pagination.total_pages > 1" class="pagination">
          <button
            @click="prevPage"
            :disabled="pagination.page === 1"
            class="pagination-btn"
          >
            上一页
          </button>
          <span class="page-info">
            第 {{ pagination.page }} 页，共 {{ pagination.total_pages }} 页
          </span>
          <button
            @click="nextPage"
            :disabled="pagination.page === pagination.total_pages"
            class="pagination-btn"
          >
            下一页
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { authState, authActions } from '../stores/auth.js'
import apiService from '../services/api.js'

const router = useRouter()
const leaderboard = ref([])
const loading = ref(false)
const error = ref(null)
const selectedDeviceType = ref(null)
const pagination = ref({
  page: 1,
  limit: 20,
  total: 0,
  total_pages: 0
})

onMounted(() => {
  loadLeaderboard()
})

const loadLeaderboard = async (page = 1) => {
  try {
    loading.value = true
    error.value = null

    let endpoint = `/benchmarks/leaderboard?page=${page}&limit=${pagination.value.limit}`
    if (selectedDeviceType.value) {
      endpoint += `&device_type=${selectedDeviceType.value}`
    }

    const response = await apiService.get(endpoint)

    if (response.success) {
      leaderboard.value = response.data.leaderboard
      pagination.value = response.data.pagination
    } else {
      throw new Error('获取排行榜数据失败')
    }
  } catch (err) {
    console.error('加载排行榜失败:', err)
    error.value = err.message || '加载排行榜失败'
  } finally {
    loading.value = false
  }
}

const handleUpload = async () => {
  // 检查用户是否已登录
  if (!authState.isAuthenticated) {
    // 如果未登录，触发登录流程
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

const prevPage = () => {
  if (pagination.value.page > 1) {
    loadLeaderboard(pagination.value.page - 1)
  }
}

const nextPage = () => {
  if (pagination.value.page < pagination.value.total_pages) {
    loadLeaderboard(pagination.value.page + 1)
  }
}

const formatTime = (seconds) => {
  if (!seconds) return 'N/A'
  return seconds.toFixed(3)
}

const handleAvatarError = (event) => {
  // 隐藏失败的图片，创建回退头像
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
      font-size: 12px;
      flex-shrink: 0;
    `
    // 从当前条目获取用户名
    const entry = event.target.closest('.leaderboard-entry')
    const username = entry?.querySelector('.username')?.textContent || 'U'
    fallback.textContent = username.charAt(0).toUpperCase()
    parent.insertBefore(fallback, event.target)
  }
}

const selectDeviceType = (deviceType) => {
  selectedDeviceType.value = deviceType
  pagination.value.page = 1
  loadLeaderboard(1)
}

const getDeviceTypeLabel = (deviceType) => {
  const labels = {
    'server': '服务器级',
    'consumer': '消费级',
    'unknown': '未知'
  }
  return labels[deviceType] || '未知'
}

const getDeviceTypeClass = (deviceType) => {
  return `device-type-${deviceType || 'unknown'}`
}

const formatConfidence = (confidence) => {
  if (!confidence) return ''
  return (confidence * 100).toFixed(0) + '%'
}
</script>

<style scoped>
.leaderboard {
  min-height: 100vh;
  padding: 2rem 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
}

.header {
  text-align: center;
  margin-bottom: 3rem;
  color: white;
}

.header h1 {
  font-size: 2.5rem;
  margin-bottom: 0.5rem;
  font-weight: 700;
}

.header p {
  font-size: 1.1rem;
  opacity: 0.9;
  margin-bottom: 2rem;
}

.device-type-selector {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin-top: 1.5rem;
}

.selector-label {
  font-weight: 600;
  color: rgba(255, 255, 255, 0.9);
  font-size: 1.1rem;
}

.device-type-buttons {
  display: flex;
  gap: 0.5rem;
  background: rgba(255, 255, 255, 0.1);
  padding: 0.3rem;
  border-radius: 25px;
  backdrop-filter: blur(10px);
}

.device-btn {
  padding: 0.6rem 1.2rem;
  border: none;
  border-radius: 20px;
  background: transparent;
  color: rgba(255, 255, 255, 0.8);
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
  font-size: 0.95rem;
}

.device-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  color: white;
}

.device-btn.active {
  background: rgba(255, 255, 255, 0.9);
  color: #667eea;
  box-shadow: 0 4px 15px rgba(255, 255, 255, 0.3);
}

.loading, .error, .empty {
  text-align: center;
  padding: 4rem 2rem;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  margin: 2rem 0;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-icon, .empty-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
}

.retry-button, .upload-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 25px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 1rem;
}

.retry-button:hover, .upload-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
}

.leaderboard-content {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
}

.leaderboard-table {
  width: 100%;
}

.table-header {
  display: grid;
  grid-template-columns: 80px 200px 1fr 100px 120px;
  background: linear-gradient(135deg, #2d3436 0%, #636e72 100%);
  color: #fff;
  font-weight: 700;
  padding: 1rem;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
  border-bottom: 3px solid #667eea;
}

.table-row {
  display: grid;
  grid-template-columns: 80px 200px 1fr 100px 120px;
  padding: 1rem;
  border-bottom: 1px solid #eee;
  align-items: center;
  transition: all 0.3s ease;
}

.table-row:hover {
  background: #f8f9fa;
}

.table-row.top-three {
  background: linear-gradient(135deg, rgba(255, 215, 0, 0.1) 0%, rgba(255, 215, 0, 0.05) 100%);
}

.rank-cell {
  text-align: center;
  font-weight: 600;
}

.medal {
  font-size: 1.5rem;
}

.rank-number {
  color: #666;
}

.user-cell {
  display: flex;
  align-items: center;
  gap: 0.8rem;
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #667eea;
}

.username {
  font-weight: 600;
  color: #333;
}

.hardware-cell {
  padding: 0 1rem;
}

.device-cell {
  text-align: center;
}

.device-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.3rem;
}

.device-type {
  padding: 0.3rem 0.8rem;
  border-radius: 15px;
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.device-type-server {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.device-type-consumer {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.device-type-unknown {
  background: linear-gradient(135deg, #dfe6e9 0%, #b2bec3 100%);
  color: #636e72;
}

.confidence {
  font-size: 0.75rem;
  color: #666;
  font-weight: 500;
}

.cpu-model {
  font-weight: 600;
  color: #333;
  margin-bottom: 0.3rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.specs {
  font-size: 0.9rem;
  color: #666;
  display: flex;
  gap: 0.5rem;
}

.time-cell {
  text-align: center;
}

.overall-time {
  font-weight: 700;
  font-size: 1.2rem;
  color: #667eea;
  margin-bottom: 0.3rem;
}

.phase-times {
  font-size: 0.8rem;
  color: #666;
  line-height: 1.3;
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  padding: 2rem;
  background: #f8f9fa;
}

.pagination-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 0.8rem 1.5rem;
  border-radius: 20px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.pagination-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-info {
  font-weight: 600;
  color: #666;
}

@media (max-width: 768px) {
  .table-header,
  .table-row {
    grid-template-columns: 60px 1fr 100px;
  }

  .hardware-cell,
  .device-cell {
    grid-column: 1 / -1;
    padding: 0.5rem 0 0 3.5rem;
  }

  .table-header > .hardware-header,
  .table-header > .device-header,
  .table-row > .hardware-cell,
  .table-row > .device-cell {
    display: contents;
  }

  .device-cell {
    text-align: left;
    margin-top: 0.5rem;
  }

  .device-info {
    align-items: flex-start;
  }

  .header h1 {
    font-size: 2rem;
  }

  .container {
    padding: 0 0.5rem;
  }

  .device-type-selector {
    flex-direction: column;
    gap: 0.8rem;
  }

  .device-type-buttons {
    flex-wrap: wrap;
    justify-content: center;
  }
}
</style>