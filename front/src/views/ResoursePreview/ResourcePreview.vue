<template>
  <div class="resource-preview-container">
    <div class="preview-header">
      <el-button @click="closePreview">返回</el-button>
      <h2>{{ currentResource ? currentResource.fileName : '' }}</h2>
    </div>
    
    <div class="preview-content">
      <div class="preview-area">
        <iframe
           v-if="currentResource && isPdf(currentResource.filePath)"
          :src="currentResource.filePath"
          frameborder="0"
          width="100%"
          height="100%"
        ></iframe>
        <iframe
           v-else-if="currentResource"
          :src="getOfficePreviewUrl(currentResource.filePath)"
          frameborder="0"
          width="100%"
          height="100%"
        ></iframe>
      </div>
      
      <div class="resource-sidebar">
        <h3>课件列表</h3>
        <div 
  v-for="resource in resources" 
  :key="resource.id"
  class="sidebar-item"
  :class="{ active: resource.id === currentResource?.id }"
  @click="switchResource(resource)"
>
  {{ resource.fileName }}
</div>
      </div>
    </div>
    
    <div class="preview-footer">
      <el-button type="primary" @click="download(currentResource.filePath)">
        下载当前资源
      </el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useRoute, useRouter } from 'vue-router'

const router = useRouter()
const route = useRoute()

const resources = ref([]) // 所有课件资源
const currentResource = ref(null)

const emit = defineEmits(['close'])

const isPdf = (url) => url.toLowerCase().endsWith('.pdf')

const getOfficePreviewUrl = (url) =>
  `https://view.officeapps.live.com/op/view.aspx?src=${encodeURIComponent(url)}`

const switchResource = (resource) => {
  currentResource.value = resource
  // 如果你想更新地址栏的 id，可以取消注释下面这一行
  // router.replace({ name: 'resource', params: { id: resource.id }, query: { courseId: route.query.courseId } })
}

const closePreview = () => {
   router.push({
    name: 'course',
    query: { id: route.query.courseId } // 从当前路由获取courseId
  });
}

const download = (url) => {
  window.open(url, '_blank')
}

onMounted(async () => {
  const resourceId = route.params.id
  const courseId = route.query.courseId

  if (!courseId) {
    console.error('courseId 未提供')
    return
  }

  try {
    // 获取该课程下所有课件资源
    const res = await axios.get(`/api/xiaozhi/teacher/resources?courseId=${courseId}`)
    if (res.data.code === 200) {
      resources.value = res.data.data || []

      // 找到当前点击的资源并设为 currentResource
      const found = resources.value.find((r) => String(r.id) === String(resourceId))
      currentResource.value = found || resources.value[0] || null
    }
  } catch (err) {
    console.error('获取资源失败:', err)
  }
})
</script>

<style scoped>
.resource-preview-container {
  height: 100vh; /* 全屏高度 */
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

.resource-sidebar {
  width: 400px;
  border-left: 1px solid #eee;
  padding-left: 16px;
  overflow-y: auto;
  background: #f7f9fc;
  border-radius: 8px;
  box-shadow: inset 0 0 10px rgb(0 0 0 / 0.03);
}

.resource-sidebar h3 {
  margin-bottom: 12px;
  font-weight: 600;
  color: #2c3e50;
}

.sidebar-item {
  padding: 12px 14px;
  margin-bottom: 8px;
  cursor: pointer;
  border-radius: 6px;
  background-color: #fff;
  transition: all 0.3s ease;
  box-shadow: 0 1px 3px rgb(0 0 0 / 0.08);
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
