<template>
  <div class="auto-exam-generator">
    <!-- 页面头部 -->
    <el-page-header @back="goBack" content="智能组卷">
      <template #icon><el-icon><ArrowLeft /></el-icon></template>
    </el-page-header>

    <!-- 课程信息卡片 -->
    <el-card class="course-info" shadow="never">
      <div class="course-header">
        <img :src="course.image || placeholder" alt="课程封面" class="course-cover" />
        <div class="course-details">
          <h2>{{ course.title || '课程名称' }}</h2>
          <p>{{ course.subtitle || '课程描述' }}</p>
          <el-tag type="primary" size="large">智能组卷</el-tag>
        </div>
      </div>
    </el-card>

    <!-- 组卷配置区域 -->
    <el-card class="config-card" shadow="never">
      <template #header>
        <div class="card-header">
          <h3>🎯 组卷配置</h3>
          <el-button type="primary" @click="showQuickConfig = !showQuickConfig">
            {{ showQuickConfig ? '隐藏' : '显示' }}快速配置
          </el-button>
        </div>
      </template>

      <el-form :model="examConfig" label-width="120px" class="config-form">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="试卷标题" required>
              <el-input v-model="examConfig.examTitle" placeholder="请输入试卷标题" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="总题数" required>
              <el-input-number 
                v-model="examConfig.totalQuestions" 
                :min="5" 
                :max="100" 
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="试卷描述">
          <el-input 
            v-model="examConfig.examDescription" 
            type="textarea" 
            :rows="3"
            placeholder="请输入试卷描述..."
          />
        </el-form-item>

        <!-- 题库选择 -->
        <el-form-item label="题库选择" required>
          <el-select 
            v-model="examConfig.categoryId" 
            placeholder="请选择题库分类" 
            style="width: 100%"
            @change="handleCategoryChange"
          >
            <el-option
              v-for="category in questionCategories"
              :key="category.id"
              :label="category.name"
              :value="category.id"
            >
              <span style="float: left">{{ category.name }}</span>
              <span style="float: right; color: #8492a6; font-size: 13px">
                {{ category.questionCount || 0 }}题
              </span>
            </el-option>
          </el-select>
        </el-form-item>

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

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="考试时长(分钟)">
              <el-input-number 
                v-model="examConfig.timeLimitMinutes" 
                :min="30" 
                :max="300" 
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="生成策略">
              <el-select v-model="examConfig.generationStrategy" style="width: 100%">
                <el-option label="AI智能组卷" value="AI智能组卷" />
                <el-option label="知识点均衡" value="知识点均衡" />
                <el-option label="难度递进" value="难度递进" />
                <el-option label="随机组卷" value="随机组卷" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <!-- 快速配置区域 -->
        <el-collapse v-model="showQuickConfig" class="quick-config">
          <el-collapse-item title="⚡ 快速配置" name="quick">
            <div class="quick-config-content">
              <el-row :gutter="20">
                <el-col :span="8">
                  <div class="config-item">
                    <label>选择题数量</label>
                    <el-input-number 
                      v-model="questionDistribution.choice" 
                      :min="0" 
                      :max="examConfig.totalQuestions"
                      controls-position="right"
                      style="width: 100%"
                    />
                  </div>
                </el-col>
                <el-col :span="8">
                  <div class="config-item">
                    <label>简答题数量</label>
                    <el-input-number 
                      v-model="questionDistribution.short_answer" 
                      :min="0" 
                      :max="examConfig.totalQuestions"
                      controls-position="right"
                      style="width: 100%"
                    />
                  </div>
                </el-col>
                <el-col :span="8">
                  <div class="config-item">
                    <label>编程题数量</label>
                    <el-input-number 
                      v-model="questionDistribution.programming" 
                      :min="0" 
                      :max="examConfig.totalQuestions"
                      controls-position="right"
                      style="width: 100%"
                    />
                  </div>
                </el-col>
              </el-row>

              <el-row :gutter="20" style="margin-top: 20px;">
                <el-col :span="8">
                  <div class="config-item">
                    <label>简单题比例</label>
                    <el-slider 
                      v-model="difficultyDistribution.easy" 
                      :min="0" 
                      :max="100" 
                      :step="5"
                      show-input
                      :format-tooltip="val => val + '%'"
                    />
                  </div>
                </el-col>
                <el-col :span="8">
                  <div class="config-item">
                    <label>中等题比例</label>
                    <el-slider 
                      v-model="difficultyDistribution.medium" 
                      :min="0" 
                      :max="100" 
                      :step="5"
                      show-input
                      :format-tooltip="val => val + '%'"
                    />
                  </div>
                </el-col>
                <el-col :span="8">
                  <div class="config-item">
                    <label>困难题比例</label>
                    <el-slider 
                      v-model="difficultyDistribution.hard" 
                      :min="0" 
                      :max="100" 
                      :step="5"
                      show-input
                      :format-tooltip="val => val + '%'"
                    />
                  </div>
                </el-col>
              </el-row>
            </div>
          </el-collapse-item>
        </el-collapse>

        <!-- 配置摘要 -->
        <div class="config-summary" v-if="examConfig.categoryId && selectedKnowledge.length > 0">
          <h4>📋 组卷配置摘要</h4>
          <div class="summary-content">
            <div class="summary-item">
              <span class="label">题库分类：</span>
              <span class="value">{{ getCategoryName(examConfig.categoryId) }}</span>
            </div>
            <div class="summary-item">
              <span class="label">知识点：</span>
              <span class="value">{{ selectedKnowledge.length }}个</span>
            </div>
            <div class="summary-item">
              <span class="label">题型分布：</span>
              <span class="value">选择题{{ questionDistribution.choice }}题，简答题{{ questionDistribution.short_answer }}题，编程题{{ questionDistribution.programming }}题</span>
            </div>
            <div class="summary-item">
              <span class="label">难度分布：</span>
              <span class="value">简单{{ difficultyDistribution.easy }}%，中等{{ difficultyDistribution.medium }}%，困难{{ difficultyDistribution.hard }}%</span>
            </div>
          </div>
        </div>

        <el-form-item>
          <el-button type="primary" size="large" @click="generateExam" :loading="generating">
            <el-icon><Star /></el-icon>
            智能组卷
          </el-button>
          <el-button size="large" @click="resetConfig">
            <el-icon><Refresh /></el-icon>
            重置配置
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 试卷预览区域 -->
    <el-card v-if="generatedExam" class="preview-card" shadow="never">
      <template #header>
        <div class="card-header">
          <h3>📋 试卷预览</h3>
          <div class="header-actions">
            <el-button type="success" @click="publishExam" :loading="publishing">
              <el-icon><Upload /></el-icon>
              发布试卷
            </el-button>
            <el-button @click="regenerateExam">
              <el-icon><Refresh /></el-icon>
              重新生成
            </el-button>
            <el-button @click="exportExam">
              <el-icon><Download /></el-icon>
              导出试卷
            </el-button>
          </div>
        </div>
      </template>

      <div class="exam-preview">
        <div class="exam-info">
          <h2>{{ generatedExam.examTitle }}</h2>
          <p>{{ generatedExam.examDescription }}</p>
          <div class="exam-meta">
            <el-tag type="info">总题数: {{ generatedExam.totalQuestions }}</el-tag>
            <el-tag type="warning">考试时长: {{ generatedExam.timeLimitMinutes }}分钟</el-tag>
            <el-tag type="success" v-if="generatedExam.qualityScore">
              质量评分: {{ generatedExam.qualityScore }}/100
            </el-tag>
            <el-tag :type="getStatusType(generatedExam.status)">
              {{ getStatusText(generatedExam.status) }}
            </el-tag>
          </div>
        </div>

        <div class="questions-list">
          <h4>📝 题目列表</h4>
          <div v-if="examQuestions && examQuestions.length > 0" class="questions">
            <div 
              v-for="(question, index) in examQuestions" 
              :key="question.id" 
              class="question-item"
            >
              <div class="question-header">
                <div class="question-number">
                  <span class="number">{{ index + 1 }}</span>
                  <span class="type">{{ getQuestionTypeName(question.type) }}</span>
                </div>
                <div class="question-meta">
                  <el-tag size="small" :type="getDifficultyType(question.difficultyLevel)">难度: {{ getDifficultyText(question.difficultyLevel) }}</el-tag>
                  <el-tag size="small" type="warning">预计: {{ question.estimatedTimeMinutes }}分钟</el-tag>
                </div>
              </div>
              <div class="question-content" v-html="formatQuestionContent(question.content)"></div>
              <div class="question-answer" v-if="question.answer">
                <strong>答案：</strong>
                <span>{{ question.answer }}</span>
              </div>
              <div class="question-footer">
                <div class="knowledge-point">
                  <strong>知识点：</strong>{{ question.knowledgePoint || '未指定' }}
                </div>
                <div class="ai-reason" v-if="question.aiSelectionReason">
                  <strong>AI选择原因：</strong>{{ question.aiSelectionReason }}
                </div>
                <div class="question-actions">
                  <el-button size="small" @click="replaceQuestion(question.id)">
                    <el-icon><Refresh /></el-icon>
                    替换
                  </el-button>
                  <el-button size="small" @click="adjustDifficulty(question.id)">
                    <el-icon><Edit /></el-icon>
                    调整难度
                  </el-button>
                </div>
              </div>
            </div>
          </div>
          <div v-else class="no-questions">
            <el-empty description="暂无题目" />
          </div>
        </div>
      </div>
    </el-card>

    <!-- 加载遮罩 -->
    <el-dialog v-model="loadingVisible" title="正在生成试卷" width="400px" :close-on-click-modal="false">
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
  Lightning, 
  Refresh, 
  Upload, 
  Download, 
  Edit,
  Loading
} from '@element-plus/icons-vue'
import { autoExamAPI } from '@/api/autoExam'
import axios from 'axios'

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

// 组卷配置
const examConfig = reactive({
  courseId: parseInt(course.id),
  teacherId: 1, // 从用户信息获取
  examTitle: '',
  examDescription: '',
  totalQuestions: 20,
  timeLimitMinutes: 90,
  generationStrategy: 'AI智能组卷',
  categoryId: null // 题库分类ID
})

// 题型分布
const questionDistribution = reactive({
  choice: 10,
  short_answer: 7,
  programming: 3
})

// 难度分布
const difficultyDistribution = reactive({
  easy: 20,
  medium: 50,
  hard: 30
})

// 状态管理
const generating = ref(false)
const publishing = ref(false)
const showQuickConfig = ref(false)
const loadingVisible = ref(false)
const loadingText = ref('正在生成试卷...')

// 生成的试卷
const generatedExam = ref(null)
const examQuestions = ref([])

// 知识点选择相关
const knowledgeOptions = ref([])
const selectedKnowledge = ref([]) // 存储选中的知识点ID数组

// 题库分类
const questionCategories = ref([])

// 知识选择相关 - 设置 checkStrictly: false 以支持父子节点关联
const cascaderProps = {
  emitPath: false,
  checkStrictly: false, // 设置为false以支持父子节点关联
  value: 'id',
  label: 'name',
  children: 'children',
  multiple: true, // 启用多选功能
  collapseTags: true
}

// 计算属性
const totalDistribution = computed(() => {
  return questionDistribution.choice + questionDistribution.short_answer + questionDistribution.programming
})

// 监听总题数变化，自动调整题型分布
const adjustQuestionDistribution = () => {
  const total = examConfig.totalQuestions
  const currentTotal = totalDistribution.value
  
  if (currentTotal !== total) {
    const ratio = total / currentTotal
    questionDistribution.choice = Math.round(questionDistribution.choice * ratio)
    questionDistribution.short_answer = Math.round(questionDistribution.short_answer * ratio)
    questionDistribution.programming = total - questionDistribution.choice - questionDistribution.short_answer
    
    // 确保编程题不为负数
    if (questionDistribution.programming < 0) {
      questionDistribution.programming = 0
      questionDistribution.short_answer = total - questionDistribution.choice
    }
  }
}

// 验证配置合理性
const validateConfig = () => {
  const total = totalDistribution.value
  const examTotal = examConfig.totalQuestions
  
  if (total !== examTotal) {
    ElMessage.warning(`题型分布总数(${total})与总题数(${examTotal})不匹配，正在自动调整...`)
    adjustQuestionDistribution()
    return false
  }
  
  // 检查难度分布总和是否为100
  const difficultyTotal = difficultyDistribution.easy + difficultyDistribution.medium + difficultyDistribution.hard
  if (Math.abs(difficultyTotal - 100) > 1) { // 允许1%的误差
    ElMessage.warning(`难度分布总和为${difficultyTotal}%，正在自动调整...`)
    const ratio = 100 / difficultyTotal
    difficultyDistribution.easy = Math.round(difficultyDistribution.easy * ratio)
    difficultyDistribution.medium = Math.round(difficultyDistribution.medium * ratio)
    difficultyDistribution.hard = 100 - difficultyDistribution.easy - difficultyDistribution.medium
  }
  
  return true
}

// 加载题库分类
const loadQuestionCategories = async () => {
  try {
    const response = await axios.get('/question-generator/categories', {
      params: { courseId: course.id }
    })
    
    // 兼容两种返回格式
    const data = Array.isArray(response.data) ? response.data : (response.data?.data || [])
    questionCategories.value = data || []
    
    // 如果没有选择分类且有可用分类，默认选择第一个
    if (!examConfig.categoryId && questionCategories.value.length > 0) {
      examConfig.categoryId = questionCategories.value[0].id
    }
    
    console.log('加载的题库分类:', questionCategories.value)
  } catch (error) {
    console.error('获取题库分类失败', error)
    ElMessage.error('获取题库分类失败: ' + error.message)
  }
}

// 题库分类变化处理
const handleCategoryChange = (categoryId) => {
  console.log('选择的题库分类ID:', categoryId)
  // 清空之前的知识点选择
  selectedKnowledge.value = []
  // 重新加载知识点选项
  loadKnowledgeOptions()
}

// 知识点选择相关方法
const loadKnowledgeOptions = async () => {
  try {
    const response = await axios.get(`/api/graph/course`, { 
      params: { courseId: course.id }
    })
    const knowledgeGraph = response.data
    
    console.log('获取到的知识图谱数据:', knowledgeGraph)
    
    // 转换数据结构 - 确保返回的数据包含章节和知识点层级
    const transformedData = transformKnowledgeTree(knowledgeGraph)
    
    console.log('转换后的知识点数据:', transformedData)
    
    // 设置级联选择器的数据
    knowledgeOptions.value = transformedData.children || []
    
    // 初始化选中状态
    selectedKnowledge.value = []
    
    console.log('最终的知识点选项:', knowledgeOptions.value)
    
  } catch (error) {
    console.error('获取知识图谱失败', error)
    ElMessage.error('获取知识点数据失败: ' + error.message)
  }
}

const transformKnowledgeTree = (node, parentChapter = '') => {
  // 如果是知识点节点（叶子节点）
  if (!node.children || node.children.length === 0) {
    return {
      id: node.id,
      name: node.name,
      leaf: true,
      chapter: parentChapter // 添加章节信息
    }
  } 
  // 如果是章节节点（有子节点）
  else {
    const currentChapter = node.name // 当前节点作为章节名
    return {
      id: node.id,
      name: node.name,
      children: node.children.map(child => transformKnowledgeTree(child, currentChapter))
    }
  }
}

const handleKnowledgeChange = (value) => {
  // value是一个数组，包含所有选中的节点ID
  console.log('当前选中的知识点ID:', value)
  selectedKnowledge.value = value // 直接更新选中的知识点ID数组
}

// 关键修改：当用户展开章节节点时，自动选中该章节下的所有知识点
const handleExpandChange = (node) => {
  // 只有当节点是章节节点（有子节点）时才处理
  if (node && node.children && node.children.length > 0) {
    // 获取该章节下的所有知识点ID
    const chapterId = node.id
    const chapter = findNodeById(knowledgeOptions.value, chapterId)
    
    if (chapter && chapter.children) {
      // 获取所有子知识点ID（递归查找）
      const knowledgeIds = getAllLeafIds(chapter)
      
      // 检查这些知识点是否已经被选中
      const currentlySelected = new Set(selectedKnowledge.value)
      const newSelections = knowledgeIds.filter(id => !currentlySelected.has(id))
      
      // 添加新选中的知识点
      if (newSelections.length > 0) {
        selectedKnowledge.value = [...selectedKnowledge.value, ...newSelections]
      }
    }
  }
}

// 辅助函数：根据ID查找节点
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

// 辅助函数：获取节点下的所有叶子节点ID（知识点ID）
const getAllLeafIds = (node) => {
  let ids = []
  if (!node.children || node.children.length === 0) {
    // 叶子节点（知识点）
    ids.push(node.id)
  } else {
    // 非叶子节点（章节），递归获取子节点的叶子节点ID
    node.children.forEach(child => {
      ids = ids.concat(getAllLeafIds(child))
    })
  }
  return ids
}

// 智能组卷
const generateExam = async () => {
  if (!examConfig.examTitle) {
    ElMessage.error('请输入试卷标题')
    return
  }

  if (!examConfig.categoryId) {
    ElMessage.error('请选择题库分类！')
    return
  }

  if (selectedKnowledge.value.length === 0) {
    ElMessage.error('请至少选择一个知识点！')
    return
  }

  // 验证配置合理性
  if (!validateConfig()) {
    return
  }

  generating.value = true
  loadingVisible.value = true
  loadingText.value = 'AI正在分析课程内容和知识点...'

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
      ...examConfig,
      questionDistribution: { ...questionDistribution },
      difficultyDistribution: {
        easy: difficultyDistribution.easy / 100,
        medium: difficultyDistribution.medium / 100,
        hard: difficultyDistribution.hard / 100
      },
      knowledgePointWeights: {},
      selectedKnowledgePoints: selectedKnowledgeNames, // 添加选中的知识点
      categoryId: examConfig.categoryId // 添加题库分类ID
    }

    loadingText.value = '正在生成试卷题目...'
    const response = await autoExamAPI.generateExam(requestData)
    
    if (response.data.code === 200) {
      generatedExam.value = response.data.data
      ElMessage.success('试卷生成成功，正在跳转预览...')
      // 生成成功后直接跳转到预览页面，传递预览数据
      router.push({ 
        name: 'AutoExamPreview', 
        query: { 
          preview: 'true',
          examData: encodeURIComponent(JSON.stringify(generatedExam.value))
        } 
      })
    } else {
      ElMessage.error('组卷失败：' + response.data.message)
    }
  } catch (error) {
    console.error('组卷失败:', error)
    ElMessage.error('组卷失败：' + (error.response?.data?.message || error.message))
  } finally {
    generating.value = false
    loadingVisible.value = false
  }
}

// 快速组卷
const quickGenerate = async () => {
  if (!examConfig.examTitle) {
    ElMessage.error('请输入试卷标题')
    return
  }

  if (!examConfig.categoryId) {
    ElMessage.error('请选择题库分类！')
    return
  }

  if (selectedKnowledge.value.length === 0) {
    ElMessage.error('请至少选择一个知识点！')
    return
  }

  // 验证配置合理性
  if (!validateConfig()) {
    return
  }

  generating.value = true
  loadingVisible.value = true
  loadingText.value = '正在快速生成试卷...'

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
      ...examConfig,
      questionDistribution: { ...questionDistribution },
      difficultyDistribution: {
        easy: difficultyDistribution.easy / 100,
        medium: difficultyDistribution.medium / 100,
        hard: difficultyDistribution.hard / 100
      },
      knowledgePointWeights: {},
      selectedKnowledgePoints: selectedKnowledgeNames,
      categoryId: examConfig.categoryId
    }

    loadingText.value = '正在从题库中筛选题目...'
    const response = await autoExamAPI.generateExam(requestData)
    
    if (response.data.code === 200) {
      generatedExam.value = response.data.data
      ElMessage.success('快速组卷成功，正在跳转预览...')
      router.push({ name: 'AutoExamPreview', query: { examId: generatedExam.value.id } })
    } else {
      ElMessage.error('快速组卷失败：' + response.data.message)
    }
  } catch (error) {
    console.error('快速组卷失败:', error)
    ElMessage.error('快速组卷失败：' + (error.response?.data?.message || error.message))
  } finally {
    generating.value = false
    loadingVisible.value = false
  }
}

// 加载试卷题目
const loadExamQuestions = async () => {
  if (!generatedExam.value) return

  try {
    const response = await autoExamAPI.previewExam(generatedExam.value.id)
    if (response.data.code === 200) {
      examQuestions.value = response.data.data.questions || []
    }
  } catch (error) {
    console.error('加载试卷题目失败:', error)
  }
}

// 发布试卷
const publishExam = async () => {
  if (!generatedExam.value) return

  try {
    await ElMessageBox.confirm('确定要发布这张试卷吗？发布后学生将可以看到并参加考试。', '确认发布', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    publishing.value = true
    const response = await autoExamAPI.publishExam(generatedExam.value.id)
    
    if (response.data.code === 200) {
      generatedExam.value.status = 'published'
      ElMessage.success('试卷发布成功！')
    } else {
      ElMessage.error('发布失败：' + response.data.message)
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('发布失败:', error)
      ElMessage.error('发布失败：' + (error.response?.data?.message || error.message))
    }
  } finally {
    publishing.value = false
  }
}

// 重新生成
const regenerateExam = () => {
  ElMessageBox.confirm('确定要重新生成试卷吗？当前试卷将被覆盖。', '确认重新生成', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    generatedExam.value = null
    examQuestions.value = []
    generateExam()
  }).catch(() => {})
}

// 导出试卷
const exportExam = () => {
  if (!generatedExam.value) return
  
  // 这里可以实现导出功能
  ElMessage.info('导出功能开发中...')
}

// 替换题目
const replaceQuestion = (questionId) => {
  ElMessage.info('替换题目功能开发中...')
}

// 调整难度
const adjustDifficulty = (questionId) => {
  ElMessage.info('调整难度功能开发中...')
}

// 获取题库分类名称
const getCategoryName = (categoryId) => {
  const category = questionCategories.value.find(cat => cat.id === categoryId)
  return category ? category.name : '未知分类'
}

// 重置配置
const resetConfig = () => {
  examConfig.examTitle = ''
  examConfig.examDescription = ''
  examConfig.totalQuestions = 20
  examConfig.timeLimitMinutes = 90
  examConfig.categoryId = questionCategories.value.length > 0 ? questionCategories.value[0].id : null
  questionDistribution.choice = 10
  questionDistribution.short_answer = 7
  questionDistribution.programming = 3
  difficultyDistribution.easy = 20
  difficultyDistribution.medium = 50
  difficultyDistribution.hard = 30
  selectedKnowledge.value = []
}

// 返回
const goBack = () => {
  router.push({ 
    name: 'DesignTools',
    query: {
      courseId: course.id,
      title: course.title,
      subtitle: course.subtitle,
      image: course.image
    }
  })
}

// 工具函数
const getQuestionTypeName = (type) => {
  const typeMap = {
    'choice': '选择题',
    'short_answer': '简答题',
    'programming': '编程题'
  }
  return typeMap[type] || type
}

const getStatusType = (status) => {
  const statusMap = {
    'draft': 'info',
    'generated': 'warning',
    'reviewed': 'primary',
    'published': 'success',
    'archived': 'info'
  }
  return statusMap[status] || 'info'
}

const getStatusText = (status) => {
  const statusMap = {
    'draft': '草稿',
    'generated': '已生成',
    'reviewed': '已审核',
    'published': '已发布',
    'archived': '已归档'
  }
  return statusMap[status] || status
}

const formatQuestionContent = (content) => {
  if (!content) return ''
  return content.replace(/\n/g, '<br>')
}

// 难度展示：不显示分数，展示中文
const getDifficultyText = (lv) => {
  if (typeof lv === 'number') {
    const map = { 1: '简单', 2: '中等', 3: '困难', 4: '较难', 5: '很难' }
    return map[lv] || '未知'
  }
  const map = { easy: '简单', medium: '中等', hard: '困难' }
  return map[lv] || '未知'
}

const getDifficultyType = (lv) => {
  if (typeof lv === 'number') {
    const map = { 1: 'success', 2: 'warning', 3: 'danger', 4: 'danger', 5: 'danger' }
    return map[lv] || 'info'
  }
  const map = { easy: 'success', medium: 'warning', hard: 'danger' }
  return map[lv] || 'info'
}

// 监听总题数变化
const unwatch = computed(() => {
  adjustQuestionDistribution()
  return examConfig.totalQuestions
})

onMounted(() => {
  // 初始化试卷标题
  if (course.title) {
    examConfig.examTitle = `${course.title} - 智能组卷`
  }
  
  // 加载题库分类和知识点数据
  loadQuestionCategories()
  loadKnowledgeOptions()
})
</script>

<style scoped>
.auto-exam-generator {
  width: 1100px;
  margin: 0 auto;
  padding: 20px;
}

/* 课程信息卡片 */
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
  border-radius: 8px;
  object-fit: cover;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.course-details h2 {
  margin: 0 0 8px 0;
  color: #1f2937;
  font-size: 24px;
}

.course-details p {
  margin: 0 0 12px 0;
  color: #6b7280;
  font-size: 16px;
}

/* 配置卡片 */
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

.quick-config {
  margin-top: 20px;
}

.quick-config-content {
  padding: 20px;
  background: #f8fafc;
  border-radius: 8px;
}

.config-item {
  margin-bottom: 16px;
}

.config-item label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #374151;
}

/* 预览卡片 */
.preview-card {
  border-radius: 12px;
  border: 1px solid #e5e7eb;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.exam-preview {
  margin-top: 20px;
}

.exam-info {
  margin-bottom: 30px;
  padding: 20px;
  background: #f8fafc;
  border-radius: 8px;
}

.exam-info h2 {
  margin: 0 0 8px 0;
  color: #1f2937;
  font-size: 28px;
}

.exam-info p {
  margin: 0 0 16px 0;
  color: #6b7280;
  font-size: 16px;
}

.exam-meta {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.questions-list h4 {
  margin: 0 0 20px 0;
  color: #1f2937;
  font-size: 20px;
}

.questions {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.question-item {
  padding: 20px;
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.question-item:hover {
  border-color: #3b82f6;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.1);
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.question-number {
  display: flex;
  align-items: center;
  gap: 12px;
}

.number {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: #3b82f6;
  color: white;
  border-radius: 50%;
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
}

.question-content {
  margin-bottom: 16px;
  line-height: 1.6;
  color: #1f2937;
}

.question-footer {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.knowledge-point,
.ai-reason {
  font-size: 14px;
  color: #6b7280;
}

.question-actions {
  display: flex;
  gap: 8px;
  margin-top: 12px;
}

.no-questions {
  text-align: center;
  padding: 40px;
}

/* 加载内容 */
.loading-content {
  text-align: center;
  padding: 20px;
}

.loading-content .el-icon {
  margin-bottom: 16px;
}

/* 配置摘要样式 */
.config-summary {
  margin: 20px 0;
  padding: 20px;
  background: linear-gradient(135deg, #f8fafc, #e2e8f0);
  border-radius: 12px;
  border: 1px solid #e2e8f0;
}

.config-summary h4 {
  margin: 0 0 16px 0;
  color: #1f2937;
  font-size: 16px;
  font-weight: 600;
}

.summary-content {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 12px;
}

.summary-item {
  display: flex;
  align-items: center;
  padding: 8px 12px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.summary-item .label {
  font-weight: 500;
  color: #6b7280;
  margin-right: 8px;
  min-width: 80px;
}

.summary-item .value {
  color: #1f2937;
  font-weight: 500;
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
}
</style>
