<template>
  <div class="home">
    <div class="container">
      <div class="parse-card">
        <div class="card-header">
          <h2>📊 基准测试结果解析</h2>
          <p>请粘贴您的基准测试结果文本，系统将自动解析并结构化显示</p>
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
            <span v-if="!isParsing">🔍 解析结果</span>
            <span v-else>⏳ 解析中...</span>
          </button>
        </div>

        <div v-if="error" class="error-message">
          ❌ {{ error }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const benchmarkText = ref('')
const isParsing = ref(false)
const error = ref('')
const router = useRouter()

const parseBenchmark = async () => {
  if (!benchmarkText.value.trim()) {
    error.value = '请输入基准测试结果文本'
    return
  }

  isParsing.value = true
  error.value = ''

  try {
    const parsedData = parseBenchmarkText(benchmarkText.value)

    if (!parsedData) {
      error.value = '解析失败，请检查输入格式是否正确'
      isParsing.value = false
      return
    }

    // 存储解析结果到 sessionStorage
    sessionStorage.setItem('parsedBenchmark', JSON.stringify(parsedData))

    // 跳转到确认页面
    await router.push('/parse-result')
  } catch (err) {
    error.value = '解析过程中发生错误: ' + err.message
  } finally {
    isParsing.value = false
  }
}

const parseBenchmarkText = (text) => {
  try {
    const result = {
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
    }

    // 解析系统信息 - 更灵活的匹配
    const cpuMatch = text.match(/CPU\s*[:\s]\s*(.+?)(?:\n|$)/i)
    const coresMatch = text.match(/(?:Cores|cores?|Cores?_logical)\s*[:\s]\s*(\d+)/i)
    const memoryMatch = text.match(/Memory\s*[:\s]\s*([\d.]+)\s*(?:GB|gb|GiB|gib)/i)

    if (cpuMatch) result.systemInfo.cpu = cpuMatch[1].trim()
    if (coresMatch) result.systemInfo.cores = parseInt(coresMatch[1]) || null
    if (memoryMatch) result.systemInfo.memory = parseFloat(memoryMatch[1]) || null

    // 解析 Phase 1 - 多种匹配方式
    const phase1Patterns = [
      /\[Phase\s*1\][\s\S]*?wall_time\s*[:\s]\s*([\d.]+)\s*s/i,
      /\[Phase\s*1\][\s\S]*?finished\s+in\s+([\d.]+)\s*s/i,
      /Phase\s*1[\s\S]*?([\d.]+)\s*s/i
    ]

    for (const pattern of phase1Patterns) {
      const match = text.match(pattern)
      if (match) {
        result.phase1.wallTime = parseFloat(match[1])
        break
      }
    }

    // 解析 Phase 2 - 多种匹配方式
    const phase2Patterns = [
      /\[Phase\s*2\][\s\S]*?wall_time\s*[:\s]\s*([\d.]+)\s*s/i,
      /\[Phase\s*2\][\s\S]*?finished\s+in\s+([\d.]+)\s*s/i,
      /Phase\s*2[\s\S]*?([\d.]+)\s*s/i
    ]

    for (const pattern of phase2Patterns) {
      const match = text.match(pattern)
      if (match) {
        result.phase2.wallTime = parseFloat(match[1])
        break
      }
    }

    // 解析总体时间 - 多种匹配方式
    const totalTimePatterns = [
      /\[Overall\][\s\S]*?wall_time\s*[:\s]\s*([\d.]+)\s*s/i,
      /\[Overall\][\s\S]*?total\s+wall_time:\s*([\d.]+)\s*s/i,
      /overall[\s\S]*?([\d.]+)\s*s/i,
      /total[\s\S]*?wall_time:\s*([\d.]+)\s*s/i
    ]

    for (const pattern of totalTimePatterns) {
      const match = text.match(pattern)
      if (match) {
        result.overall.wallTime = parseFloat(match[1])
        break
      }
    }

    // 改进验证逻辑 - 只要有一个时间信息就认为解析成功
    const hasAnyTimeData = result.phase1.wallTime || result.phase2.wallTime || result.overall.wallTime

    if (!hasAnyTimeData) {
      return null
    }

    return result
  } catch (err) {
    console.error('Parse error:', err)
    return null
  }
}
</script>

<style scoped>
.home {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  min-height: calc(100vh - 200px);
  padding: 2rem 0;
}

.container {
  width: 100%;
  max-width: 800px;
}

.parse-card {
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

.input-section {
  margin-bottom: 2rem;
}

.input-section label {
  display: block;
  color: #333;
  font-weight: 600;
  margin-bottom: 0.8rem;
  font-size: 1.1rem;
}

.benchmark-textarea {
  width: 100%;
  min-height: 400px;
  padding: 1rem;
  border: 2px solid #e1e5e9;
  border-radius: 12px;
  font-family: 'Consolas', 'Monaco', monospace;
  font-size: 0.95rem;
  line-height: 1.6;
  resize: vertical;
  transition: all 0.3s ease;
  background: #f8f9fa;
}

.benchmark-textarea:focus {
  outline: none;
  border-color: #667eea;
  background: white;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.button-section {
  text-align: center;
}

.parse-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 1rem 3rem;
  border-radius: 50px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
}

.parse-button:hover:not(.disabled) {
  transform: translateY(-2px);
  box-shadow: 0 15px 40px rgba(102, 126, 234, 0.4);
}

.parse-button.disabled {
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

@media (max-width: 768px) {
  .parse-card {
    padding: 1.5rem;
    margin: 0 1rem;
  }

  .benchmark-textarea {
    min-height: 300px;
  }

  .parse-button {
    width: 100%;
    padding: 1rem;
  }
}
</style>