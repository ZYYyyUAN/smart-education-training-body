<template>
  <div class="knowledge-graph-page">
    <!-- 顶部导航栏 -->
    <div class="top-bar">
      <div class="left-section">
        <div class="back-button" @click="goBack">
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M20,11V13H8L13.5,18.5L12.08,19.92L4.16,12L12.08,4.08L13.5,5.5L8,11H20Z" />
          </svg>
          <span>{{ courseInfo.courseName || '课程加载中...' }}</span>
        </div>
      </div>
      <div class="right-section">
        <div class="chart-icon">📊</div>
        <div class="search-bar">
          <svg viewBox="0 0 24 24" width="16" height="16" class="search-icon">
            <path fill="currentColor" d="M9.5,3A6.5,6.5 0 0,1 16,9.5C16,11.11 15.41,12.59 14.44,13.73L14.71,14H15.5L20.5,19L19,20.5L14,15.5V14.71L13.73,14.44C12.59,15.41 11.11,16 9.5,16A6.5,6.5 0 0,1 3,9.5A6.5,6.5 0 0,1 9.5,3M9.5,5C7,5 5,7 5,9.5C5,12 7,14 9.5,14C12,14 14,12 14,9.5C14,7 12,5 9.5,5Z" />
          </svg>
          <span>Polymas: 搜一搜试试吧</span>
        </div>
        <div class="action-icons">
          <div class="icon">🔗</div>
          <div class="icon">📋</div>
        </div>
      </div>
    </div>



    <!-- 左侧导航栏 -->
    <div class="left-sidebar">
      <!-- 我的学习 -->
      <div class="learning-section">
        <div class="progress-circle">
          <div class="progress-text">100%</div>
        </div>
        <div class="learning-label">我的学习</div>
      </div>

      <!-- 导航选项 -->
      <div class="nav-options">
        <div class="nav-item active">
          <div class="nav-icon">🔗</div>
          <span>知识图谱</span>
        </div>
        <div class="nav-item">
          <div class="nav-icon">🔗</div>
          <span>关系</span>
        </div>
        <div class="nav-item">
          <div class="nav-icon">📊</div>
          <span>分类</span>
        </div>
        <div class="nav-item">
          <div class="nav-icon">🏷️</div>
          <span>主题</span>
        </div>
        <div class="nav-item">
          <div class="nav-icon">🛤️</div>
          <span>路径</span>
        </div>
      </div>

             <!-- 缩放控制 -->
       <div class="zoom-controls">
         <button class="zoom-btn" @click="zoomIn">+</button>
         <span class="zoom-level">{{ Math.round(scale * 100) }}%</span>
         <button class="zoom-btn" @click="zoomOut">-</button>
         <button class="reset-btn" @click="resetView" title="重置视图">⟲</button>

       </div>
    </div>

    <!-- 中央知识图谱 -->
    <div class="graph-container" 
         ref="graphContainer"
         @mousedown="startViewDrag"
         @mousemove="onDrag"
         @mouseup="stopDrag"
         @mouseleave="stopDrag"
         @wheel="handleWheel">
      
      <!-- 加载状态 -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner"></div>
        <div class="loading-text">正在加载课程章节信息...</div>
      </div>
      
      <!-- 调试信息 -->
      <div class="debug-info">
        缩放: {{ Math.round(scale * 100) }}%
      </div>
      
      <!-- 整体缩放容器 -->
      <div class="graph-content" 
           :style="{ 
             transform: `translate(${viewOffset.x}px, ${viewOffset.y}px) scale(${scale})`,
             transformOrigin: 'center center'
           }">
        
                <!-- 连接线 - 简化为单一绿色主连接线 -->
        <svg class="connections" width="100%" height="100%">
          <defs>
            <linearGradient id="gradient-main" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" style="stop-color:#4ecdc4;stop-opacity:1" />
              <stop offset="100%" style="stop-color:#45b7d1;stop-opacity:1" />
            </linearGradient>
          </defs>
          <line v-for="connection in connections" 
                :key="connection.id"
                :x1="getConnectionPosition(connection).x1" 
                :y1="getConnectionPosition(connection).y1" 
                :x2="getConnectionPosition(connection).x2" 
                :y2="getConnectionPosition(connection).y2"
                class="connection-line connection-main"
                stroke="url(#gradient-main)"
                stroke-width="3"
                opacity="0.8" />
        </svg>
        
               <!-- 炫彩节点 -->
         <div class="graph-node" 
              v-for="node in graphNodes" 
              :key="node.id"
              :class="['node-' + node.id, { 'selected': selectedNode?.id === node.id }]"
              :style="{ 
                left: node.x + 'px', 
                top: node.y + 'px'
              }"
              @click="selectNode(node)">
          <div class="node-glow"></div>
          <div class="node-content">
            <div class="node-number">{{ node.id }}</div>
            <div class="node-title">{{ node.title }}</div>
            <div class="node-mastery">掌握度 {{ node.mastery }}%</div>
          </div>
        </div>
      </div>
      
      <!-- 节点详情面板 -->
      <div v-if="selectedNode" class="node-detail-panel">
        <div class="detail-header">
          <div class="detail-title">
            <div class="node-icon">📚</div>
            <div class="title-content">
              <h3>{{ selectedNode.title }}</h3>
              <span class="node-id">节点 #{{ selectedNode.id }}</span>
            </div>
          </div>
          <button class="close-btn" @click="selectedNode = null">×</button>
        </div>
        
        <div class="detail-content">
          <div class="info-section">
            <div class="info-item">
              <div class="info-label">掌握度</div>
              <div class="info-value">{{ selectedNode.mastery }}%</div>
            </div>
            <div class="mastery-bar">
              <div class="mastery-fill" :style="{ width: selectedNode.mastery + '%' }"></div>
            </div>
          </div>
          
          <div class="info-section">
            <div class="info-item">
              <div class="info-label">学习状态</div>
              <div class="info-value status-completed">已完成</div>
            </div>
          </div>
          
          <div class="info-section">
            <div class="info-item">
              <div class="info-label">相关节点</div>
              <div class="related-nodes">
                <span class="related-node" v-for="connection in getRelatedNodes(selectedNode)" :key="connection.id">
                  {{ connection.title }}
                </span>
              </div>
            </div>
          </div>
          
          <div class="action-buttons">
            <button class="action-btn primary">开始学习</button>
            <button class="action-btn secondary">查看详情</button>
          </div>
        </div>
      </div>
    </div>

    <!-- 右下角小地图 -->
    <div class="mini-map">
      <div class="mini-map-content">
        <div class="mini-node" 
             v-for="node in graphNodes" 
             :key="node.id"
             :style="{ left: (node.x / 10) + '%', top: (node.y / 10) + '%' }">
        </div>
        <div class="view-port" :style="{ left: (-viewOffset.x / 10) + '%', top: (-viewOffset.y / 10) + '%' }"></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import axios from 'axios'
import { mockCourseAPI, mockChaptersAPI } from '../../api/mockData.js'

const router = useRouter()
const route = useRoute()
const graphContainer = ref(null)
const selectedNode = ref(null)

// 获取课程ID
const courseId = ref(route.query.courseId || route.query.id || '101')
const courseInfo = ref({})
const loading = ref(false)

// 视图偏移量和缩放
const viewOffset = ref({ x: 0, y: 0 })
const isDraggingView = ref(false)
const viewStartPos = ref({ x: 0, y: 0 })
const scale = ref(1)
const minScale = 0.3
const maxScale = 3

// 知识图谱节点数据 - 动态获取课程章节
const graphNodes = ref([])

// 获取课程信息和章节
const fetchCourseInfo = async () => {
  try {
    loading.value = true
    
    let courseData = null
    let chaptersData = null
    
    try {
      // 1. 尝试从真实API获取课程信息
      const courseResponse = await axios.get(`/api/courses/${courseId.value}`)
      if (courseResponse.data.code === 200) {
        courseData = courseResponse.data.data
        courseInfo.value = courseData
      }
    } catch (error) {
      console.log('真实API获取课程信息失败，使用模拟数据')
      // 使用模拟数据
      const mockCourseResponse = mockCourseAPI(courseId.value)
      if (mockCourseResponse.code === 200) {
        courseData = mockCourseResponse.data
        courseInfo.value = courseData
      }
    }
    
    try {
      // 2. 尝试从真实API获取课程章节
      const chaptersResponse = await axios.get(`/api/chapters/course/${courseId.value}`)
      if (chaptersResponse.data.code === 200) {
        chaptersData = chaptersResponse.data.data
      }
    } catch (error) {
      console.log('真实API获取章节信息失败，使用模拟数据')
      // 使用模拟数据
      const mockChaptersResponse = mockChaptersAPI(courseId.value)
      if (mockChaptersResponse.code === 200) {
        chaptersData = mockChaptersResponse.data
      }
    }
    
    // 3. 生成知识图谱节点
    if (chaptersData && chaptersData.length > 0) {
      generateChapterNodes(chaptersData)
    } else {
      // 如果没有章节数据，使用默认数据
      generateDefaultNodes()
    }
    
  } catch (error) {
    console.error('获取课程信息失败:', error)
    // 如果所有方法都失败，使用默认数据
    generateDefaultNodes()
  } finally {
    loading.value = false
  }
}

// 生成章节节点
const generateChapterNodes = (chapters) => {
  if (chapters && chapters.length > 0) {
    graphNodes.value = chapters.map((chapter, index) => {
      // 计算基础位置（稍微分散一些）
      const baseX = 200 + (index % 3) * 250 // 每行3个节点，间距250
      const baseY = 150 + Math.floor(index / 3) * 180 // 每列间距180
      
      // 添加随机偏移，让节点更自然
      const randomOffsetX = (Math.random() - 0.5) * 120 // ±60px的随机偏移
      const randomOffsetY = (Math.random() - 0.5) * 100 // ±50px的随机偏移
      
      return {
        id: chapter.id,
        title: chapter.chapter_title || chapter.chapterName || `第${index + 1}章`,
        mastery: Math.floor(Math.random() * 30) + 70, // 随机掌握度70-100
        x: baseX + randomOffsetX,
        y: baseY + randomOffsetY
      }
    })
    // 生成连接线
    generateConnections()
  } else {
    generateDefaultNodes()
  }
}

// 生成默认节点（当API调用失败时使用）
const generateDefaultNodes = () => {
  // 根据课程ID生成一些默认的章节数据
  const defaultChapters = {
    101: [ // 嵌入式开发进阶
      { id: 1, title: "嵌入式系统概述", mastery: 95, x: 180, y: 120 },
      { id: 2, title: "嵌入式处理器架构", mastery: 83, x: 420, y: 180 },
      { id: 3, title: "嵌入式软件开发", mastery: 84, x: 650, y: 140 },
      { id: 4, title: "实时操作系统", mastery: 71, x: 280, y: 320 },
      { id: 5, title: "嵌入式系统通信", mastery: 74, x: 520, y: 380 },
      { id: 6, title: "嵌入式系统调试与测试", mastery: 96, x: 720, y: 280 }
    ],
    102: [ // 计算机网络
      { id: 1, title: "计算机网络概述", mastery: 88, x: 160, y: 160 },
      { id: 2, title: "物理层", mastery: 92, x: 380, y: 140 },
      { id: 3, title: "数据链路层", mastery: 85, x: 580, y: 180 },
      { id: 4, title: "网络层", mastery: 79, x: 320, y: 340 },
      { id: 5, title: "传输层", mastery: 87, x: 540, y: 360 },
      { id: 6, title: "应用层", mastery: 91, x: 680, y: 320 }
    ]
  }
  
  // 使用对应课程的默认数据，如果没有则使用通用数据
  const chapters = defaultChapters[courseId.value] || [
    { id: 1, title: "第1章", mastery: 100, x: 200, y: 150 },
    { id: 2, title: "第2章", mastery: 100, x: 400, y: 200 },
    { id: 3, title: "第3章", mastery: 100, x: 600, y: 150 }
  ]
  
  graphNodes.value = chapters
  // 生成连接线
  generateConnections()
}

// 连接线数据
const connections = ref([])

// 生成连接线
const generateConnections = () => {
  if (graphNodes.value.length > 1) {
    connections.value = []
    
    // 只保留主要学习路径连接（按章节顺序）
    for (let i = 0; i < graphNodes.value.length - 1; i++) {
      connections.value.push({
        id: i + 1,
        from: graphNodes.value[i].id,
        to: graphNodes.value[i + 1].id,
        type: 'main' // 主要连接线
      })
    }
  }
}

// 缩放控制
const zoomIn = () => {
  if (scale.value < maxScale) {
    scale.value = Math.min(maxScale, scale.value * 1.25)
  }
}

const zoomOut = () => {
  if (scale.value > minScale) {
    scale.value = Math.max(minScale, scale.value / 1.25)
  }
}

const handleWheel = (event) => {
  event.preventDefault()
  event.stopPropagation()
  console.log('滚轮事件触发:', event.deltaY)
  // 增大缩放步长，让效果更明显
  const delta = event.deltaY > 0 ? 0.8 : 1.25
  const newScale = Math.max(minScale, Math.min(maxScale, scale.value * delta))
  scale.value = newScale
  console.log('缩放比例:', scale.value)
}

const resetView = () => {
  viewOffset.value = { x: 0, y: 0 }
  scale.value = 1
}



// 计算连接线位置
const getConnectionPosition = (connection) => {
  const fromNode = graphNodes.value.find(n => n.id === connection.from)
  const toNode = graphNodes.value.find(n => n.id === connection.to)
  
  if (!fromNode || !toNode) return { x1: 0, y1: 0, x2: 0, y2: 0 }
  
  return {
    x1: fromNode.x + 70, // 节点中心点
    y1: fromNode.y + 70,
    x2: toNode.x + 70,
    y2: toNode.y + 70
  }
}

// 连接线样式统一使用主连接线样式

// 返回上一页
const goBack = () => {
  // 返回到学习空间，保持课程ID
  router.push({
    path: '/study_space',
    query: { courseId: courseId.value }
  })
}

// 页面加载时获取课程信息
onMounted(() => {
  fetchCourseInfo()
})



// 视图拖拽功能
const startViewDrag = (event) => {
  event.preventDefault()
  isDraggingView.value = true
  viewStartPos.value = {
    x: event.clientX - viewOffset.value.x,
    y: event.clientY - viewOffset.value.y
  }
}

const onDrag = (event) => {
  if (isDraggingView.value) {
    event.preventDefault()
    const newOffsetX = event.clientX - viewStartPos.value.x
    const newOffsetY = event.clientY - viewStartPos.value.y
    
    // 限制视图偏移范围，防止拖拽过度
    const maxOffsetX = 800
    const maxOffsetY = 800
    
    viewOffset.value.x = Math.max(-maxOffsetX, Math.min(maxOffsetX, newOffsetX))
    viewOffset.value.y = Math.max(-maxOffsetY, Math.min(maxOffsetY, newOffsetY))
  }
}

const stopDrag = () => {
  isDraggingView.value = false
}

// 选择节点 - 修改跳转逻辑
const selectNode = (node) => {
  // 构建知识图谱数据结构
  const graphData = {
    name: node.title,
    id: node.id,
    children: [
      {
        name: node.title,
        id: node.id,
        children: getChapterKnowledgePoints(node.id)
      }
    ]
  }
  
  // 跳转到详情页面，传递必要参数
  router.push({
    path: '/knowledge-detail',
    query: {
      graphData: JSON.stringify(graphData),
      displayTitle: node.title,
      courseName: courseInfo.value.courseName || '课程',
      highlightIds: JSON.stringify(getHighlightIds(node.id))
    }
  })
}

// 获取章节对应的知识点
const getChapterKnowledgePoints = (chapterId) => {
  // 根据课程ID和章节ID返回对应的知识点
  const knowledgePoints = {
    101: { // 嵌入式开发进阶课程
      1: [
        { id: 10101, name: "嵌入式系统定义" },
        { id: 10102, name: "嵌入式系统特点" },
        { id: 10103, name: "嵌入式系统应用领域" }
    ],
    2: [
        { id: 10104, name: "ARM架构" },
        { id: 10105, name: "MIPS架构" },
        { id: 10106, name: "处理器选型" }
    ],
    3: [
        { id: 10107, name: "开发环境搭建" },
        { id: 10108, name: "交叉编译" },
        { id: 10109, name: "调试技术" }
    ],
    4: [
        { id: 10110, name: "RTOS概念" },
        { id: 10111, name: "任务调度" },
        { id: 10112, name: "中断处理" }
    ],
    5: [
        { id: 10113, name: "串口通信" },
        { id: 10114, name: "CAN总线" },
        { id: 10115, name: "以太网通信" }
    ],
    6: [
        { id: 10116, name: "JTAG调试" },
        { id: 10117, name: "单元测试" },
        { id: 10118, name: "集成测试" }
      ]
    },
    102: { // 计算机网络课程
      1: [
        { id: 10201, name: "网络发展历史" },
        { id: 10202, name: "网络分类" },
        { id: 10203, name: "网络拓扑结构" }
      ],
      2: [
        { id: 10204, name: "传输介质" },
        { id: 10205, name: "信号编码" },
        { id: 10206, name: "物理层设备" }
      ],
      3: [
        { id: 10207, name: "帧格式" },
        { id: 10208, name: "差错控制" },
        { id: 10209, name: "流量控制" }
      ],
      4: [
        { id: 10210, name: "IP协议" },
        { id: 10211, name: "路由算法" },
        { id: 10212, name: "网络层设备" }
      ],
      5: [
        { id: 10213, name: "TCP协议" },
        { id: 10214, name: "UDP协议" },
        { id: 10215, name: "端口号" }
      ],
      6: [
        { id: 10216, name: "HTTP协议" },
        { id: 10217, name: "FTP协议" },
        { id: 10218, name: "DNS协议" }
      ]
    }
  }
  
  // 根据课程ID和章节ID返回知识点
  const coursePoints = knowledgePoints[courseId.value]
  if (coursePoints && coursePoints[chapterId]) {
    return coursePoints[chapterId]
  }
  
  // 如果没有找到对应知识点，返回默认数据
  return [
    { id: chapterId * 100 + 1, name: "知识点1" },
    { id: chapterId * 100 + 2, name: "知识点2" },
    { id: chapterId * 100 + 3, name: "知识点3" }
  ]
}

// 获取需要高亮的节点ID
const getHighlightIds = (chapterId) => {
  const knowledgePoints = getChapterKnowledgePoints(chapterId)
  return knowledgePoints.map(point => point.id)
}

// 获取相关节点
const getRelatedNodes = (node) => {
  const related = []
  connections.value.forEach(connection => {
    if (connection.from === node.id) {
      const targetNode = graphNodes.value.find(n => n.id === connection.to)
      if (targetNode) {
        related.push(targetNode)
      }
    } else if (connection.to === node.id) {
      const sourceNode = graphNodes.value.find(n => n.id === connection.from)
      if (sourceNode) {
        related.push(sourceNode)
      }
    }
  })
  return related.slice(0, 3) // 只显示前3个相关节点
}



onMounted(() => {
  // 初始化
  // 添加全局滚轮事件监听器
  const container = graphContainer.value
  if (container) {
    container.addEventListener('wheel', handleWheel, { passive: false })
  }
})
</script>

<style scoped>
.knowledge-graph-page {
  width: 100vw;
  height: 100vh;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  color: white;
}

/* 顶部导航栏 */
.top-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 30px;
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.left-section {
  display: flex;
  align-items: center;
}

.back-button {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  padding: 8px 16px;
  border-radius: 8px;
  transition: background-color 0.3s ease;
}

.back-button:hover {
  background: rgba(255, 255, 255, 0.1);
}

.right-section {
  display: flex;
  align-items: center;
  gap: 20px;
}

.chart-icon {
  font-size: 20px;
  opacity: 0.8;
}

.search-bar {
  display: flex;
  align-items: center;
  gap: 10px;
  background: rgba(255, 255, 255, 0.1);
  padding: 10px 15px;
  border-radius: 20px;
  cursor: pointer;
  transition: background-color 0.3s ease;
  border: 1px solid rgba(147, 51, 234, 0.3);
}

.search-bar:hover {
  background: rgba(255, 255, 255, 0.15);
}

.search-icon {
  opacity: 0.7;
}

.action-icons {
  display: flex;
  gap: 15px;
}

.icon {
  cursor: pointer;
  opacity: 0.8;
  transition: opacity 0.3s ease;
  font-size: 18px;
}

.icon:hover {
  opacity: 1;
}



/* 左侧导航栏 */
.left-sidebar {
  position: absolute;
  left: 0;
  top: 80px;
  width: 250px;
  height: calc(100vh - 80px);
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(10px);
  border-right: 1px solid rgba(255, 255, 255, 0.1);
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.learning-section {
  text-align: center;
}

.progress-circle {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 10px;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.progress-text {
  font-size: 18px;
  font-weight: 700;
}

.learning-label {
  font-size: 14px;
  opacity: 0.8;
}

.nav-options {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 15px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.nav-item:hover {
  background: rgba(255, 255, 255, 0.1);
}

.nav-item.active {
  background: linear-gradient(135deg, #667eea, #764ba2);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.nav-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  font-size: 16px;
}

.zoom-controls {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 15px;
  margin-top: auto;
}

.zoom-btn {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  border: none;
  color: white;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

 .zoom-btn:hover {
   background: rgba(255, 255, 255, 0.2);
 }

 .zoom-level {
   font-size: 14px;
   opacity: 0.8;
 }

 .reset-btn {
   width: 30px;
   height: 30px;
   border-radius: 50%;
   background: rgba(255, 255, 255, 0.1);
   border: none;
   color: white;
   cursor: pointer;
   transition: background-color 0.3s ease;
   font-size: 16px;
 }

   .reset-btn:hover {
    background: rgba(255, 255, 255, 0.2);
  }



/* 中央知识图谱 */
.graph-container {
  position: absolute;
  left: 250px;
  top: 80px;
  width: calc(100vw - 250px);
  height: calc(100vh - 80px);
  overflow: hidden;
  background: radial-gradient(circle at center, rgba(0, 188, 212, 0.05) 0%, transparent 70%);
  cursor: grab;
  /* 确保滚轮事件能正常工作 */
  pointer-events: auto;
}

.debug-info {
  position: absolute;
  top: 10px;
  left: 10px;
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 10px;
  border-radius: 5px;
  font-size: 14px;
  z-index: 1000;
}

.graph-container:active {
  cursor: grabbing;
}

.graph-content {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  transition: transform 0.1s ease;
}

.connections {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 1;
  /* 确保不会阻止滚轮事件 */
  pointer-events: none;
}

/* 连接线渐变定义 */
.connections defs {
  position: absolute;
}

/* 连接线动画 */
@keyframes flow {
  0% { 
    stroke-dasharray: 5, 5;
    stroke-dashoffset: 0;
  }
  100% { 
    stroke-dasharray: 5, 5;
    stroke-dashoffset: -10;
  }
}

.connections line {
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.3));
  transition: all 0.3s ease;
}

.connections line:nth-child(1) { animation-delay: 0s; }
.connections line:nth-child(2) { animation-delay: 0.2s; }
.connections line:nth-child(3) { animation-delay: 0.4s; }
.connections line:nth-child(4) { animation-delay: 0.6s; }
.connections line:nth-child(5) { animation-delay: 0.8s; }
.connections line:nth-child(6) { animation-delay: 1s; }
.connections line:nth-child(7) { animation-delay: 1.2s; }
.connections line:nth-child(8) { animation-delay: 1.4s; }
.connections line:nth-child(9) { animation-delay: 1.6s; }
.connections line:nth-child(10) { animation-delay: 1.8s; }
.connections line:nth-child(11) { animation-delay: 2s; }

.connections line:hover {
  stroke-width: 4;
  opacity: 1;
  animation-duration: 1s;
}

/* 主要连接线样式 */
.connection-main {
  stroke-width: 3;
  opacity: 1;
  animation: flow 2s linear infinite;
}

.graph-node {
  position: absolute;
  width: 140px;
  height: 140px;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: center;
  padding: 15px;
  box-sizing: border-box;
  z-index: 10;
  overflow: hidden;
}

/* 炫彩节点背景 */
.node-1 { background: linear-gradient(135deg, #ff6b6b, #4ecdc4); }
.node-2 { background: linear-gradient(135deg, #a8edea, #fed6e3); }
.node-3 { background: linear-gradient(135deg, #ffecd2, #fcb69f); }
.node-4 { background: linear-gradient(135deg, #a8caba, #5d4e75); }
.node-5 { background: linear-gradient(135deg, #ff9a9e, #fecfef); }
.node-6 { background: linear-gradient(135deg, #f093fb, #f5576c); }
.node-7 { background: linear-gradient(135deg, #4facfe, #00f2fe); }
.node-8 { background: linear-gradient(135deg, #43e97b, #38f9d7); }
.node-9 { background: linear-gradient(135deg, #fa709a, #fee140); }
.node-10 { background: linear-gradient(135deg, #667eea, #764ba2); }
.node-11 { background: linear-gradient(135deg, #ff6b6b, #4ecdc4); }
.node-12 { background: linear-gradient(135deg, #a8edea, #fed6e3); }

/* 蠕动动画效果 */
@keyframes wiggle {
  0% { 
    transform: translateX(0px) translateY(0px) rotate(0deg);
    border-radius: 50%;
  }
  25% { 
    transform: translateX(2px) translateY(-1px) rotate(1deg);
    border-radius: 45% 55% 55% 45%;
  }
  50% { 
    transform: translateX(-1px) translateY(2px) rotate(-1deg);
    border-radius: 55% 45% 45% 55%;
  }
  75% { 
    transform: translateX(-2px) translateY(-1px) rotate(1deg);
    border-radius: 45% 55% 45% 55%;
  }
  100% { 
    transform: translateX(0px) translateY(0px) rotate(0deg);
    border-radius: 50%;
  }
}

/* 呼吸效果 */
@keyframes breathe {
  0%, 100% { 
    transform: scale(1);
    box-shadow: 0 8px 25px rgba(0, 188, 212, 0.4);
  }
  50% { 
    transform: scale(1.02);
    box-shadow: 0 12px 35px rgba(0, 188, 212, 0.6);
  }
}

/* 脉冲效果 */
@keyframes pulse {
  0%, 100% { 
    opacity: 1;
  }
  50% { 
    opacity: 0.8;
  }
}

.graph-node {
  animation: wiggle 4s ease-in-out infinite, breathe 3s ease-in-out infinite;
  transition: all 0.3s ease;
}

/* 不同节点使用不同的动画延迟，创造错落感 */
.graph-node:nth-child(1) { animation-delay: 0s, 0s; }
.graph-node:nth-child(2) { animation-delay: 0.5s, 0.3s; }
.graph-node:nth-child(3) { animation-delay: 1s, 0.6s; }
.graph-node:nth-child(4) { animation-delay: 1.5s, 0.9s; }
.graph-node:nth-child(5) { animation-delay: 2s, 1.2s; }
.graph-node:nth-child(6) { animation-delay: 2.5s, 1.5s; }
.graph-node:nth-child(7) { animation-delay: 3s, 1.8s; }
.graph-node:nth-child(8) { animation-delay: 3.5s, 2.1s; }
.graph-node:nth-child(9) { animation-delay: 4s, 2.4s; }
.graph-node:nth-child(10) { animation-delay: 4.5s, 2.7s; }
.graph-node:nth-child(11) { animation-delay: 5s, 3s; }
.graph-node:nth-child(12) { animation-delay: 5.5s, 3.3s; }

/* 节点内容也有轻微的脉冲效果 */
.node-content {
  animation: pulse 2s ease-in-out infinite;
}

/* 确保缩放transform不被动画覆盖 */
.graph-node[style*="transform"] {
  animation: none;
}

.graph-node:hover {
  transform: scale(1.15);
  animation-play-state: paused;
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.3);
}

/* 加载状态样式 */
.loading-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.9);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

.loading-text {
  font-size: 16px;
  color: #333;
  font-weight: 500;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}



.graph-node.selected {
  transform: scale(1.2);
  box-shadow: 0 20px 50px rgba(255, 255, 255, 0.3);
  border: 3px solid rgba(255, 255, 255, 0.8);
}

.node-number {
  font-size: 18px;
  font-weight: 700;
  margin-bottom: 8px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.node-title {
  font-size: 11px;
  line-height: 1.3;
  margin-bottom: 8px;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

.node-mastery {
  font-size: 10px;
  opacity: 0.9;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

/* 右下角小地图 */
.mini-map {
  position: fixed;
  bottom: 20px;
  right: 20px;
  width: 200px;
  height: 150px;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  overflow: hidden;
}

.mini-map-content {
  position: relative;
  width: 100%;
  height: 100%;
}

.mini-node {
  position: absolute;
  width: 4px;
  height: 4px;
  background: rgba(0, 188, 212, 0.6);
  border-radius: 50%;
}

 .view-port {
   position: absolute;
   top: 20%;
   left: 20%;
   width: 60%;
   height: 60%;
   border: 1px solid rgba(255, 255, 255, 0.3);
   border-radius: 4px;
   background: rgba(255, 255, 255, 0.05);
   transition: all 0.1s ease;
 }

/* 节点详情面板 */
.node-detail-panel {
  position: absolute;
  top: 20px;
  right: 20px;
  width: 350px;
  background: rgba(0, 0, 0, 0.9);
  backdrop-filter: blur(15px);
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.15);
  padding: 24px;
  z-index: 100;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5);
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
}

.detail-title {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
}

.node-icon {
  font-size: 24px;
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.title-content h3 {
  margin: 0 0 4px 0;
  color: white;
  font-size: 16px;
  font-weight: 600;
  line-height: 1.3;
}

.node-id {
  color: rgba(255, 255, 255, 0.6);
  font-size: 12px;
  font-weight: 400;
}

.close-btn {
  background: rgba(255, 255, 255, 0.1);
  border: none;
  color: white;
  font-size: 18px;
  cursor: pointer;
  padding: 0;
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: all 0.3s ease;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: scale(1.1);
}

.detail-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.info-section {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.info-label {
  color: rgba(255, 255, 255, 0.7);
  font-size: 14px;
  font-weight: 500;
}

.info-value {
  color: white;
  font-size: 14px;
  font-weight: 600;
}

.status-completed {
  color: #4caf50;
}

.mastery-bar {
  width: 100%;
  height: 6px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 3px;
  overflow: hidden;
  margin-top: 8px;
}

.mastery-fill {
  height: 100%;
  background: linear-gradient(90deg, #4caf50, #8bc34a);
  border-radius: 3px;
  transition: width 0.3s ease;
  box-shadow: 0 0 10px rgba(76, 175, 80, 0.5);
}

.related-nodes {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 8px;
}

.related-node {
  background: rgba(102, 126, 234, 0.2);
  color: #667eea;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  border: 1px solid rgba(102, 126, 234, 0.3);
  cursor: pointer;
  transition: all 0.3s ease;
}

.related-node:hover {
  background: rgba(102, 126, 234, 0.3);
  transform: scale(1.05);
}

.action-buttons {
  display: flex;
  gap: 12px;
  margin-top: 8px;
}

.action-btn {
  flex: 1;
  padding: 10px 16px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.action-btn.primary {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.action-btn.primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.action-btn.secondary {
  background: rgba(255, 255, 255, 0.1);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.action-btn.secondary:hover {
  background: rgba(255, 255, 255, 0.15);
  transform: translateY(-2px);
}
</style>
