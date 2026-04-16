<template>
  <div class="assistant-page">
    <el-page-header @back="goBack" content="AI 助教">
      <template #icon><el-icon><ArrowLeft /></el-icon></template>
    </el-page-header>
    <TeacherAIAssistant />
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { ArrowLeft } from '@element-plus/icons-vue'
import TeacherAIAssistant from '@/components/TeacherAIAssistant.vue'

const router = useRouter()
function goBack() { router.back() }
</script>

<style scoped>
.assistant-page { padding: 16px; max-width: 1100px; margin: 0 auto; }
</style>


