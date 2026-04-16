<template>
  <div class="app" :class="{ 'dark-mode': isDark }">
    <TeacherHeader>
      <template #right>
        <ThemeToggle @theme-changed="handleThemeChange" />
      </template>
    </TeacherHeader>
    
    <main class="main-content">
      <router-view />
    </main>
    
    <!-- AI助手组件 -->
    <TeacherAIAssistant />
    
    <!-- 全局悬浮番茄钟 -->
    <FloatingPomodoroTimer />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import TeacherHeader from '../components/TeacherHeader.vue'
import ThemeToggle from '../components/ThemeToggle.vue'
import TeacherAIAssistant from '../components/TeacherAIAssistant.vue'
import FloatingPomodoroTimer from '../components/FloatingPomodoroTimer.vue'
import { useGlobalPomodoro } from '@/store/pomodoro.js'

const isDark = ref(false)
const globalPomodoro = useGlobalPomodoro()

const handleThemeChange = (darkMode) => {
  isDark.value = darkMode
}

onMounted(async () => {
  // 初始化全局番茄钟状态
  await globalPomodoro.actions.init()
})
</script>

<style scoped>
.app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(to bottom, var(--bg-color), #e0e7ff);
}

.main-content {
  flex: 1;
  padding: 2rem 0;
}

.main-content > *:not(:last-child) {
  margin-bottom: 2rem;
}
</style>
