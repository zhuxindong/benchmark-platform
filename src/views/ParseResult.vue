<template>
  <div class="parse-result">
    <div class="container">
      <div class="confirm-card">
        <div class="card-header">
          <h2>✅ 解析结果确认</h2>
          <p>请检查以下解析结果，如需修改请直接编辑，确认无误后点击提交</p>
        </div>

        <div class="result-sections">
          <!-- 系统信息 -->
          <div class="result-section">
            <h3>💻 系统信息</h3>
            <p class="section-hint">💡 系统信息为可选项，如解析失败可手动填写或留空</p>
            <div class="form-grid">
              <div class="form-group">
                <label>CPU <span class="optional-tag">(可选)</span>:</label>
                <input
                  v-model="parsedData.systemInfo.cpu"
                  type="text"
                  class="form-input"
                  placeholder="处理器型号，如：AMD Ryzen 7 6800H"
                />
              </div>
              <div class="form-group">
                <label>核心数 <span class="optional-tag">(可选)</span>:</label>
                <input
                  v-model.number="parsedData.systemInfo.cores"
                  type="number"
                  class="form-input"
                  placeholder="逻辑核心数量，如：16"
                />
              </div>
              <div class="form-group">
                <label>内存 (GB) <span class="optional-tag">(可选)</span>:</label>
                <input
                  v-model.number="parsedData.systemInfo.memory"
                  type="number"
                  step="0.1"
                  class="form-input"
                  placeholder="内存大小，如：7.8"
                />
              </div>
            </div>
          </div>

          <!-- Phase 1 信息 -->
          <div class="result-section">
            <h3>⚡ Phase 1 - HMAC 暴力破解</h3>
            <p class="section-hint">💡 至少需要填写一个时间数据（Phase 1、Phase 2 或总耗时）</p>
            <div class="form-grid">
              <div class="form-group">
                <label>耗时 (秒) <span class="required-tag">*</span>:</label>
                <input
                  v-model.number="parsedData.phase1.wallTime"
                  type="number"
                  step="0.001"
                  class="form-input"
                  :class="{ 'is-empty': !parsedData.phase1.wallTime }"
                  placeholder="如：64.642"
                />
              </div>
            </div>
          </div>

          <!-- Phase 2 信息 -->
          <div class="result-section">
            <h3>🔧 Phase 2 - LLL 浮点基准测试</h3>
            <div class="form-grid">
              <div class="form-group">
                <label>耗时 (秒) <span class="required-tag">*</span>:</label>
                <input
                  v-model.number="parsedData.phase2.wallTime"
                  type="number"
                  step="0.001"
                  class="form-input"
                  :class="{ 'is-empty': !parsedData.phase2.wallTime }"
                  placeholder="如：71.761"
                />
              </div>
            </div>
          </div>

          <!-- 总体信息 -->
          <div class="result-section">
            <h3>📊 总体信息</h3>
            <div class="form-grid">
              <div class="form-group">
                <label>总耗时 (秒) <span class="required-tag">*</span>:</label>
                <input
                  v-model.number="parsedData.overall.wallTime"
                  type="number"
                  step="0.001"
                  class="form-input"
                  :class="{ 'is-empty': !parsedData.overall.wallTime }"
                  placeholder="如：136.405"
                />
              </div>
            </div>
          </div>
        </div>

        <div class="action-buttons">
          <button @click="goBack" class="back-button">
            ← 返回重新解析
          </button>
          <button
            @click="submitResults"
            :disabled="isSubmitting"
            class="submit-button"
          >
            <span v-if="!isSubmitting">📤 确认提交</span>
            <span v-else>⏳ 提交中...</span>
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
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const parsedData = ref({
  systemInfo: {
    cpu: '',
    cores: null,
    memory: null
  },
  phase1: {
    wallTime: null
  },
  phase2: {
    wallTime: null
  },
  overall: {
    wallTime: null
  }
})

const isSubmitting = ref(false)
const error = ref('')
const success = ref('')

onMounted(() => {
  // 从 sessionStorage 获取解析的数据
  const storedData = sessionStorage.getItem('parsedBenchmark')
  if (storedData) {
    try {
      parsedData.value = JSON.parse(storedData)
    } catch (err) {
      error.value = '数据加载失败，请重新解析'
    }
  } else {
    // 如果没有数据，返回首页
    router.push('/')
  }
})

const goBack = () => {
  router.push('/')
}

const submitResults = async () => {
  if (!validateData()) {
    return
  }

  isSubmitting.value = true
  error.value = ''
  success.value = ''

  try {
    // 这里将来会调用后端 API
    // 目前模拟提交过程
    await new Promise(resolve => setTimeout(resolve, 2000))

    // 保存提交结果到 sessionStorage (临时存储)
    const submissions = JSON.parse(sessionStorage.getItem('submissions') || '[]')
    submissions.push({
      ...parsedData.value,
      timestamp: new Date().toISOString(),
      id: Date.now()
    })
    sessionStorage.setItem('submissions', JSON.stringify(submissions))

    success.value = '基准测试结果提交成功！即将跳转到排行榜...'

    // 延迟跳转到排行榜页面（将来实现）
    setTimeout(() => {
      // router.push('/leaderboard')
      alert('排行榜功能正在开发中，请稍后再试')
      router.push('/')
    }, 2000)
  } catch (err) {
    error.value = '提交失败: ' + err.message
  } finally {
    isSubmitting.value = false
  }
}

const validateData = () => {
  // 灵活的验证逻辑 - 只验证必填项，允许用户留空可选信息
  const errors = []

  // CPU是可选的，如果填写了就不能为空
  if (parsedData.value.systemInfo.cpu && parsedData.value.systemInfo.cpu.trim() === '') {
    errors.push('CPU 型号不能为空字符串')
  }

  // 核心数如果填写了必须大于0
  if (parsedData.value.systemInfo.cores !== null && parsedData.value.systemInfo.cores <= 0) {
    errors.push('核心数必须大于0')
  }

  // 内存如果填写了必须大于0
  if (parsedData.value.systemInfo.memory !== null && parsedData.value.systemInfo.memory <= 0) {
    errors.push('内存大小必须大于0')
  }

  // 至少需要有一个时间数据
  const hasTimeData = parsedData.value.phase1.wallTime ||
                     parsedData.value.phase2.wallTime ||
                     parsedData.value.overall.wallTime

  if (!hasTimeData) {
    errors.push('至少需要提供一个时间数据（Phase 1、Phase 2 或总耗时）')
  }

  // 验证时间数据格式
  if (parsedData.value.phase1.wallTime !== null && parsedData.value.phase1.wallTime <= 0) {
    errors.push('Phase 1 耗时必须大于0')
  }

  if (parsedData.value.phase2.wallTime !== null && parsedData.value.phase2.wallTime <= 0) {
    errors.push('Phase 2 耗时必须大于0')
  }

  if (parsedData.value.overall.wallTime !== null && parsedData.value.overall.wallTime <= 0) {
    errors.push('总耗时必须大于0')
  }

  if (errors.length > 0) {
    error.value = errors.join('；')
    return false
  }

  return true
}
</script>

<style scoped>
.parse-result {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  min-height: calc(100vh - 200px);
  padding: 2rem 0;
}

.container {
  width: 100%;
  max-width: 900px;
}

.confirm-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  padding: 2.5rem;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.card-header {
  text-align: center;
  margin-bottom: 2rem;
}

.card-header h2 {
  color: #333;
  font-size: 2rem;
  margin-bottom: 0.5rem;
}

.card-header p {
  color: #666;
  font-size: 1.1rem;
}

.result-sections {
  margin-bottom: 2rem;
}

.result-section {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  border: 1px solid #e9ecef;
}

.result-section h3 {
  color: #495057;
  font-size: 1.3rem;
  margin-bottom: 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.section-hint {
  color: #6c757d;
  font-size: 0.9rem;
  margin-bottom: 1rem;
  font-style: italic;
}

.optional-tag {
  color: #28a745;
  font-size: 0.8rem;
  font-weight: normal;
}

.required-tag {
  color: #dc3545;
  font-size: 0.8rem;
  font-weight: normal;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group label {
  color: #495057;
  font-weight: 600;
  font-size: 0.95rem;
}

.form-input {
  padding: 0.75rem;
  border: 2px solid #dee2e6;
  border-radius: 8px;
  font-size: 1rem;
  transition: all 0.3s ease;
  background: white;
}

.form-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-input.is-empty {
  border-color: #ffc107;
  background: #fffdf7;
}

.action-buttons {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-top: 2rem;
}

.back-button {
  background: #6c757d;
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 50px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.back-button:hover {
  background: #5a6268;
  transform: translateY(-2px);
}

.submit-button {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
  color: white;
  border: none;
  padding: 1rem 2.5rem;
  border-radius: 50px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 10px 30px rgba(40, 167, 69, 0.3);
}

.submit-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 15px 40px rgba(40, 167, 69, 0.4);
}

.submit-button:disabled {
  background: #ccc;
  cursor: not-allowed;
  box-shadow: none;
}

.error-message {
  margin-top: 1rem;
  padding: 1rem;
  background: #fee;
  color: #c33;
  border-radius: 8px;
  border: 1px solid #fcc;
  text-align: center;
  font-weight: 500;
}

.success-message {
  margin-top: 1rem;
  padding: 1rem;
  background: #eef7ee;
  color: #2d6a2d;
  border-radius: 8px;
  border: 1px solid #c3e6cb;
  text-align: center;
  font-weight: 500;
}

@media (max-width: 768px) {
  .confirm-card {
    padding: 1.5rem;
    margin: 0 1rem;
  }

  .form-grid {
    grid-template-columns: 1fr;
  }

  .action-buttons {
    flex-direction: column;
  }

  .back-button,
  .submit-button {
    width: 100%;
  }
}
</style>