<template>
  <div class="knowledge-graph-container">
    <div ref="chartRef" class="chart-container"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, nextTick, defineExpose, onBeforeUnmount } from 'vue'
import * as echarts from 'echarts'

const props = defineProps({
  data: Object
})

const chartRef = ref(null)
let chart = null
const emit = defineEmits(['nodeClick'])

const handleNodeClick = (params) => {
  console.log('KnowledgeGraph handleNodeClick 被调用:', params);
  
  if (params && params.dataType === 'node') {
    console.log('发射 nodeClick 事件，数据:', params.data);
    emit('nodeClick', params.data)
  }
}

// 生成炫彩渐变色 - 修复为ECharts兼容的颜色值
const generateGradientColors = () => {
  const colors = [
    '#ff6b6b',  // 红色
    '#4ecdc4',  // 青色
    '#a8edea',  // 浅青色
    '#fed6e3',  // 浅粉色
    '#ffecd2',  // 浅橙色
    '#fcb69f',  // 橙色
    '#a8caba',  // 浅绿色
    '#5d4e75',  // 深紫色
    '#ff9a9e',  // 粉红色
    '#fecfef',  // 浅紫色
    '#f093fb',  // 紫色
    '#f5576c',  // 深红色
    '#4facfe',  // 蓝色
    '#00f2fe',  // 青色
    '#43e97b',  // 绿色
    '#38f9d7',  // 浅绿色
    '#fa709a',  // 粉红色
    '#fee140',  // 黄色
    '#667eea',  // 蓝紫色
    '#764ba2'   // 深紫色
  ]
  return colors
}

const convertTreeToGraph = (rootNode) => {
  console.log('convertTreeToGraph 输入数据:', rootNode)
  
  if (!rootNode || !rootNode.name) {
    console.error('convertTreeToGraph: 输入数据无效', rootNode)
    return { nodes: [], links: [] }
  }

  const nodes = []
  const links = []
  const colors = generateGradientColors()

  const traverse = (node, parentPath = '', level = 0) => {
    if (!node || !node.id || !node.name) {
      console.warn('convertTreeToGraph: 跳过无效节点', node)
      return
    }

    const currentPath = parentPath ? `${parentPath}-${node.id}` : String(node.id)
    const colorIndex = level % colors.length
    
    // 创建节点
    const graphNode = {
      id: currentPath,
      name: node.name,
      symbolSize: Math.max(40, 120 - level * 15),
      category: level,
      draggable: true,
      itemStyle: {
        color: colors[colorIndex],  // 直接使用纯色值
        shadowColor: 'rgba(0, 0, 0, 0.3)',
        shadowBlur: 20,
        shadowOffsetX: 0,
        shadowOffsetY: 5,
        borderColor: '#fff',
        borderWidth: 2
      },
      label: {
        show: true,
        color: '#333',
        fontWeight: level === 0 ? 'bold' : 'normal',
        fontSize: Math.max(12, 18 - level * 2),
        backgroundColor: 'rgba(255, 255, 255, 0.8)',
        borderRadius: 4,
        padding: [4, 8]
      },
      symbol: 'circle',
      emphasis: {
        itemStyle: {
          shadowBlur: 30,
          shadowColor: 'rgba(0, 0, 0, 0.5)',
          scale: 1.2
        }
      }
    }
    
    nodes.push(graphNode)
    console.log('添加节点:', graphNode.name, '路径:', currentPath, '级别:', level)

    // 创建连接线
    if (parentPath) {
      const link = {
        source: parentPath,
        target: currentPath,
        lineStyle: {
          color: 'rgba(100, 100, 100, 0.6)',  // 简化为单一颜色
          width: 2,
          curveness: 0.3,
          opacity: 0.6
        },
        emphasis: {
          lineStyle: {
            width: 4,
            opacity: 1,
            color: '#5470C6'
          }
        }
      }
      links.push(link)
      console.log('添加连接线:', parentPath, '->', currentPath)
    }

    // 递归处理子节点
    if (node.children && Array.isArray(node.children)) {
      console.log('处理子节点:', node.name, '子节点数量:', node.children.length)
      node.children.forEach((child, index) => {
        if (child) {
          traverse(child, currentPath, level + 1)
        } else {
          console.warn('跳过空的子节点，索引:', index)
        }
      })
    } else {
      console.log('节点没有子节点:', node.name)
    }
  }

  try {
    traverse(rootNode)
    console.log('convertTreeToGraph 完成，节点数:', nodes.length, '连接数:', links.length)
    return { nodes, links }
  } catch (error) {
    console.error('convertTreeToGraph 执行出错:', error)
    return { nodes: [], links: [] }
  }
}

const renderChart = () => {
  console.log('renderChart 被调用，数据:', props.data)
  
  if (!props.data || !props.data.name) {
    console.warn('renderChart: 数据为空或格式不正确', props.data)
    return
  }

  nextTick(() => {
    try {
      const { nodes, links } = convertTreeToGraph(props.data)
      console.log('renderChart: 转换后的数据', { nodes, links })

      if (nodes.length === 0) {
        console.warn('renderChart: 没有有效的节点数据')
        return
      }

      const option = {
        backgroundColor: 'transparent',
        tooltip: {
          trigger: 'item',
          formatter: '{b}',
          backgroundColor: 'rgba(50,50,50,0.9)',
          textStyle: { color: '#fff' },
          borderColor: 'rgba(255,255,255,0.2)',
          borderWidth: 1,
          borderRadius: 8
        },
        animation: true,
        animationDuration: 2000,
        animationEasing: 'cubicOut',
        animationDelay: (idx) => idx * 100,
        
        series: [
          {
            type: 'graph',
            layout: 'force',
            roam: true,
            focusNodeAdjacency: true,
            selectable: true,
            selectMode: 'single',
            
            // 力导向布局配置
            force: {
              repulsion: 600,
              edgeLength: [120, 200],
              gravity: 0.05,
              layoutAnimation: true
            },
            
            data: nodes,
            links: links,
            
            // 节点样式
            itemStyle: {
              borderColor: '#fff',
              borderWidth: 2
            },
            
            // 连线样式
            lineStyle: {
              color: 'rgba(100, 100, 100, 0.4)',
              width: 2,
              curveness: 0.3
            },
            
            // 强调效果
            emphasis: {
              focus: 'adjacency',
              lineStyle: {
                width: 4,
                color: '#5470C6'
              },
              itemStyle: {
                shadowBlur: 30,
                shadowColor: 'rgba(0, 0, 0, 0.5)'
              }
            },
            
            // 选择效果
            select: {
              itemStyle: {
                borderColor: '#5470C6',
                borderWidth: 3
              }
            }
          }
        ]
      }

      console.log('renderChart: ECharts配置', option)

      // 初始化或重绘
      if (!chart) {
        if (!chartRef.value) {
          console.error('renderChart: chartRef 未找到')
          return
        }
        
        chart = echarts.init(chartRef.value)
        console.log('renderChart: ECharts 实例已创建，绑定点击事件')
        chart.on('click', handleNodeClick)

        // 响应窗口大小变化
        window.addEventListener('resize', () => {
          chart && chart.resize()
        })
      } else {
        chart.off('click')
        chart.on('click', handleNodeClick)
        console.log('renderChart: 重新绑定 ECharts 点击事件')
      }

      // 强制重绘图表
      chart.setOption(option, true)
      console.log('renderChart: 图表渲染完成')
      
    } catch (error) {
      console.error('renderChart: 渲染图表时出错', error)
    }
  })
}

// expose 用于外部调用 resize 方法
defineExpose({
  resize: () => {
    if (chart) chart.resize()
  }
})

onMounted(() => {
  console.log('KnowledgeGraph 组件已挂载，开始监听数据变化')
  
  // 监听数据变化
  watch(
    () => props.data,
    (newData, oldData) => {
      console.log('KnowledgeGraph: 数据发生变化', { newData, oldData })
      if (newData && newData !== oldData) {
        renderChart()
      }
    },
    { deep: true, immediate: true }
  )
})

// 组件卸载时清理资源
onBeforeUnmount(() => {
  console.log('KnowledgeGraph 组件即将卸载，清理资源')
  if (chart) {
    chart.dispose()
    chart = null
  }
  // 移除窗口大小变化监听器
  window.removeEventListener('resize', () => {
    chart && chart.resize()
  })
})
</script>

<style scoped>
.knowledge-graph-container {
  width: 100%;
  height: 100vh;
  position: relative;
  background: #ffffff;  /* 改为白色背景 */
  overflow: hidden;
}

.chart-container {
  width: 100%;
  height: 100%;
}
</style>
