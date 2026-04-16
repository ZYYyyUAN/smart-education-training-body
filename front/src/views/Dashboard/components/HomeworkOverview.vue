<template>
  <section class="homework-dashboard">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <div class="header-left">
          <h1 class="page-title">
            <el-icon class="title-icon"><Document /></el-icon>
            题库管理
          </h1>
          <p class="page-subtitle">管理和组织您的题目资源</p>
        </div>
        <div class="header-right">
          <el-button v-if="isSelectionMode" type="success" @click="confirmSelection" class="action-btn">
            <el-icon><Check /></el-icon>
            确认选择
          </el-button>
          <el-button type="primary" @click="addHomework" class="action-btn">
            <el-icon><Plus /></el-icon>
            创建题目
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
            placeholder="搜索题目内容..."
            class="search-input"
            clearable
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>
        <div class="search-right">
          <el-select
            v-model="selectedCourse"
            placeholder="筛选课程"
            class="filter-select"
            clearable
          >
            <el-option
              v-for="course in courseOptions"
              :key="course.id"
              :label="course.courseName"
              :value="course.courseName"
            />
          </el-select>
          <el-select
            v-model="selectedSubject"
            placeholder="知识点分类"
            class="filter-select"
            clearable
          >
            <el-option
              v-for="subject in subjectOptions"
              :key="subject"
              :label="subject"
              :value="subject"
            />
          </el-select>
          <el-select
            v-model="selectedType"
            placeholder="题目类型"
            class="filter-select"
            clearable
          >
            <el-option
              v-for="type in typeOptions"
              :key="type.value"
              :label="type.label"
              :value="type.value"
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
          :data="paginatedData"
          v-loading="loading"
          style="width: 100%"
          empty-text="暂无题目"
          ref="selectableTable"
          @selection-change="handleSelectionChange"
          :row-key="row => row.id"
          class="question-table"
          :header-cell-style="{ background: '#f8f9fa', color: '#606266', fontWeight: '600' }"
        >
          <!-- 选择模式下显示复选框列 -->
          <el-table-column v-if="isSelectionMode" type="selection" width="55" align="center" />

          <!-- 题目ID列 -->
          <el-table-column prop="id" label="题目ID" width="100" align="center">
            <template #default="{ $index }">
              <span class="question-id">{{ String(($index + 1)).padStart(3, '0') }}</span>
            </template>
          </el-table-column>

          <!-- 题目内容列 -->
          <el-table-column prop="title" label="题目内容" min-width="300" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="question-content">
                <el-icon class="question-icon"><Document /></el-icon>
                <span class="question-text">{{ row.title }}</span>
              </div>
            </template>
          </el-table-column>

          <!-- 知识点列 -->
          <el-table-column prop="subject" label="知识点" width="150" align="center">
            <template #default="{ row }">
              <el-tag type="info" effect="light" size="small">{{ row.subject || '-' }}</el-tag>
            </template>
          </el-table-column>

          <!-- 题目类型列 -->
          <el-table-column prop="type" label="题目类型" width="120" align="center">
            <template #default="{ row }">
              <el-tag :type="getTypeTagType(row.typeValue)" effect="light" size="small">
                {{ row.type }}
              </el-tag>
            </template>
          </el-table-column>

          <!-- 创建时间列 -->
          <el-table-column label="创建时间" width="180" align="center">
            <template #default="{ row }">
              <div class="time-info">
                <el-icon class="time-icon"><Clock /></el-icon>
                <span>{{ formatDate(row.createdAt) }}</span>
              </div>
            </template>
          </el-table-column>

          <!-- 操作列 -->
          <el-table-column v-if="!isSelectionMode" label="操作" width="180" align="center" fixed="right">
            <template #default="{ row }">
              <div class="action-buttons">
                <el-button size="small" type="primary" @click="viewHomework(row)" class="action-btn">
                  <el-icon><Edit /></el-icon>
                  修改
                </el-button>
                <el-button size="small" type="danger" @click="deleteHomework(row.id)" class="action-btn">
                  <el-icon><Delete /></el-icon>
                  删除
                </el-button>
              </div>
            </template>
          </el-table-column>
        </el-table>

        <!-- 分页区域 -->
        <div v-if="filteredHomeworks.length > 0" class="pagination-wrapper">
          <div class="pagination-info">
            <span class="pagination-text">
              共 {{ filteredHomeworks.length }} 条记录，第 {{ currentPage }} / {{ Math.ceil(filteredHomeworks.length / pageSize) }} 页
            </span>
          </div>
          <el-pagination
            background
            layout="sizes, prev, pager, next, jumper"
            :current-page="currentPage"
            :page-size="pageSize"
            :page-sizes="[10,20,50]"
            :total="filteredHomeworks.length"
            @current-change="handlePageChange"
            @size-change="handleSizeChange"
            class="pagination"
          />
        </div>
      </el-card>
    </div>
  </section>
</template>


<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Document, 
  Search, 
  Refresh, 
  Check, 
  Plus, 
  Clock, 
  Edit, 
  Delete 
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const selectedSubject = ref(route.query.subject || '')
const searchKeyword = ref('') // 搜索关键词

const homeworks = ref([])
const total = ref(0)
const selectedCourse = ref('') // ✅ 当前选中的课程 ID
const courseOptions = ref([])  // ✅ 课程下拉选项
const subjectOptions = ref([]) // ✅ 知识点分类选项
const selectedType = ref('')   // ✅ 当前选中的题型
const typeOptions = ref([])    // ✅ 题型选项
const selectedBank = ref('')   // ✅ 当前选中的题库分类
const bankOptions = ref([])    // ✅ 题库分类选项

const fromCreateHomework = computed(() => route.query.from === 'create-homework')
const fromCreateExam = computed(() => route.query.from === 'create-exam')
const isSelectionMode = computed(() => fromCreateHomework.value || fromCreateExam.value)

const filteredHomeworks = computed(() => {
  return homeworks.value.filter(hw => {
    const matchSubject = !selectedSubject.value || hw.subject === selectedSubject.value
    const matchCourse = !selectedCourse.value || hw.courseName === selectedCourse.value
    const matchType = !selectedType.value || hw.typeValue === selectedType.value
    const matchBank = !selectedBank.value || hw.bankCategoryId === selectedBank.value
    const matchSearch = !searchKeyword.value || hw.title.toLowerCase().includes(searchKeyword.value.toLowerCase())
    return matchSubject && matchCourse && matchType && matchBank && matchSearch
  })
})
const selectedRows = ref([])

const currentPage = ref(1)
const pageSize = ref(10)

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredHomeworks.value.slice(start, end)
})
const handlePageChange = (p) => {
  currentPage.value = p
}
const handleSizeChange = (s) => {
  pageSize.value = s
  currentPage.value = 1
}

const handleSelectionChange = (selection) => {
  selectedRows.value = selection
}

const confirmSelection = () => {
  if (selectedRows.value.length === 0) {
    ElMessage.warning('请至少选择一个题目')
    return
  }

  const courseId = selectedRows.value[0]?.courseId || ''

  localStorage.setItem('selectedQuestions', JSON.stringify({
    courseId,
    questions: selectedRows.value
  }))

  if (fromCreateHomework.value) {
    router.push({ name: 'CreateHomework', query: { from: 'create-homework' } })
  } else if (fromCreateExam.value) {
    router.push({ name: 'CreateExam', query: { from: 'create-exam' } })
  }
}

const addHomework = () => {
  router.push('/teacher_school/addWork')
}

// ✅ 重置所有筛选条件
const resetFilters = () => {
  selectedCourse.value = ''
  selectedSubject.value = ''
  selectedType.value = ''
  selectedBank.value = ''
  searchKeyword.value = ''
}

// 获取题目类型标签颜色
const getTypeTagType = (typeValue) => {
  const typeMap = {
    'choice': 'success',
    'short_answer': 'warning',
    'programming': 'danger'
  }
  return typeMap[typeValue] || 'info'
}

// ✅ 题目类型转换函数
const getTypeDisplayName = (type) => {
  const typeMap = {
    'choice': '选择题',
    'short_answer': '简答题',
    'programming': '编程题'
  }
  return typeMap[type] || type
}

// ✅ 根据课程ID获取课程名称
const getCourseNameById = (courseId) => {
  const course = courseOptions.value.find(c => c.id === courseId)
  return course ? course.courseName : `课程${courseId}`
}

const viewHomework = (hw) => {
  router.push({
    path: '/teacher_school/addWork',
    query: {
      editId: hw.id   // ✅ 明确传递题目 ID
    }
  })
}
const deleteHomework = async (id) => {
  try {
    await ElMessageBox.confirm('确认删除该题目吗？', '提示', {
      type: 'warning',
      confirmButtonText: '确定',
      cancelButtonText: '取消',
    })

    const res = await axios.delete('/api/xiaozhi/teacher/question/delete', {
      params: { id }
    })

    if (res.data.code === 200) {
      ElMessage.success('✅ 删除成功')
      homeworks.value = homeworks.value.filter(hw => hw.id !== id)
    } else {
      ElMessage.error('❌ 删除失败：' + res.data.message)
    }

  } catch (err) {
    if (err !== 'cancel') {
      ElMessage.error('❌ 请求异常：' + err.message)
    } else {
      ElMessage.info('已取消删除')
    }
  }
}



// ✅ 可选：从后端加载课程列表
const fetchCourses = async () => {
  try {
    const res = await axios.get('/api/xiaozhi/teacher/courses')
    if (res.data.code === 200) {
      courseOptions.value = res.data.data
    } else {
      ElMessage.error('获取课程失败: ' + res.data.message)
    }
  } catch (e) {
    ElMessage.error('获取课程异常: ' + e.message)
  }
}

// ✅ 获取知识点分类列表
const fetchSubjects = async () => {
  try {
    const res = await axios.get('/api/xiaozhi/teacher/question/subjects')
    if (res.data.code === 200) {
      subjectOptions.value = res.data.data || []
    } else {
      // 如果后端没有专门的接口，从题目中提取知识点
      const subjects = [...new Set(homeworks.value.map(hw => hw.subject).filter(Boolean))]
      subjectOptions.value = subjects
    }
  } catch (e) {
    // 如果请求失败，从现有题目中提取知识点
    const subjects = [...new Set(homeworks.value.map(hw => hw.subject).filter(Boolean))]
    subjectOptions.value = subjects
  }
}

// ✅ 获取题型列表
const fetchTypes = async () => {
  try {
    const res = await axios.get('/api/xiaozhi/teacher/question/types')
    if (res.data.code === 200) {
      typeOptions.value = res.data.data || []
    } else {
      // 如果后端没有专门的接口，从题目中提取题型
      const types = [...new Set(homeworks.value.map(hw => hw.typeValue).filter(Boolean))]
      typeOptions.value = types.map(type => ({
        value: type,
        label: getTypeDisplayName(type)
      }))
    }
  } catch (e) {
    // 如果请求失败，从现有题目中提取题型
    const types = [...new Set(homeworks.value.map(hw => hw.typeValue).filter(Boolean))]
    typeOptions.value = types.map(type => ({
      value: type,
      label: getTypeDisplayName(type)
    }))
  }
}

// ✅ 获取题库分类列表
const fetchBanks = async () => {
  try {
    const res = await axios.get('/question-generator/categories')
    if (res.data.code === 200) {
      bankOptions.value = (res.data.data || []).map(item => ({
        value: item.id,
        label: item.name,
        description: item.description,
        color: item.color,
        icon: item.icon
      }))
    } else {
      ElMessage.error('获取题库分类失败: ' + res.data.message)
      // 如果后端没有专门的接口，从题目中提取题库分类
      const banks = [...new Set(homeworks.value.map(hw => hw.bankCategory).filter(Boolean))]
      bankOptions.value = banks.map(bank => ({ value: bank, label: bank }))
    }
  } catch (e) {
    ElMessage.error('获取题库分类异常: ' + e.message)
    // 如果请求失败，从现有题目中提取题库分类
    const banks = [...new Set(homeworks.value.map(hw => hw.bankCategory).filter(Boolean))]
    bankOptions.value = banks.map(bank => ({ value: bank, label: bank }))
  }
}



const fetchQuestions = async () => {
  loading.value = true
  try {
    // 获取所有题目数据，不分页
    const res = await axios.get('/api/xiaozhi/teacher/question/list')
    if (res.data.code === 200) {
      homeworks.value = (res.data.data || []).map(item => ({
        id: item.id,
        title: item.content,
        subject: item.knowledgePoint,
        type: getTypeDisplayName(item.type), // 转换为中文显示
        typeValue: item.type, // 保留原始值用于筛选
        courseId: item.courseId,
        courseName: item.courseName || getCourseNameById(item.courseId), // 添加课程名称
        bankCategory: item.bankCategory || item.category || '默认分类',
        bankCategoryId: item.categoryId, // 使用正确的字段名
        createdAt: item.createdAt
      }))
    } else {
      ElMessage.error('加载题目失败: ' + res.data.message)
    }
  } catch (e) {
    ElMessage.error('请求错误: ' + e.message)
  } finally {
    loading.value = false
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

// 👇 页面加载时一并加载所有筛选选项
onMounted(async () => {
  console.log('HomeworkOverview component mounted')
  console.log('Current route:', route.path)
  await fetchCourses()
  await fetchQuestions()
  await fetchSubjects()
  await fetchTypes()
  await fetchBanks()
})

</script>

<style scoped>
.homework-dashboard {
  flex: 1;
  min-height: 100vh;
  padding: 0;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
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
  font-size: 1.5rem;
  color: #667eea;
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
  gap: 1rem;
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
  flex-wrap: wrap;
}

.filter-select {
  width: 160px;
}

.reset-btn {
  color: #64748b;
  border-color: #e2e8f0;
}

.reset-btn:hover {
  color: #3b82f6;
  border-color: #3b82f6;
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
.question-table {
  border-radius: 8px;
  overflow: hidden;
}

.question-table :deep(.el-table__header) {
  background: #f8f9fa;
}

.question-table :deep(.el-table__row) {
  transition: all 0.3s ease;
}

.question-table :deep(.el-table__row:hover) {
  background: #f0f9ff;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.question-id {
  font-weight: 600;
  color: #667eea;
  font-family: 'Courier New', monospace;
}

.question-content {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.question-icon {
  color: #409eff;
  font-size: 1rem;
}

.question-text {
  font-weight: 500;
  color: #303133;
}

.time-info {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.875rem;
  color: #64748b;
}

.time-icon {
  font-size: 0.875rem;
}

.action-buttons {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  justify-content: center;
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
}

/* 响应式设计 */
@media (max-width: 768px) {
  .homework-dashboard {
    padding: 0;
  }
  
  .page-header {
    padding: 1.5rem;
    margin: 1rem;
  }
  
  .header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
  
  .search-section {
    margin: 0 1rem 1rem;
  }
  
  .search-bar {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }
  
  .search-right {
    flex-direction: column;
    gap: 0.75rem;
  }
  
  .filter-select {
    width: 100%;
  }
  
  .table-container {
    margin: 0 1rem 1rem;
  }
  
  .pagination-wrapper {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }
}
</style>
