<template>
  <header class="header">
    <div class="logo">
      <h1>智教实训通</h1>
      <p>有温度、有感情的个性化智能教学平台</p>
    </div>

    <div class="nav-container">
      <button @click="showChatBot = !showChatBot" class="bot-toggle-btn">🤖</button>

      <nav class="nav">
        <router-link to="/teacher" :class="{ active: isActive('/teacher') }">首页</router-link>
        <router-link to="/teacher_school" :class="{ active: isActive('/teacher_school') }">教学首页</router-link>
        <router-link to="/notice2" :class="{ active: isActive('/notice2') }">消息通知</router-link>
        <a href="/" @click.prevent="onLogout">退出系统</a>
      </nav>
      <div class="avatar-wrapper" @click="goProfile">
        <img v-if="teacherAvatarUrl" :src="teacherAvatarUrl" class="user-avatar" @error="onAvatarError" />
        <div v-else class="avatar-initial">教</div>
      </div>
      <slot name="right"></slot>
    </div>
  </header>
</template>

<script setup>
import { useRouter, useRoute } from 'vue-router'
import { ref, onMounted, onBeforeUnmount } from 'vue'

const router = useRouter()
const route = useRoute()

const showChatBot = ref(false)
const teacherAvatarUrl = ref('')

const isActive = (path) => {
  if (path === '/teacher') return route.path === '/teacher'
  if (path === '/teacher_school') {
    return route.path.startsWith('/teacher_school') && !route.path.startsWith('/teacher_school/profile')
  }
  return route.path.startsWith(path)
}

const onLogout = () => {
  try {
    localStorage.removeItem('token')
    localStorage.removeItem('currentUser')
  } catch (e) {}
  router.replace('/')
}

const loadAvatar = () => {
  const local = localStorage.getItem('teacherAvatarUrl')
  if (local) { teacherAvatarUrl.value = local; return }
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    teacherAvatarUrl.value = user?.avatarUrl || ''
  } catch {}
}
const handleAvatarUpdated = (e) => { teacherAvatarUrl.value = e?.detail || teacherAvatarUrl.value }
const goProfile = () => router.push('/teacher_school/profile')

onMounted(() => {
  loadAvatar()
  window.addEventListener('teacher-avatar-updated', handleAvatarUpdated)
})
onBeforeUnmount(() => window.removeEventListener('teacher-avatar-updated', handleAvatarUpdated))
</script>

<style scoped>
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 32px;
  min-height: 100px;
  background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  border-bottom: 1px solid #e5e7eb;
}

.logo h1 {
  font-size: 2rem;
  color: #0c4ba3; 
  margin-bottom: 0.25rem;
  margin: 0;
}

.logo p {
  font-size: 0.9rem;
  color: var(--secondary-color);
  margin: 0;
}

.nav-container {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.avatar-wrapper { width: 40px; height: 40px; border-radius: 50%; background:#e5e7eb; display:flex; align-items:center; justify-content:center; cursor:pointer; overflow:hidden; }
.user-avatar { width:100%; height:100%; object-fit: cover; }
.avatar-initial { color:#666; font-weight:600; }

.nav {
  display: flex;
  gap: 1.5rem;
  align-items: center;
}

.nav a {
  text-decoration: none;
  color: var(--text-color);
  font-weight: 500;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  transition: 0.3s;
  position: relative;
}

.nav a:hover {
  background-color: var(--hover-bg);
}

.nav a.active {
  color: var(--primary-color);
  font-weight: bold;
}

.nav a.active::after {
  content: "";
  position: absolute;
  left: 0;
  right: 0;
  bottom: -6px;
  height: 3px;
  border-radius: 2px;
  background: var(--primary-color);
}

.bot-toggle-btn {
  background-color: var(--primary-color);
  color: white;
  border: none;
  padding: 0.4rem 0.8rem;
  border-radius: 8px;
  font-size: 1.2rem;
  cursor: pointer;
  box-shadow: 0 4px 10px rgba(30, 58, 138, 0.3);
  transition: transform 0.2s;
}

.bot-toggle-btn:hover {
  transform: scale(1.05);
}
</style>
