<template>
  <div class="generated-exam">
    <el-page-header @back="goBack" content="AI 考核题目">
      <template #icon><el-icon><ArrowLeft /></el-icon></template>
    </el-page-header>

    <el-alert v-if="loading" title="正在生成题目，请稍候…" type="info" show-icon class="mb-3" />

    <div v-if="!loading && chapters.length" class="toolbar">
      <el-select v-model="chapterIdx" placeholder="选择章节" size="large" class="toolbar-select">
        <el-option v-for="(ch, i) in chapters" :key="i" :label="chapterLabel(ch)" :value="i" />
      </el-select>

      <el-radio-group v-model="typeFilter" size="large" class="type-group">
        <el-radio-button label="all">全部</el-radio-button>
        <el-radio-button label="choice">选择题</el-radio-button>
        <el-radio-button label="short_answer">简答题</el-radio-button>
        <el-radio-button label="programming">编程题</el-radio-button>
      </el-radio-group>
    </div>

    <el-card v-if="!loading && currentChapter" class="chapter-card" shadow="hover">
      <div class="chapter-title">{{ currentChapter.title }}</div>
      <div class="batch-bar">
        <el-checkbox v-model="selectAll" @change="toggleSelectAll">全选当前章</el-checkbox>
        <el-button type="success" size="small" :disabled="selectedList.length===0" @click="saveSelected">批量入库（{{ selectedList.length }}）</el-button>
      </div>
      <div class="question-list">
        <div v-for="(q, qidx) in filteredQuestions" :key="qidx" class="question-card" :class="q.type">
          <div class="q-select">
            <el-checkbox v-model="q._selected"></el-checkbox>
          </div>
          <div class="q-header">
            <span class="pill" :class="q.type">{{ typeText(q.type) }}</span>
            <span class="q-kp">知识点：{{ q.knowledgePoint }}</span>
          </div>
          <div class="q-stem" v-html="format(q.content)"></div>
          <ul v-if="q.type === 'choice' && options(q.content).length" class="q-options">
            <li v-for="(opt, i) in options(q.content)" :key="i">
              <span class="opt-tag">{{ optionLetter(opt) }}</span>
              <span class="opt-text">{{ optionText(opt) }}</span>
            </li>
          </ul>
          <div class="q-answer">
            <div class="answer-title">参考答案</div>
            <div class="answer-content" v-html="format(q.answer)"></div>
          </div>
        </div>
      </div>
    </el-card>
  </div>
  
</template>

<script setup>
import { onMounted, ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft } from '@element-plus/icons-vue'
import axios from 'axios'

const route = useRoute()
const router = useRouter()
const loading = ref(true)
const chapters = ref([])
const chapterIdx = ref(0)
const typeFilter = ref('all')
const courseId = ref(null)
const teacherId = ref(null)

// 统一消息（简单且稳定）
function notifySuccess(text) {
  try { ElMessage({ type: 'success', message: text }) } catch (e) { console.log(text) }
}
function notifyError(text) {
  try { ElMessage({ type: 'error', message: text }) } catch (e) { console.error(text) }
}

function goBack() {
  router.back()
}

function format(text) {
  return String(text || '').replace(/\n/g, '<br/>')
}

function typeText(t) {
  return t === 'choice' ? '选择题' : t === 'programming' ? '编程题' : '简答题'
}

function options(content) {
  // 从内容里提取可能的选项行：A. / A、 / - 选项
  const arr = String(content || '').split(/\n|\r\n/)
  return arr.filter(l => /^[A-Da-d][\.|、\)]\s+/.test(l) || /^-\s+/.test(l)).map(l => l.trim())
}

function optionLetter(line) {
  const m = String(line).match(/^([A-Da-d])[\.|、\)]\s*/)
  return m ? m[1].toUpperCase() : '·'
}
function optionText(line) {
  return String(line).replace(/^[A-Da-d][\.|、\)]\s*/, '').replace(/^-\s*/, '')
}

const currentChapter = computed(() => chapters.value[chapterIdx.value] || null)
const filteredQuestions = computed(() => {
  if (!currentChapter.value) return []
  const list = currentChapter.value.questions || []
  return typeFilter.value === 'all' ? list : list.filter(q => q.type === typeFilter.value)
})
function chapterLabel(ch) {
  const count = (ch.questions || []).length
  return `${ch.title}（${count}题）`
}

onMounted(async () => {
  try {
    // 直接读取 aiTeach 预生成好的渲染数据
    const render = sessionStorage.getItem('ai-generated-exam-render')
    if (!render) throw new Error('未找到题目数据，请返回重试')
    const data = JSON.parse(render)
    chapters.value = (data.chapters || []).map(ch => ({
      ...ch,
      questions: (ch.questions || []).map(q => ({ ...q, _selected: false }))
    }))
    courseId.value = data.courseId
    teacherId.value = data.teacherId
    chapterIdx.value = 0
  } catch (e) {
    notifyError('生成失败：' + e.message)
  } finally {
    loading.value = false
  }
})

const selectAll = ref(false)
const selectedList = computed(() => {
  if (!currentChapter.value) return []
  return (currentChapter.value.questions || []).filter(q => q._selected)
})
function toggleSelectAll(val) {
  if (!currentChapter.value) return
  (currentChapter.value.questions || []).forEach(q => { q._selected = val })
}
async function saveSelected() {
  if (!selectedList.value.length) return
  try {
    const res = await axios.post('/api/xiaozhi/teacher/save-questions', {
      teacherId: teacherId.value || 1,
      courseId: courseId.value,
      questions: selectedList.value
    })
    if (res.data.code === 200) {
      notifySuccess('✅ 已入库 ' + selectedList.value.length + ' 道题目')
      ;(currentChapter.value.questions || []).forEach(q => { q._selected = false })
      selectAll.value = false
      return
    }
    notifyError('❌ 入库失败：' + (res.data.message || '未知错误'))
  } catch (e) {
    notifyError('❌ 入库失败：' + (e?.message || '网络错误'))
  }
}
</script>

<style scoped>
 .generated-exam { padding: 16px; max-width: 1100px; margin: 0 auto; }
.mb-3 { margin-bottom: 12px; }

.toolbar { display: flex; gap: 12px; align-items: center; margin-bottom: 12px; flex-wrap: wrap; }
.toolbar-select { width: 260px; }
/* 放大题型筛选按钮 */
:deep(.type-group .el-radio-button__inner) {
  padding: 8px 16px;
  font-size: 14px;
}
/* 让按钮组更圆润 */
:deep(.type-group .el-radio-button__inner) {
  border-radius: 999px !important;
}

.chapter-card { margin-bottom: 18px; }
.chapter-title {
  font-size: 18px;
  font-weight: 700;
  margin-bottom: 10px;
}
.batch-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
.question-card { 
  padding: 16px; 
  border-radius: 16px; 
  background: #ffffff; 
  margin-bottom: 14px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.06);
  border: 1px solid #eef2f7;
  transition: transform .15s ease;
}
.question-card:hover { transform: translateY(-2px); }
.q-select { position: absolute; margin-top: -6px; }
.question-card.choice { border-left: 6px solid #f59e0b; }
.question-card.short_answer { border-left: 6px solid #6366f1; }
.question-card.programming { border-left: 6px solid #10b981; }

.q-header { display: flex; gap: 10px; align-items: center; margin-bottom: 8px; }
.pill { padding: 2px 10px; border-radius: 999px; font-size: 12px; font-weight: 700; color:#fff; }
.pill.choice { background: #f59e0b; }
.pill.short_answer { background: #6366f1; }
.pill.programming { background: #10b981; }
.q-kp { color:#64748b; font-size: 13px; }

.q-stem { color:#0f172a; margin: 6px 0 8px; font-weight: 600; }
.q-options { margin: 4px 0 8px 0; list-style: none; padding: 0; }
.q-options li { display: flex; align-items: flex-start; gap: 8px; padding: 6px 10px; border-radius: 10px; background:#f8fafc; margin-bottom: 6px; }
.opt-tag { width: 24px; height: 24px; border-radius: 50%; background:#e2e8f0; display:inline-flex; align-items:center; justify-content:center; font-weight:700; color:#334155; }
.opt-text { color:#334155; }

.q-answer { background: #f9fafb; border-radius: 12px; padding: 10px 12px; }
.answer-title { color:#334155; font-weight: 700; margin-bottom: 4px; }
.answer-content { color:#0f172a; white-space: pre-wrap; }
</style>


