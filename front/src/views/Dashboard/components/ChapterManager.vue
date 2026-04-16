<template>
  <section class="chapter-manager">
    <div class="toolbar">
      <el-button @click="goBack">返回课程列表</el-button>
      <el-button type="primary" @click="addChapter" icon="Plus">添加章节</el-button>
    </div>

    <el-table :data="chapters" border style="width: 100%;" row-key="id" @expand-change="onExpandChange" class="chapters-table">
      <el-table-column type="expand">
        <template #default="{ row }">
          <div class="kp-expand">
            <div class="kp-header">
              <el-tag type="success" effect="dark" size="small">知识点</el-tag>
              <span class="kp-title">{{ row.chapterTitle }}</span>
              <div class="flex-1" />
              <el-button type="primary" size="small" @click="openAddKnowledgePoint(row)" icon="Plus">添加知识点</el-button>
            </div>
            <el-table :data="kpMap[row.id] || []" border size="small" class="kp-table">
              <el-table-column label="ID" prop="id" width="80"/>
              <el-table-column prop="title" label="知识点标题" />
              <el-table-column label="操作" width="160">
                <template #default="{ row: kp }">
                  <el-button type="primary" size="small" @click="editKnowledgePoint(kp)">编辑</el-button>
                  <el-button type="danger" size="small" @click="deleteKnowledgePoint(kp.id)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="章节ID" prop="id" width="80"/>
      <el-table-column prop="chapterTitle" label="章节标题" />
      <el-table-column prop="content" label="章节内容" />
      <el-table-column prop="createdAt" label="创建时间" />
      <el-table-column label="操作" width="200">
        <template #default="{ row }">
          <el-button type="primary" size="small" @click.stop="editChapter(row)">编辑</el-button>
          <el-button type="danger" size="small" @click.stop="deleteChapter(row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 知识图谱 -->
    <div class="kg-wrap">
      <div class="kg-header">
        <span>知识图谱</span>
        <div class="kg-actions">
          <el-button size="small" @click="zoomOut">－</el-button>
          <el-button size="small" @click="zoomReset">重置</el-button>
          <el-button size="small" @click="zoomIn">＋</el-button>
          <el-button size="small" @click="renderKnowledgeGraph">刷新</el-button>
        </div>
      </div>
      <div id="chapter-kg" class="kg-canvas"></div>
    </div>

    <el-dialog v-model="chapterEditDialogVisible" :title="editingChapter ? '编辑章节' : '添加章节'" width="50%">
      <el-form :model="chapterForm" :rules="chapterRules" ref="chapterFormRef" label-width="100px">
        <el-form-item label="章节标题" prop="chapterTitle">
          <el-input v-model="chapterForm.chapterTitle" placeholder="请输入章节标题" />
        </el-form-item>
        <el-form-item label="章节内容" prop="content">
          <el-input v-model="chapterForm.content" type="textarea" :rows="4" placeholder="请输入章节内容" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="chapterEditDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="saveChapter">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <el-dialog v-model="knowledgePointEditDialogVisible" :title="editingKnowledgePoint ? '编辑知识点' : '添加知识点'" width="40%">
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
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'
import { ElMessage, ElMessageBox } from 'element-plus'

// d3 用于渲染知识图谱（学生端已有实现，可直接搬用）
import * as d3 from 'd3'

const route = useRoute()
const router = useRouter()
const courseId = ref(Number(route.params.courseId))

const chapters = ref([])
const course = ref(null)
const currentChapter = ref(null)
const knowledgePoints = ref([])

const chapterEditDialogVisible = ref(false)
const knowledgePointEditDialogVisible = ref(false)
const editingChapter = ref(null)
const editingKnowledgePoint = ref(null)

const chapterFormRef = ref(null)
const chapterForm = reactive({ chapterTitle: '', content: '' })
const chapterRules = { chapterTitle: [{ required: true, message: '请输入章节标题', trigger: 'blur' }] }

const knowledgePointFormRef = ref(null)
const knowledgePointForm = reactive({ title: '' })
const knowledgePointRules = { title: [{ required: true, message: '请输入知识点标题', trigger: 'blur' }] }

// 知识点缓存 map: chapterId -> list
const kpMap = ref({})

function goBack(){ router.push('/teacher_school/query') }

async function fetchChapters(){
  const res = await axios.get('/api/xiaozhi/teacher/chapters', { params: { courseId: courseId.value } })
  if (res.data.code === 200 || Array.isArray(res.data)) {
    chapters.value = res.data.data || res.data || []
  }
}

async function fetchCourse(){
  try{
    const res = await axios.get('/api/xiaozhi/teacher/course', { params: { id: courseId.value } })
    if (res.data && (res.data.code === 200 || res.data.data)) {
      course.value = res.data.data || res.data
    }
  }catch(e){ }
}

// 预加载所有章节的知识点
async function preloadKnowledgePoints(){
  const map = {}
  for (const ch of chapters.value) {
    const list = await fetchKnowledgePoints(ch.id)
    map[ch.id] = list
  }
  kpMap.value = map
}

async function onExpandChange(row, expandedRows){
  currentChapter.value = row
  if (!kpMap.value[row.id]) {
    const list = await fetchKnowledgePoints(row.id)
    kpMap.value = { ...kpMap.value, [row.id]: list }
  }
}

async function fetchKnowledgePoints(cid){
  const res = await axios.get('/api/xiaozhi/teacher/knowledge-points', { params: { chapterId: cid } })
  const list = res.data && (res.data.data || [])
  knowledgePoints.value = list
  return list
}

function addChapter(){
  editingChapter.value = null
  chapterForm.chapterTitle = ''
  chapterForm.content = ''
  chapterEditDialogVisible.value = true
}

function editChapter(ch){
  editingChapter.value = ch
  chapterForm.chapterTitle = ch.chapterTitle
  chapterForm.content = ch.content
  chapterEditDialogVisible.value = true
}

async function saveChapter(){
  const payload = { courseId: courseId.value, chapterTitle: chapterForm.chapterTitle, content: chapterForm.content }
  if (editingChapter.value){
    await axios.put(`/api/xiaozhi/teacher/chapters/${editingChapter.value.id}`, payload)
    ElMessage.success('章节更新成功')
  } else {
    await axios.post('/api/xiaozhi/teacher/chapters', payload)
    ElMessage.success('章节创建成功')
  }
  chapterEditDialogVisible.value = false
  await fetchChapters()
  await preloadKnowledgePoints()
  renderKnowledgeGraph()
}

async function deleteChapter(id){
  await ElMessageBox.confirm('确认删除该章节吗？','提示',{type:'warning'})
  await axios.delete(`/api/xiaozhi/teacher/chapters/${id}`)
  ElMessage.success('删除成功')
  await fetchChapters()
}

function addKnowledgePoint(){
  editingKnowledgePoint.value = null
  knowledgePointForm.title = ''
  knowledgePointEditDialogVisible.value = true
}

function openAddKnowledgePoint(chapter){
  currentChapter.value = chapter
  addKnowledgePoint()
}

function editKnowledgePoint(kp){
  editingKnowledgePoint.value = kp
  knowledgePointForm.title = kp.title
  knowledgePointEditDialogVisible.value = true
}

async function saveKnowledgePoint(){
  const payload = { chapterId: currentChapter.value.id, title: knowledgePointForm.title }
  if (editingKnowledgePoint.value){
    await axios.put(`/api/xiaozhi/teacher/knowledge-points/${editingKnowledgePoint.value.id}`, payload)
    ElMessage.success('知识点更新成功')
  } else {
    await axios.post('/api/xiaozhi/teacher/knowledge-points', payload)
    ElMessage.success('知识点创建成功')
  }
  knowledgePointEditDialogVisible.value = false
  const list = await fetchKnowledgePoints(currentChapter.value.id)
  kpMap.value = { ...kpMap.value, [currentChapter.value.id]: list }
  renderKnowledgeGraph()
}

async function deleteKnowledgePoint(id){
  await ElMessageBox.confirm('确认删除该知识点吗？','提示',{type:'warning'})
  await axios.delete(`/api/xiaozhi/teacher/knowledge-points/${id}`)
  ElMessage.success('删除成功')
  const list = await fetchKnowledgePoints(currentChapter.value.id)
  kpMap.value = { ...kpMap.value, [currentChapter.value.id]: list }
  renderKnowledgeGraph()
}

onMounted(async () => {
  await fetchCourse()
  await fetchChapters()
  await preloadKnowledgePoints()
  renderKnowledgeGraph()
})

// ====== 知识图谱渲染 ======
function renderKnowledgeGraph(){
  // 容器
  const container = document.getElementById('chapter-kg')
  if (!container) return
  container.innerHTML = ''

  const width = container.clientWidth || container.offsetWidth || 1000
  const height = 420

  const svg = d3.select(container)
    .append('svg')
    .attr('width', width)
    .attr('height', height)

  // zoom & pan support
  const g = svg.append('g')
  const zoomBehavior = d3.zoom()
    .scaleExtent([0.3, 3])
    .on('zoom', (event) => {
      g.attr('transform', event.transform)
    })
  svg.call(zoomBehavior)

  // 构建节点与连线：中心为课程，第一层是章节，第二层是知识点
  const cname = course.value?.courseName || course.value?.name || `课程 ${courseId.value}`
  const courseNode = { id: `course-${courseId.value}`, label: cname, type: 'course' }

  const nodes = [courseNode]
  const links = []

  // 章节节点
  chapters.value.forEach(ch => {
    const chNode = { id: `chapter-${ch.id}`, label: ch.chapterTitle, type: 'chapter' }
    nodes.push(chNode)
    links.push({ source: courseNode.id, target: chNode.id })

    const list = kpMap.value[ch.id] || []
    list.forEach(kp => {
      const kpNode = { id: `kp-${kp.id}`, label: kp.title, type: 'kp' }
      nodes.push(kpNode)
      links.push({ source: chNode.id, target: kpNode.id })
    })
  })

  const simulation = d3.forceSimulation(nodes)
    .force('link', d3.forceLink(links).id(d => d.id).distance(80))
    .force('charge', d3.forceManyBody().strength(-200))
    .force('center', d3.forceCenter(width/2, height/2))

  const link = g.append('g')
    .attr('stroke', '#c5cee0')
    .attr('stroke-width', 1.2)
    .selectAll('line')
    .data(links)
    .enter().append('line')

  const node = g.append('g')
    .selectAll('g')
    .data(nodes)
    .enter().append('g')

  node.append('circle')
    .attr('r', d => d.type==='course'? 26 : d.type==='chapter'? 18 : 12)
    .attr('fill', d => d.type==='course'? '#2563eb' : d.type==='chapter'? '#22c55e' : '#f59e0b')
    .attr('opacity', 0.9)

  node.append('text')
    .text(d => d.label)
    .attr('x', 10)
    .attr('y', 4)
    .attr('font-size', '12px')
    .attr('fill', '#334155')

  node.call(d3.drag()
    .on('start', (event) => { if(!event.active) simulation.alphaTarget(0.3).restart(); event.subject.fx = event.subject.x; event.subject.fy = event.subject.y })
    .on('drag', (event) => { event.subject.fx = event.x; event.subject.fy = event.y })
    .on('end', (event) => { if(!event.active) simulation.alphaTarget(0); event.subject.fx = null; event.subject.fy = null }))

  simulation.on('tick', () => {
    link
      .attr('x1', d => d.source.x)
      .attr('y1', d => d.source.y)
      .attr('x2', d => d.target.x)
      .attr('y2', d => d.target.y)

    node.attr('transform', d => `translate(${d.x},${d.y})`)
  })

  // expose controls
  window.__kgZoom = {
    zoomIn: () => svg.transition().duration(200).call(zoomBehavior.scaleBy, 1.2),
    zoomOut: () => svg.transition().duration(200).call(zoomBehavior.scaleBy, 1/1.2),
    reset: () => svg.transition().duration(200).call(zoomBehavior.transform, d3.zoomIdentity)
  }
}

function zoomIn(){ window.__kgZoom?.zoomIn?.() }
function zoomOut(){ window.__kgZoom?.zoomOut?.() }
function zoomReset(){ window.__kgZoom?.reset?.() }
</script>

<style scoped>
.chapter-manager {
  padding: 16px 24px;
  background: linear-gradient(180deg,#f8fafc 0%, #f3f6fb 100%);
  border-radius: 12px;
  width: 100%;
  max-width: none;     /* 占满可用空间 */
  margin: 0;           /* 取消居中限制 */
}
.grid { display:grid; grid-template-columns: 1fr; gap: 16px; }
.col { background:#fff; border:1px solid #eef1f5; border-radius:10px; padding:12px; }
.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}
.kp-wrap { margin-top: 16px; }
.kp-header {
  display:flex;
  align-items:center;
  gap: 12px;
  margin-bottom: 8px;
  padding: 8px 12px;
  background: #fff;
  border: 1px solid #eef1f5;
  border-radius: 8px;
}
.flex-1 { flex: 1; }
.dialog-footer { text-align: right; }

/* 表格美化 */
:deep(.el-table) {
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 6px 18px rgba(0,0,0,0.06);
}
:deep(.el-table__cell) { padding: 10px 12px; }
:deep(.el-table th.el-table__cell) {
  background: #f6f8fb;
  color: #4b5563;
  font-weight: 600;
}

/* 章节与知识点的视觉区分 */
.chapters-table :deep(.el-table__header) {
  background: linear-gradient(90deg, #e9f2ff, #eef6ff);
}
.chapters-table :deep(.el-table__row) {
  transition: background .15s ease;
}
.chapters-table :deep(.el-table__row:hover) {
  background: #f4f9ff;
}

.kp-expand {
  background: #fbfffa;
  border: 1px solid #e8f6ec;
  border-radius: 8px;
  padding: 12px;
}
.kp-table :deep(.el-table__header) {
  background: linear-gradient(90deg, #eafff1, #f2fff6);
}
.kp-table :deep(.el-table__cell) {
  background: #ffffff;
}
.kp-table :deep(.el-table__row:hover) {
  background: #f5fff8;
}
.kp-header {
  background: #f0fff5;
  border: 1px dashed #b7ebc6;
  border-radius: 8px;
  padding: 8px 12px;
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}
.kp-title { color: #16a34a; font-weight: 600; }

/* 知识图谱样式 */
.kg-wrap { margin-top: 18px; background:#fff; border:1px solid #eef1f5; border-radius:10px; }
.kg-header { display:flex; align-items:center; justify-content: space-between; padding:10px 12px; border-bottom:1px solid #eef1f5; font-weight:600; color:#334155 }
.kg-canvas { width: 100%; height: 420px; }
</style>


