<template>
  <div class="student-manager">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <div class="header-left">
          <h1 class="page-title">
            <img src="@/assets/icon/可达鸭.png" alt="可达鸭" class="title-icon">
            学生管理
          </h1>
          <p class="page-subtitle">管理和查看您的学生信息</p>
        </div>
        <div class="header-right">
          <div class="stats-container">
            <div class="stat-item">
              <span class="stat-number">{{ filteredStudents.length }}</span>
              <span class="stat-label">学生总数</span>
            </div>
            <div class="stat-item">
              <span class="stat-number">{{ averageAccuracy }}%</span>
              <span class="stat-label">平均正确率</span>
            </div>
            <div class="stat-item">
              <span class="stat-number">{{ totalAssignments }}</span>
              <span class="stat-label">作业总数</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 搜索和筛选区域 -->
    <div class="search-section">
      <div class="search-bar">
        <div class="search-left">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索学生姓名、学号..."
            class="search-input"
            clearable
            @input="applyFilter"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>
        <div class="search-right">
          <el-select 
            v-model="selectedCourse" 
            placeholder="按课程筛选" 
            class="filter-select"
            clearable 
            @change="onCourseChange"
          >
            <el-option 
              v-for="course in courseOptions" 
              :key="course.id" 
              :label="course.name" 
              :value="course.name" 
            />
          </el-select>
          <el-button 
            type="info" 
            size="small" 
            @click="resetFilters"
            class="reset-btn"
          >
            <el-icon><Refresh /></el-icon>
            重置
          </el-button>
        </div>
        </div>
      </div>
      
    <!-- 学情分析面板 -->
    <div class="analytics-section" v-if="selectedCourse">
      <el-card shadow="hover" class="analytics-card">
        <div class="analytics-content">
          <div class="radar-chart-container">
          <RadarChart :radarData="aggregatedRadar" />
        </div>
          <div class="ai-summary">
            <div class="summary-title">课程学情分析</div>
          <div class="summary-text">
            {{ selectedCourse }} 课程共有 {{ filteredStudents.length }} 名学生，整体掌握情况较差。
            通过分析学生的练习记录和作业表现，发现学生在基础概念理解和实践应用方面存在明显不足。
            具体表现为：理论知识掌握不牢固，编程实践能力有待提升，部分学生在选择题和简答题中错误率较高。
            建议重点关注薄弱知识点的专项训练，加强基础知识的巩固，通过分层教学和个性化辅导来提升整体学习效果。
            同时建议增加课堂互动环节，及时了解学生学习困难，提供针对性的学习指导和练习建议。
          </div>
        </div>
      </div>
      </el-card>
    </div>

    <!-- 表格容器 -->
    <div class="table-container">
      <el-card shadow="hover" class="table-card">
        <el-table
          :data="sortedStudents"
          class="student-table"
          empty-text="暂无学生数据"
          :header-cell-style="{ background: '#f8f9fa', color: '#606266', fontWeight: '600' }"
        >
          <el-table-column label="学号" width="120" align="center">
            <template #default="{ row }">
              <span class="student-id">{{ row.id }}</span>
            </template>
          </el-table-column>
          
          <el-table-column prop="name" label="姓名" width="120" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="student-name">
                <el-icon class="name-icon"><User /></el-icon>
                {{ row.name }}
              </div>
            </template>
          </el-table-column>
          
          <el-table-column prop="school" label="学校" min-width="150" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="school-info">
                <el-icon class="school-icon"><OfficeBuilding /></el-icon>
                {{ row.school }}
              </div>
            </template>
          </el-table-column>
          
          <el-table-column prop="college" label="学院" min-width="150" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="college-info">
                <el-icon class="college-icon"><School /></el-icon>
                {{ row.college }}
              </div>
            </template>
          </el-table-column>
          
          <el-table-column prop="gender" label="性别" width="80" align="center">
            <template #default="{ row }">
              <el-tag :type="row.gender === '男' ? 'primary' : 'success'" size="small">
                {{ row.gender }}
              </el-tag>
            </template>
          </el-table-column>
          
          <el-table-column prop="className" label="班级" width="120" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="class-info">
                <el-icon class="class-icon"><Collection /></el-icon>
                {{ row.className }}
              </div>
            </template>
          </el-table-column>
          
          <el-table-column prop="registerDate" label="注册时间" width="150" align="center">
            <template #default="{ row }">
              <div class="register-time">
                <el-icon class="time-icon"><Clock /></el-icon>
                {{ row.registerDate }}
              </div>
            </template>
          </el-table-column>
          
          <el-table-column label="操作" width="200" align="center" fixed="right">
            <template #default="{ row }">
              <div class="action-buttons">
                <el-button 
                  size="small" 
                  @click="viewStudent(row)"
                  class="action-btn"
                >
                  <el-icon><View /></el-icon>
                  学情分析
                </el-button>
                <el-button 
                  size="small" 
                  type="primary" 
                  @click="sendNotification(row)"
                  class="action-btn"
                >
                  <el-icon><Message /></el-icon>
                  发送通知
                </el-button>
              </div>
            </template>
          </el-table-column>
        </el-table>
      </el-card>
    </div>

    <!-- 通知对话框 -->
    <el-dialog
      v-model="notificationDialog"
      title="发送通知"
      width="500px"
      :before-close="cancelNotification"
    >
      <el-form
        ref="notificationFormRef"
        :model="notificationForm"
        :rules="notificationRules"
        label-width="80px"
      >
        <el-form-item label="学生姓名">
          <el-input
            :model-value="notificationForm.targetStudent ? notificationForm.targetStudent.name : ''"
            disabled
            placeholder="学生姓名"
          />
        </el-form-item>
        
        <el-form-item label="通知标题" prop="title">
          <el-input
            v-model="notificationForm.title"
            placeholder="请输入通知标题"
            maxlength="50"
            show-word-limit
          />
        </el-form-item>
        
        <el-form-item label="通知内容" prop="content">
          <el-input
            v-model="notificationForm.content"
            type="textarea"
            :rows="4"
            placeholder="请输入通知内容"
            maxlength="200"
            show-word-limit
          />
        </el-form-item>
        
        <el-form-item label="重要程度">
          <el-switch
            v-model="notificationForm.isImportant"
            active-text="重要通知"
            inactive-text="普通通知"
          />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="cancelNotification">取消</el-button>
          <el-button type="primary" @click="submitNotification">发送通知</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Search, Refresh, OfficeBuilding, School, Collection, Clock, View, Message } from '@element-plus/icons-vue'
import RadarChart from './RadarChart.vue'
import axios from 'axios'
import { sendNotificationToStudent } from '@/api/notification.js'

const router = useRouter()
const teacherId = Number(localStorage.getItem('teacherId') || 2)
const students = ref([])
const courseOptions = ref([])
const selectedCourse = ref('') // Unified variable for selected course name
const searchKeyword = ref('') // 搜索关键词

// 排序相关
const sortField = ref('id')
const sortOrder = ref('asc')

// 通知相关
const notificationDialog = ref(false)
const notificationForm = ref({
  title: '',
  content: '',
  isImportant: false,
  targetStudent: null
})
const notificationRules = ref({
  title: [
    { required: true, message: '请输入通知标题', trigger: 'blur' }
  ],
  content: [
    { required: true, message: '请输入通知内容', trigger: 'blur' }
  ]
})



// 搜索和筛选相关
const filteredStudents = computed(() => {
  let filtered = students.value
  
  // 按关键词搜索
  if (searchKeyword.value.trim()) {
    const keyword = searchKeyword.value.trim().toLowerCase()
    filtered = filtered.filter(student => 
      student.name.toLowerCase().includes(keyword) ||
      student.id.toString().includes(keyword) ||
      student.school.toLowerCase().includes(keyword) ||
      student.college.toLowerCase().includes(keyword) ||
      student.className.toLowerCase().includes(keyword)
    )
  }
  
  return filtered
})

// 应用筛选
const applyFilter = () => {
  // 搜索功能已通过computed属性实现
}

// 重置筛选
const resetFilters = () => {
  searchKeyword.value = ''
  selectedCourse.value = ''
  students.value = []
}

// Add course change handler
const onCourseChange = async (courseName) => {
  selectedCourse.value = courseName
  await loadStudents()
}

// 发送通知相关方法
const sendNotification = (student) => {
  notificationForm.value.targetStudent = student
  notificationForm.value.title = ''
  notificationForm.value.content = ''
  notificationForm.value.isImportant = false
  notificationDialog.value = true
}

const submitNotification = async () => {
  try {
    const notificationData = {
      title: notificationForm.value.title,
      content: notificationForm.value.content,
      isImportant: notificationForm.value.isImportant,
      receiverId: notificationForm.value.targetStudent.id,  // 修改字段名
      receiverName: notificationForm.value.targetStudent.name,  // 修改字段名
      senderId: teacherId,  // 添加发送者ID
      senderName: '老师',  // 添加发送者姓名
      courseName: selectedCourse.value,
      sendTime: new Date().toISOString()
    }
    
    // 发送通知到后端
    const response = await axios.post('/api/notifications/send', notificationData)
    
    if (response.data.code === 200) {
      ElMessage.success('通知发送成功！')
      notificationDialog.value = false
      // 重置表单
      notificationForm.value = {
        title: '',
        content: '',
        isImportant: false,
        targetStudent: null
      }
    } else {
      ElMessage.error(response.data.message || '发送失败')
    }
  } catch (error) {
    console.error('发送通知失败:', error)
    ElMessage.error('发送通知失败，请重试')
  }
}

const cancelNotification = () => {
  notificationDialog.value = false
  notificationForm.value = {
    title: '',
    content: '',
    isImportant: false,
    targetStudent: null
  }
}

// 排序方法
const sortBy = (field) => {
  if (sortField.value === field) {
    sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortField.value = field
    sortOrder.value = 'asc'
  }
}

// 排序后的学生列表
const sortedStudents = computed(() => {
  if (!students.value.length) return []
  
  return [...students.value].sort((a, b) => {
    let aVal = a[sortField.value]
    let bVal = b[sortField.value]
    
    if (sortField.value === 'id') {
      aVal = Number(aVal)
      bVal = Number(bVal)
    }
    
    if (sortOrder.value === 'asc') {
      return aVal > bVal ? 1 : -1
    } else {
      return aVal < bVal ? 1 : -1
    }
  })
})

// 计算属性

const averageAccuracy = computed(() => {
  if (!students.value.length) return 0
  // 这里可以根据实际数据计算平均正确率
  return 0 // 暂时返回固定值
})

const totalAssignments = computed(() => {
  if (!students.value.length) return 0
  // 这里可以根据实际数据计算作业总数
  return 1 // 暂时返回固定值
})

// For each student add default radar data to prevent errors when data is empty
const getStudentRadarData = (studentId) => {
  const courseName = selectedCourse.value
  if (!courseName) return { '暂无数据': 0 }

  const analytics = studentAnalytics[studentId]?.[courseName]
  if (!analytics || !analytics.radar) {
    return { '暂无数据': 0 }
  }
  return analytics.radar
}

const aggregatedRadar = computed(() => {
  // Ensure a course is selected
  if (!selectedCourse.value) {
    console.log('没有选择课程，返回默认数据')
    return { '暂无数据': 0 }
  }

  // 直接使用课程知识点数据
  const courseAnalytics = studentAnalytics.value[selectedCourse.value]
  console.log('当前课程:', selectedCourse.value)
  console.log('课程分析数据:', courseAnalytics)
  
  if (courseAnalytics && courseAnalytics.radar) {
    console.log('返回雷达图数据:', courseAnalytics.radar)
    return courseAnalytics.radar
  }

  // 如果没有数据，返回默认值
  console.log('没有雷达图数据，返回默认值')
  return { '暂无数据': 0 }
})

// 查看学生详情 - 跳转到新页面
const viewStudent = (student) => {
  const course = courseOptions.value.find(c => c.name === selectedCourse.value)
  if (course) {
    router.push(`/student-detail/${student.id}/${course.id}`)
  } else {
    ElMessage.error('请先选择课程')
  }
}

// 显示学情分析
const showLearningAnalysis = async (student) => {
  currentStudent.value = student
  analysisDialogVisible.value = true
  
  // 生成AI学情分析数据
  await generateLearningAnalysis(student)
}

// 生成学情分析数据
const generateLearningAnalysis = async (student) => {
  try {
    const course = courseOptions.value.find(c => c.name === selectedCourse.value)
    if (!course) return
    
    // 1. 获取知识点掌握度数据
    await loadKnowledgeMastery(student.id, course.id)
    
    // 2. 获取作业完成情况
    await loadHomeworkAnalysis(student.id, course.id)
    
    // 3. 获取学习积极性数据
    await loadMotivationAnalysis(student.id, course.id)
    
    // 4. 生成AI建议
    generateAIRecommendations()
    
  } catch (error) {
    console.error('生成学情分析失败:', error)
    ElMessage.error('生成学情分析失败')
  }
}

// 加载知识点掌握度
const loadKnowledgeMastery = async (studentId, courseId) => {
  try {
    // 这里应该调用真实的API获取学生知识点掌握度
    // 暂时使用模拟数据
    const response = await axios.get('/api/xiaozhi/teacher/analysis/student-knowledge-mastery', {
      params: { studentId, courseId }
    })
    
    if (response.data?.data) {
      knowledgeMastery.value = response.data.data
    } else {
      // 模拟数据
      knowledgeMastery.value = {
        '嵌入式系统概述': 85,
        '嵌入式处理器架构': 72,
        '嵌入式软件开发': 68,
        '实时操作系统': 45,
        '嵌入式系统通信': 78,
        '嵌入式系统调试与测试': 92
      }
    }
  } catch (error) {
    // 使用模拟数据
    knowledgeMastery.value = {
      '嵌入式系统概述': 85,
      '嵌入式处理器架构': 72,
      '嵌入式软件开发': 68,
      '实时操作系统': 45,
      '嵌入式系统通信': 78,
      '嵌入式系统调试与测试': 92
    }
  }
}

// 加载作业分析
const loadHomeworkAnalysis = async (studentId, courseId) => {
  try {
    // 这里应该调用真实的API获取学生作业数据
    const response = await axios.get('/api/xiaozhi/teacher/analysis/student-homework', {
      params: { studentId, courseId }
    })
    
    if (response.data?.data) {
      homeworkStats.value = response.data.data.stats
      homeworkDetails.value = response.data.data.details
    } else {
      // 模拟数据
      homeworkStats.value = {
        total: 8,
        completed: 7,
        averageScore: 82.5
      }
      
      homeworkDetails.value = [
        {
          id: 1,
          title: '第一章作业 - 嵌入式系统基础',
          score: 90,
          submitTime: '2024-01-15 14:30',
          duration: '45分钟',
          analysis: '该生在基础概念理解上表现良好，但在实际应用方面还有提升空间。'
        },
        {
          id: 2,
          title: '第二章作业 - 处理器架构',
          score: 75,
          submitTime: '2024-01-20 16:15',
          duration: '60分钟',
          analysis: '对ARM架构理解不够深入，建议加强相关练习。'
        }
      ]
    }
  } catch (error) {
    // 使用模拟数据
    homeworkStats.value = {
      total: 8,
      completed: 7,
      averageScore: 82.5
    }
    
    homeworkDetails.value = [
      {
        id: 1,
        title: '第一章作业 - 嵌入式系统基础',
        score: 90,
        submitTime: '2024-01-15 14:30',
        duration: '45分钟',
        analysis: '该生在基础概念理解上表现良好，但在实际应用方面还有提升空间。'
      },
      {
        id: 2,
        title: '第二章作业 - 处理器架构',
        score: 75,
        submitTime: '2024-01-20 16:15',
        duration: '60分钟',
        analysis: '对ARM架构理解不够深入，建议加强相关练习。'
      }
    ]
  }
}

// 加载学习积极性分析
const loadMotivationAnalysis = async (studentId, courseId) => {
  try {
    // 这里应该调用真实的API获取学生学习积极性数据
    const response = await axios.get('/api/xiaozhi/teacher/analysis/student-motivation', {
      params: { studentId, courseId }
    })
    
    if (response.data?.data) {
      motivationStats.value = response.data.data.stats
      motivationAnalysis.value = response.data.data.analysis
    } else {
      // 模拟数据
      motivationStats.value = {
        aiPracticeCount: 15,
        practiceTime: 12.5,
        questionCount: 8
      }
      
      motivationAnalysis.value = '该生学习积极性较高，经常参与AI陪练练习，课下练习时间充足，主动提问次数较多，表现出良好的学习态度。'
    }
  } catch (error) {
    // 使用模拟数据
    motivationStats.value = {
      aiPracticeCount: 15,
      practiceTime: 12.5,
      questionCount: 8
    }
    
    motivationAnalysis.value = '该生学习积极性较高，经常参与AI陪练练习，课下练习时间充足，主动提问次数较多，表现出良好的学习态度。'
  }
}

// 生成AI建议
const generateAIRecommendations = () => {
  // 基于分析数据生成个性化建议
  const recommendations = []
  
  // 分析知识点掌握情况
  const weakPoints = Object.entries(knowledgeMastery.value)
    .filter(([_, mastery]) => mastery < 70)
    .map(([knowledge, _]) => knowledge)
  
  if (weakPoints.length > 0) {
    recommendations.push({
      title: '重点加强薄弱知识点',
      description: `建议重点复习：${weakPoints.join('、')}，可以通过专项练习和AI陪练来提升掌握度。`
    })
  }
  
  // 分析作业完成情况
  if (homeworkStats.value.averageScore < 80) {
    recommendations.push({
      title: '提升作业质量',
      description: '建议在完成作业前先复习相关知识点，仔细审题，提高答题准确性。'
    })
  }
  
  // 分析学习积极性
  if (motivationStats.value.aiPracticeCount < 10) {
    recommendations.push({
      title: '增加练习频率',
      description: '建议增加AI陪练练习次数，通过反复练习巩固知识点。'
    })
  }
  
  // 通用建议
  recommendations.push({
    title: '制定学习计划',
    description: '建议制定每周学习计划，合理安排复习和练习时间，保持学习的连续性。'
  })
  
  aiRecommendations.value = recommendations
}

// 关闭分析弹窗
const closeAnalysisDialog = () => {
  analysisDialogVisible.value = false
  currentStudent.value = null
}

// 导出分析报告
const exportAnalysis = () => {
  // 这里可以实现导出PDF或Excel的功能
  ElMessage.success('报告导出功能开发中...')
}

onMounted(async () => {
  try {
    const cr = await axios.get('/api/xiaozhi/teacher/by-teacher', { params: { teacherId } })
    courseOptions.value = (cr.data || []).map(c => ({ id: c.id, name: c.courseName }))

    // Set default selected course
    if (courseOptions.value.length > 0) {
      selectedCourse.value = courseOptions.value[0].name
      await loadStudents()
    }
  } catch (e) {
    ElMessage.error('加载课程失败：' + e.message)
  }
})

async function loadStudents() {
  if (!selectedCourse.value) { students.value = []; return }
  try {
    // Find course ID based on course name
    const course = courseOptions.value.find(c => c.name === selectedCourse.value)
    if (!course) { students.value = []; return }

    const rs = await axios.get('/api/xiaozhi/teacher/course/students', { params: { courseId: course.id } })
    students.value = (rs.data?.data || []).map(s => ({ ...s }))
    
    // 加载课程知识点雷达图数据
    await loadStudentAnalytics()
  } catch (e) {
    ElMessage.error('加载学生失败：' + e.message)
  }
}

// 模拟数据（用于雷达图）
const studentAnalytics = ref({})

// 获取学生雷达图数据
const loadStudentAnalytics = async () => {
  if (!selectedCourse.value) {
    studentAnalytics.value = {}
    return
  }

  const course = courseOptions.value.find(c => c.name === selectedCourse.value)
  if (!course) return

  try {
    // 获取课程下的所有知识点
    const response = await axios.get('/api/xiaozhi/teacher/analysis/course-knowledge-points', {
      params: { courseId: course.id }
    })
    
    console.log('课程知识点API响应:', response.data)
    
    if (response.data?.data && response.data.data.length > 0) {
      // 将知识点转换为雷达图格式，所有值设为0
      const radarData = {}
      response.data.data.forEach(knowledgePoint => {
        radarData[knowledgePoint] = 0
      })
      
      console.log('生成的雷达图数据:', radarData)
      
      // 存储到studentAnalytics中
      studentAnalytics.value = {
        [selectedCourse.value]: { radar: radarData }
      }
      
      console.log('存储后的studentAnalytics:', studentAnalytics.value)
    } else {
      // 如果没有知识点数据，使用默认数据
      studentAnalytics.value = {
        [selectedCourse.value]: { radar: { '暂无知识点数据': 0 } }
      }
      console.log('使用默认数据:', studentAnalytics.value)
    }
  } catch (error) {
    console.error('获取课程知识点失败:', error)
    // 使用默认数据
    studentAnalytics.value = {
      [selectedCourse.value]: { radar: { '暂无知识点数据': 0 } }
    }
  }
}

// 获取掌握度状态样式类
const getMasteryStatusClass = (mastery) => {
  if (mastery >= 90) return 'excellent'
  if (mastery >= 80) return 'good'
  if (mastery >= 70) return 'fair'
  if (mastery >= 60) return 'poor'
  return 'very-poor'
}

// 获取掌握度状态文本
const getMasteryStatusText = (mastery) => {
  if (mastery >= 90) return '优秀'
  if (mastery >= 80) return '良好'
  if (mastery >= 70) return '一般'
  if (mastery >= 60) return '较差'
  return '很差'
}

// 获取分数样式类
const getScoreClass = (score) => {
  if (score >= 90) return 'high-score'
  if (score >= 80) return 'medium-score'
  if (score >= 70) return 'low-score'
  return 'no-score'
}
</script>

<style scoped>
.student-manager {
  background: #ffffff;
  min-height: 100vh;
  padding: 0;
}

/* 页面头部 */
.page-header {
  background: white;
  padding: 2rem;
  margin-bottom: 0;
  border-bottom: 1px solid #e0e0e0;
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
  font-size: 1.8rem;
  font-weight: 700;
  color: #1e293b;
  margin: 0 0 0.5rem 0;
}

.title-icon {
  width: 3rem;
  height: 3rem;
  object-fit: contain;
  vertical-align: middle;
  margin-right: 0.5rem;
}

.page-subtitle {
  color: #64748b;
  font-size: 0.9rem;
  margin: 0;
}

.header-right {
  display: flex; 
  align-items: center;
}

.stats-container {
  display: flex;
  gap: 1.5rem;
}

.stat-item {
  text-align: center;
  background: #f8f9fa;
  padding: 1rem 1.5rem;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  min-width: 100px;
}

.stat-number {
  display: block;
  font-size: 1.5rem;
  font-weight: 700; 
  color: #1e293b;
  margin-bottom: 0.25rem;
}

.stat-label { 
  font-size: 0.8rem;
  color: #64748b; 
  font-weight: 500;
}

/* 搜索和筛选区域 */
.search-section {
  background: white;
  padding: 1.5rem 2rem;
  border-bottom: 1px solid #e0e0e0;
}

.search-bar {
  display: flex; 
  justify-content: space-between;
  align-items: center;
  max-width: 1200px;
  margin: 0 auto;
  gap: 1rem;
}

.search-left {
  flex: 1;
  max-width: 400px;
}

.search-input {
  width: 100%;
}

.search-right {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.filter-select {
  width: 200px;
}

.reset-btn {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

/* 学情分析面板 */
.analytics-section {
  padding: 1.5rem 2rem;
  background: white;
}

.analytics-card {
  max-width: 1200px;
  margin: 0 auto;
}

.analytics-content {
  display: flex;
  gap: 2rem;
  align-items: stretch; 
}

.radar-chart-container {
  flex: 0 0 300px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.ai-summary { 
  flex: 1;
  padding: 1rem; 
}

.summary-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 1rem;
}

.summary-text { 
  color: #64748b;
  line-height: 1.6; 
  font-size: 0.9rem;
}

/* 表格容器 */
.table-container {
  padding: 1.5rem 2rem;
  background: white;
}

.table-card {
  max-width: 1200px;
  margin: 0 auto;
}

.student-table {
  width: 100%;
}

.student-id {
  font-weight: 600;
  color: #1e293b;
}

.student-name,
.school-info,
.college-info,
.class-info,
.register-time {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.name-icon,
.school-icon,
.college-icon,
.class-icon,
.time-icon {
  color: #64748b;
  font-size: 0.9rem;
}

.action-buttons {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.8rem;
  padding: 0.25rem 0.75rem;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .header-content {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
  }
  
  .stats-container {
    flex-wrap: wrap;
    gap: 1rem;
  }
  
  .search-bar {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }
  
  .search-left {
    max-width: none;
  }
  
  .analytics-content {
    flex-direction: column;
    gap: 1rem;
  }
  
  .radar-chart-container {
    flex: none;
  }
}

/* 学生详情样式 */
.student-detail {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.detail-card {
  margin-bottom: 1rem;
}

.basic-info p {
  margin: 0.5rem 0;
  color: #334155;
}

.weak-points {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.weak-point-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem;
  background: #f8fafc;
  border-radius: 6px;
  border-left: 3px solid #ef4444;
}

.point-name {
  font-weight: 500;
  color: #0f172a;
}

.error-count {
  color: #ef4444;
  font-weight: 600;
}

.assignment-scores {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.assignment-item {
  padding: 0.75rem;
  background: #f8fafc;
  border-radius: 6px;
  border: 1px solid #e2e8f0;
}

.assignment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.assignment-title {
  font-weight: 600;
  color: #0f172a;
}

.assignment-score {
  font-weight: 600;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.875rem;
}

.assignment-score.high-score {
  background: #dcfce7;
  color: #166534;
}

.assignment-score.medium-score {
  background: #fef3c7;
  color: #92400e;
}

.assignment-score.low-score {
  background: #fee2e2;
  color: #991b1b;
}

.assignment-score.no-score {
  background: #f1f5f9;
  color: #64748b;
}

.assignment-meta {
  display: flex;
  gap: 1rem;
  font-size: 0.875rem;
  color: #64748b;
  margin-bottom: 0.5rem;
}

/* 作业详情样式 */
.assignment-detail {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.question-item {
  padding: 1rem;
  background: #f8fafc;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.question-number {
  font-weight: 600;
  color: #0f172a;
}

.question-status {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.875rem;
  font-weight: 500;
}

.question-status.correct {
  background: #dcfce7;
  color: #166534;
}

.question-status.incorrect {
  background: #fee2e2;
  color: #991b1b;
}

.question-content {
  background: #fff;
  padding: 0.75rem;
  border-radius: 6px;
  margin-bottom: 0.75rem;
  color: #334155;
  line-height: 1.5;
}

.answer-info p {
  margin: 0.5rem 0;
  color: #334155;
}

.answer-info strong {
  color: #0f172a;
}

.no-data {
  text-align: center;
  color: #64748b;
  font-style: italic;
  padding: 2rem;
}

/* 学情分析弹窗样式 */
.learning-analysis {
  padding: 20px 0;
}

.student-info {
  text-align: center;
  margin-bottom: 30px;
  padding: 20px;
  background: #f8fafc;
  border-radius: 12px;
}

.student-info h3 {
  margin: 0 0 10px 0;
  color: #0f172a;
  font-size: 20px;
}

.student-info p {
  margin: 0;
  color: #64748b;
  font-size: 14px;
}

.analysis-sections {
  display: flex;
  flex-direction: column;
  gap: 25px;
}

.analysis-section {
  background: #fff;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.analysis-section h4 {
  margin: 0 0 20px 0;
  color: #0f172a;
  font-size: 16px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
}

/* 知识点掌握度样式 */
.knowledge-mastery {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.mastery-item {
  display: grid;
  grid-template-columns: 2fr 3fr 80px 100px;
  gap: 15px;
  align-items: center;
  padding: 15px;
  background: #f8fafc;
  border-radius: 8px;
}

.knowledge-name {
  font-weight: 500;
  color: #0f172a;
}

.mastery-bar {
  width: 100%;
  height: 8px;
  background: #e2e8f0;
  border-radius: 4px;
  overflow: hidden;
}

.mastery-fill {
  height: 100%;
  background: linear-gradient(90deg, #ef4444, #f59e0b, #10b981);
  border-radius: 4px;
  transition: width 0.3s ease;
}

.mastery-value {
  font-weight: 600;
  color: #0f172a;
  text-align: center;
}

.mastery-status {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  text-align: center;
}

.mastery-status.excellent {
  background: #dcfce7;
  color: #166534;
}

.mastery-status.good {
  background: #dbeafe;
  color: #1e40af;
}

.mastery-status.fair {
  background: #fef3c7;
  color: #92400e;
}

.mastery-status.poor {
  background: #fed7aa;
  color: #c2410c;
}

.mastery-status.very-poor {
  background: #fee2e2;
  color: #991b1b;
}

/* 作业分析样式 */
.homework-stats {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
  padding: 15px;
  background: #f8fafc;
  border-radius: 8px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
}

.stat-label {
  font-size: 12px;
  color: #64748b;
}

.stat-value {
  font-size: 18px;
  font-weight: 600;
  color: #0f172a;
}

.stat-value.completed {
  color: #10b981;
}

.homework-details {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.homework-item {
  padding: 15px;
  background: #f8fafc;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
}

.homework-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.homework-title {
  font-weight: 600;
  color: #0f172a;
}

.homework-score {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.homework-score.high-score {
  background: #dcfce7;
  color: #166534;
}

.homework-score.medium-score {
  background: #fef3c7;
  color: #92400e;
}

.homework-score.low-score {
  background: #fed7aa;
  color: #c2410c;
}

.homework-score.no-score {
  background: #f1f5f9;
  color: #64748b;
}

.homework-meta {
  display: flex;
  gap: 20px;
  margin-bottom: 10px;
  font-size: 12px;
  color: #64748b;
}

.homework-analysis-text {
  font-size: 14px;
  color: #334155;
  line-height: 1.5;
  font-style: italic;
}

/* 学习积极性样式 */
.motivation-stats {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
  padding: 15px;
  background: #f8fafc;
  border-radius: 8px;
}

.motivation-analysis h5 {
  margin: 0 0 10px 0;
  color: #0f172a;
  font-size: 14px;
}

.motivation-analysis p {
  margin: 0;
  color: #334155;
  line-height: 1.6;
  font-size: 14px;
}

/* AI建议样式 */
.ai-recommendations {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.recommendation-item {
  display: flex;
  gap: 15px;
  padding: 15px;
  background: #f8fafc;
  border-radius: 8px;
  border-left: 4px solid #3b82f6;
}

.rec-icon {
  font-size: 20px;
  color: #3b82f6;
}

.rec-content h6 {
  margin: 0 0 8px 0;
  color: #0f172a;
  font-size: 14px;
  font-weight: 600;
}

.rec-content p {
  margin: 0;
  color: #334155;
  line-height: 1.5;
  font-size: 13px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .student-detail {
    grid-template-columns: 1fr;
  }
  
  .subject-body {
    flex-direction: column;
  }
  
  .radar-chart-container {
    flex: none;
  }
  
  .stats {
    flex-wrap: wrap;
  }
  
  .stat {
    min-width: 100px;
  }
  
  .mastery-item {
    grid-template-columns: 1fr;
    gap: 10px;
  }
  
  .homework-stats,
  .motivation-stats {
    flex-direction: column;
    gap: 10px;
  }
}
</style>
