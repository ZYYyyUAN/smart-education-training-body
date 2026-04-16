<template>
  <div class="pomodoro-statistics">
    <div class="stats-header">
      <h1>
        <i class="fas fa-chart-bar"></i>
        学习统计
      </h1>
      <p>追踪你的学习进度和习惯</p>
    </div>
    
    <!-- 概览卡片 -->
    <div class="overview-cards">
      <div class="overview-card total">
        <div class="card-icon">
          <i class="fas fa-clock"></i>
        </div>
        <div class="card-content">
          <h3>总学习时间</h3>
          <p class="big-number">{{ formatTotalTime(statistics.totalMinutes) }}</p>
        </div>
      </div>
      
      <div class="overview-card pomodoros">
        <div class="card-icon">
          <i class="fas fa-tomato"></i>
        </div>
        <div class="card-content">
          <h3>完成番茄钟</h3>
          <p class="big-number">{{ statistics.totalPomodoros }}</p>
        </div>
      </div>
      
      <div class="overview-card streak">
        <div class="card-icon">
          <i class="fas fa-fire"></i>
        </div>
        <div class="card-content">
          <h3>最长连续</h3>
          <p class="big-number">{{ statistics.maxStreak }} 天</p>
        </div>
      </div>
      
      <div class="overview-card average">
        <div class="card-icon">
          <i class="fas fa-chart-line"></i>
        </div>
        <div class="card-content">
          <h3>日均学习</h3>
          <p class="big-number">{{ statistics.dailyAverage }} 个</p>
        </div>
      </div>
    </div>
    
    <!-- 图表区域 -->
    <div class="charts-section">
      <!-- 每日学习趋势 -->
      <div class="chart-card">
        <h3>
          <i class="fas fa-line-chart"></i>
          每日学习趋势
        </h3>
        <div class="chart-container">
          <canvas ref="dailyChart" width="400" height="200"></canvas>
        </div>
      </div>
      
      <!-- 学习时段分析 -->
      <div class="chart-card">
        <h3>
          <i class="fas fa-clock"></i>
          学习时段分析
        </h3>
        <div class="chart-container">
          <canvas ref="hourlyChart" width="400" height="200"></canvas>
        </div>
      </div>
    </div>
    
    <!-- 详细统计 -->
    <div class="detailed-stats">
      <div class="stats-grid">
        <!-- 本周统计 -->
        <div class="stat-section">
          <h3>
            <i class="fas fa-calendar-week"></i>
            本周统计
          </h3>
          <div class="week-stats">
            <div 
              v-for="(day, index) in weekStats" 
              :key="index"
              class="day-stat"
              :class="{ 'today': day.isToday, 'active': day.count > 0 }"
            >
              <div class="day-name">{{ day.name }}</div>
              <div class="day-count">{{ day.count }}</div>
              <div class="day-bar">
                <div 
                  class="day-fill" 
                  :style="{ height: (day.count / maxDayCount) * 100 + '%' }"
                ></div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- 月度统计 -->
        <div class="stat-section">
          <h3>
            <i class="fas fa-calendar-alt"></i>
            月度统计
          </h3>
          <div class="month-stats">
            <div class="month-item">
              <span>本月完成</span>
              <strong>{{ monthStats.thisMonth }}</strong>
            </div>
            <div class="month-item">
              <span>上月完成</span>
              <strong>{{ monthStats.lastMonth }}</strong>
            </div>
            <div class="month-item">
              <span>月度目标</span>
              <strong>{{ monthStats.target }}</strong>
            </div>
            <div class="month-item">
              <span>目标进度</span>
              <div class="progress-container">
                <div class="progress-bar">
                  <div 
                    class="progress-fill" 
                    :style="{ width: monthStats.progress + '%' }"
                  ></div>
                </div>
                <span class="progress-text">{{ monthStats.progress }}%</span>
              </div>
            </div>
          </div>
        </div>
        
        <!-- 效率分析 -->
        <div class="stat-section">
          <h3>
            <i class="fas fa-tachometer-alt"></i>
            效率分析
          </h3>
          <div class="efficiency-stats">
            <div class="efficiency-item">
              <span>平均专注时长</span>
              <strong>{{ statistics.avgFocusTime }}分钟</strong>
            </div>
            <div class="efficiency-item">
              <span>完成率</span>
              <strong>{{ statistics.completionRate }}%</strong>
            </div>
            <div class="efficiency-item">
              <span>最佳学习时段</span>
              <strong>{{ statistics.bestHour }}:00</strong>
            </div>
            <div class="efficiency-item">
              <span>专注度评分</span>
              <div class="score-container">
                <div class="score-circle" :class="getScoreClass(statistics.focusScore)">
                  {{ statistics.focusScore }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 学习日历 -->
    <div class="calendar-section">
      <h3>
        <i class="fas fa-calendar"></i>
        学习日历
      </h3>
      <div class="calendar-container">
        <div class="calendar-header">
          <button @click="previousMonth" class="nav-btn">
            <i class="fas fa-chevron-left"></i>
          </button>
          <h4>{{ currentMonthName }} {{ currentYear }}</h4>
          <button @click="nextMonth" class="nav-btn">
            <i class="fas fa-chevron-right"></i>
          </button>
        </div>
        
        <div class="calendar-grid">
          <div class="day-header" v-for="day in dayHeaders" :key="day">
            {{ day }}
          </div>
          
          <div 
            v-for="date in calendarDates" 
            :key="date.key"
            class="calendar-day"
            :class="{
              'other-month': date.otherMonth,
              'today': date.isToday,
              'has-study': date.studyCount > 0
            }"
          >
            <span class="date-number">{{ date.date }}</span>
            <div v-if="date.studyCount > 0" class="study-indicator">
              <span class="study-count">{{ date.studyCount }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PomodoroStatistics',
  
  data() {
    return {
      // 统计数据
      statistics: {
        totalMinutes: 0,
        totalPomodoros: 0,
        maxStreak: 0,
        currentStreak: 0,
        dailyAverage: 0,
        avgFocusTime: 25,
        completionRate: 85,
        bestHour: 14,
        focusScore: 85
      },
      
      // 周统计
      weekStats: [],
      
      // 月统计
      monthStats: {
        thisMonth: 0,
        lastMonth: 0,
        target: 100,
        progress: 0
      },
      
      // 日历相关
      currentMonth: new Date().getMonth(),
      currentYear: new Date().getFullYear(),
      dayHeaders: ['日', '一', '二', '三', '四', '五', '六'],
      
      // 图表实例
      dailyChart: null,
      hourlyChart: null
    };
  },
  
  computed: {
    currentMonthName() {
      const months = [
        '1月', '2月', '3月', '4月', '5月', '6月',
        '7月', '8月', '9月', '10月', '11月', '12月'
      ];
      return months[this.currentMonth];
    },
    
    maxDayCount() {
      return Math.max(...this.weekStats.map(day => day.count), 1);
    },
    
    calendarDates() {
      const dates = [];
      const firstDay = new Date(this.currentYear, this.currentMonth, 1);
      const lastDay = new Date(this.currentYear, this.currentMonth + 1, 0);
      const startWeekday = firstDay.getDay();
      
      // 添加上个月的日期
      const prevMonth = new Date(this.currentYear, this.currentMonth, 0);
      for (let i = startWeekday - 1; i >= 0; i--) {
        const date = prevMonth.getDate() - i;
        dates.push({
          key: `prev-${date}`,
          date,
          otherMonth: true,
          isToday: false,
          studyCount: 0
        });
      }
      
      // 添加当前月的日期
      for (let date = 1; date <= lastDay.getDate(); date++) {
        const currentDate = new Date(this.currentYear, this.currentMonth, date);
        const isToday = this.isToday(currentDate);
        const studyCount = this.getStudyCountForDate(currentDate);
        
        dates.push({
          key: `current-${date}`,
          date,
          otherMonth: false,
          isToday,
          studyCount
        });
      }
      
      // 添加下个月的日期填满6周
      const remainingDays = 42 - dates.length;
      for (let date = 1; date <= remainingDays; date++) {
        dates.push({
          key: `next-${date}`,
          date,
          otherMonth: true,
          isToday: false,
          studyCount: 0
        });
      }
      
      return dates;
    }
  },
  
  mounted() {
    this.loadStatistics();
    this.generateWeekStats();
    this.generateMonthStats();
    this.initCharts();
  },
  
  methods: {
    // 加载统计数据
    loadStatistics() {
      // 从localStorage加载数据
      const savedStats = localStorage.getItem('pomodoro-all-stats');
      if (savedStats) {
        const stats = JSON.parse(savedStats);
        this.statistics = { ...this.statistics, ...stats };
      }
      
      // 计算衍生数据
      this.calculateDerivedStats();
    },
    
    // 计算衍生统计数据
    calculateDerivedStats() {
      // 这里可以根据原始数据计算各种统计指标
      // 例如：日均学习量、最长连续天数等
    },
    
    // 生成周统计
    generateWeekStats() {
      const today = new Date();
      const dayNames = ['日', '一', '二', '三', '四', '五', '六'];
      
      this.weekStats = [];
      
      for (let i = 0; i < 7; i++) {
        const date = new Date(today);
        date.setDate(today.getDate() - today.getDay() + i);
        
        const isToday = this.isToday(date);
        const count = this.getStudyCountForDate(date);
        
        this.weekStats.push({
          name: dayNames[i],
          count,
          isToday,
          date: date.getDate()
        });
      }
    },
    
    // 生成月统计
    generateMonthStats() {
      const now = new Date();
      const thisMonth = this.getMonthStudyCount(now.getFullYear(), now.getMonth());
      const lastMonth = this.getMonthStudyCount(
        now.getMonth() === 0 ? now.getFullYear() - 1 : now.getFullYear(),
        now.getMonth() === 0 ? 11 : now.getMonth() - 1
      );
      
      this.monthStats = {
        thisMonth,
        lastMonth,
        target: 100,
        progress: Math.min(100, (thisMonth / 100) * 100)
      };
    },
    
    // 获取指定日期的学习次数
    getStudyCountForDate(date) {
      // 这里应该从实际数据中获取
      // 暂时返回随机数据作为示例
      const seed = date.getTime();
      return Math.floor(Math.random() * seed % 8);
    },
    
    // 获取月度学习统计
    getMonthStudyCount(year, month) {
      // 这里应该从实际数据中计算
      // 暂时返回随机数据作为示例
      return Math.floor(Math.random() * 80) + 20;
    },
    
    // 判断是否为今天
    isToday(date) {
      const today = new Date();
      return date.toDateString() === today.toDateString();
    },
    
    // 格式化总时间
    formatTotalTime(minutes) {
      const hours = Math.floor(minutes / 60);
      const mins = minutes % 60;
      
      if (hours > 0) {
        return `${hours}小时${mins}分钟`;
      }
      return `${mins}分钟`;
    },
    
    // 获取评分等级样式
    getScoreClass(score) {
      if (score >= 90) return 'excellent';
      if (score >= 80) return 'good';
      if (score >= 70) return 'fair';
      return 'poor';
    },
    
    // 上个月
    previousMonth() {
      if (this.currentMonth === 0) {
        this.currentMonth = 11;
        this.currentYear--;
      } else {
        this.currentMonth--;
      }
    },
    
    // 下个月
    nextMonth() {
      if (this.currentMonth === 11) {
        this.currentMonth = 0;
        this.currentYear++;
      } else {
        this.currentMonth++;
      }
    },
    
    // 初始化图表
    initCharts() {
      this.$nextTick(() => {
        this.initDailyChart();
        this.initHourlyChart();
      });
    },
    
    // 初始化日趋势图表
    initDailyChart() {
      // 这里可以使用 Chart.js 或其他图表库
      // 暂时用简单的实现
      console.log('初始化日趋势图表');
    },
    
    // 初始化时段分析图表
    initHourlyChart() {
      // 这里可以使用 Chart.js 或其他图表库
      // 暂时用简单的实现
      console.log('初始化时段分析图表');
    }
  }
};
</script>

<style scoped>
.pomodoro-statistics {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  background: #f5f7fa;
  min-height: 100vh;
}

.stats-header {
  text-align: center;
  margin-bottom: 40px;
}

.stats-header h1 {
  font-size: 2.5rem;
  margin-bottom: 10px;
  color: #333;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 15px;
}

.stats-header p {
  color: #666;
  font-size: 1.1rem;
}

.overview-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 40px;
}

.overview-card {
  background: white;
  border-radius: 15px;
  padding: 25px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  gap: 20px;
  transition: transform 0.3s;
}

.overview-card:hover {
  transform: translateY(-5px);
}

.card-icon {
  width: 60px;
  height: 60px;
  border-radius: 15px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: white;
}

.overview-card.total .card-icon {
  background: linear-gradient(135deg, #667eea, #764ba2);
}

.overview-card.pomodoros .card-icon {
  background: linear-gradient(135deg, #f093fb, #f5576c);
}

.overview-card.streak .card-icon {
  background: linear-gradient(135deg, #4facfe, #00f2fe);
}

.overview-card.average .card-icon {
  background: linear-gradient(135deg, #43e97b, #38f9d7);
}

.card-content h3 {
  margin: 0 0 10px 0;
  color: #666;
  font-size: 14px;
  font-weight: normal;
}

.big-number {
  font-size: 2rem;
  font-weight: bold;
  color: #333;
  margin: 0;
}

.charts-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 20px;
  margin-bottom: 40px;
}

.chart-card {
  background: white;
  border-radius: 15px;
  padding: 25px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.chart-card h3 {
  margin-bottom: 20px;
  color: #333;
  display: flex;
  align-items: center;
  gap: 10px;
}

.chart-container {
  height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8f9fa;
  border-radius: 10px;
  color: #666;
}

.detailed-stats {
  margin-bottom: 40px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 20px;
}

.stat-section {
  background: white;
  border-radius: 15px;
  padding: 25px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.stat-section h3 {
  margin-bottom: 20px;
  color: #333;
  display: flex;
  align-items: center;
  gap: 10px;
}

.week-stats {
  display: flex;
  justify-content: space-between;
  gap: 10px;
}

.day-stat {
  flex: 1;
  text-align: center;
  position: relative;
}

.day-name {
  font-size: 12px;
  color: #666;
  margin-bottom: 5px;
}

.day-count {
  font-weight: bold;
  color: #333;
  margin-bottom: 10px;
}

.day-stat.today .day-count {
  color: #4CAF50;
}

.day-bar {
  height: 60px;
  background: #f0f0f0;
  border-radius: 4px;
  position: relative;
  display: flex;
  align-items: flex-end;
}

.day-fill {
  width: 100%;
  background: #4CAF50;
  border-radius: 4px;
  min-height: 2px;
  transition: height 0.3s;
}

.day-stat.today .day-fill {
  background: #FF9800;
}

.month-stats {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.month-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
}

.month-item:last-child {
  border-bottom: none;
}

.progress-container {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 1;
  justify-content: flex-end;
}

.progress-bar {
  width: 100px;
  height: 8px;
  background: #f0f0f0;
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: #4CAF50;
  transition: width 0.3s;
}

.progress-text {
  font-size: 12px;
  color: #666;
}

.efficiency-stats {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.efficiency-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
}

.efficiency-item:last-child {
  border-bottom: none;
}

.score-container {
  display: flex;
  justify-content: flex-end;
}

.score-circle {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: bold;
  font-size: 14px;
}

.score-circle.excellent {
  background: #4CAF50;
}

.score-circle.good {
  background: #2196F3;
}

.score-circle.fair {
  background: #FF9800;
}

.score-circle.poor {
  background: #F44336;
}

.calendar-section {
  background: white;
  border-radius: 15px;
  padding: 25px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.calendar-section h3 {
  margin-bottom: 20px;
  color: #333;
  display: flex;
  align-items: center;
  gap: 10px;
}

.calendar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.nav-btn {
  background: #f0f0f0;
  border: none;
  border-radius: 8px;
  width: 40px;
  height: 40px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.3s;
}

.nav-btn:hover {
  background: #e0e0e0;
}

.calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 1px;
  background: #f0f0f0;
  border-radius: 8px;
  overflow: hidden;
}

.day-header {
  background: #f8f9fa;
  padding: 15px 5px;
  text-align: center;
  font-weight: bold;
  color: #666;
  font-size: 14px;
}

.calendar-day {
  background: white;
  padding: 10px 5px;
  min-height: 60px;
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  cursor: pointer;
  transition: background 0.3s;
}

.calendar-day:hover {
  background: #f8f9fa;
}

.calendar-day.other-month {
  color: #ccc;
  background: #fafafa;
}

.calendar-day.today {
  background: #e3f2fd;
  color: #1976d2;
  font-weight: bold;
}

.calendar-day.has-study {
  background: #e8f5e8;
}

.calendar-day.has-study.today {
  background: #c8e6c9;
}

.date-number {
  font-size: 14px;
}

.study-indicator {
  margin-top: 5px;
  background: #4CAF50;
  color: white;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 10px;
  font-weight: bold;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .pomodoro-statistics {
    padding: 10px;
  }
  
  .overview-cards {
    grid-template-columns: 1fr;
  }
  
  .charts-section {
    grid-template-columns: 1fr;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .week-stats {
    gap: 5px;
  }
  
  .calendar-day {
    min-height: 50px;
    padding: 8px 3px;
  }
}
</style>

