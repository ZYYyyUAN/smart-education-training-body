<template>
  <div class="chat-box">
    <div class="chat-header">
      <div class="ai-info">
        <span class="ai-tag">小智(AI)</span>
        <span class="status">活力状态</span>
      </div>
      <div class="greeting">你好，张政同学</div>
    </div>
    <div class="chat-message">
      <div v-if="messages.length === 0" class="welcome-message">
        <p>嘿嘿，当然可以!让我们一起向着未来的星辰大海，勇敢追梦，创造无限可能吧!</p>
      </div>
      <div v-else class="message-list">
        <div 
          v-for="(msg, index) in messages" 
          :key="index" 
          :class="['message-item', msg.isUser ? 'user-message' : 'bot-message']"
        >
          <div class="message-content">
            <span v-if="msg.isUser">你：</span>
            <span v-else>小智：</span>
            <span v-html="msg.content"></span>
            <span v-if="msg.isTyping" class="typing-indicator">
              <span class="dot"></span>
              <span class="dot"></span>
              <span class="dot"></span>
            </span>
          </div>
        </div>
      </div>
    </div>
    <div class="chat-input-section">
      <div class="input-container">
        <input 
          v-model="inputMessage" 
          type="text" 
          placeholder="输入消息或点击麦克风开始语音输入..."
          class="message-input"
          @keyup.enter="sendMessage"
        />
        <button 
          @click="toggleVoiceRecognition" 
          :class="['voice-btn', { 'recording': isRecording }]"
          :title="isRecording ? '停止录音' : '开始语音输入'"
        >
          {{ isRecording ? '🔴' : '🎤' }}
        </button>
        <button @click="sendMessage" class="send-btn" :disabled="!inputMessage.trim() || isSending">
          {{ isSending ? '发送中...' : '发送' }}
        </button>
      </div>
             <div v-if="isRecording" class="voice-status">
         <span class="recording-indicator">🎤 正在录音...</span>
         <span v-if="interimTranscript" class="interim-text">{{ interimTranscript }}</span>
         <span v-if="finalTranscript && autoSendTimer" class="auto-send-indicator">
           ⏰ 静音2秒后自动发送
         </span>
         <span v-if="finalTranscript && !autoSendTimer" class="manual-send-indicator">
           <button @click="manualSendVoiceResult" class="manual-send-btn">
             📤 手动发送识别结果
           </button>
         </span>
       </div>
    </div>
    <div class="chat-footer">
      <small>系统中所有标有小慧标记的提示框</small>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import axios from 'axios'

// 语音识别相关状态
const isRecording = ref(false)
const inputMessage = ref('')
const interimTranscript = ref('')
const finalTranscript = ref('')
const lastFinalTranscript = ref('') // 记录上一次的最终结果
const mergeTimer = ref(null) // 合并定时器
const isMerging = ref(false) // 是否正在合并
const autoSendTimer = ref(null) // 自动发送定时器

// 聊天相关状态
const messages = ref([])
const isSending = ref(false)

// 语音识别对象
let recognition = null

// 初始化语音识别
const initSpeechRecognition = () => {
  if (!('webkitSpeechRecognition' in window) && !('SpeechRecognition' in window)) {
    console.warn('当前浏览器不支持语音识别')
    return false
  }

  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
  recognition = new SpeechRecognition()
  
  // 配置语音识别参数
  recognition.continuous = true // 连续识别
  recognition.interimResults = true // 获取中间结果
  recognition.lang = 'zh-CN' // 中文识别
  
  // 识别结果事件 - 增强版处理逻辑
  recognition.onresult = (event) => {
    let allFinal = '';
    let interim = '';
    
    console.log('🎤 语音识别结果事件触发，results长度:', event.results.length);
    
    // 全量遍历所有 results
    for (let i = 0; i < event.results.length; ++i) {
      const result = event.results[i];
      const transcript = result[0].transcript;
      console.log(`结果 ${i}: isFinal=${result.isFinal}, transcript="${transcript}"`);
      
      if (result.isFinal) {
        allFinal += transcript;
      } else {
        interim += transcript;
      }
    }
    
    console.log('📝 最终结果:', allFinal, '中间结果:', interim);
    
    // 智能合并逻辑：如果新的最终结果比上次的短，可能是分段了
    if (allFinal && allFinal.length < lastFinalTranscript.value.length) {
      // 可能是分段，尝试合并
      const combined = lastFinalTranscript.value + allFinal;
      finalTranscript.value = combined;
      lastFinalTranscript.value = combined;
      console.log('🔄 合并结果:', combined);
    } else if (allFinal) {
      // 正常情况，更新最终结果
      finalTranscript.value = allFinal;
      lastFinalTranscript.value = allFinal;
      console.log('✅ 更新最终结果:', allFinal);
    }
    
    interimTranscript.value = interim;
    inputMessage.value = finalTranscript.value + interimTranscript.value;
    
    // 清除之前的合并定时器
    if (mergeTimer.value) {
      clearTimeout(mergeTimer.value);
      console.log('⏰ 清除合并定时器');
    }
    
    // 设置合并定时器：如果1.5秒内没有新的最终结果，认为识别完成
    mergeTimer.value = setTimeout(() => {
      if (finalTranscript.value.trim()) {
        console.log('🎯 语音识别完成，最终结果:', finalTranscript.value);
        isMerging.value = false;
        
        // 设置自动发送定时器：静音2秒后自动发送
        if (autoSendTimer.value) {
          clearTimeout(autoSendTimer.value);
          console.log('⏰ 清除之前的自动发送定时器');
        }
        
        console.log('🚀 设置自动发送定时器，2秒后发送:', finalTranscript.value);
        autoSendTimer.value = setTimeout(() => {
          if (finalTranscript.value.trim() && !isSending.value) {
            console.log('📤 静音2秒，自动发送语音识别结果:', finalTranscript.value);
            inputMessage.value = finalTranscript.value;
            sendMessage();
          } else {
            console.log('❌ 自动发送条件不满足:', {
              hasContent: !!finalTranscript.value.trim(),
              isSending: isSending.value
            });
          }
        }, 2000); // 2秒静音后自动发送
      } else {
        console.log('⚠️ 最终结果为空，不设置自动发送');
      }
    }, 1500);
  }
  
  // 识别错误事件
  recognition.onerror = (event) => {
    console.error('语音识别错误:', event.error)
    stopVoiceRecognition()
    if (event.error === 'not-allowed') {
      alert('请允许浏览器使用麦克风权限')
    }
  }
  
     // 识别结束事件
   recognition.onend = () => {
     console.log('语音识别结束')
     isRecording.value = false
     interimTranscript.value = ''
     
     // 清除合并定时器
     if (mergeTimer.value) {
       clearTimeout(mergeTimer.value);
       mergeTimer.value = null;
     }
     
     // 清除自动发送定时器
     if (autoSendTimer.value) {
       clearTimeout(autoSendTimer.value);
       autoSendTimer.value = null;
     }
     
     // 如果有最终识别结果，自动填充到输入框
     if (finalTranscript.value.trim()) {
       inputMessage.value = finalTranscript.value
     }
   }
  
     // 识别开始事件
   recognition.onstart = () => {
     console.log('语音识别开始')
     isRecording.value = true
     finalTranscript.value = ''
     lastFinalTranscript.value = ''
     interimTranscript.value = ''
     isMerging.value = false
     
     // 清除之前的定时器
     if (mergeTimer.value) {
       clearTimeout(mergeTimer.value);
       mergeTimer.value = null;
     }
     
     // 清除自动发送定时器
     if (autoSendTimer.value) {
       clearTimeout(autoSendTimer.value);
       autoSendTimer.value = null;
     }
   }
  
  return true
}

// 切换语音识别状态
const toggleVoiceRecognition = () => {
  if (!recognition) {
    if (!initSpeechRecognition()) {
      alert('当前浏览器不支持语音识别功能')
      return
    }
  }
  
  if (isRecording.value) {
    stopVoiceRecognition()
  } else {
    startVoiceRecognition()
  }
}

// 开始语音识别
const startVoiceRecognition = () => {
  try {
    recognition.start()
  } catch (error) {
    console.error('启动语音识别失败:', error)
    isRecording.value = false
  }
}

// 停止语音识别
const stopVoiceRecognition = () => {
  try {
    recognition.stop()
  } catch (error) {
    console.error('停止语音识别失败:', error)
  }
  isRecording.value = false
  
  // 清除合并定时器
  if (mergeTimer.value) {
    clearTimeout(mergeTimer.value);
    mergeTimer.value = null;
  }
  
  // 清除自动发送定时器
  if (autoSendTimer.value) {
    clearTimeout(autoSendTimer.value);
    autoSendTimer.value = null;
  }
}

// 发送消息
const sendMessage = async () => {
  if (inputMessage.value.trim() && !isSending.value) {
    const userMessage = inputMessage.value.trim()
    console.log('发送消息:', userMessage)
    
    // 添加用户消息
    messages.value.push({
      isUser: true,
      content: userMessage,
      isTyping: false
    })
    
    // 添加机器人消息（初始为空，等待流式响应）
    const botMessageIndex = messages.value.length
    messages.value.push({
      isUser: false,
      content: '',
      isTyping: true
    })
    
    isSending.value = true
    
    try {
      // 使用axios进行流式请求
      const response = await axios.post('/api/xiaozhi/student/chat/by-course', {
        memoryId: getOrCreateUUID(),
        message: userMessage,
        courseId: props.courseId || (new URLSearchParams(location.search).get('courseId'))
      }, {
        responseType: 'text',
        onDownloadProgress: (progressEvent) => {
          const responseText = progressEvent.event.target.responseText
          if (responseText) {
            messages.value[botMessageIndex].content = responseText
            messages.value[botMessageIndex].isTyping = false
          }
        }
      })
      
      // 如果流式响应没有正常工作，使用普通响应
      if (!messages.value[botMessageIndex].content) {
        messages.value[botMessageIndex].content = response.data || '抱歉，我现在无法回答您的问题。'
        messages.value[botMessageIndex].isTyping = false
      }
      
    } catch (error) {
      console.error('发送消息失败:', error)
      messages.value[botMessageIndex].content = '抱歉，网络连接出现问题，请稍后重试。'
      messages.value[botMessageIndex].isTyping = false
    }
    
    // 清空输入框
    inputMessage.value = ''
    finalTranscript.value = ''
    lastFinalTranscript.value = ''
    interimTranscript.value = ''
    isSending.value = false
  }
}

// 获取或创建UUID
const getOrCreateUUID = () => {
  let storedUUID = localStorage.getItem('user_uuid')
  if (!storedUUID) {
    // 生成一个简单的数字ID作为memoryId
    storedUUID = Date.now().toString()
    localStorage.setItem('user_uuid', storedUUID)
  }
  return storedUUID
}

// 手动发送语音识别结果
const manualSendVoiceResult = () => {
  if (finalTranscript.value.trim() && !isSending.value) {
    console.log('🔧 手动发送语音识别结果:', finalTranscript.value);
    inputMessage.value = finalTranscript.value;
    sendMessage();
  } else {
    console.log('❌ 手动发送条件不满足:', {
      hasContent: !!finalTranscript.value.trim(),
      isSending: isSending.value
    });
  }
}

// 组件挂载时初始化
onMounted(() => {
  initSpeechRecognition()
})

// 组件卸载时清理
onUnmounted(() => {
  if (recognition && isRecording.value) {
    recognition.stop()
  }
  if (mergeTimer.value) {
    clearTimeout(mergeTimer.value);
  }
  if (autoSendTimer.value) {
    clearTimeout(autoSendTimer.value);
  }
})
</script>

<style scoped>
.chat-box {
  border-radius: 0.75rem;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  background-color: var(--card-bg);
  display: flex;
  flex-direction: column;
  height: 100%;
}

.chat-header {
  padding: 1rem;
  background-color: var(--primary-color);
  color: white;
}

.ai-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}

.ai-tag {
  font-weight: bold;
}

.status {
  font-size: 0.8rem;
  opacity: 0.8;
}

.greeting {
  font-size: 1.1rem;
}

.chat-message {
  padding: 1.5rem;
  background-color: var(--card-bg);
  color: var(--text-color);
  flex: 1;
  overflow-y: auto;
}

.chat-message p {
  line-height: 1.6;
  margin: 0;
}

.welcome-message {
  text-align: center;
  color: #666;
  font-style: italic;
}

.message-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  max-height: 300px;
  overflow-y: auto;
}

.message-item {
  padding: 0.75rem;
  border-radius: 0.5rem;
  max-width: 85%;
}

.user-message {
  align-self: flex-end;
  background-color: #e3f2fd;
  color: #1565c0;
  margin-left: auto;
}

.bot-message {
  align-self: flex-start;
  background-color: #f3e5f5;
  color: #7b1fa2;
}

.message-content {
  line-height: 1.4;
}

.typing-indicator {
  display: inline-flex;
  gap: 0.25rem;
  margin-left: 0.5rem;
}

.typing-indicator .dot {
  width: 6px;
  height: 6px;
  background-color: currentColor;
  border-radius: 50%;
  animation: typing 1.4s infinite ease-in-out;
}

.typing-indicator .dot:nth-child(1) {
  animation-delay: -0.32s;
}

.typing-indicator .dot:nth-child(2) {
  animation-delay: -0.16s;
}

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

.chat-input-section {
  padding: 1rem;
  background-color: var(--card-bg);
  border-top: 1px solid rgba(0, 0, 0, 0.1);
}

.input-container {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.message-input {
  flex: 1;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 0.5rem;
  font-size: 0.9rem;
  outline: none;
  transition: border-color 0.3s;
}

.message-input:focus {
  border-color: var(--primary-color);
}

.voice-btn {
  padding: 0.75rem;
  border: none;
  border-radius: 0.5rem;
  background-color: #f0f0f0;
  cursor: pointer;
  font-size: 1.2rem;
  transition: all 0.3s;
  min-width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.voice-btn:hover {
  background-color: #e0e0e0;
}

.voice-btn.recording {
  background-color: #ff4444;
  color: white;
  animation: pulse 1.5s infinite;
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

.send-btn {
  padding: 0.75rem 1rem;
  border: none;
  border-radius: 0.5rem;
  background-color: var(--primary-color);
  color: white;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s;
  min-width: 60px;
}

.send-btn:hover:not(:disabled) {
  background-color: #1e3a8a;
}

.send-btn:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.voice-status {
  padding: 0.5rem;
  background-color: #f8f9fa;
  border-radius: 0.5rem;
  font-size: 0.8rem;
  color: #666;
}

.recording-indicator {
  display: block;
  margin-bottom: 0.25rem;
  font-weight: 500;
}

.interim-text {
  display: block;
  font-style: italic;
  color: #888;
}

.auto-send-indicator {
  display: block;
  margin-top: 0.25rem;
  font-weight: 500;
  color: #ff6b35;
  animation: pulse 1s infinite;
}

.manual-send-indicator {
  display: block;
  margin-top: 0.25rem;
}

.manual-send-btn {
  background: #4CAF50;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 0.25rem;
  cursor: pointer;
  font-size: 0.8rem;
  transition: background-color 0.3s;
}

.manual-send-btn:hover {
  background: #45a049;
}

.chat-footer {
  padding: 0.5rem 1rem;
  background-color: rgba(0, 0, 0, 0.05);
  font-size: 0.75rem;
  color: var(--secondary-color);
  text-align: center;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .input-container {
    flex-wrap: wrap;
  }
  
  .message-input {
    order: 1;
    width: 100%;
    margin-bottom: 0.5rem;
  }
  
  .voice-btn {
    order: 2;
  }
  
  .send-btn {
    order: 3;
  }
}
</style>