<template>
  <div class="user-management-container">
    <div class="user-layout">
      <!-- 左侧栏 -->
      <div class="column left-col">
        <!-- 用户角色分布 -->
        <div class="panel-box">
          <div class="panel-header">用户角色分布</div>
          <div class="panel-content flex-row">
            <div class="chart-wrapper-circle">
              <v-chart class="chart" :option="roleDistributionOption" autoresize />
              <div class="center-text">
                <div class="num">{{ totalUsers }}</div>
                <div class="label">总用户数</div>
              </div>
            </div>
            <div class="legend-list">
              <div class="legend-item" v-for="(item, idx) in roleDistributionData" :key="idx">
                <span class="dot" :style="{background: item.color}"></span>
                <span class="name">{{ item.name }}</span>
                <span class="val">{{ item.value }}</span>
                <span class="pct">{{ item.pct }}</span>
              </div>
            </div>
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>

        <!-- 用户活跃度 -->
        <div class="panel-box">
          <div class="panel-header">用户活跃度</div>
          <div class="panel-content">
            <div class="activity-filter">
              <el-button 
                :type="activityRole === 'student' ? 'primary' : 'default'"
                :class="['activity-role-btn', { active: activityRole === 'student' }]"
                @click="handleActivityRoleChange('student')"
              >
                学生
              </el-button>
              <el-button 
                :type="activityRole === 'teacher' ? 'primary' : 'default'"
                :class="['activity-role-btn', { active: activityRole === 'teacher' }]"
                @click="handleActivityRoleChange('teacher')"
              >
                教师
              </el-button>
            </div>
            <v-chart class="chart" :option="activityOption" autoresize />
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>

        <!-- 用户统计 - 男女比例 -->
        <div class="panel-box">
          <div class="panel-header">用户统计</div>
          <div class="panel-content flex-row">
            <div class="chart-wrapper-circle">
              <v-chart class="chart" :option="genderRatioOption" autoresize />
              <div class="center-text">
                <div class="num">{{ totalUsers }}</div>
                <div class="label">总用户数</div>
              </div>
            </div>
            <div class="legend-list">
              <div class="legend-item" v-for="(item, idx) in genderRatioData" :key="idx">
                <span class="dot" :style="{background: item.color}"></span>
                <span class="name">{{ item.name }}</span>
                <span class="val">{{ item.value }}</span>
                <span class="pct">{{ item.pct }}</span>
              </div>
            </div>
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>
      </div>

      <!-- 中间栏 -->
      <div class="column center-col">
        <!-- 用户管理内容区域（包含顶部统计和列表） -->
        <div class="user-management-content">
          <!-- 顶部数据统计 -->
          <div class="top-data-row">
            <div class="data-item" v-for="(item, idx) in centerStats" :key="idx">
              <div class="data-label">{{ item.label }}</div>
              <div class="data-num">{{ item.value }}</div>
              <div class="data-decoration"></div>
            </div>
          </div>

          <!-- 用户列表区域 -->
          <div class="user-list-area">
          <div class="user-list-header">
            <div class="role-filter">
              <el-button 
                v-for="role in roleOptions" 
                :key="role.value"
                :type="selectedRole === role.value ? 'primary' : 'default'"
                :class="['role-btn', { active: selectedRole === role.value }]"
                @click="handleRoleFilter(role.value)"
              >
                {{ role.label }}
              </el-button>
            </div>
            <div class="header-actions">
              <el-button 
                type="primary" 
                :icon="Plus" 
                @click="handleAdd"
                class="add-btn"
              >
                新增
              </el-button>
            <div class="search-box">
              <el-input
                v-model="searchKeyword"
                placeholder="搜索用户名、邮箱..."
                clearable
                @input="handleSearch"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              </div>
            </div>
          </div>

          <div class="user-table-container">
            <el-table
              :data="filteredUserList"
              style="width: 100%"
              :row-class-name="tableRowClassName"
              v-loading="loading"
              @row-click="handleRowClick"
              highlight-current-row
              table-layout="auto"
            >
              <el-table-column prop="avatar_url" label="头像" width="70" align="center">
                <template #default="{ row }">
                  <el-avatar 
                    :src="row.avatar_url || defaultAvatar" 
                    :size="35"
                    :icon="UserFilled"
                  />
                </template>
              </el-table-column>
              <el-table-column prop="username" label="用户名" width="100" />
              <el-table-column prop="real_name" label="真实姓名" width="100" />
              <el-table-column prop="email" label="邮箱" min-width="150" show-overflow-tooltip />
              <el-table-column prop="sex" label="性别" width="70" align="center">
                <template #default="{ row }">
                  <el-tag :type="row.sex === '男' ? 'primary' : 'danger'" size="small">
                    {{ row.sex || '未知' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="role" label="角色" width="80" align="center">
                <template #default="{ row }">
                  <el-tag :type="getRoleTagType(row.role)" size="small">
                    {{ getRoleLabel(row.role) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="class" label="班级" min-width="100" show-overflow-tooltip />
              <el-table-column prop="school" label="学校" min-width="120" show-overflow-tooltip />
              <el-table-column prop="study_score" label="学习积分" width="90" align="center" />
              <el-table-column prop="created_at" label="注册时间" width="160" show-overflow-tooltip>
                <template #default="{ row }">
                  {{ formatDate(row.created_at, false) }}
                </template>
              </el-table-column>
              <el-table-column prop="last_login" label="最后登录" width="170" show-overflow-tooltip>
                <template #default="{ row }">
                  {{ formatDate(row.last_login, true) }}
                </template>
              </el-table-column>
              <el-table-column label="操作" width="160" align="center" class-name="operation-column">
                <template #default="{ row }">
                  <div class="operation-buttons">
                    <el-button link type="primary" @click.stop="handleEdit(row)">编辑</el-button>
                    <el-button link type="danger" @click.stop="handleDelete(row)">删除</el-button>
                  </div>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </div>
        </div>
      </div>

      <!-- 右侧栏 -->
      <div class="column right-col">
        <!-- 用户详情 -->
        <div class="panel-box">
          <div class="panel-header">用户详情</div>
          <div class="panel-content" v-if="selectedUser">
            <div class="user-detail">
              <div class="detail-avatar">
                <el-avatar 
                  :src="selectedUser.avatar_url || defaultAvatar" 
                  :size="80"
                  :icon="UserFilled"
                />
              </div>
              <div class="detail-info">
                <div class="detail-item">
                  <span class="label">用户名：</span>
                  <span class="value">{{ selectedUser.username }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">真实姓名：</span>
                  <span class="value">{{ selectedUser.real_name || '未设置' }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">邮箱：</span>
                  <span class="value">{{ selectedUser.email || '未设置' }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">性别：</span>
                  <span class="value">{{ selectedUser.sex || '未知' }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">角色：</span>
                  <span class="value">{{ getRoleLabel(selectedUser.role) }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">班级：</span>
                  <span class="value">{{ selectedUser.class || '未设置' }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">学校：</span>
                  <span class="value">{{ selectedUser.school || '未设置' }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">学习积分：</span>
                  <span class="value">{{ selectedUser.study_score || 0 }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">注册时间：</span>
                  <span class="value">{{ formatDate(selectedUser.created_at, false) }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">最后登录：</span>
                  <span class="value">{{ formatDate(selectedUser.last_login, true) }}</span>
                </div>
              </div>
            </div>
          </div>
          <div class="panel-content empty-detail" v-else>
            <div class="empty-text">请选择用户查看详情</div>
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>

        <!-- 操作日志 -->
        <div class="panel-box">
          <div class="panel-header">操作日志</div>
          <div class="panel-content">
            <div class="log-list">
              <div class="log-item" v-for="(log, idx) in operationLogs" :key="idx">
                <div class="log-time">{{ formatDate(log.operationTime, false) }}</div>
                <div class="log-action">{{ log.operationDesc || getOperationDesc(log) }}</div>
              </div>
              <div v-if="operationLogs.length === 0" class="empty-text">暂无操作日志</div>
            </div>
          </div>
          <div class="corner-tl"></div><div class="corner-tr"></div><div class="corner-bl"></div><div class="corner-br"></div>
        </div>
      </div>
    </div>

    <!-- 新增/编辑用户对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEditMode ? '编辑用户' : '新增用户'"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form
        ref="addUserFormRef"
        :model="addUserForm"
        :rules="addUserRules"
        label-width="100px"
        label-position="left"
      >
        <el-form-item label="用户名" prop="username">
          <el-input v-model="addUserForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="!isEditMode">
          <el-input 
            v-model="addUserForm.password" 
            type="password" 
            placeholder="请输入密码" 
            show-password
          />
        </el-form-item>
        <el-form-item label="密码" prop="password" v-else>
          <el-input 
            v-model="addUserForm.password" 
            type="password" 
            placeholder="留空则不修改密码" 
            show-password
          />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="addUserForm.email" placeholder="请输入邮箱地址" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="addUserForm.role" placeholder="请选择角色" style="width: 100%">
            <el-option 
              v-for="role in roleOptions.filter(r => r.value !== 'all')" 
              :key="role.value"
              :label="role.label" 
              :value="role.value" 
            />
          </el-select>
        </el-form-item>
        <el-form-item label="真实姓名" prop="real_name">
          <el-input v-model="addUserForm.real_name" placeholder="请输入真实姓名" />
        </el-form-item>
        <el-form-item label="性别" prop="sex">
          <el-select v-model="addUserForm.sex" placeholder="请选择性别" style="width: 100%">
            <el-option label="男" value="男" />
            <el-option label="女" value="女" />
          </el-select>
        </el-form-item>
        <el-form-item label="学校" prop="school">
          <el-input v-model="addUserForm.school" placeholder="请输入学校名称" />
        </el-form-item>
        <el-form-item 
          v-if="addUserForm.role === 'student'" 
          label="班级" 
          prop="class"
        >
          <el-input v-model="addUserForm.class" placeholder="请输入班级" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit" :loading="addLoading">
            {{ isEditMode ? '保存' : '确定' }}
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
// 导航逻辑已移至 AdminHome.vue，不再需要 router
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { PieChart, BarChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent
} from 'echarts/components'
import VChart from 'vue-echarts'
import { 
  User, Avatar, Search, UserFilled, Plus,
  DataLine, Connection, Reading, Monitor
} from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import http from '@/api/http.js'

// router 已移除，导航逻辑统一在 AdminHome.vue 管理

use([CanvasRenderer, PieChart, BarChart, TitleComponent, TooltipComponent, LegendComponent, GridComponent])

// 数据定义
const loading = ref(false)
const userList = ref([])
const selectedUser = ref(null)
const selectedRole = ref('all')
const searchKeyword = ref('')
const dialogVisible = ref(false)
const addLoading = ref(false)
const addUserFormRef = ref(null)
const isEditMode = ref(false) // 是否为编辑模式
const editingUserId = ref(null) // 正在编辑的用户ID

// 新增用户表单
const addUserForm = reactive({
  username: '',
  password: '',
  email: '',
  role: 'student',
  real_name: '',
  sex: '',
  school: '',
  class: ''
})

// 表单验证规则
const addUserRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度应在3-20个字符之间', trigger: 'blur' }
  ],
  password: [
    { 
      validator: (rule, value, callback) => {
        // 编辑模式下密码可以为空（不修改密码）
        if (isEditMode.value && (!value || value.trim() === '')) {
          callback()
        } else if (!isEditMode.value && (!value || value.trim() === '')) {
          callback(new Error('请输入密码'))
        } else if (value && (value.length < 6 || value.length > 20)) {
          callback(new Error('密码长度应在6-20个字符之间'))
        } else {
          callback()
        }
      }, 
      trigger: 'blur' 
    }
  ],
  email: [
    { required: true, message: '请输入邮箱地址', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择角色', trigger: 'change' }
  ],
  real_name: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' }
  ],
  sex: [
    { required: true, message: '请选择性别', trigger: 'change' }
  ],
  school: [
    { required: true, message: '请输入学校名称', trigger: 'blur' }
  ],
  class: [
    { 
      validator: (rule, value, callback) => {
        if (addUserForm.role === 'student' && !value) {
          callback(new Error('学生角色请填写班级信息'))
        } else {
          callback()
        }
      }, 
      trigger: 'blur' 
    }
  ]
}

const roleOptions = [
  { label: '全部', value: 'all' },
  { label: '学生', value: 'student' },
  { label: '教师', value: 'teacher' },
  { label: '管理员', value: 'admin' }
]

// 导航逻辑已移至 AdminHome.vue 统一管理

const defaultAvatar = 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png'

// 计算属性
const totalUsers = computed(() => userList.value.length)

const roleDistributionData = computed(() => {
  const roleCount = {
    student: 0,
    teacher: 0,
    admin: 0
  }
  
  userList.value.forEach(user => {
    const role = (user.role || '').toLowerCase()
    if (role.includes('student')) roleCount.student++
    else if (role.includes('teacher')) roleCount.teacher++
    else if (role.includes('admin')) roleCount.admin++
  })
  
  const total = roleCount.student + roleCount.teacher + roleCount.admin
  return [
    { name: '学生', value: roleCount.student, pct: total > 0 ? ((roleCount.student / total) * 100).toFixed(1) + '%' : '0%', color: '#00bfff' },
    { name: '教师', value: roleCount.teacher, pct: total > 0 ? ((roleCount.teacher / total) * 100).toFixed(1) + '%' : '0%', color: '#00f2fe' },
    { name: '管理员', value: roleCount.admin, pct: total > 0 ? ((roleCount.admin / total) * 100).toFixed(1) + '%' : '0%', color: '#7c3aed' }
  ]
})

const roleDistributionOption = computed(() => ({
  series: [{
    type: 'pie',
    radius: ['60%', '75%'],
    center: ['50%', '50%'],
    label: { show: false },
    data: roleDistributionData.value.map(item => ({ 
      value: item.value, 
      name: item.name, 
      itemStyle: { color: item.color } 
    }))
  }]
}))

const activityOption = computed(() => ({
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'shadow'
    },
    backgroundColor: 'rgba(0, 0, 0, 0.8)',
    borderColor: '#00bfff',
    borderWidth: 1,
    textStyle: {
      color: '#fff'
    },
    formatter: function(params) {
      if (params && params.length > 0) {
        const param = params[0]
        return `${param.name}<br/>${param.seriesName}: <span style="color: #00bfff; font-weight: bold;">${param.value}</span>次`
      }
      return ''
    }
  },
  grid: { top: '20%', bottom: '15%', left: '10%', right: '5%' },
  xAxis: {
    type: 'category',
    data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
    axisLine: { lineStyle: { color: 'rgba(255,255,255,0.3)' } },
    axisLabel: { color: '#fff' }
  },
  yAxis: {
    type: 'value',
    splitLine: { lineStyle: { color: 'rgba(255,255,255,0.1)' } },
    axisLabel: { color: '#fff' }
  },
  series: [
    { 
      type: 'bar', 
      name: activityRole.value === 'student' ? '学生登录次数' : '教师登录次数', 
      data: weeklyLoginData.value[activityRole.value] || [0, 0, 0, 0, 0, 0, 0], 
      itemStyle: { color: '#00bfff' } 
    }
  ]
}))

const genderRatioData = computed(() => {
  const maleCount = userList.value.filter(u => u.sex === '男').length
  const femaleCount = userList.value.filter(u => u.sex === '女').length
  const unknownCount = userList.value.filter(u => !u.sex || (u.sex !== '男' && u.sex !== '女')).length
  const total = maleCount + femaleCount + unknownCount
  
  return [
    { name: '男', value: maleCount, pct: total > 0 ? ((maleCount / total) * 100).toFixed(1) + '%' : '0%', color: '#00bfff' },
    { name: '女', value: femaleCount, pct: total > 0 ? ((femaleCount / total) * 100).toFixed(1) + '%' : '0%', color: '#ff69b4' },
    { name: '未知', value: unknownCount, pct: total > 0 ? ((unknownCount / total) * 100).toFixed(1) + '%' : '0%', color: '#999' }
  ]
})

const genderRatioOption = computed(() => ({
  series: [{
    type: 'pie',
    radius: ['60%', '75%'],
    center: ['50%', '50%'],
    label: { show: false },
    data: genderRatioData.value.map(item => ({ 
      value: item.value, 
      name: item.name, 
      itemStyle: { color: item.color } 
    }))
  }]
}))

const centerStats = computed(() => {
  const studentCount = userList.value.filter(u => (u.role || '').toLowerCase().includes('student')).length
  const teacherCount = userList.value.filter(u => (u.role || '').toLowerCase().includes('teacher')).length
  const adminCount = userList.value.filter(u => (u.role || '').toLowerCase().includes('admin')).length
  const activeCount = userList.value.filter(u => u.last_login).length
  
  return [
    { label: '总用户数', value: totalUsers.value.toString() },
    { label: '学生数', value: studentCount.toString() },
    { label: '教师数', value: teacherCount.toString() },
    { label: '管理员', value: adminCount.toString() },
    { label: '活跃用户', value: activeCount.toString() }
  ]
})

const filteredUserList = computed(() => {
  let filtered = userList.value
  
  // 角色筛选
  if (selectedRole.value !== 'all') {
    filtered = filtered.filter(user => {
      const role = (user.role || '').toLowerCase()
      return role.includes(selectedRole.value)
    })
  }
  
  // 搜索筛选
  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase()
    filtered = filtered.filter(user => 
      (user.username && user.username.toLowerCase().includes(keyword)) ||
      (user.email && user.email.toLowerCase().includes(keyword)) ||
      (user.real_name && user.real_name.toLowerCase().includes(keyword))
    )
  }
  
  return filtered
})

const operationLogs = ref([])

// 用户活跃度相关
const activityRole = ref('student') // 当前选择的角色：student 或 teacher
const weeklyLoginData = ref({
  student: [0, 0, 0, 0, 0, 0, 0], // 周一到周日的登录次数
  teacher: [0, 0, 0, 0, 0, 0, 0]
})

// 方法
const loadUserList = async () => {
  loading.value = true
  try {
    // 尝试使用 /xiaozhi/user/list 路径（不经过 /api 代理重写）
    const res = await http.get({ url: '/xiaozhi/user/list' })
    
    console.log('🔍 用户列表API响应:', res)
    
    if (res.code === 200 || res.code === 0) {
      // 处理字段映射：将后端的 camelCase 转换为前端的 snake_case
      const users = (res.data || []).map((user, index) => {
        // 只在第一个用户时打印详细日志
        if (index === 0) {
          console.log('🔍 原始用户数据:', user)
          console.log('🔍 日期字段检查:', {
            createdAt: user.createdAt,
            created_at: user.created_at,
            lastLogin: user.lastLogin,
            last_login: user.last_login,
            allKeys: Object.keys(user)
          })
        }
        
        // 兼容多种字段名格式，尝试多种可能的字段名
        // 注意：后端可能返回 LocalDateTime 对象，需要转换为字符串
        let createdAt = user.createdAt || user.created_at || null
        let lastLogin = user.lastLogin || user.last_login || null
        
        // 如果是对象（LocalDateTime），尝试转换为字符串
        if (createdAt && typeof createdAt === 'object') {
          // 尝试从对象中提取日期字符串
          if (createdAt.toString && typeof createdAt.toString === 'function') {
            const dateStr = createdAt.toString()
            // 如果toString返回的是ISO格式，解析它
            if (dateStr.includes('T')) {
              createdAt = dateStr.replace('T', ' ').substring(0, 19)
            } else {
              createdAt = dateStr
            }
          }
        }
        
        if (lastLogin && typeof lastLogin === 'object') {
          if (lastLogin.toString && typeof lastLogin.toString === 'function') {
            const dateStr = lastLogin.toString()
            if (dateStr.includes('T')) {
              lastLogin = dateStr.replace('T', ' ').substring(0, 19)
            } else {
              lastLogin = dateStr
            }
          }
        }
        
        const mappedUser = {
          id: user.id,
          username: user.username,
          real_name: user.realName || user.real_name || '',
          email: user.email || '',
          sex: user.sex || '',
          role: user.role || '',
          class: user.className || user.class || user.userClass || '',
          school: user.school || '',
          avatar_url: user.avatarUrl || user.avatar_url || '',
          study_score: user.studyScore || user.study_score || 0,
          // 保留原始日期值，让formatDate函数处理格式化
          created_at: createdAt,
          last_login: lastLogin
        }
        
        if (index === 0) {
          console.log('🔍 映射后的用户数据:', mappedUser)
        }
        
        return mappedUser
      })
      
      userList.value = users
      console.log('✅ 用户列表加载成功，共', users.length, '位用户')
      if (users.length > 0) {
        console.log('🔍 第一个用户的日期字段:', {
          created_at: users[0].created_at,
          last_login: users[0].last_login,
          created_at_type: typeof users[0].created_at,
          last_login_type: typeof users[0].last_login
        })
      }
    } else {
      console.error('❌ 获取用户列表失败:', res)
      ElMessage.error(res.message || '获取用户列表失败')
      userList.value = []
    }
  } catch (error) {
    console.error('❌ 加载用户列表异常:', error)
    console.error('错误详情:', {
      message: error.message,
      response: error.response,
      status: error.response?.status,
      data: error.response?.data,
      config: error.config
    })
    
    if (error.response) {
      const status = error.response.status
      const errorData = error.response.data
      console.error(`HTTP错误 ${status}:`, errorData)
      
      if (status === 400) {
        ElMessage.error(`请求参数错误: ${errorData?.message || errorData || 'Bad Request'}`)
      } else if (status === 401) {
        ElMessage.error('未授权，请先登录')
      } else if (status === 404) {
        ElMessage.error('接口不存在，请检查后端服务')
      } else {
        ElMessage.error(`加载用户列表失败: ${errorData?.message || error.message}`)
      }
    } else if (error.request) {
      ElMessage.error('无法连接到服务器，请检查后端服务是否启动')
    } else {
      ElMessage.error(`加载用户列表失败: ${error.message}`)
    }
    userList.value = []
  } finally {
    loading.value = false
  }
}

// 格式化日期时间
const formatDateTime = (dateTime) => {
  if (!dateTime) return ''
  
  // 如果是字符串，直接返回
  if (typeof dateTime === 'string') {
    return dateTime
  }
  
  // 如果是 Date 对象或时间戳
  const date = new Date(dateTime)
  if (isNaN(date.getTime())) return ''
  
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  const seconds = String(date.getSeconds()).padStart(2, '0')
  
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

const handleRoleFilter = (role) => {
  selectedRole.value = role
}

const handleSearch = () => {
  // 搜索时不需要重置分页
}

const handleEdit = (row) => {
  selectedUser.value = row
  isEditMode.value = true
  editingUserId.value = row.id
  
  // 填充表单数据
  Object.assign(addUserForm, {
    username: row.username || '',
    password: '', // 编辑时不显示密码
    email: row.email || '',
    role: row.role || 'student',
    real_name: row.real_name || '',
    sex: row.sex || '',
    school: row.school || '',
    class: row.class || ''
  })
  
  // 清除表单验证
  if (addUserFormRef.value) {
    addUserFormRef.value.clearValidate()
  }
  
  dialogVisible.value = true
}

const handleDelete = async (row) => {
  ElMessageBox.confirm(
    `确定要删除用户 "${row.username}" (${row.real_name || '未设置姓名'}) 吗？此操作不可恢复！`, 
    '删除确认', 
    {
      confirmButtonText: '确定删除',
    cancelButtonText: '取消',
      type: 'warning',
      dangerouslyUseHTMLString: false
    }
  ).then(async () => {
    try {
      const res = await http.delete({
        url: `/xiaozhi/user/${row.id}`
      })
      
      if (res.code === 200 || res.code === 0) {
    ElMessage.success('删除成功')
        // 刷新用户列表和操作日志
        await loadUserList()
        await loadOperationLogs()
        // 如果删除的是当前选中的用户，清空选中
        if (selectedUser.value && selectedUser.value.id === row.id) {
          selectedUser.value = null
        }
      } else {
        ElMessage.error(res.message || '删除失败')
      }
    } catch (error) {
      console.error('删除用户失败:', error)
      if (error.response) {
        ElMessage.error(error.response.data?.message || '删除失败')
      } else {
        ElMessage.error('删除失败，请检查网络连接')
      }
    }
  }).catch(() => {
    // 用户取消删除
  })
}

// 打开新增用户对话框
const handleAdd = () => {
  isEditMode.value = false
  editingUserId.value = null
  // 重置表单
  Object.assign(addUserForm, {
    username: '',
    password: '',
    email: '',
    role: 'student',
    real_name: '',
    sex: '',
    school: '',
    class: ''
  })
  // 清除表单验证
  if (addUserFormRef.value) {
    addUserFormRef.value.clearValidate()
  }
  dialogVisible.value = true
}

// 提交新增/编辑用户
const handleSubmit = async () => {
  if (!addUserFormRef.value) return
  
  // 表单验证
  await addUserFormRef.value.validate(async (valid) => {
    if (!valid) return
    
    addLoading.value = true
    try {
      // 构建提交数据
      const submitData = {
        username: addUserForm.username,
        email: addUserForm.email,
        role: addUserForm.role,
        real_name: addUserForm.real_name,
        sex: addUserForm.sex,
        school: addUserForm.school
      }
      
      // 如果是学生角色，添加班级信息
      if (addUserForm.role === 'student' && addUserForm.class) {
        submitData.class = addUserForm.class
      }
      
      // 编辑模式下，只有填写了密码才更新密码
      if (isEditMode.value) {
        if (addUserForm.password && addUserForm.password.trim() !== '') {
          submitData.password = addUserForm.password
        }
        
        // 调用更新API
        const res = await http.put({
          url: `/xiaozhi/user/${editingUserId.value}`,
          data: submitData
        })
        
        if (res.code === 200 || res.code === 0) {
          ElMessage.success('用户更新成功')
          dialogVisible.value = false
          // 刷新用户列表和操作日志
          await loadUserList()
          await loadOperationLogs()
          // 如果更新的是当前选中的用户，更新选中用户信息
          if (selectedUser.value && selectedUser.value.id === editingUserId.value) {
            const updatedUser = userList.value.find(u => u.id === editingUserId.value)
            if (updatedUser) {
              selectedUser.value = updatedUser
            }
          }
        } else {
          ElMessage.error(res.message || '用户更新失败')
        }
      } else {
        // 新增模式下，密码必填
        if (!addUserForm.password || addUserForm.password.trim() === '') {
          ElMessage.warning('请输入密码')
          addLoading.value = false
          return
        }
        submitData.password = addUserForm.password
        
        // 调用注册API
        const res = await http.post({
          url: '/auth/register',
          data: submitData
        })
        
      if (res.code === 200 || res.code === 0) {
        ElMessage.success('新增用户成功')
        dialogVisible.value = false
        // 刷新用户列表和操作日志
        await loadUserList()
        await loadOperationLogs()
      } else {
        ElMessage.error(res.message || '新增用户失败')
      }
      }
    } catch (error) {
      console.error(isEditMode.value ? '更新用户失败:' : '新增用户失败:', error)
      if (error.response) {
        ElMessage.error(error.response.data?.message || (isEditMode.value ? '更新用户失败' : '新增用户失败'))
      } else {
        ElMessage.error((isEditMode.value ? '更新用户失败' : '新增用户失败') + '，请检查网络连接')
      }
    } finally {
      addLoading.value = false
    }
  })
}

const formatDate = (dateStr, isLastLogin = false) => {
  // 处理null、undefined、空字符串
  if (dateStr === null || dateStr === undefined || dateStr === 'null' || dateStr === 'undefined' || dateStr === '') {
    return isLastLogin ? '未登录' : '未知'
  }
  
  // 如果是对象，尝试转换为字符串
  if (typeof dateStr === 'object') {
    try {
      // 如果是Date对象
      if (dateStr instanceof Date) {
        return formatDateTime(dateStr)
      }
      // 如果是其他对象，尝试toString
      const str = dateStr.toString()
      if (str && str !== '[object Object]') {
        dateStr = str
      } else {
        return isLastLogin ? '未登录' : '未知'
      }
    } catch (e) {
      console.warn('日期对象转换失败:', dateStr, e)
      return isLastLogin ? '未登录' : '未知'
    }
  }
  
  // 如果已经是格式化好的字符串（YYYY-MM-DD HH:MM:SS格式），直接返回
  if (typeof dateStr === 'string') {
    // 检查是否是标准日期时间格式
    const dateTimePattern = /^\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}$/
    if (dateTimePattern.test(dateStr)) {
  return dateStr
    }
    
    // 检查是否是ISO格式（2025-07-12T00:00:00）
    const isoPattern = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/
    if (isoPattern.test(dateStr)) {
      return dateStr.replace('T', ' ').substring(0, 19)
    }
    
    // 检查是否是日期格式（YYYY-MM-DD）
    const datePattern = /^\d{4}-\d{2}-\d{2}$/
    if (datePattern.test(dateStr)) {
      return dateStr + ' 00:00:00'
    }
  }
  
  // 尝试解析和格式化日期
  try {
    const date = new Date(dateStr)
    if (isNaN(date.getTime())) {
      console.warn('日期解析失败，无效的日期值:', dateStr)
      return isLastLogin ? '未登录' : '未知'
    }
    return formatDateTime(date)
  } catch (e) {
    console.warn('日期格式化失败:', dateStr, e)
    return isLastLogin ? '未登录' : '未知'
  }
}

const getRoleLabel = (role) => {
  if (!role) return '未知'
  const r = role.toLowerCase()
  if (r.includes('student')) return '学生'
  if (r.includes('teacher')) return '教师'
  if (r.includes('admin')) return '管理员'
  return role
}

const getRoleTagType = (role) => {
  if (!role) return 'info'
  const r = role.toLowerCase()
  if (r.includes('student')) return 'success'
  if (r.includes('teacher')) return 'warning'
  if (r.includes('admin')) return 'danger'
  return 'info'
}

const handleRowClick = (row) => {
  selectedUser.value = row
}

const tableRowClassName = ({ row, rowIndex }) => {
  if (selectedUser.value && selectedUser.value.id === row.id) {
    return 'selected-row'
  }
  return ''
}

// 加载操作日志
const loadOperationLogs = async () => {
  try {
    const res = await http.get({ url: '/xiaozhi/operation-log/recent?limit=10' })
    
    if (res.code === 200 || res.code === 0) {
      operationLogs.value = (res.data || []).map(log => ({
        ...log,
        operationTime: log.operationTime || log.operation_time
      }))
      console.log('✅ 操作日志加载成功，共', operationLogs.value.length, '条')
    } else {
      console.error('❌ 获取操作日志失败:', res.message)
      operationLogs.value = []
    }
  } catch (error) {
    console.error('❌ 加载操作日志异常:', error)
    operationLogs.value = []
  }
}

// 获取操作描述
const getOperationDesc = (log) => {
  if (log.operationDesc) {
    return log.operationDesc
  }
  
  const operationType = log.operationType || log.operation_type || ''
  const tableName = log.tableName || log.table_name || ''
  const username = log.username || '未知用户'
  
  const typeMap = {
    'CREATE': '新增',
    'UPDATE': '更新',
    'DELETE': '删除',
    'QUERY': '查询'
  }
  
  const tableMap = {
    'user': '用户',
    'course': '课程',
    'question': '题目'
  }
  
  const type = typeMap[operationType] || operationType
  const table = tableMap[tableName] || tableName
  
  return `${username}${type}了${table}`
}

// 加载周登录统计数据
const loadWeeklyLoginStats = async (role) => {
  try {
    const url = role === 'student' ? '/xiaozhi/login-log/student/weekly' : '/xiaozhi/login-log/teacher/weekly'
    const res = await http.get({ url })
    
    if (res.code === 200 || res.code === 0) {
      const data = res.data || {}
      // 将数据转换为数组格式：周一、周二、...、周日
      const weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
      const counts = weekDays.map(day => data[day] || 0)
      weeklyLoginData.value[role] = counts
      console.log(`✅ ${role === 'student' ? '学生' : '教师'}周登录统计加载成功:`, counts)
    } else {
      console.error(`❌ 获取${role === 'student' ? '学生' : '教师'}周登录统计失败:`, res.message)
      weeklyLoginData.value[role] = [0, 0, 0, 0, 0, 0, 0]
    }
  } catch (error) {
    console.error(`❌ 加载${role === 'student' ? '学生' : '教师'}周登录统计异常:`, error)
    weeklyLoginData.value[role] = [0, 0, 0, 0, 0, 0, 0]
  }
}

// 切换活跃度角色
const handleActivityRoleChange = async (role) => {
  activityRole.value = role
  // 如果该角色的数据还没有加载，则加载
  if (weeklyLoginData.value[role].every(count => count === 0)) {
    await loadWeeklyLoginStats(role)
  }
}

onMounted(() => {
  loadUserList()
  loadOperationLogs()
  // 加载学生和教师的周登录统计数据
  loadWeeklyLoginStats('student')
  loadWeeklyLoginStats('teacher')
})
</script>

<style scoped>
.user-management-container {
  height: 100%;
  width: 100%;
  color: #fff;
  font-family: "Microsoft YaHei", sans-serif;
  overflow: hidden; /* 防止整体溢出 */
  display: flex;
  flex-direction: column;
}

.user-layout {
  display: flex;
  height: 100%;
  width: 100%;
  padding: 0 10px;
  gap: 15px;
  overflow: hidden; /* 防止布局溢出 */
  min-width: 0; /* 允许flex子元素收缩 */
  box-sizing: border-box; /* 确保padding包含在宽度内 */
}

.column {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.left-col,
.right-col {
  width: 25%;
  min-width: 280px; /* 减小最小宽度，确保能显示 */
  max-width: 25%; /* 限制最大宽度 */
  flex-shrink: 0; /* 防止被压缩 */
  flex-grow: 0; /* 防止自动扩展 */
  position: relative; /* 确保定位正常 */
  box-sizing: border-box; /* 确保padding包含在宽度内 */
}

/* 左侧栏不滚动，内容保持固定 */
.left-col {
  overflow: hidden;
}

/* 右侧栏允许上下滚动，方便查看“用户详情”和“操作日志” */
.right-col {
  overflow-y: auto;
  overflow-x: hidden;
}

.center-col {
  flex: 1;
  min-width: 0; /* 允许flex收缩，这是关键 */
  position: relative;
  display: flex;
  flex-direction: column;
  min-height: 0; /* 允许flex收缩 */
  overflow: hidden; /* 防止溢出 */
  box-sizing: border-box; /* 确保padding包含在宽度内 */
}

/* Panels */
.panel-box {
  background: rgba(8, 16, 45, 0.6);
  border: 1px solid rgba(0, 191, 255, 0.3);
  position: relative;
  flex: 1;
  display: flex;
  flex-direction: column;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
}

.panel-header {
  height: 36px;
  line-height: 36px;
  padding-left: 20px;
  background: linear-gradient(90deg, rgba(0, 191, 255, 0.2) 0%, transparent 100%);
  border-bottom: 1px solid rgba(0, 191, 255, 0.2);
  font-size: 16px;
  font-weight: bold;
  color: #00f2fe;
  position: relative;
}

.panel-header::before {
  content: '';
  position: absolute;
  left: 5px;
  top: 10px;
  width: 4px;
  height: 16px;
  background: #00f2fe;
}

.panel-content {
  flex: 1;
  padding: 10px;
  position: relative;
  /* 让列控制滚动，单个面板内部不再出现滚动条 */
  overflow: hidden;
}

/* Corners */
.corner-tl, .corner-tr, .corner-bl, .corner-br {
  position: absolute;
  width: 10px;
  height: 10px;
  border: 2px solid #00bfff;
}
.corner-tl { top: -1px; left: -1px; border-right: none; border-bottom: none; }
.corner-tr { top: -1px; right: -1px; border-left: none; border-bottom: none; }
.corner-bl { bottom: -1px; left: -1px; border-right: none; border-top: none; }
.corner-br { bottom: -1px; right: -1px; border-left: none; border-top: none; }

/* Charts & Layouts */
.chart { width: 100%; height: 100%; }
.flex-row { display: flex; align-items: center; height: 100%; }
.space-around { justify-content: space-around; }

.chart-wrapper-circle {
  width: 140px;
  height: 140px;
  position: relative;
}
.center-text {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
}
.center-text .num { font-size: 20px; font-weight: bold; color: #fff; }
.center-text .label { font-size: 10px; color: #aaa; }

.legend-list {
  flex: 1;
  padding-left: 10px;
  font-size: 12px;
}
.legend-item {
  display: flex;
  align-items: center;
  margin-bottom: 5px;
  justify-content: space-between;
}
.dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; margin-right: 5px; }
.name { color: #ccc; flex: 1; }
.val { color: #fff; font-weight: bold; margin-right: 10px; }
.pct { color: #00bfff; }

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}
.stat-icon {
  font-size: 32px;
  color: #00bfff;
}
.stat-info {
  text-align: center;
}
.stat-name {
  font-size: 12px;
  color: #aaa;
  margin-bottom: 5px;
}
.stat-val {
  font-size: 18px;
  font-weight: bold;
  color: #fff;
}

/* Center Column */
.user-management-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: 
    linear-gradient(180deg, rgba(8, 16, 45, 0.5) 0%, rgba(8, 16, 45, 0.65) 100%),
    url('@/assets/images/用户管理.jpg') center/cover no-repeat;
  border: 1px solid rgba(0, 191, 255, 0.3);
  border-radius: 8px;
  padding: 20px;
  overflow: hidden;
  min-height: 0;
  position: relative;
}

.top-data-row {
  display: flex;
  justify-content: space-between;
  padding: 0 20px;
  margin-bottom: 20px;
  flex-shrink: 0; /* 防止顶部数据被压缩 */
  position: relative;
  z-index: 1;
}

.data-item {
  text-align: center;
  position: relative;
}
.data-label { color: #00bfff; font-size: 12px; margin-bottom: 5px; }
.data-num { font-size: 28px; font-family: 'Impact', sans-serif; color: #fff; text-shadow: 0 0 10px #00bfff; }
.data-decoration { height: 2px; width: 40px; background: #00bfff; margin: 5px auto; box-shadow: 0 0 5px #00bfff; }

.user-list-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden; /* 改为hidden，让子元素控制滚动 */
  min-height: 0; /* 确保flex布局正常工作 */
  position: relative; /* 添加相对定位 */
  z-index: 1;
}

.user-list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  gap: 15px;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 15px;
}

.add-btn {
  background: linear-gradient(135deg, #00bfff, #00f2fe);
  border: none;
  color: #fff;
  font-weight: bold;
  box-shadow: 0 0 10px rgba(0, 191, 255, 0.5);
  transition: all 0.3s;
}

.add-btn:hover {
  background: linear-gradient(135deg, #00f2fe, #00bfff);
  box-shadow: 0 0 15px rgba(0, 191, 255, 0.8);
  transform: translateY(-2px);
}

.role-filter {
  display: flex;
  gap: 10px;
}

.role-btn {
  background: rgba(0, 191, 255, 0.1);
  border: 1px solid rgba(0, 191, 255, 0.3);
  color: #fff;
}

.role-btn.active {
  background: rgba(0, 191, 255, 0.3);
  border-color: #00bfff;
  color: #00bfff;
}

.activity-filter {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
  justify-content: center;
}

.activity-role-btn {
  background: rgba(0, 191, 255, 0.1);
  border: 1px solid rgba(0, 191, 255, 0.3);
  color: #fff;
  min-width: 80px;
}

.activity-role-btn.active {
  background: rgba(0, 191, 255, 0.3);
  border-color: #00bfff;
  color: #00bfff;
}

.search-box {
  flex: 1;
  max-width: 300px;
  min-width: 200px;
}

.search-box :deep(.el-input__wrapper) {
  background: rgba(0, 191, 255, 0.1);
  border: 1px solid rgba(0, 191, 255, 0.3);
}

.search-box :deep(.el-input__inner) {
  color: #fff;
}

.user-table-container {
  flex: 1;
  overflow-x: auto; /* 保留水平滚动条（底部） */
  overflow-y: auto; /* 启用垂直滚动条（右侧） */
  margin-bottom: 15px;
  min-height: 0; /* 允许flex收缩 */
  max-height: calc(100vh - 350px); /* 设置最大高度，确保滚动条出现 */
  width: 100%; /* 确保占满宽度 */
  position: relative; /* 确保定位正常 */
  /* 确保表格容器有明确的高度限制 */
  display: flex;
  flex-direction: column;
}

/* 自定义滚动条样式 */
.user-table-container::-webkit-scrollbar {
  width: 8px; /* 垂直滚动条宽度 */
  height: 8px; /* 水平滚动条高度 */
}

.user-table-container::-webkit-scrollbar-track {
  background: rgba(0, 191, 255, 0.1);
  border-radius: 4px;
}

.user-table-container::-webkit-scrollbar-thumb {
  background: rgba(0, 191, 255, 0.5);
  border-radius: 4px;
  transition: background 0.3s;
}

.user-table-container::-webkit-scrollbar-thumb:hover {
  background: rgba(0, 191, 255, 0.8);
}

.user-table-container :deep(.el-table) {
  background: transparent !important;
  color: #fff;
  width: 100%;
  min-width: 1350px; /* 增加最小宽度，确保所有列都能显示且不重合 */
}

.user-table-container :deep(.el-table) {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.user-table-container :deep(.el-table__body-wrapper) {
  flex: 1;
  overflow-x: auto !important; /* 允许水平滚动 */
  overflow-y: auto !important; /* 允许垂直滚动 */
  min-height: 0; /* 允许flex收缩 */
}

.user-table-container :deep(.el-table__header-wrapper) {
  overflow-x: hidden !important; /* 表头不需要水平滚动 */
  overflow-y: hidden !important; /* 表头不需要垂直滚动 */
}

.user-table-container :deep(.el-table__inner-wrapper) {
  overflow: visible !important; /* 让表格内容自然展开 */
}

.user-table-container :deep(.el-table) {
  overflow: visible !important; /* 让表格内容自然展开 */
}

.user-table-container :deep(.el-table__body) {
  /* 表格主体高度由内容决定 */
}

.user-table-container :deep(.el-table__body) {
  background: transparent !important;
}

.user-table-container :deep(.el-table__body tr) {
  background: transparent !important;
}

.user-table-container :deep(.el-table__body td) {
  background: transparent !important;
  color: #fff !important;
}

.user-table-container :deep(.el-table__body tr.hover-row) {
  background-color: rgba(0, 191, 255, 0.1) !important;
}

.user-table-container :deep(.el-table__body tr.hover-row td.el-table__cell) {
  background-color: rgba(0, 191, 255, 0.1) !important;
  color: #fff !important;
}

.user-table-container :deep(.el-table__body tr:hover) {
  background-color: rgba(0, 191, 255, 0.1) !important;
}

.user-table-container :deep(.el-table__body tr:hover td.el-table__cell) {
  background-color: rgba(0, 191, 255, 0.1) !important;
  color: #fff !important;
}

.user-table-container :deep(.el-table tbody tr.hover-row > td.el-table__cell) {
  background-color: rgba(0, 191, 255, 0.1) !important;
  color: #fff !important;
}

.user-table-container :deep(.el-table tbody tr:hover > td.el-table__cell) {
  background-color: rgba(0, 191, 255, 0.1) !important;
  color: #fff !important;
}

.user-table-container :deep(.el-table__row--hover) {
  background-color: rgba(0, 191, 255, 0.1) !important;
}

.user-table-container :deep(.el-table__row--hover td) {
  background-color: rgba(0, 191, 255, 0.1) !important;
  color: #fff !important;
}

.user-table-container :deep(.el-table th) {
  background: rgba(0, 191, 255, 0.1);
  color: #00bfff;
  border-bottom: 1px solid rgba(0, 191, 255, 0.3);
}

.user-table-container :deep(.el-table td) {
  border-bottom: 1px solid rgba(0, 191, 255, 0.1);
}

.user-table-container :deep(.el-table tr) {
  background: transparent;
}

.user-table-container :deep(.el-table tr:hover) {
  background: rgba(0, 191, 255, 0.1) !important;
}

.user-table-container :deep(.el-table tr:hover td) {
  background: rgba(0, 191, 255, 0.1) !important;
  color: #fff !important;
}

.user-table-container :deep(.el-table tbody tr:hover > td) {
  background-color: rgba(0, 191, 255, 0.1) !important;
  color: #fff !important;
}

.user-table-container :deep(.el-table tbody tr:hover > td.el-table__cell) {
  background-color: rgba(0, 191, 255, 0.1) !important;
  color: #fff !important;
}

.user-table-container :deep(.el-table__row:hover) {
  background-color: rgba(0, 191, 255, 0.1) !important;
}

.user-table-container :deep(.el-table__row:hover td) {
  background-color: rgba(0, 191, 255, 0.1) !important;
  color: #fff !important;
}

.user-table-container :deep(.el-table__row:hover td.el-table__cell) {
  background-color: rgba(0, 191, 255, 0.1) !important;
  color: #fff !important;
}

/* 确保所有可能的悬停状态都不会变成白色 */
.user-table-container :deep(.el-table tbody tr.hover-row),
.user-table-container :deep(.el-table tbody tr:hover),
.user-table-container :deep(.el-table__row--hover),
.user-table-container :deep(.el-table__row:hover) {
  background-color: rgba(0, 191, 255, 0.1) !important;
}

.user-table-container :deep(.el-table tbody tr.hover-row td),
.user-table-container :deep(.el-table tbody tr.hover-row td.el-table__cell),
.user-table-container :deep(.el-table tbody tr:hover td),
.user-table-container :deep(.el-table tbody tr:hover td.el-table__cell),
.user-table-container :deep(.el-table__row--hover td),
.user-table-container :deep(.el-table__row--hover td.el-table__cell),
.user-table-container :deep(.el-table__row:hover td),
.user-table-container :deep(.el-table__row:hover td.el-table__cell) {
  background-color: rgba(0, 191, 255, 0.1) !important;
  color: #fff !important;
}

.user-table-container :deep(.el-table tbody tr.hover-row > td) {
  background-color: rgba(0, 191, 255, 0.1) !important;
}

.user-table-container :deep(.el-table tr.selected-row) {
  background: rgba(0, 191, 255, 0.2) !important;
}

.user-table-container :deep(.el-table tr.selected-row td) {
  background: rgba(0, 191, 255, 0.2) !important;
}

/* 操作列样式 - 已移除固定定位，现在随表格一起滚动 */

.operation-buttons {
  display: flex;
  gap: 12px;
  justify-content: center;
  align-items: center;
  white-space: nowrap; /* 防止按钮换行 */
  padding: 0 5px; /* 增加内边距 */
}

/* 增大操作按钮的字体和大小 */
.operation-buttons :deep(.el-button) {
  font-size: 14px;
  padding: 8px 12px;
  font-weight: 500;
}

.user-table-container :deep(.operation-column) {
  min-width: 150px !important; /* 确保最小宽度，适应更大的按钮 */
}

/* 底部导航菜单已移至 AdminHome.vue 统一管理 */


/* Right Column */
.user-detail {
  padding: 10px;
}

.detail-avatar {
  text-align: center;
  margin-bottom: 20px;
}

.detail-info {
  font-size: 14px;
}

.detail-item {
  display: flex;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid rgba(0, 191, 255, 0.1);
}

.detail-item .label {
  color: #00bfff;
  min-width: 80px;
}

.detail-item .value {
  color: #fff;
  flex: 1;
}

.empty-detail {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
}

.empty-text {
  color: #aaa;
  font-size: 14px;
}

.log-list {
  font-size: 12px;
}

.log-item {
  padding: 8px 0;
  border-bottom: 1px solid rgba(0, 191, 255, 0.1);
}

.log-time {
  color: #00bfff;
  font-size: 11px;
  margin-bottom: 3px;
}

.log-action {
  color: #ccc;
}

/* 对话框样式 */
:deep(.el-dialog) {
  background: rgba(8, 16, 45, 0.95);
  border: 1px solid rgba(0, 191, 255, 0.3);
  color: #fff;
}

:deep(.el-dialog__header) {
  background: linear-gradient(90deg, rgba(0, 191, 255, 0.2) 0%, transparent 100%);
  border-bottom: 1px solid rgba(0, 191, 255, 0.2);
  padding: 20px;
}

:deep(.el-dialog__title) {
  color: #00f2fe;
  font-weight: bold;
}

:deep(.el-dialog__body) {
  padding: 20px;
  color: #fff;
}

:deep(.el-form-item__label) {
  color: #00bfff;
}

:deep(.el-input__wrapper) {
  background: rgba(0, 191, 255, 0.1);
  border: 1px solid rgba(0, 191, 255, 0.3);
}

:deep(.el-input__inner) {
  color: #fff;
}

:deep(.el-select .el-input__wrapper) {
  background: rgba(0, 191, 255, 0.1);
  border: 1px solid rgba(0, 191, 255, 0.3);
}

:deep(.el-select .el-input__inner) {
  color: #fff;
}

:deep(.el-dialog__footer) {
  border-top: 1px solid rgba(0, 191, 255, 0.2);
  padding: 15px 20px;
}

:deep(.el-button) {
  border-color: rgba(0, 191, 255, 0.3);
}

:deep(.el-button--primary) {
  background: linear-gradient(135deg, #00bfff, #00f2fe);
  border: none;
}

:deep(.el-button--primary:hover) {
  background: linear-gradient(135deg, #00f2fe, #00bfff);
}
</style>

