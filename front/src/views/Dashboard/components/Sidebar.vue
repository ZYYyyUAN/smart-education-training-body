<template>
  <div class="sidebar-container">
    <div class="sidebar-header">
      <h3>教学管理</h3>
    </div>
    
    <el-menu
      class="sidebar"
      background-color="transparent"
      text-color="#64748b"
      active-text-color="#3b82f6"
      :default-openeds="['course', 'homework', 'exam']"
      :default-active="currentRoute"
      router
      :collapse="false"
    >
      <el-menu-item index="/teacher_school/" class="menu-item">
        <el-icon class="menu-icon"><View /></el-icon>
        <span>教学总览</span>
      </el-menu-item>

      <el-sub-menu index="course" class="sub-menu">
        <template #title>
          <el-icon class="menu-icon"><Folder /></el-icon>
          <span>课程管理</span>
        </template>
        <el-menu-item index="/teacher_school/query" class="sub-menu-item">
          <el-icon class="sub-icon"><Document /></el-icon>
          <span>课程总览</span>
        </el-menu-item>
        <el-menu-item index="/teacher_school/resourcedashboard" class="sub-menu-item">
          <el-icon class="sub-icon"><Collection /></el-icon>
          <span>教学资源管理</span>
        </el-menu-item>
      </el-sub-menu>

      <el-sub-menu index="homework" class="sub-menu">
        <template #title>
          <el-icon class="menu-icon"><EditPen /></el-icon>
          <span>作业管理</span>
        </template>
        <el-menu-item index="/teacher_school/homework-dashboard" class="sub-menu-item">
          <el-icon class="sub-icon"><Document /></el-icon>
          <span>作业总览</span>
        </el-menu-item>
        <el-menu-item index="/teacher_school/question-bank" class="sub-menu-item">
          <el-icon class="sub-icon"><Collection /></el-icon>
          <span>题库管理</span>
        </el-menu-item>
      </el-sub-menu>

      <el-sub-menu index="exam" class="sub-menu">
        <template #title>
          <el-icon class="menu-icon"><Document /></el-icon>
          <span>考试管理</span>
        </template>
        <el-menu-item index="/teacher_school/exam-dashboard" class="sub-menu-item">
          <el-icon class="sub-icon"><DataAnalysis /></el-icon>
          <span>考试总览</span>
        </el-menu-item>
      </el-sub-menu>

      <el-menu-item index="/teacher_school/manager" class="menu-item">
        <el-icon class="menu-icon"><User /></el-icon>
        <span>学生管理</span>
      </el-menu-item>

      <el-menu-item index="/teacher_school/group-chat" class="menu-item">
        <el-icon class="menu-icon"><ChatDotRound /></el-icon>
        <span>群聊</span>
      </el-menu-item>
    </el-menu>
  </div>
</template>


<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { 
  View, 
  Folder, 
  Document, 
  Collection, 
  EditPen, 
  DataAnalysis, 
  User, 
  ChatDotRound 
} from '@element-plus/icons-vue'

const route = useRoute()

// 计算当前路由，确保教学总览在访问 /teacher_school 时被选中
const currentRoute = computed(() => {
  const path = route.path
  if (path === '/teacher_school' || path === '/teacher_school/') {
    return '/teacher_school/'
  }
  return path
})

// 控制课程管理下拉
const showSubMenu = ref(false)
const toggleSubMenu = () => {
  showSubMenu.value = !showSubMenu.value
}

// 控制作业管理下拉
const showHomeworkSubMenu = ref(false)
const toggleHomeworkMenu = () => {
  showHomeworkSubMenu.value = !showHomeworkSubMenu.value
}
</script>


<style scoped>
.sidebar-container {
  width: 260px;
  background: #ffffff;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #e2e8f0;
  overflow: hidden;
  margin: 20px;
  height: calc(100vh - 40px);
  display: flex;
  flex-direction: column;
}

.sidebar-header {
  padding: 24px 20px 16px;
  border-bottom: 1px solid #f1f5f9;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
}

.sidebar-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #1e293b;
  text-align: center;
}

.sidebar {
  width: 100%;
  border: none;
  background: transparent;
  padding: 8px 0;
  flex: 1;
  overflow-y: auto;
}

/* 主菜单项样式 */
.menu-item {
  margin: 4px 12px;
  border-radius: 12px;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.menu-item:hover {
  background: #f1f5f9 !important;
  color: #3b82f6 !important;
  transform: translateX(4px);
}

.menu-item.is-active {
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%) !important;
  color: #ffffff !important;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

.menu-icon {
  margin-right: 12px;
  font-size: 18px;
  width: 20px;
  text-align: center;
}

/* 子菜单样式 */
.sub-menu {
  margin: 4px 12px;
  border-radius: 12px;
  transition: all 0.3s ease;
}

.sub-menu:hover {
  background: #f8fafc !important;
}

.sub-menu .el-sub-menu__title {
  border-radius: 12px;
  transition: all 0.3s ease;
  padding: 0 16px;
  height: 48px;
  line-height: 48px;
}

.sub-menu .el-sub-menu__title:hover {
  background: #f1f5f9 !important;
  color: #3b82f6 !important;
}

.sub-menu-item {
  margin: 2px 8px;
  border-radius: 10px;
  transition: all 0.3s ease;
  padding-left: 40px !important;
  height: 40px;
  line-height: 40px;
}

.sub-menu-item:hover {
  background: #f1f5f9 !important;
  color: #3b82f6 !important;
  transform: translateX(8px);
}

.sub-menu-item.is-active {
  background: linear-gradient(135deg, #e0f2fe 0%, #b3e5fc 100%) !important;
  color: #0277bd !important;
  font-weight: 500;
}

.sub-icon {
  margin-right: 8px;
  font-size: 16px;
  width: 16px;
  text-align: center;
}

/* 子菜单展开/收起动画 */
.el-sub-menu .el-menu {
  background: transparent;
  border: none;
  padding: 8px 0;
}

.el-sub-menu .el-menu-item {
  height: 40px;
  line-height: 40px;
  padding: 0 16px;
}

/* 滚动条样式 */
.sidebar::-webkit-scrollbar {
  width: 4px;
}

.sidebar::-webkit-scrollbar-track {
  background: #f1f5f9;
  border-radius: 2px;
}

.sidebar::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 2px;
}

.sidebar::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .sidebar-container {
    width: 100%;
    margin: 10px;
    border-radius: 12px;
  }
  
  .sidebar-header {
    padding: 16px;
  }
  
  .sidebar-header h3 {
    font-size: 16px;
  }
}
</style>
