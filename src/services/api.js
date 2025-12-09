// API 服务层 - 与后端API通信

// 动态获取 API 基础 URL
function getApiBaseUrl() {
  // 如果有环境变量配置，优先使用
  if (import.meta.env.VITE_API_URL) {
    return import.meta.env.VITE_API_URL
  }

  // 始终使用相对路径，让Vite代理处理
  // 这样可以避免跨域问题，因为Vite代理会将API请求转发到后端
  return ''  // 空字符串表示使用相对路径，通过Vite代理
}

const API_PREFIX = '/api/v1'

class ApiService {
  constructor() {
    this.baseURL = getApiBaseUrl()
  }

  // 获取请求头（不再需要手动设置Authorization，cookie会自动发送）
  getHeaders() {
    const headers = {
      'Content-Type': 'application/json'
    }

    // 注意：不再设置Authorization header，因为现在使用cookie认证
    return headers
  }

  // 通用请求方法
  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${API_PREFIX}${endpoint}`
    const headers = this.getHeaders()

    // 调试日志
    console.log('API请求:', url)
    console.log('请求头:', headers)
    console.log('注意：使用cookie认证，不再需要Authorization header')

    const config = {
      headers: headers,
      credentials: 'include',  // 确保发送cookie
      ...options
    }

    try {
      const response = await fetch(url, config)

      // 处理HTTP错误状态
      if (!response.ok) {
        let errorMessage = `HTTP ${response.status}: ${response.statusText}`

        try {
          // 尝试解析错误响应中的详细信息
          const errorData = await response.json()
          if (errorData.detail) {
            errorMessage = errorData.detail
          } else if (errorData.message) {
            errorMessage = errorData.message
          }
        } catch (parseError) {
          // 如果解析JSON失败，使用默认错误消息
        }

        if (response.status === 401) {
          throw new Error('认证失败，请重新登录')
        } else if (response.status === 400) {
          // 对于400错误，提供更友好的错误信息
          throw new Error(errorMessage)
        } else if (response.status === 403) {
          throw new Error('权限不足，无法执行此操作')
        } else if (response.status === 404) {
          throw new Error('请求的资源不存在')
        } else if (response.status === 422) {
          throw new Error('请求参数格式不正确：' + errorMessage)
        } else {
          throw new Error(errorMessage)
        }
      }

      const data = await response.json()
      return data
    } catch (error) {
      console.error('API请求失败:', error)
      throw error
    }
  }

  // GET 请求
  async get(endpoint) {
    return this.request(endpoint, { method: 'GET' })
  }

  // POST 请求
  async post(endpoint, data = null) {
    return this.request(endpoint, {
      method: 'POST',
      body: data ? JSON.stringify(data) : null
    })
  }

  // PUT 请求
  async put(endpoint, data = null) {
    return this.request(endpoint, {
      method: 'PUT',
      body: data ? JSON.stringify(data) : null
    })
  }

  // DELETE 请求
  async delete(endpoint) {
    return this.request(endpoint, { method: 'DELETE' })
  }

  // OAuth 认证相关API
  async getLoginUrl() {
    return this.get('/auth/login')
  }

  async handleOAuthCallback(code) {
    return this.post('/auth/linuxdo/callback', { code })
  }

  async getCurrentUser() {
    return this.get('/auth/me')
  }

  async verifyToken() {
    return this.get('/auth/verify-token')
  }

  async logout() {
    const result = await this.post('/auth/logout')
    // 不再需要清除localStorage，使用cookie认证
    return result
  }

  // Mock登录（仅用于本地测试）
  async mockLogin(username, email = null) {
    return this.post('/auth/mock-login', { username, email })
  }

  // 基准测试相关API
  async parseBenchmarkText(text) {
    return this.post('/benchmarks/parse', { text })
  }

  async submitBenchmark(data) {
    return this.post('/benchmarks/submit', data)
  }

  async getMyResults(page = 1, limit = 20) {
    return this.get(`/benchmarks/my-results?page=${page}&limit=${limit}`)
  }

  async getBenchmarkResult(id) {
    return this.get(`/benchmarks/${id}`)
  }

  async updateBenchmarkResult(id, data) {
    return this.put(`/benchmarks/${id}`, data)
  }

  async deleteBenchmarkResult(id) {
    return this.delete(`/benchmarks/${id}`)
  }

  // 用户相关API
  async getUserProfile() {
    return this.get('/users/profile')
  }

  // 系统相关API
  async getHealth() {
    return this.get('/health')
  }
}

// 创建单例实例
const apiService = new ApiService()

export default apiService

// 导出常用的方法
export const {
  getLoginUrl,
  handleOAuthCallback,
  getCurrentUser,
  verifyToken,
  logout,
  mockLogin,
  parseBenchmarkText,
  submitBenchmark,
  getMyResults,
  getBenchmarkResult,
  updateBenchmarkResult,
  deleteBenchmarkResult,
  getUserProfile,
  getHealth
} = {
  getLoginUrl: () => apiService.getLoginUrl(),
  handleOAuthCallback: (code) => apiService.handleOAuthCallback(code),
  getCurrentUser: () => apiService.getCurrentUser(),
  verifyToken: () => apiService.verifyToken(),
  logout: () => apiService.logout(),
  mockLogin: (username, email) => apiService.mockLogin(username, email),
  parseBenchmarkText: (text) => apiService.parseBenchmarkText(text),
  submitBenchmark: (data) => apiService.submitBenchmark(data),
  getMyResults: (page, limit) => apiService.getMyResults(page, limit),
  getBenchmarkResult: (id) => apiService.getBenchmarkResult(id),
  updateBenchmarkResult: (id, data) => apiService.updateBenchmarkResult(id, data),
  deleteBenchmarkResult: (id) => apiService.deleteBenchmarkResult(id),
  getUserProfile: () => apiService.getUserProfile(),
  getHealth: () => apiService.getHealth()
}