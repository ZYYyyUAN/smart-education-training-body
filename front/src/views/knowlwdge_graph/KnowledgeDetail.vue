<template>
  <div class="knowledge-detail-container" :class="sidebarVisible ? 'sidebar-active' : 'sidebar-closed'">
    <div class="top-actions">
      <el-button circle size="small" class="action-btn back-btn" @click="$router.back()">
        <el-icon><ArrowLeft /></el-icon>
      </el-button>
    </div>

    <div class="main-layout">
      <div class="knowledge-graph">
        <div ref="graphContainer" class="graph-echarts" />

        <!-- 左侧底部居中按钮，永远显示 -->
        <div class="left-bottom-button">
          <el-button class="flat-btn" icon="el-icon-arrow-left" @click="$router.back()">
            {{ courseName }}
          </el-button>
        </div>

        <!-- 右侧缩放控制按钮 -->
        <div class="zoom-controls" v-if="sidebarVisible">
          <el-button class="zoom-btn" @click="zoomIn" title="放大">
            <el-icon><Plus /></el-icon>
          </el-button>
          <span class="zoom-level">{{ Math.round(currentZoom * 100) }}%</span>
          <el-button class="zoom-btn" @click="zoomOut" title="缩小">
            <el-icon><Minus /></el-icon>
          </el-button>
          <el-button class="reset-btn" @click="resetZoom" title="重置视图">
            <el-icon><Refresh /></el-icon>
          </el-button>
          <el-button class="fit-btn" @click="fitToView" title="适应视图">
            <el-icon><FullScreen /></el-icon>
          </el-button>
        </div>

        <!-- 右上方展开按钮，当侧边栏关闭时显示 -->
        <div class="right-top-button" v-if="!sidebarVisible">
          <el-button class="expand-btn" @click="sidebarVisible = true">
            <el-icon><ArrowLeft /></el-icon>
            展开
          </el-button>
        </div>
      </div>

      <!-- 自定义侧边栏 -->
      <div v-if="sidebarVisible" class="custom-sidebar">
        <div class="sidebar-header">
          <div class="header-controls" @click="handleSidebarClose">
            <span class="collapse-text">收起</span>
            <el-icon><ArrowRight /></el-icon>
          </div>
        </div>

        <div class="sidebar-content">
          <!-- 知识标签 -->
          <div class="knowledge-tags">
            <span class="tag conceptual">概念性知识</span>
            <span class="tag key-point">重点</span>
          </div>

          <!-- 主标题 -->
          <div class="main-title-section">
            <h1 class="main-title">{{ getDisplayTitle() }}</h1>
            <el-button class="action-icon" circle size="small">
              <el-icon><ArrowRight /></el-icon>
            </el-button>
          </div>

          <!-- 知识点描述 -->
          <div class="detail-section">
            <div class="section-header">
              <div class="header-left">
                <h3>知识点描述</h3>
              </div>
            </div>
            <div class="section-content">
              <p class="desc-text">
                {{ getKnowledgeDescription() }}
              </p>
            </div>
          </div>

          <!-- 掌握度 -->
          <div class="detail-section">
            <div class="section-header">
              <div class="header-left">
                <span class="mastery-label">当前掌握度 {{ currentMastery }}%</span>
              </div>
              <el-button type="text" size="small" class="improve-btn">
                提升掌握度 >
              </el-button>
            </div>
            <div class="section-content center-content">
              <div class="mastery-card">
                <div class="mastery-circle">
                  <span class="mastery-percent">{{ currentMastery }}%</span>
                  <p class="mastery-text">最新掌握度</p>
                </div>
                <p class="mastery-history">历史最高掌握度: {{ highestMastery }}%</p>
              </div>
            </div>
          </div>

          <!-- 知识点资源 -->
          <div class="detail-section">
            <div class="section-header">
              <div class="header-left">
                <h3>知识点资源 · {{ getResourceCount() }}</h3>
              </div>
              <el-button type="text" size="small" class="view-more-btn">
                查看更多 >
              </el-button>
            </div>
            <div class="section-content resource-list">
              <div v-if="getCurrentChildren() && getCurrentChildren().length > 0">
                <div 
                  v-for="child in getCurrentChildren()" 
                  :key="child.id"
                  class="resource-item"
                  :class="{ 'highlight': highlightedIds.includes(child.id) }"
                >
                  <div class="resource-content">
                    <div class="resource-left">
                      <span class="required-tag">必学</span>
                      <div class="resource-info">
                        <h4 class="resource-title">{{ child.name }}</h4>
                        <p class="resource-subtitle">{{ getResourceSubtitle(child) }}</p>
                      </div>
                    </div>
                    <div class="resource-right">
                      <span class="grid-icon">📊</span>
                    </div>
                  </div>
                </div>
              </div>
              <div v-else class="no-resources">
                <p>暂无相关资源</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>


  </div>
</template>

<script setup>
import { useRoute, onBeforeRouteUpdate } from 'vue-router'
import { ref, watch, onMounted, onBeforeUnmount } from 'vue'
import * as echarts from 'echarts'
import { ArrowLeft, ArrowRight } from '@element-plus/icons-vue'
import { Plus, Minus, Refresh, FullScreen } from '@element-plus/icons-vue'

const sidebarVisible = ref(true)

// 监听侧边栏状态变化
watch(sidebarVisible, (newVal) => {
  if (newVal) {
    // 侧边栏打开时，确保图表可以交互
    setTimeout(() => {
      if (chart.value) {
        chart.value.resize()
      }
      // 强制重新渲染图表
      renderChart()
    }, 100)
  } else {
    // 侧边栏关闭时，重新渲染图表
    setTimeout(() => {
      renderChart()
    }, 100)
  }
})
const graphContainer = ref(null)
const chart = ref(null)

const route = useRoute()
const selectedNode = ref(null)
const highlightedIds = ref([])
const courseId = ref(null)
const courseName = ref('计算机网络原理') // 默认课程名称
const displayTitle = ref('') // 显示标题

// 掌握度数据
const currentMastery = ref(0)
const highestMastery = ref(0)

// 缩放相关
const currentZoom = ref(1)

// 处理侧边栏关闭
const handleSidebarClose = () => {
  sidebarVisible.value = false
  // 强制重新渲染图表，清除残留
  setTimeout(() => {
    if (chart.value) {
      chart.value.resize()
    }
  }, 100)
}

// 获取知识点描述
const getKnowledgeDescription = () => {
  // 获取当前点击的节点名称
  let nodeName = selectedNode.value?.name
  if (!nodeName) return '暂无描述'
  
  // 如果有传递的graphData，使用其子节点的名称（即实际点击的节点）
  if (route.query.graphData) {
    try {
      const graphData = JSON.parse(route.query.graphData)
      if (graphData.children && graphData.children.length > 0) {
        nodeName = graphData.children[0].name
      }
    } catch (e) {
      console.error('解析graphData失败:', e)
    }
  }
  
  // 根据节点名称返回对应的描述 - 修改为《中国近现代史纲要》的描述
  const descriptions = {
    '历史是最好的教科书': '历史是最好的教科书，它记录了人类社会发展的重要历程，蕴含着丰富的智慧和经验。通过学习历史，我们可以了解过去，把握现在，展望未来。历史告诉我们，只有坚持正确的方向，才能实现民族复兴的伟大梦想。',
    '近代中华民族的磨难与抗争': '近代以来，中华民族遭受了前所未有的磨难，经历了鸦片战争、甲午战争等一系列不平等条约的签订。面对内忧外患，中国人民进行了不屈不挠的抗争，从太平天国运动到义和团运动，体现了中华民族不屈不挠的民族精神。',
    '不同社会力量对国家出路的早期探索': '在近代中国，不同的社会力量都曾探索过救国救民的道路。农民阶级发动了太平天国运动，地主阶级开展了洋务运动，资产阶级进行了维新变法，但都未能成功。这些探索虽然失败了，但为后来的革命积累了宝贵的经验。',
    '辛亥革命与君主专制制度的终结': '辛亥革命是中国历史上一次伟大的资产阶级民主革命，它推翻了统治中国几千年的君主专制制度，建立了中华民国。虽然革命果实被袁世凯窃取，但它为中国的民主革命开辟了道路。',
    '中国共产党成立和中国革命新局面': '1921年中国共产党成立，这是中国历史上开天辟地的大事。党成立后，领导了五四运动，推动了第一次国共合作，开展了北伐战争，为中国革命开辟了新的局面。',
    '中国革命的新道路': '在大革命失败后，中国共产党探索出了农村包围城市、武装夺取政权的革命道路。通过土地革命、长征等重大事件，党在革命实践中不断成长壮大。',
    '中华民族的抗日战争': '抗日战争是中华民族反抗日本帝国主义侵略的伟大民族解放战争。从九一八事变到七七事变，再到全民族抗战，中国人民经过14年的浴血奋战，最终取得了抗日战争的伟大胜利。',
    '为建立新中国而奋斗': '抗日战争胜利后，中国共产党为建立新中国进行了艰苦卓绝的斗争。通过重庆谈判、解放战争、三大战役、渡江战役等重大事件，最终推翻了国民党反动统治，建立了中华人民共和国。',
    '中华人民共和国的成立与中国社会主义建设道路的探索': '1949年中华人民共和国成立，中国人民站起来了。建国后，党领导人民进行了社会主义改造，探索社会主义建设道路，虽然经历了文化大革命等曲折，但为改革开放奠定了基础。',
    '改革开放与中国特色社会主义的开创与发展': '1978年党的十一届三中全会开启了改革开放的新时期。党领导人民开创了中国特色社会主义道路，建立了社会主义市场经济体制，全面建设小康社会，实现了从站起来到富起来的伟大飞跃。',
    '中国特色社会主义进入新时代': '党的十八大以来，中国特色社会主义进入新时代。党领导人民实现了从富起来到强起来的伟大飞跃，提出了中国梦、四个全面、五位一体等重要思想，为实现中华民族伟大复兴指明了方向。',
    '结语': '历史是最好的教科书，也是最好的营养剂。通过学习中国近现代史，我们可以深刻理解中国共产党为什么能、马克思主义为什么行、中国特色社会主义为什么好，从而更加坚定地走中国特色社会主义道路。'
  }
  
  return descriptions[nodeName] || `${nodeName}是《中国近现代史纲要》中的重要章节，涉及重要的历史事件和理论观点。`
}

// 获取描述数量
const getDescriptionCount = () => {
  return 1
}

// 获取资源数量
const getResourceCount = () => {
  return getCurrentChildren().length
}

// 获取显示标题
const getDisplayTitle = () => {
  // 优先使用传递的displayTitle
  if (displayTitle.value) {
    return displayTitle.value
  }
  // 如果有传递的graphData，使用其根节点名称作为标题
  if (route.query.graphData) {
    try {
      const graphData = JSON.parse(route.query.graphData)
      return graphData.name || selectedNode.value?.name || '知识点详情'
    } catch (e) {
      console.error('解析graphData失败:', e)
    }
  }
  return selectedNode.value?.name || '知识点详情'
}

// 获取当前显示的子节点
const getCurrentChildren = () => {
  // 如果有传递的graphData，使用其子节点
  if (route.query.graphData) {
    try {
      const graphData = JSON.parse(route.query.graphData)
      if (graphData.children && graphData.children.length > 0) {
        return graphData.children[0].children || []
      }
    } catch (e) {
      console.error('解析graphData失败:', e)
    }
  }
  return selectedNode.value?.children || []
}

// 获取资源副标题 - 修改为《中国近现代史纲要》的副标题
const getResourceSubtitle = (child) => {
  const nodeName = selectedNode.value?.name
  if (nodeName === '历史是最好的教科书') {
    return '历史意义与现实价值'
  } else if (nodeName === '近代中华民族的磨难与抗争') {
    return '民族危机与救亡图存'
  } else if (nodeName === '不同社会力量对国家出路的早期探索') {
    return '各阶级探索与历史教训'
  } else if (nodeName === '辛亥革命与君主专制制度的终结') {
    return '民主革命与制度变革'
  } else if (nodeName === '中国共产党成立和中国革命新局面') {
    return '党的诞生与革命新局'
  } else if (nodeName === '中国革命的新道路') {
    return '道路探索与革命实践'
  } else if (nodeName === '中华民族的抗日战争') {
    return '民族抗战与胜利历程'
  } else if (nodeName === '为建立新中国而奋斗') {
    return '解放战争与建国历程'
  } else if (nodeName === '中华人民共和国的成立与中国社会主义建设道路的探索') {
    return '建国初期与建设探索'
  } else if (nodeName === '改革开放与中国特色社会主义的开创与发展') {
    return '改革开放与道路开创'
  } else if (nodeName === '中国特色社会主义进入新时代') {
    return '新时代与新思想'
  } else if (nodeName === '结语') {
    return '历史启示与未来展望'
  }
  return '相关学习资源'
}

// 树转图数据函数（与 KnowledgeGraph.vue 保持一致）
function convertTreeToGraphData(rootNode) {
  console.log('convertTreeToGraphData 被调用，输入树:', rootNode);
  const nodes = []
  const links = []

  const traverse = (node, parentPath = '') => {
    const currentPath = parentPath ? `${parentPath}-${node.id}` : String(node.id)
    console.log('处理节点:', node.name, '当前路径:', currentPath, '父路径:', parentPath);
    
    nodes.push({
      id: currentPath,
      name: node.name,
      symbolSize: parentPath ? 60 : 100,
      category: parentPath ? 1 : 0,
      draggable: true,
      itemStyle: {
        color: parentPath ? '#73C9E6' : '#5470C6',
        shadowColor: 'rgba(0, 0, 0, 0.4)',
        shadowBlur: 10
      },
      label: {
        show: true,
        color: '#333',
        fontWeight: parentPath ? 'normal' : 'bold',
        fontSize: parentPath ? 14 : 18
      },
      symbol: 'circle'
    })

    if (parentPath) {
      links.push({
        source: parentPath,
        target: currentPath,
        lineStyle: {
          color: '#aab',
          width: 2,
          curveness: 0.4
        },
        emphasis: {
          lineStyle: {
            color: '#5470C6',
            width: 3
          }
        },
        symbol: ['none', 'arrow'],
        symbolSize: 8
      })
    }

    if (node.children && Array.isArray(node.children)) {
      console.log('节点有子节点，数量:', node.children.length);
      node.children.forEach(child => {
        if (child) traverse(child, currentPath)
      })
    } else {
      console.log('节点没有子节点');
    }
  }

  traverse(rootNode)
  console.log('转换完成，节点数:', nodes.length, '连接数:', links.length);
  return { nodes, links }
}

// 封装渲染图表方法 - 增强高亮效果和缩放功能
function renderChart() {
  console.log('renderChart 被调用');
  console.log('selectedNode.value:', selectedNode.value);
  console.log('graphContainer.value:', graphContainer.value);
  
  if (!selectedNode.value || !graphContainer.value) {
    console.log('缺少必要数据，退出渲染');
    return;
  }

  const { nodes, links } = convertTreeToGraphData(selectedNode.value)
  console.log('转换后的节点数据:', nodes);
  console.log('转换后的连接数据:', links);

  // 增强高亮效果
  nodes.forEach(node => {
    // 检查节点ID是否在高亮列表中
    const nodeId = typeof node.id === 'string' ? parseInt(node.id.split('-').pop()) : node.id
    console.log('检查节点高亮:', node.name, '节点ID:', nodeId, '高亮列表:', highlightedIds.value);
    
    if (highlightedIds.value.includes(nodeId)) {
      console.log('节点被高亮:', node.name);
      node.itemStyle = {
        ...node.itemStyle,
        color: '#ff6600',
        borderColor: '#ff6600',
        borderWidth: 4,
        shadowColor: 'rgba(255, 102, 0, 0.8)',
        shadowBlur: 20,
        shadowOffsetX: 0,
        shadowOffsetY: 0
      }
      // 高亮节点的标签也加粗
      node.label = {
        ...node.label,
        fontWeight: 'bold',
        fontSize: 18,
        color: '#ff6600',
        textShadow: '0 2px 4px rgba(255, 102, 0, 0.5)'
      }
      // 增大高亮节点的尺寸
      node.symbolSize = Math.max(node.symbolSize || 60, 80)
    } else {
      // 非高亮节点变暗
      node.itemStyle = {
        ...node.itemStyle,
        color: '#e0e0e0',
        borderColor: '#ccc',
        opacity: 0.4
      }
      node.label = {
        ...node.label,
        color: '#999',
        opacity: 0.6
      }
    }
  })

  // 彻底清除之前的图表内容，避免残留
  if (chart.value) {
    chart.value.clear();
    chart.value.dispose();
  }
  
  // 重新初始化图表
  chart.value = echarts.init(graphContainer.value);

  chart.value.setOption({
    backgroundColor: '#ffffff',
    tooltip: {
      trigger: 'item',
      formatter: function(params) {
        if (params.dataType === 'node') {
          const isHighlighted = highlightedIds.value.includes(parseInt(params.data.id.split('-').pop()))
          const highlightText = isHighlighted ? '<br/><span style="color: #ff6600; font-weight: bold;">★ 重点知识点</span>' : ''
          return `${params.name}${highlightText}`
        }
        return params.name
      },
      backgroundColor: 'rgba(50,50,50,0.9)',
      textStyle: { color: '#fff' },
      borderColor: '#ff6600',
      borderWidth: 1
    },
    legend: [{
      data: ['章节', '知识点'],
      textStyle: {
        color: '#555',
        fontWeight: 'bold'
      },
      bottom: 10
    }],
    // 添加数据缩放组件
    dataZoom: [
      {
        type: 'inside',
        start: 0,
        end: 100,
        zoomOnMouseWheel: true,
        moveOnMouseMove: true,
        preventDefaultMouseMove: false
      }
    ],
    series: [
      {
        type: 'graph',
        layout: 'force',
        roam: true,
        focusNodeAdjacency: true,
        label: {
          show: true,
          position: 'right',
          formatter: '{b}',
          fontWeight: 'bold',
          fontSize: 14,
          color: '#333'
        },
        force: {
          repulsion: 500,
          edgeLength: [120, 160],
          gravity: 0.1
        },
        data: nodes,
        links: links,
        categories: [
          { name: '章节' },
          { name: '知识点' }
        ],
        lineStyle: {
          color: '#aaa',
          width: 2,
          curveness: 0.3
        },
        emphasis: {
          focus: 'adjacency',
          lineStyle: {
            width: 4,
            color: '#ff6600'
          }
        },
        // 添加缩放功能
        zoom: 1,
        center: ['50%', '50%'],
        // 添加缩放限制
        scaleLimit: {
          min: 0.3,
          max: 3
        }
      },
    ],
  })

  // 添加缩放事件监听
  chart.value.on('datazoom', function(params) {
    console.log('图表缩放事件:', params)
    if (params.endValue !== undefined) {
      currentZoom.value = params.endValue / 100
    }
  })

  // 添加点击事件监听
  chart.value.on('click', function(params) {
    if (params.dataType === 'node') {
      console.log('点击节点:', params.data)
      // 可以在这里添加节点点击的交互逻辑
    }
  })

  // 监听图表缩放变化
  chart.value.on('graphroam', function(params) {
    console.log('图表漫游事件:', params)
    // 更新缩放状态
    if (params.zoom) {
      currentZoom.value = params.zoom
    }
  })
}

// 解析路由参数，更新数据并渲染图表
function updateDataFromRoute() {
  console.log('updateDataFromRoute 被调用');
  console.log('当前路由查询参数:', route.query);
  
  // 优先使用传递的 graphData，如果没有则使用 node
  if (route.query.graphData) {
    try {
      console.log('原始 graphData 参数:', route.query.graphData);
      selectedNode.value = JSON.parse(route.query.graphData)
      console.log('解析后的知识图谱数据:', selectedNode.value)
      console.log('节点名称:', selectedNode.value?.name)
      console.log('子节点数量:', selectedNode.value?.children?.length || 0)
    } catch (e) {
      console.error('graphData 参数解析失败', e)
      selectedNode.value = null
    }
  } else if (route.query.node) {
    try {
      console.log('原始 node 参数:', route.query.node);
      selectedNode.value = JSON.parse(route.query.node)
      console.log('解析后的节点数据:', selectedNode.value)
      console.log('节点名称:', selectedNode.value?.name)
      console.log('子节点数量:', selectedNode.value?.children?.length || 0)
    } catch (e) {
      console.error('node 参数解析失败', e)
      selectedNode.value = null
    }
  } else {
    console.error('未传入 node 或 graphData 参数')
    return
  }

  try {
    console.log('原始 highlightIds 参数:', route.query.highlightIds);
    highlightedIds.value = JSON.parse(route.query.highlightIds || '[]')
    console.log('解析后的高亮节点IDs:', highlightedIds.value)
  } catch (e) {
    console.error('highlightIds 参数解析失败', e)
    highlightedIds.value = []
  }

  try {
    courseId.value = route.query.courseId
    console.log('课程ID:', courseId.value)
  } catch (e) {
    console.error('courseId 参数解析失败', e)
    courseId.value = null
  }

  // 根据课程ID设置课程名称
  if (route.query.courseName) {
    courseName.value = route.query.courseName
  } else if (courseId.value) {
    // 这里可以根据课程ID动态获取课程名称，暂时使用默认值
    courseName.value = '计算机网络原理'
  }

  // 设置显示标题
  if (route.query.displayTitle) {
    displayTitle.value = route.query.displayTitle
  }

  // 初始化掌握度数据
  currentMastery.value = Math.floor(Math.random() * 100)
  highestMastery.value = Math.max(currentMastery.value, Math.floor(Math.random() * 100))

  console.log('开始渲染图表...');
  renderChart()
}

// 初始化时读取参数并渲染
onMounted(() => {
  updateDataFromRoute()
})

// 监听路由变化，重新加载图表
onBeforeRouteUpdate((to, from, next) => {
  updateDataFromRoute()
  next()
})

// 组件卸载时销毁图表
onBeforeUnmount(() => {
  if (chart.value) {
    chart.value.dispose()
    chart.value = null
  }
})

// 缩放控制函数
const zoomIn = () => {
  if (chart.value) {
    const option = chart.value.getOption()
    const currentZoom = option.series[0].zoom || 1
    const newZoom = Math.min(3, currentZoom * 1.2)
    
    chart.value.setOption({
      series: [{
        zoom: newZoom
      }]
    })
    currentZoom.value = newZoom
  }
}

const zoomOut = () => {
  if (chart.value) {
    const option = chart.value.getOption()
    const currentZoom = option.series[0].zoom || 1
    const newZoom = Math.max(0.3, currentZoom / 1.2)
    
    chart.value.setOption({
      series: [{
        zoom: newZoom
      }]
    })
    currentZoom.value = newZoom
  }
}

const resetZoom = () => {
  if (chart.value) {
    chart.value.setOption({
      series: [{
        zoom: 1
      }]
    })
    currentZoom.value = 1
  }
}

const fitToView = () => {
  if (chart.value) {
    // 重置缩放并适应视图
    chart.value.setOption({
      series: [{
        zoom: 1
      }]
    })
    currentZoom.value = 1
    
    // 触发重新布局
    setTimeout(() => {
      chart.value.resize()
    }, 100)
  }
}

</script>


<style scoped>
.knowledge-detail-container {
  display: flex;
  flex-direction: column;
  height:100vh;
  background-color: #ffffff;
  overflow: hidden;
  position: relative;
  z-index: 1;
  width: 100%;
}

.sidebar-closed .main-layout {
  margin-right: 0 !important;
  padding-right: 0 !important;
  width: 100% !important;
}

.graph-echarts {
  width: 100%;
  height: 100%;
  pointer-events: auto;
  z-index: 50;
  will-change: transform;
  transform: translateZ(1px);
}

.main-layout {
  display: flex;
  flex: 1;
  position: relative;
  overflow: hidden;
}

.sidebar-active .knowledge-graph {
  width: 65%;
  position: relative;
  z-index: 50;
  margin-right: 0;
  padding-right: 0;
}

.sidebar-closed .knowledge-graph {
  width: 100% !important;
  position: relative;
  z-index: 50;
  margin-right: 0 !important;
  padding-right: 0 !important;
  right: 0 !important;
  left: 0 !important;
}

.knowledge-graph {
  position: relative; /* 定位上下文 */
  transition: width 0.3s ease;
  background: transparent;
  display: flex;
  flex-direction: column;
  pointer-events: auto;
  z-index: 50;
  user-select: none;
  isolation: isolate;
  position: relative;
  pointer-events: all;
  transform: translateZ(1px);
  will-change: transform;
  width: 100%;
}

.top-actions {
  background: #ffffff;
  padding: 16px;
}

.action-btn {
  width: 36px;
  height: 36px;
  border-radius: 8px;
}

.custom-sidebar {
  position: fixed;
  right: 0;
  top: 0;
  height: 100vh;
  width: 40%;
  background: linear-gradient(135deg, #ffffff, #f8f9fa);
  border-radius: 16px 0 0 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  z-index: 1000;
  pointer-events: auto;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.detail-sidebar {
  margin: 24px 24px 0 0;
  border-left: 1px solid #e4e7ed;
  background: linear-gradient(135deg, #ffffff, #f8f9fa);
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  z-index: -1;
  position: fixed;
  right: 0;
  top: 0;
  height: 100vh;
  width: 40%;
  pointer-events: none;
  transform: translateZ(-1px);
}

.sidebar-closed .detail-sidebar {
  transform: translateX(100%) translateZ(-1px);
  opacity: 0;
  pointer-events: none;
  z-index: -1;
  visibility: hidden;
  width: 0;
  margin: 0;
  display: none;
  position: fixed;
  right: -100%;
}

.sidebar-header {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  padding: 20px 20px 10px 10px;
  border-bottom: 1px solid #e9ecef;
  background: #ffffff;
  transition: all 0.3s ease;
  pointer-events: auto;
  border-radius: 16px 0 0 0;
}

.drawer-header {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  padding: 10px 10px 5px 10px;
  border-bottom: 1px solid #e9ecef;
  background: #ffffff;
  transition: all 0.3s ease;
  pointer-events: auto;
  border-radius: 16px 0 0 0;
}

.header-controls {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #409eff;
  font-weight: 500;
  padding: 0;
  background: transparent;
  border: none;
  transition: all 0.3s ease;
  cursor: pointer;
}

.header-controls:hover {
  color: #66b1ff;
  transform: translateY(-1px);
}

.expand-text, .collapse-text {
  font-weight: 600;
  color: #2c3e50;
}

.sidebar-content {
  padding: 10px 10px 10px 10px;
  background: transparent;
  max-height: calc(100vh - 110px);
  overflow-y: auto;
  z-index: 1000;
  pointer-events: auto;
  flex: 1;
}

.sidebar-content::-webkit-scrollbar {
  width: 6px;
}

.sidebar-content::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.sidebar-content::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.sidebar-content::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}

/* 知识标签 */
.knowledge-tags {
  display: flex;
  gap: 8px;
  margin-bottom: 20px;
}

.tag {
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.tag.conceptual {
  background: linear-gradient(135deg, #e3f2fd, #bbdefb);
  color: #1565c0;
  border: 1px solid #90caf9;
}

.tag.key-point {
  background: linear-gradient(135deg, #fff3e0, #ffe0b2);
  color: #e65100;
  border: 1px solid #ffcc02;
}

.tag:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

/* 主标题区域 */
.main-title-section {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 28px;
  padding: 20px;
  background: linear-gradient(135deg, #f8f9fa, #e9ecef);
  border-radius: 12px;
  border-left: 4px solid #409eff;
}

.main-title {
  font-size: 26px;
  font-weight: 700;
  color: #2c3e50;
  margin: 0;
  line-height: 1.3;
  flex: 1;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

.action-icon {
  margin-left: 12px;
  flex-shrink: 0;
  background: #409eff;
  color: white;
  border: none;
  transition: all 0.3s ease;
}

.action-icon:hover {
  background: #66b1ff;
  transform: scale(1.05);
}

/* 详情区域 */
.detail-section {
  background: linear-gradient(135deg, #ffffff, #f8f9fa);
  border-radius: 16px;
  margin-bottom: 20px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  border: 1px solid #e9ecef;
  transition: all 0.3s ease;
}

.detail-section:hover {
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 18px 24px;
  background: linear-gradient(135deg, #f8f9fa, #e9ecef);
  border-bottom: 1px solid #dee2e6;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 8px;
}

.section-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #2c3e50;
}

.mastery-label {
  font-size: 14px;
  color: #495057;
  font-weight: 500;
}

.view-more-btn, .improve-btn {
  color: #409eff;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.view-more-btn:hover, .improve-btn:hover {
  color: #66b1ff;
  transform: translateX(2px);
}

.section-content {
  padding: 24px;
}

.desc-text {
  color: #495057;
  line-height: 1.7;
  margin: 0;
  font-size: 14px;
  text-align: justify;
}

.center-content {
  text-align: center;
}

/* 掌握度卡片 */
.mastery-card {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.mastery-circle {
  width: 140px;
  height: 140px;
  background: linear-gradient(135deg, #409eff, #66b1ff);
  border: 4px solid #e3f2fd;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  margin-bottom: 20px;
  box-shadow: 0 8px 24px rgba(64, 158, 255, 0.3);
  position: relative;
  overflow: hidden;
}

.mastery-circle::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.1), transparent);
  animation: shine 3s infinite;
}

@keyframes shine {
  0% { transform: translateX(-100%) translateY(-100%) rotate(45deg); }
  100% { transform: translateX(100%) translateY(100%) rotate(45deg); }
}

.mastery-percent {
  font-size: 32px;
  font-weight: 700;
  color: #ffffff;
  margin-bottom: 6px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  z-index: 1;
  position: relative;
}

.mastery-text {
  font-size: 12px;
  color: #ffffff;
  margin: 0;
  font-weight: 500;
  z-index: 1;
  position: relative;
}

.mastery-history {
  font-size: 13px;
  color: #6c757d;
  text-align: center;
  margin: 0;
  padding: 8px 16px;
  background: #f8f9fa;
  border-radius: 20px;
  font-weight: 500;
}

/* 资源列表 */
.resource-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.resource-item {
  background: linear-gradient(135deg, #ffffff, #f8f9fa);
  border-radius: 12px;
  border: 1px solid #e9ecef;
  overflow: hidden;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.resource-item:hover {
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
  border-color: #409eff;
}

.resource-item.highlight {
  border-color: #ff6600;
  background: linear-gradient(135deg, #fff3e0, #ffe0b2);
  box-shadow: 0 4px 12px rgba(255, 102, 0, 0.2);
}

.resource-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
}

.resource-left {
  display: flex;
  align-items: flex-start;
  gap: 16px;
  flex: 1;
}

.required-tag {
  background: linear-gradient(135deg, #ff6600, #ff8533);
  color: white;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 600;
  flex-shrink: 0;
  box-shadow: 0 2px 4px rgba(255, 102, 0, 0.3);
}

.resource-info {
  flex: 1;
}

.resource-title {
  font-size: 15px;
  font-weight: 600;
  color: #2c3e50;
  margin: 0 0 6px 0;
  line-height: 1.4;
}

.resource-subtitle {
  font-size: 13px;
  color: #6c757d;
  margin: 0;
  line-height: 1.5;
}

.resource-right {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #f8f9fa, #e9ecef);
  border-radius: 12px;
  flex-shrink: 0;
  border: 1px solid #dee2e6;
  transition: all 0.3s ease;
}

.resource-item:hover .resource-right {
  background: linear-gradient(135deg, #409eff, #66b1ff);
  transform: scale(1.05);
}

.grid-icon {
  color: #6c757d;
  font-size: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.resource-item:hover .grid-icon {
  color: #ffffff;
}

.no-resources {
  text-align: center;
  color: #999;
  padding: 20px;
}

/* 按钮样式 */
.flat-btn {
  background-color: white;
  color: black;
  border: 1px solid #dcdfe6;
  border-radius: 8px;
  padding: 8px 20px;
  font-weight: 500;
}

.flat-btn:hover {
  background-color: #f2f2f2;
}

/* 左侧底部按钮固定位置 */
.left-bottom-button {
  position: absolute;
  bottom: 40px;
  left: 50%;
  transform: translateX(-50%) translateZ(2px);
  z-index: 2000;
  pointer-events: auto;
  will-change: transform;
}

/* 右上方展开按钮 */
.right-top-button {
  position: absolute;
  top: 24px;
  right: 24px;
  z-index: 2000;
  pointer-events: auto;
  transform: translateZ(2px);
  will-change: transform;
}

.expand-btn {
  background: linear-gradient(135deg, #409eff, #66b1ff);
  color: white;
  border: none;
  border-radius: 20px;
  padding: 8px 16px;
  font-weight: 500;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
  transition: all 0.3s ease;
}

.expand-btn:hover {
  background: linear-gradient(135deg, #66b1ff, #85c1ff);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(64, 158, 255, 0.4);
}

/* 缩放控制按钮 */
.zoom-controls {
  position: absolute;
  top: 24px;
  left: 50%;
  transform: translateX(-50%) translateZ(2px);
  z-index: 2000;
  pointer-events: auto;
  display: flex;
  align-items: center;
  gap: 10px;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 20px;
  padding: 5px 15px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(5px);
  border: 1px solid rgba(255, 255, 255, 0.5);
  transition: all 0.3s ease;
}

.zoom-controls:hover {
  background: rgba(255, 255, 255, 1);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
}

.zoom-btn {
  background: linear-gradient(135deg, #409eff, #66b1ff);
  color: white;
  border: none;
  border-radius: 15px;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.3);
}

.zoom-btn:hover {
  background: linear-gradient(135deg, #66b1ff, #85c1ff);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.4);
}

.zoom-level {
  font-size: 14px;
  font-weight: 600;
  color: #333;
  min-width: 40px;
  text-align: center;
}

.reset-btn, .fit-btn {
  background: linear-gradient(135deg, #f56c6c, #f78989);
  color: white;
  border: none;
  border-radius: 15px;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(245, 108, 108, 0.3);
}

.reset-btn:hover, .fit-btn:hover {
  background: linear-gradient(135deg, #f78989, #f9a8a8);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(245, 108, 108, 0.4);
}

</style>
