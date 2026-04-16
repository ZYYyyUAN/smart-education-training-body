<template>
  <div class="student-detail">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <div class="header-left">
        <el-button @click="goBack" class="back-btn" type="text">
            <el-icon><ArrowLeft /></el-icon>
          返回
        </el-button>
          <h1 class="page-title">
            <img src="@/assets/icon/可达鸭.png" alt="可达鸭" class="title-icon">
            {{ student?.name }} 学情详情
          </h1>
          <p class="page-subtitle">查看学生详细学习情况</p>
      </div>
        <div class="header-right">
          <div class="student-info">
        <div class="student-avatar">
          <span>{{ student?.name?.charAt(0) || 'S' }}</span>
            </div>
            <div class="student-basic">
              <div class="student-name">{{ student?.name }}</div>
              <div class="student-id">学号：{{ student?.id }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="student" class="content">
      <!-- 左侧主要内容区域 -->
      <div class="main-content">
        <!-- 学生基本信息卡片 -->
        <div class="info-section">
          <el-card shadow="hover" class="info-card">
            <div class="card-header">
              <h3 class="card-title">学生基本信息</h3>
              </div>
              <div class="info-grid">
          <div class="info-item">
                <div class="info-label">学号</div>
                <div class="info-value">{{ student.id }}</div>
                  </div>
              <div class="info-item">
                <div class="info-label">姓名</div>
                <div class="info-value">{{ student.name }}</div>
          </div>
          <div class="info-item">
                <div class="info-label">学校</div>
                <div class="info-value">{{ student.school }}</div>
          </div>
          <div class="info-item">
                <div class="info-label">学院</div>
                <div class="info-value">{{ student.college }}</div>
          </div>
          <div class="info-item">
                <div class="info-label">班级</div>
                <div class="info-value">{{ student.className }}</div>
          </div>
          <div class="info-item">
                <div class="info-label">性别</div>
                <div class="info-value">{{ student.gender }}</div>
                  </div>
                </div>
          </el-card>
              </div>

        <!-- 学习统计 -->
        <div class="stats-section">
          <el-card shadow="hover" class="stats-card">
            <div class="card-header">
              <h3 class="card-title">学习统计</h3>
          </div>
            <div class="stats-grid">
              <div class="stat-item">
                <div class="stat-icon">📚</div>
                <div class="stat-content">
                  <div class="stat-number">{{ assignmentScores.length }}</div>
                  <div class="stat-label">总作业数</div>
          </div>
        </div>
                <div class="stat-item">
                <div class="stat-icon">⚠️</div>
                <div class="stat-content">
                  <div class="stat-number">{{ weakKnowledgePoints.length }}</div>
                  <div class="stat-label">薄弱知识点</div>
                </div>
                </div>
                <div class="stat-item">
                <div class="stat-icon">📊</div>
                <div class="stat-content">
                  <div class="stat-number">{{ getAverageScore() }}%</div>
                  <div class="stat-label">平均分</div>
                </div>
              </div>
              <div class="stat-item">
                <div class="stat-icon">✅</div>
                <div class="stat-content">
                  <div class="stat-number">{{ getCompletedAssignments() }}</div>
                  <div class="stat-label">已完成作业</div>
            </div>
          </div>
            </div>
          </el-card>
        </div>

        <!-- 作业表现 -->
        <div class="assignments-section">
          <el-card shadow="hover" class="assignments-card">
            <div class="card-header">
              <h3 class="card-title">作业表现</h3>
              <p class="card-subtitle">查看学生作业完成情况</p>
          </div>
            <div v-if="assignmentScores.length > 0" class="assignments-list">
              <div v-for="(assignment, index) in assignmentScores" :key="index" class="assignment-item">
            <div class="assignment-header">
                <div class="assignment-title">
                  <h4>{{ assignment.title }}</h4>
                  <span class="assignment-id">#{{ assignment.assignment_id }}</span>
                </div>
                  <div class="assignment-score" :class="getScoreClass(assignment.score)">
                {{ assignment.score_display || (assignment.score ? assignment.score + '分' : '待评分') }}
                </div>
            </div>
            <div class="assignment-meta">
                <div class="meta-item">
                    <span class="meta-label">截止时间：</span>
                  <span class="meta-value">{{ formatDate(assignment.due_date) }}</span>
                </div>
                <div class="meta-item" v-if="assignment.submitted_at">
                    <span class="meta-label">提交时间：</span>
                  <span class="meta-value">{{ formatDate(assignment.submitted_at) }}</span>
                </div>
            </div>
              <div class="assignment-actions">
            <el-button 
              size="small" 
                    type="primary"
              @click="viewAssignmentDetail(assignment.assignment_id, student.id)"
              v-if="assignment.assignment_id"
            >
                    查看详情
            </el-button>
              </div>
            </div>
          </div>
            <div v-else class="no-data">
            <div class="no-data-icon">📝</div>
            <p>暂无作业数据</p>
          </div>
          </el-card>
        </div>
      </div>

      <!-- 右侧薄弱知识点 -->
      <div class="right-sidebar">
        <el-card shadow="hover" class="weakness-card">
          <div class="card-header">
            <h3 class="card-title">薄弱知识点</h3>
            <p class="card-subtitle">按错误次数排序</p>
          </div>
          <div v-if="weakKnowledgePoints.length > 0" class="weakness-list">
            <div v-for="(point, index) in weakKnowledgePoints" :key="index" class="weakness-item">
              <div class="weakness-rank">{{ index + 1 }}</div>
              <div class="weakness-content">
                <div class="weakness-name">{{ point.knowledge_point }}</div>
                <div class="weakness-stats">
                  <span class="error-count">错误 {{ point.error_count }} 次</span>
                  <div class="error-bar">
                    <div class="error-fill" :style="{ width: Math.min(point.error_count * 20, 100) + '%' }"></div>
                    </div>
                  </div>
                </div>
              </div>
              </div>
          <div v-else class="no-data">
            <div class="no-data-icon">🎉</div>
            <p>暂无薄弱知识点</p>
            </div>
        </el-card>
      </div>
    </div>

    <!-- 作业详情对话框 -->
    <el-dialog v-model="assignmentDetailVisible" title="作业详情" width="80%" :close-on-click-modal="false">
      <div v-if="assignmentDetails.length > 0" class="assignment-detail">
        <div v-for="(question, index) in assignmentDetails" :key="index" class="question-item">
          <div class="question-header">
            <span class="question-number">第{{ question.sort_order || (index + 1) }}题</span>
            <span class="question-status" :class="question.is_correct ? 'correct' : 'incorrect'">
              {{ question.status }}
            </span>
          </div>
          <div class="question-content">{{ question.question_content }}</div>
          <div class="answer-info">
            <p><strong>学生答案：</strong>{{ question.answer_text || '未作答' }}</p>
            <p><strong>得分：</strong>{{ question.score }}分</p>
            <p v-if="!question.is_correct && question.error_reason">
              <strong>错误原因：</strong>{{ question.error_reason }}
            </p>
          </div>
        </div>
      </div>
      <div v-else class="no-data">暂无作业详情数据</div>
      
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="assignmentDetailVisible = false">关闭</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft } from '@element-plus/icons-vue'
import axios from 'axios'

const route = useRoute()
const router = useRouter()

const student = ref(null)
const weakKnowledgePoints = ref([])
const assignmentScores = ref([])
const assignmentDetails = ref([])
const assignmentDetailVisible = ref(false)

// 获取学生详情
const loadStudentDetail = async () => {
  try {
    const studentId = route.params.studentId
    const courseId = route.params.courseId
    
    // 获取学生基本信息
    const studentRes = await axios.get('/api/xiaozhi/teacher/course/students', { 
      params: { courseId } 
    })
    const students = studentRes.data?.data || []
    student.value = students.find(s => s.id == studentId)
    
    if (!student.value) {
      ElMessage.error('未找到学生信息')
      return
    }
    
    // 获取薄弱知识点
    const weakPointsRes = await axios.get('/api/xiaozhi/teacher/analysis/weak-points', {
      params: { studentId, courseId }
    })
    weakKnowledgePoints.value = weakPointsRes.data?.data || []
    
    // 获取作业得分情况
    const scoresRes = await axios.get('/api/xiaozhi/teacher/analysis/assignment-scores', {
      params: { studentId, courseId }
    })
    assignmentScores.value = scoresRes.data?.data || []
    
  } catch (e) {
    ElMessage.error('加载学情失败：' + e.message)
  }
}

// 查看作业详情
const viewAssignmentDetail = async (assignmentId, studentId) => {
  try {
    console.log('查看作业详情:', { assignmentId, studentId })
    
    const detailRes = await axios.get('/api/xiaozhi/teacher/analysis/assignment-detail', {
      params: { assignmentId, studentId }
    })
    
    console.log('作业详情API响应:', detailRes.data)
    
    assignmentDetails.value = detailRes.data?.data || []
    assignmentDetailVisible.value = true
    
    console.log('设置作业详情数据:', assignmentDetails.value)
  } catch (e) {
    console.error('加载作业详情失败:', e)
    ElMessage.error('加载作业详情失败：' + e.message)
  }
}

// 获取得分样式类
const getScoreClass = (score) => {
  if (score === null || score === undefined) return 'pending-score'
  if (score >= 80) return 'high-score'
  if (score >= 60) return 'medium-score'
  return 'low-score'
}

// 格式化日期
const formatDate = (dateStr) => {
  if (!dateStr) return '未设置'
  try {
    return new Date(dateStr).toLocaleString('zh-CN')
  } catch (e) {
    return dateStr
  }
}

// 计算平均分
const getAverageScore = () => {
  if (!assignmentScores.value.length) return 0
  
  const validScores = assignmentScores.value
    .filter(assignment => assignment.score !== null && assignment.score !== undefined)
    .map(assignment => assignment.score)
  
  if (validScores.length === 0) return 0
  
  const total = validScores.reduce((sum, score) => sum + score, 0)
  return Math.round(total / validScores.length)
}

// 计算已完成作业数
const getCompletedAssignments = () => {
  return assignmentScores.value.filter(assignment => 
    assignment.score !== null && assignment.score !== undefined
  ).length
}

// 返回上一页
const goBack = () => {
  router.back()
}

onMounted(() => {
  loadStudentDetail()
})
</script>

<style scoped>
.student-detail {
  background: #ffffff;
  min-height: 100vh;
  padding: 0;
}

/* 页面头部 */
.page-header {
  background: white;
  padding: 2rem;
  margin-bottom: 0;
  border-bottom: 1px solid #e0e0e0;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1200px;
  margin: 0 auto;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex: 1;
}

.back-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #409EFF;
  font-weight: 500;
  padding: 8px 16px;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.back-btn:hover {
  background: rgba(64, 158, 255, 0.1);
}

.page-title {
  display: flex;
  align-items: center;
  font-size: 1.8rem;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
}

.title-icon {
  width: 3rem;
  height: 3rem;
  object-fit: contain;
  vertical-align: middle;
  margin-right: 0.5rem;
}

.page-subtitle {
  color: #64748b;
  font-size: 0.9rem;
  margin: 0.5rem 0 0 0;
}

.header-right {
  display: flex; 
  align-items: center;
}

.student-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  background: #f8f9fa;
  padding: 1rem 1.5rem;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
}

.student-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: #409EFF;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.5rem;
  font-weight: 700;
}

.student-basic {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.student-name {
  font-size: 1.1rem;
  font-weight: 600;
  color: #1e293b;
}

.student-id {
  font-size: 0.875rem;
  color: #64748b;
}

.content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
  display: grid;
  grid-template-columns: 1fr 350px;
  gap: 2rem;
  align-items: start;
}

/* 左侧主要内容区域 */
.main-content {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

/* 右侧边栏 */
.right-sidebar {
  position: sticky;
  top: 2rem;
}

/* 卡片通用样式 */
.info-section,
.stats-section,
.assignments-section {
  width: 100%;
}

.info-card,
.stats-card,
.assignments-card,
.weakness-card {
  border-radius: 12px;
  border: 1px solid #e2e8f0;
}

.card-header {
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #f1f5f9;
}

.card-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1e293b;
  margin: 0;
}

.card-subtitle {
  font-size: 0.875rem;
  color: #64748b;
  margin: 0.5rem 0 0 0;
}

/* 学生信息网格 */
.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  padding: 1rem;
  background: #f8fafc;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
}

.info-label {
  font-size: 0.875rem;
  color: #64748b;
  font-weight: 500;
}

.info-value {
  font-size: 1rem;
  color: #1e293b;
  font-weight: 600;
}

/* 统计网格 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem;
  background: #f8fafc;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  transition: all 0.3s ease;
}

.stat-item:hover {
  background: #f1f5f9;
  transform: translateY(-2px);
}

.stat-icon {
  font-size: 2rem;
  width: 60px;
  height: 60px;
  background: #409EFF;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.stat-content {
  flex: 1;
}

.stat-number {
  font-size: 2rem;
  font-weight: 700;
  color: #1e293b;
  margin-bottom: 0.25rem;
}

.stat-label {
  font-size: 0.875rem;
  color: #64748b;
  font-weight: 500;
}

/* 作业列表 */
.assignments-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.assignment-item {
  padding: 1.5rem;
  background: #f8fafc;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  transition: all 0.3s ease;
}

.assignment-item:hover {
  background: #f1f5f9;
  transform: translateY(-2px);
}

.assignment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.assignment-title h4 {
  margin: 0 0 0.25rem 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: #1e293b;
}

.assignment-id {
  font-size: 0.875rem;
  color: #64748b;
}

.assignment-score {
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.875rem;
  font-weight: 600;
}

.assignment-score.high-score {
  background: #dcfce7;
  color: #166534;
}

.assignment-score.medium-score {
  background: #fef3c7;
  color: #92400e;
}

.assignment-score.low-score {
  background: #fee2e2;
  color: #991b1b;
}

.assignment-score.pending-score {
  background: #e0e7ff;
  color: #3730a3;
}

.assignment-meta {
  display: flex;
  gap: 2rem;
  margin-bottom: 1rem;
  font-size: 0.875rem;
  color: #64748b;
}

.meta-item {
  display: flex;
  gap: 0.5rem;
}

.meta-label {
  font-weight: 500;
}

.assignment-actions {
  display: flex;
  justify-content: flex-end;
}

/* 薄弱知识点列表 */
.weakness-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.weakness-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: #f8fafc;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  transition: all 0.3s ease;
}

.weakness-item:hover {
  background: #f1f5f9;
  transform: translateX(4px);
}

.weakness-rank {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #409EFF;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.875rem;
  flex-shrink: 0;
}

.weakness-content {
  flex: 1;
}

.weakness-name {
  font-weight: 600;
  color: #1e293b;
  font-size: 0.875rem;
  margin-bottom: 0.5rem;
}

.weakness-stats {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.error-count {
  color: #ef4444;
  font-weight: 600;
  font-size: 0.75rem;
}

.error-bar {
  width: 100%;
  height: 4px;
  background: #e2e8f0;
  border-radius: 2px;
  overflow: hidden;
}

.error-fill {
  height: 100%;
  background: #ef4444;
  border-radius: 2px;
  transition: width 0.3s ease;
}

/* 无数据状态 */
.no-data {
  text-align: center;
  padding: 3rem 2rem;
  color: #64748b;
}

.no-data-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
  display: block;
}

.no-data p {
  margin: 0;
  font-size: 1rem;
  font-weight: 500;
}

/* 作业详情对话框 */
.assignment-detail {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  max-height: 60vh;
  overflow-y: auto;
  padding-right: 0.5rem;
}

.question-item {
  padding: 1.5rem;
  background: #f8f9fa;
  border-radius: 12px;
  border: 1px solid #e9ecef;
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.question-number {
  font-weight: 600;
  color: #333;
}

.question-status {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.875rem;
  font-weight: 500;
}

.question-status.correct {
  background: #dcfce7;
  color: #166534;
}

.question-status.incorrect {
  background: #fee2e2;
  color: #991b1b;
}

.question-content {
  background: #fff;
  padding: 0.75rem;
  border-radius: 6px;
  margin-bottom: 0.75rem;
  color: #333;
  line-height: 1.5;
}

.answer-info p {
  margin: 0.5rem 0;
  color: #333;
}

.answer-info strong {
  color: #333;
}

.dialog-footer {
  text-align: center;
  padding-top: 1rem;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-header {
    padding: 1rem;
  }
  
  .header-content {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
  }
  
  .header-left {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .page-title {
    font-size: 1.5rem;
  }
  
  .content {
    padding: 1rem;
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .right-sidebar {
    position: static;
    order: -1;
  }
  
  .info-grid,
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .assignment-meta {
    flex-direction: column;
    gap: 0.5rem;
  }
}
</style>