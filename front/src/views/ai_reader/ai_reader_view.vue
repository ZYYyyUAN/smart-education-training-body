<template>
  <div class="reader-page">
    <div class="topbar">
      <button class="back-btn" @click="goBack">
        <svg viewBox="0 0 24 24" width="20" height="20"><path fill="currentColor" d="M20 11v2H8l5.5 5.5-1.42 1.42L4.16 12l7.92-7.92L13.5 5.5 8 11h12Z"/></svg>
        <span>返回</span>
      </button>
      <div class="document-title">
        <div class="title-icon">📄</div>
        <h1 class="title-text">{{ fileNameText }}</h1>
      </div>
      <div class="topbar-spacer"></div>
    </div>

    <div class="body">
      <div class="left">
        <div class="doc-pane" v-if="isPdf">
          <div ref="pdfContainer" class="pdf-container"></div>
        </div>
        <div class="doc-pane" v-else-if="isDocx">
          <div ref="docxContainer" class="docx-container"></div>
        </div>
        <div class="doc-pane" v-else-if="isImage">
          <div class="image-preview-container">
            <!-- 图片预览区域 -->
            <div class="image-preview-section">
              <div class="image-preview-header">
                <h3>图片预览</h3>
                <div class="image-name">{{ fileMeta.name }}</div>
              </div>
              <div class="image-preview-content">
                <div class="image-wrapper">
                  <img :src="imagePreviewUrl" :alt="fileMeta.name" class="preview-image" />
                  <!-- 行级坐标边框 -->
                  <div
                    v-for="(line, index) in ocrLines"
                    :key="index"
                    :class="['ocr-line-box', { 'highlighted': highlightedLineIndex === index }]"
                    :style="getBoundingBoxStyle(line.coord)"
                    @click="highlightLine(index)"
                    @mouseenter="highlightLine(index)"
                    @mouseleave="clearLineHighlight"
                  ></div>
                </div>
              </div>
            </div>
            
            
          </div>
        </div>
        <div class="doc-pane" v-else>
          <div class="doc-placeholder">
            <div class="doc-icon">📄</div>
            <div class="tip">暂不内嵌预览此格式，已加载文件元数据，可用于AI解析。</div>
            <a :href="rawHref" download>点击下载原文件</a>
          </div>
        </div>
      </div>

      <div class="right">
        <div class="tabs">
          <div :class="['tab', activeTab==='ocr' && 'active']" @click="activeTab='ocr'" v-if="isImage">文字识别</div>
          <div :class="['tab', activeTab==='reader' && 'active']" @click="activeTab='reader'">AI阅读器</div>
          <div :class="['tab', activeTab==='qa' && 'active']" @click="activeTab='qa'">AI问答</div>
          <div :class="['tab', activeTab==='notes' && 'active']" @click="activeTab='notes'">AI学习笔记</div>
          <div :class="['tab', activeTab==='mind' && 'active']" @click="activeTab='mind'">笔记导图</div>
          <div :class="['tab', activeTab==='resources' && 'active']" @click="activeTab='resources'">全网搜索</div>
        </div>

        <div class="panel" v-if="activeTab==='ocr'">
          <div class="ocr-panel">
            <div class="ocr-tabs">
              <div :class="['ocr-tab', ocrViewMode==='text' && 'active']" @click="ocrViewMode='text'">识别结果</div>
              <div :class="['ocr-tab', ocrViewMode==='json' && 'active']" @click="ocrViewMode='json'">JSON结果</div>
            </div>
            
            <div class="ocr-content">
              <div class="ocr-actions" v-if="ocrText">
                <button class="action-btn" @click="copyOcrText">复制识别结果</button>
                <button class="action-btn" @click="exportOcrText">导出TXT</button>
                <span class="copy-tip" v-if="copyState==='copied'">已复制到剪贴板</span>
              </div>
              <div v-if="ocrViewMode==='text'" class="ocr-text-view">
                <div v-if="ocrText" class="ocr-text-content">
                  <div
                    v-for="(line, index) in ocrLines"
                    :key="index"
                    :class="['ocr-line', { 'highlighted': highlightedLineIndex === index }]"
                    @click="highlightLine(index)"
                    @mouseenter="highlightLine(index)"
                    @mouseleave="clearLineHighlight"
                  >
                    {{ line.text }}
                  </div>
                </div>
                <div v-else-if="ocrLoading" class="ocr-loading-state">
                  <div class="loading-spinner"></div>
                  <p>正在识别图片文字...</p>
                </div>
                <div v-else-if="ocrError" class="ocr-error-state">
                  <p class="error-message">{{ ocrError }}</p>
                  <button class="retry-btn" @click="performOCRWithCoordinates">重新识别</button>
                </div>
                <div v-else class="ocr-empty-state">
                  <p>点击"重新识别"按钮开始OCR识别</p>
                  <button class="retry-btn" @click="performOCRWithCoordinates">开始识别</button>
                </div>
              </div>
              
              <div v-else-if="ocrViewMode==='json'" class="ocr-json-view">
                <pre v-if="ocrJsonResult" class="json-content">{{ ocrJsonResult }}</pre>
                <div v-else class="json-empty">
                  <p>暂无JSON数据</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="panel" v-if="activeTab==='reader'">
          <div class="section">
            <div class="sec-title">内容摘要</div>
            <div class="sec-body">
              <div v-if="!summary && !loading.summary" class="empty-state">
                <p>点击下方按钮开始生成内容摘要</p>
              </div>
              <div v-else-if="loading.summary" class="loading-state">
                <div class="loading-spinner"></div>
                <p>正在生成内容摘要...</p>
              </div>
              <div v-else class="summary-content">
                <div class="summary-text">
                  {{ summary }}
                  <span v-if="summaryStreaming" class="streaming-indicator">|</span>
                </div>
                <div class="streaming-info" v-if="summaryStreaming">
                  <div class="typing-animation">AI正在思考中...</div>
                </div>
              </div>
          </div>
            <button class="btn" :disabled="loading.summary" @click="genSummary">
              {{ loading.summary ? '生成中...' : '生成摘要' }}
            </button>
          </div>
        </div>

        <div class="panel" v-else-if="activeTab==='qa'">
          <div class="ai-chat-container">
            <div class="chat-header">
              <div class="chat-title">
                <span class="chat-icon">🤖</span>
                <h3>AI智能问答</h3>
            </div>
              <div class="chat-actions">
                <button 
                  class="chat-action-btn" 
                  @click="clearChatHistory"
                  :disabled="chatMessages.length <= 1"
                  title="清空对话"
                >
                  🗑️
                </button>
              </div>
              <div class="chat-status" :class="{ typing: isTyping }">
                <span v-if="isTyping" class="typing-indicator">
                  <span class="dot"></span>
                  <span class="dot"></span>
                  <span class="dot"></span>
                  AI正在思考...
                </span>
                <span v-else class="online-indicator">
                  <span class="status-dot"></span>
                  在线 | 已回答 {{ answeredQuestionsCount }} 个问题
                </span>
              </div>
            </div>
            
            <div class="chat-messages" ref="chatContainer">
              <div 
                v-for="(message, index) in chatMessages" 
                :key="message.id"
                class="message-wrapper"
                :class="message.role"
                :style="{ animationDelay: `${index * 0.1}s` }"
              >
                <div class="message-avatar">
                  <span v-if="message.role === 'assistant'">🤖</span>
                  <span v-else>👤</span>
                </div>
                <div class="message-bubble" :class="message.role">
                  <div class="message-content">
                    {{ message.content }}
                    <span v-if="message.typing" class="typing-cursor">|</span>
                  </div>
                  <div class="message-time">{{ formatTime(message.timestamp) }}</div>
                </div>
              </div>
              
              <!-- 正在输入的消息 -->
              <div v-if="isTyping && currentTypingMessage" class="message-wrapper assistant typing-message">
                <div class="message-avatar">
                  <span>🤖</span>
                </div>
                <div class="message-bubble assistant">
                  <div class="message-content">
                    {{ currentTypingMessage }}
                    <span class="typing-cursor">|</span>
                  </div>
                </div>
              </div>
            </div>
            
            <div class="chat-input-area">
              <div class="quick-questions" v-if="quickQuestionsLoading || quickQuestions.length > 0">
                <div class="quick-questions-label">💡 快速提问</div>
                
                <!-- Loading状态 -->
                <div v-if="quickQuestionsLoading" class="quick-questions-loading">
                  <div class="loading-dots">
                    <span></span>
                    <span></span>
                    <span></span>
                  </div>
                  <span class="loading-text">正在为您的文档生成专属问题...</span>
                </div>
                
                <!-- 快速问题按钮容器 - 添加滚动 -->
                <div v-else class="quick-questions-container">
                  <button 
                    v-for="question in quickQuestions" 
                    :key="question"
                    class="quick-question-btn"
                    :disabled="!fileMeta || isTyping"
                    @click="askQuickQuestion(question)"
                    :title="!fileMeta ? '请先上传文档' : '点击快速提问'"
                  >
                    {{ question }}
                  </button>
                </div>
              </div>
              <div class="chat-input">
                <input 
                  v-model="qaInput" 
                  placeholder="请输入您的问题..." 
                  @keydown.enter="askEnhanced"
                  :disabled="isTyping"
                  class="chat-input-field"
                />
                <button 
                  class="send-btn" 
                  @click="askEnhanced"
                  :disabled="isTyping || !qaInput.trim()"
                >
                  <span v-if="isTyping">⏳</span>
                  <span v-else>🚀</span>
                </button>
              </div>
            </div>
          </div>
        </div>

        <div class="panel" v-else-if="activeTab==='notes'">
          <div class="ai-notes-container">
            <div class="notes-header">
              <h3>AI学习笔记</h3>
              <div class="notes-actions">
                <!-- 已移除AI生成笔记按钮，仅在空状态时显示生成按钮 -->
              </div>
            </div>

            <!-- 笔记列表 -->
            <div class="notes-list">
              <div 
                v-for="(note, index) in aiNotes" 
                :key="note.id"
                class="note-card"
                :style="{ animationDelay: `${index * 0.1}s` }"
              >
                <div class="note-header">
                  <div class="note-meta">
                    <span class="note-time">{{ formatTime(note.timestamp) }}</span>
                  </div>
                </div>
                
              <div class="note-content">
                <h4 class="note-title">{{ note.title }}</h4>
                <p class="note-text">{{ note.content }}</p>
              </div>
              </div>
            </div>
            
            <!-- 空状态 -->
            <div v-if="aiNotes.length === 0" class="empty-notes">
              <div class="empty-icon">📔</div>
              <p>还没有学习笔记</p>
              <button class="action-btn primary" @click="generateAINotes">✨ 让AI帮你生成第一份笔记</button>
            </div>
          </div>
        </div>

        <div class="panel" v-else-if="activeTab==='mind'">
          <div class="mind-map-container">
            <div class="mind-map-header">
              <div class="mind-map-title">
              <h3>📊 智能思维导图</h3>
                <div class="mind-map-subtitle" v-if="mindMapData.name">{{ mindMapData.name }}</div>
              </div>
              
              <!-- 浮动控制面板 -->
              <div class="floating-controls" :class="{ visible: showControls }">
                <div class="control-group">
                  <div class="group-title">缩放</div>
                  <button class="control-btn" @click="zoomOut" :disabled="mindMapZoom <= 0.5" title="缩小">🔍-</button>
                  <span class="zoom-display">{{ Math.round(mindMapZoom * 100) }}%</span>
                  <button class="control-btn" @click="zoomIn" :disabled="mindMapZoom >= 2" title="放大">🔍+</button>
                  <button class="control-btn" @click="resetZoom" title="重置">⚡</button>
            </div>
                
                <div class="control-group">
                  <div class="group-title">操作</div>
                  <button class="control-btn" @click="generateMindMap()" :disabled="mindMapLoading" title="重新生成">
                    <span v-if="mindMapLoading">⏳</span>
                    <span v-else>🔄</span>
                  </button>
                  <button class="control-btn" @click="expandAll" title="全部展开">📂</button>
                  <button class="control-btn" @click="collapseAll" title="全部折叠">📁</button>
                  <button class="control-btn" @click="toggleExportMenu" title="导出" :class="{ active: showExportMenu }">📤</button>
                </div>
                
                <!-- 导出格式选择菜单 -->
                <div class="export-menu" v-if="showExportMenu">
                  <div class="export-category">
                    <div class="category-title">📄 文档格式</div>
                    <div class="export-options">
                      <button class="export-btn" @click="exportAs('markdown')" title="Markdown文档">
                        <span class="export-icon">📝</span>
                        <span class="export-text">Markdown</span>
                      </button>
                      <button class="export-btn" @click="exportAs('json')" title="JSON数据">
                        <span class="export-icon">🗂️</span>
                        <span class="export-text">JSON</span>
                      </button>
                      <button class="export-btn" @click="exportAs('txt')" title="纯文本">
                        <span class="export-icon">📋</span>
                        <span class="export-text">TXT</span>
                      </button>
                    </div>
                  </div>
                  
                  <div class="export-category">
                    <div class="category-title">🖼️ 图片格式</div>
                    <div class="export-options">
                      <button class="export-btn" @click="exportAs('png')" title="PNG图片">
                        <span class="export-icon">🖼️</span>
                        <span class="export-text">PNG</span>
                      </button>
                      <button class="export-btn" @click="exportAs('jpeg')" title="JPEG图片">
                        <span class="export-icon">📸</span>
                        <span class="export-text">JPEG</span>
                      </button>
                      <button class="export-btn" @click="exportAs('svg')" title="SVG矢量图">
                        <span class="export-icon">🎨</span>
                        <span class="export-text">SVG</span>
                      </button>
                    </div>
                  </div>
                  
                  <div class="export-category">
                    <div class="category-title">📊 其他格式</div>
                    <div class="export-options">
                      <button class="export-btn" @click="exportAs('xmind')" title="XMind格式">
                        <span class="export-icon">🧠</span>
                        <span class="export-text">XMind</span>
                      </button>
                      <button class="export-btn" @click="exportAs('opml')" title="OPML大纲">
                        <span class="export-icon">📊</span>
                        <span class="export-text">OPML</span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
              
              <!-- 控制面板触发按钮 -->
              <button class="controls-trigger" @click="toggleControls" :class="{ active: showControls }">
                <span v-if="showControls">✕</span>
                <span v-else>⚙️</span>
              </button>
            </div>
            
            <div class="mind-map-content">
              <div v-if="mindMapLoading" class="mind-map-loading">
                <div class="loading-spinner"></div>
                <p>AI正在分析文档，生成思维导图...</p>
                <p class="loading-tip">🤖 正在运用先进AI技术解析您的文档内容</p>
                  </div>
              
              <div v-else-if="mindMapError" class="mind-map-error">
                <div class="error-icon">⚠️</div>
                <p class="error-message">{{ mindMapError }}</p>
                <p class="error-hint">系统已自动为您加载演示内容，您可以尝试重新生成或使用当前内容。</p>
                <div class="error-actions">
                  <button class="retry-btn primary" @click="generateMindMap()">🔄 重新生成</button>
                  <button class="continue-btn" @click="mindMapError = ''">✅ 使用演示内容</button>
                </div>
              </div>
              
              <div v-else class="mind-map-viewport" 
                   @wheel="handleWheelZoomOptimized" 
                   @mousedown="startDrag" 
                   @mousemove="handleDrag" 
                   @mouseup="endDrag">
                <div class="mind-map-tree" 
                     ref="mindMapTree" 
                     :style="{ 
                       transform: `scale(${mindMapZoom}) translate(${dragOffset.x}px, ${dragOffset.y}px)`,
                       transformOrigin: 'center center'
                     }">
                  <div class="tree-node root-node" v-if="mindMapData.name">
                    <div class="node-content" @click="toggleNodeDetails('root')">
                      <span class="node-text main-title">{{ mindMapData.name }}</span>
                      <span class="node-count" v-if="mindMapData.children">({{ mindMapData.children.length }})</span>
                  </div>
                    <div class="node-children" v-if="mindMapData.children && !collapsedNodes.includes('root')">
                    <div 
                      v-for="(child, index) in mindMapData.children" 
                      :key="index"
                      class="tree-node branch-node"
                      :style="{ animationDelay: `${index * 0.2}s` }"
                    >
                        <div class="node-content" @click="toggleNodeDetails(`branch-${index}`)">
                          <span class="node-text branch-title">{{ child.name }}</span>
                          <span class="node-count" v-if="child.children">({{ child.children.length }})</span>
                          <button class="collapse-btn" @click.stop="toggleNode(`branch-${index}`)" v-if="child.children">
                            {{ collapsedNodes.includes(`branch-${index}`) ? '+' : '-' }}
                          </button>
                      </div>
                        <div class="node-children" v-if="child.children && !collapsedNodes.includes(`branch-${index}`)">
                        <div 
                          v-for="(leaf, leafIndex) in child.children" 
                          :key="leafIndex"
                          class="tree-node leaf-node"
                          :style="{ animationDelay: `${(index * child.children.length + leafIndex) * 0.1 + 0.5}s` }"
                        >
                            <div class="node-content" @click="toggleNodeDetails(`leaf-${index}-${leafIndex}`)">
                              <span class="node-text leaf-title">{{ leaf.name }}</span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                  
                  <!-- 空状态显示 -->
                  <div v-else class="empty-mind-map">
                    <div class="empty-icon">🧠</div>
                    <h4>还没有思维导图</h4>
                    <p>点击下方按钮，让AI帮你分析文档并生成思维导图</p>
                      <button class="action-btn primary" @click="generateMindMap()" :disabled="mindMapLoading">
                        <span v-if="mindMapLoading">⏳ 生成中...</span>
                        <span v-else>生成思维导图</span>
                      </button>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 节点详情面板 -->
            <div v-if="selectedNodeDetails" class="node-details-panel">
              <div class="details-header">
                <h4>{{ selectedNodeDetails.title }}</h4>
                <button class="close-details" @click="selectedNodeDetails = null">✕</button>
              </div>
              <div class="details-content">
                <p>{{ selectedNodeDetails.content }}</p>
              </div>
            </div>
          </div>
        </div>

        <div class="panel" v-else-if="activeTab==='resources'">
          <div class="resources-container">
            <div class="resources-header">
              <h3>🔍 全网搜索</h3>
              <div class="resources-stats">
                <span class="stats-item">
                  <span class="stats-number">{{ filteredResources.length }}</span>
                  <span class="stats-label">个搜索链接</span>
                </span>
              </div>
            </div>


            <!-- 加载状态 -->
            <div v-if="resourcesLoading" class="resources-loading">
              <div class="loading-spinner"></div>
              <p>🔍 正在生成搜索链接...</p>
            </div>
            
            <!-- 错误状态 -->
            <div v-else-if="resourcesError" class="resources-error">
              <div class="error-icon">❌</div>
              <p>加载失败：{{ resourcesError }}</p>
              <button class="action-btn primary" @click="loadInitialResources">重新加载</button>
            </div>

            <!-- 资源列表 -->
            <div v-else class="resources-list">
              <div 
                v-for="(resource, index) in filteredResources" 
                :key="resource.id"
                class="resource-card"
                :style="{ animationDelay: `${index * 0.1}s` }"
                @click="openResource(resource)"
              >
                <div class="resource-header">
                  <div class="resource-type-badge" :class="resource.type">
                    <span class="type-icon">{{ getResourceTypeIcon(resource.type) }}</span>
                    <span class="type-text">{{ getResourceTypeName(resource.type) }}</span>
                  </div>
                  <div class="resource-format">
                    <span class="format-badge" :class="resource.format">{{ resource.format ? resource.format.toUpperCase() : 'UNKNOWN' }}</span>
                  </div>
                </div>
                
                <div class="resource-content">
                  <h4 class="resource-title">{{ resource.title }}</h4>
                  <p class="resource-description">{{ truncateText(resource.description, 120) }}</p>
                  
                </div>
                
                <div class="resource-meta">
                  <div class="resource-source">
                    <span class="source-icon">🌐</span>
                    <span class="source-text">{{ resource.source }}</span>
                  </div>
                </div>
                
              </div>
              
              <!-- 空状态 -->
              <div v-if="filteredResources.length === 0" class="empty-resources">
                <div class="empty-icon">📭</div>
                <p>没有找到搜索链接</p>
                <button class="action-btn primary" @click="clearAllFilters">清除筛选条件</button>
              </div>
            </div>
            
          </div>
        </div>

        
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const fileMeta = ref({})

const activeTab = ref('reader')
const summary = ref('')
const summaryChunks = ref([])
const summaryStreaming = ref(false)
const notes = ref('')
const qaInput = ref('')

// 监听标签切换，只有在切换到AI问答时才加载快速问题
watch(activeTab, async (newTab, oldTab) => {
  if (newTab === 'qa' && oldTab !== 'qa') {
    console.log('🔄 切换到AI问答标签，开始加载快速问题...')
    await enhanceQaExperience()
  }
}, { immediate: false })
const qaLog = ref([])
const loading = ref({ summary: false })

// OCR相关状态
const ocrText = ref('')
const ocrLoading = ref(false)
const ocrError = ref('')
const ocrJsonResult = ref('')
const ocrWords = ref([])
const ocrLines = ref([])
const ocrViewMode = ref('text')
const highlightedWordIndex = ref(-1)
const highlightedLineIndex = ref(-1)
const copyState = ref('idle')

// 笔记导图相关状态
const mindMapData = ref({
  name: '',
  children: []
})

// AI学习笔记相关状态（仅保留AI生成功能）
const aiNotes = ref([])

// AI问答增强状态
const chatMessages = ref([
  {
    id: 1,
    role: 'assistant',
    content: '你好！我是AI阅读助手，可以帮你解答关于文档内容的任何问题。请随时向我提问！',
    timestamp: new Date('2024-01-15 10:00:00'),
    typing: false
  }
])
const isTyping = ref(false)
const currentTypingMessage = ref('')
const quickQuestions = ref([])
const quickQuestionsLoading = ref(false)

// 默认快速问题（作为备用）
const defaultQuickQuestions = [
  '📋 总结文档要点',
  '🔍 解释关键概念', 
  '💡 提供学习建议',
  '📊 分析数据内容'
]

// 根据文档类型获取优化的默认问题
const getOptimizedDefaultQuestions = () => {
  const documentType = getDocumentType()
  const fileName = fileMeta.value?.name || ''
  
  if (documentType === 'word' && fileName.includes('复习')) {
    return [
      '📋 归纳复习重点内容',
      '🔍 解析核心知识点',
      '💡 制定学习计划建议',
      '📊 梳理知识框架结构',
      '🎯 找出考试要点',
      '📝 总结记忆方法'
    ]
  } else if (documentType === 'word') {
    return [
      '📋 概括文档主要内容',
      '🔍 分析关键信息点',
      '💡 提炼核心观点',
      '📊 整理文档结构',
      '🎯 找出重要结论',
      '📝 归纳要点总结'
    ]
  } else if (documentType === 'pdf') {
    return [
      '📋 提取文档摘要',
      '🔍 分析章节要点',
      '💡 解释专业术语',
      '📊 梳理逻辑关系',
      '🎯 总结关键发现',
      '📝 制作学习笔记'
    ]
  }
  
  return [...defaultQuickQuestions]
}

// 动态加载快速问题
const loadQuickQuestions = async () => {
  // 如果已经加载过且有数据，不重复加载
  if (quickQuestions.value.length > 0 && !quickQuestions.value[0].includes('📋 提取文档摘要')) {
    console.log('✅ 快速问题已存在，跳过重复加载')
    return
  }
  
  quickQuestionsLoading.value = true
  console.log('📥 开始加载快速问题...')
  
  try {
    const documentType = getDocumentType()
    
    // 添加请求超时控制
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 10000) // 10秒超时
    
    const response = await fetch('/ai-qa/quick-questions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      },
      signal: controller.signal,
      body: JSON.stringify({
        documentType: documentType,
        fileName: fileMeta.value.name
      })
    })
    
    clearTimeout(timeoutId)
    
    if (response.ok) {
      const result = await response.json()
      console.log('快速问题API响应:', result)
      
      // 检查多种成功响应格式
      const isSuccess = result.success === true || result.code === 200 || result.message === '操作成功'
      
      if (isSuccess && result.data && Array.isArray(result.data) && result.data.length > 0) {
        quickQuestions.value = result.data
        console.log('✅ 动态加载快速问题成功:', result.data)
        return
      } else if (result.data && typeof result.data === 'string') {
        // 尝试解析字符串格式的JSON数组
        try {
          const parsedData = JSON.parse(result.data)
          if (Array.isArray(parsedData) && parsedData.length > 0) {
            quickQuestions.value = parsedData
            console.log('✅ 解析字符串格式快速问题成功:', parsedData)
            return
          }
        } catch (parseError) {
          console.warn('⚠️ 解析快速问题JSON失败:', parseError)
        }
      } else {
        console.warn('⚠️ API响应格式不符合预期:', {
          isSuccess,
          hasData: !!result.data,
          isArray: Array.isArray(result.data),
          dataLength: result.data?.length
        })
      }
    }
    
    // API返回空数据或失败，使用优化的默认问题
    console.log('📝 API响应格式不符合预期，使用优化的默认快速问题')
    quickQuestions.value = getOptimizedDefaultQuestions()
    
  } catch (error) {
    console.warn('⚠️ 加载快速问题失败，使用优化的默认问题:', error)
    
    // 检查是否是超时错误
    if (error.name === 'AbortError') {
      console.error('❌ 快速问题API请求超时 (10秒)')
    } else if (error.message?.includes('500')) {
      console.error('❌ 后端服务错误，可能是MongoDB消息冲突问题')
    }
    
    quickQuestions.value = getOptimizedDefaultQuestions()
  } finally {
    quickQuestionsLoading.value = false
    console.log('🏁 快速问题加载流程结束')
  }
}

// 获取文档类型
const getDocumentType = () => {
  const fileName = fileMeta.value?.name || ''
  const type = fileMeta.value?.type || ''
  
  if (type.includes('pdf') || fileName.toLowerCase().endsWith('.pdf')) {
    return 'pdf'
  } else if (type.includes('wordprocessingml') || fileName.toLowerCase().endsWith('.docx')) {
    return 'word'
  } else if (type.startsWith('image/')) {
    return 'image'
  } else if (fileName.toLowerCase().endsWith('.txt')) {
    return 'text'
  } else {
    return 'general'
  }
}

// 思维导图相关状态
const mindMapTree = ref(null)
const mindMapLoading = ref(false)
const mindMapError = ref('')
const mindMapZoom = ref(1)
const mindMapViewMode = ref('tree') // tree, radial, compact
const collapsedNodes = ref([])
const selectedNodeDetails = ref(null)
const dragOffset = ref({ x: 0, y: 0 })
const isDragging = ref(false)
const dragStart = ref({ x: 0, y: 0 })
const showControls = ref(false)
const showExportMenu = ref(false)

// 搜索链接数据
const relatedResources = ref([])
const resourcesLoading = ref(false)
const resourcesError = ref('')
const resourcesLoaded = ref(false)

const resourceSearchQuery = ref('')
const selectedResourceType = ref('all')
const selectedFormat = ref('all')
const sortBy = ref('publishTime') // publishTime, downloadCount, rating

const resourceTypes = [
  { value: 'all', label: '全部类型' },
  { value: 'document', label: '文档资料' },
  { value: 'exercise', label: '练习题集' },
  { value: 'summary', label: '知识总结' },
  { value: 'courseware', label: '课件资源' }
]

const resourceFormats = [
  { value: 'all', label: '全部格式' },
  { value: 'pdf', label: 'PDF' },
  { value: 'docx', label: 'Word' },
  { value: 'pptx', label: 'PowerPoint' },
  { value: 'txt', label: '文本' }
]

const isPdf = computed(() => (fileMeta.value?.type || '').includes('pdf'))
const isDocx = computed(() => {
  const type = fileMeta.value?.type || ''
  const name = (fileMeta.value?.name || '').toLowerCase()
  return type.includes('wordprocessingml.document') || name.endsWith('.docx')
})
const isImage = computed(() => {
  const type = fileMeta.value?.type || ''
  const name = (fileMeta.value?.name || '').toLowerCase()
  return type.startsWith('image/') || /\.(jpg|jpeg|png|bmp|gif|webp)$/i.test(name)
})
const pdfUrl = ref('')
const pdfSrc = computed(() => pdfUrl.value || fileMeta.value?.url || fileMeta.value?.data || '')
const pdfContainer = ref(null)
const pdfViewerSrc = computed(() => {
  if (!pdfSrc.value) return ''
  // 使用内置的 PDF.js viewer 去掉浏览器自带头部，且可全屏适配
  const origin = window.location.origin
  const viewerPath = `${origin}/pdfjs-2.16.105/web/viewer.html`
  try {
    const encoded = encodeURIComponent(pdfSrc.value)
    return `${viewerPath}?file=${encoded}#toolbar=0&navpanes=0`
  } catch {
    return pdfSrc.value
  }
})
const rawHref = computed(() => fileMeta.value?.url || fileMeta.value?.data || '')
const fileNameText = computed(() => {
  // 只显示文件名，不显示ID
  const name = fileMeta.value?.name || ''
  return name || '未知文档'
})

// AI已回答问题数量统计
const answeredQuestionsCount = computed(() => {
  // 统计role为'assistant'的消息数量
  return chatMessages.value.filter(msg => msg.role === 'assistant').length-1
})

// 图片预览URL
const imagePreviewUrl = computed(() => {
  const id = route.params.id
  
  // 如果有全局文件存储，创建object URL
  if (window.__AI_READER_FILES__ && window.__AI_READER_FILES__[id]) {
    const file = window.__AI_READER_FILES__[id]
    return URL.createObjectURL(file)
  }
  
  // 如果有URL，直接使用
  if (fileMeta.value?.url) {
    return fileMeta.value.url
  }
  
  // 如果有data URL，直接使用
  if (fileMeta.value?.data) {
    return fileMeta.value.data
  }
  
  return ''
})

const docxContainer = ref(null)
let objectUrlToRevoke = ''

const loadFile = async () => {
  const id = route.params.id
  const raw = sessionStorage.getItem(`ai_reader_file_${id}`)
  if (!raw) {
    router.replace('/ai_reader')
    return
  }
  try {
    fileMeta.value = JSON.parse(raw)
  } catch {
    router.replace('/ai_reader')
  }
  
  // 如果是 docx 则渲染
  if (isDocx.value) {
    renderDocx()
  }
  // 如果是 pdf，渲染
  if (isPdf.value) {
    renderPdf()
  }
  // 如果是图片，自动进行OCR识别
  if (isImage.value) {
    await performOCRWithCoordinates()
  }
  
  // 文件加载完成
  await nextTick()
  console.log('✅ 文件加载完成，AI问答功能已就绪')
}

const goBack = () => router.back()

// 执行OCR识别
const performOCR = async () => {
  try {
    ocrLoading.value = true
    ocrError.value = ''
    ocrText.value = ''
    
    console.log('开始OCR识别图片:', fileMeta.value.name)
    console.log('fileMeta:', fileMeta.value)
    console.log('全局文件存储:', window.__AI_READER_FILES__)
    
    // 获取图片文件
    const imageFile = await getImageFile()
    if (!imageFile) {
      throw new Error('无法获取图片文件')
    }
    
    console.log('成功获取图片文件:', imageFile.name, imageFile.size, imageFile.type)
    
    // 创建FormData
    const formData = new FormData()
    formData.append('image', imageFile)
    
    console.log('准备发送OCR请求...')
    
    // 调用OCR API
            const response = await fetch('/ai-reader/ocr', {
      method: 'POST',
      body: formData
    })
    
    console.log('OCR响应状态:', response.status, response.statusText)
    
    if (!response.ok) {
      const errorData = await response.json()
      throw new Error(errorData.message || 'OCR识别失败')
    }
    
    const result = await response.json()
    console.log('OCR响应结果:', result)
    
    if (result.success) {
      ocrText.value = result.text
      console.log('OCR识别成功，识别文字长度:', result.text.length)
    } else {
      throw new Error(result.message || 'OCR识别失败')
    }
    
  } catch (error) {
    console.error('OCR识别失败:', error)
    ocrError.value = error.message
  } finally {
    ocrLoading.value = false
  }
}

// 执行OCR识别 - 返回完整坐标信息
const performOCRWithCoordinates = async () => {
  try {
    ocrLoading.value = true
    ocrError.value = ''
    ocrText.value = ''
    ocrJsonResult.value = ''
    ocrWords.value = []
    ocrLines.value = []
    
    console.log('开始OCR识别图片（完整模式）:', fileMeta.value.name)
    
    // 获取图片文件
    const imageFile = await getImageFile()
    if (!imageFile) {
      throw new Error('无法获取图片文件')
    }
    
    // 创建FormData
    const formData = new FormData()
    formData.append('image', imageFile)
    
    // 调用OCR API - 完整模式
            const response = await fetch('/ai-reader/ocr-with-coordinates', {
      method: 'POST',
      body: formData
    })
    
    if (!response.ok) {
      const errorData = await response.json()
      throw new Error(errorData.message || 'OCR识别失败')
    }
    
    const result = await response.json()
    
    if (result.success) {
      ocrJsonResult.value = result.result
      
      // 解析JSON结果，提取文字和坐标信息
      const parsedResult = JSON.parse(result.result)
      const words = extractWordsFromOCRResult(parsedResult)
      ocrWords.value = words
      const lines = extractLinesFromOCRResult(parsedResult)
      ocrLines.value = lines
      
      // 提取纯文本
      ocrText.value = lines.map(line => line.text).join('\n')
      
      console.log('OCR识别成功，提取到', words.length, '个文字')
    } else {
      throw new Error(result.message || 'OCR识别失败')
    }
    
  } catch (error) {
    console.error('OCR识别失败:', error)
    ocrError.value = error.message
  } finally {
    ocrLoading.value = false
  }
}

// 从OCR结果中提取文字和坐标信息
const extractWordsFromOCRResult = (ocrResult) => {
  const words = []
  
  try {
    if (ocrResult.pages && ocrResult.pages.length > 0) {
      for (const page of ocrResult.pages) {
        if (page.lines && page.lines.length > 0) {
          for (const line of page.lines) {
            if (line.words && line.words.length > 0) {
              for (const word of line.words) {
                if (word.content && word.coord) {
                  words.push({
                    content: word.content,
                    coord: word.coord,
                    conf: word.conf || 0
                  })
                }
              }
            }
          }
        }
      }
    }
  } catch (error) {
    console.error('解析OCR结果失败:', error)
  }
  
  return words
}

// 从OCR结果中提取行（文本+行级坐标）
const extractLinesFromOCRResult = (ocrResult) => {
  const lines = []
  try {
    if (ocrResult.pages && ocrResult.pages.length > 0) {
      for (const page of ocrResult.pages) {
        if (page.lines && page.lines.length > 0) {
          for (const line of page.lines) {
            const text = (line.words || []).map(w => w.content || '').join('')
            if (text) {
              lines.push({ text, coord: line.coord || null })
            }
          }
        }
      }
    }
  } catch (e) {
    console.error('解析行失败:', e)
  }
  return lines
}

// 高亮显示文字
const highlightWord = (index) => {
  highlightedWordIndex.value = index
}

// 清除高亮
const clearHighlight = () => {
  highlightedWordIndex.value = -1
}

// 行高亮
const highlightLine = (index) => {
  highlightedLineIndex.value = index
}
const clearLineHighlight = () => {
  highlightedLineIndex.value = -1
}

// 复制识别结果
const copyOcrText = async () => {
  try {
    const text = ocrText.value || ocrWords.value.map(w => w.content).join('')
    await navigator.clipboard.writeText(text)
    copyState.value = 'copied'
    setTimeout(() => (copyState.value = 'idle'), 1500)
  } catch (e) {
    alert('复制失败，请手动选择文本复制')
  }
}

// 导出TXT
const exportOcrText = () => {
  const text = ocrText.value || ocrWords.value.map(w => w.content).join('')
  const blob = new Blob([text], { type: 'text/plain;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = (fileMeta.value?.name || 'ocr') + '.txt'
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

// 计算边框样式
const getBoundingBoxStyle = (coord) => {
  if (!coord || coord.length < 4) return {}
  
  // 计算边界框的位置和大小
  const x = Math.min(...coord.map(p => p.x))
  const y = Math.min(...coord.map(p => p.y))
  const width = Math.max(...coord.map(p => p.x)) - x
  const height = Math.max(...coord.map(p => p.y)) - y
  
  return {
    position: 'absolute',
    left: `${x}px`,
    top: `${y}px`,
    width: `${width}px`,
    height: `${height}px`,
    border: '2px solid #ffd700',
    borderRadius: '2px',
    pointerEvents: 'auto',
    zIndex: 10
  }
}

// 获取图片文件
const getImageFile = async () => {
  const id = route.params.id
  
  // 首先尝试从全局文件存储中获取
  if (window.__AI_READER_FILES__ && window.__AI_READER_FILES__[id]) {
    const file = window.__AI_READER_FILES__[id]
    console.log('从全局存储获取文件:', file.name, file.size)
    return file
  }
  
  // 如果fileMeta中有file对象，直接使用
  if (fileMeta.value.file) {
    return fileMeta.value.file
  }
  
  // 如果有URL，尝试从URL获取文件
  if (fileMeta.value.url) {
    try {
      const response = await fetch(fileMeta.value.url)
      const blob = await response.blob()
      return new File([blob], fileMeta.value.name, { type: fileMeta.value.type })
    } catch (error) {
      console.error('从URL获取图片失败:', error)
      return null
    }
  }
  
  console.error('无法获取图片文件，fileMeta:', fileMeta.value)
  return null
}

// 从文档中提取文本内容
const extractDocumentText = async () => {
  try {
    const id = route.params.id
    
    if (isPdf.value) {
      // 对于PDF，使用之前提取的文本内容
      if (window.__AI_READER_PDF__ && window.__AI_READER_PDF__[id]) {
        const pdfData = window.__AI_READER_PDF__[id]
        if (pdfData.textContent && pdfData.textContent.trim()) {
          return `PDF文档：${fileMeta.value.name}\n\n${pdfData.textContent}`
        }
      }
      
      // 如果没有提取到文本，返回基本信息
      return `PDF文档：${fileMeta.value.name}\n文件类型：${fileMeta.value.type}\n文件大小：${(fileMeta.value.size / 1024).toFixed(2)} KB`
      
    } else if (isDocx.value) {
      // 对于DOCX，从容器中提取文本
      const container = docxContainer.value
      if (container) {
        const text = container.innerText || container.textContent
        if (text && text.trim()) {
          return `Word文档：${fileMeta.value.name}\n\n${text}`
        }
      }
      
      // 如果没有提取到文本，返回基本信息
      return `Word文档：${fileMeta.value.name}\n文件类型：${fileMeta.value.type}\n文件大小：${(fileMeta.value.size / 1024).toFixed(2)} KB`
      
    } else if (isImage.value) {
      // 对于图片，使用OCR识别的文本
      if (ocrText.value && ocrText.value.trim()) {
        return `图片文件：${fileMeta.value.name}\n\nOCR识别内容：\n${ocrText.value}`
      }
      
      // 如果OCR还在进行中，提示用户等待
      if (ocrLoading.value) {
        return `图片文件：${fileMeta.value.name}\n\n正在识别图片文字，请稍后重试...`
      }
      
      // 如果OCR失败，返回错误信息
      if (ocrError.value) {
        return `图片文件：${fileMeta.value.name}\n\nOCR识别失败：${ocrError.value}`
      }
      
      // 如果没有OCR结果，返回基本信息
      return `图片文件：${fileMeta.value.name}\n文件类型：${fileMeta.value.type}\n文件大小：${(fileMeta.value.size / 1024).toFixed(2)} KB`
    }
    
    // 如果无法提取具体内容，返回文件基本信息
    return `文档：${fileMeta.value.name}\n文件类型：${fileMeta.value.type}\n文件大小：${(fileMeta.value.size / 1024).toFixed(2)} KB`
  } catch (error) {
    console.error('提取文档文本失败:', error)
    return `文档：${fileMeta.value.name}\n文件类型：${fileMeta.value.type}\n文件大小：${(fileMeta.value.size / 1024).toFixed(2)} KB`
  }
}

const genSummary = async () => {
  if (loading.value.summary) return
  
  try {
  loading.value.summary = true
    summaryChunks.value = []
    summary.value = '' // 清空之前的摘要内容
    summaryStreaming.value = true
    
    // 提取文档内容
    const documentText = await extractDocumentText()
    
    // 调用后端API生成摘要
    console.log('正在调用后端API，文档内容长度:', documentText.length)
    console.log('文档内容预览:', documentText.substring(0, 200) + '...')
    
    // 使用完整的后端URL，确保端口正确
            const backendUrl = '/ai-reader/generate-summary'
    console.log('调用后端URL:', backendUrl)
    console.log('请求参数:', {
      fileName: fileMeta.value.name,
      contentLength: documentText.length
    })
    
    const response = await fetch(backendUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      },
      body: JSON.stringify({
        fileName: fileMeta.value.name,
        content: documentText
      })
    })
    
    console.log('API响应状态:', response.status, response.statusText)
    
    if (!response.ok) {
      const errorText = await response.text()
      console.error('API错误详情:', errorText)
      throw new Error(`API请求失败: ${response.status} ${response.statusText}`)
    }
    
    // 处理流式响应 - 使用简单的UTF-8解码器
    const reader = response.body.getReader()
    const decoder = new TextDecoder('utf-8')
    let fullText = ''
    
    while (true) {
      const { done, value } = await reader.read()
      if (done) break
      
      const chunk = decoder.decode(value, { stream: true })
      if (chunk.trim()) {
        summaryChunks.value.push(chunk)
        summary.value += chunk
        fullText += chunk
        console.log('接收到内容片段:', chunk)
      }
    }
    
  } catch (error) {
    console.error('生成摘要失败:', error)
    
    // 提供更详细的错误信息
    if (error.message.includes('Failed to fetch')) {
      summary.value = '❌ 无法连接到后端服务，请确保后端已启动并运行在8080端口'
    } else if (error.message.includes('API请求失败')) {
      summary.value = '❌ 后端API调用失败，请检查后端日志'
    } else {
      summary.value = `❌ 生成摘要失败: ${error.message}`
    }
  } finally {
    loading.value.summary = false
    summaryStreaming.value = false
  }
}

const ask = async () => {
  const q = qaInput.value.trim()
  if (!q) return
  qaLog.value.push({ role: 'user', text: q })
  qaInput.value = ''
  const a = await fakeLLM(`回答：${q}`)
  qaLog.value.push({ role: 'bot', text: a })
}

// 增强的AI问答方法
const askEnhanced = async () => {
  const q = qaInput.value.trim()
  if (!q || isTyping.value) return
  
  // 添加用户消息
  const userMessage = {
    id: Date.now(),
    role: 'user',
    content: q,
    timestamp: new Date(),
    typing: false
  }
  chatMessages.value.push(userMessage)
  qaInput.value = ''
  
  // 调用后端API
  await callAIQaAPI(q)
  
  // 滚动到底部
  await nextTick()
  scrollToBottom()
}

// 调用后端AI问答API
const callAIQaAPI = async (question) => {
  try {
    isTyping.value = true
    currentTypingMessage.value = ''
    
    // 获取文档内容
    const documentContent = await extractDocumentText()
    
    // 将聊天历史转换为字符串格式
    const chatHistoryText = chatMessages.value.slice(-5)
      .map(msg => `${msg.role === 'user' ? '用户' : 'AI'}: ${msg.content}`)
      .join('\n')
    
    const requestPayload = {
      question: question,
      documentContent: documentContent,
      fileName: fileMeta.value?.name || 'unknown',
      chatHistory: chatHistoryText || ''
    }
    
    console.log('发送AI问答请求:', {
      url: '/ai-qa/document-qa',
      payload: {
        question: question,
        documentContentLength: documentContent?.length || 0,
        fileName: requestPayload.fileName,
        chatHistoryLength: chatHistoryText?.length || 0
      }
    })
    
    const response = await fetch('/ai-qa/document-qa', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      },
      body: JSON.stringify(requestPayload)
    })
    
    console.log('收到API响应:', {
      status: response.status,
      statusText: response.statusText,
      headers: Object.fromEntries(response.headers.entries())
    })
    
    if (!response.ok) {
      const errorText = await response.text()
      console.error('API错误详情:', {
        status: response.status,
        statusText: response.statusText,
        errorBody: errorText
      })
      throw new Error(`API请求失败: ${response.status} - ${response.statusText}${errorText ? '\n错误详情: ' + errorText : ''}`)
    }
    
    // 处理流式响应
    const reader = response.body.getReader()
    const decoder = new TextDecoder('utf-8')
    let fullResponse = ''
    
    while (true) {
      const { done, value } = await reader.read()
      if (done) break
      
      const chunk = decoder.decode(value, { stream: true })
      if (chunk.trim()) {
        currentTypingMessage.value += chunk
        fullResponse += chunk
        
        // 每隔几个字符滚动一次
        if (fullResponse.length % 10 === 0) {
          await nextTick()
          scrollToBottom()
        }
      }
    }
    
    // 完成后添加到消息列表
    const aiMessage = {
      id: Date.now(),
      role: 'assistant',
      content: fullResponse,
      timestamp: new Date(),
      typing: false
    }
    chatMessages.value.push(aiMessage)
    
  } catch (error) {
    console.error('AI问答API调用失败:', error)
    
    // 添加错误消息和重试选项
    const errorMessage = {
      id: Date.now(),
      role: 'assistant',
      content: `❌ 抱歉，AI问答服务暂时不可用。\n\n错误信息：${error.message}\n\n💡 您可以：\n• 检查网络连接\n• 稍后重试\n• 尝试其他问题`,
      timestamp: new Date(),
      typing: false,
      isError: true,
      retryQuestion: question // 保存问题以便重试
    }
    chatMessages.value.push(errorMessage)
  } finally {
    isTyping.value = false
    currentTypingMessage.value = ''
  }
}

// 重试问答
const retryQuestion = async (question) => {
  await callAIQaAPI(question)
}

// 清空对话历史
const clearChatHistory = () => {
  if (confirm('确定要清空所有对话记录吗？')) {
    chatMessages.value = [
      {
        id: Date.now(),
        role: 'assistant',
        content: '你好！我是AI阅读助手，可以帮你解答关于文档内容的任何问题。请随时向我提问！',
        timestamp: new Date(),
        typing: false
      }
    ]
    console.log('对话历史已清空')
  }
}

// 快速问题
const askQuickQuestion = async (question) => {
  if (!fileMeta.value) {
    alert('请先上传文档再进行提问')
    return
  }
  
  if (isTyping.value) {
    alert('AI正在回复中，请稍后再提问')
    return
  }
  
  // 设置问题到输入框，让用户看到
  qaInput.value = question
  
  // 添加小延迟让用户看到问题被填入
  await new Promise(resolve => setTimeout(resolve, 200))
  
  // 发送问题
  askEnhanced()
}

// 模拟AI回复的打字效果
const simulateAIResponse = async (question) => {
  isTyping.value = true
  currentTypingMessage.value = ''
  
  // 模拟AI思考时间
  await new Promise(resolve => setTimeout(resolve, 800))
  
  // 简化的模拟回答（实际应调用真实API）
  const fullResponse = `关于"${question}"的问题，我来为您详细解答：\n\n基于文档内容分析，这是一个很有意思的问题。\n\n请注意：这是模拟回复，实际应用中需要调用真实的AI API。`
  
  // 逐字显示效果
  for (let i = 0; i < fullResponse.length; i++) {
    currentTypingMessage.value = fullResponse.substring(0, i + 1)
    await new Promise(resolve => setTimeout(resolve, 30))
    
    // 滚动到底部
    if (i % 10 === 0) {
      await nextTick()
      scrollToBottom()
    }
  }
  
  // 完成打字效果，添加到消息列表
  const aiMessage = {
    id: Date.now(),
    role: 'assistant',
    content: fullResponse,
    timestamp: new Date(),
    typing: false
  }
  chatMessages.value.push(aiMessage)
  
  isTyping.value = false
  currentTypingMessage.value = ''
  
  await nextTick()
  scrollToBottom()
}

// 滚动到聊天底部
const scrollToBottom = () => {
  const container = document.querySelector('.chat-messages')
  if (container) {
    container.scrollTop = container.scrollHeight
  }
}

// 笔记相关方法（仅保留AI生成功能）






const generateAINotes = async () => {
  try {
    console.log('🚀 开始生成AI笔记...')
    
    // 检查认证状态
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('请先登录后再使用AI笔记功能')
    }
    
    // 获取文档内容
    console.log('📄 正在提取文档内容...')
    const documentContent = await extractDocumentText()
    console.log('📄 文档内容长度:', documentContent.length)
    
    // 限制文档内容长度，避免过长导致处理慢
    const maxContentLength = 8000 // 限制在8000字符以内
    const processedContent = documentContent.length > maxContentLength 
      ? documentContent.substring(0, maxContentLength) + '\n...(内容已截取前8000字符进行分析)'
      : documentContent
    
    console.log('🔄 发送AI笔记生成请求...')
    console.log('📊 处理内容长度:', processedContent.length)
    
    // 添加超时控制
    const controller = new AbortController()
    const timeoutId = setTimeout(() => {
      controller.abort()
      console.log('⏰ AI笔记生成请求超时')
    }, 60000) // 60秒超时
    
    const response = await fetch('/ai-notes-generation/generate', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        fileName: fileMeta.value.name,
        documentContent: processedContent
      }),
      signal: controller.signal
    })
    
    clearTimeout(timeoutId)
    
    if (!response.ok) {
      throw new Error(`API请求失败: ${response.status}`)
    }
    
    console.log('✅ 收到AI笔记响应，开始处理流式数据...')
    
    // 处理流式响应
    const reader = response.body.getReader()
    const decoder = new TextDecoder('utf-8')
    let fullContent = ''
    let chunkCount = 0
    
    // 创建一个临时的笔记对象来显示生成过程
    const tempNote = {
      id: Date.now(),
      title: '🤖 AI正在生成学习笔记...',
      content: '正在分析文档内容，请稍候...\n\n📊 AI正在运用先进的自然语言处理技术分析您的文档',
      timestamp: new Date()
    }
    aiNotes.value.unshift(tempNote)
    
    const startTime = Date.now()
    
    while (true) {
      const { done, value } = await reader.read()
      if (done) break
      
      const chunk = decoder.decode(value, { stream: true })
      if (chunk.trim()) {
        fullContent += chunk
        chunkCount++
        
        // 实时更新笔记内容
        tempNote.content = fullContent
        tempNote.title = `🤖 AI正在生成学习笔记... (${chunkCount}块数据)`
        
        // 每5个chunk输出一次进度日志
        if (chunkCount % 5 === 0) {
          console.log(`📝 已接收 ${chunkCount} 块数据，当前内容长度: ${fullContent.length}`)
        }
        
        // 每50个chunk强制触发一次UI更新
        if (chunkCount % 50 === 0) {
          aiNotes.value = [...aiNotes.value]
        }
      }
    }
    
    const endTime = Date.now()
    const duration = Math.round((endTime - startTime) / 1000)
    
    // 生成完成后更新标题和内容
    const finalTitle = `✨ AI自动生成：${fileMeta.value.name} 学习笔记`
    tempNote.title = finalTitle
    tempNote.content = fullContent
    
    console.log('🎉 AI笔记生成完成！')
    console.log(`⏱️  生成耗时: ${duration}秒`)
    console.log(`📊 最终内容长度: ${fullContent.length}字符`)
    console.log(`🔢 总接收块数: ${chunkCount}`)
    
    // 设置笔记类型
    tempNote.type = 'AI_GENERATED'
    
    // 强制触发Vue响应式更新
    aiNotes.value = [...aiNotes.value]
    
    console.log('📋 笔记已添加到列表，当前笔记数量:', aiNotes.value.length)
    
    // 验证笔记内容
    const addedNote = aiNotes.value.find(note => note.id === tempNote.id)
    if (addedNote) {
      console.log('✅ 笔记验证成功:', {
        id: addedNote.id,
        title: addedNote.title,
        contentLength: addedNote.content.length,
        timestamp: addedNote.timestamp,
        type: addedNote.type
      })
    } else {
      console.error('❌ 笔记验证失败：在列表中找不到生成的笔记')
    }
    
    // 额外的UI刷新确保显示
    setTimeout(() => {
      aiNotes.value = [...aiNotes.value]
      console.log('🔄 执行延迟UI刷新')
    }, 100)
    
    
  } catch (error) {
    console.error('❌ AI生成笔记失败:', error)
    
    let errorMessage = error.message
    let suggestions = ''
    
    // 根据错误类型提供具体建议
    if (error.name === 'AbortError') {
      errorMessage = 'AI笔记生成超时（超过60秒）'
      suggestions = '建议：\n1. 文档内容可能过长，请尝试较短的文档\n2. 网络连接可能不稳定，请检查网络\n3. 服务器可能繁忙，请稍后重试'
    } else if (error.message.includes('401')) {
      errorMessage = '身份验证失败'
      suggestions = '建议：\n1. 请重新登录\n2. 检查登录状态是否有效'
    } else if (error.message.includes('500')) {
      errorMessage = 'AI服务暂时不可用'
      suggestions = '建议：\n1. 服务器正在处理中，请稍后重试\n2. 如果持续出现问题，请联系管理员'
    } else if (error.message.includes('timeout')) {
      errorMessage = '请求超时'
      suggestions = '建议：\n1. 检查网络连接\n2. 文档内容过长，请尝试较短的文档\n3. 稍后重试'
    }
    
    // 移除可能存在的临时笔记
    aiNotes.value = aiNotes.value.filter(note => !note.title.includes('AI正在生成'))
    
    // 添加错误提示笔记
    const errorNote = {
      id: Date.now(),
      title: '❌ AI生成笔记失败',
      content: `抱歉，AI生成笔记遇到问题：\n\n🔍 错误详情：${errorMessage}\n\n💡 ${suggestions}\n\n⏰ 发生时间：${new Date().toLocaleString()}\n\n🔄 您可以稍后重试或手动添加笔记。`,
      timestamp: new Date()
    }
    aiNotes.value.unshift(errorNote)
  }
}

// 工具方法
const formatTime = (timestamp) => {
  const now = new Date()
  const time = new Date(timestamp)
  const diff = now - time
  
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  
  return time.toLocaleDateString()
}

// 已移除 getNoteTypeIcon 和 getNoteTypeName 方法，因为不再使用 type 字段

// 思维导图相关方法

const generateMindMap = async (retryCount = 0) => {
  if (mindMapLoading.value) return
  
  try {
    mindMapLoading.value = true
    mindMapError.value = ''
    console.log(`开始生成思维导图 (尝试 ${retryCount + 1}/3)`)
    
    // 设置加载状态提示
    if (retryCount === 0) {
      console.log('🎨 正在分析文档内容并生成思维导图...')
    } else {
      console.log(`🔄 第${retryCount + 1}次尝试生成思维导图 (使用${mapType}模式)...`)
    }
    
    // 获取文档内容
    const documentContent = await extractDocumentText()
    
    // 根据重试次数调整请求参数
    const mapType = retryCount === 0 ? 'hierarchical' : (retryCount === 1 ? 'concept' : 'simple')
    
    const requestParams = {
      fileName: fileMeta.value.name,
      documentContent: documentContent,
      mapType: mapType
    }
    
    // 增加超时时间，避免过早超时
    const timeoutMs = 30000 + (retryCount * 10000) // 30s, 40s, 50s
    
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), timeoutMs)
    
    try {
    const response = await fetch('/api/mind-map/generate', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      },
        body: JSON.stringify(requestParams),
        signal: controller.signal
      })
      
      clearTimeout(timeoutId)
    
    if (!response.ok) {
        throw new Error(`API请求失败: ${response.status} ${response.statusText}`)
    }
    
    const result = await response.json()
      console.log('后端返回结果:', result)
      console.log('result.success:', result.success)
      console.log('result.code:', result.code)
      console.log('result.data:', result.data)
      console.log('result.message:', result.message)
      
      // 检查是否明确失败 - 支持多种错误格式
      if (result.success === false || result.code === 500 || (result.code && result.code !== 200)) {
        const errorMessage = result.message || '生成思维导图失败'
        console.error('❌ 后端返回错误:', errorMessage)
        
        // 减少不必要的重试，只有在特定错误时才重试
        if (retryCount < 1 && (errorMessage.includes('null') || errorMessage.includes('服务') || errorMessage.includes('超时'))) {
          console.log(`⏳ 即将重试生成思维导图 (${2000 * (retryCount + 1)}ms后)...`)
          await new Promise(resolve => setTimeout(resolve, 2000 * (retryCount + 1))) // 递增延迟
          return await generateMindMap(retryCount + 1)
        }
        
        throw new Error(errorMessage)
      }
      
      // 检查数据是否为空
      if (!result.data && !result.name && !result.children) {
        console.error('❌ 后端返回的数据为空')
        
        // 如果数据为空且还有重试机会，进行一次重试
        if (retryCount < 1) {
          console.log(`⏳ 数据为空，即将重试生成思维导图 (${1500}ms后)...`)
          await new Promise(resolve => setTimeout(resolve, 1500))
          return await generateMindMap(retryCount + 1)
        }
        
        throw new Error('后端返回的思维导图数据为空，请重试或检查文档内容')
      }
      
      // 将数据解析逻辑移到try块内部
      let mindMapResult = null
      
      // 尝试多种数据格式解析
      console.log('🔍 开始解析思维导图数据...')
      console.log('检查条件:', {
        hasData: !!result.data,
        hasMindMapData: !!(result.data && result.data.mindMapData),
        mindMapDataType: result.data?.mindMapData ? typeof result.data.mindMapData : 'undefined'
      })
      
      if (result.data && result.data.mindMapData) {
        // 格式1: { success: true, data: { mindMapData: {...} } }
        console.log('✅ 匹配格式1: result.data.mindMapData')
        console.log('mindMapData类型:', typeof result.data.mindMapData)
        console.log('mindMapData内容预览:', result.data.mindMapData.substring(0, 100) + '...')
        
        try {
          let cleanedData = result.data.mindMapData
          
          // 如果是字符串，清理markdown代码块标记
          if (typeof cleanedData === 'string') {
            // 清理markdown代码块标记 ```json 和 ```
            cleanedData = cleanedData
              .replace(/^```json\s*/, '')  // 移除开头的 ```json
              .replace(/\s*```\s*$/, '')   // 移除结尾的 ```
              .trim()
            
            console.log('🧹 清理后的数据预览:', cleanedData.substring(0, 100) + '...')
          }
          
          mindMapResult = typeof cleanedData === 'string' 
            ? JSON.parse(cleanedData) 
            : cleanedData
          console.log('✅ 成功解析格式1数据:', mindMapResult)
        } catch (parseError) {
          console.error('❌ 解析格式1数据失败:', parseError)
          console.error('原始数据:', result.data.mindMapData)
        }
      } else if (result.data && (result.data.name || result.data.children)) {
        // 格式2: { success: true, data: { name: "...", children: [...] } }
        console.log('使用格式2: result.data 直接就是思维导图数据')
        mindMapResult = result.data
      } else if (result.data && typeof result.data === 'string') {
        // 格式3: 字符串格式的JSON数据
        console.log('使用格式3: 解析字符串格式的JSON数据')
        try {
          // 清理可能的markdown代码块标记
          let cleanedData = result.data
            .replace(/^```json\s*/, '')  // 移除开头的 ```json
            .replace(/\s*```\s*$/, '')   // 移除结尾的 ```
            .trim()
          
          mindMapResult = JSON.parse(cleanedData)
          console.log('✅ 成功解析字符串格式思维导图:', mindMapResult)
        } catch (parseError) {
          console.warn('⚠️ 解析字符串格式思维导图失败:', parseError)
          console.warn('原始数据:', result.data)
        }
      } else if (result.name || result.children) {
        // 格式4: 直接返回思维导图数据 { name: "...", children: [...] }
        console.log('使用格式4: result 直接就是思维导图数据')
        mindMapResult = result
      } else if (result.message === '操作成功' && result.data) {
        // 格式5: 特殊的"操作成功"格式
        console.log('使用格式5: 操作成功格式')
        if (typeof result.data === 'string') {
          // 清理可能的markdown代码块标记
          let cleanedData = result.data
            .replace(/^```json\s*/, '')  // 移除开头的 ```json
            .replace(/\s*```\s*$/, '')   // 移除结尾的 ```
            .trim()
          mindMapResult = JSON.parse(cleanedData)
        } else {
          mindMapResult = result.data
        }
      }
      
      console.log('🔍 最终数据验证:', {
        hasMindMapResult: !!mindMapResult,
        hasName: !!(mindMapResult && mindMapResult.name),
        hasChildren: !!(mindMapResult && mindMapResult.children),
        childrenLength: mindMapResult?.children?.length || 0
      })
      
      if (mindMapResult && (mindMapResult.name || mindMapResult.children)) {
        mindMapData.value = mindMapResult
        console.log('✅ 思维导图生成成功!')
        console.log('📊 思维导图结构:', {
          name: mindMapResult.name,
          childrenCount: mindMapResult.children?.length || 0,
          firstChild: mindMapResult.children?.[0]?.name || '无'
        })
        
        // 重置视图状态
        collapsedNodes.value = []
        dragOffset.value = { x: 0, y: 0 }
        mindMapZoom.value = 1
        
        console.log('🎉 思维导图展示准备完成!')
      } else {
        console.error('❌ 无法解析思维导图数据，所有格式都失败')
        console.error('mindMapResult:', mindMapResult)
        console.error('完整返回数据:', JSON.stringify(result, null, 2))
        throw new Error('返回的数据格式不正确，无法生成思维导图')
      }
      
    } catch (fetchError) {
      clearTimeout(timeoutId)
      
      if (fetchError.name === 'AbortError') {
        throw new Error(`请求超时 (${timeoutMs / 1000}秒)，请检查网络连接`)
      }
      
      throw fetchError
    }
    
  } catch (error) {
    console.error(`生成思维导图失败 (尝试 ${retryCount + 1}/3):`, error)
    
    // 提供更友好的错误信息
    let friendlyMessage = ''
    if (error.message.includes('生成思维导图失败: null')) {
      friendlyMessage = `🤖 AI服务暂时不可用 (已重试${retryCount + 1}次)，已为您加载智能演示内容`
    } else if (error.message.includes('请求超时')) {
      friendlyMessage = `⏰ 生成时间较长 (已等待${Math.round((30 + retryCount * 10))}秒)，已为您加载智能演示内容`
    } else if (error.message.includes('API请求失败')) {
      friendlyMessage = `🌐 网络连接异常 (已重试${retryCount + 1}次)，请检查网络后重试`
    } else if (error.message.includes('数据为空')) {
      friendlyMessage = `📄 文档内容较短，无法生成思维导图 (已重试${retryCount + 1}次)，请尝试更丰富的文档`
    } else {
      friendlyMessage = `❌ ${error.message || '生成思维导图时发生未知错误'}`
    }
    
    mindMapError.value = friendlyMessage
    
    // 自动加载智能默认演示数据
    console.log('使用智能默认思维导图数据')
    const documentContent = await extractDocumentText().catch(() => '文档内容')
    
    mindMapData.value = await generateSmartDefaultMindMap(documentContent)
    
    // 重置视图状态
    collapsedNodes.value = []
    dragOffset.value = { x: 0, y: 0 }
    mindMapZoom.value = 1
    
    // 5秒后清除错误信息
    setTimeout(() => {
      mindMapError.value = ''
    }, 5000)
    
  } finally {
    mindMapLoading.value = false
  }
}

// 生成智能默认思维导图
const generateSmartDefaultMindMap = async (documentContent) => {
  const fileName = fileMeta.value?.name || '文档'
  const fileExtension = fileName.split('.').pop()?.toLowerCase()
  
  // 分析文档内容，生成更智能的结构
  const contentAnalysis = analyzeDocumentContent(documentContent, fileName)
  
  // 根据分析结果生成智能结构
  let smartStructure = {
    name: contentAnalysis.title,
    children: contentAnalysis.structure
  }
  
  console.log('✅ 生成智能默认思维导图:', smartStructure)
  return smartStructure
}

// 分析文档内容并生成相应结构
const analyzeDocumentContent = (content, fileName) => {
  const title = `${fileName.replace(/\.[^/.]+$/, "")} - 知识结构图`
  
  // 检测内容特征
  const isStudyMaterial = /复习|提纲|知识点|章节|习题|作业/.test(content + fileName)
  const isTechnical = /技术|原理|系统|方法|算法|架构/.test(content + fileName)
  const isEducational = /教育|学习|课程|培训|教学/.test(content + fileName)
  
  let structure = []
  
  if (isStudyMaterial) {
    // 学习资料类型
    structure = [
      {
        name: '核心知识点',
        children: [
          { name: '基础概念' },
          { name: '重要原理' },
          { name: '关键技术' },
          { name: '实际应用' }
        ]
      },
      {
        name: '章节内容',
        children: [
          { name: '第一部分' },
          { name: '第二部分' },
          { name: '第三部分' },
          { name: '总结部分' }
        ]
      },
      {
        name: '学习要点',
        children: [
          { name: '重点内容' },
          { name: '难点解析' },
          { name: '易错点' },
          { name: '考试要点' }
        ]
      },
      {
        name: '实践环节',
        children: [
          { name: '课后习题' },
          { name: '实验作业' },
          { name: '项目练习' },
          { name: '扩展阅读' }
        ]
      }
    ]
  } else if (isTechnical) {
    // 技术文档类型
    structure = [
      {
        name: '技术概述',
        children: [
          { name: '核心原理' },
          { name: '技术特点' },
          { name: '应用领域' }
        ]
      },
      {
        name: '详细说明',
        children: [
          { name: '实现方式' },
          { name: '关键技术' },
          { name: '性能指标' }
        ]
      },
      {
        name: '实际应用',
        children: [
          { name: '使用场景' },
          { name: '最佳实践' },
          { name: '注意事项' }
        ]
      }
    ]
  } else {
    // 通用文档类型
    structure = [
      {
        name: '主要内容',
        children: [
          { name: '核心主题' },
          { name: '重要观点' },
          { name: '关键信息' },
          { name: '详细说明' }
        ]
      },
      {
        name: '内容结构',
        children: [
          { name: '前言部分' },
          { name: '主体内容' },
          { name: '结论总结' },
          { name: '附加信息' }
        ]
      },
      {
        name: '价值分析',
        children: [
          { name: '实用价值' },
          { name: '参考意义' },
          { name: '学习价值' },
          { name: '应用前景' }
        ]
      }
    ]
  }
  
  return { title, structure }
}

// 原有的按文件类型生成的逻辑（保留作为备用）
const generateDefaultByFileType = (fileExtension, fileName, documentContent) => {
  let smartStructure = {
    name: `${fileName} - 智能思维导图`,
    children: []
  }
  
  if (fileExtension === 'pdf' || documentContent.length > 5000) {
    // 长文档结构
    smartStructure.children = [
      {
        name: '文档概要',
        children: [
          { name: '主要主题' },
          { name: '核心观点' },
          { name: '关键信息' }
        ]
      },
      {
        name: '内容结构',
        children: [
          { name: '章节划分' },
          { name: '逻辑脉络' },
          { name: '重点段落' }
        ]
      },
      {
        name: '知识要点',
        children: [
          { name: '核心概念' },
          { name: '重要定义' },
          { name: '实践应用' }
        ]
      },
      {
        name: '学习建议',
        children: [
          { name: '重点关注' },
          { name: '难点突破' },
          { name: '扩展阅读' }
        ]
      }
    ]
  } else if (fileExtension === 'docx' || fileExtension === 'doc') {
    // Word文档结构
    smartStructure.children = [
      {
        name: '文档要点',
        children: [
          { name: '主要内容' },
          { name: '关键信息' },
          { name: '总结归纳' }
        ]
      },
      {
        name: '结构分析',
        children: [
          { name: '内容层次' },
          { name: '段落要点' },
          { name: '逻辑关系' }
        ]
      },
      {
        name: '实用价值',
        children: [
          { name: '应用场景' },
          { name: '参考价值' },
          { name: '学习重点' }
        ]
      }
    ]
  } else {
    // 通用文档结构
    smartStructure.children = [
      {
        name: '主要内容',
        children: [
          { name: '核心主题' },
          { name: '重要观点' },
          { name: '关键信息' }
        ]
      },
      {
        name: '内容分析',
        children: [
          { name: '结构框架' },
          { name: '逻辑关系' },
          { name: '要点总结' }
        ]
      },
      {
        name: '学习指导',
        children: [
          { name: '重点内容' },
          { name: '理解要点' },
          { name: '应用建议' }
        ]
      }
    ]
  }
  
  return smartStructure
}

// 简单的关键词提取
const extractKeywords = (text) => {
  if (!text || typeof text !== 'string') return []
  
  // 移除标点符号和特殊字符，分割成词汇
  const words = text
    .replace(/[^\u4e00-\u9fa5\w\s]/g, '') // 保留中文、字母、数字和空格
    .split(/\s+/)
    .filter(word => word.length > 1) // 过滤单字符
    .filter(word => !/^\d+$/.test(word)) // 过滤纯数字
  
  // 统计词频
  const wordCount = {}
  words.forEach(word => {
    word = word.toLowerCase()
    wordCount[word] = (wordCount[word] || 0) + 1
  })
  
  // 排序并返回高频词汇
  return Object.entries(wordCount)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10)
    .map(([word]) => word)
    .filter(word => word.length > 1)
}

// 思维导图缩放控制
const zoomIn = () => {
  if (mindMapZoom.value < 2) {
    mindMapZoom.value = Math.min(2, mindMapZoom.value + 0.1)
  }
}

const zoomOut = () => {
  if (mindMapZoom.value > 0.5) {
    mindMapZoom.value = Math.max(0.5, mindMapZoom.value - 0.1)
  }
}

const resetZoom = () => {
  mindMapZoom.value = 1
  dragOffset.value = { x: 0, y: 0 }
}

// 滚轮缩放
const handleWheelZoom = (event) => {
  event.preventDefault()
  if (event.ctrlKey || event.metaKey) {
    if (event.deltaY < 0) {
      zoomIn()
    } else {
      zoomOut()
    }
  }
}

// 优化的滚轮缩放处理器（减少性能警告）
const handleWheelZoomOptimized = (event) => {
  // 只在按住Ctrl/Meta键时处理缩放并阻止默认行为
  if (event.ctrlKey || event.metaKey) {
    // 只有在需要缩放时才阻止默认滚动行为
    event.preventDefault()
    if (event.deltaY < 0) {
      zoomIn()
    } else {
      zoomOut()
    }
  }
  // 如果没有按修饰键，允许正常滚动（不调用preventDefault）
}

// 拖拽功能
const startDrag = (event) => {
  if (event.button === 0) { // 左键
    isDragging.value = true
    dragStart.value = { x: event.clientX, y: event.clientY }
  }
}

const handleDrag = (event) => {
  if (isDragging.value) {
    const deltaX = event.clientX - dragStart.value.x
    const deltaY = event.clientY - dragStart.value.y
    dragOffset.value = {
      x: dragOffset.value.x + deltaX / mindMapZoom.value,
      y: dragOffset.value.y + deltaY / mindMapZoom.value
    }
    dragStart.value = { x: event.clientX, y: event.clientY }
  }
}

const endDrag = () => {
  isDragging.value = false
}

// 控制面板显示/隐藏
const toggleControls = () => {
  showControls.value = !showControls.value
  if (!showControls.value) {
    showExportMenu.value = false // 关闭控制面板时，同时关闭导出菜单
  }
}

// 导出菜单显示/隐藏
const toggleExportMenu = () => {
  showExportMenu.value = !showExportMenu.value
}

// 移除视图模式切换功能 - 简化界面，只保持树形视图

// 节点展开/折叠
const toggleNode = (nodeId) => {
  const index = collapsedNodes.value.indexOf(nodeId)
  if (index > -1) {
    collapsedNodes.value.splice(index, 1)
  } else {
    collapsedNodes.value.push(nodeId)
  }
}

const expandAll = () => {
  collapsedNodes.value = []
}

const collapseAll = () => {
  const allNodes = ['root']
  if (mindMapData.value.children) {
    mindMapData.value.children.forEach((_, index) => {
      allNodes.push(`branch-${index}`)
    })
  }
  collapsedNodes.value = allNodes
}

// 节点详情显示
const toggleNodeDetails = (nodeId) => {
  if (selectedNodeDetails.value?.id === nodeId) {
    selectedNodeDetails.value = null
    return
  }
  
  let nodeData = null
  let title = ''
  let content = ''
  
  if (nodeId === 'root') {
    nodeData = mindMapData.value
    title = nodeData.name || '根节点'
    content = `主题：${title}\n包含 ${nodeData.children?.length || 0} 个主要分支`
  } else if (nodeId.startsWith('branch-')) {
    const index = parseInt(nodeId.split('-')[1])
    nodeData = mindMapData.value.children?.[index]
    title = nodeData?.name || '分支节点'
    content = `分支：${title}\n包含 ${nodeData?.children?.length || 0} 个子项目`
  } else if (nodeId.startsWith('leaf-')) {
    const [, branchIndex, leafIndex] = nodeId.split('-')
    nodeData = mindMapData.value.children?.[parseInt(branchIndex)]?.children?.[parseInt(leafIndex)]
    title = nodeData?.name || '叶节点'
    content = `详细内容：${title}\n这是一个具体的知识点或要素。`
  }
  
  selectedNodeDetails.value = { id: nodeId, title, content }
}

// 导出思维导图 - 新的统一导出函数
const exportAs = async (format) => {
  try {
    if (!mindMapData.value || !mindMapData.value.name) {
      alert('没有可导出的思维导图数据')
      return
    }
    
    showExportMenu.value = false // 关闭导出菜单
    
    switch (format) {
      case 'json':
        await exportAsJSON()
        break
      case 'markdown':
        await exportAsMarkdown()
        break
      case 'txt':
        await exportAsTXT()
        break
      case 'png':
        await exportAsPNG()
        break
      case 'jpeg':
        await exportAsJPEG()
        break
      case 'svg':
        await exportAsSVG()
        break
      case 'xmind':
        await exportAsXMind()
        break
      case 'opml':
        await exportAsOPML()
        break
      default:
        alert('暂不支持该格式导出')
    }
    
  } catch (error) {
    console.error(`${format.toUpperCase()}导出失败:`, error)
    alert(`${format.toUpperCase()}导出失败：${error.message}`)
  }
}

// JSON导出
const exportAsJSON = () => {
  try {
    const exportData = {
      title: mindMapData.value.name || '思维导图',
      source: fileMeta.value?.name || '未知文档',
      exportTime: new Date().toISOString(),
      data: mindMapData.value
    }
    
    const jsonData = JSON.stringify(exportData, null, 2)
    const blob = new Blob([jsonData], { type: 'application/json;charset=utf-8' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${fileMeta.value?.name || '思维导图'}-思维导图.json`
    a.style.display = 'none'
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
    
    alert('JSON 文件已成功导出！')
  } catch (error) {
    console.error('JSON导出失败:', error)
    alert('JSON导出失败：' + error.message)
  }
}

// Markdown导出
const exportAsMarkdown = () => {
  try {
    let markdown = `# ${mindMapData.value.name || '思维导图'}\n\n`
    markdown += `> **文档来源**：${fileMeta.value?.name || '未知文档'}  \n`
    markdown += `> **导出时间**：${new Date().toLocaleString()}  \n\n`
    
    if (mindMapData.value.children && mindMapData.value.children.length > 0) {
      mindMapData.value.children.forEach((branch, branchIndex) => {
        markdown += `## ${branchIndex + 1}. ${branch.name}\n\n`
        if (branch.children && branch.children.length > 0) {
          branch.children.forEach((leaf) => {
            markdown += `- ${leaf.name}\n`
          })
          markdown += '\n'
    } else {
          markdown += '*该分支暂无详细内容*\n\n'
        }
      })
    } else {
      markdown += '> 暂无思维导图内容\n\n'
    }
    
    markdown += `---\n\n*此思维导图由 AI 阅读器自动生成*\n`
    
    const blob = new Blob([markdown], { type: 'text/markdown;charset=utf-8' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${fileMeta.value?.name || '思维导图'}-思维导图.md`
    a.style.display = 'none'
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
    
    alert('Markdown 文件已成功导出！')
  } catch (error) {
    console.error('Markdown导出失败:', error)
    alert('Markdown导出失败：' + error.message)
  }
}

// TXT导出
const exportAsTXT = async () => {
  try {
    let content = `${mindMapData.value.name || '思维导图'}\n`
    content += '='.repeat(content.length - 1) + '\n\n'
    content += `文档来源：${fileMeta.value?.name || '未知文档'}\n`
    content += `导出时间：${new Date().toLocaleString()}\n\n`
    
    if (mindMapData.value.children && mindMapData.value.children.length > 0) {
      mindMapData.value.children.forEach((branch, index) => {
        content += `${index + 1}. ${branch.name}\n`
        if (branch.children && branch.children.length > 0) {
          branch.children.forEach((leaf) => {
            content += `   • ${leaf.name}\n`
          })
        } else {
          content += '   （暂无详细内容）\n'
        }
        content += '\n'
      })
    } else {
      content += '暂无思维导图内容\n'
    }
    
    content += '\n' + '-'.repeat(50) + '\n'
    content += '此思维导图由 AI 阅读器自动生成\n'
    
    downloadFile(content, `${fileMeta.value?.name || '思维导图'}-思维导图.txt`, 'text/plain;charset=utf-8')
    alert('TXT 文件已成功导出！')
  } catch (error) {
    throw new Error('TXT导出失败：' + error.message)
  }
}

// PNG导出 - 高质量版本
const exportAsPNG = async () => {
  try {
    // 选择合适的容器元素进行捕获
    const element = document.querySelector('.mind-map-content')
    if (!element) {
      throw new Error('找不到思维导图容器元素')
    }
    
    // 临时移除overflow限制并重置transform
    const originalStyles = await prepareForFullCapture()
    
    try {
      // 等待DOM更新
      await new Promise(resolve => setTimeout(resolve, 200))
      
      const canvas = await captureElementWithStyles(element, {
        backgroundColor: '#f8fafc',
        scale: 2,
        useCORS: true,
        allowTaint: true,
        logging: true,
        width: element.scrollWidth || element.offsetWidth,
        height: element.scrollHeight || element.offsetHeight
      })
      
      const dataURL = canvas.toDataURL('image/png', 1.0)
      downloadFile(dataURL, `${fileMeta.value?.name || '思维导图'}-思维导图.png`, null, true)
      alert('PNG 图片已成功导出！')
      
    } catch (html2canvasError) {
      console.warn('html2canvas失败，使用增强Canvas方案:', html2canvasError)
      // 备用方案：使用增强的Canvas绘制
      const canvas = await createStyledMindMapCanvas(element, 'png')
      const dataURL = canvas.toDataURL('image/png', 1.0)
      downloadFile(dataURL, `${fileMeta.value?.name || '思维导图'}-思维导图.png`, null, true)
      alert('PNG 图片已成功导出（使用增强绘制）！')
    } finally {
      // 恢复原始样式
      restoreOriginalStyles(originalStyles)
    }
    
  } catch (error) {
    console.error('PNG导出失败:', error)
    // 提供手动截图建议
    if (confirm('自动导出失败，是否查看手动截图指南？')) {
      showScreenshotGuide()
    }
  }
}

// JPEG导出 - 高质量版本
const exportAsJPEG = async () => {
  try {
    // 选择合适的容器元素进行捕获
    const element = document.querySelector('.mind-map-content')
    if (!element) {
      throw new Error('找不到思维导图容器元素')
    }
    
    // 临时移除overflow限制并重置transform
    const originalStyles = await prepareForFullCapture()
    
    try {
      // 等待DOM更新
      await new Promise(resolve => setTimeout(resolve, 200))
      
      const canvas = await captureElementWithStyles(element, {
        backgroundColor: '#f8fafc',
        scale: 2,
        useCORS: true,
        allowTaint: true,
        logging: true,
        width: element.scrollWidth || element.offsetWidth,
        height: element.scrollHeight || element.offsetHeight
      })
      
      const dataURL = canvas.toDataURL('image/jpeg', 0.9)
      downloadFile(dataURL, `${fileMeta.value?.name || '思维导图'}-思维导图.jpg`, null, true)
      alert('JPEG 图片已成功导出！')
      
    } catch (html2canvasError) {
      console.warn('html2canvas失败，使用增强Canvas方案:', html2canvasError)
      const canvas = await createStyledMindMapCanvas(element, 'jpeg')
      const dataURL = canvas.toDataURL('image/jpeg', 0.9)
      downloadFile(dataURL, `${fileMeta.value?.name || '思维导图'}-思维导图.jpg`, null, true)
      alert('JPEG 图片已成功导出（使用增强绘制）！')
    } finally {
      // 恢复原始样式
      restoreOriginalStyles(originalStyles)
    }
    
  } catch (error) {
    console.error('JPEG导出失败:', error)
    if (confirm('自动导出失败，是否查看手动截图指南？')) {
      showScreenshotGuide()
    }
  }
}

// SVG导出 - 高质量版本
const exportAsSVG = async () => {
  try {
    const treeElement = document.querySelector('.mind-map-content')
    if (!treeElement) {
      throw new Error('找不到思维导图容器元素')
    }
    
    // 创建高质量SVG，包含样式和图标
    const svgContent = await createStyledSVGFromMindMap(mindMapData.value, treeElement)
    
    downloadFile(svgContent, `${fileMeta.value?.name || '思维导图'}-思维导图.svg`, 'image/svg+xml;charset=utf-8')
    alert('SVG 矢量图已成功导出！')
  } catch (error) {
    throw new Error('SVG导出失败：' + error.message)
  }
}

// XMind格式导出
const exportAsXMind = async () => {
  try {
    // XMind格式是基于XML的，这里生成一个简化版本
    const xmindData = {
      topic: mindMapData.value.name || '思维导图',
      subtopics: mindMapData.value.children?.map(branch => ({
        title: branch.name,
        subtopics: branch.children?.map(leaf => ({
          title: leaf.name
        })) || []
      })) || []
    }
    
    const xmlContent = generateXMindXML(xmindData)
    downloadFile(xmlContent, `${fileMeta.value?.name || '思维导图'}-思维导图.xmind`, 'application/xml;charset=utf-8')
    alert('XMind 文件已成功导出！\n注意：这是简化版本的XMind格式')
  } catch (error) {
    throw new Error('XMind导出失败：' + error.message)
  }
}

// OPML导出
const exportAsOPML = async () => {
  try {
    const opmlContent = generateOPMLFromMindMap(mindMapData.value)
    downloadFile(opmlContent, `${fileMeta.value?.name || '思维导图'}-思维导图.opml`, 'text/x-opml;charset=utf-8')
    alert('OPML 大纲文件已成功导出！')
  } catch (error) {
    throw new Error('OPML导出失败：' + error.message)
  }
}

// ========== 导出辅助函数 ==========

// 通用文件下载函数
const downloadFile = (content, filename, mimeType = 'text/plain;charset=utf-8', isDataURL = false) => {
  try {
    let url
    if (isDataURL) {
      // 如果是Data URL，直接使用
      url = content
    } else {
      // 创建Blob对象
      const blob = new Blob([content], { type: mimeType })
      url = URL.createObjectURL(blob)
    }
    
    const a = document.createElement('a')
    a.href = url
    a.download = filename
    a.style.display = 'none'
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    
    if (!isDataURL) {
      URL.revokeObjectURL(url)
    }
  } catch (error) {
    console.error('文件下载失败:', error)
    throw new Error('文件下载失败：' + error.message)
  }
}

// 高质量DOM截图 - 尝试使用html2canvas
const captureElementWithStyles = async (element, options = {}) => {
  return new Promise(async (resolve, reject) => {
    try {
      // 尝试动态导入html2canvas
      let html2canvas
      try {
        // 先尝试从CDN加载html2canvas
        if (!window.html2canvas) {
          await loadHtml2Canvas()
        }
        html2canvas = window.html2canvas
      } catch (importError) {
        console.warn('html2canvas不可用，使用内置方案')
        throw new Error('html2canvas不可用')
      }
      
      // 使用html2canvas截图
      const canvas = await html2canvas(element, {
        backgroundColor: options.backgroundColor || '#ffffff',
        scale: options.scale || 2,
        useCORS: options.useCORS || true,
        allowTaint: options.allowTaint || true,
        logging: options.logging || false,
        width: options.width || element.scrollWidth,
        height: options.height || element.scrollHeight,
        scrollX: 0,
        scrollY: 0,
        removeContainer: false,
        ignoreElements: (element) => {
          // 忽略滚动条和某些UI元素
          return element.classList.contains('floating-controls') || 
                 element.classList.contains('export-menu') ||
                 element.classList.contains('zoom-controls')
        },
        imageTimeout: 5000
      })
      
      resolve(canvas)
    } catch (error) {
      reject(error)
    }
  })
}

// 准备完整内容捕获 - 临时移除overflow限制并重置transform
const prepareForFullCapture = async () => {
  const originalStyles = new Map()
  
  // 需要临时修改的选择器和样式
  const elementsToModify = [
    { selector: '.reader-page', styles: { overflow: 'visible', height: 'auto' } },
    { selector: '.mind-map-container', styles: { overflow: 'visible', height: 'auto', position: 'static' } },
    { selector: '.mind-map-content', styles: { overflow: 'visible', height: 'auto', position: 'static' } },
    { selector: '.mind-map-viewport', styles: { overflow: 'visible', height: 'auto', position: 'static' } },
    { selector: '.mind-map-tree', styles: { 
      transform: 'none',
      transformOrigin: 'initial',
      position: 'static',
      overflow: 'visible',
      width: 'auto',
      height: 'auto'
    } },
    { selector: '.panel', styles: { overflow: 'visible', height: 'auto' } }
  ]
  
  elementsToModify.forEach(({ selector, styles }) => {
    const elements = document.querySelectorAll(selector)
    elements.forEach((element) => {
      // 保存原始样式
      const originalElementStyles = {}
      Object.keys(styles).forEach(property => {
        originalElementStyles[property] = element.style[property] || ''
      })
      originalStyles.set(element, originalElementStyles)
      
      // 应用新样式
      Object.assign(element.style, styles)
    })
  })
  
  // 特别处理：隐藏浮动控件
  const controlsToHide = [
    '.floating-controls',
    '.export-menu', 
    '.zoom-controls',
    '.mind-map-controls'
  ]
  
  controlsToHide.forEach(selector => {
    const elements = document.querySelectorAll(selector)
    elements.forEach(element => {
      const originalDisplay = element.style.display || getComputedStyle(element).display
      originalStyles.set(element, { display: originalDisplay })
      element.style.display = 'none'
    })
  })
  
  return originalStyles
}

// 恢复原始样式
const restoreOriginalStyles = (originalStyles) => {
  originalStyles.forEach((styles, element) => {
    Object.assign(element.style, styles)
  })
}

// 加载html2canvas库（从CDN）
const loadHtml2Canvas = () => {
  return new Promise((resolve, reject) => {
    if (window.html2canvas) {
      resolve(window.html2canvas)
      return
    }
    
    const script = document.createElement('script')
    script.src = 'https://cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js'
    script.onload = () => {
      if (window.html2canvas) {
        resolve(window.html2canvas)
      } else {
        reject(new Error('html2canvas加载失败'))
      }
    }
    script.onerror = () => reject(new Error('html2canvas脚本加载失败'))
    document.head.appendChild(script)
  })
}

// 创建高质量思维导图Canvas（备用方案）
const createStyledMindMapCanvas = async (element, format = 'png') => {
  return new Promise((resolve, reject) => {
    try {
      const rect = element.getBoundingClientRect()
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')
      
      // 高分辨率设置
      const scale = 3
      const padding = 60
      canvas.width = (rect.width + padding * 2) * scale
      canvas.height = (rect.height + padding * 2) * scale
      
      ctx.scale(scale, scale)
      
      // 背景设置
      ctx.fillStyle = format === 'jpeg' ? '#ffffff' : '#ffffff'
      ctx.fillRect(0, 0, canvas.width / scale, canvas.height / scale)
      
      // 绘制样式化的思维导图
      drawStyledMindMap(ctx, mindMapData.value, padding, format)
      
      resolve(canvas)
    } catch (error) {
      reject(error)
    }
  })
}

// 绘制样式化的思维导图
const drawStyledMindMap = (ctx, data, padding, format) => {
  const colors = {
    root: { bg: '#667eea', text: '#ffffff', border: '#5a67d8' },
    branch: { bg: '#3182ce', text: '#ffffff', border: '#2c5aa0' },
    leaf: { bg: '#38a169', text: '#ffffff', border: '#2f855a' }
  }
  
  let currentY = padding + 80
  
  // 绘制主标题
  if (data.name) {
    drawStyledNode(ctx, {
      text: data.name,
      x: padding + 50,
      y: padding + 40,
      width: 300,
      height: 60,
      colors: colors.root,
      icon: '🎯',
      fontSize: 24,
      fontWeight: 'bold'
    })
    
    // 绘制连接线到子节点
    if (data.children && data.children.length > 0) {
      ctx.strokeStyle = '#d1d5db'
      ctx.lineWidth = 2
      ctx.beginPath()
      ctx.moveTo(padding + 200, padding + 70)
      ctx.lineTo(padding + 200, currentY - 20)
      ctx.stroke()
    }
  }
  
  // 绘制分支节点
  if (data.children) {
    data.children.forEach((branch, index) => {
      const branchX = padding + 50
      const branchY = currentY
      
      // 绘制分支节点
      drawStyledNode(ctx, {
        text: `${index + 1}. ${branch.name}`,
        x: branchX,
        y: branchY,
        width: 280,
        height: 50,
        colors: colors.branch,
        icon: '',
        fontSize: 18,
        fontWeight: 'bold'
      })
      
      // 绘制叶子节点
      if (branch.children) {
        let leafY = branchY + 70
        branch.children.forEach((leaf, leafIndex) => {
          drawStyledNode(ctx, {
            text: `• ${leaf.name}`,
            x: branchX + 60,
            y: leafY,
            width: 250,
            height: 40,
            colors: colors.leaf,
            icon: '',
            fontSize: 14,
            fontWeight: 'normal'
          })
          
          // 连接线
          ctx.strokeStyle = '#d1d5db'
          ctx.lineWidth = 1
          ctx.beginPath()
          ctx.moveTo(branchX + 30, branchY + 50)
          ctx.lineTo(branchX + 30, leafY + 20)
          ctx.moveTo(branchX + 30, leafY + 20)
          ctx.lineTo(branchX + 60, leafY + 20)
          ctx.stroke()
          
          leafY += 50
        })
        currentY = leafY + 20
      } else {
        currentY = branchY + 80
      }
    })
  }
}

// 绘制样式化节点
const drawStyledNode = (ctx, options) => {
  const { text, x, y, width, height, colors, icon, fontSize, fontWeight } = options
  
  // 绘制节点背景（圆角矩形）
  drawRoundedRect(ctx, x, y, width, height, 12, colors.bg, colors.border)
  
  // 绘制图标
  if (icon) {
    ctx.font = `${fontSize * 1.2}px "Segoe UI Emoji", "Apple Color Emoji", sans-serif`
    ctx.fillStyle = colors.text
    ctx.textAlign = 'center'
    ctx.fillText(icon, x + 25, y + height / 2 + fontSize * 0.4)
  }
  
  // 绘制文本
  ctx.font = `${fontWeight} ${fontSize}px -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`
  ctx.fillStyle = colors.text
  ctx.textAlign = 'left'
  
  // 文本换行处理
  const maxWidth = width - 60
  const words = text.split(' ')
  let line = ''
  let textY = y + height / 2 - fontSize / 2
  
  if (words.length === 1 || text.length < 30) {
    // 短文本直接绘制
    ctx.fillText(text, x + 50, y + height / 2 + fontSize * 0.3)
  } else {
    // 长文本换行
    for (let i = 0; i < words.length; i++) {
      const testLine = line + words[i] + ' '
      const metrics = ctx.measureText(testLine)
      const testWidth = metrics.width
      
      if (testWidth > maxWidth && i > 0) {
        ctx.fillText(line, x + 50, textY)
        line = words[i] + ' '
        textY += fontSize + 2
      } else {
        line = testLine
      }
    }
    ctx.fillText(line, x + 50, textY)
  }
}

// 绘制圆角矩形
const drawRoundedRect = (ctx, x, y, width, height, radius, fillColor, strokeColor) => {
  ctx.beginPath()
  ctx.moveTo(x + radius, y)
  ctx.lineTo(x + width - radius, y)
  ctx.quadraticCurveTo(x + width, y, x + width, y + radius)
  ctx.lineTo(x + width, y + height - radius)
  ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
  ctx.lineTo(x + radius, y + height)
  ctx.quadraticCurveTo(x, y + height, x, y + height - radius)
  ctx.lineTo(x, y + radius)
  ctx.quadraticCurveTo(x, y, x + radius, y)
  ctx.closePath()
  
  // 填充
  ctx.fillStyle = fillColor
  ctx.fill()
  
  // 描边
  if (strokeColor) {
    ctx.strokeStyle = strokeColor
    ctx.lineWidth = 2
    ctx.stroke()
  }
}

// 创建高质量样式化SVG
const createStyledSVGFromMindMap = async (data, element) => {
  const rect = element.getBoundingClientRect()
  const padding = 40
  const width = Math.max(800, rect.width + padding * 2)
  const height = Math.max(600, rect.height + padding * 2)
  
  let svgContent = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <style>
      .root-node { font: bold 24px -apple-system, BlinkMacSystemFont, sans-serif; fill: white; }
      .branch-node { font: bold 18px -apple-system, BlinkMacSystemFont, sans-serif; fill: white; }
      .leaf-node { font: 14px -apple-system, BlinkMacSystemFont, sans-serif; fill: white; }
      .icon { font: 20px "Segoe UI Emoji", "Apple Color Emoji", sans-serif; }
      .connection { stroke: #d1d5db; stroke-width: 2; fill: none; }
      .connection-light { stroke: #e5e7eb; stroke-width: 1; fill: none; }
    </style>
    <!-- 渐变定义 -->
    <defs>
      <linearGradient id="rootGradient" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
        <stop offset="100%" style="stop-color:#5a67d8;stop-opacity:1" />
      </linearGradient>
      <linearGradient id="branchGradient" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" style="stop-color:#3182ce;stop-opacity:1" />
        <stop offset="100%" style="stop-color:#2c5aa0;stop-opacity:1" />
      </linearGradient>
      <linearGradient id="leafGradient" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" style="stop-color:#38a169;stop-opacity:1" />
        <stop offset="100%" style="stop-color:#2f855a;stop-opacity:1" />
      </linearGradient>
      <!-- 阴影滤镜 -->
      <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
        <feDropShadow dx="2" dy="4" stdDeviation="3" flood-color="#000000" flood-opacity="0.1"/>
      </filter>
    </defs>
  </defs>
  
  <!-- 背景 -->
  <rect width="${width}" height="${height}" fill="#ffffff"/>
  
  <!-- 装饰性背景图案 -->
  <defs>
    <pattern id="grid" width="20" height="20" patternUnits="userSpaceOnUse">
      <path d="M 20 0 L 0 0 0 20" fill="none" stroke="#f8fafc" stroke-width="1"/>
    </pattern>
  </defs>
  <rect width="${width}" height="${height}" fill="url(#grid)"/>`
  
  let currentY = padding + 80
  
  // 绘制主标题节点
  if (data.name) {
    svgContent += `\n  <!-- 主标题节点 -->
  <rect x="${padding + 50}" y="${padding + 40}" width="300" height="60" rx="12" ry="12" 
        fill="url(#rootGradient)" stroke="#5a67d8" stroke-width="2" filter="url(#shadow)"/>
  <text x="${padding + 70}" y="${padding + 55}" class="icon">🎯</text>
  <text x="${padding + 100}" y="${padding + 75}" class="root-node">${escapeXML(data.name)}</text>`
    
    // 主连接线
    if (data.children && data.children.length > 0) {
      svgContent += `\n  <line x1="${padding + 200}" y1="${padding + 100}" x2="${padding + 200}" y2="${currentY - 20}" class="connection"/>`
    }
  }
  
  // 绘制分支和叶子节点
  if (data.children) {
    data.children.forEach((branch, index) => {
      const branchX = padding + 50
      const branchY = currentY
      
      // 绘制分支节点
      svgContent += `\n  <!-- 分支节点 ${index + 1} -->
  <rect x="${branchX}" y="${branchY}" width="280" height="50" rx="10" ry="10" 
        fill="url(#branchGradient)" stroke="#2c5aa0" stroke-width="2" filter="url(#shadow)"/>
  <text x="${branchX + 20}" y="${branchY + 32}" class="branch-node">${escapeXML(`${index + 1}. ${branch.name}`)}</text>`
      
      // 绘制叶子节点
      if (branch.children) {
        let leafY = branchY + 70
        branch.children.forEach((leaf, leafIndex) => {
          svgContent += `\n  <!-- 叶子节点 ${index + 1}-${leafIndex + 1} -->
  <rect x="${branchX + 60}" y="${leafY}" width="250" height="40" rx="8" ry="8" 
        fill="url(#leafGradient)" stroke="#2f855a" stroke-width="1" filter="url(#shadow)"/>
  <text x="${branchX + 75}" y="${leafY + 18}" class="icon">📋</text>
  <text x="${branchX + 105}" y="${leafY + 26}" class="leaf-node">${escapeXML(`• ${leaf.name}`)}</text>
  
  <!-- 连接线 -->
  <line x1="${branchX + 30}" y1="${branchY + 50}" x2="${branchX + 30}" y2="${leafY + 20}" class="connection-light"/>
  <line x1="${branchX + 30}" y1="${leafY + 20}" x2="${branchX + 60}" y2="${leafY + 20}" class="connection-light"/>`
          
          leafY += 50
        })
        currentY = leafY + 20
      } else {
        currentY = branchY + 80
      }
    })
  }
  
  // 添加水印
  svgContent += `\n  <!-- 水印 -->
  <text x="${width - 200}" y="${height - 20}" style="font: 12px sans-serif; fill: #9ca3af; opacity: 0.6;">
    由 AI 阅读器生成 - ${new Date().toLocaleDateString()}
  </text>`
  
  svgContent += '\n</svg>'
  return svgContent
}

// 显示截图指南
const showScreenshotGuide = () => {
  const guide = `📸 手动截图指南：

🖥️ Windows:
• Win + Shift + S：截图工具
• Alt + PrtSc：截取当前窗口

🍎 macOS:
• Cmd + Shift + 4：选择区域截图
• Cmd + Shift + 3：全屏截图

🌐 浏览器:
• 右键点击思维导图 → "另存为图片"
• 使用浏览器开发者工具截图功能

💡 提示：
1. 先调整思维导图到合适的缩放比例
2. 确保完整显示要截图的内容
3. 选择高分辨率进行截图以保证清晰度`

  alert(guide)
}

// 生成XMind XML内容
const generateXMindXML = (data) => {
  let xml = `<?xml version="1.0" encoding="UTF-8"?>
<map xmlns="urn:xmind:xmap:xmlns:content:2.0" xmlns:fo="http://www.w3.org/1999/XSL/Format">
  <sheet>
    <topic id="root">
      <title>${escapeXML(data.topic)}</title>
      <children>`
  
  if (data.subtopics) {
    data.subtopics.forEach((subtopic, index) => {
      xml += `\n        <topics type="attached">
          <topic id="branch_${index}">
            <title>${escapeXML(subtopic.title)}</title>`
      
      if (subtopic.subtopics && subtopic.subtopics.length > 0) {
        xml += '\n            <children>\n              <topics type="attached">'
        subtopic.subtopics.forEach((leaf, leafIndex) => {
          xml += `\n                <topic id="leaf_${index}_${leafIndex}">
                  <title>${escapeXML(leaf.title)}</title>
                </topic>`
        })
        xml += '\n              </topics>\n            </children>'
      }
      
      xml += '\n          </topic>\n        </topics>'
    })
  }
  
  xml += `
      </children>
    </topic>
  </sheet>
</map>`
  
  return xml
}

// 生成OPML内容
const generateOPMLFromMindMap = (data) => {
  let opml = `<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head>
    <title>${escapeXML(data.name || '思维导图')}</title>
    <dateCreated>${new Date().toUTCString()}</dateCreated>
    <dateModified>${new Date().toUTCString()}</dateModified>
    <ownerName>AI阅读器</ownerName>
    <docs>http://dev.opml.org/spec2.html</docs>
  </head>
  <body>`
  
  if (data.children) {
    data.children.forEach(branch => {
      opml += `\n    <outline text="${escapeXML(branch.name)}">`
      
      if (branch.children) {
        branch.children.forEach(leaf => {
          opml += `\n      <outline text="${escapeXML(leaf.name)}"/>`
        })
      }
      
      opml += '\n    </outline>'
    })
  }
  
  opml += `
  </body>
</opml>`
  
  return opml
}

// XML转义函数
const escapeXML = (str) => {
  return str.replace(/[<>&'"]/g, (char) => {
    switch (char) {
      case '<': return '&lt;'
      case '>': return '&gt;'
      case '&': return '&amp;'
      case "'": return '&apos;'
      case '"': return '&quot;'
      default: return char
    }
  })
}

// 搜索链接计算属性和方法
const filteredResources = computed(() => {
  let filtered = relatedResources.value

  // 搜索过滤
  if (resourceSearchQuery.value) {
    const query = resourceSearchQuery.value.toLowerCase()
    filtered = filtered.filter(resource => 
      resource.title.toLowerCase().includes(query) ||
      resource.description.toLowerCase().includes(query) ||
      resource.tags.some(tag => tag.toLowerCase().includes(query)) ||
      resource.source.toLowerCase().includes(query)
    )
  }

  // 类型过滤
  if (selectedResourceType.value !== 'all') {
    filtered = filtered.filter(resource => resource.type === selectedResourceType.value)
  }

  // 格式过滤
  if (selectedFormat.value !== 'all') {
    filtered = filtered.filter(resource => resource.format === selectedFormat.value)
  }

  // 排序
  filtered.sort((a, b) => {
    switch (sortBy.value) {
      case 'publishTime':
        return new Date(b.publishTime) - new Date(a.publishTime)
      case 'downloadCount':
        return b.downloadCount - a.downloadCount
      case 'rating':
        return b.rating - a.rating
      default:
        return 0
    }
  })

  return filtered
})

// 资源相关方法
const getResourceTypeIcon = (type) => {
  const icons = {
    'document': '📄',
    'exercise': '📝',
    'summary': '📋',
    'courseware': '🎯'
  }
  return icons[type] || '📄'
}

const getResourceTypeName = (type) => {
  const names = {
    'document': '文档资料',
    'exercise': '练习题集',
    'summary': '知识总结',
    'courseware': '课件资源'
  }
  return names[type] || '文档资料'
}

const truncateText = (text, maxLength) => {
  if (text.length <= maxLength) return text
  return text.substring(0, maxLength) + '...'
}

const formatResourceTime = (timeString) => {
  const time = new Date(timeString)
  const now = new Date()
  const diff = now - time
  
  if (diff < 86400000) { // 24小时内
    return '今天'
  } else if (diff < 172800000) { // 48小时内
    return '昨天'
  } else if (diff < 604800000) { // 7天内
    return `${Math.floor(diff / 86400000)}天前`
  } else {
    return time.toLocaleDateString()
  }
}

const formatNumber = (num) => {
  // 处理undefined、null或非数字值
  if (num == null || num === undefined || num === '' || isNaN(num)) {
    return '0'
  }
  
  const number = Number(num)
  if (number >= 10000) {
    return `${(number / 10000).toFixed(1)}万`
  } else if (number >= 1000) {
    return `${(number / 1000).toFixed(1)}k`
  }
  return number.toString()
}

const clearSearch = () => {
  resourceSearchQuery.value = ''
}

const clearAllFilters = () => {
  resourceSearchQuery.value = ''
  selectedResourceType.value = 'all'
  selectedFormat.value = 'all'
  sortBy.value = 'publishTime'
}

// 已移除预览、下载、收藏功能，现在只保留搜索功能

// 初始化生成搜索链接
const loadInitialResources = async () => {
  if (resourcesLoaded.value || resourcesLoading.value) {
    return // 避免重复加载
  }
  
  try {
    resourcesLoading.value = true
    resourcesError.value = ''
    console.log('🔍 开始生成搜索链接...')
    
    // 获取文档内容用于推荐
    const documentContent = await extractDocumentText().catch(() => '文档内容')
    
    // 生成全网搜索链接
    const searchResources = generateSearchResources(fileMeta.value.name, documentContent)
    
    // 模拟异步加载
    await new Promise(resolve => setTimeout(resolve, 500))
    
    relatedResources.value = searchResources
    resourcesLoaded.value = true
    console.log('✅ 成功生成搜索链接:', searchResources.length, '个')
    
  } catch (error) {
    console.error('❌ 生成相关资源失败:', error)
    resourcesError.value = '生成资源失败，请重试'
    
    // 回退到基础搜索
    relatedResources.value = generateSearchResources(fileMeta.value.name, '文档内容')
    resourcesLoaded.value = true
    
  } finally {
    resourcesLoading.value = false
  }
}

// 生成全网搜索链接
const generateSearchResources = (fileName, documentContent) => {
  const baseFileName = fileName.replace(/\.[^/.]+$/, "")
  
  // 提取关键词用于搜索
  const keywords = extractSearchKeywords(fileName, documentContent)
  
  let resources = []
  let resourceId = 1
  
  // 为每个关键词生成搜索链接
  keywords.forEach(keyword => {
    const googleUrl = `https://www.google.com/search?q=${encodeURIComponent(keyword)}`
    const baiduUrl = `https://www.baidu.com/s?wd=${encodeURIComponent(keyword)}`
    const bingUrl = `https://www.bing.com/search?q=${encodeURIComponent(keyword)}`
    
    // Google搜索
    resources.push({
      id: resourceId++,
      title: `Google搜索: ${keyword}`,
      description: `在Google上搜索"${keyword}"的相关内容`,
      type: 'search',
      format: 'link',
      source: 'Google',
      searchEngine: 'Google',
      keyword: keyword,
      url: googleUrl,
      tags: ['搜索', 'Google', keyword]
    })
    
    // 百度搜索  
    resources.push({
      id: resourceId++,
      title: `百度搜索: ${keyword}`,
      description: `在百度上搜索"${keyword}"的相关内容`,
      type: 'search',
      format: 'link', 
      source: '百度',
      searchEngine: '百度',
      keyword: keyword,
      url: baiduUrl,
      tags: ['搜索', '百度', keyword]
    })
    
    // 必应搜索
    resources.push({
      id: resourceId++,
      title: `必应搜索: ${keyword}`,
      description: `在必应上搜索"${keyword}"的相关内容`,
      type: 'search',
      format: 'link',
      source: 'Bing', 
      searchEngine: 'Bing',
      keyword: keyword,
      url: bingUrl,
      tags: ['搜索', 'Bing', keyword]
    })
  })
  
  return resources
}

// 提取搜索关键词
const extractSearchKeywords = (fileName, documentContent) => {
  const baseFileName = fileName.replace(/\.[^/.]+$/, "")
  let keywords = [baseFileName]
  
  // 根据文档内容提取关键词
  if (documentContent) {
    // 学习材料相关关键词
    if (/复习|提纲|知识点/.test(documentContent + fileName)) {
      keywords.push(`${baseFileName} 知识点`)
      keywords.push(`${baseFileName} 复习资料`)
      keywords.push(`${baseFileName} 学习笔记`)
    }
    
    // 技术文档相关关键词
    if (/技术|原理|系统|方法/.test(documentContent + fileName)) {
      keywords.push(`${baseFileName} 技术原理`)
      keywords.push(`${baseFileName} 实现方法`)
      keywords.push(`${baseFileName} 案例分析`)
    }
    
    // 提取文档中的专业术语（简单实现）
    const terms = documentContent.match(/[A-Z]{2,}|[a-zA-Z]{4,}/g) || []
    const uniqueTerms = [...new Set(terms)].slice(0, 2)
    uniqueTerms.forEach(term => {
      if (term.length > 2) {
        keywords.push(`${baseFileName} ${term}`)
      }
    })
  }
  
  // 去重并限制数量
  return [...new Set(keywords)].slice(0, 3)
}

// 已移除generateBasicResources功能，现在使用搜索链接

// 点击资源卡片处理
const openResource = (resource) => {
  console.log('🔍 打开搜索:', resource.title)
  
  try {
    if (resource.type === 'search' && resource.url) {
      // 在新标签页中打开搜索链接
      window.open(resource.url, '_blank', 'noopener,noreferrer')
      console.log(`✅ 已在${resource.searchEngine}中搜索: ${resource.keyword}`)
    } else {
      console.warn('❌ 无效的搜索链接')
      alert('无效的搜索链接')
    }
  } catch (error) {
    console.error('❌ 打开搜索失败:', error)
    alert('无法打开搜索页面，请稍后重试')
  }
}

// 已移除资源详情功能

// 已移除loadMoreResources功能

// 已移除AI资源标签功能

// 监听activeTab变化，自动生成搜索链接
watch(() => activeTab.value, async (newTab) => {
  if (newTab === 'resources') {
    console.log('🔄 切换到全网搜索标签页，开始生成搜索链接...')
    await loadInitialResources()
  }
}, { immediate: false })

// 手动重新加载资源
const reloadResources = async () => {
  resourcesLoaded.value = false
  resourcesError.value = ''
  await loadInitialResources()
}


// 优化AI问答体验
const enhanceQaExperience = async () => {
  try {
    console.log('🚀 开始优化AI问答体验...')
    // 加载动态快速问题
    await loadQuickQuestions()
    console.log('✅ AI问答体验优化完成')
  } catch (error) {
    console.warn('⚠️ AI问答体验优化失败:', error)
  }
}

// 全局错误处理
const handleGlobalErrors = () => {
  // 处理未捕获的Promise拒绝（如CORS错误）
  window.addEventListener('unhandledrejection', (event) => {
    // 忽略语雀扩展和其他外部服务的CORS错误
    if (event.reason && event.reason.message) {
      const message = event.reason.message.toLowerCase()
      if (message.includes('cors') || 
          message.includes('yuque.com') ||
          message.includes('network error') ||
          message.includes('access-control-allow-origin')) {
        console.warn('🔇 忽略外部服务CORS错误:', event.reason.message)
        event.preventDefault() // 阻止错误显示在控制台
        return
      }
    }
  })
  
  // 处理音频播放错误
  window.addEventListener('error', (event) => {
    if (event.error && event.error.name === 'AbortError') {
      const message = event.error.message
      if (message.includes('play()') || message.includes('pause()')) {
        console.warn('🔇 忽略音频播放冲突错误:', message)
        event.preventDefault()
        return
      }
    }
  })
}

onMounted(async () => {
  handleGlobalErrors()
  await loadFile()
  
  // 延迟加载笔记，等待文档加载完成
  // 不再自动加载数据库笔记，仅保留本地功能
})

// 监听文档变化（已移除数据库笔记加载）
watch(() => fileMeta.value.name, async (newName) => {
  if (newName) {
    console.log('📄 文档变化:', newName)
    // 清空当前笔记列表（仅保留本地AI生成功能）
    aiNotes.value = []
  }
}, { deep: true })

onBeforeUnmount(() => {
  // 清理错误事件监听器
  window.removeEventListener('unhandledrejection', () => {})
  window.removeEventListener('error', () => {})
  
  if (objectUrlToRevoke) {
    try { URL.revokeObjectURL(objectUrlToRevoke) } catch {}
  }
  // 清理图片预览的object URL
  if (imagePreviewUrl.value && imagePreviewUrl.value.startsWith('blob:')) {
    try { URL.revokeObjectURL(imagePreviewUrl.value) } catch {}
  }
})

// 使用 docx-preview 渲染 DOCX
const renderDocx = async () => {
  try {
    const id = route.params.id
    let file = window.__AI_READER_FILES__ && window.__AI_READER_FILES__[id]
    if (!file) {
      // 如果用户刷新了页面，提示重新上传
      throw new Error('FILE_NOT_IN_MEMORY')
    }
    // 按需加载渲染函数与样式
    const mod = await import(/* @vite-ignore */ 'docx-preview')
    const renderAsync = mod.renderAsync || (mod.default && mod.default.renderAsync)
    ensureDocxCss()
    await nextTick()
    const container = docxContainer.value
    container.innerHTML = ''
    const buffer = await file.arrayBuffer()
    await renderAsync(buffer, container, undefined, {
      className: 'docx',
      inWrapper: true,
      ignoreWidth: false,
      ignoreHeight: false,
      breakPages: true,
      experimental: true
    })
  } catch (e) {
    // 渲染失败时保持占位
    if (String(e?.message).includes('FILE_NOT_IN_MEMORY')) {
      alert('页面已刷新或会话已丢失，请回到AI阅读助手重新选择文件后再进入。')
      router.replace('/ai_reader')
      return
    }
    console.warn('DOCX 预览失败：', e)
  }
}

const ensureDocxCss = () => {
  if (document.getElementById('docx-preview-css')) return
  const link = document.createElement('link')
  link.id = 'docx-preview-css'
  link.rel = 'stylesheet'
  link.href = 'https://unpkg.com/docx-preview@0.3.6/dist/docx-preview.css'
  document.head.appendChild(link)
}

// 使用 pdfjs 渲染 PDF（无浏览器自带工具栏）
const renderPdf = async () => {
  try {
    const id = route.params.id
    const file = window.__AI_READER_FILES__ && window.__AI_READER_FILES__[id]
    if (!file) throw new Error('FILE_NOT_IN_MEMORY')
    const arrayBuffer = await file.arrayBuffer()
    const pdfjsLib = await import(/* @vite-ignore */ 'pdfjs-dist')
    pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://unpkg.com/pdfjs-dist@3.11.174/build/pdf.worker.min.js'
    const loadingTask = pdfjsLib.getDocument({ data: arrayBuffer })
    const pdf = await loadingTask.promise
    
    // 存储PDF对象和文本内容供后续使用
    window.__AI_READER_PDF__ = window.__AI_READER_PDF__ || {}
    window.__AI_READER_PDF__[id] = {
      pdf: pdf,
      textContent: ''
    }
    
    const container = pdfContainer.value
    container.innerHTML = ''
    
    // 提取所有页面的文本内容
    let allText = ''
    for (let pageNum = 1; pageNum <= pdf.numPages; pageNum++) {
      const page = await pdf.getPage(pageNum)
      const viewport = page.getViewport({ scale: 1.2 })
      
      // 渲染canvas
      const canvas = document.createElement('canvas')
      const context = canvas.getContext('2d')
      canvas.width = viewport.width
      canvas.height = viewport.height
      canvas.style.margin = '16px auto'
      canvas.style.display = 'block'
      canvas.style.boxShadow = '0 2px 12px rgba(0,0,0,0.06)'
      container.appendChild(canvas)
      await page.render({ canvasContext: context, viewport }).promise
      
      // 提取文本内容
      try {
        const textContent = await page.getTextContent()
        const pageText = textContent.items.map(item => item.str).join(' ')
        allText += pageText + '\n'
      } catch (textError) {
        console.warn('提取PDF文本失败:', textError)
      }
    }
    
    // 保存提取的文本内容
    if (window.__AI_READER_PDF__[id]) {
      window.__AI_READER_PDF__[id].textContent = allText
    }
    
  } catch (e) {
    if (String(e?.message).includes('FILE_NOT_IN_MEMORY')) {
      alert('页面已刷新或会话已丢失，请回到AI阅读助手重新选择文件后再进入。')
      router.replace('/ai_reader')
    } else {
      console.warn('PDF 预览失败：', e)
    }
  }
}
</script>

<style scoped>
/* 全局滚动条样式 - 隐藏滚动条 */
* {
  scrollbar-width: none; /* Firefox */
  -ms-overflow-style: none; /* IE 10+ */
}
*::-webkit-scrollbar {
  display: none; /* WebKit */
}

.reader-page { 
  display: flex; 
  flex-direction: column; 
  height: 100vh; 
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  overflow: hidden;
}

.topbar { 
  height: 72px; 
  display: flex; 
  align-items: center; 
  justify-content: space-between;
  padding: 0 24px; 
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.3);
  position: relative;
  z-index: 10;
}

.back-btn { 
  display: inline-flex; 
  align-items: center; 
  gap: 10px; 
  border: none; 
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.2), rgba(255, 255, 255, 0.1));
  backdrop-filter: blur(20px);
  color: white; 
  padding: 14px 24px; 
  border-radius: 25px; 
  cursor: pointer; 
  font-size: 15px;
  font-weight: 600;
  transition: all 0.3s ease;
  border: 1px solid rgba(255, 255, 255, 0.3);
  position: relative;
  overflow: hidden;
}

.back-btn:hover {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.35), rgba(255, 255, 255, 0.25));
  transform: translateY(-3px) scale(1.05);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.2);
  border-color: rgba(255, 255, 255, 0.5);
}

.back-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s;
}

.back-btn:hover::before {
  left: 100%;
}

.document-title {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  align-items: center;
  gap: 12px;
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(20px);
  padding: 12px 24px;
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.title-icon {
  font-size: 20px;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1));
}

.title-text {
  margin: 0;
  color: white;
  font-size: 24px;
  font-weight: 900;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3), 0 0 20px rgba(255, 255, 255, 0.3);
  white-space: nowrap;
  max-width: 400px;
  overflow: hidden;
  text-overflow: ellipsis;
  font-family: 'Microsoft YaHei', 'SimHei', 'Arial Black', sans-serif;
  letter-spacing: 1px;
  background: linear-gradient(45deg, #ffffff, #f0f0f0, #ffffff);
  background-size: 200% 200%;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: titleShine 3s ease-in-out infinite;
}

.topbar-spacer {
  width: 120px; /* 与返回按钮同宽，用于平衡布局 */
}

.body { 
  display: flex; 
  flex: 1; 
  min-height: 0; 
  gap: 16px;
  padding: 16px 24px 24px 24px;
  background: transparent;
}

.left { 
  width: 60%; 
  background: transparent; 
  display: flex; 
}

.doc-pane { 
  width: 100%; 
  height: 100%; 
  background: #ffffff;
  backdrop-filter: blur(20px);
  border-radius: 20px; 
  box-shadow: 0 8px 40px rgba(0, 0, 0, 0.12); 
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.3);
  position: relative;
}

.doc-pane::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.8), transparent);
}

.doc-frame { 
  border: none; 
  width: 100%; 
  height: 100%; 
  border-radius: 20px;
}

.doc-placeholder { 
  height: 100%; 
  display: flex; 
  flex-direction: column; 
  align-items: center; 
  justify-content: center; 
  color: #8b5cf6; 
  gap: 16px;
  background: radial-gradient(circle at center, rgba(139, 92, 246, 0.05) 0%, transparent 70%);
}

.doc-icon { 
  font-size: 64px; 
  filter: drop-shadow(0 4px 12px rgba(139, 92, 246, 0.3));
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
}

.docx-container { padding: 0; height: 100%; width: 100%; overflow: auto; }

.pdf-container { padding: 16px; height: 100%; width: 100%; overflow: auto; background: #fff; }

.image-preview-container {
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 16px;
  gap: 20px;
}

.image-preview-section {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  background: #fff;
  border-radius: 8px;
  border: 1px solid #e9ecef;
  overflow: hidden;
}

.image-preview-header {
  padding: 12px 16px;
  background: #f8f9fa;
  border-bottom: 1px solid #e9ecef;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.image-preview-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.image-name {
  font-size: 14px;
  color: #666;
  font-weight: 500;
}

.image-preview-content {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
  min-height: 0;
  overflow: auto;
}

.preview-image {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.ocr-result-section {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  background: #fff;
  border-radius: 8px;
  border: 1px solid #e9ecef;
  overflow: hidden;
}

.ocr-result-header {
  padding: 12px 16px;
  background: #f8f9fa;
  border-bottom: 1px solid #e9ecef;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.ocr-result-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.ocr-status-indicator {
  font-size: 14px;
  font-weight: 500;
}

.status-success {
  color: #28a745;
}

.status-loading {
  color: #007bff;
}

.status-error {
  color: #dc3545;
}

.ocr-result-content {
  flex: 1;
  padding: 16px;
  overflow: auto;
  min-height: 0;
}

.ocr-text {
  font-size: 14px;
  line-height: 1.6;
  color: #333;
  white-space: pre-wrap;
  word-break: break-word;
}

.ocr-loading-placeholder,
.ocr-error-placeholder,
.ocr-empty-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  text-align: center;
  color: #666;
}

.loading-spinner {
  width: 24px;
  height: 24px;
  border: 2px solid #e9ecef;
  border-top: 2px solid #007bff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 12px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-message {
  color: #dc3545;
  margin-bottom: 16px;
}

.retry-btn {
  background: #007bff;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: background-color 0.2s;
}

.retry-btn:hover {
  background: #0056b3;
}

/* 文字识别面板样式 */
.ocr-panel {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
  position: relative;
}

.ocr-panel::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(59, 130, 246, 0.4), transparent);
  z-index: 1;
}

.ocr-tabs {
  display: flex;
  border-bottom: 1px solid #e9ecef;
  background: #f8f9fa;
}

.ocr-tab {
  padding: 12px 16px;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  color: #666;
  font-weight: 500;
  transition: all 0.2s;
}

.ocr-tab.active {
  color: #007bff;
  border-bottom-color: #007bff;
  background: #fff;
}

.ocr-content {
  flex: 1;
  overflow: auto;
  padding: 16px;
}

.ocr-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.action-btn {
  background: #5865f2;
  color: #fff;
  border: none;
  padding: 6px 10px;
  border-radius: 6px;
  cursor: pointer;
}

.action-btn:hover {
  background: #4954d6;
}

.copy-tip { color: #28a745; font-size: 12px; }

.ocr-text-view {
  height: 100%;
}

.ocr-text-content {
  line-height: 1.8;
  font-size: 14px;
  color: #333;
}

.ocr-word {
  display: inline;
  padding: 2px 4px;
  margin: 1px;
  border-radius: 3px;
  cursor: pointer;
  transition: all 0.2s;
  background: transparent;
}

.ocr-word:hover {
  background: #e3f2fd;
}

.ocr-word.highlighted {
  background: #ffd700;
  color: #333;
  font-weight: 600;
}

/* 行文本样式 */
.ocr-line {
  padding: 4px 6px;
  margin: 2px 0;
  border-radius: 4px;
  cursor: pointer;
}
.ocr-line:hover { background: #e3f2fd; }
.ocr-line.highlighted { background: #fff3cd; }

.ocr-json-view {
  height: 100%;
}

.json-content {
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 6px;
  padding: 12px;
  font-size: 12px;
  line-height: 1.4;
  overflow: auto;
  max-height: 100%;
  white-space: pre-wrap;
  word-break: break-all;
}

.json-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #666;
}

/* 图片预览区域样式 */
.image-wrapper {
  position: relative;
  display: inline-block;
  max-width: 100%;
  max-height: 100%;
}

.ocr-bounding-box {
  position: absolute;
  border: 2px solid #ffd700;
  border-radius: 2px;
  pointer-events: auto;
  z-index: 10;
  transition: all 0.2s;
  background: rgba(255, 215, 0, 0.1);
}

.ocr-bounding-box:hover {
  border-color: #ff6b35;
  background: rgba(255, 107, 53, 0.2);
  transform: scale(1.02);
}

.ocr-bounding-box.highlighted {
  border-color: #ff6b35;
  background: rgba(255, 107, 53, 0.3);
  box-shadow: 0 0 8px rgba(255, 107, 53, 0.5);
}

/* 行级边框 */
.ocr-line-box {
  position: absolute;
  border: 2px dashed #4caf50;
  background: rgba(76, 175, 80, 0.15);
  border-radius: 2px;
  transition: all 0.2s;
}
.ocr-line-box.highlighted {
  border-color: #2e7d32;
  background: rgba(46, 125, 50, 0.25);
  box-shadow: 0 0 8px rgba(46,125,50,.4);
}

.right { 
  width: 40%; 
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  box-shadow: 0 8px 40px rgba(0, 0, 0, 0.12);
  display: flex; 
  flex-direction: column; 
  overflow: hidden;
  position: relative;
}

.right::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.8), transparent);
}

.tabs { 
  display: flex; 
  gap: 8px; 
  padding: 20px 20px 16px 20px; 
  background: transparent;
  position: sticky; 
  top: 0; 
  z-index: 5;
  flex-wrap: wrap;
}

.tab { 
  padding: 10px 16px; 
  border-radius: 12px; 
  cursor: pointer; 
  color: #64748b; 
  font-size: 14px;
  font-weight: 500;
  transition: all 0.3s ease;
  background: rgba(255, 255, 255, 0.5);
  border: 1px solid rgba(0, 0, 0, 0.05);
  backdrop-filter: blur(10px);
  position: relative;
  overflow: hidden;
}

.tab::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.tab:hover::before {
  opacity: 1;
}

.tab.active { 
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white; 
  font-weight: 600;
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
  border-color: transparent;
}

.tab:hover:not(.active) {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  color: #667eea;
}

.panel { 
  padding: 0 20px 20px 20px; 
  overflow: auto; 
  flex: 1;
  /* 隐藏滚动条但保持滚动功能 */
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.panel::-webkit-scrollbar {
  display: none;
}
.section { 
  background: rgba(255, 255, 255, 0.8); 
  backdrop-filter: blur(15px);
  border: 1px solid rgba(255, 255, 255, 0.3); 
  border-radius: 16px; 
  padding: 20px; 
  margin-bottom: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  position: relative;
  overflow: hidden;
}

.section::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(102, 126, 234, 0.3), transparent);
}

.sec-title { 
  font-weight: 700; 
  color: #1e293b; 
  margin-bottom: 12px;
  font-size: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.sec-title::before {
  content: '✨';
  font-size: 14px;
}

.sec-body { 
  color: #475569; 
  margin-bottom: 16px; 
  white-space: pre-wrap; 
  line-height: 1.6;
  font-size: 14px;
}

.btn { 
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
  color: #fff; 
  border: none; 
  padding: 10px 20px; 
  border-radius: 12px; 
  cursor: pointer;
  font-weight: 500;
  font-size: 14px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
  position: relative;
  overflow: hidden;
}

.btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.2) 0%, transparent 100%);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
}

.btn:hover::before {
  opacity: 1;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.2);
}

.qa { display: flex; flex-direction: column; height: 100%; }
.qa-log { flex: 1; overflow: auto; background: #fafbff; border: 1px solid #eef0f6; border-radius: 10px; padding: 10px; }
.msg { padding: 6px 8px; border-radius: 8px; margin-bottom: 8px; max-width: 90%; }
.msg.user { align-self: flex-end; background: #e9ecff; }
.msg.bot { align-self: flex-start; background: #f1f5ff; }
.qa-input { display: flex; gap: 8px; margin-top: 10px; }
.qa-input input { flex: 1; height: 36px; border-radius: 8px; border: 1px solid #dfe3f0; padding: 0 10px; }

.notes { width: 100%; height: 100%; min-height: 380px; border: 1px solid #eef0f6; border-radius: 10px; padding: 10px; background: #fafbff; }
.placeholder { color: #8a8fa3; background: #fafbff; border: 1px dashed #dfe3f0; border-radius: 10px; padding: 18px; text-align: center; }

/* 新增的样式 */
.empty-state {
  text-align: center;
  color: #8a8fa3;
  padding: 40px 20px;
}

.loading-state {
  text-align: center;
  color: #5865f2;
  padding: 40px 20px;
}

.loading-spinner {
  width: 24px;
  height: 24px;
  border: 3px solid #eef0f6;
  border-top: 3px solid #5865f2;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.summary-content {
  line-height: 1.6;
  color: #333;
}

.summary-text {
  font-size: 14px;
  line-height: 1.8;
  color: #2c3e50;
  background: #f8f9fa;
  padding: 16px;
  border-radius: 8px;
  border-left: 4px solid #5865f2;
  position: relative;
}

.streaming-indicator {
  display: inline-block;
  animation: blink 1s infinite;
  color: #5865f2;
  font-weight: bold;
  margin-left: 2px;
}

.streaming-info {
  margin-top: 12px;
  text-align: center;
}

.typing-animation {
  display: inline-block;
  color: #5865f2;
  font-size: 13px;
  animation: pulse 2s infinite;
}

@keyframes blink {
  0%, 50% { opacity: 1; }
  51%, 100% { opacity: 0; }
}

@keyframes pulse {
  0%, 100% { opacity: 0.6; }
  50% { opacity: 1; }
}

/* AI聊天容器样式 */
.ai-chat-container {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  position: relative;
}

.ai-chat-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.8), transparent);
  z-index: 1;
}

.chat-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 16px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 10px rgba(102, 126, 234, 0.3);
  flex-wrap: wrap;
  gap: 10px;
}

.chat-actions {
  display: flex;
  gap: 8px;
}

.chat-action-btn {
  background: rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 8px;
  padding: 6px 10px;
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 14px;
}

.chat-action-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-1px);
}

.chat-action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.chat-title {
  display: flex;
  align-items: center;
  gap: 10px;
}

.chat-title h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
}

.chat-icon {
  font-size: 24px;
  animation: bounce 2s infinite;
}

.chat-status {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
}

.online-indicator {
  display: flex;
  align-items: center;
  gap: 6px;
}

.status-dot {
  width: 8px;
  height: 8px;
  background: #4ade80;
  border-radius: 50%;
  animation: pulse 2s infinite;
}

.typing-indicator {
  display: flex;
  align-items: center;
  gap: 6px;
}

.typing-indicator .dot {
  width: 4px;
  height: 4px;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 50%;
  animation: typing 1.4s infinite ease-in-out;
}

.typing-indicator .dot:nth-child(2) {
  animation-delay: 0.2s;
}

.typing-indicator .dot:nth-child(3) {
  animation-delay: 0.4s;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background: #ffffff;
  background-image: 
    radial-gradient(circle at 20px 80px, rgba(120, 119, 198, 0.03) 0%, transparent 50%),
    radial-gradient(circle at 80px 20px, rgba(255, 119, 198, 0.03) 0%, transparent 50%);
}

.message-wrapper {
  display: flex;
  margin-bottom: 16px;
  animation: messageSlideIn 0.3s ease-out;
  opacity: 0;
  animation-fill-mode: forwards;
}

.message-wrapper.user {
  justify-content: flex-end;
}

.message-wrapper.assistant {
  justify-content: flex-start;
}

.message-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  margin: 0 12px;
  flex-shrink: 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.message-wrapper.user .message-avatar {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  box-shadow: 0 2px 8px rgba(245, 87, 108, 0.3);
}

.message-bubble {
  max-width: 70%;
  padding: 12px 16px;
  border-radius: 18px;
  position: relative;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  animation: bubbleScale 0.2s ease-out;
}

.message-bubble.user {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.message-bubble.assistant {
  background: #ffffff;
  color: #333;
  border: 1px solid #e5e7eb;
}

.typing-message .message-bubble {
  background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%);
  animation: typingPulse 1.5s infinite;
}

.message-content {
  font-size: 14px;
  line-height: 1.5;
  white-space: pre-wrap;
  word-break: break-word;
}

.message-time {
  font-size: 11px;
  opacity: 0.7;
  margin-top: 4px;
  text-align: right;
}

.typing-cursor {
  color: #667eea;
  font-weight: bold;
  animation: blink 1s infinite;
}

.chat-input-area {
  background: #ffffff;
  border-top: 1px solid #e5e7eb;
  padding: 16px 20px;
}

.quick-questions {
  margin-bottom: 12px;
  padding: 8px;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border-radius: 8px;
  border: 1px solid #e2e8f0;
}

.quick-questions-label {
  font-size: 12px;
  font-weight: 600;
  color: #475569;
  margin-bottom: 6px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.quick-questions-container {
  max-height: 80px;
  overflow-y: auto;
  overflow-x: hidden;
  padding-right: 4px;
  /* 隐形滚动条样式 */
  scrollbar-width: thin;
  scrollbar-color: rgba(156, 163, 175, 0.3) transparent;
}

.quick-questions-container::-webkit-scrollbar {
  width: 4px;
}

.quick-questions-container::-webkit-scrollbar-track {
  background: transparent;
}

.quick-questions-container::-webkit-scrollbar-thumb {
  background: rgba(156, 163, 175, 0.3);
  border-radius: 2px;
  transition: background 0.2s ease;
}

.quick-questions-container::-webkit-scrollbar-thumb:hover {
  background: rgba(156, 163, 175, 0.5);
}

.quick-questions-container .quick-question-btn {
  display: inline-block;
  margin: 3px 4px 3px 0;
}

.quick-question-btn {
  background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
  border: 1px solid #cbd5e1;
  border-radius: 16px;
  padding: 6px 12px;
  font-size: 12px;
  color: #475569;
  cursor: pointer;
  transition: all 0.3s ease;
  white-space: nowrap;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  font-weight: 500;
}

.quick-question-btn:hover:not(:disabled) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
  border-color: #667eea;
}

.quick-question-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

.quick-questions-loading {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px 0;
  color: #6b7280;
}

.loading-dots {
  display: flex;
  gap: 4px;
}

.loading-dots span {
  width: 8px;
  height: 8px;
  background: #667eea;
  border-radius: 50%;
  animation: loading-pulse 1.4s infinite ease-in-out;
}

.loading-dots span:nth-child(1) {
  animation-delay: -0.32s;
}

.loading-dots span:nth-child(2) {
  animation-delay: -0.16s;
}

.loading-text {
  font-size: 12px;
  color: #6b7280;
  font-style: italic;
}

@keyframes loading-pulse {
  0%, 80%, 100% {
    transform: scale(0);
    opacity: 0.5;
  }
  40% {
    transform: scale(1);
    opacity: 1;
  }
}

.chat-input {
  display: flex;
  gap: 12px;
  align-items: center;
}

.chat-input-field {
  flex: 1;
  padding: 12px 16px;
  border: 2px solid #e5e7eb;
  border-radius: 25px;
  outline: none;
  font-size: 14px;
  transition: border-color 0.2s;
}

.chat-input-field:focus {
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.chat-input-field:disabled {
  background: #f9fafb;
  cursor: not-allowed;
}

.send-btn {
  width: 44px;
  height: 44px;
  border: none;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-size: 18px;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.send-btn:hover:not(:disabled) {
  transform: scale(1.05);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

.send-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

/* AI学习笔记样式 */
.ai-notes-container {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
  position: relative;
}

.ai-notes-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(139, 92, 246, 0.4), transparent);
}

.notes-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 0;
  border-bottom: 2px solid #f1f3f4;
  margin-bottom: 16px;
}

.notes-header h3 {
  margin: 0;
  color: #1f2937;
  font-size: 18px;
  font-weight: 700;
}

.notes-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  background: #f3f4f6;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  padding: 8px 12px;
  font-size: 13px;
  color: #374151;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 4px;
}

.action-btn:hover {
  background: #e5e7eb;
  transform: translateY(-1px);
}

.action-btn.primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
}

.action-btn.primary:hover {
  background: linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}


.notes-list {
  flex: 1;
  overflow-y: auto;
}

.note-card {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: all 0.2s;
  animation: noteSlideIn 0.4s ease-out;
  opacity: 0;
  animation-fill-mode: forwards;
}

.note-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transform: translateY(-2px);
}

.note-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.note-meta {
  display: flex;
  align-items: center;
  gap: 8px;
}

/* 已移除 note-type-badge 相关样式，因为不再使用 type 字段 */

.note-time {
  font-size: 11px;
  color: #9ca3af;
}


.note-title {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
}

.note-text {
  margin: 0 0 12px 0;
  font-size: 14px;
  line-height: 1.6;
  color: #4b5563;
  white-space: pre-wrap;
}


.tag {
  background: #f3f4f6;
  color: #6b7280;
  padding: 2px 6px;
  border-radius: 8px;
  font-size: 11px;
}


.empty-notes {
  text-align: center;
  padding: 60px 20px;
  color: #6b7280;
}

.empty-mind-map {
  text-align: center;
  padding: 80px 20px;
  color: #6b7280;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  min-height: 300px;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

/* 思维导图样式 */
.mind-map-container {
  height: 100%;
  display: flex;
  flex-direction: column;
  position: relative;
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
}

.mind-map-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(245, 87, 108, 0.4), transparent);
  z-index: 1;
}

.mind-map-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 0;
  border-bottom: 2px solid #f1f3f4;
  margin-bottom: 20px;
  position: relative;
}

.mind-map-title h3 {
  margin: 0 0 8px 0;
  color: #1f2937;
  font-size: 18px;
  font-weight: 700;
}

.mind-map-subtitle {
  font-size: 14px;
  color: #6b7280;
  font-weight: 500;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* 控制面板触发按钮 */
.controls-trigger {
  position: relative;
  width: 40px;
  height: 40px;
  border: none;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  color: white;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
  z-index: 100;
}

.controls-trigger:hover {
  transform: scale(1.1);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

.controls-trigger.active {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  transform: rotate(90deg);
}

/* 浮动控制面板 */
.floating-controls {
  position: absolute;
  top: 50px;
  right: 0;
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  border: 1px solid #e5e7eb;
  padding: 16px;
  z-index: 99;
  opacity: 0;
  transform: translateY(-10px);
  transition: all 0.3s ease;
  pointer-events: none;
  min-width: 200px;
}

/* 确保导出菜单相对于控制组定位 */
.control-group {
  position: relative;
}

.floating-controls.visible {
  opacity: 1;
  transform: translateY(0);
  pointer-events: auto;
}

.control-group {
  margin-bottom: 16px;
}

.control-group:last-child {
  margin-bottom: 0;
}

.group-title {
  font-size: 12px;
  font-weight: 600;
  color: #6b7280;
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.control-group {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}

.control-btn {
  min-width: 36px;
  height: 36px;
  border: 1px solid #d1d5db;
  background: #ffffff;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.2s;
  padding: 0 8px;
}

.control-btn:hover:not(:disabled) {
  border-color: #667eea;
  background: #f3f4f6;
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.2);
}

.control-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.control-btn.active {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

.zoom-display {
  font-size: 12px;
  color: #667eea;
  font-weight: 600;
  min-width: 45px;
  text-align: center;
  background: #f3f4f6;
  border-radius: 6px;
  padding: 4px 8px;
}

/* 导出菜单样式 */
.export-menu {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 8px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  border: 1px solid #e5e7eb;
  padding: 16px;
  min-width: 300px;
  z-index: 200;
  animation: slideDown 0.3s ease-out;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.export-category {
  margin-bottom: 20px;
}

.export-category:last-child {
  margin-bottom: 0;
}

.category-title {
  font-size: 14px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 12px;
  padding-bottom: 6px;
  border-bottom: 1px solid #f3f4f6;
}

.export-options {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
}

.export-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 12px 8px;
  border: 1px solid #e5e7eb;
  background: #ffffff;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
  min-height: 70px;
  justify-content: center;
}

.export-btn:hover {
  border-color: #667eea;
  background: #f8fafc;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
}

.export-icon {
  font-size: 24px;
  margin-bottom: 4px;
}

.export-text {
  font-size: 12px;
  font-weight: 500;
  color: #6b7280;
  text-align: center;
}

.mind-map-content {
  flex: 1;
  overflow: hidden;
  background: radial-gradient(circle at center, #f8fafc 0%, #f1f5f9 100%);
  border-radius: 12px;
  position: relative;
  border: 1px solid #e5e7eb;
}

.mind-map-loading, .mind-map-error {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  padding: 40px;
  text-align: center;
  color: #6b7280;
}

.mind-map-loading .loading-tip {
  font-size: 12px;
  color: #9ca3af;
  margin-top: 8px;
  font-style: italic;
}

.mind-map-loading .loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #e5e7eb;
  border-top: 3px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

.mind-map-error .error-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.mind-map-error .error-message {
  font-size: 16px;
  color: #dc2626;
  margin-bottom: 8px;
  font-weight: 500;
}

.mind-map-error .error-hint {
  font-size: 14px;
  color: #6b7280;
  margin-bottom: 20px;
  text-align: center;
  line-height: 1.5;
}

.mind-map-error .error-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
  flex-wrap: wrap;
}

.mind-map-error .retry-btn {
  padding: 10px 20px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 14px;
  font-weight: 500;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.mind-map-error .retry-btn:hover {
  background: linear-gradient(135deg, #5a67d8, #6c5ce7);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.mind-map-error .continue-btn {
  padding: 10px 20px;
  background: linear-gradient(135deg, #10b981, #059669);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 14px;
  font-weight: 500;
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
}

.mind-map-error .continue-btn:hover {
  background: linear-gradient(135deg, #059669, #047857);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
}

.mind-map-viewport {
  width: 100%;
  height: 100%;
  overflow: hidden;
  cursor: grab;
  position: relative;
}

.mind-map-viewport:active {
  cursor: grabbing;
}

.mind-map-tree {
  transition: transform 0.2s ease;
  transform-origin: center center;
  min-width: 100%;
  min-height: 100%;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding: 30px;
}

.mind-map-tree {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  min-height: 100%;
}

.tree-node {
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  animation: nodeAppear 0.6s ease-out;
  opacity: 0;
  animation-fill-mode: forwards;
}

.root-node .node-content {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 16px 24px;
  border-radius: 25px;
  font-size: 16px;
  font-weight: 700;
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
  transform: scale(1.1);
}

.branch-node .node-content {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  padding: 12px 18px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
  box-shadow: 0 4px 15px rgba(245, 87, 108, 0.3);
  margin: 20px 0;
}

.leaf-node .node-content {
  background: #ffffff;
  color: #374151;
  border: 2px solid #e5e7eb;
  padding: 8px 14px;
  border-radius: 15px;
  font-size: 13px;
  font-weight: 500;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  margin: 8px 0;
  transition: all 0.2s;
}

.leaf-node .node-content:hover {
  border-color: #667eea;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.2);
  transform: translateY(-2px);
}

.node-content {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.node-icon {
  font-size: 16px;
}

.node-text {
  white-space: nowrap;
}

/* 不同层级标题样式 */
.main-title {
  font-size: 16px;
  font-weight: 700 !important;
  color: #1f2937;
}

.branch-title {
  font-size: 14px;
  font-weight: 600 !important;
  color: #374151;
}

.leaf-title {
  font-size: 12px;
  font-weight: 500 !important;
  color: #4b5563;
}

/* 节点计数器 */
.node-count {
  background: rgba(255, 255, 255, 0.8);
  color: #6b7280;
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 10px;
  margin-left: 8px;
  font-weight: 600;
}

/* 折叠按钮 */
.collapse-btn {
  width: 20px;
  height: 20px;
  border: 1px solid rgba(255, 255, 255, 0.5);
  background: rgba(255, 255, 255, 0.9);
  border-radius: 50%;
  color: #6b7280;
  font-size: 12px;
  font-weight: 700;
  cursor: pointer;
  margin-left: 8px;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.collapse-btn:hover {
  background: white;
  border-color: #667eea;
  color: #667eea;
  transform: scale(1.1);
}

/* 节点详情面板 */
.node-details-panel {
  position: absolute;
  bottom: 20px;
  right: 20px;
  width: 300px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  border: 1px solid #e5e7eb;
  z-index: 10;
  animation: slideUp 0.3s ease-out;
}

.details-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #f3f4f6;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 12px 12px 0 0;
}

.details-header h4 {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
}

.close-details {
  background: none;
  border: none;
  color: white;
  font-size: 16px;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: background 0.2s;
}

.close-details:hover {
  background: rgba(255, 255, 255, 0.2);
}

.details-content {
  padding: 16px 20px;
  color: #4b5563;
  line-height: 1.6;
  font-size: 14px;
  white-space: pre-wrap;
}

/* 移除了视图模式样式 - 简化界面 */

/* 动画效果 */
@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 增强的节点交互 */
.tree-node .node-content {
  cursor: pointer;
  position: relative;
  transition: all 0.3s ease;
}

.tree-node .node-content:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.2);
}

.tree-node .node-content:active {
  transform: translateY(0);
}

.node-children {
  display: flex;
  gap: 20px;
  margin-top: 20px;
  position: relative;
}

.branch-node .node-children {
  flex-direction: column;
  gap: 10px;
  margin-top: 15px;
}

.root-node > .node-children {
  margin-top: 40px;
}

/* 连接线 */
.tree-node::before {
  content: '';
  position: absolute;
  top: -20px;
  left: 50%;
  width: 2px;
  height: 20px;
  background: linear-gradient(to bottom, #d1d5db, transparent);
  transform: translateX(-50%);
}

.root-node::before {
  display: none;
}

/* 动画定义 */
@keyframes messageSlideIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes bubbleScale {
  from {
    transform: scale(0.8);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}

@keyframes typingPulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.7;
  }
}

@keyframes typing {
  0%, 60%, 100% {
    transform: translateY(0);
    opacity: 0.4;
  }
  30% {
    transform: translateY(-10px);
    opacity: 1;
  }
}

@keyframes bounce {
  0%, 20%, 50%, 80%, 100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-5px);
  }
  60% {
    transform: translateY(-3px);
  }
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes noteSlideIn {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes nodeAppear {
  from {
    opacity: 0;
    transform: scale(0.8) translateY(20px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

/* 全网搜索样式 */
.resources-container {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
  position: relative;
}

.resources-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(16, 185, 129, 0.4), transparent);
  z-index: 1;
}

.resources-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 0;
  border-bottom: 2px solid #f1f3f4;
  margin-bottom: 20px;
}

.resources-header h3 {
  margin: 0;
  color: #1f2937;
  font-size: 18px;
  font-weight: 700;
}

.resources-stats {
  display: flex;
  gap: 16px;
}

.stats-item {
  display: flex;
  align-items: baseline;
  gap: 4px;
}

.stats-number {
  font-size: 20px;
  font-weight: 700;
  color: #667eea;
}

.stats-label {
  font-size: 14px;
  color: #6b7280;
}

.resources-filters {
  background: #f8f9fa;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 20px;
}

.search-bar {
  margin-bottom: 16px;
}

.search-input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 12px;
  font-size: 16px;
  color: #6b7280;
  z-index: 1;
}

.search-input {
  width: 100%;
  padding: 12px 16px 12px 40px;
  border: 2px solid #e5e7eb;
  border-radius: 25px;
  font-size: 14px;
  outline: none;
  transition: all 0.2s;
}

.search-input:focus {
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.clear-search {
  position: absolute;
  right: 12px;
  width: 24px;
  height: 24px;
  border: none;
  background: #e5e7eb;
  border-radius: 50%;
  color: #6b7280;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  transition: all 0.2s;
}

.clear-search:hover {
  background: #d1d5db;
}

.filter-controls {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
}

.filter-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.filter-label {
  font-size: 14px;
  color: #374151;
  font-weight: 500;
  white-space: nowrap;
}

.filter-select {
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-size: 14px;
  background: white;
  outline: none;
  transition: border-color 0.2s;
  min-width: 120px;
}

.filter-select:focus {
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.resources-list {
  flex: 1;
  overflow-y: auto;
}

.resource-card {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  padding: 20px;
  margin-bottom: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  transition: all 0.3s;
  animation: resourceSlideIn 0.4s ease-out;
  opacity: 0;
  animation-fill-mode: forwards;
  cursor: pointer;
}

.resource-card:hover {
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.12);
  transform: translateY(-4px);
  border-color: #667eea;
}

.resource-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.resource-type-badge {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
}

.resource-type-badge.document {
  background: #dbeafe;
  color: #1e40af;
}

.resource-type-badge.exercise {
  background: #fef3c7;
  color: #92400e;
}

.resource-type-badge.summary {
  background: #d1fae5;
  color: #065f46;
}

.resource-type-badge.courseware {
  background: #f3e8ff;
  color: #6b21a8;
}

.resource-format {
  display: flex;
  align-items: center;
}

.format-badge {
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.5px;
}

.format-badge.pdf {
  background: #fee2e2;
  color: #dc2626;
}

.format-badge.docx, .format-badge.doc {
  background: #dbeafe;
  color: #2563eb;
}

.format-badge.pptx {
  background: #fed7d7;
  color: #c53030;
}

.format-badge.txt {
  background: #f3f4f6;
  color: #374151;
}

.resource-content {
  margin-bottom: 16px;
}

.resource-title {
  margin: 0 0 12px 0;
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.resource-description {
  margin: 0 0 12px 0;
  font-size: 14px;
  line-height: 1.6;
  color: #6b7280;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.resource-tags {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.resource-tag {
  background: #f3f4f6;
  color: #6b7280;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 500;
  transition: all 0.2s;
}

.resource-tag:hover {
  background: #667eea;
  color: white;
}

.resource-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-top: 12px;
  border-top: 1px solid #f3f4f6;
}

.meta-info {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #6b7280;
}

.meta-icon {
  font-size: 14px;
}

.resource-source {
  font-size: 12px;
  color: #9ca3af;
  font-style: italic;
}

.resource-actions {
  display: flex;
  gap: 8px;
  justify-content: flex-end;
}

.action-button {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  border: none;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.action-button.preview {
  background: #f3f4f6;
  color: #374151;
}

.action-button.preview:hover {
  background: #667eea;
  color: white;
  transform: translateY(-1px);
}

.action-button.download {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
}

.action-button.download:hover {
  background: linear-gradient(135deg, #059669 0%, #047857 100%);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.action-button.collect {
  background: #fef3c7;
  color: #92400e;
}

.action-button.collect:hover {
  background: #fbbf24;
  color: white;
  transform: translateY(-1px);
}

.button-icon {
  font-size: 14px;
}

.empty-resources {
  text-align: center;
  padding: 80px 20px;
  color: #6b7280;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 20px;
  opacity: 0.5;
}

/* 资源加载状态 */
.resources-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  color: #6b7280;
}

.resources-loading .loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f4f6;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

.resources-loading p {
  font-size: 16px;
  color: #6b7280;
  margin: 0;
}

/* 资源错误状态 */
.resources-error {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  color: #6b7280;
  text-align: center;
}

.resources-error .error-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.resources-error p {
  font-size: 16px;
  color: #dc2626;
  margin: 0 0 20px 0;
}

.load-more-section {
  display: flex;
  justify-content: center;
  padding: 20px 0;
  border-top: 1px solid #f3f4f6;
  margin-top: 20px;
}

.load-more-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 25px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.load-more-btn:hover {
  background: linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%);
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.load-icon {
  font-size: 16px;
  animation: rotate 2s linear infinite;
}

@keyframes rotate {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

@keyframes resourceSlideIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes titleShine {
  0%, 100% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
}

/* 深度选择器：美化 docx-preview 的页面布局（使页面水平居中并有投影） */
::v-deep(.docx) { display: flex; justify-content: center; background: #fff; }
::v-deep(.docx .docx-wrapper) { padding: 16px; }
::v-deep(.docx .docx-page) { margin: 16px auto; box-shadow: 0 2px 12px rgba(0,0,0,0.06); }
</style>


