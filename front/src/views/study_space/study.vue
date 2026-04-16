<template>
  <div class="app-container">
    <!-- 返回按钮 -->
    <div class="back-button" @click="goBack">
      <svg viewBox="0 0 24 24" width="20" height="20">
        <path fill="currentColor" d="M20,11V13H8L13.5,18.5L12.08,19.92L4.16,12L12.08,4.08L13.5,5.5L8,11H20Z" />
      </svg>
      <span>返回</span>
    </div>
    
    <!-- 左侧导航栏 -->
    <div class="sidebar">
      <!-- 用户信息区域 -->
      <div class="user-info">
        <img 
          :src="userAvatarUrl" 
          alt="用户头像" 
          class="user-avatar"
        >
        <div class="user-details">
          <div class="user-name">{{ currentUserName }}</div>
        </div>
      </div>
      
      <!-- 导航菜单 -->
      <div class="nav-menu">
        <div 
          class="nav-item"
          :class="{ active: currentView === 'myspace' }"
          @click="selectNavItem('myspace')"
        >
          <div class="nav-icon">
            <img src="@/assets/images/用户管理.png" alt="我的空间" width="20" height="20">
          </div>
          <div class="nav-text" :class="{ 'active-text': currentView === 'myspace' }">我的空间</div>
        </div>
        
        <div class="nav-item" :class="{ active: currentView === 'mycourse' }" @click="selectNavItem('mycourse')">
          <div class="nav-icon">
            <img src="@/assets/images/知识库.png" alt="我的课程" width="20" height="20">
          </div>
          <div class="nav-text" :class="{ 'active-text': currentView === 'mycourse' }">我的课程</div>
        </div>
        
        <!-- <div class="nav-item" :class="{ active: currentView === 'smarttutor' }" @click="selectNavItem('smarttutor')">
          <div class="nav-icon">
            <img src="@/assets/images/模型.png" alt="智慧学伴" width="20" height="20">
          </div>
          <div class="nav-text" :class="{ 'active-text': currentView === 'smarttutor' }">智慧学伴</div>
        </div>
        
        <div class="nav-item" :class="{ active: currentView === 'aiagents' }" @click="selectNavItem('aiagents')">
          <div class="nav-icon">
            <img src="@/assets/images/菜单管理.png" alt="智能体助手" width="20" height="20">
          </div>
          <div class="nav-text" :class="{ 'active-text': currentView === 'aiagents' }">智能体助手</div>
        </div> -->
      </div>
    </div>

    <!-- 主内容区域 -->
    <div class="main-content" 
         :class="{
           'course-view': currentView === 'mycourse',
           'smarttutor-view': currentView === 'smarttutor'
         }">
      <!-- 智能体助手视图 -->
      <div v-if="currentView === 'aiagents'" class="ai-agents-content">
        <!-- 页面标题 -->
        <div class="agents-header">
          <h1>智能体助手</h1>
          <p>选择您需要的智能体助手，提升学习效率</p>
        </div>

        <!-- 智能体卡片网格 -->
        <div class="agents-grid">
          <div 
            v-for="agent in aiAgents" 
            :key="agent.id" 
            class="agent-card"
            :data-agent-id="agent.id"
            @click="useAgent(agent)"
          >
            <div class="agent-image">
              <div class="image-placeholder" :style="{ background: agent.bgColor }">
                {{ agent.emoji }}
              </div>
            </div>
            <div class="agent-content">
              <div class="agent-header">
                <h3 class="agent-title">{{ agent.title }}</h3>
                <span class="agent-type">{{ agent.type }}</span>
              </div>
              <p class="agent-description">{{ agent.description }}</p>
              <div class="agent-footer">
                <span class="agent-publisher">{{ agent.publisher }}</span>
                <button class="use-button">
                  <span class="button-text">免费复制</span>
                  <span class="copy-count">{{ agent.copyCount }}</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="content-wrapper" 
           :class="{
             'course-view': currentView === 'mycourse',
             'smarttutor-view': currentView === 'smarttutor'
           }"
           v-if="currentView !== 'aiagents'">
      <!-- 顶部欢迎区域 - 只在我的空间视图显示 -->
      <div v-if="currentView === 'myspace'" class="welcome-section">
        <div class="user-header">
          <div class="avatar-container">
            <img src="../../assets/images/xiaozhi.png" class="user-avatar2">
          </div>
         <div class="title-section">
            <!-- 添加一个流式输出的容器 -->
             <h1>{{ currentUserName }}，您好！我是您的{{ getCourseName() }}AI助教</h1>
            <div class="streaming-title">
              <span ref="titleSpan"></span>
            </div>
            <div class="streaming-subtitle">
              <span ref="subtitleSpan"></span>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 课程视图标题 -->
      <div v-if="currentView === 'mycourse'" class="course-title-section">
        <h1>
          <span ref="courseTitleSpan"></span>
        </h1>
      </div>

      <!-- 聊天区域 -->
      <div v-if="currentView === 'myspace'" class="chat-area">
        <div class="messages-container" ref="messagesContainer">
          <div v-for="(msg, index) in messages" :key="index" 
               :class="['message', msg.isUser ? 'user-message' : 'bot-message']">
            <div v-if="msg.isUser" class="user-message-content">
              {{ msg.content }}
            </div>
            <div v-else class="bot-message-content">
              <span v-html="convertStreamOutput(msg.content)"></span>
              <div v-if="msg.isTyping" class="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          </div>
        </div>
        
        <!-- 建议问题区域 -->
        <div v-if="messages.length === 0" class="suggested-questions">
          <div class="suggested-questions-title">💡 您可能想问：</div>
          <div class="suggested-questions-grid">
            <div 
              v-for="(question, index) in suggestedQuestions" 
              :key="index"
              class="suggested-question-item"
              @click="askSuggestedQuestion(question)"
            >
              {{ question }}
            </div>
          </div>
        </div>
      </div>

      <!-- 我的课程视图 -->
      <div v-if="currentView === 'mycourse'" class="courses-content course-view">
        <!-- 正在学习中 -->
        <div class="courses-section">
          <div class="section-header">
            <div class="section-bullet green"></div>
            <h2>正在学习中</h2>
          </div>
          
          <!-- 加载状态 -->
          <div v-if="coursesLoading" class="loading-state">
            <div class="loading-spinner"></div>
            <p>正在加载课程信息...</p>
          </div>
          
          <!-- 课程列表 -->
          <div v-else-if="currentCourses.length > 0" class="courses-grid">
            <div class="course-card" 
                 v-for="course in currentCourses" 
                 :key="course.id" 
                 @click="enterCourse(course)"
                 :class="{ 'current-course': isCurrentCourse(course.id) }">
              <div class="card-header">
                <div class="course-tag">+ 智慧课程</div>
                <div class="course-dates">开课时间：{{ formatCourseDate(course.createdAt) }}</div>
              </div>
              <div class="course-title">{{ course.title }}</div>
              <div class="course-subtitle">{{ course.subtitle }}</div>
              <div class="course-instructor">
                <span class="instructor-icon">👨‍🏫</span>
                {{ course.instructor }}
              </div>
              <div class="course-metrics">
                <div class="metric-item">
                  <span class="metric-label">问题</span>
                  <span class="metric-value">{{ course.questions }}</span>
                </div>
                <div class="metric-item">
                  <span class="metric-label">实践</span>
                  <span class="metric-value">{{ course.practice }}</span>
                </div>
                <div class="metric-item">
                  <span class="metric-label">主能力</span>
                  <span class="metric-value">{{ course.mainAbility }}</span>
                </div>
                <div class="metric-item">
                  <span class="metric-label">子能力</span>
                  <span class="metric-value">{{ course.subAbility }}</span>
                </div>
              </div>
              <div class="course-score">{{ course.scoreType }} | {{ course.score }}分</div>
              <div class="course-progress">
                <div class="progress-info">
                  <span>学习进度 {{ course.progress }}%</span>
                  <span>{{ course.knowledgePoints }} 个知识点</span>
                </div>
                <div class="progress-bar">
                  <div class="progress-fill" :style="{ width: course.progress + '%' }"></div>
                </div>
              </div>
              <div class="mastery-progress">
                <div class="mastery-circle" :class="{ completed: course.mastery === 100 }">
                  <span class="mastery-text">{{ course.mastery }}%</span>
                </div>
                <span class="mastery-label">掌握度</span>
              </div>
            </div>
          </div>
          
          <!-- 空状态 -->
          <div v-else class="empty-state">
            <div class="empty-icon">📚</div>
            <h3>暂无课程</h3>
            <p>您还没有选择任何课程，请联系老师添加课程</p>
          </div>
        </div>
      </div>

      <!-- 智慧学伴视图 -->
      <div v-if="currentView === 'smarttutor'" class="smart-tutor-content">
        <!-- 顶部头部 -->
        <div class="tutor-header">
          <div class="header-left">
            <div class="welcome-text">Hi, {{ currentUserName }}, 欢迎学习</div>
            <div class="course-title">
              {{ courseInfo.courseName || '课程加载中...' }}
              <span class="course-detail-link">课程详情></span>
            </div>
          </div>
          <div class="header-right">
            <div class="graph-nav" @click="goToKnowledgeGraph">
              <div class="graph-icon">🔷</div>
              <div class="graph-text">
                <div>去图谱</div>
                <div>探索></div>
              </div>
            </div>
          </div>
        </div>

        <!-- 主要内容区域 -->
        <div class="tutor-main">
          <!-- 左侧面板 -->
          <div class="tutor-left-panel">
            <!-- 学习指导 -->
            <div class="learning-guidance">
              <div class="guidance-text">
                学习本课时,需明确学习目标,规律学习时间,循序渐进,认真学习
              </div>
              <div class="guidance-quote">
                "学习从来无捷径,循序渐进登高峰~"
              </div>
            </div>

            <!-- 搜索栏 -->
            <div class="search-section">
              <div class="search-input">
                <input type="text" placeholder="学习遇到了困难?搜搜试试" />
                <span class="search-icon">🔍</span>
              </div>
            </div>

            <!-- 掌握度统计 -->
            <div class="mastery-stats">
              <div class="stat-item">
                <div class="stat-dot blue"></div>
                <span>136 掌握较好</span>
              </div>
              <div class="stat-item">
                <div class="stat-dot orange"></div>
                <span>0 掌握一般</span>
              </div>
              <div class="stat-item">
                <div class="stat-dot red"></div>
                <span>0 掌握较差</span>
              </div>
              <div class="stat-item">
                <div class="stat-dot grey"></div>
                <span>7 免考核</span>
              </div>
            </div>

            <!-- 待练习提示 -->
            <div class="pending-practice">
              还有7个知识点尚未开启练习~
            </div>
          </div>

          <!-- 中央知识图谱 -->
          <div class="knowledge-graph-container">
            <div class="knowledge-graph">
              <div class="graph-center">
                <div class="center-text">100% 知识掌握</div>
              </div>
              <div class="graph-segments">
                <div class="segment" v-for="(segment, index) in graphSegments" :key="index" 
                     :style="{ transform: `rotate(${index * 30}deg)` }">
                  <div class="segment-label">{{ segment.label }}</div>
                  <div class="segment-points">
                    <div v-for="point in segment.points" :key="point.id" 
                         class="knowledge-point" 
                         :class="{ mastered: point.mastered }"
                         :style="{ left: point.x + '%', top: point.y + '%' }">
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- AI助手 -->
        <div class="ai-assistant">
          <div class="assistant-avatar">🤖</div>
          <div class="assistant-label">AI助手</div>
        </div>
      </div>



      </div> <!-- 闭合 content-wrapper -->
      
      <!-- 聊天输入区域 -->
      <div v-if="currentView === 'myspace'" class="chat-input-section">
        <div class="input-area">
          <textarea 
            class="chat-input"
            placeholder="试着输入您想了解的问题吧 ~ Shift+enter是换行哦"
            v-model="userInput"
            @keydown.enter.exact.prevent="submitMessage"
            @keydown.shift.enter="newline"
          ></textarea>
          <button class="send-button" @click="submitMessage">
            <svg viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M2,21L23,12L2,3V10L17,12L2,14V21Z" />
            </svg>
          </button>
        </div>
      </div>
    </div>
    
    <!-- 右侧面板 -->
    <div v-if="currentView === 'myspace'" class="right-panel">
      <!-- 待办任务 -->
      <div class="task-panel">
        <div class="panel-header">
          <span class="panel-title">待办任务</span>
          <span class="task-count">(0)</span>
        </div>
        <div class="task-content">
          <div class="task-icon">📋</div>
          <div class="task-text">暂无任务</div>
        </div>
      </div>
      
      <!-- AI工具 -->
      <div class="ai-tools-panel">
        <div class="panel-header">
          <span class="panel-title">AI工具</span>
        </div>
        
        <div class="ai-tool-item" @click="navigateToAiReader">
          <div class="ai-tool-icon"><img src="@/assets/images/aiReading.png" alt="AI阅读助手"></div>
          <div class="ai-tool-info">
            <div class="ai-tool-name">AI阅读助手</div>
          </div>
          <div class="ai-tool-arrow">›</div>
        </div>
        
        <div class="ai-tool-item" @click="navigateToAiWriting">
          <div class="ai-tool-icon"><img src="@/assets/images/aiWritting.png" alt="AI写作助手"></div>
          <div class="ai-tool-info">
            <div class="ai-tool-name">AI写作助手</div>
          </div>
          <div class="ai-tool-arrow">›</div>
        </div>
        
       <div class="ai-tool-item" @click="navigateToAiPractice">
    <div class="ai-tool-icon"><img src="@/assets/images/aiPracticing.png" alt="AI陪练"></div>
    <div class="ai-tool-info">
      <div class="ai-tool-name">AI陪练</div>
    </div>
    <div class="ai-tool-arrow">›</div>
  </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, watch } from 'vue';
import axios from 'axios';
import { useRouter, useRoute } from 'vue-router';
import { useUserStore } from '../../store/user.js';
import { marked } from 'marked';

// 视图控制
const currentView = ref('myspace');

// Pinia 用户仓库
const userStore = useUserStore();

// 默认头像路径
const DEFAULT_AVATAR = '../../assets/images/shanzhi.png';

// 头像地址（优先 Pinia，再到 localStorage，最后默认图）
const userAvatarUrl = computed(() => {
  const cu = userStore?.currentUser || null;
  const storeAvatar = cu?.avatar || cu?.avatarUrl || cu?.headImg || '';
  if (storeAvatar) return storeAvatar;
  try {
    const ls = localStorage.getItem('studentAvatarUrl') || '';
    if (ls) return ls;
  } catch {}
  return DEFAULT_AVATAR;
});

// 获取当前用户信息
const currentUserName = computed(() => {
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    return user?.realName || user?.username || '同学'
  } catch {
    return '同学'
  }
})

// 根据courseId获取课程名称
const getCourseName = () => {
  const courseId = route.query.courseId || route.query.id || '101'
  const courseNames = {
    '101': '嵌入式开发进阶',
    '102': '计算机网络'
  }
  return courseNames[courseId] || '课程'
}

// 格式化课程开课时间
const formatCourseDate = (createdAt) => {
  if (!createdAt) return '未知时间'
  
  // 如果createdAt是数组格式 [Y, M, D, h, m, s]
  if (Array.isArray(createdAt)) {
    const [year, month, day] = createdAt
    return `${year}年${month}月${day}日`
  }
  
  // 如果createdAt是字符串格式
  if (typeof createdAt === 'string') {
    try {
      const date = new Date(createdAt)
      if (isNaN(date.getTime())) return '未知时间'
      return date.toLocaleDateString('zh-CN', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    } catch {
      return '未知时间'
    }
  }
  
  // 如果createdAt是Date对象
  if (createdAt instanceof Date) {
    return createdAt.toLocaleDateString('zh-CN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }
  
  return '未知时间'
}

const currentUserId = computed(() => {
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    return user?.id || '未知学号'
  } catch {
    return '未知学号'
  }
})

// 消息相关
const messages = ref([]);
const userInput = ref('');
const isSending = ref(false);
const messagesContainer = ref(null);
const uuid = ref('');

// 新增用于流式输出标题的refs
const titleSpan = ref(null);
const subtitleSpan = ref(null);
const courseTitleSpan = ref(null);

// 欢迎语内容
const welcomeTitle = computed(() => `我可以帮您做些什么呢？`);
const welcomeSubtitle = computed(() => `欢迎向我提问哦！😀`);
const courseWelcomeTitle = computed(() => `Hi, 点击课程, 开启学习旅程吧!`);

// 建议问题数据
const suggestedQuestions = computed(() => {
  const courseName = getCourseName();
  const courseId = route.query.courseId || route.query.id || '101';
  
  // 根据课程ID和课程名称生成相关的问题建议
  if (courseId === '101') { // 嵌入式开发进阶
    return [
      `请介绍一下${courseName}这门课程的主要内容`,
      '这门课程的学习重点是什么？',
      '如何学好这门课程？',
      '嵌入式开发需要掌握哪些编程语言？',
      '如何搭建嵌入式开发环境？',
      '嵌入式系统的调试方法有哪些？',
      '这门课程会涉及哪些硬件知识？',
      '嵌入式开发中常见的问题有哪些？',
      '如何优化嵌入式系统的性能？'
    ];
  } else if (courseId === '102') { // 计算机网络
    return [
      `请介绍一下${courseName}这门课程的主要内容`,
      '这门课程的学习重点是什么？',
      '如何学好这门课程？',
      '网络协议有哪些重要概念？',
      '如何理解OSI七层模型？',
      'TCP/IP协议族包含哪些协议？',
      '网络安全有哪些注意事项？',
      '网络拓扑结构有哪些类型？',
      '如何诊断网络故障？'
    ];
  }
  
  // 默认返回9条通用问题
  return [
    `请介绍一下${courseName}这门课程的主要内容`,
    '这门课程的学习重点是什么？',
    '如何学好这门课程？',
    '这门课程有哪些实践项目？',
    '这门课程需要哪些前置知识？',
    '如何评估学习效果？',
    '这门课程与就业有什么关系？',
    '有哪些学习资源推荐？',
    '如何制定学习计划？'
  ];
});

// 课程数据
const currentCourses = ref([]);
const coursesLoading = ref(false);



// 智能体数据
const aiAgents = ref([
  {
    id: 1,
    title: "智能助教 (作业批改)",
    description: "哈喽,生成课件/教案、辅助批阅作业请找我,我是历史老师的好帮手!",
    publisher: "扣子官方",
    type: "智能体",
    copyCount: "31.1K",
    emoji: "📝",
    bgColor: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)"
  },
  {
    id: 2,
    title: "雅思口语专家",
    description: "雅思保7冲8,认准雅思口语专家。支持语音通话，点击开始口语练习对话！",
    publisher: "momo @start_test",
    type: "智能体",
    copyCount: "22.3K",
    emoji: "🗣️",
    bgColor: "linear-gradient(135deg, #f093fb 0%, #f5576c 100%)"
  },
  {
    id: 3,
    title: "故事生成",
    description: "故事生成第一步",
    publisher: "西成歌 @xcai",
    type: "应用",
    copyCount: "20K",
    emoji: "📚",
    bgColor: "linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)"
  },
  {
    id: 4,
    title: "拍照解题",
    description: "结合豆包视觉理解和Deepseek能力,支持拍照解答题目",
    publisher: "Bepop @bepop",
    type: "应用",
    copyCount: "12.1K",
    emoji: "📷",
    bgColor: "linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)"
  },
  {
    id: 5,
    title: "古诗词情景再现",
    description: "诠释古诗词所要表达的意思和情感,并画出每一句的情景,帮助中小学生更好的理解古诗...",
    publisher: "扣子官方",
    type: "智能体",
    copyCount: "11.5K",
    emoji: "🏮",
    bgColor: "linear-gradient(135deg, #fa709a 0%, #fee140 100%)"
  },
  {
    id: 6,
    title: "翻译大师",
    description: "一边翻译一边记单词,助你学习提效。",
    publisher: "扣子官方",
    type: "智能体",
    copyCount: "9.7K",
    emoji: "🌐",
    bgColor: "linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)"
  },
  {
    id: 7,
    title: "智能助教 (学习陪伴)",
    description: "一起开始小学语文的快乐学习吧~",
    publisher: "扣子官方",
    type: "智能体",
    copyCount: "8.7K",
    emoji: "👩‍🏫",
    bgColor: "linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)"
  },
  {
    id: 8,
    title: "英语聊天",
    description: "Passionate and open-minded English foreign teacher",
    publisher: "扣子官方",
    type: "智能体",
    copyCount: "6.7K",
    emoji: "💬",
    bgColor: "linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%)"
  }
]);

// 知识图谱数据
const graphSegments = ref([
  { label: "结语", points: generatePoints(8, true) },
  { label: "历史是最好的教科书", points: generatePoints(12, true) },
  { label: "近代中华民族的磨难与抗争", points: generatePoints(15, true) },
  { label: "不同社会力量对国家出路的早期探索", points: generatePoints(10, true) },
  { label: "辛亥革命与君主专制制度的终结", points: generatePoints(14, true) },
  { label: "中国共产党成立和中国革命新局面", points: generatePoints(18, true) },
  { label: "中国革命的新道路", points: generatePoints(16, true) },
  { label: "中华民族的抗日战争", points: generatePoints(20, true) },
  { label: "为建立新中国而奋斗", points: generatePoints(12, true) },
  { label: "中华人民共和国的成立与中国社会...", points: generatePoints(11, true) },
  { label: "改革开放与中国特色社会主义的开...", points: generatePoints(13, true) },
  { label: "中国特色社会主义进入新时代", points: generatePoints(9, true) }
]);

// 生成知识点
function generatePoints(count, mostlyMastered = true) {
  const points = [];
  for (let i = 0; i < count; i++) {
    points.push({
      id: i,
      x: Math.random() * 80 + 10, // 10-90%
      y: Math.random() * 80 + 10, // 10-90%
      mastered: mostlyMastered ? Math.random() > 0.1 : Math.random() > 0.7
    });
  }
  return points;
}


const router = useRouter();
const route = useRoute();

// 课程信息相关
const courseInfo = ref({})
const loading = ref(false)

// 获取课程信息
const fetchCourseInfo = async () => {
  try {
    loading.value = true
    const courseId = route.query.courseId || route.query.id || '101'
    console.log('正在获取课程信息，courseId:', courseId)
    
    // 使用正确的API路径
    response = await axios.get('/api/xiaozhi/teacher/course', {
      params: { id: courseId }
    })
    
    if (response.data.code === 200) {
      courseInfo.value = response.data.data
      console.log('课程信息获取成功:', courseInfo.value)
      // 更新课程数据
      updateCourseData()
    } else {
      throw new Error(`API返回错误: ${response.data.message}`)
    }
  } catch (error) {
    console.error('获取课程信息失败:', error)
    // 如果API调用失败，使用默认数据
    courseInfo.value = {
      courseName: '未知课程',
      instructor: '未知教师',
      progress: 0,
      knowledgePoints: 0,
      mastery: 0
    }
  } finally {
    loading.value = false
  }
}

// 获取学生选择的课程列表
const fetchStudentCourses = async () => {
  try {
    coursesLoading.value = true
    console.log('正在获取学生课程列表...')
    
    // 获取当前学生ID
    const studentId = currentUserId.value
    if (!studentId || studentId === '未知学号') {
      console.warn('学生ID无效，无法获取课程列表')
      return
    }
    
    // 调用获取学生课程的API
    const response = await axios.get('/api/xiaozhi/student/my-courses', {
      params: { studentId: studentId }
    })
    
    if (response.data.code === 200) {
      // 转换API返回的数据格式为前端需要的格式
      const coursesData = response.data.data || []
      currentCourses.value = coursesData.map(course => ({
        id: course.id,
        title: course.courseName || '未知课程',
        subtitle: course.courseName ? `${course.courseName}(图谱)` : '课程(图谱)',
        instructor: course.instructor || '家里蹲大学 | 张老师',
        createdAt: course.createdAt, // 添加开课时间字段
        questions: course.questionCount || 0,
        practice: course.practiceCount || 0,
        mainAbility: course.mainAbility || 0,
        subAbility: course.subAbility || 0,
        scoreType: course.scoreType || '专业课',
        score: course.score || 4.0,
        progress: course.progress || 0,
        knowledgePoints: course.knowledgePointCount || 0,
        mastery: course.mastery || 0
      }))
      
      console.log('学生课程列表获取成功:', currentCourses.value)
    } else {
      throw new Error(`API返回错误: ${response.data.message}`)
    }
  } catch (error) {
    console.error('获取学生课程列表失败:', error)
    // 如果API调用失败，使用默认数据
    currentCourses.value = [
      {
        id: 1,
        title: "课程加载失败",
        subtitle: "请检查网络连接",
        instructor: "系统提示",
        createdAt: null, // 开课时间未知
        questions: 0,
        practice: 0,
        mainAbility: 0,
        subAbility: 0,
        scoreType: "未知",
        score: 0,
        progress: 0,
        knowledgePoints: 0,
        mastery: 0
      }
    ]
  } finally {
    coursesLoading.value = false
  }
}



// 判断是否为当前课程
const isCurrentCourse = (courseId) => {
  const currentCourseId = route.query.courseId || route.query.id;
  return currentCourseId == courseId;
}

// 更新课程数据
const updateCourseData = () => {
  if (courseInfo.value && courseInfo.value.courseName) {
    // 更新课程列表中的第二个课程（当前课程）
    if (currentCourses.value && currentCourses.value.length > 1) {
      currentCourses.value[1].title = courseInfo.value.courseName
      currentCourses.value[1].subtitle = courseInfo.value.courseName + '(图谱)'
      currentCourses.value[1].instructor = courseInfo.value.instructor || '家里蹲大学 | 张老师'
      currentCourses.value[1].progress = courseInfo.value.progress || 97
      currentCourses.value[1].knowledgePoints = courseInfo.value.knowledgePoints || 143
      currentCourses.value[1].mastery = courseInfo.value.mastery || 100
    }
  }
}

const navigateToAiPractice = () => {
  router.push('/ai_practice'); // 跳转到 AI陪练页面
};

// 跳转到 AI 阅读助手
const navigateToAiReader = () => {
  router.push('/ai_reader');
};

// 跳转到 AI 写作助手
const navigateToAiWriting = () => {
  router.push('/ai_writing');
};

// 使用智能体
const useAgent = (agent) => {
  console.log('使用智能体:', agent.title);
  
  // 智能体启动逻辑
  alert(`正在启动 ${agent.title}，请稍候...`);
};

// 返回课程页面功能
const goBack = () => {
  // 从当前路由参数中获取课程ID
  const courseId = route.query.courseId || route.query.id || '101'; // 默认为101
  window.location.href = `/course?id=${courseId}`;
};
// 初始化 UUID
const initUUID = () => {
  let storedUUID = localStorage.getItem('user_uuid');
  if (!storedUUID) {
    storedUUID = uuidToNumber(generateUUID());
    localStorage.setItem('user_uuid', storedUUID);
  }
  uuid.value = storedUUID;
}

// 简单的UUID生成函数
const generateUUID = () => {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0,
        v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

// UUID转换函数
const uuidToNumber = (uuid) => {
  let number = 0;
  for (let i = 0; i < uuid.length && i < 6; i++) {
    const hexValue = uuid[i];
    number = number * 16 + (parseInt(hexValue, 16) || 0);
  }
  return number % 1000000;
}

// 转换特殊字符并支持markdown
const convertStreamOutput = (output) => {
  if (!output) return '';
  
  // 先清理后端可能返回的各种形式的<br>标签文本
  let cleanedOutput = output
    .replace(/<br\s*\/?>/gi, '\n')           // 匹配 <br> 或 <br/> 或 <br />
    .replace(/&lt;br\s*\/?&gt;/gi, '\n')    // 匹配已转义的 &lt;br&gt;
    .replace(/＜br＞/g, '\n')               // 匹配全角的<br>
    // 处理连续的多个换行符，将它们减少为最多两个换行
    .replace(/\n{3,}/g, '\n\n')
    // 移除首尾的换行符
    .trim();
  
  // 使用marked解析markdown
  try {
    // 配置marked选项
    marked.setOptions({
      breaks: true, // 支持换行符转换为<br>
      gfm: true,    // 支持GitHub风格的markdown
    });
    
    // 解析markdown为HTML
    const htmlOutput = marked.parse(cleanedOutput);
    return htmlOutput;
  } catch (error) {
    console.warn('Markdown解析失败，使用原始文本:', error);
    // 如果markdown解析失败，回退到原来的处理方式
    return cleanedOutput
      .replace(/\n/g, '<br>')
      .replace(/\t/g, '&nbsp;&nbsp;&nbsp;&nbsp;');
  }
}

// 滚动到底部
const scrollToBottom = async () => {
  await nextTick();
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight;
  }
}

// 流式输出文本函数
const streamText = (elementRef, text, delay = 30) => {
  return new Promise((resolve) => {
    let i = 0;
    const interval = setInterval(() => {
      if (i < text.length) {
        elementRef.value.textContent += text.charAt(i);
        i++;
      } else {
        clearInterval(interval);
        resolve();
      }
    }, delay);
  });
}

// 页面加载时流式输出欢迎语
const streamWelcomeMessage = async () => {
  // 先清空原有内容
  if (titleSpan.value) titleSpan.value.textContent = '';
  if (subtitleSpan.value) subtitleSpan.value.textContent = '';
  
  // 流式输出标题
  await streamText(titleSpan, welcomeTitle.value, 30);
  
  // 短暂延迟后输出副标题
  await new Promise(resolve => setTimeout(resolve, 200));
  await streamText(subtitleSpan, welcomeSubtitle.value, 20);
}

// 流式输出课程欢迎语
const streamCourseWelcome = async () => {
  // 先清空原有内容
  if (courseTitleSpan.value) courseTitleSpan.value.textContent = '';
  
  // 流式输出课程欢迎语
  await streamText(courseTitleSpan, courseWelcomeTitle.value, 30);
}

// 处理建议问题点击
const askSuggestedQuestion = (question) => {
  // 将问题填入输入框
  userInput.value = question;
  // 自动发送消息
  submitMessage();
};

// 发送消息
const submitMessage = () => {
  if (!userInput.value.trim()) return;
  
  // 添加用户消息
  const userMsg = {
    isUser: true,
    content: userInput.value,
    isTyping: false,
    isThinking: false,
  };
  messages.value.push(userMsg);
  
  // 清空输入框
  const messageToSend = userInput.value;
  userInput.value = '';
  
  // 添加机器人加载消息
  const botMsg = {
    isUser: false,
    content: '', // 增量填充
    isTyping: true, // 显示加载动画
    isThinking: false,
  };
  messages.value.push(botMsg);
  
  // 滚动到底部
  scrollToBottom();
  
  // 发送请求
  isSending.value = true;
  sendRequest(messageToSend);
}

// 发送请求到后端
const sendRequest = (message) => {
  axios
    .post(
      '/api/xiaozhi/student/chat/by-course',
      { memoryId: uuid.value, message, courseId: route.query.courseId || currentCourseId.value },
      {
        responseType: 'stream', // 必须为合法值 "text"
        onDownloadProgress: (e) => {
          if (e.event.target.responseText) {
            const fullText = e.event.target.responseText; // 累积的完整文本
            if (messages.value.length > 0 && messages.value[messages.value.length - 1].isTyping) {
              let lastMsg = messages.value[messages.value.length - 1];
              let newText = fullText.substring(lastMsg.content.length);
              lastMsg.content += newText; //增量更新
              scrollToBottom(); // 实时滚动
            }
          }
        },
      }
    )
    .then(() => {
      // 流结束后隐藏加载动画
      if (messages.value.length > 0 && messages.value[messages.value.length - 1].isTyping) {
        messages.value[messages.value.length - 1].isTyping = false;
      }
      isSending.value = false;
    })
    .catch((error) => {
      console.error('流式错误:', error);
      if (messages.value.length > 0 && messages.value[messages.value.length - 1].isTyping) {
        messages.value[messages.value.length - 1].content = '请求失败，请重试';
        messages.value[messages.value.length - 1].isTyping = false;
      }
      isSending.value = false;
    });
}

// 换行处理
const newline = (e) => {
  // Shift+Enter换行
  // 这里不需要额外处理，因为textarea默认支持Shift+Enter换行
}

// 选择导航项
const selectNavItem = (item) => {
  currentView.value = item;
  console.log(`Selected: ${item}`);
  
  // 根据选择的视图执行相应的流式输出
  if (item === 'mycourse') {
    setTimeout(() => {
      streamCourseWelcome();
    }, 100);
  } else if (item === 'myspace') {
    setTimeout(() => {
      streamWelcomeMessage();
    }, 100);
  }
}

// 进入课程
const enterCourse = (course) => {
  console.log('进入课程:', course);
  
  // 获取当前页面的课程ID
  const currentCourseId = route.query.courseId || route.query.id;
  
  // 如果点击的是当前页面的课程，不需要跳转
  if (currentCourseId == course.id) {
    console.log('当前已在课程', course.id, '的学习空间中');
    // 可以在这里添加提示或者切换到智慧学伴视图
    currentView.value = 'smarttutor';
    return;
  }
  
  // 清空聊天记录与输入，重置到“我的空间”视图
  messages.value = [];
  userInput.value = '';
  currentView.value = 'myspace';
  // 重置会话ID，避免串到上一门课的上下文
  try {
    localStorage.removeItem('user_uuid');
  } catch {}
  uuid.value = Date.now().toString();
  
  // 跳转到学习空间页面，传递课程ID，并回到“我的空间”
  const targetUrl = `/study_space?courseId=${course.id}`;
  console.log('🚀 跳转到:', targetUrl);
  router.replace(targetUrl);
}

// 跳转到知识图谱
const goToKnowledgeGraph = () => {
  const courseId = route.query.courseId || route.query.id || '101';
  router.push({
    path: '/knowledge-graph',
    query: { courseId: courseId }
  });
}

// 组件挂载时初始化UUID并流式输出欢迎语
onMounted(async () => {
  initUUID();
  // 确保有头像：如果 Pinia/LocalStorage 都没有，则写入默认头像
  try {
    const cu = userStore?.currentUser || (JSON.parse(localStorage.getItem('currentUser')||'null')||{});
    const existing = cu?.avatar || cu?.avatarUrl || cu?.headImg || localStorage.getItem('studentAvatarUrl');
    const finalAvatar = existing || DEFAULT_AVATAR;
    if (!existing) {
      userStore?.setUser?.({ ...cu, avatarUrl: finalAvatar });
      localStorage.setItem('studentAvatarUrl', finalAvatar);
      window.dispatchEvent(new Event('student-avatar-updated'));
    }
  } catch {}
  // 先获取课程信息
  await fetchCourseInfo();
  
  // 获取学生课程列表
  await fetchStudentCourses();
  
  // 课程信息加载完成后再启动流式欢迎语
  setTimeout(streamWelcomeMessage, 500); // 稍微延迟确保DOM已渲染
  
  // 组件初始化完成
  console.log('✅ 学习空间组件已就绪，课程信息:', courseInfo.value, '学生课程:', currentCourses.value);
});

// 监控课程切换：刷新课程信息并触发欢迎语
watch(() => route.query.courseId, async (newId, oldId) => {
  if (newId === oldId) return;
  try {
    await fetchCourseInfo();
    await fetchStudentCourses();
    if (currentView.value !== 'aiagents') {
      setTimeout(streamWelcomeMessage, 300);
    }
  } catch (e) {
    console.warn('切换课程后加载信息失败', e);
  }
});
</script>

<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: "PingFang SC", "Microsoft YaHei", sans-serif;
}

.app-container {
  display: flex;
  height: 815px;
  width: 100%;
  background: url('../../assets/images/图片处理.png') no-repeat center center;
  background-size: cover;
  overflow: hidden;
  position: relative;
}

/* 返回按钮样式 */
.back-button {
  position: absolute;
  top: 10px;
  left: 20px;
  display: flex;
  height: 30px;
  align-items: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 12px;
  padding: 10px 16px;
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
  z-index: 1000;
  font-weight: 500;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

/* 课程相关样式 */
.section-header {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  gap: 15px;
}



.loading-state {
  text-align: center;
  padding: 40px 20px;
  color: #666;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #007acc;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #666;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 20px;
}

.empty-state h3 {
  margin: 0 0 10px 0;
  color: #333;
}

.empty-state p {
  margin: 0;
  color: #888;
}

/* 当前课程样式 */
.current-course {
  border: 2px solid #007acc !important;
  background: #e3f2fd !important;
  position: relative;
}

.current-course::after {
  content: '当前课程';
  position: absolute;
  top: -10px;
  right: 20px;
  background: #007acc;
  color: white;
  padding: 6px 12px;
  border-radius: 16px;
  font-size: 13px;
  font-weight: bold;
  white-space: nowrap;
  z-index: 10;
  box-shadow: 0 2px 8px rgba(0, 122, 204, 0.3);
}

.back-button:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
}

.back-button:active {
  transform: translateY(0);
}

.back-button svg {
  transition: transform 0.3s ease;
}

.back-button:hover svg {
  transform: translateX(-2px);
}

.back-button span {
  font-size: 14px;
}

/* 左侧导航栏样式 */
.sidebar {
  width: 240px;
  background: rgba(102, 126, 234, 0.9);
  backdrop-filter: blur(15px);
  border-radius: 16px;
  padding: 15px 0 0 0;
  display: flex;
  flex-direction: column;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  height: 720px;
  margin-top: 50px;
  margin-left: 35px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  position: relative;
  overflow: hidden;
}

.sidebar::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0.05) 100%);
  pointer-events: none;
}

.user-info {
  display: flex;
  align-items: center;
  padding: 0 20px 25px;
  position: relative;
  z-index: 1;
}

.user-avatar {
  width: 80px;
  height: 80px;
  margin-right: 15px;
  border-radius: 50%;
  border: 3px solid rgba(255,255,255,0.3);
  box-shadow: 0 4px 15px rgba(0,0,0,0.2);
  transition: transform 0.3s ease;
}

.user-avatar:hover {
  transform: scale(1.05);
}

.user-details {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-size: 18px;
  font-weight: 600;
  color: white;
  text-shadow: 0 1px 2px rgba(0,0,0,0.1);
  margin-bottom: 4px;
}

.user-id {
  font-size: 13px;
  color: rgba(255,255,255,0.8);
  background: rgba(255,255,255,0.1);
  padding: 2px 8px;
  border-radius: 10px;
  font-weight: 500;
}

.nav-menu {
  flex: 1;
  overflow-y: auto;
  padding: 0 15px;
  position: relative;
  z-index: 1;
}

.nav-item {
  display: flex;
  align-items: center;
  padding: 16px 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  border-radius: 12px;
  margin-bottom: 8px;
  position: relative;
  overflow: hidden;
}

.nav-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent);
  transition: left 0.5s;
}

.nav-item:hover::before {
  left: 100%;
}

.nav-item:hover {
  background: rgba(255,255,255,0.15);
  transform: translateX(5px);
}

.nav-icon {
  margin-right: 15px;
  color: rgba(255,255,255,0.9);
  transition: all 0.3s ease;
}

.nav-text {
  font-size: 15px;
  color: rgba(255,255,255,0.9);
  font-weight: 500;
  transition: all 0.3s ease;
}

.nav-item.active {
  background: rgba(255,255,255,0.25);
  border-radius: 12px;
  transform: translateX(5px);
  box-shadow: 0 4px 15px rgba(0,0,0,0.1);
}

.nav-item.active .nav-icon {
  color: white;
  transform: scale(1.1);
}

.active-text {
  color: white !important;
  font-weight: 600;
}

/* 主内容区域 */
.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 20px;
  gap: 20px;
  overflow-y: auto;
  background: transparent;
  position: relative;
}

/* 课程视图和智慧学伴视图时，主内容区域占满页面高度 */
.main-content.course-view,
.main-content.smarttutor-view {
  height: 100vh;
  min-height: 100vh;
}

/* 欢迎区域 */
.welcome-section {
  background: transparent;
  padding: 25px;
  position: relative;
}

/* 课程视图标题区域 */
.course-title-section {
  background: transparent;
  padding: 20px 25px;
  position: relative;
  text-align: center;
}

.course-title-section h1 {
  font-size: 28px;
  margin: 0;
  color: #ffffff;
  text-shadow: 0 2px 4px rgba(0,0,0,0.3);
  font-weight: 700;
}



.user-header {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  position: relative;
  z-index: 1;
}

.avatar-container {
  margin-right: 60px;
  margin-left: 60px;
  margin-top: 40px;
  position: relative;
}

.avatar-container::before {
  content: '';
  position: absolute;
  top: -10px;
  left: -10px;
  right: -10px;
  bottom: -10px;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4, #45b7d1, #96ceb4);
  border-radius: 50%;
  animation: rotate 3s linear infinite;
  z-index: -1;
}

@keyframes rotate {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.user-avatar2 {
  width: 130px;
  height: 110px;
  border-radius: 20px;
  border: 4px solid rgba(255,255,255,0.3);
  box-shadow: 0 10px 30px rgba(0,0,0,0.2);
  transition: transform 0.3s ease;
  position: relative;
  z-index: 1;
}

.user-avatar2:hover {
  transform: scale(1.05) rotate(2deg);
}

.title-section {
  display: flex;
  margin-top: 30px;
  flex-direction: column;
  position: relative;
  z-index: 1;
}

.title-section h1 {
  font-size: 28px;
  margin: 0 0 12px 0;
  color: #ffffff;
  text-shadow: 0 2px 4px rgba(0,0,0,0.3);
  font-weight: 700;
}

.streaming-title span, .streaming-subtitle span {
  font-size: 20px;
  color: #ffffff;
  text-shadow: 0 1px 3px rgba(0,0,0,0.3);
  font-weight: 600;
  display: inline-block;
  animation: textGlow 2s ease-in-out infinite alternate;
}

.streaming-subtitle span {
  font-size: 16px;
  color: #ffffff;
}

@keyframes textGlow {
  from { text-shadow: 0 1px 3px rgba(0,0,0,0.3); }
  to { text-shadow: 0 1px 3px rgba(0,0,0,0.3), 0 0 10px rgba(255,255,255,0.3); }
}

.title-section h2 {
  font-size: 18px;
  font-weight: normal;
  margin: 0 0 8px 0;
  color: rgba(255,255,255,0.9);
  text-shadow: 0 1px 2px rgba(0,0,0,0.2);
}

.subtitle {
  color: rgba(255,255,255,0.8);
  font-size: 14px;
  margin: 0;
  text-shadow: 0 1px 2px rgba(0,0,0,0.2);
}

/* 聊天区域 */
.chat-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  margin-bottom: 20px;
  background: transparent;
  border-radius: 15px;
}

/* 建议问题区域 */
.suggested-questions {
  padding: 20px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 15px;
  margin: 20px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.suggested-questions-title {
  font-size: 16px;
  color: #ffffff;
  margin-bottom: 15px;
  font-weight: 600;
  text-shadow: 0 1px 2px rgba(0,0,0,0.3);
}

.suggested-questions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 12px;
}

.suggested-question-item {
  background: rgba(255, 255, 255, 0.15);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 12px;
  padding: 12px 16px;
  color: #ffffff;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
  backdrop-filter: blur(5px);
  text-align: center;
  line-height: 1.4;
}

.suggested-question-item:hover {
  background: rgba(255, 255, 255, 0.25);
  border-color: rgba(255, 255, 255, 0.5);
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(255, 255, 255, 0.2);
}

.messages-container {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  scrollbar-width: thin;
  scrollbar-color: rgba(107, 91, 222, 0.3) transparent;
}

.messages-container::-webkit-scrollbar {
  width: 6px;
}

.messages-container::-webkit-scrollbar-track {
  background: transparent;
}

.messages-container::-webkit-scrollbar-thumb {
  background: rgba(107, 91, 222, 0.3);
  border-radius: 3px;
}

.message {
  margin-bottom: 20px;
  display: flex;
  animation: messageSlideIn 0.3s ease-out;
}

@keyframes messageSlideIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.user-message {
  justify-content: flex-end;
}

.bot-message {
  justify-content: flex-start;
}

.user-message-content {
  max-width: 70%;
  padding: 14px 18px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 20px 8px 20px 20px;
  word-break: break-word;
  box-shadow: 0 4px 15px rgba(107, 91, 222, 0.3);
  position: relative;
  font-weight: 500;
  line-height: 1.4;
}

.user-message-content::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(255,255,255,0.1) 0%, transparent 100%);
  border-radius: 20px 8px 20px 20px;
  pointer-events: none;
}

.bot-message-content {
  max-width: 70%;
  padding: 14px 18px;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  color: #333;
  border-radius: 8px 20px 20px 20px;
  word-break: break-word;
  position: relative;
  box-shadow: 0 4px 15px rgba(0,0,0,0.1);
  border: 1px solid rgba(0,0,0,0.05);
  line-height: 1.5;
}

.bot-message-content::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(79, 172, 254, 0.05) 0%, transparent 100%);
  border-radius: 8px 20px 20px 20px;
  pointer-events: none;
}

.typing-indicator {
  display: flex;
  padding-top: 8px;
  align-items: center;
}

.typing-indicator span {
  height: 10px;
  width: 10px;
  background: linear-gradient(45deg, #667eea, #764ba2);
  border-radius: 50%;
  margin-right: 6px;
  display: inline-block;
  animation: bounce 1.4s ease-in-out infinite;
  box-shadow: 0 2px 4px rgba(0,0,0,0.2);
}

.typing-indicator span:nth-child(2) {
  animation-delay: 0.2s;
}

.typing-indicator span:nth-child(3) {
  animation-delay: 0.4s;
  margin-right: 0;
}

@keyframes bounce {
  0%, 80%, 100% {
    transform: translateY(0) scale(1);
  }
  40% {
    transform: translateY(-8px) scale(1.1);
  }
}

/* 聊天输入区域 */
.chat-input-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: transparent;
  border-radius: 15px;
}

.input-area {
  width: 85%;
  display: flex;
  gap: 15px;
  align-items: flex-end;
  margin-left: 80px;
}

.chat-input {
  flex: 1;
  min-height: 60px;
  max-height: 120px;
  border: 2px solid rgba(107, 91, 222, 0.3);
  border-radius: 16px;
  padding: 15px 20px;
  font-size: 15px;
  resize: none;
  outline: none;
  background: rgba(255,255,255,0.95);
  backdrop-filter: blur(10px);
  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
  transition: all 0.3s ease;
  font-family: inherit;
  line-height: 1.5;
}

.chat-input::placeholder {
  color: #999;
  font-weight: 400;
}

.chat-input:focus {
  border-color: #667eea;
  background: white;
  box-shadow: 0 6px 25px rgba(102, 126, 234, 0.2);
  transform: translateY(-2px);
}

.send-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 50%;
  width: 50px;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
  position: relative;
  overflow: hidden;
}

.send-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  transition: left 0.5s;
}

.send-button:hover::before {
  left: 100%;
}

.send-button:hover {
  transform: scale(1.05);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
}

.send-button:active {
  transform: scale(0.95);
}

/* 右侧面板 */
.right-panel {
  width: 380px;
  display: flex;
  flex-direction: column;
  gap: 25px;
  padding: 0 20px;
  margin-top: 50px;
  margin-right: 50px;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 15px;
  border-bottom: 2px solid rgba(102, 126, 234, 0.1);
  position: relative;
}

.panel-header::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 30px;
  height: 2px;
  background: linear-gradient(90deg, #667eea, #764ba2);
  border-radius: 1px;
}

.panel-title {
  font-size: 16px;
  color: #333;
  font-weight: 600;
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.task-count {
  font-size: 14px;
  color: #667eea;
  margin-left: 6px;
  background: rgba(102, 126, 234, 0.1);
  padding: 2px 8px;
  border-radius: 10px;
  font-weight: 500;
}

/* 待办任务面板 */
.task-panel {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 18px;
  padding: 25px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  height: 300px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  position: relative;
  overflow: hidden;
}

.task-panel::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.03) 0%, transparent 100%);
  pointer-events: none;
}

.task-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 150px;
  position: relative;
  z-index: 1;
}

.task-icon {
  font-size: 48px;
  margin-bottom: 15px;
  filter: grayscale(0.3);
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-5px); }
}

.task-text {
  font-size: 16px;
  color: #666;
  font-weight: 500;
}

/* AI工具面板 */
.ai-tools-panel {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 18px;
  padding: 25px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  height: 400px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  position: relative;
  overflow: hidden;
}

.ai-tools-panel::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.03) 0%, transparent 100%);
  pointer-events: none;
}

.ai-tool-item {
  display: flex;
  align-items: center;
  padding: 18px 15px;
  border-radius: 12px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  z-index: 1;
  background: rgba(255,255,255,0.8);
  backdrop-filter: blur(5px);
  border: 1px solid rgba(102, 126, 234, 0.2);
}

.ai-tool-item:last-child {
  margin-bottom: 0;
}

.ai-tool-item:hover {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.2);
  border-color: rgba(102, 126, 234, 0.3);
}

.ai-tool-icon {
  width: 64px;
  height: 64px;
  border-radius: 0;
  background: transparent;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  margin-right: 18px;
  box-shadow: none;
  transition: all 0.3s ease;
}

.ai-tool-icon img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  border-radius: 0;
  display: block;
}

.ai-tool-item:hover .ai-tool-icon {
  transform: scale(1.05);
  box-shadow: none;
}

.ai-tool-info {
  flex: 1;
}

.ai-tool-name {
  font-size: 16px;
  color: #333;
  font-weight: 600;
  transition: color 0.3s ease;
}

.ai-tool-item:hover .ai-tool-name {
  color: #667eea;
}

.ai-tool-arrow {
  font-size: 18px;
  color: #667eea;
  font-weight: bold;
  transition: all 0.3s ease;
}

.ai-tool-item:hover .ai-tool-arrow {
  transform: translateX(5px);
  color: #764ba2;
}

/* 内容包装器样式 */
.content-wrapper {
  overflow-y: auto;
  height: calc(100vh - 200px);
  padding: 20px;
  gap: 20px;
  scrollbar-width: none; /* Firefox */
  -ms-overflow-style: none; /* IE and Edge */
}

/* 课程视图和智慧学伴视图的内容包装器 - 占满页面高度 */
.content-wrapper.course-view,
.content-wrapper.smarttutor-view {
  height: 100vh;
  min-height: 100vh;
}

/* Chrome, Safari, Opera */
.content-wrapper::-webkit-scrollbar {
  display: none;
}

/* AI工具项增强交互效果 */
.ai-tool-item:active {
  transform: scale(0.98) translateY(-1px);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

/* 课程内容样式 */
.courses-content {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background: transparent;
  height: 100%;
  min-height: 100%;
}

.courses-section {
  margin-bottom: 40px;
}

.section-header {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}

.section-bullet {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  margin-right: 12px;
}

.section-bullet.green {
  background: #52c41a;
}

.section-bullet.red {
  background: #ff4d4f;
}

.section-header h2 {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin: 0;
}

.courses-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  min-height: 0;
  justify-content: flex-start;
  align-items: flex-start;
}

/* 课程视图时，课程网格占满可用高度 */
.content-wrapper.course-view .courses-grid {
  min-height: calc(100vh - 300px);
}

/* 课程视图时，禁用滚动 */
.content-wrapper.course-view {
  overflow: hidden;
}

.courses-content.course-view {
  overflow: hidden;
}

.course-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #f0f0f0;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
  width: 400px;
  height: 400px;
  flex-shrink: 0;
}

.course-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
  border-color: #667eea;
}

.course-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #667eea, #764ba2);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

.course-tag {
  background: linear-gradient(135deg, #52c41a, #73d13d);
  color: white;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
}

.course-dates {
  font-size: 12px;
  color: #666;
}

.course-title {
  font-size: 16px;
  font-weight: 700;
  color: #333;
  margin-bottom: 6px;
  line-height: 1.2;
  word-wrap: break-word;
  overflow-wrap: break-word;
}

.course-subtitle {
  font-size: 12px;
  color: #666;
  margin-bottom: 8px;
  line-height: 1.3;
  word-wrap: break-word;
  overflow-wrap: break-word;
}

.course-instructor {
  display: flex;
  align-items: center;
  font-size: 14px;
  color: #666;
  margin-bottom: 16px;
}

.instructor-icon {
  margin-right: 8px;
  font-size: 16px;
}

.course-metrics {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
  margin-bottom: 12px;
}

.metric-item {
  text-align: center;
  padding: 6px 4px;
  background: #f8f9fa;
  border-radius: 6px;
}

.metric-label {
  display: block;
  font-size: 12px;
  color: #666;
  margin-bottom: 4px;
}

.metric-value {
  display: block;
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.course-score {
  font-size: 14px;
  color: #667eea;
  font-weight: 500;
  margin-bottom: 16px;
}

.course-progress {
  margin-bottom: 16px;
}

.progress-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
  font-size: 14px;
  color: #666;
}

.progress-bar {
  height: 6px;
  background: #f0f0f0;
  border-radius: 3px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #667eea, #764ba2);
  border-radius: 3px;
  transition: width 0.3s ease;
}

.mastery-progress {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.mastery-circle {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: #f0f0f0;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  border: 4px solid #e8e8e8;
}

.mastery-circle.completed {
  background: linear-gradient(135deg, #52c41a, #73d13d);
  border-color: #52c41a;
}

.mastery-text {
  font-size: 12px;
  font-weight: 600;
  color: #333;
}

.mastery-circle.completed .mastery-text {
  color: white;
}

.mastery-label {
  font-size: 14px;
  color: #666;
  font-weight: 500;
}

/* 智慧学伴样式 */
.smart-tutor-content {
  flex: 1;
  padding: 20px;
  background: linear-gradient(135deg, #e3f2fd 0%, #f3e5f5 100%);
  overflow-y: auto;
  height: 100%;
  min-height: 100%;
}

/* 顶部头部 */
.tutor-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 30px;
  padding: 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.header-left .welcome-text {
  font-size: 18px;
  color: #333;
  margin-bottom: 8px;
  font-weight: 500;
}

.header-left .course-title {
  font-size: 24px;
  font-weight: 700;
  color: #333;
}

.course-detail-link {
  font-size: 14px;
  color: #667eea;
  margin-left: 10px;
  cursor: pointer;
  font-weight: 500;
}

.graph-nav {
  display: flex;
  align-items: center;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  padding: 12px 20px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.graph-nav:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.3);
}

.graph-icon {
  font-size: 20px;
  margin-right: 10px;
}

.graph-text div:first-child {
  font-size: 14px;
  font-weight: 500;
}

.graph-text div:last-child {
  font-size: 12px;
  opacity: 0.8;
}

/* 主要内容区域 */
.tutor-main {
  display: flex;
  gap: 30px;
  height: calc(100vh - 200px);
}

/* 课程视图和智慧学伴视图时，主要内容区域占满页面高度 */
.content-wrapper.course-view .tutor-main,
.content-wrapper.smarttutor-view .tutor-main {
  height: calc(100vh - 100px);
}

/* 左侧面板 */
.tutor-left-panel {
  width: 300px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.learning-guidance {
  background: #2c3e50;
  color: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.guidance-text {
  font-size: 14px;
  line-height: 1.6;
  margin-bottom: 15px;
}

.guidance-quote {
  font-size: 12px;
  opacity: 0.8;
  font-style: italic;
}

.search-section {
  background: white;
  padding: 15px;
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
}

.search-input {
  position: relative;
  display: flex;
  align-items: center;
}

.search-input input {
  width: 100%;
  padding: 12px 40px 12px 15px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 14px;
  outline: none;
  transition: border-color 0.3s ease;
}

.search-input input:focus {
  border-color: #667eea;
}

.search-icon {
  position: absolute;
  right: 12px;
  font-size: 16px;
  color: #999;
}

.mastery-stats {
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
}

.stat-item {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
  font-size: 14px;
  color: #333;
}

.stat-item:last-child {
  margin-bottom: 0;
}

.stat-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  margin-right: 10px;
}

.stat-dot.blue { background: #3498db; }
.stat-dot.orange { background: #f39c12; }
.stat-dot.red { background: #e74c3c; }
.stat-dot.grey { background: #95a5a6; }

.pending-practice {
  background: white;
  padding: 15px;
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  font-size: 14px;
  color: #666;
  text-align: center;
}

/* 知识图谱 */
.knowledge-graph-container {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
  min-height: 0;
}

/* 智慧学伴视图时，知识图谱占满可用高度 */
.content-wrapper.smarttutor-view .knowledge-graph-container {
  min-height: calc(100vh - 300px);
}

.knowledge-graph {
  width: 600px;
  height: 600px;
  position: relative;
  background: white;
  border-radius: 50%;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.1);
  display: flex;
  justify-content: center;
  align-items: center;
}

.graph-center {
  position: absolute;
  z-index: 10;
  text-align: center;
}

.center-text {
  font-size: 18px;
  font-weight: 700;
  color: #333;
  background: white;
  padding: 20px;
  border-radius: 50%;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.graph-segments {
  position: absolute;
  width: 100%;
  height: 100%;
}

.segment {
  position: absolute;
  width: 50%;
  height: 50%;
  top: 25%;
  left: 25%;
  transform-origin: 50% 50%;
}

.segment-label {
  position: absolute;
  top: -30px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 12px;
  color: #666;
  white-space: nowrap;
  background: rgba(255, 255, 255, 0.9);
  padding: 4px 8px;
  border-radius: 4px;
}

.segment-points {
  position: relative;
  width: 100%;
  height: 100%;
}

.knowledge-point {
  position: absolute;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #95a5a6;
  transition: all 0.3s ease;
}

.knowledge-point.mastered {
  background: #00bcd4;
  box-shadow: 0 2px 6px rgba(0, 188, 212, 0.3);
}

.knowledge-point:hover {
  transform: scale(1.5);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

/* AI助手 */
.ai-assistant {
  position: fixed;
  bottom: 30px;
  right: 30px;
  display: flex;
  flex-direction: column;
  align-items: center;
  cursor: pointer;
  z-index: 1000;
}

.assistant-avatar {
  width: 60px;
  height: 60px;
  background: transparent;  /* 移除背景颜色 */
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: #333;  /* 改为深色文字 */
  transition: all 0.3s ease;
}

.assistant-avatar:hover {
  transform: scale(1.1);
}

.assistant-label {
  margin-top: 8px;
  font-size: 12px;
  color: #666;
  font-weight: 500;
}

/* 智能体助手视图样式 */
.ai-agents-content {
  flex: 1;
  padding: 30px;
  background: transparent;
  color: #333;
  overflow: hidden;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.agents-header {
  text-align: center;
  margin-bottom: 40px;
}

.agents-header h1 {
  font-size: 32px;
  font-weight: 700;
  margin-bottom: 10px;
  color: #333;
  text-shadow: 0 2px 4px rgba(255, 255, 255, 0.8);
}

.agents-header p {
  font-size: 16px;
  color: #666;
  font-weight: 400;
  text-shadow: 0 1px 2px rgba(255, 255, 255, 0.6);
}

.agents-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 25px;
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 20px;
  flex: 1;
  overflow: hidden;
}

.agent-card {
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(15px);
  border-radius: 20px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
  position: relative;
  overflow: hidden;
  min-height: 200px;
}

.agent-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
  transition: left 0.5s;
}

.agent-card:hover::before {
  left: 100%;
}

.agent-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
  border-color: rgba(255, 255, 255, 0.5);
}

/* 雅思口语专家特殊样式 */
.agent-card[data-agent-id="2"] {
  position: relative;
  overflow: hidden;
}

.agent-card[data-agent-id="2"]::after {
  content: '🎤 语音通话';
  position: absolute;
  top: 10px;
  right: 10px;
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 10px;
  font-weight: 600;
  opacity: 0;
  transform: translateY(-10px);
  transition: all 0.3s ease;
}

.agent-card[data-agent-id="2"]:hover::after {
  opacity: 1;
  transform: translateY(0);
}

.agent-image {
  margin-bottom: 20px;
  text-align: center;
}

.image-placeholder {
  width: 60px;
  height: 60px;
  border-radius: 15px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 30px;
  margin: 0 auto;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
  transition: all 0.3s ease;
}

.agent-card:hover .image-placeholder {
  transform: scale(1.1) rotate(5deg);
}

.agent-content {
  color: #333;
}

.agent-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.agent-title {
  font-size: 16px;
  font-weight: 700;
  color: #333;
  margin: 0;
  line-height: 1.3;
  flex: 1;
}

.agent-type {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
  margin-left: 10px;
  white-space: nowrap;
}

.agent-description {
  font-size: 13px;
  color: #666;
  line-height: 1.4;
  margin-bottom: 15px;
  min-height: 36px;
}

.agent-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.agent-publisher {
  font-size: 12px;
  color: #999;
  font-weight: 500;
}

.use-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 25px;
  padding: 8px 16px;
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 500;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.use-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.button-text {
  font-weight: 600;
}

.copy-count {
  background: rgba(255, 255, 255, 0.2);
  padding: 2px 8px;
  border-radius: 10px;
  font-size: 12px;
  font-weight: 500;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .ai-agents-content {
    padding: 20px;
    overflow: hidden;
  }
  
  .agents-grid {
    grid-template-columns: 1fr;
    gap: 20px;
    overflow: hidden;
  }
  
  .agents-header h1 {
    font-size: 28px;
  }
  
  .agents-header p {
    font-size: 16px;
  }
}

@media (max-width: 480px) {
  .agent-card {
    padding: 20px;
  }
  
  .agent-title {
    font-size: 16px;
  }
  
  .agent-description {
    font-size: 13px;
  }
}

/* Markdown样式支持 */
.bot-message-content :deep(h1),
.bot-message-content :deep(h2),
.bot-message-content :deep(h3),
.bot-message-content :deep(h4),
.bot-message-content :deep(h5),
.bot-message-content :deep(h6) {
  margin: 16px 0 8px 0;
  font-weight: 600;
  color: #2c3e50;
  line-height: 1.3;
}

.bot-message-content :deep(h1) {
  font-size: 1.5em;
  border-bottom: 2px solid #e1e8ed;
  padding-bottom: 8px;
}

.bot-message-content :deep(h2) {
  font-size: 1.3em;
  border-bottom: 1px solid #e1e8ed;
  padding-bottom: 6px;
}

.bot-message-content :deep(h3) {
  font-size: 1.1em;
}

.bot-message-content :deep(p) {
  margin: 8px 0;
  line-height: 1.6;
}

.bot-message-content :deep(ul),
.bot-message-content :deep(ol) {
  margin: 8px 0;
  padding-left: 20px;
}

.bot-message-content :deep(li) {
  margin: 4px 0;
  line-height: 1.5;
}

.bot-message-content :deep(blockquote) {
  margin: 12px 0;
  padding: 12px 16px;
  background: rgba(79, 172, 254, 0.1);
  border-left: 4px solid #4facfe;
  border-radius: 0 8px 8px 0;
  font-style: italic;
  color: #555;
}

.bot-message-content :deep(code) {
  background: rgba(0, 0, 0, 0.1);
  padding: 2px 6px;
  border-radius: 4px;
  font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
  font-size: 0.9em;
  color: #e74c3c;
}

.bot-message-content :deep(pre) {
  background: #f8f9fa;
  border: 1px solid #e1e8ed;
  border-radius: 8px;
  padding: 12px 16px;
  margin: 12px 0;
  overflow-x: auto;
  font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
  font-size: 0.9em;
  line-height: 1.4;
}

.bot-message-content :deep(pre code) {
  background: none;
  padding: 0;
  color: #333;
  border-radius: 0;
}

.bot-message-content :deep(table) {
  width: 100%;
  border-collapse: collapse;
  margin: 12px 0;
  font-size: 0.9em;
}

.bot-message-content :deep(th),
.bot-message-content :deep(td) {
  border: 1px solid #e1e8ed;
  padding: 8px 12px;
  text-align: left;
}

.bot-message-content :deep(th) {
  background: #f8f9fa;
  font-weight: 600;
  color: #2c3e50;
}

.bot-message-content :deep(tr:nth-child(even)) {
  background: rgba(0, 0, 0, 0.02);
}

.bot-message-content :deep(a) {
  color: #4facfe;
  text-decoration: none;
  border-bottom: 1px solid transparent;
  transition: all 0.3s ease;
}

.bot-message-content :deep(a:hover) {
  color: #2196f3;
  border-bottom-color: #2196f3;
}

.bot-message-content :deep(strong) {
  font-weight: 600;
  color: #2c3e50;
}

.bot-message-content :deep(em) {
  font-style: italic;
  color: #555;
}

.bot-message-content :deep(hr) {
  border: none;
  height: 1px;
  background: linear-gradient(to right, transparent, #e1e8ed, transparent);
  margin: 16px 0;
}

.bot-message-content :deep(img) {
  max-width: 100%;
  height: auto;
  border-radius: 8px;
  margin: 8px 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
</style>