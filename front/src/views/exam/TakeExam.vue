<template>
  <div class="take-exam">
    <div class="left-panel">
      <el-card class="timer-card">
        <div class="title">剩余时间：</div>
        <div class="time">{{ remainText }}</div>
        <div class="meta"><span>考试科目：</span>{{ exam?.courseName || '-' }}</div>
        <div class="meta"><span>答题数量：</span>{{ answeredCount }}/{{ questions.length }}</div>
        <div class="button-group">
          <el-button type="primary" @click="submitExam()">提交试卷</el-button>
          <el-button type="danger" @click="exitExam()">退出考试</el-button>
        </div>
      </el-card>

      <el-card class="sheet-card">
        <div class="sheet-title">答题卡</div>
        <div class="sheet-group" v-for="(group, gidx) in groupedIndexes" :key="gidx">
          <div class="sheet-group-title">{{ group.title }}</div>
          <div class="sheet-grid">
            <el-button v-for="idx in group.indexes" :key="idx" size="small" :type="answers[idx] ? 'success' : 'info'" @click="scrollTo(idx)">{{ idx+1 }}</el-button>
          </div>
        </div>
      </el-card>
    </div>

    <div class="paper-panel">
      <div class="webcam-box">
        <video ref="videoRef" autoplay playsinline muted></video>
      </div>

      <div class="questions-container">
        <div class="question-item" v-for="(q, index) in questions" :key="q.id" :id="'q-'+index">
          <div class="q-title">
            <span>{{ index+1 }}. {{ q.content }}</span>
            <!-- 显示分数 -->
            <span v-if="showResult && getQuestionScore(q.id) !== null" class="question-score" :class="getQuestionScore(q.id) >= 6 ? 'score-pass' : 'score-fail'">
              {{ getQuestionScore(q.id) }}分
            </span>
          </div>
          
          <!-- 显示AI反馈 -->
          <div v-if="showResult && getQuestionFeedback(q.id)" class="ai-feedback">
            <el-tag :type="getQuestionScore(q.id) >= 6 ? 'success' : 'warning'" size="small">
              AI反馈：{{ getQuestionFeedback(q.id) }}
            </el-tag>
          </div>
          
          <div v-if="q.type==='choice'" class="choice-block">
            <el-radio-group v-model="answers[index]" class="choice-group" :disabled="showResult"><div class="choice-item" v-for="opt in q.options" :key="opt.value">
              <el-radio :label="opt.value">{{ opt.label }}</el-radio>
            </div></el-radio-group>
          </div>
          <div v-else-if="q.type==='true_false'">
            <el-radio-group v-model="answers[index]" :disabled="showResult">
              <el-radio :label="true">A. 正确</el-radio>
              <el-radio :label="false">B. 错误</el-radio>
            </el-radio-group>
          </div>
          <div v-else>
            <el-input type="textarea" v-model="answers[index]" rows="5" :disabled="showResult" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, computed } from 'vue'
import { useRoute } from 'vue-router'
import axios from 'axios'
import { ElMessage, ElMessageBox } from 'element-plus'

const route = useRoute()
const videoRef = ref(null)
const questions = ref([])
const answers = ref({})
const exam = ref(null)
const durationMs = ref(60 * 60 * 1000)
const endAt = ref(Date.now() + durationMs.value)
const nowTs = ref(Date.now())
const examResult = ref(null) // 保存批阅结果
const showResult = ref(false) // 是否显示详细结果
let tickTimer = null

const remainText = computed(() => {
  const ms = Math.max(0, endAt.value - nowTs.value)
  const m = Math.floor(ms/60000)
  const s = Math.floor((ms%60000)/1000)
  return `${m}分${s}秒`
})

const groupedIndexes = computed(() => {
  const single = [], judge = [], short = []
  questions.value.forEach((q, i) => {
    if (q.type==='choice') single.push(i)
    else if (q.type==='true_false') judge.push(i)
    else short.push(i)
  })
  return [
    { title: '单选题', indexes: single },
    { title: '判断题', indexes: judge },
    { title: '简答题', indexes: short }
  ]
})

function hasAnswer(idx) {
  const q = questions.value[idx]
  const val = answers.value[idx]
  if (!q) return false
  if (q.type === 'choice' || q.type === 'true_false') return val !== undefined && val !== null && val !== ''
  return typeof val === 'string' ? val.trim().length > 0 : !!val
}

const answeredCount = computed(() => {
  let c = 0
  for (let i = 0; i < questions.value.length; i++) {
    if (hasAnswer(i)) c++
  }
  return c
})

// 获取每道题的分数
const getQuestionScore = (questionId) => {
  if (!examResult.value || !examResult.value.questionResults) return null
  const questionResult = examResult.value.questionResults.find(qr => qr.questionId === questionId)
  return questionResult ? questionResult.score : null
}

// 获取每道题的AI反馈
const getQuestionFeedback = (questionId) => {
  if (!examResult.value || !examResult.value.questionResults) return null
  const questionResult = examResult.value.questionResults.find(qr => qr.questionId === questionId)
  return questionResult ? questionResult.aiFeedback : null
}

function scrollTo(idx){
  document.getElementById('q-'+idx)?.scrollIntoView({ behavior:'smooth', block:'start' })
}

// 退出考试
async function exitExam() {
  try {
    await ElMessageBox.confirm(
      '确定要退出考试吗？\n\n⚠️ 注意：退出后当前答题进度将丢失，需要重新开始考试。',
      '退出考试确认',
      {
        type: 'warning',
        confirmButtonText: '确定退出',
        cancelButtonText: '继续考试',
        confirmButtonClass: 'el-button--danger'
      }
    )
    
    // 用户确认退出
    ElMessage.info('正在退出考试...')
    
    // 停止摄像头
    const stream = videoRef.value?.srcObject
    stream?.getTracks()?.forEach(t => t.stop())
    
    // 清除定时器
    if (tickTimer) {
      clearInterval(tickTimer)
      tickTimer = null
    }
    
    // 跳转回考试列表或首页
    // 这里可以根据实际路由配置调整
    window.history.back() // 返回上一页
    // 或者跳转到特定页面：router.push({ name: 'ExamList' })
    
  } catch (error) {
    // 用户取消退出，什么都不做
    console.log('用户取消退出考试')
  }
}

async function openWebcam(){
  try {
    const stream = await navigator.mediaDevices.getUserMedia({ video:true, audio:true })
    if (videoRef.value) videoRef.value.srcObject = stream
  } catch (e) {
    ElMessage.error('无法开启摄像头/麦克风，请检查权限设置')
  }
}

async function loadExam(){
  try {
    const examId = route.params.id
    
    // 先加载考试基本信息
    const examRes = await axios.get(`/api/xiaozhi/student/exam/${examId}`)
    if (examRes.data.code === 200) {
      exam.value = {
        id: examRes.data.data.id,
        title: examRes.data.data.title,
        courseName: examRes.data.data.courseName || '未知课程',
        duration: examRes.data.data.durationMinutes || 120
      }
      
      // 设置考试时长
      durationMs.value = (exam.value.duration || 120) * 60 * 1000
      endAt.value = Date.now() + durationMs.value
    }
    
    // 再加载考试题目
    const res = await axios.get('/api/xiaozhi/student/exam/questions', { params: { examId } })
    if (res.data.code === 200) {
      // 题目适配：将后端 question_bank 的字段映射为前端渲染结构
      const rawQuestions = (res.data.data || []).map(q => {
        const { stem, options } = splitStemAndOptions(q.content)
        return {
          id: q.id,
          type: mapType(q.type),
          content: stem,
          options
        }
      })
      
      // 按题目类型排序：选择题 → 判断题 → 简答题
      questions.value = rawQuestions.sort((a, b) => {
        const typeOrder = { 'choice': 1, 'true_false': 2, 'text': 3 }
        return (typeOrder[a.type] || 999) - (typeOrder[b.type] || 999)
      })
    } else {
      ElMessage.error(res.data.message || '加载考试题目失败')
    }
  } catch (e) {
    console.error('加载考试失败:', e)
    ElMessage.error('请求失败：' + e.message)
  }
}

function mapType(t){
  if (!t) return 'text'
  const norm = String(t).toLowerCase()
  if (norm.includes('choice') || norm.includes('选择')) return 'choice'
  if (norm.includes('true') || norm.includes('判断')) return 'true_false'
  return 'text'
}

function splitStemAndOptions(raw){
  // 支持两种来源：
  // 1) 题干末尾紧跟 "A. ... B. ... C. ... D. ..."（任意数量选项）
  // 2) 后端未来提供结构化选项时可在此扩展
  const content = raw || ''
  // 兼容 A. / A．/ A、/ A) 等多种写法
  const firstMatch = content.match(/\bA[\.．、\)]\s*/)
  const firstIdx = firstMatch ? content.indexOf(firstMatch[0]) : -1
  if (firstIdx !== -1) {
    const stem = content.slice(0, firstIdx).trim()
    const tail = content.slice(firstIdx).trim()
    const opts = []
    const re = /([A-Z])[\.．、\)]\s*([\s\S]+?)(?=(?:\s+[A-Z][\.．、\)]\s)|$)/g
    let m
    while ((m = re.exec(tail)) !== null) {
      const letter = m[1]
      const text = (m[2] || '').trim()
      if (letter >= 'A' && letter <= 'Z' && text) {
        opts.push({ value: letter, label: `${letter}. ${text}` })
      }
    }
    if (opts.length) {
      return { stem, options: opts }
    }
  }
  return { stem: content.trim(), options: [] }
}

async function submitExam(force = false){
  try{
    if (!force) {
      const unanswered = questions.value.length - answeredCount.value
      if (unanswered > 0) {
        await ElMessageBox.confirm(
          `<div style="color:#f56c6c;font-size:18px;font-weight:700;">您尚未答完的题目，还剩 ${unanswered} 道</div><div style="margin-top:10px;">确定要提交所有试卷吗？</div>`,
          '确认提交试卷',
          { type:'warning', dangerouslyUseHTMLString: true }
        )
      } else {
        await ElMessageBox.confirm('确定要提交试卷吗？','确认提交试卷',{type:'warning'})
      }
    }
    
    // 检查考试信息是否加载完成
    if (!exam.value || !exam.value.id) {
      ElMessage.error('考试信息加载失败，请刷新页面重试')
      return
    }
    
    // 构建提交数据
    const submissionData = {
      examId: exam.value.id,
      studentId: 1, // 这里应该从用户信息中获取
      answers: questions.value.map((q, index) => ({
        questionId: q.id,
        answer: answers.value[index] || '',
        questionType: q.type
      })),
      submitTime: Date.now()
    }
    
    // 显示提交中状态
    ElMessage.info('正在提交试卷，AI正在批阅中...')
    
    // 调用后端提交接口
    const response = await axios.post('/api/exam/submit', submissionData)
    
    if (response.data.code === 200) {
      const result = response.data.data
      examResult.value = result // 保存批阅结果
      ElMessage.success('提交成功！AI批阅完成')
      
      // 显示批阅结果
      await ElMessageBox.alert(
        `<div style="text-align: left;">
          <h3>📊 考试结果</h3>
          <p><strong>总分：</strong>${result.score}分</p>
          <p><strong>正确率：</strong>${result.correctAnswers}/${result.totalQuestions}题</p>
          <p><strong>AI反馈：</strong></p>
          <div style="background: #f5f5f5; padding: 10px; border-radius: 4px; margin-top: 10px;">
            ${result.aiFeedback.replace(/\n/g, '<br>')}
          </div>
        </div>`,
        '批阅结果',
        { 
          type: 'success', 
          dangerouslyUseHTMLString: true,
          confirmButtonText: '查看详细结果'
        }
      )
      
      // 显示详细结果
      showResult.value = true
      
    } else {
      // 检查是否是重复提交错误
      if (response.data.message && response.data.message.includes('已经提交过')) {
        ElMessage.error('您已经提交过此考试，不能重复提交')
        // 跳转到结果页面或返回考试列表
        showResult.value = true
      } else {
        ElMessage.error(response.data.message || '提交失败')
      }
    }
    
  }catch(e){ 
    console.error('提交考试失败:', e)
    ElMessage.error('提交失败: ' + (e.response?.data?.message || e.message))
  }
}

onMounted(()=>{
  openWebcam()
  loadExam()
  // 启动倒计时心跳
  tickTimer = setInterval(() => {
    nowTs.value = Date.now()
    if (nowTs.value >= endAt.value) {
      clearInterval(tickTimer)
      tickTimer = null
      // 时间到自动提交
      submitExam(true)
    }
  }, 1000)
})

onBeforeUnmount(()=>{
  const stream = videoRef.value?.srcObject
  stream?.getTracks()?.forEach(t=>t.stop())
  if (tickTimer) {
    clearInterval(tickTimer)
    tickTimer = null
  }
})
</script>

<style scoped>
.take-exam { display:flex; gap:16px; padding:16px; }
.left-panel { width:280px; display:flex; flex-direction:column; gap:16px }
.timer-card .time { color:#f56c6c; font-size:20px; font-weight:700; margin:8px 0 }
.sheet-title { font-weight:700; margin-bottom:8px }
.sheet-grid { display:flex; gap:8px; flex-wrap:wrap }
.paper-panel { flex:1; position:relative }
.webcam-box { position:fixed; right:24px; top:24px; width:220px; height:160px; background:#000; border-radius:8px; overflow:hidden; z-index:10 }
.webcam-box video { width:100%; height:100%; object-fit:cover }
.questions-container { background: white; border-radius: 8px; padding: 20px; }
.question-item { padding: 20px 0; border-bottom: 1px solid #f0f0f0; }
.question-item:last-child { border-bottom: none; }
.q-title { 
  font-weight:600; 
  margin-bottom:8px; 
  display: flex; 
  justify-content: space-between; 
  align-items: center; 
}
.question-score {
  font-size: 14px;
  font-weight: bold;
  padding: 4px 8px;
  border-radius: 4px;
  color: white;
}
.score-pass {
  background-color: #67c23a;
}
.score-fail {
  background-color: #f56c6c;
}
.ai-feedback {
  margin: 10px 0;
  padding: 8px;
  background-color: #f8f9fa;
  border-radius: 4px;
  border-left: 3px solid #409eff;
}
.button-group {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 15px;
}
.choice-block { text-align:left }
.choice-group { display:flex; flex-direction:column; gap:8px; align-items:flex-start }
.choice-item { margin:0; display:flex; align-items:flex-start }
:deep(.el-radio) { margin:0 }
</style>


