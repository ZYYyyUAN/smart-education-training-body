<template>
  <div class="writing-result-container">
    <!-- 顶部导航栏 -->
    <div class="top-navigation">
      <!-- 返回按钮 -->
      <div class="back-button" @click="goBack">
        <svg viewBox="0 0 24 24" width="20" height="20">
          <path fill="currentColor" d="M20,11V13H8L13.5,18.5L12.08,19.92L4.16,12L12.08,4.08L13.5,5.5L8,11H20Z" />
        </svg>
        <span>返回</span>
      </div>

      <!-- 中间标题 -->
      <div class="page-title">{{ documentTitle }}</div>

      <!-- 导出下拉按钮 -->
      <div class="export-dropdown" ref="exportDropdown">
        <button class="export-button" @click="toggleExportMenu">
          导出
          <svg viewBox="0 0 24 24" width="16" height="16" class="dropdown-arrow">
            <path fill="currentColor" d="M7,10L12,15L17,10H7Z" />
          </svg>
        </button>
        <div class="export-menu" v-show="showExportMenu">
          <div class="export-option" @click="exportAsPDF">
            <span class="export-icon pdf-icon">📄</span>
            PDF
          </div>
          <div class="export-option" @click="exportAsWord">
            <span class="export-icon word-icon">📘</span>
            Word
          </div>
        </div>
      </div>
    </div>

    <div class="result-layout">
      <!-- 左侧控制面板 -->
      <div class="control-panel">
        <div class="panel-header">
          <h3 class="panel-title">写作要求</h3>
          <div class="menu-icon">
            <svg viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M3,6H21V8H3V6M3,11H21V13H3V11M3,16H21V18H3V16Z" />
            </svg>
          </div>
        </div>

        <div class="requirement-section">
          <div class="requirement-item">
            <label class="requirement-label">
              <span class="required-star">*</span>主题
            </label>
            <input 
              type="text" 
              v-model="topic" 
              class="topic-input"
              placeholder="请输入主题"
            />
          </div>

          <div class="requirement-item">
            <label class="requirement-label">内容要求</label>
            <textarea 
              v-model="contentRequirement"
              class="requirement-content content-box editable-requirement"
              placeholder="输入文本，自动识别参考资料，正文大纲，字数要求"
              rows="4"
            ></textarea>
          </div>
        </div>

        <div class="ai-section">
          <button 
            class="ai-identify-button"
            @click="handleAiIdentify"
            :disabled="isAnalyzing"
          >
            <span class="ai-icon">🤖</span>
            <span v-if="!isAnalyzing">AI识别</span>
            <span v-else>🔄 识别中...</span>
          </button>
        </div>

        <div class="outline-section">
          <div class="outline-header">
            <h4>正文大纲</h4>
            <label class="ai-toggle">
              <input type="checkbox" v-model="aiRecommendEnabled">
              <span class="toggle-slider" :class="{ active: aiRecommendEnabled }"></span>
              <span class="toggle-label">AI推荐</span>
            </label>
          </div>
          
          <!-- 标题列表 -->
          <div class="outline-list" v-if="outlineTitles.length > 0">
            <div 
              v-for="(title, index) in outlineTitles" 
              :key="title.order || index"
              class="outline-item"
            >
              <div class="outline-order">{{ title.order || (index + 1) }}</div>
              <input 
                v-model="title.title"
                class="outline-title-input"
                placeholder="标题内容"
              />
              <button 
                class="outline-delete-btn"
                @click="removeTitle(index)"
                title="删除标题"
              >
                ×
              </button>
            </div>
          </div>
          
          <div class="add-outline">
            <button class="add-button" @click="addNewTitle">+ 添加标题</button>
          </div>
        </div>

        <div class="generate-section">
          <button 
            class="generate-full-button" 
            @click="handleGenerateFullText"
            :disabled="isGenerating || outlineTitles.length === 0"
          >
            <span v-if="!isGenerating && outlineTitles.length > 0">📝 按大纲生成全文</span>
            <span v-else-if="isGenerating">🔄 正在生成中...</span>
            <span v-else>请先生成大纲标题</span>
          </button>
        </div>
      </div>

      <!-- 右侧文档区域 -->
      <div class="document-area">
        <div class="document-content">
          <div class="document-editor">
            <div 
              contenteditable="true"
              class="editable-content"
              :class="{ 'readonly': isGenerating }"
              @input="updateWordCount"
              ref="contentTextarea"
              v-html="formattedContent"
            ></div>
            <div v-if="!generatedContent && !isGenerating" class="placeholder">
              点击这里，轻松开始写作~
            </div>
          </div>

          <div class="word-count">{{ wordCount }}字</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import axios from 'axios'
import jsPDF from 'jspdf'
import html2canvas from 'html2canvas'
import * as fileSaver from 'file-saver'
import { Document, Packer, Paragraph, TextRun, HeadingLevel, AlignmentType } from 'docx'

const router = useRouter()
const route = useRoute()

// 获取传递的参数
const topic = ref(route.query.topic || '人工智能在教育领域的应用研究')
const documentTitle = ref(topic.value || '未命名')
const isGenerating = ref(false)
const generatedContent = ref('')
const aiRecommendEnabled = ref(false)
const showExportMenu = ref(false)
const contentRequirement = ref('')
const isAnalyzing = ref(false)
const analysisResult = ref(null)
const outlineTitles = ref([])
const contentTextarea = ref(null)

// 计算属性 - 将文本转换为带格式的HTML
const formattedContent = computed(() => {
  if (!generatedContent.value) return ''
  
  let content = generatedContent.value
  
  // 先处理标题，确保标题前后有正确的换行
  content = content
    // 处理一级标题 - 大号加粗
    .replace(/【\s*(.*?)\s*】/g, '\n<h1 class="title-level-1">$1</h1>\n')
    // 处理二级标题 - 中号加粗  
    .replace(/▪\s*(.*?)\s*▪/g, '\n<h2 class="title-level-2">$1</h2>\n')
    // 处理三级标题 - 小号加粗
    .replace(/◆\s*(.*?)\s*◆/g, '\n<h3 class="title-level-3">$1</h3>\n')
  
  // 处理段落：将多个换行分组为段落
  content = content
    // 将连续的换行替换为段落分隔
    .split(/\n\s*\n/)
    .map(paragraph => {
      // 如果段落包含标题标签，直接返回
      if (paragraph.includes('<h1') || paragraph.includes('<h2') || paragraph.includes('<h3')) {
        return paragraph
      }
      // 如果是普通段落，包装为p标签，并将单个换行转为空格
      return paragraph.trim() ? `<p>${paragraph.replace(/\n/g, ' ').trim()}</p>` : ''
    })
    .filter(p => p) // 过滤空段落
    .join('\n')
  
  // 处理其他markdown格式
  content = content
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
  
  return content
})

const wordCount = computed(() => {
  if (!generatedContent.value) return 0
  // 移除HTML标签和计算实际字符数
  return generatedContent.value.replace(/<[^>]*>/g, '').replace(/\s/g, '').length
})

// 方法
const goBack = () => {
  router.go(-1)
}

const toggleExportMenu = () => {
  showExportMenu.value = !showExportMenu.value
}

// PDF导出功能
const exportAsPDF = async () => {
  console.log('导出为PDF')
  showExportMenu.value = false
  
  try {
    if (!generatedContent.value || generatedContent.value.trim() === '') {
      alert('没有内容可以导出，请先生成文档内容')
      return
    }

    // 创建一个临时的HTML元素用于PDF生成
    const tempDiv = document.createElement('div')
    tempDiv.style.cssText = `
      width: 210mm;
      padding: 20mm;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif;
      font-size: 14px;
      line-height: 1.6;
      color: #333;
      background: white;
      position: absolute;
      top: -9999px;
      left: -9999px;
    `
    
    // 生成PDF内容，包含标题和正文
    const pdfContent = `
      <div style="text-align: center; margin-bottom: 30px; border-bottom: 2px solid #333; padding-bottom: 15px;">
        <h1 style="font-size: 24px; font-weight: bold; color: #1a1a1a; margin: 0;">${documentTitle.value}</h1>
      </div>
      <div style="margin-top: 20px;">
        ${formattedContent.value}
      </div>
    `
    
    tempDiv.innerHTML = pdfContent
    document.body.appendChild(tempDiv)

    // 使用html2canvas生成图片
    const canvas = await html2canvas(tempDiv, {
      scale: 2,
      useCORS: true,
      allowTaint: true,
      backgroundColor: '#ffffff',
      width: tempDiv.offsetWidth,
      height: tempDiv.offsetHeight
    })

    // 移除临时元素
    document.body.removeChild(tempDiv)

    // 创建PDF
    const pdf = new jsPDF('p', 'mm', 'a4')
    const imgData = canvas.toDataURL('image/png')
    
    const imgWidth = 210 // A4宽度
    const pageHeight = 297 // A4高度
    const imgHeight = (canvas.height * imgWidth) / canvas.width
    let heightLeft = imgHeight

    let position = 0

    // 添加第一页
    pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight)
    heightLeft -= pageHeight

    // 如果内容超过一页，添加更多页面
    while (heightLeft >= 0) {
      position = heightLeft - imgHeight
      pdf.addPage()
      pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight)
      heightLeft -= pageHeight
    }

    // 下载PDF
    const fileName = `${documentTitle.value || '文档'}.pdf`
    pdf.save(fileName)
    
    console.log('PDF导出成功')
  } catch (error) {
    console.error('PDF导出失败:', error)
    alert('PDF导出失败，请稍后重试')
  }
}

// Word导出功能
const exportAsWord = async () => {
  console.log('导出为Word')
  showExportMenu.value = false
  
  try {
    if (!generatedContent.value || generatedContent.value.trim() === '') {
      alert('没有内容可以导出，请先生成文档内容')
      return
    }

    // 解析HTML内容为纯文本段落
    const parseContentToDocx = (htmlContent) => {
      const tempDiv = document.createElement('div')
      tempDiv.innerHTML = htmlContent
      
      const paragraphs = []
      
      // 添加文档标题
      paragraphs.push(
        new Paragraph({
          children: [
            new TextRun({
              text: documentTitle.value,
              bold: true,
              size: 32, // 16pt
            })
          ],
          heading: HeadingLevel.TITLE,
          alignment: AlignmentType.CENTER,
          spacing: { after: 400 }
        })
      )

      // 遍历所有元素
      const elements = tempDiv.children
      for (let i = 0; i < elements.length; i++) {
        const element = elements[i]
        
        if (element.tagName === 'H1') {
          paragraphs.push(
            new Paragraph({
              children: [
                new TextRun({
                  text: element.textContent,
                  bold: true,
                  size: 28, // 14pt
                })
              ],
              heading: HeadingLevel.HEADING_1,
              spacing: { before: 300, after: 200 }
            })
          )
        } else if (element.tagName === 'H2') {
          paragraphs.push(
            new Paragraph({
              children: [
                new TextRun({
                  text: element.textContent,
                  bold: true,
                  size: 24, // 12pt
                })
              ],
              heading: HeadingLevel.HEADING_2,
              spacing: { before: 250, after: 150 }
            })
          )
        } else if (element.tagName === 'H3') {
          paragraphs.push(
            new Paragraph({
              children: [
                new TextRun({
                  text: element.textContent,
                  bold: true,
                  size: 22, // 11pt
                })
              ],
              heading: HeadingLevel.HEADING_3,
              spacing: { before: 200, after: 100 }
            })
          )
        } else if (element.tagName === 'P' && element.textContent.trim()) {
          // 处理段落中的格式化文本
          const children = []
          const processNode = (node) => {
            if (node.nodeType === Node.TEXT_NODE) {
              if (node.textContent.trim()) {
                children.push(new TextRun({
                  text: node.textContent,
                  size: 20 // 10pt
                }))
              }
            } else if (node.nodeType === Node.ELEMENT_NODE) {
              const text = node.textContent
              if (text.trim()) {
                children.push(new TextRun({
                  text: text,
                  bold: node.tagName === 'STRONG' || node.tagName === 'B',
                  italics: node.tagName === 'EM' || node.tagName === 'I',
                  size: 20 // 10pt
                }))
              }
            }
          }
          
          for (const child of element.childNodes) {
            processNode(child)
          }
          
          if (children.length > 0) {
            paragraphs.push(
              new Paragraph({
                children: children,
                spacing: { after: 120 },
                alignment: AlignmentType.JUSTIFIED
              })
            )
          }
        }
      }
      
      return paragraphs
    }

    // 创建文档
    const doc = new Document({
      sections: [{
        properties: {},
        children: parseContentToDocx(formattedContent.value)
      }]
    })

    // 生成并下载Word文档
    const buffer = await Packer.toBlob(doc)
    const fileName = `${documentTitle.value || '文档'}.docx`
    fileSaver.saveAs(buffer, fileName)
    
    console.log('Word导出成功')
  } catch (error) {
    console.error('Word导出失败:', error)
    alert('Word导出失败，请稍后重试')
  }
}

// AI识别处理函数
const handleAiIdentify = async () => {
  if (!topic.value.trim() || !contentRequirement.value.trim()) {
    alert('请先输入主题和内容要求')
    return
  }

  // 检查认证token
  const token = localStorage.getItem('token')
  if (!token) {
    alert('请先登录后再使用AI写作功能')
    return
  }

  isAnalyzing.value = true

  try {
    // 调用AI识别接口
    const result = await axios.post('/api/ai-writing/analyze-requirement', {
      topic: topic.value,
      contentRequirement: contentRequirement.value
    })

    analysisResult.value = result.data || result
    
    console.log('AI识别结果:', result)
    
    // 识别成功后，自动生成标题
    await generateOutlineTitles(result.data || result)

  } catch (error) {
    console.error('AI识别失败:', error)
    alert('AI识别失败，请检查网络连接或稍后重试')
  } finally {
    isAnalyzing.value = false
  }
}

// 生成大纲标题
const generateOutlineTitles = async (analysisResult) => {
  try {
    // 如果analysisResult是字符串，先解析为JSON
    let parsedResult = analysisResult
    if (typeof analysisResult === 'string') {
      try {
        parsedResult = JSON.parse(analysisResult)
      } catch (e) {
        console.error('解析AI识别结果失败:', e)
        alert('AI识别结果格式错误')
        return
      }
    }

    console.log('解析后的识别结果:', parsedResult)

    const titles = await axios.post('/api/ai-writing/generate-outline-titles', {
      topic: topic.value,
      documentType: parsedResult.documentType,
      keyPoints: JSON.stringify(parsedResult.keyPoints || []),
      contentRequirement: contentRequirement.value
    })

    // 处理axios响应
    const titlesData = titles.data || titles
    console.log('生成的标题响应:', titles)
    console.log('标题数据:', titlesData)

    // 如果返回的是字符串，尝试解析为JSON
    if (typeof titlesData === 'string') {
      try {
        outlineTitles.value = JSON.parse(titlesData)
      } catch (e) {
        console.error('解析标题数据失败:', e)
        alert('标题数据格式错误')
        return
      }
    } else {
      outlineTitles.value = titlesData
    }

    // 检查是否返回了空数组
    if (!outlineTitles.value || outlineTitles.value.length === 0) {
      console.warn('AI返回了空的标题列表')
      alert('AI无法为当前主题和要求生成合适的标题，请尝试提供更具体的主题和内容要求')
      
      // 提供一些默认标题作为示例
      outlineTitles.value = [
        { order: 1, title: '引言与背景', description: '介绍主题背景和研究意义' },
        { order: 2, title: '相关概念与理论', description: '阐述相关的基本概念和理论基础' },
        { order: 3, title: '现状分析', description: '分析当前的发展现状和特点' },
        { order: 4, title: '案例研究', description: '具体案例的分析和讨论' },
        { order: 5, title: '问题与挑战', description: '存在的问题和面临的挑战' },
        { order: 6, title: '发展趋势与展望', description: '未来的发展趋势和前景' },
        { order: 7, title: '结论与建议', description: '总结主要观点并提出建议' }
      ]
    }

  } catch (error) {
    console.error('标题生成失败:', error)
    alert('标题生成失败，请稍后重试')
  }
}

// 删除标题
const removeTitle = (index) => {
  outlineTitles.value.splice(index, 1)
  // 重新调整序号
  outlineTitles.value.forEach((title, idx) => {
    title.order = idx + 1
  })
}

// 添加新标题
const addNewTitle = () => {
  const newTitle = {
    order: outlineTitles.value.length + 1,
    title: '',
    description: '新添加的标题'
  }
  outlineTitles.value.push(newTitle)
}

const generateContent = async () => {
  // 检查是否有大纲标题
  if (!outlineTitles.value || outlineTitles.value.length === 0) {
    alert('请先生成大纲标题后再生成全文')
    return
  }

  // 检查必要的信息
  if (!topic.value.trim()) {
    alert('请先输入主题')
    return
  }

  isGenerating.value = true
  generatedContent.value = '' // 清空之前的内容
  
  try {
    // 检查认证token
    const token = localStorage.getItem('token')
    if (!token) {
      alert('请先登录后再使用AI写作功能')
      return
    }
    console.log('使用token:', token ? '有效' : '无效')
    
    // 准备请求数据
    const requestData = {
      topic: topic.value,
      documentType: analysisResult.value?.documentType || '研究报告',
      outlineTitles: JSON.stringify(outlineTitles.value),
      contentRequirement: contentRequirement.value,
      estimatedWordCount: analysisResult.value?.estimatedWordCount || '3000-5000字',
      writingStyle: analysisResult.value?.writingStyle || '学术、专业'
    }

    console.log('发送全文生成请求:', requestData)
    console.log('当前大纲标题:', outlineTitles.value)
    
    // 显示当前使用的大纲结构
    const titlesList = outlineTitles.value.map(item => `${item.order}. ${item.title}`).join('\n')
    console.log('将按照以下大纲生成全文:\n' + titlesList)

    // 调用流式生成接口 - 手动添加认证token
    const response = await fetch('/api/ai-writing/generate-full-document', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      },
      body: JSON.stringify(requestData)
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    // 处理流式响应
    const reader = response.body.getReader()
    const decoder = new TextDecoder()

    console.log('开始接收流式响应...')

    while (true) {
      const { done, value } = await reader.read()
      
      if (done) {
        console.log('流式响应结束')
        break
      }
      
      // 解码数据块
      const chunk = decoder.decode(value, { stream: true })
      
      // 直接添加原始内容，不在流式过程中处理格式
      generatedContent.value += chunk
      
      // 实时滚动到底部
      requestAnimationFrame(() => {
        if (contentTextarea.value) {
          contentTextarea.value.scrollTop = contentTextarea.value.scrollHeight
        }
      })
      
      // 稍微延迟以显示流式效果
      await new Promise(resolve => setTimeout(resolve, 10))
    }

    console.log('全文生成完成')
    
    // 🎯 统一处理标题格式：将#标题转换为更突出的显示格式
    console.log('开始处理标题格式转换...')
    console.log('转换前的内容预览:', generatedContent.value.substring(0, 200) + '...')
    
    // 先清理开头和结尾的空白
    let content = generatedContent.value.trim()
    
    // 处理标题格式
    content = content
      // 处理一级标题 (# 标题) - 前面加空行，后面加空行
      .replace(/^#\s+(.*?)$/gm, '\n【 $1 】\n')         
      // 处理二级标题 (## 标题) - 前面加空行
      .replace(/^##\s+(.*?)$/gm, '\n▪ $1 ▪')           
      // 处理三级标题 (### 标题) - 前面加空行
      .replace(/^###\s+(.*?)$/gm, '\n◆ $1 ◆')
      // 清理开头的空行
      .replace(/^\n+/, '')
      // 清理多余的空行（最多保持两个连续换行）
      .replace(/\n{3,}/g, '\n\n')
    
    generatedContent.value = content
    
    console.log('转换后的内容预览:', generatedContent.value.substring(0, 200) + '...')
    console.log('标题格式转换完成')
    
    // 滚动到顶部，让用户看到完整的格式化结果
    requestAnimationFrame(() => {
      if (contentTextarea.value) {
        contentTextarea.value.scrollTop = 0
      }
    })
    
  } catch (error) {
    console.error('生成全文失败:', error)
    alert('生成全文失败，请稍后重试: ' + error.message)
    generatedContent.value = '生成失败，请重试'
  } finally {
    isGenerating.value = false
  }
}

// 更新字数统计
const updateWordCount = (event) => {
  // 从contenteditable元素中获取纯文本内容
  if (contentTextarea.value) {
    generatedContent.value = contentTextarea.value.innerText || contentTextarea.value.textContent || ''
  }
}

// 点击生成全文按钮时触发
const handleGenerateFullText = () => {
  generateContent()
}

onMounted(() => {
  console.log('✅ AI写作结果页面已就绪')
})
</script>

<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: "PingFang SC", "Microsoft YaHei", sans-serif;
}

.writing-result-container {
  height: 100vh;
  background: #f8f9fa;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

/* 顶部导航栏 */
.top-navigation {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  background: white;
  border-bottom: 1px solid #e5e5e5;
  position: relative;
  z-index: 1000;
}

/* 返回按钮样式 */
.back-button {
  display: flex;
  align-items: center;
  gap: 8px;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 8px 12px;
  color: #666;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 14px;
  font-weight: 500;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.back-button:hover {
  background: #f5f5f5;
  color: #333;
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

/* 页面标题 */
.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  text-align: center;
  flex: 1;
}

/* 导出下拉菜单 */
.export-dropdown {
  position: relative;
}

.export-button {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  color: #666;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s ease;
}

.export-button:hover {
  border-color: #4f46e5;
  color: #4f46e5;
}

.dropdown-arrow {
  transition: transform 0.3s ease;
}

.export-menu {
  position: absolute;
  top: 100%;
  right: 0;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  min-width: 120px;
  z-index: 1001;
  margin-top: 4px;
}

.export-option {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  cursor: pointer;
  font-size: 14px;
  color: #333;
  transition: background-color 0.2s ease;
}

.export-option:hover {
  background: #f8f9fa;
}

.export-option:first-child {
  border-radius: 8px 8px 0 0;
}

.export-option:last-child {
  border-radius: 0 0 8px 8px;
}

.export-icon {
  font-size: 16px;
}

.pdf-icon {
  color: #dc3545;
}

.word-icon {
  color: #0066cc;
}

.result-layout {
  display: flex;
  flex: 1;
  height: 0; /* 让flex子元素能够正确收缩 */
}

/* 左侧控制面板 */
.control-panel {
  width: 400px;
  background: white;
  border-right: 1px solid #e5e5e5;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid #f0f0f0;
}

.panel-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
}

.menu-icon {
  color: #666;
  cursor: pointer;
}

.requirement-section {
  padding: 24px;
  border-bottom: 1px solid #f0f0f0;
}

.requirement-item {
  margin-bottom: 20px;
}

.requirement-item:last-child {
  margin-bottom: 0;
}

.requirement-label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
}

.required-star {
  color: #dc3545;
  margin-right: 4px;
}

.requirement-content {
  font-size: 14px;
  color: #666;
  line-height: 1.5;
}

.topic-input {
  width: 100%;
  padding: 12px;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  font-size: 14px;
  color: #333;
  background: #f8f9fa;
  transition: all 0.3s ease;
}

.topic-input:focus {
  outline: none;
  border-color: #4f46e5;
  background: white;
  box-shadow: 0 0 0 2px rgba(79, 70, 229, 0.1);
}

.content-box {
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  padding: 12px;
  min-height: 80px;
}

/* 可编辑的内容要求样式 */
.editable-requirement {
  width: 100%;
  resize: vertical;
  font-family: inherit;
  font-size: 14px;
  color: #333;
  line-height: 1.5;
  transition: all 0.3s ease;
  border: 1px solid #e9ecef;
  outline: none;
}

.editable-requirement:focus {
  border-color: #4f46e5;
  background: white;
  box-shadow: 0 0 0 2px rgba(79, 70, 229, 0.1);
}

.editable-requirement::placeholder {
  color: #999;
}

.ai-section {
  padding: 20px 24px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  justify-content: center;
}

.ai-identify-button {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 20px;
  color: #666;
  cursor: pointer;
  font-size: 13px;
  font-weight: 500;
  transition: all 0.3s ease;
  min-width: auto;
}

.ai-identify-button:hover {
  border-color: #4f46e5;
  color: #4f46e5;
  background: #f8f9ff;
}

.ai-icon {
  font-size: 16px;
}

.outline-section {
  padding: 20px 24px;
  border-bottom: 1px solid #f0f0f0;
  flex: 1;
}

.outline-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.outline-header h4 {
  font-size: 14px;
  font-weight: 600;
  color: #333;
}

.ai-toggle {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.ai-toggle input {
  display: none;
}

.toggle-slider {
  width: 36px;
  height: 20px;
  background: #ddd;
  border-radius: 10px;
  position: relative;
  transition: all 0.3s ease;
}

.toggle-slider.active {
  background: #4f46e5;
}

.toggle-slider::before {
  content: '';
  position: absolute;
  top: 2px;
  left: 2px;
  width: 16px;
  height: 16px;
  background: white;
  border-radius: 50%;
  transition: all 0.3s ease;
}

.toggle-slider.active::before {
  left: 18px;
}

.toggle-label {
  font-size: 12px;
  color: #666;
}

/* 大纲列表样式 */
.outline-list {
  margin-top: 16px;
  margin-bottom: 16px;
}

.outline-item {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
  padding: 8px;
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.outline-item:hover {
  border-color: #4f46e5;
  background: #f0f4ff;
}

.outline-order {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  background: #4f46e5;
  color: white;
  border-radius: 50%;
  font-size: 12px;
  font-weight: 600;
  flex-shrink: 0;
}

.outline-title-input {
  flex: 1;
  padding: 6px 8px;
  border: 1px solid transparent;
  border-radius: 4px;
  font-size: 14px;
  color: #333;
  background: transparent;
  transition: all 0.3s ease;
}

.outline-title-input:focus {
  outline: none;
  border-color: #4f46e5;
  background: white;
  box-shadow: 0 0 0 2px rgba(79, 70, 229, 0.1);
}

.outline-delete-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
  background: #dc3545;
  color: white;
  border: none;
  border-radius: 50%;
  cursor: pointer;
  font-size: 14px;
  line-height: 1;
  transition: all 0.3s ease;
  flex-shrink: 0;
}

.outline-delete-btn:hover {
  background: #c82333;
  transform: scale(1.1);
}

.add-outline {
  margin-top: 16px;
}

.add-button {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: white;
  border: 1px dashed #d0d0d0;
  border-radius: 6px;
  color: #888;
  cursor: pointer;
  font-size: 14px;
  width: 100%;
  transition: all 0.3s ease;
}

.add-button:hover {
  border-color: #4f46e5;
  color: #4f46e5;
}

.generate-section {
  padding: 20px 24px;
}

.generate-full-button {
  width: 100%;
  padding: 12px 16px;
  background: #4f46e5;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-bottom: 16px;
}

.generate-full-button:hover:not(:disabled) {
  background: #4338ca;
  transform: translateY(-1px);
}

.generate-full-button:active:not(:disabled) {
  transform: translateY(0);
}

.generate-full-button:disabled {
  background: #9ca3af;
  cursor: not-allowed;
  transform: none;
}



/* 右侧文档区域 */
.document-area {
  flex: 1;
  background: white;
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 0; /* 允许flex子元素收缩 */
}




.document-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  position: relative;
  height: 100%;
  min-height: 0; /* 允许flex子元素收缩 */
}

.document-editor {
  flex: 1;
  padding: 0;
  overflow-y: auto;
  line-height: 1.8;
  font-size: 15px;
  color: #333;
  position: relative;
  height: 100%;
}

.generating-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 200px;
}

.typing-animation {
  display: flex;
  gap: 4px;
  margin-bottom: 16px;
}

.typing-animation span {
  width: 8px;
  height: 8px;
  background: #4f46e5;
  border-radius: 50%;
  animation: bounce 1.4s ease-in-out infinite;
}

.typing-animation span:nth-child(2) {
  animation-delay: 0.2s;
}

.typing-animation span:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes bounce {
  0%, 80%, 100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-10px);
  }
}

.generating-content p {
  color: #666;
  font-size: 14px;
}

.editable-content {
  width: 100%;
  height: 100%;
  border: none;
  outline: none;
  resize: none;
  padding: 20px;
  font-size: 16px;
  line-height: 1.6; /* 减少行高，让内容更紧凑 */
  color: #333;
  background: transparent;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif;
  font-weight: 400;
  letter-spacing: 0.3px;
  /* 使用等宽字体可以让特殊字符对齐更好 */
  font-variant-numeric: tabular-nums;
  /* 移除overflow，让父容器document-editor控制滚动 */
  overflow: visible;
  /* 确保内容可以滚动 */
  box-sizing: border-box;
  min-height: 100%;
}

/* 优化文本渲染，让标题更清晰 */
.editable-content {
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.editable-content::placeholder {
  color: #999;
  text-align: center;
  padding-top: 100px;
  font-size: 16px;
}

/* contenteditable特定样式 */
.editable-content.readonly {
  pointer-events: none;
  user-select: none;
}

/* 占位符样式 */
.placeholder {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: #999;
  font-size: 16px;
  pointer-events: none;
  z-index: 0;
  user-select: none;
}

/* 标题样式 - 真正的加大加粗效果，紧凑间距 */
.editable-content h1.title-level-1 {
  font-size: 24px;
  font-weight: 800;
  color: #1a1a1a;
  margin: 12px 0 4px 0; /* 减少间距：上12px 下4px */
  line-height: 1.3;
  text-shadow: 0 1px 2px rgba(0,0,0,0.1);
  display: block;
}

.editable-content h2.title-level-2 {
  font-size: 20px;
  font-weight: 700;
  color: #2c2c2c;
  margin: 10px 0 3px 0; /* 减少间距：上10px 下3px */
  line-height: 1.4;
  display: block;
}

.editable-content h3.title-level-3 {
  font-size: 18px;
  font-weight: 600;
  color: #404040;
  margin: 8px 0 2px 0; /* 减少间距：上8px 下2px */
  line-height: 1.4;
  display: block;
}

/* 段落样式 */
.editable-content p {
  margin: 0 0 12px 0; /* 段落之间的间距 */
  line-height: 1.6;
  text-align: justify; /* 两端对齐 */
}

.word-count {
  position: absolute;
  bottom: 20px;
  right: 30px;
  background: rgba(0, 0, 0, 0.6);
  color: white;
  padding: 6px 12px;
  border-radius: 16px;
  font-size: 12px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .result-layout {
    flex-direction: column;
  }
  
  .control-panel {
    width: 100%;
    height: 300px;
  }
  
  .document-editor {
    padding: 20px;
  }
}
</style>