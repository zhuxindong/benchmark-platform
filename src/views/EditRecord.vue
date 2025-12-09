<template>
  <div class="edit-record">
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
            <p>编辑基准测试结果</p>
          </div>
          <div class="user-actions">
            <button @click="goToDetail" class="detail-btn">查看我的结果</button>
            <button @click="goHome" class="home-btn">返回首页</button>
          </div>
        </div>
      </div>

      <div class="edit-card">
        <div class="card-header">
          <h2>✏️ 编辑基准测试结果</h2>
          <p>请修改以下信息，确认后将更新记录</p>
        </div>

        <div v-if="loading" class="loading">
          <div class="spinner"></div>
          <p>正在加载记录数据...</p>
        </div>

        <div v-else-if="error" class="error">
          <div class="error-icon">❌</div>
          <h2>加载失败</h2>
          <p>{{ error }}</p>
          <button @click="loadRecordData" class="retry-button">重试</button>
        </div>

        <div v-else class="edit-form">
          <div class="result-grid">
            <div class="result-item">
              <label>CPU 型号：</label>
              <input
                v-model="editData.cpu_model"
                type="text"
                class="editable-input"
                placeholder="请输入CPU型号"
              />
            </div>
            <div class="result-item">
              <label>CPU 核心数：</label>
              <input
                v-model.number="editData.cpu_cores"
                type="number"
                class="editable-input"
                placeholder="请输入CPU核心数"
                min="1"
              />
            </div>
            <div class="result-item">
              <label>内存大小：</label>
              <input
                v-model.number="editData.memory_gb"
                type="number"
                class="editable-input"
                placeholder="请输入内存大小(GB)"
                min="0.1"
                step="0.1"
              />
            </div>
            <div class="result-item">
              <label>Phase 1 耗时：</label>
              <input
                v-model.number="editData.phase1_wall_time"
                type="number"
                class="editable-input"
                placeholder="请输入Phase 1耗时(秒)"
                min="0"
                step="0.001"
              />
            </div>
            <div class="result-item">
              <label>Phase 2 耗时：</label>
              <input
                v-model.number="editData.phase2_wall_time"
                type="number"
                class="editable-input"
                placeholder="请输入Phase 2耗时(秒)"
                min="0"
                step="0.001"
              />
            </div>
            <div class="result-item">
              <label>总体耗时：</label>
              <input
                v-model.number="editData.overall_wall_time"
                type="number"
                class="editable-input"
                placeholder="请输入总体耗时(秒)"
                min="0"
                step="0.001"
              />
            </div>
          </div>

          <!-- 设备类型分类部分 -->
          <div class="device-type-section">
            <h3>🖥️ 设备类型分类</h3>
            <div class="device-type-display">
              <div v-if="isClassifying" class="classification-loading">
                <span class="loading-spinner"></span>
                正在分析设备类型...
              </div>
              <div v-else class="classification-result">
                <div class="device-type-badge" :style="{ backgroundColor: getDeviceTypeColor(deviceClassification.device_type) }">
                  <span class="device-icon">
                    {{ deviceClassification.device_type === 'server' ? '🏢' : deviceClassification.device_type === 'consumer' ? '🏠' : '❓' }}
                  </span>
                  <span class="device-text">
                    {{ getDeviceTypeLabel(deviceClassification.device_type) }}
                  </span>
                  <span class="confidence">
                    (置信度: {{ deviceClassification.device_type_confidence.toFixed(2) }})
                  </span>
                </div>
                <div class="classification-text">
                  {{ deviceClassification.classification_text }}
                </div>
              </div>
            </div>

            <!-- 手动选择设备类型 -->
            <div class="device-type-manual">
              <label>如果分类不正确，请手动选择：</label>
              <div class="device-type-buttons">
                <button
                  v-for="option in deviceTypeOptions"
                  :key="option.value"
                  @click="setDeviceType(option.value)"
                  :class="{ active: deviceClassification.device_type === option.value }"
                  :style="{
                    backgroundColor: deviceClassification.device_type === option.value ? option.color : '#f8f9fa',
                    borderColor: deviceClassification.device_type === option.value ? option.color : '#dee2e6'
                  }"
                  class="device-type-btn"
                >
                  <span>{{ option.label }}</span>
                  <span class="device-icon">{{ option.value === 'server' ? '🏢' : option.value === 'consumer' ? '🏠' : '❓' }}</span>
                </button>
              </div>
            </div>
          </div>
        </div>

        <div class="button-section">
          <button @click="goBack" class="back-button">
            ← 取消编辑
          </button>
          <button
            @click="confirmUpdate"
            :disabled="isUpdating"
            class="update-button"
            :class="{ disabled: isUpdating }"
          >
            <span v-if="!isUpdating">✅ 确认更新</span>
            <span v-else>⏳ 更新中...</span>
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
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { authState } from '../stores/auth.js'
import apiService from '../services/api.js'

const router = useRouter()
const route = useRoute()

const loading = ref(true)
const error = ref('')
const success = ref('')
const isUpdating = ref(false)
const currentUser = computed(() => authState.user)

// 编辑数据
const editData = ref({
  cpu_model: '',
  cpu_cores: 0,
  memory_gb: 0,
  phase1_wall_time: 0,
  phase2_wall_time: 0,
  overall_wall_time: 0
})

const recordId = ref(null)

// 设备类型分类相关
const deviceClassification = ref({
  device_type: 'unknown',
  device_type_confidence: 0,
  classification_text: ''
})
const isClassifying = ref(false)
const deviceTypeOptions = [
  { value: 'server', label: '服务器级', color: '#667eea' },
  { value: 'consumer', label: '消费级', color: '#f093fb' },
  { value: 'unknown', label: '未知', color: '#4a5568' }
]

onMounted(() => {
  // 检查用户是否已登录
  if (!authState.isAuthenticated) {
    router.push('/')
    return
  }

  // 从路由参数获取记录ID
  if (route.query.id) {
    recordId.value = parseInt(route.query.id)
    loadRecordData()
  } else {
    error.value = '缺少记录ID'
    loading.value = false
  }
})

const loadRecordData = async () => {
  try {
    loading.value = true
    error.value = ''

    // 获取记录详情
    const response = await apiService.get(`/benchmarks/${recordId.value}`)

    if (response.success) {
      const record = response.data
      editData.value = {
        cpu_model: record.cpu_model || '',
        cpu_cores: record.cpu_cores || 0,
        memory_gb: record.memory_gb || 0,
        phase1_wall_time: record.phase1_wall_time || 0,
        phase2_wall_time: record.phase2_wall_time || 0,
        overall_wall_time: record.overall_wall_time || 0
      }

      // 自动分类设备类型
      classifyDeviceType(editData.value.cpu_model || '')
    } else {
      throw new Error(response.message || '获取记录失败')
    }

  } catch (err) {
    console.error('加载记录数据失败:', err)
    error.value = err.message || '加载记录失败，请重试'
  } finally {
    loading.value = false
  }
}

// 设备类型分类函数
const classifyDeviceType = async (cpuModel) => {
  if (!cpuModel || isClassifying.value) return

  try {
    isClassifying.value = true
    const response = await apiService.post('/benchmarks/classify-device-type', {
      cpu_model: cpuModel.trim()
    })

    if (response.success) {
      deviceClassification.value = response.data
    } else {
      console.error('设备类型分类失败:', response.message)
    }
  } catch (err) {
    console.error('设备类型分类异常:', err)
    // 设置默认值
    deviceClassification.value = {
      device_type: 'unknown',
      device_type_confidence: 0,
      classification_text: '设备类型: 未知 (置信度: 0.00)'
    }
  } finally {
    isClassifying.value = false
  }
}

// 手动设置设备类型
const setDeviceType = (deviceType) => {
  deviceClassification.value.device_type = deviceType
  deviceClassification.value.device_type_confidence = 1.0
  deviceClassification.value.classification_text = `设备类型: ${deviceTypeOptions.find(opt => opt.value === deviceType)?.label} (手动设置)`
}

// 获取设备类型的颜色
const getDeviceTypeColor = (deviceType) => {
  const option = deviceTypeOptions.find(opt => opt.value === deviceType)
  return option ? option.color : '#4a5568'
}

// 获取设备类型的标签
const getDeviceTypeLabel = (deviceType) => {
  const option = deviceTypeOptions.find(opt => opt.value === deviceType)
  return option ? option.label : '未知'
}

const confirmUpdate = async () => {
  try {
    isUpdating.value = true
    error.value = ''
    success.value = ''

    // 更新记录
    const response = await apiService.put(`/benchmarks/${recordId.value}`, {
      cpu_model: editData.value.cpu_model || '',
      cpu_cores: editData.value.cpu_cores || 0,
      memory_gb: editData.value.memory_gb || 0,
      phase1_wall_time: editData.value.phase1_wall_time || 0,
      phase2_wall_time: editData.value.phase2_wall_time || 0,
      overall_wall_time: editData.value.overall_wall_time || 0,
      device_type: deviceClassification.value.device_type,
      device_type_confidence: deviceClassification.value.device_type_confidence
    })

    if (response.success) {
      success.value = response.message || '更新成功！'

      // 3秒后跳转到详情页
      setTimeout(() => {
        router.push('/detail')
      }, 3000)
    } else {
      throw new Error(response.message || '更新失败')
    }

  } catch (err) {
    console.error('更新失败:', err)
    error.value = err.message || '更新失败，请重试'
  } finally {
    isUpdating.value = false
  }
}

const goBack = () => {
  router.push('/detail')
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

// 监听CPU型号变化，自动重新分类
watch(() => editData.value.cpu_model, (newCpuModel) => {
  if (newCpuModel) {
    classifyDeviceType(newCpuModel)
  }
})
</script>

<style scoped>
/* ========================================
    Edit Record - Apple Design System
   ======================================== */

.edit-record {
  min-height: 100vh;
  padding: 40px 0;
  background: var(--bg-body); /* Global token */
}

.container {
  max-width: 800px;
  margin: 0 auto;
  padding: 0 24px;
}

/* ========================================
   User Profile Section
   ======================================== */

.user-info {
  margin-bottom: 32px;
}

.user-card {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: var(--shadow-sm);
  border: 1px solid rgba(0,0,0,0.05);
}

.user-avatar {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  object-fit: cover;
  border: 1px solid rgba(0,0,0,0.1);
}

.user-details {
  flex: 1;
}

.user-details h3 {
  margin: 0 0 4px 0;
  color: var(--text-primary);
  font-size: 20px;
  font-weight: 700;
}

.user-details p {
  margin: 0;
  color: var(--text-secondary);
  font-size: 15px;
}

.user-actions {
  display: flex;
  gap: 12px;
}

.detail-btn, .home-btn {
  background: rgba(0,0,0,0.05);
  color: var(--text-primary);
  border: none;
  padding: 8px 16px;
  border-radius: 999px; /* Pill shape */
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.detail-btn:hover, .home-btn:hover {
  background: rgba(0,0,0,0.1);
  transform: none;
  box-shadow: none;
}

/* ========================================
   Edit Form Card
   ======================================== */

.edit-card {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  padding: 40px;
  box-shadow: var(--shadow-sm);
  border: 1px solid rgba(0,0,0,0.05);
  backdrop-filter: none;
}

.card-header {
  text-align: center;
  margin-bottom: 40px;
}

.card-header h2 {
  color: var(--text-primary);
  font-size: 28px;
  margin-bottom: 12px;
  font-weight: 700;
  letter-spacing: -0.01em;
}

.card-header p {
  color: var(--text-secondary);
  font-size: 16px;
  line-height: 1.5;
}

/* ========================================
   Form Grid
   ======================================== */

.edit-form {
  margin-bottom: 32px;
}

.result-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
  margin-bottom: 32px;
}

.result-item {
  background: transparent;
  padding: 0;
  border: none;
}

.result-item label {
  font-size: 13px;
  font-weight: 500;
  color: var(--text-secondary);
  display: block;
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 0.02em;
}

.editable-input {
  width: 100%;
  padding: 12px 16px;
  border: 1px solid #D1D1D6;
  border-radius: 12px;
  font-size: 17px;
  font-weight: 400;
  background: #FFFFFF;
  transition: all 0.2s;
  color: var(--text-primary);
  font-family: -apple-system, BlinkMacSystemFont, sans-serif;
}

.editable-input:focus {
  outline: none;
  border-color: var(--color-blue);
  box-shadow: 0 0 0 4px rgba(0, 113, 227, 0.15);
}

.editable-input::placeholder {
  color: #C7C7CC;
}

/* ========================================
   Device Type Classifier
   ======================================== */

.device-type-section {
  background: #F2F2F7;
  padding: 24px;
  border-radius: 16px;
  border: none;
  margin-bottom: 32px;
}

.device-type-section h3 {
  margin: 0 0 16px 0;
  color: var(--text-primary);
  font-size: 17px;
  font-weight: 600;
}

.classification-loading {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  color: var(--text-secondary);
  font-size: 15px;
}

.loading-spinner {
  width: 18px;
  height: 18px;
  border: 2px solid rgba(0,0,0,0.1);
  border-top: 2px solid var(--color-blue);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin-right: 10px;
}

.classification-result {
  text-align: center;
}

.device-type-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  border-radius: 999px;
  color: white;
  font-weight: 500;
  font-size: 15px;
  margin-bottom: 12px;
  box-shadow: none;
}

.classification-text {
  color: var(--text-secondary);
  font-size: 13px;
}

.device-type-manual {
  margin-top: 24px;
  padding-top: 20px;
  border-top: 1px solid rgba(0,0,0,0.05);
}

.device-type-manual label {
  display: block;
  margin-bottom: 12px;
  color: var(--text-secondary);
  font-size: 13px;
  font-weight: 500;
}

.device-type-buttons {
  display: flex;
  gap: 12px;
  justify-content: center;
}

.device-type-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  border: 1px solid transparent;
  border-radius: 999px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 13px;
  background: white;
  color: var(--text-secondary);
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.device-type-btn.active {
  color: white;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

/* ========================================
   Action Buttons
   ======================================== */

.button-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
  margin-bottom: 24px;
  padding-top: 24px;
}

.back-button {
  background: rgba(0,0,0,0.05);
  color: var(--text-primary);
  border: none;
  padding: 12px 24px;
  border-radius: 999px;
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.back-button:hover {
  background: rgba(0,0,0,0.1);
}

.update-button {
  background: var(--color-blue);
  color: white;
  border: none;
  padding: 12px 40px;
  border-radius: 999px;
  font-size: 17px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: none;
  min-width: 160px;
}

.update-button:hover:not(.disabled) {
  background: var(--color-blue-hover);
  transform: scale(1.02);
  box-shadow: 0 4px 12px rgba(0, 113, 227, 0.3);
}

.update-button.disabled {
  background: #E5E5EA;
  color: #8E8E93;
  cursor: not-allowed;
  transform: none;
}

/* States */
.loading, .error {
  text-align: center;
  padding: 80px 24px;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #E5E5EA;
  border-top: 4px solid var(--color-blue);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 16px;
}

@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }

.error-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.error-message {
  background: #FFF2F2;
  color: #FF3B30;
  padding: 16px;
  border-radius: 12px;
  text-align: center;
  font-weight: 500;
  border: 1px solid rgba(255, 59, 48, 0.1);
}

.success-message {
  background: #F2FDF4;
  color: #34C759;
  padding: 16px;
  border-radius: 12px;
  text-align: center;
  font-weight: 500;
  border: 1px solid rgba(52, 199, 89, 0.1);
}

/* Responsive */
@media (max-width: 768px) {
  .user-card {
    flex-direction: column;
    text-align: center;
  }
  
  .user-actions {
    width: 100%;
    justify-content: center;
  }
  
  .edit-card {
    padding: 24px;
  }
  
  .result-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  
  .button-section {
    flex-direction: column-reverse;
    gap: 16px;
  }
  
  .back-button, .update-button {
    width: 100%;
  }
}
</style>
.edit-record {
  min-height: 100vh;
  padding: 2rem 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.container {
