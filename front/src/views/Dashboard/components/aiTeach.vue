<template>
  <div class="design-panel">
    <!-- 放在最上方 -->
    <div class="back-button-wrapper">
      <el-button type="text" @click="goBack">
        <el-icon><ArrowLeft /></el-icon>
        返回
      </el-button>
    </div>
    <!-- 课程基本信息 -->
    <el-card class="course-header hero" shadow="hover">
      <div class="hero-inner">
        <img :src="course.image" alt="课程封面" class="hero-cover" />
        <div class="hero-content">
          <h2>📘 智能教学设计 — {{ course.title || '未命名课程' }}</h2>
          <p class="hero-sub">{{ course.subtitle || '上传课程大纲，AI 将自动生成教学目标、知识点分布、时间安排与教学建议。' }}</p>
          <div class="hero-meta">
            <span class="chip">目标 {{ objectiveList.length || 0 }}</span>
            <span class="chip">章节 {{ knowledgeChapters.length || 0 }}</span>
            <span class="chip">课时 {{ scheduleList.length || 0 }}</span>
          </div>
        </div>
      </div>
    </el-card>



    <!-- 上传教学大纲 -->
    <el-card class="upload-card" shadow="hover">
      <h3>上传教学大纲</h3>
      <el-upload
  :http-request="customUpload"
  :limit="1"
  :auto-upload="true"
  accept=".pdf,.doc,.docx"
>
  <el-button type="primary">点击上传教学大纲</el-button>
</el-upload>
 <div style="margin-top: 8px;">
   <el-button type="success" :disabled="!syllabusUploaded || generating" @click="generatePlan">
     {{ generating ? '正在生成...' : '一键生成教学内容' }}
   </el-button>
 </div>
    </el-card>
<!-- 结构化教学计划渲染/占位 -->
<el-empty
  v-if="!plan"
  :description="generating ? '教学内容生成中，请稍候…' : '暂未生成教学内容，请点击一键生成'"
  style="margin-bottom: 2rem"
/>

<el-card v-if="plan && !generating" class="ai-content" shadow="hover">
  <div class="plan-grid">
    <!-- 教学目标 -->
    <el-card shadow="never" class="plan-item">
      <div class="plan-header">
        <h3>🎯 教学目标</h3>
        <el-button link type="primary" @click="toggleEdit('goal')">{{ edit.goal ? '保存' : '修改' }}</el-button>
      </div>
      <div v-if="!edit.goal" class="bullet-list">
        <div v-for="(item, idx) in objectiveList" :key="idx" class="bullet-item">
          <span class="dot">{{ idx + 1 }}</span>
          <span class="text">{{ item }}</span>
        </div>
      </div>
      <el-input v-else type="textarea" :rows="6" v-model="plan['教学目标']" />
    </el-card>

    <!-- 知识点分布 -->
    <el-card shadow="never" class="plan-item">
      <div class="plan-header">
        <h3>🧩 知识点分布</h3>
        <el-button link type="primary" @click="toggleEdit('knowledge')">{{ edit.knowledge ? '保存' : '修改' }}</el-button>
      </div>
      <div v-if="!edit.knowledge" class="chapter-list">
        <div v-for="(chapter, cidx) in knowledgeChapters" :key="cidx" class="chapter">
          <div class="chapter-title">{{ chapter.title }}</div>
          <ul class="chapter-points">
            <li v-for="(p, pidx) in chapter.points" :key="pidx">{{ p }}</li>
          </ul>
        </div>
      </div>
      <el-input v-else type="textarea" :rows="8" v-model="plan['知识点分布']" />
    </el-card>

    <!-- 教学时间安排 -->
    <el-card shadow="never" class="plan-item">
      <div class="plan-header">
        <h3>⏱ 教学时间安排</h3>
        <el-button link type="primary" @click="toggleEdit('schedule')">{{ edit.schedule ? '保存' : '修改' }}</el-button>
      </div>
      <div v-if="!edit.schedule" class="timeline">
        <div v-for="(it, idx) in scheduleList" :key="idx" class="timeline-item">
          <div class="time-dot">{{ idx + 1 }}</div>
          <div class="time-content">
            <div class="time-title">{{ it.title }}</div>
            <div class="time-sub" v-if="it.detail">{{ it.detail }}</div>
          </div>
        </div>
      </div>
      <el-input v-else type="textarea" :rows="8" v-model="plan['教学时间安排']" />
    </el-card>

    <!-- 教学建议 -->
    <el-card shadow="never" class="plan-item">
      <div class="plan-header">
        <h3>💡 教学建议</h3>
        <el-button link type="primary" @click="toggleEdit('advice')">{{ edit.advice ? '保存' : '修改' }}</el-button>
      </div>
      <div v-if="!edit.advice" class="bullet-list">
        <div v-for="(item, idx) in adviceList" :key="idx" class="bullet-item">
          <span class="dot">{{ idx + 1 }}</span>
          <span class="text">{{ item }}</span>
        </div>
      </div>
      <el-input v-else type="textarea" :rows="6" v-model="plan['教学建议']" />
    </el-card>
  </div>
  <el-divider />
  <div class="closing-card">
    <div class="plan-header">
      <h3>📌 结语</h3>
      <el-button link type="primary" @click="toggleEdit('closing')">{{ edit.closing ? '保存' : '修改' }}</el-button>
    </div>
    <div v-if="!edit.closing" class="closing">{{ plan['结语'] }}</div>
    <el-input v-else type="textarea" :rows="3" v-model="plan['结语']" />
  </div>

  <div class="content-header" style="margin-top: 12px; gap: 8px;">
    <el-button type="primary" @click="exportToWord" :disabled="loadingContent || !plan">📄 导出教学内容</el-button>
    <el-button type="success" @click="toGeneratedExam" :disabled="loadingContent || !plan">生成考核题目及参考答案</el-button>
    <el-button type="danger" @click="regenerateContent" :disabled="loadingContent">重新生成</el-button>
  </div>
</el-card>

    
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import axios from 'axios'
import { reactive } from 'vue'  
import { useRoute } from 'vue-router'
import { ElMessageBox, ElMessage, ElLoading } from 'element-plus'
import { ArrowLeft } from '@element-plus/icons-vue'
import { useRouter } from 'vue-router'  // ✅ 需要引入！
import { Document, Packer, Paragraph, TextRun, HeadingLevel, AlignmentType } from 'docx'
import * as fileSaver from 'file-saver'

// 删除“AI推荐考核题目”模块，相关状态清理
const route = useRoute()
const lastUploadedFile = ref(null);
const router = useRouter()
const syllabusUploaded = ref(false)
const loadingContent = ref(false)
const aiContent = ref(null)
const exam = ref(null)
const currentIndex = ref(0)
const gradientList = [
  'linear-gradient(135deg, #ff9a9e, #fad0c4)',
  'linear-gradient(135deg, #a1c4fd, #c2e9fb)',
  'linear-gradient(135deg, #fbc2eb, #a6c1ee)',
  'linear-gradient(135deg, #fdcbf1, #e6dee9)',
  'linear-gradient(135deg, #d4fc79, #96e6a1)',
  'linear-gradient(135deg, #84fab0, #8fd3f4)'
]

// 已移除轮播题目展示
// 从路由 query 中获取课程信息
const course = reactive({
    id: route.query.courseId,
  title: route.query.title || '',
  subtitle: route.query.subtitle || '',
  image: route.query.image || ''
})
// 已移除配色与轮播监听
function goBack() {
  // 返回到design-tools页面，保持URL参数
  router.push({ 
    name: 'DesignTools',
    query: {
      courseId: route.query.courseId,
      title: route.query.title,
      subtitle: route.query.subtitle,
      image: route.query.image
    }
  })
}
async function saveSingleQuestion(question) {
  try {
    const res = await axios.post('/api/xiaozhi/teacher/save-questions', {
      teacherId: route.query.teacherId || 2,
      courseId: route.query.courseId,
      questions: [question]
    })

    if (res.data.code === 200) {
      ElMessage.success('✅ 当前题目保存成功');
    } else {
      ElMessage.error('❌ 保存失败：' + res.data.message);
    }
  } catch (err) {
    ElMessage.error('❌ 请求异常：' + err.message);
  }
}
async function saveQuestions() {
  if (!examList.value.length) {
    ElMessage.warning('暂无题目可保存');
    return;
  }

  try {
    const res = await axios.post('/api/xiaozhi/teacher/save-questions', {

      teacherId: route.query.teacherId || 2,
      courseId: route.query.courseId,
      questions: examList.value
    })

    if (res.data.code === 200) {
      ElMessage.success('✅ 题目已保存到题库');
    } else {
      ElMessage.error('❌ 保存失败：' + res.data.message);
    }
  } catch (err) {
    ElMessage.error('❌ 请求异常：' + err.message);
  }
}

function discardQuestion() {
  if (!examList.value.length) return;
  examList.value.splice(currentIndex.value, 1);
  if (examList.value.length === 0) {
    currentIndex.value = 0;
  } else if (currentIndex.value >= examList.value.length) {
    currentIndex.value = examList.value.length - 1;
  }
}

function handleUploadSuccess(response) {
  ElMessage.success('教学大纲上传成功')
  syllabusUploaded.value = true
}
const aiRawText = ref('')
const plan = ref(null)
const edit = ref({ goal: false, knowledge: false, schedule: false, advice: false, closing: false })

function customUpload({ file, onSuccess }) {
  // 仅缓存文件，不立刻调用后端生成
  aiRawText.value = ''
  lastUploadedFile.value = file
  syllabusUploaded.value = true
  loadingContent.value = false
  onSuccess && onSuccess({ ok: true })
  ElMessage.success('✅ 教学大纲上传成功，点击“一键生成教学内容”开始生成')
}

const generating = ref(false)
async function generatePlan() {
  if (!lastUploadedFile.value) {
    ElMessage.warning('请先上传教学大纲文件')
    return
  }
  generating.value = true
  loadingContent.value = true
  try {
    const formData = new FormData()
    formData.append('file', lastUploadedFile.value)
    const response = await fetch('/api/xiaozhi/teacher/generate-plan-by-file', { method: 'POST', body: formData })
    const data = await response.json()
    if (data.code === 200) {
      plan.value = data.data
      aiRawText.value = `${plan.value.教学目标}\n${plan.value.知识点分布}\n${plan.value.教学时间安排}\n${plan.value.教学建议}\n${plan.value.结语}`
      ElMessage.success('✅ 教学内容生成成功')
    } else {
      throw new Error(data.message || '生成失败')
    }
  } catch (e) {
    ElMessage.error('生成失败：' + e.message)
  } finally {
    generating.value = false
    loadingContent.value = false
  }
}

function formatDate(dateString) {
  const date = new Date(dateString)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}
async function generateContent() {
  loadingContent.value = true
  try {
    const res = await axios.get('/api/xiaozhi/teacher/generate-plan-by-file')
    aiContent.value = res.data
    ElMessage.success('生成教学内容成功')
  } catch (err) {
    ElMessage.error('生成教学内容失败')
  } finally {
    loadingContent.value = false
  }
}

function toggleEdit(key) {
  edit.value[key] = !edit.value[key]
}

// 解析与分段
const objectiveList = computed(() => splitLines(plan.value?.['教学目标']))
const adviceList = computed(() => splitLines(plan.value?.['教学建议']))
const scheduleList = computed(() => parseSchedule(plan.value?.['教学时间安排']))
const knowledgeChapters = computed(() => parseChapters(plan.value?.['知识点分布']))

function splitLines(text) {
  if (!text) return []
  return text
    .split(/\n|\r\n/)
    .map(s => s.replace(/^\d+[\.|、]\s*/, '').trim())
    .filter(Boolean)
}

function parseChapters(text) {
  if (!text) return []
  const lines = text.split(/\n|\r\n/)
  const chapters = []
  let current = null
  
  lines.forEach(l => {
    const trimmedLine = l.trim()
    if (!trimmedLine) return
    
    // 匹配多种章节格式：
    // 1. 第X章/节：标题
    // 2. 一、二、三、等：标题  
    // 3. 标题：内容（冒号分隔格式）
    // 4. 标题（独立行，后面跟子项）
    const chapterMatch = trimmedLine.match(/^(第[一二三四五六七八九十]+[章节]|[一二三四五六七八九十]+、)[：:，,\s-]*(.*)$/)
    const colonMatch = trimmedLine.match(/^([^：:]+)[：:](.*)$/)
    const bulletMatch = trimmedLine.match(/^[-•·]\s*(.+)$/)
    
    if (chapterMatch) {
      // 格式1和2：第X章 或 一、二、三、
      if (current) chapters.push(current)
      current = { title: `${chapterMatch[1]} ${chapterMatch[2] || ''}`.trim(), points: [] }
    } else if (colonMatch && !bulletMatch) {
      // 格式3：标题：内容（冒号分隔）
      if (current) chapters.push(current)
      const title = colonMatch[1].trim()
      const content = colonMatch[2].trim()
      current = { title, points: [] }
      if (content) {
        // 如果冒号后面有内容，按逗号或分号分割作为知识点
        const points = content.split(/[，,；;]/).map(p => p.trim()).filter(Boolean)
        current.points = points
      }
    } else if (bulletMatch && current) {
      // 格式4：子项（以-、•、·开头）
      const point = bulletMatch[1].trim()
      if (point) current.points.push(point)
    } else if (current && !bulletMatch) {
      // 其他情况：可能是独立的标题行或知识点
      if (trimmedLine.length > 0 && !trimmedLine.match(/^[-•·\s]/)) {
        // 如果当前章节没有标题，这可能是标题
        if (!current.title || current.title === '') {
          current.title = trimmedLine
        } else {
          // 否则作为知识点添加
          current.points.push(trimmedLine)
        }
      }
    } else if (!current) {
      // 如果还没有当前章节，这可能是第一个标题
      current = { title: trimmedLine, points: [] }
    }
  })
  
  if (current) chapters.push(current)
  return chapters
}

function parseSchedule(text) {
  if (!text) return []
  return text.split(/\n|\r\n/)
    .map(l => l.trim())
    .filter(Boolean)
    .map(l => {
      const m = l.match(/^(第?\d+[\-~到至]?\d*[^：:]*):?\s*(.*)$/)
      return { title: m ? m[1] : l, detail: m ? m[2] : '' }
    })
}


async function regenerateContent() {
  if (!lastUploadedFile.value) {
    ElMessage.warning('请先上传教学大纲文件');
    return;
  }
  ElMessage.info('正在重新生成...');
  aiRawText.value = '';
  await customUpload({ file: lastUploadedFile.value });
}

async function generateExam() {
  if (!plan.value || !course.title) {
    ElMessage.warning('教学内容未生成或课程信息缺失');
    return;
  }

  const loadingInstance = ElLoading.service({
    lock: true,
    text: '正在生成考核题目，请稍候...',
    background: 'rgba(255, 255, 255, 0.7)'
  });

  try {
    const res = await axios.post('/api/xiaozhi/teacher/generate-questions', {
      courseId: route.query.courseId,
      objective: plan.value.教学目标,
      teacherId: route.query.teacherId || 1
    });

    if (res.data.code === 200 && Array.isArray(res.data.data)) {
      examList.value = res.data.data;
      ElMessage.success('考核题目生成成功');
    } else {
      ElMessage.error('考核题目生成失败');
    }
  } catch (err) {
    ElMessage.error('请求失败：' + err.message);
  } finally {
    loadingInstance.close();
  }
}

async function toGeneratedExam() {
  if (!plan.value) return
  const base = {
    courseId: route.query.courseId,
    teacherId: route.query.teacherId || 1,
    chapters: knowledgeChapters.value
  }

  const loading = ElLoading.service({
    lock: true,
    text: '正在根据知识点生成题目 0%',
    background: 'rgba(255,255,255,0.7)'
  })

  // 工具：限制长度，避免提示过长导致大模型超慢/超时
  const truncate = (s, max = 2000) => (s && s.length > max ? s.slice(0, max) : s)

  // 工具：并发执行
  async function withConcurrency(tasks, limit) {
    const ret = []
    let idx = 0
    const workers = new Array(Math.min(limit, tasks.length)).fill(0).map(async () => {
      while (idx < tasks.length) {
        const cur = idx++
        ret[cur] = await tasks[cur]()
        const percent = Math.round((ret.filter(Boolean).length / tasks.length) * 100)
        loading.setText(`正在根据知识点生成题目 ${percent}%`)
      }
    })
    await Promise.allSettled(workers)
    return ret
  }

  try {
    const tasks = base.chapters.map((ch) => async () => {
      // 将章节知识点拼为更短的 objective
      const objective = truncate(`章节：${ch.title}\n知识点：\n- ${ch.points.join('\n- ')}`, 1800)
      try {
        const res = await axios.post('/api/xiaozhi/teacher/generate-questions', {
          courseId: base.courseId,
          objective,
          teacherId: base.teacherId
        }, { timeout: 60000 })
        if (res.data.code === 200 && Array.isArray(res.data.data)) {
          return { ok: true, questions: res.data.data }
        }
        return { ok: false, error: res.data.message || '出题失败' }
      } catch (err) {
        // 简单重试一次（更短提示）
        try {
          const retryObj = truncate(`知识点：${ch.points.join('、')}`, 1200)
          const res2 = await axios.post('/api/xiaozhi/teacher/generate-questions', {
            courseId: base.courseId,
            objective: retryObj,
            teacherId: base.teacherId
          }, { timeout: 50000 })
          if (res2.data.code === 200 && Array.isArray(res2.data.data)) {
            return { ok: true, questions: res2.data.data }
          }
          return { ok: false, error: res2.data.message || err.message }
        } catch (e2) {
          return { ok: false, error: e2.message }
        }
      }
    })

    const results = await withConcurrency(tasks, 3) // 并发3个章节

    const grouped = base.chapters.map(ch => ({ title: ch.title, points: ch.points, questions: [] }))

    results.forEach((res, i) => {
      if (res && res.ok) {
        const pts = base.chapters[i].points || []
        res.questions.forEach(q => {
          // 缺失知识点时补上本章第一个知识点，防止归类失败
          if (!q.knowledgePoint || !q.knowledgePoint.trim()) q.knowledgePoint = pts[0] || base.chapters[i].title
          // 简单清洗题目内容长度
          q.content = truncate(q.content || '', 1200)
          q.answer = truncate(q.answer || '', 1000)
          grouped[i].questions.push(q)
        })
      }
    })

    const total = grouped.reduce((s, ch) => s + ch.questions.length, 0)
    if (total === 0) {
      throw new Error('未生成到任何题目，请稍后重试')
    }

    sessionStorage.setItem('ai-generated-exam-render', JSON.stringify({ courseId: base.courseId, teacherId: base.teacherId, chapters: grouped }))
    router.push({ name: 'aiGeneratedExam' })

  } catch (e) {
    ElMessage.error('生成失败：' + e.message)
  } finally {
    loading.close()
  }
}

function nextQuestion() {
  if (currentIndex.value < examList.value.length - 1) {
    currentIndex.value++
    currentQuestion.value = examList.value[currentIndex.value]
  }
}

function prevQuestion() {
  if (currentIndex.value > 0) {
    currentIndex.value--
    currentQuestion.value = examList.value[currentIndex.value]
  }
}

// 导出教学内容为Word文档
async function exportToWord() {
  if (!plan.value) {
    ElMessage.warning('请先生成教学内容')
    return
  }

  try {
    const loading = ElLoading.service({
      lock: true,
      text: '正在生成Word文档...',
      background: 'rgba(255, 255, 255, 0.7)'
    })

    // 创建Word文档内容
    const doc = new Document({
      sections: [{
        properties: {},
        children: [
          // 课程标题
          new Paragraph({
            text: `智能教学设计 - ${course.title || '未命名课程'}`,
            heading: HeadingLevel.TITLE,
            alignment: AlignmentType.CENTER,
            spacing: { after: 400 }
          }),
          
          // 课程副标题
          new Paragraph({
            text: course.subtitle || 'AI生成的教学内容',
            alignment: AlignmentType.CENTER,
            spacing: { after: 600 }
          }),

          // 教学目标
          new Paragraph({
            text: '🎯 教学目标',
            heading: HeadingLevel.HEADING_1,
            spacing: { before: 400, after: 200 }
          }),
          ...objectiveList.value.map(obj => 
            new Paragraph({
              text: `• ${obj}`,
              spacing: { after: 100 }
            })
          ),

          // 知识点分布
          new Paragraph({
            text: '🧩 知识点分布',
            heading: HeadingLevel.HEADING_1,
            spacing: { before: 400, after: 200 }
          }),
          ...knowledgeChapters.value.map(chapter => [
            new Paragraph({
              text: chapter.title,
              heading: HeadingLevel.HEADING_2,
              spacing: { before: 200, after: 100 }
            }),
            ...chapter.points.map(point => 
              new Paragraph({
                text: `• ${point}`,
                spacing: { after: 50 }
              })
            )
          ]).flat(),

          // 教学时间安排
          new Paragraph({
            text: '⏱ 教学时间安排',
            heading: HeadingLevel.HEADING_1,
            spacing: { before: 400, after: 200 }
          }),
          ...scheduleList.value.map(schedule => 
            new Paragraph({
              text: `• ${schedule.title}${schedule.detail ? ': ' + schedule.detail : ''}`,
              spacing: { after: 100 }
            })
          ),

          // 教学建议
          new Paragraph({
            text: '💡 教学建议',
            heading: HeadingLevel.HEADING_1,
            spacing: { before: 400, after: 200 }
          }),
          ...adviceList.value.map(advice => 
            new Paragraph({
              text: `• ${advice}`,
              spacing: { after: 100 }
            })
          ),

          // 结语
          new Paragraph({
            text: '📌 结语',
            heading: HeadingLevel.HEADING_1,
            spacing: { before: 400, after: 200 }
          }),
          new Paragraph({
            text: plan.value['结语'] || '',
            spacing: { after: 200 }
          })
        ]
      }]
    })

    // 生成Word文档
    try {
      const blob = await Packer.toBlob(doc)
      const fileName = `${course.title || '教学内容'}_${new Date().toISOString().split('T')[0]}.docx`
      fileSaver.saveAs(blob, fileName)
    } catch (blobError) {
      // 备用方案：使用 base64 编码
      const base64 = await Packer.toBase64String(doc)
      const byteCharacters = atob(base64)
      const byteNumbers = new Array(byteCharacters.length)
      for (let i = 0; i < byteCharacters.length; i++) {
        byteNumbers[i] = byteCharacters.charCodeAt(i)
      }
      const byteArray = new Uint8Array(byteNumbers)
      const blob = new Blob([byteArray], { 
        type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' 
      })
      const fileName = `${course.title || '教学内容'}_${new Date().toISOString().split('T')[0]}.docx`
      fileSaver.saveAs(blob, fileName)
    }
    
    ElMessage.success('✅ Word文档导出成功')
    loading.close()
  } catch (error) {
    ElMessage.error('导出失败：' + error.message)
    console.error('导出Word文档失败:', error)
  }
}
</script>

<style scoped>
.design-panel {
  padding: 2rem;
  width: 100%;
  margin: 0 auto;
}

.course-header {
  margin-bottom: 2rem;
}

/* 顶部大横幅 */
.hero { padding: 0; overflow: hidden; }
.hero-inner {
  display: flex; gap: 16px; align-items: center;
  background: linear-gradient(135deg, #eef2ff, #fef3c7);
  padding: 16px;
}
.hero-cover {
  width: 120px; height: 90px; object-fit: cover; border-radius: 12px;
  box-shadow: 0 8px 20px rgba(0,0,0,0.06);
}
.hero-content h2 { margin: 0 0 6px 0; color: #1e3a8a; }
.hero-sub { margin: 0; color: #475569; }
.hero-meta { margin-top: 8px; display: flex; gap: 8px; }
.chip { background:#fff; border-radius: 999px; padding: 2px 10px; font-size:12px; color:#0f172a; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }

.intro-card {
  margin-bottom: 2rem;
  border-radius: 14px;
  overflow: hidden;
  background: linear-gradient(135deg, #eef2ff 0%, #fdf2f8 100%);
}

.intro-hero {
  padding: 1.25rem 1.5rem;
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(6px);
}

.intro-title {
  font-size: 1.1rem;
  font-weight: 700;
  margin: 0 0 0.5rem 0;
  color: #1e3a8a;
}

.intro-desc {
  margin: 0 0 0.5rem 0;
  line-height: 1.7;
  color: #374151;
}

.course-image {
  width: 100%;
  max-width: 180px;
  height: auto;
  border-radius: 8px;
}

.upload-card,
.ai-content,
.exam-card {
  margin-bottom: 2rem;
}

/* 引导卡片 */
.tips-card { background: transparent; }
.tips-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
.tip { background: #fff; border-radius: 12px; padding: 14px; box-shadow: 0 2px 12px rgba(0,0,0,0.04); }
.tip-title { font-weight: 700; color:#111827; margin-bottom: 4px; }
.tip-desc { color:#6b7280; }

.content-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}
.design-panel {
  padding: 2rem;
  background-color: #f9fafb;
  min-height: 100vh;
}

.course-header {
  margin-bottom: 2rem;
  border-radius: 12px;
  overflow: hidden;
}

.course-image {
  width: 100%;
  max-width: 160px;
  height: auto;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

h2 {
  font-size: 1.6rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
  color: #1e3a8a;
}

.upload-card,
.ai-content,
.exam-card {
  margin-bottom: 2rem;
  border-radius: 12px;
  padding: 1.5rem;
  background-color: #fff;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.upload-card h3 {
  font-size: 1.25rem;
  margin-bottom: 1rem;
  color: #374151;
}

.content-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.content-header h3 {
  font-size: 1.2rem;
  color: #10b981;
  font-weight: 600;
}

.content-section p {
  margin: 0.5rem 0;
  font-size: 1rem;
  color: #374151;
  line-height: 1.6;
}

.exam-card h3 {
  font-size: 1.2rem;
  color: #f97316;
  font-weight: 600;
  margin-bottom: 1rem;
}

.plan-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 16px;
}
@media (min-width: 900px) {
  .plan-grid {
    grid-template-columns: 1fr 1fr;
  }
}
.plan-item h3 {
  margin: 0 0 8px 0;
  color: #1e3a8a;
}
.plan-item {
  /* 统一卡片内内容高度感受 */
  display: flex;
  flex-direction: column;
}
.plan-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 6px;
}
.bullet-list,
.chapter-list,
.timeline,
.closing-card .closing {
  /* 统一高度 + 超出滚动（隐藏滚动条） */
  min-height: 220px;
  max-height: 260px;
  overflow-y: auto;
  padding-right: 6px;
  -ms-overflow-style: none;      /* IE/Edge */
  scrollbar-width: none;         /* Firefox */
}
.bullet-list::-webkit-scrollbar,
.chapter-list::-webkit-scrollbar,
.timeline::-webkit-scrollbar,
.closing-card .closing::-webkit-scrollbar {
  width: 0;
  height: 0;                      /* Chrome/Safari */
}
.bullet-list .bullet-item {
  display: flex;
  gap: 8px;
  padding: 8px 10px;
  border-radius: 10px;
  background: #f8fafc;
  margin-bottom: 8px;
}
.bullet-list .dot {
  width: 22px;
  height: 22px;
  border-radius: 50%;
  background: #e0e7ff;
  color: #4338ca;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
}
.chapter {
  background: #f9fafb;
  border-radius: 12px;
  padding: 10px 12px;
  margin-bottom: 10px;
}
.chapter-title {
  font-weight: 700;
  color: #0f172a;
  margin-bottom: 6px;
}
.chapter-points {
  padding-left: 18px;
  margin: 0;
}
.timeline {
  position: relative;
  padding-left: 18px;
}
.timeline::before {
  content: '';
  position: absolute;
  left: 9px;
  top: 0;
  bottom: 0;
  width: 2px;
  background: linear-gradient(#93c5fd, #60a5fa);
}
.timeline-item {
  position: relative;
  display: flex;
  gap: 10px;
  margin: 10px 0;
}
.time-dot {
  width: 18px;
  height: 18px;
  line-height: 18px;
  text-align: center;
  border-radius: 50%;
  background: #3b82f6;
  color: #fff;
  font-size: 12px;
  position: relative;
  top: 2px;
}
.time-title {
  font-weight: 600;
  color: #1e293b;
}
.time-sub {
  color: #64748b;
  font-size: 13px;
}
.closing-card {
  background: #f8fafc;
  padding: 10px 12px;
  border-radius: 12px;
}
.plan-text {
  white-space: pre-wrap;
  line-height: 1.6;
}
.closing {
  margin-top: 8px;
  color: #64748b;
}

.el-button {
  border-radius: 8px;
}

.el-button + .el-button {
  margin-left: 1rem;
}

.el-upload {
  margin-bottom: 1rem;
}
.stream-content {
  background-color: #f4f4f5;
  padding: 1rem;
  border-radius: 8px;
  min-height: 150px;
  white-space: pre-wrap;
  /* 更友好的中英文字体栈，避免中文显示为问号 */
  font-family: "SFMono-Regular", Consolas, Menlo, "PingFang SC", "Microsoft YaHei", "Noto Sans CJK SC", "Source Han Sans SC", "Courier New", monospace;
  color: #1f2937;
}

.stream-content pre {
  margin: 0;
  font-family: "SFMono-Regular", Consolas, Menlo, "PingFang SC", "Microsoft YaHei", "Noto Sans CJK SC", "Source Han Sans SC", "Courier New", monospace;
}
.stream-content {
  background-color: #f4f4f5;
  padding: 1rem;
  border-radius: 8px;
  height: 300px;        /* 固定高度，比如300px */
  overflow-y: auto;     /* 超出时显示垂直滚动条 */
  white-space: pre-wrap;
  font-family: "SFMono-Regular", Consolas, Menlo, "PingFang SC", "Microsoft YaHei", "Noto Sans CJK SC", "Source Han Sans SC", "Courier New", monospace;
  color: #1f2937;
}
.exam-scroll {
  max-height: 400px; /* 可根据需要调整高度 */
  overflow-y: auto;
  padding-right: 0.5rem; /* 防止滚动条遮住内容 */
}
.back-button {
position: relative;
  top: 1rem;
  left: 1rem;
  z-index: 10;
  font-weight: bold;
  color: #1d4ed8;
}
.back-button-wrapper {
  margin-bottom: 1rem;
}
.design-panel {
  padding: 2rem;
  width: 1000px;
  margin: 0 auto;
  background-color: #f9fafb;
  min-height: 100vh;
}

.course-header {
  margin-bottom: 2rem;
  border-radius: 12px;
}

.course-image {
  width: 100%;
  max-width: 180px;
  height: auto;
  border-radius: 8px;
}

.exam-card {
  margin-bottom: 2rem;
  border-radius: 12px;
  padding: 1.5rem;
  background-color: #fff;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.button-group {
  display: flex;
  justify-content: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.question-card {
  padding: 1rem;
  border-radius: 10px;
  background: linear-gradient(135deg, #fef9f9, #f0f4ff);
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.question-title {
  font-size: 1.3rem;
  font-weight: bold;
  color: #4f46e5;
  margin-bottom: 1rem;
  text-align: center;
}

.content-section {
  margin-bottom: 1rem;
  border-radius: 8px;
}

.content-text {
  font-size: 1rem;
  line-height: 1.6;
  color: #374151;
}

.meta-section {
  margin-bottom: 1rem;
}

.action-buttons {
  display: flex;
  justify-content: center;
  gap: 1rem;
  margin-top: 1rem;
}

.back-button-wrapper {
  margin-bottom: 1rem;
}

.exam-title {
  font-size: 1.5rem;
  font-weight: bold;
  background: linear-gradient(to right, #667eea, #764ba2);
  background-clip: text;
  -webkit-background-clip: text;
  color: transparent;
  text-align: center;
  margin-bottom: 1rem;
}

.button-group {
  display: flex;
  justify-content: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.fancy-card {
  padding: 1.5rem;
  border-radius: 15px;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
  transition: all 0.3s ease;
  color: #374151;
}

.fancy-card:hover {
  transform: translateY(-5px) scale(1.02);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.25);
}

.question-header {
  font-weight: bold;
  font-size: 1.2rem;
  text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.1);
  margin-bottom: 0.75rem;
  text-align: center;
}

.question-body {
  background: rgba(255, 255, 255, 0.85);
  padding: 1rem;
  border-radius: 12px;
  backdrop-filter: blur(5px);
}

.question-input {
  margin-bottom: 0.75rem;
}

.question-meta {
  font-size: 0.9rem;
  color: #6b7280;
  margin-top: 0.75rem;
}

.action-buttons {
  display: flex;
  justify-content: center;
  gap: 0.75rem;
  margin-top: 1rem;
}

.fade-slide-enter-active,
.fade-slide-leave-active {
  transition: all 0.5s ease;
}

.fade-slide-enter-from {
  opacity: 0;
  transform: translateY(20px);
}

.fade-slide-leave-to {
  opacity: 0;
  transform: translateY(-20px);
}
</style>