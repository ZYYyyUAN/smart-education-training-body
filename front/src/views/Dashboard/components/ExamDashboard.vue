<template>
  <div class="exam-dashboard">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <div class="header-left">
          <h1 class="page-title">
            <img src="@/assets/icon/腊肠犬.png" alt="腊肠犬" class="title-icon">
            考试管理
          </h1>
          <p class="page-subtitle">管理和组织您的考试资源</p>
        </div>
        <div class="header-right">
          <el-button type="primary" @click="router.push({ name: 'CreateExam' })" class="action-btn">
            <el-icon><Plus /></el-icon>
            创建考试
          </el-button>
        </div>
      </div>
    </div>

    <!-- 搜索和筛选区域 -->
    <div class="search-section">
      <div class="search-bar">
        <div class="search-left">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索考试标题..."
            class="search-input"
            clearable
            @input="applyFilter"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>
        <div class="search-right">
          <el-select 
            v-model="selectedCourseId" 
            placeholder="按课程筛选" 
            class="filter-select"
            clearable 
            @change="applyFilter"
          >
            <el-option 
              v-for="course in courses" 
              :key="course.id" 
              :label="course.courseName" 
              :value="course.id" 
            />
          </el-select>
          <el-button 
            type="info" 
            size="small" 
            @click="resetFilters"
            class="reset-btn"
          >
            <el-icon><Refresh /></el-icon>
            重置
          </el-button>
        </div>
      </div>
    </div>

    <!-- 表格容器 -->
    <div class="table-container">
      <el-card shadow="hover" class="table-card">
        <el-table 
          :data="pagedExams" 
          v-loading="loading" 
          class="exam-table"
          empty-text="暂无考试"
          :header-cell-style="{ background: '#f8f9fa', color: '#606266', fontWeight: '600' }"
        >
        <el-table-column label="考试ID" width="100" align="center">
          <template #default="{ $index }">
            <span class="exam-id">{{ String(($index + 1)).padStart(3, '0') }}</span>
          </template>
        </el-table-column>

        <el-table-column label="课程" width="200" align="center">
          <template #default="{ row }">
            <div class="course-info">
              <el-icon class="course-icon"><Reading /></el-icon>
              <span>{{ getCourseName(row.courseId) || '-' }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column prop="title" label="考试题目" min-width="200" show-overflow-tooltip>
          <template #default="{ row }">
            <div class="exam-title">
              <el-icon class="exam-icon"><Document /></el-icon>
              <span>{{ row.title }}</span>
            </div>
          </template>
        </el-table-column>
        
        <el-table-column label="完成率" width="120" align="center">
          <template #default="{ row }">
            <div class="completion-rate">
              <el-progress 
                :percentage="parseInt(calcRate(row))" 
                :show-text="false" 
                :stroke-width="8"
                :color="getProgressColor(parseInt(calcRate(row)))"
                class="progress-bar"
              />
              <span class="rate-text">{{ calcRate(row) }}</span>
            </div>
          </template>
        </el-table-column>
        
        <el-table-column label="完成人数" width="120" align="center">
          <template #default="{ row }">
            <div class="completion-count">
              <el-icon class="count-icon"><User /></el-icon>
              <span>{{ row.completedCount || 0 }} 人</span>
            </div>
          </template>
        </el-table-column>
        
        <el-table-column label="考试时间" width="180" align="center">
          <template #default="{ row }">
            <div class="exam-date">
              <el-icon class="date-icon"><Clock /></el-icon>
              <span>{{ formatDate(row.examDate) }}</span>
            </div>
          </template>
        </el-table-column>
        
        <el-table-column label="状态" width="120" align="center">
          <template #default="{ row }">
            <el-tag 
              :type="getStatusTagType(row)" 
              :effect="getStatusTagType(row) === 'danger' ? 'dark' : 'light'"
              class="status-tag"
            >
              <el-icon class="status-icon">
                <Check v-if="getStatusTagType(row) === 'success'" />
                <Close v-else />
              </el-icon>
              {{ getStatusText(row) }}
            </el-tag>
          </template>
        </el-table-column>
        
        <el-table-column label="操作" width="280" align="center" fixed="right">
          <template #default="{ row }">
            <div class="action-buttons">
              <el-button 
                size="small" 
                type="primary" 
                class="action-btn"
                @click="editExam(row)"
              >
                <el-icon><Edit /></el-icon>
                编辑
              </el-button>
              <el-button 
                size="small" 
                type="danger" 
                class="action-btn"
                @click="deleteExam(row.id)"
              >
                <el-icon><Delete /></el-icon>
                删除
              </el-button>
            </div>
          </template>
        </el-table-column>
        </el-table>
      </el-card>
    </div>

    <!-- 分页器 -->
    <div class="pagination-wrapper">
      <div class="pagination-info">
        <span class="pagination-text">
          共 {{ filteredExams.length }} 条记录，第 {{ currentPage }} / {{ Math.ceil(filteredExams.length / pageSize) }} 页
        </span>
      </div>
      <el-pagination
        background
        layout="prev, pager, next, jumper"
        :total="filteredExams.length"
        :page-size="pageSize"
        :current-page="currentPage"
        @current-change="(p) => (currentPage = p)"
        class="pagination"
      />
    </div>
  </div>
  </template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { 
  Trophy, 
  Plus, 
  Document, 
  Reading, 
  User, 
  Clock, 
  Check, 
  Close, 
  Edit, 
  Delete,
  Search,
  Refresh
} from '@element-plus/icons-vue'

const router = useRouter()
const loading = ref(false)
const exams = ref([])
const courses = ref([])

// 筛选相关
const searchKeyword = ref('')
const selectedCourseId = ref('')

const currentPage = ref(1)
const pageSize = 10

// 筛选后的考试列表
const filteredExams = computed(() => {
  let filtered = exams.value
  
  // 按课程筛选
  if (selectedCourseId.value) {
    filtered = filtered.filter(exam => String(exam.courseId) === String(selectedCourseId.value))
  }
  
  // 按关键词搜索
  if (searchKeyword.value.trim()) {
    const keyword = searchKeyword.value.trim().toLowerCase()
    filtered = filtered.filter(exam => 
      exam.title.toLowerCase().includes(keyword) ||
      (exam.description && exam.description.toLowerCase().includes(keyword))
    )
  }
  
  return filtered
})

const pagedExams = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  return filteredExams.value.slice(start, start + pageSize)
})

const fetchExams = async () => {
  loading.value = true
  try {
    const res = await axios.get('/api/xiaozhi/teacher/exams/overview', { params: { teacherId: 2 } })
    if (res.data.code === 200) {
      exams.value = res.data.data
    } else {
      ElMessage.error('加载考试失败: ' + res.data.message)
    }
  } catch (e) {
    ElMessage.error('请求错误: ' + e.message)
  } finally {
    loading.value = false
  }
}

// 加载课程列表
const loadCourses = async () => {
  try {
    const res = await axios.get('/api/xiaozhi/teacher/courses')
    if (res.data.code === 200) {
      courses.value = res.data.data || []
    }
  } catch (error) {
    console.error('加载课程失败:', error)
    ElMessage.error('加载课程失败')
  }
}

// 获取课程名称
const getCourseName = (courseId) => {
  const course = courses.value.find(c => String(c.id) === String(courseId))
  return course?.courseName || '未知课程'
}

// 应用筛选
const applyFilter = () => {
  currentPage.value = 1
}

// 重置筛选
const resetFilters = () => {
  searchKeyword.value = ''
  selectedCourseId.value = ''
  currentPage.value = 1
}

onMounted(async () => {
  await Promise.all([
    fetchExams(),
    loadCourses()
  ])
})

const calcRate = (row) => {
  const total = row.totalStudents || 0
  if (!total) return '0%'
  const done = row.completedCount || 0
  return Math.round((done / total) * 100) + '%'
}

// 根据完成率获取进度条颜色
const getProgressColor = (percentage) => {
  if (percentage >= 80) return '#67c23a'
  if (percentage >= 60) return '#e6a23c'
  if (percentage >= 40) return '#f56c6c'
  return '#909399'
}

// ✅ 获取考试状态文本
const getStatusText = (row) => {
  const now = new Date()
  const examDate = new Date(row.examDate)
  const durationMinutes = row.durationMinutes || 120 // 默认2小时
  
  // 计算考试结束时间（考试日期 + 考试时长）
  const examEndTime = new Date(examDate.getTime() + durationMinutes * 60 * 1000)
  
  // 如果当前时间已超过考试结束时间，则为已截止
  if (now > examEndTime) {
    return '已截止'
  }
  
  // 其他情况都是进行中（只要发布了考试就是进行中）
  return '进行中'
}

// ✅ 获取状态标签类型
const getStatusTagType = (row) => {
  const now = new Date()
  const examDate = new Date(row.examDate)
  const durationMinutes = row.durationMinutes || 120 // 默认2小时
  
  // 计算考试结束时间（考试日期 + 考试时长）
  const examEndTime = new Date(examDate.getTime() + durationMinutes * 60 * 1000)
  
  // 如果当前时间已超过考试结束时间，则为已截止
  if (now > examEndTime) {
    return 'danger' // 已截止 - 红色
  }
  
  // 其他情况都是进行中
  return 'success' // 进行中 - 绿色
}

const editExam = (row) => {
  const encoded = encodeURIComponent(JSON.stringify(row))
  router.push({ name: 'CreateExam', query: { editExam: encoded } })
}

const deleteExam = async (id) => {
  try {
    const res = await axios.delete('/api/xiaozhi/teacher/exam/delete', { params: { examId: id } })
    if (res.data.code === 200) {
      ElMessage.success('删除成功')
      exams.value = exams.value.filter(e => e.id !== id)
    } else {
      ElMessage.error('删除失败: ' + res.data.message)
    }
  } catch (e) {
    ElMessage.error('请求错误: ' + e.message)
  }
}

function formatDate(value) {
  if (!value) return '-'
  // 支持数组 [Y,M,D,h,m,s] / 对象 {year,month,day,...} / 字符串 / 时间戳
  if (Array.isArray(value)) {
    const [y,m,d,h=0,mi=0,s=0] = value
    if (!y || !m || !d) return '-'
    const dt = new Date(y, m-1, d, h, mi, s)
    return toYMDHM(dt)
  }
  if (typeof value === 'object' && value.year && value.month && value.day) {
    const { year:y, month:m, day:d, hour:h=0, minute:mi=0, second:s=0 } = value
    const dt = new Date(y, m-1, d, h, mi, s)
    return toYMDHM(dt)
  }
  const dt = new Date(value)
  if (isNaN(dt.getTime())) return '-'
  return toYMDHM(dt)
}

function toYMDHM(dt){
  const pad = n => String(n).padStart(2,'0')
  return `${dt.getFullYear()}-${pad(dt.getMonth()+1)}-${pad(dt.getDate())} ${pad(dt.getHours())}:${pad(dt.getMinutes())}`
}
</script>

<style scoped>
.exam-dashboard {
  background: #ffffff;
  min-height: 100vh;
}

/* 页面头部 */
.page-header {
  background: white;
  padding: 2rem;
  border-radius: 16px;
  color: #1e293b;
  margin: 2rem;
  margin-bottom: 2rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1200px;
  margin: 0 auto;
}

.header-left {
  flex: 1;
}

.page-title {
  font-size: 1.75rem;
  font-weight: 700;
  margin: 0 0 0.5rem 0;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.title-icon {
  width: 3rem;
  height: 3rem;
  object-fit: contain;
  vertical-align: middle;
  margin-right: 0.5rem;
}

.page-subtitle {
  font-size: 0.95rem;
  color: #64748b;
  margin: 0;
  margin-left: 2.25rem;
}

.header-right {
  display: flex;
  align-items: center;
}

.action-btn {
  border-radius: 8px;
  font-weight: 600;
  transition: all 0.3s ease;
}

.action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

/* 搜索区域 */
.search-section {
  background: white;
  margin: 0 2rem 2rem;
  padding: 1.5rem;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.search-bar {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.search-left {
  flex: 1;
}

.search-input {
  width: 100%;
}

.search-right {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.filter-select {
  width: 200px;
}

.reset-btn {
  background: #f3f4f6;
  border: 1px solid #d1d5db;
  color: #6b7280;
  font-weight: 500;
}

.reset-btn:hover {
  background: #e5e7eb;
  border-color: #9ca3af;
}

/* 表格容器 */
.table-container {
  margin: 0 2rem 2rem;
  min-height: 400px;
}

.table-card {
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

/* 表格样式 */
.exam-table {
  border-radius: 8px;
  overflow: hidden;
}

.exam-table :deep(.el-table__header) {
  background: #f8f9fa;
}

.exam-table :deep(.el-table__row) {
  transition: all 0.3s ease;
}

.exam-table :deep(.el-table__row:hover) {
  background: #f0f9ff;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.exam-id {
  font-weight: 600;
  color: #667eea;
  font-family: 'Courier New', monospace;
}

.course-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  justify-content: center;
}

.course-icon {
  color: #409eff;
  font-size: 1rem;
}

/* 考试标题样式 */
.exam-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.exam-icon {
  color: #667eea;
  font-size: 1rem;
}

/* 完成率样式 */
.completion-rate {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.progress-bar {
  width: 60px;
}

.rate-text {
  font-size: 12px;
  font-weight: 600;
  color: #374151;
}

/* 完成人数样式 */
.completion-count {
  display: flex;
  align-items: center;
  gap: 4px;
  font-weight: 500;
  color: #374151;
}

.count-icon {
  color: #6b7280;
  font-size: 14px;
}

/* 考试时间样式 */
.exam-date {
  display: flex;
  align-items: center;
  gap: 4px;
  font-weight: 500;
  color: #374151;
}

.date-icon {
  color: #6b7280;
  font-size: 14px;
}

/* 状态标签样式 */
.status-tag {
  font-weight: 600;
  padding: 6px 12px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
}

.status-icon {
  font-size: 12px;
}

/* 操作按钮样式 */
.action-buttons {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  justify-content: center;
  flex-wrap: wrap;
}

.action-btn {
  border-radius: 6px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.action-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

/* 分页样式 */
.pagination-wrapper {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 2rem;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
}

.pagination-info {
  display: flex;
  align-items: center;
}

.pagination-text {
  color: #606266;
  font-size: 0.9rem;
  font-weight: 500;
}

.pagination {
  --el-pagination-bg-color: white;
  --el-pagination-button-bg-color: white;
  --el-pagination-button-color: #606266;
  --el-pagination-hover-color: #667eea;
}

.pagination :deep(.el-pager li) {
  border-radius: 6px;
  margin: 0 2px;
  transition: all 0.3s ease;
}

.pagination :deep(.el-pager li:hover) {
  background: #f0f9ff;
  color: #667eea;
}

.pagination :deep(.el-pager li.is-active) {
  background: #667eea;
  color: white;
  font-weight: 600;
}

.pagination :deep(.btn-prev),
.pagination :deep(.btn-next) {
  border-radius: 6px;
  transition: all 0.3s ease;
}

.pagination :deep(.btn-prev:hover),
.pagination :deep(.btn-next:hover) {
  background: #f0f9ff;
  color: #667eea;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-header {
    margin: 1rem;
    padding: 1.5rem;
  }
  
  .search-section {
    margin: 0 1rem 1rem;
    padding: 1rem;
  }
  
  .table-container {
    margin: 0 1rem 1rem;
  }
  
  .header-content {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
  }
  
  .search-bar {
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
  }
  
  .search-right {
    justify-content: space-between;
  }
  
  .filter-select {
    width: 150px;
  }
  
  .action-buttons {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .pagination-wrapper {
    flex-direction: column;
    gap: 1rem;
    align-items: center;
    padding: 1rem;
  }
}
</style>


