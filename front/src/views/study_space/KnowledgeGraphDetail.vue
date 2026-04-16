<template>
    <div class="knowledge-graph-detail-page">
      <!-- 顶部导航栏 -->
      <div class="top-bar">
        <div class="left-section">
          <div class="back-button" @click="goBack">
            <svg viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M20,11V13H8L13.5,18.5L12.08,19.92L4.16,12L12.08,4.08L13.5,5.5L8,11H20Z" />
            </svg>
            <span>《中国近现代史纲要》</span>
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
        
        <!-- 整体缩放容器 -->
        <div class="graph-content" 
             :style="{ 
               transform: `translate(${viewOffset.x}px, ${viewOffset.y}px) scale(${scale})`,
               transformOrigin: 'center center'
             }">
          
          <!-- 连接线 -->
          <svg class="connections" width="100%" height="100%">
            <defs>
              <linearGradient id="gradient-line" x1="0%" y1="0%" x2="100%" y2="0%">
                <stop offset="0%" style="stop-color:#ff6b6b;stop-opacity:0.8" />
                <stop offset="50%" style="stop-color:#4ecdc4;stop-opacity:1" />
                <stop offset="100%" style="stop-color:#667eea;stop-opacity:0.8" />
              </linearGradient>
            </defs>
            <line v-for="connection in connections" 
                  :key="connection.id"
                  :x1="getConnectionPosition(connection).x1" 
                  :y1="getConnectionPosition(connection).y1" 
                  :x2="getConnectionPosition(connection).x2" 
                  :y2="getConnectionPosition(connection).y2"
                  stroke="url(#gradient-line)" 
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
  
  const router = useRouter()
  const route = useRoute()
  const graphContainer = ref(null)
  const selectedNode = ref(null)
  
  // 视图偏移量和缩放
  const viewOffset = ref({ x: 0, y: 0 })
  const isDraggingView = ref(false)
  const viewStartPos = ref({ x: 0, y: 0 })
  const scale = ref(1)
  const minScale = 0.3
  const maxScale = 3
  
  // 知识图谱节点数据
  const graphNodes = ref([
    { id: 1, title: "历史是最好的教科书", mastery: 100, x: 200, y: 150 },
    { id: 2, title: "近代中华民族的磨难与抗争", mastery: 100, x: 400, y: 200 },
    { id: 3, title: "不同社会力量对国家出路的早期探索", mastery: 100, x: 600, y: 150 },
    { id: 4, title: "辛亥革命与君主专制制度的终结", mastery: 100, x: 300, y: 300 },
    { id: 5, title: "中国共产党成立和中国革命新局面", mastery: 100, x: 500, y: 350 },
    { id: 6, title: "中国革命的新道路", mastery: 98, x: 700, y: 300 },
    { id: 7, title: "中华民族的抗日战争", mastery: 100, x: 150, y: 450 },
    { id: 8, title: "为建立新中国而奋斗", mastery: 100, x: 350, y: 500 },
    { id: 9, title: "中华人民共和国的成立与中国社会主义建设道路的探索", mastery: 100, x: 550, y: 450 },
    { id: 10, title: "改革开放与中国特色社会主义的开创与发展", mastery: 100, x: 750, y: 400 },
    { id: 11, title: "中国特色社会主义进入新时代", mastery: 100, x: 250, y: 600 },
    { id: 12, title: "结语", mastery: 100, x: 450, y: 650 }
  ])
  
  // 连接线数据
  const connections = ref([
    { id: 1, from: 1, to: 2 },
    { id: 2, from: 2, to: 3 },
    { id: 3, from: 3, to: 4 },
    { id: 4, from: 4, to: 5 },
    { id: 5, from: 5, to: 6 },
    { id: 6, from: 6, to: 7 },
    { id: 7, from: 7, to: 8 },
    { id: 8, from: 8, to: 9 },
    { id: 9, from: 9, to: 10 },
    { id: 10, from: 10, to: 11 },
    { id: 11, from: 11, to: 12 }
  ])
  
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
    const delta = event.deltaY > 0 ? 0.8 : 1.25
    const newScale = Math.max(minScale, Math.min(maxScale, scale.value * delta))
    scale.value = newScale
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
      x1: fromNode.x + 70,
      y1: fromNode.y + 70,
      x2: toNode.x + 70,
      y2: toNode.y + 70
    }
  }
  
  // 返回上一页
  const goBack = () => {
    router.go(-1)
  }
  
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
      
      const maxOffsetX = 800
      const maxOffsetY = 800
      
      viewOffset.value.x = Math.max(-maxOffsetX, Math.min(maxOffsetX, newOffsetX))
      viewOffset.value.y = Math.max(-maxOffsetY, Math.min(maxOffsetY, newOffsetY))
    }
  }
  
  const stopDrag = () => {
    isDraggingView.value = false
  }
  
  // 选择节点
const selectNode = (node) => {
  selectedNode.value = node
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
  const container = graphContainer.value
  if (container) {
    container.addEventListener('wheel', handleWheel, { passive: false })
  }
  
  // 根据路由参数设置选中的节点
  const nodeId = parseInt(route.params.id)
  const targetNode = graphNodes.value.find(node => node.id === nodeId)
  if (targetNode) {
    selectedNode.value = targetNode
    // 自动调整视图到选中的节点
    viewOffset.value = {
      x: -targetNode.x + window.innerWidth / 2 - 70,
      y: -targetNode.y + window.innerHeight / 2 - 70
    }
  }
})
  </script>
  
  <style scoped>
  .knowledge-graph-detail-page {
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
    pointer-events: auto;
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
    stroke-dasharray: 5, 5;
    animation: flow 2s linear infinite;
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
