<template>
  <section class="create-homework">
    <!-- 顶部返回按钮 -->
    <div class="top-bar-only-button">
      <el-button type="primary" @click="goBack" class="back-button">
        <el-icon style="margin-right: 4px"><ArrowLeft /></el-icon>
        返回
      </el-button>
    </div>

    <div class="top-bar">
      <h2 class="form-title">{{ isEditing ? '编辑题目' : '新建题目' }}</h2>
    </div>

    <el-form @submit.prevent="submitHomework" label-width="100px">
      <!-- 作业题目 -->
      <el-form-item label="题目内容">
        <el-input v-model="form.question" />
      </el-form-item>

      <!-- 横排两个字段：题目学科 & 作业类型 -->
      <div class="horizontal-form">
        <!-- 从后端加载课程 -->
        <el-form-item label="题目学科" class="half-width">
          <el-select v-model="form.courseId" placeholder="请选择学科" style="width: 100%;">
            <el-option
              v-for="course in courses"
              :key="course.id"
              :label="course.courseName"
              :value="course.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="作业类型" class="half-width">
          <el-select v-model="form.type" placeholder="请选择类型" style="width: 100%;">
            <el-option label="选择题" value="choice" />
            <el-option label="简答题" value="short_answer" />
            <el-option label="编程题" value="programming" />
          </el-select>
        </el-form-item>
      </div>

      <el-form-item label="知识点">
        <el-input v-model="form.knowledgePoint" />
      </el-form-item>

      <!-- 正确答案 -->
      <el-form-item label="正确答案">
        <el-input v-model="form.answer" />
      </el-form-item>

      <!-- 提交按钮 -->
      <el-form-item>
        <el-button type="primary" @click="submitHomework">{{ isEditing ? '保存修改' : '提交' }}</el-button>
      </el-form-item>
    </el-form>
  </section>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft } from '@element-plus/icons-vue'
import axios from 'axios'

const router = useRouter()
const route = useRoute()

const isEditing = ref(false)
const form = reactive({
  id: null,
  type: '',
  question: '',
  answer: '',
  knowledgePoint: '',
  courseId: null,
})

const courses = ref([])

// ✅ 获取题目详情（编辑时调用）
const fetchQuestionDetail = async (id) => {
  try {
    const res = await axios.get('/api/xiaozhi/teacher/question/get', {
      params: { id },
    })
    if (res.data.code === 200 && res.data.data) {
      const data = res.data.data
      form.id = data.id
      form.type = data.type
      form.question = data.content
      form.answer = data.answer
      form.knowledgePoint = data.knowledgePoint
      form.courseId = data.courseId
      isEditing.value = true
    } else {
      ElMessage.error('❌ 题目详情获取失败：' + res.data.message)
    }
  } catch (err) {
    ElMessage.error('❌ 请求异常：' + err.message)
  }
}

// ✅ 获取课程列表
const fetchCourses = async () => {
  try {
    const res = await axios.get('/api/xiaozhi/teacher/courses')
    if (res.data.code === 200) {
      courses.value = res.data.data
    } else {
      ElMessage.error('❌ 获取课程失败：' + res.data.message)
    }
  } catch (err) {
    ElMessage.error('❌ 获取课程异常：' + err.message)
  }
}

// ✅ 表单提交（新增或编辑）
const submitHomework = async () => {
  if ( !form.type || !form.courseId || !form.question || !form.answer) {
    ElMessage.error('请填写完整题目信息')
    return
  }

  const questionData = {
    id: form.id,
    title: form.title,
    type: form.type,
    content: form.question,
    answer: form.answer,
    courseId: form.courseId,
    knowledgePoint: form.knowledgePoint,
    createdBy: route.query.teacherId || 2,
  }

  try {
    const res = isEditing.value
      ? await axios.put('/api/xiaozhi/teacher/question/update', questionData)
      : await axios.post('/api/xiaozhi/teacher/question/create', questionData)

    if (res.data.code === 200) {
      ElMessage.success(isEditing.value ? '✅ 题目修改成功' : '✅ 题目创建成功')
      router.push('/teacher_school/homework')
    } else {
      ElMessage.error('❌ 操作失败：' + res.data.message)
    }
  } catch (err) {
    ElMessage.error('❌ 请求异常：' + err.message)
  }
}

// ✅ 返回按钮
const goBack = () => {
  router.push('/teacher_school/homework')
}

// ✅ 页面加载逻辑
onMounted(async () => {
  await fetchCourses()

  const editId = route.query.editId
  if (editId) {
    await fetchQuestionDetail(editId)
  }
})
</script>


<style scoped>
.create-homework {
  flex: 1;
  padding: 1rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
  margin: 1rem;
  box-sizing: border-box;
}
.top-bar-only-button {
  margin-bottom: 1.5rem;
}

.back-button {
  font-weight: 500;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background-color: #f5f7fa;
  border: 1px solid #dcdfe6;
  color: #409EFF;
  transition: all 0.3s ease;
}

.back-button:hover {
  background-color: #ecf5ff;
  border-color: #b3d8ff;
}


.top-bar {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.form-title {
  font-size: 1.6rem;
  font-weight: 600;
  margin: 0;
}

.horizontal-form {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 1rem;
}

.half-width {
  flex: 1;
}
</style>