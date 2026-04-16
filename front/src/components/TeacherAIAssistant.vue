<template>
  <div class="ai-assistant-container">
    <!-- 浮动AI助手图标 -->
    <div 
      class="ai-assistant-icon" 
      @click="toggleDialog"
      :class="{ 'pulse': isDialogOpen }"
    >
      <img 
        src="@/assets/images/智能机器人GIF_爱给网_aigei_com.gif" 
        alt="AI助手" 
        class="robot-gif"
      />
    </div>

    <!-- AI助手对话框 -->
    <div 
      v-if="isDialogOpen" 
      class="ai-dialog-overlay"
    >
      <div 
        class="ai-dialog"
      >
        <!-- 对话框头部 -->
        <div class="dialog-header">
          <div class="header-left">
            <div class="ai-avatar">
              <img 
                src="@/assets/images/智能机器人GIF_爱给网_aigei_com.gif" 
                alt="AI助手" 
                class="avatar-gif"
              />
            </div>
            <div class="ai-info">
              <h3>教师AI助手</h3>
              <p>智能教学助手 - 支持语音交互</p>
            </div>
          </div>
          <div class="header-right">
            <button class="action-btn" @click="downloadChat">
              📥
            </button>
            <button class="close-btn" @click="closeDialog">
              ✕
            </button>
          </div>
        </div>

        <!-- 聊天区域 -->
        <div class="chat-area" ref="chatArea">
          <div class="chat-messages">
            <!-- AI欢迎消息 -->
            <div class="message ai-message">
              <div class="message-avatar">
                <img 
                  src="@/assets/images/智能机器人GIF_爱给网_aigei_com.gif" 
                  alt="AI助手" 
                  class="message-avatar-gif"
                />
              </div>
              <div class="message-content">
                <div class="message-bubble">
                  <p>👋 Hi, 欢迎使用教师AI助手！</p>
                  <p>我是您的专属教学助手，可以帮您：</p>
                  <ul>
                    <li>📚 课程内容规划与优化</li>
                    <li>📝 作业题目智能生成</li>
                    <li>📊 学生学习数据分析</li>
                    <li>🎯 个性化教学建议</li>
                    <li>📖 教学资源推荐</li>
                  </ul>
                  <p>🎤 点击语音按钮，开启语音交互模式！</p>
                </div>
              </div>
            </div>

                         <!-- 用户消息 -->
             <div 
               v-for="(message, index) in chatMessages" 
               :key="index"
               class="message"
               :class="message.type"
             >
               <!-- AI消息 -->
               <div v-if="message.type === 'ai-message'" class="message-avatar">
                 <img 
                   src="@/assets/images/智能机器人GIF_爱给网_aigei_com.gif" 
                   alt="AI助手" 
                   class="message-avatar-gif"
                 />
               </div>
               <!-- 用户消息 -->
               <div v-if="message.type === 'user-message'" class="message-avatar user-avatar">
                 <img 
                   v-if="userAvatarUrl" 
                   :src="userAvatarUrl" 
                   alt="用户头像" 
                   class="user-avatar-img"
                   @error="onAvatarError"
                 />
                 <span v-else class="user-avatar-initial">{{ userInitial }}</span>
               </div>
               <div class="message-content">
                 <div class="message-bubble">
                   <p>{{ message.content }}</p>
                 </div>
               </div>
             </div>

            <!-- 加载状态 -->
            <div v-if="isLoading" class="message ai-message">
              <div class="message-avatar">
                <img 
                  src="@/assets/images/智能机器人GIF_爱给网_aigei_com.gif" 
                  alt="AI助手" 
                  class="message-avatar-gif"
                />
              </div>
              <div class="message-content">
                <div class="message-bubble">
                  <div class="typing-indicator">
                    <span></span>
                    <span></span>
                    <span></span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 输入区域 -->
        <div class="input-area">
          <div class="input-container">
            <button class="voice-btn" @click="toggleVoiceMode" :class="{ 'active': isVoiceMode }">
              🎤
            </button>
            <input 
              v-model="userInput"
              @keyup.enter="sendMessage"
              placeholder="输入您的问题..."
              class="message-input"
              :disabled="isVoiceMode"
            />
            <button class="send-btn" @click="sendMessage" :disabled="!userInput.trim() || isVoiceMode">
              ➤
            </button>
          </div>
          <div class="input-footer">
            <small>Powered by AI. 内容仅供参考。</small>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick, onMounted } from 'vue'
import axios from 'axios'

// 响应式数据
const isDialogOpen = ref(false)
const userInput = ref('')
const chatMessages = ref([])
const isLoading = ref(false)
const isVoiceMode = ref(false)
const chatArea = ref(null)
const userAvatarUrl = ref('') // 添加用户头像URL
const userInitial = ref('教')

// 获取当前用户头像
const loadUserAvatar = async () => {
  try {
    // 尝试从本地存储获取头像
    const localAvatar = localStorage.getItem('teacherAvatarUrl') || localStorage.getItem('studentAvatarUrl')
    if (localAvatar) {
      userAvatarUrl.value = localAvatar
      return
    }
    
    // 从localStorage获取当前用户信息
    const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
    if (currentUser.id) {
      // 尝试从后端获取用户头像
      const response = await axios.get(`/api/user/profile?userId=${currentUser.id}`)
      if (response.data?.data?.avatarUrl) {
        userAvatarUrl.value = response.data.data.avatarUrl
        // 保存到本地存储
        try {
          localStorage.setItem('teacherAvatarUrl', response.data.data.avatarUrl)
        } catch (e) {
          console.warn('保存头像到本地存储失败:', e)
        }
      }
    }
  } catch (error) {
    console.warn('加载用户头像失败:', error)
  }
}

// 切换对话框显示状态
const toggleDialog = () => {
  isDialogOpen.value = !isDialogOpen.value
  if (isDialogOpen.value) {
    nextTick(() => {
      scrollToBottom()
    })
  }
}

// 关闭对话框
const closeDialog = () => {
  isDialogOpen.value = false
}

// 发送消息
const sendMessage = async () => {
  if (!userInput.value.trim() || isLoading.value) return

  const userMessage = userInput.value.trim()
  
  // 添加用户消息
  chatMessages.value.push({
    type: 'user-message',
    content: userMessage
  })

  // 清空输入框
  userInput.value = ''
  
  // 滚动到底部
  await nextTick()
  scrollToBottom()

  // 显示加载状态
  isLoading.value = true

  try {
    // 调用后端AI接口
    const response = await fetch('/api/teacher-assistant', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      },
      body: JSON.stringify({
        memoryId: Date.now(), // 使用时间戳作为记忆ID
        userMessage: userMessage
      })
    })

    if (response.ok) {
      const reader = response.body.getReader()
      const decoder = new TextDecoder()
      let aiResponse = ''

      // 处理流式响应
      while (true) {
        const { done, value } = await reader.read()
        if (done) break

        const chunk = decoder.decode(value)
        aiResponse += chunk

        // 实时更新AI响应
        const lastMessage = chatMessages.value.find(msg => msg.type === 'ai-message' && msg.isStreaming)
        if (lastMessage) {
          lastMessage.content = aiResponse
        } else {
          chatMessages.value.push({
            type: 'ai-message',
            content: aiResponse,
            isStreaming: true
          })
        }

        await nextTick()
        scrollToBottom()
      }

      // 完成流式响应
      const finalMessage = chatMessages.value.find(msg => msg.type === 'ai-message' && msg.isStreaming)
      if (finalMessage) {
        finalMessage.isStreaming = false
      }
    } else {
      throw new Error('API请求失败')
    }
  } catch (error) {
    console.error('AI响应错误:', error)
    // 如果API调用失败，使用本地响应
    const aiResponse = generateAIResponse(userMessage)
    chatMessages.value.push({
      type: 'ai-message',
      content: aiResponse
    })
  } finally {
    isLoading.value = false
    await nextTick()
    scrollToBottom()
  }
}

// 生成AI响应（模拟）
const generateAIResponse = (userMessage) => {
  const responses = {
    '课程': '我可以帮您规划课程内容，根据学生的学习进度和掌握情况，提供个性化的教学建议。您想了解哪个方面的课程规划呢？',
    '作业': '作业管理是教学的重要环节。我可以帮您生成适合的作业题目，分析学生的作业完成情况，并提供改进建议。',
    '学生': '学生管理包括学习进度跟踪、成绩分析、个性化辅导等。我可以为您提供详细的学生学习数据分析报告。',
    '考试': '考试管理包括试卷生成、成绩统计、错题分析等。我可以帮您智能生成试卷，分析考试结果。',
    '资源': '教学资源推荐包括课件、视频、练习题等。我可以根据您的课程内容，推荐相关的优质教学资源。',
    '分析': '数据分析可以帮助您更好地了解学生的学习情况。我可以为您生成学习进度报告、成绩分析图表等。'
  }

  // 根据用户输入匹配响应
  for (const [keyword, response] of Object.entries(responses)) {
    if (userMessage.includes(keyword)) {
      return response
    }
  }

  // 默认响应
  return '感谢您的提问！我是您的专属教学助手，可以帮您处理课程规划、作业管理、学生分析、考试管理、资源推荐等各种教学相关事务。请告诉我您需要什么帮助？'
}

// 切换语音模式
const toggleVoiceMode = () => {
  isVoiceMode.value = !isVoiceMode.value
  if (isVoiceMode.value) {
    // 这里可以添加语音识别功能
    alert('语音模式已开启，请开始说话...')
  }
}

// 下载聊天记录
const downloadChat = () => {
  const chatText = chatMessages.value
    .map(msg => `${msg.type === 'user-message' ? '您' : 'AI助手'}: ${msg.content}`)
    .join('\n\n')
  
  const blob = new Blob([chatText], { type: 'text/plain' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `AI助手聊天记录_${new Date().toLocaleDateString()}.txt`
  a.click()
  URL.revokeObjectURL(url)
}



// 滚动到底部
const scrollToBottom = () => {
  if (chatArea.value) {
    chatArea.value.scrollTop = chatArea.value.scrollHeight
  }
}

// 组件挂载后初始化
onMounted(() => {
  // 加载用户头像
  loadUserAvatar()
})
</script>

<style scoped>
.ai-assistant-container {
  position: relative;
}

/* 浮动AI助手图标 */
.ai-assistant-icon {
  position: fixed;
  bottom: 30px;
  right: 30px;
  width: 80px;
  height: 80px;
  cursor: pointer;
  z-index: 1000;
  transition: all 0.3s ease;
  background: transparent;
  padding: 0;
}

.ai-assistant-icon:hover {
  transform: scale(1.1);
}

.ai-assistant-icon.pulse {
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
}

.robot-gif {
  width: 100%;
  height: 100%;
  object-fit: cover;
  background: transparent;
}

/* 对话框遮罩 */
.ai-dialog-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: transparent;
  z-index: 1001;
  pointer-events: none;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

/* 对话框主体 */
.ai-dialog {
  position: fixed;
  bottom: 120px;
  right: 30px;
  width: 400px;
  height: 600px;
  background: white;
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  animation: slideUp 0.3s ease;
  pointer-events: auto;
}

@keyframes slideUp {
  from { 
    transform: translateY(20px) scale(0.95);
    opacity: 0;
  }
  to { 
    transform: translateY(0) scale(1);
    opacity: 1;
  }
}

/* 对话框头部 */
.dialog-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px;
  border-bottom: 1px solid #f0f0f0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 15px;
}

.ai-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  overflow: hidden;
  border: 3px solid rgba(255, 255, 255, 0.3);
}

.avatar-gif {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.ai-info h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
}

.ai-info p {
  margin: 5px 0 0 0;
  font-size: 14px;
  opacity: 0.9;
}

.header-right {
  display: flex;
  gap: 10px;
}

.action-btn, .close-btn {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.action-btn:hover, .close-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: scale(1.1);
}

/* 聊天区域 */
.chat-area {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background: #f8f9fa;
}

.chat-messages {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.message {
  display: flex;
  align-items: flex-start;
  gap: 12px;
}

.message.user-message {
  flex-direction: row-reverse;
}

.message-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  overflow: hidden;
  flex-shrink: 0;
}

.message-avatar-gif {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.user-avatar {
  background: #667eea;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 20px;
  line-height: 1;
  overflow: hidden;
}

.user-avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}

.user-avatar-initial {
  font-size: 16px;
  font-weight: bold;
}

.message-content {
  flex: 1;
  max-width: 70%;
}

.message-bubble {
  background: white;
  padding: 15px;
  border-radius: 18px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  line-height: 1.5;
}

.user-message .message-bubble {
  background: #667eea;
  color: white;
}

.message-bubble p {
  margin: 0 0 10px 0;
}

.message-bubble p:last-child {
  margin-bottom: 0;
}

.message-bubble ul {
  margin: 10px 0;
  padding-left: 20px;
}

.message-bubble li {
  margin-bottom: 5px;
}

/* 打字指示器 */
.typing-indicator {
  display: flex;
  gap: 4px;
  padding: 10px 0;
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #667eea;
  animation: typing 1.4s infinite ease-in-out;
}

.typing-indicator span:nth-child(1) { animation-delay: -0.32s; }
.typing-indicator span:nth-child(2) { animation-delay: -0.16s; }

@keyframes typing {
  0%, 80%, 100% {
    transform: scale(0.8);
    opacity: 0.5;
  }
  40% {
    transform: scale(1);
    opacity: 1;
  }
}

/* 输入区域 */
.input-area {
  padding: 20px;
  border-top: 1px solid #f0f0f0;
  background: white;
}

.input-container {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 10px;
}

.voice-btn {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  border: none;
  background: #f0f0f0;
  color: #666;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.voice-btn.active {
  background: #667eea;
  color: white;
}

.voice-btn:hover {
  background: #667eea;
  color: white;
}

.message-input {
  flex: 1;
  padding: 12px 16px;
  border: 2px solid #f0f0f0;
  border-radius: 24px;
  font-size: 14px;
  outline: none;
  transition: border-color 0.3s ease;
}

.message-input:focus {
  border-color: #667eea;
}

.message-input:disabled {
  background: #f8f9fa;
  color: #999;
}

.send-btn {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  border: none;
  background: #667eea;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.send-btn:hover:not(:disabled) {
  background: #5a6fd8;
  transform: scale(1.05);
}

.send-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.input-footer {
  text-align: center;
  color: #999;
  font-size: 12px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .ai-dialog {
    width: 350px;
    height: 500px;
    bottom: 100px;
    right: 20px;
  }
  
  .ai-assistant-icon {
    width: 60px;
    height: 60px;
    bottom: 20px;
    right: 20px;
  }
  
  .message-content {
    max-width: 85%;
  }
}
</style>
