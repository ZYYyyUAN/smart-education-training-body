<template>
  <div class="homework-dashboard">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <div class="header-left">
          <h1 class="page-title">
            <img src="@/assets/icon/羊.png" alt="羊" class="title-icon">
            作业管理
          </h1>
          <p class="page-subtitle">管理和组织您的作业资源</p>
        </div>
        <div class="header-right">
          <el-button type="primary" @click="router.push({ name: 'CreateHomework' })" class="action-btn">
            <el-icon><Plus /></el-icon>
            创建作业
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
            placeholder="搜索作业标题..."
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
          :data="pagedHomeworks"
          v-loading="loading"
          class="homework-table"
          empty-text="暂无作业"
          :header-cell-style="{ background: '#f8f9fa', color: '#606266', fontWeight: '600' }"
        >
        <!-- 表格列 -->
        <el-table-column label="作业ID" width="100" align="center">
          <template #default="{ $index }">
            <span class="homework-id">{{ String(($index + 1)).padStart(3, '0') }}</span>
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

        <el-table-column prop="title" label="作业题目" min-width="200" show-overflow-tooltip>
          <template #default="{ row }">
            <div class="homework-title">
              <el-icon class="homework-icon"><Document /></el-icon>
              <span>{{ row.title }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column label="完成率" width="120" align="center">
          <template #default>
            <div class="completion-rate">
              <el-progress 
                :percentage="100" 
                :show-text="false" 
                :stroke-width="8"
                color="#67c23a"
                class="progress-bar"
              />
              <span class="rate-text">100%</span>
            </div>
          </template>
        </el-table-column>
        
        <el-table-column label="完成人数" width="120" align="center">
          <template #default>
            <div class="completion-count">
              <el-icon class="count-icon"><User /></el-icon>
              <span>1 人</span>
            </div>
          </template>
        </el-table-column>
        
        <el-table-column prop="dueDate" label="截止时间" min-width="160" align="center">
          <template #default="{ row }">
            <div class="due-date">
              <el-icon class="date-icon"><Clock /></el-icon>
              <span>{{ row.dueDate }}</span>
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
                @click="viewHomework(row.id)"
              >
                <el-icon><Edit /></el-icon>
                编辑
              </el-button>
              <el-button 
                size="small" 
                type="danger" 
                class="action-btn"
                @click="deleteHomework(row.id)"
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
          共 {{ filteredHomeworks.length }} 条记录，第 {{ currentPage }} / {{ Math.ceil(filteredHomeworks.length / pageSize) }} 页
        </span>
      </div>
      <el-pagination
        background
        layout="prev, pager, next, jumper"
        :total="filteredHomeworks.length"
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
import dayjs from 'dayjs'
import { ElMessage } from 'element-plus'
import { 
  Document, 
  Plus, 
  User, 
  Clock, 
  Check, 
  Close, 
  Edit, 
  Delete,
  Search,
  Refresh,
  Folder,
  Reading
} from '@element-plus/icons-vue'

const router = useRouter()
const homeworks = ref([])
const courses = ref([])
const loading = ref(false)

// 筛选相关
const searchKeyword = ref('')
const selectedCourseId = ref('')

const currentPage = ref(1)
const pageSize = 10

// 筛选后的作业列表
const filteredHomeworks = computed(() => {
  let filtered = homeworks.value
  
  // 按课程筛选
  if (selectedCourseId.value) {
    filtered = filtered.filter(hw => String(hw.courseId) === String(selectedCourseId.value))
  }
  
  // 按关键词搜索
  if (searchKeyword.value.trim()) {
    const keyword = searchKeyword.value.trim().toLowerCase()
    filtered = filtered.filter(hw => 
      hw.title.toLowerCase().includes(keyword) ||
      (hw.description && hw.description.toLowerCase().includes(keyword))
    )
  }
  
  return filtered
})

const pagedHomeworks = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  return filteredHomeworks.value.slice(start, start + pageSize)
})

const fetchHomeworksByTeacher = async (teacherId) => {
  loading.value = true
  try {
    const res = await axios.get('/api/xiaozhi/teacher/assignments/by-teacher', {
      params: { teacherId }
    })
    if (res.data.code === 200) {
      homeworks.value = res.data.data.map(hw => ({
        id: hw.id,
        title: hw.title,
        description: hw.description,
        courseId: hw.courseId,
        teacherId: hw.teacherId,
        dueDate: dayjs(hw.dueDate).format('YYYY-MM-DD'),  // 👈 转为无时区的日期字符串
        createdAt: hw.createdAt
      }))
    } else {
      ElMessage.error('加载作业失败: ' + res.data.message)
    }
  } catch (error) {
    ElMessage.error('请求作业失败: ' + error.message)
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
  // 这里写死 teacherId=2，实际可从登录状态或路由参数获取
  await Promise.all([
    fetchHomeworksByTeacher(2),
    loadCourses()
  ])
})

const viewHomework = (id) => {
  const hw = homeworks.value.find(h => h.id === id)
  if (hw) {
    const encoded = encodeURIComponent(JSON.stringify(hw))
    router.push({ name: 'CreateHomework', query: { editHomework: encoded } })
  }
}

const deleteHomework = async (id) => {
  try {
    await axios.delete('/api/xiaozhi/teacher/delete', { params: { assignmentId: id } })
    ElMessage.success('✅ 删除成功')
    homeworks.value = homeworks.value.filter(hw => hw.id !== id)
    const totalPages = Math.ceil(homeworks.value.length / pageSize) || 1
    if (currentPage.value > totalPages) currentPage.value = totalPages
  } catch (err) {
    ElMessage.error('❌ 删除失败：' + (err.response?.data?.message || err.message))
  }
}

const getStatusText = (row) => {
  const now = dayjs()
  const deadline = dayjs(row.dueDate)
  return now.isAfter(deadline) ? '已截止' : '提交中'
}

const getStatusTagType = (row) => {
  const now = dayjs()
  const deadline = dayjs(row.dueDate)
  return now.isAfter(deadline) ? 'danger' : 'success'
}
</script>


<style scoped>
.homework-dashboard {
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
.homework-table {
  border-radius: 8px;
  overflow: hidden;
}

.homework-table :deep(.el-table__header) {
  background: #f8f9fa;
}

.homework-table :deep(.el-table__row) {
  transition: all 0.3s ease;
}

.homework-table :deep(.el-table__row:hover) {
  background: #f0f9ff;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.homework-id {
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

/* 作业标题样式 */
.homework-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.homework-icon {
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
  color: #67c23a;
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

/* 截止时间样式 */
.due-date {
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
