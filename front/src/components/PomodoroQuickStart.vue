<template>
  <div class="pomodoro-quick-start">
    <!-- 快速启动按钮 -->
    <div 
      v-if="!globalPomodoro.state.isRunning && !globalPomodoro.state.showFloatingTimer"
      class="quick-start-btn"
      @click="quickStart"
      title="快速开始番茄钟"
    >
      <span class="icon">🍅</span>
      <span>番茄钟</span>
    </div>
    
    <!-- 运行状态指示器 -->
    <div 
      v-else-if="globalPomodoro.state.isRunning"
      class="running-indicator"
      @click="showFloatingTimer"
      title="点击查看番茄钟详情"
    >
      <div class="timer-mini">
        <span class="icon">{{ globalPomodoro.state.isStudyMode ? '📚' : '☕' }}</span>
        <span class="mini-time">{{ globalPomodoro.computed.formattedTime.value }}</span>
      </div>
      
      <!-- 迷你进度条 -->
      <div class="mini-progress">
        <div 
          class="mini-progress-fill" 
          :style="{ width: globalPomodoro.computed.progress.value + '%' }"
        ></div>
      </div>
    </div>
    
    <!-- 悬浮计时器已显示时的快捷操作 -->
    <div 
      v-else-if="globalPomodoro.state.showFloatingTimer"
      class="floating-controls"
    >
      <button 
        @click="toggleFloatingTimer"
        class="toggle-btn"
        :title="globalPomodoro.state.showFloatingTimer ? '隐藏番茄钟' : '显示番茄钟'"
      >
        <span class="icon">👁️</span>
      </button>
    </div>
    
    <!-- 快速时间选择菜单 -->
    <div v-if="showQuickMenu" class="quick-menu" @click.stop>
      <div class="menu-header">
        <h4>快速开始</h4>
        <button @click="showQuickMenu = false" class="close-btn">
          <span class="icon">❌</span>
        </button>
      </div>
      
      <div class="quick-options">
        <button 
          v-for="option in quickOptions" 
          :key="option.value"
          @click="startWithTime(option.value)"
          class="quick-option"
        >
          <div class="option-icon">
            <span class="icon">{{ option.icon }}</span>
          </div>
          <div class="option-content">
            <span class="option-title">{{ option.label }}</span>
            <small class="option-desc">{{ option.description }}</small>
          </div>
        </button>
      </div>
      
      <div class="menu-footer">
        <button @click="openDetailPage" class="detail-btn">
          <span class="icon">⚙️</span>
          详细设置
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useGlobalPomodoro } from '@/store/pomodoro.js'

export default {
  name: 'PomodoroQuickStart',
  
  setup() {
    const router = useRouter()
    const globalPomodoro = useGlobalPomodoro()
    const showQuickMenu = ref(false)
    
    // 快速选项
    const quickOptions = [
      {
        value: 25,
        label: '标准学习',
        description: '25分钟专注时间',
        icon: '📚'
      },
      {
        value: 15,
        label: '短时学习',
        description: '15分钟快速专注',
        icon: '⚡'
      },
      {
        value: 45,
        label: '深度学习',
        description: '45分钟深度专注',
        icon: '🧠'
      },
      {
        value: 5,
        label: '休息',
        description: '5分钟放松时间',
        icon: '☕'
      }
    ]
    
    // 方法
    const quickStart = () => {
      showQuickMenu.value = true
    }
    
    const startWithTime = (minutes) => {
      const isStudy = minutes > 10 // 大于10分钟的认为是学习时间
      globalPomodoro.actions.switchMode(isStudy, minutes)
      globalPomodoro.actions.startTimer()
      
      // 显示悬浮计时器
      if (!globalPomodoro.state.showFloatingTimer) {
        globalPomodoro.actions.toggleFloatingTimer()
      }
      
      showQuickMenu.value = false
    }
    
    const showFloatingTimer = () => {
      if (!globalPomodoro.state.showFloatingTimer) {
        globalPomodoro.actions.toggleFloatingTimer()
      }
    }
    
    const toggleFloatingTimer = () => {
      globalPomodoro.actions.toggleFloatingTimer()
    }
    
    const openDetailPage = () => {
      router.push('/pomodoro')
      showQuickMenu.value = false
    }
    
    // 点击外部关闭菜单
    const handleClickOutside = (event) => {
      if (!event.target.closest('.pomodoro-quick-start')) {
        showQuickMenu.value = false
      }
    }
    
    // 添加全局点击监听
    document.addEventListener('click', handleClickOutside)
    
    return {
      globalPomodoro,
      showQuickMenu,
      quickOptions,
      quickStart,
      startWithTime,
      showFloatingTimer,
      toggleFloatingTimer,
      openDetailPage
    }
  }
}
</script>

<style scoped>
.pomodoro-quick-start {
  position: relative;
  display: inline-block;
}

/* 通用图标样式 */
.icon {
  display: inline-block;
  font-style: normal;
  line-height: 1;
  vertical-align: middle;
  user-select: none;
}

/* 快速启动按钮 */
.quick-start-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  padding: 6px 10px;
  background: linear-gradient(135deg, #4CAF50, #66BB6A);
  color: white;
  border-radius: 16px;
  cursor: pointer;
  font-size: 11px;
  font-weight: 500;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(76, 175, 80, 0.3);
  white-space: nowrap;
  flex-shrink: 0;
  min-width: 80px;
  height: 32px;
}

.quick-start-btn:hover {
  background: linear-gradient(135deg, #45a049, #5cb85c);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.4);
}

.quick-start-btn .icon {
  font-size: 12px;
  display: inline-block;
  line-height: 1;
  flex-shrink: 0;
}

/* 运行状态指示器 */
.running-indicator {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 6px 10px;
  background: rgba(76, 175, 80, 0.1);
  border: 1px solid #4CAF50;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 80px;
}

.running-indicator:hover {
  background: rgba(76, 175, 80, 0.2);
  transform: scale(1.05);
}

.timer-mini {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 11px;
  font-weight: bold;
  color: #4CAF50;
}

.timer-mini i {
  font-size: 12px;
}

.mini-time {
  font-family: 'Courier New', monospace;
}

.mini-progress {
  width: 100%;
  height: 2px;
  background: rgba(76, 175, 80, 0.2);
  border-radius: 1px;
  overflow: hidden;
}

.mini-progress-fill {
  height: 100%;
  background: #4CAF50;
  border-radius: 1px;
  transition: width 0.3s ease;
}

/* 悬浮控制器 */
.floating-controls {
  display: flex;
  align-items: center;
}

.toggle-btn {
  width: 32px;
  height: 32px;
  border: none;
  border-radius: 50%;
  background: #f5f5f5;
  color: #666;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  transition: all 0.3s;
}

.toggle-btn:hover {
  background: #e0e0e0;
  color: #4CAF50;
  transform: scale(1.1);
}

/* 快速菜单 */
.quick-menu {
  position: absolute;
  top: 100%;
  right: 0;
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  padding: 0;
  margin-top: 8px;
  min-width: 200px;
  z-index: 1000;
  border: 1px solid rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.menu-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: #f8f9fa;
  border-bottom: 1px solid #e9ecef;
}

.menu-header h4 {
  margin: 0;
  font-size: 14px;
  color: #333;
  font-weight: 600;
}

.close-btn {
  width: 20px;
  height: 20px;
  border: none;
  background: none;
  color: #999;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  font-size: 10px;
  transition: all 0.2s;
}

.close-btn:hover {
  background: #e9ecef;
  color: #666;
}

/* 快速选项 */
.quick-options {
  padding: 8px;
}

.quick-option {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border: none;
  background: none;
  cursor: pointer;
  border-radius: 10px;
  transition: all 0.3s ease;
  text-align: left;
  border: 1px solid rgba(76, 175, 80, 0.1);
}

/* 根据不同的学习模式设置图标样式 */
.quick-option:nth-child(1) .option-icon {
  --icon-gradient: linear-gradient(135deg, #4CAF50, #2E7D32);
  --icon-shadow: rgba(46, 125, 50, 0.3);
}
.quick-option:nth-child(1) .option-icon::before {
  content: "";
  position: absolute;
  width: 100%;
  height: 100%;
  background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="45" fill="%23e53935"/><path d="M50,10 C30,10 15,25 15,45 C15,65 30,80 50,80 C70,80 85,65 85,45 C85,25 70,10 50,10 Z" fill="%23c62828"/><path d="M50,15 C45,5 30,10 30,20 C30,30 40,30 50,40" fill="%234CAF50"/><path d="M60,10 C55,10 55,15 60,20" fill="%234CAF50"/></svg>');
  background-size: contain;
  background-position: center;
  background-repeat: no-repeat;
  opacity: 0.6;
  z-index: 0;
  transition: all 0.3s ease;
}

.quick-option:nth-child(2) .option-icon {
  --icon-gradient: linear-gradient(135deg, #66BB6A, #43A047);
  --icon-shadow: rgba(67, 160, 71, 0.3);
}
.quick-option:nth-child(2) .option-icon::before {
  content: "";
  position: absolute;
  width: 100%;
  height: 100%;
  background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="45" fill="%23e53935"/><ellipse cx="50" cy="50" rx="25" ry="35" fill="%23c62828"/><circle cx="38" cy="45" r="4" fill="%23ffcdd2"/><circle cx="46" cy="45" r="4" fill="%23ffcdd2"/><circle cx="54" cy="45" r="4" fill="%23ffcdd2"/><circle cx="62" cy="45" r="4" fill="%23ffcdd2"/><path d="M50,15 C45,5 35,10 35,15 C35,25 45,25 50,30" fill="%234CAF50"/></svg>');
  background-size: contain;
  background-position: center;
  background-repeat: no-repeat;
  opacity: 0.6;
  z-index: 0;
  transition: all 0.3s ease;
}

.quick-option:nth-child(3) .option-icon {
  --icon-gradient: linear-gradient(135deg, #388E3C, #1B5E20);
  --icon-shadow: rgba(27, 94, 32, 0.3);
}
.quick-option:nth-child(3) .option-icon::before {
  content: "";
  position: absolute;
  width: 100%;
  height: 100%;
  background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="45" fill="%23e53935"/><circle cx="50" cy="50" r="30" fill="%23c62828"/><circle cx="65" cy="35" r="7" fill="%23ffcdd2"/><path d="M50,10 C40,5 30,15 35,20 C40,25 45,20 50,15" fill="%234CAF50"/><path d="M60,5 C55,5 55,10 60,15" fill="%234CAF50"/></svg>');
  background-size: contain;
  background-position: center;
  background-repeat: no-repeat;
  opacity: 0.6;
  z-index: 0;
  transition: all 0.3s ease;
}

.quick-option:nth-child(4) .option-icon {
  --icon-gradient: linear-gradient(135deg, #81C784, #66BB6A);
  --icon-shadow: rgba(129, 199, 132, 0.3);
}
.quick-option:nth-child(4) .option-icon::before {
  content: "";
  position: absolute;
  width: 100%;
  height: 100%;
  background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="45" fill="%23e53935"/><path d="M50,95 C70,95 85,80 85,60 L50,60 L50,95 Z" fill="%23c62828"/><path d="M50,10 C40,5 30,15 35,20 C40,25 45,20 50,15" fill="%234CAF50"/><path d="M65,5 C60,5 60,10 65,15" fill="%234CAF50"/></svg>');
  background-size: contain;
  background-position: center;
  background-repeat: no-repeat;
  opacity: 0.6;
  z-index: 0;
  transition: all 0.3s ease;
}

.quick-option:hover {
  background: linear-gradient(135deg, #f1f8e9, #e8f5e8);
  border-color: rgba(76, 175, 80, 0.3);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.15);
}

.option-icon {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  background: var(--icon-gradient, linear-gradient(135deg, #4CAF50, #66BB6A));
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 2px 8px var(--icon-shadow, rgba(76, 175, 80, 0.3));
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.option-icon .icon {
  font-size: 16px;
  color: white;
  filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.2));
  position: relative;
  z-index: 1;
  display: inline-block;
}

.quick-option:hover .option-icon {
  transform: scale(1.05);
  box-shadow: 0 3px 10px var(--icon-shadow, rgba(76, 175, 80, 0.4));
}

.quick-option:hover .option-icon::before {
  opacity: 0.8;
  transform: scale(1.1);
}

.quick-option:hover .option-icon .icon {
  animation: iconPulse 0.6s ease-in-out;
}

@keyframes iconPulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.2); }
  100% { transform: scale(1); }
}

.option-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.option-title {
  font-weight: 600;
  color: #333;
  font-size: 14px;
  line-height: 1.2;
}

.option-desc {
  color: #666;
  font-size: 11px;
  line-height: 1.3;
}

/* 菜单底部 */
.menu-footer {
  padding: 8px;
  border-top: 1px solid #e9ecef;
  background: #f8f9fa;
}

.detail-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 8px;
  border: none;
  background: none;
  color: #666;
  cursor: pointer;
  border-radius: 6px;
  font-size: 12px;
  transition: all 0.2s;
}

.detail-btn:hover {
  background: #e9ecef;
  color: #4CAF50;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .quick-start-btn {
    padding: 6px 10px;
    font-size: 11px;
  }
  
  .quick-start-btn span {
    display: none;
  }
  
  .running-indicator {
    min-width: 60px;
    padding: 4px 8px;
  }
  
  .timer-mini {
    font-size: 10px;
  }
  
  .quick-menu {
    right: -50%;
    min-width: 180px;
  }
}

/* 动画效果 */
.quick-menu {
  animation: slideIn 0.2s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-10px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.running-indicator {
  animation: pulse 2s infinite ease-in-out;
}

@keyframes pulse {
  0%, 100% { 
    transform: scale(1); 
    opacity: 1;
  }
  50% { 
    transform: scale(1.02); 
    opacity: 0.9;
  }
}

/* 高对比度模式支持 */
@media (prefers-contrast: high) {
  .quick-start-btn,
  .running-indicator {
    border: 2px solid #333;
  }
  
  .quick-menu {
    border: 2px solid #333;
  }
}

/* 减少动画模式 */
@media (prefers-reduced-motion: reduce) {
  .quick-start-btn,
  .running-indicator,
  .toggle-btn,
  .quick-option {
    transition: none;
  }
  
  .running-indicator {
    animation: none;
  }
  
  .quick-menu {
    animation: none;
  }
}
</style>

