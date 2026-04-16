<template>
  <div class="ai-practice-container">
    <!-- 顶部导航区域 -->
    <div class="top-bar">
      <div class="back-button">
        <i class="icon-back" @click="goback">←</i>
      </div>
      <div class="title-container">
        <h1 class="title">AI·陪练</h1>
      </div>
      <div class="history-button">
        <button class="btn-history" @click="handleHistory">
          <i class="icon-history">📋</i> 历史练习
        </button>
      </div>
    </div>

    <!-- 主内容区域 -->
    <div class="main-content">
      <!-- 训练范围区域 -->
      <div class="training-scope">
        <div class="scope-title">训练范围：</div>
        
        <div class="selector-group">
          <!-- 课程选择 -->
          <div class="selector-item">
            <div class="selector-label">
              <span class="required-dot">*</span>
              <span>课程选择：</span>
            </div>
            <el-select v-model="courseValue" placeholder="请选择" @change="handleCourseChange" style="width: 250px;">
              <el-option
                label="嵌入式进阶"
                :value="101">
              </el-option>
            </el-select>
          </div>
          
          <!-- 知识选择 -->
             <div class="selector-item">
            <div class="selector-label">
              <span>知识选择：</span>
            </div>
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
            ></el-cascader>
          </div>
        </div>
      </div>
      
      <!-- 功能选项区域 -->
      <div class="function-options">
        <!-- 训练薄弱题 -->
        <div class="function-card green-card" @click="handleWeakQuestion">
          <div class="card-icon">
            <div class="icon-wrapper green">
              <svg viewBox="0 0 24 24" width="40" height="40">
                <path fill="currentColor" d="M14,2H6C4.9,2,4,2.9,4,4V20C4,21.1,4.9,22,6,22H18C19.1,22,20,21.1,20,20V8L14,2M18,20H6V4H13V9H18V20Z"></path>
              </svg>
            </div>
          </div>
          <h3 class="card-title">训练薄弱题</h3>
          <p class="card-description">
            AI陪练根据您选择的范围会帮您训练薄弱题，巩固基础，突破难点。
          </p>
        </div>
        
        <!-- AI自动出题 -->
        <div class="function-card pink-card" @click="handleAIPractice">
          <div class="card-icon">
            <div class="icon-wrapper pink">
              <svg viewBox="0 0 24 24" width="40" height="40">
                <path fill="currentColor" d="M19,3H5A2,2 0 0,0 3,5V19A2,2 0 0,0 5,21H19A2,2 0 0,0 21,19V5A2,2 0 0,0 19,3M19,19H5V5H19V19M13.07,9.54L11.09,12.04L13.75,14.7L16.67,11.04L19,13.5L13.07,19.5L10.67,16.5L8.31,18.96L5.39,16.27L7.05,13.81L4.12,11.04L6.68,10.72L8.12,8.37L9.56,10.72L12.88,4.78L13.07,9.54Z"></path>
              </svg>
            </div>
          </div>
          <h3 class="card-title">AI自动出题</h3>
          <p class="card-description">
            根据您选择的训练范围，AI陪练会生成个性化的练习内容，帮助巩固基础，突破难点。
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { ElSelect, ElOption, ElCascader, ElMessage } from 'element-plus';
import { useRouter } from 'vue-router';
import axios from 'axios';
import { useUserStore } from '@/store/user.js'

const router = useRouter();
const studentName = ref('张政'); // TODO: 实际项目应从用户信息获取

const courseValue = ref(101); // 默认用数字
const knowledgeOptions = ref([]);
const selectedKnowledge = ref([]); // 存储选中的知识点ID数组

// 知识选择相关 - 关键修改：设置 checkStrictly: false 以支持父子节点关联
const cascaderProps = {
  emitPath: false,
  checkStrictly: false, // 设置为false以支持父子节点关联
  value: 'id',
  label: 'name',
  children: 'children',
  multiple: true, // 启用多选功能
  collapseTags: true
};

const handleCourseChange = async (courseId) => {
  try {
    const response = await axios.get(`/api/graph/course`, { 
      params: { courseId: 101 } // 使用传入的courseId
    });
    const knowledgeGraph = response.data;
    
    // 转换数据结构 - 确保返回的数据包含章节和知识点层级
    const transformedData = transformKnowledgeTree(knowledgeGraph);
    
    // 设置级联选择器的数据
    knowledgeOptions.value = transformedData.children || [];
    
    // 初始化选中状态
    selectedKnowledge.value = [];
    
  } catch (error) {
    console.error('获取知识图谱失败', error);
  }
};

const transformKnowledgeTree = (node, parentChapter = '') => {
  // 如果是知识点节点（叶子节点）
  if (!node.children || node.children.length === 0) {
    return {
      id: node.id,
      name: node.name,
      leaf: true,
      chapter: parentChapter // 添加章节信息
    };
  } 
  // 如果是章节节点（有子节点）
  else {
    const currentChapter = node.name; // 当前节点作为章节名
    return {
      id: node.id,
      name: node.name,
      children: node.children.map(child => transformKnowledgeTree(child, currentChapter))
    };
  }
};

const handleKnowledgeChange = (value) => {
  // value是一个数组，包含所有选中的节点ID
  console.log('当前选中的知识点ID:', value);
  selectedKnowledge.value = value; // 直接更新选中的知识点ID数组
};

// 关键修改：当用户展开章节节点时，自动选中该章节下的所有知识点
const handleExpandChange = (node) => {
  // 只有当节点是章节节点（有子节点）时才处理
  if (node && node.children && node.children.length > 0) {
    // 获取该章节下的所有知识点ID
    const chapterId = node.id;
    const chapter = findNodeById(knowledgeOptions.value, chapterId);
    
    if (chapter && chapter.children) {
      // 获取所有子知识点ID（递归查找）
      const knowledgeIds = getAllLeafIds(chapter);
      
      // 检查这些知识点是否已经被选中
      const currentlySelected = new Set(selectedKnowledge.value);
      const newSelections = knowledgeIds.filter(id => !currentlySelected.has(id));
      
      // 添加新选中的知识点
      if (newSelections.length > 0) {
        selectedKnowledge.value = [...selectedKnowledge.value, ...newSelections];
      }
    }
  }
};

// 辅助函数：根据ID查找节点
const findNodeById = (options, id) => {
  for (const option of options) {
    if (option.id === id) return option;
    if (option.children) {
      const found = findNodeById(option.children, id);
      if (found) return found;
    }
  }
  return null;
};

// 辅助函数：获取节点下的所有叶子节点ID（知识点ID）
const getAllLeafIds = (node) => {
  let ids = [];
  if (!node.children || node.children.length === 0) {
    // 叶子节点（知识点）
    ids.push(node.id);
  } else {
    // 非叶子节点（章节），递归获取子节点的叶子节点ID
    node.children.forEach(child => {
      ids = ids.concat(getAllLeafIds(child));
    });
  }
  return ids;
};

// 返回按钮功能
const goback = () => {
  router.push("/study_space");
};

// 历史练习按钮功能
const handleHistory = () => {
  // 跳转到历史练习记录页面
  router.push('/practice_history');
};

// 训练薄弱题点击事件
const handleWeakQuestion = async () => {
  if (!courseValue.value) {
    ElMessage.error('请先选择课程！');
    return;
  }
  
  try {
    // 获取薄弱知识点数据
    const res = await axios.get('/api/xiaozhi/student/weakPointsRanking', {
      params: {
        studentId: useUserStore().currentUserId, // TODO: 实际项目应从用户信息获取
        courseId: Number(courseValue.value),
        limit: 10
      }
    });
    
    const weakPoints = (res.data.data || []).filter(item => !!item.knowledgePoint);
    
    if (weakPoints.length === 0) {
      ElMessage.warning('当前课程暂无薄弱知识点数据，请先进行一些练习！');
      return;
    }
    
    // 跳转到薄弱题训练页面
    router.push({
      path: '/weak_point_practice',
      query: {
        courseId: courseValue.value,
        courseName: '嵌入式进阶', // TODO: 根据实际课程名称获取
        studentName: studentName.value,
        weakPoints: JSON.stringify(weakPoints)
      }
    });
    
  } catch (error) {
    console.error('获取薄弱知识点失败', error);
    ElMessage.error('获取薄弱知识点失败，请稍后重试！');
  }
};

const handleAIPractice = () => {
  if (!courseValue.value) {
    ElMessage.error("请先选择课程！");
    return;
  }
  if (selectedKnowledge.value.length === 0) {
    ElMessage.error("请至少选择一个知识点！");
    return;
  }

  // 获取选中的知识点名称
  const selectedKnowledgeNames = selectedKnowledge.value.map((id) => {
    // 在 `knowledgeOptions` 中查找对应的知识点名称
    const findKnowledgeName = (options, targetId) => {
      for (const option of options) {
        if (option.id === targetId) {
          return option.name; // 返回知识点名称
        }
        if (option.children) {
          const found = findKnowledgeName(option.children, targetId);
          if (found) return found;
        }
      }
      return null;
    };

    return findKnowledgeName(knowledgeOptions.value, id);
  }).filter(Boolean); // 过滤掉未找到的情况

  // 构建传递的数据格式：从知识图谱中提取章节信息
  const formattedKnowledgeNames = selectedKnowledgeNames.map(name => {
    // 在知识图谱中查找对应的节点，获取章节信息
    const findNodeInfo = (options, targetName) => {
      for (const option of options) {
        if (option.name === targetName) {
          // 找到节点，判断是章节还是知识点
          if (option.children && option.children.length > 0) {
            // 这是章节节点，直接使用节点名称作为章节
            return {
              name: option.name,
              chapter: option.name
            };
          } else {
            // 这是知识点节点，使用其章节信息
            return {
              name: option.name,
              chapter: option.chapter || '未知章节'
            };
          }
        }
        if (option.children) {
          const found = findNodeInfo(option.children, targetName);
          if (found) {
            return found;
          }
        }
      }
      return null;
    };

    const nodeInfo = findNodeInfo(knowledgeOptions.value, name);
    if (nodeInfo) {
      return `${nodeInfo.chapter}/${nodeInfo.name}`;
    } else {
      // 如果找不到章节信息，使用默认格式
      return `综合知识点/${name}`;
    }
  });

  // 跳转并传递参数
  console.log('原始知识点名称:', selectedKnowledgeNames);
  console.log('传递的知识点数据:', formattedKnowledgeNames);
  router.push({
    path: "/ai_practice_2",
    query: {
      courseId: courseValue.value,       // 课程编号
      knowledgeNames: formattedKnowledgeNames.join(","), // 格式化的知识点名称数组转字符串
    },
  });
};



onMounted(() => {
  handleCourseChange(courseValue.value);
});
</script>

<style scoped>
:root {
  --primary-color: #6a5acd;
  --pink-color: #f8a9d4;
  --green-color: #b3e5bc;
  --light-bg: #f5f7fa;
  --white: #ffffff;
  --text-gray: #666666;
  --text-light: #333333;
  --blue-color: #e6f2ff; /* 新增蓝色变量 */
  --blue-text: #1a73e8; /* 新增蓝色文字变量 */
}

.ai-practice-container {
  width: 100%;
  min-height: 100vh;
  background: linear-gradient(135deg, #f0f5ff 0%, #e6eeff 100%);
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
  background-image: url('../../assets/images/people.gif');
  background-size: cover;
  background-position: center;
}

.top-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 30px;
  height: 80px;
}

.back-button {
  cursor: pointer;
  font-size: 24px;
  color: #333;
}

.title-container {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
}

.title {
  font-size: 40px;
  font-weight: bold;
  background: linear-gradient(to right, #6a5acd, #ff69b4);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  animation: rainbow 5s ease infinite;
}

@keyframes rainbow { 
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

.history-button {
  z-index: 1;
}

.btn-history {
  background-color: #6a5acd;
  color: white;
  border: none;
  border-radius: 20px;
  padding: 8px 20px;
  font-size: 14px;
  cursor: button;
  box-shadow: 0 2px 10px rgba(106, 90, 205, 0.3);
}

.btn-history:hover {
  background-color: #5949b0;
}

.main-content {
  position: relative;
  top: 70px;
  padding: 20px 40px 60px;
  width: 1000px;
  margin: 0 auto;
}



/* 训练范围样式 */
.training-scope {
  margin-bottom: 40px;
}

.scope-title {
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 15px;
  color: var(--text-light);
}

.selector-group {
  display: flex;
  justify-content: space-between;
  gap: 30px;
   position: relative;
   left: 100px;
}

.selector-item {
  flex: 1;
}

.selector-label {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
  font-size: 14px;
  color: var(--text-light);
}

.required-dot {
  color: #ff4d4f;
  margin-right: 4px;
}

/* Element Plus 自定义样式 */
:deep(.el-select) {
  width: 100%;
}

:deep(.el-select .el-input__wrapper) {
  border-radius: 10px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  border: 1px solid #e0e0e0;
}

:deep(.el-select .el-input__inner) {
  border: none;
  outline: none;
  padding-left: 15px;
}

:deep(.el-select-dropdown__item.selected) {
  color: var(--primary-color);
}

/* 功能选项样式 */
.function-options {
  display: flex;
  justify-content: space-between;
  gap: 30px;
}

.function-card {
  flex: 1;
  background-color: var(--green-color);
  border-radius: 15px;
  padding: 30px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  display: flex;
  flex-direction: column;
  cursor: pointer; /* 添加指针样式表示可点击 */
  transition: transform 0.2s, box-shadow 0.2s; /* 添加过渡效果 */
}

.function-card:hover {
  transform: translateY(-5px); /* 悬停时轻微上浮 */
  box-shadow: 0 6px 15px rgba(0, 0, 0, 0.1); /* 悬停时阴影加深 */
}

.green-card {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.6), rgba(106, 199, 83, 0.6));
}

.pink-card {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.6), rgba(245, 149, 199, 0.6));
}

.card-icon {
  margin-bottom: 20px;
  display: flex;
  justify-content: center;
}

.icon-wrapper {
  width: 50px;
  height: 50px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
}

.green .icon-wrapper {
  background-color: rgba(179, 229, 188, 0.2);
}

.pink .icon-wrapper {
  background-color: rgba(248, 169, 212, 0.2);
}

.card-title {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 12px;
  color: var(--text-light);
}

.green-card .card-title {
  color: #006400;
}

.pink-card .card-title {
  color: #8b0000;
}

.card-description {
  font-size: 14px;
  line-height: 1.6;
  color: var(--text-gray);
}
.custom-cascader .el-cascader-menu {
  min-width: 300px;
  max-height: 400px;
  overflow-y: auto;
}

</style>