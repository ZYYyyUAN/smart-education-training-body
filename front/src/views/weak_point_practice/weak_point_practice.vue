<template>
  <div class="weak-practice-container">
    <!-- 顶部导航 -->
    <div class="top-bar">
      <div class="back-button" @click="goBack">
        <i class="icon-back">←</i>
      </div>
      <div class="title-container">
        <h1 class="title">训练薄弱题</h1>
      </div>
    </div>

    <!-- 欢迎区域（多选卡片） -->
    <div class="welcome-section" v-if="!showSelection">
      <div class="welcome-text">
        <span class="student-name">{{ studentName }}</span>同学，以下是你当前薄弱的知识点，想先练习哪些呢？
      </div>
      <div class="weak-points-grid">
        <div 
          v-for="point in weakPoints" 
          :key="point.knowledgePoint"
          class="weak-point-card"
          :class="{selected: selectedKnowledgePoints.includes(point)}"
          @click="toggleKnowledgePoint(point)"
        >
          <div class="point-name">{{ point.knowledgePoint }}</div>
          <div class="point-stats">
            <span class="error-count">错误: {{ point.wrongCount }}次</span>
            <span class="accuracy-rate">正确率: {{ point.accuracyRate }}%</span>
          </div>
          <div v-if="selectedKnowledgePoints.includes(point)" class="selected-mark">✔</div>
        </div>
      </div>
      <div class="multi-actions">
        <el-button type="primary" class="next-btn" :disabled="selectedKnowledgePoints.length===0" @click="showSelection=true">
          下一步
        </el-button>
      </div>
    </div>

    <!-- 题型和数量选择区域（美化） -->
    <div class="selection-section" v-if="showSelection && !showPractice">
      <div class="selection-text">
        <span class="magic-icon star">★</span>
        <span class="magic-title">告诉我你想练习的题目数量和题型</span>
        <span class="magic-icon star">★</span>
      </div>
      <div class="selection-form magic-card">
        <div class="form-group">
          <label>题型选择：</label>
          <div class="type-square-group">
            <div
              v-for="type in typeOptions"
              :key="type.value"
              :class="['type-square', {active: selectedType===type.value}]"
              @click="selectedType=type.value"
            >
              <span class="type-icon">{{ type.icon }}</span>
              <span class="type-label">{{ type.label }}</span>
            </div>
          </div>
        </div>
        <div class="form-group">
          <label>题目数量（1-15）：</label>
          <div class="slider-row">
            <el-slider v-model="selectedNum" :min="1" :max="15" :step="1" />
            <span class="slider-value">{{ selectedNum }}</span>
          </div>
        </div>
        <div class="form-actions">
          <el-button class="back-btn" @click="goBackToSelection">返回选择</el-button>
          <el-button type="primary" class="start-btn" @click="startPractice" :disabled="!selectedType || selectedNum < 1">
            <span class="btn-glow">开始练习</span>
          </el-button>
        </div>
      </div>
    </div>

    <!-- 练习区域 -->
    <div class="practice-section" v-if="showPractice">
      <div class="practice-header">
        <h3>正在练习：{{ selectedKnowledgePoint.knowledgePoint }}</h3>
        <div class="progress-info">
          第 {{ currentQuestionIndex + 1 }} 题 / 共 {{ questions.length }} 题
        </div>
      </div>
      
      <div class="question-container" v-if="currentQuestion">
        <div class="question-content">
          <h4>题目：</h4>
          <div v-html="currentQuestion.question"></div>
        </div>
        
        <div class="answer-section">
          <!-- 选择题 -->
          <div v-if="currentQuestion.type === 'choice'" class="choice-options">
            <h4>选项：</h4>
            <el-radio-group v-model="userAnswer">
              <el-radio 
                v-for="option in currentQuestion.options" 
                :key="option.key" 
                :label="option.key"
                class="option-item"
              >
                {{ option.key }}. {{ option.value }}
              </el-radio>
            </el-radio-group>
          </div>
          
          <!-- 简答题 -->
          <div v-else-if="currentQuestion.type === 'short_answer'" class="short-answer">
            <h4>答案：</h4>
            <el-input 
              v-model="userAnswer" 
              type="textarea" 
              :rows="4"
              placeholder="请输入你的答案..."
            />
          </div>
          
          <!-- 编程题 -->
          <div v-else-if="currentQuestion.type === 'programming'" class="programming">
            <h4>代码：</h4>
            <el-input 
              v-model="userAnswer" 
              type="textarea" 
              :rows="8"
              placeholder="请输入你的代码..."
            />
          </div>
        </div>
        
        <div class="question-actions">
          <el-button @click="previousQuestion" :disabled="currentQuestionIndex === 0">
            上一题
          </el-button>
          <el-button type="primary" @click="nextQuestion" :disabled="!userAnswer">
            {{ currentQuestionIndex === questions.length - 1 ? '完成练习' : '下一题' }}
          </el-button>
        </div>
      </div>
    </div>

    <!-- 魔法粒子背景 -->
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { ElMessage, ElRadioGroup, ElRadio, ElInputNumber, ElButton, ElInput } from 'element-plus';
import axios from 'axios';
import { useAiPracticeStore } from '../../store/aiPractice';
import { useUserStore } from '@/store/user.js'

const route = useRoute();
const router = useRouter();
const aiPracticeStore = useAiPracticeStore();

// 页面状态
const showSelection = ref(false);
const showPractice = ref(false);

// 数据
const studentName = ref('');
const courseId = ref('');
const courseName = ref('');
const weakPoints = ref([]);
const selectedKnowledgePoints = ref([]); // 多选
const selectedType = ref('choice');
const selectedNum = ref(5);
const questions = ref([]);
const currentQuestionIndex = ref(0);
const userAnswer = ref('');
const answers = ref([]);

const typeOptions = [
  { value: 'choice', label: '选择题', icon: '📝' },
  { value: 'short_answer', label: '简答题', icon: '💬' },
  { value: 'programming', label: '编程题', icon: '💻' }
];

// 计算当前题目
const currentQuestion = computed(() => {
  return questions.value[currentQuestionIndex.value] || null;
});

// 返回上一页
const goBack = () => {
  router.push('/ai_practice');
};

// 多选卡片切换
const toggleKnowledgePoint = (point) => {
  const idx = selectedKnowledgePoints.value.indexOf(point);
  if (idx === -1) {
    selectedKnowledgePoints.value.push(point);
  } else {
    selectedKnowledgePoints.value.splice(idx, 1);
  }
};

// 返回知识点选择
const goBackToSelection = () => {
  showSelection.value = false;
  // 不清空已选
};

// 开始练习（支持多知识点）
const startPractice = async () => {
  try {
    const knowledgeList = selectedKnowledgePoints.value.map(p => p.knowledgePoint);
    const requestBody = {
      courseId: courseId.value,
      knowledgePoint: knowledgeList.join(','),
      questionType: selectedType.value,
      count: selectedNum.value
    };
    const response = await axios.post('/api/xiaozhi/student/generate', requestBody);
    if (response.data.code === 200) {
      const generatedQuestions = response.data.data || [];
      if (generatedQuestions.length > 0) {
        // 清除全局状态中的题目，避免与AI自动出题的题目冲突
        aiPracticeStore.clearGeneratedQuestions();
        
        // 跳转到/ai_practice_3并传递题目数据
        router.push({
          path: '/ai_practice_3',
          query: {
            questions: encodeURIComponent(JSON.stringify(generatedQuestions)),
            fromWeakTrain: '1'
          }
        });
      } else {
        ElMessage.warning('未能生成相关题目，请稍后重试！');
      }
    } else {
      ElMessage.error('生成题目失败：' + response.data.message);
    }
  } catch (error) {
    console.error('生成题目失败', error);
    ElMessage.error('生成题目失败，请稍后重试！');
  }
};

// 上一题
const previousQuestion = () => {
  if (currentQuestionIndex.value > 0) {
    // 保存当前答案
    if (userAnswer.value) {
      answers.value[currentQuestionIndex.value] = userAnswer.value;
    }
    
    currentQuestionIndex.value--;
    userAnswer.value = answers.value[currentQuestionIndex.value] || '';
  }
};

// 下一题
const nextQuestion = () => {
  // 保存当前答案
  if (userAnswer.value) {
    answers.value[currentQuestionIndex.value] = userAnswer.value;
  }
  
  if (currentQuestionIndex.value < questions.value.length - 1) {
    currentQuestionIndex.value++;
    userAnswer.value = answers.value[currentQuestionIndex.value] || '';
  } else {
    // 完成练习，保存记录
    savePracticeRecord();
  }
};

// 保存练习记录
const savePracticeRecord = async () => {
  try {
    const practiceData = {
      studentId: useUserStore().currentUserId, // TODO: 从用户信息获取
      courseId: courseId.value,
      practiceType: '训练薄弱题',
      questionDetails: questions.value.map((question, index) => ({
        questionContent: question.question,
        questionType: question.type,
        userAnswer: answers.value[index] || '',
        correctAnswer: question.answer || '',
        knowledgePoint: selectedKnowledgePoints.value.map(p => p.knowledgePoint).join(','), // 多个知识点
        score: 0, // TODO: 根据答案正确性计算分数
        isCorrect: false // TODO: 根据答案正确性设置
      }))
    };
    
    const response = await axios.post('/api/xiaozhi/student/savePracticeRecord', practiceData);
    
    if (response.data.code === 200) {
      ElMessage.success('练习完成！');
      // 跳转到历史记录页面
      router.push('/practice_history');
    } else {
      ElMessage.error('保存练习记录失败：' + response.data.message);
    }
  } catch (error) {
    console.error('保存练习记录失败', error);
    ElMessage.error('保存练习记录失败，请稍后重试！');
  }
};

// 初始化页面数据
onMounted(() => {
  const query = route.query;
  studentName.value = query.studentName || '同学';
  courseId.value = query.courseId;
  courseName.value = query.courseName;
  
  try {
    weakPoints.value = JSON.parse(query.weakPoints || '[]');
  } catch (error) {
    console.error('解析薄弱知识点数据失败', error);
    weakPoints.value = [];
  }
});
</script>

<style scoped>
.weak-practice-container {
  min-height: 100vh;
  background: url('@/assets/images/people.gif') center center/cover no-repeat;
  position: relative;
  overflow: hidden;
}

.magic-particles {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  background-image: 
    radial-gradient(circle at 20% 80%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
    radial-gradient(circle at 80% 20%, rgba(255, 119, 198, 0.3) 0%, transparent 50%),
    radial-gradient(circle at 40% 40%, rgba(120, 219, 255, 0.3) 0%, transparent 50%);
  animation: float 6s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-20px) rotate(180deg); }
}

.top-bar {
  display: flex;
  align-items: center;
  padding: 20px 30px;
  position: relative;
  z-index: 10;
}

.back-button {
  cursor: pointer;
  font-size: 24px;
  color: #222;
  margin-right: 20px;
}

.title {
  font-size: 32px;
  font-weight: bold;
  color: #222;
  text-shadow: none;
}

.welcome-section, .selection-section, .practice-section {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
  position: relative;
  z-index: 10;
}

.welcome-text {
  font-size: 24px;
  color: #222;
  text-align: center;
  margin-bottom: 40px;
  text-shadow: 1px 1px 2px #fff8, 0 0 2px #0002;
}

.student-name {
  color: #ffd700;
  font-weight: bold;
}

.weak-points-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
  margin-top: 30px;
}

.weak-point-card {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 15px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.weak-point-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.2);
  background: rgba(255, 255, 255, 1);
}

.weak-point-card.selected {
  border: 2px solid #6a5acd;
  box-shadow: 0 0 12px #6a5acd66;
  position: relative;
}
.selected-mark {
  position: absolute;
  top: 10px;
  right: 18px;
  color: #6a5acd;
  font-size: 22px;
  font-weight: bold;
}
.multi-actions {
  text-align: center;
  margin-top: 30px;
}
.next-btn {
  font-size: 18px;
  padding: 10px 40px;
  border-radius: 30px;
  background: linear-gradient(90deg, #6a5acd 0%, #8f6ed5 100%);
  color: #fff;
  box-shadow: 0 4px 16px #6a5acd33;
  transition: all 0.2s;
}
.next-btn:active {
  background: linear-gradient(90deg, #8f6ed5 0%, #6a5acd 100%);
}
.magic-gradient-text {
  background: linear-gradient(90deg, #ffd700, #1a73e8, #00c3ff);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  font-size: 26px;
  font-weight: bold;
  text-align: center;
  margin-bottom: 30px;
  letter-spacing: 2px;
  animation: rainbow 3s linear infinite;
  display: flex;
  align-items: center;
  justify-content: center;
}
.magic-title {
  font-size: 32px;
  font-weight: 900;
  color: #222;
  letter-spacing: 2px;
  margin: 0 12px;
  background: none;
  -webkit-background-clip: unset;
  -webkit-text-fill-color: unset;
}
.magic-icon {
  font-size: 28px;
  margin: 0 8px;
  vertical-align: middle;
  animation: twinkle 1.5s infinite alternate;
}
.magic-icon.star {
  color: #ffd700;
  font-size: 36px;
  margin: 0 12px;
  vertical-align: middle;
  /* 去掉text-shadow，保证清晰 */
  filter: none;
  text-shadow: none;
  animation: none;
}
@keyframes twinkle {
  0% { opacity: 1; transform: scale(1); }
  100% { opacity: 0.7; transform: scale(1.2); }
}
.magic-card {
  background: linear-gradient(135deg, #f0f5ff 0%, #e6eeff 100%);
  border-radius: 20px;
  box-shadow: 0 8px 32px #6a5acd22;
  padding: 40px 30px 30px 30px;
  max-width: 520px;
  margin: 0 auto;
  position: relative;
}
.type-radio-group {
  display: flex;
  gap: 30px;
  margin-bottom: 10px;
}
.start-btn {
  font-size: 18px;
  padding: 10px 40px;
  border-radius: 30px;
  background: linear-gradient(90deg, #6a5acd 0%, #00c3ff 100%);
  color: #fff;
  box-shadow: 0 4px 16px #00c3ff33;
  transition: all 0.2s;
  position: relative;
  overflow: hidden;
}
.start-btn .btn-glow {
  position: relative;
  z-index: 2;
}
.start-btn:active {
  background: linear-gradient(90deg, #00c3ff 0%, #6a5acd 100%);
}
.start-btn::after {
  content: '';
  position: absolute;
  left: 0; top: 0; right: 0; bottom: 0;
  background: radial-gradient(circle, #fff6 0%, transparent 70%);
  opacity: 0.5;
  pointer-events: none;
  z-index: 1;
}
.back-btn {
  border-radius: 30px;
  padding: 10px 30px;
  background: #fff;
  color: #6a5acd;
  border: 1px solid #6a5acd;
  transition: all 0.2s;
}
.back-btn:active {
  background: #f0f5ff;
}

.point-name {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 10px;
}

.point-stats {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
}

.error-count {
  color: #ff4757;
}

.accuracy-rate {
  color: #2ed573;
}

.selection-text {
  font-size: 26px;
  font-weight: bold;
  text-align: center;
  margin-bottom: 30px;
  letter-spacing: 2px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #222;
}

.selection-form {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 15px;
  padding: 30px;
  max-width: 500px;
  margin: 0 auto;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 10px;
  font-weight: bold;
  color: #333;
}

.form-actions {
  display: flex;
  justify-content: space-between;
  margin-top: 30px;
}

.practice-header {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 15px;
  padding: 20px;
  margin-bottom: 20px;
  text-align: center;
}

.practice-header h3 {
  color: #333;
  margin-bottom: 10px;
}

.progress-info {
  color: #666;
  font-size: 14px;
}

.question-container {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 15px;
  padding: 30px;
  margin-bottom: 20px;
}

.question-content {
  margin-bottom: 30px;
}

.question-content h4 {
  color: #333;
  margin-bottom: 15px;
}

.answer-section {
  margin-bottom: 30px;
}

.choice-options .option-item {
  display: block;
  margin-bottom: 10px;
  padding: 10px;
  border-radius: 8px;
  transition: background-color 0.3s;
}

.choice-options .option-item:hover {
  background-color: #f5f5f5;
}

.question-actions {
  display: flex;
  justify-content: space-between;
}

.type-square-group {
  display: flex;
  gap: 24px;
  margin: 18px 0 10px 0;
}
.type-square {
  width: 90px;
  height: 90px;
  background: linear-gradient(135deg, #e6eeff 60%, #fff 100%);
  border-radius: 16px;
  box-shadow: 0 2px 12px #6a5acd22;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  border: 2px solid transparent;
  transition: all 0.2s;
  font-size: 18px;
  position: relative;
}
.type-square.active {
  border: 2.5px solid #1a73e8;
  background: linear-gradient(135deg, #fffbe6 60%, #e6eeff 100%);
  box-shadow: 0 0 16px #1a73e855;
}
.type-square .type-icon {
  font-size: 32px;
  margin-bottom: 8px;
}
.type-square .type-label {
  font-size: 16px;
  color: #333;
}
.slider-row {
  display: flex;
  align-items: center;
  gap: 18px;
  margin-top: 10px;
}
.slider-value {
  font-size: 20px;
  color: #1a73e8;
  font-weight: bold;
  min-width: 32px;
  text-align: center;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .weak-points-grid {
    grid-template-columns: 1fr;
  }
  
  .welcome-text {
    font-size: 20px;
  }
  
  .selection-form {
    margin: 0 20px;
  }
}
</style>
