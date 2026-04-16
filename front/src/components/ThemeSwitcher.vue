<template>
  <div class="theme-switcher">
    <el-dropdown @command="handleThemeChange" trigger="click">
      <el-button type="primary" circle class="theme-button">
        <el-icon><Setting /></el-icon>
      </el-button>
      <template #dropdown>
        <el-dropdown-menu>
          <el-dropdown-item 
            v-for="theme in themes" 
            :key="theme.value"
            :command="theme.value"
            :class="{ active: currentTheme === theme.value }"
          >
            <div class="theme-option">
              <div class="theme-preview" :class="theme.value"></div>
              <span class="theme-name">{{ theme.name }}</span>
              <span class="theme-emoji">{{ theme.icon }}</span>
              <el-icon v-if="currentTheme === theme.value" class="check-icon">
                <Check />
              </el-icon>
            </div>
          </el-dropdown-item>
        </el-dropdown-menu>
      </template>
    </el-dropdown>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Setting, Check } from '@element-plus/icons-vue'

const emit = defineEmits(['theme-change'])

const currentTheme = ref('minimal')

const themes = ref([
  {
    value: 'minimal',
    name: '简约风',
    description: '简洁优雅的极简风格',
    icon: '✨'
  },
  {
    value: 'cartoon',
    name: '卡通风',
    description: '活泼可爱的卡通风格',
    icon: '🎨'
  }
])


const handleThemeChange = (themeValue) => {
  currentTheme.value = themeValue
  emit('theme-change', themeValue)
  // 保存到本地存储
  localStorage.setItem('course-theme', themeValue)
}

// 从本地存储加载主题
onMounted(() => {
  const savedTheme = localStorage.getItem('course-theme')
  if (savedTheme && themes.value.some(t => t.value === savedTheme)) {
    currentTheme.value = savedTheme
  }
})
</script>

<style scoped>
.theme-switcher {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 1000;
}

.theme-button {
  width: 50px;
  height: 50px;
  font-size: 18px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transition: all 0.3s ease;
}

.theme-button:hover {
  transform: scale(1.1);
}

.theme-option {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 0;
  min-width: 150px;
}

.theme-preview {
  width: 24px;
  height: 24px;
  border-radius: 4px;
  border: 2px solid #e0e0e0;
  position: relative;
  overflow: hidden;
}

.theme-preview.cartoon {
  background: linear-gradient(135deg, #ff6b6b, #4ecdc4, #45b7d1);
}


.theme-preview.tech {
  background: linear-gradient(135deg, #667eea, #764ba2, #f093fb);
}

.theme-preview.minimal {
  background: linear-gradient(135deg, #f8f9fa, #e9ecef, #dee2e6);
}

.theme-preview.dark {
  background: linear-gradient(135deg, #1a1a1a, #2d2d2d, #404040);
}

.theme-name {
  flex: 1;
  font-weight: 500;
}

.theme-emoji {
  font-size: 16px;
  margin-left: 8px;
}

.check-icon {
  color: #409eff;
  font-size: 16px;
  margin-left: 8px;
}

:deep(.el-dropdown-menu__item.active) {
  background-color: #f0f9ff;
  color: #409eff;
}

:deep(.el-dropdown-menu__item:hover) {
  background-color: #f5f7fa;
}
</style>
