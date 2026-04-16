<!-- components/RadarChart.vue -->
<template>
  <div ref="chartRef" style="width: 100%; height: 300px;"></div>
</template>

<script setup>
import { onMounted, watch, ref, onBeforeUnmount } from 'vue'
import * as echarts from 'echarts'

const props = defineProps({
  radarData: Object
})

const chartRef = ref(null)
let chartInstance = null
let resizeObserver = null

function renderChart() {
  if (!chartRef.value) return

  if (!chartInstance) {
    chartInstance = echarts.init(chartRef.value)
  }

  // 确保 radarData 存在且有效
  const radarData = props.radarData || {}
  const keys = Object.keys(radarData)
  
  console.log('雷达图组件接收到的数据:', radarData)
  console.log('雷达图数据键值:', keys)
  
  // 如果没有数据，显示空状态
  if (keys.length === 0) {
    console.log('雷达图没有数据，显示空状态')
    chartInstance.setOption({
      title: {
        text: '暂无数据',
        left: 'center',
        top: 'middle',
        textStyle: {
          color: '#999',
          fontSize: 14
        }
      }
    })
    return
  }

  const indicators = keys.map(key => ({
    name: key,
    max: 100
  }))
  const values = keys.map(key => radarData[key] || 0)

  console.log('雷达图指标:', indicators)
  console.log('雷达图数值:', values)

  chartInstance.setOption({
    tooltip: {},
    radar: {
      indicator: indicators,
      shape: 'polygon',
      radius: '70%'
    },
    series: [{
      type: 'radar',
      data: [{
        value: values,
        name: '知识点掌握'
      }]
    }]
  })

  chartInstance.resize()  // 确保自适应
}


onMounted(() => {
  renderChart()

  resizeObserver = new ResizeObserver(() => {
    chartInstance?.resize()
  })

  resizeObserver.observe(chartRef.value)
})

watch(() => props.radarData, () => {
  if (chartInstance) {
    chartInstance.dispose()
    chartInstance = null
  }
  renderChart()
})

onBeforeUnmount(() => {
  if (chartInstance) chartInstance.dispose()
})
</script>
