<template>
  <div class="sidebar-container">
    <div class="sidebar-header">
      <h3>系统管理后台</h3>
    </div>
    
    <el-menu
      class="sidebar"
      background-color="transparent"
      text-color="#64748b"
      active-text-color="#3b82f6"
      :default-openeds="['user', 'system']"
      :default-active="currentRoute"
      router
      :collapse="false"
    >
      <el-menu-item index="/admin/" class="menu-item">
        <el-icon class="menu-icon"><DataBoard /></el-icon>
        <span>控制台</span>
      </el-menu-item>

      <el-sub-menu index="user" class="sub-menu">
        <template #title>
          <el-icon class="menu-icon"><User /></el-icon>
          <span>用户管理</span>
        </template>
        <el-menu-item index="/admin/users" class="sub-menu-item">
          <el-icon class="sub-icon"><Avatar /></el-icon>
          <span>用户信息管理</span>
        </el-menu-item>
        <el-menu-item index="/admin/roles" class="sub-menu-item">
          <el-icon class="sub-icon"><Lock /></el-icon>
          <span>权限角色管理</span>
        </el-menu-item>
      </el-sub-menu>

      <el-menu-item index="/admin/student-analysis" class="menu-item">
        <el-icon class="menu-icon"><TrendCharts /></el-icon>
        <span>学情分析</span>
      </el-menu-item>

      <el-sub-menu index="system" class="sub-menu">
        <template #title>
          <el-icon class="menu-icon"><Setting /></el-icon>
          <span>系统设置</span>
        </template>
        <el-menu-item index="/admin/config" class="sub-menu-item">
          <el-icon class="sub-icon"><Operation /></el-icon>
          <span>参数设置</span>
        </el-menu-item>
        <el-menu-item index="/admin/logs" class="sub-menu-item">
          <el-icon class="sub-icon"><Document /></el-icon>
          <span>系统日志</span>
        </el-menu-item>
      </el-sub-menu>

      <el-menu-item index="/" class="menu-item">
        <el-icon class="menu-icon"><Back /></el-icon>
        <span>返回首页</span>
      </el-menu-item>
    </el-menu>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { 
  DataBoard,
  User, 
  Avatar,
  Lock,
  Setting,
  Operation,
  Document,
  Back,
  TrendCharts
} from '@element-plus/icons-vue'

const route = useRoute()

const currentRoute = computed(() => {
  const path = route.path
  if (path === '/admin' || path === '/admin/') {
    return '/admin/'
  }
  return path
})
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
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
}

.sidebar-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #ffffff;
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

.sub-menu {
  margin: 4px 12px;
  border-radius: 12px;
  transition: all 0.3s ease;
}

.sub-menu-item {
  margin: 2px 8px;
  border-radius: 10px;
  transition: all 0.3s ease;
  padding-left: 40px !important;
  height: 40px;
  line-height: 40px;
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
</style>
