<template>
  <div class="overview-panel">
      <!-- 左侧栏 -->
      <div class="column left-col">
        <!-- 人才发展成果 -->
        <div class="panel-box">
          <div class="panel-header">人才发展成果</div>
          <div class="panel-content flex-row">
            <div class="chart-wrapper-circle">
               <v-chart class="chart" :option="talentOption" autoresize />
               <div class="center-text">
                 <div class="num">{{ talentTotal }}</div>
                 <div class="label">{{ isShandongJianzhu ? '数据量(万人)' : '数据量(人)' }}</div>
               </div>
            </div>
            <div class="legend-list">
              <div class="legend-item" v-for="(item, idx) in talentData" :key="idx">
                <span class="dot" :style="{background: item.color}"></span>
                <span class="name">{{ item.name }}</span>
                <span class="val">{{ item.value }}</span>
                <span class="pct">{{ item.pct }}</span>
              </div>
            </div>
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>

        <!-- 学生工作图谱 -->
        <div class="panel-box">
          <div class="panel-header">学生工作图谱</div>
          <div class="panel-content">
            <v-chart class="chart" :option="studentWorkOption" autoresize />
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>

        <!-- 科研效能转化 -->
        <div class="panel-box">
          <div class="panel-header">科研效能转化</div>
          <div class="panel-content flex-row space-around">
            <div class="ring-group" v-for="(item, idx) in researchData" :key="idx">
              <el-progress type="circle" :percentage="item.value" :width="80" :stroke-width="8" :color="item.color" />
              <div class="ring-label">{{ item.label }}</div>
            </div>
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>
      </div>

      <!-- 中间栏 -->
      <div class="column center-col">
        <!-- 顶部数据 -->
        <div class="top-data-row">
          <div class="data-item" v-for="(item, idx) in centerStats" :key="idx">
            <div class="data-label">{{ item.label }}</div>
            <div class="data-num">{{ item.value }}</div>
            <div class="data-decoration"></div>
          </div>
        </div>

        <!-- 中间地图/模型区域 -->
        <div class="center-map-area">
          <div class="map-bg-effect">
            <!-- 扫描线效果 -->
            <div class="scan-line"></div>
            <!-- 网格动画 -->
            <div class="grid-overlay"></div>
            <!-- 光点粒子 -->
            <div class="particles">
              <div class="particle" v-for="(particle, idx) in particles" :key="idx" :style="{
                left: particle.left + '%',
                top: particle.top + '%',
                animationDelay: particle.delay + 's',
                animationDuration: particle.duration + 's'
              }"></div>
            </div>
            <!-- 数据流线条 -->
            <svg class="data-flow" viewBox="0 0 100 100" preserveAspectRatio="none">
              <defs>
                <linearGradient id="flowGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" style="stop-color:#00bfff;stop-opacity:0" />
                  <stop offset="50%" style="stop-color:#00bfff;stop-opacity:0.8" />
                  <stop offset="100%" style="stop-color:#00bfff;stop-opacity:0" />
                </linearGradient>
              </defs>
              <path class="flow-path" d="M0,50 Q25,20 50,50 T100,50" />
              <path class="flow-path" d="M0,30 Q30,60 60,30 T100,30" />
              <path class="flow-path" d="M0,70 Q20,40 40,70 T100,70" />
            </svg>
            <!-- 光晕脉冲 -->
            <div class="glow-pulse"></div>
          </div>
          
          <div class="floating-tag" style="top:30%; left:20%">学术交流与合作</div>
          <div class="floating-tag" style="top:50%; right:20%">科研项目与经费</div>
        </div>
      </div>

      <!-- 右侧栏 -->
      <div class="column right-col">
        <!-- 校园物联感知 -->
        <div class="panel-box">
          <div class="panel-header">校园物联感知</div>
          <div class="panel-content grid-2">
            <div class="iot-item" v-for="(item, idx) in iotData" :key="idx">
               <div class="iot-icon"><component :is="item.icon" /></div>
               <div class="iot-info">
                 <div class="iot-name">{{ item.name }}</div>
                 <div class="iot-val">{{ item.value }}</div>
               </div>
            </div>
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>

        <!-- 学术影响生态 -->
        <div class="panel-box">
          <div class="panel-header">学术影响生态</div>
          <div class="panel-content flex-row">
             <div class="list-side">
               <div class="list-row" v-for="(item, idx) in academicList" :key="idx">
                 <el-icon><CaretRight /></el-icon>
                 <span class="l-name">{{ item.name }}</span>
                 <span class="l-val">{{ item.val }}</span>
               </div>
             </div>
             <div class="chart-side-circle">
               <v-chart class="chart" :option="academicOption" autoresize />
               <div class="center-text">
                 <div class="num">{{ academicTotal }}</div>
                 <div class="label">总计</div>
               </div>
             </div>
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>

        <!-- 教学管理 -->
        <div class="panel-box">
          <div class="panel-header">教学管理</div>
          <div class="panel-content flex-row">
            <div class="teach-stats">
              <div class="t-stat">
                <div class="t-val">{{ teachingData.attendanceRate }}%</div>
                <div class="t-label">学生出勤率</div>
              </div>
            </div>
            <div class="teach-icons">
               <div class="hex-icon" v-for="n in 5" :key="n"></div>
            </div>
            <div class="teach-list">
              <div class="tl-item"><el-icon><User /></el-icon> 学生数量 {{ teachingData.studentCount }}</div>
              <div class="tl-item"><el-icon><Avatar /></el-icon> 教师数量 {{ teachingData.teacherCount }}人</div>
              <div class="tl-item"><el-icon><Reading /></el-icon> 课程数量 {{ teachingData.courseCount }}个</div>
            </div>
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>
      </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { PieChart, BarChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent
} from 'echarts/components'
import VChart from 'vue-echarts'
import { 
  User, Avatar, Reading, Monitor, 
  DataLine, Connection, CaretRight,
  School, Cpu, ChatLineRound
} from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user.js'

use([CanvasRenderer, PieChart, BarChart, TitleComponent, TooltipComponent, LegendComponent, GridComponent])

// 获取管理员信息
const userStore = useUserStore()
const adminInfo = computed(() => {
  try {
    const currentUser = userStore.currentUser || JSON.parse(localStorage.getItem('currentUser') || 'null')
    if (currentUser && currentUser.role === 'admin') {
      return currentUser
    }
    return null
  } catch {
    return null
  }
})

// 判断是否为山东建筑大学
const isShandongJianzhu = computed(() => {
  return adminInfo.value?.school?.includes('山东建筑大学') || adminInfo.value?.school?.includes('山建')
})

// 山东建筑大学数据
const shandongJianzhuData = {
  // 人才发展成果 - 按学科门类分布
  talentData: [
    { name: '工学', value: 45, pct: '35%', color: '#00bfff' },
    { name: '理学', value: 18, pct: '14%', color: '#00f2fe' },
    { name: '管理学', value: 22, pct: '17%', color: '#4facfe' },
    { name: '文学', value: 15, pct: '12%', color: '#7c3aed' },
    { name: '艺术学', value: 12, pct: '9%', color: '#f59e0b' },
    { name: '其他', value: 16, pct: '13%', color: '#67c23a' }
  ],
  talentTotal: 128, // 总数据量（万人）
  
  // 学生工作图谱 - 近5年数据
  studentWorkData: {
    years: ['2020', '2021', '2022', '2023', '2024'],
    enrollment: [2800, 2900, 3000, 3100, 2800], // 招生
    inSchool: [28000, 28500, 28000, 27500, 28000], // 在校
    graduation: [2600, 2700, 2800, 2900, 3000] // 毕业
  },
  
  // 科研效能转化
  researchData: [
    { label: '年均科研经费', value: 85, color: '#f59e0b' }, // 2.69亿元，按百分比显示
    { label: '国家级项目', value: 72, color: '#00bfff' }, // 194项，按百分比显示
    { label: '成果转化率', value: 68, color: '#f43f5e' } // 按百分比显示
  ],
  
  // 顶部统计数据
  centerStats: [
    { label: '在校学生', value: '2.8万' },
    { label: '办学历史', value: '69年' },
    { label: '本科专业', value: '64个' },
    { label: '硕士学位', value: '17个' },
    { label: '博士项目', value: '1个' }
  ],
  
  // 校园物联感知（改为学校资源）
  iotData: [
    { name: '占地面积', value: '2600亩', icon: School },
    { name: '校舍面积', value: '102万㎡', icon: Connection },
    { name: '学院数量', value: '21个', icon: Cpu },
    { name: '馆藏图书', value: '377.57万', icon: ChatLineRound }
  ],
  
  // 学术影响生态
  academicList: [
    { name: '国家级项目', val: '194项' },
    { name: '省部级项目', val: '613项' },
    { name: '有效专利', val: '2245件' },
    { name: '学术论文', val: '17410篇' }
  ],
  academicTotal: 2245,
  
  // 教学管理
  teachingData: {
    attendanceRate: 98,
    studentCount: '2.8万',
    teacherCount: '2200',
    courseCount: '64'
  }
}

// 默认数据（非山东建筑大学时使用）
const defaultData = {
  talentData: [
    { name: '本科', value: 27, pct: '11%', color: '#00bfff' },
    { name: '研究生', value: 45, pct: '12%', color: '#00f2fe' },
    { name: '博士', value: 221, pct: '38%', color: '#4facfe' },
    { name: '研究员', value: 89, pct: '15%', color: '#7c3aed' },
    { name: '工程师', value: 123, pct: '21%', color: '#f59e0b' }
  ],
  talentTotal: 500,
  studentWorkData: {
    years: ['2020', '2021', '2022', '2023', '2024'],
    enrollment: [120, 200, 150, 80, 70],
    inSchool: [320, 332, 301, 334, 390],
    graduation: [150, 232, 201, 154, 190]
  },
  researchData: [
    { label: '科研经费', value: 28, color: '#f59e0b' },
    { label: '科研项目', value: 32, color: '#00bfff' },
    { label: '成果转化', value: 26, color: '#f43f5e' }
  ],
  centerStats: [
    { label: '在校学生', value: '1234' },
    { label: '今年招生', value: '263' },
    { label: '今年毕业', value: '255' },
    { label: '今年就业', value: '368' },
    { label: '今年建业', value: '562' }
  ],
  iotData: [
    { name: '照明设施', value: '4,729个', icon: School },
    { name: '排水排污', value: '1,739个', icon: Connection },
    { name: '垃圾清洁', value: '136处', icon: Cpu },
    { name: '健身器材', value: '12处', icon: ChatLineRound }
  ],
  academicList: [
    { name: '论文发表', val: '50, 57%' },
    { name: '著作出版', val: '43, 21%' },
    { name: '项目承担', val: '97, 13%' },
    { name: '学术交流', val: '300, 9%' }
  ],
  academicTotal: 605,
  teachingData: {
    attendanceRate: 100,
    studentCount: '3256人',
    teacherCount: '125人',
    courseCount: '300人'
  }
}

// 根据学校选择数据
const currentData = computed(() => {
  return isShandongJianzhu.value ? shandongJianzhuData : defaultData
})

const talentData = computed(() => currentData.value.talentData)
const talentTotal = computed(() => currentData.value.talentTotal)

const talentOption = computed(() => ({
  series: [{
    type: 'pie',
    radius: ['60%', '75%'],
    center: ['50%', '50%'],
    label: { show: false },
    data: talentData.value.map(item => ({ value: item.value, name: item.name, itemStyle: { color: item.color } }))
  }]
}))

const studentWorkOption = computed(() => {
  const data = currentData.value.studentWorkData
  return {
    grid: { top: '20%', bottom: '15%', left: '10%', right: '5%' },
    xAxis: {
      type: 'category',
      data: data.years,
      axisLine: { lineStyle: { color: 'rgba(255,255,255,0.3)' } },
      axisLabel: { color: '#fff' }
    },
    yAxis: {
      type: 'value',
      splitLine: { lineStyle: { color: 'rgba(255,255,255,0.1)' } },
      axisLabel: { 
        color: '#fff',
        formatter: (value) => {
          if (isShandongJianzhu.value && value >= 1000) {
            return (value / 1000).toFixed(1) + '万'
          }
          return value
        }
      }
    },
    series: [
      { type: 'bar', name: '招生', data: data.enrollment, itemStyle: { color: '#00bfff' } },
      { type: 'bar', name: '在校', data: data.inSchool, itemStyle: { color: '#00f2fe' } },
      { type: 'bar', name: '毕业', data: data.graduation, itemStyle: { color: '#7c3aed' } }
    ]
  }
})

const researchData = computed(() => currentData.value.researchData)
const centerStats = computed(() => currentData.value.centerStats)

const iotData = computed(() => currentData.value.iotData)
const academicList = computed(() => currentData.value.academicList)
const academicTotal = computed(() => currentData.value.academicTotal)

const academicOption = computed(() => ({
  series: [{
    type: 'pie',
    radius: ['55%', '70%'],
    center: ['50%', '50%'],
    label: { show: false },
    data: [
      { value: academicTotal.value, itemStyle: { color: '#ffff00' } },
      { value: Math.round(academicTotal.value * 0.3), itemStyle: { color: '#00bfff' } }
    ]
  }]
}))

const teachingData = computed(() => currentData.value.teachingData)

// 生成粒子数据
const particles = ref([])
onMounted(() => {
  // 生成20个粒子的随机位置和动画参数
  particles.value = Array.from({ length: 20 }, () => ({
    left: Math.random() * 100,
    top: Math.random() * 100,
    delay: Math.random() * 3,
    duration: Math.random() * 3 + 2
  }))
})
</script>

<style scoped>
.overview-panel {
  display: flex;
  height: 100%;
  padding: 0 10px;
  gap: 15px;
  width: 100%;
  box-sizing: border-box;
  position: relative;
  z-index: 1;
  overflow: visible;
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
  position: relative;
  /* Add padding bottom to avoid nav overlap */
  padding-bottom: 70px;
}

.overview-panel {
  padding-bottom: 70px; /* 为底部导航留出空间 */
}

/* Panels */
.panel-box {
  background: rgba(8, 16, 45, 0.6);
  border: 1px solid rgba(0, 191, 255, 0.3);
  position: relative;
  flex: 1;
  display: flex;
  flex-direction: column;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
}

.panel-header {
  height: 36px;
  line-height: 36px;
  padding-left: 20px;
  background: linear-gradient(90deg, rgba(0, 191, 255, 0.2) 0%, transparent 100%);
  border-bottom: 1px solid rgba(0, 191, 255, 0.2);
  font-size: 16px;
  font-weight: bold;
  color: #00f2fe;
  position: relative;
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

/* Charts & Layouts */
.chart { width: 100%; height: 100%; }
.flex-row { display: flex; align-items: center; height: 100%; }
.space-around { justify-content: space-around; }

.chart-wrapper-circle {
  width: 140px;
  height: 140px;
  position: relative;
}
.center-text {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
}
.center-text .num { font-size: 20px; font-weight: bold; color: #fff; }
.center-text .label { font-size: 10px; color: #aaa; }

.legend-list {
  flex: 1;
  padding-left: 10px;
  font-size: 12px;
}
.legend-item {
  display: flex;
  align-items: center;
  margin-bottom: 5px;
  justify-content: space-between;
}
.dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; margin-right: 5px; }
.name { color: #ccc; flex: 1; }
.val { color: #fff; font-weight: bold; margin-right: 10px; }
.pct { color: #00bfff; }

.ring-group {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}
.ring-label { font-size: 12px; color: #ddd; }

/* Center Column */
.top-data-row {
  display: flex;
  justify-content: space-between;
  padding: 0 20px;
  margin-bottom: 20px;
}
.data-item {
  text-align: center;
  position: relative;
}
.data-label { color: #00bfff; font-size: 12px; margin-bottom: 5px; }
.data-num { font-size: 28px; font-family: 'Impact', sans-serif; color: #fff; text-shadow: 0 0 10px #00bfff; }
.data-decoration { height: 2px; width: 40px; background: #00bfff; margin: 5px auto; box-shadow: 0 0 5px #00bfff; }

.center-map-area {
  flex: 1;
  position: relative;
  background-image: url('@/assets/images/数字孪生(1).png');
  background-size: cover;
  background-position: center center;
  background-repeat: no-repeat;
  background-color: rgba(8, 16, 45, 0.6);
  border-radius: 20px;
  border: 1px solid rgba(0, 191, 255, 0.1);
  overflow: hidden;
  box-shadow: 0 0 30px rgba(0, 191, 255, 0.2);
}

.center-map-area::before {
  content: '';
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  border-radius: 20px;
  background: linear-gradient(45deg, 
    rgba(0, 191, 255, 0.3), 
    rgba(0, 242, 254, 0.3), 
    rgba(0, 191, 255, 0.3));
  background-size: 200% 200%;
  z-index: -1;
  animation: borderGlow 3s linear infinite;
  opacity: 0.5;
}

@keyframes borderGlow {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}

.map-bg-effect {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: transparent;
  pointer-events: none;
  z-index: 0;
  overflow: hidden;
}

/* 扫描线效果 */
.scan-line {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, 
    transparent 0%, 
    rgba(0, 191, 255, 0.8) 50%, 
    transparent 100%);
  box-shadow: 0 0 10px rgba(0, 191, 255, 0.8);
  animation: scanMove 3s linear infinite;
}

@keyframes scanMove {
  0% { top: 0; opacity: 0; }
  10% { opacity: 1; }
  90% { opacity: 1; }
  100% { top: 100%; opacity: 0; }
}

/* 网格动画 */
.grid-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    linear-gradient(rgba(0, 191, 255, 0.1) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0, 191, 255, 0.1) 1px, transparent 1px);
  background-size: 50px 50px;
  animation: gridMove 20s linear infinite;
  opacity: 0.5;
}

@keyframes gridMove {
  0% { transform: translate(0, 0); }
  100% { transform: translate(50px, 50px); }
}

/* 光点粒子 */
.particles {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
}

.particle {
  position: absolute;
  width: 4px;
  height: 4px;
  background: #00bfff;
  border-radius: 50%;
  box-shadow: 0 0 10px #00bfff, 0 0 20px #00bfff;
  animation: particleFloat infinite ease-in-out;
}

@keyframes particleFloat {
  0%, 100% {
    transform: translateY(0) scale(1);
    opacity: 0.3;
  }
  50% {
    transform: translateY(-20px) scale(1.5);
    opacity: 1;
  }
}

/* 数据流线条 */
.data-flow {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  opacity: 0.6;
}

.flow-path {
  fill: none;
  stroke: url(#flowGradient);
  stroke-width: 2;
  stroke-dasharray: 200;
  stroke-dashoffset: 200;
  animation: flowMove 4s linear infinite;
}

.flow-path:nth-child(2) {
  animation-delay: 1.3s;
}

.flow-path:nth-child(3) {
  animation-delay: 2.6s;
}

@keyframes flowMove {
  0% {
    stroke-dashoffset: 200;
    opacity: 0;
  }
  10% {
    opacity: 1;
  }
  90% {
    opacity: 1;
  }
  100% {
    stroke-dashoffset: -200;
    opacity: 0;
  }
}

/* 光晕脉冲 */
.glow-pulse {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 200px;
  height: 200px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0, 191, 255, 0.3) 0%, transparent 70%);
  animation: pulseGlow 3s ease-in-out infinite;
}

@keyframes pulseGlow {
  0%, 100% {
    transform: translate(-50%, -50%) scale(1);
    opacity: 0.3;
  }
  50% {
    transform: translate(-50%, -50%) scale(1.5);
    opacity: 0.6;
  }
}

.floating-tag {
  position: absolute;
  padding: 5px 10px;
  background: rgba(0,0,0,0.6);
  border: 1px solid #f59e0b;
  color: #f59e0b;
  font-size: 12px;
  border-radius: 4px;
  z-index: 2;
  animation: tagFloat 3s ease-in-out infinite;
  box-shadow: 0 0 10px rgba(245, 158, 11, 0.5);
  backdrop-filter: blur(5px);
}

.floating-tag:nth-child(2) {
  animation-delay: 1.5s;
}

@keyframes tagFloat {
  0%, 100% {
    transform: translateY(0);
    box-shadow: 0 0 10px rgba(245, 158, 11, 0.5);
  }
  50% {
    transform: translateY(-10px);
    box-shadow: 0 0 20px rgba(245, 158, 11, 0.8);
  }
}

/* Right Column Specifics */
.grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; padding: 10px; }
.iot-item { display: flex; align-items: center; background: rgba(255,255,255,0.05); padding: 10px; border-radius: 4px; }
.iot-icon { font-size: 24px; color: #00f2fe; margin-right: 10px; }
.iot-name { font-size: 12px; color: #aaa; }
.iot-val { font-size: 16px; font-weight: bold; color: #fff; }

.list-side { flex: 1; font-size: 12px; }
.list-row { display: flex; align-items: center; margin-bottom: 8px; color: #ddd; }
.list-row .el-icon { color: #00bfff; margin-right: 5px; }
.l-name { flex: 1; }
.l-val { color: #00f2fe; }

.chart-side-circle { width: 120px; height: 120px; position: relative; }

.teach-stats { width: 80px; text-align: center; }
.t-val { font-size: 24px; color: #00f2fe; font-weight: bold; }
.t-label { font-size: 10px; color: #aaa; }
.teach-icons { flex: 1; display: flex; flex-wrap: wrap; justify-content: center; gap: 5px; }
.hex-icon { width: 20px; height: 20px; background: #00bfff; clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%); opacity: 0.5; }
.teach-list { width: 120px; font-size: 12px; color: #ddd; display: flex; flex-direction: column; justify-content: center; }
.tl-item { margin-bottom: 5px; display: flex; align-items: center; gap: 5px; }
</style>
