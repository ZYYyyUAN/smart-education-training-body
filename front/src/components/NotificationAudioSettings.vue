<template>
  <div class="audio-settings">
    <el-card class="settings-card">
      <template #header>
        <div class="card-header">
          <span>🔊 通知语音设置</span>
          <el-switch
            v-model="settings.enabled"
            @change="updateSettings"
            active-text="启用"
            inactive-text="禁用"
          />
        </div>
      </template>
      
      <div class="settings-content" v-if="settings.enabled">
        <div class="setting-item">
          <label>音量</label>
          <el-slider
            v-model="settings.volume"
            :min="0"
            :max="1"
            :step="0.1"
            :format-tooltip="formatVolume"
            @change="updateSettings"
            style="width: 200px;"
          />
          <span class="value-display">{{ Math.round(settings.volume * 100) }}%</span>
        </div>
        
        <div class="setting-item">
          <label>语速</label>
          <el-slider
            v-model="settings.rate"
            :min="0.1"
            :max="2"
            :step="0.1"
            :format-tooltip="formatRate"
            @change="updateSettings"
            style="width: 200px;"
          />
          <span class="value-display">{{ settings.rate.toFixed(1) }}x</span>
        </div>
        
        <div class="setting-item">
          <label>音调</label>
          <el-slider
            v-model="settings.pitch"
            :min="0"
            :max="2"
            :step="0.1"
            :format-tooltip="formatPitch"
            @change="updateSettings"
            style="width: 200px;"
          />
          <span class="value-display">{{ settings.pitch.toFixed(1) }}</span>
        </div>
        
        <div class="setting-item">
          <label>语言</label>
          <el-select v-model="settings.lang" @change="updateSettings" style="width: 120px;">
            <el-option label="中文" value="zh-CN" />
            <el-option label="English" value="en-US" />
          </el-select>
        </div>
        
        <div class="test-section">
          <el-button type="primary" @click="testVoice" :loading="isTesting">
            🎵 测试语音
          </el-button>
          <el-button @click="testSound" :loading="isTestingSound">
            🔊 测试音效
          </el-button>
        </div>
      </div>
      
      <div v-else class="disabled-message">
        <p>语音提醒已禁用</p>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import notificationAudioService from '@/utils/notificationAudio.js'

const isTesting = ref(false)
const isTestingSound = ref(false)

const settings = reactive({
  enabled: true,
  volume: 0.8,
  rate: 0.9,
  pitch: 1.0,
  lang: 'zh-CN'
})

// 格式化音量显示
const formatVolume = (value) => `${Math.round(value * 100)}%`

// 格式化语速显示
const formatRate = (value) => `${value.toFixed(1)}x`

// 格式化音调显示
const formatPitch = (value) => value.toFixed(1)

// 更新设置
const updateSettings = () => {
  notificationAudioService.applySettings(settings)
  saveSettings()
}

// 保存设置到本地存储
const saveSettings = () => {
  localStorage.setItem('notificationAudioSettings', JSON.stringify(settings))
}

// 加载设置
const loadSettings = () => {
  const saved = localStorage.getItem('notificationAudioSettings')
  if (saved) {
    try {
      const savedSettings = JSON.parse(saved)
      Object.assign(settings, savedSettings)
      notificationAudioService.applySettings(settings)
    } catch (error) {
      console.warn('加载语音设置失败:', error)
    }
  }
}

// 测试语音
const testVoice = async () => {
  isTesting.value = true
  try {
    notificationAudioService.playVoiceNotification('这是一条测试语音，用于验证语音提醒功能是否正常工作。')
    ElMessage.success('正在播放测试语音...')
  } catch (error) {
    ElMessage.error('语音测试失败')
  } finally {
    setTimeout(() => {
      isTesting.value = false
    }, 2000)
  }
}

// 测试音效
const testSound = async () => {
  isTestingSound.value = true
  try {
    // 依次播放三种音效
    notificationAudioService.playSound('success')
    setTimeout(() => {
      notificationAudioService.playSound('info')
    }, 300)
    setTimeout(() => {
      notificationAudioService.playSound('error')
    }, 600)
    
    ElMessage.success('正在播放测试音效...')
  } catch (error) {
    ElMessage.error('音效测试失败')
  } finally {
    setTimeout(() => {
      isTestingSound.value = false
    }, 1000)
  }
}

onMounted(() => {
  loadSettings()
})
</script>

<style scoped>
.audio-settings {
  max-width: 500px;
  margin: 0 auto;
}

.settings-card {
  margin: 20px 0;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
  font-size: 16px;
}

.settings-content {
  padding: 10px 0;
}

.setting-item {
  display: flex;
  align-items: center;
  margin: 20px 0;
  gap: 15px;
}

.setting-item label {
  min-width: 60px;
  font-weight: 500;
  color: #606266;
}

.value-display {
  min-width: 50px;
  text-align: center;
  font-weight: bold;
  color: #409eff;
}

.test-section {
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid #ebeef5;
  display: flex;
  gap: 10px;
  justify-content: center;
}

.disabled-message {
  text-align: center;
  color: #909399;
  padding: 20px;
}

.disabled-message p {
  margin: 0;
  font-size: 14px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .setting-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .setting-item label {
    min-width: auto;
  }
  
  .test-section {
    flex-direction: column;
    align-items: center;
  }
}
</style>
