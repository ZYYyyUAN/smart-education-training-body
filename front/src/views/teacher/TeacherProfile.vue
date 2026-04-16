<template>
  <div class="teacher-profile">
    <section class="header">
      <div class="header-left">
      <div class="avatar" @click="onEditAvatar">
        <img v-if="profile.avatar" :src="profile.avatar" @error="onAvatarError" />
        <div v-else class="avatar-initial">{{ initials }}</div>
          <!-- 性别符号徽章 -->
          <div class="gender-badge" v-if="profile.sex">
            <span v-if="profile.sex === '男'" class="gender-icon male">♂</span>
            <span v-else-if="profile.sex === '女'" class="gender-icon female">♀</span>
            <span v-else class="gender-icon unknown">?</span>
          </div>
      </div>
      <div class="info">
        <div class="name-line">
          <h2>{{ profile.name }}</h2>
          <el-tag type="success" class="ml8">{{ profile.title }}</el-tag>
        </div>
        <div class="meta">{{ profile.major }} | {{ profile.email }}</div>
        <div class="meta" v-if="profile.realName && profile.realName !== profile.name">真实姓名: {{ profile.realName }}</div>
        <div class="actions">
          <el-button size="small" @click="onEditAvatar">修改头像</el-button>
          <el-button size="small" @click="onEditName">修改姓名</el-button>
        </div>
      </div>
      </div>

      <div class="header-right">
        <div class="stats-cards">
          <div class="stat-card">
        <div class="value">{{ stats.prepTimes7d }}</div>
        <div class="label">近7天备课天数</div>
      </div>
          <div class="stat-card">
        <div class="value">{{ stats.assignedQuestions7d }}</div>
        <div class="label">布置作业数</div>
      </div>
          <div class="stat-card">
        <div class="value">{{ teacherPoints }}</div>
        <div class="label">教师积分</div>
            <el-tooltip 
              effect="dark" 
              placement="top" 
              :content="pointsRule"
              :show-after="300"
            >
              <div class="help-btn" @click="refreshPoints">
                <span class="help-icon">?</span>
      </div>
            </el-tooltip>
          </div>
          <div class="stat-card">
        <div class="value">{{ stats.studentInteractions7d }}</div>
        <div class="label">近7天学生互动数</div>
      </div>
      </div>
      </div>
      
      <input ref="avatarInput" type="file" accept="image/*" class="hidden" @change="handleAvatarSelected" />
    </section>

    <!-- 模块切换按钮 -->
    <section class="tab-navigation">
      <div class="tab-buttons">
        <button 
          v-for="tab in tabs" 
          :key="tab.key"
          :class="['tab-button', { active: activeTab === tab.key }]"
          @click="switchTab(tab.key)"
        >
          <span class="tab-icon">{{ tab.icon }}</span>
          <span class="tab-label">{{ tab.label }}</span>
        </button>
      </div>
    </section>

    <!-- 教师成就模块 -->
    <div v-show="activeTab === 'achievements'" class="tab-content">
    <!-- 勋章墙 -->
    <section class="module">
      <h3>勋章墙</h3>
      <div class="medal-wall">
        <div v-for="m in medals" :key="m.id" class="medal-item" :class="{ locked: !m.unlocked }" :title="m.unlocked ? ('已解锁 · ' + m.desc) : ('待解锁 · ' + m.desc)" @click="openMedal(m)">
          <img :src="m.img" :alt="m.name" />
          <div class="medal-name">{{ m.name }}</div>
          <div class="medal-tip" v-if="!m.unlocked">待解锁</div>
        </div>
      </div>
      <div class="chart-legend center">当前连续备课：{{ consecutivePrepDays }} 天</div>
    </section>

    <!-- 备课打卡墙 -->
    <section class="module">
      <h3>备课打卡墙（近一年）</h3>
      <div class="calendar-grid">
        <div v-for="(d, i) in calendar" :key="i" class="cell" :title="`${d.date}：${d.count} 次`" :style="{ background: colorFor(d.count) }"></div>
      </div>
      <div class="chart-legend center">颜色越深表示当天备课次数越多</div>
    </section>

      <!-- 教学数据分析 -->
    <section class="module">
      <h3>教学数据分析</h3>
      <div class="chart-container">
        <div class="chart-item">
          <div ref="lineChart" style="width: 100%; height: 300px;"></div>
        </div>
        <div class="chart-item">
          <div ref="barChart" style="width: 100%; height: 300px;"></div>
        </div>
      </div>
    </section>
    </div>

    <!-- 积分排行榜模块 -->
    <div v-show="activeTab === 'ranking'" class="tab-content">
    <section class="module">
      <h3>教师积分排行榜</h3>
      <div class="ranking-showcase">
        <div class="ranking-cards">
          <!-- 第二名 - 左边 -->
          <div class="ranking-card rank-2">
            <div class="medal-container">
              <div class="medal medal-2">
                <span class="medal-number">2</span>
              </div>
            </div>
            
            <div class="avatar-container">
              <div class="teacher-avatar">
                <img v-if="topThreeTeachers[1] && topThreeTeachers[1].avatar && topThreeTeachers[1].avatar.startsWith('http')" :src="topThreeTeachers[1].avatar" :alt="topThreeTeachers[1].name" />
                <div v-else class="avatar-placeholder">?</div>
              </div>
            </div>
            
            <div class="teacher-info">
              <div class="teacher-name">{{ topThreeTeachers[1]?.name || '待定' }}</div>
              <div class="teacher-school">{{ topThreeTeachers[1]?.school || '家里蹲大学' }}</div>
            </div>
            
            <div class="points-section">
              <div class="points-icon">💰</div>
              <div class="points-value">{{ topThreeTeachers[1]?.point || 0 }}</div>
            </div>
          </div>
          
          <!-- 第一名 - 中间 -->
          <div class="ranking-card rank-1">
            <div class="medal-container">
              <div class="medal medal-1">
                <span class="medal-number">1</span>
              </div>
            </div>
            
            <div class="avatar-container">
              <div class="teacher-avatar">
                <img v-if="topThreeTeachers[0] && topThreeTeachers[0].avatar && topThreeTeachers[0].avatar.startsWith('http')" :src="topThreeTeachers[0].avatar" :alt="topThreeTeachers[0].name" />
                <div v-else class="avatar-placeholder">?</div>
              </div>
            </div>
            
            <div class="teacher-info">
              <div class="teacher-name">{{ topThreeTeachers[0]?.name || '待定' }}</div>
              <div class="teacher-school">{{ topThreeTeachers[0]?.school || '家里蹲大学' }}</div>
            </div>
            
            <div class="points-section">
              <div class="points-icon">💰</div>
              <div class="points-value">{{ topThreeTeachers[0]?.point || 0 }}</div>
            </div>
            
            <div class="crown-decoration">👑</div>
          </div>
          
          <!-- 第三名 - 右边 -->
          <div class="ranking-card rank-3">
            <div class="medal-container">
              <div class="medal medal-3">
                <span class="medal-number">3</span>
              </div>
            </div>
            
            <div class="avatar-container">
              <div class="teacher-avatar">
                <img v-if="topThreeTeachers[2] && topThreeTeachers[2].avatar && topThreeTeachers[2].avatar.startsWith('http')" :src="topThreeTeachers[2].avatar" :alt="topThreeTeachers[2].name" />
                <div v-else class="avatar-placeholder">?</div>
              </div>
            </div>
            
            <div class="teacher-info">
              <div class="teacher-name">{{ topThreeTeachers[2]?.name || '待定' }}</div>
              <div class="teacher-school">{{ topThreeTeachers[2]?.school || '家里蹲大学' }}</div>
            </div>
            
            <div class="points-section">
              <div class="points-icon">💰</div>
              <div class="points-value">{{ topThreeTeachers[2]?.point || 0 }}</div>
            </div>
          </div>
        </div>
      </div>
    </section>
    </div>

    <!-- 其他模块 - 教师信息展示 -->
    <div v-show="activeTab === 'others'" class="tab-content">
      <!-- 专业能力雷达图 -->
      <section class="module teacher-skills-section">
        <h3>💡 专业能力</h3>
        
        <!-- 雷达图和技能列表 -->
        <div class="skills-content">
          <!-- 雷达图区域 -->
          <div class="radar-section">
            <div class="radar-container">
              <canvas ref="radarCanvas" width="500" height="500" class="radar-canvas"></canvas>
            </div>
          </div>
          
          <!-- 技能详情卡片 -->
          <div class="skill-details-grid">
            <div class="skill-detail-card" v-for="skill in teacherSkills" :key="skill.name">
              <div class="skill-card-header">
                <div class="skill-icon" :style="{ backgroundColor: skill.color + '20', color: skill.color }">
                  {{ skill.icon }}
                </div>
                <div class="skill-info">
                  <div class="skill-name">{{ skill.name }}</div>
                  <div class="skill-level">{{ skill.level }}%</div>
                </div>
                <div class="skill-badge" :class="getSkillLevelClass(skill.level)">
                  {{ getSkillLevelText(skill.level) }}
                </div>
              </div>
              <div class="skill-progress-bar">
                <div 
                  class="skill-progress-fill" 
                  :style="{ 
                    width: skill.level + '%', 
                    backgroundColor: skill.color,
                    animationDelay: (teacherSkills.indexOf(skill) * 0.1) + 's'
                  }"
                ></div>
              </div>
              <div class="skill-description">{{ skill.description }}</div>
            </div>
          </div>
        </div>
      </section>


      <!-- 学生评价墙 -->
      <section class="module student-reviews-section">
        <h3>💬 学生评价</h3>
        <div class="reviews-wall">
          <div class="reviews-grid">
            <div v-for="review in studentReviews" :key="review.id" class="review-card" :style="{ '--card-color': review.color }">
              <div class="review-header">
                <div class="student-avatar">{{ review.student.charAt(0) }}</div>
                <div class="student-info">
                  <div class="student-name">{{ review.student }}</div>
                  <div class="review-date">{{ review.date }}</div>
                </div>
                <div class="review-rating">
                  <span v-for="i in 5" :key="i" class="star" :class="{ filled: i <= review.rating }">⭐</span>
                </div>
              </div>
              <div class="review-content">
                "{{ review.content }}"
              </div>
              <div class="review-tags">
                <span v-for="tag in review.tags" :key="tag" class="review-tag">{{ tag }}</span>
              </div>
            </div>
          </div>
      </div>
    </section>

    </div>

    <!-- 勋章3D展示弹窗 -->
    <el-dialog v-model="medalDialog.visible" width="480px" :show-close="true" class="medal-dialog" :title="medalDialog.medal?.name || '勋章'">
      <div class="medal-dialog-content">
      <div class="medal-stage" @mousemove="onMedalMove" @mouseleave="onMedalLeave" @touchmove.passive="onMedalTouch">
        <div class="medal-card" :style="{ transform: medalTransform }">
          <img class="medal-large" :src="medalDialog.medal?.img" :alt="medalDialog.medal?.name" />
          <div class="medal-shine"></div>
        </div>
      </div>
      <div class="medal-meta">
        <div class="medal-title">{{ medalDialog.medal?.name }}</div>
        <div class="medal-desc">{{ medalDialog.medal?.desc }}</div>
        <div class="medal-state" :class="{ unlocked: medalDialog.medal?.unlocked }">{{ medalDialog.medal?.unlocked ? '已解锁' : '待解锁' }}</div>
        </div>
      </div>
      <template #footer>
        <el-button @click="medalDialog.visible=false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
import * as echarts from 'echarts'

const router = useRouter()

// 标签页状态管理
const activeTab = ref('achievements')

// 标签页配置
const tabs = ref([
  { key: 'achievements', label: '教师成就', icon: '🏆' },
  { key: 'ranking', label: '排行榜', icon: '📊' },
  { key: 'others', label: '综合评价', icon: '📋' }
])

// 切换标签页
const switchTab = (tabKey) => {
  activeTab.value = tabKey
  // 如果切换到包含图表的标签页，延迟初始化图表
  if (tabKey === 'achievements') {
    setTimeout(() => {
      initCharts()
    }, 100)
  }
  // 如果切换到其他标签页，初始化雷达图
  if (tabKey === 'others') {
    console.log('切换到其他标签页，初始化雷达图')
    nextTick(() => {
      initRadarChart()
    })
  }
}

const profile = ref({
  avatar: '',
  name: '',
  title: '教师',
  major: '',
  phone: '',
  email: '',
  realName: '',
  sex: '' // 性别字段
})

const initials = computed(() => (profile.value.name?.[0] || '教'))
const avatarInput = ref(null)

const stats = ref({ prepTimes7d: 0, assignedQuestions7d: 0, studentInteractions7d: 20, efficiencyIndex: 85 })
const teacherPoints = ref(0) // 教师积分
const rankingList = ref([]) // 积分排行榜
const currentUserId = ref(null) // 当前用户ID

// 计算属性：前三名教师
const topThreeTeachers = computed(() => {
  return rankingList.value.slice(0, 3)
})

// 计算属性：其他教师
const otherTeachers = computed(() => {
  return rankingList.value.slice(3, 10)
})

// 图表相关数据
const chartData = ref({
  loginDays: [], // 近7天登录天数数据
  assignmentStats: [] // 作业统计数据
})

// 图表实例
const lineChart = ref(null)
const barChart = ref(null)

// 生成模拟登录数据
const generateMockLoginData = () => {
  const last7Days = []
  const dailyLogins = {}
  let uniqueDays = 0
  
  for (let i = 6; i >= 0; i--) {
    const date = new Date()
    date.setDate(date.getDate() - i)
    const dateStr = date.toISOString().split('T')[0]
    last7Days.push(dateStr)
    
    // 随机生成登录次数（0-5次）
    const count = Math.floor(Math.random() * 6)
    dailyLogins[dateStr] = count
    if (count > 0) uniqueDays++
  }
  
  const chartData = last7Days.map(date => ({
    date: date,
    count: dailyLogins[date],
    formattedDate: new Date(date).toLocaleDateString('zh-CN', { month: 'numeric', day: 'numeric' })
  }))
  
  return { uniqueDays, chartData }
}

// 生成模拟作业数据 - 按日期统计
const generateMockAssignmentData = () => {
  const last7Days = []
  const dailyAssignments = {}
  let totalCount = 0
  
  for (let i = 6; i >= 0; i--) {
    const date = new Date()
    date.setDate(date.getDate() - i)
    // 使用本地日期格式，避免时区偏移
    const year = date.getFullYear()
    const month = date.getMonth() + 1
    const day = date.getDate()
    const dateStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
    last7Days.push(dateStr)
    
    // 随机生成每天的作业数量（0-5个）
    const count = Math.floor(Math.random() * 6)
    dailyAssignments[dateStr] = count
    totalCount += count
  }
  
  const assignmentStats = last7Days.map(date => ({
    date: date,
    count: dailyAssignments[date],
    formattedDate: new Date(date + 'T00:00:00').toLocaleDateString('zh-CN', { month: 'numeric', day: 'numeric' })
  }))
  
  return { totalCount, assignmentStats }
}

const lessonPlans = ref([
  { course: 'Python基础', chapter: '第3章：循环语句', status: '进行中', updatedAt: '2025-08-26 14:30' },
  { course: '数据结构', chapter: '第2章：栈与队列', status: '未开始', updatedAt: '2025-08-25 09:10' }
])

const questionFilter = ref({ type: 'all', level: 'all' })
const questions = ref([
  { title: '实现斐波那契函数', type: '编程题', level: '基础', updatedAt: '2025-08-26 11:00' },
  { title: '队列的基本操作', type: '选择题', level: '基础', updatedAt: '2025-08-25 15:40' }
])

const studentStats = ref([
  { name: '李雷', studentNo: '2025123001', finishedAt: '2025-08-26 20:15', score: 85, accuracy: '80%', wrongCount: 4, rank: '5/56' }
])

const students = ref([
  { name: '韩梅梅', studentNo: '2025123056', major: '计科', grade: '2023', activity: '登录7次/完成18题', avgAccuracy: '82%' }
])

const resources = ref([
  { name: 'Python基础语法.pdf', size: '2.1MB', uploadedAt: '2025-08-20 10:20' },
  { name: '循环练习题.docx', size: '380KB', uploadedAt: '2025-08-22 13:45' }
])

const overview = ref({ teacher: { today: 3, week: 12 }, student: { today: 20, week: 80 }, efficiency: 80 })

// 教师信息展示相关数据
const teachingStats = ref({
  totalStudents: null,
  totalCourses: null,
  avgRating: null,
  awards: null
})

// 教师技能数据
const teacherSkills = ref([
  { 
    name: '课程管理', 
    level: 95, 
    icon: '📚', 
    color: '#3b82f6',
    description: '精通课程设计与管理，能够创建系统化的教学体系，有效组织和管理各类课程资源。'
  },
  { 
    name: '作业管理', 
    level: 88, 
    icon: '📝', 
    color: '#10b981',
    description: '具备丰富的作业设计经验，能够创建多样化的作业形式，有效评估学生学习效果。'
  },
  { 
    name: '考试管理', 
    level: 92, 
    icon: '📊', 
    color: '#f59e0b',
    description: '擅长设计科学的考试体系，能够创建公平有效的评估机制，准确反映学生学习水平。'
  },
  { 
    name: '学生管理', 
    level: 85, 
    icon: '👥', 
    color: '#ef4444',
    description: '具备良好的学生管理能力，能够有效激发学生学习兴趣，引导学生健康成长。'
  },
  { 
    name: '备课效率', 
    level: 90, 
    icon: '⚡', 
    color: '#8b5cf6',
    description: '拥有高效的备课方法，能够快速准备高质量的教学内容，提升教学效率。'
  },
  { 
    name: '互动', 
    level: 87, 
    icon: '💬', 
    color: '#06b6d4',
    description: '善于与学生互动交流，能够营造活跃的课堂氛围，促进师生之间的有效沟通。'
  }
])

// 教学历程里程碑
const teachingMilestones = ref([
  { year: '2015', title: '入职教师', description: '加入计算机学院，开始教学生涯', icon: '🎓', color: '#3b82f6' },
  { year: '2017', title: '优秀教师奖', description: '获得学院优秀教师称号', icon: '🏆', color: '#f59e0b' },
  { year: '2019', title: '教学创新', description: '开发在线编程实践平台', icon: '💡', color: '#10b981' },
  { year: '2021', title: '学科带头人', description: '担任软件工程专业负责人', icon: '👑', color: '#ef4444' },
  { year: '2023', title: '研究突破', description: '发表SCI论文3篇，获得专利2项', icon: '🔬', color: '#8b5cf6' }
])

// 学生评价数据
const studentReviews = ref([
  {
    id: 1,
    student: '张政',
    date: '2024-01-15',
    rating: 5,
    content: '老师讲课非常生动有趣，总能用简单的例子解释复杂的概念，让我对编程产生了浓厚的兴趣！',
    tags: ['生动有趣', '通俗易懂'],
    color: '#eff6ff'
  },
  {
    id: 2,
    student: '李东楷',
    date: '2024-01-10',
    rating: 5,
    content: '老师的项目指导很有针对性，帮助我们解决了很多实际问题，受益匪浅。',
    tags: ['项目指导', '实用性强'],
    color: '#f0fdf4'
  },
  {
    id: 3,
    student: '梁本华',
    date: '2024-01-08',
    rating: 4,
    content: '课堂氛围很好，老师很有耐心，会反复解答我们的疑问。',
    tags: ['耐心细致', '课堂氛围'],
    color: '#fefce8'
  },
  {
    id: 4,
    student: '小贝',
    date: '2024-01-05',
    rating: 5,
    content: '老师的教学方法很创新，结合了理论和实践，让学习变得更有意思。',
    tags: ['教学创新', '理论结合实践'],
    color: '#fef2f2'
  }
])

// 教师荣誉数据
const teacherHonors = ref([
  { id: 1, title: '优秀教师', year: '2023', level: '国家级', icon: '🏆', color: '#ffd700' },
  { id: 2, title: '教学名师', year: '2022', level: '省级', icon: '👨‍🏫', color: '#c0c0c0' },
  { id: 3, title: '科研先进', year: '2021', level: '校级', icon: '🔬', color: '#cd7f32' },
  { id: 4, title: '创新团队', year: '2020', level: '院级', icon: '💡', color: '#87ceeb' }
])

const onEditAvatar = () => avatarInput.value?.click()
const onEditName = () => ElMessage.info('可在后续接入修改姓名接口')
const onAvatarError = () => { profile.value.avatar = '' }

const uploadFileToAliyun = async (file) => {
  const fd = new FormData()
  fd.append('file', file)
  const res = await axios.post('/api/xiaozhi/teacher/image', fd, { headers: { 'Content-Type': 'multipart/form-data' } })
  // 兼容多种 Result 格式
  if (res?.data?.code === 200 && res.data.data) return res.data.data
  if (res?.data?.code === 200 && typeof res.data.message === 'string' && res.data.message.startsWith('http')) return res.data.message
  if (typeof res.data === 'string') return res.data
  throw new Error('上传响应格式不支持')
}

const handleAvatarSelected = async (e) => {
  const file = e.target.files?.[0]
  if (!file) return
  try {
    const url = await uploadFileToAliyun(file)
    const encoded = encodeURI(url)
    profile.value.avatar = encoded
    // 保存至用户表（优先使用 Pinia 的 currentUserId，其次 localStorage 兼容字段）
    const store = useUserStore()
    const current = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const uid = store.currentUserId || current?.id || current?.userId || current?.teacherId
    if (uid) {
      await axios.post('/api/user/avatar', { userId: uid, avatarUrl: encoded }, { headers: { 'Content-Type': 'application/json' } })
      
      // 更新本地存储
      current.avatarUrl = encoded
      localStorage.setItem('currentUser', JSON.stringify(current))
      localStorage.setItem('teacherAvatarUrl', encoded)
      
      // 更新Pinia store中的用户信息
      const store = useUserStore()
      if (store.currentUser) {
        store.currentUser.avatarUrl = encoded
        console.log('已更新Pinia store中的头像:', encoded)
      }
      
      // 触发头像更新事件，通知其他组件
      window.dispatchEvent(new CustomEvent('teacher-avatar-updated', { detail: encoded }))
      
      // 同时更新profile中的头像
      profile.value.avatar = encoded
      
      ElMessage.success('头像更新成功，已保存数据库并同步到群聊和Pinia')
    } else {
      ElMessage.warning('未找到教师ID，未保存到数据库（请确认登录信息中包含 id 或 userId）')
    }
  } catch (err) {
    console.error(err)
    ElMessage.error('头像更新失败')
  } finally {
    e.target.value = ''
  }
}

// 获取近7天登录数据
const loadLoginStats = async () => {
  try {
    const store = useUserStore()
    const current = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const uid = store.currentUserId || current?.id || current?.userId || current?.teacherId
    
    console.log('当前用户ID:', uid, '用户信息:', current)
    
    if (!uid) {
      console.warn('无法获取用户ID，跳过登录统计')
      // 使用模拟数据
      const mockData = generateMockLoginData()
      stats.value.prepTimes7d = mockData.uniqueDays
      chartData.value.loginDays = mockData.chartData
      console.log('使用模拟登录数据:', mockData)
      return
    }

    try {
      // 尝试使用现有的登录记录接口
      const response = await axios.get(`/api/login-log/teacher?teacherId=${uid}&size=100`)
      console.log('登录记录接口响应:', response)
      
      if (response.data.code === 200 && response.data.data) {
        const loginData = response.data.data.records || response.data.data
        console.log('获取到的登录数据:', loginData)
        console.log('数据条数:', loginData?.length)
        
        // 计算近7天登录天数和每日登录次数
        const uniqueDays = new Set()
        const dailyLogins = {}
        
        // 获取近7天的日期
        const last7Days = []
        for (let i = 6; i >= 0; i--) {
          const date = new Date()
          date.setDate(date.getDate() - i)
          const dateStr = date.toISOString().split('T')[0]
          last7Days.push(dateStr)
          dailyLogins[dateStr] = 0
        }
        
        console.log('近7天日期范围:', last7Days)
        
        // 统计每天的登录次数
        if (Array.isArray(loginData)) {
          loginData.forEach((record, index) => {
            // 处理后端返回的字段名（驼峰命名loginTime或下划线login_time）
            const loginTime = record.loginTime || record.login_time
            if (loginTime) {
              let loginDate
              // 处理后端返回的数组格式时间 [2025, 9, 3, 19, 43, 10]
              if (Array.isArray(loginTime)) {
                // 数组格式：[年, 月, 日, 时, 分, 秒]，注意月份需要减1
                const [year, month, day, hour, minute, second] = loginTime
                const dateObj = new Date(year, month - 1, day, hour || 0, minute || 0, second || 0)
                loginDate = dateObj.toISOString().split('T')[0]
              } else {
                // 字符串格式时间
                loginDate = new Date(loginTime).toISOString().split('T')[0]
              }
              
              console.log(`第${index + 1}条记录: ${JSON.stringify(loginTime)} -> ${loginDate}`)
              
              if (dailyLogins.hasOwnProperty(loginDate)) {
                dailyLogins[loginDate]++
                uniqueDays.add(loginDate)
                console.log(`${loginDate} 登录次数: ${dailyLogins[loginDate]}`)
              } else {
                console.log(`${loginDate} 不在近7天范围内`)
              }
            } else {
              console.warn('记录缺少登录时间字段:', record)
            }
          })
        }
        
        console.log('每日登录统计:', dailyLogins)
        console.log('登录天数Set:', Array.from(uniqueDays))
        
        // 更新统计数据 - 备课天数是登录的天数（去重）
        stats.value.prepTimes7d = uniqueDays.size
        console.log('近7天备课天数:', uniqueDays.size)
        
        // 准备图表数据
        chartData.value.loginDays = last7Days.map(date => ({
          date: date,
          count: dailyLogins[date],
          formattedDate: new Date(date).toLocaleDateString('zh-CN', { month: 'numeric', day: 'numeric' })
        }))
        
        console.log('登录统计数据加载完成:', chartData.value.loginDays)
      } else {
        console.warn('登录记录接口返回数据格式异常:', response.data)
        throw new Error('数据格式异常')
      }
    } catch (apiError) {
      console.error('调用登录记录接口失败:', apiError)
      // 使用模拟数据作为备选方案
      const mockData = generateMockLoginData()
      stats.value.prepTimes7d = mockData.uniqueDays
      chartData.value.loginDays = mockData.chartData
      console.log('API调用失败，使用模拟登录数据:', mockData)
    }
  } catch (error) {
    console.error('获取登录统计失败:', error)
    // 使用模拟数据
    const mockData = generateMockLoginData()
    stats.value.prepTimes7d = mockData.uniqueDays
    chartData.value.loginDays = mockData.chartData
  }
}

// 获取作业统计数据
const loadAssignmentStats = async () => {
  try {
    const store = useUserStore()
    const current = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const uid = store.currentUserId || current?.id || current?.userId || current?.teacherId
    
    console.log('获取作业统计，用户ID:', uid)
    
    if (!uid) {
      console.warn('无法获取用户ID，使用模拟作业数据')
      const mockData = generateMockAssignmentData()
      stats.value.assignedQuestions7d = mockData.totalCount
      chartData.value.assignmentStats = mockData.assignmentStats
      console.log('使用模拟作业数据:', mockData)
      return
    }

    try {
      // 获取教师的作业数据
      console.log('正在获取教师作业数据...')
      const response = await axios.get(`/api/xiaozhi/teacher/assignments/by-teacher?teacherId=${uid}`)
      console.log('作业接口响应:', response)
      
      if (response.data.code === 200 && response.data.data) {
        const assignmentData = response.data.data
        console.log('获取到的作业数据:', assignmentData)
        
        // 统计作业总数
        const totalCount = Array.isArray(assignmentData) ? assignmentData.length : 0
        stats.value.assignedQuestions7d = totalCount
        console.log('作业总数:', totalCount)
        
        if (totalCount > 0) {
          // 按日期统计作业数量
          const dailyAssignments = {}
          
          // 获取近7天的日期
          const last7Days = []
          for (let i = 6; i >= 0; i--) {
            const date = new Date()
            date.setDate(date.getDate() - i)
            // 使用本地日期格式，避免时区偏移
            const year = date.getFullYear()
            const month = date.getMonth() + 1
            const day = date.getDate()
            const dateStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
            last7Days.push(dateStr)
            dailyAssignments[dateStr] = 0
          }
          
          console.log('近7天日期范围:', last7Days)
          
          // 统计每天的作业数量
          assignmentData.forEach((assignment, index) => {
            // 处理后端返回的字段名（驼峰命名或下划线）
            const createTime = assignment.createTime || assignment.create_time || assignment.createdAt || assignment.created_at
            if (createTime) {
              let assignmentDate
              // 处理后端返回的数组格式时间 [2025, 9, 3, 19, 43, 10]
              if (Array.isArray(createTime)) {
                // 数组格式：[年, 月, 日, 时, 分, 秒]，注意月份需要减1
                const [year, month, day, hour, minute, second] = createTime
                // 使用本地时间而不是UTC时间，避免时区偏移问题
                const dateObj = new Date(year, month - 1, day, hour || 0, minute || 0, second || 0)
                // 使用本地日期格式，避免UTC转换导致的日期偏移
                assignmentDate = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
              } else {
                // 字符串格式时间，使用本地时间解析
                const date = new Date(createTime)
                const year = date.getFullYear()
                const month = date.getMonth() + 1
                const day = date.getDate()
                assignmentDate = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
              }
              
              console.log(`第${index + 1}条作业记录: ${JSON.stringify(createTime)} -> ${assignmentDate}`)
              
              if (dailyAssignments.hasOwnProperty(assignmentDate)) {
                dailyAssignments[assignmentDate]++
                console.log(`${assignmentDate} 作业数量: ${dailyAssignments[assignmentDate]}`)
              } else {
                console.log(`${assignmentDate} 不在近7天范围内`)
              }
            } else {
              console.warn('作业记录缺少创建时间字段:', assignment)
            }
          })
          
          console.log('每日作业统计:', dailyAssignments)
          
          // 准备图表数据
          chartData.value.assignmentStats = last7Days.map(date => ({
            date: date,
            count: dailyAssignments[date],
            formattedDate: new Date(date + 'T00:00:00').toLocaleDateString('zh-CN', { month: 'numeric', day: 'numeric' })
          }))
          
          console.log('作业统计数据加载完成:', chartData.value.assignmentStats)
        } else {
          // 没有作业数据，初始化近7天数据为0
          const last7Days = []
          for (let i = 6; i >= 0; i--) {
            const date = new Date()
            date.setDate(date.getDate() - i)
            // 使用本地日期格式，避免时区偏移
            const year = date.getFullYear()
            const month = date.getMonth() + 1
            const day = date.getDate()
            const dateStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
            last7Days.push(dateStr)
          }
          
          chartData.value.assignmentStats = last7Days.map(date => ({
            date: date,
            count: 0,
            formattedDate: new Date(date + 'T00:00:00').toLocaleDateString('zh-CN', { month: 'numeric', day: 'numeric' })
          }))
          
          console.log('该教师暂无作业数据，初始化近7天数据为0')
        }
      } else {
        console.warn('作业接口返回数据格式异常:', response.data)
        throw new Error('数据格式异常')
      }
    } catch (apiError) {
      console.error('调用作业接口失败:', apiError)
      // 使用模拟数据作为备选方案
      const mockData = generateMockAssignmentData()
      stats.value.assignedQuestions7d = mockData.totalCount
      chartData.value.assignmentStats = mockData.assignmentStats
      console.log('API调用失败，使用模拟作业数据:', mockData)
    }
  } catch (error) {
    console.error('获取作业统计失败:', error)
    // 使用模拟数据
    const mockData = generateMockAssignmentData()
    stats.value.assignedQuestions7d = mockData.totalCount
    chartData.value.assignmentStats = mockData.assignmentStats
  }
}

// 初始化图表
const initCharts = () => {
  console.log('初始化图表，当前数据:', {
    loginDays: chartData.value.loginDays,
    assignmentStats: chartData.value.assignmentStats
  })
  
  // 初始化折线图 - 近7天备课次数
  if (lineChart.value && chartData.value.loginDays.length > 0) {
    const lineChartInstance = echarts.init(lineChart.value)
    const lineOption = {
      title: {
        text: '近7天备课次数',
        left: 'center',
        textStyle: {
          fontSize: 14,
          fontWeight: 'normal'
        }
      },
      tooltip: {
        trigger: 'axis',
        formatter: function(params) {
          const data = params[0]
          return `${data.axisValue}<br/>备课次数: ${data.value}次`
        }
      },
      xAxis: {
        type: 'category',
        data: chartData.value.loginDays.map(item => item.formattedDate),
        axisLabel: {
          fontSize: 12
        }
      },
      yAxis: {
        type: 'value',
        minInterval: 1,
        axisLabel: {
          fontSize: 12
        }
      },
      series: [{
        data: chartData.value.loginDays.map(item => item.count),
        type: 'line',
        smooth: true,
        lineStyle: {
          color: '#5470c6',
          width: 3
        },
        itemStyle: {
          color: '#5470c6'
        },
        areaStyle: {
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [{
              offset: 0, color: 'rgba(84, 112, 198, 0.3)'
            }, {
              offset: 1, color: 'rgba(84, 112, 198, 0.1)'
            }]
          }
        }
      }],
      grid: {
        left: '10%',
        right: '10%',
        bottom: '15%',
        top: '20%'
      }
    }
    lineChartInstance.setOption(lineOption)
    console.log('折线图初始化完成')
  } else {
    console.warn('折线图数据为空或DOM未就绪')
  }
  
  // 初始化折线图 - 近7天作业布置数量
  if (barChart.value && chartData.value.assignmentStats.length > 0) {
    const lineChartInstance = echarts.init(barChart.value)
    const lineOption = {
      title: {
        text: '近7天作业布置数量',
        left: 'center',
        textStyle: {
          fontSize: 14,
          fontWeight: 'normal'
        }
      },
      tooltip: {
        trigger: 'axis',
        formatter: function(params) {
          const data = params[0]
          return `${data.axisValue}<br/>作业数量: ${data.value}个`
        }
      },
      xAxis: {
        type: 'category',
        data: chartData.value.assignmentStats.map(item => item.formattedDate),
        axisLabel: {
          fontSize: 12
        }
      },
      yAxis: {
        type: 'value',
        minInterval: 1,
        axisLabel: {
          fontSize: 12
        }
      },
      series: [{
        data: chartData.value.assignmentStats.map(item => item.count),
        type: 'line',
        smooth: true,
        lineStyle: {
          color: '#91cc75',
          width: 3
        },
        itemStyle: {
          color: '#91cc75'
        },
        areaStyle: {
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [{
              offset: 0, color: 'rgba(145, 204, 117, 0.3)'
            }, {
              offset: 1, color: 'rgba(145, 204, 117, 0.1)'
            }]
          }
        }
      }],
      grid: {
        left: '10%',
        right: '10%',
        bottom: '15%',
        top: '20%'
      }
    }
    lineChartInstance.setOption(lineOption)
    console.log('作业折线图初始化完成')
  } else {
    console.warn('作业折线图数据为空或DOM未就绪')
  }
}

// 获取教师积分
const loadTeacherPoints = async (forceRefresh = false) => {
  try {
    const store = useUserStore()
    const current = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const uid = store.currentUserId || current?.id || current?.userId || current?.teacherId
    
    if (!uid) {
      console.warn('无法获取用户ID，跳过积分加载')
      teacherPoints.value = 0
      return
    }

    try {
      // 添加时间戳参数强制刷新缓存
      const timestamp = forceRefresh ? `?t=${Date.now()}` : ''
      
      // 优先使用专门的积分接口
      const response = await axios.get(`/api/xiaozhi/user/${uid}/points${timestamp}`, {
        headers: {
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache'
        }
      })
      console.log('获取用户积分信息响应:', response)
      
      if (response.data.code === 200 && response.data.data !== undefined) {
        teacherPoints.value = response.data.data || 0
        console.log('教师积分（专用接口）:', teacherPoints.value)
      } else {
        console.warn('积分接口返回数据格式异常，尝试用户信息接口:', response.data)
        
        // 如果专用接口失败，回退到用户信息接口
        const userResponse = await axios.get(`/api/xiaozhi/user/${uid}${timestamp}`, {
          headers: {
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache'
          }
        })
        
        if (userResponse.data.code === 200 && userResponse.data.data) {
          const userData = userResponse.data.data
        teacherPoints.value = userData.point || userData.points || 0
          console.log('教师积分（用户信息接口）:', teacherPoints.value)
      } else {
          console.warn('获取积分接口返回数据格式异常:', userResponse.data)
        teacherPoints.value = 0
        }
      }
    } catch (apiError) {
      console.error('调用积分接口失败:', apiError)
      // 如果API调用失败，设置默认值
      teacherPoints.value = 0
    }
  } catch (error) {
    console.error('获取教师积分失败:', error)
    teacherPoints.value = 0
  }
}

// 确保当前用户头像数据是最新的
const ensureCurrentUserAvatar = async () => {
  try {
    console.log('=== 确保当前用户头像数据最新 ===')
    
    const store = useUserStore()
    const current = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const uid = store.currentUserId || current?.id || current?.userId || current?.teacherId
    
    console.log('当前用户ID:', uid)
    console.log('profile.value.avatar 当前值:', profile.value.avatar)
    
    // 如果profile中没有头像，尝试从后端重新获取
    if (!profile.value.avatar && uid) {
      console.log('profile中没有头像，从后端重新获取...')
      
      try {
        const response = await axios.get(`/xiaozhi/user/${uid}`)
        if (response.data.code === 200 && response.data.data && response.data.data.avatar_url) {
          const avatarUrl = response.data.data.avatar_url
          console.log('从后端获取到头像:', avatarUrl)
          
          // 更新profile
          profile.value.avatar = avatarUrl
          
          // 同步到localStorage
          current.avatarUrl = avatarUrl
          localStorage.setItem('currentUser', JSON.stringify(current))
          localStorage.setItem('teacherAvatarUrl', avatarUrl)
          
          console.log('头像数据已同步到profile和localStorage')
        } else {
          console.log('后端没有返回头像数据')
        }
      } catch (error) {
        console.error('从后端获取头像失败:', error)
      }
    } else {
      console.log('profile中已有头像或没有用户ID')
    }
    
    console.log('最终profile.value.avatar:', profile.value.avatar)
  } catch (error) {
    console.error('确保头像数据时出错:', error)
  }
}

// 获取积分排行榜
const loadRankingList = async () => {
  try {
    console.log('正在获取积分排行榜...')
    
    // 在生成排行榜前，确保当前用户头像数据是最新的
    await ensureCurrentUserAvatar()
    
    // 尝试获取所有教师用户的积分排行
    const response = await axios.get('/xiaozhi/user/teachers/ranking')
    console.log('积分排行榜接口响应:', response)
    
    if (response.data.code === 200 && response.data.data && Array.isArray(response.data.data)) {
      const teachers = response.data.data
      console.log('从后端获取到的教师数据:', teachers)
      
      // 过滤教师角色，按积分降序排列，取前3名
      const validTeachers = teachers
        .filter(teacher => teacher.role === 'teacher' && teacher.point !== null && teacher.point !== undefined)
        .sort((a, b) => (b.point || 0) - (a.point || 0))
        .slice(0, 3)
      
      if (validTeachers.length > 0) {
        // 默认头像数组
        const defaultAvatars = [
          'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png',  // 默认头像1
          'https://cube.elemecdn.com/9/c2/f0ee8a3c7c9638a54940382568c9dpng.png',  // 默认头像2
          'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png',  // 默认头像3
          'https://fuss10.elemecdn.com/e/5d/4a731a90594a4af544c0c25941171jpeg.jpeg' // 默认头像4
        ]
        
        // 确保数据格式正确，只有真实头像才显示，否则显示问号
        rankingList.value = validTeachers.map((teacher, index) => {
          // 正确读取头像字段（后端返回的是avatarUrl驼峰命名）
          let avatarUrl = teacher.avatarUrl || teacher.avatar_url || teacher.avatar || ''
          
          console.log(`教师 ${teacher.realName || teacher.username} (ID: ${teacher.id}) 的头像字段:`, {
            avatarUrl: teacher.avatarUrl,
            avatar_url: teacher.avatar_url,
            avatar: teacher.avatar,
            final: avatarUrl
          })
          
          // 如果是张磊老师且没有头像，强制设置已知头像URL
          if (!avatarUrl && (teacher.realName === '张磊' || teacher.username === '张磊' || teacher.id === 1 || teacher.id === 2)) {
            console.log('为张磊老师设置已知头像URL (后端数据)')
            avatarUrl = 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/eabea5d7-ba89-40bd-9488-84812d32440f-2232.jpg_wh300.jpg'
          }
          
          return {
            id: teacher.id,
            name: teacher.realName || teacher.username || '未知教师',
            school: teacher.school || teacher.major || '家里蹲大学',
            point: teacher.point || 0,
            avatar: avatarUrl
          }
        })
        
        console.log('=== 后端数据排行榜调试 ===')
        console.log('后端返回的原始教师数据:', validTeachers)
        console.log('处理后的排行榜数据:', rankingList.value)
        
        // 详细显示每个教师的信息
        rankingList.value.forEach((teacher, index) => {
          console.log(`第${index + 1}名详细信息:`, {
            id: teacher.id,
            name: teacher.name,
            point: teacher.point,
            avatar: teacher.avatar,
            avatarValid: teacher.avatar && teacher.avatar.startsWith('http')
          })
        })
        return
      } else {
        console.warn('后端返回的教师数据为空或无效，使用动态数据')
      }
    } else {
      console.warn('积分排行榜接口返回数据格式异常:', response.data)
    }
  } catch (apiError) {
    console.error('调用积分排行榜接口失败:', apiError)
  }
  
  // 如果API调用失败或数据无效，使用动态数据
  console.log('使用动态排行榜数据作为备选方案')
    generateDynamicRankingData()
}

// 生成动态排行榜数据（基于当前用户数据）
const generateDynamicRankingData = () => {
  const store = useUserStore()
  const current = JSON.parse(localStorage.getItem('currentUser') || '{}')
  const uid = store.currentUserId || current?.id || current?.userId || current?.teacherId
  
  // 默认头像数组
  const defaultAvatars = [
    'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png',  // 默认头像1
    'https://cube.elemecdn.com/9/c2/f0ee8a3c7c9638a54940382568c9dpng.png',  // 默认头像2
    'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png',  // 默认头像3
    'https://fuss10.elemecdn.com/e/5d/4a731a90594a4af544c0c25941171jpeg.jpeg' // 默认头像4
  ]
  
  if (uid) {
    // 尝试从多个来源获取当前用户的头像
    let currentUserAvatar = profile.value.avatar
    if (!currentUserAvatar) {
      // 尝试从localStorage获取
      const localAvatar = localStorage.getItem('teacherAvatarUrl')
      if (localAvatar) {
        currentUserAvatar = localAvatar
      } else {
        // 尝试从currentUser获取
        try {
          const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
          currentUserAvatar = currentUser.avatarUrl || ''
        } catch (e) {
          currentUserAvatar = ''
        }
      }
    }
    
    // 如果所有本地来源都没有头像，强制使用张磊老师的已知头像URL作为临时解决方案
    if (!currentUserAvatar) {
      console.log('没有获取到头像，强制使用张磊老师的头像URL, 用户ID:', uid)
      currentUserAvatar = 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/eabea5d7-ba89-40bd-9488-84812d32440f-2232.jpg_wh300.jpg'
      console.log('强制设置后的头像URL:', currentUserAvatar)
    }
    
    console.log('=== 动态排行榜数据生成调试 ===')
    console.log('profile.value.avatar:', profile.value.avatar)
    console.log('localStorage teacherAvatarUrl:', localStorage.getItem('teacherAvatarUrl'))
    console.log('localStorage currentUser:', localStorage.getItem('currentUser'))
    console.log('最终使用的头像URL:', currentUserAvatar)
    console.log('头像URL是否以http开头:', currentUserAvatar?.startsWith('http'))
    
    // 生成包含当前用户和模拟数据的排行榜（确保有3个条目）
    rankingList.value = [
      {
      id: uid,
      name: profile.value.name || '当前教师',
      school: profile.value.major || '家里蹲大学',
      point: teacherPoints.value || 0,
        avatar: currentUserAvatar || ''  // 使用获取到的头像
      },
      {
        id: 999998,
        name: '张老师',
        school: '家里蹲大学',
        point: Math.max(0, (teacherPoints.value || 0) - 10),
        avatar: ''  // 模拟数据没有头像，显示问号
      },
      {
        id: 999999,
        name: '李老师',
        school: '家里蹲大学',
        point: Math.max(0, (teacherPoints.value || 0) - 20),
        avatar: ''  // 模拟数据没有头像，显示问号
      }
    ]
    
    // 按积分重新排序
    rankingList.value.sort((a, b) => (b.point || 0) - (a.point || 0))
    
    console.log('使用动态积分排行榜数据（包含模拟数据）:', rankingList.value)
    console.log('第一名数据详细:', rankingList.value[0])
    console.log('第一名头像URL:', rankingList.value[0]?.avatar)
    console.log('第一名头像是否以http开头:', rankingList.value[0]?.avatar?.startsWith('http'))
  } else {
    // 如果无法获取用户信息，提供默认排行榜
    rankingList.value = [
      {
        id: 999997,
        name: '王老师',
        school: '家里蹲大学',
        point: 120,
        avatar: ''  // 默认数据没有头像，显示问号
      },
      {
        id: 999998,
        name: '张老师',
        school: '家里蹲大学',
        point: 95,
        avatar: ''  // 默认数据没有头像，显示问号
      },
      {
        id: 999999,
        name: '李老师',
        school: '家里蹲大学',
        point: 85,
        avatar: ''  // 默认数据没有头像，显示问号
      }
    ]
    console.log('使用默认积分排行榜数据:', rankingList.value)
  }
}

// 获取用户信息
const loadUserInfo = async () => {
  try {
    const store = useUserStore()
    const current = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const uid = store.currentUserId || current?.id || current?.userId || current?.teacherId
    
    // 设置当前用户ID
    currentUserId.value = uid
    
    // 优先使用Pinia store中的用户信息
    if (store.currentUser) {
      const userData = store.currentUser
      profile.value = {
        avatar: userData.avatarUrl || '',
        name: userData.realName || userData.real_name || userData.username || '教师',
        title: '教师',
          major: userData.school || '未设置',
        phone: userData.email || '未设置',
        email: userData.email || '',
          realName: userData.realName || userData.real_name || userData.username || '',
          sex: userData.sex || '' // 性别
      }
      
      // 同时获取积分信息
      if (userData.point || userData.points) {
        teacherPoints.value = userData.point || userData.points || 0
      }
      
      // 确保头像同步到本地存储，供群聊使用
      if (userData.avatarUrl) {
        localStorage.setItem('teacherAvatarUrl', userData.avatarUrl)
        console.log('已从Pinia同步教师头像到本地存储:', userData.avatarUrl)
        return // 如果Pinia有数据，直接返回，不需要调用API
      }
    }
    
    // 如果Pinia没有数据，则调用API获取
    if (uid) {
      // 获取用户详细信息
      const response = await axios.get(`/api/xiaozhi/user/${uid}`)
      if (response.data.code === 200 && response.data.data) {
        const userData = response.data.data
        profile.value = {
          avatar: userData.avatarUrl || userData.avatar_url || '',
          name: userData.realName || userData.real_name || userData.username || '教师',
          title: '教师',
          major: userData.school || '未设置',
          phone: userData.email || '未设置',
          email: userData.email || '',
          realName: userData.realName || userData.real_name || userData.username || '',
          sex: userData.sex || '' // 性别
        }
        
        // 获取积分信息
        teacherPoints.value = userData.point || userData.points || 0
        
        // 确保头像同步到本地存储，供群聊使用
        const avatarToSync = userData.avatarUrl || userData.avatar_url
        if (avatarToSync) {
          localStorage.setItem('teacherAvatarUrl', avatarToSync)
          console.log('已从API同步教师头像到本地存储:', avatarToSync)
        }
      }
    }
  } catch (error) {
    console.error('获取用户信息失败:', error)
    // 如果API调用失败，使用本地存储的数据作为备选
    try {
      const raw = localStorage.getItem('currentUser')
      const user = raw ? JSON.parse(raw) : null
      if (user) {
        profile.value = {
          avatar: user.avatarUrl || '',
          name: user.real_name || user.username || '教师',
          title: '教师',
          major: user.school || '未设置',
          phone: user.email || '未设置',
          email: user.email || '',
          realName: user.real_name || user.username || '',
          sex: user.sex || '' // 性别
        }
        
        // 获取积分信息
        teacherPoints.value = user.point || user.points || 0
      }
    } catch (e) {
      console.error('解析本地用户数据失败:', e)
    }
  }
}

onMounted(async () => {
  // 加载用户信息
  await loadUserInfo()
  
  // 强制刷新教师积分，确保获取最新数据
  await loadTeacherPoints(true)
  
  // 如果loadUserInfo没有设置头像，则使用本地存储的头像
  if (!profile.value.avatar) {
    const local = localStorage.getItem('teacherAvatarUrl')
    if (local) {
      profile.value.avatar = decodeURI(local) === local ? encodeURI(local) : local
    } else {
      try {
        const raw = localStorage.getItem('currentUser')
        const user = raw ? JSON.parse(raw) : null
        if (user?.avatarUrl) {
          const u = user.avatarUrl
          profile.value.avatar = decodeURI(u) === u ? encodeURI(u) : u
        }
      } catch {}
    }
  }
  
  console.log('教师端个人信息页面头像初始化完成:', profile.value.avatar)
  console.log('教师积分初始化完成:', teacherPoints.value)
  
  // 监听头像更新事件，当头像更新时重新加载排行榜
  window.addEventListener('teacher-avatar-updated', async (event) => {
    console.log('检测到头像更新，重新加载排行榜:', event.detail)
    profile.value.avatar = event.detail
    await loadRankingList()
  })
  
  // 加载统计数据
  await loadLoginStats()
  await loadAssignmentStats()
  
  // 加载备课打卡墙
  await loadCalendar()
  
  // 重要：在用户信息和头像都加载完成后，再加载积分排行榜
  console.log('开始加载积分排行榜，当前用户头像:', profile.value.avatar)
  await loadRankingList()
  
  // 延迟初始化图表，确保DOM已渲染和数据加载完成
  setTimeout(() => {
    console.log('延迟执行图表初始化...')
    initCharts()
  }, 500)
  
  // 如果第一次失败，再尝试一次
  setTimeout(() => {
    if (chartData.value.loginDays.length > 0 || chartData.value.assignmentStats.length > 0) {
      console.log('二次尝试图表初始化...')
      initCharts()
    }
  }, 1000)
  
  // 初始化教师信息
  initTeacherInfo()
  
  // 延迟初始化雷达图
  setTimeout(() => {
    if (activeTab.value === 'others') {
      console.log('onMounted中初始化雷达图')
      initRadarChart()
    }
  }, 1500)
  
  // 无论什么标签页都尝试初始化雷达图
  setTimeout(() => {
    console.log('强制初始化雷达图')
    initRadarChart()
  }, 2000)
})

// 组件销毁时清理
onUnmounted(() => {
  // 清理监听器
  window.removeEventListener('teacher-avatar-updated', () => {})
  
})

const go = (path) => router.push(path)

// 积分规则说明
const pointsRule = '积分规则：每次登录+2积分，布置作业+4积分。'

// 手动刷新积分
const refreshPoints = async () => {
  console.log('手动刷新积分...')
  await loadTeacherPoints(true)
  console.log('积分刷新完成:', teacherPoints.value)
}

// 勋章墙逻辑
const consecutivePrepDays = ref(0)
// 使用新上传的教师专属勋章图片
const medal1Img = new URL('@/assets/images/春风化雨.png', import.meta.url).href
const medal2Img = new URL('@/assets/images/桃李满蹊.png', import.meta.url).href
const medal3Img = new URL('@/assets/images/诲人不倦.png', import.meta.url).href
const medal4Img = new URL('@/assets/images/甘为人梯.png', import.meta.url).href
const medal5Img = new URL('@/assets/images/润物无声.png', import.meta.url).href

// 教师专属勋章
const medals = computed(() => [
  { id: 'spring_rain', name: '春风化雨', img: medal1Img, unlocked: consecutivePrepDays.value >= 7, desc: '连续7天备课，如春风化雨般滋润学生心田' },
  { id: 'peach_plum', name: '桃李满蹊', img: medal2Img, unlocked: consecutivePrepDays.value >= 18, desc: '连续18天备课，桃李满天下' },
  { id: 'tireless_teaching', name: '诲人不倦', img: medal3Img, unlocked: stats.value.assignedQuestions7d >= 10, desc: '布置作业数≥10，诲人不倦的教学精神' },
  { id: 'ladder', name: '甘为人梯', img: medal4Img, unlocked: stats.value.assignedQuestions7d >= 30, desc: '布置作业数≥30，甘为人梯助学生成长' },
  { id: 'silent_nourishment', name: '润物无声', img: medal5Img, unlocked: stats.value.assignedQuestions7d >= 50, desc: '布置作业数≥50，润物无声的教育力量' }
])

// 备课打卡墙数据（近一年）
const calendar = ref([])
const colorFor = (count) => {
  // 绿色梯度：0=灰，>=1 浅绿，>=4 中绿，>=8 深绿，>=12 更深
  if (count >= 12) return '#166534'    // 深
  if (count >= 8)  return '#15803d'
  if (count >= 4)  return '#22c55e'
  if (count >= 1)  return '#86efac'
  return '#e5e7eb'                     // 无记录
}

// 加载备课打卡墙数据
const loadCalendar = async () => {
  try {
    const store = useUserStore()
    const current = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const uid = store.currentUserId || current?.id || current?.userId || current?.teacherId
    
    if (!uid) {
      console.warn('无法获取用户ID，跳过备课打卡墙加载')
      calendar.value = []
      return
    }

    // 尝试从现有的登录记录接口获取数据
    const response = await axios.get(`/api/login-log/teacher?teacherId=${uid}&size=365`)
    console.log('备课打卡墙接口响应:', response)
    
    if (response.data.code === 200 && response.data.data) {
      const loginData = response.data.data.records || response.data.data
      console.log('获取到的登录数据用于打卡墙:', loginData)
      
      // 处理近一年的日期数据
      const calendarData = []
      const loginCounts = {}
      
      // 统计每天的登录次数
      if (Array.isArray(loginData)) {
        loginData.forEach((record) => {
          const loginTime = record.loginTime || record.login_time
          if (loginTime) {
            let loginDate
            // 处理后端返回的数组格式时间 [2025, 9, 3, 19, 43, 10]
            if (Array.isArray(loginTime)) {
              const [year, month, day] = loginTime
              loginDate = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
            } else {
              // 字符串格式时间
              const date = new Date(loginTime)
              const year = date.getFullYear()
              const month = date.getMonth() + 1
              const day = date.getDate()
              loginDate = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
            }
            
            if (!loginCounts[loginDate]) {
              loginCounts[loginDate] = 0
            }
            loginCounts[loginDate]++
          }
        })
      }
      
      // 生成近一年的日期数组
      const oneYearAgo = new Date()
      oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1)
      
      for (let d = new Date(oneYearAgo); d <= new Date(); d.setDate(d.getDate() + 1)) {
        const year = d.getFullYear()
        const month = d.getMonth() + 1
        const day = d.getDate()
        const dateStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
        
        calendarData.push({
          date: dateStr,
          count: loginCounts[dateStr] || 0
        })
      }
      
      calendar.value = calendarData
      
      // 计算连续备课天数
      consecutivePrepDays.value = computeConsecutivePrepDays(calendarData)
      
      console.log('备课打卡墙数据加载完成，连续备课天数:', consecutivePrepDays.value)
    } else {
      console.warn('备课打卡墙接口返回数据格式异常:', response.data)
      calendar.value = []
    }
  } catch (error) {
    console.error('获取备课打卡墙数据失败:', error)
    calendar.value = []
  }
}

// 计算连续备课天数
const computeConsecutivePrepDays = (arr) => {
  try {
    const active = new Set((arr || []).filter(it => it && it.count > 0 && it.date).map(it => it.date))
    const ONE_DAY = 24 * 60 * 60 * 1000
    const pad = (n) => (n < 10 ? '0' + n : '' + n)
    const fmt = (d) => `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
    let d = new Date()
    let cnt = 0
    while (true) {
      const key = fmt(d)
      if (active.has(key)) {
        cnt++
        d = new Date(d.getTime() - ONE_DAY)
      } else {
        break
      }
    }
    return cnt
  } catch {
    return 0
  }
}

// 教师信息相关方法
// 初始化教师信息
const initTeacherInfo = () => {
  // 模拟生成教学数据
  teachingStats.value = {
    totalStudents: Math.floor(Math.random() * 500 + 100),
    totalCourses: Math.floor(Math.random() * 20 + 5), 
    avgRating: (Math.random() * 1 + 4).toFixed(1),
    awards: Math.floor(Math.random() * 8 + 2)
  }
  
  // 扩展profile信息
  if (!profile.value.joinDate) {
    profile.value.joinDate = '2023年9月'
  }
  if (!profile.value.specialty) {
    profile.value.specialty = '计算机科学与技术'
  }
  if (!profile.value.experience) {
    profile.value.experience = Math.floor(Math.random() * 10 + 2) + '年'
  }
  if (!profile.value.education) {
    profile.value.education = '硕士研究生'
  }
  if (!profile.value.motto) {
    profile.value.motto = '因材施教，寓教于乐，让每一位学生在快乐中学习，在实践中成长'
  }
}

// 获取技能等级文本
const getSkillLevelText = (level) => {
  if (level >= 90) return '专家'
  if (level >= 80) return '熟练'
  if (level >= 70) return '中等'
  return '初级'
}

// 获取技能等级样式类
const getSkillLevelClass = (level) => {
  if (level >= 90) return 'expert'
  if (level >= 80) return 'proficient'
  if (level >= 70) return 'intermediate'
  return 'beginner'
}

// 获取技能描述
const getSkillDescription = (skillName, level) => {
  const descriptions = {
    '编程教学': {
      95: '在编程教学领域具有深厚的理论基础和丰富的实践经验，能够指导学生掌握复杂的编程技术。',
      90: '具备扎实的编程教学能力，能够有效传授各种编程语言和开发技术。',
      85: '拥有良好的编程教学技能，能够指导学生完成基础和中级编程项目。'
    },
    '学术研究': {
      88: '在学术研究方面表现突出，具有较强的研究能力和学术写作水平。',
      85: '具备良好的学术研究素养，能够独立完成研究项目。',
      80: '拥有基础的学术研究能力，能够参与科研项目。'
    },
    '项目指导': {
      92: '在项目指导方面经验丰富，能够有效指导学生完成复杂项目。',
      90: '具备优秀的项目指导能力，能够帮助学生提升实践技能。',
      85: '拥有良好的项目指导经验，能够指导基础项目开发。'
    },
    '团队协作': {
      85: '具备良好的团队协作能力，能够有效组织和参与团队项目。',
      80: '拥有基础的团队协作技能，能够与同事良好合作。',
      75: '具备一定的团队协作意识，正在提升协作技能。'
    },
    '创新思维': {
      90: '具有强烈的创新意识和创新能力，能够提出新颖的教学方法。',
      85: '拥有良好的创新思维，能够在教学中融入创新元素。',
      80: '具备基础的创新能力，能够尝试新的教学方式。'
    },
    '学生管理': {
      87: '在学生管理方面经验丰富，能够有效管理和激励学生。',
      85: '具备良好的学生管理能力，能够建立良好的师生关系。',
      80: '拥有基础的学生管理技能，能够维护课堂秩序。'
    }
  }
  
  const skillDesc = descriptions[skillName]
  if (skillDesc) {
    // 找到最接近的等级描述
    const levels = Object.keys(skillDesc).map(Number).sort((a, b) => b - a)
    for (const l of levels) {
      if (level >= l) {
        return skillDesc[l]
      }
    }
  }
  
  return '在该技能领域表现良好，具备相应的专业能力。'
}

// 按技能等级排序
const sortedSkills = computed(() => {
  return [...teacherSkills.value].sort((a, b) => b.level - a.level)
})

// 获取最强技能
const getTopSkill = () => {
  return teacherSkills.value.reduce((max, skill) => skill.level > max.level ? skill : max, teacherSkills.value[0])
}

// 雷达图Canvas引用
const radarCanvas = ref(null)

// 测试Canvas基本功能
const testCanvas = () => {
  if (!radarCanvas.value) {
    console.log('Canvas不存在，无法测试')
    return
  }
  
  const canvas = radarCanvas.value
  const ctx = canvas.getContext('2d')
  
  // 绘制简单的测试图形
  ctx.fillStyle = 'red'
  ctx.fillRect(50, 50, 100, 100)
  
  ctx.fillStyle = 'blue'
  ctx.beginPath()
  ctx.arc(200, 200, 50, 0, 2 * Math.PI)
  ctx.fill()
  
  console.log('Canvas测试绘制完成')
}

// 绘制雷达图 - 简化版本
const drawRadarChart = () => {
  if (!radarCanvas.value) {
    console.log('雷达图Canvas不存在')
    return
  }
  
  console.log('开始绘制雷达图，技能数据:', teacherSkills.value)
  
  // 先测试Canvas基本功能
  testCanvas()
  
  const canvas = radarCanvas.value
  const ctx = canvas.getContext('2d')
  
  // 使用固定尺寸，不处理DPI
  canvas.width = 500
  canvas.height = 500
  
  const centerX = 250
  const centerY = 250
  const radius = 150
  
  // 清空画布
  ctx.clearRect(0, 0, canvas.width, canvas.height)
  
  const skills = teacherSkills.value
  const numSkills = skills.length
  const angleStep = (2 * Math.PI) / numSkills
  
  console.log('技能数据:', skills)
  console.log('技能数量:', numSkills)
  
  // 绘制背景网格（5层同心多边形）
  ctx.strokeStyle = '#e5e7eb'
  ctx.lineWidth = 1
  
  for (let i = 1; i <= 5; i++) {
    const currentRadius = (radius / 5) * i
    ctx.beginPath()
    
    for (let j = 0; j < numSkills; j++) {
      const angle = j * angleStep - Math.PI / 2
      const x = centerX + Math.cos(angle) * currentRadius
      const y = centerY + Math.sin(angle) * currentRadius
      
      if (j === 0) {
        ctx.moveTo(x, y)
      } else {
        ctx.lineTo(x, y)
      }
    }
    
    ctx.closePath()
    ctx.stroke()
  }
  
  // 绘制轴线
  ctx.strokeStyle = '#d1d5db'
  ctx.lineWidth = 1
  
  for (let i = 0; i < numSkills; i++) {
    const angle = i * angleStep - Math.PI / 2
    const x = centerX + Math.cos(angle) * radius
    const y = centerY + Math.sin(angle) * radius
    
    ctx.beginPath()
    ctx.moveTo(centerX, centerY)
    ctx.lineTo(x, y)
    ctx.stroke()
  }
  
  // 绘制技能标签
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  ctx.font = 'bold 14px Arial, sans-serif'
  
  for (let i = 0; i < numSkills; i++) {
    const angle = i * angleStep - Math.PI / 2
    const labelRadius = radius + 30
    const x = centerX + Math.cos(angle) * labelRadius
    const y = centerY + Math.sin(angle) * labelRadius
    
    // 绘制技能名称
    ctx.fillStyle = skills[i].color
    ctx.fillText(skills[i].name, x, y)
  }
  
  // 计算数据点
  const dataPoints = []
  for (let i = 0; i < numSkills; i++) {
    const angle = i * angleStep - Math.PI / 2
    const dataRadius = (radius * skills[i].level) / 100
    const x = centerX + Math.cos(angle) * dataRadius
    const y = centerY + Math.sin(angle) * dataRadius
    dataPoints.push({ x, y, skill: skills[i] })
  }
  
  console.log('数据点:', dataPoints)
  
  // 填充数据区域
  if (dataPoints.length > 0) {
    ctx.fillStyle = 'rgba(59, 130, 246, 0.3)'
    ctx.beginPath()
    dataPoints.forEach((point, index) => {
      if (index === 0) {
        ctx.moveTo(point.x, point.y)
      } else {
        ctx.lineTo(point.x, point.y)
      }
    })
    ctx.closePath()
    ctx.fill()
    
    // 绘制数据线条
    ctx.strokeStyle = '#3b82f6'
    ctx.lineWidth = 2
    ctx.beginPath()
    dataPoints.forEach((point, index) => {
      if (index === 0) {
        ctx.moveTo(point.x, point.y)
      } else {
        ctx.lineTo(point.x, point.y)
      }
    })
    ctx.closePath()
    ctx.stroke()
    
    // 绘制数据点
    dataPoints.forEach((point, index) => {
      ctx.fillStyle = '#ffffff'
      ctx.strokeStyle = skills[index].color
      ctx.lineWidth = 2
      ctx.beginPath()
      ctx.arc(point.x, point.y, 6, 0, 2 * Math.PI)
      ctx.fill()
      ctx.stroke()
    })
  }
  
  // 绘制中心分数
  ctx.fillStyle = '#3b82f6'
  ctx.font = 'bold 18px Arial, sans-serif'
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  const avgScore = Math.round(skills.reduce((sum, skill) => sum + skill.level, 0) / skills.length)
  ctx.fillText(avgScore + '%', centerX, centerY - 5)
  
  ctx.fillStyle = '#6b7280'
  ctx.font = '12px Arial, sans-serif'
  ctx.fillText('综合评分', centerX, centerY + 15)
  
  console.log('雷达图绘制完成!')
}

// 初始化雷达图
const initRadarChart = () => {
  console.log('准备初始化雷达图')
  // 立即尝试绘制一次
  drawRadarChart()
  
  // 延迟再绘制一次，确保DOM已加载
  setTimeout(() => {
    console.log('延迟后再次绘制雷达图')
    drawRadarChart()
  }, 500)
  
  // 再延迟绘制一次，确保所有资源已加载
  setTimeout(() => {
    console.log('最终确保绘制雷达图')
    drawRadarChart()
  }, 1000)
}


// 勋章3D预览逻辑
const medalDialog = ref({ visible: false, medal: null })
const tilt = ref({ x: 0, y: 0 })
const medalTransform = computed(() => `translateX(25px) rotateX(${tilt.value.y}deg) rotateY(${tilt.value.x}deg)`)
const openMedal = (m) => { medalDialog.value = { visible: true, medal: m } }
const onMedalMove = (e) => {
  const rect = e.currentTarget.getBoundingClientRect()
  const px = (e.clientX - rect.left) / rect.width
  const py = (e.clientY - rect.top) / rect.height
  tilt.value = { x: (px - 0.5) * 20, y: -(py - 0.5) * 20 }
}
const onMedalLeave = () => { tilt.value = { x: 0, y: 0 } }
const onMedalTouch = (e) => {
  if (!e.touches?.length) return
  const t = e.touches[0]
  const rect = e.currentTarget.getBoundingClientRect()
  const px = (t.clientX - rect.left) / rect.width
  const py = (t.clientY - rect.top) / rect.height
  tilt.value = { x: (px - 0.5) * 20, y: -(py - 0.5) * 20 }
}
</script>

<style scoped>
.teacher-profile { padding: 16px; }
.header { display: flex; align-items: stretch; gap: 20px; margin-bottom: 16px; background: #fff; border: 1px solid #eee; border-radius: 12px; padding: 20px; min-height: 180px; }

/* 左侧区域 - 头像和基本信息 */
.header-left { display: flex; align-items: center; gap: 20px; flex: 1; min-width: 0; }
.avatar { width: 140px; height: 140px; border-radius: 50%; background: #e5e7eb; overflow: visible; display: flex; align-items: center; justify-content: center; cursor: pointer; flex: 0 0 140px; position: relative; }
.avatar img { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; }
.avatar-initial { font-size: 28px; color: #666; }

/* 性别符号徽章样式 */
.gender-badge {
  position: absolute;
  bottom: 8px;
  right: 8px;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
}

.gender-icon {
  font-size: 18px;
  font-weight: bold;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  border-radius: 50%;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.gender-icon.male {
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  color: white;
}

.gender-icon.female {
  background: linear-gradient(135deg, #ec4899 0%, #be185d 100%);
  color: white;
}

.gender-icon.unknown {
  background: linear-gradient(135deg, #64748b 0%, #475569 100%);
  color: white;
}
.info { flex: 1; min-width: 0; }
.name-line { display: flex; align-items: center; gap: 8px; }
.meta { color: #666; margin-top: 4px; }
.actions { margin-top: 8px; }

/* 右侧区域 - 统计卡片 */
.header-right { flex: 0 0 auto; display: flex; align-items: center; }
.stats-cards { display: flex; gap: 12px; min-width: 480px; }
.stat-card { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px; text-align: center; transition: all 0.2s ease; flex: 1;flex-direction: column; min-width: 110px; position: relative; }
.stat-card:hover { background: #f1f5f9; transform: translateY(-1px); box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
.stat-card .value { font-size: 18px; font-weight: 700; color: #1e293b; margin-bottom: 0px; }
.stat-card .label { color: #64748b; font-size: 11px; line-height: 1.3; }
.help-btn { position: absolute; top: 8px; right: 8px; width: 20px; height: 20px; background: transparent; border: 1px solid #cbd5e1; border-radius: 50%; display: flex; align-items: center; justify-content: center; cursor: pointer; opacity: 0.6; transition: all 0.2s ease; z-index: 10; }
.help-btn:hover { opacity: 1; background: rgba(59, 130, 246, 0.1); border-color: #3b82f6; transform: scale(1.1); }
.help-icon { color: #64748b; font-size: 12px; font-weight: bold; }
.help-btn:hover .help-icon { color: #3b82f6; }

/* 标签页导航样式 */
.tab-navigation {
  background: #fff;
  border: 1px solid #eee;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 16px;
}

.tab-buttons {
  display: flex;
  gap: 8px;
  justify-content: center;
}

.tab-button {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  background: #f8fafc;
  color: #64748b;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  min-width: 120px;
  justify-content: center;
}

.tab-button:hover {
  background: #f1f5f9;
  border-color: #cbd5e1;
  color: #475569;
  transform: translateY(-1px);
}

.tab-button.active {
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  border-color: #3b82f6;
  color: white;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

.tab-button.active:hover {
  background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(59, 130, 246, 0.4);
}

.tab-icon {
  font-size: 16px;
}

.tab-label {
  font-weight: 600;
}

.tab-content {
  animation: fadeIn 0.3s ease-in-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

/* 通用样式 */
.ml8 { margin-left: 8px; }
.mt12 { margin-top: 12px; }
.hidden { display: none; }
.shortcuts { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 16px; }
.module { background: #fff; border: 1px solid #eee; border-radius: 8px; padding: 12px; margin-bottom: 16px; }
.module h3 { margin: 0 0 10px; }
.filters { display: flex; align-items: center; margin-bottom: 8px; }
.grid-3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
.panel { background: #fafafa; border: 1px solid #eee; border-radius: 8px; padding: 12px; }
.panel-title { font-weight: 600; margin-bottom: 6px; }
.chart-container { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 16px; }
.chart-item { background: #fafafa; border: 1px solid #eee; border-radius: 8px; padding: 16px; }

/* 勋章墙样式 */
.medal-wall { 
  display: grid; 
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); 
  gap: 12px; 
  align-items: start; 
}
.medal-item { 
  position: relative; 
  background: #f8fafc; 
  border-radius: 10px; 
  padding: 10px; 
  text-align: center; 
  cursor: pointer;
  transition: transform 0.2s ease;
}
.medal-item:hover {
  transform: translateY(-2px);
}
.medal-item:hover img {
  transform: translateX(12px) translateY(-2px);
}
.medal-item img { 
  width: 120px; 
  height: 120px; 
  object-fit: contain; 
  display: block; 
  margin: 0 auto; 
  transform: translateX(12px);
}
.medal-name { margin-top: 6px; font-weight: 600; }
.medal-tip { position: absolute; top: 8px; right: 8px; font-size: 12px; color: #999; }
.medal-item.locked img { filter: grayscale(0.9) contrast(0.9); opacity: 0.7; }

.medal-dialog :deep(.el-dialog__header) { border-bottom: none; }
.medal-dialog :deep(.el-dialog__body) { padding: 0; }
.medal-dialog-content { 
  text-align: center; 
  display: flex; 
  flex-direction: column; 
  align-items: center; 
  width: 100%; 
}
.medal-stage { 
  perspective: 900px; 
  padding: 20px 0; 
  width: 100%; 
  display: flex; 
  justify-content: center; 
  align-items: center; 
}
.medal-card { 
  width: 300px; 
  height: 300px; 
  display: flex; 
  justify-content: center; 
  align-items: center; 
  transform-style: preserve-3d; 
  transition: transform .2s ease; 
  position: relative; 
}
.medal-large { 
  width: 260px; 
  height: 260px; 
  object-fit: contain; 
  filter: drop-shadow(0 12px 24px rgba(0,0,0,.25)); 
  display: block; 
}
.medal-shine { position: absolute; inset: 0; background: radial-gradient(120px 80px at 20% 10%, rgba(255,255,255,.25), transparent 60%), linear-gradient(120deg, rgba(255,255,255,.06), transparent 40%); mix-blend-mode: screen; pointer-events: none; }
.medal-meta { 
  text-align: center; 
  margin-top: 6px; 
  padding: 0 20px; 
  width: 100%; 
  max-width: 300px; 
}
.medal-title { font-weight: 700; }
.medal-desc { color: #666; font-size: 13px; margin-top: 4px; }
.medal-state { margin-top: 6px; font-weight: 600; color: #999; }
.medal-state.unlocked { color: #22c55e; }

/* 打卡墙样式 */
.calendar-grid {
  display: grid;
  /* 竖排：一列显示周一到周日，从上到下，再从左到右按周推进 */
  grid-auto-flow: column;
  grid-template-rows: repeat(7, 12px);
  grid-auto-columns: 12px;
  gap: 3px;
  width: 1000px;
  padding: 8px;
  background: #f8fafc;
  border-radius: 8px;
  /* 去除右侧大空白：让容器按内容宽度收缩并靠左 */
  width: max-content;
  /* 居中显示 */
  margin: 0 auto;
}
.calendar-grid .cell { width: 12px; height: 12px; border-radius: 2px; }

.chart-legend.center { text-align: center; }

/* 积分排行榜样式 - 参考图片设计 */
.ranking-showcase {
  background: #ffffff;
  
  border-radius: 20px;
  padding: 30px;
  position: relative;
  overflow: hidden;
}

.ranking-showcase::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -30%;
  width: 200%;
  height: 200%;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><path d="M20,20 Q30,10 40,20 Q50,30 60,20 Q70,10 80,20" stroke="rgba(255,255,255,0.1)" stroke-width="2" fill="none"/></svg>') repeat;
  opacity: 0.3;
  animation: float 6s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-10px) rotate(2deg); }
}

.ranking-cards {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  margin-bottom: 30px;
  position: relative;
  z-index: 2;
  min-height: 300px;
}

.ranking-card {
  background: white;
  border-radius: 16px;
  padding: 20px;
  text-align: center;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  position: relative;
  min-width: 200px;
  max-width: 220px;
}

.ranking-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.15);
}

.ranking-card.rank-1 {
  transform: scale(1.1);
  z-index: 3;
  background: linear-gradient(135deg, #fff 0%, #f8f9fa 100%);
  border: 3px solid #ffd700;
  order: 2; /* 第一名在中间 */
}

.ranking-card.rank-1:hover {
  transform: scale(1.1) translateY(-8px);
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.15);
}

.ranking-card.rank-2 {
  transform: scale(1.05);
  z-index: 2;
  background: linear-gradient(135deg, #fff 0%, #f8f9fa 100%);
  border: 2px solid #c0c0c0;
  order: 1; /* 第二名在左边 */
}

.ranking-card.rank-2:hover {
  transform: scale(1.05) translateY(-8px);
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.15);
}

.ranking-card.rank-3 {
  background: linear-gradient(135deg, #fff 0%, #f8f9fa 100%);
  border: 2px solid #cd7f32;
  order: 3; /* 第三名在右边 */
}

.medal-container {
  margin-bottom: 15px;
}

.medal {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
  position: relative;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.medal-1 {
  background: linear-gradient(135deg, #ffd700 0%, #ffed4e 100%);
  border: 3px solid #ffd700;
}

.medal-2 {
  background: linear-gradient(135deg, #c0c0c0 0%, #e8e8e8 100%);
  border: 3px solid #c0c0c0;
}

.medal-3 {
  background: linear-gradient(135deg, #cd7f32 0%, #daa520 100%);
  border: 3px solid #cd7f32;
}

.medal-number {
  font-size: 24px;
  font-weight: 700;
  color: white;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.avatar-container {
  margin-bottom: 15px;
}

.teacher-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  margin: 0 auto;
  overflow: hidden;
  border: 4px solid rgba(255, 255, 255, 0.8);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.teacher-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  font-weight: 700;
  color: white;
}

.avatar-placeholder.empty-avatar {
  background: linear-gradient(135deg, #e5e7eb 0%, #d1d5db 100%);
  color: #9ca3af;
  font-size: 24px;
}

.teacher-info {
  margin-bottom: 15px;
}

.teacher-name {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin-bottom: 5px;
}

.teacher-school {
  font-size: 12px;
  color: #666;
  opacity: 0.8;
}

.points-section {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8e8e 100%);
  border-radius: 20px;
  padding: 8px 16px;
  color: white;
}

.points-icon {
  font-size: 16px;
}

.points-value {
  font-size: 18px;
  font-weight: 700;
}

.crown-decoration {
  position: absolute;
  top: -10px;
  right: -10px;
  font-size: 24px;
  animation: sparkle 2s ease-in-out infinite;
}

@keyframes sparkle {
  0%, 100% { transform: scale(1) rotate(0deg); }
  50% { transform: scale(1.2) rotate(180deg); }
}

/* 教师信息展示样式 */
.teacher-info-section {
  margin-bottom: 24px;
}

.teacher-info-section h3 {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 16px;
  padding-bottom: 8px;
  border-bottom: 2px solid #e5e7eb;
}


/* 专业能力样式 */
.teacher-skills-section h3 {
  color: #1f2937;
  margin-bottom: 24px;
}

.skills-showcase {
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  border: 1px solid #e5e7eb;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 32px;
  align-items: center;
}

.radar-chart {
  width: 100%;
  height: 400px;
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 15px;
  box-sizing: border-box;
}

.skills-details {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.skill-item {
  background: #f9fafb;
  border-radius: 12px;
  padding: 16px;
  border: 1px solid #e5e7eb;
}

.skill-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
}

.skill-icon {
  font-size: 20px;
  margin-right: 8px;
}

.skill-name {
  font-weight: 600;
  color: #1f2937;
  flex: 1;
}

.skill-level {
  font-weight: 700;
  color: #3b82f6;
  font-size: 14px;
}

.skill-bar {
  height: 8px;
  background: #e5e7eb;
  border-radius: 4px;
  overflow: hidden;
}

.skill-progress {
  height: 100%;
  border-radius: 4px;
  transition: width 0.6s ease;
}

/* 教学历程样式 */
.teacher-journey-section h3 {
  color: #1f2937;
  margin-bottom: 24px;
}

.journey-timeline {
  background: #fff;
  border-radius: 16px;
  padding: 32px;
  border: 1px solid #e5e7eb;
  position: relative;
}

.timeline-track {
  position: absolute;
  left: 50%;
  top: 32px;
  bottom: 32px;
  width: 4px;
  background: linear-gradient(to bottom, #3b82f6, #8b5cf6);
  border-radius: 2px;
  transform: translateX(-50%);
}

.milestone-item {
  position: relative;
  margin-bottom: 32px;
  display: flex;
  align-items: center;
}

.milestone-item:last-child {
  margin-bottom: 0;
}

.milestone-left {
  justify-content: flex-end;
}

.milestone-left .milestone-content {
  text-align: right;
  margin-right: 24px;
}

.milestone-right {
  justify-content: flex-start;
}

.milestone-right .milestone-content {
  text-align: left;
  margin-left: 24px;
}

.milestone-dot {
  position: absolute;
  left: 50%;
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transform: translateX(-50%);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 2;
}

.milestone-icon {
  font-size: 20px;
  color: white;
}

.milestone-content {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 16px;
  width: calc(50% - 32px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.milestone-year {
  font-size: 18px;
  font-weight: 700;
  color: #3b82f6;
  margin-bottom: 4px;
}

.milestone-title {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 6px;
}

.milestone-desc {
  font-size: 14px;
  color: #6b7280;
  line-height: 1.4;
}

/* 学生评价样式 */
.student-reviews-section h3 {
  color: #1f2937;
  margin-bottom: 24px;
}

.reviews-wall {
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  border: 1px solid #e5e7eb;
}

.reviews-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.review-card {
  background: var(--card-color, #f8fafc);
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  padding: 20px;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.review-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #3b82f6, #8b5cf6);
}

.review-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px rgba(0, 0, 0, 0.1);
}

.review-header {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
}

.student-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, #3b82f6, #8b5cf6);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  margin-right: 12px;
}

.student-info {
  flex: 1;
}

.student-name {
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 2px;
}

.review-date {
  font-size: 12px;
  color: #6b7280;
}

.review-rating {
  display: flex;
  gap: 2px;
}

.star {
  font-size: 16px;
  filter: grayscale(100%);
}

.star.filled {
  filter: grayscale(0%);
}

.review-content {
  font-size: 14px;
  color: #374151;
  line-height: 1.6;
  margin-bottom: 12px;
  font-style: italic;
}

.review-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.review-tag {
  background: rgba(59, 130, 246, 0.1);
  color: #3b82f6;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

/* 荣誉展示样式 */
.honors-section h3 {
  color: #1f2937;
  margin-bottom: 24px;
}

.honors-showcase {
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  border: 1px solid #e5e7eb;
}

.honors-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
}

.honor-item {
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  padding: 20px;
  text-align: center;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.honor-item::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: conic-gradient(from 0deg, transparent, rgba(255, 215, 0, 0.1), transparent);
  animation: rotate 4s linear infinite;
}

@keyframes rotate {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.honor-item:hover {
  transform: translateY(-8px);
  box-shadow: 0 16px 32px rgba(0, 0, 0, 0.15);
}

.honor-medal {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
  position: relative;
  z-index: 2;
}

.honor-icon {
  font-size: 32px;
  color: white;
}

.honor-info {
  position: relative;
  z-index: 2;
}

.honor-title {
  font-size: 16px;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 4px;
}

.honor-year {
  font-size: 14px;
  color: #6b7280;
  margin-bottom: 4px;
}

.honor-level {
  font-size: 12px;
  color: #3b82f6;
  font-weight: 600;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .skills-showcase {
    grid-template-columns: 1fr;
    gap: 24px;
  }
  
  .timeline-track {
    left: 24px;
  }
  
  .milestone-item {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .milestone-left,
  .milestone-right {
    justify-content: flex-start;
  }
  
  .milestone-left .milestone-content,
  .milestone-right .milestone-content {
    text-align: left;
    margin: 16px 0 0 48px;
    width: calc(100% - 64px);
  }
  
  .milestone-dot {
    left: 24px;
    transform: translateX(-50%);
  }
  
  .reviews-grid {
    grid-template-columns: 1fr;
  }
  
  .honors-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 480px) {
  .honors-grid {
    grid-template-columns: 1fr;
  }
}

/* 个人档案卡 */
.teacher-profile-card {
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  padding: 24px;
  display: flex;
  gap: 24px;
  align-items: flex-start;
}

.profile-left {
  display: flex;
  align-items: center;
  gap: 20px;
  flex-shrink: 0;
}

.large-avatar {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  background: #e5e7eb;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.large-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.large-avatar .avatar-placeholder {
  font-size: 36px;
  font-weight: 600;
  color: #6b7280;
}

.profile-basic {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.teacher-name {
  font-size: 24px;
  font-weight: 700;
  color: #1f2937;
}

.teacher-title {
  font-size: 16px;
  color: #3b82f6;
  font-weight: 500;
}

.teacher-school {
  font-size: 14px;
  color: #6b7280;
}

.profile-right {
  flex: 1;
  min-width: 0;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

.info-item {
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 16px;
  transition: all 0.2s ease;
}

.info-item:hover {
  border-color: #3b82f6;
  box-shadow: 0 2px 8px rgba(59, 130, 246, 0.1);
}

.info-label {
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 6px;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.info-value {
  font-size: 16px;
  color: #1f2937;
  font-weight: 600;
}

/* 教学成就概览 */
.achievement-overview {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  border: 1px solid #e5e7eb;
}

.achievement-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

.stat-card {
  background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
  border: 1px solid #3b82f6;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(59, 130, 246, 0.15);
}

.stat-icon {
  font-size: 32px;
  width: 48px;
  height: 48px;
  background: #3b82f6;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.stat-content {
  flex: 1;
}

.stat-number {
  font-size: 24px;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 2px;
}

.stat-label {
  font-size: 12px;
  color: #6b7280;
  font-weight: 500;
}

/* 教学风格 */
.teaching-style {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  border: 1px solid #e5e7eb;
}

.style-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 20px;
}

.style-tag {
  font-size: 14px;
  padding: 8px 16px !important;
  border-radius: 20px !important;
}

.teaching-motto {
  background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
  border: 1px solid #f59e0b;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.motto-icon {
  font-size: 24px;
  color: #f59e0b;
  flex-shrink: 0;
}

.motto-content {
  flex: 1;
}

.motto-title {
  font-size: 16px;
  font-weight: 600;
  color: #92400e;
  margin-bottom: 8px;
}

.motto-text {
  font-size: 14px;
  color: #78350f;
  line-height: 1.6;
  font-style: italic;
}

/* 课程安排 */
.course-schedule {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  border: 1px solid #e5e7eb;
}

.schedule-timeline {
  position: relative;
}

.schedule-timeline::before {
  content: '';
  position: absolute;
  left: 16px;
  top: 16px;
  bottom: 16px;
  width: 2px;
  background: #e5e7eb;
}

.timeline-item {
  position: relative;
  padding-left: 48px;
  margin-bottom: 16px;
}

.timeline-item:last-child {
  margin-bottom: 0;
}

.timeline-dot {
  position: absolute;
  left: 8px;
  top: 8px;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: #3b82f6;
  border: 3px solid #fff;
  box-shadow: 0 0 0 2px #e5e7eb;
  z-index: 1;
}

.timeline-content {
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 16px;
  transition: all 0.2s ease;
}

.timeline-content:hover {
  background: #f3f4f6;
  border-color: #d1d5db;
}

.course-time {
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 4px;
  font-weight: 500;
}

.course-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.course-name {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
}

.course-details {
  font-size: 12px;
  color: #6b7280;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .teacher-profile-card {
    flex-direction: column;
    gap: 16px;
  }
  
  .profile-left {
    justify-content: center;
    text-align: center;
  }
  
  .info-grid {
    grid-template-columns: 1fr;
  }
  
  .achievement-stats {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .style-tags {
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .achievement-stats {
    grid-template-columns: 1fr;
  }
}


@media (max-width: 768px) {
  .chart-container { grid-template-columns: 1fr; gap: 16px; }
  .chart-item { height: 250px; }
  
  /* Header 响应式调整 */
  .header { 
    flex-direction: column; 
    align-items: stretch; 
    gap: 16px; 
    min-height: auto; 
    padding: 16px; 
  }
  .header-left { 
    flex-direction: column; 
    align-items: center; 
    text-align: center; 
    gap: 16px; 
  }
  .avatar { 
    width: 100px; 
    height: 100px; 
    flex: 0 0 100px; 
  }
  .avatar-initial { font-size: 24px; }
  .info { text-align: center; }
  .actions { 
    display: flex; 
    gap: 8px; 
    justify-content: center; 
  }
  
  /* 标签页移动端适配 */
  .tab-navigation { 
    padding: 12px; 
  }
  .tab-buttons { 
    flex-direction: column; 
    gap: 8px; 
  }
  .tab-button { 
    min-width: 100%; 
    padding: 10px 16px; 
  }
  
  /* 统计卡片移动端调整 */
  .header-right { align-items: stretch; }
  .stats-cards { 
    display: grid;
    grid-template-columns: repeat(2, 1fr); 
    gap: 8px; 
    min-width: 100%; 
  }
  .stat-card { 
    padding: 12px; 
    min-width: auto;
  }
  .stat-card .value { font-size: 16px; }
  .stat-card .label { font-size: 10px; }
  
  /* 排行榜移动端适配 */
  .ranking-showcase { padding: 20px; }
  .ranking-cards { 
    flex-direction: column; 
    align-items: center; 
    gap: 15px; 
    min-height: auto;
  }
  .ranking-card { 
    min-width: 180px; 
    max-width: 200px; 
    order: unset !important; /* 移动端恢复默认顺序 */
  }
  .ranking-card.rank-1,
  .ranking-card.rank-2 {
    transform: none;
  }
  .ranking-card.rank-1:hover,
  .ranking-card.rank-2:hover {
    transform: translateY(-8px);
  }
  .teacher-avatar { width: 60px; height: 60px; }
  .medal { width: 50px; height: 50px; }
  .medal-number { font-size: 20px; }
  .teacher-name { font-size: 16px; }
  .points-value { font-size: 16px; }
}

@media (max-width: 1024px) {
  .header { 
    flex-direction: column; 
    align-items: stretch; 
    gap: 16px; 
  }
  .header-left { 
    justify-content: center; 
  }
  .stats-cards { 
    flex-wrap: wrap;
    min-width: 100%; 
  }
  .stat-card {
    min-width: 100px;
    flex: 1;
  }
}

@media (max-width: 1200px) {
  .stats-cards { 
    min-width: 400px; 
  }
  .stat-card { 
    padding: 12px; 
    min-width: 90px;
  }
  .stat-card .value { font-size: 16px; }
  .stat-card .label { font-size: 10px; }
}

/* 新的雷达图专业能力样式 */
.skills-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
  align-items: start;
}

.radar-section {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  display: flex;
  justify-content: center;
  align-items: center;
}

.radar-container {
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
}

.radar-canvas {
  display: block;
  width: 100%;
  height: 500px;
  max-width: 500px;
}

.skills-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.skill-item {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 16px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  transition: all 0.2s ease;
}

.skill-item:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.skill-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.skill-icon-circle {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid;
  flex-shrink: 0;
}

.skill-icon-circle .skill-icon {
  font-size: 18px;
}

.skill-info {
  flex: 1;
}

.skill-info .skill-name {
  font-weight: 600;
  color: #1f2937;
  font-size: 14px;
  margin-bottom: 2px;
}

.skill-info .skill-level {
  font-size: 12px;
  color: #6b7280;
  font-weight: 500;
}

.skill-score {
  font-weight: 700;
  font-size: 16px;
}

.skill-progress {
  margin-bottom: 8px;
}

.progress-track {
  height: 6px;
  background: #f3f4f6;
  border-radius: 3px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  border-radius: 3px;
  animation: progressFill 1.5s ease-out forwards;
  width: 0;
}

@keyframes progressFill {
  to {
    width: var(--progress-width);
  }
}

.skill-description {
  color: #4b5563;
  font-size: 12px;
  line-height: 1.4;
}

/* 技能详情卡片网格 */
.skill-details-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  margin-top: 24px;
}

.skill-detail-card {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 16px;
  transition: all 0.3s ease;
}

.skill-detail-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
}

.skill-card-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.skill-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  font-weight: bold;
}

.skill-info {
  flex: 1;
}

.skill-name {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 2px;
}

.skill-level {
  font-size: 14px;
  font-weight: 700;
  color: #3b82f6;
}

.skill-badge {
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 10px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.skill-badge.expert {
  background: #dbeafe;
  color: #1e40af;
}

.skill-badge.proficient {
  background: #d1fae5;
  color: #065f46;
}

.skill-badge.intermediate {
  background: #fef3c7;
  color: #92400e;
}

.skill-badge.beginner {
  background: #fee2e2;
  color: #991b1b;
}

.skill-progress-bar {
  width: 100%;
  height: 8px;
  background: #f3f4f6;
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 12px;
}

.skill-progress-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 1.5s ease;
  animation: skillProgress 2s ease-out;
}

@keyframes skillProgress {
  from {
    width: 0%;
  }
}

.skill-description {
  font-size: 12px;
  color: #6b7280;
  line-height: 1.5;
}

/* 技能统计概览 */
.skill-overview-section {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-top: 24px;
}

.overview-card {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 20px;
  text-align: center;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.overview-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, #3b82f6, #60a5fa);
}

.overview-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
}

.overview-card.total-score::before {
  background: linear-gradient(90deg, #3b82f6, #60a5fa);
}

.overview-card.highest-skill::before {
  background: linear-gradient(90deg, #f59e0b, #fbbf24);
}

.overview-card.mastery-count::before {
  background: linear-gradient(90deg, #10b981, #34d399);
}

.overview-card.growth-potential::before {
  background: linear-gradient(90deg, #ef4444, #f87171);
}

.overview-icon {
  font-size: 24px;
  margin-bottom: 8px;
}

.overview-value {
  font-size: 28px;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 4px;
}

.overview-label {
  font-size: 14px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 4px;
}

.overview-desc {
  font-size: 11px;
  color: #6b7280;
}

/* 技能等级说明 */
.skill-legend-section {
  margin-top: 32px;
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  padding: 24px;
}

.legend-title {
  margin: 0 0 20px 0;
  color: #1f2937;
  font-size: 18px;
  font-weight: 600;
  text-align: center;
}

.legend-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}

.legend-item {
  text-align: center;
  padding: 16px;
  border-radius: 12px;
  border: 2px solid transparent;
  transition: all 0.3s ease;
}

.legend-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.legend-item.expert {
  background: linear-gradient(135deg, #dbeafe, #eff6ff);
  border-color: #3b82f6;
}

.legend-item.proficient {
  background: linear-gradient(135deg, #d1fae5, #ecfdf5);
  border-color: #10b981;
}

.legend-item.intermediate {
  background: linear-gradient(135deg, #fef3c7, #fffbeb);
  border-color: #f59e0b;
}

.legend-item.beginner {
  background: linear-gradient(135deg, #fee2e2, #fef2f2);
  border-color: #ef4444;
}

.legend-badge {
  font-size: 16px;
  font-weight: 700;
  margin-bottom: 8px;
}

.legend-item.expert .legend-badge {
  color: #1e40af;
}

.legend-item.proficient .legend-badge {
  color: #065f46;
}

.legend-item.intermediate .legend-badge {
  color: #92400e;
}

.legend-item.beginner .legend-badge {
  color: #991b1b;
}

.legend-range {
  font-size: 12px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 8px;
}

.legend-desc {
  font-size: 11px;
  color: #6b7280;
  line-height: 1.4;
}

/* 响应式设计 */
@media (max-width: 1024px) {
  .skill-details-grid {
    grid-template-columns: 1fr;
  }
  
  .skill-overview-section {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .legend-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .skill-overview-section {
    grid-template-columns: 1fr;
  }
  
  .legend-grid {
    grid-template-columns: 1fr;
  }
}
</style>


