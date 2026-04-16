<template>
  <div class="pomodoro-settings">
    <div class="settings-header">
      <h1>
        <i class="fas fa-cog"></i>
        番茄钟设置
      </h1>
      <p>个性化你的番茄钟体验</p>
    </div>
    
    <!-- 基本设置 -->
    <div class="settings-section">
      <h2>
        <i class="fas fa-clock"></i>
        时间设置
      </h2>
      
      <div class="settings-grid">
        <div class="setting-item">
          <label>学习时长（分钟）</label>
          <div class="input-group">
            <input 
              v-model.number="settings.studyTime" 
              type="number" 
              min="5" 
              max="60"
              class="setting-input"
            />
            <span class="input-unit">分钟</span>
          </div>
          <p class="setting-description">建议保持在25分钟，这是最有效的专注时长</p>
        </div>
        
        <div class="setting-item">
          <label>短休息时长（分钟）</label>
          <div class="input-group">
            <input 
              v-model.number="settings.shortBreak" 
              type="number" 
              min="1" 
              max="30"
              class="setting-input"
            />
            <span class="input-unit">分钟</span>
          </div>
          <p class="setting-description">每个学习周期后的短暂休息时间</p>
        </div>
        
        <div class="setting-item">
          <label>长休息时长（分钟）</label>
          <div class="input-group">
            <input 
              v-model.number="settings.longBreak" 
              type="number" 
              min="5" 
              max="60"
              class="setting-input"
            />
            <span class="input-unit">分钟</span>
          </div>
          <p class="setting-description">完成多个番茄钟后的长休息时间</p>
        </div>
        
        <div class="setting-item">
          <label>长休息间隔</label>
          <div class="input-group">
            <input 
              v-model.number="settings.longBreakInterval" 
              type="number" 
              min="2" 
              max="8"
              class="setting-input"
            />
            <span class="input-unit">个番茄钟</span>
          </div>
          <p class="setting-description">每隔多少个番茄钟进行一次长休息</p>
        </div>
      </div>
    </div>
    
    <!-- 通知设置 -->
    <div class="settings-section">
      <h2>
        <i class="fas fa-bell"></i>
        通知设置
      </h2>
      
      <div class="settings-grid">
        <div class="setting-item">
          <div class="toggle-setting">
            <label>启用浏览器通知</label>
            <div class="toggle-switch">
              <input 
                v-model="settings.browserNotifications" 
                type="checkbox" 
                id="browser-notifications"
                @change="handleNotificationToggle"
              />
              <label for="browser-notifications" class="switch"></label>
            </div>
          </div>
          <p class="setting-description">在后台显示桌面通知提醒</p>
        </div>
        
      </div>
    </div>
    
    <!-- 主题设置 -->
    <div class="settings-section">
      <h2>
        <i class="fas fa-palette"></i>
        主题设置
      </h2>
      
      <div class="theme-options">
        <div 
          v-for="theme in themes" 
          :key="theme.id"
          class="theme-option"
          :class="{ 'active': settings.theme === theme.id }"
          @click="selectTheme(theme.id)"
        >
          <div class="theme-preview" :style="theme.style">
            <div class="theme-circle"></div>
          </div>
          <span class="theme-name">{{ theme.name }}</span>
        </div>
      </div>
    </div>
    
    <!-- 行为设置 -->
    <div class="settings-section">
      <h2>
        <i class="fas fa-user-cog"></i>
        行为设置
      </h2>
      
      <div class="settings-grid">
        <div class="setting-item">
          <div class="toggle-setting">
            <label>自动开始休息</label>
            <div class="toggle-switch">
              <input 
                v-model="settings.autoStartBreak" 
                type="checkbox" 
                id="auto-start-break"
              />
              <label for="auto-start-break" class="switch"></label>
            </div>
          </div>
          <p class="setting-description">学习时间结束后自动开始休息倒计时</p>
        </div>
        
        <div class="setting-item">
          <div class="toggle-setting">
            <label>自动开始学习</label>
            <div class="toggle-switch">
              <input 
                v-model="settings.autoStartStudy" 
                type="checkbox" 
                id="auto-start-study"
              />
              <label for="auto-start-study" class="switch"></label>
            </div>
          </div>
          <p class="setting-description">休息时间结束后自动开始下一个学习周期</p>
        </div>
        
        <div class="setting-item">
          <div class="toggle-setting">
            <label>显示统计提醒</label>
            <div class="toggle-switch">
              <input 
                v-model="settings.showStats" 
                type="checkbox" 
                id="show-stats"
              />
              <label for="show-stats" class="switch"></label>
            </div>
          </div>
          <p class="setting-description">完成番茄钟后显示学习统计信息</p>
        </div>
        
        <div class="setting-item">
          <label>每日目标（番茄钟数量）</label>
          <div class="input-group">
            <input 
              v-model.number="settings.dailyTarget" 
              type="number" 
              min="1" 
              max="20"
              class="setting-input"
            />
            <span class="input-unit">个</span>
          </div>
          <p class="setting-description">设定每日学习目标，激励自己坚持学习</p>
        </div>
      </div>
    </div>
    
    <!-- 高级设置 -->
    <div class="settings-section">
      <h2>
        <i class="fas fa-tools"></i>
        高级设置
      </h2>
      
      <div class="settings-grid">
        <div class="setting-item">
          <div class="toggle-setting">
            <label>启用白噪音</label>
            <div class="toggle-switch">
              <input 
                v-model="settings.whiteNoise" 
                type="checkbox" 
                id="white-noise"
              />
              <label for="white-noise" class="switch"></label>
            </div>
          </div>
          <p class="setting-description">学习时播放白噪音帮助专注</p>
        </div>
        
        <div class="setting-item">
          <label>白噪音类型</label>
          <select v-model="settings.whiteNoiseType" class="setting-select">
            <option value="rain">雨声</option>
            <option value="ocean">海浪声</option>
            <option value="forest">森林声</option>
            <option value="cafe">咖啡厅</option>
            <option value="pink">粉红噪音</option>
          </select>
        </div>
        
        <div class="setting-item">
          <label>数据保存</label>
          <div class="action-buttons">
            <button @click="exportData" class="action-btn">
              <i class="fas fa-download"></i>
              导出数据
            </button>
            <button @click="importData" class="action-btn">
              <i class="fas fa-upload"></i>
              导入数据
            </button>
          </div>
          <input 
            ref="importInput" 
            type="file" 
            accept=".json"
            style="display: none"
            @change="handleImport"
          />
        </div>
        
        <div class="setting-item">
          <label>重置设置</label>
          <button @click="resetSettings" class="danger-btn">
            <i class="fas fa-undo"></i>
            恢复默认设置
          </button>
          <p class="setting-description">将所有设置恢复到初始状态</p>
        </div>
      </div>
    </div>
    
    <!-- 保存按钮 -->
    <div class="save-section">
      <button @click="saveSettings" class="save-btn">
        <i class="fas fa-save"></i>
        保存设置
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PomodoroSettings',
  
  data() {
    return {
      settings: {
        // 时间设置
        studyTime: 25,
        shortBreak: 5,
        longBreak: 15,
        longBreakInterval: 4,
        
        // 通知设置
        browserNotifications: true,
        
        // 主题设置
        theme: 'default',
        
        // 行为设置
        autoStartBreak: false,
        autoStartStudy: false,
        showStats: true,
        dailyTarget: 8,
        
        // 高级设置
        whiteNoise: false,
        whiteNoiseType: 'rain'
      },
      
      themes: [
        {
          id: 'default',
          name: '默认',
          style: {
            background: 'linear-gradient(135deg, #4CAF50, #66BB6A)',
            color: 'white'
          }
        },
        {
          id: 'ocean',
          name: '海洋',
          style: {
            background: 'linear-gradient(135deg, #2196F3, #03DAC6)',
            color: 'white'
          }
        },
        {
          id: 'sunset',
          name: '日落',
          style: {
            background: 'linear-gradient(135deg, #FF9800, #FF5722)',
            color: 'white'
          }
        },
        {
          id: 'forest',
          name: '森林',
          style: {
            background: 'linear-gradient(135deg, #4CAF50, #2E7D32)',
            color: 'white'
          }
        },
        {
          id: 'purple',
          name: '紫色',
          style: {
            background: 'linear-gradient(135deg, #9C27B0, #673AB7)',
            color: 'white'
          }
        },
        {
          id: 'minimal',
          name: '简约',
          style: {
            background: 'linear-gradient(135deg, #607D8B, #455A64)',
            color: 'white'
          }
        }
      ]
    };
  },
  
  mounted() {
    this.loadSettings();
  },
  
  methods: {
    // 加载设置
    loadSettings() {
      const saved = localStorage.getItem('pomodoro-settings');
      if (saved) {
        this.settings = { ...this.settings, ...JSON.parse(saved) };
      }
    },
    
    // 保存设置
    saveSettings() {
      localStorage.setItem('pomodoro-settings', JSON.stringify(this.settings));
      
      // 触发全局设置更新事件
      this.$emit('settings-updated', this.settings);
      
      // 显示成功消息
      if (this.$message) {
        this.$message.success('设置已保存');
      }
    },
    
    // 处理通知权限切换
    async handleNotificationToggle() {
      if (this.settings.browserNotifications) {
        if ('Notification' in window && Notification.permission === 'default') {
          const permission = await Notification.requestPermission();
          if (permission !== 'granted') {
            this.settings.browserNotifications = false;
            if (this.$message) {
              this.$message.warning('请允许浏览器通知权限');
            }
          }
        }
      }
    },
    
    // 选择主题
    selectTheme(themeId) {
      this.settings.theme = themeId;
    },
    
    
    // 导出数据
    exportData() {
      const data = {
        settings: this.settings,
        statistics: JSON.parse(localStorage.getItem('pomodoro-stats') || '{}'),
        exportDate: new Date().toISOString()
      };
      
      const blob = new Blob([JSON.stringify(data, null, 2)], {
        type: 'application/json'
      });
      
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `pomodoro-data-${new Date().toISOString().split('T')[0]}.json`;
      a.click();
      
      URL.revokeObjectURL(url);
      
      if (this.$message) {
        this.$message.success('数据导出成功');
      }
    },
    
    // 导入数据
    importData() {
      this.$refs.importInput.click();
    },
    
    // 处理文件导入
    handleImport(event) {
      const file = event.target.files[0];
      if (!file) return;
      
      const reader = new FileReader();
      reader.onload = (e) => {
        try {
          const data = JSON.parse(e.target.result);
          
          if (data.settings) {
            this.settings = { ...this.settings, ...data.settings };
          }
          
          if (data.statistics) {
            localStorage.setItem('pomodoro-stats', JSON.stringify(data.statistics));
          }
          
          if (this.$message) {
            this.$message.success('数据导入成功');
          }
        } catch (error) {
          if (this.$message) {
            this.$message.error('导入文件格式错误');
          }
        }
      };
      
      reader.readAsText(file);
      
      // 清空input
      event.target.value = '';
    },
    
    // 重置设置
    resetSettings() {
      if (confirm('确定要重置所有设置吗？此操作不可撤销。')) {
        // 恢复默认设置
        this.settings = {
          studyTime: 25,
          shortBreak: 5,
          longBreak: 15,
          longBreakInterval: 4,
          browserNotifications: true,
          theme: 'default',
          autoStartBreak: false,
          autoStartStudy: false,
          showStats: true,
          dailyTarget: 8,
          whiteNoise: false,
          whiteNoiseType: 'rain'
        };
        
        // 清除本地存储
        localStorage.removeItem('pomodoro-settings');
        
        if (this.$message) {
          this.$message.success('设置已重置');
        }
      }
    }
  }
};
</script>

<style scoped>
.pomodoro-settings {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
  background: #f5f7fa;
  min-height: 100vh;
}

.settings-header {
  text-align: center;
  margin-bottom: 40px;
}

.settings-header h1 {
  font-size: 2.5rem;
  margin-bottom: 10px;
  color: #333;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 15px;
}

.settings-header p {
  color: #666;
  font-size: 1.1rem;
}

.settings-section {
  background: white;
  border-radius: 15px;
  padding: 30px;
  margin-bottom: 30px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.settings-section h2 {
  margin-bottom: 25px;
  color: #333;
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 1.3rem;
  border-bottom: 2px solid #f0f0f0;
  padding-bottom: 10px;
}

.settings-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 25px;
}

.setting-item {
  display: flex;
  flex-direction: column;
}

.setting-item label {
  font-weight: bold;
  color: #333;
  margin-bottom: 8px;
  font-size: 14px;
}

.input-group {
  display: flex;
  align-items: center;
  gap: 10px;
}

.setting-input {
  flex: 1;
  padding: 10px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 14px;
  transition: border-color 0.3s;
}

.setting-input:focus {
  outline: none;
  border-color: #4CAF50;
}

.input-unit {
  color: #666;
  font-size: 14px;
  white-space: nowrap;
}

.setting-select {
  width: 100%;
  padding: 10px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 14px;
  background: white;
  transition: border-color 0.3s;
}

.setting-select:focus {
  outline: none;
  border-color: #4CAF50;
}

.setting-description {
  margin-top: 5px;
  color: #666;
  font-size: 12px;
  line-height: 1.4;
}

.toggle-setting {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 5px;
}

.toggle-switch {
  position: relative;
}

.toggle-switch input[type="checkbox"] {
  display: none;
}

.switch {
  display: block;
  width: 50px;
  height: 24px;
  background: #ddd;
  border-radius: 12px;
  position: relative;
  cursor: pointer;
  transition: background 0.3s;
}

.switch::after {
  content: '';
  position: absolute;
  top: 2px;
  left: 2px;
  width: 20px;
  height: 20px;
  background: white;
  border-radius: 50%;
  transition: transform 0.3s;
}

.toggle-switch input[type="checkbox"]:checked + .switch {
  background: #4CAF50;
}

.toggle-switch input[type="checkbox"]:checked + .switch::after {
  transform: translateX(26px);
}

.test-btn {
  margin-top: 10px;
  padding: 8px 16px;
  background: #2196F3;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 12px;
  display: flex;
  align-items: center;
  gap: 5px;
  transition: background 0.3s;
}

.test-btn:hover {
  background: #1976D2;
}


.theme-options {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 15px;
}

.theme-option {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  padding: 15px;
  border: 2px solid transparent;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s;
}

.theme-option:hover {
  border-color: #ddd;
}

.theme-option.active {
  border-color: #4CAF50;
  background: #f1f8e9;
}

.theme-preview {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}

.theme-circle {
  width: 30px;
  height: 30px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 50%;
}

.theme-name {
  font-size: 12px;
  color: #333;
  font-weight: bold;
}

.action-buttons {
  display: flex;
  gap: 10px;
  margin-top: 10px;
}

.action-btn {
  padding: 8px 16px;
  background: #2196F3;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 12px;
  display: flex;
  align-items: center;
  gap: 5px;
  transition: background 0.3s;
}

.action-btn:hover {
  background: #1976D2;
}

.danger-btn {
  padding: 8px 16px;
  background: #F44336;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 12px;
  display: flex;
  align-items: center;
  gap: 5px;
  transition: background 0.3s;
  margin-top: 10px;
}

.danger-btn:hover {
  background: #D32F2F;
}

.save-section {
  text-align: center;
  margin-top: 40px;
}

.save-btn {
  padding: 15px 40px;
  background: #4CAF50;
  color: white;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  font-size: 16px;
  font-weight: bold;
  display: inline-flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s;
  box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
}

.save-btn:hover {
  background: #45a049;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(76, 175, 80, 0.4);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .pomodoro-settings {
    padding: 10px;
  }
  
  .settings-grid {
    grid-template-columns: 1fr;
  }
  
  .theme-options {
    grid-template-columns: repeat(3, 1fr);
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .toggle-setting {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
}

/* 动画效果 */
.settings-section {
  animation: fadeInUp 0.6s ease-out;
}

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
</style>

