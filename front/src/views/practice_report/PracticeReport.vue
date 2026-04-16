<template>
  <div class="report-container">
    <header class="header">
      <button class="back-btn" @click="goBack">←</button>
      <h1 class="title">练习报告</h1>
    </header>

    <div class="score-section">
      <div class="score-circle">
        <div class="circle-progress">
          <div class="circle-fill" :style="{ transform: `rotate(${scoreAngle}deg)` }"></div>
          <div class="circle-content">
            <div class="score-text">{{ averageScore }}%</div>
            <div class="score-label">正确率</div>
          </div>
        </div>
      </div>
      
      <div class="score-details">
        <div class="detail-item correct">
          <span class="detail-text">答对 {{ correctCount }}</span>
          <span class="detail-icon">✓</span>
        </div>
        <div class="detail-item wrong">
          <span class="detail-text">答错 {{ wrongCount }}</span>
          <span class="detail-icon">✗</span>
        </div>
        <div class="detail-item unanswered">
          <span class="detail-text">未做 {{ unansweredCount }}</span>
          <span class="detail-icon">○</span>
        </div>
      </div>
    </div>

    <div class="question-grid-section">
      <h3 class="section-title">题目状态</h3>
      <div class="question-grid">
        <div 
          v-for="(status, index) in questionStatuses" 
          :key="index"
          class="question-square"
          :class="getQuestionClass(status)"
        >
          {{ index + 1 }}
        </div>
      </div>
    </div>

    <div class="action-buttons">
      <button class="retry-btn" @click="retryPractice">重新练习</button>
      <button class="home-btn" @click="goHome">返回首页</button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';

const router = useRouter();
const route = useRoute();

const averageScore = ref(0);
const correctCount = ref(0);
const wrongCount = ref(0);
const unansweredCount = ref(0);
const questionStatuses = ref([]);

const scoreAngle = computed(() => {
  return (averageScore.value / 100) * 360;
});

const getQuestionClass = (status) => {
  switch (status) {
    case 'correct':
      return 'correct-square';
    case 'wrong':
      return 'wrong-square';
    case 'unanswered':
      return 'unanswered-square';
    default:
      return '';
  }
};

const goBack = () => {
  // 返回到历史练习页面，并添加刷新参数
  router.push({
    path: '/practice_history',
    query: { refresh: 'true' }
  });
};

const retryPractice = () => {
  router.push('/ai_practice_3');
};

const goHome = () => {
  router.push('/ai_practice');
};

onMounted(() => {
  const params = route.query;
  
  if (params.averageScore) {
    averageScore.value = parseFloat(params.averageScore);
  }
  
  if (params.correctCount) {
    correctCount.value = parseInt(params.correctCount);
  }
  
  if (params.wrongCount) {
    wrongCount.value = parseInt(params.wrongCount);
  }
  
  if (params.unansweredCount) {
    unansweredCount.value = parseInt(params.unansweredCount);
  }
  
  if (params.questionStatuses) {
    try {
      questionStatuses.value = JSON.parse(decodeURIComponent(params.questionStatuses));
    } catch (e) {
      console.error('解析题目状态失败:', e);
      const totalQuestions = correctCount.value + wrongCount.value + unansweredCount.value;
      questionStatuses.value = Array(totalQuestions).fill('unanswered');
    }
  } else {
    const totalQuestions = correctCount.value + wrongCount.value + unansweredCount.value;
    questionStatuses.value = [];
    
    for (let i = 0; i < correctCount.value; i++) {
      questionStatuses.value.push('correct');
    }
    
    for (let i = 0; i < wrongCount.value; i++) {
      questionStatuses.value.push('wrong');
    }
    
    for (let i = 0; i < unansweredCount.value; i++) {
      questionStatuses.value.push('unanswered');
    }
  }
});
</script>

<style scoped>
.report-container {
  min-height: 100vh;
  background: url('../../assets/images/people.gif') no-repeat center center fixed;
  background-size: cover;
  font-family: 'Arial', sans-serif;
  padding: 0;
}

.header {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  height: 80px;
  background: rgba(76, 144, 226, 0.7);
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  margin-bottom: 40px;
}

.back-btn {
  position: absolute;
  left: 30px;
  top: 24px;
  background: none;
  border: none;
  font-size: 30px;
  cursor: pointer;
  color: #fff;
}

.title {
  color: #fff;
  font-size: 32px;
  font-weight: bold;
  letter-spacing: 2px;
  margin: 0 auto;
}

.score-section {
  display: flex;
  justify-content: center;
  align-items: center;
  background: rgba(255,255,255,0.95);
  border-radius: 30px;
  padding: 40px 60px;
  margin: 0 auto 40px auto;
  max-width: 700px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.12);
}

.score-circle {
  flex: 0 0 240px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.circle-progress {
  position: relative;
  width: 220px;
  height: 220px;
  border-radius: 50%;
  background: #e3eaf7;
  box-shadow: 0 4px 24px rgba(76,144,226,0.12);
  display: flex;
  align-items: center;
  justify-content: center;
}

.circle-fill {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  z-index: 1;
  background: conic-gradient(
    #4a90e2 0deg,
    #4a90e2 calc(v-bind(averageScore) * 3.6deg),
    #e3eaf7 calc(v-bind(averageScore) * 3.6deg),
    #e3eaf7 360deg
  );
}

.circle-content {
  position: relative;
  z-index: 2;
  text-align: center;
  width: 100%;
}

.score-text {
  font-size: 54px;
  font-weight: bold;
  color: #fff;
  margin-bottom: 8px;
  text-shadow: 0 2px 8px rgba(76,144,226,0.25);
}

.score-label {
  font-size: 22px;
  color: #fff;
  text-shadow: 0 2px 8px rgba(76,144,226,0.25);
}

.score-details {
  flex: 1;
  margin-left: 60px;
}

.detail-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 18px 0;
  border-bottom: 1px solid #f0f0f0;
}

.detail-item:last-child {
  border-bottom: none;
}

.detail-text {
  font-size: 20px;
  color: #333;
}

.detail-icon {
  font-size: 26px;
  font-weight: bold;
}

.correct .detail-icon { color: #4CAF50; }
.wrong .detail-icon { color: #f44336; }
.unanswered .detail-icon { color: #9e9e9e; }

.question-grid-section {
  background: rgba(255,255,255,0.95);
  border-radius: 20px;
  padding: 30px;
  margin: 0 auto 30px auto;
  max-width: 700px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.10);
  opacity: 0.95;
}

.section-title {
  font-size: 22px;
  color: #333;
  margin-bottom: 20px;
  text-align: center;
  font-weight: bold;
}

.question-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 16px;
  max-width: 420px;
  margin: 0 auto;
  padding: 20px;
}

.question-square {
  width: 54px;
  height: 54px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  font-weight: bold;
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
}

.correct-square { background: linear-gradient(135deg, #4CAF50, #45a049); }
.wrong-square { background: linear-gradient(135deg, #f44336, #d32f2f); }
.unanswered-square { background: linear-gradient(135deg, #9e9e9e, #757575); }

.question-square:hover {
  transform: scale(1.08);
  box-shadow: 0 5px 15px rgba(0,0,0,0.18);
}

.action-buttons {
  display: flex;
  justify-content: center;
  gap: 30px;
  margin-top: 40px;
  opacity: 0.95;
}

.retry-btn, .home-btn {
  padding: 18px 38px;
  border: none;
  border-radius: 25px;
  font-size: 20px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 5px 15px rgba(0,0,0,0.10);
}

.retry-btn {
  background: linear-gradient(135deg, #4CAF50, #45a049);
  color: white;
}

.home-btn {
  background: linear-gradient(135deg, #2196F3, #1976D2);
  color: white;
}

.retry-btn:hover, .home-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(0,0,0,0.18);
}
</style>