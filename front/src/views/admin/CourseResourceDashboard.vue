<template>
  <div class="course-resource-dashboard">
    <div class="content-layout">
      <!-- 左侧栏 -->
      <div class="column left-col">
        <!-- 资源概览 -->
        <div class="panel-box">
          <div class="panel-header">
            <span class="icon-box">▣</span> 资源概览
          </div>
          <div class="panel-content">
            <div class="chart-title">资源统计</div>
             <div class="stats-row">
               <div class="stat-item">
                 <div class="num">{{ totalResources }}</div>
                 <div class="label">总资源数</div>
               </div>
               <div class="stat-item">
                 <div class="num highlight">{{ ingestedResources }}</div>
                 <div class="label">已入库</div>
               </div>
               <div class="stat-item">
                 <div class="num warning">{{ pendingResources }}</div>
                 <div class="label">待入库</div>
               </div>
             </div>
             <div class="course-filter-section">
               <div class="chart-title">课程名称</div>
               <el-select 
                 v-model="selectedCourseId" 
                 placeholder="选择课程筛选" 
                 class="course-filter-select"
                 popper-class="course-filter-dropdown"
                 @change="handleCourseFilterChange"
               >
                 <el-option label="全部" :value="'all'" />
                 <el-option
                   v-for="course in courses"
                   :key="course.id"
                   :label="course.courseName"
                   :value="course.id"
                 />
               </el-select>
             </div>
          </div>
        </div>

        <!-- 资源类型分布 -->
        <div class="panel-box">
          <div class="panel-header">
            <span class="icon-box">▣</span> 资源类型分布
          </div>
          <div class="panel-content">
             <v-chart 
               ref="resourceTypeChart"
               class="chart" 
               :option="resourceTypeOption" 
               autoresize 
               @click="handleChartClick"
             />
          </div>
        </div>

        <!-- 课程资源排行 -->
        <div class="panel-box">
          <div class="panel-header">
            <span class="icon-box">▣</span> 课程资源排行
          </div>
          <div class="panel-content">
             <v-chart class="chart" :option="courseRankOption" autoresize />
          </div>
        </div>
      </div>

      <!-- 中间栏 -->
      <div class="column center-col">
        <div class="center-top-panel">
          <div class="center-title">COURSE RESOURCE MANAGEMENT</div>
          <div class="center-subtitle">::: 课程教学资源管理中心 :::</div>
          
          <div class="process-circles">
            <div class="process-item" v-for="(item, idx) in resourceStats" :key="idx">
              <div class="circle-ring">
                <span class="pct">{{ item.value }}</span>
                <div class="status-badge">{{ item.label }}</div>
              </div>
              <div class="proc-name">{{ item.subLabel }}</div>
            </div>
          </div>
        </div>

        <div class="center-middle-panel">
          <div class="panel-header-center">
            <div class="header-title">::: 最新课程资源列表 :::</div>
            <div class="header-actions">
              <div class="header-left">
                <el-checkbox 
                  v-model="selectAll" 
                  @change="handleSelectAll"
                  class="select-all-checkbox"
                >
                  全选
                </el-checkbox>
                <el-dropdown 
                  trigger="click" 
                  @command="handleBatchCommand"
                  class="batch-action-dropdown"
                  popper-class="batch-action-dropdown-menu"
                >
                  <el-button class="batch-action-btn" :disabled="selectedResourceIds.length === 0">
                    <el-icon><MoreFilled /></el-icon>
                  </el-button>
                  <template #dropdown>
                    <el-dropdown-menu>
                      <el-dropdown-item command="ingest" :disabled="selectedResourceIds.length === 0">
                        批量入库
                      </el-dropdown-item>
                      <el-dropdown-item command="delete" :disabled="selectedResourceIds.length === 0" divided>
                        批量删除
                      </el-dropdown-item>
                    </el-dropdown-menu>
                  </template>
                </el-dropdown>
              </div>
              <div class="header-right">
                <div class="search-box">
                  <el-input
                    v-model="searchKeyword"
                    placeholder="搜索文件名..."
                    class="search-input"
                    clearable
                    @input="handleSearch"
                  >
                    <template #prefix>
                      <el-icon><Search /></el-icon>
                    </template>
                  </el-input>
                </div>
                <el-button 
                  class="upload-resource-btn" 
                  @click="handleUploadClick"
                >
                  <el-icon><Plus /></el-icon>
                  上传资源
                </el-button>
              </div>
            </div>
          </div>
          <div class="table-container">
            <div class="table-header">
              <span class="checkbox-col"></span>
              <span>文件名</span>
              <span>所属课程</span>
              <span>类型</span>
              <span>上传时间</span>
              <span class="status-header">状态</span>
              <span>操作</span>
            </div>
            <div class="table-body" v-loading="loading">
               <div class="table-row" v-for="(row, idx) in paginatedResourceList" :key="idx">
                 <span class="checkbox-col">
                   <el-checkbox 
                     v-model="selectedResourceIds" 
                     :value="row.id"
                     @change="handleSelectChange"
                   />
                 </span>
                 <span class="col-name" :title="row.name">
                   <el-icon><Document /></el-icon> {{ row.name }}
                 </span>
                 <span>{{ row.course }}</span>
                 <span>{{ row.type }}</span>
                 <span>{{ row.date }}</span>
                 <span class="status-col">
                   <el-tag 
                     :type="row.status === '已入库' ? 'success' : 'warning'"
                     class="status-tag"
                     effect="plain"
                   >
                     {{ row.status }}
                   </el-tag>
                 </span>
                 <span class="action-col">
                   <span class="btn-text" @click="viewResource(row)">查看</span>
                   <span class="btn-text" @click="downloadResource(row)">下载</span>
                   <span class="btn-text" @click="editResource(row)">修改</span>
                   <span 
                     class="btn-text" 
                     :class="{ 'btn-cancel-ingest': row.status === '已入库' }"
                     @click="row.status === '已入库' ? cancelIngestResource(row) : ingestResource(row)"
                   >
                     {{ row.status === '已入库' ? '取消入库' : '入库' }}
                   </span>
                   <span class="btn-text btn-delete" @click="deleteResource(row)">删除</span>
                 </span>
               </div>
               <div v-if="paginatedResourceList.length === 0 && !loading" class="no-data">暂无数据</div>
            </div>
            <div class="table-pagination">
              <div class="pagination-info">
                共 {{ displayedResourceList.length }} 条记录, 第 {{ currentPage }}/{{ totalPages }} 页
              </div>
              <el-pagination
                v-model:current-page="currentPage"
                v-model:page-size="pageSize"
                :page-sizes="[6]"
                :total="displayedResourceList.length"
                layout="prev, pager, next, jumper"
                class="pagination-component"
                @size-change="handleSizeChange"
                @current-change="handleCurrentChange"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧栏 -->
      <div class="column right-col">
        <!-- 热门下载资源 -->
        <div class="panel-box">
          <div class="panel-header">
            <span class="icon-box">▣</span> 热门下载资源
          </div>
          <div class="panel-content">
             <div class="rank-list">
               <div class="rank-item" v-for="(item, index) in topDownloads" :key="index">
                 <div class="rank-idx" :class="{'top3': index < 3}">{{ index + 1 }}</div>
                 <div class="rank-name" :title="item.name">{{ item.name }}</div>
                 <div class="rank-val">{{ item.downloads }}次</div>
               </div>
             </div>
          </div>
        </div>

        <!-- 资源上传趋势 -->
        <div class="panel-box">
           <div class="panel-header">
            <span class="icon-box">▣</span> 资源上传趋势
          </div>
          <div class="panel-content">
             <v-chart class="chart" :option="uploadTrendOption" autoresize />
          </div>
        </div>
      </div>
    </div>
    
    <!-- 上传资源弹窗 -->
    <el-dialog
      v-model="uploadDialogVisible"
      title="上传教学资源"
      width="500px"
      :close-on-click-modal="false"
      :append-to-body="true"
      :modal="false"
      :modal-class="'upload-resource-modal'"
      class="upload-resource-dialog"
    >
      <el-form :model="uploadForm" label-width="80px" class="upload-form">
        <el-form-item label="课程" required>
          <el-select 
            v-model="uploadForm.courseId" 
            placeholder="请选择课程" 
            style="width: 100%"
            popper-class="upload-resource-select-dropdown"
          >
            <el-option
              v-for="course in courses"
              :key="course.id"
              :label="course.courseName"
              :value="course.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="文件名">
          <el-input v-model="uploadForm.fileName" disabled />
        </el-form-item>
        <el-form-item label="文件" required>
          <el-upload
            class="file-upload"
            :auto-upload="false"
            :show-file-list="false"
            :on-change="handleUploadFileChange"
          >
            <el-button type="primary" plain>
              <el-icon><Upload /></el-icon>
              选择文件
            </el-button>
          </el-upload>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="uploadDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitUpload">上传</el-button>
        </div>
      </template>
    </el-dialog>
    
    <!-- 修改文件名弹窗 -->
    <el-dialog
      v-model="editDialogVisible"
      title="修改文件名"
      width="500px"
      :close-on-click-modal="false"
      :append-to-body="true"
      :modal="false"
      :modal-class="'edit-resource-modal'"
      class="edit-resource-dialog"
    >
      <el-form :model="editForm" label-width="80px" class="edit-form">
        <el-form-item label="文件名" required>
          <el-input 
            v-model="editForm.fileName" 
            placeholder="请输入新的文件名"
            maxlength="100"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="editDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitEdit">确定</el-button>
        </div>
      </template>
    </el-dialog>
    
    <!-- 预览弹窗 -->
    <el-dialog
      v-model="previewDialogVisible"
      :title="previewFileName"
      width="90%"
      top="10vh"
      :close-on-click-modal="true"
      :append-to-body="true"
      :modal="true"
      class="preview-dialog"
    >
      <div class="preview-container">
        <iframe 
          v-if="previewUrl" 
          :src="previewUrl" 
          frameborder="0"
          class="preview-iframe"
        ></iframe>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart, BarChart, PieChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent
} from 'echarts/components'
import VChart from 'vue-echarts'
import { Document, Plus, Upload } from '@element-plus/icons-vue'
import http from '@/api/http.js'
import dayjs from 'dayjs'
import { ElMessage, ElMessageBox } from 'element-plus'
import backgroundImage from '@/assets/icon/背景.png'

use([
  CanvasRenderer, LineChart, BarChart, PieChart,
  TitleComponent, TooltipComponent, LegendComponent, GridComponent
])

// 状态定义
const loading = ref(false)
const rawResources = ref([])
const courseMap = ref({}) // courseId -> courseName
const courses = ref([]) // 所有课程列表
const selectedCourseId = ref('all') // 选中的课程ID，'all'表示全部，默认选择全部
const previewDialogVisible = ref(false)
const previewUrl = ref('')
const previewFileName = ref('')
const uploadDialogVisible = ref(false)
const uploadForm = ref({
  courseId: '',
  fileName: '',
  file: null
})
const editDialogVisible = ref(false)
const editForm = ref({
  id: null,
  fileName: ''
})
// 批量操作相关状态
const selectedResourceIds = ref([]) // 选中的资源ID列表
const selectAll = ref(false) // 全选状态
const searchKeyword = ref('') // 搜索关键词
// 文件类型筛选状态
const selectedFileTypes = ref([]) // 选中的文件类型列表（空数组表示显示全部）
const resourceTypeChart = ref(null) // 图表引用
// 分页相关状态
const currentPage = ref(1) // 当前页码
const pageSize = ref(6) // 每页显示数量

// 筛选后的资源列表
const filteredResources = computed(() => {
    if (selectedCourseId.value === 'all' || !selectedCourseId.value) {
        return rawResources.value
    }
    return rawResources.value.filter(r => r.courseId === selectedCourseId.value)
})

// 统计数据（基于筛选后的资源）
const totalResources = computed(() => filteredResources.value.length)
const ingestedResources = computed(() => filteredResources.value.filter(r => r.isIngested).length)
const pendingResources = computed(() => filteredResources.value.filter(r => !r.isIngested).length)
const totalCourses = computed(() => courses.value.length)
const totalDownloads = computed(() => {
    return filteredResources.value.reduce((sum, r) => {
        return sum + (r.downloadCount || 0)
    }, 0)
})

// 左侧 - 资源类型分布
const resourceTypeOption = computed(() => {
  const typeCount = {}
  filteredResources.value.forEach(r => {
    const type = r.fileType || 'OTHER'
    typeCount[type] = (typeCount[type] || 0) + 1
  })
  
  const allTypes = Object.keys(typeCount)
  
  // 如果selectedFileTypes为空，表示显示全部
  const visibleTypes = selectedFileTypes.value.length === 0 ? allTypes : selectedFileTypes.value
  
  // 构建图例选中状态：未选中的类型会被隐藏
  const legendSelected = {}
  allTypes.forEach(type => {
    legendSelected[type] = visibleTypes.includes(type)
  })
  
  const data = allTypes.map(type => {
    const isSelected = visibleTypes.includes(type)
    return {
      name: type,
      value: typeCount[type],
      itemStyle: {
        borderRadius: 10,
        borderColor: isSelected ? '#00f2fe' : '#666',
        borderWidth: isSelected ? 3 : 1,
        shadowBlur: isSelected ? 10 : 0,
        shadowColor: isSelected ? 'rgba(0, 242, 254, 0.8)' : 'transparent'
      }
    }
  })
  
  // 默认如果没数据
  if (data.length === 0) {
      return {
        tooltip: { trigger: 'item' },
        series: [{ type: 'pie', data: [{name: '无数据', value: 0}] }]
      }
  }

  return {
    tooltip: { 
      trigger: 'item',
      formatter: '{b}: {c} ({d}%)'
    },
    legend: { 
      top: '5%', 
      left: 'center', 
      textStyle: { color: '#fff' },
      selected: legendSelected,
      selectedMode: true // 允许点击图例进行筛选
    },
    series: [{
      name: '资源类型',
      type: 'pie',
      radius: ['40%', '70%'],
      avoidLabelOverlap: false,
      itemStyle: {
        borderRadius: 10,
        borderColor: '#fff',
        borderWidth: 2
      },
      label: { show: false, position: 'center' },
      emphasis: {
        label: { show: true, fontSize: 20, fontWeight: 'bold', color: '#fff' },
        itemStyle: {
          shadowBlur: 15,
          shadowColor: 'rgba(0, 242, 254, 0.8)'
        }
      },
      labelLine: { show: false },
      data: data
    }]
  }
})

// 左侧 - 课程资源排行
const courseRankOption = computed(() => {
    const courseCount = {}
    filteredResources.value.forEach(r => {
        const cName = courseMap.value[r.courseId] || '未知课程'
        courseCount[cName] = (courseCount[cName] || 0) + 1
    })
    
    // 按数量从大到小排序并取前6
    const sorted = Object.entries(courseCount)
        .sort((a, b) => b[1] - a[1])  // 从大到小排序
        .slice(0, 6)
        
    return {
      grid: { top: 10, right: 30, bottom: 0, left: 50, containLabel: true },
      xAxis: { type: 'value', show: false },
      yAxis: {
        type: 'category',
        data: sorted.map(i => i[0]),
        axisLine: { show: false },
        axisTick: { show: false },
        axisLabel: { color: '#fff', fontSize: 12 },
        inverse: false  // 确保大的在上面（不反转）
      },
      series: [{
        type: 'bar',
        data: sorted.map(i => i[1]),
        itemStyle: {
          color: (params) => {
            const colors = ['#f59e0b', '#7c3aed', '#00f2fe', '#00bfff', '#f43f5e', '#10b981']
            return colors[params.dataIndex % colors.length]
          },
          borderRadius: [0, 10, 10, 0]
        },
        barWidth: 12,
        label: { show: true, position: 'right', color: '#fff', formatter: '{c} 份' }
      }]
    }
})

// 中间 - 顶部统计圆环
const resourceStats = computed(() => [
  { value: totalCourses.value, label: '总课程数', subLabel: '总课程数' },
  { value: totalResources.value > 0 ? Math.round((ingestedResources.value / totalResources.value) * 100) + '%' : '0%', label: '入库率', subLabel: '资源管理' },
  { value: pendingResources.value, label: '待入库', subLabel: '待入库资源' },
  { value: totalDownloads.value, label: '总下载数', subLabel: '总下载数' }
])

// 中间 - 资源列表数据（包含搜索过滤）
const resourceList = computed(() => {
    return filteredResources.value.map(r => ({
        id: r.id,
        name: r.fileName,
        course: courseMap.value[r.courseId] || '未知课程',
        type: r.fileType || 'FILE',
        date: r.uploadedAt ? dayjs(r.uploadedAt).format('YYYY-MM-DD HH:mm:ss') : '-',
        status: r.isIngested ? '已入库' : '待入库',
        filePath: r.filePath,
        isIngested: r.isIngested
    }))
})

// 显示的资源列表（应用搜索过滤和文件类型筛选）
const displayedResourceList = computed(() => {
    let filtered = resourceList.value
    
    // 文件类型筛选
    if (selectedFileTypes.value.length > 0) {
        filtered = filtered.filter(r => {
            const fileType = r.type || 'OTHER'
            return selectedFileTypes.value.includes(fileType)
        })
    }
    
    // 搜索关键词筛选
    if (searchKeyword.value && searchKeyword.value.trim() !== '') {
        const keyword = searchKeyword.value.trim().toLowerCase()
        filtered = filtered.filter(r => 
            r.name.toLowerCase().includes(keyword)
        )
    }
    
    return filtered
})

// 分页后的资源列表
const paginatedResourceList = computed(() => {
    const start = (currentPage.value - 1) * pageSize.value
    const end = start + pageSize.value
    return displayedResourceList.value.slice(start, end)
})

// 总页数
const totalPages = computed(() => {
    return Math.ceil(displayedResourceList.value.length / pageSize.value)
})

// 分页处理方法
const handleSizeChange = (val) => {
    // 强制设置为6，因为最大记录数为6
    pageSize.value = 6
    currentPage.value = 1 // 改变每页数量时重置到第一页
    // 清除选中状态
    selectedResourceIds.value = []
    selectAll.value = false
}

const handleCurrentChange = (val) => {
    currentPage.value = val
    // 切换页面时清除选中状态
    selectedResourceIds.value = []
    selectAll.value = false
}

const getStatusClass = (status) => {
  return status === '已入库' ? 'text-green' : 'text-yellow'
}

// 右侧 - 热门下载
const topDownloads = computed(() => {
    // 复制并排序
    const sorted = [...filteredResources.value].sort((a, b) => {
        const countA = a.downloadCount || 0
        const countB = b.downloadCount || 0
        return countB - countA
    })
    return sorted.slice(0, 6).map(r => ({
        name: r.fileName,
        downloads: r.downloadCount || 0
    }))
})

// 右侧 - 上传趋势
const uploadTrendOption = computed(() => {
    // 获取最近7天的日期
    const dates = []
    const xLabels = []
    for (let i = 6; i >= 0; i--) {
        const d = dayjs().subtract(i, 'day')
        dates.push(d.format('YYYY-MM-DD'))
        xLabels.push(d.format('MM-DD'))
    }
    
    // 统计每天上传数量（基于筛选后的资源）
    const counts = dates.map(date => {
        return filteredResources.value.filter(r => {
            if (!r.uploadedAt) return false
            return dayjs(r.uploadedAt).format('YYYY-MM-DD') === date
        }).length
    })

    return {
      grid: { top: 30, right: 20, bottom: 20, left: 40 },
      tooltip: { trigger: 'axis' },
      xAxis: {
        type: 'category',
        data: xLabels,
        axisLine: { lineStyle: { color: '#4facfe' } },
        axisLabel: { color: '#fff' }
      },
      yAxis: {
        type: 'value',
        splitLine: { lineStyle: { color: 'rgba(255,255,255,0.1)' } },
        axisLabel: { color: '#fff' },
        minInterval: 1
      },
      series: [{
        data: counts,
        type: 'line',
        smooth: true,
        areaStyle: {
          color: {
            type: 'linear',
            x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [{ offset: 0, color: '#00f2fe' }, { offset: 1, color: 'rgba(0,242,254,0)' }]
          }
        },
        itemStyle: { color: '#00f2fe' }
      }]
    }
})

const formatProgress = (percentage) => `${percentage}%`

// 课程筛选变化处理
const handleCourseFilterChange = () => {
    // 筛选逻辑已通过 computed 自动处理，这里可以添加其他逻辑
    console.log('课程筛选变更:', selectedCourseId.value)
    // 筛选时重置到第一页并清除选中状态
    currentPage.value = 1
    selectedResourceIds.value = []
    selectAll.value = false
}

// 上传资源按钮点击处理
const handleUploadClick = () => {
    uploadDialogVisible.value = true
    // 重置表单
    uploadForm.value = {
        courseId: '',
        fileName: '',
        file: null
    }
}

// 监听上传文件选择事件
const handleUploadFileChange = (file) => {
    if (file && file.raw) {
        uploadForm.value.file = file.raw
        uploadForm.value.fileName = file.name
    } else {
        uploadForm.value.file = null
        uploadForm.value.fileName = ''
    }
}

// 上传接口调用
const submitUpload = async () => {
    if (!uploadForm.value.file) {
        ElMessage.warning('请选择文件！')
        return
    }
    if (!uploadForm.value.courseId) {
        ElMessage.warning('请选择课程！')
        return
    }

    // 获取选中课程的教师ID
    const selectedCourse = courses.value.find(c => c.id === uploadForm.value.courseId)
    if (!selectedCourse || !selectedCourse.teacherId) {
        ElMessage.error('无法获取课程教师信息')
        return
    }

    const formData = new FormData()
    formData.append('file', uploadForm.value.file)
    formData.append('courseId', uploadForm.value.courseId)
    formData.append('teacherId', selectedCourse.teacherId)
    formData.append('type', 'resource')

    try {
        const res = await http.post({ 
            url: '/xiaozhi/teacher/upload', 
            data: formData,
            headers: { 'Content-Type': 'multipart/form-data' }
        })
        if (res && res.code === 200) {
            ElMessage.success('文件上传成功')
            uploadDialogVisible.value = false
            // 上传成功后刷新资源列表
            await loadData()
            // 重置上传表单
            uploadForm.value = {
                courseId: '',
                fileName: '',
                file: null
            }
        } else {
            ElMessage.error('上传失败：' + (res?.message || '未知错误'))
        }
    } catch (error) {
        ElMessage.error('上传接口异常：' + (error.message || '网络错误'))
    }
}

// API Call
const loadData = async () => {
    loading.value = true
    try {
        // Load Courses
        const courseRes = await http.get({ url: '/xiaozhi/teacher/courses/all' })
        if (courseRes && courseRes.code === 200) {
            courses.value = courseRes.data || []
            courses.value.forEach(c => {
                courseMap.value[c.id] = c.courseName
            })
        } else {
            ElMessage.warning('课程列表加载异常')
        }
        
        // Load Resources
        const resRes = await http.get({ url: '/xiaozhi/teacher/resources/all' })
        if (resRes && resRes.code === 200) {
            rawResources.value = resRes.data || []
            // 调试：打印第一条数据，查看字段名
            if (rawResources.value.length > 0) {
                console.log('资源数据示例:', rawResources.value[0])
                console.log('downloadCount 值:', rawResources.value[0].downloadCount)
            }
        } else {
            ElMessage.error('获取资源失败: ' + (resRes?.message || '未知错误'))
        }
    } catch (e) {
        ElMessage.error('数据加载异常: ' + (e.message || '网络错误'))
    } finally {
        loading.value = false
        // 数据加载完成后清除选中状态
        selectedResourceIds.value = []
        selectAll.value = false
    }
}

const downloadResource = async (row) => {
    if (!row.filePath) {
        ElMessage.error('文件路径不存在')
        return
    }
    
    // 增加下载次数
    try {
        await http.post({ 
            url: '/xiaozhi/teacher/resource/download-count', 
            params: { id: row.id }
        })
        // 乐观更新本地数据
        const target = rawResources.value.find(r => r.id === row.id)
        if (target) {
            target.downloadCount = (target.downloadCount || 0) + 1
        }
    } catch (e) {
        console.error('增加下载次数失败', e)
    }

    const link = document.createElement('a')
    link.href = row.filePath
    link.download = row.name
    link.target = '_blank'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
}

const viewResource = (row) => {
    if (!row.filePath) {
        ElMessage.warning('无法预览该资源')
        return
    }
    
    // 预览功能：根据文件类型选择不同的预览方式
    const fileType = row.type?.toLowerCase() || ''
    const filePath = row.filePath
    const fileName = row.name || '预览文件'
    
    // PDF、图片等可以在弹窗中预览
    if (fileType === 'pdf' || fileType === 'png' || fileType === 'jpg' || fileType === 'jpeg' || fileType === 'gif' || fileType === 'bmp' || fileType === 'webp') {
        // 使用弹窗预览
        previewFileName.value = fileName
        previewUrl.value = filePath
        previewDialogVisible.value = true
    } else if (fileType === 'docx' || fileType === 'doc' || fileType === 'xlsx' || fileType === 'xls' || fileType === 'pptx' || fileType === 'ppt') {
        // Office 文件：使用微软 Office Online 预览服务
        const officePreviewUrl = `https://view.officeapps.live.com/op/view.aspx?src=${encodeURIComponent(filePath)}`
        previewFileName.value = fileName
        previewUrl.value = officePreviewUrl
        previewDialogVisible.value = true
    } else if (fileType === 'txt' || fileType === 'md') {
        // 文本文件：使用 fetch 获取内容并在弹窗显示
        fetch(filePath)
            .then(response => response.text())
            .then(text => {
                previewFileName.value = fileName
                // 创建 data URL 用于预览
                const blob = new Blob([text], { type: 'text/plain;charset=utf-8' })
                previewUrl.value = URL.createObjectURL(blob)
                previewDialogVisible.value = true
            })
            .catch(() => {
                ElMessage.warning('无法加载文本内容，请使用下载功能')
            })
    } else {
        // 其他文件类型：提示无法预览，建议下载
        ElMessage.warning('该文件类型不支持在线预览，请使用下载功能')
    }
}

// 修改资源文件名
const editResource = (row) => {
    editForm.value = {
        id: row.id,
        fileName: row.name
    }
    editDialogVisible.value = true
}

// 提交修改
const submitEdit = async () => {
    if (!editForm.value.fileName || !editForm.value.fileName.trim()) {
        ElMessage.warning('文件名不能为空')
        return
    }
    
    try {
        const res = await http.put({ 
            url: '/xiaozhi/teacher/resource/admin/update-name', 
            params: {
                id: editForm.value.id,
                fileName: editForm.value.fileName.trim()
            }
        })
        
        if (res && res.code === 200) {
            ElMessage.success('文件名修改成功')
            editDialogVisible.value = false
            // 刷新数据
            await loadData()
        } else {
            ElMessage.error(res?.message || '修改失败')
        }
    } catch (error) {
        ElMessage.error('修改失败：' + (error.message || '网络错误'))
    }
}

// 管理端入库：只更新数据库标记，不进行实际向量化入库
const ingestResource = async (row) => {
    if (row.status === '已入库') {
        ElMessage.info('该资源已入库')
        return
    }
    
    try {
        const res = await http.post({ 
            url: '/xiaozhi/teacher/resource/admin/ingest', 
            params: { id: row.id }
        })
        
        if (res && res.code === 200) {
            ElMessage.success('资源已入库')
            // 乐观更新本地数据
            const target = rawResources.value.find(r => r.id === row.id)
            if (target) {
                target.isIngested = true
            }
            // 刷新数据以确保所有统计数据更新
            await loadData()
        } else {
            ElMessage.error(res?.message || '入库失败')
        }
    } catch (error) {
        ElMessage.error('入库失败：' + (error.message || '网络错误'))
    }
}

// 管理端取消入库：修改数据库字段，将isIngested设置为false
const cancelIngestResource = async (row) => {
    if (row.status !== '已入库') {
        ElMessage.info('该资源未入库')
        return
    }
    
    try {
        // 调用管理端API取消入库（修改数据库字段）
        const res = await http.post({ 
            url: '/xiaozhi/teacher/resource/admin/cancel-ingest', 
            params: { id: row.id }
        })
        
        if (res && res.code === 200) {
            ElMessage.success('已取消入库')
            // 乐观更新本地数据
            const target = rawResources.value.find(r => r.id === row.id)
            if (target) {
                target.isIngested = false
            }
            // 刷新数据以确保所有统计数据更新
            await loadData()
        } else {
            ElMessage.error(res?.message || '取消入库失败')
        }
    } catch (error) {
        ElMessage.error('取消入库失败：' + (error.message || '网络错误'))
    }
}

// 删除资源
const deleteResource = async (row) => {
    try {
        await ElMessageBox.confirm(
            `确定要删除资源"${row.name}"吗？此操作不可恢复！`,
            '删除确认',
            {
                confirmButtonText: '确定删除',
                cancelButtonText: '取消',
                type: 'warning',
                confirmButtonClass: 'el-button--danger'
            }
        )
        
        // 调用删除接口
        const res = await http.delete({ 
            url: '/xiaozhi/teacher/resource/delete', 
            params: { id: row.id }
        })
        
        if (res && res.code === 200) {
            ElMessage.success('资源删除成功')
            // 刷新资源列表
            await loadData()
            // 清除选中状态
            selectedResourceIds.value = []
            selectAll.value = false
        } else {
            ElMessage.error(res?.message || '删除失败')
        }
    } catch (error) {
        if (error === 'cancel') {
            // 用户取消删除
            return
        }
        ElMessage.error('删除失败：' + (error.message || '网络错误'))
    }
}

// 全选/取消全选（只选择当前页）
const handleSelectAll = (checked) => {
    if (checked) {
        // 获取当前页的资源ID
        const currentPageIds = paginatedResourceList.value.map(r => r.id)
        // 合并到已选中的ID列表（保留其他页的选中状态）
        currentPageIds.forEach(id => {
            if (!selectedResourceIds.value.includes(id)) {
                selectedResourceIds.value.push(id)
            }
        })
    } else {
        // 只取消当前页的选中状态
        const currentPageIds = paginatedResourceList.value.map(r => r.id)
        selectedResourceIds.value = selectedResourceIds.value.filter(id => !currentPageIds.includes(id))
    }
}

// 单个选择变化时，更新全选状态（只检查当前页）
const handleSelectChange = () => {
    const currentPageIds = paginatedResourceList.value.map(r => r.id)
    if (currentPageIds.length === 0) {
        selectAll.value = false
    } else {
        selectAll.value = currentPageIds.every(id => selectedResourceIds.value.includes(id))
    }
}

// 搜索处理
const handleSearch = () => {
    // 搜索时清除选中状态并重置到第一页
    selectedResourceIds.value = []
    selectAll.value = false
    currentPage.value = 1
}

// 图表点击事件处理（饼图点击）
const handleChartClick = (params) => {
    if (!params || !params.name) return
    
    const clickedType = params.name
    toggleFileType(clickedType)
}

// 切换文件类型选中状态
const toggleFileType = (fileType) => {
    const index = selectedFileTypes.value.indexOf(fileType)
    
    if (index > -1) {
        // 如果已选中，则取消选中
        selectedFileTypes.value.splice(index, 1)
    } else {
        // 如果未选中，则添加到选中列表
        selectedFileTypes.value.push(fileType)
    }
    
    // 筛选时清除选中状态并重置到第一页
    selectedResourceIds.value = []
    selectAll.value = false
    currentPage.value = 1
}

// 设置图表事件监听
const setupChartEvents = () => {
    if (resourceTypeChart.value && resourceTypeChart.value.chart) {
        const chartInstance = resourceTypeChart.value.chart
        
        // 监听图例点击事件
        chartInstance.off('legendselectchanged')
        chartInstance.on('legendselectchanged', (params) => {
            const typeName = params.name
            const isSelected = params.selected[typeName]
            
            // 获取所有文件类型
            const typeCount = {}
            filteredResources.value.forEach(r => {
                const type = r.fileType || 'OTHER'
                typeCount[type] = (typeCount[type] || 0) + 1
            })
            const allTypes = Object.keys(typeCount)
            
            if (selectedFileTypes.value.length === 0) {
                // 如果当前是显示全部，点击图例后需要初始化selectedFileTypes
                // 如果选中，则只显示选中的类型；如果取消，则显示除该类型外的所有类型
                if (isSelected) {
                    // 选中某个类型，只显示该类型
                    selectedFileTypes.value = [typeName]
                } else {
                    // 取消某个类型，显示除该类型外的所有类型
                    selectedFileTypes.value = allTypes.filter(t => t !== typeName)
                }
            } else {
                // 如果已经有筛选，直接更新
                if (isSelected) {
                    // 图例被选中，添加到筛选列表
                    if (!selectedFileTypes.value.includes(typeName)) {
                        selectedFileTypes.value.push(typeName)
                    }
                } else {
                    // 图例被取消选中，从筛选列表移除
                    const index = selectedFileTypes.value.indexOf(typeName)
                    if (index > -1) {
                        selectedFileTypes.value.splice(index, 1)
                    }
                }
            }
            
            // 筛选时清除选中状态并重置到第一页
            selectedResourceIds.value = []
            selectAll.value = false
            currentPage.value = 1
        })
    }
}

// 批量操作命令处理
const handleBatchCommand = (command) => {
    if (selectedResourceIds.value.length === 0) {
        ElMessage.warning('请先选择要操作的资源')
        return
    }
    
    if (command === 'delete') {
        handleBatchDelete()
    } else if (command === 'ingest') {
        handleBatchIngest()
    }
}

// 批量删除
const handleBatchDelete = async () => {
    if (selectedResourceIds.value.length === 0) {
        ElMessage.warning('请先选择要删除的资源')
        return
    }
    
    try {
        await ElMessageBox.confirm(
            `确定要删除选中的 ${selectedResourceIds.value.length} 个资源吗？此操作不可恢复！`,
            '批量删除确认',
            {
                confirmButtonText: '确定删除',
                cancelButtonText: '取消',
                type: 'warning',
                confirmButtonClass: 'el-button--danger'
            }
        )
        
        // 批量删除接口调用
        const deletePromises = selectedResourceIds.value.map(id => 
            http.delete({ 
                url: '/xiaozhi/teacher/resource/delete',
                params: { id }
            }).catch(error => {
                console.error(`删除资源 ${id} 失败:`, error)
                return { code: 500, message: error.message }
            })
        )
        
        const results = await Promise.all(deletePromises)
        const successCount = results.filter(r => r && r.code === 200).length
        const failCount = results.length - successCount
        
        if (successCount > 0) {
            ElMessage.success(`成功删除 ${successCount} 个资源${failCount > 0 ? `，${failCount} 个删除失败` : ''}`)
            // 刷新资源列表
            await loadData()
            // 清除选中状态
            selectedResourceIds.value = []
            selectAll.value = false
        } else {
            ElMessage.error('批量删除失败')
        }
    } catch (error) {
        if (error === 'cancel') {
            // 用户取消删除
            return
        }
        ElMessage.error('批量删除失败：' + (error.message || '网络错误'))
    }
}

// 批量入库
const handleBatchIngest = async () => {
    if (selectedResourceIds.value.length === 0) {
        ElMessage.warning('请先选择要入库的资源')
        return
    }
    
    // 过滤掉已入库的资源
    const toIngestIds = selectedResourceIds.value.filter(id => {
        const resource = displayedResourceList.value.find(r => r.id === id)
        return resource && !resource.isIngested
    })
    
    if (toIngestIds.length === 0) {
        ElMessage.info('选中的资源都已入库')
        return
    }
    
    try {
        await ElMessageBox.confirm(
            `确定要将选中的 ${toIngestIds.length} 个资源入库吗？`,
            '批量入库确认',
            {
                confirmButtonText: '确定入库',
                cancelButtonText: '取消',
                type: 'info'
            }
        )
        
        // 批量入库接口调用
        const ingestPromises = toIngestIds.map(id => 
            http.post({ 
                url: '/xiaozhi/teacher/resource/admin/ingest',
                params: { id }
            }).catch(error => {
                console.error(`入库资源 ${id} 失败:`, error)
                return { code: 500, message: error.message }
            })
        )
        
        const results = await Promise.all(ingestPromises)
        const successCount = results.filter(r => r && r.code === 200).length
        const failCount = results.length - successCount
        
        if (successCount > 0) {
            ElMessage.success(`成功入库 ${successCount} 个资源${failCount > 0 ? `，${failCount} 个入库失败` : ''}`)
            // 刷新资源列表
            await loadData()
            // 清除选中状态
            selectedResourceIds.value = []
            selectAll.value = false
        } else {
            ElMessage.error('批量入库失败')
        }
    } catch (error) {
        if (error === 'cancel') {
            // 用户取消入库
            return
        }
        ElMessage.error('批量入库失败：' + (error.response?.data?.message || error.message))
    }
}

// 监听分页列表变化，自动更新全选状态（只检查当前页）
watch(paginatedResourceList, () => {
    const currentPageIds = paginatedResourceList.value.map(r => r.id)
    if (currentPageIds.length === 0) {
        selectAll.value = false
    } else {
        selectAll.value = currentPageIds.every(id => selectedResourceIds.value.includes(id))
    }
}, { deep: true })

// 监听选中资源变化，更新全选状态（只检查当前页）
watch(selectedResourceIds, () => {
    const currentPageIds = paginatedResourceList.value.map(r => r.id)
    if (currentPageIds.length === 0) {
        selectAll.value = false
    } else {
        selectAll.value = currentPageIds.every(id => selectedResourceIds.value.includes(id))
    }
})

// 监听页码变化，更新全选状态
watch([currentPage, pageSize], () => {
    const currentPageIds = paginatedResourceList.value.map(r => r.id)
    if (currentPageIds.length === 0) {
        selectAll.value = false
    } else {
        selectAll.value = currentPageIds.every(id => selectedResourceIds.value.includes(id))
    }
})

// 确保每页数量始终为6
watch(pageSize, (newVal) => {
    if (newVal !== 6) {
        pageSize.value = 6
    }
})

onMounted(() => {
    loadData()
    // 延迟设置图表事件，确保图表已渲染
    setTimeout(() => {
        setupChartEvents()
    }, 500)
})

// 监听图表实例变化，设置事件
watch(() => resourceTypeChart.value, (newVal) => {
    if (newVal && newVal.chart) {
        setupChartEvents()
    }
}, { immediate: true, deep: true })

// 监听图表配置变化，重新设置事件
watch(() => resourceTypeOption.value, () => {
    setTimeout(() => {
        setupChartEvents()
    }, 100)
}, { deep: true })

</script>

<style scoped>
.course-resource-dashboard {
  display: flex;
  height: 100%;
  width: 100%;
  padding: 0 10px;
  box-sizing: border-box;
  position: relative;
}

/* Layout */
.content-layout {
  flex: 1;
  display: flex;
  gap: 15px;
  position: relative;
  z-index: 10;
  background: transparent;
}

.column {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.left-col, .right-col {
  width: 25%;
  min-width: 300px;
}

.center-col {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 15px;
  /* Add padding bottom to avoid nav overlap */
  padding-bottom: 90px;
}

/* Panels */
.panel-box {
  background: rgba(8, 16, 45, 0.6);
  border: 1px solid rgba(0, 191, 255, 0.3);
  flex: 1;
  display: flex;
  flex-direction: column;
  box-shadow: inset 0 0 20px rgba(0, 191, 255, 0.1);
  border-radius: 4px;
}

.panel-header {
  height: 40px;
  display: flex;
  align-items: center;
  padding: 0 15px;
  color: #fff;
  font-size: 16px;
  background: rgba(0, 191, 255, 0.1);
  border-bottom: 1px solid rgba(0, 191, 255, 0.2);
}

.icon-box {
  color: #00f2fe;
  margin-right: 8px;
}

.panel-content {
  flex: 1;
  position: relative;
  padding: 10px;
  min-height: 200px;
  overflow: hidden;
}

.chart-title {
  font-size: 12px;
  color: #aaa;
  margin-bottom: 10px;
}

.chart {
  width: 100%;
  height: 100%;
}

/* Stats Row */
.stats-row {
  display: flex;
  justify-content: space-around;
  margin-bottom: 15px;
}
.stat-item {
  text-align: center;
}
.stat-item .num {
  font-size: 20px;
  font-weight: bold;
  color: #fff;
  font-family: 'Impact', sans-serif;
}
.stat-item .num.highlight { color: #00f2fe; }
.stat-item .num.warning { color: #f59e0b; }
.stat-item .label {
  font-size: 10px;
  color: #aaa;
}

/* Course Filter Section */
.course-filter-section {
  margin-top: 15px;
}
.course-filter-select {
  width: 100%;
  margin-top: 10px;
}
.course-filter-select :deep(.el-select__wrapper) {
  background: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid #00f2fe !important;
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.5), inset 0 0 10px rgba(0, 242, 254, 0.2) !important;
  border-radius: 4px;
}
.course-filter-select :deep(.el-input__wrapper) {
  background: rgba(8, 16, 45, 0.6) !important;
  background-color: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid #00f2fe !important;
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.5), inset 0 0 10px rgba(0, 242, 254, 0.2) !important;
  padding: 10px 15px !important;
  border-radius: 4px;
  display: flex !important;
  align-items: center !important;
  min-height: 40px;
}
.course-filter-select :deep(.el-input__inner) {
  background: transparent !important;
  background-color: transparent !important;
  border: none !important;
  color: #00f2fe !important;
  padding: 0 !important;
  font-size: 14px;
  text-shadow: 0 0 8px rgba(0, 242, 254, 0.8);
  font-weight: 500;
  line-height: 1.5;
  height: auto;
  display: flex;
  align-items: center;
}
.course-filter-select :deep(.el-input__inner::placeholder) {
  color: rgba(0, 242, 254, 0.6);
  text-shadow: 0 0 5px rgba(0, 242, 254, 0.5);
}
.course-filter-select :deep(.el-select__caret) {
  color: #00f2fe !important;
  filter: drop-shadow(0 0 5px rgba(0, 242, 254, 0.8));
  font-size: 16px;
  margin-left: 8px;
  flex-shrink: 0;
}
.course-filter-select :deep(.el-select__selected-item) {
  flex: 1;
  display: flex;
  align-items: center;
}
.course-filter-select :deep(.el-input) {
  background: transparent !important;
  background-color: transparent !important;
}
.course-filter-select :deep(.el-input.is-focus .el-input__wrapper) {
  box-shadow: 0 0 15px rgba(0, 242, 254, 0.7), inset 0 0 15px rgba(0, 242, 254, 0.3) !important;
  background: rgba(8, 16, 45, 0.8) !important;
  background-color: rgba(8, 16, 45, 0.8) !important;
  border: 1px solid #00f2fe !important;
}
.course-filter-select :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 15px rgba(0, 242, 254, 0.7), inset 0 0 15px rgba(0, 242, 254, 0.3) !important;
  background: rgba(8, 16, 45, 0.8) !important;
  background-color: rgba(8, 16, 45, 0.8) !important;
  border: 1px solid #00f2fe !important;
}
.course-filter-select :deep(.el-select) {
  background: transparent !important;
  background-color: transparent !important;
}
.course-filter-select :deep(.el-select__tags) {
  background: transparent !important;
  background-color: transparent !important;
}
/* 下拉菜单背景 - 使用全局样式，因为下拉菜单挂载到 body */
:deep(.course-filter-dropdown),
.course-filter-dropdown {
  background: rgba(8, 16, 45, 0.95) !important;
  background-color: rgba(8, 16, 45, 0.95) !important;
  border: 1px solid #00f2fe !important;
  box-shadow: 0 0 15px rgba(0, 242, 254, 0.6), inset 0 0 10px rgba(0, 242, 254, 0.2) !important;
  border-radius: 4px;
}
:deep(.course-filter-dropdown .el-select-dropdown__item),
.course-filter-dropdown .el-select-dropdown__item {
  background: transparent !important;
  background-color: transparent !important;
  color: #fff !important;
  padding: 10px 15px;
  transition: all 0.3s ease;
}
:deep(.course-filter-dropdown .el-select-dropdown__item:hover),
.course-filter-dropdown .el-select-dropdown__item:hover {
  background: rgba(0, 242, 254, 0.2) !important;
  background-color: rgba(0, 242, 254, 0.2) !important;
  color: #00f2fe !important;
  text-shadow: 0 0 8px rgba(0, 242, 254, 0.8);
  box-shadow: inset 0 0 10px rgba(0, 242, 254, 0.3);
}
:deep(.course-filter-dropdown .el-select-dropdown__item.is-selected),
.course-filter-dropdown .el-select-dropdown__item.is-selected {
  background: rgba(0, 242, 254, 0.3) !important;
  background-color: rgba(0, 242, 254, 0.3) !important;
  color: #00f2fe !important;
  text-shadow: 0 0 10px rgba(0, 242, 254, 1);
  font-weight: 600;
}
/* 当选择全部时，显示"全部"而不是占位符 */
.course-filter-select :deep(.el-select__selected-item) {
  color: #00f2fe !important;
  text-shadow: 0 0 8px rgba(0, 242, 254, 0.8);
  font-weight: 500;
}

/* Center Column Specifics */
.center-top-panel {
  background: rgba(8, 16, 45, 0.4);
  border: 1px solid rgba(0, 191, 255, 0.2);
  padding: 15px;
  text-align: center;
}

.center-title {
  color: #00f2fe;
  font-size: 20px;
  font-weight: bold;
  letter-spacing: 2px;
}
.center-subtitle {
  color: #00bfff;
  margin-bottom: 20px;
  font-size: 14px;
}

.process-circles {
  display: flex;
  justify-content: space-around;
  margin-top: 15px;
}

.process-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.circle-ring {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  border: 3px solid #00f2fe;
  box-shadow: 0 0 15px #00f2fe;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background: rgba(0, 242, 254, 0.1);
  margin-bottom: 10px;
  position: relative;
}

.pct {
  font-size: 18px;
  font-weight: bold;
  color: #fff;
}

.status-badge {
  font-size: 10px;
  background: #00bfff;
  padding: 1px 6px;
  border-radius: 10px;
  margin-top: 2px;
}

.proc-name {
  color: #00f2fe;
  font-size: 14px;
}

/* Table */
.center-middle-panel {
  flex: 1;
  background: rgba(8, 16, 45, 0.6);
  border: 1px solid rgba(0, 191, 255, 0.3);
  display: flex;
  flex-direction: column;
  padding: 10px;
  position: relative;
  overflow: hidden;
  min-height: 500px;
}

.center-middle-panel::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: v-bind('`url("${backgroundImage}")`');
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  z-index: 0;
  pointer-events: none;
  opacity: 0.3;
}

.panel-header-center {
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 10px;
  color: #00bfff;
  padding: 10px;
  z-index: 1;
}

.header-title {
  text-align: center;
  font-size: 16px;
  letter-spacing: 2px;
  color: #00bfff;
  width: 100%;
}

.header-actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.select-all-checkbox {
  color: #00bfff !important;
}

.select-all-checkbox :deep(.el-checkbox__label) {
  color: #00bfff !important;
  text-shadow: 0 0 8px rgba(0, 242, 254, 0.8);
}

.select-all-checkbox :deep(.el-checkbox__input.is-checked .el-checkbox__inner) {
  background-color: #00f2fe !important;
  border-color: #00f2fe !important;
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.8);
}

.select-all-checkbox :deep(.el-checkbox__inner) {
  border-color: #00f2fe !important;
}

.batch-action-btn {
  background: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid #00f2fe !important;
  color: #00f2fe !important;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.5), inset 0 0 5px rgba(0, 242, 254, 0.2) !important;
  padding: 8px 12px !important;
  min-width: 40px;
  transition: all 0.3s ease;
}

.batch-action-btn:hover:not(:disabled) {
  background: rgba(8, 16, 45, 0.8) !important;
  box-shadow: 0 0 12px rgba(0, 242, 254, 0.7), inset 0 0 8px rgba(0, 242, 254, 0.3) !important;
  color: #00f2fe !important;
}

.batch-action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 10px;
}

.search-box {
  width: 250px;
}

.search-input :deep(.el-input__wrapper) {
  background: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid rgba(0, 242, 254, 0.5) !important;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.3), inset 0 0 5px rgba(0, 242, 254, 0.1) !important;
  border-radius: 4px;
}

.search-input :deep(.el-input__wrapper:hover) {
  border-color: #00f2fe !important;
  box-shadow: 0 0 12px rgba(0, 242, 254, 0.5), inset 0 0 8px rgba(0, 242, 254, 0.2) !important;
}

.search-input :deep(.el-input__wrapper.is-focus) {
  border-color: #00f2fe !important;
  box-shadow: 0 0 15px rgba(0, 242, 254, 0.7), inset 0 0 10px rgba(0, 242, 254, 0.3) !important;
}

.search-input :deep(.el-input__inner) {
  background: transparent !important;
  color: #fff !important;
}

.search-input :deep(.el-input__inner::placeholder) {
  color: rgba(255, 255, 255, 0.4) !important;
}

.search-input :deep(.el-input__prefix) {
  color: #00bfff !important;
}

.search-input :deep(.el-input__suffix) {
  color: #00bfff !important;
}

.upload-resource-btn {
  background: rgba(8, 16, 45, 0.6) !important;
  background-color: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid #00f2fe !important;
  color: #00f2fe !important;
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.5), inset 0 0 10px rgba(0, 242, 254, 0.2) !important;
  padding: 8px 16px !important;
  font-size: 14px;
  text-shadow: 0 0 8px rgba(0, 242, 254, 0.8);
  transition: all 0.3s ease;
}

.upload-resource-btn:hover {
  background: rgba(8, 16, 45, 0.8) !important;
  background-color: rgba(8, 16, 45, 0.8) !important;
  box-shadow: 0 0 15px rgba(0, 242, 254, 0.7), inset 0 0 15px rgba(0, 242, 254, 0.3) !important;
  color: #00f2fe !important;
}

.upload-resource-btn :deep(.el-icon) {
  margin-right: 4px;
  filter: drop-shadow(0 0 5px rgba(0, 242, 254, 0.8));
}

.table-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  font-size: 12px;
  overflow: hidden;
  position: relative;
  z-index: 1;
  min-height: 400px;
  height: 100%;
}

.table-header {
  display: grid;
  grid-template-columns: 50px 1.5fr 1.2fr 0.7fr 0.85fr 1.2fr 1.8fr;
  background: rgba(0, 191, 255, 0.2);
  padding: 10px;
  color: #00f2fe;
  font-weight: bold;
  align-items: center;
}

.table-header > span {
  display: flex;
  align-items: center;
  justify-content: flex-start;
}

.status-header {
  justify-content: center !important;
}

.table-body {
  flex: 1;
  overflow-y: auto;
}

.table-row {
  display: grid;
  grid-template-columns: 50px 1.5fr 1.2fr 0.7fr 0.85fr 1.2fr 1.8fr;
  padding: 10px;
  color: #ddd;
  border-bottom: 1px solid rgba(255,255,255,0.05);
  align-items: center;
}
.table-row:nth-child(even) { background: rgba(255,255,255,0.02); }

.table-row > span {
  display: flex;
  align-items: center;
}

.status-col {
  display: flex;
  align-items: center;
  justify-content: center;
}

.status-tag {
  border-radius: 4px !important;
  font-size: 12px !important;
  padding: 4px 12px !important;
  border: none !important;
  font-weight: 500 !important;
}

.status-tag.el-tag--success {
  background-color: #d1fae5 !important;
  color: #10b981 !important;
}

.status-tag.el-tag--warning {
  background-color: #fee2e2 !important;
  color: #ef4444 !important;
}

.checkbox-col {
  display: flex;
  align-items: center;
  justify-content: center;
}

.checkbox-col :deep(.el-checkbox) {
  color: #00f2fe !important;
}

.checkbox-col :deep(.el-checkbox__input.is-checked .el-checkbox__inner) {
  background-color: #00f2fe !important;
  border-color: #00f2fe !important;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.8);
}

.checkbox-col :deep(.el-checkbox__inner) {
  border-color: #00f2fe !important;
}

.checkbox-col :deep(.el-checkbox__inner:hover) {
  border-color: #00bfff !important;
}

.col-name {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  display: flex;
  align-items: center;
  gap: 5px;
}

.action-col {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 10px;
  flex-wrap: nowrap;
}
.btn-text {
  color: #00f2fe;
  cursor: pointer;
  white-space: nowrap;
  flex-shrink: 0;
}
.btn-text:hover { text-decoration: underline; }
.btn-text.disabled {
  color: #666;
  cursor: not-allowed;
  opacity: 0.5;
}
.btn-text.disabled:hover { 
  text-decoration: none; 
}

.btn-delete {
  color: #f43f5e !important;
}

.btn-delete:hover {
  color: #ef4444 !important;
  text-shadow: 0 0 8px rgba(244, 63, 94, 0.8);
}

.btn-cancel-ingest {
  color: #f43f5e !important;
}

.btn-cancel-ingest:hover {
  color: #ef4444 !important;
  text-shadow: 0 0 8px rgba(244, 63, 94, 0.8);
}

.text-yellow { color: #f59e0b; }
.text-green { color: #10b981; }

.no-data {
    text-align: center;
    color: #999;
    padding: 20px;
}

/* 分页组件样式 */
.table-pagination {
  padding: 15px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(8, 16, 45, 0.3);
  border-top: 1px solid rgba(0, 191, 255, 0.2);
  position: relative;
  z-index: 1;
  flex-shrink: 0;
}

.pagination-info {
  color: #fff;
  font-size: 14px;
  white-space: nowrap;
}

.pagination-component {
  display: flex;
  align-items: center;
}

.pagination-component :deep(.el-pagination) {
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: flex-end;
}

.pagination-component :deep(.el-pagination__sizes) {
  color: #fff;
}

.pagination-component :deep(.el-pagination__sizes .el-select) {
  margin-right: 20px;
}

.pagination-component :deep(.el-pagination__sizes .el-select .el-input__wrapper) {
  background: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid rgba(0, 242, 254, 0.5) !important;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.3) !important;
}

.pagination-component :deep(.el-pagination__sizes .el-select .el-input__inner) {
  color: #fff !important;
}

.pagination-component :deep(.el-pagination__sizes .el-select__caret) {
  color: #00bfff !important;
}

.pagination-component :deep(.btn-prev),
.pagination-component :deep(.btn-next) {
  background: #fff !important;
  border: 1px solid rgba(255, 255, 255, 0.3) !important;
  color: #666 !important;
  border-radius: 4px;
  min-width: 32px;
  height: 32px;
}

.pagination-component :deep(.btn-prev:hover:not(.disabled)),
.pagination-component :deep(.btn-next:hover:not(.disabled)) {
  background: rgba(255, 255, 255, 0.9) !important;
  border-color: rgba(255, 255, 255, 0.5) !important;
  color: #333 !important;
}

.pagination-component :deep(.btn-prev.disabled),
.pagination-component :deep(.btn-next.disabled) {
  background: rgba(255, 255, 255, 0.3) !important;
  border-color: rgba(255, 255, 255, 0.2) !important;
  color: rgba(255, 255, 255, 0.5) !important;
  cursor: not-allowed;
}

.pagination-component :deep(.el-pager li) {
  background: rgba(255, 255, 255, 0.8) !important;
  border: 1px solid rgba(255, 255, 255, 0.3) !important;
  color: #333 !important;
  border-radius: 4px;
  min-width: 32px;
  height: 32px;
  margin: 0 2px;
}

.pagination-component :deep(.el-pager li:hover) {
  background: rgba(255, 255, 255, 0.95) !important;
  border-color: rgba(255, 255, 255, 0.5) !important;
  color: #333 !important;
}

.pagination-component :deep(.el-pager li.is-active) {
  background: #00f2fe !important;
  border-color: #00f2fe !important;
  color: #fff !important;
  font-weight: bold;
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.5);
}

.pagination-component :deep(.el-pagination__jump) {
  color: #fff !important;
  margin-left: 20px;
  display: flex;
  align-items: center;
}

.pagination-component :deep(.el-pagination__jump .el-input__wrapper) {
  background: #fff !important;
  border: 1px solid rgba(255, 255, 255, 0.3) !important;
  border-radius: 4px;
  margin: 0 8px;
  width: 50px;
}

.pagination-component :deep(.el-pagination__jump .el-input__inner) {
  color: #333 !important;
  text-align: center;
}

.pagination-component :deep(.el-pagination__jump .el-input__inner::placeholder) {
  color: rgba(0, 0, 0, 0.4) !important;
}

/* Rank List */
.rank-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.rank-item {
  display: flex;
  align-items: center;
  padding: 5px;
  background: rgba(255,255,255,0.02);
}
.rank-idx {
  width: 20px;
  height: 20px;
  line-height: 20px;
  text-align: center;
  background: #333;
  color: #fff;
  margin-right: 10px;
  font-size: 12px;
}
.rank-idx.top3 {
  background: #f59e0b;
}
.rank-name {
  flex: 1;
  color: #ddd;
  font-size: 12px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.rank-val {
  color: #00f2fe;
  font-size: 12px;
  margin-left: 10px;
}

/* Scrollbar */
.table-body::-webkit-scrollbar { width: 4px; }
.table-body::-webkit-scrollbar-thumb { background: #004975; border-radius: 2px; }

/* Preview Dialog */
.preview-dialog :deep(.el-dialog__wrapper) {
  z-index: 9999 !important;
}

.preview-dialog :deep(.el-overlay) {
  z-index: 9998 !important;
}

.preview-dialog :deep(.el-dialog) {
  background: rgba(8, 16, 45, 0.95);
  border: 1px solid rgba(0, 191, 255, 0.3);
  z-index: 9999 !important;
  margin-top: 60px !important;
}

.preview-dialog :deep(.el-dialog__header) {
  background: rgba(0, 191, 255, 0.1);
  border-bottom: 1px solid rgba(0, 191, 255, 0.2);
  color: #00f2fe;
}

.preview-dialog :deep(.el-dialog__title) {
  color: #00f2fe;
}

.preview-dialog :deep(.el-dialog__body) {
  padding: 0;
  background: rgba(8, 16, 45, 0.95);
}

.preview-container {
  width: 100%;
  height: 80vh;
  background: #fff;
}

.preview-iframe {
  width: 100%;
  height: 100%;
  border: none;
}

/* 上传资源弹窗样式 - 深色主题，青色发光效果 */
.upload-resource-dialog :deep(.el-dialog) {
  background: rgba(8, 16, 45, 0.95) !important;
  border: 1px solid #00f2fe !important;
  box-shadow: 0 0 25px rgba(0, 242, 254, 0.6), inset 0 0 20px rgba(0, 242, 254, 0.2) !important;
  border-radius: 4px;
}

.upload-resource-dialog :deep(.el-dialog__header) {
  background: rgba(8, 16, 45, 0.95) !important;
  border-bottom: 1px solid rgba(0, 242, 254, 0.3) !important;
  padding: 20px 20px 15px !important;
}

.upload-resource-dialog :deep(.el-dialog__title) {
  color: #00f2fe !important;
  font-size: 18px !important;
  font-weight: 600 !important;
  text-shadow: 0 0 8px rgba(0, 242, 254, 0.8) !important;
}

.upload-resource-dialog :deep(.el-dialog__headerbtn .el-dialog__close) {
  color: #00f2fe !important;
  font-size: 20px !important;
  filter: drop-shadow(0 0 5px rgba(0, 242, 254, 0.8));
}

.upload-resource-dialog :deep(.el-dialog__headerbtn .el-dialog__close:hover) {
  color: #00bfff !important;
}

.upload-resource-dialog :deep(.el-dialog__body) {
  background: rgba(8, 16, 45, 0.95) !important;
  padding: 20px !important;
  color: #fff !important;
}

.upload-resource-dialog :deep(.el-dialog__footer) {
  background: rgba(8, 16, 45, 0.95) !important;
  border-top: 1px solid rgba(0, 242, 254, 0.3) !important;
  padding: 15px 20px !important;
}

.upload-form :deep(.el-form-item__label) {
  color: #00bfff !important;
  text-shadow: 0 0 5px rgba(0, 191, 255, 0.5) !important;
}

.upload-form :deep(.el-input__wrapper) {
  background: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid rgba(0, 242, 254, 0.5) !important;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.3), inset 0 0 5px rgba(0, 242, 254, 0.1) !important;
}

.upload-form :deep(.el-input__inner) {
  background: transparent !important;
  color: #fff !important;
}

.upload-form :deep(.el-input__inner::placeholder) {
  color: rgba(255, 255, 255, 0.4) !important;
}

.upload-form :deep(.el-select .el-input__wrapper) {
  background: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid rgba(0, 242, 254, 0.5) !important;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.3), inset 0 0 5px rgba(0, 242, 254, 0.1) !important;
}

.upload-form :deep(.el-select .el-input__inner) {
  color: #fff !important;
}

.upload-form :deep(.el-select__caret) {
  color: #00bfff !important;
  filter: drop-shadow(0 0 5px rgba(0, 191, 255, 0.8));
}

.upload-form :deep(.el-button--primary.is-plain) {
  background: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid rgba(0, 242, 254, 0.6) !important;
  color: #00bfff !important;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.3) !important;
}

.upload-form :deep(.el-button--primary.is-plain:hover) {
  background: rgba(0, 242, 254, 0.2) !important;
  border-color: #00bfff !important;
  color: #00f2fe !important;
  box-shadow: 0 0 12px rgba(0, 242, 254, 0.5) !important;
}

.upload-resource-dialog :deep(.el-dialog__footer) {
  background: rgba(8, 16, 45, 0.95) !important;
  border-top: 1px solid rgba(0, 242, 254, 0.3) !important;
  padding: 15px 20px !important;
}

.dialog-footer .el-button {
  background: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid rgba(0, 242, 254, 0.5) !important;
  color: #00bfff !important;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.3) !important;
}

.dialog-footer .el-button:hover {
  background: rgba(0, 242, 254, 0.2) !important;
  box-shadow: 0 0 12px rgba(0, 242, 254, 0.5) !important;
}

.dialog-footer .el-button--primary {
  background: rgba(0, 242, 254, 0.25) !important;
  border-color: #00bfff !important;
  color: #fff !important;
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.4) !important;
}

.dialog-footer .el-button--primary:hover {
  background: rgba(0, 242, 254, 0.4) !important;
  box-shadow: 0 0 15px rgba(0, 242, 254, 0.6) !important;
}

/* 修改文件名弹窗样式 - 与上传弹窗样式一致 */
.edit-resource-dialog :deep(.el-dialog) {
  background: rgba(8, 16, 45, 0.95) !important;
  border: 1px solid #00f2fe !important;
  box-shadow: 0 0 25px rgba(0, 242, 254, 0.6), inset 0 0 20px rgba(0, 242, 254, 0.2) !important;
  border-radius: 4px;
}

.edit-resource-dialog :deep(.el-dialog__header) {
  background: rgba(8, 16, 45, 0.95) !important;
  border-bottom: 1px solid rgba(0, 242, 254, 0.3) !important;
  padding: 20px 20px 15px !important;
}

.edit-resource-dialog :deep(.el-dialog__title) {
  color: #00f2fe !important;
  font-size: 18px !important;
  font-weight: 600 !important;
  text-shadow: 0 0 8px rgba(0, 242, 254, 0.8) !important;
}

.edit-resource-dialog :deep(.el-dialog__headerbtn .el-dialog__close) {
  color: #00f2fe !important;
  font-size: 20px !important;
  filter: drop-shadow(0 0 5px rgba(0, 242, 254, 0.8));
}

.edit-resource-dialog :deep(.el-dialog__headerbtn .el-dialog__close:hover) {
  color: #00bfff !important;
}

.edit-resource-dialog :deep(.el-dialog__body) {
  background: rgba(8, 16, 45, 0.95) !important;
  padding: 20px !important;
  color: #fff !important;
}

.edit-resource-dialog :deep(.el-dialog__footer) {
  background: rgba(8, 16, 45, 0.95) !important;
  border-top: 1px solid rgba(0, 242, 254, 0.3) !important;
  padding: 15px 20px !important;
}

.edit-form :deep(.el-form-item__label) {
  color: #00bfff !important;
  text-shadow: 0 0 5px rgba(0, 191, 255, 0.5) !important;
}

.edit-form :deep(.el-input__wrapper) {
  background: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid rgba(0, 242, 254, 0.5) !important;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.3), inset 0 0 5px rgba(0, 242, 254, 0.1) !important;
}

.edit-form :deep(.el-input__inner) {
  background: transparent !important;
  color: #fff !important;
}

.edit-form :deep(.el-input__inner::placeholder) {
  color: rgba(255, 255, 255, 0.4) !important;
}
</style>

<!-- 全局样式 - 上传弹窗（因为挂载到 body，需要使用全局样式） -->
<style>
/* 上传弹窗遮罩层 - 透明，去掉黑色 */
.upload-resource-dialog.el-dialog__wrapper,
.upload-resource-modal,
.upload-resource-modal * {
  background: transparent !important;
  background-color: transparent !important;
  border: none !important;
  outline: none !important;
}

.upload-resource-dialog.el-dialog__wrapper {
  z-index: 2000 !important;
}

.upload-resource-dialog .el-overlay,
.upload-resource-modal .el-overlay,
.upload-resource-dialog .el-overlay *,
.upload-resource-modal .el-overlay * {
  background: transparent !important;
  background-color: transparent !important;
  border: none !important;
  outline: none !important;
}

.upload-resource-dialog .el-overlay,
.upload-resource-modal .el-overlay {
  z-index: 2000 !important;
}

/* 上传弹窗主体 - 确保没有任何白色边框或背景 */
.upload-resource-dialog .el-dialog,
.upload-resource-modal .el-dialog {
  background: rgba(8, 16, 45, 0.95) !important;
  background-color: rgba(8, 16, 45, 0.95) !important;
  border: 1px solid #00f2fe !important;
  box-shadow: 0 0 25px rgba(0, 242, 254, 0.6), inset 0 0 20px rgba(0, 242, 254, 0.2) !important;
  border-radius: 4px !important;
  z-index: 2001 !important;
  /* 确保没有白色边框 */
  outline: none !important;
  outline-offset: 0 !important;
  /* 移除所有可能的白色边框 */
  box-shadow: 0 0 25px rgba(0, 242, 254, 0.6), inset 0 0 20px rgba(0, 242, 254, 0.2) !important;
}

/* 覆盖所有可能的白色边框和背景 */
.upload-resource-dialog .el-dialog::before,
.upload-resource-dialog .el-dialog::after,
.upload-resource-modal .el-dialog::before,
.upload-resource-modal .el-dialog::after {
  display: none !important;
  background: transparent !important;
  border: none !important;
}

/* 确保弹窗容器没有白色边框 */
.upload-resource-dialog.el-dialog__wrapper,
.upload-resource-modal {
  border: none !important;
  outline: none !important;
  box-shadow: none !important;
}

/* 确保遮罩层没有白色边框 */
.upload-resource-dialog .el-overlay,
.upload-resource-modal .el-overlay {
  border: none !important;
  outline: none !important;
  box-shadow: none !important;
}

.upload-resource-dialog .el-dialog__header {
  background: rgba(8, 16, 45, 0.95) !important;
  background-color: rgba(8, 16, 45, 0.95) !important;
  border-bottom: 1px solid rgba(0, 242, 254, 0.3) !important;
  padding: 20px 20px 15px !important;
}

.upload-resource-dialog .el-dialog__title {
  color: #00f2fe !important;
  font-size: 18px !important;
  font-weight: 600 !important;
  text-shadow: 0 0 8px rgba(0, 242, 254, 0.8) !important;
}

.upload-resource-dialog .el-dialog__headerbtn .el-dialog__close {
  color: #00f2fe !important;
  font-size: 20px !important;
  filter: drop-shadow(0 0 5px rgba(0, 242, 254, 0.8));
}

.upload-resource-dialog .el-dialog__headerbtn .el-dialog__close:hover {
  color: #00bfff !important;
}

.upload-resource-dialog .el-dialog__body {
  background: rgba(8, 16, 45, 0.95) !important;
  background-color: rgba(8, 16, 45, 0.95) !important;
  padding: 20px !important;
  color: #fff !important;
}

.upload-resource-dialog .el-dialog__footer {
  background: rgba(8, 16, 45, 0.95) !important;
  background-color: rgba(8, 16, 45, 0.95) !important;
  border-top: 1px solid rgba(0, 242, 254, 0.3) !important;
  padding: 15px 20px !important;
}

/* 上传弹窗表单样式 */
.upload-resource-dialog .el-form-item__label {
  color: #00bfff !important;
  text-shadow: 0 0 5px rgba(0, 191, 255, 0.5) !important;
}

/* 覆盖所有输入框和选择框的白色背景 */
.upload-resource-dialog .el-input__wrapper,
.upload-resource-dialog .el-input.is-focus .el-input__wrapper,
.upload-resource-dialog .el-input__wrapper.is-focus,
.upload-resource-dialog .el-input__wrapper:hover,
.upload-resource-dialog .el-input.is-disabled .el-input__wrapper {
  background: rgba(8, 16, 45, 0.6) !important;
  background-color: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid rgba(0, 242, 254, 0.5) !important;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.3), inset 0 0 5px rgba(0, 242, 254, 0.1) !important;
}

.upload-resource-dialog .el-input__inner {
  background: transparent !important;
  background-color: transparent !important;
  color: #fff !important;
}

.upload-resource-dialog .el-input__inner::placeholder {
  color: rgba(255, 255, 255, 0.4) !important;
}

/* 覆盖 el-select 的所有可能白色背景 */
.upload-resource-dialog .el-select,
.upload-resource-dialog .el-select__wrapper,
.upload-resource-dialog .el-select .el-input__wrapper,
.upload-resource-dialog .el-select .el-input.is-focus .el-input__wrapper,
.upload-resource-dialog .el-select .el-input__wrapper.is-focus,
.upload-resource-dialog .el-select .el-input__wrapper:hover {
  background: rgba(8, 16, 45, 0.6) !important;
  background-color: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid rgba(0, 242, 254, 0.5) !important;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.3), inset 0 0 5px rgba(0, 242, 254, 0.1) !important;
}

.upload-resource-dialog .el-select .el-input__inner {
  background: transparent !important;
  background-color: transparent !important;
  color: #fff !important;
}

.upload-resource-dialog .el-select__selected-item {
  background: transparent !important;
  background-color: transparent !important;
  color: #fff !important;
}

.upload-resource-dialog .el-select__tags {
  background: transparent !important;
  background-color: transparent !important;
}

.upload-resource-dialog .el-select__caret {
  color: #00bfff !important;
  filter: drop-shadow(0 0 5px rgba(0, 191, 255, 0.8));
}

/* 覆盖所有可能的输入框背景 */
.upload-resource-dialog .el-input__wrapper,
.upload-resource-dialog .el-input.is-focus .el-input__wrapper,
.upload-resource-dialog .el-input__wrapper.is-focus,
.upload-resource-dialog .el-input__wrapper:hover {
  background: rgba(8, 16, 45, 0.6) !important;
  background-color: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid rgba(0, 242, 254, 0.5) !important;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.3), inset 0 0 5px rgba(0, 242, 254, 0.1) !important;
}

.upload-resource-dialog .el-button--primary.is-plain {
  background: rgba(8, 16, 45, 0.6) !important;
  background-color: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid rgba(0, 242, 254, 0.6) !important;
  color: #00bfff !important;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.3) !important;
}

.upload-resource-dialog .el-button--primary.is-plain:hover {
  background: rgba(0, 242, 254, 0.2) !important;
  background-color: rgba(0, 242, 254, 0.2) !important;
  border-color: #00bfff !important;
  color: #00f2fe !important;
  box-shadow: 0 0 12px rgba(0, 242, 254, 0.5) !important;
}

.upload-resource-dialog .dialog-footer .el-button {
  background: rgba(8, 16, 45, 0.6) !important;
  background-color: rgba(8, 16, 45, 0.6) !important;
  border: 1px solid rgba(0, 242, 254, 0.5) !important;
  color: #00bfff !important;
  box-shadow: 0 0 8px rgba(0, 242, 254, 0.3) !important;
}

.upload-resource-dialog .dialog-footer .el-button:hover {
  background: rgba(0, 242, 254, 0.2) !important;
  background-color: rgba(0, 242, 254, 0.2) !important;
  box-shadow: 0 0 12px rgba(0, 242, 254, 0.5) !important;
}

.upload-resource-dialog .dialog-footer .el-button--primary {
  background: rgba(0, 242, 254, 0.25) !important;
  background-color: rgba(0, 242, 254, 0.25) !important;
  border-color: #00bfff !important;
  color: #fff !important;
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.4) !important;
}

.upload-resource-dialog .dialog-footer .el-button--primary:hover {
  background: rgba(0, 242, 254, 0.4) !important;
  background-color: rgba(0, 242, 254, 0.4) !important;
  box-shadow: 0 0 15px rgba(0, 242, 254, 0.6) !important;
}

/* 上传弹窗下拉菜单 - 使用 popper-class */
.upload-resource-select-dropdown {
  background: rgba(8, 16, 45, 0.95) !important;
  background-color: rgba(8, 16, 45, 0.95) !important;
  border: 1px solid #00f2fe !important;
  box-shadow: 0 0 20px rgba(0, 242, 254, 0.5), inset 0 0 10px rgba(0, 242, 254, 0.2) !important;
}

.upload-resource-select-dropdown .el-select-dropdown__item {
  background: transparent !important;
  background-color: transparent !important;
  color: #fff !important;
}

.upload-resource-select-dropdown .el-select-dropdown__item:hover {
  background: rgba(0, 242, 254, 0.2) !important;
  background-color: rgba(0, 242, 254, 0.2) !important;
  color: #00bfff !important;
  text-shadow: 0 0 8px rgba(0, 191, 255, 0.8) !important;
}

.upload-resource-select-dropdown .el-select-dropdown__item.is-selected {
  background: rgba(0, 242, 254, 0.3) !important;
  background-color: rgba(0, 242, 254, 0.3) !important;
  color: #00bfff !important;
  text-shadow: 0 0 10px rgba(0, 191, 255, 1) !important;
}

/* 备用：覆盖所有可能的下拉菜单样式 */
.upload-resource-dialog .el-select-dropdown,
.upload-resource-dialog .el-popper,
.upload-resource-dialog .el-popper__arrow::before {
  background: rgba(8, 16, 45, 0.95) !important;
  background-color: rgba(8, 16, 45, 0.95) !important;
  border: 1px solid #00f2fe !important;
  box-shadow: 0 0 20px rgba(0, 242, 254, 0.5), inset 0 0 10px rgba(0, 242, 254, 0.2) !important;
}

.upload-resource-dialog .el-select-dropdown__item {
  background: transparent !important;
  background-color: transparent !important;
  color: #fff !important;
}

.upload-resource-dialog .el-select-dropdown__item:hover {
  background: rgba(0, 242, 254, 0.2) !important;
  background-color: rgba(0, 242, 254, 0.2) !important;
  color: #00bfff !important;
  text-shadow: 0 0 8px rgba(0, 191, 255, 0.8) !important;
}

.upload-resource-dialog .el-select-dropdown__item.is-selected {
  background: rgba(0, 242, 254, 0.3) !important;
  background-color: rgba(0, 242, 254, 0.3) !important;
  color: #00bfff !important;
  text-shadow: 0 0 10px rgba(0, 191, 255, 1) !important;
}
</style>

<!-- 全局样式 - 上传弹窗下拉菜单（因为挂载到 body） -->
<style>
/* 上传弹窗下拉菜单全局样式 */
.upload-resource-select-dropdown {
  background: rgba(8, 16, 45, 0.95) !important;
  background-color: rgba(8, 16, 45, 0.95) !important;
  border: 1px solid #00f2fe !important;
  box-shadow: 0 0 20px rgba(0, 242, 254, 0.5), inset 0 0 10px rgba(0, 242, 254, 0.2) !important;
}

.upload-resource-select-dropdown .el-select-dropdown__item {
  background: transparent !important;
  background-color: transparent !important;
  color: #fff !important;
}

.upload-resource-select-dropdown .el-select-dropdown__item:hover {
  background: rgba(0, 242, 254, 0.2) !important;
  background-color: rgba(0, 242, 254, 0.2) !important;
  color: #00bfff !important;
  text-shadow: 0 0 8px rgba(0, 191, 255, 0.8) !important;
}

.upload-resource-select-dropdown .el-select-dropdown__item.is-selected {
  background: rgba(0, 242, 254, 0.3) !important;
  background-color: rgba(0, 242, 254, 0.3) !important;
  color: #00bfff !important;
  text-shadow: 0 0 10px rgba(0, 191, 255, 1) !important;
}

/* 修改文件名弹窗全局样式 */
.edit-resource-dialog.el-dialog__wrapper,
.edit-resource-modal,
.edit-resource-modal * {
  background: transparent !important;
  background-color: transparent !important;
  border: none !important;
  outline: none !important;
}

.edit-resource-dialog.el-dialog__wrapper {
  z-index: 2000 !important;
}

.edit-resource-dialog .el-overlay,
.edit-resource-modal .el-overlay,
.edit-resource-dialog .el-overlay *,
.edit-resource-modal .el-overlay * {
  background: transparent !important;
  background-color: transparent !important;
  border: none !important;
  outline: none !important;
}

.edit-resource-dialog .el-overlay,
.edit-resource-modal .el-overlay {
  z-index: 2000 !important;
}

.edit-resource-dialog .el-dialog,
.edit-resource-modal .el-dialog {
  background: rgba(8, 16, 45, 0.95) !important;
  background-color: rgba(8, 16, 45, 0.95) !important;
  border: 1px solid #00f2fe !important;
  box-shadow: 0 0 25px rgba(0, 242, 254, 0.6), inset 0 0 20px rgba(0, 242, 254, 0.2) !important;
  border-radius: 4px !important;
  z-index: 2001 !important;
  outline: none !important;
  outline-offset: 0 !important;
}

.edit-resource-dialog .el-dialog::before,
.edit-resource-dialog .el-dialog::after,
.edit-resource-modal .el-dialog::before,
.edit-resource-modal .el-dialog::after {
  display: none !important;
  background: transparent !important;
  border: none !important;
}

.edit-resource-dialog.el-dialog__wrapper,
.edit-resource-modal {
  border: none !important;
  outline: none !important;
  box-shadow: none !important;
}

.edit-resource-dialog .el-overlay,
.edit-resource-modal .el-overlay {
  border: none !important;
  outline: none !important;
  box-shadow: none !important;
}
.edit-resource-dialog .el-dialog__title {
  color: #00f2fe !important;
  font-size: 18px !important;
  font-weight: 600 !important;
  text-shadow: 0 0 8px rgba(0, 242, 254, 0.8) !important;
}
</style>

<!-- 全局样式 - 下拉菜单（因为挂载到 body，需要使用全局样式） -->
<style>
/* 全局样式覆盖 Element Plus 下拉菜单 */
.course-filter-dropdown {
  background: rgba(8, 16, 45, 0.95) !important;
  background-color: rgba(8, 16, 45, 0.95) !important;
  border: 1px solid #00f2fe !important;
  box-shadow: 0 0 15px rgba(0, 242, 254, 0.6), inset 0 0 10px rgba(0, 242, 254, 0.2) !important;
  border-radius: 4px;
}

.course-filter-dropdown .el-select-dropdown__item {
  background: transparent !important;
  background-color: transparent !important;
  color: #fff !important;
  padding: 12px 15px;
  transition: all 0.3s ease;
  line-height: 1.5;
  display: flex;
  align-items: center;
  min-height: 40px;
}

.course-filter-dropdown .el-select-dropdown__item:hover {
  background: rgba(0, 242, 254, 0.2) !important;
  background-color: rgba(0, 242, 254, 0.2) !important;
  color: #00f2fe !important;
  text-shadow: 0 0 8px rgba(0, 242, 254, 0.8);
  box-shadow: inset 0 0 10px rgba(0, 242, 254, 0.3);
}

.course-filter-dropdown .el-select-dropdown__item.is-selected {
  background: rgba(0, 242, 254, 0.3) !important;
  background-color: rgba(0, 242, 254, 0.3) !important;
  color: #00f2fe !important;
  text-shadow: 0 0 10px rgba(0, 242, 254, 1);
  font-weight: 600;
}

/* 批量操作下拉菜单样式 */
.batch-action-dropdown :deep(.el-dropdown-menu) {
  background: rgba(8, 16, 45, 0.95) !important;
  border: 1px solid #00f2fe !important;
  box-shadow: 0 0 15px rgba(0, 242, 254, 0.6), inset 0 0 10px rgba(0, 242, 254, 0.2) !important;
  border-radius: 4px;
  padding: 4px !important;
}

.batch-action-dropdown :deep(.el-dropdown-menu__item) {
  background: rgba(0, 242, 254, 0.15) !important;
  background-color: rgba(0, 242, 254, 0.15) !important;
  color: #fff !important;
  padding: 10px 20px;
  transition: all 0.3s ease;
  margin: 2px 4px;
  border-radius: 4px;
}

.batch-action-dropdown :deep(.el-dropdown-menu__item:hover) {
  background: rgba(0, 242, 254, 0.3) !important;
  background-color: rgba(0, 242, 254, 0.3) !important;
  color: #00f2fe !important;
  text-shadow: 0 0 8px rgba(0, 242, 254, 0.8);
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.4), inset 0 0 5px rgba(0, 242, 254, 0.2);
}

.batch-action-dropdown :deep(.el-dropdown-menu__item.is-disabled) {
  background: rgba(0, 242, 254, 0.05) !important;
  background-color: rgba(0, 242, 254, 0.05) !important;
  color: rgba(255, 255, 255, 0.3) !important;
  cursor: not-allowed;
  opacity: 0.5;
}

.batch-action-dropdown :deep(.el-dropdown-menu__item--divided) {
  border-top: 1px solid rgba(0, 242, 254, 0.3);
}
</style>

<!-- 全局样式 - 批量操作下拉菜单（因为挂载到 body） -->
<style>
/* 批量操作下拉菜单全局样式 - 使用 popper-class */
.batch-action-dropdown-menu,
.batch-action-dropdown-menu .el-dropdown-menu,
.batch-action-dropdown-menu .el-popper {
  background: rgba(8, 16, 45, 0.95) !important;
  background-color: rgba(8, 16, 45, 0.95) !important;
  border: 1px solid #00f2fe !important;
  box-shadow: 0 0 15px rgba(0, 242, 254, 0.6), inset 0 0 10px rgba(0, 242, 254, 0.2) !important;
  border-radius: 4px !important;
}

.batch-action-dropdown-menu .el-dropdown-menu {
  padding: 4px !important;
  background: transparent !important;
}

.batch-action-dropdown-menu .el-dropdown-menu__item {
  background: rgba(0, 242, 254, 0.15) !important;
  background-color: rgba(0, 242, 254, 0.15) !important;
  color: #fff !important;
  padding: 10px 20px !important;
  transition: all 0.3s ease !important;
  margin: 2px 4px !important;
  border-radius: 4px !important;
}

.batch-action-dropdown-menu .el-dropdown-menu__item:hover {
  background: rgba(0, 242, 254, 0.3) !important;
  background-color: rgba(0, 242, 254, 0.3) !important;
  color: #00f2fe !important;
  text-shadow: 0 0 8px rgba(0, 242, 254, 0.8) !important;
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.4), inset 0 0 5px rgba(0, 242, 254, 0.2) !important;
}

.batch-action-dropdown-menu .el-dropdown-menu__item.is-disabled {
  background: rgba(0, 242, 254, 0.05) !important;
  background-color: rgba(0, 242, 254, 0.05) !important;
  color: rgba(255, 255, 255, 0.3) !important;
  cursor: not-allowed !important;
  opacity: 0.5 !important;
}

.batch-action-dropdown-menu .el-dropdown-menu__item--divided {
  border-top: 1px solid rgba(0, 242, 254, 0.3) !important;
}

/* 覆盖所有可能的白色背景和箭头 */
.batch-action-dropdown-menu .el-popper__arrow::before {
  background: rgba(8, 16, 45, 0.95) !important;
  background-color: rgba(8, 16, 45, 0.95) !important;
  border: 1px solid #00f2fe !important;
}

/* 备用选择器 - 确保样式生效 */
.batch-action-dropdown .el-dropdown-menu,
.batch-action-dropdown .el-popper {
  background: rgba(8, 16, 45, 0.95) !important;
  background-color: rgba(8, 16, 45, 0.95) !important;
}

.batch-action-dropdown .el-dropdown-menu__item {
  background: rgba(0, 242, 254, 0.15) !important;
  background-color: rgba(0, 242, 254, 0.15) !important;
  color: #fff !important;
  margin: 2px 4px !important;
  border-radius: 4px !important;
}

.batch-action-dropdown .el-dropdown-menu__item:hover {
  background: rgba(0, 242, 254, 0.3) !important;
  background-color: rgba(0, 242, 254, 0.3) !important;
  color: #00f2fe !important;
}
</style>