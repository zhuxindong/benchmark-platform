import { reactive, computed } from 'vue'
import apiService from '../services/api.js'

// 响应式认证状态
export const authState = reactive({
  isAuthenticated: false,
  user: null,
  loading: false,
  error: null
})

// 计算属性
export const isLoggedIn = computed(() => authState.isAuthenticated && authState.user)

export const currentUser = computed(() => authState.user)

export const authError = computed(() => authState.error)

// 认证相关方法
export const authActions = {
  // 检查登录状态
  async checkAuthStatus() {
    try {
      authState.loading = true
      authState.error = null

      // 通过API验证令牌（会自动使用cookie）
      const userData = await apiService.getCurrentUser()

      authState.user = userData
      authState.isAuthenticated = true
      return true
    } catch (error) {
      console.error('检查认证状态失败:', error)
      // 不设置错误状态，避免未登录用户看到错误提示
      authState.isAuthenticated = false
      authState.user = null
      return false
    } finally {
      authState.loading = false
    }
  },

  // 处理OAuth登录（现在只用于测试，实际不再需要）
  async handleOAuthLogin(code) {
    try {
      authState.loading = true
      authState.error = null

      const result = await apiService.handleOAuthCallback(code)

      if (result.success) {
        // 设置用户信息
        authState.user = result.user
        authState.isAuthenticated = true

        return {
          success: true,
          user: result.user
        }
      } else {
        throw new Error(result.message || '登录失败')
      }
    } catch (error) {
      console.error('OAuth登录失败:', error)
      authState.error = error.message
      return {
        success: false,
        error: error.message
      }
    } finally {
      authState.loading = false
    }
  },

  // 登出
  async logout() {
    try {
      authState.loading = true

      // 调用登出API（会清除cookie）
      await apiService.logout()

      // 清除本地状态
      authState.isAuthenticated = false
      authState.user = null
      authState.error = null

      return { success: true }
    } catch (error) {
      console.error('登出失败:', error)
      return { success: false, error: error.message }
    } finally {
      authState.loading = false
    }
  },

  // 开始OAuth登录流程
  async startOAuthLogin() {
    try {
      authState.loading = true
      authState.error = null

      const loginData = await apiService.getLoginUrl()

      // 重定向到OAuth授权页面
      window.location.href = loginData.authorization_url

      return loginData
    } catch (error) {
      console.error('获取登录URL失败:', error)
      authState.error = error.message
      authState.loading = false
      return null
    }
  },

  // 清除错误
  clearError() {
    authState.error = null
  }
}

// 初始化认证状态
export function initializeAuth() {
  // 静默检查是否已登录，不显示错误
  authActions.checkAuthStatus().catch(() => {
    // 静默忽略错误，不显示给用户
  })
}

// 检查URL中的OAuth回调参数
export function handleOAuthCallback() {
  const urlParams = new URLSearchParams(window.location.search)
  const success = urlParams.get('success')
  const username = urlParams.get('username')
  const user_id = urlParams.get('user_id')
  const user_do_id = urlParams.get('user_do_id')
  const avatar_url = urlParams.get('avatar_url')
  const email = urlParams.get('email')
  const error = urlParams.get('error')

  console.log('DEBUG: handleOAuthCallback called with params:', {
    success,
    username,
    user_id,
    error
  })

  if (error) {
    authState.error = `OAuth授权失败: ${error}`
    return {
      success: false,
      error: `OAuth授权失败: ${error}`
    }
  }

  // OAuth成功，直接设置用户信息（token已经通过cookie设置）
  if (success === 'true') {
    console.log('DEBUG: Processing OAuth callback success')
    try {
      // 更新认证状态 - 直接使用URL参数中的用户信息
      authState.isAuthenticated = true
      authState.user = {
        id: parseInt(user_id),
        username: username,
        user_do_id: user_do_id,
        email: email || null,
        avatar_url: avatar_url || null
      }
      authState.error = null

      return {
        success: true,
        user: authState.user
      }
    } catch (error) {
      console.error('设置认证状态失败:', error)
      authState.error = '设置登录信息失败'
      return {
        success: false,
        error: '设置登录信息失败'
      }
    }
  }

  console.log('DEBUG: No OAuth callback parameters found, returning null')
  return null
}