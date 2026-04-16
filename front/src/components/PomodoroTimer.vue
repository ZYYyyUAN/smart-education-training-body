<template>
  <div class="pomodoro-timer">
    <!-- 番茄钟主界面 -->
    <div class="timer-container">
      <div class="timer-circle" :class="{ 'study-mode': isStudyMode, 'rest-mode': !isStudyMode }">
        <div class="timer-content">
          <div class="mode-indicator">
            <i :class="isStudyMode ? 'fas fa-book' : 'fas fa-coffee'"></i>
            <span>{{ isStudyMode ? '学习时间' : '休息时间' }}</span>
          </div>
          
          <div class="time-display">
            {{ formatTime(currentTime) }}
          </div>
          
          <div class="timer-controls">
            <button 
              v-if="!isRunning" 
              @click="startTimer" 
              class="btn btn-start"
            >
              <i class="fas fa-play"></i>
              {{ isStudyMode ? '开始学习' : '开始休息' }}
            </button>
            
            <button 
              v-if="isRunning" 
              @click="pauseTimer" 
              class="btn btn-pause"
            >
              <i class="fas fa-pause"></i>
              暂停
            </button>
            
            <button 
              @click="resetTimer" 
              class="btn btn-reset"
            >
              <i class="fas fa-refresh"></i>
              重置
            </button>
          </div>
        </div>
        
        <!-- 进度圆环 -->
        <svg class="progress-ring" width="280" height="280">
          <circle
            class="progress-ring-background"
            stroke="#e0e0e0"
            stroke-width="8"
            fill="transparent"
            r="130"
            cx="140"
            cy="140"
          />
          <circle
            class="progress-ring-progress"
            :stroke="isStudyMode ? '#4CAF50' : '#FF9800'"
            stroke-width="8"
            fill="transparent"
            r="130"
            cx="140"
            cy="140"
            :style="{ strokeDasharray: circumference, strokeDashoffset: progressOffset }"
            stroke-linecap="round"
          />
        </svg>
      </div>
      
      <!-- 统计信息 -->
      <div class="stats-panel">
        <div class="stat-item">
          <i class="fas fa-trophy"></i>
          <span>完成番茄</span>
          <strong>{{ completedPomodoros }}</strong>
        </div>
        <div class="stat-item">
          <i class="fas fa-clock"></i>
          <span>今日学习</span>
          <strong>{{ formatTotalTime(totalStudyTime) }}</strong>
        </div>
        <div class="stat-item">
          <i class="fas fa-fire"></i>
          <span>连续天数</span>
          <strong>{{ streakDays }}</strong>
        </div>
      </div>
    </div>
    
    <!-- 时间选择对话框 -->
    <div v-if="showTimeSelector" class="modal-overlay" @click="closeTimeSelector">
      <div class="time-selector-modal" @click.stop>
        <h3>
          <i :class="timeSelectionMode === 'study' ? 'fas fa-book' : 'fas fa-coffee'"></i>
          选择{{ timeSelectionMode === 'study' ? '学习' : '休息' }}时间
        </h3>
        
        <div class="time-options">
          <div 
            v-for="option in timeOptions" 
            :key="option.value"
            class="time-option"
            :class="{ 'selected': selectedTime === option.value }"
            @click="selectedTime = option.value"
          >
            <span class="time-value">{{ option.label }}</span>
            <span class="time-description">{{ option.description }}</span>
          </div>
        </div>
        
        <!-- 自定义时间输入 -->
        <div class="custom-time">
          <label>自定义时间（分钟）：</label>
          <input 
            v-model.number="customMinutes" 
            type="number" 
            min="1" 
            max="120"
            placeholder="输入分钟数"
          />
        </div>
        
        <div class="modal-actions">
          <button @click="closeTimeSelector" class="btn btn-secondary">
            取消
          </button>
          <button @click="confirmTimeSelection" class="btn btn-primary">
            确认开始
          </button>
        </div>
      </div>
    </div>
    
    <!-- 完成提醒对话框 -->
    <div v-if="showCompletionDialog" class="modal-overlay">
      <div class="completion-dialog" @click.stop>
        <div class="completion-content">
          <div class="completion-icon">
            <i :class="completionData.icon"></i>
          </div>
          <h3>{{ completionData.title }}</h3>
          <p>{{ completionData.message }}</p>
          
          <div class="completion-actions">
            <button 
              v-for="action in completionData.actions" 
              :key="action.key"
              @click="handleCompletionAction(action.key)"
              class="btn"
              :class="action.class"
            >
              <i :class="action.icon"></i>
              {{ action.label }}
            </button>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 设置面板 -->
    <div class="settings-panel" v-if="showSettings">
      <h4><i class="fas fa-cog"></i> 番茄钟设置</h4>
      
      <div class="setting-group">
        <label>默认学习时间（分钟）</label>
        <input v-model.number="settings.defaultStudyTime" type="number" min="1" max="60" />
      </div>
      
      <div class="setting-group">
        <label>默认休息时间（分钟）</label>
        <input v-model.number="settings.defaultRestTime" type="number" min="1" max="30" />
      </div>
      
      <div class="setting-group">
        <label>长休息时间（分钟）</label>
        <input v-model.number="settings.longRestTime" type="number" min="5" max="60" />
      </div>
      
      <div class="setting-group">
        <label>长休息间隔（个番茄钟后）</label>
        <input v-model.number="settings.longRestInterval" type="number" min="2" max="8" />
      </div>
      
      <div class="setting-group checkbox-group">
        <label>
          <input v-model="settings.enableNotifications" type="checkbox" />
          启用浏览器通知
        </label>
      </div>
      
      
      <div class="setting-actions">
        <button @click="saveSettings" class="btn btn-primary">保存设置</button>
        <button @click="showSettings = false" class="btn btn-secondary">关闭</button>
      </div>
    </div>
    
    <!-- 底部控制栏 -->
    <div class="control-bar">
      <button @click="showSettings = !showSettings" class="control-btn">
        <i class="fas fa-cog"></i>
        <span>设置</span>
      </button>
      
      <button @click="showStatistics" class="control-btn">
        <i class="fas fa-chart-bar"></i>
        <span>统计</span>
      </button>
      
      <button @click="toggleFullscreen" class="control-btn">
        <i class="fas fa-expand"></i>
        <span>全屏</span>
      </button>
    </div>
  </div>
</template>

<script>
import { useGlobalPomodoro } from '@/store/pomodoro.js'

export default {
  name: 'PomodoroTimer',
  
  setup() {
    // 使用全局番茄钟状态
    const globalPomodoro = useGlobalPomodoro()
    
    return {
      globalPomodoro
    }
  },
  
  data() {
    return {
      // 计时器状态
      isRunning: false,
      isStudyMode: true,
      currentTime: 25 * 60, // 当前剩余时间（秒）
      totalTime: 25 * 60,   // 总时间（秒）
      
      // 统计数据
      completedPomodoros: 0,
      totalStudyTime: 0, // 总学习时间（秒）
      streakDays: 0,
      
      // UI状态
      showTimeSelector: false,
      showCompletionDialog: false,
      showSettings: false,
      timeSelectionMode: 'study',
      selectedTime: 25,
      customMinutes: null,
      
      // 设置
      settings: {
        defaultStudyTime: 25,
        defaultRestTime: 5,
        longRestTime: 15,
        longRestInterval: 4,
        enableNotifications: true
      },
      
      // 计时器实例
      timer: null,
      
      // 完成对话框数据
      completionData: {},
      
      // 进度圆环
      circumference: 2 * Math.PI * 130,
    };
  },
  
  computed: {
    // 时间选项
    timeOptions() {
      if (this.timeSelectionMode === 'study') {
        return [
          { value: 15, label: '15分钟', description: '短时专注' },
          { value: 25, label: '25分钟', description: '标准番茄钟' },
          { value: 30, label: '30分钟', description: '深度学习' },
          { value: 45, label: '45分钟', description: '长时专注' },
          { value: 60, label: '60分钟', description: '马拉松学习' }
        ];
      } else {
        return [
          { value: 5, label: '5分钟', description: '短暂休息' },
          { value: 10, label: '10分钟', description: '标准休息' },
          { value: 15, label: '15分钟', description: '长休息' },
          { value: 20, label: '20分钟', description: '充分休息' }
        ];
      }
    },
    
    // 进度偏移
    progressOffset() {
      const progress = (this.totalTime - this.currentTime) / this.totalTime;
      return this.circumference - (progress * this.circumference);
    }
  },
  
  mounted() {
    this.loadSettings();
    this.loadStatistics();
    this.requestNotificationPermission();
  },
  
  beforeDestroy() {
    if (this.timer) {
      clearInterval(this.timer);
    }
  },
  
  methods: {
    // 开始计时器
    startTimer() {
      this.isRunning = true;
      this.timer = setInterval(() => {
        if (this.currentTime > 0) {
          this.currentTime--;
        } else {
          this.onTimerComplete();
        }
      }, 1000);
    },
    
    // 暂停计时器
    pauseTimer() {
      this.isRunning = false;
      if (this.timer) {
        clearInterval(this.timer);
        this.timer = null;
      }
    },
    
    // 重置计时器
    resetTimer() {
      this.pauseTimer();
      this.currentTime = this.totalTime;
    },
    
    // 计时器完成
    onTimerComplete() {
      this.pauseTimer();
      
      if (this.isStudyMode) {
        // 学习时间完成
        this.completedPomodoros++;
        this.totalStudyTime += this.totalTime;
        
        // 判断是否需要长休息
        const isLongRest = this.completedPomodoros % this.settings.longRestInterval === 0;
        const restTime = isLongRest ? this.settings.longRestTime : this.settings.defaultRestTime;
        
        this.completionData = {
          icon: 'fas fa-check-circle',
          title: '学习时间完成！',
          message: `恭喜！你完成了 ${this.formatTime(this.totalTime)} 的专注学习。${isLongRest ? '建议进行长休息。' : ''}`,
          actions: [
            {
              key: 'continue',
              label: '继续学习',
              icon: 'fas fa-play',
              class: 'btn-success'
            },
            {
              key: 'rest',
              label: `休息 ${restTime} 分钟`,
              icon: 'fas fa-coffee',
              class: 'btn-warning'
            },
            {
              key: 'finish',
              label: '结束学习',
              icon: 'fas fa-stop',
              class: 'btn-secondary'
            }
          ]
        };
      } else {
        // 休息时间完成
        this.completionData = {
          icon: 'fas fa-play-circle',
          title: '休息时间结束！',
          message: '休息结束，准备开始新的学习吧！',
          actions: [
            {
              key: 'study',
              label: '开始学习',
              icon: 'fas fa-book',
              class: 'btn-success'
            },
            {
              key: 'extend',
              label: '延长休息',
              icon: 'fas fa-clock',
              class: 'btn-warning'
            }
          ]
        };
      }
      
      this.showCompletionDialog = true;
      this.playNotification();
      this.saveStatistics();
    },
    
    // 处理完成对话框操作
    handleCompletionAction(action) {
      this.showCompletionDialog = false;
      
      switch (action) {
        case 'continue':
          this.showTimeSelector('study');
          break;
        case 'rest':
          const restTime = (this.completedPomodoros % this.settings.longRestInterval === 0) 
            ? this.settings.longRestTime 
            : this.settings.defaultRestTime;
          this.switchMode(false, restTime);
          break;
        case 'study':
          this.showTimeSelector('study');
          break;
        case 'extend':
          this.showTimeSelector('rest');
          break;
        case 'finish':
          this.resetTimer();
          break;
      }
    },
    
    // 显示时间选择器
    showTimeSelector(mode = 'study') {
      this.timeSelectionMode = mode;
      this.selectedTime = mode === 'study' ? this.settings.defaultStudyTime : this.settings.defaultRestTime;
      this.customMinutes = null;
      this.showTimeSelector = true;
    },
    
    // 关闭时间选择器
    closeTimeSelector() {
      this.showTimeSelector = false;
    },
    
    // 确认时间选择
    confirmTimeSelection() {
      const minutes = this.customMinutes || this.selectedTime;
      if (minutes && minutes > 0) {
        this.switchMode(this.timeSelectionMode === 'study', minutes);
        this.closeTimeSelector();
      }
    },
    
    // 切换模式
    switchMode(isStudy, minutes) {
      this.isStudyMode = isStudy;
      this.totalTime = minutes * 60;
      this.currentTime = this.totalTime;
      this.startTimer();
    },
    
    // 格式化时间显示
    formatTime(seconds) {
      const mins = Math.floor(seconds / 60);
      const secs = seconds % 60;
      return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    },
    
    // 格式化总时间
    formatTotalTime(seconds) {
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      
      if (hours > 0) {
        return `${hours}h ${minutes}m`;
      }
      return `${minutes}m`;
    },
    
    // 播放通知
    playNotification() {
      // 移除了音频通知功能
      
      // 浏览器通知
      if (this.settings.enableNotifications && Notification.permission === 'granted') {
        const title = this.isStudyMode ? '学习时间完成！' : '休息时间结束！';
        const body = this.isStudyMode ? '是时候休息一下了' : '准备开始新的学习吧！';
        
        new Notification(title, {
          body,
          icon: '/favicon.ico',
          tag: 'pomodoro-timer'
        });
      }
    },
    
    // 请求通知权限
    async requestNotificationPermission() {
      if ('Notification' in window && Notification.permission === 'default') {
        await Notification.requestPermission();
      }
    },
    
    // 保存设置
    saveSettings() {
      localStorage.setItem('pomodoro-settings', JSON.stringify(this.settings));
      this.$message?.success('设置已保存');
    },
    
    // 加载设置
    loadSettings() {
      const saved = localStorage.getItem('pomodoro-settings');
      if (saved) {
        this.settings = { ...this.settings, ...JSON.parse(saved) };
      }
    },
    
    // 保存统计数据
    saveStatistics() {
      const stats = {
        completedPomodoros: this.completedPomodoros,
        totalStudyTime: this.totalStudyTime,
        streakDays: this.streakDays,
        lastDate: new Date().toDateString()
      };
      localStorage.setItem('pomodoro-stats', JSON.stringify(stats));
    },
    
    // 加载统计数据
    loadStatistics() {
      const saved = localStorage.getItem('pomodoro-stats');
      if (saved) {
        const stats = JSON.parse(saved);
        const today = new Date().toDateString();
        
        if (stats.lastDate === today) {
          // 今天的数据
          this.completedPomodoros = stats.completedPomodoros || 0;
          this.totalStudyTime = stats.totalStudyTime || 0;
          this.streakDays = stats.streakDays || 0;
        } else {
          // 新的一天，重置日统计
          this.completedPomodoros = 0;
          this.totalStudyTime = 0;
          
          // 检查连续天数
          const yesterday = new Date();
          yesterday.setDate(yesterday.getDate() - 1);
          
          if (stats.lastDate === yesterday.toDateString()) {
            this.streakDays = (stats.streakDays || 0) + 1;
          } else {
            this.streakDays = 1;
          }
        }
      }
    },
    
    // 显示统计
    showStatistics() {
      // 这里可以打开统计页面或对话框
      this.$message?.info('统计功能开发中...');
    },
    
    // 切换全屏
    toggleFullscreen() {
      if (!document.fullscreenElement) {
        this.$el.requestFullscreen().catch(e => {
          console.log('全屏失败:', e);
        });
      } else {
        document.exitFullscreen();
      }
    }
  }
};
</script>

<style scoped>
.pomodoro-timer {
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
  font-family: 'Arial', sans-serif;
}

.timer-container {
  text-align: center;
  margin-bottom: 30px;
}

.timer-circle {
  position: relative;
  display: inline-block;
  margin-bottom: 30px;
}

.timer-circle.study-mode {
  background: linear-gradient(135deg, #4CAF50, #66BB6A);
  border-radius: 50%;
  padding: 20px;
}

.timer-circle.rest-mode {
  background: linear-gradient(135deg, #FF9800, #FFB74D);
  border-radius: 50%;
  padding: 20px;
}

.timer-content {
  position: relative;
  z-index: 2;
  background: white;
  border-radius: 50%;
  width: 240px;
  height: 240px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.mode-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 10px;
  color: #666;
  font-size: 14px;
}

.mode-indicator i {
  font-size: 18px;
}

.time-display {
  font-size: 48px;
  font-weight: bold;
  color: #333;
  margin-bottom: 15px;
  font-family: 'Courier New', monospace;
}

.timer-controls {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  justify-content: center;
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 20px;
  cursor: pointer;
  font-size: 12px;
  display: flex;
  align-items: center;
  gap: 5px;
  transition: all 0.3s;
}

.btn-start {
  background: #4CAF50;
  color: white;
}

.btn-pause {
  background: #FF9800;
  color: white;
}

.btn-reset {
  background: #9E9E9E;
  color: white;
}

.btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

.progress-ring {
  position: absolute;
  top: 0;
  left: 0;
  transform: rotate(-90deg);
}

.progress-ring-progress {
  transition: stroke-dashoffset 0.3s;
}

.stats-panel {
  display: flex;
  justify-content: space-around;
  background: #f5f5f5;
  border-radius: 15px;
  padding: 20px;
  margin-bottom: 20px;
}

.stat-item {
  text-align: center;
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.stat-item i {
  font-size: 24px;
  color: #4CAF50;
}

.stat-item span {
  font-size: 12px;
  color: #666;
}

.stat-item strong {
  font-size: 18px;
  color: #333;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.time-selector-modal {
  background: white;
  border-radius: 15px;
  padding: 30px;
  max-width: 400px;
  width: 90%;
  max-height: 80vh;
  overflow-y: auto;
}

.time-selector-modal h3 {
  text-align: center;
  margin-bottom: 20px;
  color: #333;
}

.time-options {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 20px;
}

.time-option {
  padding: 15px;
  border: 2px solid #e0e0e0;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.time-option:hover {
  border-color: #4CAF50;
}

.time-option.selected {
  border-color: #4CAF50;
  background: #f1f8e9;
}

.time-value {
  font-weight: bold;
  color: #333;
}

.time-description {
  font-size: 12px;
  color: #666;
}

.custom-time {
  margin-bottom: 20px;
  padding: 15px;
  border: 1px solid #e0e0e0;
  border-radius: 10px;
}

.custom-time label {
  display: block;
  margin-bottom: 10px;
  color: #333;
}

.custom-time input {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 5px;
}

.modal-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.btn-primary {
  background: #4CAF50;
  color: white;
}

.btn-secondary {
  background: #9E9E9E;
  color: white;
}

.btn-success {
  background: #4CAF50;
  color: white;
}

.btn-warning {
  background: #FF9800;
  color: white;
}

.completion-dialog {
  background: white;
  border-radius: 15px;
  padding: 30px;
  max-width: 400px;
  width: 90%;
  text-align: center;
}

.completion-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 15px;
}

.completion-icon i {
  font-size: 48px;
  color: #4CAF50;
}

.completion-actions {
  display: flex;
  flex-direction: column;
  gap: 10px;
  width: 100%;
}

.settings-panel {
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 15px;
  padding: 20px;
  margin-bottom: 20px;
}

.settings-panel h4 {
  margin-bottom: 20px;
  color: #333;
}

.setting-group {
  margin-bottom: 15px;
}

.setting-group label {
  display: block;
  margin-bottom: 5px;
  color: #333;
  font-weight: bold;
}

.setting-group input[type="number"] {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 5px;
}

.checkbox-group label {
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: normal;
}

.checkbox-group input[type="checkbox"] {
  width: auto;
}

.setting-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
  margin-top: 20px;
}

.control-bar {
  display: flex;
  justify-content: center;
  gap: 20px;
  padding: 15px;
  background: #f5f5f5;
  border-radius: 15px;
}

.control-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
  padding: 10px;
  background: none;
  border: none;
  cursor: pointer;
  color: #666;
  transition: color 0.3s;
}

.control-btn:hover {
  color: #4CAF50;
}

.control-btn i {
  font-size: 20px;
}

.control-btn span {
  font-size: 12px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .pomodoro-timer {
    padding: 10px;
  }
  
  .timer-content {
    width: 200px;
    height: 200px;
  }
  
  .time-display {
    font-size: 36px;
  }
  
  .stats-panel {
    flex-direction: column;
    gap: 15px;
  }
  
  .completion-actions {
    flex-direction: column;
  }
}

/* 动画效果 */
@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
}

.timer-circle.study-mode .timer-content,
.timer-circle.rest-mode .timer-content {
  animation: pulse 2s infinite ease-in-out;
}

.timer-circle:not(.study-mode):not(.rest-mode) .timer-content {
  animation: none;
}
</style>
