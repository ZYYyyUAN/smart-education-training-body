<template>
  <div 
    v-if="globalPomodoro.state.showFloatingTimer"
    class="floating-pomodoro"
    :class="{ 
      'minimized': globalPomodoro.state.isMinimized,
      'study-mode': globalPomodoro.state.isStudyMode,
      'rest-mode': !globalPomodoro.state.isStudyMode,
      'running': globalPomodoro.state.isRunning,
      'dragging': isDragging
    }"
    :style="{ 
      top: position.y + 'px', 
      left: position.x + 'px',
      zIndex: 9999
    }"
    @mousedown="startDrag"
    @touchstart="startDrag"
  >
    <!-- 最小化状态 -->
    <div v-if="globalPomodoro.state.isMinimized" class="minimized-timer">
      <div class="mini-display" @click="toggleMinimize">
        <div class="mini-time">{{ globalPomodoro.computed.formattedTime.value }}</div>
        <div class="mini-status">
          <i :class="globalPomodoro.state.isStudyMode ? 'fas fa-book' : 'fas fa-coffee'"></i>
        </div>
      </div>
      
      <!-- 进度环 -->
      <svg class="mini-progress" width="60" height="60" viewBox="0 0 60 60">
        <circle
          cx="30"
          cy="30"
          r="26"
          fill="none"
          stroke="rgba(255,255,255,0.2)"
          stroke-width="3"
        />
        <circle
          cx="30"
          cy="30"
          r="26"
          fill="none"
          :stroke="globalPomodoro.state.isStudyMode ? '#4CAF50' : '#FF9800'"
          stroke-width="3"
          stroke-linecap="round"
          :stroke-dasharray="circumference"
          :stroke-dashoffset="progressOffset"
          transform="rotate(-90 30 30)"
          class="progress-circle"
        />
      </svg>
    </div>
    
    <!-- 展开状态 -->
    <div v-else class="expanded-timer">
      <!-- 头部 -->
      <div class="timer-header">
        <div class="mode-indicator">
          <i :class="globalPomodoro.state.isStudyMode ? 'fas fa-book' : 'fas fa-coffee'"></i>
          <span>{{ globalPomodoro.computed.statusText.value }}</span>
        </div>
        
        <div class="header-actions">
          <div class="header-btn-wrapper" :title="'最小化番茄钟'">
            <button @click="toggleMinimize" class="action-btn minimize-btn">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" class="minimize-icon">
                <path d="M4 14L10 20L16 14M4 10L10 4L16 10" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </button>
          </div>
          <div class="header-btn-wrapper" :title="'关闭番茄钟'">
            <button @click="closeTimer" class="action-btn close-btn">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" class="close-icon">
                <path d="M18 6L6 18M6 6L18 18" stroke="#FF3B30" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </button>
          </div>
        </div>
      </div>
      
      <!-- 时间显示 -->
      <div class="time-display">
        <div class="mode-text">{{ globalPomodoro.state.isStudyMode ? '专注学习' : '准备休息' }}</div>
        <div class="main-time">{{ globalPomodoro.computed.formattedTime.value }}</div>
        <div class="progress-bar">
          <div 
            class="progress-fill" 
            :style="{ width: globalPomodoro.computed.progress.value + '%' }"
          ></div>
        </div>
      </div>
      
      <!-- 控制按钮 -->
      <div class="control-buttons">
        <button 
          v-if="!globalPomodoro.state.isRunning" 
          @click="startTimer" 
          class="control-btn start-btn"
          :disabled="globalPomodoro.state.currentTime === 0"
          title="开始计时"
        >
          <i class="fas fa-play-circle"></i>
          <span>开始</span>
        </button>
        
        <button 
          v-if="globalPomodoro.state.isRunning" 
          @click="pauseTimer" 
          class="control-btn pause-btn"
          title="暂停计时"
        >
          <i class="fas fa-pause-circle"></i>
          <span>暂停</span>
        </button>
        
        <button @click="resetTimer" class="control-btn reset-btn" title="重置计时">
          <i class="fas fa-redo-alt"></i>
          <span>重置</span>
        </button>
        
        <button @click="showTimeSelector" class="control-btn settings-btn" title="时间设置">
          <i class="fas fa-cog"></i>
          <span>设置</span>
        </button>
      </div>
      
      <!-- 今日统计 -->
      <div class="daily-stats">
        <div class="stat-item" @click="showStatTooltip('pomodoros')">
          <i class="fas fa-trophy"></i>
          <span>{{ globalPomodoro.state.completedPomodoros }}</span>
          <div v-if="activeTooltip === 'pomodoros'" class="stat-tooltip">
            <h4>完成番茄数</h4>
            <p>今日已完成 {{ globalPomodoro.state.completedPomodoros }} 个番茄钟</p>
            <div class="tooltip-goal">
              <span>日目标: 8个</span>
              <div class="goal-progress">
                <div class="goal-progress-fill" :style="{ width: globalPomodoro.computed.todayProgress.value + '%' }"></div>
              </div>
              <span>{{ Math.floor(globalPomodoro.computed.todayProgress.value) }}%</span>
            </div>
          </div>
        </div>
        <div class="stat-item" @click="showStatTooltip('streak')">
          <i class="fas fa-fire"></i>
          <span>{{ globalPomodoro.state.streakDays }}</span>
          <div v-if="activeTooltip === 'streak'" class="stat-tooltip">
            <h4>连续使用天数</h4>
            <p>已连续使用 {{ globalPomodoro.state.streakDays }} 天</p>
            <p v-if="globalPomodoro.state.streakDays > 0" class="streak-tip">继续保持！</p>
            <p v-else class="streak-tip">今天开始培养习惯吧！</p>
          </div>
        </div>
        <div class="stat-item" @click="openDetailPage">
          <i class="fas fa-comment-alt"></i>
          <span>评楮</span>
        </div>
      </div>
    </div>
    
    <!-- 时间选择快捷菜单 -->
    <div v-if="showQuickSelector" class="quick-selector" @click.stop>
      <h4>
        <i :class="globalPomodoro.state.isStudyMode ? 'fas fa-book' : 'fas fa-coffee'"></i>
        {{ globalPomodoro.state.isStudyMode ? '学习时间' : '休息时间' }}
      </h4>
      
      <div class="time-options">
        <button 
          v-for="option in timeOptions" 
          :key="option.value"
          @click="selectTime(option.value)"
          class="time-option"
        >
          {{ option.label }}
        </button>
      </div>
      
      <div class="custom-input">
        <input 
          v-model.number="customMinutes" 
          type="number" 
          min="1" 
          max="120"
          placeholder="自定义"
          @keyup.enter="selectTime(customMinutes)"
        />
        <button @click="selectTime(customMinutes)" :disabled="!customMinutes">
          确定
        </button>
      </div>
      
      <button @click="showQuickSelector = false" class="close-selector">
        <i class="fas fa-times"></i>
      </button>
    </div>
    
    <!-- 完成提醒弹窗 -->
    <div v-if="globalPomodoro.state.showCompletionDialog" class="completion-popup" @click.stop>
      <div class="popup-content">
        <div class="completion-icon">
          <i :class="globalPomodoro.state.isStudyMode ? 'fas fa-check-circle' : 'fas fa-play-circle'"></i>
        </div>
        
        <h3>{{ globalPomodoro.state.isStudyMode ? '学习完成！' : '休息结束！' }}</h3>
        
        <p v-if="globalPomodoro.state.isStudyMode">
          恭喜完成 {{ Math.floor(globalPomodoro.state.totalTime / 60) }} 分钟的专注学习！
          <span v-if="globalPomodoro.state.completionData.isLongRest">建议进行长休息。</span>
        </p>
        <p v-else>
          休息结束，准备开始新的学习吧！
        </p>
        
        <div class="completion-actions">
          <button 
            v-if="globalPomodoro.state.isStudyMode"
            @click="startRest"
            class="action-btn rest-btn"
          >
            <i class="fas fa-coffee"></i>
            休息 {{ globalPomodoro.state.completionData.restTime }}分钟
          </button>
          
          <button 
            @click="continueMode"
            class="action-btn continue-btn"
          >
            <i :class="globalPomodoro.state.isStudyMode ? 'fas fa-play' : 'fas fa-book'"></i>
            {{ globalPomodoro.state.isStudyMode ? '继续学习' : '开始学习' }}
          </button>
          
          <button 
            @click="finishSession"
            class="action-btn finish-btn"
          >
            <i class="fas fa-stop"></i>
            结束
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useGlobalPomodoro } from '@/store/pomodoro.js'

export default {
  name: 'FloatingPomodoroTimer',
  
  setup() {
    const router = useRouter()
    const globalPomodoro = useGlobalPomodoro()
    
    // 组件状态
    const showQuickSelector = ref(false)
    const customMinutes = ref(null)
    const isDragging = ref(false)
    const dragStart = ref({ x: 0, y: 0 })
    const position = ref({ x: 20, y: 100 }) // 初始位置
    const activeTooltip = ref(null) // 当前活动的工具提示
    
    // 圆形进度条相关
    const radius = 26
    const circumference = 2 * Math.PI * radius
    
    // 计算属性
    const progressOffset = computed(() => {
      const progress = globalPomodoro.computed.progress.value
      return circumference - (progress / 100) * circumference
    })
    
    const timeOptions = computed(() => {
      if (globalPomodoro.state.isStudyMode) {
        return [
          { value: 15, label: '15分钟' },
          { value: 25, label: '25分钟' },
          { value: 30, label: '30分钟' },
          { value: 45, label: '45分钟' }
        ]
      } else {
        return [
          { value: 5, label: '5分钟' },
          { value: 10, label: '10分钟' },
          { value: 15, label: '15分钟' },
          { value: 20, label: '20分钟' }
        ]
      }
    })
    
    // 方法
    const toggleMinimize = () => {
      globalPomodoro.actions.toggleMinimize()
    }
    
    const closeTimer = () => {
      globalPomodoro.actions.toggleFloatingTimer()
    }
    
    const startTimer = () => {
      globalPomodoro.actions.startTimer()
    }
    
    const pauseTimer = () => {
      globalPomodoro.actions.pauseTimer()
    }
    
    const resetTimer = () => {
      globalPomodoro.actions.resetTimer()
    }
    
    const showTimeSelector = () => {
      showQuickSelector.value = true
    }
    
    const selectTime = (minutes) => {
      if (minutes && minutes > 0) {
        globalPomodoro.actions.switchMode(globalPomodoro.state.isStudyMode, minutes)
        showQuickSelector.value = false
        customMinutes.value = null
      }
    }
    
    const openDetailPage = () => {
      router.push('/pomodoro')
    }
    
    // 统计工具提示
    const showStatTooltip = (type) => {
      if (activeTooltip.value === type) {
        // 如果已经显示，则关闭
        activeTooltip.value = null
      } else {
        // 显示选择的工具提示
        activeTooltip.value = type
        
        // 5秒后自动关闭
        setTimeout(() => {
          if (activeTooltip.value === type) {
            activeTooltip.value = null
          }
        }, 5000)
        
        // 如果是第一次点击，显示提示信息
        const hasShownTip = localStorage.getItem('pomodoro-stats-tip-shown')
        if (!hasShownTip) {
          console.log('🍅 提示: 点击番茄钟统计数字可以查看详细信息')
          localStorage.setItem('pomodoro-stats-tip-shown', 'true')
        }
      }
    }
    
    // 点击文档其他位置关闭工具提示
    const handleDocumentClick = (event) => {
      if (activeTooltip.value && !event.target.closest('.stat-item')) {
        activeTooltip.value = null
      }
    }
    
    // 生命周期钩子中添加监听
    onMounted(() => {
      document.addEventListener('click', handleDocumentClick)
    })
    
    onUnmounted(() => {
      document.removeEventListener('click', handleDocumentClick)
    })
    
    // 完成对话框操作
    const startRest = () => {
      const restTime = globalPomodoro.state.completionData.restTime || globalPomodoro.state.settings.defaultRestTime
      globalPomodoro.actions.switchMode(false, restTime)
    }
    
    const continueMode = () => {
      if (globalPomodoro.state.isStudyMode) {
        // 继续学习
        showQuickSelector.value = true
      } else {
        // 开始学习
        globalPomodoro.actions.switchMode(true, globalPomodoro.state.settings.defaultStudyTime)
      }
    }
    
    const finishSession = () => {
      globalPomodoro.state.showCompletionDialog = false
      globalPomodoro.actions.resetTimer()
    }
    
    // 拖拽功能
    const startDrag = (event) => {
      if (event.target.closest('.control-btn, .action-btn, .time-option, input, button')) {
        return // 不在这些元素上启动拖拽
      }
      
      event.preventDefault()
      isDragging.value = true
      
      const clientX = event.clientX || event.touches[0].clientX
      const clientY = event.clientY || event.touches[0].clientY
      
      dragStart.value = {
        x: clientX - position.value.x,
        y: clientY - position.value.y
      }
      
      document.addEventListener('mousemove', handleDrag)
      document.addEventListener('mouseup', endDrag)
      document.addEventListener('touchmove', handleDrag)
      document.addEventListener('touchend', endDrag)
    }
    
    const handleDrag = (event) => {
      if (!isDragging.value) return
      
      event.preventDefault()
      
      const clientX = event.clientX || event.touches[0].clientX
      const clientY = event.clientY || event.touches[0].clientY
      
      const newX = Math.max(0, Math.min(window.innerWidth - 300, clientX - dragStart.value.x))
      const newY = Math.max(0, Math.min(window.innerHeight - 200, clientY - dragStart.value.y))
      
      position.value = { x: newX, y: newY }
    }
    
    const endDrag = () => {
      isDragging.value = false
      
      document.removeEventListener('mousemove', handleDrag)
      document.removeEventListener('mouseup', endDrag)
      document.removeEventListener('touchmove', handleDrag)
      document.removeEventListener('touchend', endDrag)
      
      // 保存位置
      localStorage.setItem('floating-pomodoro-position', JSON.stringify(position.value))
    }
    
    // 加载位置
    const loadPosition = () => {
      try {
        const saved = localStorage.getItem('floating-pomodoro-position')
        if (saved) {
          const savedPosition = JSON.parse(saved)
          // 确保位置在屏幕范围内
          position.value = {
            x: Math.max(0, Math.min(window.innerWidth - 300, savedPosition.x)),
            y: Math.max(0, Math.min(window.innerHeight - 200, savedPosition.y))
          }
        }
      } catch (error) {
        console.warn('位置加载失败:', error)
      }
    }
    
    // 键盘快捷键
    const handleKeyboard = (event) => {
      if (!globalPomodoro.state.settings.enableGlobalHotkeys) return
      
      // Ctrl + Space: 开始/暂停
      if (event.ctrlKey && event.code === 'Space') {
        event.preventDefault()
        if (globalPomodoro.state.isRunning) {
          pauseTimer()
        } else {
          startTimer()
        }
      }
      
      // Ctrl + R: 重置 (需要防止浏览器刷新)
      if (event.ctrlKey && event.key === 'r') {
        event.preventDefault()
        resetTimer()
      }
      
      // Ctrl + T: 切换显示
      if (event.ctrlKey && event.key === 't') {
        event.preventDefault()
        toggleMinimize()
      }
    }
    
    // 生命周期
    onMounted(() => {
      loadPosition()
      
      // 添加键盘监听
      document.addEventListener('keydown', handleKeyboard)
      
      // 监听窗口大小变化，调整位置
      window.addEventListener('resize', () => {
        position.value = {
          x: Math.max(0, Math.min(window.innerWidth - 300, position.value.x)),
          y: Math.max(0, Math.min(window.innerHeight - 200, position.value.y))
        }
      })
    })
    
    onUnmounted(() => {
      document.removeEventListener('keydown', handleKeyboard)
      document.removeEventListener('mousemove', handleDrag)
      document.removeEventListener('mouseup', endDrag)
      document.removeEventListener('touchmove', handleDrag)
      document.removeEventListener('touchend', endDrag)
    })
    
    return {
      globalPomodoro,
      showQuickSelector,
      customMinutes,
      isDragging,
      position,
      circumference,
      progressOffset,
      timeOptions,
      activeTooltip,
      
      toggleMinimize,
      closeTimer,
      startTimer,
      pauseTimer,
      resetTimer,
      showTimeSelector,
      selectTime,
      openDetailPage,
      showStatTooltip,
      startRest,
      continueMode,
      finishSession,
      startDrag
    }
  }
}
</script>

<style scoped>
.floating-pomodoro {
  position: fixed;
  background: white;
  border-radius: 15px;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  user-select: none;
  cursor: move;
  transition: all 0.3s ease;
  max-width: 280px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.floating-pomodoro:hover {
  box-shadow: 0 12px 35px rgba(0, 0, 0, 0.2);
}

.floating-pomodoro.dragging {
  transition: none;
  transform: scale(1.02);
}

.floating-pomodoro.study-mode {
  border-left: 4px solid #4CAF50;
}

.floating-pomodoro.rest-mode {
  border-left: 4px solid #FF9800;
}

.floating-pomodoro.running {
  animation: pulse 2s infinite ease-in-out;
}

/* 最小化状态 */
.minimized-timer {
  position: relative;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.mini-display {
  position: absolute;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  z-index: 2;
}

.mini-time {
  font-size: 10px;
  font-weight: bold;
  color: #333;
  font-family: 'Courier New', monospace;
}

.mini-status {
  font-size: 12px;
  color: #666;
  margin-top: 2px;
}

.mini-progress {
  position: absolute;
  top: 0;
  left: 0;
}

.progress-circle {
  transition: stroke-dashoffset 0.3s ease;
}

/* 展开状态 */
.expanded-timer {
  padding: 15px;
  min-width: 250px;
}

.timer-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.mode-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #666;
  font-size: 12px;
}

.mode-indicator i {
  font-size: 14px;
  color: #4CAF50;
}

.rest-mode .mode-indicator i {
  color: #FF9800;
}

.header-actions {
  display: flex;
  gap: 5px;
}

.header-btn-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.action-btn {
  width: 24px;
  height: 24px;
  border: none;
  border-radius: 50%;
  background: #f5f5f5;
  color: #666;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 10px;
  transition: all 0.3s ease;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  position: relative;
  overflow: hidden;
}

.close-icon {
  transform: scale(1.2);
}

.minimize-icon {
  transform: scale(0.9);
  color: #333;
}

.action-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: radial-gradient(circle, rgba(255,255,255,0.8) 0%, rgba(255,255,255,0) 70%);
  opacity: 0;
  transform: scale(0);
  transition: transform 0.5s ease, opacity 0.3s ease;
}

.action-btn:hover {
  background: #e0e0e0;
  transform: scale(1.15);
  box-shadow: 0 2px 5px rgba(0,0,0,0.15);
}

.action-btn:hover::before {
  opacity: 1;
  transform: scale(2);
}

.action-btn:active {
  transform: scale(0.95);
}

.minimize-btn:hover {
  background: #e3f2fd;
}

.minimize-btn:hover .minimize-icon {
  color: #2196F3;
  transform: scale(1);
}

.close-btn:hover {
  background: #ffebee;
}

.close-btn:hover .close-icon path {
  stroke: #f44336;
  stroke-width: 3.5;
}

/* 时间显示 */
.time-display {
  text-align: center;
  margin-bottom: 15px;
}

.mode-text {
  font-size: 14px;
  color: #666;
  margin-bottom: 4px;
  font-weight: 500;
}

.main-time {
  font-size: 28px;
  font-weight: bold;
  color: #333;
  font-family: 'Courier New', monospace;
  margin-bottom: 8px;
}

.progress-bar {
  width: 100%;
  height: 4px;
  background: #e0e0e0;
  border-radius: 2px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: #4CAF50;
  border-radius: 2px;
  transition: width 0.3s ease;
}

.rest-mode .progress-fill {
  background: #FF9800;
}

/* 控制按钮 */
.control-buttons {
  display: flex;
  justify-content: center;
  gap: 6px;
  margin-bottom: 15px;
}

.control-btn {
  min-width: 50px;
  height: 32px;
  border: none;
  border-radius: 16px;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  font-size: 11px;
  font-weight: 500;
  padding: 0 12px;
  transition: all 0.3s;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
  position: relative;
  overflow: hidden;
}

.control-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.6s ease;
}

.control-btn:hover::before {
  left: 100%;
}

.control-btn:hover i {
  transform: scale(1.15);
}

.control-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.control-btn i {
  font-size: 14px;
  margin-right: 2px;
  transition: transform 0.3s ease;
}

.control-btn span {
  font-size: 10px;
  white-space: nowrap;
}

.control-btn:active {
  transform: translateY(0) scale(0.98);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
}

.start-btn {
  background: linear-gradient(135deg, #4CAF50, #66BB6A);
}

.start-btn:hover:not(:disabled) {
  background: linear-gradient(135deg, #45a049, #5cb85c);
  transform: translateY(-2px);
  box-shadow: 0 6px 15px rgba(76, 175, 80, 0.5);
}

.pause-btn {
  background: linear-gradient(135deg, #FF9800, #FFB74D);
}

.pause-btn:hover {
  background: linear-gradient(135deg, #e68900, #ff9800);
  transform: translateY(-2px);
  box-shadow: 0 6px 15px rgba(255, 152, 0, 0.5);
}

.reset-btn {
  background: linear-gradient(135deg, #9E9E9E, #BDBDBD);
}

.reset-btn:hover {
  background: linear-gradient(135deg, #757575, #9e9e9e);
  transform: translateY(-2px);
  box-shadow: 0 6px 15px rgba(158, 158, 158, 0.5);
}

.settings-btn {
  background: linear-gradient(135deg, #2196F3, #64B5F6);
}

.settings-btn:hover {
  background: linear-gradient(135deg, #1976D2, #2196F3);
  transform: translateY(-2px);
  box-shadow: 0 6px 15px rgba(33, 150, 243, 0.5);
}

/* 统计信息 */
.daily-stats {
  display: flex;
  justify-content: space-around;
  padding-top: 10px;
  border-top: 1px solid #f0f0f0;
  position: relative;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3px;
  font-size: 10px;
  color: #666;
  cursor: pointer;
  padding: 5px;
  border-radius: 5px;
  transition: background 0.2s;
}

.stat-item:hover {
  background: #f5f5f5;
}

.stat-item {
  position: relative;
}

.stat-item i {
  font-size: 13px;
  color: #4CAF50;
  transition: transform 0.3s ease;
}

.stat-item:hover i {
  transform: scale(1.2);
}

.stat-tooltip {
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  background: white;
  border-radius: 8px;
  padding: 12px;
  width: 180px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
  z-index: 100;
  margin-bottom: 10px;
  text-align: center;
  animation: fadeIn 0.2s ease-out;
  border: 1px solid #e0e0e0;
}

.stat-tooltip::after {
  content: '';
  position: absolute;
  bottom: -8px;
  left: 50%;
  transform: translateX(-50%);
  width: 0;
  height: 0;
  border-left: 8px solid transparent;
  border-right: 8px solid transparent;
  border-top: 8px solid white;
}

.stat-tooltip h4 {
  margin: 0 0 8px;
  color: #333;
  font-size: 13px;
  font-weight: 600;
}

.stat-tooltip p {
  margin: 5px 0;
  color: #666;
  font-size: 11px;
}

.streak-tip {
  color: #FF9800 !important;
  font-weight: 500;
}

.tooltip-goal {
  margin-top: 10px;
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.goal-progress {
  width: 100%;
  height: 4px;
  background: #e0e0e0;
  border-radius: 2px;
  overflow: hidden;
}

.goal-progress-fill {
  height: 100%;
  background: #4CAF50;
  border-radius: 2px;
}

@keyframes fadeIn {
  from { 
    opacity: 0;
    transform: translateX(-50%) translateY(10px);
  }
  to { 
    opacity: 1;
    transform: translateX(-50%) translateY(0);
  }
}

/* 时间选择器 */
.quick-selector {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: white;
  border-radius: 10px;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  padding: 15px;
  margin-top: 10px;
  z-index: 10;
}

.quick-selector h4 {
  margin: 0 0 10px 0;
  color: #333;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.time-options {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  margin-bottom: 10px;
}

.time-option {
  padding: 8px;
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  background: white;
  cursor: pointer;
  font-size: 12px;
  transition: all 0.2s;
}

.time-option:hover {
  border-color: #4CAF50;
  background: #f1f8e9;
}

.custom-input {
  display: flex;
  gap: 8px;
  margin-bottom: 10px;
}

.custom-input input {
  flex: 1;
  padding: 6px;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  font-size: 12px;
}

.custom-input button {
  padding: 6px 12px;
  background: #4CAF50;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
}

.custom-input button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.close-selector {
  position: absolute;
  top: 5px;
  right: 5px;
  width: 20px;
  height: 20px;
  border: none;
  background: none;
  color: #999;
  cursor: pointer;
  font-size: 10px;
}

/* 完成弹窗 */
.completion-popup {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: white;
  border-radius: 10px;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  padding: 20px;
  margin-top: 10px;
  z-index: 10;
  text-align: center;
}

.completion-icon i {
  font-size: 32px;
  color: #4CAF50;
  margin-bottom: 10px;
}

.completion-popup h3 {
  margin: 0 0 10px 0;
  color: #333;
  font-size: 16px;
}

.completion-popup p {
  margin: 0 0 15px 0;
  color: #666;
  font-size: 12px;
  line-height: 1.4;
}

.completion-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.completion-actions .action-btn {
  width: 100%;
  height: 36px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: bold;
  gap: 8px;
}

.rest-btn {
  background: #FF9800;
}

.continue-btn {
  background: #4CAF50;
}

.finish-btn {
  background: #9E9E9E;
}

/* 动画效果 */
@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.02); }
  100% { transform: scale(1); }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .floating-pomodoro {
    max-width: 240px;
  }
  
  .expanded-timer {
    padding: 12px;
    min-width: 220px;
  }
  
  .main-time {
    font-size: 24px;
  }
  
  .control-btn {
    width: 32px;
    height: 32px;
    font-size: 12px;
  }
}

/* 高对比度模式 */
@media (prefers-contrast: high) {
  .floating-pomodoro {
    border: 2px solid #000;
  }
  
  .action-btn, .control-btn {
    border: 1px solid #333;
  }
}

/* 减少动画模式 */
@media (prefers-reduced-motion: reduce) {
  .floating-pomodoro,
  .action-btn,
  .control-btn,
  .progress-fill,
  .progress-circle {
    transition: none;
  }
  
  .floating-pomodoro.running {
    animation: none;
  }
}
</style>

