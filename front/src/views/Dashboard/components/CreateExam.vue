<template>
  <el-card class="create-exam">
    <h2>{{ isEditing ? '编辑考试' : '创建考试' }}</h2>
    <el-form :model="form" label-width="100px">
      <el-form-item label="考试标题">
        <el-input v-model="form.title" />
      </el-form-item>
      <el-form-item label="考试科目">
        <el-select v-model="form.courseId" placeholder="请选择科目">
          <el-option v-for="c in courseOptions" :key="c.id" :label="c.courseName || c.name" :value="c.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="考试日期">
        <el-date-picker v-model="form.examDate" type="date" value-format="YYYY-MM-DD" format="YYYY-MM-DD" />
      </el-form-item>
      <el-form-item label="时长(分钟)">
        <el-input v-model.number="form.durationMinutes" type="number" />
      </el-form-item>
      <el-form-item label="选择题目">
        <el-button type="primary" @click="goToQuestionBank">从题库选择</el-button>
        <div style="margin-top:8px">
          <el-tag v-for="id in form.questionIds" :key="id" class="mr8">{{ id }}</el-tag>
        </div>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitExam">提交</el-button>
        <el-button @click="router.back()">返回</el-button>
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
const isEditing = ref(false)
const courseOptions = ref([])
const form = ref({ id:null, title:'', courseId:'', examDate:'', durationMinutes:60, questionIds:[], teacherId:2 })

const fetchCourses = async () => {
  const res = await axios.get('/api/xiaozhi/teacher/courses')
  if (res.data.code === 200) courseOptions.value = res.data.data
}

const goToQuestionBank = () => {
  localStorage.setItem('tempExamForm', JSON.stringify(form.value))
  router.push({ path: '/teacher_school/homework', query: { from: 'create-exam', courseId: form.value.courseId } })
}

const submitExam = async () => {
  if (!form.value.title || !form.value.courseId || !form.value.examDate) {
    ElMessage.error('请完整填写考试信息')
    return
  }
  const api = form.value.id ? '/api/xiaozhi/teacher/exam/update' : '/api/xiaozhi/teacher/exam/create'
  const method = form.value.id ? 'put' : 'post'
  const res = await axios[method](api, form.value)
  if (res.data.code === 200) {
    ElMessage.success('考试创建成功')
    localStorage.removeItem('tempExamForm')
    localStorage.removeItem('selectedQuestions')
    router.push('/teacher_school/exam-dashboard')
  }
}

onMounted(() => {
  fetchCourses()
  if (route.query.from === 'create-exam') {
    const saved = JSON.parse(localStorage.getItem('tempExamForm') || '{}')
    form.value = { ...form.value, ...saved }
    const selected = JSON.parse(localStorage.getItem('selectedQuestions') || '{}')
    if (selected?.questions?.length) {
      const ids = selected.questions.map(q => q.id)
      form.value.questionIds = Array.from(new Set([...(form.value.questionIds||[]), ...ids]))
      localStorage.removeItem('selectedQuestions')
    }
  }
  if (route.query.editExam) {
    try {
      const parsed = JSON.parse(decodeURIComponent(route.query.editExam))
      form.value = { ...form.value, ...parsed, examDate: parsed.examDate }
    } catch {}
  }
})
</script>

<style scoped>
.create-exam { flex:1; max-width:700px; margin:2rem auto; padding:1rem; }
.mr8 { margin-right:8px }
</style>


