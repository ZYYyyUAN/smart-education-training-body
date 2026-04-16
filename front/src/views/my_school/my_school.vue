<template>
  <div>
   <SplineBac :scene="{url:'https://prod.spline.design/6abYqc7wmfe4a3Ty/scene.splinecode'}"></SplineBac>
     <div class="academy-page">
      
    <!-- 右下角语音助手浮动按钮（还原） -->
    <div v-if="!showChatBot" class="bot-container">
      <button @click="showChatBot = true" class="bot-toggle-btn">
        <img src="@/assets/images/智能机器人GIF_爱给网_aigei_com.gif" alt="智能机器人" class="bot-icon" />
      </button>
      <div v-if="showBotTip" class="bot-tip" :class="{ 'tip-visible': showBotTip }">
        {{ currentBotTip }}
      </div>
    </div>

    <!-- 右侧语音助手面板（恢复） -->
    <div v-if="showChatBot" class="chat-voice-panel">
      <!-- 状态栏 -->
      <div class="status-bar">
        <div class="status-icons">
          <div class="status-icon mic" v-if="isListening">🎤</div>
        </div>
      </div>

      <div class="voice-chat-header">
        <div class="avatar-wrapper">
          <img src="@/assets/images/xiaozhi.png" alt="avatar" />
        </div>
        <div class="assistant-name">小智</div>
      </div>

      <!-- 场景选择按钮 -->
      <div class="scene-selector">
        <button class="scene-btn">
          <span class="scene-icon">⚙️</span>
          <span class="scene-text">选择情景</span>
        </button>
      </div>

      <div class="voice-chat-content">
        <!-- 状态指示器 -->
        <div class="status-indicator" v-if="isListening">
          <div class="listening-dots">
            <span v-for="n in 3" :key="n" class="dot"></span>
          </div>
          <div class="status-text">正在聆听...</div>
        </div>

        <!-- 识别结果显示 -->
        <div class="recognition-result" v-if="displayRecognitionText">
          <div class="result-label">识别内容：</div>
          <div class="result-text">{{ displayRecognitionText }}</div>
        </div>

        <!-- 历史消息 -->
        <div class="chat-message-list" v-if="chatMessages.length > 0">
          <div v-for="(msg, index) in chatMessages" :key="index" class="chat-message">
            <span class="msg-user">🧑：</span>
            <span class="msg-text">{{ msg.text }}</span>
          </div>
        </div>

        <!-- 提示文本 -->
        <div class="prompt-text" v-if="!isListening && !displayRecognitionText">
          你可以开始说话
        </div>

        <!-- 控制按钮 -->
        <div class="button-group-chat">
          <button @click="toggleMute" class="mute-btn" :class="{ 'muted': isMuted }">
            {{ isMuted ? '🔇' : '🎤' }}
          </button>
          <button @click="startRecording" class="start-btn">开始语音对话</button>
          <button @click="handleCloseBot" class="close-btn">❌</button>
        </div>
      </div>
    </div>

      <h2>重要提醒</h2>
      <div class="card-container">
        <template v-if="importantItems && importantItems.length > 0">
          <el-card
            v-for="(item, index) in importantItems"
            :key="index"
            shadow="hover"
            class="question-card"
            @click="handleImportantItemClick(item)"
            style="cursor: pointer;"
          >
            <div class="card-header">
              <el-tag :type="item.type === 'exam' ? 'danger' : 'warning'" effect="dark">
                {{ item.type === 'exam' ? '考试' : '作业' }} · 即将截止
              </el-tag>
            </div>
            
            <!-- 课程名称 -->
            <div class="course-info" v-if="item.courseName">
              <span class="course-label">课程名称：{{ item.courseName }}</span>
            </div>
            
            <!-- 标题 -->
            <h3 class="item-title">📝 {{ item.type === 'exam' ? '考试标题' : '作业标题' }}：{{ item.title }}</h3>
            
            <!-- 描述 -->
            <p class="desc" v-if="item.description">📄 详细描述：{{ item.description }}</p>
            <p class="desc no-desc" v-else>📄 详细描述：暂无详细描述</p>
            
            <!-- 考试特有信息 -->
            <div class="exam-info" v-if="item.type === 'exam' && item.durationMinutes">
              <span class="duration">⏱️ 考试时长：{{ item.durationMinutes }}分钟</span>
            </div>
            
            <!-- 截止日期 -->
            <p class="due">📅 截止日期：{{ (item.dueDate || '').slice(0, 10) }}</p>
          </el-card>
        </template>

        <template v-else>
          <el-empty description="暂无即将到期的作业/考试提醒" :image-size="200" />
        </template>
      </div>
      <!-- 评估结果弹窗 -->
<!-- 评估结果弹窗 -->
<el-dialog 
  v-model="resultDialogVisible2" 
  title="AI评估结果" 
  width="700px"
  class="evaluation-result-dialog"
>
  <div v-loading="isLoadingResult">
    <div v-if="evaluationResult" class="evaluation-content">
      <pre>{{ evaluationResult }}</pre>
    </div>
  </div>
</el-dialog>

      <!-- 课程内容区域 -->
      <div class="course-content">
        <h2 class="section-title">🎓 我的课程</h2>
        <section class="course-section">
            <div>
            <el-button 
            type="primary" 
            size="middle" 
            class="absolute top-0 right-0 m-4"
            @click="showAddCourseDialog">
            <el-icon><Plus /></el-icon>
              添加课程
            </el-button>
             <!-- 添加课程对话框 -->
            <el-dialog
              v-model="classDialogVisible"
              title="添加新课程"
              width="30%"
              :before-close="classHandleClose">
              
              <el-form :model="courseForm" :rules="rules" ref="courseFormRef">
                <el-form-item label="课程号" prop="courseCode">
                  <el-input 
                    v-model="courseForm.courseCode" 
                    placeholder="请输入课程号"
                    clearable>
                  </el-input>
                </el-form-item>
              </el-form>
              
              <template #footer>
                <span class="dialog-footer">
                  <el-button @click="classDialogVisible = false">取消</el-button>
                  <el-button type="primary" @click="confirmAddCourse">确认</el-button>
                </span>
              </template>
            </el-dialog>
          </div>
           <template v-if="selectedCourses.length > 0">
  <el-card
    v-for="course in selectedCourses"
    :key="course.id"
    class="course-card"
    shadow="hover"
  >
    <div class="card-content">
      <img
        class="course-cover"
        :src="course.courseImage || defaultCourseImg"
        alt="课程封面"
      />
      <div class="course-info">
        <h3 class="course-title">{{ course.courseName }}</h3>
        <p class="course-desc">{{ course.description || '暂无简介' }}</p>
        <div class="course-meta">
          <el-tag type="success">已加入</el-tag>
        </div>
        <el-button type="primary" size="small" icon="ArrowRight" @click="enterCourse(course.id)" class="courseButton">
            进入课堂
          </el-button>
      </div>
    </div>
  </el-card>
</template>

<el-empty v-else description="你还没有加入任何课程" />

            <h2 class="section-title">🎓 翻转课</h2>
            <!-- <el-button type="text" class="view-all">查看全部 ></el-button> -->
            <el-card class="fzcourse-card" shadow="hover">
              <div class="fzcard">
                <span class="badge">翻转课</span>
                <h3>2024-2025(2)软件234数据结构课程设计</h3>
                <span class="value">进度0%</span>
              </div>
            </el-card>      
          </section>
        </div>
  
      <!-- 动态背景 -->
      <!-- <DynamicBackground /> -->
    </div>
  </div>
  </template>
  
  <script>
  import defaultCourseImg from '../../assets/icon/JiWang.png'
export default {
  name: 'AssessmentFrame',
  data() {
    return {
      isHovered: false,
      activeBtn: null,
      dotPositions: []
    }
  },
  created() {
    // 初始化浮动点的随机位置
    for (let i = 0; i < 12; i++) {
      this.dotPositions.push({
        x: Math.random() * 90 + 5,
        y: Math.random() * 90 + 5,
        size: Math.random() * 4 + 2,
        delay: Math.random() * 2
      });
    }
  },
  methods: {
    hoverButton(type) {
      this.activeBtn = type;
    },
    resetButton() {
      this.activeBtn = null;
    },
    getDotStyle(index) {
      const dot = this.dotPositions[index - 1];
      return {
        left: `${dot.x}%`,
        top: `${dot.y}%`,
        width: `${dot.size}px`,
        height: `${dot.size}px`,
        animationDelay: `${dot.delay}s`
      };
    }
  }
}

</script>
  <script setup>
  import { onMounted, ref, watch, reactive,onUnmounted} from 'vue'
  import axios from 'axios'
  import { v4 as uuidv4 } from 'uuid'
  import { useRouter } from 'vue-router'
  import ScoreCircle from '@/components/ScoreCircle.vue'
  import DynamicBackground from '@/components/DynamicBackground.vue'
  import { ElMessage } from 'element-plus'
  import { Plus } from '@element-plus/icons-vue'
  import ThemeToggle from '../../components/ThemeToggle.vue'
  import SplineBac from './SplineBac.vue'
  import * as CryptoJS from 'crypto-js'
  import { useUserStore } from '@/store/user.js'
  const activeTab = ref('learn')
  const dialogVisible = ref(false)
  const doWorkDialogVisible = ref(false)
  const dialogMode = ref('view') // 'answer' 或 'discussion' 或 'view'
  const selectedItem = ref(null)
  const messaggListRef = ref()
  const isSending = ref(false)
  const uuid = ref()
  const inputMessage = ref('')
  const messages = ref([])
  const router = useRouter()
  const onLogout = () => {
    try {
      localStorage.removeItem('token')
      localStorage.removeItem('currentUser')
    } catch (e) {}
    router.replace('/')
  }
  const isHovered = ref(false)
  const activeBtn = ref(null)
  const showReport = ref(false)
  const reportContent = ref([])
  const chatActive = ref(false)
  const userQuestion = ref('')
  const aiAnswer = ref('')
  const currentWork = ref(null)
  const answerContent = ref('')
  const classDialogVisible = ref(false)
  const courseFormRef = ref(null)
  const selectDialogVisible = ref(false)
  const resultDialogVisible = ref(false)
  const successDialogVisible = ref(false)
  const courseForm = ref({
    courseCode: ''
  })
  const resultDialogVisible2 = ref(false)
  const unsubmittedList = ref([])
const submittedList = ref([])
const selectedCourses = ref([])
const importantAssignments = ref([])
const importantItems = ref([])
const selectedSubject = ref('')
const isGenerating = ref(false)
const analysisResult = ref({
  knowledgeAnalysis: '',
  teachingSuggestion: ''
})
// 添加这些变量
const evaluationResult = ref('')
const isEvaluating = ref(false)
const isLoadingResult = ref(false)




const appid = 'e3d65130'
const apiKey = '91fea45dd89c08a8c6444972f41aa8d9'
const hostUrl = 'wss://rtasr.xfyun.cn/v1/ws'

const showChatBot = ref(false)
const isChatting = ref(false)
const isListening = ref(false)
const isMuted = ref(false)
const currentRecognitionText = ref('')
// 展示用识别文本：发送时保持不变，直到下一次说话产生新结果
const displayRecognitionText = ref('')
const currentTime = ref('')
const chatMessages = ref([])  // 这里放识别文本历史，或者仅放最新结果

// 机器人提示相关变量
const showBotTip = ref(false)
const currentBotTip = ref('')
const botTips = [
  '今天有什么烦心事要跟我说说吗？',
  '学习累了？来和我聊聊天吧！',
  '有什么问题需要帮助吗？',
  '想了解什么新知识呢？',
  '今天的课程怎么样？',
  '有什么想法想分享吗？',
  '需要我为你推荐一些学习资源吗？',
  '想测试一下你的知识掌握情况吗？'
]

let ws = null
let audioContext = null
let processor = null
let sourceNode = null
let audioStream = null
let pcmBuffer = new Uint8Array(0)
let audioWs = null
let audioPlayQueue = [] // 队列保存收到的音频数据
let audioPlaybackContext = null
// 语音静音检测与节流
const isSendingToBackend = ref(false)
let suspendProcessing = false
let silenceStartTime = null
let lastUtteranceText = ''
const SILENCE_THRESHOLD = 0.01
const SILENCE_DURATION_MS = 2000
// 更新当前时间
function updateCurrentTime() {
  const now = new Date()
  const hours = now.getHours().toString().padStart(2, '0')
  const minutes = now.getMinutes().toString().padStart(2, '0')
  currentTime.value = `${hours}:${minutes}`
}

// 计算签名
function getSigna(ts) {
  const md5 = CryptoJS.MD5(appid + ts).toString()
  const sha1 = CryptoJS.HmacSHA1(md5, apiKey)
  const base64 = CryptoJS.enc.Base64.stringify(sha1)
  return encodeURIComponent(base64)
}

function connectAudioWebSocket() {
  audioWs = new WebSocket('/ws/audio')  // 使用相对路径
  audioWs.binaryType = 'arraybuffer'

  audioWs.onopen = () => {
    console.log('🔊 音频WebSocket连接已建立')
  }

  audioWs.onmessage = (event) => {
    const audioData = event.data
    if (audioData instanceof ArrayBuffer) {
      playAudioData(audioData)
    }
  }

  audioWs.onerror = (err) => {
    console.error('❌ 音频WebSocket出错:', err)
  }

  audioWs.onclose = () => {
    console.log('🔌 音频WebSocket连接关闭')
  }
}
function playAudioData(arrayBuffer) {
  if (!audioPlaybackContext) {
    audioPlaybackContext = new (window.AudioContext || window.webkitAudioContext)()
  }

  audioPlaybackContext.decodeAudioData(arrayBuffer.slice(0), (decodedData) => {
    const source = audioPlaybackContext.createBufferSource()
    source.buffer = decodedData
    source.connect(audioPlaybackContext.destination)
    source.start(0)
  }, (err) => {
    console.error('❌ 解码音频失败:', err)
  })
}
// float32转16bit PCM
function floatTo16BitPCM(floatBuffer) {
  const output = new Int16Array(floatBuffer.length)
  for (let i = 0; i < floatBuffer.length; i++) {
    let s = Math.max(-1, Math.min(1, floatBuffer[i]))
    output[i] = s < 0 ? s * 0x8000 : s * 0x7FFF
  }
  return new Uint8Array(output.buffer)
}

// 解析讯飞返回结果
function parseXFResult(data) {
  return data.cn.st.rt.map(rt =>
    rt.ws.map(ws =>
      ws.cw[0].w
    ).join('')
  ).join('')
}

// 开始录音并连接 WebSocket
function startRecording() {
  if (isChatting.value || isMuted.value) return

  const ts = Math.floor(Date.now() / 1000)
  const signa = getSigna(ts)
  const url = `${hostUrl}?appid=${appid}&ts=${ts}&signa=${signa}`

  ws = new WebSocket(url)
  ws.binaryType = 'arraybuffer'

  ws.onopen = () => {
    console.log('✅ WebSocket连接成功')
    // 重置会话级状态，准备新的识别循环
    suspendProcessing = false
    silenceStartTime = null
    lastUtteranceText = ''
    currentRecognitionText.value = ''
    beginAudioCapture()
    isChatting.value = true
    isListening.value = true
  }

  ws.onmessage = (event) => {
    const res = JSON.parse(event.data)
    if (res.action === 'result') {
      const data = JSON.parse(res.data)
      const text = parseXFResult(data)
      // 更新最新一句话内容缓存
      if (text && text.trim()) {
        lastUtteranceText = text
      }

      if (data.ls === true || (data.cn && data.cn.st && data.cn.st.type === 0)) {
        // 最终结果：显示在"识别内容"，并锁定在展示区
        if (text && text.trim()) {
          currentRecognitionText.value = text
          displayRecognitionText.value = text
        }
      } else {
        // 中间结果，聆听时实时显示（发送中不更新）
        if (isListening.value) {
          currentRecognitionText.value = text
          displayRecognitionText.value = text
        }
      }
    }
  }

  ws.onerror = (err) => {
    console.error('❌ WebSocket错误:', err)
    isListening.value = false
  }

  ws.onclose = () => {
    console.log('🔌 WebSocket连接关闭')
    isChatting.value = false
    isListening.value = false
  }
}

function beginAudioCapture() {
  navigator.mediaDevices.getUserMedia({ audio: true }).then(stream => {
    audioStream = stream
  audioContext = new (window.AudioContext || window.webkitAudioContext)({ sampleRate: 16000 })
    sourceNode = audioContext.createMediaStreamSource(stream)
    processor = audioContext.createScriptProcessor(1024, 1, 1)

    processor.onaudioprocess = (e) => {
    if (suspendProcessing) return

    const input = e.inputBuffer.getChannelData(0)
    // 计算音量 RMS 用于静音检测
    let sumSquares = 0
    for (let i = 0; i < input.length; i++) {
      const s = input[i]
      sumSquares += s * s
    }
    const rms = Math.sqrt(sumSquares / input.length)

    // 正常送入 ASR
    const pcmData = floatTo16BitPCM(input)

    const combined = new Uint8Array(pcmBuffer.length + pcmData.length)
    combined.set(pcmBuffer)
    combined.set(pcmData, pcmBuffer.length)
    pcmBuffer = combined

    while (!suspendProcessing && pcmBuffer.length >= 1280) {
      const chunk = pcmBuffer.slice(0, 1280)
      ws.send(chunk.buffer)
      pcmBuffer = pcmBuffer.slice(1280)
    }

    // 静音检测：连续静音超过 2s 认为一句话结束
    if (rms < SILENCE_THRESHOLD) {
      if (!silenceStartTime) {
        silenceStartTime = Date.now()
      } else if (Date.now() - silenceStartTime >= SILENCE_DURATION_MS) {
        // 触发一次静音事件
        silenceStartTime = null
        if (isListening.value && !isSendingToBackend.value) {
          const textToSend = (currentRecognitionText.value || lastUtteranceText || '').trim()
          if (textToSend) {
            // 暂停处理与聆听，发送后再恢复
            suspendProcessing = true
            isListening.value = false
            // 锁定展示文本，不再变化
            displayRecognitionText.value = textToSend
            isSendingToBackend.value = true
            ;(async () => {
              try {
                await sendMessageToBackend(textToSend)
              } catch (err) {
                console.error('发送消息到后端失败:', err)
              } finally {
                // 清空仅供发送的缓存，保留显示内容
                currentRecognitionText.value = ''
                lastUtteranceText = ''
                isSendingToBackend.value = false
                suspendProcessing = false
                // 恢复聆听（保持同一会话，不重建 ws，避免日志刷屏）
                isListening.value = true
              }
            })()
          }
        }
      }
    } else {
      // 有声音，重置静音计时
      silenceStartTime = null
    }
    }

    sourceNode.connect(processor)
    processor.connect(audioContext.destination)
    console.log('🎙️ 开始采集麦克风')
  }).catch(err => {
    console.error('❌ 无法访问麦克风:', err)
    isChatting.value = false
  })
}

async function stopRecording() {
  if (!isChatting.value) return

  console.log('🛑 停止识别')
  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify({ end: true }))
  }

  setTimeout(async () => {
    if (processor) {
      processor.disconnect()
      processor = null
    }
    if (sourceNode) {
      sourceNode.disconnect()
      sourceNode = null
    }
    if (audioStream) {
      audioStream.getTracks().forEach(track => track.stop())
      audioStream = null
    }
    if (audioContext) {
      audioContext.close()
      audioContext = null
    }
    pcmBuffer = new Uint8Array(0)

    if (ws) {
      ws.close()
      ws = null
    }

    isChatting.value = false
    isListening.value = false
    console.log('✅ 资源释放完成')

    // 结束时不再自动发送，遵循"静音2秒自动发送"的流程
  }, 1000)
}

// 释放当前 ASR 与音频资源，但不弹窗发送
async function teardownAsrSession() {
  try {
    if (ws && ws.readyState === WebSocket.OPEN) {
      try { ws.send(JSON.stringify({ end: true })) } catch (e) { /* ignore */ }
    }
  } catch (e) { /* ignore */ }

  try {
    if (processor) {
      processor.disconnect()
      processor = null
    }
    if (sourceNode) {
      sourceNode.disconnect()
      sourceNode = null
    }
    if (audioStream) {
      audioStream.getTracks().forEach(track => track.stop())
      audioStream = null
    }
    if (audioContext) {
      await audioContext.close()
      audioContext = null
    }
    pcmBuffer = new Uint8Array(0)
    if (ws) {
      try { ws.close() } catch (e) { /* ignore */ }
      ws = null
    }
    isChatting.value = false
  } catch (e) {
    console.error('释放资源失败', e)
  }
}

function toggleRecording() {
  if (isChatting.value) {
    stopRecording()
  } else {
    startRecording()
  }
}

// 静音检测功能
function startSilentDetection() {
  if (isMuted.value) return
  
  // 自动开始录音
  if (!isChatting.value) {
    startRecording()
  }
}

// 切换静音状态
function toggleMute() {
  isMuted.value = !isMuted.value
  
  if (isMuted.value) {
    // 如果静音，停止录音
    if (isChatting.value) {
      stopRecording()
    }
  } else {
    // 如果取消静音，开始静音检测
    startSilentDetection()
  }
}

function handleCloseBot() {
  stopRecording()
  showChatBot.value = false
  isMuted.value = false
  currentRecognitionText.value = ''
}

async function sendMessageToBackend(overrideText) {
  try {
    // 优先发送本次语音识别文本，其次回退为历史文本合并
    const message = (overrideText && overrideText.trim()) || chatMessages.value.map(item => item.text).join(' ')

    // 发送 GET 请求给后端接口
    const response = await axios.get('/api/auth/start-voice-chat', {
      params: { message }
    })

    console.log('后端响应:', response.data)
  } catch (error) {
    console.error('发送消息到后端失败:', error)
  }
}
// 处理主题切换事件，按需实现
function handleThemeChange(newTheme) {
  console.log('主题切换为:', newTheme)
}

// 机器人提示相关方法
function showRandomBotTip() {
  const randomIndex = Math.floor(Math.random() * botTips.length)
  currentBotTip.value = botTips[randomIndex]
  showBotTip.value = true
  
  // 8秒后隐藏提示
  setTimeout(() => {
    showBotTip.value = false
  }, 8000)
}

function startBotTipTimer() {
  // 每15秒显示一次提示
  setTimeout(() => {
    if (!showChatBot.value) { // 只有在聊天窗口未打开时才显示提示
      showRandomBotTip()
    }
    startBotTipTimer() // 递归调用，持续显示提示
  }, 15000) // 15秒
}




// 添加这个方法
const submitAnswer2 = async () => {
  if (!answerContent.value.trim()) {
    ElMessage.warning('请填写答案后再提交')
    return
  }

  isEvaluating.value = true
  isLoadingResult.value = true
  console.log("1111"+selectedItem)
  try {
    const response = await axios.post('/api/xiaozhi/student/evaluate', {
      memoryId: 1,
      questionId: selectedItem.value.id, // 假设 selectedItem 中有题目ID
      answer: answerContent.value
    }, {
      responseType: 'stream',
      onDownloadProgress: (e) => {
        // 流式处理评估结果
        evaluationResult.value = e.event.target.responseText
      }
    })

    resultDialogVisible2.value = true
    dialogVisible.value = false
  } catch (error) {
    console.error('评估失败:', error)
    ElMessage.error('评估失败，请稍后再试')
  } finally {
    isEvaluating.value = false
    isLoadingResult.value = false
  }
}

// 题目类型映射
const getQuestionTypeName = (type) => {
  const typeMap = {
    choice: '选择题',
    programming: '编程题',
    short_answer: '简答题',
    discussion: '论述题',
    calculation: '计算题'
  }
  return typeMap[type] || type
}

const isLoading = ref(false)
// 标签颜色
const getTagType = (type) => {
  const typeMap = {
    choice: '',
    programming: 'warning',
    short_answer: 'success',
    discussion: 'info',
    calculation: 'danger'
  }
  return typeMap[type] || ''
}

// 处理重要提醒项目点击事件
const handleImportantItemClick = (item) => {
  try {
    if (!item || !item.id) {
      ElMessage.error('项目信息不完整，无法跳转')
      return
    }
    
    if (item.type === 'exam') {
      // 考试类型：跳转到考试确认界面
      console.log('跳转到考试确认界面:', item.id)
      router.push({ name: 'ExamConfirm', params: { id: item.id } })
    } else {
      // 作业类型：跳转到答题界面
      console.log('跳转到作业答题界面:', item.id)
      router.push({ name: 'homework', params: { id: item.id } })
    }
  } catch (error) {
    console.error('跳转失败:', error)
    ElMessage.error('跳转失败，请稍后再试')
  }
}

const loadImportantAssignments = async () => {
  try {
    const res = await axios.get('/xiaozhi/student/upcoming', {
      params: {
        studentId: useUserStore().currentUserId, // 请替换为真实的学生ID
        days: 3       // 默认3天内截止
      }
    })

    if (res.data.code === 200) {
      // 兼容旧返回（仅作业）和新返回（作业+考试）
      const data = res.data.data || {}
      if (Array.isArray(data)) {
        importantItems.value = (data || []).map(a => ({ ...a, type: 'assignment' }))
        importantAssignments.value = data
      } else {
        const asg = (data.assignments || []).map(a => ({ ...a, type: 'assignment' }))
        const exm = (data.exams || []).map(e => ({ ...e, type: 'exam', dueDate: e.examDate }))
        importantItems.value = [...asg, ...exm].sort((a,b) => new Date(a.dueDate||a.examDate) - new Date(b.dueDate||b.examDate))
        importantAssignments.value = data.assignments || []
      }
      
      // 为每个项目添加课程名称（如果后端没有提供）
      importantItems.value = importantItems.value.map(item => {
        if (!item.courseName && item.courseId) {
          // 如果没有课程名称，尝试从已选课程中获取
          const course = selectedCourses.value.find(c => c.id === item.courseId)
          if (course) {
            item.courseName = course.courseName
          }
        }
        return item
      })
    } else {
      ElMessage.error(res.data.message || '获取重要提醒失败')
    }
  } catch (err) {
    console.error('获取重要提醒失败:', err)
    ElMessage.error('网络异常，请稍后再试')
  }
}

const loadSelectedCourses = async () => {
  try {
    const res = await axios.get('/xiaozhi/student/my-courses', {
      params: { studentId: useUserStore().currentUserId } // 假设 uuid 即 studentId
    })

    if (res.data.code === 200) {
      selectedCourses.value = res.data.data || []
      console.log('已选课程:', selectedCourses.value)
    } else {
      ElMessage.error(res.data.message || '获取已选课程失败')
    }
  } catch (err) {
    console.error('获取课程失败:', err)
    ElMessage.error('网络异常，请稍后再试')
  }
}

const loadAssignments = async () => {
  try {
    const res = await axios.get('/xiaozhi/student/assignments', {
      params: { studentId: useUserStore().currentUserId }
    })
    if (res.data.code === 200) {
      const allAssignments = res.data.data || []

      // 区分已提交和未提交
      unsubmittedList.value = allAssignments.filter(item => !item.submitted)
      submittedList.value = allAssignments.filter(item => item.submitted)
    } else {
      ElMessage.error(res.data.message || '获取作业失败')
    }
  } catch (error) {
    console.error('加载作业异常:', error)
    ElMessage.error('加载作业失败，请稍后再试')
  }
}
const historyList = ref([]) // 初始为空，由后端加载填充
  // 推荐题目数据模拟
  const recommendList = ref([
  {
      title: '计算机网络原理',
      desc: 'IP层子网划分的综合应用',
      type: '问答',
      typeTag: 'info',
      tags: [
        { name: '难度', percent: 60, status: 'success' },
        { name: '频度', percent: 40, status: 'warning' },
        { name: '综合度', percent: 80, status: 'exception' }
      ]
    },
    {
      title: '计算机网络原理',
      desc: '互联网协议体系分层架构',
      type: '讨论',
      typeTag: 'warning',
      tags: [
        { name: '难度', percent: 30, status: 'success' },
        { name: '频度', percent: 50, status: 'warning' },
        { name: '综合度', percent: 70, status: 'exception' }
      ]
    }
  ])
  
  const rules = {
  courseCode: [
    { required: true, message: '请输入课程ID', trigger: 'blur' },
    { pattern: /^\d{1,10}$/, message: '课程ID需为1-10位数字', trigger: 'blur' }
    ]
  }

const showAddCourseDialog = () => {
  classDialogVisible.value = true
}

const classHandleClose = (done) => {
  done()
}

// 实际API调用函数（示例）
const addCourseToStudent = async (courseCode) => {
  console.log('添加课程:', courseCode)
  // 这里应该是实际的API调用，例如：
  // const response = await axios.post('/api/student/courses', { courseCode })
  // return response.data
  
  // 模拟API返回
  return new Promise(resolve => {
    setTimeout(() => {
      resolve({
        success: true,
        message: '课程添加成功'
      })
    }, 500)
  })
}

const confirmAddCourse = async () => {
  try {
    await courseFormRef.value.validate();

    const studentId = useUserStore().currentUserId;
    const courseId = parseInt((courseForm.value.courseCode || '').trim(), 10)

    if (!studentId) {
      ElMessage.error('未登录或用户信息缺失');
      return
    }
    if (!Number.isInteger(courseId) || courseId <= 0) {
      ElMessage.error('课程ID不合法');
      return
    }

    // 调用后端加入课程接口
    const res = await axios.post('/api/xiaozhi/student/addCourse', null, {
      params: { studentId, courseId }
    });

    if (res.data.code === 200 || res.data.success) {
      ElMessage.success(res.data.message || '加入课程成功！');
      classDialogVisible.value = false;
      await loadSelectedCourses()
    } else {
      ElMessage.error(res.data.message || '加入课程失败');
    }
  } catch (error) {
    console.error('加入课程异常:', error);
    if (error?.courseCode) {
      ElMessage.error(error.courseCode?.[0]?.message || '课程ID格式错误')
    } else {
      ElMessage.error(error.message || '网络异常，请稍后重试');
    }
  }
};


// 暴露给模板的变量和方法
defineExpose({
  showAddCourseDialog,
  stopRecording
})

function deepClone(obj) {
  return JSON.parse(JSON.stringify(obj))
}

function hoverButton(name) {
  activeBtn.value = name
}

function resetButton() {
  activeBtn.value = null
}

function getDotStyle(n) {
  const angle = (n * 30) * (Math.PI / 180)
  const radius = 100
  return {
    top: `${50 + radius * Math.sin(angle)}%`,
    left: `${50 + radius * Math.cos(angle)}%`
  }
}
// 生成报告
const generateReport = async () => {
  if (!selectedSubject.value) {
    ElMessage.warning('请先选择要分析的科目')
    return
  }

  try {
    isGenerating.value = true
    showReport.value = false
    
    // 调用学情分析接口
    const response = await axios.post('/api/xiaozhi/teacher/student', {
      studentId: useUserStore().currentUserId, // 假设当前学生ID为1
      courseId: selectedSubject.value
    }, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    })

    if (response.data) {
      analysisResult.value = {
        knowledgeAnalysis: response.data.knowledgeAnalysis || '暂无分析结果',
        teachingSuggestion: response.data.teachingSuggestion || '暂无教学建议'
      }
      showReport.value = true
      ElMessage.success('学情分析报告生成成功')
    } else {
      ElMessage.error('获取分析结果失败')
    }
  } catch (error) {
    console.error('生成报告失败:', error)
    ElMessage.error('生成报告失败，请稍后再试')
  } finally {
    isGenerating.value = false
  }
}


function newChat() {
  messages.value = []
  userQuestion.value = ''
}

function openChatDialog() {
  chatActive.value = true
}
function sendQuestion() {
  if (!userQuestion.value.trim()) {
    ElMessage.warning('请输入你的问题')
    return
  }

  sendRequest(userQuestion.value.trim())
  userQuestion.value = ''
}


function generateQuestion() {
  const newQuestion = {
    title: 'AI智能生成题目 ' + Math.floor(Math.random() * 1000),
    desc: '通过智能助手生成的个性化推荐题目，适合巩固知识点',
    type: 'AI生成',
    typeTag: 'success',
    tags: [
      { name: '难度', percent: Math.floor(Math.random() * 100), status: 'success' },
      { name: '频度', percent: Math.floor(Math.random() * 100), status: 'warning' },
      { name: '综合度', percent: Math.floor(Math.random() * 100), status: 'exception' }
    ],
    isNew: true
  }

  if (recommendList?.value) {
    recommendList.value.unshift(newQuestion)
    dialogVisible.value = true
  } else {
    ElMessage.error('推荐列表未连接，无法添加题目')
  }
}

const openDialog = (item, mode) => {
  selectedItem.value = deepClone(item); // 使用深拷贝避免引用问题
  dialogMode.value = mode;
  dialogVisible.value = true;
  answerContent.value = '';

  nextTick(() => {
    // 弹窗展开后滚动到答题区域
    if (mode === 'answer') {
      document.querySelector('.answer-area')?.scrollIntoView({ behavior: 'smooth' })
    }
  })
}


const handleClose = () => {
  dialogVisible.value = false
  selectedQuestion.value = null
}

onMounted(() => {
  initUUID()
  // 移除 setInterval，改用手动滚动
  watch(messages, () => scrollToBottom(), { deep: true })
  hello()

  loadHistory() // 新增：加载历史练习记录
    loadAssignments()  // 加上这句
      loadSelectedCourses() // 加载已选课程
       loadImportantAssignments()
        loadRecommendQuestions()
         connectAudioWebSocket()
         
  // 初始化时间并每分钟更新
  updateCurrentTime()
  setInterval(updateCurrentTime, 60000)
  
  // 启动机器人提示定时器
  startBotTipTimer()
})

// 监听聊天机器人显示状态，自动开始静音检测
watch(showChatBot, (newVal) => {
  if (newVal && !isMuted.value) {
    // 延迟一秒后开始静音检测，给用户时间准备
    setTimeout(() => {
      startSilentDetection()
    }, 1000)
  }
})
// 加载推荐题目
const loadRecommendQuestions = async () => {
  try {
    isLoading.value = true
    const response = await axios.get('/xiaozhi/student/questions/by-creator', {
      params: {
        createdBy: useUserStore().currentUserId // 固定传创建人ID为1
      }
    })
    
    if (response.data.code === 200) {
      // 转换数据格式并添加随机难度/频度/综合度
      recommendList.value = response.data.data.map(question => ({
        id: question.id,
        title: question.content.substring(0, 30) + (question.content.length > 30 ? '...' : ''),
        fullTiTle: question.content,
        desc: question.knowledgePoint || '通用知识点',
        type: getQuestionTypeName(question.type),
        typeTag: getTagType(question.type),
        tags: [
          { 
            name: '难度', 
            percent: Math.floor(Math.random() * 100), 
            status: getRandomStatus() 
          },
          { 
            name: '频度', 
            percent: Math.floor(Math.random() * 100), 
            status: getRandomStatus() 
          },
          { 
            name: '综合度', 
            percent: Math.floor(Math.random() * 100), 
            status: getRandomStatus() 
          }
        ],
        originalData: question // 保留原始数据
      }))
    }
  } catch (error) {
    console.error('加载推荐题目失败:', error)
    ElMessage.error('加载题目失败，请稍后再试')
  } finally {
    isLoading.value = false
  }
}
const scrollToBottom = () => {
  if (messaggListRef.value) {
    messaggListRef.value.scrollTop = messaggListRef.value.scrollHeight
  }
}

// 随机获取进度条状态
const getRandomStatus = () => {
  const statuses = ['success', 'warning', 'exception']
  return statuses[Math.floor(Math.random() * statuses.length)]
}

const hello = () => {
  sendRequest('你好')
}

const loadHistory = async () => {
  try {
    const res = await axios.get('/xiaozhi/student/practice-log', {
      params: {
        studentId: useUserStore().currentUserId  // 假设你用 uuid 作为 studentId
      }
    })

    if (res.data.code === 200) {
      historyList.value = res.data.data.map(item => ({
        id: item.logId,
        title: item.questionContent.replace(/<\/?[^>]+(>|$)/g, ""), // 去 HTML
        difficulty: Math.floor(Math.random() * 100),
        importance: Math.floor(Math.random() * 100),
        innovation: Math.floor(Math.random() * 100),
        total: Math.floor(Math.random() * 100),
        score: item.score ?? 0,
        studentAnswer: item.studentAnswer,
        errorReason: item.errorReason
      }))
    } else {
      ElMessage.error(res.data.message || '获取历史记录失败')
    }
  } catch (err) {
    console.error('请求异常:', err)
    ElMessage.error('加载练习记录失败，请稍后再试')
  }
}


const sendRequest = (message) => {
  isSending.value = true
  const userMsg = {
    isUser: true,
    content: message,
    isTyping: false,
    isThinking: false,
  }
  //第一条默认发送的用户消息"你好"不放入会话列表
  if(messages.value.length > 0){
    messages.value.push(userMsg)
  }


  // 添加机器人加载消息
  const botMsg = {
    isUser: false,
    content: '', // 增量填充
    isTyping: true, // 显示加载动画
    isThinking: false,
  }
  messages.value.push(botMsg)
  const lastMsg = messages.value[messages.value.length - 1]
  scrollToBottom()

  // axios
  //   .post(
  //     '/api/xiaozhi/student/chat',
  //     { memoryId: uuid.value, message },
  //     {
  //       responseType: 'stream', // 必须为合法值 "text"
  //       onDownloadProgress: (e) => {
  //         const fullText = e.event.target.responseText // 累积的完整文本
  //         let newText = fullText.substring(lastMsg.content.length)
  //         lastMsg.content += newText //增量更新
  //         console.log(lastMsg)
  //         scrollToBottom() // 实时滚动
  //       },
  //     }
  //   )
  //   .then(() => {
  //     // 流结束后隐藏加载动画
  //     messages.value.at(-1).isTyping = false
  //     isSending.value = false
  //   })
  //   .catch((error) => {
  //     console.error('流式错误:', error)
  //     messages.value.at(-1).content = '请求失败，请重试'
  //     messages.value.at(-1).isTyping = false
  //     isSending.value = false
  //   })
}



// 初始化 UUID
const initUUID = () => {
  let storedUUID = localStorage.getItem('user_uuid')
  if (!storedUUID) {
    storedUUID = uuidToNumber(uuidv4())
    localStorage.setItem('user_uuid', storedUUID)
  }
  uuid.value = storedUUID
}

const uuidToNumber = (uuid) => {
  let number = 0
  for (let i = 0; i < uuid.length && i < 6; i++) {
    const hexValue = uuid[i]
    number = number * 16 + (parseInt(hexValue, 16) || 0)
  }
  return number % 1000000
}

// 转换特殊字符
const convertStreamOutput = (output) => {
  return output
    .replace(/\n/g, '<br>')
    .replace(/\t/g, '&nbsp;&nbsp;&nbsp;&nbsp;')
    .replace(/&/g, '&amp;') // 新增转义，避免 HTML 注入
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
}

// const newChat = () => {
//   // 这里添加新会话的逻辑
//   console.log('开始新会话')
//   localStorage.removeItem('user_uuid')
//   window.location.reload()
// }

// function goToDetail(id) {
//   router.push({ name: 'QuestionDetail', params: { id: String(id) } })
// }
function goToDetail(id) {
  router.push(`/detail/${id}`)
}

function enterCourse(id) {
  router.push({ path: '/course', query: { id } })
}

function addRecommendedQuestion() {
  const newQuestion = {
    title: 'AI生成题目 ' + Math.floor(Math.random() * 1000),
    desc: '这是通过智能助手生成的题目,内容可以根据AI返回调整',
    type: 'AI生成',
    typeTag: 'success',
    tags: [
      { name: '难度', percent: Math.floor(Math.random() * 100), status: 'success' },
      { name: '频度', percent: Math.floor(Math.random() * 100), status: 'warning' },
      { name: '综合度', percent: Math.floor(Math.random() * 100), status: 'exception' }
    ]
  }
  recommendList.value.unshift(newQuestion) // 前插，最新的在前
  ElMessage.success('新题目已添加到推荐列表')
}



function handleDoWork(id) {
  // 使用命名路由并传递params
  router.push(`/homework/${id}`) 
  // 或者使用path方式
  // router.push(`/homework/${id}`)
}

// 点击重做
function handleRedo(id) {
   // 使用命名路由并传递params
  router.push(`/finishhomework/${id}`) 
}

// 提交答题
function submitAnswer() {
  if (!answerContent.value) {
    ElMessage.warning('请填写作业答案后提交')
    return
  }

  ElMessage.success(`作业【${currentWork.value.title}】提交成功`)

  // 从未上交列表中移除
  const index = unsubmittedList.value.indexOf(currentWork.value)
  if (index !== -1) {
    unsubmittedList.value.splice(index, 1)
  }

  // 添加到已上交列表
  submittedList.value.push({
    title: currentWork.value.title,
    desc: currentWork.value.desc,
    score: currentWork.value.score
  })

  dialogVisible.value = false
}

function submitWork(work) {
  const unanswered = work.questions.filter(q => !q.answer || q.answer.trim() === '')
  if (unanswered.length > 0) {
    ElMessage.warning(`请完成所有题目后再提交，剩余 ${unanswered.length} 道未作答`)
    return
  }

  const index = unsubmittedList.value.findIndex(item => item.title === work.title)
  if (index !== -1) {
    unsubmittedList.value.splice(index, 1)
  }

  submittedList.value.push({
    ...work,
    score: '等待老师批阅'
  })

  doWorkDialogVisible.value = false
  ElMessage.success('作业提交成功！')
}
const generateForm = reactive({
  knowledge: '',
  type: '',
  count: 5
})

const generatedQuestions = ref([])

function openSelectDialog() {
  selectDialogVisible.value = true
}

async function handleGenerate() {
  if (!generateForm.knowledge || !generateForm.type) {
    ElMessage.warning('请填写完整的生成信息')
    return
  }

  try {
       isGenerating.value = true
    isLoading.value = true
    const { data } = await axios.post('/api/xiaozhi/student/generate', {
      studentId: useUserStore().currentUserId,
      cocurseId:101,
      questionType: generateForm.type,
      knowledgePoint: generateForm.knowledge,
      count: generateForm.count
    })
    generatedQuestions.value = data.data || []
    if (generatedQuestions.value.length === 0) {
      ElMessage.warning('未查询到符合条件的题目')
      return
    }
    selectDialogVisible.value = false
    resultDialogVisible.value = true
  } catch (err) {
    ElMessage.error('生成失败，请稍后重试')
  } finally {
    isGenerating.value = false
    isLoading.value = false
  }
}

const handleSave = async () => {
  try {
    // 准备请求数据
    const saveRequest = {
      courseId: 101, // 假设您有选中的课程ID
      createdBy: useUserStore().currentUserId,   // 当前用户ID
      questions: generatedQuestions.value.map(q => ({
        type: q.type,
        content: q.content,
        answer: q.answer || '',
        knowledgePoint: q.knowledgePoint || '通用知识点',
        difficulty: q.difficulty || 'medium'
      }))
    }

    // 调用后端API
    const response = await axios.post('/api/xiaozhi/student/save', saveRequest)

    if (response.data.code === 200) {
      // 将生成的题目添加到推荐列表
      recommendList.value.unshift(...generatedQuestions.value.map(q => ({
        title: q.content.substring(0, 30) + (q.content.length > 30 ? '...' : ''),
        desc: q.knowledgePoint || 'AI生成题目',
        type: getQuestionTypeName(q.type),
        typeTag: getTagType(q.type),
        tags: [
          { name: '难度', percent: 13, status: 'success' },
          { name: '频度', percent: 50, status: 'warning' },
          { name: '综合度', percent: 70, status: 'exception' }
        ]
      })))

      // 关闭对话框并显示成功消息
      resultDialogVisible.value = false
      successDialogVisible.value = true
      ElMessage.success('题目已成功保存并添加到推荐列表')
      
    } else {
      ElMessage.error(response.data.message || '保存题目失败')
    }
  } catch (error) {
    console.error('保存题目失败:', error)
    ElMessage.error('保存题目失败，请稍后再试')
  }
}
  </script>
  
  <style scoped>
  .answer-area-container {
  margin: 20px 0;
  background: #f9f9f9;
  padding: 16px;
  border-radius: 8px;
  border: 1px solid #e0e0e0;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
}

.answer-input {
  width: 100%;
}

.submit-area {
  text-align: right;
  margin-top: 10px;
}

  .question-content {
  flex: 1;
}
  .do-work-container {
  display: flex;
  gap: 16px;
}
.question-sidebar {
  width: 150px;
  border-right: 1px solid #e4e4e4;
  padding-right: 10px;
}
  .app-layout {
  display: flex;
}

.logo-section {
  text-align: center;
  margin-bottom: 20px;
}

.logo-text {
  display: block;
  margin-top: 10px;
  font-weight: bold;
  font-size: 18px;
}

.sidebar-actions {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 20px;
}

.main-content {
  flex: 1;
  padding: 20px;
}

  .history_kuai{
    display: flex;
  }
  .mb-4{
    min-width: 1200px;
    /* height: 80vh; */
  }
  .text-lg{
    width: 200px;
    margin-top: 60px;
  }
  .text-sm{
    max-width: 800px;
    flex:2;
  }
  .scorecircle{
      margin-right: 100px;
  }
  .re-button{
    margin-top: 60px;    
  }
  .history-page {
  max-width: 1800px;
  margin: auto;
  }
  .history-item {
  display: flex;
  justify-content: space-between;
  margin: 10px 0;
  padding: 10px;
  border: 1px solid #eee;
  border-radius: 8px;
}
  .assessment-container {
  width: 100%;
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
  perspective: 1000px;
}

.report-card {
  border: 1px solid #e0e0e0;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  padding: 30px;
  background: #ffffff;
  position: relative;
  overflow: hidden;
  transition: all 0.3s ease;
  transform-style: preserve-3d;
}

.card-hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
}

/* 装饰角 */
.decoration-corner {
  position: absolute;
  width: 60px;
  height: 60px;
  border-width: 2px;
  border-style: solid;
  opacity: 0.1;
  transition: all 0.3s ease;
}

.decoration-corner.top-left {
  top: 0;
  left: 0;
  border-right: none;
  border-bottom: none;
  border-color: #409EFF;
  border-top-left-radius: 12px;
}

.decoration-corner.top-right {
  top: 0;
  right: 0;
  border-left: none;
  border-bottom: none;
  border-color: #67C23A;
  border-top-right-radius: 12px;
}

.decoration-corner.bottom-left {
  bottom: 0;
  left: 0;
  border-right: none;
  border-top: none;
  border-color: #E6A23C;
  border-bottom-left-radius: 12px;
}

.decoration-corner.bottom-right {
  bottom: 0;
  right: 0;
  border-left: none;
  border-top: none;
  border-color: #F56C6C;
  border-bottom-right-radius: 12px;
}

.report-card:hover .decoration-corner {
  opacity: 0.3;
}

/* 按钮组样式 */
.button-group {
  display: flex;
  gap: 15px;
  margin-bottom: 25px;
  flex-wrap: wrap;
  justify-content: center;
  position: relative;
  z-index: 2;
}

.bottom-buttons {
  margin-top: 25px;
  margin-bottom: 0;
}

/* 按钮样式 */
.action-btn {
  border-radius: 24px;
  padding: 12px 24px;
  position: relative;
  overflow: hidden;
  transition: all 0.3s ease;
  border: none;
  background: #f5f7fa;
  color: #606266;
  display: flex;
  align-items: center;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
}

.action-btn i {
  margin-right: 8px;
  font-size: 16px;
}

.action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.el-button--primary {
  background: linear-gradient(135deg, #6e8efb, #a777e3);
  color: white;
}

/* 内容区域样式 */
.report-content-border {
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  padding: 25px;
  min-height: 400px;
  background: #fafafa;
  position: relative;
  overflow: hidden;
}

.content-highlight {
  position: absolute;
  top: 0;
  left: 0;
  width: 4px;
  height: 100%;
  background: linear-gradient(to bottom, #6e8efb, #a777e3);
  transition: all 0.3s ease;
}

.report-content-border:hover .content-highlight {
  width: 6px;
}

/* 浮动点装饰 */
.floating-dots {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.el-dialog__body p {
  margin-bottom: 10px;
  color: #555;
  font-weight: 500;
}

.floating-dots span {
  position: absolute;
  display: block;
  background: rgba(110, 142, 251, 0.15);
  border-radius: 50%;
  animation: float 6s infinite ease-in-out;
}

@keyframes float {
  0%, 100% {
    transform: translateY(0) translateX(0);
  }
  25% {
    transform: translateY(-10px) translateX(5px);
  }
  50% {
    transform: translateY(5px) translateX(-10px);
  }
  75% {
    transform: translateY(-5px) translateX(10px);
  }
}

/* 响应式调整 */
@media (max-width: 768px) {
  .button-group {
    flex-direction: column;
    align-items: center;
  }
  
  .action-btn {
    width: 100%;
    justify-content: center;
  }
}
  .academy-page {
    position: relative;
    padding: 1rem 2rem;
  }
  
  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: white;
    padding: 1rem;
    width: 1640px;
    height: 100px;
    border-bottom: 1px solid #eee;
    position: relative;
    left: -30px;
    top:-10px
  }
  
  .logo-area {
    display: flex;
    align-items: center;
    gap: 1rem;
  }
  
  .logo-area h1 {
    font-size: 1.5rem;
    margin: 0;
    color: #1a56db;
  }
  
  .logo-area p {
    font-size: 0.85rem;
    color: #999;
  }
  
  .user-area {
    display: flex;
    align-items: center;
    gap: 1rem;
  }
  
  .main-tabs {
    margin-top: 1rem;
  }
  
  .recommend-section {
  margin-top: 2rem;
}


.question-card {
  border-radius: 12px;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.question-card:hover {
  box-shadow: 0 4px 20px rgba(26, 86, 219, 0.2);
  transform: scale(1.02);
  border: 1px solid #1a56db;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.75rem;
}
.card-header h3 {
  margin: 0.5rem 0;
}

.fzcourse-card {
  width: 100%;
  margin-bottom: 20px;
  transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  border-radius: 16px;
  overflow: hidden;
  background: linear-gradient(135deg, #ffffff 0%, #f8faff 50%, #f0f4ff 100%);
  border: 1px solid rgba(255, 255, 255, 0.8);
  box-shadow: 
    0 4px 6px -1px rgba(0, 0, 0, 0.1),
    0 2px 4px -1px rgba(0, 0, 0, 0.06),
    0 0 0 1px rgba(255, 255, 255, 0.5) inset,
    0 1px 3px rgba(0, 0, 0, 0.1) inset;
  position: relative;
}

.fzcourse-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, #409eff, #67c23a, #e6a23c);
  border-radius: 16px 16px 0 0;
}

.fzcourse-card::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, 
    rgba(255, 255, 255, 0.4) 0%, 
    rgba(255, 255, 255, 0.1) 50%, 
    rgba(255, 255, 255, 0) 100%);
  pointer-events: none;
  border-radius: 16px;
}

.fzcourse-card:hover {
  transform: translateY(-4px) scale(1.01);
  box-shadow: 
    0 12px 20px -5px rgba(0, 0, 0, 0.15),
    0 6px 10px -5px rgba(0, 0, 0, 0.1),
    0 0 0 1px rgba(255, 255, 255, 0.8) inset,
    0 1px 3px rgba(0, 0, 0, 0.1) inset;
  border-color: rgba(64, 158, 255, 0.3);
}

.fzcard {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;  
  gap: 8px;
  position: relative;
  z-index: 1;
  padding: 16px;
}

.fzcard::before {
  content: '';
  position: absolute;
  top: -8px;
  left: -8px;
  right: -8px;
  bottom: -8px;
  background: linear-gradient(135deg, 
    rgba(255, 255, 255, 0.6) 0%, 
    rgba(255, 255, 255, 0.2) 50%, 
    rgba(255, 255, 255, 0.05) 100%);
  border-radius: 12px;
  z-index: -1;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.fzcourse-card:hover .fzcard::before {
  opacity: 1;
}

.badge {
  background: linear-gradient(135deg, #409eff 0%, #67c23a 100%);
  color: white;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  box-shadow: 
    0 2px 4px rgba(64, 158, 255, 0.3),
    0 1px 2px rgba(64, 158, 255, 0.2),
    0 0 0 1px rgba(255, 255, 255, 0.2) inset;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
  transition: all 0.3s ease;
}

.fzcourse-card:hover .badge {
  transform: scale(1.05);
  box-shadow: 
    0 4px 8px rgba(64, 158, 255, 0.4),
    0 2px 4px rgba(64, 158, 255, 0.3),
    0 0 0 1px rgba(255, 255, 255, 0.3) inset;
}

.value {
  color: #f56c6c;
  font-weight: 700;
  font-size: 14px;
  margin-left: auto; 
  margin-right: 10px;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  padding: 4px 8px;
  background: linear-gradient(135deg, 
    rgba(245, 108, 108, 0.1) 0%, 
    rgba(245, 108, 108, 0.05) 100%);
  border-radius: 8px;
  border: 1px solid rgba(245, 108, 108, 0.2);
}

.fzcourse-card:hover .value {
  transform: scale(1.05);
  background: linear-gradient(135deg, 
    rgba(245, 108, 108, 0.15) 0%, 
    rgba(245, 108, 108, 0.08) 100%);
  border-color: rgba(245, 108, 108, 0.3);
  box-shadow: 0 2px 4px rgba(245, 108, 108, 0.2);
}

.desc {
  font-size: 0.95rem;
  color: #666;
  margin-bottom: 1rem;
  line-height: 1.4;
}

.progress-area {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.tag-group {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.tag-label {
  font-size: 0.85rem;
  color: #999;
}

.card-footer {
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
}
/* .card-footer {
  display: flex;
  justify-content: space-between;
  margin-top: 1rem;
} */
  .card-container {
    display: flex;
    gap: 1rem;
    flex-wrap: wrap;
  }
/* .card-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1.5rem;
} */
  
  .question-card {
    width: 300px;
  }
  
  .course-card {
    display: flex;
    height: 180px;
    margin: 15px;
    gap: 1rem;
    align-items: center;
  }
  
  .course-card img {
    width: 120px;
    border-radius: 8px;
  }
  
  .course-info {
    flex: 1;
  }
  
  .floating-ai-btn {
    position: fixed;
    bottom: 2rem;
    right: 2rem;
    z-index: 100;
    font-size: 1.4rem;
  }

  .course-section {
  margin-top: 2rem;
}



.course-card {
  transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  border-radius: 16px;
  overflow: hidden;
  background: linear-gradient(135deg, #ffffff 0%, #f8faff 50%, #f0f4ff 100%);
  border: 1px solid rgba(255, 255, 255, 0.8);
  box-shadow: 
    0 4px 6px -1px rgba(0, 0, 0, 0.1),
    0 2px 4px -1px rgba(0, 0, 0, 0.06),
    0 0 0 1px rgba(255, 255, 255, 0.5) inset,
    0 1px 3px rgba(0, 0, 0, 0.1) inset;
  position: relative;
}

.course-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, #667eea, #764ba2, #f093fb);
  border-radius: 16px 16px 0 0;
}

.course-card::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, 
    rgba(255, 255, 255, 0.4) 0%, 
    rgba(255, 255, 255, 0.1) 50%, 
    rgba(255, 255, 255, 0) 100%);
  pointer-events: none;
  border-radius: 16px;
}

.course-card:hover {
  transform: translateY(-8px) scale(1.02);
  box-shadow: 
    0 20px 25px -5px rgba(0, 0, 0, 0.15),
    0 10px 10px -5px rgba(0, 0, 0, 0.1),
    0 0 0 1px rgba(255, 255, 255, 0.8) inset,
    0 1px 3px rgba(0, 0, 0, 0.1) inset;
  border-color: rgba(102, 126, 234, 0.3);
}

.card-content {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  padding: 1rem;
}

.course-cover {
  width: 120px;
  height: 120px;
  object-fit: cover;
  border-radius: 12px;
  box-shadow: 
    0 8px 16px rgba(0, 0, 0, 0.15),
    0 4px 8px rgba(0, 0, 0, 0.1),
    0 0 0 1px rgba(255, 255, 255, 0.8) inset;
  transition: all 0.3s ease;
  position: relative;
}

.course-cover::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, 
    rgba(255, 255, 255, 0.3) 0%, 
    rgba(255, 255, 255, 0.1) 50%, 
    rgba(255, 255, 255, 0) 100%);
  border-radius: 12px;
  pointer-events: none;
}

.course-card:hover .course-cover {
  transform: scale(1.05);
  box-shadow: 
    0 12px 24px rgba(0, 0, 0, 0.2),
    0 6px 12px rgba(0, 0, 0, 0.15),
    0 0 0 1px rgba(255, 255, 255, 0.9) inset;
}

.course-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  position: relative;
  z-index: 1;
}

.course-info::before {
  content: '';
  position: absolute;
  top: -10px;
  left: -10px;
  right: -10px;
  bottom: -10px;
  background: linear-gradient(135deg, 
    rgba(255, 255, 255, 0.8) 0%, 
    rgba(255, 255, 255, 0.4) 50%, 
    rgba(255, 255, 255, 0.1) 100%);
  border-radius: 12px;
  z-index: -1;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.course-card:hover .course-info::before {
  opacity: 1;
}

.course-title {
  font-size: 1.25rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
  color: #2d3748;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.course-card:hover .course-title {
  color: #1a202c;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
}

.course-desc {
  font-size: 0.95rem;
  color: #4a5568;
  margin-bottom: 1rem;
  line-height: 1.5;
  text-shadow: 0 1px 1px rgba(255, 255, 255, 0.8);
  transition: all 0.3s ease;
}

.course-card:hover .course-desc {
  color: #2d3748;
}

.course-meta {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.courseButton {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 8px;
  padding: 8px 16px;
  font-weight: 600;
  color: white;
  box-shadow: 
    0 4px 6px rgba(102, 126, 234, 0.3),
    0 2px 4px rgba(102, 126, 234, 0.2),
    0 0 0 1px rgba(255, 255, 255, 0.2) inset;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.courseButton::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, 
    transparent, 
    rgba(255, 255, 255, 0.3), 
    transparent);
  transition: left 0.5s ease;
}

.courseButton:hover {
  transform: translateY(-2px);
  box-shadow: 
    0 6px 12px rgba(102, 126, 234, 0.4),
    0 4px 8px rgba(102, 126, 234, 0.3),
    0 0 0 1px rgba(255, 255, 255, 0.3) inset;
}

.courseButton:hover::before {
  left: 100%;
}

.courseButton:active {
  transform: translateY(0);
  box-shadow: 
    0 2px 4px rgba(102, 126, 234, 0.3),
    0 1px 2px rgba(102, 126, 234, 0.2),
    0 0 0 1px rgba(255, 255, 255, 0.1) inset;
}

.app-layout {
  display: flex;
  height: 100vh;
}

.logo-section {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.logo-text {
  font-size: 18px;
  font-weight: bold;
  margin-top: 10px;
}

.new-chat-button {
  width: 100%;
  margin-top: 20px;
}

.main-content {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}
.chat-container {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.message-list {
  flex: 1;
  overflow-y: auto;
  padding: 10px;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  background-color: #fff;
  margin-bottom: 10px;
  display: flex;
  flex-direction: column;
}

.message {
  margin-bottom: 10px;
  padding: 10px;
  border-radius: 4px;
  display: flex;
  /* align-items: center; */
}

.user-message {
  max-width: 70%;
  background-color: #e1f5fe;
  align-self: flex-end;
  flex-direction: row-reverse;
}

.bot-message {
  max-width: 100%;
  background-color: #f1f8e9;
  align-self: flex-start;
}

.message-icon {
  margin: 0 10px;
  font-size: 1.2em;
}

.loading-dots {
  padding-left: 5px;
}

.dot {
  display: inline-block;
  margin-left: 5px;
  width: 8px;
  height: 8px;
  background-color: #4e8ef7;
  border-radius: 50%;
  opacity: 0.4;
  animation: pulse 1.2s infinite ease-in-out both;
}

.dot:nth-child(2) {
  animation-delay: -0.6s;
}

@keyframes pulse {
  0%,
  100% {
    transform: scale(0.6);
    opacity: 0.4;
  }

  50% {
    transform: scale(1);
    opacity: 1;
  }
}
.input-container {
  display: flex;
}

.input-container .el-input {
  flex: 1;
  margin-right: 10px;
}

/* 媒体查询，当设备宽度小于等于 768px 时应用以下样式 */
@media (max-width: 768px) {
  .main-content {
    padding: 10px 0 10px 0;
  }
  .app-layout {
    flex-direction: column;
  }

  .sidebar {
    /* display: none; */
    width: 100%;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    padding: 10px;
  }

  .logo-section {
    flex-direction: row;
    align-items: center;
  }

  .logo-text {
    font-size: 20px;
  }

  .logo-section img {
    width: 40px;
    height: 40px;
  }

  .new-chat-button {
    margin-right: 30px;
    width: auto;
    margin-top: 5px;
  }
}

/* 媒体查询，当设备宽度大于 768px 时应用原来的样式 */
@media (min-width: 769px) {
  .main-content {
    padding: 0 0 10px 10px;
  }

  .app-layout {
    display: flex;
    height: 100vh;
  }

  .sidebar {
    width: 200px;
    background-color: #f4f4f9;
    padding: 20px;
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .logo-section {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .logo-text {
    font-size: 18px;
    font-weight: bold;
    margin-top: 10px;
  }

  .new-chat-button {
    width: 100%;
    margin-top: 20px;
  }
}
.app-layout {
  display: flex;
  background: #fdfdfd;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
}

.sidebar {
  width: 280px;
  padding: 20px;
  background: linear-gradient(145deg, #f0f0f0, #fafafa);
  display: flex;
  flex-direction: column;
  align-items: center;
}

.logo-section {
  text-align: center;
  margin-bottom: 20px;
}

.logo-text {
  display: block;
  margin-top: 10px;
  font-weight: bold;
  font-size: 20px;
  color: #333;
}

.new-chat-button {
  width: 100%;
  margin-bottom: 20px;
  border-radius: 8px;
}

.action-cards {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.action-card {
  cursor: pointer;
  transition: transform 0.3s;
  border-radius: 12px;
  border: none;
}

.action-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.action-card.success {
  background: linear-gradient(135deg, #d0f2ec, #e0faf4);
}

.card-icon {
  font-size: 30px;
  color: #409eff;
  text-align: center;
  margin-bottom: 10px;
}

.action-card.success .card-icon {
  color: #67c23a;
}

.card-content h4 {
  text-align: center;
  margin: 0;
  font-weight: bold;
  color: #333;
}

.card-content p {
  text-align: center;
  color: #666;
  font-size: 12px;
  margin-top: 4px;
}

.main-content {
  flex: 1;
  padding: 20px;
  background: #fff;
}

.chat-box {
  border-radius: 12px;
  background: #f9f9f9;
}

.ai-answer {
  background: #f0f9ff;
  padding: 10px;
  border-radius: 8px;
  min-height: 80px;
}
.chat-box {
  border-radius: 12px;
  background: #f9f9f9;
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding: 20px;
  min-height: 300px;
}

.chat-header {
  font-size: 20px;
  font-weight: bold;
  color: #409eff;
  display: flex;
  align-items: center;
  gap: 8px;
  
}

.chat-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 10px;
  background: #fff;
  border-radius: 8px;
  border: 1px solid #e0e0e0;
  overflow-y: auto;
  min-height: 500px;
  box-shadow: inset 0 2px 6px rgba(0, 0, 0, 0.05);
}

.message-bubble {
  max-width: 80%;
  padding: 10px 14px;
  border-radius: 20px;
  word-break: break-word;
  position: relative;
  animation: fadeIn 0.5s ease;
}

.message-bubble.bot {
  background: linear-gradient(135deg, #e0f7fa, #f0f9ff);
  align-self: flex-start;
  color: #333;
}

.message-placeholder {
  color: #aaa;
  text-align: center;
  padding: 10px;
  font-style: italic;
}

.chat-input-area {
  display: flex;
  gap: 10px;
  align-items: center;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(5px); }
  to { opacity: 1; transform: translateY(0); }
}
.assessment-container {
  display: flex;
  justify-content: center;
  padding: 30px;
}

.report-card {
  position: relative;
  width: 600px;
  padding: 30px;
  border-radius: 16px;
  background: #fff;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s;
}

.report-card.card-hover {
  transform: translateY(-5px) scale(1.02);
}

.decoration-corner {
  position: absolute;
  width: 10px;
  height: 10px;
  background: #409eff;
  border-radius: 50%;
}

.top-left {
  top: -5px;
  left: -5px;
}

.top-right {
  top: -5px;
  right: -5px;
}

.bottom-left {
  bottom: -5px;
  left: -5px;
}

.bottom-right {
  bottom: -5px;
  right: -5px;
}

.report-content-border {
  position: relative;
  padding: 20px;
  border: 1px dashed #409eff;
  border-radius: 12px;
  min-height: 150px;
  background: linear-gradient(135deg, #f9f9f9, #ffffff);
  text-align: center;
}

.content-highlight {
  position: absolute;
  top: -5px;
  left: -5px;
  right: -5px;
  bottom: -5px;
  border: 2px solid #409eff;
  border-radius: 14px;
  pointer-events: none;
}

.floating-dots span {
  position: absolute;
  width: 4px;
  height: 4px;
  background: #409eff;
  border-radius: 50%;
  animation: float 6s infinite ease-in-out;
}

@keyframes float {
  0% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-4px);
  }
  100% {
    transform: translateY(0);
  }
}

.report-placeholder {
  color: #999;
  font-style: italic;
  padding: 20px;
}

.report-content p {
  margin: 10px 0;
  color: #333;
}

.button-group {
  margin-top: 20px;
  text-align: center;
}

.button-group-chat {
  display: flex;
  flex-direction: row;
  gap: 40px;
  justify-content: center;
  align-items: center;
  padding: 0 20px;
  margin-top: 20px;
  animation: fadeInUp 0.8s ease-in-out;
}

.mute-btn {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  border: none;
  color: white;
  font-size: 20px;
  box-shadow: 0 8px 16px rgba(0,0,0,0.2);
  cursor: pointer;
  transition: transform 0.2s;
  position: relative;
  overflow: hidden;
  background: rgba(255, 255, 255, 0.3);
  border: 2px solid rgba(255, 255, 255, 0.3);
}

.mute-btn.muted {
  background: rgba(255, 0, 0, 0.3);
}

.mute-btn:hover {
  transform: scale(1.1);
}

.close-btn {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  border: none;
  color: white;
  font-size: 20px;
  box-shadow: 0 8px 16px rgba(0,0,0,0.2);
  cursor: pointer;
  transition: transform 0.2s;
  position: relative;
  overflow: hidden;
  background: rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.close-btn:hover {
  transform: scale(1.1);
}

.button-group-chat button {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  border: none;
  color: white;
  font-size: 20px;
  box-shadow: 0 8px 16px rgba(0,0,0,0.2);
  cursor: pointer;
  transition: transform 0.2s;
  position: relative;
  overflow: hidden;
  background: rgba(255, 255, 255, 0.2); /* 默认透明白 */
}

/* Ripple 动效 */
.button-group-chat button::after {
  content: '';
  position: absolute;
  background: rgba(255,255,255,0.3);
  border-radius: 50%;
  transform: scale(0);
  animation: ripple 0.6s linear;
  pointer-events: none;
}

@keyframes ripple {
  to {
    transform: scale(4);
    opacity: 0;
  }
}

.button-group-chat button:active::after {
  top: 50%;
  left: 50%;
  width: 100px;
  height: 100px;
  margin-top: -50px;
  margin-left: -50px;
}

.button-group-chat button:hover {
  transform: scale(1.1);
}

/* 开始按钮：透明灰色 */
.start-btn {
  background: rgba(150, 150, 150, 0.2);
  color: #ffffff;
}

/* 结束按钮：透明白色 */
.end-btn {
  background: rgba(255, 255, 255, 0.2);
  color: #ffffff;
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.btn-underline.active {
  width: 100%;
  left: 0;
}


.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.work-progress-bar {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 12px;
}

.progress-line {
  display: flex;
  align-items: center;
  gap: 10px;
}

.tag-name {
  width: 60px;
  font-weight: 500;
  color: #333;
}

.work-list-container {
  width: 100%;
  padding: 0 20px;
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.work-section {
  background: #fafafa;
  padding: 16px;
  border-radius: 10px;
  border: 1px solid #e4e4e4;
}

.section-title {
  font-size: 1.4rem;
  font-weight: bold;
  margin-bottom: 12px;
  color: #333;
  border-bottom: 2px solid #409EFF;
  padding-bottom: 4px;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.work-item {
  background: #fff;
  border: 1px solid #eaeaea;
  padding: 12px;
  border-radius: 8px;
  margin-bottom: 12px;
  transition: transform 0.2s;
}

.work-item:hover {
  transform: translateY(-3px);
  box-shadow: 0 2px 10px rgba(0,0,0,0.08);
}

.work-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.work-title {
  margin: 0;
  font-size: 1.1rem;
  font-weight: bold;
}
.work-desc {
  color: #666;
  font-size: 0.95rem;
  margin: 8px 0;
  margin-bottom: 12px;
}

.work-actions,
.work-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  align-items: center;
}

.score-text {
  font-weight: bold;
  color: #409EFF;
}

.do-work-container-all {
  max-height: 500px;
  overflow-y: auto;
}

.question-block {
  margin-bottom: 20px;
  padding: 10px;
  border-bottom: 1px solid #eaeaea;
}

.question-desc {
  margin-bottom: 10px;
  color: #555;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
}
.message-bubble {
  max-width: 80%;
  padding: 10px;
  margin: 8px 0;
  border-radius: 6px;
  line-height: 1.5;
  word-wrap: break-word;
}
.message-bubble.user {
  align-self: flex-end;
  background-color: #dff0d8;
  color: #333;
}
.message-bubble.bot {
  align-self: flex-start;
  background-color: #f0f0f0;
  color: #000;
}
.chat-content {
  display: flex;
  flex-direction: column;
  height: 300px;
  overflow-y: auto;
  padding: 10px;
  background-color: #fff;
  border: 1px solid #eee;
}
.question-info {
  width: 518px;
  padding: 8px 0;
  margin-bottom: 12px;
  word-wrap: break-word;
}

.question-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin-bottom: 6px;
}

.answer-line,
.comment-line {
  font-size: 14px;
  color: #444;
  line-height: 1.6;
  margin: 4px 0;
}
.courseButton{
  position: relative;
  left: 1320px;
  width: 70px;
}
.question-card {
  margin-bottom: 20px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}
.due {
  color: #f56c6c;
  font-weight: bold;
}
/* 加载动画样式 */
.el-loading-mask {
  background-color: rgba(255, 255, 255, 0.7);
}

.el-loading-spinner .circular {
  width: 42px;
  height: 42px;
  animation: loading-rotate 2s linear infinite;
}

.el-loading-spinner .path {
  stroke: #409EFF;
  stroke-width: 3;
  stroke-linecap: round;
  animation: loading-dash 1.5s ease-in-out infinite;
}

@keyframes loading-rotate {
  100% {
    transform: rotate(360deg);
  }
}

@keyframes loading-dash {
  0% {
    stroke-dasharray: 1, 200;
    stroke-dashoffset: 0;
  }
  50% {
    stroke-dasharray: 90, 150;
    stroke-dashoffset: -40;
  }
  100% {
    stroke-dasharray: 90, 150;
    stroke-dashoffset: -120;
  }
}

/* 按钮加载状态样式 */
.el-button.is-loading {
  position: relative;
  pointer-events: none;
}

.el-button.is-loading:before {
  content: '';
  position: absolute;
  left: -1px;
  top: -1px;
  right: -1px;
  bottom: -1px;
  border-radius: inherit;
  background-color: rgba(255,255,255,.35);
}
.evaluation-result-dialog .el-dialog__body {
  padding: 20px;
}

.evaluation-content {
  background: #f8f8f8;
  border-radius: 8px;
  padding: 15px;
  white-space: pre-wrap;
  font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', Arial, sans-serif;
  line-height: 1.6;
}

.evaluation-content pre {
  margin: 0;
  overflow-x: auto;
}

.chat-widget {
  position: fixed;
  bottom: 20px;
  right: 20px;
}
.bot-toggle-btn {
  border: none;
  outline: none;
  background-color: transparent;
  width: 80px;
  height: 80px;
  cursor: pointer;
  padding: 0;
  margin: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.3s ease;
  box-shadow: none;
}

.bot-toggle-btn:hover {
  transform: scale(1.1);
}

.bot-icon {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.bot-container {
  position: fixed;
  bottom: 20px;
  right: 20px;
  z-index: 9999;
  display: flex;
  align-items: flex-end;
  gap: 10px;
  flex-direction: row-reverse;
}

.bot-tip {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 12px 16px;
  border-radius: 20px;
  font-size: 14px;
  max-width: 200px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
  opacity: 0;
  transform: translateX(-20px);
  transition: all 0.3s ease;
  position: relative;
  white-space: nowrap;
}

.bot-tip::before {
  content: '';
  position: absolute;
  left: -8px;
  bottom: 20px;
  width: 0;
  height: 0;
  border-right: 8px solid #667eea;
  border-top: 8px solid transparent;
  border-bottom: 8px solid transparent;
}

.tip-visible {
  opacity: 1;
  transform: translateX(0);
}

.bot-tip:hover {
  transform: translateX(0) scale(1.05);
}
.chat-window {
  background: #fff;
  padding: 1rem;
  border-radius: 8px;
  width: 300px;
  box-shadow: 0 0 8px rgba(0, 0, 0, 0.15);
}
.chat-log {
  max-height: 200px;
  overflow-y: auto;
  margin-bottom: 10px;
}
.user {
  text-align: right;
  color: #333;
}
.bot {
  text-align: left;
  color: #007bff;
}
.dot-wave.active .dot:nth-child(1) {
  animation: wave 1s infinite ease-in-out;
}
.dot-wave.active .dot:nth-child(2) {
  animation: wave 1s 0.2s infinite ease-in-out;
}
.dot-wave.active .dot:nth-child(3) {
  animation: wave 1s 0.4s infinite ease-in-out;
}

@keyframes wave {
  0%, 100% {
    transform: translateY(0);
    opacity: 0.4;
  }
  50% {
    transform: translateY(-8px);
    opacity: 1;
  }
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
    opacity: 0.8;
  }
  50% {
    transform: scale(1.05);
    opacity: 1;
  }
}

.listening-dots .dot {
  animation: wave 1.2s infinite ease-in-out;
}

.listening-dots .dot:nth-child(2) {
  animation-delay: 0.2s;
}

.listening-dots .dot:nth-child(3) {
  animation-delay: 0.4s;
}

.voice-chat-content {
  text-align: center;
  margin-top: 20px;
  padding: 0 20px;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.status-indicator {
  margin-bottom: 20px;
}

.listening-dots {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  margin-bottom: 10px;
}
.dot {
  display: inline-block;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: rgba(30,144,255,0.7);
  margin: 0 4px;
  animation: dot-bounce 1s infinite alternate;
}
.dot:nth-child(2) {
  animation-delay: 0.2s;
}
.dot:nth-child(3) {
  animation-delay: 0.4s;
}
@keyframes dot-bounce {
  0% { transform: translateY(0); opacity: 0.7; }
  100% { transform: translateY(-8px); opacity: 1; }
}

.status-text {
  color: #ffffff;
  font-size: 14px;
  font-weight: 600;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.8);
}

.recognition-result {
  background: rgba(255, 255, 255, 0.3);
  border-radius: 12px;
  padding: 15px;
  margin-bottom: 20px;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.result-label {
  color: #ffffff;
  font-size: 12px;
  font-weight: 600;
  margin-bottom: 8px;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.8);
}

.result-text {
  color: #ffffff;
  font-size: 16px;
  line-height: 1.4;
  word-break: break-word;
  font-weight: 600;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.8);
}

.prompt-text {
  color: #ffffff;
  font-size: 16px;
  margin: 20px 0;
  font-style: italic;
  font-weight: 600;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.8);
}

.start-btn,
.end-btn {
  width: 100%;
  max-width: 200px;
  padding: 12px 18px;
  border: none;
  border-radius: 25px;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 5px 15px rgba(0,0,0,0.2);
}
.start-btn {
  background: linear-gradient(135deg, #4e8ef7, #6ea9f7);
  color: white;
}
.start-btn {
  background-color: #888;
  cursor: not-allowed;
}

.end-btn {
  background: linear-gradient(135deg, #f44336, #e53935);
  color: white;
}
.chat-voice-panel {
  position: fixed;
  top: 0;
  right: 0;
  height: 100vh;
  width: 350px;
  background: linear-gradient(135deg, #1a1a1a, #2d2d2d);
  border-left: 1px solid rgba(255,255,255,0.2);
  color: white;
  z-index: 9998;
  box-shadow: -4px 0 20px rgba(0, 0, 0, 0.6);
  display: flex;
  flex-direction: column;
  align-items: center;
  overflow: hidden;
}

.status-bar {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 20px;
  background: rgba(0, 0, 0, 0.8);
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  z-index: 10;
}

.status-icons {
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-icon {
  font-size: 12px;
  padding: 2px 4px;
  border-radius: 4px;
  background: rgba(255, 255, 255, 0.1);
}

.status-icon.phone {
  background: rgba(76, 175, 80, 0.3);
}

.status-icon.app {
  background: rgba(33, 150, 243, 0.3);
  font-size: 10px;
  padding: 1px 3px;
}

.status-icon.mic {
  background: rgba(76, 175, 80, 0.5);
  animation: pulse 2s infinite;
}

.status-icon.wifi {
  background: rgba(255, 193, 7, 0.3);
}

.status-icon.battery {
  background: rgba(255, 87, 34, 0.3);
}

.voice-chat-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 40px;
  margin-top: 80px;
}

.assistant-name {
  margin-top: 12px;
  font-size: 18px;
  color: #ffffff;
  text-align: center;
  font-weight: 700;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.8);
}

.scene-selector {
  margin: 20px 0;
  width: 100%;
  display: flex;
  justify-content: center;
}

.scene-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  background: rgba(255, 255, 255, 0.3);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 25px;
  color: #ffffff;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 500;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

.scene-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
}

.scene-icon {
  font-size: 16px;
}

.scene-text {
  font-weight: 500;
}

.avatar-wrapper {
  position: relative;
  width: 200px;      
  height: 200px;
  border-radius: 50%;
  overflow: hidden;
  line-height: 0;
  margin: 40px auto 20px auto;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.5);
  border: 3px solid rgba(255, 255, 255, 0.2);
  background: linear-gradient(135deg, #4e8ef7, #6ea9f7);
  display: flex;
  align-items: center;
  justify-content: center;
}

.avatar-wrapper img {
  width: 80%;
  height: 80%;
  object-fit: cover;
  display: block;
  border-radius: 50%;
}
.avatar-wrapper::before {
  content: '';
  position: absolute;
  top: -5px;
  left: -5px;
  right: -5px;
  bottom: -5px;
  border-radius: 50%;
  background: conic-gradient(#4e8ef7, #6ea9f7, #4e8ef7);
  z-index: -1;
  animation: spin 3s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.name {
  margin-top: 12px;
  font-size: 18px;
  color: #ccc;
  text-align: center;
}

.dot-wave {
  display: flex;
  justify-content: center;
  gap: 8px;
  margin-bottom: 20px;
}

.chat-message-list {
  max-height: 150px;
  overflow-y: auto;
  margin: 10px 0;
  padding: 10px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.chat-message {
  margin-bottom: 8px;
  font-size: 14px;
  color: #ffffff;
  padding: 8px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.msg-user {
  color: #4e8ef7;
  font-weight: 500;
}

.msg-text {
  color: #ffffff;
  font-weight: 600;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.8);
}

/* 重要提醒卡片样式 */
.question-card {
  transition: all 0.3s ease;
  cursor: pointer;
  height: 250px;
  width: 250px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: 10px;
  position: relative;
}

.question-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.card-header {
  margin-bottom: 12px;
  position: absolute;
  top: 10px;
  left: 10px;
  z-index: 10;
}

.card-header .el-tag {
  font-size: 12px;
  padding: 4px 8px;
}

.question-card h3 {
  margin: 12px 0;
  font-size: 18px;
  font-weight: 600;
  color: #333;
  line-height: 1.4;
}

.question-card .desc {
  margin: 12px 0;
  color: #666;
  font-size: 14px;
  line-height: 1.5;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
}

.question-card .due {
  margin: 8px 0 0 0;
  color: #f56c6c;
  font-size: 13px;
  font-weight: 500;
  word-wrap: break-word;
  overflow-wrap: break-word;
  margin-top: auto;
}

/* 课程信息样式 */
.course-info {
  margin-bottom: 12px;
  margin-top: 20px;
}

.course-label {
  display: inline-block;
  /* background: linear-gradient(135deg, #bff7fb 0%, #62e1f4 100%); */
  color: rgb(0, 0, 0);
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
}

/* 标题样式 */
.item-title {
  margin: 8px 0;
  font-size: 16px;
  font-weight: 600;
  color: #333;
  line-height: 1.4;
  word-wrap: break-word;
  overflow-wrap: break-word;
}

/* 描述样式 */
.desc {
  margin: 8px 0;
  color: #666;
  font-size: 13px;
  line-height: 1.5;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  word-wrap: break-word;
  overflow-wrap: break-word;
}

.desc.no-desc {
  color: #999;
  font-style: italic;
}

/* 考试信息样式 */
.exam-info {
  margin: 8px 0;
}

.duration {
  display: inline-block;
  background: rgba(245, 108, 108, 0.1);
  color: #f56c6c;
  padding: 6px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
}

  </style>
  