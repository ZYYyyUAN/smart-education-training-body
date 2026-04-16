/**
 * 全局番茄钟状态管理
 * 支持在任何页面使用番茄钟功能
 */

import { reactive, computed, watch } from 'vue'

// 番茄钟全局状态
const pomodoroState = reactive({
  // 计时器状态
  isRunning: false,
  isStudyMode: true,
  currentTime: 25 * 60, // 当前剩余时间（秒）
  totalTime: 25 * 60,   // 总时间（秒）
  
  // 统计数据
  completedPomodoros: 0,
  totalStudyTime: 0, // 总学习时间（秒）
  streakDays: 0,
  todayStartTime: null,
  
  // 设置
  settings: {
    defaultStudyTime: 25,
    defaultRestTime: 5,
    longRestTime: 15,
    longRestInterval: 4,
    enableNotifications: true,
    autoStartBreak: false,
    autoStartStudy: false,
    showFloatingTimer: true,
    enableGlobalHotkeys: true
  },
  
  // UI状态
  showCompletionDialog: false,
  showTimeSelector: false,
  showFloatingTimer: true,
  isMinimized: false,
  
  // 计时器实例
  timer: null,
  
  // 会话数据
  currentSession: null,
  dailyLog: [],
  
  // 完成对话框数据
  completionData: {}
})

// 计算属性
const pomodoroComputed = {
  // 格式化时间显示
  formattedTime: computed(() => {
    const mins = Math.floor(pomodoroState.currentTime / 60)
    const secs = pomodoroState.currentTime % 60
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }),
  
  // 进度百分比
  progress: computed(() => {
    if (pomodoroState.totalTime === 0) return 0
    return ((pomodoroState.totalTime - pomodoroState.currentTime) / pomodoroState.totalTime) * 100
  }),
  
  // 今日目标进度
  todayProgress: computed(() => {
    const target = pomodoroState.settings.dailyTarget || 8
    return Math.min(100, (pomodoroState.completedPomodoros / target) * 100)
  }),
  
  // 当前状态描述
  statusText: computed(() => {
    if (!pomodoroState.isRunning) {
      return pomodoroState.isStudyMode ? '准备学习' : '准备休息'
    }
    return pomodoroState.isStudyMode ? '专注学习中' : '休息时间'
  })
}

// 番茄钟操作方法
const pomodoroActions = {
  // 开始计时器
  startTimer() {
    if (pomodoroState.timer) return // 防止重复启动
    
    pomodoroState.isRunning = true
    pomodoroState.todayStartTime = pomodoroState.todayStartTime || new Date()
    
    // 开始会话记录
    if (!pomodoroState.currentSession) {
      pomodoroState.currentSession = {
        type: pomodoroState.isStudyMode ? 'study' : 'rest',
        startTime: new Date(),
        duration: Math.floor(pomodoroState.totalTime / 60),
        completed: false
      }
    }
    
    pomodoroState.timer = setInterval(() => {
      if (pomodoroState.currentTime > 0) {
        pomodoroState.currentTime--
        
        // 如果是学习模式，累计学习时间
        if (pomodoroState.isStudyMode) {
          pomodoroState.totalStudyTime++
        }
      } else {
        pomodoroActions.onTimerComplete()
      }
    }, 1000)
    
    // 保存状态
    pomodoroActions.saveState()
    
    console.log('🍅 番茄钟已开始:', pomodoroState.isStudyMode ? '学习模式' : '休息模式')
  },
  
  // 暂停计时器
  pauseTimer() {
    pomodoroState.isRunning = false
    if (pomodoroState.timer) {
      clearInterval(pomodoroState.timer)
      pomodoroState.timer = null
    }
    
    pomodoroActions.saveState()
    console.log('⏸️ 番茄钟已暂停')
  },
  
  // 重置计时器
  resetTimer() {
    pomodoroActions.pauseTimer()
    pomodoroState.currentTime = pomodoroState.totalTime
    pomodoroState.currentSession = null
    
    pomodoroActions.saveState()
    console.log('🔄 番茄钟已重置')
  },
  
  // 计时器完成
  onTimerComplete() {
    pomodoroActions.pauseTimer()
    
    // 完成当前会话
    if (pomodoroState.currentSession) {
      pomodoroState.currentSession.completed = true
      pomodoroState.currentSession.endTime = new Date()
      
      // 添加到日志
      pomodoroState.dailyLog.push({ ...pomodoroState.currentSession })
      pomodoroState.currentSession = null
    }
    
    if (pomodoroState.isStudyMode) {
      // 学习时间完成
      pomodoroState.completedPomodoros++
      
      // 判断是否需要长休息
      const isLongRest = pomodoroState.completedPomodoros % pomodoroState.settings.longRestInterval === 0
      const restTime = isLongRest ? pomodoroState.settings.longRestTime : pomodoroState.settings.defaultRestTime
      
      pomodoroState.completionData = {
        type: 'study_complete',
        isLongRest,
        restTime,
        completedCount: pomodoroState.completedPomodoros
      }
      
      // 自动开始休息或显示选择对话框
      if (pomodoroState.settings.autoStartBreak) {
        pomodoroActions.switchMode(false, restTime)
      } else {
        pomodoroState.showCompletionDialog = true
      }
    } else {
      // 休息时间完成
      pomodoroState.completionData = {
        type: 'rest_complete'
      }
      
      // 自动开始学习或显示选择对话框
      if (pomodoroState.settings.autoStartStudy) {
        pomodoroActions.switchMode(true, pomodoroState.settings.defaultStudyTime)
      } else {
        pomodoroState.showCompletionDialog = true
      }
    }
    
    // 播放通知
    pomodoroActions.playNotification()
    
    // 保存统计数据
    pomodoroActions.saveStatistics()
    pomodoroActions.saveState()
    
    console.log('✅ 番茄钟完成:', pomodoroState.isStudyMode ? '学习' : '休息')
  },
  
  // 切换模式
  switchMode(isStudy, minutes) {
    pomodoroState.isStudyMode = isStudy
    pomodoroState.totalTime = minutes * 60
    pomodoroState.currentTime = pomodoroState.totalTime
    pomodoroState.showCompletionDialog = false
    pomodoroState.showTimeSelector = false
    
    // 自动开始或等待用户手动开始
    if ((isStudy && pomodoroState.settings.autoStartStudy) || 
        (!isStudy && pomodoroState.settings.autoStartBreak)) {
      pomodoroActions.startTimer()
    }
    
    pomodoroActions.saveState()
  },
  
  // 显示时间选择器
  showTimeSelector(mode = 'study') {
    pomodoroState.showTimeSelector = true
    pomodoroState.showCompletionDialog = false
    // 可以在这里触发全局事件，让FloatingTimer组件响应
  },
  
  // 播放通知
  playNotification() {
    try {
      
      // 浏览器通知
      if (pomodoroState.settings.enableNotifications && 'Notification' in window && Notification.permission === 'granted') {
        const title = pomodoroState.isStudyMode ? '学习时间完成！' : '休息时间结束！'
        const body = pomodoroState.isStudyMode ? '是时候休息一下了' : '准备开始新的学习吧！'
        
        const notification = new Notification(title, {
          body,
          icon: '/favicon.ico',
          tag: 'pomodoro-timer',
          requireInteraction: true
        })
        
        // 点击通知时聚焦窗口
        notification.onclick = () => {
          window.focus()
          notification.close()
        }
        
        // 5秒后自动关闭
        setTimeout(() => notification.close(), 5000)
      }
    } catch (error) {
      console.warn('通知播放失败:', error)
    }
  },
  
  
  // 切换悬浮计时器显示
  toggleFloatingTimer() {
    pomodoroState.showFloatingTimer = !pomodoroState.showFloatingTimer
    pomodoroActions.saveState()
  },
  
  // 最小化/展开悬浮计时器
  toggleMinimize() {
    pomodoroState.isMinimized = !pomodoroState.isMinimized
    pomodoroActions.saveState()
  },
  
  // 保存状态到本地存储
  saveState() {
    const stateToSave = {
      isRunning: pomodoroState.isRunning,
      isStudyMode: pomodoroState.isStudyMode,
      currentTime: pomodoroState.currentTime,
      totalTime: pomodoroState.totalTime,
      completedPomodoros: pomodoroState.completedPomodoros,
      totalStudyTime: pomodoroState.totalStudyTime,
      streakDays: pomodoroState.streakDays,
      settings: pomodoroState.settings,
      showFloatingTimer: pomodoroState.showFloatingTimer,
      isMinimized: pomodoroState.isMinimized,
      todayStartTime: pomodoroState.todayStartTime,
      lastSaveTime: new Date().toISOString()
    }
    
    localStorage.setItem('global-pomodoro-state', JSON.stringify(stateToSave))
  },
  
  // 从本地存储加载状态
  loadState() {
    try {
      const saved = localStorage.getItem('global-pomodoro-state')
      if (!saved) return
      
      const state = JSON.parse(saved)
      const now = new Date()
      const lastSave = new Date(state.lastSaveTime || 0)
      const timeDiff = (now - lastSave) / 1000 // 秒
      
      // 如果保存时间超过1小时，重置计时器状态
      if (timeDiff > 3600) {
        console.log('⏰ 检测到长时间未活动，重置计时器状态')
        pomodoroState.isRunning = false
        pomodoroState.currentTime = state.totalTime || 25 * 60
      } else {
        // 恢复计时器状态，但不自动开始
        pomodoroState.isRunning = false // 页面刷新后不自动继续
        pomodoroState.currentTime = Math.max(0, state.currentTime - Math.floor(timeDiff))
      }
      
      // 恢复其他状态
      Object.assign(pomodoroState, {
        isStudyMode: state.isStudyMode,
        totalTime: state.totalTime,
        completedPomodoros: state.completedPomodoros || 0,
        totalStudyTime: state.totalStudyTime || 0,
        streakDays: state.streakDays || 0,
        settings: { ...pomodoroState.settings, ...state.settings },
        showFloatingTimer: state.showFloatingTimer !== false,
        isMinimized: state.isMinimized || false,
        todayStartTime: state.todayStartTime ? new Date(state.todayStartTime) : null
      })
      
      console.log('✅ 番茄钟状态已恢复')
    } catch (error) {
      console.warn('状态恢复失败:', error)
    }
  },
  
  // 保存统计数据
  saveStatistics() {
    const stats = {
      completedPomodoros: pomodoroState.completedPomodoros,
      totalStudyTime: pomodoroState.totalStudyTime,
      streakDays: pomodoroState.streakDays,
      dailyLog: pomodoroState.dailyLog,
      lastDate: new Date().toDateString()
    }
    
    localStorage.setItem('pomodoro-global-stats', JSON.stringify(stats))
  },
  
  // 加载统计数据
  loadStatistics() {
    try {
      const saved = localStorage.getItem('pomodoro-global-stats')
      if (!saved) return
      
      const stats = JSON.parse(saved)
      const today = new Date().toDateString()
      
      if (stats.lastDate === today) {
        // 今天的数据
        pomodoroState.completedPomodoros = stats.completedPomodoros || 0
        pomodoroState.totalStudyTime = stats.totalStudyTime || 0
        pomodoroState.streakDays = stats.streakDays || 0
        pomodoroState.dailyLog = stats.dailyLog || []
      } else {
        // 新的一天，重置日统计
        pomodoroState.completedPomodoros = 0
        pomodoroState.totalStudyTime = 0
        pomodoroState.dailyLog = []
        
        // 检查连续天数
        const yesterday = new Date()
        yesterday.setDate(yesterday.getDate() - 1)
        
        if (stats.lastDate === yesterday.toDateString()) {
          pomodoroState.streakDays = (stats.streakDays || 0) + 1
        } else {
          pomodoroState.streakDays = stats.completedPomodoros > 0 ? 1 : 0
        }
      }
      
      console.log('📊 统计数据已加载')
    } catch (error) {
      console.warn('统计数据加载失败:', error)
    }
  },
  
  // 请求通知权限
  async requestNotificationPermission() {
    if ('Notification' in window && Notification.permission === 'default') {
      const permission = await Notification.requestPermission()
      pomodoroState.settings.enableNotifications = permission === 'granted'
      pomodoroActions.saveState()
    }
  },
  
  // 初始化
  async init() {
    console.log('🍅 初始化全局番茄钟...')
    
    // 加载状态和统计数据
    pomodoroActions.loadState()
    pomodoroActions.loadStatistics()
    
    // 请求通知权限
    await pomodoroActions.requestNotificationPermission()
    
    // 监听页面可见性变化
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        pomodoroActions.saveState()
      }
    })
    
    // 监听页面关闭
    window.addEventListener('beforeunload', () => {
      pomodoroActions.saveState()
    })
    
    console.log('✅ 全局番茄钟初始化完成')
  }
}

// 监听状态变化
watch(
  () => pomodoroState.settings,
  () => {
    pomodoroActions.saveState()
  },
  { deep: true }
)

// 导出全局番茄钟
export const useGlobalPomodoro = () => {
  return {
    state: pomodoroState,
    computed: pomodoroComputed,
    actions: pomodoroActions
  }
}

// 默认导出
export default {
  state: pomodoroState,
  computed: pomodoroComputed,
  actions: pomodoroActions
}

