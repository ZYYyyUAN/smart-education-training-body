<template>
  <div class="teacher-dashboard">
    <!-- 顶部导航 -->
    <div class="header">
      <h2>教师综合页面</h2>
      <div class="nav-tabs">
        <el-tabs v-model="activeTab">
          <el-tab-pane label="备课与设计" name="preparation"></el-tab-pane>
          <el-tab-pane label="考核内容生成" name="exam"></el-tab-pane>
          <el-tab-pane label="学情数据分析" name="analysis"></el-tab-pane>
        </el-tabs>
      </div>
    </div>

    <div class="main-content">
      <!-- 左侧导航栏 -->
      <div class="left-sidebar">
        <el-menu default-active="1" class="sidebar-menu">
          <el-sub-menu index="1">
            <template #title>
              <span>本地课程</span>
            </template>
            <el-menu-item index="1-1">课程大纲</el-menu-item>
            <el-menu-item index="1-2">知识库文档</el-menu-item>
            <el-menu-item index="1-3">教学资源</el-menu-item>
          </el-sub-menu>
          <el-menu-item index="2">
            <span>教学进度</span>
          </el-menu-item>
          <el-menu-item index="3">
            <span>学生管理</span>
          </el-menu-item>
        </el-menu>
      </div>

      <!-- 中间主要内容区 -->
      <div class="content-area">
        <!-- 当前教学内容生成区 -->
        <div class="teaching-content-section">
          <h3>当前教学内容生成</h3>
          <div class="content-generation">
            <el-select v-model="selectedCourse" placeholder="选择课程">
              <el-option
                v-for="course in courses"
                :key="course.value"
                :label="course.label"
                :value="course.value"
              />
            </el-select>
            
            <el-button type="primary" @click="generateContent">生成教学内容</el-button>
            
            <div v-if="generatedContent" class="content-preview">
              <el-tabs type="border-card">
                <el-tab-pane label="知识讲解">
                  <div v-html="generatedContent.knowledge"></div>
                </el-tab-pane>
                <el-tab-pane label="实训练习">
                  <div v-html="generatedContent.practice"></div>
                </el-tab-pane>
                <el-tab-pane label="时间分布">
                  <div v-html="generatedContent.schedule"></div>
                </el-tab-pane>
              </el-tabs>
            </div>
          </div>
        </div>

        <!-- 考核内容生成区 -->
        <div class="exam-generation-section">
          <h3>考核内容生成</h3>
          <div class="exam-controls">
            <el-input v-model="examTopic" placeholder="输入考核主题" style="width: 300px" />
            <el-select v-model="examType" placeholder="选择题目类型" style="width: 200px">
              <el-option label="选择题" value="choice" />
              <el-option label="填空题" value="fill" />
              <el-option label="编程题" value="programming" />
              <el-option label="综合题" value="comprehensive" />
            </el-select>
            <el-input-number v-model="questionCount" :min="1" :max="20" />
            <el-button type="primary" @click="generateExam">生成考核题目</el-button>
          </div>
          
          <div v-if="generatedExam" class="exam-preview">
            <el-card>
              <div v-html="generatedExam.questions"></div>
              <el-collapse>
                <el-collapse-item title="参考答案">
                  <div v-html="generatedExam.answers"></div>
                </el-collapse-item>
              </el-collapse>
            </el-card>
          </div>
        </div>
      </div>

      <!-- 右侧学情数据分析区 -->
      <div class="right-analysis">
        <h3>学情数据分析</h3>
        <div class="analysis-content">
          <!-- 学生整体数据环形图 -->
          <div class="chart-container">
            <h4>学生整体数据</h4>
            <div ref="pieChart" style="width: 100%; height: 200px;"></div>
          </div>
          
          <!-- 错题率柱状图 -->
          <div class="chart-container">
            <h4>错题率分析</h4>
            <div ref="barChart" style="width: 100%; height: 250px;"></div>
          </div>
          
          <!-- 知识点掌握情况 -->
          <div class="knowledge-mastery">
            <h4>知识点掌握情况</h4>
            <el-table :data="knowledgeData" style="width: 100%">
              <el-table-column prop="knowledge" label="知识点" />
              <el-table-column prop="mastery" label="掌握率">
                <template #default="{row}">
                  <el-progress :percentage="row.mastery" :color="getMasteryColor(row.mastery)" />
                </template>
              </el-table-column>
              <el-table-column label="建议">
                <template #default="{row}">
                  {{ getSuggestion(row.mastery) }}
                </template>
              </el-table-column>
            </el-table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';

export default {
  setup() {
    // 数据状态
    const activeTab = ref('preparation');
    const selectedCourse = ref('');
    const generatedContent = ref(null);
    const examTopic = ref('');
    const examType = ref('');
    const questionCount = ref(5);
    const generatedExam = ref(null);
    const pieChart = ref(null);
    const barChart = ref(null);
    
    // 模拟数据
    const courses = ref([
      { label: '嵌入式Linux开发', value: 'embedded-linux' },
      { label: '数据结构与算法', value: 'data-structure' },
      { label: '操作系统原理', value: 'os' }
    ]);
    
    const knowledgeData = ref([
      { knowledge: 'Linux系统调用', mastery: 78 },
      { knowledge: '进程管理', mastery: 65 },
      { knowledge: '内存管理', mastery: 82 },
      { knowledge: '文件系统', mastery: 71 },
      { knowledge: '设备驱动', mastery: 58 }
    ]);
    
    // 方法
    const generateContent = () => {
      // 模拟API调用生成教学内容
      generatedContent.value = {
        knowledge: `
          <h4>Linux系统调用</h4>
          <p>系统调用是操作系统提供给用户程序的一组接口，用户程序通过这些接口请求操作系统服务...</p>
          <h4>进程管理</h4>
          <p>进程是程序的一次执行过程，是系统资源分配的基本单位...</p>
        `,
        practice: `
          <h4>实训练习</h4>
          <ol>
            <li>编写一个简单的系统调用程序</li>
            <li>实现进程创建和管理的示例</li>
            <li>分析进程调度过程</li>
          </ol>
        `,
        schedule: `
          <h4>时间分布建议</h4>
          <ul>
            <li>理论讲解: 2课时</li>
            <li>示例演示: 1课时</li>
            <li>实训练习: 3课时</li>
          </ul>
        `
      };
    };
    
    const generateExam = () => {
      // 模拟API调用生成考核内容
      generatedExam.value = {
        questions: `
          <h4>${examTopic.value || 'Linux系统调用'}考核题目</h4>
          <ol>
            <li>什么是系统调用？它与库函数有什么区别？</li>
            <li>描述fork()系统调用的功能和使用方法。</li>
            <li>编写一个简单的程序，使用open()和read()系统调用读取文件内容。</li>
          </ol>
        `,
        answers: `
          <h4>参考答案</h4>
          <ol>
            <li>系统调用是操作系统提供给用户程序的一组接口...</li>
            <li>fork()系统调用用于创建一个新的进程...</li>
            <li><pre>#include &lt;fcntl.h&gt;
#include &lt;unistd.h&gt;
// 示例代码...</pre></li>
          </ol>
        `
      };
    };
    
    const getMasteryColor = (percentage) => {
      if (percentage >= 80) return '#67C23A';
      if (percentage >= 60) return '#E6A23C';
      return '#F56C6C';
    };
    
    const getSuggestion = (percentage) => {
      if (percentage >= 80) return '掌握良好，可适当拓展';
      if (percentage >= 60) return '基本掌握，需要加强练习';
      return '掌握不足，建议重点讲解';
    };
    
    // 初始化图表
    const initCharts = () => {
      // 环形图 - 学生整体数据
      const pie = echarts.init(pieChart.value);
      pie.setOption({
        tooltip: {
          trigger: 'item'
        },
        legend: {
          top: '5%',
          left: 'center'
        },
        series: [
          {
            name: '学生分布',
            type: 'pie',
            radius: ['40%', '70%'],
            avoidLabelOverlap: false,
            itemStyle: {
              borderRadius: 10,
              borderColor: '#fff',
              borderWidth: 2
            },
            label: {
              show: false,
              position: 'center'
            },
            emphasis: {
              label: {
                show: true,
                fontSize: '18',
                fontWeight: 'bold'
              }
            },
            labelLine: {
              show: false
            },
            data: [
              { value: 35, name: '优秀' },
              { value: 40, name: '良好' },
              { value: 20, name: '及格' },
              { value: 5, name: '不及格' }
            ]
          }
        ]
      });
      
      // 柱状图 - 错题率
      const bar = echarts.init(barChart.value);
      bar.setOption({
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'shadow'
          }
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          data: ['系统调用', '进程管理', '内存管理', '文件系统', '设备驱动'],
          axisLabel: {
            interval: 0,
            rotate: 30
          }
        },
        yAxis: {
          type: 'value',
          name: '错题率(%)'
        },
        series: [
          {
            name: '错题率',
            type: 'bar',
            data: [22, 35, 18, 29, 42],
            itemStyle: {
              color: function(params) {
                const colorList = ['#409EFF', '#67C23A', '#E6A23C', '#F56C6C', '#909399'];
                return colorList[params.dataIndex % colorList.length];
              }
            }
          }
        ]
      });
    };
    
    onMounted(() => {
      initCharts();
    });
    
    return {
      activeTab,
      selectedCourse,
      courses,
      generatedContent,
      examTopic,
      examType,
      questionCount,
      generatedExam,
      knowledgeData,
      pieChart,
      barChart,
      generateContent,
      generateExam,
      getMasteryColor,
      getSuggestion
    };
  }
};
</script>

<style scoped>
.teacher-dashboard {
  font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', Arial, sans-serif;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4e8eb 100%);
  min-height: 100vh;
  padding: 20px;
}

.header {
  background: white;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.header h2 {
  margin: 0;
  color: #303133;
}

.main-content {
  display: flex;
  gap: 20px;
}

.left-sidebar {
  width: 220px;
  background: white;
  border-radius: 8px;
  padding: 10px 0;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.sidebar-menu {
  border-right: none;
}

.content-area {
  flex: 1;
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.right-analysis {
  width: 350px;
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.teaching-content-section,
.exam-generation-section,
.analysis-content {
  margin-bottom: 30px;
}

h3 {
  color: #303133;
  border-left: 4px solid #409EFF;
  padding-left: 10px;
  margin: 0 0 20px 0;
}

h4 {
  color: #606266;
  margin: 15px 0 10px 0;
}

.content-generation,
.exam-controls {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
  flex-wrap: wrap;
  align-items: center;
}

.content-preview,
.exam-preview {
  margin-top: 20px;
}

.chart-container {
  margin-bottom: 25px;
  background: #f9f9f9;
  padding: 15px;
  border-radius: 6px;
}

.knowledge-mastery {
  margin-top: 20px;
}

.el-progress {
  margin-top: 8px;
}
</style>