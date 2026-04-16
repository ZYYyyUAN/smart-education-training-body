<template>
  <div class="dashboard-container">
    <!-- 头部由 TeacherLayout 提供，这里不再渲染本地头部 -->
    <Sidebar />
    <div class="main-content">
      <router-view></router-view>
    </div>
  </div>
</template>

<script>
import { onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import Sidebar from './components/Sidebar.vue'

export default {
  components: {
    Sidebar
  },
  setup() {
    const route = useRoute()
    
    onMounted(() => {
      console.log('Dashboard component mounted')
    })
    
    // 监听路由变化
    watch(() => route.path, (newPath, oldPath) => {
      console.log('Route changed from', oldPath, 'to', newPath)
    })
  }
}
</script>

<style scoped>
.dashboard-container {
  display: flex;
  width: 100%;
  min-height: 100vh;
  align-items: flex-start;
}

.main-content {
  flex: 1;
  padding: 0;
  background: #f8fafc;
  height: calc(100vh - 40px);
  position: relative;
  overflow-y: auto;
  margin: 20px 20px 20px 0;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

/* 自定义滚动条样式 */
.main-content::-webkit-scrollbar {
  width: 6px;
}

.main-content::-webkit-scrollbar-track {
  background: #f1f5f9;
  border-radius: 3px;
}

.main-content::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

.main-content::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}

.main-content::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    radial-gradient(circle at 20% 80%, rgba(59, 130, 246, 0.05) 0%, transparent 50%),
    radial-gradient(circle at 80% 20%, rgba(16, 185, 129, 0.05) 0%, transparent 50%),
    radial-gradient(circle at 40% 40%, rgba(139, 92, 246, 0.03) 0%, transparent 50%);
  pointer-events: none;
}

.chat-float-panel {
  position: fixed;
  top: 90px;
  right: 30px;
  width: 420px;
  height: 80vh;
  background-color: var(--card-bg);
  box-shadow: -4px 0 24px rgba(0, 0, 0, 0.1);
  border-radius: var(--border-radius);
  z-index: 999;
  overflow: hidden;
  padding: 1rem;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}




.dashboard-main {
  padding-top: 0.5rem;
  padding-bottom: 0;
}




/* .course-card:hover {
  transform: scale(1.05);
}

.card-links {
  display: flex;
  justify-content: space-between;
  margin-top: 1rem;
  font-size: 13px;
  text-decoration: underline;
} */

.assistant {
  position: fixed;
  bottom: 1.5rem;
  right: 1.5rem;
  background: #7c3aed;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 9999px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
  font-weight: 500;
}
</style>
