<template>
  <div class="do-work-container">
    <el-page-header @back="router.go(-1)" content="作业作答" />
    
    <el-card class="work-info-card">
      <template #header>
        <div class="work-header">
          <h2>{{ assignment.title }}</h2>
          <el-tag :type="isSubmitted ? 'success' : 'warning'">
            {{ isSubmitted ? '已提交' : '未提交' }}
          </el-tag>
        </div>
      </template>
      
      <div class="work-meta">
        <div class="meta-item">
          <el-icon><Calendar /></el-icon>
          <span>截止日期：{{ formatDate(assignment.dueDate) }}</span>
        </div>
        <div class="meta-item" v-if="submittedAt">
          <el-icon><Clock /></el-icon>
          <span>提交时间：{{ formatDate(submittedAt) }}</span>
        </div>
        <div class="meta-item" v-if="score !== undefined">
          <el-icon><Star /></el-icon>
          <span>得分：<strong :class="scoreClass">{{ score }}/100</strong></span>
        </div>
      </div>
      
      <el-divider />
      
      <div class="work-description">
        <h3>作业说明</h3>
        <p>{{ assignment.description || '暂无详细说明' }}</p>
      </div>
    </el-card>
    
    <div class="questions-container">
      <el-card
        v-for="(question, index) in questions"
        :key="question.id"
        class="question-card"
        :class="{ 'has-score': question.score !== undefined }"
      >
        <template #header>
          <div class="question-header">
            <span class="question-index">题目 {{ index + 1 }}</span>
            <el-tag>{{ formatQuestionType(question.type) }}</el-tag>
          </div>
        </template>
        
        <div class="question-content">
          <div v-html="question.content" class="content-render"></div>
          <div class="knowledge-point">
            <el-tag type="info" size="small">知识点：{{ question.knowledgePoint }}</el-tag>
          </div>
        </div>
        
        <div class="answer-area">
          <h4>我的回答</h4>
        <el-input
  v-model="question.studentAnswer"
  type="textarea"
  :rows="4"
  placeholder="请输入你的答案..."
  resize="none"
  :disabled="isReadOnly"  
/>
          
          <div v-if="question.score !== undefined" class="feedback-area">
            <el-divider />
            <h4>参考答案</h4>
            <p>{{ question.answer }}</p>
          </div>
        </div>
      </el-card>
    </div>
    
    <div class="action-bar">
      <el-button @click="router.go(-1)">返回</el-button>
      <el-button
        type="primary"
        @click="submitWork"
        :loading="submitting"
        v-if="!isReadOnly"
      >
        提交作业
      </el-button>
      <el-button
        type="primary"
        @click="redoWork"
        v-else
      >
        重新提交
      </el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Calendar, Clock, Star } from '@element-plus/icons-vue'
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user.js'

const route = useRoute()
const router = useRouter()
// 作业数据
const assignment = ref({
  id: null,
  title: '',
  description: '',
  dueDate: null,
  createdAt: null
})

// 题目列表
const questions = ref([])

// 提交状态相关
const submittedAt = ref(null)
const score = ref(null)
const submitting = ref(false)

const isReadOnly = ref(false); // 改为ref而不是computed

// 保留原有的isSubmitted计算属性
const isSubmitted = computed(() => !!submittedAt.value);

// 分数样式
const scoreClass = computed(() => {
  if (score.value === undefined) return ''
  if (score.value >= 80) return 'high-score'
  if (score.value >= 60) return 'medium-score'
  return 'low-score'
})

// 获取作业详情
const fetchWorkDetail = async () => {
  try {
   const id = String(route.params.id)
    const response = await axios.get('/api/xiaozhi/teacher/detail', {
      params: {
        assignmentId: id
      }
    })
    
    if (response.data.code === 200) {
      const data = response.data.data
      assignment.value = data.assignment
      questions.value = data.questions.map(q => ({
        ...q,
        studentAnswer: '', // 初始化学生答案为空
        score: undefined  // 初始化分数
      }))
      
      // TODO: 这里需要根据实际情况获取提交状态和分数
      // submittedAt.value = ...
      // score.value = ...
    }
  } catch (error) {
    console.error('获取作业详情失败:', error)
    ElMessage.error('获取作业详情失败')
  }
}

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return '暂无'
  return new Date(dateString).toLocaleDateString()
}

// 格式化题目类型
const formatQuestionType = (type) => {
  const types = {
    'short_answer': '简答题',
    'choice': '选择题',
    'programming': '编程题'
  }
  return types[type] || type
}

// 提交作业
const submitWork = async () => {
  submitting.value = true;
  try {
    const id = String(route.params.id); // 确保获取当前作业ID
    
    // 验证是否有未作答的题目
    const unanswered = questions.value.filter(q => !q.studentAnswer?.trim());
    if (unanswered.length > 0) {
      ElMessage.warning(`请完成第${unanswered.map(q => questions.value.indexOf(q) + 1).join(',')}题后再提交`);
      return;
    }

    const response = await axios.post('/api/xiaozhi/student/submit', {
      assignmentId: id,
      studentId: useUserStore().currentUserId,
      details: questions.value.map(q => ({
        questionId: q.id,
        answerText: q.studentAnswer
      }))
    });
    
    if (response.data.code === 200) {
      ElMessage.success('作业提交成功');
      // 更新本地提交状态
      submittedAt.value = new Date().toISOString();
      isReadOnly.value = true; // 设置为只读模式
      
      // 如果有返回分数，更新分数
      if (response.data.data?.score) {
        score.value = response.data.data.score;
      }
    } else {
      ElMessage.error(response.data.message || '提交失败');
    }
  } catch (error) {
    console.error('提交作业失败:', error);
    let errorMsg = '提交失败，请稍后再试';
    if (error.response) {
      errorMsg = error.response.data.message || errorMsg;
    }
    ElMessage.error(errorMsg);
  } finally {
    submitting.value = false;
  }
};

const redoWork = () => {
  submittedAt.value = null;
  score.value = undefined;
  isReadOnly.value = false;
  questions.value.forEach(q => {
    q.studentAnswer = '';
    q.score = undefined;
  });
  ElMessage.info('现在可以修改答案并重新提交');
};

onMounted(() => {
  fetchWorkDetail()
})
</script>

<style scoped>
.do-work-container {
  max-width: 900px;
  margin: 0 auto;
  padding: 20px;
}

.work-info-card {
  margin-bottom: 20px;
}

.work-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.work-meta {
  display: flex;
  gap: 20px;
  margin-top: 10px;
  color: #666;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 5px;
}

.high-score {
  color: #67C23A;
}

.medium-score {
  color: #E6A23C;
}

.low-score {
  color: #F56C6C;
}

.work-description {
  margin-top: 15px;
}

.work-description h3 {
  margin-bottom: 10px;
  color: #333;
}

.questions-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.question-card {
  transition: all 0.3s ease;
}

.question-card:hover {
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.question-index {
  font-weight: bold;
  color: #409EFF;
}

.content-render {
  line-height: 1.6;
}

.content-render :deep(p) {
  margin-bottom: 10px;
}

.content-render :deep(pre) {
  background-color: #f5f5f5;
  padding: 10px;
  border-radius: 4px;
  overflow-x: auto;
}

.knowledge-point {
  margin-top: 10px;
}

.answer-area {
  margin-top: 15px;
}

.answer-area h4 {
  margin-bottom: 10px;
  color: #333;
}

.feedback-area {
  margin-top: 15px;
  padding: 10px;
  background-color: #f8f8f8;
  border-radius: 4px;
}

.feedback-area h4 {
  margin-bottom: 5px;
  color: #666;
}

.action-bar {
  display: flex;
  justify-content: center;
  margin-top: 30px;
  gap: 20px;
}

.has-score :deep(.el-textarea__inner) {
  background-color: #f5f5f5;
}
</style>