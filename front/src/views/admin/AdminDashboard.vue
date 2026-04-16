<template>
  <div class="admin-layout">
    <div class="stars-bg"></div>
    
    <!-- 顶部标题栏 -->
    <header class="admin-header">
      <div class="header-left">
        <div class="welcome-info" v-if="adminInfo">
          <span class="welcome-text">欢迎回来！{{ adminInfo.realName || adminInfo.username }}</span>
          <span class="divider">|</span>
          <span class="school-name">{{ adminInfo.school || '智慧教育平台' }}</span>
        </div>
      </div>
      
      <div class="header-center">
        <h1 class="main-title">智教实训通数字孪生管理平台</h1>
        <div class="title-decoration-left"></div>
        <div class="title-decoration-right"></div>
        <div class="sub-title">DIGITAL TWIN PERCEPTION SYSTEM FOR SMART EDUCATION</div>
      </div>
      
      <div class="header-right">
        <span class="time">{{ currentTime }}</span>
        <el-button link class="exit-btn" @click="logout">
          <el-icon><SwitchButton /></el-icon>
        </el-button>
      </div>
    </header>

    <!-- 主体内容区 -->
    <main class="admin-main">
      <router-view v-slot="{ Component }">
        <transition name="fade-transform" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>

    <!-- 底部导航栏已移至 AdminHome.vue 统一管理 -->
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { 
  SwitchButton
} from '@element-plus/icons-vue'
import { ElMessageBox } from 'element-plus'
import { useUserStore } from '@/store/user.js'

const router = useRouter()
const currentTime = ref('')

// 获取管理员信息
const userStore = useUserStore()
const adminInfo = computed(() => {
  try {
    const currentUser = userStore.currentUser || JSON.parse(localStorage.getItem('currentUser') || 'null')
    if (currentUser && currentUser.role === 'admin') {
      return currentUser
    }
    return null
  } catch {
    return null
  }
})

// 导航逻辑已移至 AdminHome.vue 统一管理

const updateTime = () => {
  const now = new Date()
  currentTime.value = now.toLocaleTimeString('zh-CN', { hour12: false })
}

let timer = null

onMounted(() => {
  updateTime()
  timer = setInterval(updateTime, 1000)
})

onUnmounted(() => {
  if (timer) clearInterval(timer)
})

const logout = () => {
  ElMessageBox.confirm('确定要退出管理系统吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
    router.push('/')
  })
}
</script>

<style scoped>
.admin-layout {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: #050a1a;
  background-image: 
    radial-gradient(circle at 50% 50%, rgba(16, 34, 73, 1) 0%, rgba(5, 10, 26, 1) 100%);
  color: #fff;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  font-family: "Microsoft YaHei", sans-serif;
}

.stars-bg {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image: 
    radial-gradient(1px 1px at 20px 30px, #fff, rgba(0,0,0,0)),
    radial-gradient(1px 1px at 40px 70px, #fff, rgba(0,0,0,0)),
    radial-gradient(1px 1px at 50px 160px, #fff, rgba(0,0,0,0)),
    radial-gradient(1px 1px at 80px 120px, #fff, rgba(0,0,0,0)),
    radial-gradient(1px 1px at 110px 10px, #fff, rgba(0,0,0,0)),
    radial-gradient(1px 1px at 150px 150px, #fff, rgba(0,0,0,0));
  background-repeat: repeat;
  background-size: 200px 200px;
  opacity: 0.3;
  pointer-events: none;
}

/* Header */
.admin-header {
  height: 80px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 30px;
  position: relative;
  z-index: 10;
  background: linear-gradient(to bottom, rgba(10, 20, 50, 0.9) 0%, rgba(10, 20, 50, 0) 100%);
  border-bottom: 1px solid rgba(0, 191, 255, 0.1);
}

.header-left, .header-right {
  flex: 1;
  display: flex;
  align-items: center;
}

.header-left {
  font-size: 14px;
  color: #00bfff;
}

.welcome-info {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 14px;
}

.welcome-text {
  color: #00f2fe;
  font-weight: 500;
  text-shadow: 0 0 5px rgba(0, 242, 254, 0.5);
}

.school-name {
  color: #00bfff;
  font-weight: 500;
  text-shadow: 0 0 5px rgba(0, 191, 255, 0.5);
}

.divider {
  color: rgba(255, 255, 255, 0.3);
  margin: 0 5px;
}

.header-center {
  flex: 2;
  text-align: center;
  position: relative;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.main-title {
  font-size: 32px;
  font-weight: bold;
  letter-spacing: 4px;
  color: #fff;
  text-shadow: 0 0 10px rgba(0, 191, 255, 0.8);
  margin: 0;
  position: relative;
  display: inline-block;
  background: linear-gradient(to bottom, #fff, #87cefa);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.sub-title {
  font-size: 10px;
  color: #00bfff;
  letter-spacing: 2px;
  margin-top: 5px;
  opacity: 0.8;
}

.header-right {
  justify-content: flex-end;
  gap: 20px;
}

.time {
  font-size: 20px;
  font-family: 'Digital', sans-serif;
  color: #fff;
  text-shadow: 0 0 5px rgba(0, 191, 255, 0.5);
}

.exit-btn {
  color: #ff4d4f;
  font-size: 18px;
}

/* Main Content */
.admin-main {
  flex: 1;
  padding: 10px 20px 20px;
  overflow: hidden;
  position: relative;
  z-index: 5;
}

/* Footer Navigation 已移至 AdminHome.vue */

/* Transitions */
.fade-transform-enter-active,
.fade-transform-leave-active {
  transition: all 0.5s ease;
}

.fade-transform-enter-from {
  opacity: 0;
  transform: scale(0.98);
}

.fade-transform-leave-to {
  opacity: 0;
  transform: scale(0.98);
}
</style>
