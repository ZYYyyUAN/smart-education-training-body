<template>
  <div class="auto-exam-preview">
    <el-page-header @back="goBack" content="试卷预览">
      <template #icon><el-icon><ArrowLeft /></el-icon></template>
    </el-page-header>

    <el-card v-if="exam" class="preview-card" shadow="never">
      <div class="exam-info">
        <h2>{{ exam.examTitle }}</h2>
        <p>{{ exam.examDescription }}</p>
        <div class="exam-meta">
          <el-tag type="info">总题数: {{ exam.totalQuestions }}</el-tag>
          <el-tag type="warning">考试时长: {{ exam.timeLimitMinutes }}分钟</el-tag>
          <el-tag :type="getStatusType(exam.status)">{{ getStatusText(exam.status) }}</el-tag>
          <div class="actions">
            <el-button type="success" size="small" @click="publishExam" :loading="publishing" v-if="!exam.id">发布试卷</el-button>
            <el-button type="success" size="small" @click="publish" :loading="publishing" v-if="exam.id">发布考试</el-button>
            <el-button size="small" @click="openAddDialog">添加题目</el-button>
          </div>
        </div>
      </div>

      <div class="questions-list">
        <h4>📝 题目列表</h4>
        <div v-if="questions.length" class="questions">
          <div v-for="(q, i) in questions" :key="q.questionId || q.id" class="question-item">
            <div class="question-header">
              <div class="question-number">
                <span class="number">{{ i + 1 }}</span>
                <span class="type">{{ getQuestionTypeName(q.type) }}</span>
              </div>
              <div class="question-meta">
                <el-tag size="small" :type="getDifficultyType(q.difficultyLevel)">难度: {{ getDifficultyText(q.difficultyLevel) }}</el-tag>
                <el-tag size="small" type="warning">预计: {{ q.estimatedTimeMinutes }}分钟</el-tag>
                <div class="q-actions">
                  <el-button link type="danger" @click="removeQuestion(q)">删除</el-button>
                  <el-button link type="primary" @click="replaceQuestion(q)">更换</el-button>
                </div>
              </div>
            </div>
            <div class="question-content" v-html="format(q.content)"></div>
            <div class="question-answer" v-if="q.answer">
              <strong>答案：</strong>
              <span>{{ q.answer }}</span>
            </div>
          </div>
        </div>
        <el-empty v-else description="暂无题目" />
      </div>
    </el-card>

    <el-dialog v-model="addDialogVisible" title="添加题目" width="520px">
      <el-input v-model="addRequirements" type="textarea" :rows="4" placeholder="描述想添加的题目要求，如题型/难度/知识点..." />
      <template #footer>
        <el-button @click="addDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="adjusting" @click="addQuestion">添加</el-button>
      </template>
    </el-dialog>

    <!-- 发布试卷对话框 -->
    <el-dialog v-model="publishDialogVisible" title="发布试卷" width="500px">
      <el-form :model="publishForm" label-width="100px">
        <el-form-item label="试卷标题" required>
          <el-input v-model="publishForm.examTitle" placeholder="请输入试卷标题" />
        </el-form-item>
        <el-form-item label="试卷描述">
          <el-input v-model="publishForm.examDescription" type="textarea" :rows="3" placeholder="请输入试卷描述" />
        </el-form-item>
        <el-form-item label="考试时长" required>
          <el-input-number v-model="publishForm.timeLimitMinutes" :min="1" :max="300" placeholder="分钟" />
          <span style="margin-left: 10px; color: #666;">分钟</span>
        </el-form-item>
        <el-form-item label="截止日期" required>
          <el-date-picker
            v-model="publishForm.deadline"
            type="datetime"
            placeholder="选择截止日期"
            format="YYYY-MM-DD HH:mm"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="publishDialogVisible = false">取消</el-button>
        <el-button type="success" @click="confirmPublish" :loading="publishing">发布试卷</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft } from '@element-plus/icons-vue'
import { autoExamAPI } from '@/api/autoExam'
import { ElMessage, ElMessageBox } from 'element-plus'
import axios from 'axios'

const route = useRoute()
const router = useRouter()
const examId = Number(route.query.examId)

const exam = ref(null)
const questions = ref([])
const publishing = ref(false)
const saving = ref(false)
const adjusting = ref(false)
const addDialogVisible = ref(false)
const addRequirements = ref('')
const publishDialogVisible = ref(false)
const publishForm = ref({
  examTitle: '',
  examDescription: '',
  timeLimitMinutes: 120,
  deadline: ''
})

const goBack = () => router.back()

const getQuestionTypeName = (type) => ({ choice:'选择题', short_answer:'简答题', programming:'编程题' }[type] || type)
const getStatusType = (s) => ({ draft:'info', generated:'warning', reviewed:'primary', published:'success', archived:'info' }[s] || 'info')
const getStatusText = (s) => ({ draft:'草稿', generated:'已生成', reviewed:'已审核', published:'已发布', archived:'已归档' }[s] || s)
const getDifficultyText = (lv) => typeof lv === 'number' ? ({1:'简单',2:'中等',3:'困难',4:'较难',5:'很难'}[lv]||'未知') : ({easy:'简单',medium:'中等',hard:'困难'}[lv]||'未知')
const getDifficultyType = (lv) => typeof lv === 'number' ? ({1:'success',2:'warning',3:'danger',4:'danger',5:'danger'}[lv]||'info') : ({easy:'success',medium:'warning',hard:'danger'}[lv]||'info')
const format = (t) => String(t||'').replace(/\n/g,'<br>')

onMounted(async () => {
  // 检查是否是预览模式（从生成页面跳转过来）
  if (route.query.preview === 'true' && route.query.examData) {
    try {
      const examData = JSON.parse(decodeURIComponent(route.query.examData))
      loadPreviewData(examData)
    } catch (e) {
      ElMessage.error('预览数据解析失败')
      return
    }
  } else if (examId) {
    // 正常的预览模式（从已保存的试卷）
    const res = await autoExamAPI.previewExam(examId)
    const data = res?.data?.data
    if (data) {
      loadPreviewData(data)
    }
  }
})

const loadQuestionDetails = async (questionSelections) => {
  try {
    console.log('开始加载题目详情，questionSelections:', questionSelections)
    // 批量获取题目详情
    const questionIds = questionSelections.map(qs => qs.questionId)
    console.log('题目ID列表:', questionIds)
    
    const response = await axios.get('/api/xiaozhi/teacher/questions/batch', {
      params: { ids: questionIds.join(',') }
    })
    
    console.log('API响应:', response.data)
    
    if (response.data.code === 200) {
      const questionDetails = response.data.data
      console.log('获取到的题目详情:', questionDetails)
      questions.value = questionSelections.map((qs, index) => {
        const detail = questionDetails.find(q => q.id === qs.questionId)
        console.log(`题目 ${index + 1} 详情:`, detail)
        return {
          id: qs.questionId,
          questionId: qs.questionId,
          type: detail ? detail.type : 'choice',
          content: detail ? detail.content : `题目 ${index + 1}`,
          answer: detail ? detail.answer : '',
          knowledgePoint: qs.knowledgePoint,
          difficultyLevel: qs.difficulty,
          estimatedTimeMinutes: qs.estimatedTime,
          aiSelectionReason: qs.aiSelectionReason
        }
      })
      console.log('最终题目列表:', questions.value)
    } else {
      console.error('API返回错误:', response.data)
      // 如果批量获取失败，使用临时数据
      questions.value = questionSelections.map((qs, index) => ({
        id: qs.questionId,
        questionId: qs.questionId,
        type: 'choice',
        content: `题目 ${index + 1}`,
        answer: '',
        knowledgePoint: qs.knowledgePoint,
        difficultyLevel: qs.difficulty,
        estimatedTimeMinutes: qs.estimatedTime,
        aiSelectionReason: qs.aiSelectionReason
      }))
    }
  } catch (error) {
    console.error('获取题目详情失败:', error)
    // 使用临时数据
    questions.value = questionSelections.map((qs, index) => ({
      id: qs.questionId,
      questionId: qs.questionId,
      type: 'choice',
      content: `题目 ${index + 1}`,
      answer: '',
      knowledgePoint: qs.knowledgePoint,
      difficultyLevel: qs.difficulty,
      estimatedTimeMinutes: qs.estimatedTime,
      aiSelectionReason: qs.aiSelectionReason
    }))
  }
}

const loadPreviewData = (data) => {
  console.log('loadPreviewData 接收到的数据:', data)
  
  // 预览响应包含试卷基本信息与题目列表
  exam.value = {
    id: data.id,
    examId: data.examId || data.id,
    examTitle: data.examTitle,
    examDescription: data.examDescription,
    totalQuestions: data.totalQuestions || (data.questionSelection ? data.questionSelection.length : 0),
    timeLimitMinutes: data.timeLimitMinutes || 120,
    qualityScore: data.qualityScore,
    status: data.status,
    createdAt: data.createdAt
  }
  
  console.log('exam.value 设置完成:', exam.value)
  
  // 如果是预览数据，需要从questionSelection构建questions
  if (data.questionSelection && data.questionSelection.length > 0) {
    console.log('开始调用 loadQuestionDetails，questionSelection:', data.questionSelection)
    // 需要调用API获取题目详情
    loadQuestionDetails(data.questionSelection)
  } else {
    console.log('没有 questionSelection，使用默认数据')
    questions.value = data.questions || []
  }
}

const refresh = async () => {
  const res = await autoExamAPI.previewExam(examId)
  const data = res?.data?.data
  if (data) {
    exam.value.totalQuestions = data.totalQuestions
    questions.value = data.questions || []
  }
}

const publishExam = () => {
  if (!exam.value) return
  
  // 初始化表单数据
  publishForm.value = {
    examTitle: exam.value.examTitle || '',
    examDescription: exam.value.examDescription || '',
    timeLimitMinutes: exam.value.timeLimitMinutes || 120,
    deadline: ''
  }
  
  publishDialogVisible.value = true
}

const confirmPublish = async () => {
  if (!publishForm.value.examTitle.trim()) {
    ElMessage.error('请输入试卷标题')
    return
  }
  if (!publishForm.value.deadline) {
    ElMessage.error('请选择截止日期')
    return
  }
  
  try {
    await ElMessageBox.confirm('确定发布该试卷吗？发布后学生可参加考试。', '确认发布', { type: 'warning' })
  } catch { return }
  
  publishing.value = true
  try {
    // 构建发布数据（只包含AutoGeneratedExam实体中存在的字段）
    const publishData = {
      id: exam.value.id,
      configId: exam.value.configId || 1,
      examTitle: publishForm.value.examTitle,
      examDescription: publishForm.value.examDescription,
      generationStrategy: exam.value.generationStrategy || 'AI智能组卷',
      aiModelUsed: exam.value.aiModelUsed || 'qwen-plus',
      generationPrompt: exam.value.generationPrompt,
      generationMetadata: exam.value.generationMetadata,
      qualityScore: exam.value.qualityScore,
      status: 'generated',
      createdAt: exam.value.createdAt,
      reviewedAt: exam.value.reviewedAt,
      publishedAt: exam.value.publishedAt,
      createdBy: exam.value.createdBy,
      questionSelection: questions.value.map(q => ({
        questionId: q.questionId || q.id,
        reason: q.aiSelectionReason || '用户选择',
        difficulty: q.difficultyLevel,
        estimatedTime: q.estimatedTimeMinutes,
        knowledgePoint: q.knowledgePoint,
        aiSelectionReason: q.aiSelectionReason
      }))
    }
    
    // 从URL参数或store获取teacherId，默认为2
    const teacherId = Number(route.query.teacherId) || 2
    
    const res = await autoExamAPI.publishExamDirect(publishData, teacherId, publishForm.value.deadline)
    if (res?.data?.code === 200) {
      ElMessage.success('发布成功')
      publishDialogVisible.value = false
      // 跳转到考试总览页面
      router.push({ name: 'ExamDashboard' })
    } else {
      ElMessage.error(res?.data?.message || '发布失败')
    }
  } catch (e) {
    ElMessage.error(e?.response?.data?.message || e.message)
  } finally {
    publishing.value = false
  }
}

const publish = async () => {
  if (!examId) return
  try {
    await ElMessageBox.confirm('确定发布该试卷吗？发布后学生可参加考试。', '确认发布', { type: 'warning' })
  } catch { return }
  publishing.value = true
  try {
    // 从URL参数或store获取teacherId，默认为2
    const teacherId = route.query.teacherId || 2
    const res = await autoExamAPI.publishExam(examId, teacherId)
    if (res?.data?.code === 200) {
      exam.value.status = 'published'
      ElMessage.success('发布成功')
    } else {
      ElMessage.error(res?.data?.message || '发布失败')
    }
  } catch (e) {
    ElMessage.error(e?.response?.data?.message || e.message)
  } finally {
    publishing.value = false
  }
}

const removeQuestion = async (q) => {
  try {
    await ElMessageBox.confirm('确认删除该题？', '删除题目', { type: 'warning' })
  } catch { return }
  
  // 如果是预览模式（exam.id为null），直接从本地数组中移除
  if (!exam.value.id) {
    const index = questions.value.findIndex(question => 
      question.id === q.id || question.questionId === q.questionId
    )
    if (index > -1) {
      questions.value.splice(index, 1)
      exam.value.totalQuestions = questions.value.length
      ElMessage.success('已删除该题')
    }
    return
  }
  
  // 如果是已保存的试卷，调用API删除
  adjusting.value = true
  try {
    const qbId = q.questionBankId || q.questionId || q.id
    const res = await autoExamAPI.adjustExam(examId, 'remove', JSON.stringify({ questionId: qbId }))
    if (res?.data?.code === 200) {
      ElMessage.success('已删除该题')
      await refresh()
    } else {
      ElMessage.error(res?.data?.message || '操作失败')
    }
  } catch (e) {
    ElMessage.error(e?.response?.data?.message || e.message)
  } finally {
    adjusting.value = false
  }
}

const replaceQuestion = async (q) => {
  adjusting.value = true
  try {
    const res = await autoExamAPI.adjustExam(examId, 'replace', JSON.stringify({ questionId: q.id }))
    if (res?.data?.code === 200) {
      ElMessage.success('已更换该题')
      await refresh()
    } else {
      ElMessage.error(res?.data?.message || '操作失败')
    }
  } catch (e) {
    ElMessage.error(e?.response?.data?.message || e.message)
  } finally {
    adjusting.value = false
  }
}

const openAddDialog = () => { addDialogVisible.value = true }
const addQuestion = async () => {
  adjusting.value = true
  try {
    const res = await autoExamAPI.adjustExam(examId, 'add', addRequirements.value)
    if (res?.data?.code === 200) {
      ElMessage.success('已添加题目')
      addDialogVisible.value = false
      addRequirements.value = ''
      await refresh()
    } else {
      ElMessage.error(res?.data?.message || '操作失败')
    }
  } catch (e) {
    ElMessage.error(e?.response?.data?.message || e.message)
  } finally {
    adjusting.value = false
  }
}
</script>

<style scoped>
.auto-exam-preview { max-width: 1200px; margin: 0 auto; padding: 20px; }
.preview-card { border-radius: 12px; border: 1px solid #e5e7eb; }
.exam-info { margin-bottom: 20px; padding: 16px; background:#f8fafc; border-radius:8px; }
.exam-meta { display:flex; gap:12px; flex-wrap:wrap; align-items:center; }
.exam-meta .actions { margin-left:auto; display:flex; gap:8px; }
.questions { display:flex; flex-direction:column; gap:14px; }
.question-item { padding:16px; border:1px solid #e5e7eb; border-radius:8px; background:#fff; }
.question-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:8px; }
.question-number { display:flex; align-items:center; gap:12px; }
.number { width:32px; height:32px; border-radius:50%; background:#3b82f6; color:#fff; display:inline-flex; align-items:center; justify-content:center; font-weight:700; }
.question-content { margin:10px 0; }
.question-answer { margin-top:6px; color:#0f172a; }
.q-actions { display:flex; gap:8px; margin-left:8px; }
</style>


