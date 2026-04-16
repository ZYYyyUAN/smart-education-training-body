<template>
  <div class="container mx-auto p-4 max-w-4xl">
    <!-- 答题记录详情 -->
    <el-card shadow="hover" class="mb-6">
      <template #header>
        <div class="flex justify-between items-center">
          <h2 class="text-xl font-bold">答题记录详情</h2>
          <div class="flex space-x-2">
            <el-tag :type="detail.isCorrect ? 'success' : 'danger'" effect="dark">
              {{ detail.isCorrect ? '回答正确' : '回答错误' }}
            </el-tag>
            <el-tag type="info">{{ detail.questionType === 'short_answer' ? '简答题' : 
                  detail.questionType === 'choice' ? '选择题' : '编程题' }}</el-tag>
          </div>
        </div>
      </template>
      
      <div class="space-y-4">
        <div>
          <h3 class="text-lg font-semibold mb-2">题目内容</h3>
          <div class="p-4 bg-gray-50 rounded" v-html="detail.questionContent"></div>
        </div>
        
        <div>
          <h3 class="text-lg font-semibold mb-2">你的回答</h3>
          <div class="p-4 bg-gray-50 rounded">{{ detail.answerText }}</div>
        </div>
        
        <div v-if="!detail.isCorrect">
          <h3 class="text-lg font-semibold mb-2">错误原因</h3>
          <div class="p-4 bg-red-50 text-red-600 rounded">{{ detail.errorReason }}</div>
        </div>
        
        <div>
          <h3 class="text-lg font-semibold mb-2">正确答案</h3>
          <div class="p-4 bg-green-50 text-green-600 rounded">{{ detail.correctAnswer }}</div>
        </div>
        
        <div class="flex justify-between items-center">
          <h3 class="text-lg font-semibold mb-2">得分</h3>
          <span class="text-gray-500">{{ detail.score }}/100</span>
        </div>
         
        <div>
          <h3 class="text-lg font-semibold mb-2">知识点</h3>
          <div class="p-4 bg-green-50 text-green-600 rounded"> {{ detail.knowledgePoint }}</div>
        </div>
      </div>
    </el-card>
   <!-- 重新作答区域 -->
    <el-card shadow="hover">
      <template #header>
        <h2 class="text-xl font-bold">重新作答</h2>
      </template>
      
      <div class="space-y-4">
        <el-input
          v-model="newAnswer"
          type="textarea"
          :rows="5"
          placeholder="请输入你的新答案..."
          resize="none"
        ></el-input>
        
        <div class="flex justify-end space-x-4">
          <el-button @click="resetAnswer">清空</el-button>
          <el-button 
            type="primary" 
            @click="submitAnswer"
            :loading="submitting"
          >
            提交答案
          </el-button>
        </div>
      </div>
    </el-card>
    
     <!-- 生成相似例题区域 -->
  <el-card shadow="hover" class="mb-6">
    <template #header>
      <div class="flex justify-between items-center">
        <h2 class="text-xl font-bold">相似例题</h2>
        <el-button 
          type="primary" 
          :loading="generatingSimilar"
          @click="generateSimilarQuestion"
          class="generate-btn"
        >
          <template #icon>
            <el-icon><MagicStick /></el-icon>
          </template>
          生成相似例题
        </el-button>
      </div>
    </template>
    
    <div v-if="similarQuestions.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div 
        v-for="(question, index) in similarQuestions" 
        :key="index"
        class="question-card"
        @click="practiceSimilarQuestion(question)"
      >
        <div class="card-content">
          <div class="question-type">
            <el-tag :type="getQuestionTypeColor(question.type)" size="small" effect="dark">
              {{ formatQuestionType(question.type) }}
            </el-tag>
          </div>
          <div class="question-text">
            {{ question.content }}
          </div>
          <div class="question-footer">
            <span class="knowledge-point">{{ question.knowledgePoint }}</span>
            <el-button 
              type="text" 
              size="small"
              class="practice-btn"
              @click.stop="practiceSimilarQuestion(question)"
            >
              开始练习 <el-icon><Right /></el-icon>
            </el-button>
          </div>
        </div>
      </div>
    </div>
    
    <el-empty v-else description="暂无相似例题，点击上方按钮生成" />
  </el-card>
        <!-- AI测评结果弹窗 -->
    <el-dialog
      v-model="evaluationDialogVisible"
      title="AI测评结果"
      width="70%"
      top="5vh"
      :close-on-click-modal="false"
    >
      <div class="evaluation-content">
        <div v-html="formattedEvaluation"></div>
      </div>
      <template #footer>
        <el-button type="primary" @click="evaluationDialogVisible = false">确定</el-button>
      </template>
    </el-dialog>
      <!-- 练习题目弹窗 -->
  <el-dialog
    v-model="practiceDialogVisible"
    :title="`练习题目 (${formatQuestionType(currentQuestion.type)})`"
    width="60%"
    top="5vh"
    :close-on-click-modal="false"
  >
    <div class="practice-content">
      <div class="question-content mb-6">
        <h3 class="text-lg font-semibold mb-2">题目内容</h3>
        <div class="p-4 bg-gray-50 rounded">{{ currentQuestion.content }}</div>
      </div>
      
      <div class="answer-area">
        <h3 class="text-lg font-semibold mb-2">你的回答</h3>
        <el-input
          v-model="practiceAnswer"
          type="textarea"
          :rows="8"
          placeholder="请在此输入你的答案..."
          resize="none"
          class="mb-4"
        ></el-input>
      </div>
    </div>
    
    <template #footer>
      <el-button @click="practiceDialogVisible = false">取消</el-button>
      <el-button 
        type="primary" 
        @click="submitPracticeAnswer"
        :loading="submittingPractice"
      >
        提交答案
      </el-button>
    </template>
  </el-dialog>
   
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { MagicStick } from '@element-plus/icons-vue'
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { Right } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()

const detail = ref({
  id: null,
  studentId: null,
  studentName: null,
  questionId: null,
  questionContent: '',
  questionType: '',
  knowledgePoint: '',
  answerText: '',
  isCorrect: false,
  errorReason: '',
  score: 0,
  correctAnswer: '',
  submittedAt: null
})

const newAnswer = ref('')
const similarQuestions = ref([])
const generatingSimilar = ref(false)
const submitting = ref(false)
const evaluationDialogVisible = ref(false)
const evaluationResult = ref('')
const practiceDialogVisible = ref(false)
const currentQuestion = ref({
  type: '',
  content: '',
  answer: '',
  knowledgePoint: ''
})
const practiceAnswer = ref('')
const submittingPractice = ref(false)

// 格式化AI返回的测评内容
const formattedEvaluation = computed(() => {
  // 将Markdown格式转换为HTML
  return evaluationResult.value
    .replace(/^### (.*$)/gm, '<h3 class="eval-title">$1</h3>')
    .replace(/^📌 (.*$)/gm, '<div class="eval-score">$1</div>')
    .replace(/^🔍 (.*$)/gm, '<div class="eval-section"><h4>$1</h4>')
    .replace(/^📘 (.*$)/gm, '<div class="eval-section"><h4>$1</h4>')
    .replace(/^💡 (.*$)/gm, '<div class="eval-section"><h4>$1</h4>')
    .replace(/```([a-z]*)\n([\s\S]*?)\n```/g, '<pre class="eval-code"><code>$2</code></pre>')
    .replace(/`([^`]+)`/g, '<code>$1</code>')
    .replace(/\n/g, '<br>')
})

// 获取答题记录详情
const fetchPracticeLogDetail = async (id) => {
  try {
    const response = await axios.get(`/api/xiaozhi/student/practice/detail?id=${id}`)
    if (response.data.code === 200) {
      detail.value = response.data.data
      newAnswer.value = detail.value.answerText
      // 可以同时加载已有的相似例题
      // await loadSimilarQuestions()
    }
  } catch (error) {
    console.error('获取答题记录详情失败:', error)
    ElMessage.error('获取答题记录详情失败')
  }
}

// 生成相似例题
const generateSimilarQuestion = async () => {
  generatingSimilar.value = true
  try {
    const response = await axios.post('/api/xiaozhi/student/similar/generate', {
      questionId: detail.value.questionId,
      count: 3 // 可以调整为需要的数量
    })
    
    if (response.status === 200) {
      similarQuestions.value = response.data
      ElMessage.success(`成功生成 ${similarQuestions.value.length} 道相似例题`)
    }
  } catch (error) {
    console.error('生成相似例题失败:', error)
    ElMessage.error('生成相似例题失败')
  } finally {
    generatingSimilar.value = false
  }
}


// 练习相似例题
const practiceSimilarQuestion = (question) => {
  currentQuestion.value = { ...question }
  practiceAnswer.value = ''
  practiceDialogVisible.value = true
}
// 提交新答案
const submitAnswer = async () => {
  if (!newAnswer.value.trim()) {
    ElMessage.warning('请输入答案后再提交')
    return
  }
  
  submitting.value = true
  try {
    // 调用评估接口
    const evaluateResponse = await axios.post('/api/xiaozhi/student/evaluate', {
      memoryId: detail.value.id,
      questionId: detail.value.questionId,
      answer: newAnswer.value
    })
    
    // 假设后端返回的是流式数据，这里简化为直接获取完整结果
    evaluationResult.value = evaluateResponse.data
    evaluationDialogVisible.value = true
    
  } catch (error) {
    console.error('提交答案失败:', error)
    ElMessage.error('提交答案失败，请重试')
  } finally {
    submitting.value = false
  }
}
// 格式化题目类型显示
const formatQuestionType = (type) => {
  const types = {
    'choice': '选择题',
    'short_answer': '简答题',
    'programming': '编程题'
  }
  return types[type] || type
}

// 根据题目类型获取标签颜色
const getQuestionTypeColor = (type) => {
  const colors = {
    'choice': 'success',
    'short_answer': 'warning',
    'programming': 'danger'
  }
  return colors[type] || 'info'
}


// 清空答案
const resetAnswer = () => {
  newAnswer.value = ''
}
// 提交练习答案
const submitPracticeAnswer = async () => {
  if (!practiceAnswer.value.trim()) {
    ElMessage.warning('请输入答案后再提交')
    return
  }
  
  submittingPractice.value = true
  try {
      // 使用URL参数形式调用接口
    const evaluateResponse = await axios.post('/api/xiaozhi/student/similar/evaluate', null, {
      params: {
        content: currentQuestion.value.content,
        standardAnswer: currentQuestion.value.answer,
        answer: practiceAnswer.value
      }
    })
    
    // 假设后端返回的是流式数据，这里简化为直接获取完整结果
    evaluationResult.value = evaluateResponse.data
    evaluationDialogVisible.value = true
    practiceDialogVisible.value = false
    
    // 如果是原题的练习，更新答题记录
    if (!currentQuestion.value.questionId) {
      await fetchPracticeLogDetail(detail.value.id)
    }
  } catch (error) {
    console.error('提交答案失败:', error)
    ElMessage.error('提交答案失败，请重试')
  } finally {
    submittingPractice.value = false
  }
}

onMounted(() => {
  const id = route.params.id
  if (id) {
    fetchPracticeLogDetail(id)
  }
})
</script>

<style scoped>
.container {
  min-height: calc(100vh - 64px);
}

:deep(.el-card__header) {
  padding: 16px 20px;
}

:deep(.el-card__body) {
  padding: 20px;
}

/* 测评结果弹窗样式 */
.evaluation-content {
  max-height: 70vh;
  overflow-y: auto;
  padding: 0 10px;
}

.evaluation-content h3 {
  color: #333;
  margin: 20px 0 10px;
  font-size: 1.2em;
}

.evaluation-content h4 {
  color: #444;
  margin: 15px 0 8px;
  font-size: 1.1em;
}

.eval-title {
  color: #409EFF;
  font-size: 1.3em;
  margin-bottom: 15px;
}

.eval-score {
  background-color: #f8f8f8;
  padding: 10px;
  border-left: 4px solid #F56C6C;
  margin: 10px 0;
  font-weight: bold;
}

.eval-section {
  margin: 15px 0;
  padding: 10px;
  background-color: #f9f9f9;
  border-radius: 4px;
}

.eval-code {
  background-color: #f5f5f5;
  padding: 10px;
  border-radius: 4px;
  margin: 10px 0;
  overflow-x: auto;
}

.eval-code code {
  font-family: 'Courier New', Courier, monospace;
  color: #333;
}

:deep(.el-dialog__body) {
  padding: 20px;
}


.similar-question {
  background-color: #fafafa;
  border-color: #e5e7eb;
  transition: all 0.3s ease;
}

.similar-question:hover {
  background-color: #f8fafc;
  border-color: #d1d5db;
  transform: translateY(-2px);
}

/* 题目内容样式 */
.similar-question h3 {
  color: #333;
  line-height: 1.6;
}

/* 标签样式 */
:deep(.el-tag) {
  height: 24px;
  line-height: 22px;
  font-size: 12px;
}
/* 生成按钮样式 */
.generate-btn {
  background: linear-gradient(135deg, #409EFF, #36D1DC);
  border: none;
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.3);
}

/* 题目卡片样式 */
.question-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
  cursor: pointer;
  overflow: hidden;
  border: 1px solid #f0f0f0;
  height: 100%;
}

.question-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
  border-color: #e0e0e0;
}

.card-content {
  padding: 16px;
  display: flex;
  flex-direction: column;
  height: 100%;
}

.question-type {
  margin-bottom: 12px;
}

.question-text {
  flex: 1;
  font-size: 14px;
  line-height: 1.6;
  color: #333;
  margin-bottom: 16px;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.question-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
}

.knowledge-point {
  font-size: 12px;
  color: #666;
  background: #f5f5f5;
  padding: 4px 8px;
  border-radius: 4px;
}

.practice-btn {
  color: #409EFF;
  padding: 4px 8px;
  transition: all 0.2s;
}

.practice-btn:hover {
  color: #36D1DC;
  transform: translateX(2px);
}

/* 响应式调整 */
@media (max-width: 768px) {
  .question-text {
    -webkit-line-clamp: 2;
  }
}
/* 练习弹窗样式 */
.practice-content {
  max-height: 70vh;
  overflow-y: auto;
  padding: 0 10px;
}

.question-content {
  background: #fff;
  border-radius: 8px;
  padding: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.answer-area {
  background: #fff;
  border-radius: 8px;
  padding: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

:deep(.el-textarea__inner) {
  font-size: 14px;
  line-height: 1.6;
  padding: 12px;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
}

:deep(.el-dialog__body) {
  padding: 20px;
}
</style>