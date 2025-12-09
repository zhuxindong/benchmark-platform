<template>
  <div class="leaderboard">
    <div class="container">
      <div class="header">
        <div class="header-title-group">
          <h1>{{ isReverse ? '🐢 卧龙凤雏榜' : '🏆 基准测试排行榜' }}</h1>
          <p>{{ isReverse ? '性能最慢的设备排行，娱乐向' : '基于真实环境的性能评测数据，实时更新' }}</p>
        </div>

        <div class="header-controls">
          <!-- 排行榜模式选择器 -->
          <div class="device-type-selector">
            <label class="selector-label">排行榜</label>
            <div class="device-type-buttons">
              <button
                @click="toggleReverseMode(false)"
                :class="['device-btn', { active: !isReverse }]"
              >
                🏆 性能榜
              </button>
              <button
                @click="toggleReverseMode(true)"
                :class="['device-btn', { active: isReverse }]"
              >
                🐢 卧龙凤雏榜
              </button>
            </div>
          </div>

          <!-- 设备类型选择器 -->
          <div class="device-type-selector">
            <label class="selector-label">显示范围</label>
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
                服务器
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
const isReverse = ref(false) // 是否为倒序模式（卧龙凤雏榜）
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
    if (isReverse.value) {
      endpoint += `&reverse=true`
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

// 切换排行榜模式（正序/倒序）
const toggleReverseMode = (reverse) => {
  isReverse.value = reverse
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
/* ========================================
    Leaderboard - Premium Dashboard Style
   ======================================== */

.leaderboard {
  min-height: 100vh;
  background: #F5F5F7;
  padding: 32px 0;
}

.container {
  max-width: 1400px; /* Wider layout */
  margin: 0 auto;
  padding: 0 24px;
}

/* ========================================
   Header Section - Compact & Functional
   ======================================== */

.header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 24px;
  padding: 0 4px;
}

.header-title-group h1 {
  font-size: 32px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 4px 0;
  letter-spacing: -0.01em;
}

.header-title-group p {
  font-size: 15px;
  color: #86868B;
  margin: 0;
  font-weight: 400;
}

/* Header Controls - Multiple Selectors */
.header-controls {
  display: flex;
  gap: 24px;
  align-items: flex-end;
}

/* Device Selector - Integrated on the Right */
.device-type-selector {
  display: flex;
  align-items: center;
  gap: 12px;
}

.selector-label {
  font-size: 13px;
  font-weight: 500;
  color: #6E6E73;
}

.device-type-buttons {
  display: inline-flex;
  background: #E8E8ED;
  padding: 2px;
  border-radius: 9px;
}

.device-btn {
  padding: 6px 16px;
  border: none;
  border-radius: 7px;
  background: transparent;
  color: #6E6E73;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.25, 0.1, 0.25, 1);
  font-weight: 500;
  font-size: 13px;
}

.device-btn:hover {
  color: #1D1D1F;
}

.device-btn.active {
  background: #FFFFFF;
  color: #1D1D1F;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  font-weight: 600;
}

/* ========================================
   States
   ======================================== */

.loading, .error, .empty {
  text-align: center;
  padding: 60px 0;
  background: transparent;
}

.spinner {
  width: 32px;
  height: 32px;
  border: 3px solid rgba(0,0,0,0.1);
  border-top: 3px solid #0071E3;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 16px;
}

@keyframes spin { to { transform: rotate(360deg); } }

.error-icon, .empty-icon { font-size: 48px; margin-bottom: 16px; }
.retry-button, .upload-button {
  background: #0071E3;
  color: white;
  padding: 8px 24px;
  border-radius: 999px;
  font-size: 14px;
  font-weight: 500;
  margin-top: 16px;
}

/* ========================================
   Leaderboard Content - Full Width Card
   ======================================== */

.leaderboard-content {
  background: #FFFFFF;
  border-radius: 18px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04), 0 0 1px rgba(0,0,0,0.06);
}

.leaderboard-table {
  width: 100%;
}

/* Table Header */
.table-header {
  display: grid;
  grid-template-columns: 80px 240px 1fr 140px 160px;
  background: #FAFAFA;
  border-bottom: 1px solid #E5E5EA;
  padding: 12px 24px;
}

.table-header > div {
  font-size: 12px;
  font-weight: 600;
  color: #86868B;
  text-transform: uppercase;
  letter-spacing: 0.02em;
}

/* Rows */
.table-row {
  display: grid;
  grid-template-columns: 80px 240px 1fr 140px 160px;
  padding: 16px 24px;
  border-bottom: 1px solid #F5F5F7;
  align-items: center;
  transition: background 0.15s ease;
  background: #FFFFFF;
}

.table-row:hover {
  background: #F5F5F7;
}

.table-row:last-child {
  border-bottom: none;
}

/* Rank Cell */
.rank-cell {
  display: flex;
  align-items: center;
}

.medal { font-size: 24px; }
.rank-number {
  color: #86868B;
  font-size: 14px;
  font-weight: 500;
  width: 28px;
  text-align: center;
}

/* User Cell */
.user-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
  border: 1px solid rgba(0,0,0,0.08);
}

.username {
  font-weight: 600;
  color: #1D1D1F;
  font-size: 15px;
}

/* Hardware Cell */
.hardware-cell {
  padding-right: 24px;
}

.hardware-info {
  display: flex;
  flex-direction: column;
}

.cpu-model {
  font-weight: 500;
  color: #1D1D1F;
  font-size: 14px;
  margin-bottom: 4px;
}

.specs {
  display: flex;
  gap: 8px;
}

.specs span {
  font-size: 11px;
  color: #6E6E73;
  background: #F5F5F7;
  padding: 2px 8px;
  border-radius: 4px;
  font-weight: 500;
}

/* Device Cell */
.device-cell {
  display: flex;
  align-items: center;
}

.device-type {
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.03em;
}

.device-type-server { background: #E8F2FF; color: #0071E3; }
.device-type-consumer { background: #E6F8EA; color: #34C759; }
.device-type-unknown { background: #F5F5F7; color: #86868B; }

.confidence {
  font-size: 10px;
  color: #86868B;
  margin-top: 4px;
  margin-left: 8px;
}

/* Time Cell */
.time-cell {
  text-align: right;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.overall-time {
  font-family: "SF Mono", SFMono-Regular, ui-monospace, monospace;
  font-weight: 600;
  font-size: 16px;
  color: #1D1D1F;
  margin-bottom: 2px;
}

.phase-times {
  font-size: 11px;
  color: #86868B;
  opacity: 0.8;
}

/* Pagination */
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 24px;
  gap: 16px;
  background: #FBFBFC;
  border-top: 1px solid #E5E5EA;
}

.pagination-btn {
  background: white;
  border: 1px solid #E5E5EA;
  color: #1D1D1F;
  padding: 6px 16px;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 500;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
  transition: all 0.2s;
}

.pagination-btn:hover:not(:disabled) {
  background: #F5F5F7;
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: default;
  box-shadow: none;
}

.page-info {
  font-size: 13px;
  color: #86868B;
}

/* ========================================
   Responsive
   ======================================== */

@media (max-width: 1024px) {
  .header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
  
  .table-header, .table-row {
    grid-template-columns: 60px 200px 1fr 100px;
  }
  
  .time-cell { grid-column: 4; }
  .table-header > .device-header, .device-cell { display: none; }
}

@media (max-width: 768px) {
  .leaderboard { padding: 16px 0; }
  .container { padding: 0 16px; }
  
  .table-header, .table-row {
    grid-template-columns: 50px 1fr 90px;
    padding: 12px 16px;
  }
  
  .hardware-cell, .table-header > .hardware-header { display: none; }
  .header-title-group h1 { font-size: 24px; }
}
</style>
