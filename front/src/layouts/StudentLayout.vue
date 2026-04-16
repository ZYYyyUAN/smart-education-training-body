<template>
  <div class="student-layout">
    <StudentHeader @toggle-bot="$emit('toggle-bot')">
      <template #right>
        <ThemeToggle @theme-changed="$emit('theme-changed', $event)" />
      </template>
    </StudentHeader>
    <main class="student-main">
      <router-view />
    </main>
    
    <!-- 全局悬浮番茄钟 -->
    <FloatingPomodoroTimer />
  </div>
  </template>

<script setup>
import { onMounted } from 'vue'
import StudentHeader from '@/components/StudentHeader.vue'
import ThemeToggle from '@/components/ThemeToggle.vue'
import FloatingPomodoroTimer from '@/components/FloatingPomodoroTimer.vue'
import { useGlobalPomodoro } from '@/store/pomodoro.js'

// 初始化全局番茄钟
const globalPomodoro = useGlobalPomodoro()

onMounted(async () => {
  // 初始化全局番茄钟状态
  await globalPomodoro.actions.init()
})
</script>

<style scoped>
.student-main{ padding: 2rem 0; }
</style>


