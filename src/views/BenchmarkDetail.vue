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
.benchmark-detail {
  min-height: 100vh;
  padding: 2rem 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.container {
  max-width: 800px;
  margin: 0 auto;
  padding: 0 1rem;
}

.loading, .error, .no-data {
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

.error-icon, .no-data-icon {
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

.benchmark-content {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.user-section {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  padding: 2rem;
  display: flex;
  align-items: center;
  gap: 1.5rem;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.user-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  object-fit: cover;
  border: 4px solid #667eea;
}

.user-info h2 {
  margin: 0 0 0.5rem 0;
  color: #333;
  font-size: 1.8rem;
}

.user-info p {
  margin: 0 0 0.8rem 0;
  color: #666;
  font-size: 1.1rem;
}

.user-stats {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.stat-item {
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
  padding: 0.3rem 0.8rem;
  border-radius: 15px;
  font-size: 0.9rem;
  font-weight: 600;
}

.actions {
  margin-left: auto;
}

.records-section {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  padding: 2rem;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  margin-bottom: 2rem;
}

.records-section h3 {
  margin: 0 0 1.5rem 0;
  color: #333;
  font-size: 1.4rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.records-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.record-item {
  background: #f8f9fa;
  border: 2px solid #e9ecef;
  border-radius: 12px;
  padding: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.record-item:hover {
  border-color: #667eea;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}

.record-item.active {
  border-color: #667eea;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.record-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.8rem;
}

.record-actions {
  display: flex;
  gap: 0.5rem;
}

.action-btn {
  padding: 0.3rem 0.6rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
  transition: all 0.3s ease;
  opacity: 0.8;
}

.action-btn:hover {
  opacity: 1;
  transform: scale(1.1);
}

.edit-btn {
  background: #667eea;
  color: white;
}

.edit-btn:hover {
  background: #5a6fd8;
}

.delete-btn {
  background: #ff6b6b;
  color: white;
}

.delete-btn:hover {
  background: #ff5252;
}

.record-number {
  background: #667eea;
  color: white;
  padding: 0.2rem 0.6rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 600;
}

.record-date {
  color: #666;
  font-size: 0.9rem;
}

.record-summary {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.cpu-info {
  flex: 1;
  font-weight: 600;
  color: #333;
  margin-right: 1rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.performance-info {
  display: flex;
  align-items: center;
  gap: 0.8rem;
  flex-shrink: 0;
}

.time {
  background: #28a745;
  color: white;
  padding: 0.2rem 0.6rem;
  border-radius: 8px;
  font-size: 0.8rem;
  font-weight: 600;
}

.device-type {
  padding: 0.2rem 0.6rem;
  border-radius: 8px;
  font-size: 0.8rem;
  font-weight: 600;
}

.device-server {
  background: #007bff;
  color: white;
}

.device-consumer {
  background: #28a745;
  color: white;
}

.device-unknown {
  background: #6c757d;
  color: white;
}

.hardware-section, .performance-section, .info-section {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  padding: 2rem;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.hardware-section h3, .performance-section h3, .info-section h3 {
  margin: 0 0 1.5rem 0;
  color: #333;
  font-size: 1.4rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.hardware-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.hardware-item {
  display: flex;
  flex-direction: column;
}

.hardware-item label {
  font-size: 0.9rem;
  color: #666;
  margin-bottom: 0.5rem;
  font-weight: 600;
}

.hardware-item .value {
  font-size: 1.2rem;
  color: #333;
  font-weight: 700;
}

.performance-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.performance-card {
  background: #f8f9fa;
  border-radius: 15px;
  padding: 1.5rem;
  text-align: center;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.performance-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.performance-card.highlight {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: #667eea;
}

.performance-card .card-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.performance-card .icon {
  font-size: 2rem;
}

.performance-card .label {
  font-weight: 600;
  font-size: 1rem;
}

.performance-card .card-value {
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.performance-card .unit {
  font-size: 0.9rem;
  font-weight: 400;
  opacity: 0.8;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.info-item {
  display: flex;
  flex-direction: column;
}

.info-item label {
  font-size: 0.9rem;
  color: #666;
  margin-bottom: 0.5rem;
  font-weight: 600;
}

.info-item .value {
  font-size: 1.1rem;
  color: #333;
  font-weight: 500;
}


.leaderboard-btn-small {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  border: none;
  padding: 0.8rem 1.2rem;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  white-space: nowrap;
}

.leaderboard-btn-small:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(240, 147, 251, 0.4);
}

.modify-btn {
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

.modify-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
}

.modify-btn.disabled {
  background: #6c757d;
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.modify-btn.disabled:hover {
  transform: none;
  box-shadow: none;
}

@media (max-width: 768px) {
  .user-section {
    flex-direction: column;
    text-align: center;
  }

  .actions {
    margin-left: 0;
    margin-top: 1rem;
  }

  .performance-grid {
    grid-template-columns: 1fr;
  }
}
</style>