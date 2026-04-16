<template>
  <div class="gen-view">
    <div class="page-bar">
      <h2 class="page-title">生成结果</h2>
      <div class="actions">
        <el-button @click="goBack">返回生成配置</el-button>
        <el-button type="success" @click="saveAll" :loading="saving">保存全部题目</el-button>
      </div>
    </div>
    <el-card>
      <div class="grid">
        <div v-for="(q,idx) in pagedList" :key="idx + (page-1)*pageSize" class="q-card">
          <div class="q-head">
            <el-tag type="primary" size="small">{{ typeText(q.type) }}</el-tag>
            <el-tag size="small" effect="plain">{{ q.knowledgePoint || '未指定知识点' }}</el-tag>
            <el-tag :type="difficultyType(q.difficultyLevel)" size="small">{{ difficultyText(q.difficultyLevel) }}</el-tag>
          </div>
          <div class="q-content" v-html="formatContent(q)"></div>
          <div class="q-answer" v-if="q.answer">
            <strong>答案：</strong>
            <span>{{ q.answer }}</span>
          </div>
          <div class="q-actions">
            <el-button size="small" type="success" :loading="savingOne[idx]" :disabled="savedOne[idx]" @click="saveOne(q, idx)">
              {{ savedOne[idx] ? '已保存' : '保存该题' }}
            </el-button>
          </div>
        </div>
      </div>
      <div class="pager">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next"
          :page-sizes="[5,10,20,50]"
          :total="total"
          :page-size="pageSize"
          :current-page="page"
          @size-change="(val) => pageSize = val"
          @current-change="(val) => page = val"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { useGeneratedQuestionsStore } from '@/store/generatedQuestions.js'

const router = useRouter()
const route = useRoute()
const store = useGeneratedQuestionsStore()
const list = computed(()=> store.list)
const saving = ref(false)
const savingOne = ref({})
const savedOne = ref({})
const page = ref(1)
const pageSize = ref(5)
const total = computed(()=> list.value.length)
const pagedList = computed(()=> {
  const start = (page.value - 1) * pageSize.value
  return list.value.slice(start, start + pageSize.value)
})

// 从URL参数加载数据
onMounted(async () => {
  // 如果store中没有数据，尝试从URL参数加载
  if (list.value.length === 0 && route.query.courseId && route.query.categoryId) {
    console.log('从URL参数加载数据:', route.query)
    await loadQuestionsFromUrl()
  }
})

// 从URL参数加载题目数据
const loadQuestionsFromUrl = async () => {
  try {
    const courseId = route.query.courseId
    const categoryId = route.query.categoryId
    
    // 这里需要根据实际的API接口来加载数据
    // 暂时使用一个模拟的加载逻辑
    console.log('尝试从API加载题目数据...')
    
    // 如果有对应的API接口，可以在这里调用
    // const response = await axios.get(`/question-generator/generated-questions?courseId=${courseId}&categoryId=${categoryId}`)
    
    // 暂时显示提示信息
    ElMessage.info('请通过题目生成页面生成题目后再查看结果')
  } catch (error) {
    console.error('加载题目数据失败:', error)
    ElMessage.error('加载题目数据失败')
  }
}

function typeText(t){
  const map = { choice: '选择题', short_answer: '简答题', programming: '编程题' }
  return map[t] || t
}

function difficultyText(lv){
  // 处理数字类型的难度等级
  if (typeof lv === 'number') {
    const numMap = { 1: '简单', 2: '中等', 3: '困难', 4: '较难', 5: '很难' }
    return numMap[lv] || `难度${lv}`
  }
  // 处理字符串类型的难度等级
  const map = { easy: '简单', medium: '中等', hard: '困难' }
  return map[lv] || '未知'
}

function difficultyType(lv){
  // 处理数字类型的难度等级
  if (typeof lv === 'number') {
    const numMap = { 1: 'success', 2: 'warning', 3: 'danger', 4: 'danger', 5: 'danger' }
    return numMap[lv] || 'info'
  }
  // 处理字符串类型的难度等级
  const map = { easy: 'success', medium: 'warning', hard: 'danger' }
  return map[lv] || 'info'
}

async function saveAll(){
  if (!list.value.length) { ElMessage.warning('没有可保存的题目'); return }
  saving.value = true
  try {
    const res = await axios.post('/question-generator/save', { questions: list.value, categoryId: store.meta.categoryId })
    if (res.data?.code === 200) ElMessage.success('保存成功')
  } finally { saving.value = false }
}

function goBack(){
  router.back()
}

function formatContent(q){
  if (!q) return ''
  
  // 调试信息：打印题目数据结构
  console.log('=== 题目数据调试 ===')
  console.log('完整题目数据:', JSON.stringify(q, null, 2))
  console.log('题目类型:', q.type)
  console.log('选项数据:', q.options)
  console.log('选项类型:', typeof q.options)
  console.log('选项长度:', q.options ? q.options.length : 'undefined')
  console.log('题目内容:', q.content)
  console.log('==================')
  
  // 选择题把 ABCD 分行渲染，并添加样式
  if (q.type === 'choice' && q.options && q.options.length) {
    const options = q.options.map((opt, i)=> 
      `<div class="option-item">${String.fromCharCode(65+i)}. ${escapeHtml(opt)}</div>`
    ).join('')
    return `<div class="question-stem">${escapeHtml(q.content)}</div><div class="options-container">${options}</div>`
  }
  
  // 如果没有options字段，尝试从content中解析选项
  if (q.type === 'choice' && q.content) {
    const content = q.content
    
    // 按行分割内容
    const lines = content.split('\n').map(line => line.trim()).filter(line => line)
    
    // 查找选项行（以A. B. C. D.开头的行）
    const optionLines = []
    const questionLines = []
    
    for (const line of lines) {
      if (/^[A-D]\.\s*/.test(line)) {
        optionLines.push(line)
      } else {
        questionLines.push(line)
      }
    }
    
    // 如果找到选项，分离题目和选项
    if (optionLines.length > 0) {
      const questionText = questionLines.join('\n').trim()
      const options = optionLines.map(opt => 
        `<div class="option-item">${escapeHtml(opt)}</div>`
      ).join('')
      return `<div class="question-stem">${escapeHtml(questionText)}</div><div class="options-container">${options}</div>`
    }
    
    // 如果没找到标准格式的选项，尝试其他格式
    const optionPatterns = [
      /^([A-D]\s*\.\s*.+)$/gm,  // A . 选项内容
      /^([A-D]\s*、\s*.+)$/gm,  // A、选项内容
      /^([A-D]\s*:\s*.+)$/gm,   // A: 选项内容
      /^([A-D]\s*\)\s*.+)$/gm   // A) 选项内容
    ]
    
    let matches = []
    let questionText = content
    
    for (const pattern of optionPatterns) {
      matches = content.match(pattern)
      if (matches && matches.length > 0) {
        questionText = content.replace(pattern, '').trim()
        break
      }
    }
    
    if (matches && matches.length > 0) {
      const options = matches.map(opt => 
        `<div class="option-item">${escapeHtml(opt)}</div>`
      ).join('')
      return `<div class="question-stem">${escapeHtml(questionText)}</div><div class="options-container">${options}</div>`
    }
  }
  
  return `<div class="question-stem">${escapeHtml(q.content || '')}</div>`
}

function escapeHtml(s){
  if (!s) return ''
  return String(s)
    .replace(/&/g,'&amp;')
    .replace(/</g,'&lt;')
    .replace(/>/g,'&gt;')
    .replace(/\n/g,'<br>')
}

async function saveOne(q, idx){
  savingOne.value[idx] = true
  try {
    const res = await axios.post('/question-generator/save', { questions: [q], categoryId: store.meta.categoryId })
    if (res.data?.code === 200) {
      savedOne.value[idx] = true
      ElMessage.success('已保存当前题目')
    }
  } finally {
    savingOne.value[idx] = false
  }
}
</script>

<style scoped>
.gen-view { 
  max-width: 1000px; 
  margin: 0 auto; 
  padding: 20px; 
  width: 100%;
  min-height: 100vh;
  background: #f8fafc;
}
.page-bar { 
  display:flex; 
  justify-content:space-between; 
  align-items:center; 
  margin-bottom: 24px; 
  padding: 0 4px;
}
.page-title { 
  font-size: 24px; 
  color:#0f172a; 
  font-weight: 600;
  margin: 0;
}
.actions { 
  display:flex; 
  gap:12px; 
}
.grid { 
  display:grid; 
  grid-template-columns: 1fr; 
  gap:20px; 
  width: 100%;
}
.q-card { 
  border:1px solid #e5e7eb; 
  border-radius:16px; 
  padding:20px; 
  background:#fff; 
  width: 100%;
  max-width: 900px;
  margin: 0 auto;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}
.q-card:hover {
  box-shadow: 0 8px 24px rgba(0,0,0,0.12);
  transform: translateY(-2px);
}
.q-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #3b82f6, #8b5cf6, #06b6d4);
}
.q-head { 
  display:flex; 
  gap:12px; 
  margin-bottom:16px; 
  flex-wrap: wrap;
  align-items: center;
}
.q-content { 
  line-height:1.8; 
  color:#1f2937; 
  font-size: 16px;
  margin-bottom: 16px;
}

.question-stem {
  margin-bottom: 16px;
  font-weight: 500;
  font-size: 16px;
  line-height: 1.6;
  color: #1f2937;
}

.options-container {
  margin-top: 12px;
}

.option-item {
  padding: 12px 16px;
  margin: 8px 0;
  background: #f8fafc;
  border-radius: 8px;
  border-left: 4px solid #e2e8f0;
  transition: all 0.2s ease;
  font-size: 15px;
  line-height: 1.5;
}

.option-item:hover {
  background: #f1f5f9;
  border-left-color: #3b82f6;
  transform: translateX(4px);
}

.q-answer { 
  margin-top:16px; 
  padding:16px; 
  background: linear-gradient(135deg, #f0f9ff, #e0f2fe); 
  border-left:4px solid #3b82f6; 
  border-radius:8px; 
  color:#1e40af; 
  font-weight: 500;
  box-shadow: 0 2px 8px rgba(59, 130, 246, 0.1);
}
.q-actions { 
  margin-top:20px; 
  text-align:right; 
  padding-top: 16px;
  border-top: 1px solid #f1f5f9;
}
.pager { 
  display:flex; 
  justify-content:center; 
  margin-top:32px; 
  padding: 20px 0;
}

/* 题目类型标签样式 */
:deep(.el-tag) {
  border-radius: 20px;
  font-weight: 500;
  font-size: 13px;
  padding: 4px 12px;
}

/* 按钮样式优化 */
:deep(.el-button) {
  border-radius: 8px;
  font-weight: 500;
  transition: all 0.3s ease;
}

:deep(.el-button--success) {
  background: linear-gradient(135deg, #10b981, #059669);
  border: none;
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
}

:deep(.el-button--success:hover) {
  background: linear-gradient(135deg, #059669, #047857);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
}

/* 分页器样式 */
:deep(.el-pagination) {
  justify-content: center;
}

:deep(.el-pagination .el-pager li) {
  border-radius: 8px;
  margin: 0 4px;
}

:deep(.el-pagination .btn-prev),
:deep(.el-pagination .btn-next) {
  border-radius: 8px;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .gen-view {
    padding: 16px;
    max-width: 900px;
  }
  .q-card {
    padding: 20px;
    max-width: 700px;
  }
}

@media (max-width: 768px) {
  .gen-view {
    padding: 12px;
    max-width: 100%;
  }
  .q-card {
    padding: 16px;
    max-width: 100%;
    margin: 0;
  }
  .page-bar {
    flex-direction: column;
    gap: 16px;
    align-items: flex-start;
  }
  .actions {
    width: 100%;
    justify-content: flex-end;
  }
  .q-head {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
}

/* 加载状态优化 */
:deep(.el-button.is-loading) {
  position: relative;
}

:deep(.el-button.is-loading .el-icon) {
  margin-right: 8px;
}

/* 卡片内容区域优化 */
.q-card > * {
  max-width: 100%;
  word-wrap: break-word;
  overflow-wrap: break-word;
}

/* 确保内容不会溢出 */
.q-content,
.question-stem,
.option-item {
  word-break: break-word;
  hyphens: auto;
}
</style>


