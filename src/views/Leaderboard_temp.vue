<template>
  <div class="leaderboard">
    <div class="container">
      <div class="header">
        <h1>🏆 基准测试排行�?/h1>
        <p>展示最快的基准测试结果，按总耗时排序</p>

        <!-- 设备类型选择�?-->
        <div class="device-type-selector">
          <label class="selector-label">设备类型�?/label>
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
              消费�?
            </button>
          </div>
        </div>
      </div>

      <div v-if="loading" class="loading">
        <div class="spinner"></div>
        <p>正在加载排行榜数�?..</p>
      </div>

      <div v-else-if="error" class="error">
        <div class="error-icon">�?/div>
        <h2>加载失败</h2>
        <p>{{ error }}</p>
        <button @click="loadLeaderboard" class="retry-button">重试</button>
      </div>

      <div v-else-if="leaderboard.length === 0" class="empty">
        <div class="empty-icon">📊</div>
        <h2>暂无数据</h2>
        <p>还没有人上传基准测试结果</p>
        <button @click="handleUpload" class="upload-button">成为第一个上传�?/button>
      </div>

      <div v-else class="leaderboard-content">
        <div class="leaderboard-table">
          <div class="table-header">
            <div class="rank-header">排名</div>
            <div class="user-header">用户</div>
            <div class="hardware-header">硬件配置</div>
            <div class="device-header">设备类型</div>
            <div class="time-header">总耗时(�?</div>
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
                  <span v-if="entry.cpu_cores">{{ entry.cpu_cores }}�?/span>
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
                  置信�? {{ formatConfidence(entry.device_type_confidence) }}
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
            上一�?
          </button>
          <span class="page-info">
            �?{{ pagination.page }} 页，�?{{ pagination.total_pages }} �?
          </span>
          <button
            @click="nextPage"
            :disabled="pagination.page === pagination.total_pages"
            class="pagination-btn"
          >
            下一�?
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
      throw new Error('获取排行榜数据失�?)
    }
  } catch (err) {
    console.error('加载排行榜失�?', err)
    error.value = err.message || '加载排行榜失�?
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
    // 如果已登录，直接跳转到上传页�?
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
    'consumer': '消费�?,
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
