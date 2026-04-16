<template>
  <header class="header">
    <div class="logo">
      <h1>智教实训通</h1>
      <p>有温度、有感情的个性化智能教学平台</p>
    </div>

    <div class="nav-container">
      <nav class="nav">
        <router-link to="/student" :class="{ active: isActive('/student') }">首页</router-link>
        <router-link to="/student/my_school" :class="{ active: isActive('/student/my_school') }">我的学堂</router-link>
        <router-link to="/student/notice" :class="{ active: isActive('/student/notice') }">消息通知</router-link>
        <a href="/" @click.prevent="onLogout">退出系统</a>
      </nav>
      <div class="right-slot">
        <!-- 番茄钟快速启动 -->
        <PomodoroQuickStart />
        <slot name="right"></slot>
        <div class="avatar" @click="goProfile" title="个人信息">
          <img :src="avatarSrc" alt="avatar" v-if="avatarSrc" @error="onImgErr" />
          <span v-else>{{ avatarInitial }}</span>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup>
import { useRouter, useRoute } from 'vue-router'
import { computed, onMounted } from 'vue'
import PomodoroQuickStart from '@/components/PomodoroQuickStart.vue'
const router = useRouter()
const route = useRoute()

const isActive = (path) => {
  if (path === '/student') return route.path === '/student'
  return route.path.startsWith(path)
}

const onLogout = () => {
  try {
    localStorage.removeItem('token')
    localStorage.removeItem('currentUser')
  } catch (e) {}
  router.replace('/')
}

// 头像数据（可从登录信息/后端替换）
const avatarSrc = computed(() => {
  try {
    const raw = localStorage.getItem('studentAvatarUrl') || ''
    if (!raw) return ''
    try { return decodeURI(raw) === raw ? encodeURI(raw) : raw } catch { return raw }
  } catch { return '' }
})
const avatarInitial = computed(() => {
  const name = (localStorage.getItem('currentUserName') || '学').trim()
  return name.charAt(0)
})

const goProfile = () => {
  router.push('/student/profile')
}

const onImgErr = (e) => {
  try { localStorage.removeItem('studentAvatarUrl') } catch {}
}

onMounted(() => {
  window.addEventListener('student-avatar-updated', () => {
    // 触发依赖 localStorage 的计算属性重新求值
    const tmp = localStorage.getItem('studentAvatarUrl') || ''
    try { localStorage.setItem('studentAvatarUrl', tmp) } catch {}
  })
})
</script>

<style scoped>
.header { 
  display: flex; 
  align-items: center; 
  justify-content: space-between; 
  padding: 24px 32px; 
  min-height: 100px;
  background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
  border-bottom: 1px solid #e2e8f0;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}
.logo h1 {
  font-size: 2rem;
  color: #0c4ba3; 
  margin-bottom: 0.25rem;
  margin: 0;
}
.logo p { 
  margin: 4px 0 0 0; 
  color: #6b7280; 
  font-size: 13px; 
}
.nav-container { 
  display: flex; 
  align-items: center; 
  gap: 16px; 
}
.nav { display:flex; gap:24px; align-items:center; flex-wrap: nowrap; }
.nav a { 
  position: relative; 
  color: #1f2d3d; 
  text-decoration: none; 
  padding: 8px 12px; 
  white-space: nowrap; 
  border-radius: 6px;
  transition: all 0.3s ease;
  font-weight: 500;
}
.nav a:hover {
  color: #1a56db;
  background: rgba(26, 86, 219, 0.1);
}
.nav a.active { 
  color: #1a56db; 
  font-weight: 700; 
  background: rgba(26, 86, 219, 0.15);
}
.nav a.active::after { 
  content: ""; 
  position: absolute; 
  left: 50%; 
  transform: translateX(-50%);
  bottom: -12px; 
  width: 6px;
  height: 6px; 
  border-radius: 50%; 
  background: #1a56db; 
}
.bot-toggle-btn { border:none; background:#203a86; color:#fff; width:44px; height:44px; border-radius:12px; }
.right-slot{ display:flex; align-items:center; gap:12px; flex-wrap: nowrap; }
.avatar{ 
  width: 40px; 
  height: 40px; 
  border-radius: 50%; 
  background: #1a56db; 
  color: #fff; 
  display: flex; 
  align-items: center; 
  justify-content: center; 
  font-weight: 700; 
  cursor: pointer; 
  overflow: hidden; 
  transition: all 0.3s ease;
  border: 2px solid transparent;
}
.avatar:hover {
  transform: scale(1.05);
  border-color: #1a56db;
  box-shadow: 0 4px 12px rgba(26, 86, 219, 0.3);
}
.avatar img{ 
  width: 100%; 
  height: 100%; 
  object-fit: cover; 
}
</style>


