<template>
    <div ref="chartRef" :style="{ height: height, width: width }"></div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import * as echarts from 'echarts'

// 定义组件的 props
const props = defineProps({
    width: String,
    height: String,
    option: Object
})

// 创建一个 ref 来引用 DOM 元素
const chartRef = ref(null)
let myChart = null

// 初始化图表的函数
const initChart = () => {
    if (myChart) {
        myChart.dispose() // 释放之前的图表实例
    }

    myChart = echarts.init(chartRef.value)
    myChart.setOption(props.option, true)
}

// 在组件挂载时初始化图表，并添加窗口大小变化的监听器
onMounted(() => {
    initChart()
    window.addEventListener('resize', () => {
        if (myChart) {
            myChart.resize()
        }
    })
})

// 在组件卸载前移除窗口大小变化的监听器，并销毁图表
onBeforeUnmount(() => {
    window.removeEventListener('resize', () => {
        if (myChart) {
            myChart.resize()
        }
    })
    if (myChart !== undefined) {
        myChart.dispose()
    }
})

// 监听 props.option 的变化，并重新初始化图表
watch(
    () => props.option,
    () => {
        initChart()
    },
    { deep: true }
)
</script>