<template>
  <div class="visual-container">
    <div class="analysis-layout">
      <!-- 左侧栏：班级信息 -->
      <div class="column left-col">
        <!-- 班级基本信息 -->
        <div class="panel-box class-info-panel">
          <div class="panel-header">班级概览 | Class Overview</div>
          <div class="panel-content class-info-content">
            <div class="info-row">
              <span class="label">班级名称：</span>
              <el-select 
                v-model="currentClassId" 
                placeholder="请选择班级" 
                size="small" 
                @change="handleClassChange" 
                class="class-selector"
                popper-class="tech-select-popper"
              >
                <el-option
                  v-for="item in classList"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
            </div>
            <div class="info-row">
              <span class="label">班主任：</span><span class="value">{{ currentTeacher }}</span>
            </div>
            <div class="stats-grid">
              <div class="stat-item">
                <div class="num">{{ classStats.totalCount }}</div>
                <div class="desc">人数</div>
              </div>
              <div class="stat-item">
                <div class="num">{{ classStats.avgScore }}</div>
                <div class="desc">平均学习积分</div>
              </div>
              <div class="stat-item">
                <div class="num">{{ classStats.excellentRate }}</div>
                <div class="desc">优秀率</div>
              </div>
            </div>
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>

        <!-- 班级科目分布 -->
        <div class="panel-box">
          <div class="panel-header">班级科目分布</div>
          <div class="panel-content">
            <v-chart class="chart" :option="courseDistributionOption" autoresize />
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>

        <!-- 学习行为指标 -->
        <div class="panel-box behavior-panel">
          <div class="panel-header">
            <span>学习行为指标</span>
            <el-select 
              v-model="selectedBehaviorCourseId" 
              placeholder="全部学科" 
              size="small" 
              clearable
              @change="updateBehaviorData"
              class="course-filter-selector"
              popper-class="tech-select-popper"
              style="width: 150px; margin-left: 10px;"
            >
              <el-option label="全部学科" :value="null" />
              <el-option
                v-for="course in behaviorCourseList"
                :key="course.id"
                :label="course.name"
                :value="course.id"
              />
            </el-select>
          </div>
          <div class="panel-content">
            <div class="behavior-list">
              <div class="b-item" v-for="(item, idx) in behaviorData" :key="idx">
                <div class="b-label">{{ item.label }}</div>
                <div class="b-bar-bg">
                  <div class="b-bar-fill" :style="{width: item.pct, background: item.color}"></div>
                </div>
                <div class="b-val" :style="{color: item.color}">{{ item.value }}</div>
              </div>
            </div>
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>
      </div>

      <!-- 中间栏：动态学习热力图 -->
      <div class="column center-col">
        <div class="center-map-area">
          <div class="map-header">
            <span>班级学习热力图 | Class Heatmap</span>
            <div class="header-actions">
              <el-button size="small" type="primary" @click="showAddStudentDialog" class="action-btn">
                <el-icon><Plus /></el-icon>
                添加学生
              </el-button>
              <el-button 
                size="small" 
                :type="removeMode ? 'danger' : 'warning'" 
                @click="toggleRemoveMode" 
                class="action-btn"
              >
                <el-icon><Delete /></el-icon>
                {{ removeMode ? '取消移除' : '移除学生' }}
              </el-button>
              <el-button 
                v-if="removeMode && selectedStudents.length > 0"
                size="small" 
                type="danger" 
                @click="batchRemoveStudents" 
                class="action-btn"
              >
                <el-icon><DeleteFilled /></el-icon>
                批量移除 ({{ selectedStudents.length }})
              </el-button>
              <el-button 
                v-if="currentStudent"
                size="small" 
                type="success" 
                @click="showLearningAnalysis" 
                class="action-btn"
              >
                <el-icon><DataLine /></el-icon>
                学情分析
              </el-button>
            </div>
          </div>
          
          <!-- Grid 布局模拟座位热力图 -->
          <div class="heatmap-grid">
            <div 
              v-for="stu in studentList" 
              :key="stu.id" 
              class="student-seat" 
              :class="['status-' + stu.statusClass, {active: currentStudent?.id === stu.id}]"
              @click="removeMode ? null : selectStudent(stu)"
              @mouseenter="showStudentTooltip(stu, $event)"
              @mouseleave="hideStudentTooltip"
            >
              <div v-if="removeMode" class="seat-checkbox">
                <el-checkbox 
                  :model-value="selectedStudents.includes(stu.id)"
                  @change="toggleStudentSelection(stu.id)"
                  @click.stop
                />
              </div>
              <div class="seat-avatar">
                <el-avatar :size="30" :src="stu.avatar" >{{ stu.name.substring(0,1) }}</el-avatar>
              </div>
              <div class="seat-info">
                <span class="seat-name">{{ stu.name }}</span>
                <span class="seat-sex">
                  <el-icon v-if="stu.sex === '男'" color="#409eff"><Male /></el-icon>
                  <el-icon v-else color="#f56c6c"><Female /></el-icon>
                </span>
              </div>
              <div class="seat-score">{{ stu.score }}</div>
            </div>
          </div>
          
          <!-- 悬浮学生信息卡片 (模拟) -->
          <div class="student-card-float" v-if="currentStudent">
            <div class="s-avatar"><el-icon><UserFilled /></el-icon></div>
            <div class="s-info">
              <div class="s-name">{{ currentStudent.name }}</div>
              <div class="s-score">总分: {{ currentStudent.score }}</div>
              <div class="s-tag" :class="currentStudent.statusClass">{{ currentStudent.statusText }}</div>
            </div>
          </div>
          
          <!-- 鼠标悬停时的学生详细信息提示框 -->
          <div 
            v-if="hoveredStudent && tooltipPosition" 
            class="student-tooltip"
            :style="{
              left: tooltipPosition.x + 'px',
              top: tooltipPosition.y + 'px'
            }"
          >
            <div class="tooltip-header">
              <div class="tooltip-avatar">
                <el-avatar :size="40" :src="hoveredStudent.avatar">{{ hoveredStudent.name.substring(0,1) }}</el-avatar>
              </div>
              <div class="tooltip-name-section">
                <div class="tooltip-name">{{ hoveredStudent.name }}</div>
                <div class="tooltip-sex">
                  <el-icon v-if="hoveredStudent.sex === '男'" color="#409eff"><Male /></el-icon>
                  <el-icon v-else color="#f56c6c"><Female /></el-icon>
                  <span>{{ hoveredStudent.sex }}</span>
                </div>
              </div>
            </div>
            <div class="tooltip-divider"></div>
            <div class="tooltip-content">
              <div class="tooltip-item">
                <span class="tooltip-label">学习积分：</span>
                <span class="tooltip-value">{{ hoveredStudent.score }}</span>
              </div>
              <div class="tooltip-item">
                <span class="tooltip-label">作业状态：</span>
                <span class="tooltip-value" :class="hoveredStudent.homework === 'ok' ? 'text-green' : 'text-warning'">
                  <el-icon v-if="hoveredStudent.homework === 'ok'" color="#67c23a"><Check /></el-icon>
                  <el-icon v-else color="#e6a23c"><Warning /></el-icon>
                  {{ hoveredStudent.homework === 'ok' ? '已完成' : '待完成' }}
                </span>
              </div>
              <div class="tooltip-item">
                <span class="tooltip-label">AI练习：</span>
                <span class="tooltip-value">{{ hoveredStudent.aiCount }}次</span>
              </div>
              <div class="tooltip-item">
                <span class="tooltip-label">学习状态：</span>
                <span class="tooltip-value" :class="'status-' + hoveredStudent.statusClass">
                  {{ hoveredStudent.statusText }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- 底部功能按钮 (已移除，使用全局底部导航) -->
      </div>

      <!-- 右侧栏：学生个人学情详情 -->
      <div class="column right-col">
        <!-- 可切换的图表区域 -->
        <div class="panel-box">
          <div class="panel-header">
            <span>{{ chartTitles[currentChartType] }}</span>
            <div class="chart-switch-btns">
              <button 
                v-for="(title, key) in chartTitles" 
                :key="key"
                @click="switchChart(key)"
                :class="['switch-btn', {active: currentChartType === key}]"
              >
                {{ title.split('|')[0].trim() }}
              </button>
            </div>
          </div>
          <div class="panel-content">
            <v-chart class="chart" :option="currentChartOption" autoresize />
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>

        <!-- 作业提交记录 -->
        <div class="panel-box">
          <div class="panel-header">
            <span>作业提交记录 | Homework</span>
            <el-select 
              v-model="selectedCourseId" 
              placeholder="全部学科" 
              size="small" 
              clearable
              @change="filterRecords"
              class="course-filter-selector"
              popper-class="tech-select-popper"
              style="width: 150px; margin-left: 10px;"
            >
              <el-option label="全部学科" :value="null" />
              <el-option
                v-for="course in courseList"
                :key="course.id"
                :label="course.name"
                :value="course.id"
              />
            </el-select>
          </div>
          <div class="panel-content record-list">
             <div class="list-header-row">
                 <span>标题</span><span>提交时间</span><span>分数</span><span>状态</span><span>操作</span>
             </div>
             <div class="list-body-scroll">
                <div v-if="filteredHomeworkRecords.length === 0" class="empty-tip">目前该同学暂无作业</div>
                <div v-for="(hw, i) in filteredHomeworkRecords" :key="i" class="record-row">
                    <span class="title-cell">{{ hw.title || '未知作业' }}</span>
                    <span>{{ formatTime(hw.submittedAt) }}</span>
                    <span :class="getScoreClass(hw.score)">{{ hw.score || '-' }}</span>
                    <span>{{ hw.isLate ? '迟交' : '正常' }}</span>
                    <span><el-button size="small" type="primary" @click="viewAssignmentDetail(hw.id)">查看</el-button></span>
                </div>
             </div>
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>

        <!-- 考试记录 -->
        <div class="panel-box">
          <div class="panel-header">
            <span>考试记录 | Exams</span>
            <el-select 
              v-model="selectedExamCourseId" 
              placeholder="全部学科" 
              size="small" 
              clearable
              @change="filterRecords"
              class="course-filter-selector"
              popper-class="tech-select-popper"
              style="width: 150px; margin-left: 10px;"
            >
              <el-option label="全部学科" :value="null" />
              <el-option
                v-for="course in courseList"
                :key="course.id"
                :label="course.name"
                :value="course.id"
              />
            </el-select>
          </div>
          <div class="panel-content record-list">
             <div class="list-header-row">
                 <span>标题</span><span>考试时间</span><span>分数</span><span>操作</span>
             </div>
             <div class="list-body-scroll">
                <div v-if="filteredExamRecords.length === 0" class="empty-tip">暂无考试记录</div>
                 <div v-for="(ex, i) in filteredExamRecords" :key="i" class="record-row">
                    <span class="title-cell">{{ ex.title || '未知考试' }}</span>
                    <span>{{ formatTime(ex.submittedAt) }}</span>
                    <span :class="getScoreClass(ex.score)">{{ ex.score || '-' }}</span>
                    <span><el-button size="small" type="primary" @click="viewExamDetail(ex.id)">查看</el-button></span>
                </div>
             </div>
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>

      </div>
    </div>

    <!-- 作业详情弹窗 - 自定义科技风格 -->
    <div v-if="assignmentDialogVisible" class="custom-dialog-overlay" @click.self="handleCloseDialog">
      <div class="custom-dialog tech-dialog-box">
        <div class="dialog-header">
          <div class="header-title">
            <span class="title-icon">📋</span>
            <span class="title-text">作业答题详情</span>
            <div class="title-line"></div>
          </div>
          <button class="close-btn" @click="handleCloseDialog">
            <el-icon><Close /></el-icon>
          </button>
        </div>
        <div class="dialog-body">
          <div class="custom-table-container">
            <table class="custom-tech-table">
              <thead>
                <tr>
                  <th>题目名称</th>
                  <th>题目类型</th>
                  <th>学生答案</th>
                  <th>正确答案</th>
                  <th>得分</th>
                  <th>是否正确</th>
                  <th>知识点</th>
                  <th>错误原因</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="assignmentDetailList.length === 0">
                  <td colspan="8" class="empty-cell">暂无数据</td>
                </tr>
                <tr v-for="(row, index) in assignmentDetailList" :key="index">
                  <td>
                    <div class="question-content">{{ row.content || '暂无题目内容' }}</div>
                  </td>
                  <td>
                    <span class="type-tag">{{ getQuestionTypeName(row.type) }}</span>
                  </td>
                  <td>
                    <div class="answer-text">{{ row.answerText || '未作答' }}</div>
                  </td>
                  <td>
                    <div class="correct-answer">{{ row.answer || '暂无' }}</div>
                  </td>
                  <td>
                    <span :class="getScoreClass(row.score)">{{ row.score ?? '-' }}</span>
                  </td>
                  <td>
                    <span :class="row.isCorrect ? 'status-correct' : 'status-error'">
                      {{ row.isCorrect ? '正确' : '错误' }}
                    </span>
                  </td>
                  <td>
                    <span class="knowledge-tag">{{ row.knowledgePoint || '暂无' }}</span>
                  </td>
                  <td>
                    <div class="error-reason">{{ row.errorReason || '-' }}</div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- 考试详情弹窗 - 自定义科技风格 -->
    <div v-if="examDialogVisible" class="custom-dialog-overlay" @click.self="handleCloseDialog">
      <div class="custom-dialog tech-dialog-box">
        <div class="dialog-header">
          <div class="header-title">
            <span class="title-icon">📝</span>
            <span class="title-text">考试答题详情</span>
            <div class="title-line"></div>
          </div>
          <button class="close-btn" @click="handleCloseDialog">
            <el-icon><Close /></el-icon>
          </button>
        </div>
        <div class="dialog-body">
          <div class="custom-table-container">
            <table class="custom-tech-table">
              <thead>
                <tr>
                  <th>题目ID</th>
                  <th>学生答案</th>
                  <th>是否正确</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="examDetailList.length === 0">
                  <td colspan="3" class="empty-cell">暂无数据</td>
                </tr>
                <tr v-for="(row, index) in examDetailList" :key="index">
                  <td>{{ row.questionId || '-' }}</td>
                  <td>
                    <div class="answer-text">{{ row.answer || '未作答' }}</div>
                  </td>
                  <td>
                    <span :class="row.correct ? 'status-correct' : 'status-error'">
                      {{ row.correct ? '正确' : '错误' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- 添加学生弹窗 -->
    <div v-if="addStudentDialogVisible" class="custom-dialog-overlay" @click.self="cancelAddStudents">
      <div class="custom-dialog tech-dialog-box add-student-dialog">
        <div class="dialog-header">
          <div class="header-title">
            <span class="title-icon">➕</span>
            <span class="title-text">添加学生到班级</span>
            <div class="title-line"></div>
          </div>
          <button class="close-btn" @click="cancelAddStudents">
            <el-icon><Close /></el-icon>
          </button>
        </div>
        <div class="dialog-body">
          <div class="add-student-content">
            <div class="search-input-wrapper">
              <el-input
                v-model="studentIdInput"
                placeholder="输入学号进行添加"
                size="large"
                class="student-id-input"
                @keyup.enter="handleAddStudentById"
              >
                <template #append>
                  <el-button @click="handleAddStudentById" :loading="addingStudent">
                    <el-icon><Plus /></el-icon>
                    添加
                  </el-button>
                </template>
              </el-input>
            </div>
            <div v-if="addStudentResult" class="add-student-result" :class="addStudentResult.type">
              <el-icon v-if="addStudentResult.type === 'success'"><CircleCheckFilled /></el-icon>
              <el-icon v-else><WarningFilled /></el-icon>
              <span>{{ addStudentResult.message }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 批量移除确认弹窗 -->
    <div v-if="batchRemoveConfirmVisible" class="custom-dialog-overlay" @click.self="cancelBatchRemove">
      <div class="custom-dialog tech-dialog-box remove-confirm-dialog">
        <div class="dialog-header">
          <div class="header-title">
            <span class="title-icon">⚠️</span>
            <span class="title-text">确认批量移除学生</span>
            <div class="title-line"></div>
          </div>
          <button class="close-btn" @click="cancelBatchRemove">
            <el-icon><Close /></el-icon>
          </button>
        </div>
        <div class="dialog-body">
          <div class="confirm-content">
            <p class="confirm-message">
              确定要将以下 <span class="student-name-highlight">{{ selectedStudents.length }}</span> 名学生移出该班级吗？
            </p>
            <div class="selected-students-list">
              <div 
                v-for="stuId in selectedStudents" 
                :key="stuId"
                class="selected-student-item"
              >
                {{ studentList.find(s => s.id === stuId)?.name || '未知学生' }}
              </div>
            </div>
            <p class="confirm-warning">此操作不可撤销，请谨慎操作！</p>
          </div>
          <div class="confirm-buttons">
            <button class="confirm-btn cancel-btn" @click="cancelBatchRemove">取消</button>
            <button class="confirm-btn confirm-primary-btn" @click="confirmBatchRemove">确定移除</button>
          </div>
        </div>
      </div>
    </div>

    <!-- 移除学生确认弹窗 -->
    <div v-if="removeConfirmVisible" class="custom-dialog-overlay" @click.self="cancelRemove">
      <div class="custom-dialog tech-dialog-box remove-confirm-dialog">
        <div class="dialog-header">
          <div class="header-title">
            <span class="title-icon">⚠️</span>
            <span class="title-text">确认移除学生</span>
            <div class="title-line"></div>
          </div>
          <button class="close-btn" @click="cancelRemove">
            <el-icon><Close /></el-icon>
          </button>
        </div>
        <div class="dialog-body">
          <div class="confirm-content">
            <p class="confirm-message">
              确定要将 <span class="student-name-highlight">{{ removeTargetStudent?.name }}</span> 移出该班级吗？
            </p>
            <p class="confirm-warning">此操作不可撤销，请谨慎操作！</p>
          </div>
          <div class="confirm-buttons">
            <button class="confirm-btn cancel-btn" @click="cancelRemove">取消</button>
            <button class="confirm-btn confirm-primary-btn" @click="confirmRemove">确定移除</button>
          </div>
        </div>
      </div>
    </div>

    <!-- AI智能学情分析弹窗 -->
    <div v-if="learningAnalysisVisible" class="custom-dialog-overlay" @click.self="closeLearningAnalysis">
      <div class="custom-dialog tech-dialog-box learning-analysis-dialog">
        <div class="dialog-header">
          <div class="header-title">
            <span class="title-icon">🤖</span>
            <span class="title-text">AI智能学情分析 - {{ currentStudent?.name }}</span>
            <div class="title-line"></div>
          </div>
          <div class="header-actions">
            <el-button 
              v-if="!analysisLoading && analysisResult"
              size="small" 
              type="primary" 
              @click="exportReport"
              :loading="exporting"
              class="export-btn"
            >
              <el-icon><Download /></el-icon>
              导出报告
            </el-button>
            <button class="close-btn" @click="closeLearningAnalysis">
              <el-icon><Close /></el-icon>
            </button>
          </div>
        </div>
        <div class="dialog-body learning-analysis-body">
          <div v-if="analysisLoading" class="analysis-loading">
            <el-icon class="is-loading"><Loading /></el-icon>
            <span>AI正在分析中，请稍候...</span>
          </div>
          <div v-else class="analysis-content">
            <div class="analysis-text" v-html="formatAnalysisText(analysisResult)"></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { PieChart, BarChart, LineChart, RadarChart, ScatterChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
  VisualMapComponent
} from 'echarts/components'
import VChart from 'vue-echarts'
import { 
  Check, Warning, UserFilled, DataLine, 
  TrendCharts, List, CircleCheckFilled, 
  WarningFilled, CircleCloseFilled,
  Monitor, Notebook, Timer,
  Male, Female, Close, Delete, Plus, DeleteFilled, Loading, Download
} from '@element-plus/icons-vue'

import http from '@/api/http.js'

use([
  CanvasRenderer, PieChart, BarChart, LineChart, RadarChart, ScatterChart,
  TitleComponent, TooltipComponent, LegendComponent, GridComponent, VisualMapComponent
])

import { ElMessage } from 'element-plus'

const classList = ref([])
const currentClassId = ref(null)
const currentTeacher = ref('张老师')

// 弹窗相关
const assignmentDialogVisible = ref(false)
const examDialogVisible = ref(false)
const assignmentDetailList = ref([])
const examDetailList = ref([])

// 移除学生相关
const removeConfirmVisible = ref(false)
const removeTargetStudent = ref(null)
const removeMode = ref(false)
const selectedStudents = ref([])
const batchRemoveConfirmVisible = ref(false)

// 添加学生相关
const addStudentDialogVisible = ref(false)
const studentIdInput = ref('')
const addingStudent = ref(false)
const addStudentResult = ref(null)

// AI学情分析相关
const learningAnalysisVisible = ref(false)
const analysisLoading = ref(false)
const analysisResult = ref('')
const exporting = ref(false)

// Fetch Classes
const fetchClasses = async () => {
  try {
    const res = await http.get({ url: '/api/class/list' })
    if (res.code === 200 && res.data) {
      classList.value = res.data
      if (classList.value.length > 0) {
        currentClassId.value = classList.value[0].id
        handleClassChange()
      } else {
        ElMessage.warning('暂无班级数据')
      }
    } else {
      ElMessage.error('获取班级列表失败')
    }
  } catch (e) {
    ElMessage.error('网络连接错误，无法获取班级列表')
  }
}

const handleClassChange = async () => {
  if (!currentClassId.value) return
  
  try {
    // 获取班级概览信息 (Mock teacher for now or update API to return teacher)
    const resOverview = await http.get({ url: `/api/class/${currentClassId.value}/overview` })
    if (resOverview.code === 200 && resOverview.data) {
        // Update stats if needed, currently using static layout for stats
        // If overview returns teacherName:
        if (resOverview.data.teacherName) {
            currentTeacher.value = resOverview.data.teacherName
        }
        
        // 更新班级科目分布图
        if (resOverview.data.courseDistribution && resOverview.data.courseDistribution.length > 0) {
          const courseData = resOverview.data.courseDistribution.map(course => ({
            value: course.studentCount,
            name: course.courseName || '未知科目'
          }))
          courseDistributionOption.value.series[0].data = courseData
          
          // 更新行为指标的课程列表
          behaviorCourseList.value = resOverview.data.courseDistribution.map(course => ({
            id: course.courseId,
            name: course.courseName
          }))
        } else {
          // 如果没有科目数据，显示空状态
          courseDistributionOption.value.series[0].data = [
            { value: 0, name: '暂无科目数据' }
          ]
          behaviorCourseList.value = []
        }
        
        // 初始化行为指标数据
        await updateBehaviorData()
    }

    const res = await http.get({ url: `/api/class/${currentClassId.value}/students` })
    if (res.code === 200 && res.data) {
      studentList.value = res.data.map(u => ({
        id: u.id,
        name: u.realName || u.username,
        score: u.studyScore || 0,
        sex: u.sex || '男',
        avatar: u.avatarUrl,
        homework: u.studyScore > 80 ? 'ok' : 'warn', // Simple logic based on score
        aiCount: u.id * 5 % 50 + 10, // Deterministic mock for demo if not in DB
        statusText: (u.studyScore || 0) > 90 ? '高活跃' : ((u.studyScore || 0) < 60 ? '需关注' : '正常'),
        statusClass: (u.studyScore || 0) > 90 ? 'high' : ((u.studyScore || 0) < 60 ? 'warn' : 'normal')
      }))
      // 默认选中第一个
      if(studentList.value.length > 0) {
          selectStudent(studentList.value[0])
      }
    } else {
      studentList.value = []
      ElMessage.warning('该班级暂无学生数据')
    }
  } catch (e) {
    ElMessage.error('获取学生数据失败')
    studentList.value = []
  }
}

onMounted(() => {
  fetchClasses()
})

// 班级科目分布图表
const courseDistributionOption = ref({
  color: ['#00bfff', '#00f2fe', '#4facfe', '#7c3aed', '#67c23a', '#e6a23c', '#f56c6c', '#909399'],
  tooltip: {
    trigger: 'item',
    formatter: '{b}: {c}人 ({d}%)'
  },
  legend: {
    orient: 'vertical',
    left: 'left',
    textStyle: { color: '#fff' }
  },
  series: [{
    type: 'pie',
    radius: ['40%', '70%'],
    center: ['50%', '50%'],
    label: { 
      show: true, 
      color: '#fff', 
      formatter: '{b}\n{c}人' 
    },
    emphasis: {
      label: {
        show: true,
        fontSize: 14,
        fontWeight: 'bold'
      }
    },
    data: []
  }]
})

const behaviorData = ref([
  { label: '作业完成率', value: '0%', pct: '0%', color: '#67c23a' },
  { label: '考试完成率', value: '0%', pct: '0%', color: '#e6a23c' },
  { label: '作业平均成绩', value: '0', pct: '0%', color: '#f56c6c' },
  { label: '考试平均成绩', value: '0', pct: '0%', color: '#00bfff' }
])

const studentList = ref([])
const currentStudent = ref(null)
const hoveredStudent = ref(null)
const tooltipPosition = ref(null)
const behaviorCourseList = ref([])
const selectedBehaviorCourseId = ref(null)

const homeworkRecords = ref([])
const examRecords = ref([])
const courseList = ref([])
const selectedCourseId = ref(null)
const selectedExamCourseId = ref(null)

// 班级统计数据 - 计算属性
const classStats = computed(() => {
  const totalCount = studentList.value.length
  
  if (totalCount === 0) {
    return {
      totalCount: 0,
      avgScore: '0.0',
      excellentRate: '0%'
    }
  }
  
  // 计算平均学习积分
  const totalScore = studentList.value.reduce((sum, stu) => sum + (stu.score || 0), 0)
  const avgScore = (totalScore / totalCount).toFixed(1)
  
  // 计算优秀率（学习积分 > 100分）
  const excellentCount = studentList.value.filter(stu => (stu.score || 0) > 100).length
  const excellentRate = ((excellentCount / totalCount) * 100).toFixed(1) + '%'
  
  return {
    totalCount,
    avgScore,
    excellentRate
  }
})

const loginTrendOption = ref({})
const homeworkLineOption = ref({})
const examLineOption = ref({})

// 图表切换相关
const currentChartType = ref('login')
const chartTitles = {
  login: '登录记录趋势',
  homework: '作业成绩趋势',
  exam: '考试成绩趋势'
}

const currentChartOption = computed(() => {
  if (currentChartType.value === 'login') return loginTrendOption.value
  if (currentChartType.value === 'homework') return homeworkLineOption.value
  if (currentChartType.value === 'exam') return examLineOption.value
  return {}
})

const switchChart = (type) => {
  currentChartType.value = type
}

// 筛选后的作业记录
const filteredHomeworkRecords = computed(() => {
  if (!selectedCourseId.value) {
    return homeworkRecords.value
  }
  return homeworkRecords.value.filter(hw => hw.courseId === selectedCourseId.value)
})

// 筛选后的考试记录
const filteredExamRecords = computed(() => {
  if (!selectedExamCourseId.value) {
    return examRecords.value
  }
  return examRecords.value.filter(ex => ex.courseId === selectedExamCourseId.value)
})

// 筛选记录（当选择改变时触发，这里主要是为了响应式更新）
const filterRecords = () => {
  // 计算属性会自动更新，这里不需要额外操作
}

const selectStudent = async (stu) => {
  if (currentStudent.value && currentStudent.value.id === stu.id) return
  currentStudent.value = stu
  
  // 清空数据以显示变化
  loginTrendOption.value = {}
  homeworkRecords.value = []
  examRecords.value = []
  homeworkLineOption.value = {}
  examLineOption.value = {}
  currentChartType.value = 'login' // 重置为登录趋势

  // Fetch detailed data
  try {
      const res = await http.get({ url: `/api/class/student/${stu.id}/details` })
      if(res.code === 200 && res.data) {
          const data = res.data
          
          // 1. Login Trend
          loginTrendOption.value = {
              grid: { top: 30, bottom: 20, left: 30, right: 10 },
              tooltip: { trigger: 'axis' },
              xAxis: { type: 'category', data: data.loginDates, axisLabel: { color: '#ccc' } },
              yAxis: { type: 'value', axisLabel: { color: '#ccc' }, splitLine: { lineStyle: { color: '#333' } } },
              series: [{
                  data: data.loginCounts,
                  type: 'line',
                  smooth: true,
                  areaStyle: { opacity: 0.3, color: '#00f2fe' },
                  itemStyle: { color: '#00f2fe' }
              }]
          }

          // 2. Homework Records
          homeworkRecords.value = data.assignments || []
          
          // 3. Exam Records
          examRecords.value = data.exams || []
          
          // 4. Course List for filtering
          courseList.value = data.courses || []
          selectedCourseId.value = null
          selectedExamCourseId.value = null

          // 4. Line Charts for homework and exam scores
          homeworkLineOption.value = {
              grid: { top: 30, bottom: 20, left: 40, right: 10 },
              tooltip: { trigger: 'axis' },
              xAxis: { 
                  type: 'category', 
                  data: data.homeworkLabels || ['作业1', '作业2', '作业3'], 
                  axisLabel: { color: '#ccc', interval: 0, rotate: 45 } 
              },
              yAxis: { 
                  type: 'value', 
                  axisLabel: { color: '#ccc' }, 
                  splitLine: { lineStyle: { color: '#333' } },
                  min: 0,
                  max: 100
              },
              series: [{
                  data: data.homeworkScores,
                  type: 'line',
                  smooth: true,
                  areaStyle: { opacity: 0.3, color: '#67c23a' },
                  itemStyle: { color: '#67c23a' },
                  lineStyle: { width: 2 }
              }]
          }

          examLineOption.value = {
              grid: { top: 30, bottom: 20, left: 40, right: 10 },
              tooltip: { trigger: 'axis' },
              xAxis: { 
                  type: 'category', 
                  data: data.examScores.map((_, i) => `考试${i+1}`), 
                  axisLabel: { color: '#ccc' } 
              },
              yAxis: { 
                  type: 'value', 
                  axisLabel: { color: '#ccc' }, 
                  splitLine: { lineStyle: { color: '#333' } },
                  min: 0,
                  max: 100
              },
              series: [{
                  data: data.examScores,
                  type: 'line',
                  smooth: true,
                  areaStyle: { opacity: 0.3, color: '#e6a23c' },
                  itemStyle: { color: '#e6a23c' },
                  lineStyle: { width: 2 }
              }]
          }
      }
  } catch(e) {
      console.error('获取学生详细信息失败:', e)
      ElMessage.error('获取学生详细信息失败，请检查后端服务和数据库')
  }
}

// 查看作业详情
const viewAssignmentDetail = async (submissionId) => {
  try {
    console.log('查看作业详情，submissionId:', submissionId)
    const res = await http.get({ url: `/api/class/assignment/${submissionId}/details` })
    console.log('作业详情API返回:', res)
    if (res.code === 200 && res.data) {
      assignmentDetailList.value = res.data
      console.log('作业详情列表:', assignmentDetailList.value)
      assignmentDialogVisible.value = true
    } else {
      ElMessage.error('获取作业详情失败：' + (res.message || '未知错误'))
    }
  } catch (e) {
    console.error('获取作业详情失败:', e)
    ElMessage.error('获取作业详情失败，请检查网络连接')
  }
}

// 查看考试详情
const viewExamDetail = async (submissionId) => {
  try {
    console.log('查看考试详情，submissionId:', submissionId)
    const res = await http.get({ url: `/api/class/exam/${submissionId}/details` })
    console.log('考试详情API返回:', res)
    if (res.code === 200 && res.data) {
      examDetailList.value = res.data
      console.log('考试详情列表:', examDetailList.value)
      examDialogVisible.value = true
    } else {
      ElMessage.error('获取考试详情失败：' + (res.message || '未知错误'))
    }
  } catch (e) {
    console.error('获取考试详情失败:', e)
    ElMessage.error('获取考试详情失败，请检查网络连接')
  }
}

// 关闭弹窗
const handleCloseDialog = () => {
  assignmentDialogVisible.value = false
  examDialogVisible.value = false
  assignmentDetailList.value = []
  examDetailList.value = []
}

const getScoreClass = (score) => {
    if(!score) return ''
    if(score >= 90) return 'text-green'
    if(score >= 60) return 'text-blue'
    return 'text-red'
}

// 题目类型转换
const getQuestionTypeName = (type) => {
  if (!type) return '未知'
  const typeMap = {
    'choice': '选择题',
    'short_answer': '简答题',
    'programming': '编程题',
    'multiple_choice': '多选题',
    'true_false': '判断题'
  }
  return typeMap[type] || type
}

// 显示移除确认弹窗
const showRemoveConfirm = (student) => {
  removeTargetStudent.value = student
  removeConfirmVisible.value = true
}

// 取消移除
const cancelRemove = () => {
  removeConfirmVisible.value = false
  removeTargetStudent.value = null
}

// 确认移除学生
const confirmRemove = async () => {
  if (!removeTargetStudent.value || !currentClassId.value) return

  try {
    const res = await http.post({ 
      url: `/api/class/${currentClassId.value}/remove-student`,
      data: { studentId: removeTargetStudent.value.id }
    })
    
    if (res.code === 200) {
      ElMessage.success(`已将 ${removeTargetStudent.value.name} 移出班级`)
      // 从列表中移除该学生
      studentList.value = studentList.value.filter(s => s.id !== removeTargetStudent.value.id)
      // 如果移除的是当前选中的学生，清空选中状态
      if (currentStudent.value && currentStudent.value.id === removeTargetStudent.value.id) {
        currentStudent.value = null
        loginTrendOption.value = {}
        homeworkRecords.value = []
        examRecords.value = []
      }
      // 关闭弹窗
      cancelRemove()
    } else {
      ElMessage.error('移除学生失败：' + (res.message || '未知错误'))
    }
  } catch (e) {
    console.error('移除学生失败:', e)
    ElMessage.error('移除学生失败，请检查网络连接')
  }
}

// 切换移除模式
const toggleRemoveMode = () => {
  removeMode.value = !removeMode.value
  if (!removeMode.value) {
    selectedStudents.value = []
  }
}

// 切换学生选择
const toggleStudentSelection = (studentId) => {
  const index = selectedStudents.value.indexOf(studentId)
  if (index > -1) {
    selectedStudents.value.splice(index, 1)
  } else {
    selectedStudents.value.push(studentId)
  }
}

// 批量移除学生 - 显示确认弹窗
const batchRemoveStudents = () => {
  if (selectedStudents.value.length === 0 || !currentClassId.value) {
    ElMessage.warning('请至少选择一个学生')
    return
  }
  batchRemoveConfirmVisible.value = true
}

// 确认批量移除学生
const confirmBatchRemove = async () => {
  if (selectedStudents.value.length === 0 || !currentClassId.value) return

  try {
    const res = await http.post({ 
      url: `/api/class/${currentClassId.value}/batch-remove-students`,
      data: { studentIds: selectedStudents.value }
    })
    
    if (res.code === 200) {
      ElMessage.success(`已成功移除 ${selectedStudents.value.length} 名学生`)
      // 从列表中移除选中的学生
      studentList.value = studentList.value.filter(s => !selectedStudents.value.includes(s.id))
      // 如果移除的学生中包含当前选中的学生，清空选中状态
      if (currentStudent.value && selectedStudents.value.includes(currentStudent.value.id)) {
        currentStudent.value = null
        loginTrendOption.value = {}
        homeworkRecords.value = []
        examRecords.value = []
      }
      // 清空选择并退出移除模式
      selectedStudents.value = []
      removeMode.value = false
      batchRemoveConfirmVisible.value = false
    } else {
      ElMessage.error('批量移除失败：' + (res.message || '未知错误'))
    }
  } catch (e) {
    console.error('批量移除失败:', e)
    ElMessage.error('批量移除失败，请检查网络连接')
  }
}

// 取消批量移除
const cancelBatchRemove = () => {
  batchRemoveConfirmVisible.value = false
}

// 显示添加学生弹窗
const showAddStudentDialog = () => {
  if (!currentClassId.value) {
    ElMessage.warning('请先选择班级')
    return
  }
  studentIdInput.value = ''
  addStudentResult.value = null
  addStudentDialogVisible.value = true
}

// 通过用户ID添加学生
const handleAddStudentById = async () => {
  if (!studentIdInput.value || !currentClassId.value) {
    ElMessage.warning('请输入学号')
    return
  }

  const studentId = parseInt(studentIdInput.value)
  if (isNaN(studentId)) {
    ElMessage.warning('请输入有效的学号（数字）')
    return
  }

  addingStudent.value = true
  addStudentResult.value = null

  try {
    const res = await http.post({ 
      url: `/api/class/${currentClassId.value}/add-student-by-id`,
      data: { studentId: studentId }
    })
    
    if (res.code === 200 && res.data) {
      const result = res.data
      if (result.success) {
        addStudentResult.value = {
          type: 'success',
          message: '添加成功！'
        }
        ElMessage.success('添加学生成功')
        // 刷新学生列表
        await handleClassChange()
        // 清空输入框
        studentIdInput.value = ''
        // 2秒后关闭弹窗
        setTimeout(() => {
          cancelAddStudents()
        }, 2000)
      } else {
        // 添加失败，显示错误信息
        addStudentResult.value = {
          type: 'error',
          message: result.message || '添加失败'
        }
        ElMessage.error(result.message || '添加失败')
      }
    } else {
      // 后端返回错误
      addStudentResult.value = {
        type: 'error',
        message: res.message || '添加失败'
      }
      ElMessage.error('添加学生失败：' + (res.message || '未知错误'))
    }
  } catch (e) {
    console.error('添加学生失败:', e)
    addStudentResult.value = {
      type: 'error',
      message: '网络连接失败，请检查网络'
    }
    ElMessage.error('添加学生失败，请检查网络连接')
  } finally {
    addingStudent.value = false
  }
}

// 取消添加学生
const cancelAddStudents = () => {
  addStudentDialogVisible.value = false
  studentIdInput.value = ''
  addStudentResult.value = null
}

const formatTime = (time) => {
    if (!time) return '-'
    // 如果是字符串格式：'2025-12-26 14:53:25' 或 '2025-12-26T14:53:25'
    if (typeof time === 'string') {
        // 只提取日期部分，格式为 MM-DD
        const datePart = time.split('T')[0].split(' ')[0] // 获取日期部分
        if (datePart && datePart.length >= 10) {
            return datePart.substring(5, 10) // 提取 MM-DD
        }
        return time.substring(5, 10) // 如果已经是简化格式，直接返回
    }
    // 如果是数组格式：[2025, 12, 26, 14, 53, 25]（兼容旧格式）
    if (Array.isArray(time)) {
        const [y, m, d] = time
        return `${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`
    }
    return '-'
}

// 中间热力图 (用散点图模拟座位分布)
// 生成模拟座位数据
const generateSeats = () => {
  const data = []
  for (let i = 0; i < 6; i++) {
    for (let j = 0; j < 8; j++) {
      const val = Math.random() * 100
      data.push([i, j, val])
    }
  }
  return data
}

// 显示学生详细信息提示框
const showStudentTooltip = (student, event) => {
  hoveredStudent.value = student
  // 计算提示框位置（在鼠标右下方）
  const rect = event.currentTarget.getBoundingClientRect()
  const scrollX = window.pageXOffset || document.documentElement.scrollLeft
  const scrollY = window.pageYOffset || document.documentElement.scrollTop
  
  tooltipPosition.value = {
    x: rect.right + scrollX + 10, // 在卡片右侧10px
    y: rect.top + scrollY - 10    // 与卡片顶部对齐，稍微上移
  }
}

// 隐藏学生详细信息提示框
const hideStudentTooltip = () => {
  hoveredStudent.value = null
  tooltipPosition.value = null
}

// 显示学情分析弹窗
const showLearningAnalysis = () => {
  if (!currentStudent.value) {
    ElMessage.warning('请先选择一个学生')
    return
  }
  learningAnalysisVisible.value = true
  analysisResult.value = ''
  analysisLoading.value = true
  fetchLearningAnalysis()
}

// 获取AI学情分析（流式数据）
const fetchLearningAnalysis = async () => {
  if (!currentStudent.value) return
  
  const studentId = currentStudent.value.id
  const token = localStorage.getItem('token')
  
  try {
    // 使用fetch接收流式数据
    const response = await fetch(`/api/class/student/${studentId}/ai-analysis`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'text/event-stream, text/plain, */*'
      }
    })
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    
    const reader = response.body.getReader()
    const decoder = new TextDecoder('utf-8')
    let buffer = ''
    
    analysisResult.value = ''
    
    while (true) {
      const { done, value } = await reader.read()
      
      if (done) {
        break
      }
      
      buffer += decoder.decode(value, { stream: true })
      
      // 处理可能的分块数据
      const lines = buffer.split('\n')
      buffer = lines.pop() || '' // 保留最后一个不完整的行
      
      for (const line of lines) {
        if (line.trim()) {
          // 如果是SSE格式，提取data部分
          if (line.startsWith('data: ')) {
            analysisResult.value += line.substring(6)
          } else {
            // 直接追加文本
            analysisResult.value += line
          }
        }
      }
    }
    
    // 处理剩余的buffer
    if (buffer.trim()) {
      if (buffer.startsWith('data: ')) {
        analysisResult.value += buffer.substring(6)
      } else {
        analysisResult.value += buffer
      }
    }
    
    analysisLoading.value = false
  } catch (error) {
    console.error('获取学情分析失败:', error)
    ElMessage.error('获取学情分析失败，请检查网络连接')
    analysisLoading.value = false
    analysisResult.value = '分析失败，请稍后重试。'
  }
}

// 格式化分析文本（将换行和特殊格式转换为HTML）
const formatAnalysisText = (text) => {
  if (!text) return ''
  
  // 将换行符转换为<br>
  let formatted = text.replace(/\n/g, '<br>')
  
  // 格式化标题（【标题】）
  formatted = formatted.replace(/【([^】]+)】/g, '<div class="analysis-section-title">【$1】</div>')
  
  // 格式化段落
  formatted = formatted.replace(/(<br>\s*<br>)+/g, '<div class="analysis-paragraph"></div>')
  
  return formatted
}

// 关闭学情分析弹窗
const closeLearningAnalysis = () => {
  learningAnalysisVisible.value = false
  analysisResult.value = ''
  analysisLoading.value = false
}

// 导出Word报告
const exportReport = async () => {
  if (!currentStudent.value || !analysisResult.value) {
    ElMessage.warning('没有可导出的分析内容')
    return
  }
  
  exporting.value = true
  
  try {
    const token = localStorage.getItem('token')
    const response = await fetch(`/api/class/student/${currentStudent.value.id}/export-report`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        analysisContent: analysisResult.value
      })
    })
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    
    // 获取文件名
    const contentDisposition = response.headers.get('Content-Disposition')
    let fileName = `${currentStudent.value.name}_学情分析报告.docx`
    if (contentDisposition) {
      const fileNameMatch = contentDisposition.match(/filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/)
      if (fileNameMatch && fileNameMatch[1]) {
        fileName = decodeURIComponent(fileNameMatch[1].replace(/['"]/g, ''))
      }
    }
    
    // 下载文件
    const blob = await response.blob()
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = fileName
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
    
    ElMessage.success('报告导出成功')
  } catch (error) {
    console.error('导出报告失败:', error)
    ElMessage.error('导出报告失败，请稍后重试')
  } finally {
    exporting.value = false
  }
}

// 更新学习行为指标数据
const updateBehaviorData = async () => {
  if (!currentClassId.value) return
  
  const courseId = selectedBehaviorCourseId.value
  
  try {
    // 获取作业完成率
    const homeworkRes = await http.get({ 
      url: `/api/class/${currentClassId.value}/homework-completion-rate`,
      params: courseId ? { courseId: courseId } : {}
    })
    
    if (homeworkRes.code === 200 && homeworkRes.data) {
      const completionRate = homeworkRes.data.completionRate || 0
      const rateStr = completionRate.toFixed(1) + '%'
      const ratePct = Math.min(completionRate, 100) + '%'
      
      behaviorData.value[0] = {
        label: '作业完成率',
        value: rateStr,
        pct: ratePct,
        color: '#67c23a'
      }
    } else {
      behaviorData.value[0] = {
        label: '作业完成率',
        value: '0%',
        pct: '0%',
        color: '#67c23a'
      }
    }
  } catch (e) {
    console.error('获取作业完成率失败:', e)
    behaviorData.value[0] = {
      label: '作业完成率',
      value: '0%',
      pct: '0%',
      color: '#67c23a'
    }
  }
  
  try {
    // 获取考试完成率
    const examRes = await http.get({ 
      url: `/api/class/${currentClassId.value}/exam-completion-rate`,
      params: courseId ? { courseId: courseId } : {}
    })
    
    if (examRes.code === 200 && examRes.data) {
      const completionRate = examRes.data.completionRate || 0
      const rateStr = completionRate.toFixed(1) + '%'
      const ratePct = Math.min(completionRate, 100) + '%'
      
      behaviorData.value[1] = {
        label: '考试完成率',
        value: rateStr,
        pct: ratePct,
        color: '#e6a23c'
      }
    } else {
      behaviorData.value[1] = {
        label: '考试完成率',
        value: '0%',
        pct: '0%',
        color: '#e6a23c'
      }
    }
  } catch (e) {
    console.error('获取考试完成率失败:', e)
    behaviorData.value[1] = {
      label: '考试完成率',
      value: '0%',
      pct: '0%',
      color: '#e6a23c'
    }
  }
  
  try {
    // 获取作业平均成绩
    const homeworkScoreRes = await http.get({ 
      url: `/api/class/${currentClassId.value}/homework-average-score`,
      params: courseId ? { courseId: courseId } : {}
    })
    
    if (homeworkScoreRes.code === 200 && homeworkScoreRes.data) {
      const avgScore = homeworkScoreRes.data.averageScore || 0
      const scoreStr = avgScore.toFixed(1)
      // 将成绩转换为百分比用于进度条显示（假设满分100分）
      const scorePct = Math.min((avgScore / 100) * 100, 100) + '%'
      
      behaviorData.value[2] = {
        label: '作业平均成绩',
        value: scoreStr,
        pct: scorePct,
        color: '#f56c6c'
      }
    } else {
      behaviorData.value[2] = {
        label: '作业平均成绩',
        value: '0',
        pct: '0%',
        color: '#f56c6c'
      }
    }
  } catch (e) {
    console.error('获取作业平均成绩失败:', e)
    behaviorData.value[2] = {
      label: '作业平均成绩',
      value: '0',
      pct: '0%',
      color: '#f56c6c'
    }
  }
  
  try {
    // 获取考试平均成绩
    const examScoreRes = await http.get({ 
      url: `/api/class/${currentClassId.value}/exam-average-score`,
      params: courseId ? { courseId: courseId } : {}
    })
    
    if (examScoreRes.code === 200 && examScoreRes.data) {
      const avgScore = examScoreRes.data.averageScore || 0
      const scoreStr = avgScore.toFixed(1)
      // 将成绩转换为百分比用于进度条显示（假设满分100分）
      const scorePct = Math.min((avgScore / 100) * 100, 100) + '%'
      
      behaviorData.value[3] = {
        label: '考试平均成绩',
        value: scoreStr,
        pct: scorePct,
        color: '#00bfff'
      }
    } else {
      behaviorData.value[3] = {
        label: '考试平均成绩',
        value: '0',
        pct: '0%',
        color: '#00bfff'
      }
    }
  } catch (e) {
    console.error('获取考试平均成绩失败:', e)
    behaviorData.value[3] = {
      label: '考试平均成绩',
      value: '0',
      pct: '0%',
      color: '#00bfff'
    }
  }
}

</script>

<style scoped>
.visual-container {
  height: 100%;
  width: 100%;
  color: #fff;
  font-family: "Microsoft YaHei", sans-serif;
  background-color: transparent; /* 假设父级有背景 */
}

.analysis-layout {
  display: flex;
  height: 100%;
  padding: 0 10px;
  gap: 15px;
}

.column {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.left-col, .right-col {
  width: 25%;
  min-width: 350px;
}

.center-col {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

/* Panel Styles */
.panel-box {
  background: rgba(8, 16, 45, 0.7);
  border: 1px solid rgba(0, 191, 255, 0.3);
  position: relative;
  flex: 1;
  display: flex;
  flex-direction: column;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
  border-radius: 4px;
}

/* 右侧栏特殊布局：控制各个panel的高度 */
.right-col .panel-box:nth-child(1) {
  /* 可切换的图表区域 */
  flex: 1;
  min-height: 250px;
}

.right-col .panel-box:nth-child(2),
.right-col .panel-box:nth-child(3) {
  /* 作业和考试记录列表 */
  flex: none;
  height: auto;
  min-height: 150px;
  max-height: 180px;
}

.panel-header {
  height: 36px;
  line-height: 36px;
  padding-left: 20px;
  padding-right: 10px;
  background: linear-gradient(90deg, rgba(0, 191, 255, 0.2) 0%, transparent 100%);
  border-bottom: 1px solid rgba(0, 191, 255, 0.2);
  font-size: 14px;
  font-weight: bold;
  color: #00f2fe;
  position: relative;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.panel-header::before {
  content: '';
  position: absolute;
  left: 5px;
  top: 10px;
  width: 4px;
  height: 16px;
  background: #00f2fe;
}

.panel-content {
  flex: 1;
  padding: 10px;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

/* Corners */
.corner-tl, .corner-tr, .corner-bl, .corner-br {
  position: absolute;
  width: 10px;
  height: 10px;
  border: 2px solid #00bfff;
}
.corner-tl { top: -1px; left: -1px; border-right: none; border-bottom: none; }
.corner-tr { top: -1px; right: -1px; border-left: none; border-bottom: none; }
.corner-bl { bottom: -1px; left: -1px; border-right: none; border-top: none; }
.corner-br { bottom: -1px; right: -1px; border-left: none; border-top: none; }

/* Class Info */
.class-info-content {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.info-row {
  display: flex;
  align-items: center;
  gap: 10px;
  border-bottom: 1px dashed rgba(255,255,255,0.1);
  padding-bottom: 5px;
}
.info-row .label { 
  color: #aaa; 
  white-space: nowrap;
  flex-shrink: 0;
}
.info-row .value { color: #fff; font-weight: bold; }
.info-row .class-selector {
  width: 150px;
  flex-shrink: 0;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 5px;
  margin-top: 10px;
}
.stat-item {
  background: rgba(0, 191, 255, 0.1);
  text-align: center;
  padding: 5px;
  border-radius: 4px;
}
.stat-item .num { font-size: 18px; color: #00f2fe; font-weight: bold; }
.stat-item .desc { font-size: 10px; color: #ccc; }

/* Behavior List */
.behavior-panel {
  flex: none;
  height: auto;
}

.behavior-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.b-item { display: flex; align-items: center; gap: 10px; font-size: 12px; }
.b-label { width: 80px; color: #ddd; }
.b-bar-bg { flex: 1; height: 6px; background: rgba(255,255,255,0.1); border-radius: 3px; overflow: hidden; }
.b-bar-fill { height: 100%; border-radius: 3px; }
.b-val { width: 40px; text-align: right; font-weight: bold; }

/* Student List */
.list-content {
  display: flex;
  flex-direction: column;
}
.list-header {
  display: flex;
  padding: 5px 10px;
  background: rgba(0, 191, 255, 0.2);
  font-size: 12px;
  color: #00bfff;
}
.list-header span { flex: 1; text-align: center; }
.list-body {
  flex: 1;
  overflow-y: auto;
}
.list-row {
  display: flex;
  padding: 8px 10px;
  border-bottom: 1px solid rgba(255,255,255,0.05);
  font-size: 12px;
  cursor: pointer;
  transition: background 0.2s;
}
.list-row:hover, .list-row.active { background: rgba(0, 191, 255, 0.2); }
.list-row span { flex: 1; text-align: center; color: #eee; }
.col-status .el-icon { vertical-align: middle; }

/* Center Map */
.center-map-area {
  flex: 1;
  background: 
    linear-gradient(rgba(8, 16, 45, 0.7), rgba(0, 15, 35, 0.7)),
    url('@/assets/images/jiaoyu.png') center center / cover no-repeat;
  border: 1px solid rgba(0, 191, 255, 0.2);
  border-radius: 10px;
  position: relative;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.center-map-area::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle at center, rgba(0, 191, 255, 0.1) 0%, transparent 70%);
  pointer-events: none;
  z-index: 0;
}

.center-map-area > * {
  position: relative;
  z-index: 1;
}
.map-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 20px;
  color: #00f2fe;
  font-size: 18px;
  font-weight: bold;
  text-shadow: 0 0 10px #00f2fe;
  border-bottom: 1px solid rgba(0, 242, 254, 0.2);
}

.header-actions {
  display: flex;
  gap: 10px;
  align-items: center;
}

.action-btn {
  background: rgba(0, 191, 255, 0.1) !important;
  border: 1px solid rgba(0, 242, 254, 0.3) !important;
  color: #00f2fe !important;
  transition: all 0.3s;
}

.action-btn:hover {
  background: rgba(0, 191, 255, 0.2) !important;
  border-color: #00f2fe !important;
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.3);
}
.heatmap-grid {
  flex: 1;
  padding: 20px;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(80px, 1fr));
  grid-auto-rows: max-content;
  align-content: start;
  gap: 15px;
  overflow-y: auto;
}

.student-seat {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(0, 191, 255, 0.2);
  border-radius: 8px;
  padding: 8px;
  display: flex;
  flex-direction: column;
  align-items: center;
  cursor: pointer;
  transition: all 0.3s;
  position: relative;
}

.student-seat:hover {
  background: rgba(0, 191, 255, 0.2);
  transform: translateY(-5px);
}

.student-seat.active {
  border-color: #00f2fe;
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.5);
  background: rgba(0, 191, 255, 0.3);
}

.student-seat.status-high { border-bottom: 3px solid #67c23a; }
.student-seat.status-warn { border-bottom: 3px solid #e6a23c; }
.student-seat.status-normal { border-bottom: 3px solid #409eff; }

.seat-avatar { margin-bottom: 5px; }
.seat-info { display: flex; align-items: center; gap: 5px; font-size: 12px; color: #fff; }
.seat-sex { display: flex; align-items: center; }
.seat-score { position: absolute; top: 5px; right: 5px; font-size: 10px; color: #aaa; }

.seat-checkbox {
  position: absolute;
  top: 5px;
  left: 5px;
  z-index: 10;
  background: rgba(0, 0, 0, 0.5);
  border-radius: 4px;
  padding: 2px;
}

.seat-checkbox :deep(.el-checkbox) {
  --el-checkbox-checked-bg-color: rgba(0, 242, 254, 0.8);
  --el-checkbox-checked-border-color: #00f2fe;
  --el-checkbox-input-border-color-hover: #00f2fe;
}

.student-card-float {
  position: absolute;
  bottom: 20px;
  left: 20px;
  background: rgba(0, 0, 0, 0.8);
  border: 1px solid #00f2fe;
  padding: 10px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 10px;
  box-shadow: 0 0 20px rgba(0, 242, 254, 0.3);
}
.s-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #333;
  display: flex;
  justify-content: center;
  align-items: center;
  color: #fff;
}
.s-info { color: #fff; font-size: 12px; }
.s-name { font-weight: bold; font-size: 14px; }
.s-tag { margin-top: 2px; padding: 2px 5px; border-radius: 2px; font-size: 10px; display: inline-block; }
.s-tag.high { background: #67c23a; }
.s-tag.warn { background: #e6a23c; }
.s-tag.normal { background: #409eff; }

/* 学生详细信息提示框 */
.student-tooltip {
  position: fixed;
  z-index: 1000;
  background: linear-gradient(145deg, rgba(8, 16, 45, 0.98), rgba(0, 15, 35, 0.98));
  border: 1px solid rgba(0, 242, 254, 0.5);
  border-radius: 8px;
  padding: 15px;
  min-width: 220px;
  box-shadow: 
    0 0 30px rgba(0, 242, 254, 0.4),
    inset 0 0 20px rgba(0, 191, 255, 0.1);
  pointer-events: none;
  animation: tooltipFadeIn 0.2s ease;
}

@keyframes tooltipFadeIn {
  from {
    opacity: 0;
    transform: translateY(-5px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.tooltip-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.tooltip-avatar {
  flex-shrink: 0;
}

.tooltip-name-section {
  flex: 1;
}

.tooltip-name {
  color: #00f2fe;
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 4px;
}

.tooltip-sex {
  display: flex;
  align-items: center;
  gap: 5px;
  color: #ccc;
  font-size: 12px;
}

.tooltip-divider {
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(0, 242, 254, 0.3), transparent);
  margin: 10px 0;
}

.tooltip-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.tooltip-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 13px;
}

.tooltip-label {
  color: #aaa;
}

.tooltip-value {
  color: #fff;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 4px;
}

.tooltip-value.text-green {
  color: #67c23a;
}

.tooltip-value.text-warning {
  color: #e6a23c;
}

.tooltip-value.status-high {
  color: #67c23a;
}

.tooltip-value.status-warn {
  color: #e6a23c;
}

.tooltip-value.status-normal {
  color: #409eff;
}


/* Chart Switch Buttons */
.chart-switch-btns {
  display: flex;
  gap: 5px;
}

.switch-btn {
  padding: 4px 10px;
  background: rgba(0, 191, 255, 0.1);
  border: 1px solid rgba(0, 191, 255, 0.3);
  border-radius: 3px;
  color: #ccc;
  font-size: 11px;
  cursor: pointer;
  transition: all 0.3s;
}

.switch-btn:hover {
  background: rgba(0, 191, 255, 0.2);
  color: #fff;
}

.switch-btn.active {
  background: rgba(0, 191, 255, 0.4);
  border-color: #00f2fe;
  color: #00f2fe;
  font-weight: bold;
}

/* Right Column - Record Lists */
.record-list {
    display: flex;
    flex-direction: column;
}
.list-header-row {
    display: flex;
    padding: 5px 0;
    border-bottom: 1px solid rgba(255,255,255,0.1);
    color: #00bfff;
    font-size: 12px;
}
.list-header-row span {
    flex: 1;
    text-align: center;
    padding: 0 5px;
}
.list-header-row span:first-child {
    flex: 1.5;
    text-align: left;
    padding-left: 10px;
}
.list-body-scroll {
    max-height: 120px;
    overflow-y: auto;
}

/* 科技风格滚动条 */
.list-body-scroll::-webkit-scrollbar {
    width: 6px;
}

.list-body-scroll::-webkit-scrollbar-track {
    background: rgba(0, 191, 255, 0.1);
    border-radius: 3px;
}

.list-body-scroll::-webkit-scrollbar-thumb {
    background: linear-gradient(180deg, #00f2fe 0%, #00bfff 100%);
    border-radius: 3px;
    box-shadow: 0 0 6px rgba(0, 242, 254, 0.5);
}

.list-body-scroll::-webkit-scrollbar-thumb:hover {
    background: linear-gradient(180deg, #00f2fe 0%, #4facfe 100%);
    box-shadow: 0 0 8px rgba(0, 242, 254, 0.8);
}
.record-row {
    display: flex;
    padding: 8px 0;
    border-bottom: 1px solid rgba(255,255,255,0.05);
    font-size: 12px;
    color: #ddd;
}
.record-row span {
    flex: 1;
    text-align: center;
    padding: 0 5px;
}
.record-row span:first-child {
    flex: 1.5;
    text-align: left;
    padding-left: 10px;
}
.empty-tip {
    text-align: center;
    color: #666;
    padding: 20px 0;
    font-size: 12px;
}
.text-green { color: #67c23a; }
.text-blue { color: #409eff; }
.text-red { color: #f56c6c; }

.chart { width: 100%; height: 100%; }

/* Tech Style for Select Input */
:deep(.el-select__wrapper) {
  background-color: rgba(0, 20, 40, 0.6) !important;
  box-shadow: 0 0 0 1px rgba(0, 191, 255, 0.3) inset !important;
  color: #00f2fe !important;
  transition: all 0.3s;
}

:deep(.el-select__wrapper:hover), :deep(.el-select__wrapper.is-focused) {
  box-shadow: 0 0 5px rgba(0, 242, 254, 0.5) inset !important;
  background-color: rgba(0, 30, 60, 0.8) !important;
}

:deep(.el-select__selected-item), :deep(.el-input__inner) {
  color: #00f2fe !important;
  font-weight: bold;
}

:deep(.el-select__caret) {
  color: #00f2fe !important;
}
</style>

<!-- Global Styles for Select Dropdown -->
<style>
/* 使用 CSS 变量从根源上修改颜色，覆盖 Element Plus 默认的白色主题 */
.tech-select-popper {
  --el-bg-color-overlay: rgba(8, 16, 45, 0.95) !important;
  --el-fill-color-light: rgba(0, 191, 255, 0.1) !important;
  --el-border-color-light: #00f2fe !important;
  --el-text-color-regular: #ccc !important;
  --el-popper-border-radius: 4px !important;
}

.tech-select-popper.el-popper {
  background: var(--el-bg-color-overlay) !important;
  border: 1px solid #00f2fe !important;
  box-shadow: 0 0 15px rgba(0, 242, 254, 0.3) !important;
}

.tech-select-popper .el-select-dropdown__item {
  color: #ccc !important;
}

.tech-select-popper .el-select-dropdown__item.hover, 
.tech-select-popper .el-select-dropdown__item:hover {
  background-color: rgba(0, 191, 255, 0.2) !important;
  color: #fff !important;
}

.tech-select-popper .el-select-dropdown__item.selected {
  color: #00f2fe !important;
  font-weight: bold;
  background-color: rgba(0, 191, 255, 0.1) !important;
}

.tech-select-popper .el-popper__arrow::before {
  background: var(--el-bg-color-overlay) !important;
  border: 1px solid #00f2fe !important;
}

/* ========== 自定义科技风格弹窗样式 ========== */
.custom-dialog-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  backdrop-filter: blur(4px);
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.tech-dialog-box {
  width: 85%;
  max-width: 1400px;
  max-height: 85vh;
  background: linear-gradient(145deg, rgba(8, 16, 45, 0.98), rgba(0, 15, 35, 0.98));
  border: 1px solid rgba(0, 242, 254, 0.5);
  box-shadow: 
    0 0 50px rgba(0, 242, 254, 0.4),
    inset 0 0 30px rgba(0, 191, 255, 0.1);
  border-radius: 12px;
  position: relative;
  overflow: hidden;
  animation: slideUp 0.3s ease;
  display: flex;
  flex-direction: column;
}

@keyframes slideUp {
  from {
    transform: translateY(30px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.tech-dialog-box::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, transparent, #00f2fe, transparent);
  animation: scan-line 3s linear infinite;
}

@keyframes scan-line {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

.tech-dialog-box::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    radial-gradient(circle at 20% 20%, rgba(0, 242, 254, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 80% 80%, rgba(0, 191, 255, 0.1) 0%, transparent 50%);
  pointer-events: none;
  z-index: 0;
}

.dialog-header {
  padding: 20px 30px;
  border-bottom: 1px solid rgba(0, 242, 254, 0.3);
  background: linear-gradient(90deg, rgba(0, 191, 255, 0.1), rgba(0, 242, 254, 0.05));
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: relative;
  z-index: 1;
}

.dialog-header .header-actions {
  display: flex;
  gap: 10px;
  align-items: center;
}

.export-btn {
  background: rgba(0, 191, 255, 0.1) !important;
  border: 1px solid rgba(0, 242, 254, 0.3) !important;
  color: #00f2fe !important;
  transition: all 0.3s;
}

.export-btn:hover {
  background: rgba(0, 191, 255, 0.2) !important;
  border-color: #00f2fe !important;
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.3);
}

.dialog-header::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, #00f2fe, transparent);
  opacity: 0.5;
}

.header-title {
  display: flex;
  align-items: center;
  gap: 12px;
  position: relative;
}

.title-icon {
  font-size: 24px;
  filter: drop-shadow(0 0 5px rgba(0, 242, 254, 0.5));
}

.title-text {
  color: #00f2fe;
  font-size: 22px;
  font-weight: bold;
  text-shadow: 0 0 10px rgba(0, 242, 254, 0.5);
  letter-spacing: 1px;
}

.title-line {
  position: absolute;
  bottom: -10px;
  left: 0;
  width: 100px;
  height: 2px;
  background: linear-gradient(90deg, #00f2fe, transparent);
}

/* 课程筛选器样式 */
.course-filter-selector :deep(.el-select__wrapper) {
  background-color: rgba(0, 20, 40, 0.6) !important;
  box-shadow: 0 0 0 1px rgba(0, 191, 255, 0.3) inset !important;
  color: #00f2fe !important;
  transition: all 0.3s;
}

.course-filter-selector :deep(.el-select__wrapper:hover), 
.course-filter-selector :deep(.el-select__wrapper.is-focused) {
  box-shadow: 0 0 5px rgba(0, 242, 254, 0.5) inset !important;
  background-color: rgba(0, 30, 60, 0.8) !important;
}

.course-filter-selector :deep(.el-select__selected-item), 
.course-filter-selector :deep(.el-input__inner) {
  color: #00f2fe !important;
  font-weight: bold;
}

.course-filter-selector :deep(.el-select__caret) {
  color: #00f2fe !important;
}

/* 标题列样式 */
.title-cell {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 120px;
  display: inline-block;
}

.close-btn {
  background: rgba(0, 191, 255, 0.1);
  border: 1px solid rgba(0, 242, 254, 0.3);
  color: #00f2fe;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s;
  font-size: 18px;
}

.close-btn:hover {
  background: rgba(0, 242, 254, 0.2);
  border-color: #00f2fe;
  color: #4facfe;
  box-shadow: 0 0 15px rgba(0, 242, 254, 0.5);
  transform: scale(1.1);
}

.dialog-body {
  flex: 1;
  padding: 20px 30px;
  overflow-y: auto;
  position: relative;
  z-index: 1;
}

.custom-table-container {
  width: 100%;
  overflow-x: auto;
}

.custom-tech-table {
  width: 100%;
  border-collapse: collapse;
  background: transparent;
}

.custom-tech-table thead {
  background: linear-gradient(180deg, rgba(0, 191, 255, 0.15), rgba(0, 191, 255, 0.05));
}

.custom-tech-table th {
  color: #00f2fe;
  font-weight: bold;
  padding: 15px 12px;
  text-align: center;
  border-bottom: 1px solid rgba(0, 242, 254, 0.4);
  font-size: 14px;
  white-space: nowrap;
}

.custom-tech-table td {
  color: #ddd;
  padding: 15px 12px;
  text-align: center;
  border-bottom: 1px solid rgba(0, 242, 254, 0.1);
  font-size: 13px;
}

.custom-tech-table tbody tr {
  transition: all 0.3s;
}

.custom-tech-table tbody tr:hover {
  background: rgba(0, 191, 255, 0.1);
  box-shadow: inset 0 0 10px rgba(0, 242, 254, 0.1);
}

.custom-tech-table tbody tr:nth-child(even) {
  background: rgba(0, 191, 255, 0.03);
}

.custom-tech-table tbody tr:nth-child(even):hover {
  background: rgba(0, 191, 255, 0.15);
}

.empty-cell {
  color: #666;
  text-align: center;
  padding: 40px 0;
}

.question-content {
  color: #fff !important;
  font-weight: 500;
  line-height: 1.6;
  text-align: left;
  max-width: 300px;
  word-break: break-word;
}

.answer-text {
  color: #ddd !important;
  line-height: 1.6;
  text-align: left;
  max-width: 250px;
  word-break: break-word;
}

.correct-answer {
  color: #67c23a !important;
  font-weight: 500;
  line-height: 1.6;
  text-align: left;
  max-width: 250px;
  word-break: break-word;
}

.error-reason {
  color: #f56c6c !important;
  line-height: 1.6;
  font-size: 12px;
  text-align: left;
  max-width: 300px;
  word-break: break-word;
}

.type-tag,
.knowledge-tag {
  display: inline-block;
  padding: 4px 12px;
  background: rgba(0, 191, 255, 0.2);
  border: 1px solid rgba(0, 242, 254, 0.3);
  color: #00f2fe;
  border-radius: 4px;
  font-size: 12px;
}

.knowledge-tag {
  background: rgba(230, 162, 60, 0.2);
  border-color: rgba(230, 162, 60, 0.3);
  color: #e6a23c;
}

.status-correct {
  color: #67c23a;
  font-weight: bold;
}

.status-error {
  color: #f56c6c;
  font-weight: bold;
}

/* 自定义弹窗滚动条 */
.dialog-body::-webkit-scrollbar {
  width: 8px;
}

.dialog-body::-webkit-scrollbar-track {
  background: rgba(0, 191, 255, 0.1);
  border-radius: 4px;
  border: 1px solid rgba(0, 242, 254, 0.2);
}

.dialog-body::-webkit-scrollbar-thumb {
  background: linear-gradient(180deg, #00f2fe 0%, #00bfff 100%);
  border-radius: 4px;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.6);
  border: 1px solid rgba(0, 242, 254, 0.3);
}

.dialog-body::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(180deg, #4facfe 0%, #00f2fe 100%);
  box-shadow: 0 0 12px rgba(0, 242, 254, 0.8);
}

/* 移除确认弹窗样式 */
.remove-confirm-dialog {
  width: 500px;
  max-width: 90%;
}

.confirm-content {
  padding: 20px 0;
  text-align: center;
}

.confirm-message {
  color: #ddd;
  font-size: 16px;
  line-height: 1.8;
  margin-bottom: 15px;
}

.student-name-highlight {
  color: #00f2fe;
  font-weight: bold;
  font-size: 18px;
  text-shadow: 0 0 10px rgba(0, 242, 254, 0.5);
}

.confirm-warning {
  color: #f56c6c;
  font-size: 14px;
  margin-top: 10px;
}

.selected-students-list {
  max-height: 200px;
  overflow-y: auto;
  margin: 15px 0;
  padding: 10px;
  background: rgba(0, 191, 255, 0.05);
  border: 1px solid rgba(0, 242, 254, 0.2);
  border-radius: 6px;
}

.selected-student-item {
  color: #ddd;
  font-size: 14px;
  padding: 5px 0;
  border-bottom: 1px solid rgba(0, 242, 254, 0.1);
}

.selected-student-item:last-child {
  border-bottom: none;
}

.confirm-buttons {
  display: flex;
  justify-content: center;
  gap: 20px;
  margin-top: 30px;
}

.confirm-btn {
  padding: 12px 30px;
  border: 1px solid;
  border-radius: 6px;
  font-size: 14px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s;
  min-width: 100px;
}

.cancel-btn {
  background: rgba(255, 255, 255, 0.05);
  border-color: rgba(0, 191, 255, 0.3);
  color: #00f2fe;
}

.cancel-btn:hover {
  background: rgba(0, 191, 255, 0.1);
  border-color: #00f2fe;
  box-shadow: 0 0 15px rgba(0, 242, 254, 0.3);
}

.confirm-primary-btn {
  background: rgba(245, 108, 108, 0.2);
  border-color: rgba(245, 108, 108, 0.5);
  color: #f56c6c;
}

.confirm-primary-btn:hover {
  background: rgba(245, 108, 108, 0.4);
  border-color: #f56c6c;
  box-shadow: 0 0 15px rgba(245, 108, 108, 0.5);
  transform: scale(1.05);
}

/* AI学情分析弹窗样式 */
.learning-analysis-dialog {
  width: 80%;
  max-width: 1200px;
}

.learning-analysis-body {
  min-height: 400px;
  max-height: 70vh;
}

.analysis-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 20px;
  padding: 60px 0;
  color: #00f2fe;
  font-size: 16px;
}

.analysis-loading .el-icon {
  font-size: 48px;
  animation: rotate 1s linear infinite;
}

@keyframes rotate {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.analysis-content {
  padding: 20px;
  line-height: 1.8;
  color: #ddd;
  font-size: 14px;
}

.analysis-text {
  white-space: pre-wrap;
  word-wrap: break-word;
}

.analysis-section-title {
  color: #00f2fe;
  font-size: 18px;
  font-weight: bold;
  margin: 20px 0 10px 0;
  padding: 10px 0;
  border-bottom: 1px solid rgba(0, 242, 254, 0.3);
  text-shadow: 0 0 10px rgba(0, 242, 254, 0.5);
}

.analysis-paragraph {
  margin: 15px 0;
}

/* 添加学生弹窗样式 */
.add-student-dialog {
  width: 600px;
  max-width: 90%;
}

.add-student-content {
  padding: 20px 0;
}

.add-student-tip {
  color: #ddd;
  font-size: 14px;
  margin-bottom: 15px;
}

.student-select-list {
  max-height: 400px;
  overflow-y: auto;
  border: 1px solid rgba(0, 242, 254, 0.2);
  border-radius: 6px;
  padding: 10px;
}

.student-select-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px;
  margin-bottom: 8px;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(0, 191, 255, 0.2);
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.3s;
}

.student-select-item:hover {
  background: rgba(0, 191, 255, 0.1);
  border-color: rgba(0, 242, 254, 0.4);
}

.student-select-item.selected {
  background: rgba(0, 191, 255, 0.15);
  border-color: #00f2fe;
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.2);
}

.student-select-name {
  flex: 1;
  color: #ddd;
  font-size: 14px;
}

.student-select-score {
  color: #00f2fe;
  font-size: 12px;
}

.empty-student-tip {
  text-align: center;
  color: #666;
  padding: 40px 0;
  font-size: 14px;
}

/* 添加学生搜索框样式 */
.search-input-wrapper {
  margin-bottom: 20px;
}

.student-id-input :deep(.el-input__wrapper) {
  background-color: rgba(0, 20, 40, 0.6) !important;
  box-shadow: 0 0 0 1px rgba(0, 191, 255, 0.3) inset !important;
  transition: all 0.3s;
}

.student-id-input :deep(.el-input__wrapper:hover),
.student-id-input :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 5px rgba(0, 242, 254, 0.5) inset !important;
  background-color: rgba(0, 30, 60, 0.8) !important;
  border-color: #00f2fe !important;
}

.student-id-input :deep(.el-input__inner) {
  color: #000 !important;
  font-weight: bold;
  background: transparent !important;
}

.student-id-input :deep(.el-input__inner::placeholder) {
  color: rgba(0, 242, 254, 0.6) !important;
}

.student-id-input :deep(.el-input-group__append) {
  background-color: rgba(0, 191, 255, 0.2) !important;
  border: 1px solid rgba(0, 242, 254, 0.3) !important;
}

.student-id-input :deep(.el-input-group__append .el-button) {
  background: rgba(0, 191, 255, 0.2) !important;
  border: none !important;
  color: #00f2fe !important;
}

.student-id-input :deep(.el-input-group__append .el-button:hover) {
  background: rgba(0, 191, 255, 0.4) !important;
  color: #4facfe !important;
}

.add-student-result {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 15px;
  border-radius: 6px;
  margin-top: 15px;
  font-size: 14px;
}

.add-student-result.success {
  background: rgba(103, 194, 58, 0.1);
  border: 1px solid rgba(103, 194, 58, 0.3);
  color: #67c23a;
}

.add-student-result.error {
  background: rgba(245, 108, 108, 0.1);
  border: 1px solid rgba(245, 108, 108, 0.3);
  color: #f56c6c;
}

.add-student-result .el-icon {
  font-size: 18px;
}

/* 弹窗遮罩层科技风格 - 全局覆盖 */
.el-overlay,
.tech-dialog :deep(.el-overlay),
:deep(.el-overlay) {
  background: rgba(0, 0, 0, 0.75) !important;
  backdrop-filter: blur(3px);
}

.el-overlay-dialog,
.tech-dialog :deep(.el-overlay-dialog),
:deep(.el-overlay-dialog) {
  background: transparent !important;
}

/* 强制覆盖弹窗背景 - 使用更高优先级的选择器 */
body .el-dialog.tech-dialog,
body .tech-dialog.el-dialog,
body :deep(.tech-dialog.el-dialog) {
  background: linear-gradient(145deg, rgba(8, 16, 45, 0.98), rgba(0, 15, 35, 0.98)) !important;
  background-color: rgba(8, 16, 45, 0.98) !important;
}

/* 科技风格弹窗样式 - 强制覆盖 Element Plus 默认样式 */
.el-dialog.tech-dialog,
.tech-dialog.el-dialog,
:deep(.tech-dialog),
:deep(.el-dialog.tech-dialog) {
  background: linear-gradient(145deg, rgba(8, 16, 45, 0.98), rgba(0, 15, 35, 0.98)) !important;
  border: 1px solid rgba(0, 242, 254, 0.5) !important;
  box-shadow: 
    0 0 40px rgba(0, 242, 254, 0.3),
    inset 0 0 20px rgba(0, 191, 255, 0.1) !important;
  border-radius: 8px !important;
  position: relative;
  overflow: hidden;
}

.tech-dialog :deep(.el-dialog) {
  background: linear-gradient(145deg, rgba(8, 16, 45, 0.98), rgba(0, 15, 35, 0.98)) !important;
  border: 1px solid rgba(0, 242, 254, 0.5) !important;
  box-shadow: 
    0 0 40px rgba(0, 242, 254, 0.3),
    inset 0 0 20px rgba(0, 191, 255, 0.1) !important;
  border-radius: 8px !important;
  position: relative;
  overflow: hidden;
}

.tech-dialog :deep(.el-dialog)::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, transparent, #00f2fe, transparent);
  animation: scan-line 3s linear infinite;
}

@keyframes scan-line {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

.tech-dialog :deep(.el-dialog__header) {
  border-bottom: 1px solid rgba(0, 242, 254, 0.3) !important;
  background: linear-gradient(90deg, rgba(0, 191, 255, 0.1), rgba(0, 242, 254, 0.05)) !important;
  padding: 20px 24px;
  position: relative;
}

.tech-dialog :deep(.el-dialog__header)::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, #00f2fe, transparent);
  opacity: 0.5;
}

.tech-dialog :deep(.el-dialog__title) {
  color: #00f2fe !important;
  font-weight: bold;
  font-size: 20px;
  text-shadow: 0 0 10px rgba(0, 242, 254, 0.5);
  letter-spacing: 1px;
}

.tech-dialog :deep(.el-dialog__close) {
  color: #00f2fe !important;
  font-size: 20px;
  transition: all 0.3s;
}

.tech-dialog :deep(.el-dialog__close:hover) {
  color: #4facfe !important;
  text-shadow: 0 0 10px rgba(79, 172, 254, 0.8);
  transform: scale(1.1);
}

.tech-dialog :deep(.el-dialog__body) {
  padding: 20px 24px !important;
  background: transparent !important;
  color: #fff !important;
}

.detail-dialog-content {
  max-height: 600px;
  overflow-y: auto;
}

/* 科技风格表格 - 强制深色背景 */
.tech-table :deep(.el-table),
body .tech-table :deep(.el-table) {
  background: transparent !important;
  background-color: transparent !important;
  color: #ccc !important;
  border: 1px solid rgba(0, 242, 254, 0.2) !important;
}

.tech-table :deep(.el-table__inner-wrapper),
body .tech-table :deep(.el-table__inner-wrapper) {
  background: transparent !important;
  background-color: transparent !important;
}

.tech-table :deep(.el-table tr),
body .tech-table :deep(.el-table tr) {
  background: transparent !important;
  background-color: transparent !important;
}

.tech-table :deep(.el-table__row),
body .tech-table :deep(.el-table__row) {
  background: transparent !important;
  background-color: transparent !important;
}

.tech-table :deep(.el-table th.el-table__cell) {
  background: linear-gradient(180deg, rgba(0, 191, 255, 0.15), rgba(0, 191, 255, 0.05)) !important;
  color: #00f2fe !important;
  border-bottom: 1px solid rgba(0, 242, 254, 0.4) !important;
  font-weight: bold;
  text-align: center;
  padding: 12px 0;
}

.tech-table :deep(.el-table td.el-table__cell),
body .tech-table :deep(.el-table td.el-table__cell) {
  border-bottom: 1px solid rgba(0, 242, 254, 0.1) !important;
  color: #ddd !important;
  background: transparent !important;
  background-color: transparent !important;
  padding: 12px 0;
}

.tech-table :deep(.el-table td.el-table__cell .cell),
body .tech-table :deep(.el-table td.el-table__cell .cell) {
  color: #ddd !important;
}

.tech-table :deep(.el-table__row:hover > td) {
  background: rgba(0, 191, 255, 0.1) !important;
  box-shadow: inset 0 0 10px rgba(0, 242, 254, 0.1);
}

.tech-table :deep(.el-table--striped .el-table__body tr.el-table__row--striped td) {
  background: rgba(0, 191, 255, 0.03) !important;
}

.tech-table :deep(.el-table__empty-text) {
  color: #666;
}

/* 表格内容样式 - 确保文字清晰可见 */
.tech-table .question-content,
.tech-table :deep(.question-content),
body .tech-table .question-content,
body .tech-table :deep(.question-content) {
  color: #fff !important;
  font-weight: 500;
  line-height: 1.6;
  text-shadow: 0 0 2px rgba(255, 255, 255, 0.3);
}

.tech-table .answer-text,
.tech-table :deep(.answer-text) {
  color: #ddd !important;
  line-height: 1.6;
}

.tech-table .correct-answer,
.tech-table :deep(.correct-answer) {
  color: #67c23a !important;
  font-weight: 500;
  line-height: 1.6;
}

.tech-table .error-reason,
.tech-table :deep(.error-reason) {
  color: #f56c6c !important;
  line-height: 1.6;
  font-size: 13px;
}

/* 确保表格所有文字都是浅色 */
.tech-table :deep(.el-table td),
.tech-table :deep(.el-table td .cell),
.tech-table :deep(.el-table td .cell *),
body .tech-table :deep(.el-table td),
body .tech-table :deep(.el-table td .cell),
body .tech-table :deep(.el-table td .cell *) {
  color: #ddd !important;
}

.tech-table :deep(.el-table th),
.tech-table :deep(.el-table th .cell),
body .tech-table :deep(.el-table th),
body .tech-table :deep(.el-table th .cell) {
  color: #00f2fe !important;
}

/* 确保自定义内容区域文字可见 */
.tech-table .question-content,
.tech-table .answer-text,
.tech-table .correct-answer,
.tech-table .error-reason,
body .tech-table .question-content,
body .tech-table .answer-text,
body .tech-table .correct-answer,
body .tech-table .error-reason {
  color: inherit !important;
}

/* 弹窗内滚动条样式 */
.detail-dialog-content::-webkit-scrollbar {
  width: 8px;
}

.detail-dialog-content::-webkit-scrollbar-track {
  background: rgba(0, 191, 255, 0.1);
  border-radius: 4px;
  border: 1px solid rgba(0, 242, 254, 0.2);
}

.detail-dialog-content::-webkit-scrollbar-thumb {
  background: linear-gradient(180deg, #00f2fe 0%, #00bfff 100%);
  border-radius: 4px;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.6);
  border: 1px solid rgba(0, 242, 254, 0.3);
}

.detail-dialog-content::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(180deg, #4facfe 0%, #00f2fe 100%);
  box-shadow: 0 0 12px rgba(0, 242, 254, 0.8);
}
</style>
