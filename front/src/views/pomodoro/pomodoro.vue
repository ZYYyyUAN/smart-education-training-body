<template>
  <div class="pomodoro-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1>
          <i class="fas fa-clock"></i>
          番茄钟学习助手
        </h1>
        <p class="subtitle">科学管理时间，提升学习效率</p>
      </div>
      
      <!-- 快速统计 -->
      <div class="quick-stats">
        <div class="stat-card">
          <i class="fas fa-fire"></i>
          <div class="stat-info">
            <span class="stat-value">{{ todayPomodoros }}</span>
            <span class="stat-label">今日番茄</span>
          </div>
        </div>
        
        <div class="stat-card">
          <i class="fas fa-trophy"></i>
          <div class="stat-info">
            <span class="stat-value">{{ totalPomodoros }}</span>
            <span class="stat-label">总完成数</span>
          </div>
        </div>
        
        <div class="stat-card">
          <i class="fas fa-calendar-check"></i>
          <div class="stat-info">
            <span class="stat-value">{{ streakDays }}</span>
            <span class="stat-label">连续天数</span>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 番茄钟组件 -->
    <div class="timer-section">
      <PomodoroTimer 
        @stats-updated="updateStats"
        @pomodoro-completed="onPomodoroCompleted"
      />
    </div>
    
    <!-- 使用技巧 -->
    <div class="tips-section">
      <h3><i class="fas fa-lightbulb"></i> 使用技巧</h3>
      <div class="tips-grid">
        <div class="tip-card">
          <i class="fas fa-target"></i>
          <h4>设定明确目标</h4>
          <p>在开始每个番茄钟前，明确这25分钟要完成的具体任务</p>
        </div>
        
        <div class="tip-card">
          <i class="fas fa-mobile-alt"></i>
          <h4>避免干扰</h4>
          <p>关闭手机通知，创造一个专注的学习环境</p>
        </div>
        
        <div class="tip-card">
          <i class="fas fa-coffee"></i>
          <h4>充分休息</h4>
          <p>休息时间同样重要，建议站起来活动或放松眼睛</p>
        </div>
        
        <div class="tip-card">
          <i class="fas fa-chart-line"></i>
          <h4>记录反思</h4>
          <p>记录学习效果，不断优化自己的学习节奏</p>
        </div>
      </div>
    </div>
    
    <!-- 今日学习记录 -->
    <div class="daily-log" v-if="dailyLog.length > 0">
      <h3><i class="fas fa-history"></i> 今日学习记录</h3>
      <div class="log-timeline">
        <div 
          v-for="(log, index) in dailyLog" 
          :key="index" 
          class="log-item"
          :class="{ 'study': log.type === 'study', 'rest': log.type === 'rest' }"
        >
          <div class="log-time">{{ formatLogTime(log.startTime) }}</div>
          <div class="log-content">
            <i :class="log.type === 'study' ? 'fas fa-book' : 'fas fa-coffee'"></i>
            <span>{{ log.type === 'study' ? '学习' : '休息' }}</span>
            <span class="duration">{{ log.duration }}分钟</span>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 学习成就 -->
    <div class="achievements-section">
      <h3><i class="fas fa-medal"></i> 学习成就</h3>
      <div class="achievements-grid">
        <div 
          v-for="achievement in achievements" 
          :key="achievement.id"
          class="achievement-card"
          :class="{ 'unlocked': achievement.unlocked }"
        >
          <i :class="achievement.icon"></i>
          <h4>{{ achievement.title }}</h4>
          <p>{{ achievement.description }}</p>
          <div class="progress-bar" v-if="!achievement.unlocked">
            <div 
              class="progress-fill" 
              :style="{ width: achievement.progress + '%' }"
            ></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import PomodoroTimer from '@/components/PomodoroTimer.vue';

export default {
  name: 'PomodoroPage',
  
  components: {
    PomodoroTimer
  },
  
  data() {
    return {
      // 统计数据
      todayPomodoros: 0,
      totalPomodoros: 0,
      streakDays: 0,
      
      // 今日记录
      dailyLog: [],
      
      // 成就系统
      achievements: [
        {
          id: 'first_pomodoro',
          title: '初学乍练',
          description: '完成第一个番茄钟',
          icon: 'fas fa-seedling',
          unlocked: false,
          progress: 0,
          requirement: 1
        },
        {
          id: 'five_pomodoros',
          title: '专注新手',
          description: '单日完成5个番茄钟',
          icon: 'fas fa-star',
          unlocked: false,
          progress: 0,
          requirement: 5
        },
        {
          id: 'ten_pomodoros',
          title: '学习达人',
          description: '单日完成10个番茄钟',
          icon: 'fas fa-fire',
          unlocked: false,
          progress: 0,
          requirement: 10
        },
        {
          id: 'week_streak',
          title: '坚持一周',
          description: '连续学习7天',
          icon: 'fas fa-calendar-week',
          unlocked: false,
          progress: 0,
          requirement: 7
        },
        {
          id: 'month_streak',
          title: '坚持一月',
          description: '连续学习30天',
          icon: 'fas fa-trophy',
          unlocked: false,
          progress: 0,
          requirement: 30
        },
        {
          id: 'hundred_pomodoros',
          title: '百炼成钢',
          description: '累计完成100个番茄钟',
          icon: 'fas fa-crown',
          unlocked: false,
          progress: 0,
          requirement: 100
        }
      ]
    };
  },
  
  mounted() {
    this.loadStatistics();
    this.loadDailyLog();
    this.updateAchievements();
  },
  
  methods: {
    // 更新统计数据
    updateStats(stats) {
      this.todayPomodoros = stats.todayPomodoros || 0;
      this.totalPomodoros = stats.totalPomodoros || 0;
      this.streakDays = stats.streakDays || 0;
      
      this.updateAchievements();
    },
    
    // 番茄钟完成回调
    onPomodoroCompleted(data) {
      // 添加到今日记录
      this.addToLog(data);
      
      // 检查成就
      this.checkAchievements();
      
      // 保存数据
      this.saveDailyLog();
    },
    
    // 添加到学习记录
    addToLog(data) {
      const logEntry = {
        type: data.type, // 'study' or 'rest'
        duration: data.duration,
        startTime: new Date(data.startTime),
        endTime: new Date()
      };
      
      this.dailyLog.push(logEntry);
      
      // 只保留今天的记录
      const today = new Date().toDateString();
      this.dailyLog = this.dailyLog.filter(log => 
        log.startTime.toDateString() === today
      );
    },
    
    // 格式化记录时间
    formatLogTime(time) {
      return time.toLocaleTimeString('zh-CN', {
        hour: '2-digit',
        minute: '2-digit'
      });
    },
    
    // 加载统计数据
    loadStatistics() {
      const saved = localStorage.getItem('pomodoro-stats');
      if (saved) {
        const stats = JSON.parse(saved);
        this.todayPomodoros = stats.todayPomodoros || 0;
        this.totalPomodoros = stats.totalPomodoros || 0;
        this.streakDays = stats.streakDays || 0;
      }
    },
    
    // 加载今日记录
    loadDailyLog() {
      const saved = localStorage.getItem('pomodoro-daily-log');
      if (saved) {
        const log = JSON.parse(saved);
        const today = new Date().toDateString();
        
        // 只加载今天的记录
        this.dailyLog = log
          .map(entry => ({
            ...entry,
            startTime: new Date(entry.startTime),
            endTime: new Date(entry.endTime)
          }))
          .filter(entry => entry.startTime.toDateString() === today);
      }
    },
    
    // 保存今日记录
    saveDailyLog() {
      localStorage.setItem('pomodoro-daily-log', JSON.stringify(this.dailyLog));
    },
    
    // 更新成就
    updateAchievements() {
      this.achievements.forEach(achievement => {
        switch (achievement.id) {
          case 'first_pomodoro':
            achievement.progress = Math.min(100, (this.totalPomodoros / achievement.requirement) * 100);
            achievement.unlocked = this.totalPomodoros >= achievement.requirement;
            break;
          case 'five_pomodoros':
            achievement.progress = Math.min(100, (this.todayPomodoros / achievement.requirement) * 100);
            achievement.unlocked = this.todayPomodoros >= achievement.requirement;
            break;
          case 'ten_pomodoros':
            achievement.progress = Math.min(100, (this.todayPomodoros / achievement.requirement) * 100);
            achievement.unlocked = this.todayPomodoros >= achievement.requirement;
            break;
          case 'week_streak':
            achievement.progress = Math.min(100, (this.streakDays / achievement.requirement) * 100);
            achievement.unlocked = this.streakDays >= achievement.requirement;
            break;
          case 'month_streak':
            achievement.progress = Math.min(100, (this.streakDays / achievement.requirement) * 100);
            achievement.unlocked = this.streakDays >= achievement.requirement;
            break;
          case 'hundred_pomodoros':
            achievement.progress = Math.min(100, (this.totalPomodoros / achievement.requirement) * 100);
            achievement.unlocked = this.totalPomodoros >= achievement.requirement;
            break;
        }
      });
    },
    
    // 检查成就
    checkAchievements() {
      this.achievements.forEach(achievement => {
        const wasUnlocked = achievement.unlocked;
        this.updateAchievements();
        
        // 如果是新解锁的成就，显示通知
        if (!wasUnlocked && achievement.unlocked) {
          this.showAchievementNotification(achievement);
        }
      });
    },
    
    // 显示成就通知
    showAchievementNotification(achievement) {
      // 可以使用 Element UI 的通知组件
      if (this.$notify) {
        this.$notify({
          title: '🎉 恭喜解锁成就！',
          message: `${achievement.title}: ${achievement.description}`,
          type: 'success',
          duration: 5000
        });
      } else {
        console.log(`🎉 成就解锁: ${achievement.title}`);
      }
    }
  }
};
</script>

<style scoped>
.pomodoro-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
  color: white;
}

.header-content h1 {
  font-size: 2.5rem;
  margin-bottom: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 15px;
}

.subtitle {
  font-size: 1.1rem;
  opacity: 0.9;
  margin-bottom: 30px;
}

.quick-stats {
  display: flex;
  justify-content: center;
  gap: 20px;
  flex-wrap: wrap;
}

.stat-card {
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  border-radius: 15px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 15px;
  min-width: 140px;
  transition: transform 0.3s;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.stat-card i {
  font-size: 24px;
  color: #FFD700;
}

.stat-info {
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: white;
}

.stat-label {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.8);
}

.timer-section {
  background: white;
  border-radius: 20px;
  padding: 30px;
  margin-bottom: 40px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.tips-section {
  background: white;
  border-radius: 20px;
  padding: 30px;
  margin-bottom: 40px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.tips-section h3 {
  text-align: center;
  margin-bottom: 30px;
  color: #333;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.tips-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

.tip-card {
  background: #f8f9fa;
  border-radius: 15px;
  padding: 20px;
  text-align: center;
  transition: transform 0.3s;
}

.tip-card:hover {
  transform: translateY(-5px);
}

.tip-card i {
  font-size: 32px;
  color: #4CAF50;
  margin-bottom: 15px;
}

.tip-card h4 {
  margin-bottom: 10px;
  color: #333;
}

.tip-card p {
  color: #666;
  font-size: 14px;
  line-height: 1.5;
}

.daily-log {
  background: white;
  border-radius: 20px;
  padding: 30px;
  margin-bottom: 40px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.daily-log h3 {
  margin-bottom: 25px;
  color: #333;
  display: flex;
  align-items: center;
  gap: 10px;
}

.log-timeline {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.log-item {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 15px;
  border-radius: 10px;
  border-left: 4px solid #ddd;
}

.log-item.study {
  background: #e8f5e8;
  border-left-color: #4CAF50;
}

.log-item.rest {
  background: #fff3e0;
  border-left-color: #FF9800;
}

.log-time {
  font-weight: bold;
  color: #666;
  min-width: 60px;
}

.log-content {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 1;
}

.log-content i {
  font-size: 16px;
}

.log-item.study .log-content i {
  color: #4CAF50;
}

.log-item.rest .log-content i {
  color: #FF9800;
}

.duration {
  margin-left: auto;
  font-weight: bold;
  color: #333;
}

.achievements-section {
  background: white;
  border-radius: 20px;
  padding: 30px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.achievements-section h3 {
  text-align: center;
  margin-bottom: 30px;
  color: #333;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.achievements-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}

.achievement-card {
  background: #f8f9fa;
  border-radius: 15px;
  padding: 20px;
  text-align: center;
  position: relative;
  transition: all 0.3s;
  border: 2px solid transparent;
}

.achievement-card.unlocked {
  background: linear-gradient(135deg, #FFD700, #FFA500);
  color: white;
  border-color: #FFD700;
  transform: scale(1.02);
}

.achievement-card:not(.unlocked) {
  opacity: 0.7;
}

.achievement-card i {
  font-size: 32px;
  margin-bottom: 15px;
  color: #666;
}

.achievement-card.unlocked i {
  color: white;
}

.achievement-card h4 {
  margin-bottom: 10px;
  color: #333;
}

.achievement-card.unlocked h4 {
  color: white;
}

.achievement-card p {
  color: #666;
  font-size: 14px;
  margin-bottom: 15px;
}

.achievement-card.unlocked p {
  color: rgba(255, 255, 255, 0.9);
}

.progress-bar {
  background: #e0e0e0;
  border-radius: 10px;
  height: 8px;
  overflow: hidden;
}

.progress-fill {
  background: #4CAF50;
  height: 100%;
  border-radius: 10px;
  transition: width 0.3s;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .pomodoro-page {
    padding: 10px;
  }
  
  .page-header h1 {
    font-size: 2rem;
  }
  
  .quick-stats {
    flex-direction: column;
    align-items: center;
  }
  
  .tips-grid {
    grid-template-columns: 1fr;
  }
  
  .achievements-grid {
    grid-template-columns: 1fr;
  }
  
  .log-item {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .log-time {
    min-width: auto;
  }
}

/* 动画效果 */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.timer-section,
.tips-section,
.daily-log,
.achievements-section {
  animation: fadeInUp 0.6s ease-out;
}

.achievement-card.unlocked {
  animation: pulse 1s ease-in-out;
}

@keyframes pulse {
  0% { transform: scale(1.02); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1.02); }
}
</style>

