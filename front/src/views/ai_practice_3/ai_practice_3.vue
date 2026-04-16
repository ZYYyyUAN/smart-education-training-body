<template>
  <div class="app-container">
    <div class="quiz-container"> 
      <!-- 现代化头部 -->
      <header class="modern-header">
        <div class="header-background">
          <div class="floating-icons">
            <div class="icon-float icon-1">🧠</div>
            <div class="icon-float icon-2">💡</div>
            <div class="icon-float icon-3">🎯</div>
            <div class="icon-float icon-4">⭐</div>
            <div class="icon-float icon-5">🚀</div>
          </div>
        </div>
        
        <div class="header-content">
          <div class="header-left">
            <button class="modern-back-btn" @click="goBack">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="m15 18-6-6 6-6"/>
              </svg>
            </button>
          </div>
          
          <div class="title-section">
            <div class="main-title">
              <span class="title-gradient">智能练习</span>
              <div class="title-decoration">
                <div class="decoration-line"></div>
                <div class="decoration-dot"></div>
                <div class="decoration-line"></div>
              </div>
            </div>
            <div class="subtitle">挑战自我，提升技能</div>
          </div>
          
          <div class="header-right">
            <div class="header-stats">
              <div class="stat-item">
                <div class="stat-icon">📊</div>
                <div class="stat-info">
                  <div class="stat-label">进度</div>
                  <div class="stat-value">{{ Math.round(progress) }}%</div>
                </div>
              </div>
              <div class="stat-item">
                <div class="stat-icon">🎲</div>
                <div class="stat-info">
                  <div class="stat-label">题目</div>
                  <div class="stat-value">{{ currentQuestionIndex + 1 }}/{{ questions.length }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 现代化进度条 -->
        <div class="modern-progress-container">
          <div class="progress-track">
            <div class="progress-fill" :style="{ width: progress + '%' }">
              <div class="progress-glow"></div>
            </div>
            <div class="progress-markers">
              <div 
                v-for="(question, index) in questions" 
                :key="index"
                class="progress-marker"
                :class="{ 
                  'completed': index < currentQuestionIndex,
                  'current': index === currentQuestionIndex,
                  'upcoming': index > currentQuestionIndex
                }"
                :style="{ left: (index / (questions.length - 1) * 100) + '%' }"
              >
                <div class="marker-dot"></div>
                <div class="marker-label">{{ index + 1 }}</div>
              </div>
            </div>
          </div>
        </div>
      </header>

      <!-- 题目区域 -->
      <div class="question-container">
        <div class="content-wrapper">
          <div v-if="loading" class="loading">
            <p>正在加载题目...</p>
          </div>
          
          <template v-else>
          <!-- 题目内容 -->
          <div class="question-content">
            <div class="question-header">
              <div class="question-type-badge">{{ getQuestionTypeText(currentQuestion.type) }}</div>
              <div class="question-number">{{ currentQuestionIndex + 1 }}/{{ questions.length }}</div>
            </div>

            <!-- 判断题 -->
            <div v-if="currentQuestion.type === 'judgement'" class="modern-question">
              <div class="question-text">{{ currentQuestion.question }}</div>
              <div class="modern-options">
                <label class="modern-option">
                  <input 
                    type="radio" 
                    v-model="selectedAnswer" 
                    :value="true"
                    @change="handleAnswerChange"
                  />
                  <div class="option-content">
                    <div class="option-label">A</div>
                    <div class="option-text">对</div>
                  </div>
                </label>
                <label class="modern-option">
                  <input 
                    type="radio" 
                    v-model="selectedAnswer" 
                    :value="false"
                    @change="handleAnswerChange"
                  />
                  <div class="option-content">
                    <div class="option-label">B</div>
                    <div class="option-text">错</div>
                  </div>
                </label>
              </div>
            </div>

            <!-- 选择题 -->
            <div v-if="currentQuestion.type === 'choice'" class="modern-question">
              <div class="question-text">{{ currentQuestion.question }}</div>
              <div class="modern-options">
                <label 
                  v-for="(option, index) in currentQuestion.options" 
                  :key="index" 
                  class="modern-option"
                >
                  <input 
                    type="radio" 
                    v-model="selectedAnswer" 
                    :value="index"
                    @change="handleAnswerChange"
                  />
                  <div class="option-content">
                    <div class="option-label">{{ optionLabel(index) }}</div>
                    <div class="option-text">{{ option }}</div>
                  </div>
                </label>
              </div>
            </div>

            <!-- 简答题 -->
            <div v-if="currentQuestion.type === 'short_answer'" class="modern-question">
              <div class="question-text">{{ currentQuestion.question }}</div>
              <div class="modern-textarea-container">
                <textarea 
                  class="modern-textarea" 
                  v-model="textAnswer" 
                  @input="handleAnswerChange"
                  placeholder="请输入你的答案..."
                ></textarea>
              </div>
            </div>

            <!-- 编程题 -->
            <div v-if="currentQuestion.type === 'programming'" class="modern-question">
              <div class="question-text">{{ currentQuestion.question }}</div>
              <div class="modern-code-container">
                <div class="code-editor" ref="codeEditor"></div>
              </div>
              <div class="modern-code-controls">
                <select v-model="selectedLanguage" @change="updateCodeMode" class="modern-select">
                  <option value="python">Python</option>
                  <option value="javascript">JavaScript</option>
                  <option value="java">Java</option>
                </select>
                <button class="modern-run-btn" @click="runCode">运行</button>
              </div>
              <div class="modern-code-result" v-if="codeResult !== null">
                <pre>{{ codeResult }}</pre>
              </div>
            </div>
          </div>

<div class="modern-action-buttons">
  <button 
    class="modern-submit-btn" 
    @click="handleSubmit"
    :disabled="evaluationLoading"
    :class="{
      'modern-continue-btn': isContinueMode === true,
      'modern-complete-btn': isContinueMode === 'complete',
      'modern-loading-btn': evaluationLoading
    }"
  >
    <span v-if="evaluationLoading" class="modern-loading-spinner"></span>
    {{ evaluationLoading ? '评估中...' : isContinueMode === true ? '继续' : isContinueMode === 'complete' ? '完成' : '提交' }}
  </button>
</div>

<!-- 错误信息显示 -->
<div v-if="evaluationError" class="error-message">
  <div class="error-content">
    <span class="error-icon">⚠️</span>
    <span class="error-text">{{ evaluationError }}</span>
    <button class="error-close-btn" @click="evaluationError = null">×</button>
  </div>
</div>
<div v-if="showEvaluationResult" class="evaluation-result">
  <h3>评估结果</h3>
  <div class="score">得分: {{ evaluationResult.score }}分</div>
  <div class="score2" v-if="currentQuestion.knowledgePoint">知识点: {{ currentQuestion.knowledgePoint}}</div>
  <div class="feedback">解析: {{ evaluationResult.feedback }}</div>

  <div class="correct-answer">
    <h4>正确答案: {{ currentQuestion.answer }}</h4>
  </div>
  
  <button class="close-evaluation-btn" @click="showEvaluationResult = false">关闭</button>
</div>
          <!-- AI辅导弹窗 -->
          <div v-if="showAIHelper" class="ai-helper-modal" @click.self="showAIHelper = false">
            <div class="ai-helper-content">
              <h3>AI答题辅导</h3>
              <div class="ai-response" v-if="aiResponse">
                <h4>建议答案：</h4>
                <p>{{ aiResponse }}</p>
              </div>
              <div v-else class="ai-loading">
                <p>正在生成解答...</p>
              </div>
              <button class="close-ai-btn" @click="showAIHelper = false">关闭</button>
            </div>
          </div>
        </template>
        </div>
      </div>
    </div>
    
    <!-- 自定义弹窗 -->
    <div v-if="showCustomModal" class="custom-modal-overlay" @click="closeCustomModal">
      <div class="custom-modal-content" @click.stop>
        <div class="custom-modal-header">
          <div class="custom-modal-icon">
            <span v-if="customModalType === 'error'" class="custom-error-icon">⚠️</span>
            <span v-else-if="customModalType === 'success'" class="custom-success-icon">✅</span>
            <span v-else class="custom-info-icon">ℹ️</span>
          </div>
          <h3 class="custom-modal-title">{{ customModalTitle }}</h3>
        </div>
        <div class="custom-modal-body">
          <p>{{ customModalMessage }}</p>
        </div>
        <div class="custom-modal-footer">
          <button class="custom-modal-btn custom-confirm-btn" @click="closeCustomModal">确定</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import axios from 'axios';
import { ref, computed, onMounted, nextTick } from 'vue';
import * as monaco from 'monaco-editor';
import { useAiPracticeStore } from '@/store/aiPractice';
import { useRouter, useRoute } from 'vue-router';
import { useUserStore } from '@/store/user.js'
// 评估结果相关
const evaluationResult = ref(null); // 存储评分和反馈
const evaluationLoading = ref(false); // 评估加载状态
const evaluationError = ref(null); // 评估错误信息
const showEvaluationResult = ref(false); // 是否显示评估结果
const router = useRouter();
const route = useRoute();
const aiPracticeStore = useAiPracticeStore();
const questions = ref([]); // 题目列表
const currentQuestionIndex = ref(0); // 当前题目索引
const selectedAnswer = ref(null); // 选择题答案
const textAnswer = ref(""); // 简答题答案
const codeEditor = ref(null); // 代码编辑器引用
let editorInstance = null; // 编辑器实例
const selectedLanguage = ref("python"); // 默认编程语言
const codeResult = ref(null); // 代码执行结果
const showAIHelper = ref(false); // 是否显示AI辅导
const aiResponse = ref(""); // AI辅导回复
const loading = ref(true); // 加载状态
const labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
const isContinueMode = ref(false); // 控制按钮状态
// 添加一个数组来存储每道题的得分
const questionScores = ref([]); // 存储每道题的得分
const correctCount = ref(0); // 答对题目数量
const wrongCount = ref(0);  // 答错题目数量
const correctIndices = ref([]); // 答对题目序号数组
const wrongIndices = ref([]);  // 答错题目序号数组
// 自定义弹窗状态
const showCustomModal = ref(false);
const customModalTitle = ref('');
const customModalMessage = ref('');
const customModalType = ref('info'); // 'info', 'error', 'success'
// 解析题目内容并提取选项
const parseQuestionContent = (content) => {
  console.log("解析的题目内容:", content); // 调试日志
  if (!content) return { question: '', options: [] };
  
  // 匹配选项的正则表达式（匹配A.、B.、C.、D.等开头的选项）
  const optionRegex = /([A-H][.、])\s*(.+?)(?=\s*[A-H][.、]\s*|\s*$)/g;
  const matches = [...content.matchAll(optionRegex)];
  console.log("匹配到的选项:", matches); // 调试日志
  
  // 如果没有匹配到选项，则返回原始内容作为问题
  if (matches.length === 0) {
    return { question: content, options: [] };
  }
  
  // 提取选项
  const options = matches.map(match => match[2].trim());
  console.log("提取的选项:", options); // 调试日志
  
  // 提取问题部分（第一个选项之前的内容）
  const questionPart = content.substring(0, content.indexOf(matches[0][0])).trim();
  console.log("提取的问题部分:", questionPart); // 调试日志
  
  return { question: questionPart, options };
};

// 计算属性
const currentQuestion = computed(() => {
  return questions.value[currentQuestionIndex.value] || {};
});

const totalQuestions = computed(() => {
  return questions.value.length;
});

const progress = computed(() => {
  return ((currentQuestionIndex.value + 1) / totalQuestions.value) * 100;
});;



const moveToNextQuestion = async () => {
  if (currentQuestionIndex.value < totalQuestions.value - 1) {
    // 不是最后一题，跳转到下一题
    currentQuestionIndex.value++;
    nextTick(() => {
      if (currentQuestion.value.type === 'programming') {
        initCodeEditor();
      }
      showEvaluationResult.value = false; // 确保跳转后关闭评估结果
    });
    // 重置为"提交"模式
    isContinueMode.value = false;
    // 清空上一题的答案
    clearCurrentAnswer();
  } else {
    // 是最后一题，跳转到练习报告页面
    const averageScore = questionScores.value.length > 0 
      ? (questionScores.value.reduce((sum, score) => sum + score, 0) / questionScores.value.length).toFixed(2)
      : 0;
    
    // 生成题目状态数组
    const questionStatuses = [];
    for (let i = 0; i < totalQuestions.value; i++) {
      if (correctIndices.value.includes(i + 1)) {
        questionStatuses.push('correct');
      } else if (wrongIndices.value.includes(i + 1)) {
        questionStatuses.push('wrong');
      } else {
        questionStatuses.push('unanswered');
      }
    }
    
    // 计算正确率
    const accuracyRate = totalQuestions.value > 0 ? Math.round((correctCount.value / totalQuestions.value) * 100) : 0;
    
    // 保存练习记录到后端
    await savePracticeRecord(accuracyRate, correctCount.value, wrongCount.value, totalQuestions.value - correctCount.value - wrongCount.value);
    
    // 跳转到练习报告页面
    router.push({
      path: '/practice_report',
      query: {
        averageScore: accuracyRate,
        correctCount: correctCount.value,
        wrongCount: wrongCount.value,
        unansweredCount: totalQuestions.value - correctCount.value - wrongCount.value,
        questionStatuses: encodeURIComponent(JSON.stringify(questionStatuses))
      }
    });
  }
};

/**
 * 通用题目解析函数
 * @param {Object} question - 原始题目对象
 * @returns {Object} - 解析后的题目对象
 */
const parseQuestion = (question) => {
  if (!question) {
    console.error('题目数据为空');
    return {
      type: 'unknown',
      question: '题目数据加载失败',
      options: [],
      answer: null
    };
  }

  // 创建解析后的题目副本
  const parsedQuestion = {
    ...question,
    question: question.question || '题目题干缺失',
    options: question.options || [],
    answer: question.answer || null,
    knowledgePoint: question.knowledgePoint || '未知知识点', // 确保知识点字段存在
    originalContent: question.content // 保留原始content字段
  };

  // 根据题型进行特定处理
  switch (parsedQuestion.type) {
    case 'judgement': // 判断题
      // 判断题通常不需要解析选项，但可以确保有默认值
      if (!parsedQuestion.question) {
        parsedQuestion.question = '判断题题干缺失';
      }
      break;

    case 'choice': // 选择题
      if (parsedQuestion.content && typeof parsedQuestion.content === 'string') {
        // 如果有content字段，尝试从中解析选项
        const optionRegex = /([A-H][.、])\s*(.+?)(?=\s*[A-H][.、]\s*|\s*$)/g;
        const matches = [...parsedQuestion.content.matchAll(optionRegex)];
        
        if (matches.length > 0) {
          // 提取选项
          parsedQuestion.options = matches.map(match => match[2].trim());
          // 提取问题部分（第一个选项之前的内容）
          const questionPart = parsedQuestion.content.substring(0, parsedQuestion.content.indexOf(matches[0][0])).trim();
          parsedQuestion.question = questionPart || '选择题题干缺失';
        } else {
          // 如果没有匹配到选项格式，直接使用content作为问题
          parsedQuestion.question = parsedQuestion.content || '选择题题干缺失';
          parsedQuestion.options = []; // 没有选项
        }
      } else {
        // 如果没有content字段，直接使用question字段
        parsedQuestion.question = parsedQuestion.question || '选择题题干缺失';
        parsedQuestion.options = parsedQuestion.options || [];
      }
      break;

    case 'short_answer': // 简答题
      parsedQuestion.question = parsedQuestion.content || '简答题题干缺失';
      // 简答题不需要选项
      parsedQuestion.options = [];
      break;

    case 'programming': // 编程题
      // 编程题的内容可能存储在content字段中
      if (parsedQuestion.content && typeof parsedQuestion.content === 'string') {
        parsedQuestion.question = parsedQuestion.content;
      } else if (parsedQuestion.question) {
        // 如果question字段存在，直接使用
        parsedQuestion.question = parsedQuestion.question;
      } else {
        // 如果都没有，使用默认值
        parsedQuestion.question = '编程题题干缺失';
      }
      // 编程题不需要选项
      parsedQuestion.options = [];
      break;

    default:
      console.warn(`未知题型: ${parsedQuestion.type}`);
      parsedQuestion.question = parsedQuestion.question || '未知题型题干';
      parsedQuestion.options = [];
  }

  return parsedQuestion;
};

// 获取编程题模板
const getProgrammingTemplate = (language) => {
  switch (language) {
    case 'python':
      return `# 请在此处编写你的Python代码
# 示例：
# 斐波那契数列
# def fibonacci(n):
#     if n <= 0:
#         return 0
#     elif n == 1:
#         return 1
#     else:
#         return fibonacci(n-1) + fibonacci(n-2)
# 
# # 测试
# print(fibonacci(10)) # 输出：55
`;
    case 'javascript':
      return `// 请在此处编写你的JavaScript代码
// 示例：
// 斐波那契数列
// function fibonacci(n) {
//     if (n <= 0) {
//         return 0;
//     } else if (n === 1) {
//         return 1;
//     } else {
//         return fibonacci(n - 1) + fibonacci(n - 2);
//     }
// }
// 
// // 测试
// console.log(fibonacci(10)); // 输出：55
`;
    case 'java':
      return `// 请在此处编写你的Java代码
// 示例：
// 斐波那契数列
// public class Fibonacci {
//     public static int fibonacci(int n) {
//         if (n <= 0) {
//             return 0;
//         } else if (n == 1) {
//             return 1;
//         } else {
//             return fibonacci(n - 1) + fibonacci(n - 2);
//         }
//     }
// }
// 
// // 测试
// System.out.println(fibonacci(10)); // 输出：55
`;
    default:
      return `// 请在此处编写你的代码
// 示例：
// 斐波那契数列
// function fibonacci(n) {
//     if (n <= 0) {
//         return 0;
//     } else if (n === 1) {
//         return 1;
//     } else {
//         return fibonacci(n - 1) + fibonacci(n - 2);
//     }
// }
// 
// // 测试
// console.log(fibonacci(10)); // 输出：55
`;
  }
};


// 初始化页面
// 初始化页面
onMounted(async () => {
  let rawQuestions = [];
  
  // 优先从URL参数获取题目（训练薄弱题使用）
  if (router.currentRoute.value.query.questions) {
    try {
      rawQuestions = JSON.parse(decodeURIComponent(router.currentRoute.value.query.questions));
      console.log("URL参数解析的题目:", rawQuestions);
    } catch (e) {
      console.error("解析题目数据失败:", e);
    }
  }
  
  // 如果URL参数没有题目，再从store获取题目（AI自动出题使用）
  if (rawQuestions.length === 0) {
    rawQuestions = aiPracticeStore.generatedQuestions || [];
    console.log("从store获取的题目数据:", rawQuestions);
  }
  
  if (rawQuestions.length === 0) {
    showModal("加载失败", "未能加载题目，请返回重试", "error");
    router.push('/ai_practice');
    return;
  }

  // 使用通用解析函数处理所有题目
  questions.value = rawQuestions.map(question => parseQuestion(question));
  console.log("处理后的题目数组:", questions.value);

  // 确保至少有一道题
  if (questions.value.length === 0) {
    questions.value.push(parseQuestion({
      id: Date.now(),
      type: 'choice', // 默认类型
      question: '示例问题：1+1等于多少？',
      options: ['1', '2', '3', '4'],
      answer: 1
    }));
  }

  // 设置当前题目索引
  currentQuestionIndex.value = 0;
  
  // 强制设置加载完成
  loading.value = false;
  
  // 确保DOM更新后初始化编辑器
  await nextTick();
  if (currentQuestion.value.type === 'programming' && questions.value.length > 0) {
    initCodeEditor();
  }
  
  // 最终处理完成后，强制更新视图
  questions.value = JSON.parse(JSON.stringify(questions.value)); // 创建全新引用
  currentQuestionIndex.value = 0; // 重置索引
  loading.value = false; // 确保加载状态关闭

  // 强制Vue重新渲染（关键！）
  await nextTick();
  window.dispatchEvent(new Event('resize')); // 触发可能的响应式更新
});
// 初始化代码编辑器
const initCodeEditor = () => {
  if (editorInstance) {
    editorInstance.dispose();
  }
  
  // 使用模板而不是答案
  const template = getProgrammingTemplate(selectedLanguage.value);
  
  editorInstance = monaco.editor.create(codeEditor.value, {
    value: template,
    language: selectedLanguage.value,
    theme: 'vs-light',
    automaticLayout: true,
    minimap: { enabled: false },
    scrollBeyondLastLine: false,
    fontSize: 14,
    lineNumbers: 'on',
    roundedSelection: false,
    scrollbar: {
      vertical: 'visible',
      horizontal: 'visible'
    }
  });
};

// 切换编程语言时更新编辑器
const updateCodeMode = () => {
  if (editorInstance) {
    monaco.editor.setModelLanguage(editorInstance.getModel(), selectedLanguage.value);
  }
};

// 获取题型显示文本
const getQuestionTypeText = (type) => {
  const typeMap = {
    'judgement': '判断题',
    'choice': '选择题',  // 关键修改点
    'short_answer': '简答题',
    'programming': '编程题'
  };
  return typeMap[type] || '未知题型';
};

// 处理选择题选项显示
const optionLabel = (index) => {
  const labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  return labels[index] + " ";
};

// 处理答案变化
const handleAnswerChange = () => {
  // 可以在这里添加答案变化的逻辑
};

// 清空当前答案
const clearCurrentAnswer = () => {
  selectedAnswer.value = null;
  textAnswer.value = "";
  codeResult.value = null;
  if (editorInstance) {
    const template = getProgrammingTemplate(selectedLanguage.value);
    editorInstance.setValue(template);
  }
};

// 返回上一页
const goBack = () => {
  router.push('/ai_practice_2');
};

// 显示自定义弹窗
const showModal = (title, message, type = 'info') => {
  customModalTitle.value = title;
  customModalMessage.value = message;
  customModalType.value = type;
  showCustomModal.value = true;
};

// 关闭自定义弹窗
const closeCustomModal = () => {
  showCustomModal.value = false;
};

// 保存练习记录到后端
const savePracticeRecord = async (accuracyRate, correctCount, wrongCount, unansweredCount) => {
  try {
    // 判断是否为训练薄弱题
    let practiceType = 'AI自动出题';
    if (route.query.fromWeakTrain === '1') {
      practiceType = '训练薄弱题';
    }
    const practiceData = {
      studentId: useUserStore().currentUserId, // 这里应该从用户信息中获取
      courseId: 101, // 从路由参数或store中获取
      totalQuestions: questions.value.length,
      correctCount: correctCount,
      wrongCount: wrongCount,
      unansweredCount: unansweredCount,
      accuracyRate: accuracyRate,
      practiceType: practiceType,
      practiceDate: new Date().toISOString(),
      questionDetails: questions.value.map((q, index) => {
        // 对于选择题，优先使用原始content（包含选项），如果没有则组合题干和选项
        let questionContent = q.question;
        if (q.type === 'choice') {
          // 优先使用原始content字段（包含完整选项）
          if (q.originalContent) {
            questionContent = q.originalContent;
          } else if (q.options && q.options.length > 0) {
            // 如果没有原始content，则组合题干和选项
            const optionsText = q.options.map((option, optIndex) => {
              const label = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'][optIndex];
              return `${label}. ${option}`;
            }).join(' ');
            questionContent = `${q.question} ${optionsText}`;
          }
        }
        
        return {
          questionId: q.id || index,
          questionType: q.type,
          questionContent: questionContent,
          knowledgePoint: q.knowledgePoint || '未知知识点', // 添加知识点字段
          userAnswer: q.userAnswer,
          correctAnswer: q.answer,
          score: questionScores.value[index] || 0,
          isCorrect: questionScores.value[index] >= 100
        };
      })
    };

    const response = await axios.post('/api/xiaozhi/student/savePracticeRecord', practiceData);
    console.log('练习记录保存成功:', response.data);
  } catch (error) {
    console.error('保存练习记录失败:', error);
  }
};

// 显示AI辅导
const getAIHelperResponse = async () => {
  showAIHelper.value = true;
  
  // 模拟AI生成回答的过程
  setTimeout(() => {
    let response = "";
    switch (currentQuestion.value.type) {
      case 'judgement':
        response = `这道判断题的正确答案是：${currentQuestion.value.answer ? "对" : "错"}。`;
        break;
      case 'choice':
        const correctOption = currentQuestion.value.options[currentQuestion.value.answer];
        response = `正确选项是：${optionLabel(currentQuestion.value.answer)}${correctOption}。`;
        break;
      case 'short_answer':
        response = "对于这道简答题，建议从以下几个方面作答：\n1. 定义与概念\n2. 主要特点\n3. 应用场景\n4. 与其他相关概念的区别";
        break;
      case 'programming':
        response = `这是一个${selectedLanguage.value}的示例解决方案：\n\n${currentQuestion.value.answer || "// 示例代码\n"}`;
        break;
    }
    aiResponse.value = response;
  }, 1500);
};

// 运行编程题代码
const runCode = () => {
  if (!editorInstance) return;
  
  codeResult.value = "正在运行代码...";
  
  // 这里是模拟代码执行的过程，实际应用中可能需要后端支持
  setTimeout(() => {
    try {
      let code = editorInstance.getValue();
      let result = "代码执行成功！";
      
      // 模拟不同语言的执行结果
      if (selectedLanguage.value === 'python') {
        // 简单模拟Python代码执行
        if (code.includes('fibonacci')) {
          result = "当n=10时，输出结果为：55";
        }
      } else if (selectedLanguage.value === 'javascript') {
        // 模拟JavaScript代码执行
        if (code.includes('function fibonacci')) {
          result = "当n=10时，控制台输出：55";
        }
      }
      
      codeResult.value = result;
    } catch (error) {
      codeResult.value = `执行错误：${error.message}`;
    }
  }, 1000);
};


// 修改handleSubmit方法（替换原来的submitAnswer中的跳转逻辑）
const handleSubmit = () => {
  if (isContinueMode.value) {
    // 如果是"继续"模式，直接跳转下一题
    showEvaluationResult.value = false; // 先关闭评估结果
    moveToNextQuestion();
  } else {
    // 如果是"提交"模式，执行提交逻辑
    submitAnswer();
  }
};
// 提交答案
// 提交答案
// 提交答案
// 提交答案 - 修复版本
// 提交答案 - 最终修复版本
const submitAnswer = async () => {
  // 1. 检查当前题目是否存在
  if (!currentQuestion.value) {
    evaluationError.value = "当前题目不存在，请刷新页面重试";
    console.error("提交失败: currentQuestion为null");
    return;
  }

  // 2. 保存当前答案
  let answer = "";
  switch (currentQuestion.value.type) {
    case 'judgement':
      answer = selectedAnswer.value;
      break;
    case 'choice':
      answer = selectedAnswer.value;
      break;
    case 'short_answer':
      answer = textAnswer.value;
      // 检查简答题答案是否为空
      if (!answer || answer.trim() === "") {
        evaluationError.value = "请填写简答题答案";
        return;
      }
      break;
    case 'programming':
      if (editorInstance) {
        answer = editorInstance.getValue();
      } else {
        evaluationError.value = "代码编辑器未初始化，请刷新页面重试";
        return;
      }
      // 检查编程题答案是否为空
      if (!answer || answer.trim() === "") {
        evaluationError.value = "请编写代码";
        return;
      }
      break;
    default:
      evaluationError.value = "不支持的题目类型";
      return;
  }

  // 保存答案到问题对象
  if (questions.value[currentQuestionIndex.value]) {
    questions.value[currentQuestionIndex.value].userAnswer = answer;
  }
  
  // 先不进行统计，等后端评估结果出来后再统计

  // 3. 如果是选择题，调用评估接口
  if (currentQuestion.value.type === 'choice') {
    evaluationLoading.value = true;
    evaluationError.value = null;
    
    try {
      // 4. 准备请求数据
      console.log("当前题目对象:", currentQuestion.value);
      
      // 安全检查
      if (!currentQuestion.value.question || !currentQuestion.value.options) {
        throw new Error("当前题目缺少必要属性(question或options)");
      }
      if (currentQuestion.value.answer === undefined || currentQuestion.value.answer === null) {
        throw new Error("当前题目缺少正确答案(answer)");
      }
      if (answer === undefined || answer === null) {
        throw new Error("用户答案未定义");
      }
      if (currentQuestion.value.answer < 0 || currentQuestion.value.answer >= currentQuestion.value.options.length) {
        throw new Error("正确答案索引超出范围");
      }
      if (answer < 0 || answer >= currentQuestion.value.options.length) {
        throw new Error("用户答案索引超出范围");
      }

      // 5. 准备请求数据
      const requestData = {
        memoryId: 0,
        content: currentQuestion.value.question,
        standardAnswer: currentQuestion.value.answer,
        answer: labels[answer]
      };

      console.log("请求数据:", requestData);

      // 6. 调用后端接口
      const response = await axios.post('api/xiaozhi/student/evaluate2', requestData);
      console.log("响应数据:", response.data);
      
      // 存储评估结果
      evaluationResult.value = response.data;
      showEvaluationResult.value = true;
      
      // 记录当前题目的得分并根据得分判断正确性
      if (evaluationResult.value && evaluationResult.value.score !== undefined) {
        questionScores.value.push(evaluationResult.value.score);
        
        // 根据得分判断是否正确（100分为正确）
        if (evaluationResult.value.score >= 100) {
          correctCount.value++;
          correctIndices.value.push(currentQuestionIndex.value + 1);
        } else {
          wrongCount.value++;
          wrongIndices.value.push(currentQuestionIndex.value + 1);
        }
      } else {
        // 如果后端没有返回score，默认算错误
        questionScores.value.push(0);
        wrongCount.value++;
        wrongIndices.value.push(currentQuestionIndex.value + 1);
      }
      
      // ===== 关键点：后端返回结果后才设置为继续模式 =====
      // 根据是否是最后一题设置按钮状态
      if (currentQuestionIndex.value < totalQuestions.value - 1) {
        isContinueMode.value = true; // 继续模式
      } else {
        isContinueMode.value = 'complete'; // 完成模式
      }
    } catch (error) {
      console.error("评估失败:", error);
      evaluationError.value = `提交失败: ${error.message}`;
      
      // 评估失败时保持按钮为"提交"状态
      isContinueMode.value = false;
      // 记录失败题目的得分为0，并算作错误
      questionScores.value.push(0);
      wrongCount.value++;
      wrongIndices.value.push(currentQuestionIndex.value + 1);
    } finally {
      evaluationLoading.value = false;
    }
  } else if (currentQuestion.value.type === 'short_answer') {
    // 处理简答题
    evaluationLoading.value = true;
    evaluationError.value = null;
    
    try {
      // 4. 准备请求数据
      console.log("当前简答题对象:", currentQuestion.value);
      
      // 安全检查
      if (!currentQuestion.value.question) {
        throw new Error("当前题目缺少必要属性(question)");
      }
      if (currentQuestion.value.answer === undefined || currentQuestion.value.answer === null) {
        throw new Error("当前题目缺少正确答案(answer)");
      }
      if (answer === undefined || answer === null || answer.trim() === "") {
        throw new Error("用户答案未填写");
      }

      // 5. 准备请求数据
      const requestData = {
        memoryId: 0,
        content: currentQuestion.value.question,
        standardAnswer: currentQuestion.value.answer,
        answer: answer
      };

      console.log("简答题请求数据:", requestData);

      // 6. 调用后端接口
      const response = await axios.post('api/xiaozhi/student/evaluate2', requestData);
      console.log("简答题响应数据:", response.data);
      
      // 存储评估结果
      evaluationResult.value = response.data;
      showEvaluationResult.value = true;
      
      // 记录当前题目的得分并根据得分判断正确性
      if (evaluationResult.value && evaluationResult.value.score !== undefined) {
        questionScores.value.push(evaluationResult.value.score);
        
        // 根据得分判断是否正确（100分为正确）
        if (evaluationResult.value.score >= 100) {
          correctCount.value++;
          correctIndices.value.push(currentQuestionIndex.value + 1);
        } else {
          wrongCount.value++;
          wrongIndices.value.push(currentQuestionIndex.value + 1);
        }
      } else {
        // 如果后端没有返回score，默认算错误
        questionScores.value.push(0);
        wrongCount.value++;
        wrongIndices.value.push(currentQuestionIndex.value + 1);
      }
      
      // ===== 关键点：后端返回结果后才设置为继续模式 =====
      // 根据是否是最后一题设置按钮状态
      if (currentQuestionIndex.value < totalQuestions.value - 1) {
        isContinueMode.value = true; // 继续模式
      } else {
        isContinueMode.value = 'complete'; // 完成模式
      }
    } catch (error) {
      console.error("简答题评估失败:", error);
      evaluationError.value = `提交失败: ${error.message}`;
      
      // 评估失败时保持按钮为"提交"状态
      isContinueMode.value = false;
      // 记录失败题目的得分为0，并算作错误
      questionScores.value.push(0);
      wrongCount.value++;
      wrongIndices.value.push(currentQuestionIndex.value + 1);
    } finally {
      evaluationLoading.value = false;
    }
  } else if (currentQuestion.value.type === 'programming') {
    // 处理编程题
    evaluationLoading.value = true;
    evaluationError.value = null;
    
    try {
      // 4. 准备请求数据
      console.log("当前编程题对象:", currentQuestion.value);
      
      // 安全检查
      if (!currentQuestion.value.question) {
        throw new Error("当前题目缺少必要属性(question)");
      }
      if (!currentQuestion.value.answer) {
        throw new Error("当前题目缺少正确答案(answer)");
      }
      
      // 检查用户代码是否为空
      if (answer === undefined || answer === null || answer.trim() === "") {
        throw new Error("请编写代码后再提交");
      }

      // 5. 准备请求数据
      const requestData = {
        memoryId: 0,
        content: currentQuestion.value.question,
        standardAnswer: currentQuestion.value.answer,
        answer: answer
      };

      console.log("编程题请求数据:", requestData);

      // 6. 调用后端接口
      const response = await axios.post('api/xiaozhi/student/evaluate2', requestData);
      console.log("编程题响应数据:", response.data);
      
      // 存储评估结果
      evaluationResult.value = response.data;
      showEvaluationResult.value = true;
      
      // 记录当前题目的得分并根据得分判断正确性
      if (evaluationResult.value && evaluationResult.value.score !== undefined) {
        questionScores.value.push(evaluationResult.value.score);
        
        // 根据得分判断是否正确（100分为正确）
        if (evaluationResult.value.score >= 100) {
          correctCount.value++;
          correctIndices.value.push(currentQuestionIndex.value + 1);
        } else {
          wrongCount.value++;
          wrongIndices.value.push(currentQuestionIndex.value + 1);
        }
      } else {
        // 如果后端没有返回score，默认算错误
        questionScores.value.push(0);
        wrongCount.value++;
        wrongIndices.value.push(currentQuestionIndex.value + 1);
      }
      
      // ===== 关键点：后端返回结果后才设置为继续模式 =====
      // 根据是否是最后一题设置按钮状态
      if (currentQuestionIndex.value < totalQuestions.value - 1) {
        isContinueMode.value = true; // 继续模式
      } else {
        isContinueMode.value = 'complete'; // 完成模式
      }
    } catch (error) {
      console.error("编程题评估失败:", error);
      evaluationError.value = `提交失败: ${error.message}`;
      
      // 评估失败时保持按钮为"提交"状态
      isContinueMode.value = false;
      // 记录失败题目的得分为0，并算作错误
      questionScores.value.push(0);
      wrongCount.value++;
      wrongIndices.value.push(currentQuestionIndex.value + 1);
    } finally {
      evaluationLoading.value = false;
    }
  } else {
    // 处理判断题
    if (currentQuestion.value.type === 'judgement') {
      // 判断题直接比较答案
      const isCorrect = answer === currentQuestion.value.answer;
      if (isCorrect) {
        correctCount.value++;
        correctIndices.value.push(currentQuestionIndex.value + 1);
        questionScores.value.push(100);
      } else {
        wrongCount.value++;
        wrongIndices.value.push(currentQuestionIndex.value + 1);
        questionScores.value.push(0);
      }
      
      // 显示评估结果
      showEvaluationResult.value = true;
      
      // 根据是否是最后一题设置按钮状态
      if (currentQuestionIndex.value < totalQuestions.value - 1) {
        isContinueMode.value = true; // 继续模式
      } else {
        isContinueMode.value = 'complete'; // 完成模式
      }
    }
  }
};
</script>
<style scoped>
.app-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  width: 100%;
  background-color: #f0f5ff;
  font-family: 'Arial', sans-serif;
  background: url('../../assets/images/people.gif') no-repeat center center fixed; /* 替换为你的GIF路径 */
  background-size: cover; /* 确保GIF覆盖整个容器 */
}
.quiz-container { 
    width: 100%;
    max-width: none;
    margin: 0;
    margin-top: 0;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
}

/* 现代化头部样式 */
.modern-header {
  position: relative;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 20px 20px 0 0;
  overflow: hidden;
  margin-bottom: 20px;
  box-shadow: 0 8px 32px rgba(102, 126, 234, 0.3);
}

.header-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  overflow: hidden;
}

.floating-icons {
  position: absolute;
  width: 100%;
  height: 100%;
}

.icon-float {
  position: absolute;
  font-size: 20px;
  opacity: 0.1;
  animation: float 6s ease-in-out infinite;
}

.icon-1 { top: 20%; left: 10%; animation-delay: 0s; }
.icon-2 { top: 30%; right: 15%; animation-delay: 1s; }
.icon-3 { top: 60%; left: 20%; animation-delay: 2s; }
.icon-4 { top: 70%; right: 25%; animation-delay: 3s; }
.icon-5 { top: 45%; left: 80%; animation-delay: 4s; }

@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-10px) rotate(5deg); }
}

.header-content {
  position: relative;
  display: grid;
  grid-template-columns: 1fr 2fr 1fr;
  align-items: center;
  padding: 25px 30px 20px;
  z-index: 1;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
  box-sizing: border-box;
}

.header-left {
  display: flex;
  justify-content: flex-start;
}

.header-right {
  display: flex;
  justify-content: flex-end;
}

.modern-back-btn {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  border-radius: 12px;
  padding: 12px;
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
}

.modern-back-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateX(-2px);
}

.title-section {
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.main-title {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 8px;
}

.title-gradient {
  font-size: 28px;
  font-weight: 700;
  color: white;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
  letter-spacing: 1px;
}

.title-decoration {
  display: flex;
  align-items: center;
  margin-top: 5px;
  gap: 8px;
}

.decoration-line {
  width: 30px;
  height: 2px;
  background: rgba(255, 255, 255, 0.5);
  border-radius: 1px;
}

.decoration-dot {
  width: 6px;
  height: 6px;
  background: white;
  border-radius: 50%;
  box-shadow: 0 0 10px rgba(255, 255, 255, 0.5);
}

.subtitle {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.8);
  font-weight: 500;
  letter-spacing: 0.5px;
}

.header-stats {
  display: flex;
  gap: 15px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.15);
  padding: 10px 15px;
  border-radius: 12px;
  backdrop-filter: blur(10px);
}

.stat-icon {
  font-size: 18px;
  filter: grayscale(0.3);
}

.stat-info {
  text-align: left;
}

.stat-label {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.7);
  font-weight: 500;
  line-height: 1;
}

.stat-value {
  font-size: 14px;
  color: white;
  font-weight: 600;
  line-height: 1.2;
}

/* 现代化进度条样式 */
.modern-progress-container {
  padding: 0 30px 25px;
  position: relative;
}

.progress-track {
  position: relative;
  height: 8px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #00d4aa 0%, #00a0ff 100%);
  border-radius: 4px;
  transition: width 0.5s ease;
  position: relative;
}

.progress-glow {
  position: absolute;
  top: 0;
  right: 0;
  width: 20px;
  height: 100%;
  background: linear-gradient(90deg, transparent 0%, rgba(255, 255, 255, 0.6) 100%);
  border-radius: 4px;
}

.progress-markers {
  position: absolute;
  top: -8px;
  left: 0;
  right: 0;
  height: 24px;
}

.progress-marker {
  position: absolute;
  transform: translateX(-50%);
  display: flex;
  flex-direction: column;
  align-items: center;
}

.marker-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.5);
  border: 2px solid transparent;
  transition: all 0.3s ease;
}

.progress-marker.completed .marker-dot {
  background: #00d4aa;
  border-color: white;
  box-shadow: 0 0 8px rgba(0, 212, 170, 0.5);
}

.progress-marker.current .marker-dot {
  background: #00a0ff;
  border-color: white;
  animation: pulse 2s ease-in-out infinite;
  box-shadow: 0 0 12px rgba(0, 160, 255, 0.7);
}

.progress-marker.upcoming .marker-dot {
  background: rgba(255, 255, 255, 0.3);
  border-color: rgba(255, 255, 255, 0.5);
}

.marker-label {
  font-size: 10px;
  color: rgba(255, 255, 255, 0.8);
  font-weight: 600;
  margin-top: 4px;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.2); }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .header-content {
    padding: 20px 20px 15px;
    grid-template-columns: auto 1fr auto;
  }
  
  .title-gradient {
    font-size: 24px;
  }
  
  .header-stats {
    flex-direction: column;
    gap: 8px;
  }
  
  .stat-item {
    padding: 6px 10px;
  }
  
  .stat-label, .stat-value {
    font-size: 10px;
  }
  
  .modern-progress-container {
    padding: 0 20px 20px;
  }
  
  .decoration-line {
    width: 20px;
  }
}

@media (max-width: 480px) {
  .header-content {
    display: flex;
    flex-direction: column;
    gap: 15px;
    text-align: center;
  }
  
  .header-left {
    align-self: flex-start;
  }
  
  .header-right {
    align-self: center;
  }
  
  .header-stats {
    flex-direction: row;
    justify-content: center;
    gap: 15px;
  }
}

.question-container {
  flex: 1;
  padding: 0;
  overflow-y: auto;
  background-color: transparent;
  opacity: 1;
  display: flex;
  flex-direction: column;
}

.content-wrapper {
  flex: 1;
  display: flex;
  flex-direction: column;
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px 30px 30px 30px;
  width: 100%;
  box-sizing: border-box;
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

.question-type-badge {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.5px;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.question-number {
  background-color: #f8f9fa;
  color: #6c757d;
  padding: 6px 12px;
  border-radius: 12px;
  font-size: 14px;
  font-weight: 500;
  border: 1px solid #e9ecef;
}

.modern-question {
  background: white;
  border-radius: 16px;
  padding: 25px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #f0f0f0;
  margin-bottom: 20px;
  max-width: 100%;
  box-sizing: border-box;
}

.question-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.question-text {
  font-size: 18px;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 25px;
  line-height: 1.6;
  letter-spacing: 0.3px;
}

/* 现代化选项样式 */
.modern-options {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.modern-option {
  display: flex;
  align-items: center;
  padding: 0;
  border: 2px solid #e9ecef;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  background: white;
  overflow: hidden;
}

.modern-option:hover {
  border-color: #667eea;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
  transform: translateY(-1px);
}

.modern-option input[type="radio"] {
  display: none;
}

.modern-option input[type="radio"]:checked + .option-content {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.option-content {
  display: flex;
  align-items: center;
  width: 100%;
  padding: 16px 20px;
  transition: all 0.3s ease;
}

.option-label {
  background: #f8f9fa;
  color: #6c757d;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 14px;
  margin-right: 16px;
  transition: all 0.3s ease;
}

.modern-option input[type="radio"]:checked + .option-content .option-label {
  background: rgba(255, 255, 255, 0.2);
  color: white;
}

.option-text {
  font-size: 16px;
  font-weight: 500;
  color: #495057;
  flex: 1;
  transition: all 0.3s ease;
}

.modern-option input[type="radio"]:checked + .option-content .option-text {
  color: white;
}

/* 现代化简答题样式 */
.modern-textarea-container {
  position: relative;
}

.modern-textarea {
  width: 100%;
  height: 200px;
  padding: 16px;
  border: 2px solid #e9ecef;
  border-radius: 12px;
  font-size: 16px;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  resize: none;
  background: #fafbfc;
  color: #495057;
  transition: all 0.3s ease;
  line-height: 1.6;
  box-sizing: border-box;
}

.modern-textarea:focus {
  outline: none;
  border-color: #667eea;
  background: white;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.modern-textarea::placeholder {
  color: #adb5bd;
  font-style: italic;
}

/* 现代化编程题样式 */
.modern-code-container {
  border: 2px solid #e9ecef;
  border-radius: 12px;
  margin-bottom: 20px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.code-editor {
  min-height: 300px;
}

.modern-code-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
}

.modern-select {
  padding: 10px 16px;
  border-radius: 8px;
  border: 2px solid #e9ecef;
  background: white;
  font-size: 14px;
  color: #495057;
  cursor: pointer;
  transition: all 0.3s ease;
}

.modern-select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.modern-run-btn {
  padding: 10px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.modern-run-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.modern-code-result {
  background: #f8f9fa;
  padding: 16px 20px;
  border-radius: 8px;
  font-family: 'Fira Code', 'Monaco', 'Consolas', monospace;
  white-space: pre-wrap;
  overflow: auto;
  max-height: 150px;
  border: 1px solid #e9ecef;
  color: #495057;
  font-size: 14px;
  line-height: 1.5;
}

/* 现代化操作按钮样式 */
.modern-action-buttons {
  display: flex;
  justify-content: center;
  margin-top: auto;
  padding: 20px;
  flex-shrink: 0;
}

.modern-submit-btn {
  padding: 16px 32px;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  font-size: 16px;
  font-weight: 600;
  transition: all 0.3s ease;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
  min-width: 120px;
  position: relative;
  overflow: hidden;
}

.modern-submit-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.modern-submit-btn:active {
  transform: translateY(0);
}

.modern-submit-btn:disabled {
  background: #e9ecef;
  color: #adb5bd;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

.modern-continue-btn {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
  box-shadow: 0 4px 15px rgba(40, 167, 69, 0.3);
}

.modern-continue-btn:hover {
  box-shadow: 0 6px 20px rgba(40, 167, 69, 0.4);
}

.modern-complete-btn {
  background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
  box-shadow: 0 4px 15px rgba(0, 123, 255, 0.3);
}

.modern-complete-btn:hover {
  box-shadow: 0 6px 20px rgba(0, 123, 255, 0.4);
}

.modern-loading-btn {
  background: #6c757d;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

/* 现代化AI辅导模态框 */
.ai-helper-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: fadeIn 0.3s ease;
}

.ai-helper-content {
  background: white;
  padding: 30px;
  border-radius: 16px;
  width: 90%;
  max-width: 600px;
  max-height: 80vh;
  overflow-y: auto;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  animation: slideIn 0.3s ease;
}

.ai-helper-content h3 {
  margin-bottom: 20px;
  color: #667eea;
  font-size: 20px;
  font-weight: 600;
  text-align: center;
}

.ai-response {
  margin-bottom: 20px;
  background: #f8f9fa;
  padding: 20px;
  border-radius: 12px;
  border-left: 4px solid #667eea;
}

.ai-response h4 {
  margin: 0 0 12px 0;
  color: #495057;
  font-size: 16px;
  font-weight: 600;
}

.ai-response p {
  margin: 0;
  color: #6c757d;
  line-height: 1.6;
  font-size: 14px;
}

.ai-loading {
  color: #6c757d;
  margin-bottom: 20px;
  text-align: center;
  font-style: italic;
}

.close-ai-btn {
  padding: 12px 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
  width: 100%;
}

.close-ai-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}
/* 现代化评估结果样式 */
.evaluation-result {
  margin-top: 25px;
  padding: 25px;
  border-radius: 16px;
  background: linear-gradient(135deg, rgba(248, 249, 250, 0.95) 0%, rgba(233, 236, 239, 0.95) 100%);
  border: 1px solid #dee2e6;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  backdrop-filter: blur(10px);
}

.score {
  font-size: 24px;
  font-weight: 700;
  color: #dc3545;
  margin-bottom: 12px;
  text-align: center;
  background: white;
  padding: 12px 20px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(220, 53, 69, 0.1);
}

.score2 {
  font-size: 16px;
  font-weight: 600;
  color: #17a2b8;
  margin-bottom: 12px;
  text-align: center;
  background: white;
  padding: 8px 16px;
  border-radius: 8px;
  box-shadow: 0 2px 6px rgba(23, 162, 184, 0.1);
}

.feedback {
  margin-bottom: 20px;
  line-height: 1.6;
  color: #495057;
  font-size: 15px;
  background: white;
  padding: 16px 20px;
  border-radius: 12px;
  border-left: 4px solid #667eea;
}

.correct-answer {
  margin-top: 20px;
  padding: 16px 20px;
  background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%);
  border-radius: 12px;
  border: 1px solid #90caf9;
}

.correct-answer h4 {
  margin: 0 0 12px 0;
  color: #1976d2;
  font-size: 16px;
  font-weight: 600;
}

.close-evaluation-btn {
  padding: 12px 24px;
  background: linear-gradient(135deg, #6c757d 0%, #495057 100%);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  margin-top: 16px;
  font-weight: 600;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(108, 117, 125, 0.3);
}

.close-evaluation-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(108, 117, 125, 0.4);
}

/* 现代化加载状态样式 */
.modern-loading-spinner {
  display: inline-block;
  width: 18px;
  height: 18px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: #ffffff;
  animation: modernSpin 1s ease-in-out infinite;
  margin-right: 10px;
}

@keyframes modernSpin {
  to { transform: rotate(360deg); }
}

/* 错误信息样式 */
.error-message {
  position: fixed;
  top: 20px;
  left: 50%;
  transform: translateX(-50%);
  background-color: #ffebee;
  border: 1px solid #f44336;
  border-radius: 8px;
  padding: 15px;
  z-index: 1001;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  max-width: 500px;
  min-width: 300px;
}

.error-content {
  display: flex;
  align-items: center;
  gap: 10px;
}

.error-icon {
  font-size: 20px;
  flex-shrink: 0;
}

.error-text {
  flex-grow: 1;
  color: #d32f2f;
  font-size: 14px;
  line-height: 1.4;
}

.error-close-btn {
  background: none;
  border: none;
  color: #d32f2f;
  font-size: 18px;
  cursor: pointer;
  padding: 0;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: background-color 0.2s;
}

.error-close-btn:hover {
  background-color: rgba(244, 67, 54, 0.1);
}

/* 自定义弹窗样式 */
.custom-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1001;
  animation: customFadeIn 0.3s ease;
}

.custom-modal-content {
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  max-width: 400px;
  width: 90%;
  animation: customSlideIn 0.3s ease;
}

.custom-modal-header {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 20px 20px 0 20px;
}

.custom-modal-icon {
  font-size: 24px;
  flex-shrink: 0;
}

.custom-error-icon {
  color: #f44336;
}

.custom-success-icon {
  color: #4caf50;
}

.custom-info-icon {
  color: #2196f3;
}

.custom-modal-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #333;
}

.custom-modal-body {
  padding: 16px 20px;
}

.custom-modal-body p {
  margin: 0;
  font-size: 14px;
  color: #666;
  line-height: 1.5;
}

.custom-modal-footer {
  padding: 0 20px 20px 20px;
  display: flex;
  justify-content: flex-end;
}

.custom-modal-btn {
  padding: 8px 20px;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
}

.custom-confirm-btn {
  background-color: #5c5cff;
  color: white;
}

.custom-confirm-btn:hover {
  background-color: #4a4acc;
}

@keyframes customFadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes customSlideIn {
  from { 
    opacity: 0;
    transform: translateY(-20px) scale(0.95);
  }
  to { 
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}
</style>