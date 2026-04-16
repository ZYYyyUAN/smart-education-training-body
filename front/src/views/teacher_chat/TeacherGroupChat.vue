<template>
  <div class="teacher-chat-layout">
    <aside class="sidebar">
      <div class="sidebar-header">我的群聊</div>
      <div class="group-list" v-loading="loading">
        <div
          v-for="g in groups"
          :key="g.courseId"
          class="group-item"
          :class="{ active: g.courseId === activeCourse?.courseId }"
          @click="switchGroup(g)"
        >
          <div class="group-avatar">{{ g.courseName?.charAt(0) || '课' }}</div>
          <div class="group-info">
            <div class="group-title">
              {{ g.courseName }}
              <span v-if="unreadCount[g.courseId] > 0" class="unread-badge">{{ unreadCount[g.courseId] }}</span>
            </div>
            <div class="group-sub">课程ID：{{ g.courseId }}</div>
          </div>
        </div>
        <div v-if="!loading && groups.length === 0" class="empty">暂无群聊</div>
      </div>
    </aside>

    <section class="chat-pane" v-if="activeCourse">
      <WeChatGroupChat
        :key="String(activeCourse.courseId)"
        :course-id="String(activeCourse.courseId)"
        :course-name="activeCourse.courseName"
        :current-user="teacherName"
        :current-user-id="String(teacherId)"
        :show-teacher-badge="true"
      />
    </section>

    <section class="chat-pane" v-else>
      <div class="placeholder">请选择左侧群聊进入</div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import axios from 'axios'
import WeChatGroupChat from '@/views/course/components/WeChatGroupChat.vue'

// 简单从本地或后端获取教师信息（演示写死一个教师名/ID，可根据实际登录替换）
const teacherId = ref(2)
const teacherName = ref('老师')

const loading = ref(false)
const groups = ref([])
const activeCourse = ref(null)
const unreadCount = ref({})
const lastSeenMap = ref({})

const STORAGE_KEY = 'teacher_group_last_seen'

// 全局消息监听器
let globalMessageListener = null

// 监听全局消息事件
const setupGlobalMessageListener = () => {
  // 监听来自其他组件的消息事件
  window.addEventListener('newChatMessage', (event) => {
    const { courseId, message } = event.detail
    if (courseId && message) {
      // 只有在离开群聊后才增加未读计数
      if (!activeCourse.value || activeCourse.value.courseId !== courseId) {
        if (unreadCount.value[courseId] === undefined) {
          unreadCount.value[courseId] = 0
        }
        unreadCount.value[courseId]++
        console.log(`收到新消息，群聊 ${courseId} 未读消息: ${unreadCount.value[courseId]} (当前不在该群聊中)`)
      } else {
        // 当前正在该群聊中，不增加未读计数
        console.log(`收到新消息，群聊 ${courseId} 但当前正在该群聊中，不增加未读计数`)
      }
    }
  })
}

// 清理全局消息监听器
const cleanupGlobalMessageListener = () => {
  if (globalMessageListener) {
    window.removeEventListener('newChatMessage', globalMessageListener)
    globalMessageListener = null
  }
}

const loadLastSeen = () => {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    lastSeenMap.value = raw ? JSON.parse(raw) : {}
  } catch {
    lastSeenMap.value = {}
  }
}

const saveLastSeen = () => {
  try { localStorage.setItem(STORAGE_KEY, JSON.stringify(lastSeenMap.value)) } catch {}
}

const fetchGroups = async () => {
  loading.value = true
  try {
    // 优先调用后端群聊列表接口（若存在）
    // 期望返回：[{ courseId, courseName }]
    const { data } = await axios.get('/api/chat/groups/by-teacher', { params: { teacherId: teacherId.value } })
    const list = data?.data || []
    if (Array.isArray(list) && list.length) {
      groups.value = list
    } else {
      throw new Error('empty')
    }
  } catch {
    // 兜底：尝试从教师课程接口推断群聊（若你的后端有其他接口可在此替换）
    try {
      // 使用后端已有接口：根据教师ID获取课程
      const { data } = await axios.get('/api/xiaozhi/teacher/by-teacher', { params: { teacherId: teacherId.value } })
      const courses = (data?.data ?? data) || []
      const mapped = Array.from(
        new Map(
          (Array.isArray(courses) ? courses : [])
            .filter(it => it?.id && it?.courseName)
            .map(it => [it.id, { courseId: it.id, courseName: it.courseName }])
        ).values()
      )
      if (mapped.length) {
        groups.value = mapped
      } else {
        // 主动抛错，进入最终兜底
        throw new Error('no courses')
      }
    } catch {
      // 最终兜底：给出一个示例群聊，便于前端联调
      groups.value = [
        { courseId: 101, courseName: '示例课程A' },
        { courseId: 102, courseName: '示例课程B' }
      ]
    }
  } finally {
    loading.value = false
    if (!activeCourse.value && groups.value.length) {
      activeCourse.value = groups.value[0]
    }
    // 初始化未读计数与最近查看时间
    loadLastSeen()
    for (const g of groups.value) {
      if (unreadCount.value[g.courseId] == null) unreadCount.value[g.courseId] = 0
      if (!lastSeenMap.value[g.courseId]) lastSeenMap.value[g.courseId] = Date.now()
    }
    saveLastSeen()
    startUnreadPolling()
  }
}

const switchGroup = (g) => {
  // 如果切换到的是当前已激活的群聊，不做任何操作
  if (activeCourse.value && activeCourse.value.courseId === g.courseId) {
    console.log(`已经在群聊 ${g.courseName} 中，无需切换`)
    return
  }
  
  // 如果之前有活跃的群聊，更新其最后查看时间
  if (activeCourse.value) {
    lastSeenMap.value[activeCourse.value.courseId] = Date.now()
    saveLastSeen()
    console.log(`离开群聊 ${activeCourse.value.courseName}, 更新时间: ${new Date().toLocaleString()}`)
  }
  
  activeCourse.value = g
  // 进入新会话即清零未读，并更新最近查看时间
  unreadCount.value[g.courseId] = 0
  lastSeenMap.value[g.courseId] = Date.now()
  saveLastSeen()
  
  // 调试信息
  console.log(`切换到群聊: ${g.courseName}, 时间: ${new Date().toLocaleString()}`)
}

onMounted(fetchGroups)
onMounted(setupGlobalMessageListener)
onUnmounted(cleanupGlobalMessageListener)

// 轮询各群未读数（基于最近查看时间统计）
let unreadTimer = null
const startUnreadPolling = () => {
  if (unreadTimer) clearInterval(unreadTimer)
  const poll = async () => {
    if (!groups.value.length) return
    for (const g of groups.value) {
      if (activeCourse.value && g.courseId === activeCourse.value.courseId) continue
      try {
        const since = lastSeenMap.value[g.courseId] || 0
        const { data } = await axios.get('/api/chat/history', { params: { courseId: g.courseId, limit: 200, offset: 0 } })
        const list = data?.data || []
        let count = 0
        for (const it of list) {
          const arr = Array.isArray(it.sentAt) ? it.sentAt : null
          let ts = 0
          if (arr && arr.length >= 6) {
            const d = new Date(arr[0], arr[1] - 1, arr[2], arr[3], arr[4], arr[5])
            ts = d.getTime()
          } else if (typeof it.sentAt === 'string') {
            ts = new Date(it.sentAt.replace(' ', 'T')).getTime()
          }
          if (ts > since) count++
        }
        unreadCount.value[g.courseId] = count
        
        // 如果当前正在该群聊中，强制清零未读计数
        if (activeCourse.value && activeCourse.value.courseId === g.courseId) {
          unreadCount.value[g.courseId] = 0
          console.log(`当前正在群聊 ${g.courseName} 中，强制清零未读计数`)
        }
      } catch (error) {
        console.error(`获取群聊 ${g.courseId} 未读消息失败:`, error)
        // 出错时不重置计数，保持上次的有效值
      }
    }
  }
  poll()
  unreadTimer = setInterval(poll, 15000)
}
</script>

<style scoped>
.teacher-chat-layout {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 16px;
  height: 95vh;
  padding: 16px;
  box-sizing: border-box;
}
.sidebar {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,.06);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.sidebar-header {
  padding: 14px 16px;
  font-weight: 600;
  border-bottom: 1px solid #eee;
}
.group-list { overflow: auto; flex: 1; }
.group-item {
  display: flex; gap: 12px; padding: 12px 14px; cursor: pointer; align-items: center;
}
.group-item:hover { background: #f7f7f7; }
.group-item.active { background: #eef9f1; }
.group-avatar { width: 36px; height: 36px; border-radius: 8px; background: #07c160; color: #fff; display:flex; align-items:center; justify-content:center; font-weight:700; }
.group-info { overflow: hidden; }
.group-title { font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.unread-badge { margin-left: 8px; background: #ff4d4f; color: #fff; border-radius: 10px; padding: 0 6px; font-size: 12px; line-height: 18px; display: inline-block; min-width: 18px; text-align: center; }
.group-sub { font-size: 12px; color: #888; }
.chat-pane { 
  min-height: 100%; 
  display: flex; 
  padding: 0;
  width: 100%;
  overflow: hidden;
}
:deep(.wechat-chat) { 
  width: 100% !important; 
  height: 100% !important; 
  max-height: 100%;
}
.placeholder { height: 100%; display:flex; align-items:center; justify-content:center; color:#888; background:#fff; border-radius:12px; box-shadow: 0 2px 8px rgba(0,0,0,.06); }
</style>

