import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

// 动态获取 API 基础 URL
function getApiBaseUrl() {
  // 如果有环境变量配置，优先使用
  if (process.env.VITE_API_URL) {
    return process.env.VITE_API_URL
  }

  // 检查是否在Docker容器中运行
  const isDockerEnvironment = process.env.VITE_DOCKER === 'true' || process.env.NODE_ENV === 'production'

  if (isDockerEnvironment) {
    return 'http://localhost:8000'  // Docker容器内直接连接后端服务
  }

  // 否则根据当前页面动态构建 API URL
  return 'http://localhost:8000'
}

// 从环境变量读取允许的主机，支持任意域名
const allowedHosts = process.env.VITE_ALLOWED_HOSTS
  ? process.env.VITE_ALLOWED_HOSTS.split(',').map(host => host.trim())
  : 'all'  // 默认允许所有

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src')
    }
  },
  server: {
    port: 3000,
    host: '0.0.0.0',  // 监听所有网络接口
    allowedHosts: allowedHosts === 'all' ? true : allowedHosts,  // 如果是 'all' 则设为 true 允许所有主机
    proxy: {
      // 代理 /api/v1/* 到后端服务
      '/api/v1': {
        target: getApiBaseUrl(),
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/api\/v1/, '/api/v1')  // 保持路径不变
      }
    }
  }
})