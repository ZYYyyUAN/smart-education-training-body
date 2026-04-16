<template>
  <div class="page">
    <div class="left">
      <div class="brand">
        <span class="ai">AI</span>
        <span class="dot">·</span>
        <span class="title">阅读助手</span>
      </div>
      <button class="back-btn" @click="goBack">返回</button>

      <!-- 文件上传区域 -->
      <div
        v-if="!selectedFile"
        class="dropzone"
        @dragover.prevent
        @dragenter.prevent
        @drop.prevent="onDrop"
      >
        <div class="dz-inner">
          <svg viewBox="0 0 48 48" width="72" height="72">
            <path fill="#7aa7ff" d="M8 40a4 4 0 0 1-4-4V12a4 4 0 0 1 4-4h12l4 4h16a4 4 0 0 1 4 4v20a4 4 0 0 1-4 4Z"/>
            <path fill="#fff" d="M24 22h14v2H24zm0 6h14v2H24zm0 6h10v2H24z"/>
          </svg>
          <div class="dz-text">
            <span>拖拽文件到此处，或</span>
            <button class="link" @click="triggerFile">点击选择</button>
          </div>
          <div class="dz-sub">支持上传PDF、Word文档和图片文件</div>
          <div class="file-types">
            <span class="file-type">📄 PDF</span>
            <span class="file-type">📝 Word</span>
            <span class="file-type">🖼️ 图片</span>
          </div>
          <input ref="fileInput" type="file" class="hidden" accept=".pdf,.doc,.docx,.jpg,.jpeg,.png,.bmp,.gif,.webp" @change="onFileChange" />
        </div>
      </div>

      <!-- 文件预览区域 -->
      <div v-if="selectedFile" class="file-preview">
        <div class="file-info">
          <div class="file-icon">
            <svg v-if="isImageFile(selectedFile)" viewBox="0 0 48 48" width="60" height="60">
              <path fill="#ff9800" d="M40 8H8c-2.2 0-4 1.8-4 4v24c0 2.2 1.8 4 4 4h32c2.2 0 4-1.8 4-4V12c0-2.2-1.8-4-4-4z"/>
              <circle fill="#fff" cx="15.5" cy="16.5" r="2.5"/>
              <path fill="#fff" d="M38 32H10l8-10 4 5 6-8 10 13z"/>
            </svg>
            <svg v-else-if="selectedFile.name.toLowerCase().includes('pdf')" viewBox="0 0 48 48" width="60" height="60">
              <path fill="#d32f2f" d="M40 12H24l-4-4H8c-2.2 0-4 1.8-4 4v24c0 2.2 1.8 4 4 4h32c2.2 0 4-1.8 4-4V16c0-2.2-1.8-4-4-4z"/>
              <path fill="#fff" d="M18 24h12v2H18zm0 4h12v2H18zm0 4h8v2h-8z"/>
            </svg>
            <svg v-else viewBox="0 0 48 48" width="60" height="60">
              <path fill="#1976d2" d="M40 12H24l-4-4H8c-2.2 0-4 1.8-4 4v24c0 2.2 1.8 4 4 4h32c2.2 0 4-1.8 4-4V16c0-2.2-1.8-4-4-4z"/>
              <path fill="#fff" d="M18 24h12v2H18zm0 4h12v2H18zm0 4h8v2h-8z"/>
            </svg>
          </div>
          <div class="file-details">
            <div class="file-name">{{ selectedFile.name }}</div>
            <div class="file-size">{{ formatFileSize(selectedFile.size) }}</div>
            <div class="file-type-badge">{{ getFileTypeText(selectedFile) }}</div>
          </div>
        </div>
        <button class="reselect-btn" @click="reselectFile">
          重新选择文件
        </button>
      </div>

      <button class="primary" :disabled="!selectedFile" @click="startReading">
        开始阅读
      </button>
    </div>

    <div class="right">
      <div class="history-card">
        <div class="history-header">
          <div class="dot"></div>
          <div class="title">历史记录</div>
          <div class="tip">仅保留一个月内历史记录</div>
        </div>
        <div class="history-list" v-if="historyList.length">
          <div class="history-item" v-for="item in historyList" :key="item.id" @click="openHistory(item)">
            <div class="rid">{{ item.id }}</div>
            <div class="fname">{{ item.name }}</div>
          </div>
        </div>
        <div class="empty" v-else>暂无历史记录</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const fileInput = ref(null)
const selectedFile = ref(null)
const historyList = ref([])

const HISTORY_KEY = 'ai_reader_history'
const HISTORY_MAX = 20
const HISTORY_TTL_DAYS = 30

const triggerFile = () => fileInput.value && fileInput.value.click()

const goBack = () => {
  router.push('/study_space?courseId=101')
}

const isImageFile = (file) => {
  const imageTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/bmp', 'image/gif', 'image/webp']
  return imageTypes.includes(file.type)
}

const isDocumentFile = (file) => {
  const docTypes = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
  return docTypes.includes(file.type) || file.name.toLowerCase().endsWith('.pdf') || file.name.toLowerCase().endsWith('.doc') || file.name.toLowerCase().endsWith('.docx')
}

const validateFile = (file) => {
  if (!file) return false
  
  if (isImageFile(file) || isDocumentFile(file)) {
    return true
  }
  
  alert('不支持的文件格式，请上传PDF、Word文档或图片文件')
  return false
}

const onFileChange = (e) => {
  const file = e.target.files && e.target.files[0]
  if (file && validateFile(file)) {
    selectedFile.value = file
  }
}

const onDrop = (e) => {
  const file = e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files[0]
  if (file && validateFile(file)) {
    selectedFile.value = file
  }
}

const generateId = () => {
  const s4 = () => Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
  return `${s4()}${s4()}-${s4()}-${s4()}-${s4()}-${s4()}${s4()}${s4()}`
}

const persistHistory = (record) => {
  const now = Date.now()
  const raw = localStorage.getItem(HISTORY_KEY)
  let list = []
  try { list = raw ? JSON.parse(raw) : [] } catch { list = [] }
  list.unshift({ ...record, ts: now })
  // 仅保留一个月 & 最多条数
  const cutoff = now - HISTORY_TTL_DAYS * 24 * 60 * 60 * 1000
  list = list.filter(x => x.ts >= cutoff).slice(0, HISTORY_MAX)
  localStorage.setItem(HISTORY_KEY, JSON.stringify(list))
  historyList.value = list
}

const loadHistory = () => {
  const raw = localStorage.getItem(HISTORY_KEY)
  try {
    const now = Date.now()
    const cutoff = now - HISTORY_TTL_DAYS * 24 * 60 * 60 * 1000
    historyList.value = raw ? JSON.parse(raw).filter(x => x.ts >= cutoff) : []
  } catch {
    historyList.value = []
  }
}

// 以 objectURL 方式传递，避免 sessionStorage 5MB 限制
const startReading = async () => {
  if (!selectedFile.value) return
  const file = selectedFile.value
  const id = generateId()
  persistHistory({ id, name: file.name, size: file.size, type: file.type })
  try {
    // 使用全局 Map 暂存 File 对象（刷新前有效），sessionStorage 仅存元数据
    window.__AI_READER_FILES__ = window.__AI_READER_FILES__ || {}
    window.__AI_READER_FILES__[id] = file
    const payload = { id, name: file.name, type: file.type, size: file.size, hasFile: true }
    sessionStorage.setItem(`ai_reader_file_${id}`, JSON.stringify(payload))
    router.push(`/ai_reader/view/${id}`)
  } catch (e) {
    alert('文件读取失败，请重试')
  }
}

const openHistory = (item) => {
  const raw = sessionStorage.getItem(`ai_reader_file_${item.id}`)
  if (!raw) {
    // 历史里只存元数据时允许跳转，但可能需要重新上传
    return router.push(`/ai_reader/view/${item.id}`)
  }
  router.push(`/ai_reader/view/${item.id}`)
}

// 格式化文件大小
const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

// 获取文件类型文本
const getFileTypeText = (file) => {
  if (isImageFile(file)) {
    return '图片文件'
  } else if (file.name.toLowerCase().includes('pdf')) {
    return 'PDF文档'
  } else if (file.name.toLowerCase().includes('doc')) {
    return 'Word文档'
  }
  return '文档文件'
}

// 重新选择文件
const reselectFile = () => {
  selectedFile.value = null
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

onMounted(loadHistory)
</script>

<style scoped>
.page {
  display: flex;
  height: 100vh;
  width: 100%;
  background: linear-gradient(180deg, #f7fbff 0%, #eef3ff 100%);
}

.left {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.brand {
  position: absolute;
  top: 40px;
  left: 60px;
  font-size: 32px;
  font-weight: 800;
  letter-spacing: 1px;
  color: #3c69ff;
}
.brand .ai { color: #4f68ff; }
.brand .dot { margin: 0 6px; color: #8aa2ff; }
.brand .title { color: #6a40ff; }

.back-btn { position: absolute; top: 16px; left: 20px; height: 32px; padding: 0 12px; border: 1px solid #d9defb; border-radius: 8px; background: #fff; color: #4f68ff; cursor: pointer; }

.dropzone {
  width: 780px;
  height: 380px;
  border-radius: 16px;
  border: 1px dashed rgba(100, 120, 255, 0.5);
  background: rgba(255,255,255,0.75);
  box-shadow: 0 20px 60px rgba(28, 44, 120, 0.08);
  display: flex;
  align-items: center;
  justify-content: center;
}

.dz-inner { text-align: center; }
.dz-text { margin-top: 12px; color: #444; font-size: 16px; }
.dz-sub { margin-top: 6px; color: #888; font-size: 13px; }
.file-types { 
  margin-top: 12px; 
  display: flex; 
  justify-content: center; 
  gap: 16px; 
}
.file-type { 
  padding: 4px 8px; 
  background: rgba(79, 104, 255, 0.1); 
  border-radius: 6px; 
  font-size: 12px; 
  color: #4f68ff; 
}
.link { background: none; border: none; color: #4f68ff; cursor: pointer; font-size: 16px; padding: 0 4px; }
.hidden { display: none; }

.primary {
  margin-top: 28px;
  width: 180px;
  height: 44px;
  border: none;
  border-radius: 10px;
  color: #fff;
  background: linear-gradient(90deg, #6f7bff, #b07bff);
  box-shadow: 0 10px 30px rgba(80, 81, 222, 0.25);
  cursor: pointer;
}
.primary:disabled { opacity: 0.5; cursor: not-allowed; }

.right {
  width: 420px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.history-card {
  width: 360px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(22, 34, 100, 0.12);
  padding: 16px;
}

.history-header { display: flex; align-items: center; gap: 8px; margin-bottom: 10px; }
.history-header .dot { width: 10px; height: 10px; background: #7c6bff; border-radius: 50%; }
.history-header .title { font-weight: 700; color: #333; }
.history-header .tip { margin-left: auto; color: #9aa0b0; font-size: 12px; }

.history-list { max-height: 520px; overflow: auto; padding: 6px; }
.history-item { border: 1px solid #eef0f6; border-radius: 10px; padding: 10px 12px; margin-bottom: 10px; cursor: pointer; background: #f9fbff; }
.history-item:hover { background: #f1f5ff; }
.history-item .rid { color: #5b6cff; font-size: 12px; margin-bottom: 6px; word-break: break-all; }
.history-item .fname { color: #333; font-weight: 600; }

.empty { color: #98a0b3; text-align: center; padding: 24px 0; }

/* 文件预览样式 */
.file-preview {
  width: 780px;
  background: #fff;
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 20px 60px rgba(28, 44, 120, 0.08);
  border: 1px solid rgba(100, 120, 255, 0.1);
}

.file-info {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 24px;
}

.file-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 80px;
  height: 80px;
  background: rgba(79, 104, 255, 0.05);
  border-radius: 12px;
  border: 1px solid rgba(79, 104, 255, 0.1);
}

.file-details {
  flex: 1;
}

.file-name {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
  word-break: break-all;
}

.file-size {
  font-size: 14px;
  color: #666;
  margin-bottom: 8px;
}

.file-type-badge {
  display: inline-block;
  padding: 4px 12px;
  background: linear-gradient(90deg, #6f7bff, #b07bff);
  color: #fff;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
}

.reselect-btn {
  width: 100%;
  height: 44px;
  border: 2px solid #4f68ff;
  background: #fff;
  color: #4f68ff;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.reselect-btn:hover {
  background: #4f68ff;
  color: #fff;
  transform: translateY(-1px);
  box-shadow: 0 6px 20px rgba(79, 104, 255, 0.3);
}
</style>


