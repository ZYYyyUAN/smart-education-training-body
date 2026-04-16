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
    <el-card class="course-header" shadow="hover">
      <el-row>
        <el-col :span="6">
          <img :src="course.image" alt="课程封面" class="course-image" />
        </el-col>
        <el-col :span="18">
          <h2>📘 智能教学设计 — {{ course.title }}</h2>
        </el-col>
      </el-row>
    </el-card>

    <!-- 上传教学大纲 -->
    <el-card class="upload-card" shadow="hover">
      <h3>上传教学大纲并生成教学内容</h3>
      <el-upload
  :http-request="customUpload"
  :limit="1"
  :auto-upload="true"
  accept=".pdf,.doc,.docx"
>
  <el-button type="primary">点击上传教学大纲</el-button>
</el-upload>
 
    </el-card>
<!-- 暂无生成内容提示 -->
<el-empty
  v-if="!aiRawText && !loadingContent"
  description="暂未生成教学内容，请上传教学大纲文件进行生成"
  style="margin-bottom: 2rem"
/>
<!-- AI 生成教学内容（流式输出） -->
<el-card class="ai-content" shadow="hover" v-if="aiRawText || loadingContent">
  <div class="content-header">
    <h3>🧠 AI教学内容生成</h3>
      <div>
    <el-button type="success" @click="generateExam" :disabled="loadingContent || !aiRawText">
      生成考核题目及参考答案
    </el-button>
    <el-button type="danger" @click="regenerateContent" :disabled="loadingContent">
      重新生成
    </el-button>
  </div>
  </div>

  <div class="stream-content">
    <pre>{{ aiRawText }}</pre>
  </div>
</el-card>

    <!-- 考核题目展示区 -->
<el-card class="exam-card" shadow="hover" v-if="examList.length">
  <h3>📝 AI推荐考核题目</h3>

  <div style="margin-bottom: 1rem; display: flex; gap: 1rem;">
    <el-button type="warning" @click="generateExam">换一批</el-button>
    <el-button type="primary" @click="saveQuestions">保存题目</el-button>
  </div>

   <div class="exam-scroll">
    <el-collapse accordion>
      <el-collapse-item
        v-for="(item, index) in examList"
        :key="index"
        :title="`【${item.type === 'choice' ? '选择题' : item.type === 'short_answer' ? '简答题' : '编程题'}】${item.knowledgePoint}`"
      >
        <p><strong>题干：</strong> {{ item.content }}</p>
        <p><strong>答案：</strong> {{ item.answer }}</p>
      </el-collapse-item>
    </el-collapse>
  </div>
</el-card>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import axios from 'axios'
import { reactive } from 'vue'  
import { useRoute } from 'vue-router'
const examList = ref([])
const route = useRoute()
import { ElLoading } from 'element-plus'
import { ArrowLeft } from '@element-plus/icons-vue'
const lastUploadedFile = ref(null);
import { useRouter } from 'vue-router'

const router = useRouter()

const syllabusUploaded = ref(false)
const loadingContent = ref(false)
const aiContent = ref(null)
const exam = ref(null)
// 从路由 query 中获取课程信息
const course = reactive({
    id: route.query.courseId,
  title: route.query.title || '',
  subtitle: route.query.subtitle || '',
  image: route.query.image || ''
})

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


function handleUploadSuccess(response) {
  ElMessage.success('教学大纲上传成功')
  syllabusUploaded.value = true
}
const aiRawText = ref('')

async function customUpload({ file }) {
  syllabusUploaded.value = false
  loadingContent.value = true
  aiRawText.value = ''
   lastUploadedFile.value = file;  // 保存上传的文件，方便重新生成时调用

  try {
    const formData = new FormData()
    formData.append('file', file)

    const response = await fetch('/api/xiaozhi/teacher/generate-plan-by-file', {
      method: 'POST',
      body: formData
    })

    const reader = response.body.getReader()
    const decoder = new TextDecoder('utf-8')
    let done = false

    while (!done) {
      const { value, done: readerDone } = await reader.read()
      if (value) {
        aiRawText.value += decoder.decode(value, { stream: true })
      }
      done = readerDone
    }

    ElMessage.success('✅ 教学内容生成成功')
    syllabusUploaded.value = true
  } catch (err) {
    ElMessage.error('❌ 上传或生成教学内容失败：' + err.message)
  } finally {
    loadingContent.value = false
  }
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
  if (!aiRawText.value || !course.title) {
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
      objective: aiRawText.value,
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

</script>

<style scoped>
.design-panel {
  padding: 2rem;
  width: 1000px;
  margin: 0 auto;
}

.course-header {
  margin-bottom: 2rem;
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
  font-family: "Courier New", monospace;
  color: #1f2937;
}
.stream-content {
  background-color: #f4f4f5;
  padding: 1rem;
  border-radius: 8px;
  height: 300px;        /* 固定高度，比如300px */
  overflow-y: auto;     /* 超出时显示垂直滚动条 */
  white-space: pre-wrap;
  font-family: "Courier New", monospace;
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

</style>