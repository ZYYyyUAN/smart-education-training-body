<template>
  <div class="admin-question-bank-management" :style="backgroundStyle">
    <div class="management-container">
      <!-- 页面头部 -->
      <div class="page-header">
        <div class="header-content">
          <div class="header-left">
            <h1 class="page-title">
              <el-icon class="title-icon"><DataLine /></el-icon>
              题库管理
            </h1>
            <p class="page-subtitle">统一管理所有题目资源，支持多维度筛选与检索</p>
          </div>
          <div class="header-right">
            <!-- 顶部预留操作区域 -->
          </div>
        </div>
      </div>

      <!-- 大型检索选择框区域（仿洛谷/LeetCode风格） -->
      <div class="search-filter-panel">
        <div class="filter-header">
          <el-icon><Filter /></el-icon>
          <span>高级筛选</span>
        </div>
        <div class="filter-grid">
          <!-- 科目筛选 -->
          <div class="filter-item">
            <label class="filter-label">科目</label>
            <el-select 
              v-model="filters.courseId" 
              placeholder="选择科目" 
              class="filter-select-large"
              clearable 
              @change="applyFilters"
            >
              <el-option 
                v-for="course in courses" 
                :key="course.id" 
                :label="course.courseName" 
                :value="course.id" 
              />
            </el-select>
          </div>

          <!-- 题目类型筛选 -->
          <div class="filter-item">
            <label class="filter-label">题目类型</label>
            <el-select 
              v-model="filters.type" 
              placeholder="选择类型" 
              class="filter-select-large"
              clearable 
              @change="applyFilters"
            >
              <el-option label="选择题" value="choice" />
              <el-option label="简答题" value="short_answer" />
              <el-option label="编程题" value="programming" />
            </el-select>
          </div>

          <!-- 题库分类筛选 -->
          <div class="filter-item">
            <label class="filter-label">题库分类</label>
            <el-select 
              v-model="filters.categoryId" 
              placeholder="选择分类" 
              class="filter-select-large"
              clearable 
              @change="applyFilters"
            >
              <el-option 
                v-for="cat in categories" 
                :key="cat.id" 
                :label="cat.name" 
                :value="cat.id" 
              />
            </el-select>
          </div>

          <!-- 难易程度筛选 -->
          <div class="filter-item">
            <label class="filter-label">难易程度</label>
            <el-select 
              v-model="filters.difficultyLevel" 
              placeholder="选择难度" 
              class="filter-select-large"
              clearable 
              @change="applyFilters"
            >
              <el-option label="简单" value="easy" />
              <el-option label="中等" value="medium" />
              <el-option label="困难" value="hard" />
            </el-select>
          </div>

          <!-- 知识点模糊搜索 -->
          <div class="filter-item full-width">
            <label class="filter-label">知识点搜索</label>
            <el-input
              v-model="filters.knowledgePoint"
              placeholder="输入知识点关键词进行模糊搜索..."
              class="filter-input-large"
              clearable
              @input="applyFilters"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </div>

          <!-- 重置按钮 -->
          <div class="filter-item filter-actions">
            <el-button 
              type="info" 
              size="default" 
              @click="resetFilters"
              class="reset-btn"
            >
              <el-icon><Refresh /></el-icon>
              重置筛选
            </el-button>
          </div>
        </div>
      </div>

      <!-- 主体+侧栏 -->
      <div class="content-layout">
        <!-- 题目列表表格 -->
        <div class="table-section">
          <el-card shadow="hover" class="table-card">
            <el-table
              :data="pagedQuestions"
              v-loading="loading"
              class="management-table"
              empty-text="暂无题目"
              stripe
            >
              <el-table-column label="题目ID" width="100" align="center">
                <template #default="{ $index }">
                  <span class="item-id">{{ String(($index + 1) + (currentPage - 1) * pageSize).padStart(4, '0') }}</span>
                </template>
              </el-table-column>

              <el-table-column label="科目" width="150" align="center">
                <template #default="{ row }">
                  <div class="course-info">
                    <el-icon class="course-icon"><Reading /></el-icon>
                    <span>{{ getCourseName(row.courseId) || '-' }}</span>
                  </div>
                </template>
              </el-table-column>

              <el-table-column label="题库分类" width="170" align="center" show-overflow-tooltip>
                <template #default="{ row }">
                  <el-tag type="info" class="category-tag">
                    {{ getCategoryName(row.categoryId) }}
                  </el-tag>
                </template>
              </el-table-column>

              <el-table-column prop="content" label="题目内容" min-width="300" show-overflow-tooltip>
                <template #default="{ row }">
                  <div class="question-content">
                    <el-icon class="item-icon"><Document /></el-icon>
                    <span v-html="truncateContent(row.content)"></span>
                  </div>
                </template>
              </el-table-column>

              <el-table-column label="类型" width="100" align="center">
                <template #default="{ row }">
                  <el-tag 
                    :type="getTypeTagType(row.type)" 
                    size="small"
                    class="type-tag"
                  >
                    {{ getTypeText(row.type) }}
                  </el-tag>
                </template>
              </el-table-column>

              <el-table-column label="难度" width="100" align="center">
                <template #default="{ row }">
                  <el-tag 
                    :type="getDifficultyTagType(row.difficultyLevel)" 
                    size="small"
                    class="difficulty-tag"
                  >
                    {{ getDifficultyText(row.difficultyLevel) }}
                  </el-tag>
                </template>
              </el-table-column>

              <el-table-column label="知识点" min-width="200" show-overflow-tooltip>
                <template #default="{ row }">
                  <div class="knowledge-point">
                    <el-icon class="kp-icon"><Collection /></el-icon>
                    <span>{{ row.knowledgePoint || '-' }}</span>
                  </div>
                </template>
              </el-table-column>

              <el-table-column label="操作" width="200" align="center" fixed="right">
                <template #default="{ row }">
                  <div class="action-buttons">
                    <el-button 
                      size="small" 
                      type="primary" 
                      class="action-btn"
                      @click="editQuestion(row)"
                    >
                      <el-icon><Edit /></el-icon>
                      编辑
                    </el-button>
                    <el-button 
                      size="small" 
                      type="danger" 
                      class="action-btn"
                      @click="deleteQuestion(row.id)"
                    >
                      <el-icon><Delete /></el-icon>
                      删除
                    </el-button>
                  </div>
                </template>
              </el-table-column>
            </el-table>
          </el-card>

          <!-- 分页器 -->
          <div class="pagination-wrapper">
            <div class="pagination-info">
              <span class="pagination-text">
                共 {{ filteredQuestions.length }} 条记录，第 {{ currentPage }} / {{ Math.ceil(filteredQuestions.length / pageSize) }} 页
              </span>
            </div>
            <el-pagination
              background
              layout="prev, pager, next, jumper"
              :total="filteredQuestions.length"
              :page-size="pageSize"
              :current-page="currentPage"
              @current-change="(p) => (currentPage = p)"
              class="pagination"
            />
          </div>
        </div>

        <!-- 右侧可视化 -->
        <div class="insight-sidebar">
          <el-card class="insight-card" shadow="hover">
            <div class="insight-title">
              <el-icon><PieChart /></el-icon>
              <span>分类分布</span>
            </div>
            <div class="insight-list">
              <div 
                v-for="cat in categoryDistribution" 
                :key="cat.name" 
                class="insight-row"
              >
                <div class="insight-row-left">
                  <span class="dot" />
                  <span class="label">{{ cat.name }}</span>
                </div>
                <div class="insight-row-right">
                  <div class="bar">
                    <div class="bar-fill" :style="{ width: cat.percent + '%' }" />
                  </div>
                  <span class="value">{{ cat.count }}</span>
                </div>
              </div>
              <div v-if="!categoryDistribution.length" class="empty-text">暂无分类数据</div>
            </div>
          </el-card>

          <el-card class="insight-card" shadow="hover">
            <div class="insight-title">
              <el-icon><Histogram /></el-icon>
              <span>难度分布</span>
            </div>
            <div class="difficulty-grid">
              <div class="difficulty-block" v-for="d in difficultyDistribution" :key="d.key">
                <div class="ring" :style="{ background: d.gradient }">
                  <div class="ring-inner">
                    <span class="ring-value">{{ d.count }}</span>
                  </div>
                </div>
                <div class="ring-label">{{ d.label }}</div>
              </div>
              <div v-if="!difficultyDistribution.length" class="empty-text">暂无难度数据</div>
            </div>
          </el-card>
        </div>
      </div>
    </div>

    <!-- 编辑题目对话框 -->
    <el-dialog
      v-model="showEditDialog"
      title="编辑题目"
      width="800px"
      :close-on-click-modal="false"
      class="edit-dialog edit-question-dialog"
    >
      <el-form
        :model="editForm"
        label-width="120px"
        :rules="editRules"
        ref="editFormRef"
      >
        <el-form-item label="题目标题/内容" prop="content">
          <el-input
            v-model="editForm.content"
            type="textarea"
            :rows="4"
            placeholder="请输入题目内容"
          />
        </el-form-item>
        <el-form-item label="所属课程" prop="courseId">
          <el-select v-model="editForm.courseId" placeholder="请选择课程" style="width: 100%">
            <el-option
              v-for="course in courses"
              :key="course.id"
              :label="course.courseName"
              :value="course.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="题库分类" prop="categoryId">
          <el-select v-model="editForm.categoryId" placeholder="请选择分类" style="width: 100%" clearable>
            <el-option
              v-for="cat in categories"
              :key="cat.id"
              :label="cat.name"
              :value="cat.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="题目类型" prop="type">
          <el-select v-model="editForm.type" placeholder="请选择题目类型" style="width: 100%">
            <el-option label="选择题" value="choice" />
            <el-option label="简答题" value="short_answer" />
            <el-option label="编程题" value="programming" />
          </el-select>
        </el-form-item>
        <el-form-item label="难易程度" prop="difficultyLevel">
          <el-select v-model="editForm.difficultyLevel" placeholder="请选择难度" style="width: 100%">
            <el-option label="简单" value="easy" />
            <el-option label="中等" value="medium" />
            <el-option label="困难" value="hard" />
          </el-select>
        </el-form-item>
        <el-form-item label="知识点" prop="knowledgePoint">
          <el-input
            v-model="editForm.knowledgePoint"
            placeholder="请输入知识点"
          />
        </el-form-item>
         <el-form-item label="答案" prop="answer">
           <el-input
             v-model="editForm.answer"
             type="textarea"
             :rows="3"
             placeholder="请输入答案"
           />
         </el-form-item>
         <el-form-item label="题目标签">
          <el-input
            v-model="editForm.tags"
            placeholder="多个标签用逗号分隔"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showEditDialog = false">取消</el-button>
          <el-button type="primary" @click="submitEdit" :loading="editSubmitting">
            确定
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  DataLine,
  Filter,
  Search,
  Refresh,
  Document, 
  Reading, 
  Edit, 
  Delete,
  Collection,
  PieChart,
  Histogram
} from '@element-plus/icons-vue'
import bgImg from '@/assets/images/bgi2.png'

const backgroundStyle = computed(() => ({
  backgroundImage: `url(${bgImg})`,
  backgroundSize: 'cover',
  backgroundPosition: 'center center',
  backgroundRepeat: 'no-repeat'
}))

// 加载状态
const loading = ref(false)

// 数据
const questions = ref([])
const courses = ref([])
const categories = ref([])

// 筛选条件
const filters = ref({
  courseId: '',
  type: '',
  difficultyLevel: '',
  knowledgePoint: '',
  categoryId: ''
})

// 编辑相关
const showEditDialog = ref(false)
const editForm = ref({
  id: null,
  content: '',
  courseId: null,
  type: '',
  difficultyLevel: '',
  knowledgePoint: '',
  categoryId: null,
  answer: '',
  tags: ''
})
const editFormRef = ref(null)
const editSubmitting = ref(false)
const editRules = {
  content: [{ required: true, message: '请输入题目内容', trigger: 'blur' }],
  courseId: [{ required: true, message: '请选择课程', trigger: 'change' }],
  type: [{ required: true, message: '请选择题目类型', trigger: 'change' }],
  difficultyLevel: [{ required: true, message: '请选择难度', trigger: 'change' }],
  knowledgePoint: [{ required: true, message: '请输入知识点', trigger: 'blur' }],
  categoryId: [{ required: false }],
  answer: [{ required: true, message: '请输入答案', trigger: 'blur' }]
}

// 分页
const currentPage = ref(1)
const pageSize = 10

// 筛选后的题目列表
const filteredQuestions = computed(() => {
  let filtered = questions.value

  // 按课程筛选
  if (filters.value.courseId) {
    filtered = filtered.filter(q => String(q.courseId) === String(filters.value.courseId))
  }

  // 按类型筛选
  if (filters.value.type) {
    filtered = filtered.filter(q => q.type === filters.value.type)
  }

  // 按分类筛选
  if (filters.value.categoryId) {
    filtered = filtered.filter(q => String(q.categoryId) === String(filters.value.categoryId))
  }

  // 按难度筛选
  if (filters.value.difficultyLevel) {
    filtered = filtered.filter(q => q.difficultyLevel === filters.value.difficultyLevel)
  }

  // 按知识点模糊搜索
  if (filters.value.knowledgePoint && filters.value.knowledgePoint.trim()) {
    const keyword = filters.value.knowledgePoint.trim().toLowerCase()
    filtered = filtered.filter(q => 
      q.knowledgePoint && q.knowledgePoint.toLowerCase().includes(keyword)
    )
  }

  return filtered
})

// 分页后的题目列表
const pagedQuestions = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  return filteredQuestions.value.slice(start, start + pageSize)
})

// 获取题目列表
const fetchQuestions = async () => {
  loading.value = true
  try {
    const res = await axios.get('/api/xiaozhi/teacher/question/list')
    if (res.data.code === 200) {
      questions.value = res.data.data || []
    } else {
      ElMessage.error('加载题目失败: ' + res.data.message)
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

// 加载题库分类列表
const loadCategories = async () => {
  try {
    const res = await axios.get('/api/question-generator/categories')
    const list = Array.isArray(res.data) ? res.data : res.data?.data || []
    categories.value = list || []
  } catch (error) {
    console.error('加载分类失败:', error)
    ElMessage.error('加载分类失败')
  }
}

// 获取课程名称
const getCourseName = (courseId) => {
  const course = courses.value.find(c => String(c.id) === String(courseId))
  return course?.courseName || '未知课程'
}

// 获取分类名称
const getCategoryName = (categoryId) => {
  if (!categoryId) return '未分配分类'
  const cat = categories.value.find(c => String(c.id) === String(categoryId))
  return cat?.name || '未分配分类'
}

// 应用筛选
const applyFilters = () => {
  currentPage.value = 1
}

// 重置筛选
const resetFilters = () => {
  filters.value = {
    courseId: '',
    type: '',
    difficultyLevel: '',
    knowledgePoint: '',
    categoryId: ''
  }
  currentPage.value = 1
}

// 题目类型相关
const getTypeText = (type) => {
  const map = {
    'choice': '选择题',
    'short_answer': '简答题',
    'programming': '编程题'
  }
  return map[type] || type
}

const getTypeTagType = (type) => {
  const map = {
    'choice': 'primary',
    'short_answer': 'success',
    'programming': 'warning'
  }
  return map[type] || 'info'
}

// 难度相关
const getDifficultyText = (difficulty) => {
  const map = {
    'easy': '简单',
    'medium': '中等',
    'hard': '困难'
  }
  return map[difficulty] || difficulty
}

const getDifficultyTagType = (difficulty) => {
  const map = {
    'easy': 'success',
    'medium': 'warning',
    'hard': 'danger'
  }
  return map[difficulty] || 'info'
}

// 截断内容
const truncateContent = (content) => {
  if (!content) return '-'
  const text = content.replace(/<[^>]*>/g, '') // 移除HTML标签
  return text.length > 100 ? text.substring(0, 100) + '...' : text
}

// 格式化日期
const formatDate = (value) => {
  if (!value) return '-'
  
  let dt
  if (typeof value === 'string') {
    // 处理字符串格式的日期（可能是 "2024-01-01T10:30:00" 或 "2024-01-01 10:30:00"）
    // 移除 T 和毫秒部分，统一为空格分隔
    const dateStr = value.replace('T', ' ').split('.')[0].trim()
    dt = new Date(dateStr)
  } else if (Array.isArray(value)) {
    // 处理数组格式：[2024, 1, 1, 10, 30, 0]
    const [y, m, d, h = 0, mi = 0, s = 0] = value
    if (!y || !m || !d) return '-'
    dt = new Date(y, m - 1, d, h, mi, s)
  } else if (typeof value === 'object' && value.year && value.month && value.day) {
    // 处理对象格式：{year: 2024, month: 1, day: 1, hour: 10, minute: 30}
    const { year: y, month: m, day: d, hour: h = 0, minute: mi = 0, second: s = 0 } = value
    dt = new Date(y, m - 1, d, h, mi, s)
  } else {
    dt = new Date(value)
  }
  
  if (isNaN(dt.getTime())) {
    console.warn('无法解析日期:', value)
    return '-'
  }
  
  const pad = n => String(n).padStart(2, '0')
  return `${dt.getFullYear()}-${pad(dt.getMonth()+1)}-${pad(dt.getDate())} ${pad(dt.getHours())}:${pad(dt.getMinutes())}`
}

// 分类分布（用于右侧可视化）
const categoryDistribution = computed(() => {
  if (!filteredQuestions.value.length) return []
  const total = filteredQuestions.value.length
  const map = {}
  filteredQuestions.value.forEach(q => {
    const key = getCategoryName(q.categoryId)
    map[key] = (map[key] || 0) + 1
  })
  return Object.entries(map).map(([name, count]) => ({
    name,
    count,
    percent: Math.round((count / total) * 100)
  })).sort((a, b) => b.count - a.count).slice(0, 6)
})

// 难度分布（用于右侧可视化）
const difficultyDistribution = computed(() => {
  if (!filteredQuestions.value.length) return []
  const presets = [
    { key: 'easy', label: '简单', gradient: 'conic-gradient(from 90deg, #34d399, #10b981, #34d399)' },
    { key: 'medium', label: '中等', gradient: 'conic-gradient(from 90deg, #60a5fa, #3b82f6, #60a5fa)' },
    { key: 'hard', label: '困难', gradient: 'conic-gradient(from 90deg, #f59e0b, #ef4444, #f59e0b)' }
  ]
  return presets.map(p => ({
    ...p,
    count: filteredQuestions.value.filter(q => q.difficultyLevel === p.key).length
  })).filter(i => i.count > 0)
})

// 编辑题目
const editQuestion = (row) => {
  editForm.value = {
    id: row.id,
    content: row.content || '',
    courseId: row.courseId || null,
    type: row.type || '',
    difficultyLevel: row.difficultyLevel || '',
    knowledgePoint: row.knowledgePoint || '',
    categoryId: row.categoryId || null,
    answer: row.answer || '',
    tags: row.tags || ''
  }
  showEditDialog.value = true
}

// 提交编辑
const submitEdit = async () => {
  if (!editFormRef.value) return
  
  try {
    await editFormRef.value.validate()
    editSubmitting.value = true
    
    const res = await axios.put('/api/xiaozhi/teacher/question/update', editForm.value)
    if (res.data.code === 200) {
      ElMessage.success('题目更新成功')
      showEditDialog.value = false
      await fetchQuestions()
    } else {
      ElMessage.error('更新失败: ' + res.data.message)
    }
  } catch (e) {
    if (e !== false) {
      ElMessage.error('请求错误: ' + e.message)
    }
  } finally {
    editSubmitting.value = false
  }
}

// 删除题目
const deleteQuestion = async (id) => {
  try {
    await ElMessageBox.confirm('确定要删除这个题目吗？删除前会检查是否被试卷引用。', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const res = await axios.delete('/api/xiaozhi/teacher/question/delete', { 
      params: { id } 
    })
    if (res.data.code === 200) {
      ElMessage.success('删除成功')
      questions.value = questions.value.filter(q => q.id !== id)
    } else {
      ElMessage.error('删除失败: ' + res.data.message)
    }
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('请求错误: ' + e.message)
    }
  }
}

onMounted(async () => {
  await Promise.all([
    loadCourses(),
    loadCategories(),
    fetchQuestions()
  ])
})
</script>

<style scoped>
.admin-question-bank-management {
  width: 100%;
  height: 100%;
  background: transparent;
  padding: 15px;
  overflow-y: auto;
  overflow-x: hidden;
  color: #fff;
  box-sizing: border-box;
}

.management-container {
  width: 100%;
  max-width: 100%;
  margin: 0;
  height: 100%;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
}

.content-layout {
  display: flex;
  gap: 14px;
  align-items: flex-start;
  width: 100%;
  box-sizing: border-box;
}

.table-section {
  flex: 1;
  min-width: 0;
}

.insight-sidebar {
  width: 280px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.insight-card {
  background: rgba(4, 10, 24, 0.78);
  border: 1px solid rgba(0, 242, 254, 0.2);
  color: #e9f2ff;
}

.insight-title {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #00f2fe;
  font-weight: 700;
  margin-bottom: 8px;
}

.insight-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.insight-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
  padding: 6px 8px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 8px;
}

.insight-row-left {
  display: flex;
  align-items: center;
  gap: 6px;
}

.insight-row .dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #00f2fe;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.8);
}

.insight-row .label {
  color: #e9f2ff;
}

.insight-row-right {
  display: flex;
  align-items: center;
  gap: 6px;
  min-width: 120px;
}

.insight-row .bar {
  flex: 1;
  height: 6px;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 999px;
  overflow: hidden;
}

.insight-row .bar-fill {
  height: 100%;
  background: linear-gradient(90deg, #00f2fe, #00bfff);
}

.insight-row .value {
  color: #9fb6d1;
  font-size: 12px;
  min-width: 24px;
  text-align: right;
}

.difficulty-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.difficulty-block {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
}

.ring {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  padding: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 0 12px rgba(0, 242, 254, 0.2);
}

.ring-inner {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background: rgba(0, 8, 20, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #e9f2ff;
  font-weight: 700;
  font-size: 14px;
}

.ring-label {
  color: #9fb6d1;
  font-size: 12px;
}

.empty-text {
  color: #6c7a92;
  font-size: 12px;
  text-align: center;
  padding: 4px 0;
}

/* 页面头部 */
.page-header {
  background: rgba(8, 16, 45, 0.6);
  border: 1px solid rgba(0, 191, 255, 0.3);
  padding: 1.5rem 2rem;
  border-radius: 8px;
  color: #fff;
  margin-bottom: 15px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
  position: relative;
}

.page-header::before {
  content: '';
  position: absolute;
  left: 5px;
  top: 10px;
  width: 4px;
  height: 16px;
  background: #00f2fe;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  flex: 1;
}

.page-title {
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0 0 0.5rem 0;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: #00f2fe;
}

.title-icon {
  font-size: 1.8rem;
  color: #00bfff;
}

.page-subtitle {
  font-size: 0.9rem;
  color: rgba(255, 255, 255, 0.7);
  margin: 0;
  margin-left: 2.5rem;
}

/* 大型筛选面板 */
.search-filter-panel {
  background: rgba(8, 16, 45, 0.6);
  border: 1px solid rgba(0, 191, 255, 0.3);
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 15px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
  position: relative;
}

.search-filter-panel::before {
  content: '';
  position: absolute;
  left: 5px;
  top: 8px;
  width: 4px;
  height: 16px;
  background: #00f2fe;
}

.filter-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.1rem;
  font-weight: 600;
  color: #00f2fe;
  margin-bottom: 1.5rem;
}

.filter-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1rem;
  align-items: end;
}

.filter-item {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.filter-item.full-width {
  grid-column: 1 / -1;
}

.filter-item.filter-actions {
  grid-column: 4;
  align-items: flex-end;
  justify-content: flex-end;
}

.filter-label {
  font-size: 0.9rem;
  color: rgba(255, 255, 255, 0.8);
  font-weight: 500;
}

.filter-select-large,
.filter-input-large {
  width: 100%;
}

.search-filter-panel :deep(.el-input__wrapper) {
  background-color: rgba(0, 0, 0, 0.3);
  border: 1px solid rgba(0, 191, 255, 0.3);
  box-shadow: none;
}

.search-filter-panel :deep(.el-input__inner) {
  color: #fff;
}

.search-filter-panel :deep(.el-input__inner::placeholder) {
  color: rgba(255, 255, 255, 0.5);
}

.search-filter-panel :deep(.el-select__wrapper) {
  background-color: rgba(0, 0, 0, 0.3);
  border: 1px solid rgba(0, 191, 255, 0.3);
  box-shadow: none;
}

.search-filter-panel :deep(.el-select__placeholder) {
  color: rgba(255, 255, 255, 0.5);
}

.reset-btn {
  background: rgba(0, 0, 0, 0.3);
  border: 1px solid rgba(0, 191, 255, 0.3);
  color: rgba(255, 255, 255, 0.8);
  font-weight: 500;
}

.reset-btn:hover {
  background: rgba(0, 191, 255, 0.2);
  border-color: #00bfff;
  color: #fff;
}

/* 表格区域 */
.table-section {
  margin-bottom: 15px;
  min-height: 400px;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.table-card {
  border-radius: 8px;
  overflow: visible;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
  background: rgba(8, 16, 45, 0.6);
  border: 1px solid rgba(0, 191, 255, 0.3);
  flex: 1;
  display: flex;
  flex-direction: column;
  position: relative;
}

.table-card::before {
  content: '';
  position: absolute;
  top: -1px;
  left: -1px;
  width: 10px;
  height: 10px;
  border: 2px solid #00bfff;
  border-right: none;
  border-bottom: none;
  z-index: 1;
}

.table-card::after {
  content: '';
  position: absolute;
  top: -1px;
  right: -1px;
  width: 10px;
  height: 10px;
  border: 2px solid #00bfff;
  border-left: none;
  border-bottom: none;
  z-index: 1;
}

.table-card :deep(.el-card__body) {
  padding: 0;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.management-table {
  border-radius: 8px;
  overflow: hidden;
  background: transparent;
  flex: 1;
  min-width: 1100px;
}

.management-table :deep(.el-table__header-wrapper) {
  background-color: #071024 !important;
}

.management-table :deep(.el-table__header) {
  background-color: #071024 !important;
  border-bottom: 1px solid rgba(0, 191, 255, 0.35);
}

.management-table :deep(.el-table__header tr) {
  background-color: #071024 !important;
}

.management-table :deep(.el-table__header th) {
  background-color: #071024 !important;
  color: #55c3ff;
  border-bottom: none;
  font-weight: 600;
  padding: 14px 12px;
  text-shadow: 0 0 6px rgba(0, 191, 255, 0.25);
}

.management-table :deep(.el-table__header th:first-child) {
  border-left: 2px solid rgba(0, 191, 255, 0.25);
}

.management-table :deep(.el-table__body) {
  background: transparent;
}

.management-table :deep(.el-table__row) {
  background: rgba(8, 20, 40, 0.85) !important;
  transition: all 0.25s ease;
  color: rgba(255, 255, 255, 0.9);
}

.management-table :deep(.el-table__row:nth-child(even)) {
  background: rgba(12, 24, 48, 0.88) !important;
}

.management-table :deep(.el-table__row:hover) {
  background: rgba(10, 30, 55, 0.95) !important;
  transform: translateX(1px);
  box-shadow: -2px 0 8px rgba(0, 191, 255, 0.18), 0 0 10px rgba(0, 191, 255, 0.12);
  border-left: 2px solid rgba(0, 191, 255, 0.4);
}

.management-table :deep(.el-table__body tr:hover>td),
.management-table :deep(.el-table__body tr.el-table__row--striped:hover>td) {
  background-color: rgba(10, 30, 55, 0.95) !important;
}

.management-table :deep(.el-table__row td) {
  background-color: transparent !important;
  border-bottom: 1px solid rgba(0, 191, 255, 0.15);
  padding: 12px 12px;
  color: rgba(255, 255, 255, 0.9) !important;
}

.management-table :deep(.el-table__empty-block) {
  background: transparent;
  color: rgba(255, 255, 255, 0.7);
}

.management-table :deep(.el-loading-mask) {
  background-color: rgba(8, 16, 45, 0.8);
}

.management-table :deep(.el-loading-spinner) {
  color: #00bfff;
}

.item-id {
  font-weight: 600;
  color: #00bfff;
  font-family: 'Courier New', monospace;
  text-shadow: 0 0 5px rgba(0, 191, 255, 0.5);
}

.course-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  justify-content: center;
}

.category-tag {
  background: rgba(0, 242, 254, 0.08);
  border-color: rgba(0, 242, 254, 0.3);
  color: #9be8ff;
}

.course-icon {
  color: #00f2fe;
  font-size: 1rem;
}

.question-content {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.item-icon {
  color: #00bfff;
  font-size: 1rem;
}

.type-tag,
.difficulty-tag {
  font-weight: 600;
}

.knowledge-point {
  display: flex;
  align-items: center;
  gap: 4px;
}

.kp-icon {
  color: #00bfff;
  font-size: 14px;
}

.create-time {
  display: flex;
  align-items: center;
  gap: 4px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.9);
}

.time-icon {
  color: #00bfff;
  font-size: 14px;
}

.action-buttons {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  justify-content: center;
  flex-wrap: wrap;
}

.action-btn {
  border-radius: 6px;
  font-weight: 600;
  transition: all 0.3s ease;
  background: linear-gradient(135deg, rgba(0, 191, 255, 0.2), rgba(0, 191, 255, 0));
  border: 1px solid rgba(0, 191, 255, 0.5);
  color: #fff;
}

.action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 0 15px rgba(0, 191, 255, 0.5);
  border-color: #00bfff;
}

/* 分页样式 */
.pagination-wrapper {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  background: rgba(8, 16, 45, 0.6);
  border: 1px solid rgba(0, 191, 255, 0.3);
  border-radius: 8px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
  margin-top: 15px;
}

.pagination-info {
  display: flex;
  align-items: center;
}

.pagination-text {
  color: rgba(255, 255, 255, 0.9);
  font-size: 0.9rem;
  font-weight: 500;
}

.pagination {
  --el-pagination-bg-color: transparent;
  --el-pagination-button-bg-color: rgba(0, 191, 255, 0.2);
  --el-pagination-button-color: rgba(255, 255, 255, 0.8);
  --el-pagination-hover-color: #00bfff;
}

.pagination :deep(.el-pager li) {
  border-radius: 6px;
  margin: 0 2px;
  transition: all 0.3s ease;
  background: rgba(0, 191, 255, 0.2);
  color: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(0, 191, 255, 0.3);
}

.pagination :deep(.el-pager li:hover) {
  background: rgba(0, 191, 255, 0.3);
  color: #00bfff;
  border-color: #00bfff;
}

.pagination :deep(.el-pager li.is-active) {
  background: #00bfff;
  color: #fff;
  font-weight: 600;
  border-color: #00bfff;
  box-shadow: 0 0 10px rgba(0, 191, 255, 0.5);
}

.pagination :deep(.btn-prev),
.pagination :deep(.btn-next) {
  border-radius: 6px;
  transition: all 0.3s ease;
  background: rgba(0, 191, 255, 0.2);
  color: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(0, 191, 255, 0.3);
}

.pagination :deep(.btn-prev:hover),
.pagination :deep(.btn-next:hover) {
  background: rgba(0, 191, 255, 0.3);
  color: #00bfff;
  border-color: #00bfff;
}

/* 编辑对话框样式 */
:deep(.el-dialog.edit-question-dialog) {
  background: linear-gradient(135deg, rgba(8, 16, 45, 0.98), rgba(0, 50, 100, 0.95));
  border: 2px solid rgba(0, 191, 255, 0.5);
  box-shadow: 0 0 30px rgba(0, 191, 255, 0.4), inset 0 0 20px rgba(0, 191, 255, 0.1);
  position: relative;
}

:deep(.el-dialog.edit-question-dialog .el-dialog__header) {
  background: linear-gradient(135deg, rgba(0, 191, 255, 0.2), rgba(0, 242, 254, 0.15));
  border-bottom: 2px solid rgba(0, 191, 255, 0.4);
  padding: 20px 24px;
  position: relative;
}

:deep(.el-dialog.edit-question-dialog .el-dialog__header)::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  width: 4px;
  height: 100%;
  background: linear-gradient(180deg, #00bfff, #00f2fe);
}

:deep(.el-dialog.edit-question-dialog .el-dialog__title) {
  color: #00f2fe;
  font-weight: 700;
  font-size: 18px;
  text-shadow: 0 0 10px rgba(0, 242, 254, 0.5);
  margin-left: 12px;
}

:deep(.el-dialog.edit-question-dialog .el-dialog__body) {
  background: transparent;
  color: rgba(255, 255, 255, 0.9);
  padding: 24px;
}

:deep(.el-dialog.edit-question-dialog .el-form-item__label) {
  color: rgba(255, 255, 255, 0.9);
  font-weight: 500;
}

:deep(.el-dialog.edit-question-dialog .el-input__wrapper),
:deep(.el-dialog.edit-question-dialog .el-select__wrapper),
:deep(.el-dialog.edit-question-dialog .el-textarea__inner),
:deep(.el-dialog.edit-question-dialog .el-input-number) {
  background-color: rgba(0, 30, 60, 0.5);
  border: 1px solid rgba(0, 191, 255, 0.4);
  box-shadow: none;
  color: #fff;
}

:deep(.el-dialog.edit-question-dialog .el-input__inner),
:deep(.el-dialog.edit-question-dialog .el-textarea__inner) {
  color: #fff;
}

:deep(.el-dialog.edit-question-dialog .el-select__placeholder),
:deep(.el-dialog.edit-question-dialog .el-input__inner::placeholder) {
  color: rgba(255, 255, 255, 0.5);
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding-top: 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.edit-question-dialog .dialog-footer .el-button {
  background: rgba(0, 191, 255, 0.2);
  border: 1px solid rgba(0, 191, 255, 0.5);
  color: rgba(255, 255, 255, 0.9);
  font-weight: 500;
  transition: all 0.3s ease;
  padding: 10px 20px;
}

.edit-question-dialog .dialog-footer .el-button:hover {
  background: rgba(0, 191, 255, 0.4);
  border-color: #00bfff;
  box-shadow: 0 0 12px rgba(0, 191, 255, 0.4);
  transform: translateY(-2px);
}

.edit-question-dialog .dialog-footer .el-button--primary {
  background: linear-gradient(135deg, rgba(0, 191, 255, 0.6), rgba(0, 242, 254, 0.5));
  border-color: #00bfff;
  color: #fff;
  font-weight: 600;
}

.edit-question-dialog .dialog-footer .el-button--primary:hover {
  background: linear-gradient(135deg, rgba(0, 191, 255, 0.8), rgba(0, 242, 254, 0.7));
  box-shadow: 0 0 15px rgba(0, 191, 255, 0.6);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .admin-question-bank-management {
    padding: 10px;
  }

  .filter-grid {
    grid-template-columns: 1fr;
  }

  .filter-item.filter-actions {
    grid-column: 1;
  }

  .pagination-wrapper {
    flex-direction: column;
    gap: 1rem;
    align-items: center;
    padding: 1rem;
  }
}
</style>
