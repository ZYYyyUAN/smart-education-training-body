<template>
  <div class="wechat-chat">
    <!-- 头部 -->
    <div class="chat-header">
      <div class="header-info">
        <div class="avatar">{{ courseName?.charAt(0) || '课' }}</div>
        <div class="info">
          <div class="title">{{ courseName || '课程群聊' }}</div>
          <div class="status">{{ onlineCount }}人在线</div>
        </div>
      </div>
    </div>

    <!-- 消息区域 -->
    <div class="chat-messages" ref="messagesRef">
      <div v-for="msg in messages" :key="msg.id" class="message" :class="{ mine: (msg.senderId && currentUserId && String(msg.senderId) === String(currentUserId)) || (!msg.senderId && msg.sender === currentUser) }">
        <div class="avatar">
          <img v-if="getAvatarFor(msg)" :src="getAvatarFor(msg)" :alt="msg.sender" @error="onAvatarErrorOther(msg.sender)" />
          <span v-else>{{ msg.sender?.charAt(0) || 'U' }}</span>
        </div>
        <div class="bubble">
          <div class="name" v-if="!((msg.senderId && currentUserId && String(msg.senderId) === String(currentUserId)) || (!msg.senderId && msg.sender === currentUser))">{{ msg.sender }}</div>
          
          <!-- 文本消息 -->
          <div v-if="msg.type === 'text' || !msg.type" class="content">{{ msg.content }}</div>
          
          <!-- 表情包消息 -->
          <div v-else-if="msg.type === 'sticker'" class="sticker-content">
            <img :src="msg.content" :alt="msg.stickerName" class="sticker-image" />
          </div>
          
          <!-- 图片消息 -->
          <div v-else-if="msg.type === 'image'" class="image-content">
            <img :src="msg.content" :alt="msg.fileName" class="message-image" @click="previewImage(msg.content)" />
          </div>
          
          <!-- 文件消息 -->
          <div v-else-if="msg.type === 'file'" class="file-content">
            <div class="file-info">
              <div class="file-icon">📄</div>
              <div class="file-details">
                <div class="file-name">{{ msg.fileName }}</div>
                <div class="file-size">{{ formatFileSize(msg.fileSize) }}</div>
              </div>
            </div>
            <el-button size="small" @click="downloadFile(msg.content, msg.fileName)">下载</el-button>
          </div>
          
          <!-- 语音消息 -->
          <div v-else-if="msg.type === 'voice'" class="voice-content" @click="playVoice(msg.content)">
            <div class="voice-info">
              <div class="voice-icon">🎤</div>
              <div class="voice-details">
                <div class="voice-duration">{{ safeDuration(msg.duration) }}秒</div>
                <div class="voice-waveform">
                  <div class="wave-bar" v-for="i in 5" :key="i"></div>
                </div>
              </div>
            </div>
          </div>
          
          <div class="time">{{ formatTime(msg.timestamp) }}</div>
        </div>
      </div>
    </div>

    <!-- 输入区域 -->
    <div class="chat-input" v-show="!emojiPickerVisible && !stickerPickerVisible">
      <div class="input-toolbar">
        <el-button type="text" class="toolbar-btn" @click.stop="toggleEmojiPicker">
          😊
        </el-button>
        <el-button type="text" class="toolbar-btn" @click.stop="toggleStickerPicker">
          🎨
        </el-button>
        <el-button type="text" class="toolbar-btn" @click="showFileUpload">
          📎
        </el-button>
        <el-button type="text" class="toolbar-btn" @click="showImageUpload">
          🖼️
        </el-button>
        <el-button type="text" class="toolbar-btn" @click="toggleVoiceInput" :class="{ 'recording': isRecording }">
          🎤
        </el-button>

      </div>
      
      <div class="input-container">
        <el-input
          v-model="newMessage"
          type="textarea"
          :rows="1"
          :autosize="{ minRows: 1, maxRows: 4 }"
          placeholder="输入消息..."
          @keydown.enter.prevent="handleEnterPress"
          @click="handleInputClick"
          ref="inputRef"
        />
        <el-button type="primary" @click="sendMessage" :disabled="!newMessage.trim() && !selectedFile">
          发送
        </el-button>
        <el-button type="text" @click="toggleVoiceInput" :class="{ 'recording': isRecording }" class="voice-btn">
          🎤
        </el-button>
      </div>
    </div>

    <!-- Emoji选择器面板 -->
    <div v-if="emojiPickerVisible" class="emoji-panel" @click.stop>
      <!-- 聊天框在面板顶部 -->
      <div class="panel-input-section">
        <div class="input-container">
          <el-input
            v-model="newMessage"
            type="textarea"
            :rows="1"
            :autosize="{ minRows: 1, maxRows: 4 }"
            placeholder="输入消息..."
            @keydown.enter.prevent="handleEnterPress"
            @click="handleInputClick"
            ref="inputRef"
          />
          <el-button type="primary" @click="sendMessage" :disabled="!newMessage.trim() && !selectedFile">
            发送
          </el-button>
        </div>
      </div>
      
      <div class="panel-header">
        <div class="panel-tabs">
          <div class="tab-item active">😊</div>
          <div class="tab-item">❤️</div>
          <div class="tab-item">👍</div>
          <div class="tab-item">🎉</div>
        </div>
        <div class="panel-close" @click.stop="closeEmojiPicker">×</div>
      </div>
      
      <div class="panel-content">
        <div class="category-label">最近使用</div>
        <div class="emoji-grid">
          <span 
            v-for="emoji in recentEmojis" 
            :key="emoji"
            class="emoji-item"
            @click.stop="insertEmoji(emoji)"
          >
            {{ emoji }}
          </span>
        </div>
        
        <div class="category-label">所有表情</div>
        <div class="emoji-grid">
          <span 
            v-for="emoji in emojis" 
            :key="emoji"
            class="emoji-item"
            @click.stop="insertEmoji(emoji)"
          >
            {{ emoji }}
          </span>
        </div>
      </div>
    </div>

    <!-- 表情包选择器面板 -->
    <div v-if="stickerPickerVisible" class="sticker-panel" @click.stop>
      <!-- 聊天框在面板顶部 -->
      <div class="panel-input-section">
        <div class="input-container">
          <el-input
            v-model="newMessage"
            type="textarea"
            :rows="1"
            :autosize="{ minRows: 1, maxRows: 4 }"
            placeholder="输入消息..."
            @keydown.enter.prevent="handleEnterPress"
            @click="handleInputClick"
            ref="inputRef"
          />
          <el-button type="primary" @click="sendMessage" :disabled="!newMessage.trim() && !selectedFile">
            发送
          </el-button>
        </div>
      </div>
      
      <div class="panel-header">
        <div class="panel-tabs">
          <div class="tab-item active">😊</div>
          <div class="tab-item">❤️</div>
          <div class="tab-item">👍</div>
          <div class="tab-item">🎉</div>
        </div>
        <div class="panel-close" @click.stop="closeStickerPicker">×</div>
      </div>
      
      <div class="panel-content">
        <div class="category-label">最近使用</div>
        <div class="sticker-grid">
          <div 
            v-for="sticker in recentStickers" 
            :key="sticker.id"
            class="sticker-item"
            @click.stop="sendSticker(sticker)"
          >
            <img :src="sticker.url" :alt="sticker.name" />
          </div>
        </div>
        
        <div class="category-label">所有表情包</div>
        <div class="sticker-grid">
          <div 
            v-for="sticker in stickers" 
            :key="sticker.id"
            class="sticker-item"
            @click.stop="sendSticker(sticker)"
          >
            <img :src="sticker.url" :alt="sticker.name" />
          </div>
        </div>
      </div>
    </div>

    <!-- 文件上传 -->
    <input 
      ref="fileInput" 
      type="file" 
      style="display: none" 
      @change="handleFileSelect"
      multiple
    />
    
    <!-- 图片上传 -->
    <input 
      ref="imageInput" 
      type="file" 
      accept="image/*" 
      style="display: none" 
      @change="handleImageSelect"
      multiple
    />
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick, watch, onUnmounted } from 'vue'
import { ElMessage } from 'element-plus'
import axios from 'axios'
import { useUserStore } from '@/store/user.js'

const props = defineProps({
  courseId: String,
  courseName: String,
  currentUser: { type: String, default: '我' },
  currentUserId: { type: [String, Number], default: null }
})

// 获取 Pinia store
const userStore = useUserStore()

const messages = ref([])
const senderAvatarMap = ref({})
const userAvatarCache = ref(new Map())
const newMessage = ref('')
const messagesRef = ref(null)
const inputRef = ref(null)
const fileInput = ref(null)
const imageInput = ref(null)
const socket = ref(null)
const onlineCount = ref(15)
const myAvatarUrl = ref('')
const avatarLoaded = ref(false)
let storageListenerBound = false

// 弹窗状态
const emojiPickerVisible = ref(false)
const stickerPickerVisible = ref(false)
const selectedFile = ref(null)

// 语音输入相关
const isRecording = ref(false)
const mediaRecorder = ref(null)
const audioChunks = ref([])
const recordingDuration = ref(0)
const recordingTimer = ref(null)

// 最近使用的emoji和表情包
const recentEmojis = ref(['😊', '😂', '❤️', '👍', '🎉', '🔥'])
const recentStickers = ref([
  { id: 1, name: '开心', url: 'https://via.placeholder.com/100x100/FF6B6B/white?text=😊' },
  { id: 2, name: '大笑', url: 'https://via.placeholder.com/100x100/4ECDC4/white?text=😂' }
])

// Emoji表情
const emojis = ref([
  '😊', '😂', '🤣', '❤️', '👍', '👎', '🎉', '🔥', '💯', '😍', '😭', '😡', '🤔', '👀', '🙏', '💪',
  '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '🙃', '😉', '😋', '😎', '😍', '🥰', '😘',
  '😗', '😙', '😚', '😇', '🤗', '🤭', '🤫', '🤥', '😐', '😑', '😶', '😏', '😒', '🙄', '😬', '🤐',
  '🤢', '🤮', '🤧', '😷', '🤒', '🤕', '🤑', '🤠', '😈', '👿', '👹', '👺', '🤡', '💩', '👻', '💀'
])

// 表情包数据
const stickers = ref([
  { id: 1, name: '开心', url: 'https://via.placeholder.com/100x100/FF6B6B/white?text=😊' },
  { id: 2, name: '大笑', url: 'https://via.placeholder.com/100x100/4ECDC4/white?text=😂' },
  { id: 3, name: '爱心', url: 'https://via.placeholder.com/100x100/45B7D1/white?text=❤️' },
  { id: 4, name: '点赞', url: 'https://via.placeholder.com/100x100/96CEB4/white?text=👍' },
  { id: 5, name: '庆祝', url: 'https://via.placeholder.com/100x100/FFEAA7/white?text=🎉' },
  { id: 6, name: '火焰', url: 'https://via.placeholder.com/100x100/DDA0DD/white?text=🔥' }
])

// 头像错误处理
const onAvatarError = () => { myAvatarUrl.value = '' }
const onAvatarErrorOther = (sender) => { 
  console.log(`头像加载失败，发送者: ${sender}`)
  // 找到对应的消息并清除头像URL
  const messageIndex = messages.value.findIndex(msg => msg.sender === sender)
  if (messageIndex !== -1) {
    messages.value[messageIndex].senderAvatar = null
    console.log(`已清除发送者 ${sender} 的头像URL`)
  }
}

// 将当前头像应用到已存在的本地“自己”消息
const propagateMyAvatarToSelfMessages = () => {
  const selfId = props.currentUserId ? String(props.currentUserId) : null
  if (!selfId) return
  for (const msg of messages.value) {
    if (msg.senderId && String(msg.senderId) === selfId) {
      msg.senderAvatar = myAvatarUrl.value || null
    }
  }
}

// 加载当前用户头像
const loadCurrentUserAvatar = async () => {
  try {
    // 优先从 Pinia store 获取头像
    if (userStore.currentUser?.avatarUrl) {
      myAvatarUrl.value = userStore.currentUser.avatarUrl
      propagateMyAvatarToSelfMessages()
      console.log('从 Pinia store 加载头像:', userStore.currentUser.avatarUrl)
      return
    }
    
    // 如果 Pinia store 中没有，尝试从本地存储获取头像（检查多个可能的键名）
    const localAvatar = localStorage.getItem('teacherAvatarUrl') || 
                       localStorage.getItem('studentAvatarUrl') || 
                       localStorage.getItem('userAvatarUrl') ||
                       localStorage.getItem('avatarUrl')
    
    if (localAvatar) {
      myAvatarUrl.value = localAvatar
      propagateMyAvatarToSelfMessages()
      console.log('从本地存储加载头像:', localAvatar)
      return
    }
    
    // 如果都没有，尝试从后端获取
    console.log('从后端获取头像，用户ID:', props.currentUserId)
    const response = await axios.get(`/api/user/profile?userId=${props.currentUserId}`)
    if (response.data?.data?.avatarUrl) {
      myAvatarUrl.value = response.data.data.avatarUrl
      // 保存到本地存储（同时保存到多个键名以确保兼容性）
      try {
        localStorage.setItem('teacherAvatarUrl', response.data.data.avatarUrl)
        localStorage.setItem('studentAvatarUrl', response.data.data.avatarUrl)
        localStorage.setItem('userAvatarUrl', response.data.data.avatarUrl)
        console.log('头像已保存到本地存储:', response.data.data.avatarUrl)
      } catch (e) {
        console.warn('保存头像到本地存储失败:', e)
      }
      propagateMyAvatarToSelfMessages()
    } else {
      console.warn('后端未返回头像URL')
    }
  } catch (error) {
    console.warn('加载用户头像失败:', error)
  } finally {
    avatarLoaded.value = true
  }
}

// 加载用户头像的函数
const loadUserAvatar = async (userId, userName) => {
  if (!userId) return null
  
  // 检查缓存
  if (userAvatarCache.value.has(userId)) {
    return userAvatarCache.value.get(userId)
  }
  
  try {
    // 尝试从后端获取用户头像
    const response = await axios.get(`/api/user/${userId}/avatar`)
    if (response.data?.data?.avatarUrl) {
      const avatarUrl = response.data.data.avatarUrl
      userAvatarCache.value.set(userId, avatarUrl)
      return avatarUrl
    }
  } catch (error) {
    console.warn(`获取用户 ${userName} (ID: ${userId}) 头像失败:`, error)
  }
  
  return null
}

// 统一头像选择：自己消息强制用当前头像（附带短期防缓存参数）
const getAvatarFor = (msg) => {
  const isMine = msg.senderId && props.currentUserId && String(msg.senderId) === String(props.currentUserId)
  
  if (isMine) {
    if (myAvatarUrl.value) {
      // 防止CDN/浏览器缓存老图：追加一个10秒粒度的时间片参数
      const tsBucket = Math.floor(Date.now() / 10000)
      try {
        const url = new URL(myAvatarUrl.value, window.location.origin)
        url.searchParams.set('t', String(tsBucket))
        return url.toString()
      } catch {
        return `${myAvatarUrl.value}${myAvatarUrl.value.includes('?') ? '&' : '?'}t=${tsBucket}`
      }
    }
    return null
  }
  
  // 对于其他用户的消息，优先使用缓存的头像
  if (msg.senderId && userAvatarCache.value.has(msg.senderId)) {
    return userAvatarCache.value.get(msg.senderId)
  }
  
  // 如果没有缓存，使用消息中的头像URL
  return msg.senderAvatar || null
}

// 确保发送前头像可用（若未加载则等待加载完成）
const ensureAvatarLoaded = async () => {
  // 优先从 Pinia store 直接获取头像
  if (userStore.currentUser?.avatarUrl) {
    myAvatarUrl.value = userStore.currentUser.avatarUrl
    propagateMyAvatarToSelfMessages()
    console.log('从 Pinia store 直接获取头像:', userStore.currentUser.avatarUrl)
    return
  }
  
  // 如果 Pinia store 中没有，尝试加载
  if (!myAvatarUrl.value) {
    await loadCurrentUserAvatar()
  }
  
  // 如果仍然没有头像，等待一小段时间再试一次
  if (!myAvatarUrl.value) {
    await new Promise(resolve => setTimeout(resolve, 100))
    await loadCurrentUserAvatar()
  }
}


// 安全解析时间戳，兼容常见时间字符串和数组格式
const parseTimestamp = (ts) => {
  if (!ts) return null
  if (ts instanceof Date) return Number.isNaN(ts.getTime()) ? null : ts
  if (typeof ts === 'number') {
    const d = new Date(ts)
    return Number.isNaN(d.getTime()) ? null : d
  }
  if (typeof ts === 'string') {
    const isoLike = ts.includes('T') ? ts : ts.replace(' ', 'T')
    let d = new Date(isoLike)
    if (!Number.isNaN(d.getTime())) return d
    d = new Date(isoLike.replace(/-/g, '/'))
    if (!Number.isNaN(d.getTime())) return d
  }
  // 处理后端返回的数组格式时间 [year, month, day, hour, minute, second]
  if (Array.isArray(ts) && ts.length >= 6) {
    try {
      // 注意：月份需要减1，因为JavaScript的Date构造函数中月份是从0开始的
      const [year, month, day, hour, minute, second] = ts
      const d = new Date(year, month - 1, day, hour, minute, second)
      if (!Number.isNaN(d.getTime())) return d
    } catch (e) {
      console.warn('解析数组时间格式失败:', ts, e)
    }
  }
  return null
}

// 获取当前本地时间字符串，避免时区问题
const getCurrentLocalTimeString = () => {
  const now = new Date()
  return now.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false
  }).replace(/\//g, '-')
}

// 将Date对象转换为本地时间字符串
const dateToLocalString = (date) => {
  if (!date || !(date instanceof Date)) return null
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false
  }).replace(/\//g, '-')
}

// 生成后端可解析的本地时间字符串（ISO本地，无时区，无毫秒）
const toLocalDateTimeString = (date) => {
  if (!date || !(date instanceof Date)) return null
  const pad = (n) => String(n).padStart(2, '0')
  const y = date.getFullYear()
  const M = pad(date.getMonth() + 1)
  const d = pad(date.getDate())
  const h = pad(date.getHours())
  const m = pad(date.getMinutes())
  const s = pad(date.getSeconds())
  return `${y}-${M}-${d}T${h}:${m}:${s}`
}

// 测试时间处理函数
const testTimeHandling = () => {
  const now = new Date()
  console.log('=== 时间处理测试 ===')
  console.log('当前时间对象:', now)
  console.log('当前本地时间字符串:', dateToLocalString(now))
  console.log('当前ISO时间:', now.toISOString())
  console.log('当前UTC时间:', now.toUTCString())
  console.log('浏览器时间字符串:', now.toString())
  console.log('==================')
}

// 通用文件上传到阿里云函数
const uploadFileToAliyun = async (file, fileType = 'file') => {
  try {
    ElMessage.info(`正在上传${fileType}到阿里云...`)
    
    console.log(`准备上传${fileType}:`, {
      fileName: file.name,
      fileSize: file.size,
      fileType: file.type,
      lastModified: file.lastModified
    })
    
    // 创建FormData上传文件
    const formData = new FormData()
    formData.append('file', file)
    
    // 验证文件是否正确添加到FormData
    console.log('FormData内容:')
    for (let [key, value] of formData.entries()) {
      console.log(`${key}:`, value)
    }
    
    // 直接使用图片上传API，因为它更简单且直接返回URL
    // 这个API实际上可以处理任何类型的文件，不仅仅是图片
    const apiUrl = '/api/xiaozhi/teacher/image'
    
    console.log('使用上传API:', apiUrl)
    
    // 调用阿里云上传API
    console.log('开始发送请求...')
    const response = await axios.post(apiUrl, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      timeout: 30000 // 30秒超时
    })
    console.log('请求完成，响应对象:', response)
    
    console.log(`${fileType}上传响应:`, response.data)
    console.log('响应状态:', response.status)
    console.log('响应头:', response.headers)
    
    // 处理响应 - 根据Result类的标准格式
    let fileUrl
    if (response.data && response.data.code === 200 && response.data.data) {
      // 标准Result格式: { code: 200, message: "操作成功", data: "url" }
      fileUrl = response.data.data
    } else if (response.data && response.data.code === 200 && response.data.message && response.data.message.startsWith('http')) {
      // 特殊格式: { code: 200, message: "url", data: null }
      fileUrl = response.data.message
    } else if (response.data && response.data.data) {
      // 兼容格式: { data: "url" }
      fileUrl = response.data.data
    } else if (response.data && typeof response.data === 'string') {
      // 直接返回URL字符串
      fileUrl = response.data
    } else {
      console.error('无法识别的响应格式:', response.data)
      throw new Error(`${fileType}上传响应格式错误，响应数据: ${JSON.stringify(response.data)}`)
    }
    
    console.log(`${fileType}上传成功，URL:`, fileUrl)
    ElMessage.success(`${fileType}上传成功`)
    
    return fileUrl
  } catch (error) {
    console.error(`${fileType}上传失败 - 详细错误:`, error)
    console.error('错误响应数据:', error.response?.data)
    console.error('错误状态码:', error.response?.status)
    console.error('错误状态文本:', error.response?.statusText)
    
    let errorMessage = `${fileType}上传失败`
    if (error.response?.data?.message) {
      errorMessage += `: ${error.response.data.message}`
    } else if (error.response?.data?.error) {
      errorMessage += `: ${error.response.data.error}`
    } else if (error.message) {
      errorMessage += `: ${error.message}`
    }
    
    ElMessage.error(errorMessage)
    throw error
  }
}

// 统一按时间升序排序，确保新消息在底部
const sortMessages = () => {
  const toMs = (t) => {
    const d = parseTimestamp(t)
    return d ? d.getTime() : Number.POSITIVE_INFINITY
  }
  
  console.log('排序前的消息:', messages.value.map(m => ({
    id: m.id,
    sender: m.sender,
    content: m.content,
    timestamp: m.timestamp,
    timeMs: toMs(m.timestamp)
  })))
  
  messages.value.sort((a, b) => {
    const ta = toMs(a.timestamp)
    const tb = toMs(b.timestamp)
    if (ta !== tb) return ta - tb
    // 次级稳定排序：优先使用后端id/或稳定字符串id
    const ida = String(a.id ?? '')
    const idb = String(b.id ?? '')
    if (ida !== idb) return ida.localeCompare(idb)
    const sa = String(a.sender ?? '')
    const sb = String(b.sender ?? '')
    if (sa !== sb) return sa.localeCompare(sb)
    const ca = String(a.content ?? '')
    const cb = String(b.content ?? '')
    return ca.localeCompare(cb)
  })
  
  console.log('排序后的消息:', messages.value.map(m => ({
    id: m.id,
    sender: m.sender,
    content: m.content,
    timestamp: m.timestamp,
    timeMs: toMs(m.timestamp)
  })))
}

// 根据 clientMsgId 查找已存在消息索引
const findMsgIndexByClientId = (clientId) => {
  if (!clientId) return -1
  return messages.value.findIndex(m => m.clientMsgId && m.clientMsgId === clientId)
}



// WebSocket连接
const initWebSocket = () => {
  const wsUrl = `/ws/chat?courseId=${props.courseId}`
  socket.value = new WebSocket(wsUrl)

  socket.value.onopen = () => {
    ElMessage.success('已连接到群聊')
  }

  socket.value.onmessage = (event) => {
    try {
      const data = JSON.parse(event.data)
      console.log('接收到WebSocket消息:', data) // 调试信息
      
      const idx = findMsgIndexByClientId(data.clientMsgId)
      const incoming = {
        id: data.id ?? data.clientMsgId ?? `${data.sender}-${+parseTimestamp(data.timestamp)}-${data.type ?? 'text'}`,
        sender: data.sender,
        senderId: data.senderId ?? data.userId ?? null,
        senderAvatar: data.senderAvatar ?? data.senderAvatarUrl ?? data.avatarUrl ?? null,
        content: data.content,
        type: data.type,
        fileName: data.fileName,
        fileSize: data.fileSize,
        stickerName: data.stickerName,
        duration: data.duration,
        timestamp: parseTimestamp(data.timestamp),
        clientMsgId: data.clientMsgId
      }
      
      console.log('处理后的WebSocket消息:', incoming) // 调试信息
      
      const isMineIncoming = (incoming.senderId && props.currentUserId && String(incoming.senderId) === String(props.currentUserId))
      if (isMineIncoming) {
        incoming.senderAvatar = myAvatarUrl.value || null
      }
      if (idx >= 0) {
        // 更新已有本地消息（填充服务端id/时间等）
        messages.value[idx] = { ...messages.value[idx], ...incoming }
        console.log('更新已有消息，索引:', idx)
      } else {
        messages.value.push(incoming)
        console.log('添加新WebSocket消息')
      }
      
      // 重新排序并滚动到底部
      sortMessages()
      scrollToBottom()
    } catch (error) {
      console.error('解析WebSocket消息失败:', error)
    }
  }

  socket.value.onerror = () => {
    ElMessage.error('连接失败')
  }
}

// 发送消息
const sendMessage = async () => {
  if (!newMessage.value.trim() && !selectedFile.value) return

  // 确保头像已加载
  await ensureAvatarLoaded()
  
  // 再次确认头像是否已设置，如果还没有则直接从 Pinia store 获取
  if (!myAvatarUrl.value && userStore.currentUser?.avatarUrl) {
    myAvatarUrl.value = userStore.currentUser.avatarUrl
    console.log('发送消息时从 Pinia store 获取头像:', userStore.currentUser.avatarUrl)
  }
  
  let message = {
    sender: props.currentUser,
    senderId: props.currentUserId ? String(props.currentUserId) : null,
    senderAvatar: myAvatarUrl.value || userStore.currentUser?.avatarUrl,
    timestamp: new Date()
  }
  
  console.log('发送消息时的头像状态:', {
    myAvatarUrl: myAvatarUrl.value,
    piniaAvatar: userStore.currentUser?.avatarUrl,
    senderAvatar: message.senderAvatar
  })
  
  console.log('准备发送消息:', {
    ...message,
    localTime: dateToLocalString(message.timestamp),
    isoTime: message.timestamp.toISOString(),
    utcTime: message.timestamp.toUTCString(),
    browserTime: new Date().toString()
  }) // 调试信息

  if (selectedFile.value) {
    // 发送文件
    message = {
      ...message,
      type: selectedFile.value.type,
      content: selectedFile.value.url,
      fileName: selectedFile.value.name,
      fileSize: selectedFile.value.size
    }
    console.log('发送文件消息:', message) // 调试信息
    selectedFile.value = null
  } else {
    // 发送文本
    message = {
      ...message,
      type: 'text',
      content: newMessage.value.trim()
    }
  }

  // 为消息生成客户端唯一ID（用于去重）
  const clientMsgId = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`

  // 先本地添加（乐观更新），收到服务端回执后用 clientMsgId 去重/更新
  const newMsg = {
    id: clientMsgId,
    ...message,
    clientMsgId
  }
  messages.value.push(newMsg)
  if (socket.value?.readyState === WebSocket.OPEN) {
    socket.value.send(JSON.stringify({ ...message, clientMsgId }))
  }

  newMessage.value = ''
  
  // 立即滚动到底部，确保新消息可见
  scrollToBottom()
  
  // 后台持久化
  try {
    const courseId = parseInt(props.courseId, 10)
    if (Number.isNaN(courseId)) {
      ElMessage.error('课程ID无效，无法保存消息')
    } else {
      // 确保发送到后端的时间是本地时间字符串，避免时区问题
      const localTimeString = dateToLocalString(message.timestamp)
      
      console.log('发送到后端的时间:', {
        original: message.timestamp,
        localString: localTimeString,
        isoString: message.timestamp.toISOString(),
        utcString: message.timestamp.toUTCString()
      })
      
      // 对于文件和图片消息，content应该是阿里云URL，不是描述性文本
      let messageContent = message.content
      if (message.type === 'file' || message.type === 'image') {
        // 使用阿里云URL，这样在数据库中就能保存真实的文件链接
        messageContent = message.content
      }
      
      // 尝试不同的字段名组合，确保与后端期望的格式匹配
      const requestData = {
        courseId: courseId,
        senderName: message.sender,
        senderId: message.senderId,
        messageContent: messageContent,
        messageType: message.type,
        fileName: message.fileName || null,
        fileSize: message.fileSize || null,
        duration: message.duration || null,
        sentAt: localTimeString
      }
      
      // 也尝试发送一个简化版本，只包含必填字段
      const simpleRequestData = {
        courseId: courseId,
        senderName: message.sender,
        senderId: message.senderId,
        messageContent: messageContent
      }
      
      // 尝试不同的字段名组合，可能是后端期望不同的字段名
      const alternativeRequestData = {
        course_id: courseId,
        sender_name: message.sender,
        sender_id: message.senderId,
        message: messageContent,
        message_type: message.type
      }
      
      console.log('替代字段名请求数据:', alternativeRequestData)
      
      console.log('完整请求数据:', requestData)
      console.log('简化请求数据:', simpleRequestData)
      
      console.log('发送到后端的完整请求数据:', requestData)
      
      // 验证必填字段
      if (!requestData.courseId || !requestData.senderName || !requestData.messageContent) {
        console.error('缺少必填字段:', {
          courseId: requestData.courseId,
          senderName: requestData.senderName,
          messageContent: requestData.messageContent
        })
        throw new Error('缺少必填字段')
      }
      
      // 验证courseId是否为有效数字
      if (isNaN(requestData.courseId) || requestData.courseId <= 0) {
        console.error('无效的courseId:', requestData.courseId)
        throw new Error('无效的课程ID')
      }
      
      // 先尝试发送简化版本，只包含必填字段
      try {
        console.log('尝试发送简化请求...')
        await axios.post('/api/chat/save', simpleRequestData)
        console.log('简化请求成功！')
      } catch (simpleError) {
        console.log('简化请求失败，尝试替代字段名请求...')
        console.error('简化请求错误:', simpleError.response?.data)
        
        try {
          await axios.post('/api/chat/save', alternativeRequestData)
          console.log('替代字段名请求成功！')
        } catch (alternativeError) {
          console.log('替代字段名请求失败，尝试完整请求...')
          console.error('替代字段名请求错误:', alternativeError.response?.data)
          
          // 如果替代字段名请求也失败，尝试完整请求
          await axios.post('/api/chat/save', requestData)
        }
      }
      // 若无服务端回显且本地不存在该消息，则补插入
      const idx = findMsgIndexByClientId(clientMsgId)
      if (idx < 0) {
        messages.value.push({ id: clientMsgId, ...message, clientMsgId })
        // 重新排序并滚动到底部
        sortMessages()
        scrollToBottom()
      }
    }
  } catch (e) {
    console.error('保存聊天记录失败 - 详细错误:', e)
    console.error('错误响应数据:', e.response?.data)
    console.error('错误状态码:', e.response?.status)
    console.error('错误状态文本:', e.response?.statusText)
    
    let errorMessage = '保存聊天记录失败'
    if (e.response?.data?.message) {
      errorMessage += `: ${e.response.data.message}`
    } else if (e.response?.data?.error) {
      errorMessage += `: ${e.response.data.error}`
    }
    
    ElMessage.error(errorMessage)
  }
  
  // 确保消息按时间排序并滚动到底部
  sortMessages()
  scrollToBottom()
  nextTick(() => inputRef.value?.focus())
}

// 处理回车键
const handleEnterPress = (event) => {
  if (event.shiftKey) {
    // Shift + Enter 换行
    return
  }
  sendMessage()
}

// 切换Emoji选择器
const toggleEmojiPicker = () => {
  if (emojiPickerVisible.value) {
    closeEmojiPicker()
  } else {
    closeStickerPicker() // 关闭表情包选择器
    emojiPickerVisible.value = true
  }
}

// 关闭Emoji选择器
const closeEmojiPicker = () => {
  emojiPickerVisible.value = false
}

// 切换表情包选择器
const toggleStickerPicker = () => {
  if (stickerPickerVisible.value) {
    closeStickerPicker()
  } else {
    closeEmojiPicker() // 关闭emoji选择器
    stickerPickerVisible.value = true
  }
}

// 关闭表情包选择器
const closeStickerPicker = () => {
  stickerPickerVisible.value = false
}

// 处理输入框点击
const handleInputClick = () => {
  if (emojiPickerVisible.value) {
    closeEmojiPicker()
  }
  if (stickerPickerVisible.value) {
    closeStickerPicker()
  }
}

// 切换语音输入
const toggleVoiceInput = async () => {
  if (isRecording.value) {
    stopRecording()
  } else {
    await startRecording()
  }
}

// 开始录音
const startRecording = async () => {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
    mediaRecorder.value = new MediaRecorder(stream)
    audioChunks.value = []
    recordingDuration.value = 0
    
    mediaRecorder.value.ondataavailable = (event) => {
      audioChunks.value.push(event.data)
    }
    
    mediaRecorder.value.onstop = () => {
      const audioBlob = new Blob(audioChunks.value, { type: 'audio/wav' })
      sendVoiceMessage(audioBlob)
      stream.getTracks().forEach(track => track.stop())
    }
    
    mediaRecorder.value.start()
    isRecording.value = true
    
    // 开始计时
    recordingTimer.value = setInterval(() => {
      recordingDuration.value++
    }, 1000)
    
    ElMessage.success('开始录音，点击按钮停止')
  } catch (error) {
    console.error('录音失败:', error)
    ElMessage.error('无法访问麦克风，请检查权限设置')
  }
}

// 停止录音
const stopRecording = () => {
  if (mediaRecorder.value && isRecording.value) {
    mediaRecorder.value.stop()
    isRecording.value = false
    
    if (recordingTimer.value) {
      clearInterval(recordingTimer.value)
      recordingTimer.value = null
    }
    
    recordingDuration.value = 0
  }
}

// 获取音频时长（秒）
const getBlobDuration = (blob) => new Promise(async (resolve) => {
  // 方案1：WebAudio精确解码
  try {
    const arrayBuffer = await blob.arrayBuffer()
    const ctx = new (window.AudioContext || window.webkitAudioContext)()
    ctx.decodeAudioData(
      arrayBuffer.slice(0),
      (buffer) => {
        const d = Math.max(1, Math.round(buffer.duration))
        ctx.close?.()
        resolve(d)
      },
      () => {
        ctx.close?.()
        // 方案2：回退到audio标签metadata
        try {
          const audio = document.createElement('audio')
          audio.preload = 'metadata'
          const url = URL.createObjectURL(blob)
          audio.src = url
          audio.onloadedmetadata = () => {
            let d = Math.max(1, Math.round(audio.duration || 0))
            URL.revokeObjectURL(url)
            resolve(d)
          }
          audio.onerror = () => {
            URL.revokeObjectURL(url)
            resolve(1)
          }
        } catch {
          resolve(1)
        }
      }
    )
    return
  } catch {}
  // 最终兜底
  resolve(1)
})

// 发送语音消息
const sendVoiceMessage = async (audioBlob) => {
  try {
    await ensureAvatarLoaded()
    
    // 确保头像已设置
    if (!myAvatarUrl.value && userStore.currentUser?.avatarUrl) {
      myAvatarUrl.value = userStore.currentUser.avatarUrl
    }
    
    // 将音频blob转换为文件
    const audioFile = new File([audioBlob], `voice_${Date.now()}.wav`, { type: 'audio/wav' })
    
    // 上传到阿里云
    const audioUrl = await uploadFileToAliyun(audioFile, '语音')
    console.log('语音文件上传结果:', audioUrl)
    
    if (!audioUrl) {
      throw new Error('语音文件上传失败，未获得URL')
    }
    
    const duration = await getBlobDuration(audioBlob)
    
    const message = {
      sender: props.currentUser,
      senderId: props.currentUserId ? String(props.currentUserId) : null,
      type: 'voice',
      content: audioUrl, // 使用阿里云URL
      duration: duration,
      senderAvatar: myAvatarUrl.value || userStore.currentUser?.avatarUrl,
      timestamp: new Date()
    }
    
    console.log('准备发送语音消息:', {
      ...message,
      localTime: dateToLocalString(message.timestamp),
      isoTime: message.timestamp.toISOString(),
      utcTime: message.timestamp.toUTCString(),
      browserTime: new Date().toString()
    })
    
    const clientMsgId = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`

    // 本地乐观加入
    const newVoiceMsg = { id: clientMsgId, ...message, clientMsgId }
    messages.value.push(newVoiceMsg)
    if (socket.value?.readyState === WebSocket.OPEN) {
      socket.value.send(JSON.stringify({ ...message, clientMsgId }))
    }
    
    // 立即滚动到底部，确保新语音消息可见
    scrollToBottom()
    
    // 保存到数据库
    try {
      const courseId = parseInt(props.courseId, 10)
      if (Number.isNaN(courseId)) {
        ElMessage.error('课程ID无效，无法保存语音消息')
      } else {
        // 确保发送到后端的时间是本地时间字符串，避免时区问题
        const localTimeString = dateToLocalString(message.timestamp)
        const sentAtISO8601Local = toLocalDateTimeString(message.timestamp)
        
        // 使用正确的字段格式，匹配后端ChatMessageRequest类
        const correctRequestData = {
          courseId: parseInt(courseId, 10),
          senderName: message.sender,
          senderId: message.senderId,
          messageContent: audioUrl,
          messageType: message.type,
          duration: message.duration || null,
          sentAt: sentAtISO8601Local
        }
        
        console.log('发送语音消息到后端 - 正确格式:', correctRequestData)
        console.log('调试信息 - courseId:', {
          original: props.courseId,
          parsed: courseId,
          type: typeof courseId,
          isNaN: isNaN(courseId)
        })
        
        // 验证必填字段
        if (!courseId || !message.sender || !audioUrl) {
          throw new Error('语音消息缺少必填字段')
        }
        
        // 验证courseId是否为有效数字
        if (isNaN(courseId) || courseId <= 0) {
          throw new Error('语音消息无效的课程ID')
        }
        
        // 使用正确的格式保存
        console.log('使用正确格式保存语音消息...')
        console.log('发送的请求数据:', JSON.stringify(correctRequestData, null, 2))
        
        // 以 JSON 提交，Content-Type: application/json
        const saveResponse = await axios.post('/api/chat/save', correctRequestData, {
          headers: {
            'Content-Type': 'application/json'
          }
        })
        console.log('语音消息保存成功，响应:', saveResponse.data)
      }
    } catch (e) {
      console.error('保存语音消息失败:', e)
      console.error('错误响应数据:', JSON.stringify(e.response?.data, null, 2))
      console.error('错误状态码:', e.response?.status)
      console.error('错误状态文本:', e.response?.statusText)
      console.error('完整错误对象:', e)
      ElMessage.error(`保存语音消息失败: ${e.message}`)
    }
    
    // 确保消息按时间排序并滚动到底部
    sortMessages()
    scrollToBottom()
    
  } catch (error) {
    console.error('语音上传失败:', error)
    ElMessage.error(`语音上传失败: ${error.message}`)
  }
}

const safeDuration = (d) => {
  const n = parseInt(d, 10)
  if (Number.isNaN(n) || n <= 0) return 1
  return n
}

// 显示Emoji选择器
const showEmojiPicker = () => {
  emojiPickerVisible.value = true
}

// 插入Emoji
const insertEmoji = (emoji) => {
  newMessage.value += emoji
  
  // 添加到最近使用
  if (!recentEmojis.value.includes(emoji)) {
    recentEmojis.value.unshift(emoji)
    if (recentEmojis.value.length > 6) {
      recentEmojis.value.pop()
    }
  }
  
  closeEmojiPicker()
  nextTick(() => inputRef.value?.focus())
}

// 显示表情包选择器
const showStickerPicker = () => {
  stickerPickerVisible.value = true
}

// 发送表情包
const sendSticker = (sticker) => {
  // 确保头像已设置
  if (!myAvatarUrl.value && userStore.currentUser?.avatarUrl) {
    myAvatarUrl.value = userStore.currentUser.avatarUrl
  }
  
  const clientMsgId = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`
  const message = {
    sender: props.currentUser,
    senderId: props.currentUserId ? String(props.currentUserId) : null,
    type: 'sticker',
    content: sticker.url,
    stickerName: sticker.name,
    senderAvatar: myAvatarUrl.value || userStore.currentUser?.avatarUrl,
    timestamp: new Date(),
    clientMsgId
  }
  
  console.log('准备发送表情包消息:', {
    ...message,
    localTime: dateToLocalString(message.timestamp),
    isoTime: message.timestamp.toISOString(),
    utcTime: message.timestamp.toUTCString(),
    browserTime: new Date().toString()
  }) // 调试信息

  // 添加到最近使用
  if (!recentStickers.value.find(s => s.id === sticker.id)) {
    recentStickers.value.unshift(sticker)
    if (recentStickers.value.length > 4) {
      recentStickers.value.pop()
    }
  }

  // 先本地添加消息（乐观更新）
  const newMsg = {
    id: clientMsgId,
    ...message
  }
  messages.value.push(newMsg)
  
  // 立即滚动到底部
  scrollToBottom()
  
  // 发送给服务器
  if (socket.value?.readyState === WebSocket.OPEN) {
    socket.value.send(JSON.stringify(message))
  }

  closeStickerPicker()
}

// 显示文件上传
const showFileUpload = () => {
  fileInput.value?.click()
}

// 处理文件选择
const handleFileSelect = async (event) => {
  const files = event.target.files
  if (files.length > 0) {
    const file = files[0]
    
    try {
      const fileUrl = await uploadFileToAliyun(file, '文件')
      selectedFile.value = {
        type: 'file',
        url: fileUrl,
        name: file.name,
        size: file.size
      }
    } catch (error) {
      // 错误已经在uploadFileToAliyun中处理了
    }
  }
  event.target.value = '' // 清空input
}

// 显示图片上传
const showImageUpload = () => {
  imageInput.value?.click()
}

// 处理图片选择
const handleImageSelect = async (event) => {
  const files = event.target.files
  if (files.length > 0) {
    const file = files[0]
    if (file.type.startsWith('image/')) {
      try {
        const imageUrl = await uploadFileToAliyun(file, '图片')
        selectedFile.value = {
          type: 'image',
          url: imageUrl,
          name: file.name,
          size: file.size
        }
      } catch (error) {
        // 错误已经在uploadFileToAliyun中处理了
      }
    } else {
      ElMessage.error('请选择图片文件')
    }
  }
  event.target.value = '' // 清空input
}

// 预览图片
const previewImage = (url) => {
  // 这里可以实现图片预览功能
  window.open(url, '_blank')
}

// 下载文件
const downloadFile = (url, fileName) => {
  const link = document.createElement('a')
  link.href = url
  link.download = fileName
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

// 播放语音
const playVoice = (audioUrl) => {
  const audio = new Audio(audioUrl)
  audio.play().catch(error => {
    console.error('播放失败:', error)
    ElMessage.error('播放失败')
  })
}

// 格式化文件大小
const formatFileSize = (bytes) => {
  if (!bytes || bytes === 0) return '未知大小'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

// 滚动到底部
const scrollToBottom = () => {
  nextTick(() => {
    if (messagesRef.value) {
      // 确保滚动到最底部
      const scrollHeight = messagesRef.value.scrollHeight
      const clientHeight = messagesRef.value.clientHeight
      const maxScrollTop = scrollHeight - clientHeight
      messagesRef.value.scrollTop = maxScrollTop
      
      // 调试信息
      console.log('滚动到底部:', {
        scrollHeight,
        clientHeight,
        maxScrollTop,
        currentScrollTop: messagesRef.value.scrollTop,
        messagesCount: messages.value.length
      })
      
      // 如果第一次滚动失败，再次尝试
      setTimeout(() => {
        if (messagesRef.value) {
          const currentScrollTop = messagesRef.value.scrollTop
          const targetScrollTop = messagesRef.value.scrollHeight - messagesRef.value.clientHeight
          if (Math.abs(currentScrollTop - targetScrollTop) > 10) {
            messagesRef.value.scrollTop = targetScrollTop
            console.log('二次滚动到底部:', targetScrollTop)
          }
        }
      }, 100)
    }
  })
}

// 格式化时间
const formatTime = (timestamp) => {
  const date = parseTimestamp(timestamp)
  if (!date) return ''
  return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

// 监听消息变化，确保新消息出现后滚动到底部
watch(messages, () => {
  nextTick(() => {
    scrollToBottom()
  })
}, { deep: true })

// 点击外部区域关闭面板
const handleClickOutside = (event) => {
  // 检查点击的是否是工具栏按钮
  const toolbarBtn = event.target.closest('.toolbar-btn')
  if (toolbarBtn) {
    return // 如果是工具栏按钮，不关闭面板
  }
  
  const emojiPanel = document.querySelector('.emoji-panel')
  const stickerPanel = document.querySelector('.sticker-panel')
  
  if (emojiPanel && !emojiPanel.contains(event.target) && emojiPickerVisible.value) {
    closeEmojiPicker()
  }
  
  if (stickerPanel && !stickerPanel.contains(event.target) && stickerPickerVisible.value) {
    closeStickerPicker()
  }
}



onMounted(async () => {
  // 首先加载当前用户头像
  await loadCurrentUserAvatar()
  
  // 如果课程切换（父组件销毁重建更彻底；此处留存以支持未来的 prop 变更）
  watch(() => props.courseId, (newId, oldId) => {
    if (newId !== oldId) {
      if (socket.value) {
        try { socket.value.close() } catch {}
      }
      messages.value = []
      nextTick(() => {
        const courseId = parseInt(String(newId), 10)
        if (!Number.isNaN(courseId)) {
          axios.get('/api/chat/history', { params: { courseId, limit: 200, offset: 0 } })
            .then(res => {
              const list = res.data?.data || []
              messages.value = list.map(it => ({
                id: it.id,
                sender: it.senderName,
                senderId: it.senderId ?? it.userId ?? null,
                content: it.message,
                type: it.messageType,
                fileName: it.fileName,
                fileSize: it.fileSize,
                duration: it.duration,
                timestamp: parseTimestamp(it.sentAt),
                senderAvatar: ((it.senderId ?? it.userId) && props.currentUserId && String(it.senderId ?? it.userId) === String(props.currentUserId))
                  ? (myAvatarUrl.value || it.senderAvatar || it.senderAvatarUrl || it.avatarUrl || null)
                  : (it.senderAvatar || it.senderAvatarUrl || it.avatarUrl || null)
              }))
              sortMessages()
              nextTick(scrollToBottom)
            })
            .finally(() => initWebSocket())
        }
      })
    }
  })
  // 测试时间处理
  testTimeHandling()
  
  // 加载当前用户头像
  loadCurrentUserAvatar()
  // 监听本地头像变更（跨页面/同页更新）
  if (!storageListenerBound) {
    const onStorage = (e) => {
      if (!e) return
      const keys = ['teacherAvatarUrl', 'studentAvatarUrl']
      if (keys.includes(e.key)) {
        try {
          const newVal = e.newValue
          if (newVal && newVal !== myAvatarUrl.value) {
            myAvatarUrl.value = newVal
            propagateMyAvatarToSelfMessages()
          }
        } catch {}
      }
    }
    try {
      window.addEventListener('storage', onStorage)
      storageListenerBound = true
    } catch {}
  }
  
  // 加载聊天历史记录
  const loadChatHistory = async () => {
    const courseId = parseInt(props.courseId, 10)
    if (Number.isNaN(courseId)) {
      ElMessage.error('课程ID无效，无法加载历史记录')
      return
    }
    
    try {
      const response = await axios.get('/api/chat/history', { 
        params: { courseId, limit: 200, offset: 0 } 
      })
      
      const list = response.data?.data || []
      console.log('加载历史记录:', list)
      
      // 先处理消息数据
      const processedMessages = list.map(it => {
        const ts = parseTimestamp(it.sentAt)
        const stableId = it.id ?? `${it.senderName ?? ''}-${it.messageType ?? ''}-${it.fileName ?? ''}-${+ts}`
        
        // 智能检测消息类型
        let messageType = it.messageType
        if (it.message && it.message.startsWith('http') && (it.message.includes('.jpg') || it.message.includes('.jpeg') || it.message.includes('.png') || it.message.includes('.gif') || it.message.includes('.webp'))) {
          messageType = 'image'
        } else if (it.message && it.message.startsWith('http') && (it.message.includes('.docx') || it.message.includes('.doc') || it.message.includes('.pdf') || it.message.includes('.txt') || it.message.includes('.xlsx') || it.message.includes('.xls') || it.message.includes('.ppt') || it.message.includes('.pptx'))) {
          messageType = 'file'
        }
        
        // 为文件消息提取文件名
        let fileName = it.fileName
        if (messageType === 'file' && !fileName && it.message) {
          try {
            const url = new URL(it.message)
            const pathParts = url.pathname.split('/')
            let extractedFileName = pathParts[pathParts.length - 1] || '未知文件'
            try {
              extractedFileName = decodeURIComponent(extractedFileName)
            } catch (e) {
              console.warn('URL解码失败:', e)
            }
            if (extractedFileName.length > 30) {
              const extension = extractedFileName.split('.').pop()
              const nameWithoutExt = extractedFileName.substring(0, extractedFileName.lastIndexOf('.'))
              extractedFileName = nameWithoutExt.substring(0, 25) + '...' + (extension ? '.' + extension : '')
            }
            fileName = extractedFileName
          } catch (e) {
            fileName = '未知文件'
          }
        }
        
        return {
          id: stableId,
          sender: it.senderName,
          senderId: it.senderId ?? it.userId ?? null,
          senderAvatar: it.senderAvatar || it.senderAvatarUrl || it.avatarUrl || null,
          content: it.message,
          type: messageType,
          fileName: fileName || it.fileName,
          fileSize: it.fileSize,
          duration: it.duration,
          timestamp: ts
        }
      })
      
      // 设置消息
      messages.value = processedMessages
      
      // 加载所有用户的头像
      const uniqueUsers = new Set()
      processedMessages.forEach(msg => {
        if (msg.senderId && !uniqueUsers.has(msg.senderId)) {
          uniqueUsers.add(msg.senderId)
        }
      })
      
      // 并行加载所有用户头像
      const avatarPromises = Array.from(uniqueUsers).map(userId => {
        const userMsg = processedMessages.find(msg => msg.senderId === userId)
        return loadUserAvatar(userId, userMsg?.sender)
      })
      
      await Promise.all(avatarPromises)
      
      // 重新处理消息，应用加载的头像
      messages.value = processedMessages.map(msg => ({
        ...msg,
        senderAvatar: getAvatarFor(msg)
      }))
      
      console.log('处理后的消息:', messages.value)
      
      // 排序并滚动到底部
      sortMessages()
      scrollToBottom()
      
    } catch (error) {
      console.error('加载聊天历史失败:', error)
      ElMessage.error('加载聊天历史失败')
    }
  }
  
  // 调用加载历史记录
  loadChatHistory().finally(() => {
    initWebSocket()
    document.addEventListener('click', handleClickOutside)
  })
})

// 组件卸载时移除事件监听
onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
  if (socket.value) {
    socket.value.close()
  }
  try {
    if (storageListenerBound) {
      // 移除storage监听，避免内存泄漏
      window.removeEventListener('storage', () => {})
      storageListenerBound = false
    }
  } catch {}
  
  // 清理录音资源
  if (isRecording.value) {
    stopRecording()
  }
  if (recordingTimer.value) {
    clearInterval(recordingTimer.value)
  }
})
</script>

<style scoped>
.wechat-chat {
  display: flex;
  flex-direction: column;
  height: 100%;
  width: 100%;
  background: #f5f5f5;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  position: relative;
}

.chat-header {
  background: linear-gradient(135deg, #07c160, #00a854);
  color: white;
  padding: 16px 20px;
  box-shadow: 0 2px 8px rgba(7, 193, 96, 0.3);
}

.header-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.avatar {
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 18px;
}

.info .title {
  font-weight: 600;
  font-size: 16px;
}

.info .status {
  font-size: 12px;
  opacity: 0.9;
  margin-top: 2px;
}

.chat-messages {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background: #f5f5f5;
  scrollbar-width: none; /* Firefox */
  -ms-overflow-style: none; /* IE and Edge */
  /* 确保滚动行为正常 */
  scroll-behavior: smooth;
  /* 强制滚动到底部 */
  display: flex;
  flex-direction: column;
}

.chat-messages::-webkit-scrollbar {
  display: none; /* Chrome, Safari and Opera */
}

.message {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  margin-bottom: 16px;
  /* 确保消息项正确排列 */
  flex-shrink: 0;
}

.message.mine {
  flex-direction: row-reverse;
}

.message .avatar {
  width: 36px;
  height: 36px;
  background: linear-gradient(135deg, #409eff, #66b1ff);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 14px;
  flex-shrink: 0;
  overflow: hidden;
}

.message .avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}

.message.mine .avatar {
  background: linear-gradient(135deg, #07c160, #00a854);
}

.message.mine .avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}

.bubble {
  max-width: 70%;
  background: white;
  border-radius: 18px;
  padding: 12px 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.message.mine .bubble {
  background: linear-gradient(135deg, #07c160, #00a854);
  color: white;
}

.bubble .name {
  font-size: 12px;
  color: #666;
  margin-bottom: 4px;
  font-weight: 500;
}

.message.mine .bubble .name {
  color: rgba(255, 255, 255, 0.8);
}

.bubble .content {
  font-size: 14px;
  line-height: 1.4;
  word-wrap: break-word;
}

.bubble .time {
  font-size: 11px;
  color: #999;
  margin-top: 4px;
  text-align: right;
}

.message.mine .bubble .time {
  color: rgba(255, 255, 255, 0.7);
}

.chat-input {
  background: white;
  border-top: 1px solid #e0e0e0;
  padding: 16px 20px;
  position: relative;
  z-index: 10001;
  transition: transform 0.3s ease-out;
}





.input-toolbar {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}

.toolbar-btn {
  padding: 8px 12px;
  border-radius: 8px;
  font-size: 16px;
  transition: all 0.3s ease;
  background: transparent;
  border: 1px solid transparent;
}

.toolbar-btn:hover {
  background: #f0f0f0;
  transform: scale(1.1);
}

.input-container {
  display: flex;
  gap: 12px;
  align-items: flex-end;
}

.input-container .el-textarea {
  flex: 1;
}

.input-container .el-textarea__inner {
  border-radius: 20px;
  border: 1px solid #e0e0e0;
  padding: 12px 16px;
  resize: none;
  transition: all 0.3s ease;
}

.input-container .el-textarea__inner:focus {
  border-color: #07c160;
  box-shadow: 0 0 0 2px rgba(7, 193, 96, 0.2);
}

.input-container .el-button {
  background: linear-gradient(135deg, #07c160, #00a854);
  border: none;
  border-radius: 20px;
  padding: 12px 24px;
  font-weight: 600;
  transition: all 0.3s ease;
}

.input-container .el-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(7, 193, 96, 0.4);
}

.input-container .el-button:disabled {
  background: #ccc;
  cursor: not-allowed;
}

/* Emoji选择器样式 */
.emoji-panel {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  width: 100%;
  height: 350px;
  background: white;
  border-top: 1px solid #e0e0e0;
  border-left: 1px solid #e0e0e0;
  border-right: 1px solid #e0e0e0;
  border-radius: 12px 12px 0 0;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
  z-index: 9999;
  display: flex;
  flex-direction: column;
  transform: translateY(0);
  animation: slideUp 0.3s ease-out;
}

/* 面板内的输入框区域 */
.panel-input-section {
  padding: 16px 20px;
  border-bottom: 1px solid #e0e0e0;
  background: white;
}

.panel-input-section .input-container {
  display: flex;
  gap: 12px;
  align-items: flex-end;
}

.panel-input-section .input-container .el-textarea {
  flex: 1;
}

.panel-input-section .input-container .el-textarea__inner {
  border-radius: 20px;
  border: 1px solid #e0e0e0;
  padding: 12px 16px;
  resize: none;
  transition: all 0.3s ease;
}

.panel-input-section .input-container .el-textarea__inner:focus {
  border-color: #07c160;
  box-shadow: 0 0 0 2px rgba(7, 193, 96, 0.2);
}

.panel-input-section .input-container .el-button {
  background: linear-gradient(135deg, #07c160, #00a854);
  border: none;
  border-radius: 20px;
  padding: 12px 24px;
  font-weight: 600;
  transition: all 0.3s ease;
}

.panel-input-section .input-container .el-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(7, 193, 96, 0.4);
}

.panel-input-section .input-container .el-button:disabled {
  background: #ccc;
  cursor: not-allowed;
}



@keyframes slideUp {
  0% {
    transform: translateY(100%);
  }
  100% {
    transform: translateY(0);
  }
}

@keyframes slideUpWithInput {
  0% {
    transform: translateY(100%);
  }
  100% {
    transform: translateY(0);
  }
}

/* 表情包选择器样式 */
.sticker-panel {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  width: 100%;
  height: 400px;
  background: white;
  border-top: 1px solid #e0e0e0;
  border-left: 1px solid #e0e0e0;
  border-right: 1px solid #e0e0e0;
  border-radius: 12px 12px 0 0;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
  z-index: 9999;
  display: flex;
  flex-direction: column;
  transform: translateY(0);
  animation: slideUp 0.3s ease-out;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #e0e0e0;
  background: #f8f8f8;
}

.panel-tabs {
  display: flex;
  gap: 8px;
}

.tab-item {
  padding: 6px 10px;
  border-radius: 16px;
  background: #f0f0f0;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.2s ease;
  min-width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.tab-item.active {
  background: #07c160;
  color: white;
  font-weight: 600;
}

.panel-close {
  font-size: 20px;
  cursor: pointer;
  color: #666;
  transition: color 0.2s ease;
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
}

.panel-close:hover {
  color: #333;
  background: #f0f0f0;
}

.panel-content {
  padding: 16px;
  overflow-y: auto;
  flex: 1;
  scrollbar-width: none; /* Firefox */
  -ms-overflow-style: none; /* IE and Edge */
}

.panel-content::-webkit-scrollbar {
  display: none; /* Chrome, Safari and Opera */
}

.category-label {
  font-size: 13px;
  color: #999;
  margin-bottom: 8px;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.emoji-grid {
  display: grid;
  grid-template-columns: repeat(8, 1fr);
  gap: 6px;
  margin-bottom: 16px;
}

.emoji-item {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  font-size: 16px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.emoji-item:hover {
  background: #f5f5f5;
  transform: scale(1.1);
}

.sticker-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
  margin-bottom: 16px;
}

.sticker-item {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 70px;
  height: 70px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 2px solid transparent;
  background: #f8f8f8;
}

.sticker-item:hover {
  border-color: #07c160;
  transform: scale(1.05);
  background: #f0f0f0;
}

.sticker-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 6px;
}

/* 消息内容样式 */
.sticker-content {
  text-align: center;
}

.sticker-image {
  max-width: 120px;
  max-height: 120px;
  border-radius: 8px;
  cursor: pointer;
  transition: transform 0.3s ease;
}

.sticker-image:hover {
  transform: scale(1.1);
}

.image-content {
  text-align: center;
}

.message-image {
  max-width: 200px;
  max-height: 200px;
  border-radius: 8px;
  cursor: pointer;
  transition: transform 0.3s ease;
}

.message-image:hover {
  transform: scale(1.05);
}

.file-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 8px;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 8px;
}

.file-info {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
}

.file-icon {
  font-size: 24px;
}

.file-details {
  flex: 1;
}

.file-name {
  font-weight: 500;
  font-size: 14px;
  color: #333;
  margin-bottom: 2px;
}

.file-size {
  font-size: 12px;
  color: #666;
}

.message.mine .file-content {
  background: rgba(255, 255, 255, 0.2);
}

.message.mine .file-name {
  color: white;
}

.message.mine .file-size {
  color: rgba(255, 255, 255, 0.8);
}

/* 语音按钮样式 */
.voice-btn {
  transition: all 0.3s ease;
}

.voice-btn.recording {
  background: #ff4757 !important;
  color: white !important;
  animation: pulse 1s infinite;
}

@keyframes pulse {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
  100% {
    transform: scale(1);
  }
}

/* 语音消息样式 */
.voice-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 8px;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 8px;
  min-width: 200px;
}

.voice-info {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
}

.voice-icon {
  font-size: 20px;
}

.voice-details {
  flex: 1;
}

.voice-duration {
  font-weight: 500;
  font-size: 14px;
  color: #333;
  margin-bottom: 4px;
}

.voice-waveform {
  display: flex;
  align-items: center;
  gap: 2px;
  height: 20px;
}

.wave-bar {
  width: 3px;
  background: #07c160;
  border-radius: 2px;
  animation: wave 1.5s ease-in-out infinite;
}

.wave-bar:nth-child(1) { height: 8px; animation-delay: 0s; }
.wave-bar:nth-child(2) { height: 12px; animation-delay: 0.1s; }
.wave-bar:nth-child(3) { height: 16px; animation-delay: 0.2s; }
.wave-bar:nth-child(4) { height: 12px; animation-delay: 0.3s; }
.wave-bar:nth-child(5) { height: 8px; animation-delay: 0.4s; }

@keyframes wave {
  0%, 100% {
    transform: scaleY(1);
  }
  50% {
    transform: scaleY(1.5);
  }
}

.play-btn {
  background: #07c160;
  color: white;
  border: none;
  border-radius: 6px;
  padding: 6px 12px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.play-btn:hover {
  background: #00a854;
  transform: scale(1.05);
}

.message.mine .voice-content {
  background: rgba(255, 255, 255, 0.2);
}

.message.mine .voice-duration {
  color: white;
}

.message.mine .wave-bar {
  background: rgba(255, 255, 255, 0.8);
}

@media (max-width: 768px) {
  .wechat-chat {
    border-radius: 0;
    height: calc(100vh - 100px);
  }
  
  .bubble {
    max-width: 85%;
  }
  
  .emoji-panel,
  .sticker-panel {
    height: 45vh;
  }
  
  .emoji-grid {
    grid-template-columns: repeat(6, 1fr);
  }
  
  .sticker-grid {
    grid-template-columns: repeat(3, 1fr);
  }
  
  .sticker-item {
    width: 70px;
    height: 70px;
  }
  
  .emoji-item {
    width: 32px;
    height: 32px;
    font-size: 16px;
  }
}

@media (max-width: 480px) {
  .emoji-grid {
    grid-template-columns: repeat(5, 1fr);
  }
  
  .sticker-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .sticker-item {
    width: 60px;
    height: 60px;
  }
  
  .emoji-item {
    width: 28px;
    height: 28px;
    font-size: 14px;
  }
  
  .panel-header {
    padding: 8px 12px;
  }
  
  .panel-content {
    padding: 12px;
  }
}
</style>
