<template>
  <section class="create-course">
    <div class="top-bar-only-button">
      <el-button type="primary" @click="goBack" class="back-button" plain>
        <el-icon style="margin-right: 4px"><ArrowLeft /></el-icon>
        返回
      </el-button>
    </div>

    <h2>{{ isEditing ? '修改课程' : '创建课程' }}</h2>

    <div class="form-layout">
      <!-- 左侧课程图片 -->
      <div class="course-image">
        <label class="section-label">课程图片</label>
      <el-upload
  class="upload-box"
  action="" 
  :auto-upload="false"
  :show-file-list="false"
  :on-change="handleImageChange"  
>
          <template v-if="!imageUrl">
            <span>+</span>
            <p>上传图片</p>
          </template>
          <template v-else>
            <img :src="imageUrl" class="preview-img" />
          </template>
        </el-upload>
      </div>

      <!-- 右侧表单表单区域 -->
      <div class="form-right">
        <div class="form-row">
          <div class="form-group flex-1">
            <label>课程名称<span class="required">*</span></label>
            <el-input placeholder="请输入课程名称" v-model="form.courseName" maxlength="30" />
          </div>
        </div>
        <div class="form-group">
          <label>教学目标</label>
          <el-input type="textarea" rows="2" placeholder="在此输入课程教学目标" v-model="form.teachingGoal" maxlength="120" />
        </div>

        <div class="form-group">
          <label>教学原则</label>
          <el-input type="textarea" rows="2" placeholder="输入课程教学重点" v-model="form.teachingPrinciple" maxlength="120" />
        </div>
      </div>
    </div>

    <div class="form-group">
      <label>课程背景</label>
      <el-input placeholder="请输入课程背景" v-model="form.courseBackground" />
    </div>

    <div class="form-group">
      <label>课程描述</label>
      <el-input type="textarea" rows="4" placeholder="请输入课程简介" v-model="form.description" maxlength="500" />
    </div>

    <el-button type="primary" @click="submitCourse" class="submit-btn">{{ isEditing ? '更新课程' : '提交课程' }}</el-button>

    <!-- 章节模块已按需求移除 -->
  </section>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { ArrowLeft } from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()

const isEditing = ref(false)
const courseId = route.query.courseId
const imageUrl = ref('')

const form = reactive({
  id: null,
  courseName: '',
  teachingGoal: '',
  teachingPrinciple: '',
  courseBackground: '',
  description: '',
  courseImage: '',
  createdAt: ''
})

const goBack = () => {
  router.push('/teacher_school/query')
}

const uploadedFile = ref(null)

const handleImageChange = async (file) => {
  uploadedFile.value = file.raw  // ✅ 这一步关键：后面要带这个文件上传

  // 预览用 URL
  imageUrl.value = URL.createObjectURL(file.raw)
}



// 提交课程
const submitCourse = async () => {
  if (!form.courseName.trim()) {
    ElMessage.error('请输入课程名称')
    return
  }

  try {
    if (isEditing.value) {
      // ✅ 编辑课程（PUT JSON）
      await axios.put('/api/xiaozhi/teacher/course/update', {
        ...form,
        teacherId: 2
      })
      ElMessage.success('课程更新成功')
    } else {
      // ✅ 新增课程（POST Multipart）
      const formData = new FormData()
      formData.append('courseName', form.courseName)
      formData.append('courseImageFile', uploadedFile.value)  // 🔁 见下面 handleImageChange
      formData.append('teachingGoal', form.teachingGoal)
      formData.append('teachingPrinciple', form.teachingPrinciple)
      formData.append('courseBackground', form.courseBackground)
      formData.append('courseDescription', form.description)
      formData.append('teacherId', 2)

      const res = await axios.post('/api/xiaozhi/teacher/createByAI', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })

      if (res.status === 200) {
        ElMessage.success('课程创建成功')
      } else {
        ElMessage.error('课程创建失败')
      }
    }

    router.push('/teacher_school/query')
  } catch (error) {
    console.error(error)
    ElMessage.error('保存失败')
  }
}



// 获取课程详情
const fetchCourseDetail = async () => {
  try {
    const { data } = await axios.get('/api/xiaozhi/teacher/course', {
      params: { id: courseId }
    })
    const course = data.data
    isEditing.value = true
    form.id = course.id
    form.courseName = course.courseName
    form.teachingGoal = course.teachingGoal
    form.teachingPrinciple = course.teachingPrinciple
    form.courseBackground = course.courseBackground
    form.description = course.description
    form.createdAt = course.createdAt
    form.courseImage = course.courseImage
    imageUrl.value = course.courseImage
  } catch (err) {
    ElMessage.error('加载课程失败')
  }
}

onMounted(() => {
  if (courseId) {
    isEditing.value = true
    fetchCourseDetail()
  } else {
    // 新建课程
    form.createdAt = new Date().toISOString().split('T')[0]
  }
})

</script>

<style scoped>
.create-course {
  flex: 1;
  padding: 2rem;
  background: white;
  border-radius: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}
.top-bar-only-button {
  margin-bottom: 1.5rem;
}

h2 {
  font-size: 1.5rem;
  margin-bottom: 1.5rem;
}

.form-layout {
  display: flex;
  gap: 2rem;
  margin-bottom: 1.5rem;
}

.course-image {
  width: 180px;
}

.upload-box {
  width: 100%;
  height: 180px;
  background: #f9fafb;
  border: 2px dashed #cbd5e1;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  color: #64748b;
  cursor: pointer;
  font-size: 1.5rem;
  overflow: hidden;
}

.preview-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.form-right {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.form-row {
  display: flex;
  gap: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.flex-1 {
  flex: 1;
}

label {
  font-weight: 500;
}
.required {
  color: red;
}

.chapter-box {
  margin-top: 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.submit-btn {
  margin-top: 1.5rem;
  width: 150px;
}

.add-btn {
  border-radius: 8px;
}
</style>
    