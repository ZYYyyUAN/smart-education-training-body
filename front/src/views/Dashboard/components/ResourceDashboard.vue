<template>
    <section class="resource-dashboard">
      <!-- 加载状态 -->
      <div v-if="!resources.length && !courseOptions.length" class="loading-container">
        <el-icon class="loading-icon"><Loading /></el-icon>
        <span class="loading-text">正在加载教学资源...</span>
      </div>
      
      <!-- 页面头部 -->
      <div class="page-header">
        <div class="header-content">
          <div class="header-left">
            <div class="page-title">
              <img src="@/assets/icon/奶牛猫.png" alt="奶牛猫" class="title-icon">
          <h2 class="title-text">教学资源管理</h2>
            </div>
            <div class="page-subtitle">管理和组织您的教学资源文件</div>
          </div>
          <div class="header-right">
            <div class="stats-container">
              <div class="stat-item">
                <span class="stat-number">{{ filteredResources.length }}</span>
                <span class="stat-label">总资源</span>
              </div>
              <div class="stat-item">
                <span class="stat-number">{{ resources.filter(r => r.ingested).length }}</span>
                <span class="stat-label">已入库</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 搜索区域 -->
      <div class="search-section">
        <div class="search-bar">
          <div class="search-left">
            <el-input
              v-model="searchKeyword"
              placeholder="搜索文件名..."
              class="search-input"
              clearable
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </div>
          <div class="search-right">
            <el-select
              v-model="selectedCourseId"
              placeholder="选择课程筛选"
              clearable
              class="filter-select"
              @change="handleCourseFilterChange"
            >
              <template #prefix>
                <el-icon><Filter /></el-icon>
              </template>
              <el-option
                v-for="course in courseOptions"
                :key="course.id"
                :label="course.courseName || course.name"
                :value="course.id"
              />
            </el-select>
            <el-button type="primary" class="upload-btn" @click="uploadDialogVisible = true">
              <el-icon><Upload /></el-icon>
              上传资源
            </el-button>
          </div>
          </div>
        </div>
  
      <!-- 资源卡片容器 -->
      <div class="resources-container">
        <!-- 空状态 -->
        <div v-if="filteredResources.length === 0" class="empty-state">
          <el-icon class="empty-icon"><Document /></el-icon>
          <h3>暂无资源</h3>
          <p>还没有上传任何教学资源，点击上方按钮开始上传吧！</p>
          <el-button type="primary" class="empty-action-btn" @click="uploadDialogVisible = true">
            <el-icon><Upload /></el-icon>
            立即上传
          </el-button>
        </div>

        <!-- 资源卡片网格 -->
        <div v-else class="resources-grid">
          <div 
            v-for="resource in pagedResources" 
            :key="resource.id" 
            class="resource-card"
          >
            <!-- 卡片头部 -->
            <div class="card-header">
              <div class="folder-icon">
                <img src="@/assets/images/文件夹.png" alt="文件夹" class="folder-img" />
              </div>
              <div class="card-actions">
                <el-dropdown trigger="click" @command="handleAction">
                  <el-button type="text" class="action-trigger">
                    <el-icon><MoreFilled /></el-icon>
                  </el-button>
                  <template #dropdown>
                    <el-dropdown-menu>
                      <el-dropdown-item 
                        :command="{ action: 'ingest', id: resource.id }"
                        :disabled="resource.ingested"
                      >
                        <el-icon><Plus /></el-icon>
                        加入知识库
                      </el-dropdown-item>
                      <el-dropdown-item :command="{ action: 'download', resource }">
                        <el-icon><Download /></el-icon>
                        下载文件
                      </el-dropdown-item>
                      <el-dropdown-item :command="{ action: 'delete', id: resource.id }" divided>
                        <el-icon><Delete /></el-icon>
                        删除资源
                      </el-dropdown-item>
                    </el-dropdown-menu>
              </template>
                </el-dropdown>
              </div>
            </div>

            <!-- 卡片内容 -->
            <div class="card-content">
              <div class="file-info">
                <h3 class="file-name" :title="resource.fileName">{{ resource.fileName }}</h3>
                <p class="course-name">{{ resource.courseName }}</p>
              </div>
              
              <div class="file-meta">
                <div class="upload-time">
                  <el-icon class="time-icon"><Clock /></el-icon>
                  <span>{{ resource.uploadTime }}</span>
                </div>
                <div class="status-badge">
                  <el-tag 
                    :type="resource.ingested ? 'success' : 'warning'" 
                    effect="light"
                    size="small"
                  >
                    <el-icon v-if="resource.ingested"><Check /></el-icon>
                    <el-icon v-else><Clock /></el-icon>
                    {{ resource.ingested ? '已入库' : '待入库' }}
                </el-tag>
                </div>
              </div>
            </div>

            <!-- 卡片底部操作 -->
            <div class="card-footer">
              <el-button 
                size="small" 
                type="success" 
                :disabled="resource.ingested" 
                @click="ingestResource(resource.id)"
                class="action-btn"
              >
                <el-icon><Plus /></el-icon>
                入库
              </el-button>
              <el-button 
                size="small" 
                type="primary" 
                @click="downloadResource(resource)"
                class="action-btn"
              >
                <el-icon><Download /></el-icon>
                下载
              </el-button>
            </div>
                </div>
        </div>
  
        <!-- 分页区域 -->
        <div v-if="filteredResources.length > 0" class="pagination-wrapper">
          <div class="pagination-info">
            <span class="pagination-text">
              共 {{ filteredResources.length }} 条记录，第 {{ currentPage }} / {{ Math.ceil(filteredResources.length / pageSize) }} 页
            </span>
          </div>
          <el-pagination
            background
            layout="sizes, prev, pager, next, jumper"
            :total="filteredResources.length"
            :page-size="pageSize"
            :current-page="currentPage"
            :page-sizes="[12, 24, 48, 96]"
            @current-change="handlePageChange"
            @size-change="handleSizeChange"
            class="pagination"
          />
        </div>
      </div>
  
      <!-- 修改弹窗 -->
      <el-dialog 
        v-model="editDialogVisible" 
        title="修改教学资源" 
        width="500px"
        :close-on-click-modal="false"
        class="edit-dialog"
      >
        <el-form :model="uploadForm" label-width="80px" class="upload-form">
          <el-form-item label="课程" required>
            <el-select v-model="uploadForm.courseId" placeholder="请选择课程" style="width: 100%">
        <el-option
          v-for="course in courseOptions"
          :key="course.id"
          :label="course.name"
          :value="course.id"
        />
      </el-select>
    </el-form-item>
    <el-form-item label="文件名">
      <el-input v-model="uploadForm.fileName" disabled />
    </el-form-item>
          <el-form-item label="文件" required>
            <el-upload
              class="file-upload"
              :auto-upload="false"
              :show-file-list="false"
              :on-change="handleUploadFileChange"
            >
              <el-button type="primary" plain>
                <el-icon><Upload /></el-icon>
                选择文件
              </el-button>
            </el-upload>
    </el-form-item>
  </el-form>
        <template #footer>
          <div class="dialog-footer">
          <el-button @click="editDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="confirmEdit">确认</el-button>
          </div>
        </template>
      </el-dialog>
  
      <!-- 上传资源弹窗 -->
      <el-dialog 
        v-model="uploadDialogVisible" 
        title="上传教学资源" 
        width="500px"
        :close-on-click-modal="false"
        class="upload-dialog"
      >
        <el-form :model="uploadForm" label-width="80px" class="upload-form">
          <el-form-item label="课程" required>
            <el-select v-model="uploadForm.courseId" placeholder="请选择课程" style="width: 100%">
              <el-option
                v-for="course in courseOptions"
                :key="course.id"
                :label="course.courseName || course.name"
                :value="course.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="文件名">
            <el-input v-model="uploadForm.fileName" disabled />
          </el-form-item>
          <el-form-item label="文件" required>
            <el-upload
              class="file-upload"
              :auto-upload="false"
              :show-file-list="false"
              :on-change="handleUploadFileChange"
            >
              <el-button type="primary" plain>
                <el-icon><Upload /></el-icon>
                选择文件
              </el-button>
            </el-upload>
          </el-form-item>
        </el-form>
        <template #footer>
          <div class="dialog-footer">
          <el-button @click="uploadDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitUpload">上传</el-button>
          </div>
        </template>
      </el-dialog>
    </section>
  </template>
  
  <script setup>
  import axios from 'axios'
  import dayjs from 'dayjs'
  import { ElMessage } from 'element-plus'
  import { ref, onMounted, computed } from 'vue'
  import { 
    Loading, 
    Document, 
    Filter, 
    Search, 
    Upload, 
    Reading, 
    Check, 
    Clock, 
    Plus, 
    Download, 
    Delete, 
    Edit,
    MoreFilled
  } from '@element-plus/icons-vue'
  
  // 教师ID，演示用，实际项目可动态获取
  const teacherId = 2
  
  // 选中的课程ID（用于筛选）
  const selectedCourseId = ref('')
  
  // 搜索关键词
  const searchKeyword = ref('')
  
  // 资源列表原始数据
  const resources = ref([])
  
  // 课程列表，后端接口获取
  const courseOptions = ref([])
  
  // 当前页码和每页大小（分页）
  const currentPage = ref(1)
  const pageSize = ref(10)
  
  // 过滤后的资源列表，基于 selectedCourseId 和 searchKeyword 筛选
  const filteredResources = computed(() => {
    let filtered = resources.value
    
    // 按课程筛选
    if (selectedCourseId.value) {
      filtered = filtered.filter(item =>
      Number(item.courseId) === Number(selectedCourseId.value)
    )
    }
    
    // 按文件名搜索
    if (searchKeyword.value) {
      filtered = filtered.filter(item =>
        item.fileName.toLowerCase().includes(searchKeyword.value.toLowerCase())
      )
    }
    
    return filtered
  })
  
  // 当前页需要展示的资源（分页切片）
  const pagedResources = computed(() => {
    const start = (currentPage.value - 1) * pageSize.value
    return filteredResources.value.slice(start, start + pageSize.value)
  })
  
  // 切换分页页码
  const handlePageChange = (page) => {
    currentPage.value = page
  }
  
  // 切换每页大小
  const handleSizeChange = (size) => {
    pageSize.value = size
    currentPage.value = 1 // 重置到第一页
  }
  
  // 格式化表格中的ID显示（你可以自定义）
  const formatId = (index) => index
  
  // 根据课程ID获取课程名称
  const getCourseNameById = (id) => {
    const course = courseOptions.value.find(c => Number(c.id) === Number(id))
    return course ? course.courseName || course.name : '未知课程'
  }
  // 下载教学资源
  const downloadResource = async (resource) => {
    try {
      if (!resource.filePath) {
        ElMessage.error('文件路径不存在，无法下载')
        return
      }
      
      // 增加下载次数
      if (resource.id) {
        try {
          await axios.post('/api/xiaozhi/teacher/resource/download-count', null, {
            params: { id: resource.id }
          })
          // 乐观更新本地数据
          const target = resources.value.find(r => r.id === resource.id)
          if (target) {
            target.downloadCount = (target.downloadCount || 0) + 1
          }
        } catch (e) {
          console.error('增加下载次数失败', e)
          // 即使计数失败，也继续下载
        }
      }
      
      // 创建一个临时的a标签来触发下载
      const link = document.createElement('a')
      link.href = resource.filePath
      link.download = resource.fileName || '下载文件'
      link.target = '_blank'
      
      // 添加到DOM中，点击后移除
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      
      ElMessage.success('开始下载文件: ' + resource.fileName)
    } catch (error) {
      ElMessage.error('下载失败: ' + error.message)
    }
  }
  
  // 删除教学资源
  const deleteResource = async (resourceId) => {
    try {
      const res = await axios.delete('/api/xiaozhi/teacher/resource/delete', {
        params: { id: resourceId }
      })
      if (res.data.code === 200) {
        ElMessage.success('删除成功')
        // 删除成功后刷新资源列表
        await loadResources()
      } else {
        ElMessage.error('删除失败: ' + (res.data.message || '未知错误'))
      }
    } catch (error) {
      ElMessage.error('删除请求失败: ' + error.message)
    }
  }
  
  // 加入知识库（向量化入Pinecone）
  const ingestResource = async (resourceId) => {
    try {
      const res = await axios.post('/api/xiaozhi/teacher/resource/ingest', null, {
        params: { resourceId }
      })
      if (res.status === 200) {
        ElMessage.success('已加入知识库')
        // 乐观更新当前行状态，并刷新列表
        const row = resources.value.find(r => r.id === resourceId)
        if (row) row.ingested = true
        // 不立即刷新，避免后端异步落库导致状态闪回
      } else {
        ElMessage.error('加入知识库失败')
      }
    } catch (error) {
      ElMessage.error('加入知识库请求失败: ' + (error.response?.data || error.message))
    }
  }
  
  
  // 加载资源数据
  const loadResources = async () => {
    try {
      const res = await axios.get('/api/xiaozhi/teacher/resources/by-teacher', {
        params: { teacherId }
      })
      if (res.data.code === 200) {
        // 获取 knowledge_doc 计数，以标识是否已加入
        const ingestedSet = new Set()
        try {
          const checkRes = await axios.get('/api/xiaozhi/teacher/resources/by-teacher', { params: { teacherId } })
          // 简化：复用接口，不二次查；若后端提供专门查询 knowledge_doc 列表，可替换
        } catch {}
        resources.value = res.data.data.map(item => ({
          id: item.id,
          courseId: item.courseId,
          teacherId: item.teacherId,
          fileName: item.fileName,
          filePath: item.filePath,
          courseName: getCourseNameById(item.courseId),
          uploadTime: dayjs(item.uploadedAt).format('YYYY-MM-DD HH:mm:ss'),
          ingested: Boolean(item.ingested),
          downloadCount: item.downloadCount || 0
        }))
        console.log('加载的资源:', resources.value)
      } else {
        ElMessage.error('加载资源失败: ' + res.data.message)
      }
    } catch (err) {
      ElMessage.error('接口请求失败: ' + err.message)
    }
  }
  
  // 加载课程列表
  const loadCourses = async () => {
    try {
      const res = await axios.get('/api/xiaozhi/teacher/courses')
      if (res.data.code === 200) {
        courseOptions.value = res.data.data
        console.log('课程列表:', courseOptions.value)
      } else {
        ElMessage.error('加载课程失败: ' + res.data.message)
      }
    } catch (err) {
      ElMessage.error('加载课程异常: ' + err.message)
    }
  }
  
  // 组件挂载时，先加载课程列表，确保课程数据已准备好，再加载资源数据
  onMounted(async () => {
    console.log('ResourceDashboard component mounted')
    console.log('Current route:', window.location.pathname)
    await loadCourses()
    await loadResources()
  })
  
  // 课程筛选变化处理函数
  const handleCourseFilterChange = () => {
    currentPage.value = 1 // 重置到第一页
  }
  
  // 上传弹窗显示控制
  const uploadDialogVisible = ref(false)
  
  // 编辑弹窗显示控制
  const editDialogVisible = ref(false)
  
  // 上传表单数据
  const uploadForm = ref({
    courseId: '',
    courseName: '',
    fileName: '',
    file: null,  // 存储上传的文件对象
  })
  
  // 监听上传文件选择事件，保存文件对象并设置文件名
  const handleUploadFileChange = (file) => {
    if (file && file.raw) {
      uploadForm.value.file = file.raw
      uploadForm.value.fileName = file.name
    } else {
      uploadForm.value.file = null
      uploadForm.value.fileName = ''
    }
  }
  
  // 上传接口调用
  const submitUpload = async () => {
    if (!uploadForm.value.file) {
      ElMessage.warning('请选择文件！')
      return
    }
    if (!uploadForm.value.courseId) {
      ElMessage.warning('请选择课程！')
      return
    }
  
    const formData = new FormData()
    formData.append('file', uploadForm.value.file)
    formData.append('courseId', uploadForm.value.courseId)
    formData.append('teacherId', teacherId)
    formData.append('type', 'resource') // 可选参数，默认传 resource
  
    try {
      const res = await axios.post('/api/xiaozhi/teacher/upload', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
      if (res.status === 200) {
        ElMessage.success('文件上传成功')
        uploadDialogVisible.value = false
        // 上传成功后刷新资源列表
        await loadResources()
        // 重置上传表单
        uploadForm.value = {
          courseId: '',
          courseName: '',
          fileName: '',
          file: null,
        }
      } else {
        ElMessage.error('上传失败：' + res.data.message || '未知错误')
      }
    } catch (error) {
      ElMessage.error('上传接口异常：' + error.message)
    }
  }
  
  // 确认编辑
  const confirmEdit = async () => {
    if (!uploadForm.value.file) {
      ElMessage.warning('请选择文件！')
      return
    }
    if (!uploadForm.value.courseId) {
      ElMessage.warning('请选择课程！')
      return
    }
  
    const formData = new FormData()
    formData.append('file', uploadForm.value.file)
    formData.append('courseId', uploadForm.value.courseId)
    formData.append('teacherId', teacherId)
    formData.append('type', 'resource')
  
    try {
      const res = await axios.post('/api/xiaozhi/teacher/upload', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
      if (res.status === 200) {
        ElMessage.success('文件更新成功')
        editDialogVisible.value = false
        await loadResources()
        uploadForm.value = {
          courseId: '',
          courseName: '',
          fileName: '',
          file: null,
        }
      } else {
        ElMessage.error('更新失败：' + res.data.message || '未知错误')
      }
    } catch (error) {
      ElMessage.error('更新接口异常：' + error.message)
    }
  }

  // 处理下拉菜单操作
  const handleAction = (command) => {
    const { action, id, resource } = command
    
    switch (action) {
      case 'ingest':
        ingestResource(id)
        break
      case 'download':
        downloadResource(resource)
        break
      case 'delete':
        deleteResource(id)
        break
    }
  }
  
  
  </script>
  
  
  <style scoped>
  .resource-dashboard {
    flex: 1;
  min-height: 100vh;
  padding: 0;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
  background: #ffffff;
  }
  
/* 加载状态 */
.loading-container {
    display: flex;
    flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4rem 2rem;
  background: white;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  margin: 2rem;
}

.loading-icon {
  font-size: 2rem;
  color: #409eff;
  margin-bottom: 1rem;
  animation: spin 1s linear infinite;
}

.loading-text {
  color: #606266;
  font-size: 1rem;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* 页面头部 */
.page-header {
  background: white;
  color: #1e293b;
  padding: 2rem;
  margin-bottom: 2rem;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  margin: 2rem;
  margin-bottom: 2rem;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1200px;
  margin: 0 auto;
}

.header-left {
  flex: 1;
}

.page-title {
  display: flex;
  align-items: center;
  margin-bottom: 0.5rem;
}

.title-icon {
  width: 3rem;
  height: 3rem;
  object-fit: contain;
  vertical-align: middle;
  margin-right: 0.75rem;
}

.title-text {
  font-size: 1.75rem;
  font-weight: 700;
  margin: 0;
}

.page-subtitle {
  font-size: 0.95rem;
  color: #64748b;
  margin-left: 2.25rem;
}

.header-right {
  display: flex;
  align-items: center;
}

.stats-container {
  display: flex;
  gap: 2rem;
}

.stat-item {
  text-align: center;
  background: #f8fafc;
  padding: 1rem 1.5rem;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
}

.stat-number {
  display: block;
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 0.25rem;
  color: #667eea;
}

.stat-label {
  font-size: 0.85rem;
  color: #64748b;
}

/* 搜索区域 */
.search-section {
  background: white;
  margin: 0 2rem 2rem;
  padding: 1.5rem;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.search-bar {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.search-left {
  flex: 1;
}

.search-input {
  width: 100%;
}

.search-right {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.filter-select {
  width: 200px;
}

.upload-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 8px;
  padding: 0.75rem 1.5rem;
  font-weight: 600;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
  transition: all 0.3s ease;
}

.upload-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

/* 资源容器 */
.resources-container {
  margin: 0 2rem 2rem;
  min-height: 400px;
}

/* 空状态 */
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.empty-icon {
  font-size: 4rem;
  color: #cbd5e1;
  margin-bottom: 1rem;
}

.empty-state h3 {
  color: #64748b;
  margin: 0 0 0.5rem 0;
  font-size: 1.5rem;
}

.empty-state p {
  color: #94a3b8;
  margin: 0 0 2rem 0;
}

.empty-action-btn {
  padding: 0.75rem 2rem;
  font-weight: 600;
}

/* 资源网格 */
.resources-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1.5rem;
}

/* 资源卡片 */
.resource-card {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f5f9;
  overflow: hidden;
  transition: all 0.3s ease;
  cursor: pointer;
  position: relative;
}

.resource-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
  border-color: #e2e8f0;
}

.resource-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #667eea, #764ba2);
}

/* 卡片头部 */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 1.5rem 1rem;
}

.folder-icon {
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.folder-img {
  width: 40px;
  height: 40px;
  object-fit: contain;
}

.card-actions {
  display: flex;
  align-items: center;
}

.action-trigger {
  color: #94a3b8;
  font-size: 1.2rem;
  padding: 0.5rem;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.action-trigger:hover {
  color: #667eea;
  background: #f8fafc;
}

/* 卡片内容 */
.card-content {
  padding: 0 1.5rem 1rem;
}

.file-info {
  margin-bottom: 1rem;
}

.file-name {
  font-size: 1rem;
  font-weight: 600;
  color: #1e293b;
  margin: 0 0 0.5rem 0;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.course-name {
  font-size: 0.875rem;
  color: #64748b;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.course-name::before {
  content: '📚';
  font-size: 0.75rem;
}

.file-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
  }
  
.upload-time {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.75rem;
  color: #94a3b8;
}

.time-icon {
  font-size: 0.875rem;
}

.status-badge {
    display: flex;
    align-items: center;
  }
  
/* 卡片底部 */
.card-footer {
  display: flex;
  gap: 0.5rem;
  padding: 1rem 1.5rem;
  background: #f8fafc;
  border-top: 1px solid #e2e8f0;
}

.action-btn {
    flex: 1;
  border-radius: 8px;
  font-weight: 500;
  transition: all 0.3s ease;
  font-size: 0.875rem;
}

.action-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

/* 分页样式 */
  .pagination-wrapper {
    display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 0;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  margin-top: 2rem;
}

.pagination-info {
    display: flex;
    align-items: center;
  padding: 0 2rem;
}

.pagination-text {
  color: #606266;
  font-size: 0.9rem;
  font-weight: 500;
}

.pagination {
  padding: 0 2rem;
  --el-pagination-bg-color: white;
  --el-pagination-button-bg-color: white;
}

/* 弹窗样式 */
.upload-dialog :deep(.el-dialog),
.edit-dialog :deep(.el-dialog) {
  border-radius: 8px;
}

.upload-dialog :deep(.el-dialog__header),
.edit-dialog :deep(.el-dialog__header) {
  padding: 20px 20px 10px;
  border-bottom: 1px solid #f0f0f0;
}

.upload-dialog :deep(.el-dialog__title),
.edit-dialog :deep(.el-dialog__title) {
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.upload-form {
  padding: 20px;
}

.file-upload {
  width: 100%;
}

.file-upload :deep(.el-upload) {
  width: 100%;
}

.file-upload :deep(.el-upload .el-button) {
  width: 100%;
  height: 36px;
  border: 1px solid #d9d9d9;
  background: #fafafa;
  color: #606266;
  transition: all 0.3s ease;
}

.file-upload :deep(.el-upload .el-button:hover) {
  border-color: #409eff;
  background: #f0f9ff;
  color: #409eff;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 10px 20px 20px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .resource-dashboard {
    padding: 0;
  }
  
  .page-header {
    padding: 1.5rem;
  }
  
  .header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
  
  .stats-container {
    gap: 1rem;
  }
  
  .search-section {
    margin: 0 1rem 1rem;
  }
  
  .search-bar {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }
  
  .search-right {
    flex-direction: column;
    gap: 0.75rem;
  }
  
  .filter-select {
    width: 100%;
  }
  
  .resources-container {
    margin: 0 1rem 1rem;
  }
  
  .resources-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .pagination-wrapper {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }
  
  .pagination-info {
    padding: 0 1rem;
  }
  
  .pagination {
    padding: 0 1rem;
  }
  }
  </style>
  