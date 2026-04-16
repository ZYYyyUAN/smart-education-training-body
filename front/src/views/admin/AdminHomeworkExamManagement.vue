<template>
  <div class="admin-homework-exam-management" :style="backgroundStyle">
    <div class="management-container">
      <!-- 页面头部 -->
      <div class="page-header">
        <div class="header-content">
          <div class="header-left">
            <h1 class="page-title">
              <el-icon class="title-icon"><Connection /></el-icon>
              作业与考试管理
            </h1>
            <p class="page-subtitle">统一管理所有作业和考试资源</p>
          </div>
          <div class="header-right">
            <!-- 顶部预留操作区域 -->
          </div>
        </div>
      </div>

      <!-- 主体 + 右侧数据可视化布局 -->
      <div class="content-layout">
        <!-- 主体区域：Tab、筛选、表格 -->
        <div class="main-area">
          <!-- Tab 切换 -->
          <div class="tab-section">
            <el-tabs v-model="activeTab" @tab-change="handleTabChange">
              <el-tab-pane label="作业管理" name="homework">
                <template #label>
                  <span class="tab-label">
                    <el-icon><EditPen /></el-icon>
                    作业管理
                  </span>
                </template>
              </el-tab-pane>
              <el-tab-pane label="考试管理" name="exam">
                <template #label>
                  <span class="tab-label">
                    <el-icon><Trophy /></el-icon>
                    考试管理
                  </span>
                </template>
              </el-tab-pane>
            </el-tabs>
          </div>

          <!-- 搜索和筛选区域 -->
          <div class="search-section">
            <div class="search-bar">
              <div class="search-left">
                <el-input
                  v-model="searchKeyword"
                  :placeholder="activeTab === 'homework' ? '搜索作业标题...' : '搜索考试标题...'"
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
                <!-- 作业管理时的筛选 -->
                <template v-if="activeTab === 'homework'">
                  <el-select 
                    v-model="selectedCourseId" 
                    placeholder="按课程筛选" 
                    class="filter-select"
                    clearable 
                    @change="applyFilter"
                  >
                    <el-option 
                      v-for="course in courses" 
                      :key="course.id" 
                      :label="course.courseName" 
                      :value="course.id" 
                    />
                  </el-select>
                  <el-select 
                    v-model="selectedTeacherId" 
                    placeholder="按教师筛选" 
                    class="filter-select"
                    clearable 
                    @change="applyFilter"
                  >
                    <el-option 
                      v-for="teacher in teachers" 
                      :key="teacher.id" 
                      :label="teacher.name || teacher.username" 
                      :value="teacher.id" 
                    />
                  </el-select>
                  <el-select 
                    v-model="selectedStudentId" 
                    placeholder="按学生筛选" 
                    class="filter-select"
                    clearable 
                    @change="applyFilter"
                  >
                    <el-option 
                      v-for="student in students" 
                      :key="student.id" 
                      :label="student.name || student.username" 
                      :value="student.id" 
                    />
                  </el-select>
                </template>
                <!-- 考试管理时的筛选 -->
                <template v-else>
                  <el-select 
                    v-model="selectedCourseId" 
                    placeholder="按课程筛选" 
                    class="filter-select"
                    clearable 
                    @change="applyFilter"
                  >
                    <el-option 
                      v-for="course in courses" 
                      :key="course.id" 
                      :label="course.courseName" 
                      :value="course.id" 
                    />
                  </el-select>
                  <el-select 
                    v-model="selectedTeacherId" 
                    placeholder="按教师筛选" 
                    class="filter-select"
                    clearable 
                    @change="applyFilter"
                  >
                    <el-option 
                      v-for="teacher in teachers" 
                      :key="teacher.id" 
                      :label="teacher.name || teacher.username" 
                      :value="teacher.id" 
                    />
                  </el-select>
                </template>
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

          <!-- 作业管理表格 -->
          <div class="table-section" v-if="activeTab === 'homework'">
            <el-card shadow="hover" class="table-card">
              <el-table
                :data="pagedHomeworks"
                v-loading="homeworkLoading"
                class="management-table"
                empty-text="暂无作业"
              >
                <el-table-column label="作业ID" width="100" align="center">
                  <template #default="{ $index }">
                    <span class="item-id">{{ String(($index + 1)).padStart(3, '0') }}</span>
                  </template>
                </el-table-column>

                <el-table-column label="课程" width="200" align="center">
                  <template #default="{ row }">
                    <div class="course-info">
                      <el-icon class="course-icon"><Reading /></el-icon>
                      <span>{{ getCourseName(row.courseId) || '-' }}</span>
                    </div>
                  </template>
                </el-table-column>

                <el-table-column prop="title" label="作业题目" min-width="200" show-overflow-tooltip>
                  <template #default="{ row }">
                    <div class="item-title">
                      <el-icon class="item-icon"><Document /></el-icon>
                      <span>{{ row.title }}</span>
                    </div>
                  </template>
                </el-table-column>

                <el-table-column label="完成率" width="120" align="center">
                  <template #default="{ row }">
                    <div class="completion-rate">
                      <el-progress 
                        :percentage="parseInt(calcHomeworkRate(row))" 
                        :show-text="false" 
                        :stroke-width="8"
                        :color="getProgressColor(parseInt(calcHomeworkRate(row)))"
                        class="progress-bar"
                      />
                      <span class="rate-text">{{ calcHomeworkRate(row) }}</span>
                    </div>
                  </template>
                </el-table-column>
                
                <el-table-column label="完成人数" width="120" align="center">
                  <template #default="{ row }">
                    <div class="completion-count">
                      <el-icon class="count-icon"><User /></el-icon>
                      <span>{{ row.completedCount || 0 }} / {{ row.totalStudents || 0 }} 人</span>
                    </div>
                  </template>
                </el-table-column>
                
                <el-table-column prop="dueDate" label="截止时间" min-width="160" align="center">
                  <template #default="{ row }">
                    <div class="due-date">
                      <el-icon class="date-icon"><Clock /></el-icon>
                      <span>{{ row.dueDate }}</span>
                    </div>
                  </template>
                </el-table-column>
                
                <el-table-column label="状态" width="120" align="center">
                  <template #default="{ row }">
                    <el-tag 
                      :type="getHomeworkStatusTagType(row)" 
                      :effect="getHomeworkStatusTagType(row) === 'danger' ? 'dark' : 'light'"
                      class="status-tag"
                    >
                      <el-icon class="status-icon">
                        <Check v-if="getHomeworkStatusTagType(row) === 'success'" />
                        <Close v-else />
                      </el-icon>
                      {{ getHomeworkStatusText(row) }}
                    </el-tag>
                  </template>
                </el-table-column>
                
                <el-table-column label="操作" width="280" align="center" fixed="right">
                  <template #default="{ row }">
                    <div class="action-buttons">
                      <el-button 
                        size="small" 
                        type="primary" 
                        class="action-btn"
                        @click="editHomework(row)"
                      >
                        <el-icon><Edit /></el-icon>
                        编辑
                      </el-button>
                      <el-button 
                        size="small" 
                        type="danger" 
                        class="action-btn"
                        @click="deleteHomework(row.id)"
                      >
                        <el-icon><Delete /></el-icon>
                        删除
                      </el-button>
                    </div>
                  </template>
                </el-table-column>
              </el-table>
            </el-card>

            <!-- 作业分页器 -->
            <div class="pagination-wrapper">
              <div class="pagination-info">
                <span class="pagination-text">
                  共 {{ filteredHomeworks.length }} 条记录，第 {{ homeworkCurrentPage }} / {{ Math.ceil(filteredHomeworks.length / pageSize) }} 页
                </span>
              </div>
              <el-pagination
                background
                layout="prev, pager, next, jumper"
                :total="filteredHomeworks.length"
                :page-size="pageSize"
                :current-page="homeworkCurrentPage"
                @current-change="(p) => (homeworkCurrentPage = p)"
                class="pagination"
              />
            </div>
          </div>

          <!-- 考试管理表格 -->
          <div class="table-section" v-if="activeTab === 'exam'">
            <el-card shadow="hover" class="table-card">
              <el-table 
                :data="pagedExams" 
                v-loading="examLoading" 
                class="management-table"
                empty-text="暂无考试"
              >
                <el-table-column label="考试ID" width="100" align="center">
                  <template #default="{ $index }">
                    <span class="item-id">{{ String(($index + 1)).padStart(3, '0') }}</span>
                  </template>
                </el-table-column>

                <el-table-column label="课程" width="200" align="center">
                  <template #default="{ row }">
                    <div class="course-info">
                      <el-icon class="course-icon"><Reading /></el-icon>
                      <span>{{ getCourseName(row.courseId) || '-' }}</span>
                    </div>
                  </template>
                </el-table-column>

                <el-table-column prop="title" label="考试题目" min-width="200" show-overflow-tooltip>
                  <template #default="{ row }">
                    <div class="item-title">
                      <el-icon class="item-icon"><Document /></el-icon>
                      <span>{{ row.title }}</span>
                    </div>
                  </template>
                </el-table-column>
                
                <el-table-column label="完成率" width="120" align="center">
                  <template #default="{ row }">
                    <div class="completion-rate">
                      <el-progress 
                        :percentage="parseInt(calcExamRate(row))" 
                        :show-text="false" 
                        :stroke-width="8"
                        :color="getProgressColor(parseInt(calcExamRate(row)))"
                        class="progress-bar"
                      />
                      <span class="rate-text">{{ calcExamRate(row) }}</span>
                    </div>
                  </template>
                </el-table-column>
                
                <el-table-column label="完成人数" width="120" align="center">
                  <template #default="{ row }">
                    <div class="completion-count">
                      <el-icon class="count-icon"><User /></el-icon>
                      <span>{{ row.completedCount || 0 }} / {{ row.totalStudents || 0 }} 人</span>
                    </div>
                  </template>
                </el-table-column>
                
                <el-table-column label="考试时间" width="180" align="center">
                  <template #default="{ row }">
                    <div class="exam-date">
                      <el-icon class="date-icon"><Clock /></el-icon>
                      <span>{{ formatDate(row.examDate) }}</span>
                    </div>
                  </template>
                </el-table-column>
                
                <el-table-column label="状态" width="120" align="center">
                  <template #default="{ row }">
                    <el-tag 
                      :type="getExamStatusTagType(row)" 
                      :effect="getExamStatusTagType(row) === 'danger' ? 'dark' : 'light'"
                      class="status-tag"
                    >
                      <el-icon class="status-icon">
                        <Check v-if="getExamStatusTagType(row) === 'success'" />
                        <Close v-else />
                      </el-icon>
                      {{ getExamStatusText(row) }}
                    </el-tag>
                  </template>
                </el-table-column>
                
                <el-table-column label="操作" width="280" align="center" fixed="right">
                  <template #default="{ row }">
                    <div class="action-buttons">
                      <el-button 
                        size="small" 
                        type="primary" 
                        class="action-btn"
                        @click="editExam(row)"
                      >
                        <el-icon><Edit /></el-icon>
                        编辑
                      </el-button>
                      <el-button 
                        size="small" 
                        type="danger" 
                        class="action-btn"
                        @click="deleteExam(row.id)"
                      >
                        <el-icon><Delete /></el-icon>
                        删除
                      </el-button>
                    </div>
                  </template>
                </el-table-column>
              </el-table>
            </el-card>

            <!-- 考试分页器 -->
            <div class="pagination-wrapper">
              <div class="pagination-info">
                <span class="pagination-text">
                  共 {{ filteredExams.length }} 条记录，第 {{ examCurrentPage }} / {{ Math.ceil(filteredExams.length / pageSize) }} 页
                </span>
              </div>
              <el-pagination
                background
                layout="prev, pager, next, jumper"
                :total="filteredExams.length"
                :page-size="pageSize"
                :current-page="examCurrentPage"
                @current-change="(p) => (examCurrentPage = p)"
                class="pagination"
              />
            </div>
          </div>
        </div>

        <!-- 右侧数据可视化区域 -->
        <div class="insight-sidebar">
          <!-- 上：总体完成度环形概览 -->
          <div class="insight-card insight-overview-card">
            <div class="insight-header">
              <span class="insight-title">总体完成概览</span>
              <span class="insight-subtitle">作业 / 考试</span>
            </div>
            <div class="insight-overview-body">
              <div class="ring-wrapper">
                <div 
                  class="ring ring-homework"
                  :style="{ '--percent': overallHomeworkRateNumber + '%' }"
                >
                  <div class="ring-inner">
                    <span class="ring-label">作业</span>
                    <span class="ring-value">{{ overallHomeworkRateNumber }}%</span>
                  </div>
                </div>
                <div 
                  class="ring ring-exam"
                  :style="{ '--percent': overallExamRateNumber + '%' }"
                >
                  <div class="ring-inner">
                    <span class="ring-label">考试</span>
                    <span class="ring-value">{{ overallExamRateNumber }}%</span>
                  </div>
                </div>
              </div>
              <div class="insight-metrics">
                <div class="metric-item">
                  <span class="metric-label">进行中作业</span>
                  <span class="metric-value">{{ ongoingHomeworkCount }}</span>
                </div>
                <div class="metric-item">
                  <span class="metric-label">进行中考试</span>
                  <span class="metric-value">{{ ongoingExamCount }}</span>
                </div>
                <div class="metric-item warning">
                  <span class="metric-label">即将到期</span>
                  <span class="metric-value">{{ upcomingDeadlineCount }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 下：时间轴形式的最近截止 -->
          <div class="insight-card insight-timeline-card">
            <div class="insight-header">
              <span class="insight-title">最近截止时间线</span>
              <span class="insight-subtitle">最近 7 天</span>
            </div>
            <div class="timeline-body">
              <div 
                v-for="item in upcomingTimeline"
                :key="item.type + '-' + item.id"
                class="timeline-item"
              >
                <div class="timeline-dot" :class="'type-' + item.typeKey"></div>
                <div class="timeline-content">
                  <div class="timeline-row">
                    <span class="timeline-type" :class="'tag-' + item.typeKey">
                      {{ item.type }}
                    </span>
                    <span class="timeline-date">{{ item.dateText }}</span>
                  </div>
                  <div class="timeline-title">{{ item.title }}</div>
                  <div class="timeline-meta">
                    <span class="meta-course">{{ item.courseName || '未知课程' }}</span>
                    <span class="meta-progress">
                      完成 {{ item.completedCount }}/{{ item.totalStudents }}
                    </span>
                  </div>
                </div>
              </div>
              <div v-if="upcomingTimeline.length === 0" class="timeline-empty">
                未来 7 天暂无截止作业或考试
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 编辑作业对话框 -->
    <el-dialog
      v-model="showEditHomeworkDialog"
      title="编辑作业"
      width="600px"
      :close-on-click-modal="false"
      class="edit-dialog edit-homework-dialog"
    >
      <el-form
        :model="editHomeworkForm"
        label-width="100px"
        :rules="editHomeworkRules"
        ref="editHomeworkFormRef"
      >
        <el-form-item label="作业标题" prop="title">
          <el-input v-model="editHomeworkForm.title" placeholder="请输入作业标题" />
        </el-form-item>
        <el-form-item label="所属课程" prop="courseId">
          <el-select v-model="editHomeworkForm.courseId" placeholder="请选择课程" style="width: 100%">
            <el-option
              v-for="course in courses"
              :key="course.id"
              :label="course.courseName"
              :value="course.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="布置教师" prop="teacherId">
          <el-select v-model="editHomeworkForm.teacherId" placeholder="请选择教师" style="width: 100%">
            <el-option
              v-for="teacher in teachers"
              :key="teacher.id"
              :label="teacher.name || teacher.username"
              :value="teacher.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="作业描述" prop="description">
          <el-input
            v-model="editHomeworkForm.description"
            type="textarea"
            :rows="4"
            placeholder="请输入作业描述（可选）"
          />
        </el-form-item>
        <el-form-item label="截止时间" prop="dueDate">
          <el-date-picker
            v-model="editHomeworkForm.dueDate"
            type="date"
            placeholder="请选择截止时间"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showEditHomeworkDialog = false">取消</el-button>
          <el-button type="primary" @click="submitEditHomework" :loading="editHomeworkSubmitting">
            确定
          </el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 编辑考试对话框 -->
    <el-dialog
      v-model="showEditExamDialog"
      title="编辑考试"
      width="600px"
      :close-on-click-modal="false"
      class="edit-dialog edit-exam-dialog"
    >
      <el-form
        :model="editExamForm"
        label-width="100px"
        :rules="editExamRules"
        ref="editExamFormRef"
      >
        <el-form-item label="考试标题" prop="title">
          <el-input v-model="editExamForm.title" placeholder="请输入考试标题" />
        </el-form-item>
        <el-form-item label="所属课程" prop="courseId">
          <el-select v-model="editExamForm.courseId" placeholder="请选择课程" style="width: 100%">
            <el-option
              v-for="course in courses"
              :key="course.id"
              :label="course.courseName"
              :value="course.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="负责教师" prop="teacherId">
          <el-select v-model="editExamForm.teacherId" placeholder="请选择教师" style="width: 100%">
            <el-option
              v-for="teacher in teachers"
              :key="teacher.id"
              :label="teacher.name || teacher.username"
              :value="teacher.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="考试描述" prop="description">
          <el-input
            v-model="editExamForm.description"
            type="textarea"
            :rows="4"
            placeholder="请输入考试描述（可选）"
          />
        </el-form-item>
        <el-form-item label="考试日期" prop="examDate">
          <el-date-picker
            v-model="editExamForm.examDate"
            type="date"
            placeholder="请选择考试日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="考试时长" prop="durationMinutes">
          <el-input-number
            v-model="editExamForm.durationMinutes"
            :min="1"
            :max="600"
            placeholder="请输入考试时长（分钟）"
            style="width: 100%"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showEditExamDialog = false">取消</el-button>
          <el-button type="primary" @click="submitEditExam" :loading="editExamSubmitting">
            确定
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Connection,
  Plus, 
  Document, 
  Reading, 
  User, 
  Clock, 
  Check, 
  Close, 
  Edit, 
  Delete,
  Search,
  Refresh,
  EditPen,
  Trophy
} from '@element-plus/icons-vue'
import bgImg from '@/assets/images/bgi.png'

const router = useRouter()

// 背景样式（使用统一的作业与考试背景图）
const backgroundStyle = computed(() => ({
  backgroundImage: `url(${bgImg})`,
  backgroundSize: 'cover',
  backgroundPosition: 'center center',
  backgroundRepeat: 'no-repeat'
}))

// Tab 切换
const activeTab = ref('homework')

// 加载状态
const homeworkLoading = ref(false)
const examLoading = ref(false)

// 数据
const homeworks = ref([])  // 存储 AssignmentOverviewDTO
const exams = ref([])
const courses = ref([])
const teachers = ref([])
const students = ref([])

// 筛选相关
const searchKeyword = ref('')
const selectedCourseId = ref('')
const selectedTeacherId = ref('')
const selectedStudentId = ref('')

// 编辑作业相关
const showEditHomeworkDialog = ref(false)
const editHomeworkForm = ref({
  id: null,
  title: '',
  courseId: null,
  teacherId: null,
  description: '',
  dueDate: ''
})
const editHomeworkFormRef = ref(null)
const editHomeworkSubmitting = ref(false)
const editHomeworkRules = {
  title: [{ required: true, message: '请输入作业标题', trigger: 'blur' }],
  courseId: [{ required: true, message: '请选择课程', trigger: 'change' }],
  teacherId: [{ required: true, message: '请选择教师', trigger: 'change' }],
  dueDate: [{ required: true, message: '请选择截止时间', trigger: 'change' }]
}

// 编辑考试相关
const showEditExamDialog = ref(false)
const editExamForm = ref({
  id: null,
  title: '',
  courseId: null,
  teacherId: null,
  description: '',
  examDate: '',
  durationMinutes: null
})
const editExamFormRef = ref(null)
const editExamSubmitting = ref(false)
const editExamRules = {
  title: [{ required: true, message: '请输入考试标题', trigger: 'blur' }],
  courseId: [{ required: true, message: '请选择课程', trigger: 'change' }],
  teacherId: [{ required: true, message: '请选择教师', trigger: 'change' }],
  examDate: [{ required: true, message: '请选择考试日期', trigger: 'change' }],
  durationMinutes: [{ required: true, message: '请输入考试时长', trigger: 'blur' }]
}

// 分页
const homeworkCurrentPage = ref(1)
const examCurrentPage = ref(1)
const pageSize = 10

// 对话框（已移除创建对话框）

// Tab 切换处理
const handleTabChange = (tabName) => {
  if (tabName === 'homework') {
    homeworkCurrentPage.value = 1
  } else {
    examCurrentPage.value = 1
  }
  resetFilters()
}

// 筛选后的作业列表
const filteredHomeworks = computed(() => {
  let filtered = homeworks.value
  
  // 按课程筛选
  if (selectedCourseId.value) {
    filtered = filtered.filter(hw => String(hw.courseId) === String(selectedCourseId.value))
  }
  
  // 按教师筛选
  if (selectedTeacherId.value) {
    filtered = filtered.filter(hw => String(hw.teacherId) === String(selectedTeacherId.value))
  }
  
  // 按学生筛选（需要重新查询）
  // 这个筛选会在 applyFilter 中通过 API 调用实现
  
  // 按关键词搜索
  if (searchKeyword.value.trim()) {
    const keyword = searchKeyword.value.trim().toLowerCase()
    filtered = filtered.filter(hw => 
      hw.title.toLowerCase().includes(keyword) ||
      (hw.description && hw.description.toLowerCase().includes(keyword))
    )
  }
  
  return filtered
})

// 筛选后的考试列表
const filteredExams = computed(() => {
  let filtered = exams.value
  
  // 按课程筛选（如果API没有按课程查询，则前端筛选）
  // 注意：如果已经通过API按课程查询了，这里就不需要再筛选
  // 但为了兼容性，保留前端筛选逻辑
  
  // 按教师筛选（如果API没有按教师查询，则前端筛选）
  if (selectedTeacherId.value) {
    filtered = filtered.filter(exam => String(exam.teacherId) === String(selectedTeacherId.value))
  }
  
  // 按关键词搜索
  if (searchKeyword.value.trim()) {
    const keyword = searchKeyword.value.trim().toLowerCase()
    filtered = filtered.filter(exam => 
      exam.title.toLowerCase().includes(keyword) ||
      (exam.description && exam.description.toLowerCase().includes(keyword))
    )
  }
  
  return filtered
})

// 总体完成率（作业）
const overallHomeworkRateNumber = computed(() => {
  let done = 0
  let total = 0
  homeworks.value.forEach(hw => {
    done += hw.completedCount || 0
    total += hw.totalStudents || 0
  })
  if (!total) return 0
  return Math.round((done / total) * 100)
})

// 总体完成率（考试）
const overallExamRateNumber = computed(() => {
  let done = 0
  let total = 0
  exams.value.forEach(exam => {
    done += exam.completedCount || 0
    total += exam.totalStudents || 0
  })
  if (!total) return 0
  return Math.round((done / total) * 100)
})

// 进行中的作业数量
const ongoingHomeworkCount = computed(() => {
  const now = new Date()
  return homeworks.value.filter(hw => {
    if (!hw.dueDate) return false
    const due = new Date(hw.dueDate)
    return now <= due
  }).length
})

// 进行中的考试数量
const ongoingExamCount = computed(() => {
  const now = new Date()
  return exams.value.filter(exam => {
    if (!exam.examDate) return false
    const examDate = new Date(exam.examDate)
    const duration = exam.durationMinutes || 120
    const end = new Date(examDate.getTime() + duration * 60 * 1000)
    return now <= end
  }).length
})

// 未来 7 天内即将到期的数量
const upcomingDeadlineCount = computed(() => {
  const now = new Date()
  const seven = 7 * 24 * 60 * 60 * 1000
  let count = 0

  homeworks.value.forEach(hw => {
    if (!hw.dueDate) return
    const due = new Date(hw.dueDate)
    if (due.getTime() >= now.getTime() && due.getTime() - now.getTime() <= seven) {
      count++
    }
  })

  exams.value.forEach(exam => {
    if (!exam.examDate) return
    const examDate = new Date(exam.examDate)
    if (examDate.getTime() >= now.getTime() && examDate.getTime() - now.getTime() <= seven) {
      count++
    }
  })

  return count
})

// 最近截止时间线（未来 7 天，作业 + 考试，最多 5 条）
const upcomingTimeline = computed(() => {
  const now = new Date()
  const seven = 7 * 24 * 60 * 60 * 1000
  const items = []

  homeworks.value.forEach(hw => {
    if (!hw.dueDate) return
    const due = new Date(hw.dueDate)
    const diff = due.getTime() - now.getTime()
    if (diff >= 0 && diff <= seven) {
      items.push({
        id: hw.id,
        type: '作业',
        typeKey: 'homework',
        title: hw.title,
        courseName: getCourseName(hw.courseId),
        date: due,
        dateText: hw.dueDate,
        completedCount: hw.completedCount || 0,
        totalStudents: hw.totalStudents || 0
      })
    }
  })

  exams.value.forEach(exam => {
    if (!exam.examDate) return
    const examDate = new Date(exam.examDate)
    const diff = examDate.getTime() - now.getTime()
    if (diff >= 0 && diff <= seven) {
      items.push({
        id: exam.id,
        type: '考试',
        typeKey: 'exam',
        title: exam.title,
        courseName: getCourseName(exam.courseId),
        date: examDate,
        dateText: formatDate(exam.examDate),
        completedCount: exam.completedCount || 0,
        totalStudents: exam.totalStudents || 0
      })
    }
  })

  items.sort((a, b) => a.date.getTime() - b.date.getTime())
  return items.slice(0, 5)
})

// 分页后的作业列表
const pagedHomeworks = computed(() => {
  const start = (homeworkCurrentPage.value - 1) * pageSize
  return filteredHomeworks.value.slice(start, start + pageSize)
})

// 分页后的考试列表
const pagedExams = computed(() => {
  const start = (examCurrentPage.value - 1) * pageSize
  return filteredExams.value.slice(start, start + pageSize)
})

// 获取作业列表
const fetchHomeworks = async () => {
  homeworkLoading.value = true
  try {
    // 如果选择了学生，使用学生查询接口
    if (selectedStudentId.value) {
      const res = await axios.get('/api/xiaozhi/teacher/admin/assignments/overview/by-student', {
        params: { studentId: selectedStudentId.value }
      })
      if (res.data.code === 200) {
        homeworks.value = res.data.data || []
      } else {
        ElMessage.error('加载作业失败: ' + res.data.message)
      }
    } else if (selectedTeacherId.value) {
      // 如果选择了教师，使用教师查询接口
      const res = await axios.get('/api/xiaozhi/teacher/admin/assignments/overview/by-teacher', {
        params: { teacherId: selectedTeacherId.value }
      })
      if (res.data.code === 200) {
        homeworks.value = res.data.data || []
      } else {
        ElMessage.error('加载作业失败: ' + res.data.message)
      }
    } else if (selectedCourseId.value) {
      // 如果选择了课程，使用课程查询接口
      const res = await axios.get('/api/xiaozhi/teacher/admin/assignments/overview/by-course', {
        params: { courseId: selectedCourseId.value }
      })
      if (res.data.code === 200) {
        homeworks.value = res.data.data || []
      } else {
        ElMessage.error('加载作业失败: ' + res.data.message)
      }
    } else {
      // 默认获取所有作业概览（含统计信息）
      const res = await axios.get('/api/xiaozhi/teacher/admin/assignments/overview')
      if (res.data.code === 200) {
        homeworks.value = res.data.data || []
      } else {
        ElMessage.error('加载作业失败: ' + res.data.message)
      }
    }
  } catch (e) {
    ElMessage.error('请求错误: ' + e.message)
  } finally {
    homeworkLoading.value = false
  }
}

// 获取考试列表
const fetchExams = async () => {
  examLoading.value = true
  try {
    // 如果选择了课程，使用课程查询接口
    if (selectedCourseId.value) {
      const res = await axios.get('/api/xiaozhi/teacher/admin/exams/overview/by-course', {
        params: { courseId: selectedCourseId.value }
      })
      if (res.data.code === 200) {
        exams.value = res.data.data || []
      } else {
        ElMessage.error('加载考试失败: ' + res.data.message)
      }
    } else if (selectedTeacherId.value) {
      // 如果选择了教师，使用教师查询接口
      const res = await axios.get('/api/xiaozhi/teacher/admin/exams/overview/by-teacher', {
        params: { teacherId: selectedTeacherId.value }
      })
      if (res.data.code === 200) {
        exams.value = res.data.data || []
      } else {
        ElMessage.error('加载考试失败: ' + res.data.message)
      }
    } else {
      // 默认获取所有考试概览（含统计信息）
      const res = await axios.get('/api/xiaozhi/teacher/admin/exams/overview')
      if (res.data.code === 200) {
        exams.value = res.data.data || []
      } else {
        ElMessage.error('加载考试失败: ' + res.data.message)
      }
    }
  } catch (e) {
    ElMessage.error('请求错误: ' + e.message)
  } finally {
    examLoading.value = false
  }
}

// 加载课程列表
const loadCourses = async () => {
  try {
    const res = await axios.get('/api/xiaozhi/teacher/courses')
    if (res.data.code === 200) {
      courses.value = res.data.data || []
    }
  } catch (error) {
    console.error('加载课程失败:', error)
    ElMessage.error('加载课程失败')
  }
}

// 加载教师列表
const loadTeachers = async () => {
  try {
    const res = await axios.get('/api/xiaozhi/user/list-by-role', {
      params: { role: 'teacher' }
    })
    if (res.data && res.data.code === 200) {
      teachers.value = res.data.data || []
      return
    }
  } catch (error) {
    console.warn('使用 list-by-role 接口失败，尝试备选方案:', error)
  }
  
  // 备选方案：使用教师排行榜接口
  try {
    const fallbackRes = await axios.get('/api/xiaozhi/user/teachers/ranking')
    if (fallbackRes.data && fallbackRes.data.code === 200) {
      teachers.value = fallbackRes.data.data || []
    } else {
      teachers.value = []
    }
  } catch (e) {
    console.warn('加载教师列表失败，将使用空列表')
    teachers.value = []
  }
}

// 加载学生列表
const loadStudents = async () => {
  try {
    const res = await axios.get('/api/xiaozhi/user/list-by-role', {
      params: { role: 'student' }
    })
    if (res.data && res.data.code === 200) {
      students.value = res.data.data || []
    } else {
      students.value = []
    }
  } catch (error) {
    console.warn('加载学生列表失败，将使用空列表:', error)
    students.value = []
  }
}

// 获取课程名称
const getCourseName = (courseId) => {
  const course = courses.value.find(c => String(c.id) === String(courseId))
  return course?.courseName || '未知课程'
}

// 应用筛选
const applyFilter = () => {
  if (activeTab.value === 'homework') {
    homeworkCurrentPage.value = 1
    // 如果筛选条件改变，重新获取数据
    fetchHomeworks()
  } else {
    examCurrentPage.value = 1
    // 如果筛选条件改变，重新获取数据
    fetchExams()
  }
}

// 重置筛选
const resetFilters = () => {
  searchKeyword.value = ''
  selectedCourseId.value = ''
  selectedTeacherId.value = ''
  selectedStudentId.value = ''
  if (activeTab.value === 'homework') {
    homeworkCurrentPage.value = 1
    fetchHomeworks()
  } else {
    examCurrentPage.value = 1
  }
}

// 作业状态相关
const getHomeworkStatusText = (row) => {
  const now = new Date()
  const dueDate = new Date(row.dueDate)
  if (now > dueDate) {
    return '已截止'
  }
  return '进行中'
}

const getHomeworkStatusTagType = (row) => {
  const now = new Date()
  const dueDate = new Date(row.dueDate)
  if (now > dueDate) {
    return 'danger'
  }
  return 'success'
}

// 考试状态相关
const getExamStatusText = (row) => {
  const now = new Date()
  const examDate = new Date(row.examDate)
  const durationMinutes = row.durationMinutes || 120
  const examEndTime = new Date(examDate.getTime() + durationMinutes * 60 * 1000)
  
  if (now > examEndTime) {
    return '已截止'
  }
  return '进行中'
}

const getExamStatusTagType = (row) => {
  const now = new Date()
  const examDate = new Date(row.examDate)
  const durationMinutes = row.durationMinutes || 120
  const examEndTime = new Date(examDate.getTime() + durationMinutes * 60 * 1000)
  
  if (now > examEndTime) {
    return 'danger'
  }
  return 'success'
}

const calcHomeworkRate = (row) => {
  const total = row.totalStudents || 0
  if (!total) return '0%'
  const done = row.completedCount || 0
  return Math.round((done / total) * 100) + '%'
}

const calcExamRate = (row) => {
  const total = row.totalStudents || 0
  if (!total) return '0%'
  const done = row.completedCount || 0
  return Math.round((done / total) * 100) + '%'
}

const getProgressColor = (percentage) => {
  if (percentage >= 80) return '#67c23a'
  if (percentage >= 60) return '#e6a23c'
  if (percentage >= 40) return '#f56c6c'
  return '#909399'
}

// 操作函数
const editHomework = (row) => {
  // 填充编辑表单
  editHomeworkForm.value = {
    id: row.id,
    title: row.title || '',
    courseId: row.courseId || null,
    teacherId: row.teacherId || null,
    description: row.description || '',
    dueDate: row.dueDate ? (typeof row.dueDate === 'string' ? row.dueDate.split('T')[0] : row.dueDate) : ''
  }
  showEditHomeworkDialog.value = true
}

// 提交编辑作业
const submitEditHomework = async () => {
  if (!editHomeworkFormRef.value) return
  
  try {
    await editHomeworkFormRef.value.validate()
    editHomeworkSubmitting.value = true
    
    const res = await axios.put('/api/xiaozhi/teacher/admin/update-assignment', editHomeworkForm.value)
    if (res.data.code === 200) {
      ElMessage.success('作业更新成功')
      showEditHomeworkDialog.value = false
      // 重新获取作业列表
      await fetchHomeworks()
    } else {
      ElMessage.error('更新失败: ' + res.data.message)
    }
  } catch (e) {
    if (e !== false) { // false 表示表单验证失败
      ElMessage.error('请求错误: ' + e.message)
    }
  } finally {
    editHomeworkSubmitting.value = false
  }
}

const deleteHomework = async (id) => {
  try {
    await ElMessageBox.confirm('确定要删除这个作业吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const res = await axios.delete('/api/xiaozhi/teacher/delete', { params: { assignmentId: id } })
    if (res.data.code === 200) {
      ElMessage.success('删除成功')
      homeworks.value = homeworks.value.filter(h => h.id !== id)
    } else {
      ElMessage.error('删除失败: ' + res.data.message)
    }
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('请求错误: ' + e.message)
    }
  }
}

const editExam = (row) => {
  // 填充编辑表单
  editExamForm.value = {
    id: row.id,
    title: row.title,
    courseId: row.courseId,
    teacherId: row.teacherId,
    description: row.description || '',
    examDate: row.examDate,
    durationMinutes: row.durationMinutes
  }
  showEditExamDialog.value = true
}

const submitEditExam = async () => {
  if (!editExamFormRef.value) return
  
  try {
    await editExamFormRef.value.validate()
    editExamSubmitting.value = true
    
    const res = await axios.put('/api/xiaozhi/teacher/admin/exam/update', editExamForm.value)
    if (res.data.code === 200) {
      ElMessage.success('考试更新成功')
      showEditExamDialog.value = false
      fetchExams() // 重新获取考试列表
    } else {
      ElMessage.error('更新失败: ' + res.data.message)
    }
  } catch (e) {
    if (e !== false) { // 表单验证失败时 e 为 false
      ElMessage.error('请求错误: ' + e.message)
    }
  } finally {
    editExamSubmitting.value = false
  }
}

const deleteExam = async (id) => {
  try {
    await ElMessageBox.confirm('确定要删除这个考试吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const res = await axios.delete('/api/xiaozhi/teacher/exam/delete', { params: { examId: id } })
    if (res.data.code === 200) {
      ElMessage.success('删除成功')
      exams.value = exams.value.filter(e => e.id !== id)
    } else {
      ElMessage.error('删除失败: ' + res.data.message)
    }
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('请求错误: ' + e.message)
    }
  }
}

const formatDate = (value) => {
  if (!value) return '-'
  if (Array.isArray(value)) {
    const [y,m,d,h=0,mi=0,s=0] = value
    if (!y || !m || !d) return '-'
    const dt = new Date(y, m-1, d, h, mi, s)
    return toYMDHM(dt)
  }
  if (typeof value === 'object' && value.year && value.month && value.day) {
    const { year:y, month:m, day:d, hour:h=0, minute:mi=0, second:s=0 } = value
    const dt = new Date(y, m-1, d, h, mi, s)
    return toYMDHM(dt)
  }
  const dt = new Date(value)
  if (isNaN(dt.getTime())) return '-'
  return toYMDHM(dt)
}

const toYMDHM = (dt) => {
  const pad = n => String(n).padStart(2,'0')
  return `${dt.getFullYear()}-${pad(dt.getMonth()+1)}-${pad(dt.getDate())} ${pad(dt.getHours())}:${pad(dt.getMinutes())}`
}

onMounted(async () => {
  await Promise.all([
    loadCourses(),
    loadTeachers(),
    loadStudents()
  ])
  await Promise.all([
    fetchHomeworks(),
    fetchExams()
  ])
})
</script>

<style scoped>
.admin-homework-exam-management {
  width: 100%;
  height: 100%;
  background: transparent;
  padding: 15px;
  overflow-y: auto;
  overflow-x: hidden; /* 避免整体出现横向滚动条 */
  color: #fff;
  box-sizing: border-box; /* 防止 padding 把整体宽度撑出 100% */
}

.management-container {
  width: 100%;
  max-width: 100%;
  margin: 0;
  height: 100%;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
}

/* 页面头部 */
.page-header {
  background: rgba(8, 16, 45, 0.6);
  border: 1px solid rgba(0, 191, 255, 0.3);
  padding: 1.5rem 2rem;
  border-radius: 8px;
  color: #fff;
  margin-bottom: 15px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
  position: relative;
}

.page-header::before {
  content: '';
  position: absolute;
  left: 5px;
  top: 10px;
  width: 4px;
  height: 16px;
  background: #00f2fe;
}

.page-header::after {
  content: '';
  position: absolute;
  top: -1px;
  left: -1px;
  width: 10px;
  height: 10px;
  border: 2px solid #00bfff;
  border-right: none;
  border-bottom: none;
}

.page-header .corner-tr {
  position: absolute;
  top: -1px;
  right: -1px;
  width: 10px;
  height: 10px;
  border: 2px solid #00bfff;
  border-left: none;
  border-bottom: none;
}

.page-header .corner-bl {
  position: absolute;
  bottom: -1px;
  left: -1px;
  width: 10px;
  height: 10px;
  border: 2px solid #00bfff;
  border-right: none;
  border-top: none;
}

.page-header .corner-br {
  position: absolute;
  bottom: -1px;
  right: -1px;
  width: 10px;
  height: 10px;
  border: 2px solid #00bfff;
  border-left: none;
  border-top: none;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  flex: 1;
}

.page-title {
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0 0 0.5rem 0;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: #00f2fe;
}

.title-icon {
  font-size: 1.8rem;
  color: #00bfff;
}

.page-subtitle {
  font-size: 0.9rem;
  color: rgba(255, 255, 255, 0.7);
  margin: 0;
  margin-left: 2.5rem;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.action-btn {
  border-radius: 6px;
  font-weight: 600;
  transition: all 0.3s ease;
  background: linear-gradient(135deg, rgba(0, 191, 255, 0.2), rgba(0, 191, 255, 0));
  border: 1px solid rgba(0, 191, 255, 0.5);
  color: #fff;
}

.action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 0 15px rgba(0, 191, 255, 0.5);
  border-color: #00bfff;
}

/* Tab 区域 */
.tab-section {
  background: rgba(8, 16, 45, 0.6);
  border: 1px solid rgba(0, 191, 255, 0.3);
  padding: 0.5rem 1rem;
  border-radius: 8px;
  margin-bottom: 15px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
  position: relative;
}

.tab-section::before {
  content: '';
  position: absolute;
  left: 5px;
  top: 8px;
  width: 4px;
  height: 16px;
  background: #00f2fe;
}

.tab-section :deep(.el-tabs__header) {
  margin: 0;
}

.tab-section :deep(.el-tabs__nav-wrap::after) {
  background-color: rgba(255, 255, 255, 0.1);
}

.tab-section :deep(.el-tabs__item) {
  color: rgba(255, 255, 255, 0.7);
  font-size: 14px;
}

.tab-section :deep(.el-tabs__item.is-active) {
  color: #00f2fe;
}

.tab-section :deep(.el-tabs__active-bar) {
  background-color: #00bfff;
}

.tab-section :deep(.el-tabs__item:hover) {
  color: #00bfff;
}

.tab-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

/* 搜索区域 */
.search-section {
  background: rgba(8, 16, 45, 0.6);
  border: 1px solid rgba(0, 191, 255, 0.3);
  margin-bottom: 15px;
  padding: 1rem 1.5rem;
  border-radius: 8px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
  position: relative;
}

.search-section::before {
  content: '';
  position: absolute;
  left: 5px;
  top: 8px;
  width: 4px;
  height: 16px;
  background: #00f2fe;
}

.search-section :deep(.el-input__wrapper) {
  background-color: rgba(0, 0, 0, 0.3);
  border: 1px solid rgba(0, 191, 255, 0.3);
  box-shadow: none;
}

.search-section :deep(.el-input__inner) {
  color: #fff;
}

.search-section :deep(.el-input__inner::placeholder) {
  color: rgba(255, 255, 255, 0.5);
}

.search-section :deep(.el-select__wrapper) {
  background-color: rgba(0, 0, 0, 0.3);
  border: 1px solid rgba(0, 191, 255, 0.3);
  box-shadow: none;
}

.search-section :deep(.el-select__placeholder) {
  color: rgba(255, 255, 255, 0.5);
}

.search-bar {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.search-left {
  flex: 1;
}

.search-input {
  width: 100%;
}

.search-right {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.filter-select {
  width: 200px;
}

.reset-btn {
  background: rgba(0, 0, 0, 0.3);
  border: 1px solid rgba(0, 191, 255, 0.3);
  color: rgba(255, 255, 255, 0.8);
  font-weight: 500;
}

.reset-btn:hover {
  background: rgba(0, 191, 255, 0.2);
  border-color: #00bfff;
  color: #fff;
}

/* 表格区域 */
.table-section {
  margin-bottom: 15px;
  min-height: 400px;
  flex: 1;
  display: flex;
  flex-direction: column;
}

/* 主体 + 右侧可视化布局 */
.content-layout {
  display: flex;
  align-items: stretch;
  gap: 16px;
  margin-top: 12px;
}

.main-area {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.insight-sidebar {
  width: 260px;
  max-width: 260px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.table-card {
  border-radius: 8px;
  overflow: visible;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
  background: rgba(8, 16, 45, 0.6);
  border: 1px solid rgba(0, 191, 255, 0.3);
  flex: 1;
  display: flex;
  flex-direction: column;
  position: relative;
}

.insight-card {
  background: radial-gradient(circle at top left, rgba(0, 191, 255, 0.25), rgba(8, 16, 45, 0.95));
  border-radius: 10px;
  border: 1px solid rgba(0, 191, 255, 0.35);
  padding: 14px 16px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.5);
  position: relative;
  overflow: hidden;
}

.insight-card::before {
  content: '';
  position: absolute;
  top: -40%;
  right: -40%;
  width: 120%;
  height: 120%;
  background: radial-gradient(circle, rgba(0, 242, 254, 0.12), transparent 55%);
  opacity: 0.8;
}

.insight-card > * {
  position: relative;
  z-index: 1;
}

.insight-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.insight-title {
  font-size: 14px;
  font-weight: 600;
  color: #00f2fe;
}

.insight-subtitle {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.6);
}

.insight-overview-body {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.ring-wrapper {
  display: flex;
  justify-content: space-between;
  gap: 10px;
}

.ring {
  --percent: 0%;
  width: 90px;
  height: 90px;
  border-radius: 50%;
  background:
    radial-gradient(circle at center, rgba(4, 12, 32, 0.95) 58%, transparent 60%),
    conic-gradient(
      var(--ring-color) var(--percent),
      rgba(30, 60, 90, 0.9) 0
    );
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  box-shadow: 0 0 12px rgba(0, 191, 255, 0.25);
}

.ring-homework {
  --ring-color: #00f2fe;
}

.ring-exam {
  --ring-color: #ffd700;
}

.ring-inner {
  width: 66px;
  height: 66px;
  border-radius: 50%;
  background: radial-gradient(circle at top, #050b1a, #060f24);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  box-shadow: inset 0 0 8px rgba(0, 0, 0, 0.7);
}

.ring-label {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.7);
}

.ring-value {
  font-size: 16px;
  font-weight: 700;
  color: #ffffff;
}

.insight-metrics {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.metric-item {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.8);
}

.metric-item.warning .metric-label {
  color: #ffb74d;
}

.metric-label {
  opacity: 0.8;
}

.metric-value {
  font-weight: 600;
}

.insight-timeline-card {
  flex: 1;
}

.timeline-body {
  margin-top: 6px;
  max-height: 260px;
  overflow-y: auto;
  padding-right: 4px;
}

.timeline-item {
  display: flex;
  gap: 8px;
  padding: 6px 0;
  position: relative;
}

.timeline-item:not(:last-child)::after {
  content: '';
  position: absolute;
  left: 5px;
  top: 18px;
  bottom: -2px;
  width: 1px;
  background: linear-gradient(to bottom, rgba(0, 191, 255, 0.4), transparent);
}

.timeline-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  margin-top: 4px;
  box-shadow: 0 0 8px rgba(0, 191, 255, 0.8);
}

.timeline-dot.type-homework {
  background: #00f2fe;
}

.timeline-dot.type-exam {
  background: #ffd700;
}

.timeline-content {
  flex: 1;
  min-width: 0;
}

.timeline-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2px;
}

.timeline-type {
  font-size: 11px;
  padding: 2px 6px;
  border-radius: 10px;
}

.tag-homework {
  background: rgba(0, 191, 255, 0.2);
  color: #00f2fe;
}

.tag-exam {
  background: rgba(255, 215, 0, 0.2);
  color: #ffd700;
}

.timeline-date {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.6);
}

.timeline-title {
  font-size: 12px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.95);
  margin-bottom: 2px;
  white-space: nowrap;
  text-overflow: ellipsis;
  overflow: hidden;
}

.timeline-meta {
  display: flex;
  justify-content: space-between;
  font-size: 11px;
  color: rgba(255, 255, 255, 0.7);
}

.meta-course {
  max-width: 120px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.meta-progress {
  flex-shrink: 0;
}

.timeline-empty {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.6);
  text-align: center;
  padding: 16px 0;
}

.table-card::before {
  content: '';
  position: absolute;
  top: -1px;
  left: -1px;
  width: 10px;
  height: 10px;
  border: 2px solid #00bfff;
  border-right: none;
  border-bottom: none;
  z-index: 1;
}

.table-card::after {
  content: '';
  position: absolute;
  top: -1px;
  right: -1px;
  width: 10px;
  height: 10px;
  border: 2px solid #00bfff;
  border-left: none;
  border-bottom: none;
  z-index: 1;
}

.table-card .corner-bl {
  position: absolute;
  bottom: -1px;
  left: -1px;
  width: 10px;
  height: 10px;
  border: 2px solid #00bfff;
  border-right: none;
  border-top: none;
  z-index: 1;
}

.table-card .corner-br {
  position: absolute;
  bottom: -1px;
  right: -1px;
  width: 10px;
  height: 10px;
  border: 2px solid #00bfff;
  border-left: none;
  border-top: none;
  z-index: 1;
}

.table-card :deep(.el-card__body) {
  padding: 0;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.management-table {
  border-radius: 8px;
  overflow: hidden;
  background: transparent;
  flex: 1;
}

.management-table :deep(.el-table__header-wrapper) {
  background-color: #071024 !important; /* 彻底覆盖白底 */
}

.management-table :deep(.el-table__header) {
  background-color: #071024 !important;
  border-bottom: 1px solid rgba(0, 191, 255, 0.35);
}

.management-table :deep(.el-table__header tr) {
  background-color: #071024 !important;
}

.management-table :deep(.el-table__header th) {
  background-color: #071024 !important;
  color: #55c3ff;
  border-bottom: none;
  font-weight: 600;
  padding: 14px 12px;
  text-shadow: 0 0 6px rgba(0, 191, 255, 0.25);
}

.management-table :deep(.el-table__header th:first-child) {
  border-left: 2px solid rgba(0, 191, 255, 0.25);
}

.management-table :deep(.el-table__body) {
  background: transparent;
}

.management-table :deep(.el-table__row) {
  background: rgba(5, 10, 25, 0.78);
  transition: all 0.25s ease;
  color: rgba(255, 255, 255, 0.9);
}

.management-table :deep(.el-table__row:nth-child(even)) {
  background: rgba(7, 14, 32, 0.82);
}

.management-table :deep(.el-table__row:hover) {
  background: rgba(5, 18, 40, 0.95);
  transform: translateX(1px);
  box-shadow: -2px 0 8px rgba(0, 191, 255, 0.18), 0 0 10px rgba(0, 191, 255, 0.12);
  border-left: 2px solid rgba(0, 191, 255, 0.4);
}

.management-table :deep(.el-table__row td) {
  border-bottom: 1px solid rgba(0, 191, 255, 0.12);
  padding: 12px 12px;
}

/* 强制覆盖 Element Plus 默认 hover 白底 */
.management-table :deep(.el-table__body tr:hover>td),
.management-table :deep(.el-table__body tr.el-table__row--striped:hover>td) {
  background-color: rgba(5, 18, 40, 0.95) !important;
}

.management-table :deep(.el-table__empty-block) {
  background: transparent;
  color: rgba(255, 255, 255, 0.7);
}

.management-table :deep(.el-loading-mask) {
  background-color: rgba(8, 16, 45, 0.8);
}

.management-table :deep(.el-loading-spinner) {
  color: #00bfff;
}

.management-table :deep(.el-loading-spinner .path) {
  stroke: #00bfff;
}

.item-id {
  font-weight: 600;
  color: #00bfff;
  font-family: 'Courier New', monospace;
  text-shadow: 0 0 5px rgba(0, 191, 255, 0.5);
}

.course-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  justify-content: center;
}

.course-icon {
  color: #00f2fe;
  font-size: 1rem;
}

.item-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.item-icon {
  color: #00bfff;
  font-size: 1rem;
}

.completion-rate {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.progress-bar {
  width: 60px;
}

.rate-text {
  font-size: 12px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.9);
}

.completion-count {
  display: flex;
  align-items: center;
  gap: 4px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.9);
}

.count-icon {
  color: #00bfff;
  font-size: 14px;
}

.due-date,
.exam-date {
  display: flex;
  align-items: center;
  gap: 4px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.9);
}

.date-icon {
  color: #00bfff;
  font-size: 14px;
}

.status-tag {
  font-weight: 600;
  padding: 6px 12px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
}

.status-icon {
  font-size: 12px;
}

.action-buttons {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  justify-content: center;
  flex-wrap: wrap;
}

/* 分页样式 */
.pagination-wrapper {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  background: rgba(8, 16, 45, 0.6);
  border: 1px solid rgba(0, 191, 255, 0.3);
  border-radius: 8px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
  margin-top: 15px;
}

.pagination-info {
  display: flex;
  align-items: center;
}

.pagination-text {
  color: rgba(255, 255, 255, 0.9);
  font-size: 0.9rem;
  font-weight: 500;
}

.pagination {
  --el-pagination-bg-color: transparent;
  --el-pagination-button-bg-color: rgba(0, 191, 255, 0.2);
  --el-pagination-button-color: rgba(255, 255, 255, 0.8);
  --el-pagination-hover-color: #00bfff;
}

.pagination :deep(.el-pager li) {
  border-radius: 6px;
  margin: 0 2px;
  transition: all 0.3s ease;
  background: rgba(0, 191, 255, 0.2);
  color: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(0, 191, 255, 0.3);
}

.pagination :deep(.el-pager li:hover) {
  background: rgba(0, 191, 255, 0.3);
  color: #00bfff;
  border-color: #00bfff;
}

.pagination :deep(.el-pager li.is-active) {
  background: #00bfff;
  color: #fff;
  font-weight: 600;
  border-color: #00bfff;
  box-shadow: 0 0 10px rgba(0, 191, 255, 0.5);
}

.pagination :deep(.btn-prev),
.pagination :deep(.btn-next) {
  border-radius: 6px;
  transition: all 0.3s ease;
  background: rgba(0, 191, 255, 0.2);
  color: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(0, 191, 255, 0.3);
}

.pagination :deep(.btn-prev:hover),
.pagination :deep(.btn-next:hover) {
  background: rgba(0, 191, 255, 0.3);
  color: #00bfff;
  border-color: #00bfff;
}

/* 编辑对话框基础样式 */
:deep(.el-dialog.edit-dialog) {
  border-radius: 12px;
  overflow: hidden;
  position: relative;
}

:deep(.el-dialog.edit-dialog .el-dialog__body) {
  background: transparent;
  color: rgba(255, 255, 255, 0.9);
  padding: 24px;
}

:deep(.el-dialog.edit-dialog .el-form-item__label) {
  color: rgba(255, 255, 255, 0.9);
  font-weight: 500;
}

:deep(.el-dialog.edit-dialog .el-input__wrapper) {
  box-shadow: none;
  transition: all 0.3s ease;
}

:deep(.el-dialog.edit-dialog .el-input__wrapper:hover) {
  box-shadow: 0 0 8px rgba(0, 191, 255, 0.3);
}

:deep(.el-dialog.edit-dialog .el-input__inner) {
  color: #fff;
}

:deep(.el-dialog.edit-dialog .el-select__wrapper) {
  box-shadow: none;
  transition: all 0.3s ease;
}

:deep(.el-dialog.edit-dialog .el-select__wrapper:hover) {
  box-shadow: 0 0 8px rgba(0, 191, 255, 0.3);
}

:deep(.el-dialog.edit-dialog .el-textarea__inner) {
  color: #fff;
  transition: all 0.3s ease;
}

:deep(.el-dialog.edit-dialog .el-textarea__inner:hover) {
  box-shadow: 0 0 8px rgba(0, 191, 255, 0.3);
}

:deep(.el-dialog.edit-dialog .el-date-editor) {
  transition: all 0.3s ease;
}

:deep(.el-dialog.edit-dialog .el-date-editor:hover) {
  box-shadow: 0 0 8px rgba(0, 191, 255, 0.3);
}

:deep(.el-dialog.edit-dialog .el-input-number) {
  width: 100%;
}

:deep(.el-dialog.edit-dialog .el-input-number__decrease),
:deep(.el-dialog.edit-dialog .el-input-number__increase) {
  background-color: rgba(0, 0, 0, 0.3);
  border-color: rgba(0, 191, 255, 0.3);
  color: rgba(255, 255, 255, 0.8);
}

:deep(.el-dialog.edit-dialog .el-input-number__decrease:hover),
:deep(.el-dialog.edit-dialog .el-input-number__increase:hover) {
  color: #00bfff;
}

/* 作业编辑对话框 - 蓝色调 */
:deep(.el-dialog.edit-homework-dialog) {
  background: linear-gradient(135deg, rgba(8, 16, 45, 0.98), rgba(0, 50, 100, 0.95));
  border: 2px solid rgba(0, 191, 255, 0.5);
  box-shadow: 0 0 30px rgba(0, 191, 255, 0.4), inset 0 0 20px rgba(0, 191, 255, 0.1);
  position: relative;
}

:deep(.el-dialog.edit-homework-dialog)::before {
  content: '';
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  background: linear-gradient(45deg, rgba(0, 191, 255, 0.3), rgba(0, 242, 254, 0.3), rgba(0, 191, 255, 0.3));
  background-size: 200% 200%;
  animation: borderGlow 3s ease infinite;
  z-index: -1;
  border-radius: 12px;
}

:deep(.el-dialog.edit-homework-dialog .el-dialog__header) {
  background: linear-gradient(135deg, rgba(0, 191, 255, 0.2), rgba(0, 242, 254, 0.15));
  border-bottom: 2px solid rgba(0, 191, 255, 0.4);
  padding: 20px 24px;
  position: relative;
}

:deep(.el-dialog.edit-homework-dialog .el-dialog__header)::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  width: 4px;
  height: 100%;
  background: linear-gradient(180deg, #00bfff, #00f2fe);
}

:deep(.el-dialog.edit-homework-dialog .el-dialog__title) {
  color: #00f2fe;
  font-weight: 700;
  font-size: 18px;
  text-shadow: 0 0 10px rgba(0, 242, 254, 0.5);
  margin-left: 12px;
}

:deep(.el-dialog.edit-homework-dialog .el-dialog__headerbtn) {
  color: rgba(0, 242, 254, 0.8);
}

:deep(.el-dialog.edit-homework-dialog .el-dialog__headerbtn:hover) {
  color: #00f2fe;
}

:deep(.el-dialog.edit-homework-dialog .el-input__wrapper) {
  background-color: rgba(0, 30, 60, 0.5);
  border: 1px solid rgba(0, 191, 255, 0.4);
}

:deep(.el-dialog.edit-homework-dialog .el-input__wrapper.is-focus) {
  border-color: #00bfff;
  box-shadow: 0 0 12px rgba(0, 191, 255, 0.5);
}

:deep(.el-dialog.edit-homework-dialog .el-select__wrapper) {
  background-color: rgba(0, 30, 60, 0.5);
  border: 1px solid rgba(0, 191, 255, 0.4);
}

:deep(.el-dialog.edit-homework-dialog .el-select__wrapper.is-focused) {
  border-color: #00bfff;
  box-shadow: 0 0 12px rgba(0, 191, 255, 0.5);
}

:deep(.el-dialog.edit-homework-dialog .el-textarea__inner) {
  background-color: rgba(0, 30, 60, 0.5);
  border: 1px solid rgba(0, 191, 255, 0.4);
}

:deep(.el-dialog.edit-homework-dialog .el-textarea__inner:focus) {
  border-color: #00bfff;
  box-shadow: 0 0 12px rgba(0, 191, 255, 0.5);
}

:deep(.el-dialog.edit-homework-dialog .el-date-editor) {
  background-color: rgba(0, 30, 60, 0.5);
  border: 1px solid rgba(0, 191, 255, 0.4);
}

:deep(.el-dialog.edit-homework-dialog .el-date-editor.is-active) {
  border-color: #00bfff;
  box-shadow: 0 0 12px rgba(0, 191, 255, 0.5);
}

:deep(.el-dialog.edit-homework-dialog .el-input-number) {
  background-color: rgba(0, 30, 60, 0.5);
  border: 1px solid rgba(0, 191, 255, 0.4);
}

:deep(.el-dialog.edit-homework-dialog .el-input-number.is-controls-right .el-input__wrapper) {
  background-color: rgba(0, 30, 60, 0.5);
}

/* 考试编辑对话框 - 紫色/金色调 */
:deep(.el-dialog.edit-exam-dialog) {
  background: linear-gradient(135deg, rgba(20, 8, 45, 0.98), rgba(60, 20, 80, 0.95));
  border: 2px solid rgba(138, 43, 226, 0.5);
  box-shadow: 0 0 30px rgba(138, 43, 226, 0.4), inset 0 0 20px rgba(255, 215, 0, 0.1);
  position: relative;
}

:deep(.el-dialog.edit-exam-dialog)::before {
  content: '';
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  background: linear-gradient(45deg, rgba(138, 43, 226, 0.3), rgba(255, 215, 0, 0.2), rgba(138, 43, 226, 0.3));
  background-size: 200% 200%;
  animation: borderGlow 3s ease infinite;
  z-index: -1;
  border-radius: 12px;
}

:deep(.el-dialog.edit-exam-dialog .el-dialog__header) {
  background: linear-gradient(135deg, rgba(138, 43, 226, 0.2), rgba(255, 215, 0, 0.15));
  border-bottom: 2px solid rgba(138, 43, 226, 0.4);
  padding: 20px 24px;
  position: relative;
}

:deep(.el-dialog.edit-exam-dialog .el-dialog__header)::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  width: 4px;
  height: 100%;
  background: linear-gradient(180deg, #8a2be2, #ffd700);
}

:deep(.el-dialog.edit-exam-dialog .el-dialog__title) {
  color: #ffd700;
  font-weight: 700;
  font-size: 18px;
  text-shadow: 0 0 10px rgba(255, 215, 0, 0.5);
  margin-left: 12px;
}

:deep(.el-dialog.edit-exam-dialog .el-dialog__headerbtn) {
  color: rgba(255, 215, 0, 0.8);
}

:deep(.el-dialog.edit-exam-dialog .el-dialog__headerbtn:hover) {
  color: #ffd700;
}

:deep(.el-dialog.edit-exam-dialog .el-input__wrapper) {
  background-color: rgba(30, 10, 50, 0.5);
  border: 1px solid rgba(138, 43, 226, 0.4);
}

:deep(.el-dialog.edit-exam-dialog .el-input__wrapper.is-focus) {
  border-color: #8a2be2;
  box-shadow: 0 0 12px rgba(138, 43, 226, 0.5);
}

:deep(.el-dialog.edit-exam-dialog .el-select__wrapper) {
  background-color: rgba(30, 10, 50, 0.5);
  border: 1px solid rgba(138, 43, 226, 0.4);
}

:deep(.el-dialog.edit-exam-dialog .el-select__wrapper.is-focused) {
  border-color: #8a2be2;
  box-shadow: 0 0 12px rgba(138, 43, 226, 0.5);
}

:deep(.el-dialog.edit-exam-dialog .el-textarea__inner) {
  background-color: rgba(30, 10, 50, 0.5);
  border: 1px solid rgba(138, 43, 226, 0.4);
}

:deep(.el-dialog.edit-exam-dialog .el-textarea__inner:focus) {
  border-color: #8a2be2;
  box-shadow: 0 0 12px rgba(138, 43, 226, 0.5);
}

:deep(.el-dialog.edit-exam-dialog .el-date-editor) {
  background-color: rgba(30, 10, 50, 0.5);
  border: 1px solid rgba(138, 43, 226, 0.4);
}

:deep(.el-dialog.edit-exam-dialog .el-date-editor.is-active) {
  border-color: #8a2be2;
  box-shadow: 0 0 12px rgba(138, 43, 226, 0.5);
}

:deep(.el-dialog.edit-exam-dialog .el-input-number) {
  background-color: rgba(30, 10, 50, 0.5);
  border: 1px solid rgba(138, 43, 226, 0.4);
}

:deep(.el-dialog.edit-exam-dialog .el-input-number.is-controls-right .el-input__wrapper) {
  background-color: rgba(30, 10, 50, 0.5);
}

:deep(.el-dialog.edit-exam-dialog .el-input-number__decrease),
:deep(.el-dialog.edit-exam-dialog .el-input-number__increase) {
  border-color: rgba(138, 43, 226, 0.4);
}

:deep(.el-dialog.edit-exam-dialog .el-input-number__decrease:hover),
:deep(.el-dialog.edit-exam-dialog .el-input-number__increase:hover) {
  color: #8a2be2;
}

/* 边框动画 */
@keyframes borderGlow {
  0%, 100% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding-top: 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

/* 作业对话框按钮 */
.edit-homework-dialog .dialog-footer .el-button {
  background: rgba(0, 191, 255, 0.2);
  border: 1px solid rgba(0, 191, 255, 0.5);
  color: rgba(255, 255, 255, 0.9);
  font-weight: 500;
  transition: all 0.3s ease;
  padding: 10px 20px;
}

.edit-homework-dialog .dialog-footer .el-button:hover {
  background: rgba(0, 191, 255, 0.4);
  border-color: #00bfff;
  box-shadow: 0 0 12px rgba(0, 191, 255, 0.4);
  transform: translateY(-2px);
}

.edit-homework-dialog .dialog-footer .el-button--primary {
  background: linear-gradient(135deg, rgba(0, 191, 255, 0.6), rgba(0, 242, 254, 0.5));
  border-color: #00bfff;
  color: #fff;
  font-weight: 600;
}

.edit-homework-dialog .dialog-footer .el-button--primary:hover {
  background: linear-gradient(135deg, rgba(0, 191, 255, 0.8), rgba(0, 242, 254, 0.7));
  box-shadow: 0 0 15px rgba(0, 191, 255, 0.6);
}

/* 考试对话框按钮 */
.edit-exam-dialog .dialog-footer .el-button {
  background: rgba(138, 43, 226, 0.2);
  border: 1px solid rgba(138, 43, 226, 0.5);
  color: rgba(255, 255, 255, 0.9);
  font-weight: 500;
  transition: all 0.3s ease;
  padding: 10px 20px;
}

.edit-exam-dialog .dialog-footer .el-button:hover {
  background: rgba(138, 43, 226, 0.4);
  border-color: #8a2be2;
  box-shadow: 0 0 12px rgba(138, 43, 226, 0.4);
  transform: translateY(-2px);
}

.edit-exam-dialog .dialog-footer .el-button--primary {
  background: linear-gradient(135deg, rgba(138, 43, 226, 0.6), rgba(255, 215, 0, 0.4));
  border-color: #8a2be2;
  color: #fff;
  font-weight: 600;
}

.edit-exam-dialog .dialog-footer .el-button--primary:hover {
  background: linear-gradient(135deg, rgba(138, 43, 226, 0.8), rgba(255, 215, 0, 0.6));
  box-shadow: 0 0 15px rgba(138, 43, 226, 0.6);
}

/* 下拉选项样式 */
.edit-homework-dialog :deep(.el-select-dropdown) {
  background: rgba(8, 16, 45, 0.95);
  border: 1px solid rgba(0, 191, 255, 0.4);
}

.edit-homework-dialog :deep(.el-select-dropdown__item) {
  color: rgba(255, 255, 255, 0.9);
}

.edit-homework-dialog :deep(.el-select-dropdown__item:hover) {
  background: rgba(0, 191, 255, 0.2);
  color: #00f2fe;
}

.edit-homework-dialog :deep(.el-select-dropdown__item.is-selected) {
  background: rgba(0, 191, 255, 0.3);
  color: #00f2fe;
}

.edit-exam-dialog :deep(.el-select-dropdown) {
  background: rgba(20, 8, 45, 0.95);
  border: 1px solid rgba(138, 43, 226, 0.4);
}

.edit-exam-dialog :deep(.el-select-dropdown__item) {
  color: rgba(255, 255, 255, 0.9);
}

.edit-exam-dialog :deep(.el-select-dropdown__item:hover) {
  background: rgba(138, 43, 226, 0.2);
  color: #ffd700;
}

.edit-exam-dialog :deep(.el-select-dropdown__item.is-selected) {
  background: rgba(138, 43, 226, 0.3);
  color: #ffd700;
}

/* 日期选择器下拉样式 */
.edit-homework-dialog :deep(.el-picker__popper) {
  background: rgba(8, 16, 45, 0.95);
  border: 1px solid rgba(0, 191, 255, 0.4);
}

.edit-exam-dialog :deep(.el-picker__popper) {
  background: rgba(20, 8, 45, 0.95);
  border: 1px solid rgba(138, 43, 226, 0.4);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .admin-homework-exam-management {
    padding: 10px;
  }

  .page-header {
    margin-bottom: 1rem;
    padding: 1.5rem;
  }

  .header-content {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
  }

  .header-right {
    width: 100%;
    flex-direction: column;
  }

  .search-section {
    margin-bottom: 1rem;
    padding: 1rem;
  }

  .search-bar {
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
  }

  .search-right {
    justify-content: space-between;
  }

  .filter-select {
    width: 150px;
  }

  .pagination-wrapper {
    flex-direction: column;
    gap: 1rem;
    align-items: center;
    padding: 1rem;
  }
}
</style>
