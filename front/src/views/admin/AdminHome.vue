<template>
  <div class="visual-container">
    <div class="home-layout" :class="{ 'full-width': activeNav === 2 || activeNav === 3 || activeNav === 4 || activeNav === 5 }">
      <!-- 大屏概览 (activeNav === 0) - 三栏布局 -->
      <template v-if="activeNav === 0">
        <OverviewPanel />
      </template>

      <!-- 用户管理 (activeNav === 1) - 全屏 -->
      <div v-else-if="activeNav === 1" class="content-area">
        <UserManagement />
      </div>

      <!-- 题库管理 (activeNav === 2) - 全屏 -->
      <div v-else-if="activeNav === 2" class="content-area">
        <AdminQuestionBankManagement />
      </div>

      <!-- 作业考试管理 (activeNav === 3) - 全屏 -->
      <div v-else-if="activeNav === 3" class="content-area">
        <AdminHomeworkExamManagement />
      </div>

      <!-- 课程资源管理 (activeNav === 4) - 全屏 -->
      <div v-else-if="activeNav === 4" class="content-area">
        <CourseResourceDashboard />
      </div>

      <!-- 学情信息管理 (activeNav === 5) - 全屏 -->
      <div v-else-if="activeNav === 5" class="content-area">
        <StudentAnalysis />
      </div>

      <!-- 底部导航菜单 -->
      <div class="bottom-nav-menu">
         <div class="nav-btn" v-for="(nav, idx) in bottomNavs" :key="idx" :class="{active: activeNav === idx}" @click="handleNavClick(nav, idx)">
           <div class="nav-icon-wrapper">
             <div class="nav-icon-bg">
               <div class="icon-glow"></div>
               <el-icon class="nav-icon"><component :is="nav.icon" /></el-icon>
               <div class="active-ring" v-if="activeNav === idx"></div>
             </div>
             <div class="nav-text">{{ nav.name }}</div>
             <div class="nav-indicator" v-if="activeNav === idx"></div>
           </div>
         </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { 
  User, Avatar, Reading, Monitor, 
  DataLine, Connection
} from '@element-plus/icons-vue'
import OverviewPanel from './components/OverviewPanel.vue'
import CourseResourceDashboard from './CourseResourceDashboard.vue'
import AdminQuestionBankManagement from './AdminQuestionBankManagement.vue'
import AdminHomeworkExamManagement from './AdminHomeworkExamManagement.vue'
import UserManagement from './UserManagement.vue'
import StudentAnalysis from './StudentAnalysis.vue'

// 定义组件映射
// 0: 大屏概览 -> OverviewPanel
// 1: 用户管理 -> UserManagement
// 2: 题库管理 -> AdminQuestionBankManagement
// 3: 作业考试管理 -> AdminHomeworkExamManagement
// 4: 课程资源管理 -> CourseResourceDashboard
// 5: 学情信息管理 -> StudentAnalysis
const activeNav = ref(0)

const bottomNavs = [
  { name: '大屏概览', icon: User },
  { name: '用户管理', icon: Avatar },
  { name: '题库管理', icon: DataLine },
  { name: '作业考试管理', icon: Connection },
  { name: '课程资源管理', icon: Reading },
  { name: '学情信息管理', icon: Monitor }
]

// 统一导航点击处理 - 所有模块跳转都通过这里管理
const handleNavClick = (nav, idx) => {
  activeNav.value = idx
  // 不再使用路由跳转，统一在当前页面切换模块
}
</script>

<style scoped>
.visual-container {
  height: 100%;
  width: 100%;
  color: #fff;
  font-family: "Microsoft YaHei", sans-serif;
  position: relative;
  overflow: visible;
}

.home-layout {
  height: 100%;
  width: 100%;
  position: relative;
  display: flex;
  flex-direction: column;
  overflow: visible;
}

.home-layout.full-width .content-area {
  width: 100%;
  max-width: 100%;
  min-height: calc(100vh - 120px);
  overflow-y: auto;
  overflow-x: hidden;
  padding: 0;
  padding-bottom: 70px;
}

/* 内容区域 */
.content-area {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  position: relative;
  padding-bottom: 70px; /* 为底部导航留出空间 */
  min-height: calc(100vh - 120px); /* 确保有足够的高度 */
  width: 100%;
}

.placeholder-content {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 400px;
}

.placeholder-text {
  text-align: center;
  color: rgba(255, 255, 255, 0.7);
}

.placeholder-icon {
  font-size: 64px;
  color: rgba(0, 191, 255, 0.5);
  margin-bottom: 20px;
}

.placeholder-text h2 {
  font-size: 24px;
  margin: 10px 0;
  color: rgba(255, 255, 255, 0.9);
}

.placeholder-text p {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.6);
}

/* 底部导航菜单 */
.bottom-nav-menu {
  position: fixed !important;
  bottom: 10px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  justify-content: center;
  gap: 15px;
  height: auto;
  align-items: center;
  padding: 10px 25px;
  z-index: 9999 !important;
  width: 100%;
  max-width: 1400px;
  background: transparent;
  backdrop-filter: none;
  border: none;
  border-radius: 0;
  box-shadow: none;
  position: relative;
  overflow: visible;
  pointer-events: auto;
}

.bottom-nav-menu::before {
  display: none;
}

@keyframes scanLine {
  0%, 100% { opacity: 0.5; }
  50% { opacity: 1; }
}

.nav-btn {
  position: relative;
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.nav-icon-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  padding: 5px 10px;
  border-radius: 12px;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.nav-btn:hover .nav-icon-wrapper {
  transform: translateY(-5px);
  background: rgba(0, 242, 254, 0.1);
}

.nav-btn.active .nav-icon-wrapper {
  transform: translateY(-6px);
  background: rgba(0, 242, 254, 0.15);
}

.nav-icon-bg {
  width: 48px;
  height: 48px;
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  margin-bottom: 6px;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.nav-icon-bg::before {
  content: '';
  position: absolute;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background: linear-gradient(135deg, 
    rgba(0, 242, 254, 0.2) 0%,
    rgba(0, 191, 255, 0.1) 50%,
    rgba(0, 242, 254, 0.2) 100%);
  border: 2px solid rgba(0, 242, 254, 0.4);
  box-shadow: 
    0 0 20px rgba(0, 242, 254, 0.3),
    inset 0 0 20px rgba(0, 242, 254, 0.1);
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.nav-btn:hover .nav-icon-bg::before,
.nav-btn.active .nav-icon-bg::before {
  border-color: rgba(0, 242, 254, 0.8);
  box-shadow: 
    0 0 30px rgba(0, 242, 254, 0.6),
    0 0 60px rgba(0, 191, 255, 0.4),
    inset 0 0 30px rgba(0, 242, 254, 0.2);
  transform: scale(1.1);
}

.nav-btn.active .nav-icon-bg::before {
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    box-shadow: 
      0 0 30px rgba(0, 242, 254, 0.6),
      0 0 60px rgba(0, 191, 255, 0.4),
      inset 0 0 30px rgba(0, 242, 254, 0.2);
  }
  50% {
    box-shadow: 
      0 0 40px rgba(0, 242, 254, 0.9),
      0 0 80px rgba(0, 191, 255, 0.6),
      inset 0 0 40px rgba(0, 242, 254, 0.3);
  }
}

.icon-glow {
  position: absolute;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background: radial-gradient(circle, 
    rgba(0, 242, 254, 0.4) 0%,
    rgba(0, 191, 255, 0.2) 40%,
    transparent 70%);
  opacity: 0;
  transition: opacity 0.4s;
  pointer-events: none;
}

.nav-btn:hover .icon-glow,
.nav-btn.active .icon-glow {
  opacity: 1;
  animation: glowPulse 2s ease-in-out infinite;
}

@keyframes glowPulse {
  0%, 100% { transform: scale(1); opacity: 0.6; }
  50% { transform: scale(1.2); opacity: 1; }
}

.nav-icon {
  position: relative;
  z-index: 2;
  font-size: 22px;
  color: rgba(255, 255, 255, 0.9);
  transition: all 0.4s;
  filter: drop-shadow(0 0 8px rgba(0, 242, 254, 0.5));
}

.nav-btn:hover .nav-icon,
.nav-btn.active .nav-icon {
  color: #00f2fe;
  transform: scale(1.15);
  filter: drop-shadow(0 0 15px rgba(0, 242, 254, 1));
}

.active-ring {
  position: absolute;
  width: 60px;
  height: 60px;
  border: 2px solid rgba(0, 242, 254, 0.6);
  border-radius: 50%;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  animation: rotateRing 3s linear infinite;
  pointer-events: none;
}

.active-ring::before {
  content: '';
  position: absolute;
  width: 68px;
  height: 68px;
  border: 1px solid rgba(0, 191, 255, 0.4);
  border-radius: 50%;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  animation: rotateRing 4s linear infinite reverse;
}

@keyframes rotateRing {
  0% { transform: translate(-50%, -50%) rotate(0deg); }
  100% { transform: translate(-50%, -50%) rotate(360deg); }
}

.nav-text {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.8);
  text-shadow: 0 0 10px rgba(0, 242, 254, 0.5);
  font-weight: 500;
  letter-spacing: 0.3px;
  transition: all 0.4s;
  margin-top: 2px;
  position: relative;
  z-index: 2;
}

.nav-btn:hover .nav-text,
.nav-btn.active .nav-text {
  color: #00f2fe;
  text-shadow: 
    0 0 15px rgba(0, 242, 254, 1),
    0 0 30px rgba(0, 191, 255, 0.8);
  transform: scale(1.05);
}

.nav-indicator {
  position: absolute;
  bottom: -2px;
  left: 50%;
  transform: translateX(-50%);
  width: 40px;
  height: 3px;
  background: linear-gradient(90deg, 
    transparent 0%,
    rgba(0, 242, 254, 1) 50%,
    transparent 100%);
  border-radius: 2px;
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.8);
  animation: indicatorPulse 2s ease-in-out infinite;
}

@keyframes indicatorPulse {
  0%, 100% {
    width: 40px;
    opacity: 1;
  }
  50% {
    width: 50px;
    opacity: 0.8;
  }
}
</style>
