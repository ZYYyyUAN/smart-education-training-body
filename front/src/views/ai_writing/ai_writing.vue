<template>
  <div class="ai-writing-container">
    <!-- 返回按钮 -->
    <div class="back-button" @click="goBack">
      <svg viewBox="0 0 24 24" width="20" height="20">
        <path fill="currentColor" d="M20,11V13H8L13.5,18.5L12.08,19.92L4.16,12L12.08,4.08L13.5,5.5L8,11H20Z" />
      </svg>
      <span>返回</span>
    </div>

    <!-- 右侧历史记录面板 -->
    <div class="history-sidebar">
      <div class="history-header">
        <div class="history-icon">📝</div>
        <div class="history-text">
          <div class="history-title">历史记录</div>
          <div class="history-subtitle">仅保存一个月的历史记录</div>
        </div>
      </div>
      
      <div class="history-content">
        <div v-if="historyRecords.length === 0" class="empty-history-content">
          <div class="empty-icon">📄</div>
          <div class="empty-text">暂无历史数据</div>
        </div>
        
        <div v-else class="history-list">
          <div 
            v-for="(record, index) in historyRecords" 
            :key="index"
            class="history-item"
            @click="loadHistoryItem(record)"
          >
            <div class="history-topic">{{ record.topic }}</div>
            <div class="history-time">{{ formatTime(record.timestamp) }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 主内容区域 -->
    <div class="main-content">
      <!-- 页面标题 -->
      <div class="header-section">
        <h1 class="main-title">AI·写作助手</h1>
        <p class="subtitle">辅助撰写各类教学文档</p>
      </div>

      <!-- 输入区域 -->
      <div class="input-section">
        <div class="input-container">
          <input 
            type="text" 
            v-model="writingTopic"
            placeholder="请输入AI写作主题"
            class="topic-input"
          />
          <button 
            class="generate-button" 
            @click="generateContent"
            :disabled="!writingTopic.trim() || isGenerating"
          >
            <span v-if="!isGenerating">✨ 生成</span>
            <span v-else>🔄 生成中...</span>
          </button>
        </div>
      </div>


    </div>


  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'

const router = useRouter()

// 响应式数据
const writingTopic = ref('')
const selectedType = ref(1)
const historyRecords = ref([])

// 写作类型配置
const writingTypes = ref([
  { id: 1, name: '教学方案', emoji: '📚' },
  { id: 2, name: '课程大纲', emoji: '📝' },
  { id: 3, name: '学习总结', emoji: '📋' },
  { id: 4, name: '研究报告', emoji: '🔬' },
  { id: 5, name: '演讲稿', emoji: '🎤' },
  { id: 6, name: '论文摘要', emoji: '📄' }
])



// 页面方法
const goBack = () => {
  router.go(-1)
}

const selectType = (typeId) => {
  selectedType.value = typeId
}

const generateContent = () => {
  if (!writingTopic.value.trim()) return
  
  // 保存到历史记录
  const historyItem = {
    topic: writingTopic.value,
    type: selectedType.value,
    timestamp: new Date()
  }
  historyRecords.value.unshift(historyItem)
  
  // 限制历史记录数量
  if (historyRecords.value.length > 10) {
    historyRecords.value = historyRecords.value.slice(0, 10)
  }
  
  saveHistoryToLocal()
  
  // 跳转到结果页面
  router.push({
    path: '/ai_writing/result',
    query: {
      topic: writingTopic.value,
      type: selectedType.value
    }
  })
}



const loadHistoryItem = (record) => {
  writingTopic.value = record.topic
  selectedType.value = record.type
}

const clearHistory = () => {
  if (confirm('确定要清空所有历史记录吗？')) {
    historyRecords.value = []
    localStorage.removeItem('ai_writing_history')
  }
}

const formatTime = (timestamp) => {
  const date = new Date(timestamp)
  return `${date.getMonth() + 1}/${date.getDate()} ${date.getHours()}:${date.getMinutes().toString().padStart(2, '0')}`
}

const saveHistoryToLocal = () => {
  localStorage.setItem('ai_writing_history', JSON.stringify(historyRecords.value))
}

const loadHistoryFromLocal = () => {
  const saved = localStorage.getItem('ai_writing_history')
  if (saved) {
    try {
      historyRecords.value = JSON.parse(saved).map(item => ({
        ...item,
        timestamp: new Date(item.timestamp)
      }))
    } catch (error) {
      console.error('加载历史记录失败:', error)
    }
  }
}

onMounted(() => {
  loadHistoryFromLocal()
  console.log('✅ AI写作助手页面已就绪')
})
</script>

<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: "PingFang SC", "Microsoft YaHei", sans-serif;
}

.ai-writing-container {
  height: 100vh;
  background: linear-gradient(135deg, #e3f2fd 0%, #f8fbff 50%, #e8f4fd 100%);
  position: relative;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
}

/* 返回按钮样式 */
.back-button {
  position: absolute;
  top: 20px;
  left: 20px;
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  padding: 8px 12px;
  color: #666;
  cursor: pointer;
  transition: all 0.3s ease;
  z-index: 1000;
  font-size: 14px;
  font-weight: 500;
}

.back-button:hover {
  background: rgba(255, 255, 255, 0.9);
  color: #333;
}

/* 右侧历史记录面板 */
.history-sidebar {
  position: absolute;
  top: 40px;
  right: 40px;
  width: 320px;
  height: calc(100vh - 80px);
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(102, 126, 234, 0.1);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  z-index: 10;
}

.history-header {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 20px 24px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  background: rgba(179, 157, 219, 0.02);
}

.history-icon {
  font-size: 18px;
  color: #b39ddb;
}

.history-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.history-title {
  font-size: 15px;
  font-weight: 600;
  color: #333;
  letter-spacing: 0.5px;
}

.history-subtitle {
  font-size: 12px;
  color: #888;
  font-weight: 400;
}

.history-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  padding: 20px 24px;
}

/* 当没有历史记录时的居中样式 */
.history-content:has(.empty-history-content) {
  align-items: center;
  justify-content: center;
  padding: 40px 24px;
}

/* 自定义滚动条样式 */
.history-content::-webkit-scrollbar {
  width: 6px;
}

.history-content::-webkit-scrollbar-track {
  background: rgba(0, 0, 0, 0.05);
  border-radius: 3px;
}

.history-content::-webkit-scrollbar-thumb {
  background: rgba(179, 157, 219, 0.3);
  border-radius: 3px;
  transition: all 0.3s ease;
}

.history-content::-webkit-scrollbar-thumb:hover {
  background: rgba(179, 157, 219, 0.5);
}

.empty-history-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  opacity: 0.6;
}

.empty-icon {
  font-size: 48px;
  color: #b39ddb;
}

.empty-text {
  font-size: 14px;
  color: #888;
  text-align: center;
  font-weight: 500;
}

.history-list {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding-right: 4px; /* 为滚动条留出空间 */
}

.history-item {
  background: rgba(179, 157, 219, 0.05);
  border-radius: 12px;
  padding: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid rgba(179, 157, 219, 0.1);
}

.history-item:hover {
  background: rgba(179, 157, 219, 0.1);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(179, 157, 219, 0.2);
}

.history-topic {
  font-size: 14px;
  font-weight: 600;
  color: #333;
  margin-bottom: 6px;
  line-height: 1.4;
}

.history-time {
  font-size: 12px;
  color: #888;
}

/* 主内容区域 */
.main-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  max-width: 800px;
  width: 100%;
  position: relative;
  z-index: 1;
}

/* 页面标题 */
.header-section {
  text-align: center;
  margin-bottom: 48px;
}

.main-title {
  font-size: 48px;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #ff6b6b 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin-bottom: 12px;
  letter-spacing: 2px;
}

.subtitle {
  font-size: 16px;
  color: #666;
  font-weight: 400;
}

/* 输入区域 */
.input-section {
  width: 100%;
  max-width: 700px;
  margin-bottom: 60px;
}

.input-container {
  display: flex;
  align-items: center;
  gap: 12px;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 50px;
  padding: 8px;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(102, 126, 234, 0.1);
  backdrop-filter: blur(10px);
}

.topic-input {
  flex: 1;
  padding: 16px 24px;
  border: none;
  outline: none;
  font-size: 16px;
  background: transparent;
  color: #333;
}

.topic-input::placeholder {
  color: #999;
}

.generate-button {
  background: linear-gradient(135deg, #b39ddb 0%, #9c88ff 100%);
  color: white;
  border: none;
  border-radius: 50px;
  padding: 16px 32px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  white-space: nowrap;
}

.generate-button:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 6px 20px rgba(179, 157, 219, 0.4);
}

.generate-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}





/* 响应式设计 */
@media (max-width: 1200px) {
  .ai-writing-container {
    padding: 20px;
    padding-right: 340px;
  }
  
  .history-sidebar {
    width: 300px;
    right: 20px;
    top: 20px;
  }
  
  .main-content {
    max-width: 600px;
  }
}

@media (max-width: 768px) {
  .ai-writing-container {
    padding: 15px;
    flex-direction: column;
    align-items: center;
    padding-right: 15px;
  }
  
  .main-content {
    max-width: 100%;
    order: 1;
  }
  
  .main-title {
    font-size: 36px;
    letter-spacing: 1px;
  }
  
  .header-section {
    margin-bottom: 40px;
  }
  
  .input-section {
    max-width: 100%;
    margin-bottom: 40px;
  }
  
  .input-container {
    flex-direction: column;
    border-radius: 20px;
    padding: 20px;
    gap: 16px;
  }
  
  .topic-input {
    width: 100%;
    text-align: center;
    padding: 16px 20px;
  }
  
  .generate-button {
    border-radius: 12px;
    width: 100%;
    padding: 16px 24px;
  }
  
  .history-sidebar {
    position: relative;
    width: 100%;
    height: 250px;
    top: auto;
    right: auto;
    margin-top: 30px;
    order: 2;
  }
  
  .history-header {
    padding: 16px 20px;
  }
  
  .history-content {
    padding: 20px;
  }
  
  .back-button {
    top: 15px;
    left: 15px;
    padding: 6px 10px;
    font-size: 13px;
  }
}

@media (max-width: 480px) {
  .main-title {
    font-size: 28px;
  }
  
  .subtitle {
    font-size: 14px;
  }
  
  .input-container {
    padding: 16px;
  }
  
  .history-sidebar {
    height: 180px;
  }
  
  .history-header {
    padding: 12px 16px;
  }
  
  .history-title {
    font-size: 14px;
  }
  
  .history-subtitle {
    font-size: 11px;
  }
  
  .empty-icon {
    font-size: 36px;
  }
  
  .empty-text {
    font-size: 13px;
  }
}
</style>