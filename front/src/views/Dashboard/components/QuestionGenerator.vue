<template>
  <div class="question-generator">
    <!-- 页面头部 -->
    <el-page-header @back="goBack" content="题目生成">
      <template #icon><el-icon><ArrowLeft /></el-icon></template>
    </el-page-header>

    <!-- 课程信息卡片 -->
    <el-card class="course-info" shadow="never">
      <div class="course-header">
        <img :src="course.image || placeholder" alt="课程封面" class="course-cover" />
        <div class="course-details">
          <h2>{{ course.title || '课程名称' }}</h2>
          <p>{{ course.subtitle || '课程描述' }}</p>
          <el-tag type="primary" size="large">AI题目生成</el-tag>
        </div>
      </div>
    </el-card>

    <!-- 题目生成配置 -->
    <el-card class="config-card" shadow="never">
      <template #header>
        <div class="card-header">
          <h3>🎯 题目生成配置</h3>
        </div>
      </template>

      <el-form :model="generationConfig" label-width="120px" class="config-form">
        <!-- 知识点选择 -->
        <el-form-item label="知识点选择" required>
          <el-cascader
            v-model="selectedKnowledge"
            :options="knowledgeOptions"
            :props="cascaderProps"
            placeholder="请选择章节/知识点"
            @change="handleKnowledgeChange"
            @expand-change="handleExpandChange"
            collapse-tags
            clearable
            :popper-append-to-body="true" 
            popper-class="custom-cascader"
            style="width: 100%"
          />
        </el-form-item>

        <!-- 题目数量 -->
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="题目数量" required>
              <el-input-number 
                v-model="generationConfig.questionCount" 
                :min="1" 
                :max="50" 
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="题库分类" required>
              <el-select v-model="generationConfig.categoryId" placeholder="选择题库分类" style="width: 100%">
                <el-option
                  v-for="category in questionCategories"
                  :key="category.id"
                  :label="category.name"
                  :value="category.id"
                >
                  <span style="float: left">{{ category.name }}</span>
                  <span style="float: right; color: #8492a6; font-size: 13px">{{ category.description }}</span>
                </el-option>
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <!-- 题型分布 -->
        <el-form-item label="题型分布">
          <div class="distribution-container">
            <div class="distribution-item">
              <label>选择题</label>
              <el-input-number 
                v-model="questionTypeDistribution.choice" 
                :min="0" 
                :max="generationConfig.questionCount"
                controls-position="right"
                style="width: 120px"
              />
            </div>
            <div class="distribution-item">
              <label>简答题</label>
              <el-input-number 
                v-model="questionTypeDistribution.short_answer" 
                :min="0" 
                :max="generationConfig.questionCount"
                controls-position="right"
                style="width: 120px"
              />
            </div>
            <div class="distribution-item">
              <label>编程题</label>
              <el-input-number 
                v-model="questionTypeDistribution.programming" 
                :min="0" 
                :max="generationConfig.questionCount"
                controls-position="right"
                style="width: 120px"
              />
            </div>
          </div>
        </el-form-item>

        <!-- 难度分布 -->
        <el-form-item label="难度分布">
          <div class="difficulty-container">
            <div class="difficulty-item">
              <label>简单</label>
              <el-slider
                v-model="difficultyDistribution.easy"
                :min="0"
                :max="100"
                :step="5"
                show-input
                :format-tooltip="formatTooltip"
                style="width: 200px"
              />
            </div>
            <div class="difficulty-item">
              <label>中等</label>
              <el-slider
                v-model="difficultyDistribution.medium"
                :min="0"
                :max="100"
                :step="5"
                show-input
                :format-tooltip="formatTooltip"
                style="width: 200px"
              />
            </div>
            <div class="difficulty-item">
              <label>困难</label>
              <el-slider
                v-model="difficultyDistribution.hard"
                :min="0"
                :max="100"
                :step="5"
                show-input
                :format-tooltip="formatTooltip"
                style="width: 200px"
              />
            </div>
          </div>
        </el-form-item>

        <!-- 生成按钮 -->
        <el-form-item>
          <el-button type="primary" @click="generateQuestions" :loading="generating" size="large">
            <el-icon><Star /></el-icon>
            生成题目
          </el-button>
          <el-button @click="resetConfig" size="large">
            <el-icon><Refresh /></el-icon>
            重置配置
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 生成的题目预览 -->
    <el-card v-if="generatedQuestions.length > 0" class="preview-card" shadow="never">
      <template #header>
        <div class="card-header">
          <h3>📝 生成的题目预览</h3>
          <div class="header-actions">
            <el-button type="success" @click="saveAllQuestions" :loading="saving">
              <el-icon><Download /></el-icon>
              保存全部题目
            </el-button>
            <el-button @click="regenerateQuestions">
              <el-icon><Refresh /></el-icon>
              重新生成
            </el-button>
          </div>
        </div>
      </template>

      <div class="questions-preview">
        <div class="generation-summary" v-if="generationSummary">
          <h4>生成摘要</h4>
          <div class="summary-stats">
            <el-tag type="info">总题目数: {{ generationSummary.totalQuestions }}</el-tag>
            <el-tag type="success">选择题: {{ generationSummary.typeDistribution?.choice || 0 }}</el-tag>
            <el-tag type="warning">简答题: {{ generationSummary.typeDistribution?.short_answer || 0 }}</el-tag>
            <el-tag type="danger">编程题: {{ generationSummary.typeDistribution?.programming || 0 }}</el-tag>
          </div>
        </div>

        <div class="questions-list">
          <div 
            v-for="(question, index) in generatedQuestions" 
            :key="index" 
            class="question-item"
          >
            <div class="question-header">
              <div class="question-number">
                <span class="number">{{ index + 1 }}</span>
                <span class="type">{{ getQuestionTypeName(question.type) }}</span>
              </div>
              <div class="question-meta">
                <el-tag :type="getDifficultyType(question.difficultyLevel)" size="small">
                  {{ getDifficultyText(question.difficultyLevel) }}
                </el-tag>
                <el-tag size="small" type="info">{{ question.estimatedTimeMinutes }}分钟</el-tag>
                <el-tag size="small" type="warning" v-if="question.qualityScore">
                  质量: {{ question.qualityScore }}/100
                </el-tag>
              </div>
            </div>
            
            <div class="question-content" v-html="formatQuestionContent(question.content)"></div>
            
            <div class="question-answer" v-if="question.answer">
              <strong>答案：</strong>{{ question.answer }}
            </div>
            
            <div class="question-options" v-if="question.options && question.options.length > 0">
              <div class="options-list">
                <div 
                  v-for="(option, optIndex) in question.options" 
                  :key="optIndex"
                  class="option-item"
                >
                  {{ String.fromCharCode(65 + optIndex) }}. {{ option }}
                </div>
              </div>
            </div>
            
            <div class="question-footer">
              <div class="knowledge-point">
                <strong>知识点：</strong>{{ question.knowledgePoint || '未指定' }}
              </div>
              <div class="question-tags" v-if="question.tags">
                <strong>标签：</strong>{{ question.tags }}
              </div>
              <div class="question-actions">
                <el-button size="small" @click="editQuestion(question, index)">
                  <el-icon><Edit /></el-icon>
                  编辑
                </el-button>
                <el-button size="small" @click="deleteQuestion(index)">
                  <el-icon><Delete /></el-icon>
                  删除
                </el-button>
                <el-button size="small" type="success" @click="saveSingleQuestion(question)">
                  <el-icon><Download /></el-icon>
                  保存
                </el-button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 加载遮罩 -->
    <el-dialog v-model="loadingVisible" title="正在生成题目" width="400px" :close-on-click-modal="false">
      <div class="loading-content">
        <el-icon class="is-loading" size="24"><Loading /></el-icon>
        <p>{{ loadingText }}</p>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  ArrowLeft, 
  Star, 
  Refresh, 
  Download, 
  Edit,
  Delete,
  Loading
} from '@element-plus/icons-vue'
import axios from 'axios'
import { useGeneratedQuestionsStore } from '@/store/generatedQuestions.js'

const route = useRoute()
const router = useRouter()

// 课程信息
const course = reactive({
  id: route.query.courseId,
  title: decodeURIComponent(route.query.title || ''),
  subtitle: decodeURIComponent(route.query.subtitle || ''),
  image: route.query.image
})

const placeholder = 'https://dummyimage.com/240x180/edf2ff/1e293b&text=Course'

// 生成配置
const generationConfig = reactive({
  courseId: parseInt(course.id),
  teacherId: 1, // 从用户信息获取
  questionCount: 10,
  categoryId: null
})

// 知识点选择相关
const knowledgeOptions = ref([])
const selectedKnowledge = ref([])

const cascaderProps = {
  emitPath: false,
  checkStrictly: false,
  value: 'id',
  label: 'name',
  children: 'children',
  multiple: true,
  collapseTags: true
}

// 题型分布
const questionTypeDistribution = reactive({
  choice: 5,
  short_answer: 3,
  programming: 2
})

// 难度分布
const difficultyDistribution = reactive({
  easy: 20,
  medium: 50,
  hard: 30
})

// 题库分类
const questionCategories = ref([])

// 状态管理
const generating = ref(false)
const saving = ref(false)
const loadingVisible = ref(false)
const loadingText = ref('正在生成题目...')

// 生成的题目
const generatedQuestions = ref([])
const generationSummary = ref(null)
const genStore = useGeneratedQuestionsStore()

// 计算属性
const totalDistribution = computed(() => {
  return questionTypeDistribution.choice + questionTypeDistribution.short_answer + questionTypeDistribution.programming
})

// 知识点选择相关方法
const loadKnowledgeOptions = async () => {
  try {
    const response = await axios.get(`/api/graph/course`, { 
      params: { courseId: course.id }
    })
    const knowledgeGraph = response.data
    
    console.log('获取到的知识图谱数据:', knowledgeGraph)
    
    const transformedData = transformKnowledgeTree(knowledgeGraph)
    knowledgeOptions.value = transformedData.children || []
    selectedKnowledge.value = []
    
    console.log('最终的知识点选项:', knowledgeOptions.value)
    
  } catch (error) {
    console.error('获取知识图谱失败', error)
    ElMessage.error('获取知识点数据失败: ' + error.message)
  }
}

const transformKnowledgeTree = (node, parentChapter = '') => {
  if (!node.children || node.children.length === 0) {
    return {
      id: node.id,
      name: node.name,
      leaf: true,
      chapter: parentChapter
    }
  } else {
    const currentChapter = node.name
    return {
      id: node.id,
      name: node.name,
      children: node.children.map(child => transformKnowledgeTree(child, currentChapter))
    }
  }
}

const handleKnowledgeChange = (value) => {
  console.log('当前选中的知识点ID:', value)
  selectedKnowledge.value = value
}

const handleExpandChange = (node) => {
  if (node && node.children && node.children.length > 0) {
    const chapterId = node.id
    const chapter = findNodeById(knowledgeOptions.value, chapterId)
    
    if (chapter && chapter.children) {
      const knowledgeIds = getAllLeafIds(chapter)
      const currentlySelected = new Set(selectedKnowledge.value)
      const newSelections = knowledgeIds.filter(id => !currentlySelected.has(id))
      
      if (newSelections.length > 0) {
        selectedKnowledge.value = [...selectedKnowledge.value, ...newSelections]
      }
    }
  }
}

const findNodeById = (options, id) => {
  for (const option of options) {
    if (option.id === id) return option
    if (option.children) {
      const found = findNodeById(option.children, id)
      if (found) return found
    }
  }
  return null
}

const getAllLeafIds = (node) => {
  let ids = []
  if (!node.children || node.children.length === 0) {
    ids.push(node.id)
  } else {
    node.children.forEach(child => {
      ids = ids.concat(getAllLeafIds(child))
    })
  }
  return ids
}

// 加载题库分类
const loadQuestionCategories = async () => {
  try {
    const response = await axios.get('/question-generator/categories')
    if (response.data.code === 200) {
      questionCategories.value = response.data.data
    }
  } catch (error) {
    console.error('获取题库分类失败', error)
    ElMessage.error('获取题库分类失败')
  }
}

// 生成题目
const generateQuestions = async () => {
  if (selectedKnowledge.value.length === 0) {
    ElMessage.error('请至少选择一个知识点！')
    return
  }

  if (!generationConfig.categoryId) {
    ElMessage.error('请选择题库分类！')
    return
  }

  if (totalDistribution.value !== generationConfig.questionCount) {
    ElMessage.warning('题型分布总数与总题数不匹配，正在自动调整...')
    adjustQuestionDistribution()
  }

  generating.value = true
  loadingVisible.value = true
  loadingText.value = 'AI正在分析知识点并生成题目...'

  try {
    // 获取选中的知识点名称
    const selectedKnowledgeNames = selectedKnowledge.value.map((id) => {
      const findKnowledgeName = (options, targetId) => {
        for (const option of options) {
          if (option.id === targetId) {
            return option.name
          }
          if (option.children) {
            const found = findKnowledgeName(option.children, targetId)
            if (found) return found
          }
        }
        return null
      }
      return findKnowledgeName(knowledgeOptions.value, id)
    }).filter(Boolean)

    const requestData = {
      courseId: generationConfig.courseId,
      knowledgePoints: selectedKnowledgeNames,
      questionCount: generationConfig.questionCount,
      questionTypeDistribution: { ...questionTypeDistribution },
      difficultyDistribution: {
        easy: difficultyDistribution.easy / 100,
        medium: difficultyDistribution.medium / 100,
        hard: difficultyDistribution.hard / 100
      },
      categoryId: generationConfig.categoryId,
      teacherId: generationConfig.teacherId
    }

    loadingText.value = '正在生成题目...'
    const response = await axios.post('/question-generator/generate', requestData)
    
    if (response.data.code === 200) {
      generatedQuestions.value = response.data.data
      // 将结果存入全局 store 并跳转新页面展示
      genStore.setAll(generatedQuestions.value, { courseId: generationConfig.courseId, categoryId: generationConfig.categoryId })
      router.push({ name: 'GeneratedQuestionsView', query: { courseId: generationConfig.courseId, categoryId: generationConfig.categoryId } })
      ElMessage.success('题目生成成功！')
    } else {
      ElMessage.error('题目生成失败：' + response.data.message)
    }
  } catch (error) {
    console.error('题目生成失败:', error)
    ElMessage.error('题目生成失败：' + (error.response?.data?.message || error.message))
  } finally {
    generating.value = false
    loadingVisible.value = false
  }
}

// 调整题型分布
const adjustQuestionDistribution = () => {
  const total = generationConfig.questionCount
  const currentTotal = totalDistribution.value
  
  if (currentTotal !== total) {
    const ratio = total / currentTotal
    questionTypeDistribution.choice = Math.round(questionTypeDistribution.choice * ratio)
    questionTypeDistribution.short_answer = Math.round(questionTypeDistribution.short_answer * ratio)
    questionTypeDistribution.programming = total - questionTypeDistribution.choice - questionTypeDistribution.short_answer
  }
}

// 保存全部题目
const saveAllQuestions = async () => {
  if (generatedQuestions.value.length === 0) {
    ElMessage.warning('没有题目可保存')
    return
  }

  try {
    await ElMessageBox.confirm('确定要保存所有生成的题目到题库吗？', '确认保存', {
      type: 'warning'
    })

    saving.value = true
    const response = await axios.post('/question-generator/save', {
      questions: generatedQuestions.value,
      categoryId: generationConfig.categoryId
    })

    if (response.data.code === 200) {
      ElMessage.success(response.data.data)
    } else {
      ElMessage.error('保存失败：' + response.data.message)
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('保存题目失败:', error)
      ElMessage.error('保存题目失败：' + (error.response?.data?.message || error.message))
    }
  } finally {
    saving.value = false
  }
}

// 保存单个题目
const saveSingleQuestion = async (question) => {
  try {
    const response = await axios.post('/question-generator/save', {
      questions: [question],
      categoryId: generationConfig.categoryId
    })

    if (response.data.code === 200) {
      ElMessage.success('题目保存成功')
    } else {
      ElMessage.error('保存失败：' + response.data.message)
    }
  } catch (error) {
    console.error('保存单个题目失败:', error)
    ElMessage.error('保存失败：' + (error.response?.data?.message || error.message))
  }
}

// 编辑题目
const editQuestion = (question, index) => {
  // 实现编辑功能
  ElMessage.info('编辑功能开发中...')
}

// 删除题目
const deleteQuestion = (index) => {
  generatedQuestions.value.splice(index, 1)
  ElMessage.success('题目已删除')
}

// 重新生成
const regenerateQuestions = () => {
  generatedQuestions.value = []
  generationSummary.value = null
  generateQuestions()
}

// 重置配置
const resetConfig = () => {
  generationConfig.questionCount = 10
  generationConfig.categoryId = null
  selectedKnowledge.value = []
  questionTypeDistribution.choice = 5
  questionTypeDistribution.short_answer = 3
  questionTypeDistribution.programming = 2
  difficultyDistribution.easy = 20
  difficultyDistribution.medium = 50
  difficultyDistribution.hard = 30
  generatedQuestions.value = []
  generationSummary.value = null
}

// 工具方法
const formatTooltip = (val) => `${val}%`

const getQuestionTypeName = (type) => {
  const typeMap = {
    'choice': '选择题',
    'short_answer': '简答题',
    'programming': '编程题'
  }
  return typeMap[type] || type
}

const getDifficultyType = (level) => {
  const typeMap = {
    'easy': 'success',
    'medium': 'warning',
    'hard': 'danger'
  }
  return typeMap[level] || 'info'
}

const getDifficultyText = (level) => {
  const textMap = {
    'easy': '简单',
    'medium': '中等',
    'hard': '困难'
  }
  return textMap[level] || level
}

const formatQuestionContent = (content) => {
  if (!content) return ''
  return content.replace(/\n/g, '<br>')
}

const goBack = () => {
  router.go(-1)
}

onMounted(() => {
  loadKnowledgeOptions()
  loadQuestionCategories()
  // 若从题库分类页跳转，预选分类
  if (route.query.categoryId) {
    const cid = parseInt(route.query.categoryId)
    if (!Number.isNaN(cid)) generationConfig.categoryId = cid
  }
  // 若缺少标题/封面，从后端补全课程信息
  if (!course.title || !course.image) {
    loadCourseInfo()
  }
})

// 根据 courseId 加载课程信息（用于从其它页面跳转时补全标题/封面）
async function loadCourseInfo() {
  try {
    if (!course.id) return
    const res = await axios.get('/xiaozhi/teacher/course', { params: { id: course.id } })
    const data = res.data?.data
    if (data) {
      course.title = data.courseName || course.title
      course.subtitle = data.description || course.subtitle
      course.image = data.courseImage || course.image
    }
  } catch (e) { /* 忽略失败，保留占位 */ }
}
</script>

<style scoped>
.question-generator {
  width: 1100px;
  margin: 0 auto;
  padding: 20px;
}

.course-info {
  margin-bottom: 20px;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
}

.course-header {
  display: flex;
  align-items: center;
  gap: 20px;
}

.course-cover {
  width: 120px;
  height: 90px;
  object-fit: cover;
  border-radius: 8px;
}

.course-details h2 {
  margin: 0 0 8px 0;
  font-size: 24px;
  color: #1f2937;
}

.course-details p {
  margin: 0 0 12px 0;
  color: #6b7280;
  font-size: 14px;
}

.config-card {
  margin-bottom: 20px;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.config-form {
  margin-top: 20px;
}

.distribution-container {
  display: flex;
  gap: 30px;
  flex-wrap: wrap;
}

.distribution-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.distribution-item label {
  font-weight: 500;
  color: #374151;
}

.difficulty-container {
  display: flex;
  gap: 40px;
  flex-wrap: wrap;
}

.difficulty-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.difficulty-item label {
  font-weight: 500;
  color: #374151;
  min-width: 60px;
}

.preview-card {
  border-radius: 12px;
  border: 1px solid #e5e7eb;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.questions-preview {
  margin-top: 20px;
}

.generation-summary {
  margin-bottom: 30px;
  padding: 20px;
  background: #f8fafc;
  border-radius: 8px;
}

.generation-summary h4 {
  margin: 0 0 15px 0;
  color: #1f2937;
}

.summary-stats {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.questions-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.question-item {
  padding: 20px;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  background: #ffffff;
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.question-number {
  display: flex;
  align-items: center;
  gap: 12px;
}

.number {
  width: 32px;
  height: 32px;
  background: #3b82f6;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 14px;
}

.type {
  font-weight: 500;
  color: #374151;
}

.question-meta {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.question-content {
  margin-bottom: 15px;
  line-height: 1.6;
  color: #1f2937;
}

.question-answer {
  margin-bottom: 15px;
  padding: 12px;
  background: #f0f9ff;
  border-left: 4px solid #3b82f6;
  border-radius: 4px;
  color: #1e40af;
}

.question-options {
  margin-bottom: 15px;
}

.options-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.option-item {
  padding: 8px 12px;
  background: #f8fafc;
  border-radius: 4px;
  color: #374151;
}

.question-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
  padding-top: 15px;
  border-top: 1px solid #e5e7eb;
}

.knowledge-point, .question-tags {
  font-size: 14px;
  color: #6b7280;
}

.question-actions {
  display: flex;
  gap: 8px;
}

.loading-content {
  text-align: center;
  padding: 20px;
}

.loading-content .el-icon {
  margin-bottom: 16px;
}

/* 级联选择器样式 */
:deep(.el-cascader) {
  width: 100%;
}

:deep(.el-cascader .el-input__wrapper) {
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  border: 1px solid #e0e0e0;
}

:deep(.el-cascader .el-input__inner) {
  border: none;
  outline: none;
  padding-left: 15px;
}

.custom-cascader .el-cascader-menu {
  min-width: 300px;
  max-height: 400px;
  overflow-y: auto;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .course-header {
    flex-direction: column;
    text-align: center;
  }
  
  .header-actions {
    flex-direction: column;
  }
  
  .question-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .question-meta {
    align-self: flex-end;
  }
  
  .distribution-container,
  .difficulty-container {
    flex-direction: column;
    gap: 20px;
  }
}
</style>
