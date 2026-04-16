<template>
  <div class="qb-browser">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <div class="header-left">
             <h1 class="page-title">
               <img src="@/assets/icon/田园犬.png" alt="田园犬" class="title-icon">
               题目管理
             </h1>
          <p class="page-subtitle">管理和组织您的题目资源</p>
        </div>
        <div class="header-right">
          <el-button type="primary" @click="openCreate" class="action-btn">
            <el-icon><Plus /></el-icon>
            新建题目
          </el-button>
          <el-button @click="goBackToList" class="action-btn">
            <el-icon><Back /></el-icon>
            返回题库分类
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
            @input="applyFilter"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>
        <div class="search-right">
          <el-select 
            v-model="query.categoryId" 
            placeholder="选择题库分类" 
            class="filter-select"
            @change="reload"
          >
            <el-option v-for="c in categories" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
          <el-button 
            type="primary" 
            @click="toGenerator"
            class="action-btn"
          >
            <el-icon><Star /></el-icon>
            去生成题目
          </el-button>
        </div>
      </div>
      <div v-if="!categories.length" class="empty-tip">暂无题库分类，请先在题目生成页创建或在后台添加分类。</div>
    </div>

    <!-- 表格容器 -->
    <div class="table-container">
      <el-card shadow="hover" class="table-card">
        <el-table 
          :data="rows" 
          class="question-table"
          empty-text="暂无题目"
          :header-cell-style="{ background: '#f8f9fa', color: '#606266', fontWeight: '600' }"
        >
          <el-table-column label="题目ID" width="100" align="center">
            <template #default="{ $index }">
              <span class="question-id">{{ String((query.page - 1) * query.pageSize + $index + 1).padStart(3, '0') }}</span>
            </template>
          </el-table-column>

          <el-table-column prop="content" label="题目内容" min-width="300" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="question-content">
                <el-icon class="question-icon"><Document /></el-icon>
                <span>{{ row.content }}</span>
              </div>
            </template>
          </el-table-column>

          <el-table-column prop="knowledgePoint" label="知识点" width="180" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="knowledge-point">
                <el-icon class="knowledge-icon"><Reading /></el-icon>
                <span>{{ row.knowledgePoint || '-' }}</span>
              </div>
            </template>
          </el-table-column>

          <el-table-column label="题目类型" width="120" align="center">
            <template #default="{ row }">
              <el-tag :type="getTypeTagType(row.type)" effect="light">
                {{ typeText(row.type) }}
              </el-tag>
            </template>
          </el-table-column>

          <el-table-column label="难度" width="100" align="center">
            <template #default="{ row }">
              <el-tag :type="getDifficultyTagType(row.difficultyLevel)" effect="light" size="small">
                {{ getDifficultyText(row.difficultyLevel) }}
              </el-tag>
            </template>
        </el-table-column>

          <el-table-column label="创建时间" width="180" align="center">
            <template #default="{ row }">
              <div class="create-time">
                <el-icon class="time-icon"><Clock /></el-icon>
                <span>{{ formatTime(row.createdAt) }}</span>
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
                  @click="openEdit(row)"
                >
                  <el-icon><Edit /></el-icon>
                  编辑
                </el-button>
                <el-button 
                  size="small" 
                  type="danger" 
                  class="action-btn"
                  @click="removeQuestion(row)"
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
          共 {{ total }} 条记录，第 {{ query.page }} / {{ Math.ceil(total / query.pageSize) }} 页
        </span>
      </div>
        <el-pagination
          background
          layout="total, sizes, prev, pager, next"
        :page-sizes="[10, 20, 50]"
          :page-size="query.pageSize"
          :current-page="query.page"
          :total="total"
          @size-change="size=>{query.pageSize=size; query.page=1; reload()}"
          @current-change="p=>{query.page=p; reload()}"
        class="pagination"
        />
      </div>

    <!-- 新建题目 Dialog -->
    <el-dialog v-model="dialog.visible" title="新建题目" width="640px">
      <el-form :model="dialog.form" label-width="90px">
        <el-form-item label="题型" required>
          <el-select v-model="dialog.form.type" placeholder="请选择题型">
            <el-option label="选择题" value="choice" />
            <el-option label="简答题" value="short_answer" />
            <el-option label="编程题" value="programming" />
          </el-select>
        </el-form-item>
        <el-form-item label="难度">
          <el-select v-model="dialog.form.difficultyLevel">
            <el-option label="简单" value="easy" />
            <el-option label="中等" value="medium" />
            <el-option label="困难" value="hard" />
          </el-select>
        </el-form-item>
        <el-form-item label="知识点">
          <el-cascader
            v-model="selectedKnowledge"
            :options="knowledgeOptions"
            :props="cascaderProps"
            placeholder="请选择章节/知识点"
            style="width: 100%"
            clearable
          />
        </el-form-item>
        <el-form-item label="题干" required>
          <el-input type="textarea" v-model="dialog.form.content" rows="5" placeholder="请输入题干（选择题请带 A/B/C/D 选项）" />
        </el-form-item>
        <el-form-item label="答案">
          <el-input type="textarea" v-model="dialog.form.answer" rows="3" placeholder="请输入标准答案" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible=false">取消</el-button>
        <el-button type="primary" :loading="dialog.loading" @click="submitCreate">保存</el-button>
      </template>
    </el-dialog>

    <!-- 编辑题目 Dialog -->
    <el-dialog v-model="editDialog.visible" title="编辑题目" width="640px">
      <el-form :model="editDialog.form" label-width="90px">
        <el-form-item label="题型" required>
          <el-select v-model="editDialog.form.type" placeholder="请选择题型">
            <el-option label="选择题" value="choice" />
            <el-option label="简答题" value="short_answer" />
            <el-option label="编程题" value="programming" />
          </el-select>
        </el-form-item>
        <el-form-item label="难度">
          <el-select v-model="editDialog.form.difficultyLevel">
            <el-option label="简单" value="easy" />
            <el-option label="中等" value="medium" />
            <el-option label="困难" value="hard" />
          </el-select>
        </el-form-item>
        <el-form-item label="知识点">
          <el-input v-model="editDialog.form.knowledgePoint" />
        </el-form-item>
        <el-form-item label="题干" required>
          <el-input type="textarea" v-model="editDialog.form.content" rows="5" />
        </el-form-item>
        <el-form-item label="答案">
          <el-input type="textarea" v-model="editDialog.form.answer" rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editDialog.visible=false">取消</el-button>
        <el-button type="primary" :loading="editDialog.loading" @click="submitEdit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'
import { useGlobalDataStore } from '@/store/globalData.js'
import { 
  Collection, 
  Plus, 
  Back, 
  Search, 
  Star, 
  Document, 
  Reading, 
  Clock, 
  Edit, 
  Delete 
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const global = useGlobalDataStore()

const categories = ref([])
const rows = ref([])
const total = ref(0)
const query = reactive({ categoryId: null, page: 1, pageSize: 10 })

// 搜索相关
const searchKeyword = ref('')
const searchTimeout = ref(null)

const dialog = reactive({
  visible: false,
  loading: false,
  form: { type: 'short_answer', difficultyLevel: 'medium', knowledgePoint: '', content: '', answer: '' }
})
const editDialog = reactive({ visible:false, loading:false, form:{ id:null, type:'short_answer', difficultyLevel:'medium', knowledgePoint:'', content:'', answer:'' } })

// 知识点选择（沿用题目生成页的数据源）
const knowledgeOptions = ref([])
const selectedKnowledge = ref(null)
const cascaderProps = { emitPath: false, value: 'id', label: 'name', children: 'children', checkStrictly: false }

function goBack(){ router.push({ name: 'DesignTools', query: route.query }) }

async function loadCategories(){
  try {
    const res = await axios.get('/question-generator/categories')
    // 兼容两种返回：Result 包装 或 直接数组
    const data = Array.isArray(res.data) ? res.data : (res.data?.data || [])
    categories.value = data || []
    if (!query.categoryId && categories.value.length) {
      query.categoryId = categories.value[0].id
    }
  } catch {}
}

async function reload(){
  if (!query.categoryId) return
  const params = {
    ...query,
    keyword: searchKeyword.value.trim() || undefined
  }
  const res = await axios.get('/xiaozhi/teacher/question/pageByCategory', { params })
  if (res.data?.code === 200) {
    const list = res.data.data.records || res.data.data.list || []
    rows.value = list
    total.value = res.data.data.total || 0
  }
}

function toGenerator(){
  const courseId = currentCategory.value?.courseId || route.query.courseId
  router.push({
    name: 'QuestionGenerator',
    query: {
      ...route.query,
      courseId: courseId,
      categoryId: query.categoryId,
      // 可选：把当前课程名/封面透传，若上级页面 query 有就沿用
      title: route.query.title,
      subtitle: route.query.subtitle,
      image: route.query.image
    }
  })
}

function goBackToList(){
  router.push({ name: 'QuestionBankList', query: route.query })
}

function typeText(t){
  const map = { choice: '选择题', short_answer: '简答题', programming: '编程题' }
  return map[t] || t
}

// 获取题目类型标签类型
function getTypeTagType(type) {
  const map = { 
    choice: 'primary', 
    short_answer: 'success', 
    programming: 'warning' 
  }
  return map[type] || 'info'
}

// 获取难度文本
function getDifficultyText(level) {
  const map = { 
    easy: '简单', 
    medium: '中等', 
    hard: '困难' 
  }
  return map[level] || level
}

// 获取难度标签类型
function getDifficultyTagType(level) {
  const map = { 
    easy: 'success', 
    medium: 'warning', 
    hard: 'danger' 
  }
  return map[level] || 'info'
}

// 应用筛选
function applyFilter() {
  query.page = 1
  // 清除之前的定时器
  if (searchTimeout.value) {
    clearTimeout(searchTimeout.value)
  }
  // 设置防抖搜索
  searchTimeout.value = setTimeout(() => {
    reload()
  }, 500)
}

const currentCategory = computed(()=> categories.value.find(c => String(c.id) === String(query.categoryId)))

function openCreate(){
  dialog.form = { type: 'short_answer', difficultyLevel: 'medium', knowledgePoint: '', content: '', answer: '' }
  dialog.visible = true
  // 打开时加载知识点树
  loadKnowledgeOptions()
}

async function submitCreate(){
  if (!dialog.form.content?.trim()) return
  dialog.loading = true
  try {
    // 取分类上的 courseId 作为题目的 courseId
    const courseId = currentCategory.value?.courseId || null
    // 解析所选知识点名称
    const knowledgePointName = await findKnowledgeNameById(knowledgeOptions.value, selectedKnowledge.value)
    const payload = {
      courseId,
      categoryId: query.categoryId,
      type: dialog.form.type,
      content: dialog.form.content,
      answer: dialog.form.answer,
      knowledgePoint: knowledgePointName || dialog.form.knowledgePoint,
      difficultyLevel: dialog.form.difficultyLevel
    }
    const res = await axios.post('/xiaozhi/teacher/question/create', payload)
    if (res.data?.code === 200) {
      dialog.visible = false
      await reload()
    }
  } finally {
    dialog.loading = false
  }
}

function formatTime(v){
  try {
    if (!v) return ''
    if (typeof v === 'string') return v.replace('T', ' ').slice(0, 19)
    if (Array.isArray(v)) { // [yyyy,MM,dd,HH,mm,ss]
      const [y, M, d, h=0, m=0, s=0] = v
      const pad=n=>String(n).padStart(2,'0')
      return `${y}-${pad(M)}-${pad(d)} ${pad(h)}:${pad(m)}:${pad(s)}`
    }
    const date = new Date(v)
    if (!isNaN(date.getTime())) {
      const pad=n=>String(n).padStart(2,'0')
      return `${date.getFullYear()}-${pad(date.getMonth()+1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
    }
    return String(v)
  } catch { return '' }
}

function openEdit(row){
  editDialog.form = { id: row.id, type: row.type, difficultyLevel: row.difficultyLevel, knowledgePoint: row.knowledgePoint, content: row.content, answer: row.answer }
  editDialog.visible = true
}

async function submitEdit(){
  editDialog.loading = true
  try {
    const courseId = currentCategory.value?.courseId || null
    const payload = { ...editDialog.form, courseId, categoryId: query.categoryId }
    const res = await axios.put('/xiaozhi/teacher/question/update', payload)
    if (res.data?.code === 200) {
      editDialog.visible = false
      await reload()
    }
  } finally { editDialog.loading = false }
}

async function removeQuestion(row){
  try {
    await axios.delete('/xiaozhi/teacher/question/delete', { params: { id: row.id } })
    await reload()
  } catch {}
}

onMounted(async ()=>{
  // 从列表页带入的分类ID
  const cid = Number(route.query.categoryId)
  if (!Number.isNaN(cid) && cid > 0) {
    query.categoryId = cid
  }
  // 推入面包屑
  pushCrumb({ title: '题库分类·题目浏览', path: route.path, query: route.query })
  await loadCategories()
  await reload()
})

async function loadKnowledgeOptions(){
  try {
    // 优先使用分类自带的 courseId；缺失时回退到路由上的 courseId
    const courseId = currentCategory.value?.courseId || Number(route.query.courseId)
    if (!courseId) { knowledgeOptions.value = []; return }
    const response = await axios.get(`/api/graph/course`, { params: { courseId } })
    const knowledgeGraph = response.data
    if (Array.isArray(knowledgeGraph)) {
      // 返回是数组：逐个转换为叶/树节点
      knowledgeOptions.value = knowledgeGraph.map(n => transformKnowledgeTree(n))
    } else {
      // 返回是单个根节点：取其 children
      const transformed = transformKnowledgeTree(knowledgeGraph)
      knowledgeOptions.value = transformed.children || []
    }
  } catch (e) { knowledgeOptions.value = [] }
}

// 面包屑逻辑
const crumbs = computed(()=> global.breadcrumbs)
function pushCrumb(c){ global.pushCrumb(c) }
function closeCrumb(index){
  const was = global.breadcrumbs[index]
  global.removeCrumb(index)
  // 期望返回到被关闭项的前一个；若不存在，则返回栈顶；若栈空，后退浏览器历史
  const prev = global.breadcrumbs[index - 1] || global.breadcrumbs[global.breadcrumbs.length - 1]
  if (prev) {
    router.push({ path: prev.path, query: prev.query })
  } else {
    router.back()
  }
}
function goCrumb(c){ router.push({ path: c.path, query: c.query }) }

function transformKnowledgeTree(node, parentChapter = ''){
  if (!node || !node.children || node.children.length === 0) {
    return { id: node?.id, name: node?.name, leaf: true, chapter: parentChapter }
  } else {
    const current = node.name
    return { id: node.id, name: node.name, children: node.children.map(ch => transformKnowledgeTree(ch, current)) }
  }
}

async function findKnowledgeNameById(options, id){
  if (!id) return null
  const stack = [...(options||[])]
  while (stack.length){
    const n = stack.pop()
    if (!n) continue
    if (String(n.id) === String(id)) return n.name
    if (n.children) stack.push(...n.children)
  }
  return null
}
</script>

<style scoped>
.qb-browser {
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
}

.filter-select {
  width: 200px;
}

.empty-tip {
  color: #6b7280;
  font-size: 13px;
  margin-top: 8px;
  text-align: center;
  padding: 1rem;
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
  align-items: flex-start;
  gap: 0.5rem;
}

.question-icon {
  color: #667eea;
  font-size: 1rem;
  margin-top: 2px;
  flex-shrink: 0;
}

.knowledge-point {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.knowledge-icon {
  color: #409eff;
  font-size: 1rem;
}

.create-time {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: #64748b;
}

.time-icon {
  color: #6b7280;
  font-size: 0.875rem;
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


