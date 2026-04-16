<template>
  <div class="file-preview-container">
    <div class="preview-header">
      <el-button @click="closePreview">返回</el-button>
      <h2>{{ currentFile ? currentFile.fileName : '' }}</h2>
    </div>
    
    <div class="preview-content">
      <div class="preview-area">
        <iframe
          v-if="currentFile && isPdf(currentFile.fileUrl)"
          :src="currentFile.fileUrl"
          frameborder="0"
          width="100%"
          height="100%"
        ></iframe>
        <iframe
          v-else-if="currentFile"
          :src="getOfficePreviewUrl(currentFile.fileUrl)"
          frameborder="0"
          width="100%"
          height="100%"
        ></iframe>
      </div>
      
      <div class="file-sidebar">
        <h3>附件列表</h3>
        <div 
          v-for="file in files" 
          :key="file.id || file.fileName"
          class="sidebar-item"
          :class="{ active: file.fileUrl === currentFile?.fileUrl }"
          @click="switchFile(file)"
        >
          <span class="file-icon">{{ getFileIconEmoji(file.fileName) }}</span>
          {{ file.fileName }}
        </div>
      </div>
    </div>
    
    <div class="preview-footer">
      <el-button type="primary" @click="download(currentFile.fileUrl)">
        下载当前文件
      </el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'

const router = useRouter()
const route = useRoute()

const files = ref([])
const currentFile = ref(null)

const isPdf = (url) => url.toLowerCase().endsWith('.pdf')

const getOfficePreviewUrl = (url) =>
  `https://view.officeapps.live.com/op/view.aspx?src=${encodeURIComponent(url)}`

const getFileIconEmoji = (filename) => {
  const ext = filename.split('.').pop().toLowerCase()
  if (['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'].includes(ext)) return '🖼️'
  if (['mp4', 'avi', 'mov', 'mkv', 'webm'].includes(ext)) return '🎞️'
  if (['pdf'].includes(ext)) return '📄'
  if (['doc', 'docx'].includes(ext)) return '📃'
  if (['ppt', 'pptx'].includes(ext)) return '📊'
  if (['xls', 'xlsx'].includes(ext)) return '📈'
  if (['zip', 'rar', '7z'].includes(ext)) return '🗜️'
  if (['txt', 'md', 'csv', 'log'].includes(ext)) return '📑'
  if (['exe', 'msi', 'bat', 'sh'].includes(ext)) return '💻'
  if (['mp3', 'wav', 'ogg'].includes(ext)) return '🎵'
  return '📎'
}

const switchFile = (file) => {
  currentFile.value = file
  router.replace({ 
    name: 'filePreview', 
    params: { 
      questionId: route.params.questionId,
      fileId: file.id || 0
    }, 
    query: { 
      fileName: file.fileName,
      fileUrl: file.fileUrl,
      courseId: route.query.courseId,
      activeNav: route.query.activeNav
    }
  })
}

const closePreview = () => {
  // 从当前路由的query参数中获取课程ID，如果没有则使用默认值
  const courseId = route.query.courseId || '102'
  // 从当前路由的query参数中获取之前选中的模块，如果没有则使用默认值
  const activeNav = route.query.activeNav || 'learning-resources'
  router.push({
    name: 'course',
    query: { 
      id: courseId,
      activeNav: activeNav
    }
  })
}

const download = (url) => {
  if (url) {
    window.open(url, '_blank')
  } else {
    ElMessage.error('文件路径无效')
  }
}

onMounted(async () => {
  const questionId = route.params.questionId
  const fileName = route.query.fileName
  const fileUrl = route.query.fileUrl

  if (!questionId) {
    ElMessage.error('参数错误')
    router.back()
    return
  }

  try {
    const response = await axios.get('/api/questions/answers', {
      params: { questionId: questionId }
    })
    
    if (response.data.code === 200) {
      const questionData = response.data.data
      files.value = questionData.attachments || []

      if (fileName && fileUrl) {
        const found = files.value.find((f) => 
          f.fileName === fileName && (f.fileUrl === fileUrl || f.filePath === fileUrl)
        )
        currentFile.value = found || files.value[0] || null
      } else {
        currentFile.value = files.value[0] || null
      }

      if (!currentFile.value) {
        ElMessage.error('未找到文件')
        router.back()
      }
    } else {
      ElMessage.error('获取问题详情失败')
      router.back()
    }
  } catch (err) {
    console.error('获取文件列表失败:', err)
    ElMessage.error('获取文件列表失败')
    router.back()
  }
})
</script>

<style scoped>
.file-preview-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background-color: #fafafa;
  color: #333;
}

.preview-header {
  display: flex;
  align-items: center;
  padding: 12px 24px;
  border-bottom: 1px solid #ddd;
  background: #fff;
  box-shadow: 0 1px 4px rgb(0 0 0 / 0.1);
  font-weight: 600;
  font-size: 1.2rem;
  gap: 20px;
}

.preview-content {
  display: flex;
  flex: 1;
  overflow: hidden;
  background: #fff;
  padding: 20px 24px;
  gap: 20px;
}

.preview-area {
  flex: 1;
  max-width: calc(100% - 250px);
  min-width: 400px;
  border: 1px solid #ddd;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgb(0 0 0 / 0.05);
}

.preview-area iframe {
  border-radius: 8px;
  width: 100%;
  height: 100%;
  display: block;
}

.file-sidebar {
  width: 400px;
  border-left: 1px solid #eee;
  padding-left: 16px;
  overflow-y: auto;
  background: #f7f9fc;
  border-radius: 8px;
  box-shadow: inset 0 0 10px rgb(0 0 0 / 0.03);
}

.file-sidebar h3 {
  margin-bottom: 12px;
  font-weight: 600;
  color: #2c3e50;
}

.sidebar-item {
  display: flex;
  align-items: center;
  padding: 12px 14px;
  margin-bottom: 8px;
  cursor: pointer;
  border-radius: 6px;
  background-color: #fff;
  transition: all 0.3s ease;
  box-shadow: 0 1px 3px rgb(0 0 0 / 0.08);
  gap: 8px;
}

.sidebar-item:hover {
  background-color: #e6f0ff;
  box-shadow: 0 4px 10px rgb(0 0 0 / 0.12);
  transform: translateX(3px);
}

.sidebar-item.active {
  background-color: #409eff;
  color: #fff;
  font-weight: 700;
  box-shadow: 0 4px 12px rgb(64 158 255 / 0.5);
  transform: translateX(3px);
}

.file-icon {
  font-size: 18px;
}

.preview-footer {
  padding: 16px 24px;
  border-top: 1px solid #ddd;
  background: #fff;
  box-shadow: 0 -1px 4px rgb(0 0 0 / 0.05);
  text-align: right;
}

.preview-footer .el-button {
  padding: 8px 24px;
  font-weight: 600;
  border-radius: 6px;
}
</style> 