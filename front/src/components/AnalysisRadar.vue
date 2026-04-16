<template>
    <div ref="chartRef" class="radar-chart"></div>
  </template>
  
  <script setup>
  import { ref, onMounted, watch } from 'vue'
  import * as echarts from 'echarts'
  
  const props = defineProps({
    data: { type: Object, required: true }
  })
  
  const chartRef = ref(null)
  let myChart = null
  
  function initChart() {
    myChart = echarts.init(chartRef.value)
    myChart.setOption({
      tooltip: {},
      radar: {
        indicator: [
          { name: '难度', max: 100 },
          { name: '重要度', max: 100 },
          { name: '创新度', max: 100 },
          { name: '综合度', max: 100 }
        ]
      },
      series: [{
        name: '题目维度环',
        type: 'radar',
        data: [{
          value: [
            props.data.difficulty,
            props.data.importance,
            props.data.innovation,
            props.data.total
          ],
          name: props.data.title || '本题'
        }]
      }]
    })
  }
  
  onMounted(initChart)
  watch(() => props.data, () => {
    if (myChart) {
      myChart.dispose()
      initChart()
    }
  })
  </script>
  
  <style scoped>
  .radar-chart {
    width: 300px;
    height: 300px;
  }
  </style>
  