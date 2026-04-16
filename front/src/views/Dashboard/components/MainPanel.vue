<template>
  <div class="main-panel">
    <!-- 欢迎横幅 -->
    <div class="welcome-banner">
      <div class="banner-content">
        <div class="welcome-text">
          <h1><img src="@/assets/icon/哈士奇.png" alt="哈士奇" class="welcome-icon"> 欢迎回来，张老师！</h1>
          <p>今天也要为教育事业发光发热哦～</p>
        </div>
        <div class="banner-stats">
          <div class="stat-item">
            <div class="stat-number">{{ stats.courseCount }}</div>
            <div class="stat-label">开课数</div>
          </div>
          <div class="stat-item">
            <div class="stat-number">{{ stats.resourceCount }}</div>
            <div class="stat-label">资源数</div>
          </div>
          <div class="stat-item">
            <div class="stat-number">{{ stats.homeworkCount }}</div>
            <div class="stat-label">作业数</div>
          </div>
          <div class="stat-item">
            <div class="stat-number">{{ stats.examCount }}</div>
            <div class="stat-label">考试数</div>
          </div>
          <div class="stat-item">
            <div class="stat-number">{{ stats.starCount }}</div>
            <div class="stat-label">星星数</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="content-area">
      <!-- 左侧内容 -->
      <div class="left-content">
        <!-- AI 推荐语 -->
        <div class="ai-card">
          <div class="ai-header">
            <div class="ai-header-left">
              <div class="ai-icon"><img src="@/assets/icon/荷兰猪.png" alt="荷兰猪" class="ai-icon-img"></div>
              <h3>AI 教学助手</h3>
            </div>
            <el-button type="primary" class="regenerate-btn" @click="regenerate">
              <el-icon><Refresh /></el-icon>
              重新生成
            </el-button>
          </div>
          <div class="ai-content">
            <p class="ai-text">
              衷心感谢老师们无私的奉献和辛勤的付出，您们的教诲如同明灯，照亮我们前行的道路。
            </p>
          </div>
        </div>

        <!-- 课程卡片 -->
        <div class="courses-section">
          <div class="section-header">
            <h2><img src="@/assets/icon/仓鼠.png" alt="仓鼠" class="section-icon"> 您所教授的课程</h2>
            <p>点击课程卡片开始智能教学设计</p>
          </div>
          <el-row :gutter="20" class="course-grid">
            <el-col
              v-for="(course, index) in courses"
              :key="index"
              :xs="24"
              :sm="12"
              :md="8"
              :lg="6"
            >
              <CourseCard
                :id="course.id"
                :title="course.title"
                :subtitle="course.subtitle"
                :image="course.image"
                @design="goToDesign"
              />
            </el-col>
          </el-row>
        </div>
      </div>

      <!-- 右侧装饰和统计 -->
      <div class="right-sidebar">
        <!-- 快速操作 -->
        <div class="quick-actions">
          <h3><el-icon class="section-icon"><Lightning /></el-icon> 快速操作</h3>
          <div class="action-buttons">
            <el-button class="action-btn" @click="goToCreate">
              <el-icon><Plus /></el-icon>
              创建课程
            </el-button>
            <el-button class="action-btn" @click="goToResources">
              <el-icon><Folder /></el-icon>
              资源管理
            </el-button>
            <el-button class="action-btn" @click="goToStudents">
              <el-icon><User /></el-icon>
              学生管理
            </el-button>
          </div>
        </div>

        <!-- 教学统计 -->
        <div class="teaching-stats">
          <h3><el-icon class="section-icon"><DataAnalysis /></el-icon> 教学统计</h3>
          <div class="stats-grid">
            <div class="stat-card">
              <div class="stat-icon"><el-icon><TrendCharts /></el-icon></div>
              <div class="stat-info">
                <div class="stat-value">85%</div>
                <div class="stat-desc">学生参与度</div>
              </div>
            </div>
            <div class="stat-card">
              <div class="stat-icon"><el-icon><Star /></el-icon></div>
              <div class="stat-info">
                <div class="stat-value">4.8</div>
                <div class="stat-desc">课程评分</div>
              </div>
            </div>
            <div class="stat-card">
              <div class="stat-icon"><el-icon><Aim /></el-icon></div>
              <div class="stat-info">
                <div class="stat-value">92%</div>
                <div class="stat-desc">任务完成率</div>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { Refresh, Plus, Folder, User, Lightning, DataAnalysis, TrendCharts, Star, Aim } from '@element-plus/icons-vue'
import CourseCard from './CourseCard.vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const teacherId = 2
const courses = ref([])

// 统计数据
const stats = ref({
  courseCount: 0,
  resourceCount: 0,
  homeworkCount: 0,
  examCount: 0,
  starCount: 0
})

function goToDesign(course) {
  router.push({
    name: 'DesignTools',
    query: {
      courseId: course.id,
      title: course.title,
      subtitle: course.subtitle,
      image: course.image
    }
  })
}

function goToCreate() {
  router.push('/teacher_school/create')
}

function goToResources() {
  router.push('/teacher_school/resourcedashboard')
}

function goToStudents() {
  router.push('/teacher_school/manager')
}

async function loadCourses() {
  try {
    const res = await axios.get(`/api/xiaozhi/teacher/by-teacher`, {
      params: { teacherId }
    })
    courses.value = res.data.map(item => ({
      id: item.id,
      title: item.courseName,
      subtitle: item.description || item.teachingGoal || '暂无简介',
      image: item.courseImage?.replace(/[\r\n]/g, '').trim(),
      teachingGoal: item.teachingGoal,
      teachingPrinciple: item.teachingPrinciple
    }))
    console.log('课程数据', courses.value)
    
    // 课程数据加载完成后，更新开课数
    stats.value.courseCount = courses.value.length
  } catch (err) {
    ElMessage.error('获取课程失败')
    console.error(err)
  }
}

// 获取统计数据 - 使用现有数据源
async function loadStats() {
  try {
    // 并行获取其他统计数据
    const [resourcesRes, homeworksRes, examsRes] = await Promise.all([
      // 获取资源数
      axios.get('/api/xiaozhi/teacher/resources/by-teacher', { params: { teacherId } }),
      // 获取作业数
      axios.get('/api/xiaozhi/teacher/assignments/by-teacher', { params: { teacherId } }),
      // 获取考试数
      axios.get('/api/xiaozhi/teacher/exams/overview', { params: { teacherId } })
    ])

    // 调试信息
    console.log('资源API响应:', resourcesRes.data)
    console.log('作业API响应:', homeworksRes.data)
    console.log('考试API响应:', examsRes.data)

    // 更新统计数据
    stats.value.resourceCount = resourcesRes.data?.data?.length || 0
    stats.value.homeworkCount = homeworksRes.data?.data?.length || 0
    stats.value.examCount = examsRes.data?.data?.length || 0
    
    // 计算星星数（前四个数之和）
    stats.value.starCount = stats.value.courseCount + stats.value.resourceCount + stats.value.homeworkCount + stats.value.examCount

    console.log('统计数据加载完成:', stats.value)
  } catch (err) {
    console.error('获取统计数据失败:', err)
    // 如果API调用失败，至少显示课程数（已加载）
    stats.value.resourceCount = 0
    stats.value.homeworkCount = 0
    stats.value.examCount = 0
    stats.value.starCount = stats.value.courseCount
  }
}

onMounted(async () => {
  console.log('MainPanel component mounted')
  await loadCourses()  // 先加载课程数据
  loadStats()          // 再加载其他统计数据
})

function regenerate() {
  ElMessage.success('已生成新的推荐语')
}
</script>

<style scoped>
.main-panel {
  flex: 1;
  padding: 0;
  box-sizing: border-box;
  position: relative;
  z-index: 1;
}

/* 欢迎横幅 */
.welcome-banner {
  background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  margin: 1rem;
  padding: 1.5rem;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
}

.banner-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
}

.welcome-text h1 {
  color: #1e293b;
  font-size: 1.8rem;
  font-weight: 700;
  margin: 0 0 0.25rem 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.welcome-icon {
  width: 2rem;
  height: 2rem;
  object-fit: contain;
  vertical-align: middle;
}

.welcome-text p {
  color: #64748b;
  font-size: 0.9rem;
  margin: 0;
}

.banner-stats {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.stat-item {
  text-align: center;
  background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%);
  padding: 0.75rem 1rem;
  border-radius: 12px;
  border: 1px solid #cbd5e1;
  box-shadow: 0 2px 8px rgba(148, 163, 184, 0.08);
}

.stat-number {
  color: #1e293b;
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 0.125rem;
}

.stat-label {
  color: #64748b;
  font-size: 0.8rem;
  font-weight: 500;
}

/* 主要内容区域 */
.content-area {
  display: flex;
  gap: 1.5rem;
  padding: 0 1rem 1rem;
}

.left-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.right-sidebar {
  width: 320px;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

/* AI 卡片 */
.ai-card {
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 20px;
  padding: 1.5rem;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
}

.ai-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 1rem;
}

.ai-header-left {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.ai-icon {
  font-size: 2rem;
}

.ai-icon-img {
  width: 2rem;
  height: 2rem;
  object-fit: contain;
  vertical-align: middle;
}

.section-icon {
  width: 1.8rem;
  height: 1.8rem;
  margin-right: 0.5rem;
  vertical-align: middle;
  color: #3b82f6;
}

.ai-header h3 {
  color: #1e293b;
  font-size: 1.3rem;
  font-weight: 600;
  margin: 0;
}

.ai-content {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.ai-text {
  color: #64748b;
  font-size: 1rem;
  line-height: 1.6;
  margin: 0;
}

.regenerate-btn {
  align-self: flex-start;
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  border: none;
  border-radius: 12px;
  padding: 0.75rem 1.5rem;
  font-weight: 500;
  box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
  transition: all 0.3s ease;
}

.regenerate-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
}

/* 课程区域 */
.courses-section {
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 20px;
  padding: 1.5rem;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
}

.section-header {
  margin-bottom: 1.5rem;
}

.section-header h2 {
  color: #1e293b;
  font-size: 1.5rem;
  font-weight: 600;
  margin: 0 0 0.5rem 0;
}

.section-header p {
  color: #64748b;
  font-size: 0.9rem;
  margin: 0;
}

.course-grid {
  margin: 0;
}

/* 右侧边栏 */
.quick-actions,
.teaching-stats,
.today-reminders {
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  padding: 1.5rem;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
}

.quick-actions h3,
.teaching-stats h3,
.today-reminders h3 {
  color: #1e293b;
  font-size: 1.1rem;
  font-weight: 600;
  margin: 0 0 1rem 0;
}

.action-buttons {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.action-btn {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  color: #475569;
  border-radius: 12px;
  padding: 0.75rem 1rem;
  font-weight: 500;
  transition: all 0.3s ease;
  justify-content: flex-start;
}

.action-btn:hover {
  background: #3b82f6;
  color: white;
  border-color: #3b82f6;
  transform: translateX(4px);
}

.stats-grid {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: #f8fafc;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
}

.stat-icon {
  font-size: 1.5rem;
  color: #3b82f6;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2rem;
  height: 2rem;
  background: rgba(59, 130, 246, 0.1);
  border-radius: 8px;
  margin-right: 0.75rem;
}

.stat-info {
  flex: 1;
}

.stat-value {
  color: #1e293b;
  font-size: 1.2rem;
  font-weight: 700;
  margin-bottom: 0.25rem;
}

.stat-desc {
  color: #64748b;
  font-size: 0.8rem;
}

.reminder-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.reminder-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem;
  background: #f8fafc;
  border-radius: 10px;
  border: 1px solid #e2e8f0;
}

.reminder-time {
  color: #3b82f6;
  font-weight: 600;
  font-size: 0.9rem;
  min-width: 50px;
}

.reminder-text {
  color: #475569;
  font-size: 0.9rem;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .content-area {
    flex-direction: column;
  }
  
  .right-sidebar {
    width: 100%;
    flex-direction: row;
    flex-wrap: wrap;
  }
  
  .quick-actions,
  .teaching-stats,
  .today-reminders {
    flex: 1;
    min-width: 280px;
  }
}

@media (max-width: 768px) {
  .welcome-banner {
    margin: 1rem;
    padding: 1.5rem;
  }
  
  .banner-content {
    flex-direction: column;
    text-align: center;
  }
  
  .welcome-text h1 {
    font-size: 2rem;
  }
  
  .banner-stats {
    justify-content: center;
  }
  
  .content-area {
    padding: 0 1rem 1rem;
  }
  
  .right-sidebar {
    flex-direction: column;
  }
}
</style>
