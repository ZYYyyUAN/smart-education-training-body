<template>
  <div class="p-6 bg-gradient-to-br from-purple-100 via-pink-100 to-red-100 rounded-2xl shadow-inner backdrop-blur-md">
    <h2 class="text-2xl font-bold text-gray-800 mb-4 flex items-center gap-2">
      🎯 相似例题巩固练习
    </h2>

    <div class="flex gap-2 mb-4">
      <el-button type="primary" @click="generateExample">生成新例题</el-button>
      <el-button type="danger" @click="clearExamples" :disabled="examples.length === 0">删除全部</el-button>
    </div>

    <el-empty v-if="examples.length === 0" description="快来生成你的专属例题吧！" />

    <div v-else class="grid gap-4 grid-cols-1 md:grid-cols-2">
      <el-card
        v-for="(item, index) in examples"
        :key="index"
        shadow="always"
        class="glass-card hover:scale-105 transition duration-300"
      >
        <div class="flex items-center justify-between mb-2">
          <p class="font-semibold text-gray-800">例题 {{ index + 1 }}</p>
          <el-tag v-if="item.isWrong" type="danger" effect="dark">错题待纠正</el-tag>
        </div>

        <p class="text-gray-700 mb-2 leading-relaxed">{{ item.content }}</p>

        <div class="flex flex-col gap-2">
          <div class="flex gap-2 justify-end">
            <el-button size="small" type="success" @click="openDialog(item)">前往作答</el-button>
            <el-button size="small" type="warning" @click="regenerateExample(index)">重新生成</el-button>
          </div>
          <el-button
            v-if="item.showAnswer"
            size="small"
            type="info"
            plain
            @click="viewExplanation(item)"
          >
            查看解析
          </el-button>
        </div>
      </el-card>
    </div>

    <!-- 作答弹窗 -->
    <el-dialog v-model="dialogVisible" title="练习作答" width="550px" :close-on-click-modal="false">
      <div class="mb-3">
        <p class="mb-1 font-semibold">题目：</p>
        <el-alert :title="currentExample.content" type="info" />
      </div>

      <el-input v-model="answer" type="textarea" :rows="4" placeholder="在此输入你的答案..." />

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitAnswer">提交答案</el-button>
      </template>
    </el-dialog>

    <!-- Markdown解析 弹窗 -->
    <el-dialog v-model="explanationVisible" title="参考解析" width="650px">
      <v-md-preview :text="explanationData.explanation" />

      <template #footer>
        <el-button type="primary" @click="explanationVisible = false">我知道了</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ElMessageBox, ElMessage } from 'element-plus'
import axios from 'axios'
import * as VMdPreview from '@kangc/v-md-editor/lib/preview'
import '@kangc/v-md-editor/lib/style/preview.css'
import { useUserStore } from '@/store/user.js'

// 示例数据管理
const examples = ref([])
const dialogVisible = ref(false)
const explanationVisible = ref(false)

const currentExample = ref(null)
const answer = ref('')

// 解析数据
const explanationData = ref({ explanation: '' })

// function generateExample() {
//   const content = inputExample.value
//     ? `${inputExample.value}（生成的例题）`
//     : `系统随机例题 #${Math.floor(Math.random() * 1000)}`
//   const answer = '这是标准答案示例'
//   const explanation = '这是针对该题目的详细解析说明，帮助你理解和巩固。'
//   examples.value.push({
//     content,
//     answer,
//     explanation,
//     isWrong: false,
//     showAnswer: false
//   })
//   ElMessage.success('新例题已生成！')
// }
function getRandomQuestionType() {
  const types = ['short_answer', 'programming', 'choice']
  return types[Math.floor(Math.random() * types.length)]
}

async function generateExample() {
  try {
    const { data } = await axios.post('/xiaozhi/student/generate/history', {
      studentId: useUserStore().currentUserId,
      courseId: 101,
      questionType: getRandomQuestionType(),
      count: 1
    })

    const question = (data.data && data.data[0]) || null
    if (!question) {
      ElMessage.warning('未查询到符合条件的例题')
      return
    }

    examples.value.push({
      content: question.content || '未返回题目内容',
      answer: question.answer || '未返回答案',
      explanation: '由后端生成的练习题，无解析',
      isWrong: false,
      showAnswer: false
    })

    ElMessage.success('新例题已生成！')
  } catch (err) {
    ElMessage.error('生成例题失败，请稍后重试')
  }
}

function clearExamples() {
  ElMessageBox.confirm('确认删除全部例题吗？', '警告', {
    confirmButtonText: '确认',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    examples.value = []
    ElMessage.success('已删除所有例题')
  })
}

// function regenerateExample(index) {
//   examples.value[index] = {
//     content: `重新生成的例题 #${Math.floor(Math.random() * 1000)}`,
//     answer: '这是标准答案示例',
//     explanation: '这是针对该题目的详细解析说明。',
//     isWrong: false,
//     showAnswer: false
//   }
//   ElMessage.success('已重新生成该例题')
// }
async function regenerateExample(index) {
  try {
    const { data } = await axios.post('/xiaozhi/student/generate/history', {
      studentId: useUserStore().currentUserId,
      courseId: 101,
      questionType: getRandomQuestionType(),
      count: 1
    })

    const question = (data.data && data.data[0]) || null
    if (!question) {
      ElMessage.warning('未查询到符合条件的例题')
      return
    }

    examples.value[index] = {
      content: question.content || '未返回题目内容',
      answer: question.answer || '未返回答案',
      explanation: '由后端重新生成的练习题',
      isWrong: false,
      showAnswer: false
    }

    ElMessage.success('已重新生成该例题')
  } catch (err) {
    ElMessage.error('重新生成失败，请稍后重试')
  }
}


function openDialog(item) {
  currentExample.value = item
  answer.value = ''
  dialogVisible.value = true
}

// 提交答案，获取解析
async function submitAnswer() {
  try {
    const { data } = await axios.post('/xiaozhi/student/evaluate', {
      studentId: useUserStore().currentUserId,
      questionId: currentExample.value.id,
      answer: answer.value
    })

    currentExample.value.showAnswer = true
    currentExample.value.isWrong = false  // 你可以按需标错

    explanationData.value = {
      explanation: data || '未返回解析内容'
    }

    explanationVisible.value = true
    ElMessage.success('解析已生成，快去查看吧！')
  } catch (err) {
    ElMessage.error('提交失败，请稍后重试')
  } finally {
    dialogVisible.value = false
  }
}

function viewExplanation(item) {
  explanationData.value = {
    explanation: item.explanation || '暂无解析，请先作答'
  }
  explanationVisible.value = true
}
</script>

<style scoped>
.glass-card {
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(10px);
  border-radius: 1rem;
  border: 1px solid rgba(255, 255, 255, 0.3);
  transition: all 0.3s ease;
}

.glass-card:hover {
  transform: scale(1.02);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
}
</style>
