<template>
  <div class="exam-confirm">
    <el-card class="confirm-card" shadow="hover">
      <h2>重要提醒 - 考试规则确认</h2>
      <p class="tip">请在开始考试前确认以下事项：</p>
      <ol class="rules">
        <li><b>监控设备：</b>摄像头和麦克风已开启并正常运行</li>
        <li><b>考试环境：</b>独立空间，无他人协助，光线充足</li>
        <li><b>行为规范：</b>
          <ul>
            <li>全程保持摄像头开启</li>
            <li>不得使用任何辅助工具</li>
            <li>不得离开考试页面</li>
            <li>不得与他人通讯</li>
          </ul>
        </li>
        <li><b>违规后果：</b>违反上述任一规定将视为作弊</li>
      </ol>
      <el-checkbox v-model="agreed">我已阅读并同意遵守以上规则</el-checkbox>
      <div class="actions">
        <el-button type="primary" :disabled="!agreed" @click="startExam">开始考试</el-button>
        <el-button @click="router.back()">返回</el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()
const agreed = ref(false)

const startExam = () => {
  router.push({ name: 'TakeExam', params: { id: route.params.id } })
}
</script>

<style scoped>
.exam-confirm { display:flex; justify-content:center; padding:40px; }
.confirm-card { max-width: 800px; width:100%; }
.rules { margin: 12px 0 16px; }
.rules ul { margin: 6px 0 0 20px; list-style: disc; }
.actions { margin-top: 16px; display:flex; gap:12px }
</style>


