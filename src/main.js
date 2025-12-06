import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'
import Leaderboard from './views/Leaderboard.vue'
import Upload from './views/Upload.vue'
import ConfirmResult from './views/ConfirmResult.vue'
import BenchmarkDetail from './views/BenchmarkDetail.vue'
import EditRecord from './views/EditRecord.vue'
import OAuthCallback from './views/OAuthCallback.vue'

const routes = [
  { path: '/', name: 'Leaderboard', component: Leaderboard },
  { path: '/upload', name: 'Upload', component: Upload },
  { path: '/confirm', name: 'ConfirmResult', component: ConfirmResult },
  { path: '/detail', name: 'BenchmarkDetail', component: BenchmarkDetail },
  { path: '/edit', name: 'EditRecord', component: EditRecord },
  { path: '/parse-result', name: 'ParseResult', component: Upload }, // 保留兼容性
  { path: '/oauth/callback', name: 'OAuthCallback', component: OAuthCallback }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

const app = createApp(App)
app.use(router)
app.mount('#app')