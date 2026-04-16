<template>
  <div class="qb-list">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <div class="header-left">
          <h1 class="page-title">
            <img src="@/assets/images/三花猫.png" alt="三花猫" class="title-icon">
            题库管理
          </h1>
          <p class="page-subtitle">管理和组织您的题库资源</p>
        </div>
        <div class="header-right">
          <el-button type="primary" @click="handleCreateClick" class="action-btn">
            <el-icon><Plus /></el-icon>
            新建题库
          </el-button>
        </div>
      </div>
    </div>

    <!-- 搜索和筛选区域 -->
    <div class="search-section">
      <div class="search-bar">
        <div class="search-left">
          <el-input
            v-model="keyword"
            placeholder="搜索题库名称/描述..."
            class="search-input"
            clearable
            @change="applyFilter"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>
        <div class="search-right">
          <el-select 
            v-model="filters.courseId" 
            placeholder="按课程筛选" 
            class="filter-select"
            clearable 
            @change="applyFilter"
          >
            <el-option v-for="c in courses" :key="c.id" :label="c.courseName" :value="c.id" />
          </el-select>
        </div>
      </div>
    </div>

    <!-- 表格容器 -->
    <div class="table-container">
      <el-card shadow="hover" class="table-card">
        <el-table 
          :data="pagedRows" 
          class="bank-table"
          :header-cell-style="{ background: '#f8f9fa', color: '#606266', fontWeight: '600' }"
        >
          <el-table-column prop="id" label="题库ID" width="100" align="center">
            <template #default="{ $index }">
              <span class="bank-id">{{ String(($index + 1)).padStart(3, '0') }}</span>
            </template>
          </el-table-column>
          
          <el-table-column label="课程" width="200" align="center">
            <template #default="{ row }">
              <div class="course-info">
                <el-icon class="course-icon"><Reading /></el-icon>
                <span>{{ courseNameOf(row.courseId) || '-' }}</span>
              </div>
            </template>
          </el-table-column>
          
          <el-table-column prop="name" label="题库名称" min-width="200" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="bank-name">
                <el-icon class="bank-icon"><Collection /></el-icon>
                <span>{{ row.name }}</span>
              </div>
            </template>
          </el-table-column>
          
          <el-table-column prop="description" label="描述" min-width="300" show-overflow-tooltip>
            <template #default="{ row }">
              <span class="bank-description">{{ row.description || '暂无描述' }}</span>
            </template>
          </el-table-column>
          
          <el-table-column prop="total" label="题目数量" width="120" align="center">
            <template #default="{ row }">
              <el-tag type="info" effect="light" size="small">
                {{ row.total ?? 0 }} 题
              </el-tag>
            </template>
          </el-table-column>
          
          <el-table-column label="操作" width="280" align="center" fixed="right">
            <template #default="{ row }">
              <div class="action-buttons">
                <el-button size="small" type="primary" @click="viewQuestions(row)" class="action-btn">
                  <el-icon><View /></el-icon>
                  查看题目
                </el-button>
                <el-button size="small" @click="openEdit(row)" class="action-btn">
                  <el-icon><Edit /></el-icon>
                  编辑
                </el-button>
                <el-button size="small" type="danger" @click="remove(row)" class="action-btn">
                  <el-icon><Delete /></el-icon>
                  删除
                </el-button>
              </div>
            </template>
          </el-table-column>
        </el-table>
        
        <!-- 分页区域 -->
        <div v-if="filteredRows.length > 0" class="pagination-wrapper">
          <div class="pagination-info">
            <span class="pagination-text">
              共 {{ filteredRows.length }} 条记录，第 {{ page }} / {{ Math.ceil(filteredRows.length / pageSize) }} 页
            </span>
          </div>
          <el-pagination
            background
            layout="sizes, prev, pager, next"
            :page-sizes="[10,20,50]"
            :page-size="pageSize"
            :current-page="page"
            :total="filteredRows.length"
            @size-change="s=>{pageSize=s; page=1}"
            @current-change="p=>page=p"
            class="pagination"
          />
        </div>
      </el-card>
    </div>

    <!-- 新建/编辑 题库分类 Dialog -->
    <el-dialog 
      v-model="dialog.visible" 
      :title="dialog.mode==='create' ? '新建题库' : '编辑题库'" 
      width="520px"
      :close-on-click-modal="false"
      :close-on-press-escape="true"
    >
      <el-form :model="dialog.form" label-width="90px">
        <el-form-item label="课程" required>
          <el-select v-model="dialog.form.courseId" placeholder="请选择课程">
            <el-option v-for="c in courses" :key="c.id" :label="c.courseName" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="名称" required>
          <el-input v-model="dialog.form.name" maxlength="50" show-word-limit />
        </el-form-item>
        <el-form-item label="描述">
          <el-input type="textarea" v-model="dialog.form.description" rows="3" maxlength="200" show-word-limit />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible=false">取消</el-button>
        <el-button type="primary" @click="submitDialog" :loading="dialog.loading">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'
import { ElMessageBox, ElMessage } from 'element-plus'
import { 
  Collection, 
  Plus, 
  Search, 
  Reading, 
  View, 
  Edit, 
  Delete 
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()

const rows = ref([])
const keyword = ref('')
const page = ref(1)
const pageSize = ref(10)
const courses = ref([])
const filters = reactive({ courseId: Number(route.query.courseId) || null })

const dialog = reactive({ 
  visible: false, 
  mode: 'create', 
  loading: false, 
  form: { 
    id: null, 
    courseId: null, 
    name: '', 
    description: '' 
  }
})

// 添加调试信息
console.log('Dialog 初始化:', dialog)

const filteredRows = computed(()=>{
  const k = keyword.value.trim().toLowerCase()
  let list = rows.value
  if (filters.courseId) list = list.filter(r => String(r.courseId) === String(filters.courseId))
  if (!k) return list
  return list.filter(r => (r.name||'').toLowerCase().includes(k) || (r.description||'').toLowerCase().includes(k))
})

const pagedRows = computed(()=>{
  const start = (page.value - 1) * pageSize.value
  return filteredRows.value.slice(start, start + pageSize.value)
})

function applyFilter(){ page.value = 1 }

async function loadCategories(){
  const res = await axios.get('/question-generator/categories')
  const list = Array.isArray(res.data) ? res.data : (res.data?.data || [])
  // 先渲染基本信息
  rows.value = (list || []).map(c => ({ ...c }))
  // 再并发拉取各分类题目总数（用分页接口的 total）
  const tasks = rows.value.map(async (c)=>{
    try {
      const r = await axios.get('/xiaozhi/teacher/question/pageByCategory', { params: { categoryId: c.id, page: 1, pageSize: 1 }})
      c.total = r.data?.data?.total ?? 0
    } catch { c.total = 0 }
  })
  await Promise.allSettled(tasks)
}

function viewQuestions(row){
  router.push({ name: 'QuestionBankBrowser', query: { ...route.query, categoryId: row.id } })
}

onMounted(async ()=>{
  console.log('组件已挂载')
  console.log('Dialog 状态:', dialog)
  await Promise.all([loadCategories(), loadCourses()])
})

async function loadCourses(){
  try {
    console.log('开始加载课程数据...')
    // 使用正确的API路径获取课程列表
    const res = await axios.get('/api/xiaozhi/teacher/by-teacher', {
      params: { teacherId: 2 }
    })
    console.log('课程API响应:', res.data)
    // 转换数据格式以匹配前端需要的格式
    courses.value = (res.data || []).map(course => ({
      id: course.id,
      courseName: course.courseName,
      description: course.description
    }))
    console.log('加载的课程数据:', courses.value)
  } catch (error) {
    console.error('加载课程数据失败:', error)
    // 尝试备用API
    try {
      const res = await axios.get('/api/xiaozhi/teacher/courses')
      if (res.data.code === 200) {
        courses.value = res.data.data || []
        console.log('使用备用API加载的课程数据:', courses.value)
      }
    } catch (backupError) {
      console.error('备用API也失败:', backupError)
      courses.value = []
    }
  }
}

function courseNameOf(id){
  const c = courses.value.find(i => String(i.id) === String(id))
  return c?.courseName
}

function handleCreateClick(){
  console.log('按钮被点击了！')
  console.log('当前 dialog 状态:', dialog)
  openCreate()
}

function openCreate(){
  console.log('openCreate 被调用')
  console.log('当前 dialog.visible:', dialog.visible)
  dialog.mode = 'create'
  dialog.form = { id: null, courseId: Number(route.query.courseId) || null, name: '', description: '' }
  dialog.visible = true
  console.log('dialog.visible 设置为:', dialog.visible)
  console.log('dialog 对象:', dialog)
}

function openEdit(row){
  dialog.mode = 'edit'
  dialog.form = { id: row.id, courseId: row.courseId || Number(route.query.courseId) || null, name: row.name, description: row.description }
  dialog.visible = true
}

async function submitDialog(){
  if (!dialog.form.name?.trim()) { ElMessage.error('名称不能为空'); return }
  dialog.loading = true
  try {
    if (dialog.mode === 'create') {
      await axios.post('/question-generator/categories', { courseId: dialog.form.courseId, name: dialog.form.name, description: dialog.form.description })
      ElMessage.success('创建成功')
    } else {
      await axios.put(`/question-generator/categories/${dialog.form.id}`, { id: dialog.form.id, courseId: dialog.form.courseId, name: dialog.form.name, description: dialog.form.description })
      ElMessage.success('更新成功')
    }
    dialog.visible = false
    await loadCategories()
  } catch (e) {
    ElMessage.error('操作失败')
  } finally {
    dialog.loading = false
  }
}

async function remove(row){
  try {
    await ElMessageBox.confirm(`确认删除题库「${row.name}」吗？`, '删除确认', { type: 'warning' })
  } catch { return }
  try {
    await axios.delete(`/question-generator/categories/${row.id}`)
    ElMessage.success('删除成功')
  } catch (e) {
    const msg = e?.response?.data?.message || e?.message || '删除失败'
    ElMessage.error(msg)
  }
  await loadCategories()
}
</script>

<style scoped>
.qb-list {
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
  pointer-events: auto !important;
  cursor: pointer !important;
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
.bank-table {
  border-radius: 8px;
  overflow: hidden;
}

.bank-table :deep(.el-table__header) {
  background: #f8f9fa;
}

.bank-table :deep(.el-table__row) {
  transition: all 0.3s ease;
}

.bank-table :deep(.el-table__row:hover) {
  background: #f0f9ff;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.bank-id {
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

.bank-name {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.bank-icon {
  color: #667eea;
  font-size: 1rem;
}

.bank-description {
  color: #64748b;
  font-size: 0.875rem;
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
  .qb-list {
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
  
  .action-buttons {
    flex-direction: column;
    gap: 0.25rem;
  }
}
</style>


