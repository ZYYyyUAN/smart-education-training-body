<template>
  <el-card class="create-homework">
    <h2>{{ isEditing ? '编辑作业' : '创建作业' }}</h2>
    <el-form :model="form" label-width="100px" @submit.prevent>
      <el-form-item label="作业标题">
        <el-input v-model="form.title" />
      </el-form-item>
<el-form-item label="作业科目">
  <el-select v-model="form.courseId" placeholder="请选择科目">
    <el-option
      v-for="course in courseOptions"
      :key="course.id"
      :label="course.courseName || course.name"
      :value="course.id"
    />
  </el-select>
</el-form-item>
      <el-form-item label="作业描述">
        <el-input type="textarea" v-model="form.description" placeholder="可选填写" />
      </el-form-item>

      <el-form-item label="截止时间">
        <el-date-picker v-model="form.deadline" type="date" value-format="YYYY-MM-DD" format="YYYY-MM-DD" />
      </el-form-item>

      <el-form-item label="选择题目" required>
        <div>
          <div style="margin-bottom: 10px;">
            <el-tag
              v-for="id in form.questionIds"
              :key="id"
              style="margin-right: 8px;"
              type="info"
            >
              {{ id }}
            </el-tag>
            <span v-if="!form.questionIds || form.questionIds.length === 0" style="color: #909399; font-size: 12px;">
              请从题库选择至少一道题目
            </span>
          </div>
          <el-button type="primary" @click="goToQuestionBank">从题库选择</el-button>
        </div>
      </el-form-item>

      <el-form-item>
        <el-button type="primary" @click="submitHomework">提交</el-button>
        <el-button @click="resetForm" style="margin-left: 12px;">重置</el-button>
        <el-button @click="goBack" style="margin-left: 12px;">返回</el-button>
      </el-form-item>
    </el-form>
  </el-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import axios from 'axios'
import { ElMessage } from 'element-plus'

const router = useRouter()
const route = useRoute()
const courseOptions = ref([])

const isEditing = ref(false)

const form = ref({
  id: null,
  title: '',
  description: '',
  deadline: '',
  questionIds: [],
  courseId: '',
  teacherId: ''
})
const goBack = () => {
  // 清空临时保存的表单数据
  localStorage.removeItem('tempHomeworkForm')
  localStorage.removeItem('selectedQuestions')
  
  // 如果你总是从某个固定页面来，比如 dashboard，就写死：
  router.push('/teacher_school/homework-dashboard')

  // 或者更灵活一点：返回上一页
  // router.back()
}

// 重置表单
const resetForm = () => {
  form.value = {
    id: null,
    title: '',
    description: '',
    deadline: '',
    questionIds: [],
    courseId: route.query.courseId || '',
    teacherId: route.query.teacherId || 2
  }
  // 清空临时保存的数据
  localStorage.removeItem('tempHomeworkForm')
  localStorage.removeItem('selectedQuestions')
  ElMessage.success('表单已重置')
}

// 跳转到题库页面
const goToQuestionBank = () => {
  localStorage.setItem('tempHomeworkForm', JSON.stringify(form.value))
  router.push({
    path: '/teacher_school/homework',
    query: {
      from: 'create-homework',
      courseId: form.value.courseId // ✅ 保留 courseId，而不是 subject
    }
  })
}

const fetchCourses = async () => {
  try {
    const res = await axios.get('/api/xiaozhi/teacher/courses')
    if (res.data.code === 200) {
      courseOptions.value = res.data.data
    } else {
      ElMessage.error('获取课程失败：' + res.data.message)
    }
  } catch (err) {
    ElMessage.error('获取课程异常：' + err.message)
  }
}
// 提交作业数据到后端
const submitHomework = async () => {
  if (!form.value.title || !form.value.courseId || !form.value.deadline) {
    ElMessage.error('请填写完整作业信息')
    return
  }
  
  // 检查是否选择了题目
  if (!form.value.questionIds || form.value.questionIds.length === 0) {
    ElMessage.error('请至少选择一道题目')
    return
  }

  const payload = {
    id: form.value.id || Date.now(),
    title: form.value.title,
    description: form.value.description,
    questionIds: form.value.questionIds,
    courseId: form.value.courseId,
    teacherId: form.value.teacherId || route.query.teacherId || 2,
    dueDate: form.value.deadline // 自动转换为 ISO 格式，Spring Boot 会识别为 LocalDate
  }

  try {
    const res = await axios.post('/api/xiaozhi/teacher/create-assignment', payload)

    if (res.data.code === 200) {
      ElMessage.success('✅ 作业创建成功')
      // 清空临时保存的表单数据
      localStorage.removeItem('tempHomeworkForm')
      localStorage.removeItem('selectedQuestions')
      router.push('/teacher_school/homework-dashboard')
    } else {
      ElMessage.error('❌ 创建失败：' + res.data.message)
    }
  } catch (error) {
    ElMessage.error('❌ 提交失败：' + error.message)
  }
}

onMounted(async () => {
  await fetchCourses() // ⚠️ 等待课程加载完成

  // 优先从本地恢复草稿；无草稿时按默认值初始化
  const savedForm = JSON.parse(localStorage.getItem('tempHomeworkForm') || '{}')
  if (savedForm && Object.keys(savedForm).length > 0) {
    form.value = { ...form.value, ...savedForm }
  } else {
    form.value = {
      id: null,
      title: '',
      description: '',
      deadline: '',
      questionIds: [],
      courseId: route.query.courseId || '',
      teacherId: route.query.teacherId || 2
    }
  }

  // 合并从题库带回的题目（若有）
  const selected = JSON.parse(localStorage.getItem('selectedQuestions') || '{}')
  if (selected && selected.questions?.length > 0) {
    const existingIds = new Set(form.value.questionIds)
    selected.questions.forEach(q => {
      if (!existingIds.has(q.id)) {
        form.value.questionIds.push(q.id)
      }
    })
    localStorage.removeItem('selectedQuestions')
  }

  // 处理编辑模式
  if (route.query.editHomework) {
    try {
      const parsed = JSON.parse(decodeURIComponent(route.query.editHomework))
      form.value = {
        ...form.value,
        ...parsed,
        deadline: parsed.dueDate || '',
        questionIds: parsed.questionIds || form.value.questionIds,
        courseId: parsed.courseId || route.query.courseId || '',
        teacherId: parsed.teacherId || route.query.teacherId || ''
      }
      isEditing.value = true

      // 进一步拉取作业详情以获取题目列表
      if (parsed.id) {
        try {
          const detailRes = await axios.get('/api/xiaozhi/teacher/detail', {
            params: { assignmentId: parsed.id }
          })
          if (detailRes.data.code === 200) {
            const qs = detailRes.data.data?.questions || []
            form.value.questionIds = qs.map(q => q.id)
          }
        } catch (err) {
          console.error('加载作业详情失败', err)
        }
      }
    } catch (e) {
      console.error('解析作业失败', e)
    }
  }
})

</script>

<style scoped>
.create-homework {
  flex: 1;
  padding: 1rem;
  max-width: 700px;
  margin: 2rem auto;
  box-sizing: border-box;
}
</style>
