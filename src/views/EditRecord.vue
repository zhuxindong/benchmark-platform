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
.edit-record {
  min-height: 100vh;
  padding: 2rem 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.container {
  max-width: 900px;
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

.edit-card {
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

.loading, .error {
  text-align: center;
  padding: 4rem 2rem;
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

.error-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
}

.retry-button {
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

.retry-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
}

.edit-form {
  margin-bottom: 2rem;
}

.result-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.result-item {
  background: #f8f9fa;
  padding: 1.2rem;
  border-radius: 12px;
  border-left: 4px solid #667eea;
}

.result-item label {
  font-weight: 600;
  color: #333;
  display: block;
  margin-bottom: 0.5rem;
}

.editable-input {
  width: 100%;
  padding: 0.6rem 0.8rem;
  border: 2px solid #e1e5e9;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 500;
  background: white;
  transition: all 0.3s ease;
  color: #333;
}

.editable-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.editable-input::placeholder {
  color: #999;
  font-style: italic;
}

/* 设备类型分类样式 */
.device-type-section {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 12px;
  border: 1px solid #e9ecef;
  margin-bottom: 2rem;
}

.device-type-section h3 {
  margin: 0 0 1rem 0;
  color: #333;
  font-size: 1.2rem;
}

.device-type-display {
  margin-bottom: 1.5rem;
}

.classification-loading {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  color: #666;
  font-style: italic;
}

.loading-spinner {
  display: inline-block;
  width: 20px;
  height: 20px;
  border: 2px solid #f3f3f3;
  border-top: 2px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-right: 0.5rem;
}

.classification-result {
  text-align: center;
}

.device-type-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.8rem 1.2rem;
  border-radius: 25px;
  color: white;
  font-weight: 600;
  font-size: 1rem;
  margin-bottom: 0.8rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.device-type-badge .device-icon {
  font-size: 1.2rem;
}

.device-type-badge .device-text {
  font-size: 1.1rem;
}

.device-type-badge .confidence {
  font-size: 0.9rem;
  opacity: 0.9;
  font-weight: 500;
}

.classification-text {
  color: #666;
  font-size: 0.9rem;
  font-style: italic;
}

.device-type-manual {
  margin-top: 1rem;
}

.device-type-manual label {
  display: block;
  margin-bottom: 0.8rem;
  color: #333;
  font-weight: 600;
}

.device-type-buttons {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

.device-type-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.8rem 1.2rem;
  border: 2px solid;
  border-radius: 20px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.95rem;
  background: white;
}

.device-type-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.device-type-btn.active {
  color: white;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.25);
}

.device-type-btn .device-icon {
  font-size: 1rem;
}

.button-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.back-button {
  background: #6c757d;
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 25px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.back-button:hover {
  background: #5a6268;
  transform: translateY(-2px);
}

.update-button {
  background: linear-gradient(135deg, #51cf66 0%, #37b24d 100%);
  color: white;
  border: none;
  padding: 1rem 3rem;
  border-radius: 25px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 10px 30px rgba(81, 207, 102, 0.3);
  min-width: 150px;
}

.update-button:hover:not(.disabled) {
  transform: translateY(-2px);
  box-shadow: 0 15px 40px rgba(81, 207, 102, 0.4);
}

.update-button.disabled {
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

  .edit-card {
    padding: 2rem 1.5rem;
  }

  .card-header h2 {
    font-size: 1.8rem;
  }

  .result-grid {
    grid-template-columns: 1fr;
  }

  .button-section {
    flex-direction: column;
  }

  .back-button, .update-button {
    width: 100%;
  }
}
</style>