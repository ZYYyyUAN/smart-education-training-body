<template>
   <SplineBac :scene="{url:'https://prod.spline.design/6abYqc7wmfe4a3Ty/scene.splinecode'}"></SplineBac>
     <div class="academy-page">
      
    <!-- ✅ 顶部栏替换为带导航和主题切换的新结构 -->
    <header class="header">
      <div class="logo">
        <h1>智教实训通</h1>
        <p>有温度、有感情的个性化智能教学平台</p>
      </div>

      <div class="nav-container">
        <button @click="showChatBot = !showChatBot" class="bot-toggle-btn">🤖</button>
  <div v-if="showChatBot" class="chat-window">
      <h2>🗣️ 智能语音聊天</h2>
      <div class="chat-log">
        <div v-for="(msg, index) in chatMessages" :key="index" :class="msg.role">
          <strong>{{ msg.role === 'user' ? '你：' : 'AI：' }}</strong> {{ msg.text }}
        </div>
      </div>
      <button @click="startVoiceChat" :disabled="isChatting" class="start-btn">
        {{ isChatting ? '🎙️ 聊天中...' : '开始语音聊天' }}
      </button>
    </div>
        <nav class="nav">
          <router-link to="/student">首页</router-link>
          <router-link to="/my_school">我的学堂</router-link>
          <router-link to="/notice">消息通知</router-link>
           <router-link to="/">退出系统</router-link>
        </nav>
        <ThemeToggle @theme-changed="handleThemeChange" />
      </div>
    </header>


      <h2>重要提醒</h2>
      <div class="card-container">
        <template v-if="importantAssignments && importantAssignments.length > 0">
          <el-card
            v-for="(item, index) in importantAssignments"
            :key="index"
            shadow="hover"
            class="question-card"
          >
            <div class="card-header">
              <el-tag type="danger" effect="dark">即将截止</el-tag>
            </div>
            <h3>{{ item.title }}</h3>
            <p class="desc">{{ item.description }}</p>
            <p class="due">📅 截止日期：{{ item.dueDate?.slice(0, 10) }}</p>
          </el-card>
        </template>

        <template v-else>
          <el-empty description="暂无即将到期的作业提醒" :image-size="200" />
        </template>
      </div>
      <h2>AI智能推荐题目</h2>
      <div class="card-container">
                <!-- 有题目时显示卡片列表 -->
                <template v-if="recommendList && recommendList.length > 0">
                <el-card
                  v-for="(item, index) in recommendList"
                  :key="index"
                  shadow="hover"
                  class="question-card">
                  <div class="card-header">
                    <el-tag :type="item.typeTag" effect="dark">{{ item.type }}</el-tag>
                    <h3>{{ item.title }}</h3>
                  </div>
                  <p class="desc">{{ item.desc }}</p>
                  <div class="progress-area">
                    <div v-for="tag in item.tags" :key="tag.name" class="tag-line">
                      <span class="tag-name">{{ tag.name }}</span>
                      <el-progress :percentage="tag.percent" :status="tag.status" />
                    </div>
                  </div>
                  <div class="card-footer">
                      <el-button size="small" type="primary" @click="openDialog(item, 'answer')">答题</el-button>
                  </div>
                </el-card>
              </template>
    
              <!-- 无题目时显示提示 -->
              <template v-else>
                <el-empty description="目前暂无可用AI题目" :image-size="200">
                </el-empty>
              </template>
              <section class="recommend-section">

                <!-- 弹窗详情 -->
              <el-dialog v-model="dialogVisible" title="题目详情" width="600px" :before-close="handleClose">
                  <div v-if="selectedItem">
                    <h3 style="margin-bottom: 10px">{{ selectedItem.fullTiTle }}</h3>
                    <p style="margin-bottom: 10px">{{ selectedItem.desc }}</p>
                    <el-tag :type="selectedItem.typeTag">{{ selectedItem.type }}</el-tag>
                    <div style="margin-top: 20px">
                      <div v-for="tag in selectedItem.tags" :key="tag.name" style="margin-bottom: 10px">
                        <div style="display: flex; justify-content: space-between">
                          <span>{{ tag.name }}</span>
                          <el-progress :percentage="tag.percent" :status="tag.status" style="flex: 1; margin-left: 10px" />
                        </div>
                      </div>
                    </div>
                  </div>
                  <el-divider content-position="center" class="answer-area">我的答题</el-divider>
                  <div class="answer-area-container">
                    <el-input
                      v-model="answerContent"
                      type="textarea"
                      rows="6"
                      placeholder="请在此输入你的答案，尽量详尽完整..."
                      maxlength="1000"
                      show-word-limit
                      class="answer-input"
                    />
                    <div class="submit-area">
                      <el-button 
  type="primary" 
  @click="submitAnswer2" 
  :disabled="!answerContent.trim()" 
  :loading="isEvaluating"
>
  <i class="el-icon-check"></i> 提交答案
</el-button>
                    </div>
                  </div>
                </el-dialog>
            </section>
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
      <!-- Tab 导航 -->
      <el-tabs v-model="activeTab" class="main-tabs">

        <el-tab-pane label="我的课程" name="learn">
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
        </el-tab-pane>
        
        <el-tab-pane label="小智助手" name="AIhelper">
          <div class="app-layout">
           <div class="sidebar">
          <div class="logo-section">
          <img src="@/assets/icon/ai-assistant.png" alt="硅谷小智" width="120" height="120" />
          <span class="logo-text">小智</span>
        </div>

            <el-button class="new-chat-button" @click="newChat">
              <i class="fa-solid fa-plus"></i>&nbsp;新会话
            </el-button>

            <div class="action-cards">
              <el-card shadow="hover" class="action-card" @click="openChatDialog">
                <div class="card-icon">
                  <i class="fa-solid fa-comments"></i>
                </div>
                <div class="card-content">
                  <h4>智能对话</h4>
                  <p>与小智进行专业互动</p>
                </div>
              </el-card>

              <el-card shadow="hover" class="action-card success" @click="openSelectDialog">
                <div class="card-icon">
                  <i class="fa-solid fa-lightbulb"></i>
                </div>
                <div class="card-content">
                  <h4>生成推荐题目</h4>
                  <p>智能生成练习巩固题</p>
                </div>
              </el-card>
            </div>
          </div>

          <div class="main-content">
          <transition name="fade">
            <el-card v-if="chatActive" shadow="hover" class="chat-box">
              <div class="chat-header">
                <i class="fa-solid fa-robot"></i>&nbsp;<span>学业对话助手</span>
              </div>

        <div class="chat-content" ref="messaggListRef">
          <div
            v-for="(msg, index) in messages"
            :key="index"
            :class="['message-bubble', msg.isUser ? 'user' : 'bot']"
            v-html="msg.content"
          />
        </div>

              <div class="chat-input-area">
                <el-input
                  v-model="userQuestion"
                  placeholder="请输入你的问题..."
                  @keyup.enter="sendQuestion"
                  clearable
                />
                <el-button type="primary" @click="sendQuestion">发送</el-button>
              </div>
            </el-card>
          </transition>

          <el-empty v-if="!chatActive" description="请选择功能或开启对话助手" />
          </div>

          <!-- 参数选择对话框 -->
          <el-dialog v-model="selectDialogVisible" title="生成推荐题目" width="500px">
              <el-form :model="generateForm" label-width="80px">
                <el-form-item label="知识点">
                  <el-input v-model="generateForm.knowledge" placeholder="请输入知识点" />
                </el-form-item>
                <el-form-item label="题型">
                  <el-select v-model="generateForm.type" placeholder="请选择题型">
                    <el-option label="选择题" value="choice" />
                    <el-option label="简答题" value="short_answer" />
                    <el-option label="编程题" value="programming" />
                  </el-select>
                </el-form-item>
                <el-form-item label="题量">
                  <el-input-number v-model="generateForm.count" :min="1" :max="10" />
                </el-form-item>
              </el-form>

              <template #footer>
                <el-button @click="selectDialogVisible = false">取消</el-button>
                <el-button 
  type="primary" 
  @click="handleGenerate"
  :loading="isGenerating"
>
  {{ isGenerating ? '生成中...' : '生成' }}
</el-button>

              </template>
            </el-dialog>

            <!-- 生成结果展示对话框 -->
           <el-dialog 
  v-model="resultDialogVisible" 
  title="AI生成题目" 
  width="700px"
  class="simple-question-dialog"
>
  <div class="question-list" v-loading="isLoading">
    <div 
      v-for="(q, index) in generatedQuestions" 
      :key="index"
      v-if="!isLoading"
      class="question-item"
    >
      <div class="question-type">
        {{ index+1 }}.
        <el-tag :type="getTagType(q.type)" size="small">
          {{ getQuestionTypeName(q.type) }}
        </el-tag>
      </div>
      
      <div class="question-content">
        <p class="question-text">{{ q.content }}</p>
        <div class="knowledge-point">
          <el-icon><Collection /></el-icon>
          <span>知识点：{{ q.knowledgePoint || '通用知识点' }}</span>
        </div>
      </div>
    </div>
  </div>

              <template #footer>
                  <el-button 
  @click="handleGenerate" 
  :loading="isGenerating"
>
  <template v-if="!isGenerating">
    <el-icon><Refresh /></el-icon>
    换一批
  </template>
  <template v-else>
    加载中...
  </template>
</el-button>
                <el-button type="primary" @click="handleSave">保存到推荐</el-button>
              </template>
            </el-dialog>

            <!-- 生成成功弹窗 -->
            <el-dialog v-model="successDialogVisible" title="助手消息" width="400px">
              <p>新题目已成功生成，并添加到推荐列表！</p>
              <template #footer>
                <el-button type="primary" @click="successDialogVisible = false">我知道了</el-button>
              </template>
            </el-dialog>
          
            </div>
          </el-tab-pane>

        <el-tab-pane label="我的作业" name="work">
          <div class="work-list-container">

          <!-- 未上交作业 -->
   <div v-if="unsubmittedList.length > 0" class="work-section">
  <h2 class="section-title">未上交作业</h2>
  <div v-for="(item, index) in unsubmittedList" :key="index" class="work-item">
    <div class="work-header">
      <h3 class="work-title">{{ item.title }}</h3>
      <el-tag type="warning">未上交</el-tag>
    </div>
    <p class="work-desc">{{ item.description }}</p>
    <p class="work-date">截止日期：{{ item.dueDate ? item.dueDate.slice(0, 10) : '暂无' }}</p>

    <div class="work-actions">
      <el-button type="primary" size="small" @click="handleDoWork(item.assignmentId)">去完成</el-button>
    </div>
  </div>
</div>
<div v-if="submittedList.length > 0" class="work-section">
  <h2 class="section-title">已上交作业</h2>
  <div v-for="(item, index) in submittedList" :key="index" class="work-item">
    <div class="work-header">
      <h3 class="work-title">{{ item.title }}</h3>
      <el-tag type="success">已上交</el-tag>
    </div>
    <p class="work-desc">{{ item.description }}</p>
    <p class="work-date">提交时间：{{ item.submittedAt ? item.submittedAt.slice(0, 10) : '暂无' }}</p>


     <div class="work-actions">
      <el-button type="success" size="small" @click="handleRedo(item.assignmentId)">查看详情</el-button>
    </div>
  </div>
</div>

            <el-empty v-if="unsubmittedList.length === 0 && submittedList.length === 0" description="暂无作业任务" />

            <el-dialog v-model="doWorkDialogVisible" title="作业作答" width="800px">
              <div class="do-work-container-all">
                <div
                  v-for="(q, index) in currentWork.questions"
                  :key="q.qid"
                  class="question-block"
                >
                  <h4>题 {{ index + 1 }}：</h4>
                  <p class="question-desc">{{ q.content }}</p>
                  <el-input
                    v-model="q.answer"
                    type="textarea"
                    rows="3"
                    placeholder="请输入你的答案"
                    class="answer-input"
                  />
                </div>
              </div>

              <template #footer>
                <el-button @click="doWorkDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="submitWork(currentWork)">提交作业</el-button>
              </template>
            </el-dialog>

          </div>
        </el-tab-pane>

        <el-tab-pane label="历史练习记录" name="history">
          <div class="history-page p-4">
    <el-card
      v-for="record in historyList"
      :key="record.id"
      shadow="hover"
      class="mb-4">
      <div class="flex justify-between items-center history_kuai">
         <!-- 左侧展示区 -->
<div class="question-info">
  <h3 class="question-title">{{ record.title }}</h3>
  <p class="answer-line"><strong>我的回答：</strong> {{ record.studentAnswer }}</p>
  <p class="comment-line"><strong>评语：</strong> {{ record.errorReason || '暂无反馈' }}</p>
</div>
          <!-- 进度条 -->
        <div class="text-sm text-gray-600 space-y-1">
          <div class="flex items-center justify-between">
            <span>难度：</span>
            <el-progress :percentage="record.difficulty" stroke-width="8" status="success" class="w-3/4" />
          </div>
          <div class="flex items-center justify-between">
            <span>重要度：</span>
            <el-progress :percentage="record.importance" stroke-width="8" status="warning" class="w-3/4" />
          </div>
          <div class="flex items-center justify-between">
            <span>创新度：</span>
            <el-progress :percentage="record.innovation" stroke-width="8" status="exception" class="w-3/4" />
          </div>
          <div class="flex items-center justify-between">
            <span>综合度：</span>
            <el-progress :percentage="record.total" stroke-width="8" status="success" color="#6C5CE7" class="w-3/4" />
          </div>
        </div>
        <!--进度条完成-->
        <div class="flex items-center gap-2 scorecircle">
          <!--圆形计分-->
          <ScoreCircle :score="record.score" />
        </div>
        <div class="flex items-center gap-2 re-button">
          <!--重做按钮-->
          <el-button type="primary" size="big" round @click="goToDetail(record.id)">前往重做</el-button>
        </div>
      </div>
    </el-card>
    <router-view />
  </div>
        </el-tab-pane>

        <el-tab-pane label="个人评价" name="AIevaluate">
          <div class="assessment-container">
            
   <div
        class="report-card"
        :class="{ 'card-hover': isHovered }"
        @mouseenter="isHovered = true"
        @mouseleave="isHovered = false"
      >
        <!-- 科目选择区域 -->
        <div class="subject-selector">
          <el-form label-width="100px">
            <el-form-item label="选择科目">
              <el-select 
                v-model="selectedSubject" 
                placeholder="请选择要分析的科目"
                @change="handleSubjectChange"
              >
                <el-option
                  v-for="course in selectedCourses"
                  :key="course.id"
                  :label="course.courseName"
                  :value="course.id"
                />
              </el-select>
            </el-form-item>
          </el-form>
        </div>

      <!-- 动态装饰元素 -->
      <div class="decoration-corner top-left"></div>
      <div class="decoration-corner top-right"></div>
      <div class="decoration-corner bottom-left"></div>
      <div class="decoration-corner bottom-right"></div>

      <!-- 报告内容区域边框 -->
      <div class="report-content-border">
        <div class="content-highlight"></div>

        <div class="floating-dots">
          <span v-for="n in 12" :key="n" :style="getDotStyle(n)"></span>
        </div>

        <!-- 动态展示内容 -->
        <transition name="fade">
                <div v-if="showReport" class="report-content">
  <h3 class="report-title">{{ selectedSubjectName }}学情分析报告</h3>
  <div class="report-meta">
    <p><strong>学生ID：</strong> {{ analysisResult.studentId || 1 }}</p>
    <p><strong>课程ID：</strong> {{ selectedSubject }}</p>
  </div>
  
  <el-divider></el-divider>
  
  <div class="knowledge-analysis">
    <h4>📚 知识点掌握情况</h4>
    <p>{{ analysisResult.knowledgeAnalysis }}</p>
  </div>
  
  <el-divider></el-divider>
  
  <div class="suggestions">
    <h4>💡 教学建议</h4>
    <p>{{ analysisResult.teachingSuggestion }}</p>
  </div>
</div>
        </transition>
          <div v-if="showReport" class="report-content">
            <p v-for="(line, index) in reportContent" :key="index">{{ line }}</p>
          </div>
        
        <!-- 未生成前的提示-->
        <div v-else class="report-placeholder">
          <p>点击按钮生成你的专属个人评价</p>
        </div>
      </div> 

       <!-- 按钮组 -->
        <div class="button-group bottom-buttons">
          <el-button
            type="primary"
            class="action-btn plan-btn"
            @click="generateReport"
            @mouseenter="hoverButton('plan')"
            @mouseleave="resetButton"
            :disabled="!selectedSubject"
          >
            <i class="el-icon-timer"></i>
            <span>生成学情分析</span>
            <div class="btn-underline" :class="{ active: activeBtn === 'plan' }"></div>
          </el-button>
        </div>
    </div>
          </div>
        </el-tab-pane>
      </el-tabs>
  
      <!-- 动态背景 -->
      <!-- <DynamicBackground /> -->
    </div>
  </template>
  
  <script>
  import defaultCourseImg from '../../assets/icon/JiWang.png'
import { useUserStore } from '@/store/user.js'
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







const showChatBot = ref(false)
const chatMessages = ref([])

let ws = null
let audioContext = null
let isChatting = false
let isPlayingTTS = false // 👈 加上这个标志用于控制录音是否暂停

// ✅ 播放音频时暂停语音识别（避免 TTS 被识别为输入）
function playAudioChunk(arrayBuffer) {
  if (!audioContext) {
    audioContext = new (window.AudioContext || window.webkitAudioContext)()
  }

  audioContext.decodeAudioData(arrayBuffer, (buffer) => {
    const source = audioContext.createBufferSource()
    source.buffer = buffer
    source.connect(audioContext.destination)

    // 设置播放中标志
    isPlayingTTS = true
    console.log('🔇 正在播放合成语音，暂停识别...')

    source.onended = () => {
      isPlayingTTS = false
      console.log('🎤 播放结束，可以重新开始识别了')
      // 👇 播放结束可以重新开始录音（你自己的逻辑）
      maybeStartRecording()
    }

    source.start()
  }, (e) => {
    console.error('❌ 音频解码失败：', e)
    isPlayingTTS = false
  })
}

// ✅ 接收 WebSocket 音频
function initWebSocket() {
  if (ws) return

  ws = new WebSocket('/ws/audio')
  ws.binaryType = 'arraybuffer'

  ws.onopen = () => {
    console.log('✅ WebSocket已连接，等待接收音频...')
  }

  ws.onmessage = (event) => {
    if (event.data instanceof ArrayBuffer) {
      playAudioChunk(event.data)
    } else {
      console.warn('收到非音频数据:', event.data)
    }
  }

  ws.onerror = (err) => {
    console.error('❌ WebSocket错误:', err)
  }

  ws.onclose = () => {
    console.log('🔌 WebSocket已关闭')
    ws = null
  }
}

// ✅ 控制识别是否该启动（播放期间不识别）
function maybeStartRecording() {
  if (!isPlayingTTS) {
    console.log('🎙️ 开始录音识别（播放已结束）')
    // TODO: 👇你要在这里加上你的录音启动逻辑，比如 startMicStream() 等
    startRecording() // 👉 你自己的函数
  } else {
    console.log('⏳ 还在播放中，不能开始识别')
  }
}

// ✅ 启动语音对话主逻辑
const startVoiceChat = async () => {
  if (isChatting) return
  isChatting = true

  initWebSocket()

  try {
    const res = await axios.get('api/auth/start-voice-chat')
    console.log(res.data)
    // 👇 加上自动启动录音
    maybeStartRecording()
  } catch (err) {
    console.error('❌ 启动对话失败', err)
  }
}

// ✅ 清理资源
onUnmounted(() => {
  if (ws) ws.close()
  if (audioContext) audioContext.close()
})





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

const loadImportantAssignments = async () => {
  try {
    const res = await axios.get('/api/xiaozhi/student/upcoming', {
      params: {
        studentId: useUserStore().currentUserId, // 请替换为真实的学生ID
        days: 3       // 默认3天内截止
      }
    })

    if (res.data.code === 200) {
      importantAssignments.value = res.data.data || []
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
    const res = await axios.get('/api/xiaozhi/student/my-courses', {
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
    const res = await axios.get('/api/xiaozhi/student/assignments', {
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
    { required: true, message: '请输入课程号', trigger: 'blur' },
    { min: 6, max: 20, message: '课程号长度在6到20个字符', trigger: 'blur' }
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

    const studentId = 1; // 这里换成实际学生ID
    const courseCode = courseForm.value.courseCode;

    // 调用后端加入课程接口
    const res = await axios.post('/api/xiaozhi/student/addCourse', null, {
      params: {
        studentId,
        courseId: courseCode  // 如果后端courseId对应课程号
      }
    });

    if (res.data.code === 200 || res.data.success) {
      ElMessage.success(res.data.message || '加入课程成功！');
      classDialogVisible.value = false;
      // TODO: 刷新课程列表逻辑
    } else {
      ElMessage.error(res.data.message || '加入课程失败');
    }
  } catch (error) {
    console.error('加入课程异常:', error);
    ElMessage.error(error.message || '网络异常，请稍后重试');
  }
};


// 暴露给模板的变量和方法
defineExpose({
  showAddCourseDialog
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
})
// 加载推荐题目
const loadRecommendQuestions = async () => {
  try {
    isLoading.value = true
    const response = await axios.get('/api/xiaozhi/student/questions/by-creator', {
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
    const res = await axios.get('/api/xiaozhi/student/practice-log', {
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
  //第一条默认发送的用户消息”你好“不放入会话列表
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
    width: 1830px;
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
}

.fzcard {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;  
  gap: 8px;
}

.badge {
  background-color: #409eff;
  color: white;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
}

/* .view-all {
  color: #409eff;
  padding: 0;
} */

.value {
  color: #f56c6c;
  font-weight: bold;
  /* justify-content: flex-end; */
  margin-left: auto; 
  margin-right: 10px;
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
    margin: 20px;
    height: 170px;
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
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  border-radius: 12px;
  overflow: hidden;
  background: linear-gradient(to right, #f7faff, #ffffff);
}

.course-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
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
  border-radius: 8px;
  box-shadow: 0 0 8px rgba(0, 0, 0, 0.08);
}

.course-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.course-title {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.course-desc {
  font-size: 0.95rem;
  color: #666;
  margin-bottom: 1rem;
}

.course-meta {
  display: flex;
  align-items: center;
  gap: 1rem;
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
  background-color: #000000;
  border-radius: 50%;
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

.btn-underline {
  position: absolute;
  bottom: -2px;
  left: 50%;
  width: 0;
  height: 2px;
  background: #409eff;
  transition: all 0.3s;
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
  left: 1450px;
  width: 90px;
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
  font-size: 20px;
  padding: 10px;
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
.start-btn {
  width: 100%;
  padding: 8px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
}
  </style>
  