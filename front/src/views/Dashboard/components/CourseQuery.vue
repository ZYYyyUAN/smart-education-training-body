<template>
  <section class="course-query">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <div class="header-left">
          <h1 class="page-title">
            <img src="@/assets/icon/金毛.png" alt="金毛" class="title-icon">
            课程总览
          </h1>
          <p class="page-subtitle">管理您的所有课程，创建精彩的教学内容</p>
        </div>
        <div class="header-right">
          <el-button type="primary" @click="addCourse" class="add-course-btn">
            <el-icon><Plus /></el-icon>
            创建新课程
          </el-button>
        </div>
    </div>
    
      <!-- 统计卡片 -->
      <div class="stats-cards">
        <div class="stat-card">
          <div class="stat-icon total">
            <el-icon><Document /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-number">{{ courseList.length }}</div>
            <div class="stat-label">总课程数</div>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon active">
            <el-icon><Check /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-number">{{ filteredCourses.length }}</div>
            <div class="stat-label">当前显示</div>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon recent">
            <el-icon><Clock /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-number">{{ recentCoursesCount }}</div>
            <div class="stat-label">最近创建</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 搜索和筛选区域 -->
    <div class="search-section">
      <div class="search-bar">
        <div class="search-left">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索课程名称、教学目标..."
            class="search-input"
            clearable
            @input="handleSearch"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>
        <div class="search-right">
          <el-select v-model="tempForm.courseName" placeholder="筛选课程" clearable class="filter-select" @change="handleSearch">
          <el-option
            v-for="course in courseList"
            :key="course.id"
            :label="course.courseName || course.name"
            :value="course.courseName || course.name"
          />
        </el-select>
          <el-button @click="resetSearch" class="reset-btn">
            <el-icon><Refresh /></el-icon>
            重置
          </el-button>
        </div>
      </div>
    </div>

    <!-- 课程卡片列表 -->
    <div class="courses-container" v-loading="loading">
      <div v-if="loading" class="loading-container">
        <el-icon class="is-loading"><Loading /></el-icon>
        <span>加载中...</span>
      </div>
      
      <div v-else-if="formattedCourses.length === 0" class="empty-state">
        <el-icon class="empty-icon"><Document /></el-icon>
        <h3>暂无课程数据</h3>
        <p>点击"创建新课程"开始您的教学之旅</p>
        <el-button type="primary" @click="addCourse" class="empty-action-btn">
          <el-icon><Plus /></el-icon>
          创建第一个课程
        </el-button>
      </div>
      
      <div v-else class="courses-grid">
        <div 
          v-for="course in formattedCourses" 
          :key="course.id" 
          class="course-card"
          @click="viewCourseDetail(course)"
        >
          <div class="course-header">
            <div class="course-avatar">
              <img v-if="course.courseImage" :src="course.courseImage" :alt="course.courseName" />
              <div v-else class="default-avatar">
                <el-icon><Document /></el-icon>
              </div>
            </div>
            <div class="course-meta">
              <h3 class="course-title">{{ course.courseName }}</h3>
              <div class="course-id">#{{ course.formattedId }}</div>
            </div>
            <div class="course-actions">
              <el-dropdown trigger="click" @click.stop>
                <el-button type="text" class="action-trigger">
                  <el-icon><MoreFilled /></el-icon>
                </el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item @click="editCourse(course)">
                      <el-icon><Edit /></el-icon>
                      编辑课程
                    </el-dropdown-item>
                    <el-dropdown-item @click="gotoChapters(course)">
                      <el-icon><List /></el-icon>
                      管理章节
                    </el-dropdown-item>
                    <el-dropdown-item @click="deleteCourse(course.id)" class="danger-item">
                      <el-icon><Delete /></el-icon>
                      删除课程
                    </el-dropdown-item>
                  </el-dropdown-menu>
        </template>
              </el-dropdown>
            </div>
          </div>
          
          <div class="course-content">
            <div class="course-description">
              <p class="description-text">{{ course.description || '暂无课程描述' }}</p>
            </div>
            
            <div class="course-details">
              <div class="detail-item" v-if="course.teachingGoal">
                <el-icon class="detail-icon"><Aim /></el-icon>
                <span class="detail-label">教学目标</span>
                <span class="detail-value">{{ course.teachingGoal }}</span>
              </div>
              <div class="detail-item" v-if="course.teachingPrinciple">
                <el-icon class="detail-icon"><Star /></el-icon>
                <span class="detail-label">教学原则</span>
                <span class="detail-value">{{ course.teachingPrinciple }}</span>
              </div>
            </div>
          </div>
          
          <div class="course-footer">
            <div class="course-date">
              <el-icon><Calendar /></el-icon>
              <span>{{ formatDate(course.createdAt) }}</span>
            </div>
            <div class="course-actions-inline">
              <el-button type="primary" size="small" @click.stop="editCourse(course)" class="action-btn">
                编辑
              </el-button>
              <el-button type="success" size="small" @click.stop="gotoChapters(course)" class="action-btn">
                章节
              </el-button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 分页器 -->
    <div class="pagination-wrapper" v-if="filteredCourses.length > pageSize">
      <el-pagination
        background
        layout="prev, pager, next, total"
        :total="filteredCourses.length"
        :page-size="pageSize"
        v-model="currentPage"
        :page-sizes="[5, 10, 20, 50]"
        @current-change="handlePageChange"
        @size-change="handleSizeChange"
        class="custom-pagination"
      />
    </div>
    
    <!-- 章节管理对话框 -->
    <el-dialog
      v-model="chapterDialogVisible"
      :title="`管理章节 - ${currentCourse?.courseName || ''}`"
      width="80%"
      :before-close="handleChapterDialogClose"
    >
      <div class="chapter-management">
        <!-- 添加章节按钮 -->
        <div class="chapter-actions">
          <el-button type="primary" @click="addChapter" icon="Plus">添加章节</el-button>
        </div>
        
        <!-- 章节列表 -->
        <el-table :data="chapters" border style="width: 100%; margin-top: 20px;" @row-click="onChapterRowClick">
          <el-table-column label="章节ID" prop="id" width="80"/>
          <el-table-column prop="chapterTitle" label="章节标题" />
          <el-table-column prop="content" label="章节内容" />
          <el-table-column prop="createdAt" label="创建时间" />
          <el-table-column label="操作" width="200">
            <template #default="{ row }">
              <el-button type="primary" size="small" @click="editChapter(row)">编辑</el-button>
              <el-button type="danger" size="small" @click="deleteChapter(row.id)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>

        <!-- 知识点列表（内联显示在章节表下方） -->
        <div v-if="currentChapter" style="margin-top: 16px;">
          <div style="display:flex; align-items:center; justify-content: space-between; margin-bottom: 8px;">
            <div>
              <b>知识点：</b>
              <span>{{ currentChapter.chapterTitle }}</span>
            </div>
            <div>
              <el-button type="primary" @click="addKnowledgePoint" icon="Plus">添加知识点</el-button>
            </div>
          </div>

          <el-table :data="knowledgePoints" border style="width: 100%;">
            <el-table-column label="ID" prop="id" width="80"/>
            <el-table-column prop="title" label="知识点标题" />
            <el-table-column label="操作" width="150">
              <template #default="{ row }">
                <el-button type="primary" size="small" @click="editKnowledgePoint(row)">编辑</el-button>
                <el-button type="danger" size="small" @click="deleteKnowledgePoint(row.id)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>
    </el-dialog>
    
    <!-- 章节编辑对话框 -->
    <el-dialog
      v-model="chapterEditDialogVisible"
      :title="editingChapter ? '编辑章节' : '添加章节'"
      width="50%"
    >
      <el-form :model="chapterForm" :rules="chapterRules" ref="chapterFormRef" label-width="100px">
        <el-form-item label="章节标题" prop="chapterTitle">
          <el-input v-model="chapterForm.chapterTitle" placeholder="请输入章节标题" />
        </el-form-item>
        <el-form-item label="章节内容" prop="content">
          <el-input
            v-model="chapterForm.content"
            type="textarea"
            :rows="4"
            placeholder="请输入章节内容"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="chapterEditDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="saveChapter">确定</el-button>
        </span>
      </template>
    </el-dialog>
    
    
    <!-- 知识点编辑对话框 -->
    <el-dialog
      v-model="knowledgePointEditDialogVisible"
      :title="editingKnowledgePoint ? '编辑知识点' : '添加知识点'"
      width="50%"
    >
      <el-form :model="knowledgePointForm" :rules="knowledgePointRules" ref="knowledgePointFormRef" label-width="100px">
        <el-form-item label="知识点标题" prop="title">
          <el-input v-model="knowledgePointForm.title" placeholder="请输入知识点标题" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="knowledgePointEditDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="saveKnowledgePoint">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </section>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import axios from 'axios'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Loading, 
  Document, 
  Plus, 
  Search, 
  Refresh, 
  Check, 
  Clock, 
  MoreFilled, 
  Edit, 
  List, 
  Delete, 
  Aim, 
  Star, 
  Calendar 
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const loading = ref(false)

const teacherId = ref(null)
const courseList = ref([]) // 全部课程
const filteredCourses = ref([]) // 搜索后课程
const searchKeyword = ref('') // 搜索关键词

// 分页控制
const currentPage = ref(1)
const pageSize = ref(5)

const tempForm = reactive({
  courseName: ''
})
const searchForm = reactive({
  courseName: ''
})

// 计算最近创建的课程数量（7天内）
const recentCoursesCount = computed(() => {
  const sevenDaysAgo = new Date()
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)
  
  return courseList.value.filter(course => {
    if (!course.createdAt) return false
    const courseDate = new Date(course.createdAt)
    return courseDate >= sevenDaysAgo
  }).length
})

// 当前页课程数据
const pagedCourses = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  return filteredCourses.value.slice(start, start + pageSize.value)
})

// 添加序号字段
const formattedCourses = computed(() => {
  return pagedCourses.value.map((course, index) => {
    const seqNum = (currentPage.value - 1) * pageSize.value + index + 1
    return {
      ...course,
      formattedId: seqNum.toString().padStart(3, '0')
    }
  })
})

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

// 查询课程列表
const fetchCourses = async () => {
  console.log('开始获取课程列表...')
  loading.value = true
  try {
    const { data } = await axios.get(`/api/xiaozhi/teacher/by-teacher`, {
      params: { teacherId: 2 }
    })
    console.log('获取到的课程数据:', data)
    courseList.value = data
    handleSearch()
  } catch (e) {
    console.error('获取课程失败:', e)
    ElMessage.error('加载课程失败')
  } finally {
    loading.value = false
  }
}

// 搜索课程
const handleSearch = () => {
  searchForm.courseName = tempForm.courseName ? tempForm.courseName.trim() : ''
  currentPage.value = 1
  
  filteredCourses.value = courseList.value.filter(course => {
    const courseName = course.courseName || course.name || ''
    const teachingGoal = course.teachingGoal || ''
    const description = course.description || ''
    const keyword = searchKeyword.value.toLowerCase()
    
    // 如果有关键词搜索
    if (keyword) {
      return courseName.toLowerCase().includes(keyword) ||
             teachingGoal.toLowerCase().includes(keyword) ||
             description.toLowerCase().includes(keyword)
    }
    
    // 如果有课程名称筛选
    if (searchForm.courseName) {
      return courseName === searchForm.courseName
    }
    
    return true
  })
}

// 重置搜索
const resetSearch = () => {
  searchKeyword.value = ''
  tempForm.courseName = ''
  searchForm.courseName = ''
  currentPage.value = 1
  handleSearch()
}

// 查看课程详情
const viewCourseDetail = (course) => {
  // 可以在这里添加查看详情的逻辑
  console.log('查看课程详情:', course)
}

// 处理分页大小变化
const handleSizeChange = (newSize) => {
  pageSize.value = newSize
  currentPage.value = 1
}

// 编辑
const editCourse = (course) => {
  router.push({
    path: '/teacher_school/create',
    query: { courseId: course.id }
  })
}
// 删除课程（示例）
const deleteCourse = async (id) => {
  try {
    await ElMessageBox.confirm('确认删除该课程吗？此操作不可恢复', '提示', {
      type: 'warning',
      confirmButtonText: '确认',
      cancelButtonText: '取消'
    })
    await axios.delete(`/api/xiaozhi/teacher/course/delete`, { params: { id } })
    ElMessage.success('删除成功')
    await fetchCourses()
  } catch (err) {
    if (err !== 'cancel') {
      ElMessage.error('删除失败，可能存在关联数据，请先删除章节/作业/考试等')
    }
  }
}

const handlePageChange = (page) => {
  currentPage.value = page
}

const addCourse = () => {
  localStorage.removeItem('editingCourse')
  router.push('/teacher_school/create')
}

// 章节管理相关（迁移到新页面，这里仅负责跳转）
const currentCourse = ref(null)

// 章节管理对话框相关
const chapterDialogVisible = ref(false)
const chapters = ref([])
const currentChapter = ref(null)
const editingChapter = ref(null)
const chapterEditDialogVisible = ref(false)

// 知识点管理相关
const knowledgePoints = ref([])
const editingKnowledgePoint = ref(null)
const knowledgePointEditDialogVisible = ref(false)

const chapterForm = reactive({
  chapterTitle: '',
  content: ''
})

const knowledgePointForm = reactive({
  title: ''
})

const chapterRules = {
  chapterTitle: [{ required: true, message: '请输入章节标题', trigger: 'blur' }],
  content: [{ required: true, message: '请输入章节内容', trigger: 'blur' }]
}

const knowledgePointRules = {
  title: [{ required: true, message: '请输入知识点标题', trigger: 'blur' }]
}

// 跳转章节页面
const gotoChapters = (course) => {
  router.push({ name: 'ChapterManager', params: { courseId: course.id } })
}

// 获取章节列表
const fetchChapters = async (courseId) => {
  try {
    const res = await axios.get('/api/xiaozhi/teacher/chapters', { params: { courseId } })
    if (res.data.code === 200) {
      chapters.value = res.data.data || []
    }
  } catch (error) {
    ElMessage.error('获取章节列表失败')
  }
}

// 添加章节
const addChapter = () => {
  editingChapter.value = null
  chapterForm.chapterTitle = ''
  chapterForm.content = ''
  chapterEditDialogVisible.value = true
}

// 编辑章节
const editChapter = (chapter) => {
  editingChapter.value = chapter
  chapterForm.chapterTitle = chapter.chapterTitle
  chapterForm.content = chapter.content
  chapterEditDialogVisible.value = true
}

// 保存章节
const saveChapter = async () => {
  try {
    const formData = {
      courseId: currentCourse.value.id,
      chapterTitle: chapterForm.chapterTitle,
      content: chapterForm.content
    }
    
    if (editingChapter.value) {
      // 编辑
      await axios.put(`/api/xiaozhi/teacher/chapters/${editingChapter.value.id}`, formData)
      ElMessage.success('章节更新成功')
    } else {
      // 新增
      await axios.post('/api/xiaozhi/teacher/chapters', formData)
      ElMessage.success('章节创建成功')
    }
    
    chapterEditDialogVisible.value = false
    await fetchChapters(currentCourse.value.id)
  } catch (error) {
    ElMessage.error('保存章节失败')
  }
}

// 删除章节
const deleteChapter = async (chapterId) => {
  try {
    await ElMessageBox.confirm('确认删除该章节吗？', '提示', { type: 'warning' })
    await axios.delete(`/api/xiaozhi/teacher/chapters/${chapterId}`)
    ElMessage.success('删除成功')
    await fetchChapters(currentCourse.value.id)
  } catch (error) {
    if (error !== 'cancel') ElMessage.error('删除章节失败')
  }
}

// 点击章节行，加载其知识点并在下方展示
const onChapterRowClick = async (chapter) => {
  currentChapter.value = chapter
  await fetchKnowledgePoints(chapter.id)
}

// 获取知识点列表
const fetchKnowledgePoints = async (chapterId) => {
  try {
    const res = await axios.get('/api/xiaozhi/teacher/knowledge-points', { params: { chapterId } })
    if (res.data.code === 200) {
      knowledgePoints.value = res.data.data || []
    }
  } catch (error) {
    ElMessage.error('获取知识点列表失败')
  }
}

// 添加知识点
const addKnowledgePoint = () => {
  editingKnowledgePoint.value = null
  knowledgePointForm.title = ''
  knowledgePointEditDialogVisible.value = true
}

// 编辑知识点
const editKnowledgePoint = (knowledgePoint) => {
  editingKnowledgePoint.value = knowledgePoint
  knowledgePointForm.title = knowledgePoint.title
  knowledgePointEditDialogVisible.value = true
}

// 保存知识点
const saveKnowledgePoint = async () => {
  try {
    const formData = {
      chapterId: currentChapter.value.id,
      title: knowledgePointForm.title
    }
    
    if (editingKnowledgePoint.value) {
      // 编辑
      await axios.put(`/api/xiaozhi/teacher/knowledge-points/${editingKnowledgePoint.value.id}`, formData)
      ElMessage.success('知识点更新成功')
    } else {
      // 新增
      await axios.post('/api/xiaozhi/teacher/knowledge-points', formData)
      ElMessage.success('知识点创建成功')
    }
    
    knowledgePointEditDialogVisible.value = false
    await fetchKnowledgePoints(currentChapter.value.id)
  } catch (error) {
    ElMessage.error('保存知识点失败')
  }
}

// 删除知识点
const deleteKnowledgePoint = async (knowledgePointId) => {
  try {
    await ElMessageBox.confirm('确认删除该知识点吗？', '提示', { type: 'warning' })
    await axios.delete(`/api/xiaozhi/teacher/knowledge-points/${knowledgePointId}`)
    ElMessage.success('删除成功')
    await fetchKnowledgePoints(currentChapter.value.id)
  } catch (error) {
    if (error !== 'cancel') ElMessage.error('删除知识点失败')
  }
}

// 关闭章节对话框
const handleChapterDialogClose = () => {
  chapterDialogVisible.value = false
  currentCourse.value = null
  chapters.value = []
}

onMounted(() => {
  console.log('CourseQuery component mounted')
  console.log('Current route:', route.path)
  fetchCourses()
})
</script>

<style scoped>
.course-query {
  flex: 1;
  padding: 0;
  background: #ffffff;
  min-height: 100vh;
}

/* 页面头部样式 */
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
  align-items: flex-start;
  margin-bottom: 2rem;
}

.header-left {
  flex: 1;
}

.page-title {
  font-size: 2rem;
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
  font-size: 1rem;
  opacity: 0.9;
  margin: 0;
}

.header-right {
  margin-left: 2rem;
}

.add-course-btn {
  background: #667eea;
  border: 1px solid #667eea;
  color: white;
  font-weight: 600;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.add-course-btn:hover {
  background: #5a67d8;
  border-color: #5a67d8;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* 统计卡片样式 */
.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.stat-card {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  transition: all 0.3s ease;
}

.stat-card:hover {
  background: #f1f5f9;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.stat-icon {
  width: 3rem;
  height: 3rem;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
}

.stat-icon.total {
  background: rgba(34, 197, 94, 0.2);
  color: #22c55e;
}

.stat-icon.active {
  background: rgba(59, 130, 246, 0.2);
  color: #3b82f6;
}

.stat-icon.recent {
  background: rgba(245, 158, 11, 0.2);
  color: #f59e0b;
}

.stat-content {
  flex: 1;
}

.stat-number {
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 0.25rem;
  color: #667eea;
}

.stat-label {
  font-size: 0.9rem;
  color: #64748b;
}

/* 搜索区域样式 */
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
  color: #64748b;
  border-color: #e2e8f0;
}

.reset-btn:hover {
  color: #3b82f6;
  border-color: #3b82f6;
}

/* 课程容器样式 */
.courses-container {
  margin: 0 2rem 2rem;
  min-height: 400px;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4rem;
  color: #64748b;
}

.loading-container .el-icon {
  font-size: 2rem;
  margin-bottom: 1rem;
}

/* 空状态样式 */
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.empty-icon {
  font-size: 4rem;
  color: #cbd5e1;
  margin-bottom: 1rem;
}

.empty-state h3 {
  color: #64748b;
  margin: 0 0 0.5rem 0;
  font-size: 1.5rem;
}

.empty-state p {
  color: #94a3b8;
  margin: 0 0 2rem 0;
}

.empty-action-btn {
  padding: 0.75rem 2rem;
  font-weight: 600;
}

/* 课程网格样式 */
.courses-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 1.5rem;
}

/* 课程卡片样式 */
.course-card {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f5f9;
  overflow: hidden;
  transition: all 0.3s ease;
  cursor: pointer;
}

.course-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
  border-color: #e2e8f0;
}

.course-header {
  display: flex;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #f1f5f9;
  gap: 1rem;
}

.course-avatar {
  width: 3rem;
  height: 3rem;
  border-radius: 12px;
  overflow: hidden;
  flex-shrink: 0;
}

.course-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.default-avatar {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.5rem;
}

.course-meta {
  flex: 1;
  min-width: 0;
}

.course-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #1e293b;
  margin: 0 0 0.25rem 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.course-id {
  font-size: 0.8rem;
  color: #64748b;
  font-weight: 500;
}

.course-actions {
  flex-shrink: 0;
}

.action-trigger {
  color: #94a3b8;
  padding: 0.5rem;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.action-trigger:hover {
  background: #f1f5f9;
  color: #64748b;
}

.course-content {
  padding: 1.5rem;
}

.course-description {
  margin-bottom: 1rem;
}

.description-text {
  color: #64748b;
  font-size: 0.9rem;
  line-height: 1.5;
  margin: 0;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.course-details {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
}

.detail-icon {
  color: #3b82f6;
  font-size: 1rem;
  flex-shrink: 0;
}

.detail-label {
  color: #64748b;
  font-weight: 500;
  min-width: 60px;
}

.detail-value {
  color: #1e293b;
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.course-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  background: #f8fafc;
  border-top: 1px solid #f1f5f9;
}

.course-date {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #64748b;
  font-size: 0.85rem;
}

.course-actions-inline {
  display: flex;
  gap: 0.5rem;
}

.action-btn {
  font-size: 0.8rem;
  padding: 0.4rem 0.8rem;
  border-radius: 6px;
}

/* 分页器样式 */
.pagination-wrapper {
  display: flex;
  justify-content: center;
  padding: 2rem 0;
  background: white;
  margin: 0 2rem;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.custom-pagination {
  --el-pagination-bg-color: transparent;
}

/* 下拉菜单样式 */
.danger-item {
  color: #ef4444 !important;
}

.danger-item:hover {
  background: #fef2f2 !important;
}

/* 章节管理样式 */
.chapter-management {
  padding: 20px;
}

.chapter-actions {
  margin-bottom: 20px;
}

.knowledge-point-management {
  padding: 20px;
}

.knowledge-point-actions {
  margin-bottom: 20px;
}

.dialog-footer {
  text-align: right;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-header {
    padding: 1.5rem;
    margin-bottom: 1rem;
  }
  
  .header-content {
    flex-direction: column;
    gap: 1rem;
  }
  
  .header-right {
    margin-left: 0;
    width: 100%;
  }
  
  .add-course-btn {
    width: 100%;
  }
  
  .stats-cards {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .search-section {
    margin: 0 1rem 1rem;
    padding: 1rem;
  }
  
  .search-bar {
    flex-direction: column;
    gap: 1rem;
  }
  
  .search-right {
    width: 100%;
    justify-content: space-between;
  }
  
  .courses-container {
    margin: 0 1rem 1rem;
  }
  
  .courses-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .pagination-wrapper {
    margin: 0 1rem;
  }
}

@media (max-width: 480px) {
  .course-card {
    margin: 0;
  }
  
  .course-header {
    padding: 1rem;
  }
  
  .course-content {
    padding: 1rem;
  }
  
  .course-footer {
    padding: 0.75rem 1rem;
    flex-direction: column;
    gap: 0.75rem;
    align-items: stretch;
  }
  
  .course-actions-inline {
    justify-content: center;
  }
}
</style>
