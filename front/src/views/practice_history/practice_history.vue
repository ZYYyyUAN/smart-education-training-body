<template>
  <div class="practice-history-container">
    <!-- 顶部导航 -->
    <div class="top-bar">
      <div class="back-button">
        <i class="icon-back" @click="goBack">←</i>
      </div>
      <div class="title-container">
        <h1 class="title">历史练习记录</h1>
      </div>
      <div class="filter-section">
        <el-select v-model="selectedCourse" placeholder="选择课程" @change="handleCourseChange" style="width: 150px; margin-right: 10px;">
          <el-option label="全部课程" value=""></el-option>
          <el-option label="嵌入式进阶" value="101"></el-option>
        </el-select>
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          @change="loadHistoryRecords"
          style="width: 250px;">
        </el-date-picker>
      </div>
    </div>

    <!-- 统计卡片单独一行 -->
    <div class="stats-section">
      <div class="stat-card">
        <div class="stat-icon">📊</div>
        <div class="stat-content">
          <div class="stat-number">{{ totalPractices }}</div>
          <div class="stat-label">总练习次数</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">✅</div>
        <div class="stat-content">
          <div class="stat-number">{{ averageAccuracy }}%</div>
          <div class="stat-label">平均正确率</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">🎯</div>
        <div class="stat-content">
          <div class="stat-number">{{ totalQuestions }}</div>
          <div class="stat-label">总题目数</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">⭐</div>
        <div class="stat-content">
          <div class="stat-number">{{ bestScore }}%</div>
          <div class="stat-label">最高得分</div>
        </div>
      </div>
    </div>
    <!-- 主内容区：练习记录 + 错题排行榜横向排列 -->
    <div class="main-content">
      <div class="history-list">
        <!-- 练习记录原有内容全部放这里 -->
        <div class="list-header">
          <h2>练习记录</h2>
          <div class="sort-options">
            <el-select v-model="sortBy" placeholder="排序方式" @change="sortRecords" style="width: 120px;">
              <el-option label="时间倒序" value="date-desc"></el-option>
              <el-option label="时间正序" value="date-asc"></el-option>
              <el-option label="得分倒序" value="score-desc"></el-option>
              <el-option label="得分正序" value="score-asc"></el-option>
            </el-select>
          </div>
        </div>
        <div v-if="loading" class="loading-container">
          <div class="loading-spinner"></div>
          <p>加载中...</p>
        </div>
        <div v-else-if="practiceRecords.length === 0" class="empty-state">
          <div class="empty-icon">📝</div>
          <p>暂无练习记录</p>
          <button class="start-practice-btn" @click="startNewPractice">开始练习</button>
        </div>
        <div v-else class="records-container">
          <div 
            v-for="record in practiceRecords" 
            :key="record.id" 
            class="record-card"
            @click="showRecordDetail(record)"
          >
            <div class="record-header">
              <div class="record-type">{{ record.practiceType }}</div>
              <div class="record-date">{{ formatDate(record.practiceDate) }}</div>
            </div>
            <div class="record-stats">
              <div class="stat-item">
                <span class="stat-label">正确率:</span>
                <span class="stat-value" :class="getAccuracyClass(record.accuracyRate)">
                  {{ record.accuracyRate }}%
                </span>
              </div>
              <div class="stat-item">
                <span class="stat-label">题目数:</span>
                <span class="stat-value">{{ record.totalQuestions }}</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">正确:</span>
                <span class="stat-value correct">{{ record.correctCount }}</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">错误:</span>
                <span class="stat-value wrong">{{ record.wrongCount }}</span>
              </div>
            </div>
            <div class="record-footer">
              <div class="course-info">{{ getCourseName(record.courseId) }}</div>
              <div class="view-detail">
                <span>查看详情</span>
                <i class="arrow-icon">→</i>
              </div>
            </div>
          </div>
        </div>
        <!-- 分页 -->
        <div v-if="practiceRecords.length > 0" class="pagination-container">
          <el-pagination
            :current-page="currentPage"
            :page-size="pageSize"
            :page-sizes="[5, 10, 20, 50, 100]"
            :total="totalRecords"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </div>
      <div class="weak-points-ranking">
        <div class="ranking-header">
          <h3 class="ranking-title">📊 错误知识点排行榜</h3>
          <p class="ranking-subtitle">根据您的练习记录，显示错误最多的知识点</p>
          <button class="refresh-btn" @click="refreshRanking" title="刷新排行榜">
            🔄
          </button>
        </div>
        <div class="ranking-content" v-if="weakPointsRanking.length > 0">
          <div class="ranking-item" v-for="(item, index) in weakPointsRanking" :key="index">
            <div class="ranking-number" :class="getRankingClass(index)">
              {{ index + 1 }}
            </div>
            <div class="ranking-info">
              <div class="knowledge-name">{{ item.knowledgePoint }}</div>
              <div class="ranking-stats">
                <span class="error-count">错误: {{ item.wrongCount }}次</span>
                <span class="accuracy-rate">正确率: {{ item.accuracyRate }}%</span>
              </div>
            </div>
            <div class="ranking-progress">
              <el-progress 
                :percentage="100 - item.accuracyRate" 
                :color="getProgressColor(100 - item.accuracyRate)"
                :stroke-width="8"
                :show-text="false"
              />
            </div>
          </div>
        </div>
        <div class="no-data" v-else>
          <div class="no-data-icon">📝</div>
          <p>暂无练习记录，开始练习后即可查看错题排行榜</p>
        </div>
      </div>
    </div>

    <!-- 详情弹窗 -->
    <el-dialog
      v-model="showDetailDialog"
      title="练习详情"
      width="80%"
      :before-close="closeDetailDialog"
    >
      <div v-if="selectedRecord" class="detail-content">
        <div class="detail-header">
          <div class="detail-info">
            <h3>{{ selectedRecord.practiceType }}</h3>
            <p>练习时间: {{ formatDate(selectedRecord.practiceDate) }}</p>
            <p>课程: {{ getCourseName(selectedRecord.courseId) }}</p>
          </div>
          <div class="detail-summary">
            <div class="summary-item">
              <span class="summary-label">总题目:</span>
              <span class="summary-value">{{ selectedRecord.totalQuestions }}</span>
            </div>
            <div class="summary-item">
              <span class="summary-label">正确率:</span>
              <span class="summary-value" :class="getAccuracyClass(selectedRecord.accuracyRate)">
                {{ selectedRecord.accuracyRate }}%
              </span>
            </div>
            <div class="summary-item">
              <span class="summary-label">正确:</span>
              <span class="summary-value correct">{{ selectedRecord.correctCount }}</span>
            </div>
            <div class="summary-item">
              <span class="summary-label">错误:</span>
              <span class="summary-value wrong">{{ selectedRecord.wrongCount }}</span>
            </div>
          </div>
        </div>

        <div class="questions-detail">
          <h4>题目详情</h4>
          <div class="question-list">
            <div 
              v-for="(question, index) in selectedRecord.questionDetails" 
              :key="index"
              class="question-item"
              :class="{ correct: question.isCorrect, wrong: !question.isCorrect }"
            >
              <div class="question-header">
                <span class="question-number">第{{ index + 1 }}题</span>
                <span class="question-type">{{ getQuestionTypeText(question.questionType) }}</span>
                <span class="question-score" :class="question.isCorrect ? 'correct' : 'wrong'">
                  {{ question.score }}分
                </span>
              </div>
              <div class="question-content">
                <!-- 选择题显示题干和选项 -->
                <div v-if="question.questionType === 'choice'" class="choice-question">
                  <div class="question-text">{{ parseChoiceQuestion(question.questionContent).question }}</div>
                  <div class="options-list">
                    <div 
                      v-for="(option, index) in parseChoiceQuestion(question.questionContent).options" 
                      :key="index"
                      class="option-item"
                      :class="{
                        'user-selected': question.userAnswer == index,
                        'correct-option': question.correctAnswer == index,
                        'wrong-selected': question.userAnswer == index && question.userAnswer != question.correctAnswer
                      }"
                    >
                      <span class="option-label">{{ getOptionLabel(index) }}.</span>
                      <span class="option-text">{{ option }}</span>
                      <span v-if="question.userAnswer == index" class="selection-indicator">
                        {{ question.userAnswer == question.correctAnswer ? '✓' : '✗' }}
                      </span>
                    </div>
                  </div>
                </div>
                
                <!-- 其他题型显示原始内容 -->
                <div v-else>
                  <div class="question-text">{{ question.questionContent }}</div>
                </div>
                
                <div class="answer-section">
                  <div class="user-answer">
                    <strong>你的答案:</strong> {{ formatAnswer(question.userAnswer, question.questionType) }}
                  </div>
                  <div class="correct-answer">
                    <strong>正确答案:</strong> {{ formatAnswer(question.correctAnswer, question.questionType) }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import axios from 'axios';
import { ElMessage, ElProgress } from 'element-plus';
import { useUserStore } from '@/store/user.js'

const router = useRouter();
const route = useRoute();

// 响应式数据
const loading = ref(false);
const practiceRecords = ref([]);
const selectedCourse = ref('');
const dateRange = ref([]);
const sortBy = ref('date-desc');
const currentPage = ref(1);
const pageSize = ref(5);
const totalRecords = ref(0);
const showDetailDialog = ref(false);
const selectedRecord = ref(null);

// 错题排行榜相关
const weakPointsRanking = ref([]);

// 计算属性
const totalPractices = computed(() => practiceRecords.value.length);
const averageAccuracy = computed(() => {
  if (practiceRecords.value.length === 0) return 0;
  const total = practiceRecords.value.reduce((sum, record) => sum + record.accuracyRate, 0);
  return Math.round(total / practiceRecords.value.length);
});
const totalQuestions = computed(() => {
  return practiceRecords.value.reduce((sum, record) => sum + record.totalQuestions, 0);
});
const bestScore = computed(() => {
  if (practiceRecords.value.length === 0) return 0;
  return Math.max(...practiceRecords.value.map(record => record.accuracyRate));
});

// 方法
const goBack = () => {
  router.push('/ai_practice');
};

const loadHistoryRecords = async () => {
  loading.value = true;
  try {
    const params = {
      studentId: useUserStore().currentUserId, // 从用户信息获取
      page: currentPage.value,
      size: pageSize.value,
      courseId: selectedCourse.value,
      sortBy: sortBy.value
    };

    if (dateRange.value && dateRange.value.length === 2) {
      params.startDate = dateRange.value[0].toISOString();
      params.endDate = dateRange.value[1].toISOString();
    }

    const response = await axios.get('/api/xiaozhi/student/getPracticeHistory', { params });
    console.log('完整API响应:', response);
    console.log('API响应data:', response.data);
    console.log('response.data.data:', response.data.data);
    console.log('response.data.data.records:', response.data.data?.records);
    console.log('response.data.data.records类型:', typeof response.data.data?.records);
    console.log('response.data.data.records长度:', response.data.data?.records ? response.data.data.records.length : 'undefined');
    console.log('response.data.data.records是否为数组:', Array.isArray(response.data.data?.records));
    
    // 确保数据正确赋值
    if (response.data && response.data.data && response.data.data.records) {
      practiceRecords.value = response.data.data.records;
      totalRecords.value = response.data.data.total || 0;
    } else {
      practiceRecords.value = [];
      totalRecords.value = 0;
    }
    
    console.log('处理后的数据:', practiceRecords.value);
    console.log('practiceRecords.value长度:', practiceRecords.value.length);
    console.log('loading状态:', loading.value);
  } catch (error) {
    console.error('加载练习记录失败:', error);
    ElMessage.error('加载练习记录失败');
  } finally {
    loading.value = false;
  }
  
  // 加载错题排行榜数据
  await loadWeakPointsRanking();
};

const sortRecords = () => {
  loadHistoryRecords();
};

const handleCourseChange = () => {
  loadHistoryRecords();
};

// 手动刷新错题排行榜
const refreshRanking = async () => {
  try {
    await loadWeakPointsRanking();
    ElMessage.success('错题排行榜已刷新');
  } catch (error) {
    ElMessage.error('刷新失败，请重试');
  }
};

const handleSizeChange = (size) => {
  pageSize.value = size;
  currentPage.value = 1;
  loadHistoryRecords();
};

const handleCurrentChange = (page) => {
  currentPage.value = page;
  loadHistoryRecords();
};

const showRecordDetail = (record) => {
  selectedRecord.value = record;
  showDetailDialog.value = true;
};

const closeDetailDialog = () => {
  showDetailDialog.value = false;
  selectedRecord.value = null;
};

const startNewPractice = () => {
  router.push('/ai_practice');
};

// 加载错题排行榜数据
const loadWeakPointsRanking = async () => {
  try {
    const response = await axios.get('/api/xiaozhi/student/weakPointsRanking', {
      params: {
        studentId: useUserStore().currentUserId, // 从用户信息获取
        courseId: selectedCourse.value || 101, // 当前选中的课程ID，如果没有选择则默认101
        limit: 6 // 显示前6个薄弱知识点
      }
    });
    
    if (response.data.code === 200) {
      weakPointsRanking.value = response.data.data || [];
    }
  } catch (error) {
    console.error('获取错题排行榜失败', error);
  }
};

// 获取排行榜样式类
const getRankingClass = (index) => {
  if (index === 0) return 'rank-first';
  if (index === 1) return 'rank-second';
  if (index === 2) return 'rank-third';
  return 'rank-normal';
};

// 获取进度条颜色
const getProgressColor = (errorRate) => {
  if (errorRate >= 80) return '#f56c6c'; // 红色
  if (errorRate >= 60) return '#e6a23c'; // 橙色
  if (errorRate >= 40) return '#409eff'; // 蓝色
  return '#67c23a'; // 绿色
};

const formatDate = (dateInput) => {
  let date;
  if (Array.isArray(dateInput)) {
    // 处理数组格式的日期 [2024, 1, 15, 10, 30]
    date = new Date(dateInput[0], dateInput[1] - 1, dateInput[2], dateInput[3], dateInput[4]);
  } else if (typeof dateInput === 'string') {
    // 处理字符串格式的日期
    date = new Date(dateInput);
  } else {
    // 处理其他格式
    date = new Date(dateInput);
  }
  return date.toLocaleString('zh-CN');
};

const getAccuracyClass = (accuracy) => {
  if (accuracy >= 80) return 'excellent';
  if (accuracy >= 60) return 'good';
  return 'poor';
};

const getCourseName = (courseId) => {
  const courseMap = {
    '101': '嵌入式进阶'
  };
  return courseMap[courseId] || '未知课程';
};

const getQuestionTypeText = (type) => {
  const typeMap = {
    'choice': '选择题',
    'judgement': '判断题',
    'short_answer': '简答题',
    'programming': '编程题'
  };
  return typeMap[type] || '未知题型';
};

const formatAnswer = (answer, type) => {
  if (type === 'choice') {
    const labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    return labels[answer] || answer;
  } else if (type === 'judgement') {
    return answer ? '对' : '错';
  } else {
    return answer || '未作答';
  }
};

// 解析选择题内容，提取题干和选项
const parseChoiceQuestion = (content) => {
  if (!content) return { question: '', options: [] };
  
  // 匹配选项的正则表达式（匹配A.、B.、C.、D.等开头的选项）
  const optionRegex = /([A-H][.、])\s*(.+?)(?=\s*[A-H][.、]\s*|\s*$)/g;
  const matches = [...content.matchAll(optionRegex)];
  
  // 如果没有匹配到选项，则返回原始内容作为问题
  if (matches.length === 0) {
    return { question: content, options: [] };
  }
  
  // 提取选项
  const options = matches.map(match => match[2].trim());
  
  // 提取问题部分（第一个选项之前的内容）
  const questionPart = content.substring(0, content.indexOf(matches[0][0])).trim();
  
  return { question: questionPart, options };
};

// 获取选项标签
const getOptionLabel = (index) => {
  const labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  return labels[index] || '';
};

// 生命周期
onMounted(() => {
  loadHistoryRecords();
  
  // 检查是否有刷新参数
  if (route.query.refresh === 'true') {
    // 如果有刷新参数，立即刷新错题排行榜
    loadWeakPointsRanking();
    // 清除URL中的刷新参数
    router.replace({ path: '/practice_history', query: {} });
  }
  
  // 监听页面可见性变化，当页面重新获得焦点时刷新数据
  const handleVisibilityChange = () => {
    if (!document.hidden) {
      // 页面重新可见时，刷新错题排行榜
      loadWeakPointsRanking();
    }
  };

  document.addEventListener('visibilitychange', handleVisibilityChange);

  // 清理事件监听器
  onUnmounted(() => {
    document.removeEventListener('visibilitychange', handleVisibilityChange);
  });
});
</script>

<style scoped>
.practice-history-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f0f5ff 0%, #e6eeff 100%);
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

.top-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 30px;
  background: white;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.back-button {
  cursor: pointer;
  font-size: 24px;
  color: #333;
}

.title-container {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
}

.title {
  font-size: 28px;
  font-weight: bold;
  background: linear-gradient(to right, #6a5acd, #ff69b4);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

.filter-section {
  display: flex;
  align-items: center;
}

.stats-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  padding: 30px;
  max-width: 1200px;
  margin: 0 auto;
}

.stat-card {
  background: white;
  border-radius: 15px;
  padding: 25px;
  display: flex;
  align-items: center;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.stat-icon {
  font-size: 40px;
  margin-right: 20px;
}

.stat-content {
  flex: 1;
}

.stat-number {
  font-size: 32px;
  font-weight: bold;
  color: #6a5acd;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 14px;
  color: #666;
}

/* 错题排行榜样式 */
.weak-points-ranking {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 15px;
  padding: 25px;
  margin: 0;
  margin-top: 0;
  max-width: 1200px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  backdrop-filter: blur(10px);
}

.ranking-header {
  text-align: center;
  margin-bottom: 25px;
  position: relative;
}

.refresh-btn {
  position: absolute;
  top: 0;
  right: 0;
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  padding: 5px;
  border-radius: 50%;
  transition: transform 0.3s ease;
}

.refresh-btn:hover {
  transform: rotate(180deg);
  background-color: rgba(255, 255, 255, 0.1);
}

.ranking-title {
  font-size: 24px;
  font-weight: bold;
  color: #333;
  margin-bottom: 8px;
}

.ranking-subtitle {
  font-size: 14px;
  color: #666;
  margin: 0;
}

.ranking-content {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.ranking-item {
  display: flex;
  align-items: center;
  padding: 15px;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 10px;
  border: 1px solid #e0e0e0;
  transition: transform 0.2s, box-shadow 0.2s;
}

.ranking-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.ranking-number {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 16px;
  margin-right: 15px;
  color: white;
}

.rank-first {
  background: linear-gradient(135deg, #ffd700, #ffed4e);
  box-shadow: 0 2px 8px rgba(255, 215, 0, 0.3);
}

.rank-second {
  background: linear-gradient(135deg, #c0c0c0, #e0e0e0);
  box-shadow: 0 2px 8px rgba(192, 192, 192, 0.3);
}

.rank-third {
  background: linear-gradient(135deg, #cd7f32, #daa520);
  box-shadow: 0 2px 8px rgba(205, 127, 50, 0.3);
}

.rank-normal {
  background: linear-gradient(135deg, #6a5acd, #8a7fd1);
  box-shadow: 0 2px 8px rgba(106, 90, 205, 0.3);
}

.ranking-info {
  flex: 1;
  margin-right: 15px;
}

.knowledge-name {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 5px;
}

.ranking-stats {
  display: flex;
  gap: 15px;
  font-size: 12px;
  color: #666;
}

.error-count {
  color: #f56c6c;
  font-weight: 500;
}

.accuracy-rate {
  color: #67c23a;
  font-weight: 500;
}

.ranking-progress {
  width: 120px;
}

.no-data {
  text-align: center;
  padding: 40px 20px;
  color: #999;
}

.no-data-icon {
  font-size: 48px;
  margin-bottom: 15px;
}

.no-data p {
  font-size: 14px;
  margin: 0;
}

.history-list {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 30px 30px;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.list-header h2 {
  font-size: 24px;
  color: #333;
  margin: 0;
}

.loading-container {
  text-align: center;
  padding: 50px;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #6a5acd;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.empty-state {
  text-align: center;
  padding: 80px 20px;
}

.empty-icon {
  font-size: 60px;
  margin-bottom: 20px;
}

.empty-state p {
  font-size: 18px;
  color: #666;
  margin-bottom: 30px;
}

.start-practice-btn {
  background: linear-gradient(135deg, #6a5acd, #ff69b4);
  color: white;
  border: none;
  border-radius: 25px;
  padding: 12px 30px;
  font-size: 16px;
  cursor: pointer;
  transition: transform 0.3s ease;
}

.start-practice-btn:hover {
  transform: translateY(-2px);
}

.records-container {
  display: grid;
  gap: 20px;
}

.record-card {
  background: white;
  border-radius: 15px;
  padding: 25px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  transition: all 0.3s ease;
}

.record-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
}

.record-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.record-type {
  font-size: 18px;
  font-weight: bold;
  color: #333;
}

.record-date {
  font-size: 14px;
  color: #666;
}

.record-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 15px;
  margin-bottom: 20px;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stat-label {
  font-size: 14px;
  color: #666;
}

.stat-value {
  font-weight: bold;
  font-size: 16px;
}

.stat-value.excellent {
  color: #28a745;
}

.stat-value.good {
  color: #ffc107;
}

.stat-value.poor {
  color: #dc3545;
}

.stat-value.correct {
  color: #28a745;
}

.stat-value.wrong {
  color: #dc3545;
}

.record-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 15px;
  border-top: 1px solid #eee;
}

.course-info {
  font-size: 14px;
  color: #666;
}

.view-detail {
  display: flex;
  align-items: center;
  color: #6a5acd;
  font-size: 14px;
}

.arrow-icon {
  margin-left: 5px;
  transition: transform 0.3s ease;
}

.record-card:hover .arrow-icon {
  transform: translateX(5px);
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 30px;
}

.detail-content {
  max-height: 70vh;
  overflow-y: auto;
}

.detail-header {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 30px;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid #eee;
}

.detail-info h3 {
  margin: 0 0 10px 0;
  color: #333;
}

.detail-info p {
  margin: 5px 0;
  color: #666;
}

.detail-summary {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 15px;
}

.summary-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  background: #f8f9fa;
  border-radius: 8px;
}

.summary-label {
  font-size: 14px;
  color: #666;
}

.summary-value {
  font-weight: bold;
  font-size: 16px;
}

.questions-detail h4 {
  margin: 0 0 20px 0;
  color: #333;
}

.question-list {
  display: grid;
  gap: 20px;
}

.question-item {
  border: 1px solid #eee;
  border-radius: 10px;
  padding: 20px;
  transition: all 0.3s ease;
}

.question-item.correct {
  border-left: 4px solid #28a745;
  background: #f8fff9;
}

.question-item.wrong {
  border-left: 4px solid #dc3545;
  background: #fff8f8;
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.question-number {
  font-weight: bold;
  color: #333;
}

.question-type {
  background: #6a5acd;
  color: white;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
}

.question-score {
  font-weight: bold;
  font-size: 16px;
}

.question-score.correct {
  color: #28a745;
}

.question-score.wrong {
  color: #dc3545;
}

.question-content {
  line-height: 1.6;
}

.question-text {
  margin-bottom: 15px;
  color: #333;
}

.answer-section {
  display: grid;
  gap: 10px;
}

.user-answer, .correct-answer {
  padding: 10px;
  border-radius: 8px;
  font-size: 14px;
}

.user-answer {
  background: #e3f2fd;
  color: #1976d2;
}

.correct-answer {
  background: #e8f5e8;
  color: #2e7d32;
}

/* 选择题选项样式 */
.choice-question {
  margin-bottom: 20px;
}

.options-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 15px;
}

.option-item {
  display: flex;
  align-items: center;
  padding: 12px 15px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  background: #fafafa;
  transition: all 0.3s ease;
  position: relative;
}

.option-item:hover {
  border-color: #6a5acd;
  background: #f8f9ff;
}

.option-item.user-selected {
  border-color: #409eff;
  background: #e3f2fd;
}

.option-item.correct-option {
  border-color: #67c23a;
  background: #f0f9ff;
}

.option-item.wrong-selected {
  border-color: #f56c6c;
  background: #fef0f0;
}

.option-label {
  font-weight: bold;
  color: #6a5acd;
  margin-right: 10px;
  min-width: 20px;
}

.option-text {
  flex: 1;
  color: #333;
}

.selection-indicator {
  margin-left: 10px;
  font-weight: bold;
  font-size: 16px;
}

.option-item.user-selected .selection-indicator {
  color: #409eff;
}

.option-item.wrong-selected .selection-indicator {
  color: #f56c6c;
}

.option-item.correct-option .selection-indicator {
  color: #67c23a;
}

/* 方案A主内容横向布局样式 */
.main-content {
  display: flex;
  flex-direction: row;
  align-items: flex-start;
  justify-content: space-between;
  max-width: 1200px;
  margin: 0 auto;
  gap: 24px;
  width: 100%;
}
.history-list {
  flex: 2 1 0;
  max-width: 65%;
  /* 保持原有padding等 */
}
.weak-points-ranking {
  flex: 1 1 220px;
  min-width: 220px;
  max-width: 320px;
  margin: 0;
  margin-top: 0;
}
@media (max-width: 1000px) {
  .main-content {
    flex-direction: column;
    gap: 0;
  }
  .history-list, .weak-points-ranking {
    max-width: 100%;
    min-width: 0;
  }
  .weak-points-ranking {
    margin-top: 20px;
  }
}
</style> 