<template>
  <div class="page-background">
    <div class="detail-container">
      <el-page-header @back="router.go(-1)" content="作业详情" />
    
    <el-card class="header-card">
      <template #header>
      <div class="header-content">
        <h2>{{ assignment.title || '作业详情' }}</h2>
        <div class="status-tags">
          <el-tag type="info">提交ID: {{ details[0]?.submissionId }}</el-tag>
          <el-tag :type="score >= 60 ? 'success' : 'danger'" v-if="score !== null">
            总分: {{ score }}
          </el-tag>
        </div>
      </div>
    </template>
      
      <div class="meta-info">
        <div class="meta-item">
          <el-icon><Calendar /></el-icon>
          <span>截止日期：{{ formatDate(assignment.dueDate) }}</span>
        </div>
        <div class="meta-item" v-if="submittedAt">
          <el-icon><Clock /></el-icon>
          <span>提交时间：{{ safeFormatDate(submittedAt) }}</span>
        </div>
      </div>
      
      <div class="description">
        <h3>作业说明</h3>
        <p>{{ assignment.description || '暂无详细说明' }}</p>
      </div>
    </el-card>
    
    <!-- 加载状态 -->
    <div v-if="loading" class="loading-container">
      <el-skeleton :rows="5" animated />
      <p>正在加载作业详情...</p>
    </div>
    
    <!-- 错误状态 -->
    <div v-else-if="error" class="error-container">
      <el-alert
        :title="error"
        type="error"
        :closable="false"
        show-icon
      />
      <el-button @click="fetchSubmissionDetails" style="margin-top: 20px;">
        重新加载
      </el-button>
    </div>
    
    <!-- 无数据状态 -->
    <div v-else-if="details.length === 0" class="empty-container">
      <el-empty description="暂无作业详情数据">
        <el-button @click="fetchSubmissionDetails">重新加载</el-button>
      </el-empty>
    </div>
    
    <!-- 正常显示 -->
    <div v-else class="questions-list">
      <el-card 
        v-for="(detail, index) in details" 
        :key="detail.id"
        class="question-card"
        :class="{ 'correct': detail.isCorrect, 'incorrect': !detail.isCorrect }"
      >
        <template #header>
          <div class="question-header">
            <span class="question-index">题目 {{ index + 1 }}</span>
            <el-tag :type="detail.isCorrect ? 'success' : 'danger'">
              {{ detail.isCorrect ? '正确' : '错误' }}
            </el-tag>
            <el-tag v-if="detail.score !== undefined" type="info">
              得分: {{ detail.score }}
            </el-tag>
          </div>
        </template>
        
        <div class="question-content">
          <div class="question-text" v-html="detail.content || '题目内容加载中...'"></div>
          <el-tag type="info" size="small" class="knowledge-tag" v-if="detail.knowledgePoint">
            知识点：{{ detail.knowledgePoint }}
          </el-tag>
          <el-tag v-else type="warning" size="small" class="knowledge-tag">
            知识点：暂无
          </el-tag>
        </div>
        
        <div class="answer-section">
          <div class="answer-block">
            <h4>我的回答</h4>
            <div class="answer-text">{{ detail.answerText || '暂无回答' }}</div>
          </div>
          
          <div class="feedback-block" v-if="!detail.isCorrect && detail.errorReason">
            <el-divider />
            <h4>错误原因</h4>
            <p class="error-reason">{{ detail.errorReason }}</p>
          </div>
          
          <div class="reference-block">
            <el-divider />
            <h4>参考答案</h4>
            <p class="reference-answer">{{ detail.answer || '暂无参考答案' }}</p>
          </div>
        </div>
      </el-card>
    </div>
    
    <div class="action-bar">
      <el-button @click="router.go(-1)" plain>返回</el-button>
    </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Calendar, Clock } from '@element-plus/icons-vue'
import axios from 'axios'
import { ElMessage } from 'element-plus'

const route = useRoute()
const router = useRouter()

// 作业数据
const assignment = ref({
  id: null,
  title: '',
  description: '',
  dueDate: null
})

// 详情数据
const details = ref([])
const submittedAt = ref(null)
const score = ref(null)
const loading = ref(true)
const error = ref(null)

// 计算属性
const isSubmitted = computed(() => !!submittedAt.value)

// 获取作业详情
const fetchSubmissionDetails = async () => {
  try {
    loading.value = true
    error.value = null
    
    const assignmentId = route.params.id || route.params.assignmentId
    console.log('获取作业详情，assignmentId:', assignmentId)
    
    if (!assignmentId) {
      throw new Error('作业ID不能为空')
    }
    
    // 1. 获取作业基本信息
    console.log('正在获取作业基本信息...')
    const assignmentRes = await axios.get('/api/xiaozhi/teacher/detail', { 
      params: { assignmentId } 
    })
    console.log('作业基本信息响应:', assignmentRes.data)
    
    if (assignmentRes.data.code === 200) {
      assignment.value = assignmentRes.data.data.assignment
      console.log('作业基本信息:', assignment.value)
    } else {
      console.warn('获取作业基本信息失败:', assignmentRes.data.message)
    }

    // 2. 获取提交详情（后端已经处理了题目信息补充）
    console.log('正在获取提交详情...')
    const response = await axios.get('/api/xiaozhi/student/details', { 
      params: { assignmentId } 
    })
    console.log('提交详情响应:', response.data)
    
    if (response.data.code === 200) {
      details.value = response.data.data || []
      console.log('提交详情数据:', details.value)
      
      if (details.value.length > 0) {
        submittedAt.value = details.value[0]?.submittedAt
        score.value = details.value.reduce((sum, item) => sum + (item.score || 0), 0)
        console.log('提交时间:', submittedAt.value, '总分:', score.value)
      } else {
        console.warn('没有找到提交详情数据')
        error.value = '没有找到提交详情数据'
      }
    } else {
      console.warn('获取提交详情失败:', response.data.message)
      error.value = response.data.message || '获取提交详情失败'
    }
  } catch (err) {
    console.error('获取作业详情失败:', err)
    error.value = err.message || '获取作业详情失败'
    ElMessage.error('获取作业详情失败: ' + (err.response?.data?.message || err.message))
  } finally {
    loading.value = false
  }
}

// 更稳健的日期格式化
const formatDate = (dateString) => {
  if (!dateString) return '暂无'
  const date = new Date(dateString)
  if (isNaN(date.getTime())) return String(dateString)
  return date.toLocaleDateString('zh-CN')
}

function toDateFromArray(arr) {
  const [year, month, day, hour = 0, minute = 0, second = 0] = arr || []
  if (!year || !month || !day) return null
  return new Date(year, month - 1, day, hour, minute, second)
}

function parseFlexibleDate(value) {
  if (!value) return null
  if (Array.isArray(value)) {
    if (value.length === 1) return parseFlexibleDate(value[0])
    if (value.length >= 3 && value.every(v => typeof v === 'number')) {
      return toDateFromArray(value)
    }
  }
  if (typeof value === 'object' && value.year && value.month && value.day) {
    const { year, month, day, hour = 0, minute = 0, second = 0 } = value
    return new Date(year, month - 1, day, hour, minute, second)
  }
  const d = new Date(value)
  return isNaN(d.getTime()) ? null : d
}

const safeFormatDate = (value) => {
  const d = parseFlexibleDate(value)
  if (!d) return '暂无'
  try {
    return d.toLocaleString('zh-CN', { 
      year: 'numeric', 
      month: '2-digit', 
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch (e) {
    console.error('日期格式化错误:', e, value)
    return '暂无'
  }
}

onMounted(() => {
  fetchSubmissionDetails()
})
</script>

<style scoped>
.page-background {
  min-height: 100vh;
  background-image: url('@/assets/images/简约线条蓝色视频背景边框_爱给网_aigei_com.gif');
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  background-attachment: fixed;
  padding: 20px;
}

.detail-container {
  max-width: 900px;
  margin: 0 auto;
  padding: 20px;
  background: rgba(255, 255, 255, 0.75);
  border-radius: 20px;
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
  backdrop-filter: blur(15px);
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.header-card {
  margin-bottom: 24px;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
  background: rgba(255, 255, 255, 0.7);
  border: 1px solid rgba(255, 255, 255, 0.3);
  backdrop-filter: blur(10px);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-content h2 {
  font-size: 24px;
  font-weight: 700;
  color: #2c3e50;
  margin: 0;
}

.status-tags {
  display: flex;
  gap: 12px;
}

.status-tags .el-tag {
  font-weight: 600;
  padding: 6px 12px;
  border-radius: 8px;
}

.meta-info {
  display: flex;
  gap: 24px;
  margin-top: 16px;
  padding: 16px;
  background: linear-gradient(135deg, rgba(64, 158, 255, 0.05), rgba(100, 177, 255, 0.02));
  border-radius: 12px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #6c757d;
  font-weight: 500;
}

.meta-item .el-icon {
  color: #409eff;
  font-size: 16px;
}

.description {
  margin-top: 20px;
  padding: 20px;
  background: rgba(255, 255, 255, 0.6);
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  backdrop-filter: blur(8px);
}

.description h3 {
  margin-bottom: 12px;
  color: #2c3e50;
  font-size: 18px;
  font-weight: 600;
}

.description p {
  color: #5f6b7a;
  line-height: 1.6;
  margin: 0;
}

.loading-container,
.error-container,
.empty-container {
  margin-top: 20px;
  text-align: center;
  padding: 40px;
}

.loading-container p {
  margin-top: 20px;
  color: #666;
}

.questions-list {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.question-card {
  border-radius: 16px;
  transition: all 0.3s ease;
  background: rgba(255, 255, 255, 0.7);
  border: 1px solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
  overflow: hidden;
  position: relative;
  backdrop-filter: blur(10px);
}

.question-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(135deg, #409eff, #66b1ff);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.question-card.correct::before {
  background: linear-gradient(135deg, #67c23a, #85ce61);
}

.question-card.incorrect::before {
  background: linear-gradient(135deg, #f56c6c, #f78989);
}

.question-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.12);
}

.question-card:hover::before {
  opacity: 1;
}

.question-header {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  background: rgba(255, 255, 255, 0.6);
  border-bottom: 1px solid rgba(0, 0, 0, 0.08);
  backdrop-filter: blur(8px);
}

.question-index {
  font-weight: 700;
  color: #409eff;
  font-size: 18px;
}

.question-content {
  margin-bottom: 20px;
  padding: 20px;
}

.question-text {
  line-height: 1.6;
  margin-bottom: 16px;
  color: #2c3e50;
  font-size: 15px;
}

.knowledge-tag {
  margin-top: 12px;
  font-weight: 500;
}

.answer-section {
  margin-top: 20px;
  padding: 20px;
  background: rgba(248, 250, 252, 0.6);
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  backdrop-filter: blur(8px);
}

.answer-block h4, 
.feedback-block h4,
.reference-block h4 {
  margin-bottom: 12px;
  color: #2c3e50;
  font-size: 16px;
  font-weight: 600;
}

.answer-text {
  padding: 16px;
  background: linear-gradient(135deg, rgba(64, 158, 255, 0.05), rgba(100, 177, 255, 0.02));
  border-radius: 8px;
  line-height: 1.6;
  color: #2c3e50;
  border: 1px solid rgba(64, 158, 255, 0.1);
}

.error-reason {
  color: #f56c6c;
  padding: 16px;
  background: linear-gradient(135deg, rgba(245, 108, 108, 0.05), rgba(247, 137, 137, 0.02));
  border-radius: 8px;
  border: 1px solid rgba(245, 108, 108, 0.1);
  line-height: 1.6;
}

.reference-answer {
  color: #67c23a;
  padding: 16px;
  background: linear-gradient(135deg, rgba(103, 194, 58, 0.05), rgba(133, 206, 97, 0.02));
  border-radius: 8px;
  border: 1px solid rgba(103, 194, 58, 0.1);
  line-height: 1.6;
}

.action-bar {
  display: flex;
  justify-content: center;
  margin-top: 32px;
  padding: 20px;
}

.action-bar .el-button {
  background: linear-gradient(135deg, #409eff, #66b1ff);
  border: none;
  border-radius: 12px;
  padding: 12px 24px;
  font-weight: 600;
  transition: all 0.3s ease;
  box-shadow: 0 4px 16px rgba(64, 158, 255, 0.3);
}

.action-bar .el-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(64, 158, 255, 0.4);
}

:deep(.el-divider--horizontal) {
  margin: 16px 0;
}
</style>