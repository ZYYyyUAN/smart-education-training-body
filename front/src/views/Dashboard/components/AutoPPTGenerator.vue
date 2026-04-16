<template>
  <div class="auto-ppt-generator">
    <el-page-header @back="goBack" content="PPT 生成助手">
      <template #icon><el-icon><ArrowLeft /></el-icon></template>
    </el-page-header>
    <div class="header">
      <h1>🎯 Kimi PPT助手</h1>
      <p>输入主题，AI自动生成专业PPT，效率提升80%！</p>
    </div>

    <!-- 第一步：输入主题生成大纲 -->
    <div class="step-1" v-if="currentStep === 1">
      <h2>📝 第一步：生成PPT大纲</h2>
      <div class="input-section">
        <el-input
          v-model="theme"
          type="textarea"
          :rows="4"
          placeholder="请输入PPT主题，例如：Q3销售业绩分析汇报、人工智能技术发展趋势、产品发布会等..."
          class="theme-input"
        />
        <el-button type="primary" size="large" @click="generateOutline" :loading="outlineLoading">
          🚀 生成PPT大纲
        </el-button>
      </div>
    </div>

    <!-- 第一步半：展示和编辑大纲 -->
    <div class="step-1-5" v-if="currentStep === 1.5">
      <h2>📋 大纲预览与编辑</h2>
      <div class="outline-preview">
        <div class="outline-header">
          <h3>{{ theme }}</h3>
          <el-button type="primary" @click="editOutlineMode = !editOutlineMode">
            {{ editOutlineMode ? '预览模式' : '编辑模式' }}
          </el-button>
        </div>
        
        <div v-if="editOutlineMode" class="outline-editor">
          <el-input
            v-model="editingOutline"
            type="textarea"
            :rows="12"
            placeholder="编辑PPT大纲内容..."
          />
        </div>
        
        <div v-else class="outline-display">
          <div class="outline-content" v-html="formatOutline(editingOutline)"></div>
        </div>
        
        <div class="outline-actions">
          <el-button @click="currentStep = 1">重新生成</el-button>
          <el-button type="primary" @click="confirmOutline">确认大纲，选择模板</el-button>
        </div>
      </div>
    </div>

    <!-- 第二步：选择模板和风格 -->
    <div class="step-2" v-if="currentStep === 2">
      <h2>🎨 第二步：选择模板和风格</h2>
      
      <!-- 模板场景分类 -->
      <div class="scene-categories">
        <div class="category-tabs">
          <div 
            v-for="scene in templateScenes" 
            :key="scene.id"
            class="category-tab"
            :class="{ active: selectedScene === scene.id }"
            @click="selectedScene = scene.id"
          >
            <span class="scene-icon">{{ scene.icon }}</span>
            <span class="scene-name">{{ scene.name }}</span>
          </div>
        </div>
      </div>

      <!-- 模板风格分类 -->
      <div class="style-categories">
        <div class="category-tabs">
          <div 
            v-for="style in templateStyles" 
            :key="style.id"
            class="category-tab"
            :class="{ active: selectedStyle === style.id }"
            @click="selectedStyle = style.id"
          >
            <span class="style-icon">{{ style.icon }}</span>
            <span class="style-name">{{ style.name }}</span>
          </div>
        </div>
      </div>

      <!-- 模板选择区域 -->
      <div class="template-selection-area">
        <!-- 左侧模板列表 -->
        <div class="template-list">
          <div class="template-grid">
            <div 
              v-for="template in filteredTemplates" 
              :key="template.id"
              class="template-item"
              :class="{ active: selectedTemplate === template.id }"
              @click="selectTemplate(template)"
            >
              <div class="template-preview">{{ template.preview }}</div>
              <div class="template-name">{{ template.name }}</div>
              <div class="template-category">{{ template.category }}</div>
            </div>
          </div>
        </div>

        <!-- 右侧模板预览 -->
        <div class="template-preview-panel">
          <div v-if="selectedTemplateData" class="preview-content">
            <div class="preview-header">
              <h3>{{ selectedTemplateData.name }}</h3>
              <p class="template-description">{{ selectedTemplateData.description }}</p>
            </div>
            
            <!-- 主预览图 -->
                          <div class="main-preview">
                <div class="preview-slide">
                  <img 
                    v-if="selectedTemplateData.currentSlide?.isImage || selectedTemplateData.slides[0].isImage"
                    :src="selectedTemplateData.currentSlide?.preview || selectedTemplateData.slides[0].preview"
                    :alt="selectedTemplateData.currentSlide?.title || selectedTemplateData.slides[0].title"
                    class="main-slide-img"
                  />
                  <div v-else class="slide-preview-content">
                    <div class="slide-icon">{{ selectedTemplateData.currentSlide?.preview || selectedTemplateData.slides[0].preview }}</div>
                    <h2>{{ selectedTemplateData.currentSlide?.content || selectedTemplateData.slides[0].content }}</h2>
                    <p class="slide-subtitle">汇报人: {{ theme || '用户' }}</p>
                    <p class="slide-date">时间: {{ new Date().getFullYear() }}.{{ new Date().getMonth() + 1 }}</p>
                    <div class="slide-decoration"></div>
                  </div>
                </div>
              </div>

            <!-- 幻灯片缩略图 -->
            <div class="slide-thumbnails">
              <div 
                v-for="(slide, index) in selectedTemplateData.slides" 
                :key="index"
                class="slide-thumbnail"
                @click="previewSlide(slide, index)"
              >
                <div class="thumbnail-preview">
                  <img 
                    v-if="slide.isImage" 
                    :src="slide.preview" 
                    :alt="slide.title"
                    class="thumbnail-img"
                  />
                  <div v-else class="thumbnail-icon">{{ slide.preview }}</div>
                  <div class="thumbnail-overlay">
                    <span class="play-icon">👁️</span>
                  </div>
                </div>
                <div class="thumbnail-number">{{ index + 1 }}</div>
                <div class="thumbnail-title">{{ slide.title }}</div>
                <div class="thumbnail-description">{{ slide.description }}</div>
                <div class="thumbnail-details">{{ slide.details }}</div>
              </div>
            </div>
          </div>
          
          <div v-else class="preview-placeholder">
            <div class="placeholder-icon">🎯</div>
            <p>请选择一个模板进行预览</p>
          </div>
        </div>
      </div>

      <div class="action-buttons">
        <el-button @click="currentStep = 1">上一步</el-button>
        <el-button type="primary" @click="generatePPT" :loading="generating" :disabled="!selectedTemplate">
          🎯 一键生成PPT
        </el-button>
      </div>
    </div>

    <!-- 第三步：生成结果 -->
    <div class="step-3" v-if="currentStep === 3">
      <h2>✨ 第三步：PPT生成完成</h2>
      
      <div class="result-header">
        <h3>{{ result.title }}</h3>
        <div class="result-actions">
          <el-button type="success" @click="downloadPPT('ppt')">📥 下载PPT</el-button>
          <el-button type="warning" @click="downloadPPT('pdf')">📄 下载PDF</el-button>
          <el-button type="info" @click="downloadPPT('image')">🖼️ 下载图片</el-button>
          <el-button @click="editPPT">✏️ 去编辑</el-button>
        </div>
      </div>

      <!-- PPT预览 -->
      <div class="ppt-preview">
        <div class="slides-container">
          <div 
            v-for="(slide, index) in result.slides" 
            :key="index"
            class="slide-preview"
          >
            <div class="slide-number">{{ index + 1 }}</div>
            <div class="slide-content">
              <h4>{{ slide.title }}</h4>
              <div class="slide-text" v-html="slide.content"></div>
            </div>
          </div>
        </div>
      </div>

      <div class="action-buttons">
        <el-button @click="currentStep = 2">重新选择模板</el-button>
        <el-button type="primary" @click="startOver">重新开始</el-button>
      </div>
    </div>

    <!-- 编辑模式 -->
    <div class="edit-mode" v-if="showEditor">
      <h2>✏️ PPT编辑模式</h2>
      <div class="editor-tabs">
        <el-tabs v-model="activeTab">
          <el-tab-pane label="大纲" name="outline">
            <el-input v-model="editingOutline" type="textarea" :rows="8" />
          </el-tab-pane>
          <el-tab-pane label="模板" name="template">
            <div class="template-grid">
              <div v-for="template in templates" :key="template.id" class="template-item">
                <div class="template-preview">{{ template.preview }}</div>
                <div class="template-name">{{ template.name }}</div>
              </div>
            </div>
          </el-tab-pane>
          <el-tab-pane label="插入元素" name="elements">
            <div class="elements-grid">
              <el-button>📊 图表</el-button>
              <el-button>🖼️ 图片</el-button>
              <el-button>📋 表格</el-button>
              <el-button>🎨 形状</el-button>
            </div>
          </el-tab-pane>
        </el-tabs>
      </div>
      <div class="editor-actions">
        <el-button @click="showEditor = false">完成编辑</el-button>
        <el-button type="primary" @click="saveChanges">保存更改</el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ArrowLeft } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { pptTemplates, templateScenes, templateStyles, filterTemplates } from './pptTemplates.js'

// 响应式数据
const currentStep = ref(1)
const theme = ref('')
const outlineLoading = ref(false)
const generating = ref(false)
const result = ref(null)
const showEditor = ref(false)
const activeTab = ref('outline')
const editingOutline = ref('')
const editOutlineMode = ref(false)

// 选择状态
const selectedTemplate = ref('')
const selectedScene = ref('all')
const selectedStyle = ref('all')
const selectedTemplateData = ref(null)

// 返回
const router = useRouter()
const goBack = () => { router.back() }

// 计算属性：筛选后的模板
const filteredTemplates = computed(() => {
  return filterTemplates(selectedScene.value, selectedStyle.value)
})

// 选择模板
const selectTemplate = (template) => {
  selectedTemplate.value = template.id
  selectedTemplateData.value = template
}

// 预览幻灯片
const previewSlide = (slide, index) => {
  // 更新主预览图显示选中的幻灯片
  selectedTemplateData.value.currentSlide = slide
  selectedTemplateData.value.currentSlideIndex = index
}

// 生成大纲
const generateOutline = async () => {
  if (!theme.value.trim()) {
    ElMessage.warning('请输入PPT主题')
    return
  }
  
  outlineLoading.value = true
  
  // 模拟生成大纲
  setTimeout(() => {
    outlineLoading.value = false
    // 生成示例大纲内容
    editingOutline.value = `# ${theme.value}

## 第一部分：概述
- 背景介绍
- 目标设定
- 主要内容

## 第二部分：核心内容
- 关键要点1
- 关键要点2
- 关键要点3

## 第三部分：总结
- 主要成果
- 未来展望
- 行动计划`
    
    currentStep.value = 1.5
    ElMessage.success('大纲生成完成，请预览和编辑')
  }, 1500)
}

// 确认大纲
const confirmOutline = () => {
  if (!editingOutline.value.trim()) {
    ElMessage.warning('请编辑大纲内容')
    return
  }
  currentStep.value = 2
  
  // 默认选中第一个模板
  const firstTemplate = filteredTemplates.value[0]
  if (firstTemplate) {
    selectedTemplate.value = firstTemplate.id
    selectedTemplateData.value = firstTemplate
  }
  
  ElMessage.success('大纲确认完成，请选择模板和风格')
}

// 格式化大纲显示
const formatOutline = (outline) => {
  if (!outline) return ''
  return outline
    .replace(/^# (.+)$/gm, '<h3 style="color: #1e3a8a; margin: 16px 0 8px 0;">$1</h3>')
    .replace(/^## (.+)$/gm, '<h4 style="color: #374151; margin: 12px 0 6px 0;">$1</h4>')
    .replace(/^- (.+)$/gm, '<li style="margin: 4px 0; color: #6b7280;">$1</li>')
    .replace(/\n/g, '<br>')
}

// 生成PPT
const generatePPT = async () => {
  if (!selectedTemplate.value) {
    ElMessage.warning('请选择一个PPT模板')
    return
  }
  
  generating.value = true
  
  // 使用选中的模板生成PPT
  setTimeout(() => {
    const template = selectedTemplateData.value
    result.value = {
      title: `${theme.value} - ${template.name}`,
      slides: template.slides.map(slide => ({
        title: slide.title,
        content: slide.content.replace('用户', theme.value || '用户')
      }))
    }
    generating.value = false
    currentStep.value = 3
    ElMessage.success('PPT生成完成！')
  }, 2000)
}

// 下载PPT
const downloadPPT = (type) => {
  if (type === 'ppt' && selectedTemplateData.value?.downloadUrl) {
    // 直接下载PPT模板文件
    const link = document.createElement('a')
    link.href = selectedTemplateData.value.downloadUrl
    link.download = `${selectedTemplateData.value.name}.pptx`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    ElMessage.success('PPT模板下载成功！')
  } else {
    const typeMap = {
      'ppt': 'PPT文件',
      'pdf': 'PDF文件', 
      'image': '图片文件'
    }
    ElMessage.success(`${typeMap[type]}下载功能开发中...`)
  }
}

// 编辑PPT
const editPPT = () => {
  showEditor.value = true
  editingOutline.value = theme.value
}

// 保存更改
const saveChanges = () => {
  ElMessage.success('更改已保存')
  showEditor.value = false
}

// 重新开始
const startOver = () => {
  currentStep.value = 1
  theme.value = ''
  result.value = null
  selectedTemplate.value = ''
  selectedScene.value = 'all'
  selectedStyle.value = 'all'
  selectedTemplateData.value = null
  editingOutline.value = ''
  editOutlineMode.value = false
}
</script>

<style scoped>
.auto-ppt-generator {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

.header {
  text-align: center;
  margin-bottom: 32px;
  padding: 32px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  color: white;
}

.header h1 {
  font-size: 2.5rem;
  margin-bottom: 16px;
  font-weight: 700;
}

.header p {
  font-size: 1.1rem;
  opacity: 0.9;
}

.step-1, .step-1-5, .step-2, .step-3 {
  background: white;
  padding: 32px;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  margin-bottom: 24px;
}

.step-1 h2, .step-1-5 h2, .step-2 h2, .step-3 h2 {
  color: #1e3a8a;
  margin-bottom: 24px;
  font-size: 1.5rem;
}

.input-section {
  text-align: center;
}

.theme-input {
  margin-bottom: 24px;
}

/* 场景和风格分类 */
.scene-categories, .style-categories {
  margin-bottom: 24px;
}

.category-tabs {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.category-tab {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  background: white;
  font-size: 14px;
  font-weight: 500;
}

.category-tab:hover {
  border-color: #3b82f6;
  background: #f8fafc;
}

.category-tab.active {
  border-color: #3b82f6;
  background: #eff6ff;
  color: #1e3a8a;
}

.scene-icon, .style-icon {
  font-size: 16px;
}

/* 模板选择区域 */
.template-selection-area {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
  margin-bottom: 24px;
  min-height: 500px;
}

.template-list {
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 20px;
  background: #f8fafc;
  overflow-y: auto;
  max-height: 500px;
}

.template-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 16px;
}

.template-item {
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  padding: 16px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  background: white;
}

.template-item:hover {
  border-color: #3b82f6;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
}

.template-item.active {
  border-color: #3b82f6;
  background: #eff6ff;
}

.template-preview {
  font-size: 2rem;
  margin-bottom: 8px;
}

.template-name {
  font-size: 12px;
  color: #374151;
  font-weight: 600;
  margin-bottom: 4px;
  line-height: 1.3;
}

.template-category {
  font-size: 10px;
  color: #6b7280;
  background: #f3f4f6;
  padding: 2px 6px;
  border-radius: 4px;
  display: inline-block;
}

/* 模板预览面板 */
.template-preview-panel {
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 20px;
  background: white;
}

.preview-content {
  height: 100%;
}

.preview-header h3 {
  margin: 0 0 8px 0;
  color: #1e3a8a;
  font-size: 18px;
}

.template-description {
  color: #6b7280;
  font-size: 14px;
  margin: 0 0 20px 0;
  line-height: 1.4;
}

.main-preview {
  margin-bottom: 20px;
}

.preview-slide {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  overflow: hidden;
  min-height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}

.main-slide-img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  max-height: 400px;
}

.slide-preview-content {
  text-align: center;
  color: white;
  padding: 20px;
  position: relative;
  z-index: 2;
}

.slide-icon {
  font-size: 48px;
  margin-bottom: 16px;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.3));
}

.slide-preview-content h2 {
  margin: 0 0 20px 0;
  font-size: 28px;
  font-weight: 700;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.slide-subtitle, .slide-date {
  margin: 8px 0;
  font-size: 16px;
  opacity: 0.9;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

.slide-decoration {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="20" cy="20" r="2" fill="rgba(255,255,255,0.1)"/><circle cx="80" cy="40" r="1.5" fill="rgba(255,255,255,0.1)"/><circle cx="40" cy="80" r="1" fill="rgba(255,255,255,0.1)"/></svg>');
  z-index: 1;
}

.slide-thumbnails {
  display: flex;
  gap: 12px;
  overflow-x: auto;
  padding-bottom: 8px;
}

.slide-thumbnail {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 12px;
  min-width: 120px;
  text-align: center;
  flex-shrink: 0;
  cursor: pointer;
  transition: all 0.3s ease;
}

.slide-thumbnail:hover {
  border-color: #3b82f6;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
}

.thumbnail-preview {
  position: relative;
  width: 100%;
  height: 80px;
  margin-bottom: 8px;
  border-radius: 6px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  background: white;
  border: 1px solid #e5e7eb;
}

.thumbnail-icon {
  font-size: 32px;
  color: white;
  filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.3));
}

.thumbnail-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 6px;
}

.thumbnail-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.slide-thumbnail:hover .thumbnail-overlay {
  opacity: 1;
}

.play-icon {
  font-size: 20px;
  color: white;
}

.thumbnail-number {
  background: #3b82f6;
  color: white;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 10px;
  font-weight: 600;
  margin: 0 auto 8px;
}

.thumbnail-title {
  font-size: 11px;
  color: #374151;
  line-height: 1.2;
  font-weight: 600;
  margin-bottom: 4px;
}

.thumbnail-description {
  font-size: 9px;
  color: #6b7280;
  line-height: 1.2;
  margin-bottom: 4px;
}

.thumbnail-details {
  font-size: 8px;
  color: #9ca3af;
  line-height: 1.1;
  font-style: italic;
}

.preview-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #9ca3af;
}

.placeholder-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.action-buttons {
  text-align: center;
  margin-top: 24px;
}

.result-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid #e5e7eb;
}

.result-header h3 {
  margin: 0;
  color: #1e3a8a;
}

.result-actions {
  display: flex;
  gap: 12px;
}

.ppt-preview {
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  overflow: hidden;
  margin-bottom: 24px;
}

.slides-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  padding: 24px;
}

.slide-preview {
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  padding: 20px;
  background: white;
  min-height: 200px;
}

.slide-number {
  background: #3b82f6;
  color: white;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 16px;
}

.slide-content h4 {
  margin: 0 0 12px 0;
  color: #1e3a8a;
  font-size: 16px;
}

.slide-text {
  color: #6b7280;
  font-size: 14px;
  line-height: 1.5;
}

.slide-text ul {
  margin: 0;
  padding-left: 20px;
}

.slide-text li {
  margin-bottom: 8px;
}

.edit-mode {
  background: white;
  padding: 32px;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  margin-top: 24px;
}

.edit-mode h2 {
  color: #1e3a8a;
  margin-bottom: 24px;
}

.elements-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
  gap: 12px;
}

.editor-actions {
  text-align: center;
  margin-top: 24px;
}

/* 大纲预览样式 */
.outline-preview {
  max-width: 800px;
  margin: 0 auto;
}

.outline-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid #e5e7eb;
}

.outline-header h3 {
  margin: 0;
  color: #1e3a8a;
  font-size: 1.3rem;
}

.outline-editor {
  margin-bottom: 24px;
}

.outline-display {
  background: #f8fafc;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 24px;
  min-height: 200px;
}

.outline-content {
  line-height: 1.6;
}

.outline-content h3 {
  margin: 16px 0 8px 0;
  color: #1e3a8a;
}

.outline-content h4 {
  margin: 12px 0 6px 0;
  color: #374151;
}

.outline-content li {
  margin: 4px 0;
  color: #6b7280;
}

.outline-actions {
  text-align: center;
  display: flex;
  gap: 16px;
  justify-content: center;
}

@media (max-width: 768px) {
  .auto-ppt-generator {
    padding: 16px;
  }
  
  .header {
    padding: 24px 16px;
  }
  
  .header h1 {
    font-size: 2rem;
  }
  
  .step-1, .step-1-5, .step-2, .step-3 {
    padding: 24px 16px;
  }
  
  .template-selection-area {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  
  .category-tabs {
    gap: 6px;
  }
  
  .category-tab {
    padding: 8px 12px;
    font-size: 12px;
  }
  
  .template-grid {
    grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  }
  
  .result-header {
    flex-direction: column;
    gap: 16px;
    align-items: flex-start;
  }
  
  .result-actions {
    flex-wrap: wrap;
  }
  
  .slides-container {
    grid-template-columns: 1fr;
  }
}
</style>
