<template>
  <div class="ai-training-container">
    <!-- 顶部返回按钮 -->
    <div class="back-button">
      <button class="back-btn" @click="goback">
        ←
      </button>
    </div>

    <!-- 主内容区域 -->
    <div class="card">
      <!-- 标题栏 -->
      <div class="header">
        <div class="title-section">
          <div class="ai-icon">
            <div class="icon-container">
              <span class="icon-text">AI</span>
            </div>
          </div>
          <span class="title">AI自动出题</span>
        </div>
        <button class="start-button" @click="startTraining" :disabled="isLoading">
          <span v-if="isLoading" class="loading-spinner"></span>
          <i v-else class="pi pi-play" style="margin-right: 5px;"></i>
          {{ isLoading ? '生成中...' : '开始训练' }}
        </button>
      </div>

      <!-- 内容区域 -->
      <div class="content">
        <!-- 训练数量 - 使用Element Plus滑块 -->
        <div class="form-group">
          <div class="form-label">
            <span class="radio-dot"></span>
            <span>训练数量*</span>
          </div>
          <div class="slider-container">
            <el-slider 
              v-model="trainCount" 
              :min="0" 
              :max="15" 
              class="element-slider"
            />
            <div class="slider-values">
              <span>{{ trainCount }}</span>
              <span>15</span>
            </div>
          </div>
        </div>

        <!-- 题型选择 -->
        <div class="form-group">
          <div class="form-label">
            <span class="radio-dot"></span>
            <span>题型选择*（多选）</span>
          </div>
          <div class="question-types">
            <div 
              class="type-item single-select" 
              :class="{ active: selectedTypes.includes('single') }"
              @click="toggleType('single')"
            >
              <div class="type-icon single-icon"></div>
              <span>单选题</span>
            </div>
            <div 
              class="type-item multi-select" 
              :class="{ active: selectedTypes.includes('multi') }"
              @click="toggleType('multi')"
            >
              <div class="type-icon multi-icon"></div>
              <span>简答题</span>
            </div>
            <div 
              class="type-item judge" 
              :class="{ active: selectedTypes.includes('judge') }"
              @click="toggleType('judge')"
            >
              <div class="type-icon judge-icon"></div>
              <span>编程题</span>
            </div>
           
          </div>
        </div>

        <!-- 训练内容 -->
        <div class="form-group">
          <div class="form-label">
            <span class="radio-dot"></span>
            <span>训练内容：</span>
          </div>
          <div class="content-value">{{ courseName }}</div>
        </div>

        <!-- 知识模块 -->
        <div class="knowledge-section">
          <div class="knowledge-title">知识模块：{{ selectedChapter }}</div>
          <div class="knowledge-content">
            <div v-for="(chapter, index) in chapterKnowledgeMap" :key="index" class="chapter-group">
              <div class="chapter-name">{{ chapter.chapter }}</div>
              <div class="chapter-points">{{ chapter.points.join('；') }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 自定义弹窗 -->
    <div v-if="showModal" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <div class="modal-icon">
            <span v-if="modalType === 'error'" class="error-icon">⚠️</span>
            <span v-else-if="modalType === 'success'" class="success-icon">✅</span>
            <span v-else class="info-icon">ℹ️</span>
          </div>
          <h3 class="modal-title">{{ modalTitle }}</h3>
        </div>
        <div class="modal-body">
          <p>{{ modalMessage }}</p>
        </div>
        <div class="modal-footer">
          <button class="modal-btn confirm-btn" @click="closeModal">确定</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { ElSlider } from 'element-plus';
import { useRouter } from 'vue-router';
import { useRoute } from "vue-router";
import axios from 'axios'; // 需要导入axios
import { useAiPracticeStore } from '../../store/aiPractice'
import { useUserStore } from '@/store/user.js'
const route = useRoute();
const router = useRouter();
const aiPracticeStore = useAiPracticeStore()
// 训练数量
const trainCount = ref(0);
// 题型选择
const selectedTypes = ref([]);
// 加载状态
const isLoading = ref(false);
// 弹窗状态
const showModal = ref(false);
const modalTitle = ref('');
const modalMessage = ref('');
const modalType = ref('info'); // 'info', 'error', 'success'
// 从路由参数获取数据
const courseId = route.query.courseId; // 获取课程编号
const knowledgeNames = route.query.knowledgeNames
  ? route.query.knowledgeNames.split(",") // 将字符串转回数组
  : [];

console.log("课程编号:", courseId);
console.log("知识点名称:", knowledgeNames);

// 显示用的数据
const courseName = ref('嵌入式进阶'); // 课程名称
const selectedChapter = ref('绪论'); // 选中的章节
const selectedKnowledgePoints = ref('数据库系统概述；数据模型；数据库系统的结构；数据库系统的组成；'); // 选中的知识点
const chapterKnowledgeMap = ref([]); // 按章节分组的知识点映射

// 开始训练方法
const startTraining = async () => {
  // 表单验证
  if (trainCount.value <= 0) {
    showCustomModal("提示", "请输入有效的训练数量", "error");
    return;
  }
  
  if (selectedTypes.value.length === 0) {
    showCustomModal("提示", "请至少选择一种题型", "error");
    return;
  }

  // 设置加载状态
  isLoading.value = true;

  try {
    const requestDto = {
      studentId: useUserStore().currentUserId,
      courseId: Number(courseId),
      questionType: convertTypesToApiFormat(selectedTypes.value),
      knowledgePoint: knowledgeNames.join("、"),
      count: trainCount.value
    }

    console.log("请求数据:", requestDto)

    const response = await axios.post('/api/xiaozhi/student/generate', requestDto)
    
    if (response.data.code === 200) {
      const questions = response.data.data
      // 存储到store
      aiPracticeStore.setGeneratedQuestions(questions)
      
      // 跳转时不带任何题目参数
      router.push('/ai_practice_3')
    } else {
      showCustomModal("生成失败", "生成题目失败: " + response.data.message, "error")
    }
  } catch (error) {
    console.error("调用接口出错:", error)
    showCustomModal("网络错误", "网络错误，请稍后重试", "error")
  } finally {
    // 无论成功还是失败，都要重置加载状态
    isLoading.value = false;
  }
};

// 将前端选择的题型转换为后端需要的格式
const convertTypesToApiFormat = (types) => {
  const typeMap = {
    'single': 'choice',      // 单选题 -> choice
    'multi': 'short_answer', // 简答题 -> short_answer
    'judge': 'programming'   // 编程题 -> programming
  };
  
  return types.map(type => typeMap[type]).join(";"); // 用分号分隔多个题型
};

const goback = () => {
  router.push('/ai_practice');
};

const toggleType = (type) => {
  if (selectedTypes.value.includes(type)) {
    selectedTypes.value = selectedTypes.value.filter(t => t !== type);
  } else {
    selectedTypes.value.push(type);
  }
};

// 显示弹窗
const showCustomModal = (title, message, type = 'info') => {
  modalTitle.value = title;
  modalMessage.value = message;
  modalType.value = type;
  showModal.value = true;
};

// 关闭弹窗
const closeModal = () => {
  showModal.value = false;
};

// 处理路由参数，提取章节和知识点信息
const processRouteParams = () => {
  // 设置课程名称
  if (courseId) {
    courseName.value = '嵌入式进阶'; // 这里可以根据courseId动态获取课程名称
  }
  
  // 处理知识点名称，按章节分组
  if (knowledgeNames && knowledgeNames.length > 0) {
    // 按章节分组知识点
    const chapterGroups = {};
    
         knowledgeNames.forEach(name => {
       let chapterName = '';
       let knowledgePoint = '';
       
       // 检查是否包含章节分隔符
       if (name.includes('/')) {
         // 使用 "/" 作为分隔符
         const parts = name.split('/');
         chapterName = parts[0];
         knowledgePoint = parts.length > 1 ? parts[1] : name;
         
         // 特殊处理：如果章节名和知识点名相同，说明选择的是章节节点
         if (chapterName === knowledgePoint) {
           knowledgePoint = '整个章节';
         }
       } else if (name.includes('：') || name.includes(':')) {
         // 使用 "：" 或 ":" 作为分隔符
         const separator = name.includes('：') ? '：' : ':';
         const parts = name.split(separator);
         chapterName = parts[0];
         knowledgePoint = parts.length > 1 ? parts[1] : name;
         
         // 特殊处理：如果章节名和知识点名相同，说明选择的是章节节点
         if (chapterName === knowledgePoint) {
           knowledgePoint = '整个章节';
         }
       } else {
         // 没有章节分隔符，使用默认章节
         chapterName = '综合知识点';
         knowledgePoint = name;
       }
       
       // 按章节分组
       if (!chapterGroups[chapterName]) {
         chapterGroups[chapterName] = [];
       }
       chapterGroups[chapterName].push(knowledgePoint);
     });
    
    // 转换为数组格式
    const chapterArray = Object.keys(chapterGroups).map(chapter => ({
      chapter: chapter,
      points: chapterGroups[chapter]
    }));
    
    // 设置显示内容
    chapterKnowledgeMap.value = chapterArray;
    
    // 如果有多个章节，显示"多章节"
    if (chapterArray.length > 1) {
      selectedChapter.value = '多章节';
      selectedKnowledgePoints.value = chapterArray.map(ch => 
        `${ch.chapter}：${ch.points.join('、')}`
      ).join('；');
    } else {
      // 单个章节
      selectedChapter.value = chapterArray[0].chapter;
      selectedKnowledgePoints.value = chapterArray[0].points.join('；');
    }
    
  } else {
    // 没有选择知识点时的默认显示
    selectedChapter.value = '未选择章节';
    selectedKnowledgePoints.value = '请返回选择知识点';
    chapterKnowledgeMap.value = [];
  }
};

// 组件挂载时处理路由参数
onMounted(() => {
  processRouteParams();
  console.log('处理后的显示数据:', {
    courseName: courseName.value,
    selectedChapter: selectedChapter.value,
    selectedKnowledgePoints: selectedKnowledgePoints.value,
    chapterKnowledgeMap: chapterKnowledgeMap.value
  });
  console.log('原始路由参数:', {
    courseId: courseId,
    knowledgeNames: knowledgeNames
  });
});
</script>


<style scoped>
.ai-training-container {
  width: 50%;
  height: 700px;
  display: flex;
  padding: 20px;
  margin: 0 auto;
    background: url('../../assets/images/people.gif') no-repeat center center fixed; /* 替换为你的GIF路径 */
  background-size: cover; /* 确保GIF覆盖整个容器 */
}

.back-button {
  position: absolute;
  top: 20px;
  left: 20px;
  z-index: 10;
}

/* 弹窗样式 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: fadeIn 0.3s ease;
}

.modal-content {
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  max-width: 400px;
  width: 90%;
  animation: slideIn 0.3s ease;
}

.modal-header {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 20px 20px 0 20px;
}

.modal-icon {
  font-size: 24px;
  flex-shrink: 0;
}

.error-icon {
  color: #f44336;
}

.success-icon {
  color: #4caf50;
}

.info-icon {
  color: #2196f3;
}

.modal-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #333;
}

.modal-body {
  padding: 16px 20px;
}

.modal-body p {
  margin: 0;
  font-size: 14px;
  color: #666;
  line-height: 1.5;
}

.modal-footer {
  padding: 0 20px 20px 20px;
  display: flex;
  justify-content: flex-end;
}

.modal-btn {
  padding: 8px 20px;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
}

.confirm-btn {
  background-color: #5c5cff;
  color: white;
}

.confirm-btn:hover {
  background-color: #4a4acc;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slideIn {
  from { 
    opacity: 0;
    transform: translateY(-20px) scale(0.95);
  }
  to { 
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.back-btn {
  background-color: transparent;
  border: none;
  cursor: pointer;
  color: #333;
  font-size: 1.5rem;
  padding: 5px;
  border-radius: 50%;
  transition: all 0.3s;
}

.back-btn:hover {
  background-color: rgba(0, 0, 0, 0.1);
}

.card {
  width: 700px;
  background-color: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
  padding: 24px;
  display: flex;
  flex-direction: column;
  margin: 0 auto;
  opacity: 0.8; /* 0~1 之间的值，0 完全透明，1 完全不透明 */
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.title-section {
  display: flex;
  align-items: center;
  gap: 10px;
}

.ai-icon {
  width: 30px;
  height: 30px;
  background-color: #ff9999;
  border-radius: 6px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.icon-container {
  color: white;
  font-size: 14px;
  font-weight: bold;
}

.title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
}

.start-button {
  background-color: #5c5cff;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  display: flex;
  align-items: center;
  transition: all 0.3s;
}

.start-button:hover {
  background-color: #4a4acc;
}

.start-button:disabled {
  background-color: #cccccc;
  cursor: not-allowed;
  opacity: 0.7;
}

.start-button:disabled:hover {
  background-color: #cccccc;
}

/* 加载动画样式 */
.loading-spinner {
  display: inline-block;
  width: 16px;
  height: 16px;
  border: 2px solid #ffffff;
  border-radius: 50%;
  border-top-color: transparent;
  animation: spin 1s ease-in-out infinite;
  margin-right: 8px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-label {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #666;
  font-size: 14px;
}

.radio-dot {
  width: 8px;
  height: 8px;
  background-color: #5c5cff;
  border-radius: 50%;
}

.slider-container {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.slider {
  width: 100%;
  height: 6px;
}

.slider-values {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #999;
}

.question-types {
  display: flex;
  justify-content: space-between;
  gap: 10px;
}

.type-item {
  flex: 1;
  border-radius: 8px;
  padding: 16px 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.type-item:hover {
  opacity: 0.9;
}

.type-item.active {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.type-icon {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  margin-bottom: 4px;
}

.single-icon {
  background-color: #f0e6ff;
}

.multi-icon {
  background-color: #e6f2ff;
}

.judge-icon {
  background-color: #ffe6e6;
}

.fill-icon {
  background-color: #e6fff0;
}

.content-value {
  font-size: 15px;
  color: #333;
  font-weight: 500;
  padding: 8px 12px;
  background: rgba(102, 126, 234, 0.1);
  border-radius: 8px;
  border-left: 3px solid #667eea;
}

.knowledge-section {
  margin-top: 15px;
  padding: 15px;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 10px;
  border: 1px solid rgba(102, 126, 234, 0.2);
}

.knowledge-title {
  font-size: 15px;
  color: #333;
  margin-bottom: 10px;
  font-weight: 600;
}

.knowledge-content {
  font-size: 14px;
  color: #666;
  line-height: 1.6;
  padding: 8px 0;
}

.chapter-group {
  margin-bottom: 12px;
  padding: 8px 12px;
  background: rgba(255, 255, 255, 0.6);
  border-radius: 8px;
  border-left: 3px solid #667eea;
}

.chapter-group:last-child {
  margin-bottom: 0;
}

.chapter-name {
  font-weight: 600;
  color: #333;
  font-size: 13px;
  margin-bottom: 4px;
}

.chapter-points {
  color: #666;
  font-size: 12px;
  line-height: 1.5;
}
/* 原有样式保持不变，新增原生滑块样式 */
.slider {
  width: 100%;
  height: 6px;
  -webkit-appearance: none; /* 移除默认样式（针对部分浏览器） */
  background: #e0e0e0;
  border-radius: 3px;
  outline: none;
}

.slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 16px;
  height: 16px;
  background: #5c5cff;
  border-radius: 50%;
  cursor: pointer;
}

.slider::-moz-range-thumb {
  width: 16px;
  height: 16px;
  background: #5c5cff;
  border-radius: 50%;
  cursor: pointer;
}
/* 原有样式保持不变 */
.thick-slider {
  width: 100%;
  height: 12px; /* 增加滑块高度使其变粗 */
  -webkit-appearance: none; /* 移除默认样式（针对部分浏览器） */
  background: linear-gradient(to right, #007bff, #00c8ff); /* 设置滑块轨道的渐变颜色 */
  border-radius: 6px; /* 使轨道边缘更圆润 */
  outline: none;
}

.thick-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 20px; /* 增加滑块宽度使其变粗 */
  height: 20px; /* 增加滑块高度使其变粗 */
  background: #5c5cff; /* 设置滑块的默认颜色 */
  border-radius: 50%;
  cursor: pointer;
  transition: background 0.3s; /* 添加颜色过渡效果 */
}

.thick-slider::-webkit-slider-thumb:hover {
  background: #3333ff; /* 鼠标悬停时改变滑块颜色 */
}

.thick-slider::-moz-range-thumb {
  width: 20px;
  height: 20px;
  background: #5c5cff;
  border-radius: 50%;
  cursor: pointer;
  transition: background 0.3s;
}

.thick-slider::-moz-range-thumb:hover {
  background: #3333ff;
}
/* 自定义滑块样式 */
.custom-slider {
  position: relative;
  width: 100%;
  height: 30px; /* 整体高度 */
}

.slider-track {
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  height: 8px;
  background-color: white;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  transform: translateY(-50%);
}

.slider-progress {
  position: absolute;
  top: 0;
  left: 0;
  height: 100%;
  background-color: #5c5cff;
  border-radius: 4px;
  transition: width 0.1s ease;
}

.native-slider {
  position: absolute;
  top: 50%;
  left: 0;
  width: 100%;
  height: 0; /* 隐藏原生滑块轨道 */
  -webkit-appearance: none;
  background: transparent;
  outline: none;
  margin: 0;
  transform: translateY(-50%);
  z-index: 2;
}

/* Webkit浏览器(Chrome, Safari)的滑块样式 */
.native-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 20px;
  height: 20px;
  background: #5c5cff;
  border-radius: 50%;
  cursor: pointer;
  border: none;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

/* Firefox的滑块样式 */
.native-slider::-moz-range-thumb {
  width: 20px;
  height: 20px;
  background: #5c5cff;
  border-radius: 50%;
  cursor: pointer;
  border: none;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

/* Webkit浏览器(Chrome, Safari)的轨道样式 - 完全隐藏 */
.native-slider::-webkit-slider-runnable-track {
  height: 0;
  background: transparent;
  border: none;
}

/* Firefox的轨道样式 - 完全隐藏 */
.native-slider::-moz-range-track {
  height: 0;
  background: transparent;
  border: none;
}
.element-slider {
  width: 100%;
  margin-top: 10px;
}

/* 自定义滑块轨道和手柄颜色 */
:deep(.el-slider__runway) {
  background-color: white;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
}

:deep(.el-slider__bar) {
  background-color: #5c5cff;
  border-radius: 4px;
}

:deep(.el-slider__button) {
  width: 20px;
  height: 20px;
  background-color: #5c5cff;
  border: none;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

:deep(.el-slider__button:hover) {
  background-color: #3333ff;
}
.ai-training-container{
  width: 1650px; /* 设置宽度为视口宽度 */
  height: 765px; /* 设置高度为视口高度 */
  display: flex;
  padding: 20px;
  margin: 0 auto;
  background: url('../../assets/images/people.gif') no - repeat center center fixed;
  background-size: cover;
  position: relative; /* 确保子元素的定位相对于此容器 */
}

.back-button {
  position: absolute;
  top: 20px;
  left: 20px;
  z-index: 10;
}


</style>