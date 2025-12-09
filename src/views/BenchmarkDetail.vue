<template>
  <div class="benchmark-detail">
    <div class="container">
      <div v-if="loading" class="loading">
        <div class="spinner"></div>
        <p>正在加载基准测试结果...</p>
      </div>

      <div v-else-if="error" class="error">
        <div class="error-icon">❌</div>
        <h2>加载失败</h2>
        <p>{{ error }}</p>
        <button @click="loadBenchmarkData" class="retry-button">重试</button>
      </div>

      <div v-else-if="benchmarkList.length === 0" class="no-data">
        <div class="no-data-icon">📊</div>
        <h2>还没有基准测试结果</h2>
        <p>你还没有上传过基准测试结果，点击下方按钮开始上传</p>
        <button @click="goToUpload" class="upload-button">上传基准测试结果</button>
      </div>

      <div v-else class="benchmark-content">
        <!-- 用户信息 -->
        <div class="user-section">
          <img
            :src="selectedRecord?.avatar_url || `https://ui-avatars.com/api/?name=${selectedRecord?.username || 'User'}&background=667eea&color=fff&size=120`"
            :alt="selectedRecord?.username"
            class="user-avatar"
            @error="handleAvatarError"
          />
          <div class="user-info">
            <h2>{{ selectedRecord?.username || '用户' }}</h2>
            <p>我的基准测试结果</p>
            <div class="user-stats">
              <span class="stat-item">📊 {{ userStats.total_count }}/3 条记录</span>
              <span class="stat-item">📝 还可提交 {{ userStats.remaining_slots }} 条</span>
            </div>
          </div>
          <div class="actions">
            <button
              @click="goToUpload"
              class="modify-btn"
              :disabled="userStats.remaining_slots === 0"
              :class="{ disabled: userStats.remaining_slots === 0 }"
            >
              {{ userStats.remaining_slots === 0 ? '已达上限' : '新增结果' }}
            </button>
            <button @click="goToLeaderboard" class="leaderboard-btn-small">
              🏆 查看排行榜
            </button>
          </div>
        </div>

        <!-- 记录列表 -->
        <div class="records-section">
          <h3>📋 我的测试记录</h3>
          <div class="records-list">
            <div
              v-for="(record, index) in benchmarkList"
              :key="record.id"
              @click="selectRecord(record)"
              :class="['record-item', { active: selectedRecord?.id === record.id }]"
            >
              <div class="record-header">
                <span class="record-number">#{{ index + 1 }}</span>
                <span class="record-date">{{ formatDate(record.submitted_at) }}</span>
                <div class="record-actions" @click.stop>
                  <button
                    @click="editRecord(record)"
                    class="action-btn edit-btn"
                    title="修改记录"
                  >
                    ✏️
                  </button>
                  <button
                    @click="deleteRecord(record)"
                    class="action-btn delete-btn"
                    title="删除记录"
                  >
                    🗑️
                  </button>
                </div>
              </div>
              <div class="record-summary">
                <div class="cpu-info">{{ record.cpu_model }}</div>
                <div class="performance-info">
                  <span class="time">{{ formatTime(record.overall_wall_time) }}s</span>
                  <span class="device-type" :class="getDeviceTypeClass(record.device_type)">
                    {{ getDeviceTypeLabel(record.device_type) }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 硬件配置 -->
        <div class="hardware-section">
          <h3>💻 硬件配置</h3>
          <div class="hardware-grid">
            <div class="hardware-item">
              <label>CPU</label>
              <div class="value">{{ selectedRecord?.cpu_model || '未知' }}</div>
            </div>
            <div class="hardware-item">
              <label>核心数</label>
              <div class="value">{{ selectedRecord?.cpu_cores || 'N/A' }}</div>
            </div>
            <div class="hardware-item">
              <label>内存</label>
              <div class="value">{{ selectedRecord?.memory_gb ? selectedRecord.memory_gb + ' GB' : 'N/A' }}</div>
            </div>
          </div>
        </div>

        <!-- 性能结果 -->
        <div class="performance-section">
          <h3>⚡ 性能结果</h3>
          <div class="performance-grid">
            <div class="performance-card highlight">
              <div class="card-header">
                <span class="icon">🏁</span>
                <span class="label">总耗时</span>
              </div>
              <div class="card-value">
                {{ formatTime(selectedRecord?.overall_wall_time) }}
                <span class="unit">秒</span>
              </div>
            </div>

            <div class="performance-card">
              <div class="card-header">
                <span class="icon">1️⃣</span>
                <span class="label">阶段1</span>
              </div>
              <div class="card-value">
                {{ formatTime(selectedRecord?.phase1_wall_time) }}
                <span class="unit">秒</span>
              </div>
            </div>

            <div class="performance-card">
              <div class="card-header">
                <span class="icon">2️⃣</span>
                <span class="label">阶段2</span>
              </div>
              <div class="card-value">
                {{ formatTime(selectedRecord?.phase2_wall_time) }}
                <span class="unit">秒</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 时间信息 -->
        <div class="info-section">
          <h3>📅 提交信息</h3>
          <div class="info-grid">
            <div class="info-item">
              <label>首次提交</label>
              <div class="value">{{ formatDate(selectedRecord?.submitted_at) }}</div>
            </div>
            <div class="info-item">
              <label>最后更新</label>
              <div class="value">{{ formatDate(selectedRecord?.updated_at) }}</div>
            </div>
          </div>
        </div>

        </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import apiService from '../services/api.js'

const router = useRouter()
const loading = ref(false)
const error = ref(null)
const benchmarkList = ref([])
const userStats = ref({ total_count: 0, remaining_slots: 3 })
const selectedRecord = ref(null) // 当前选中的记录详情

onMounted(() => {
  loadBenchmarkData()
})

const loadBenchmarkData = async () => {
  try {
    loading.value = true
    error.value = null

    const response = await apiService.get('/benchmarks/my-result')

    if (response.success) {
      // 处理新的数据结构
      if (response.data.results && response.data.results.length > 0) {
        benchmarkList.value = response.data.results
        selectedRecord.value = response.data.results[0] // 默认选中第一条
        userStats.value = {
          total_count: response.data.total_count,
          remaining_slots: response.data.remaining_slots
        }
      } else {
        benchmarkList.value = []
        selectedRecord.value = null
        userStats.value = { total_count: 0, remaining_slots: 3 }
      }
    } else {
      throw new Error('获取基准测试结果失败')
    }
  } catch (err) {
    console.error('加载基准测试数据失败:', err)
    error.value = err.message || '加载基准测试结果失败'
  } finally {
    loading.value = false
  }
}

const goToUpload = () => {
  router.push('/upload')
}

const goToLeaderboard = () => {
  router.push('/')
}

const selectRecord = (record) => {
  selectedRecord.value = record
}

const formatTime = (seconds) => {
  if (!seconds) return 'N/A'
  return seconds.toFixed(3)
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getDeviceTypeClass = (deviceType) => {
  const classes = {
    'server': 'device-server',
    'consumer': 'device-consumer',
    'unknown': 'device-unknown'
  }
  return classes[deviceType] || 'device-unknown'
}

const getDeviceTypeLabel = (deviceType) => {
  const labels = {
    'server': '服务器级',
    'consumer': '消费级',
    'unknown': '未知'
  }
  return labels[deviceType] || '未知'
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
    fallback.textContent = (selectedRecord.value?.username || 'U').charAt(0).toUpperCase()
    parent.insertBefore(fallback, event.target)
  }
}

const editRecord = (record) => {
  // 跳转到专门的编辑页面
  router.push({
    path: '/edit',
    query: {
      id: record.id
    }
  })
}

const deleteRecord = async (record) => {
  if (!confirm(`确定要删除这条记录吗？\n\nCPU: ${record.cpu_model}\n总耗时: ${formatTime(record.overall_wall_time)}s`)) {
    return
  }

  try {
    const response = await apiService.delete(`/benchmarks/${record.id}`)

    if (response.success) {
      // 重新加载基准测试数据
      await loadBenchmarkData()

      // 如果删除的是当前选中的记录，选中第一条记录
      if (benchmarkList.value.length > 0 && (!selectedRecord.value || selectedRecord.value.id === record.id)) {
        selectedRecord.value = benchmarkList.value[0]
      }
    } else {
      alert(response.message || '删除失败')
    }
  } catch (err) {
    console.error('删除记录失败:', err)
    alert(err.message || '删除失败，请重试')
  }
}
</script>

<style scoped>
/* ========================================
    Benchmark Detail (Apple Style)
   ======================================== */

.benchmark-detail {
  width: 100%;
  padding-bottom: 60px;
}

.container {
  max-width: var(--max-width);
  margin: 0 auto;
  padding: 0 22px;
}

/* ========================================
   States
   ======================================== */

.loading, .error, .no-data {
  text-align: center;
  padding: 80px 24px;
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  margin-top: 24px;
  box-shadow: var(--shadow-sm);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid var(--border-light);
  border-top: 3px solid var(--color-blue);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin-bottom: 24px;
}

@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }

.error h2, .no-data h2 {
  font-size: 24px;
  font-weight: 600;
  margin-bottom: 12px;
  color: var(--text-primary);
}

.error p, .no-data p {
  color: var(--text-secondary);
  font-size: 16px;
  margin-bottom: 24px;
}

.error-icon, .no-data-icon {
  font-size: 56px;
  margin-bottom: 24px;
}

.retry-button, .upload-button {
  background: var(--color-blue);
  color: white;
  padding: 8px 20px;
  border-radius: var(--radius-full);
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s ease;
}

.retry-button:hover, .upload-button:hover {
  background: var(--color-blue-hover);
  transform: scale(1.02);
}

/* ========================================
   User Profile Section
   ======================================== */

.user-section {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  padding: 32px;
  margin-top: 24px;
  display: flex;
  align-items: center;
  gap: 24px;
  box-shadow: var(--shadow-sm);
}

.user-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  object-fit: cover;
  border: 1px solid var(--border-light);
}

.user-info h2 {
  font-size: 24px;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 4px;
}

.user-info p {
  color: var(--text-secondary);
  font-size: 14px;
  margin-bottom: 12px;
}

.user-stats {
  display: flex;
  gap: 12px;
}

.stat-item {
  background: var(--bg-body);
  color: var(--text-secondary);
  padding: 4px 12px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
}

.actions {
  margin-left: auto;
  display: flex;
  gap: 12px;
}

.modify-btn {
  background: var(--color-blue);
  color: white;
  padding: 8px 20px;
  border-radius: var(--radius-full);
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
}

.modify-btn:hover:not(.disabled) {
  background: var(--color-blue-hover);
}

.modify-btn.disabled {
  background: var(--border-light);
  color: var(--text-tertiary);
  cursor: not-allowed;
}

.leaderboard-btn-small {
  background: rgba(0,0,0,0.05);
  color: var(--text-primary);
  padding: 8px 20px;
  border-radius: var(--radius-full);
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
}

.leaderboard-btn-small:hover {
  background: rgba(0,0,0,0.1);
}

/* ========================================
   Records List
   ======================================== */

.benchmark-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.records-section, .hardware-section, .performance-section, .info-section {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  padding: 32px;
  box-shadow: var(--shadow-sm);
}

h3 {
  font-size: 19px;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 24px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.records-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.record-item {
  display: flex;
  flex-direction: column;
  padding: 16px 20px;
  border-radius: var(--radius-md);
  background: var(--bg-body);
  border: 1px solid transparent;
  cursor: pointer;
  transition: all 0.2s ease;
}

.record-item:hover {
  background: #E8E8ED;
}

.record-item.active {
  background: #F0F7FF;
  border-color: rgba(0, 113, 227, 0.2);
}

.record-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.record-number {
  font-size: 12px;
  font-weight: 600;
  color: var(--text-tertiary);
  background: rgba(0,0,0,0.05);
  padding: 2px 8px;
  border-radius: 4px;
}

.record-date {
  font-size: 12px;
  color: var(--text-tertiary);
}

.record-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  font-size: 14px;
  padding: 4px;
  opacity: 0.6;
  transition: opacity 0.2s;
}

.action-btn:hover {
  opacity: 1;
}

.record-summary {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.cpu-info {
  font-weight: 500;
  font-size: 14px;
  color: var(--text-primary);
}

.performance-info {
  display: flex;
  gap: 12px;
  align-items: center;
}

.time {
  font-family: "SF Mono", monospace;
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
}

/* ========================================
   Hardware & Info Grids
   ======================================== */

.hardware-grid, .info-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

.hardware-item label, .info-item label {
  font-size: 12px;
  font-weight: 500;
  color: var(--text-secondary);
  display: block;
  margin-bottom: 4px;
  text-transform: uppercase;
  letter-spacing: 0.02em;
}

.hardware-item .value, .info-item .value {
  font-size: 16px;
  font-weight: 500;
  color: var(--text-primary);
}

/* ========================================
   Performance Cards
   ======================================== */

.performance-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.performance-card {
  background: var(--bg-body);
  border-radius: var(--radius-md);
  padding: 24px;
  text-align: center;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.performance-card.highlight {
  background: #F0F7FF; /* Very light blue */
}

.performance-card.highlight .card-value {
  color: var(--color-blue);
}

.card-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.card-header .icon {
  font-size: 32px;
}

.card-header .label {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.02em;
}

.card-value {
  font-size: 32px;
  font-weight: 700;
  color: var(--text-primary);
  font-family: "SF Pro Display", sans-serif;
  letter-spacing: -0.02em;
}

.card-value .unit {
  font-size: 14px;
  font-weight: 500;
  color: var(--text-tertiary);
  margin-left: 2px;
}

/* ========================================
   Device Tags
   ======================================== */

.device-type {
  font-size: 11px;
  padding: 3px 8px;
  border-radius: 4px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.03em;
}

.device-server {
  background: #E8F2FF;
  color: var(--color-blue);
}

.device-consumer {
  background: #E6F8EA;
  color: var(--color-green);
}

.device-unknown {
  background: var(--bg-body);
  color: var(--text-tertiary);
}

/* ========================================
   Responsive
   ======================================== */

@media (max-width: 768px) {
  .user-section {
    flex-direction: column;
    text-align: center;
    padding: 24px;
  }

  .actions {
    margin-top: 16px;
    margin-left: 0;
    width: 100%;
    justify-content: center;
  }
  
  .hardware-grid, .info-grid, .performance-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }
}
</style>
.benchmark-detail {
  min-height: 100vh;
  padding: 2rem 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}
