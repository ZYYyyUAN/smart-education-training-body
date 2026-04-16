<template>
  <div class="notification-container">
    <!-- 左侧导航栏 -->
    <div class="sidebar">
      <!-- 导航项 -->
      <div 
        class="nav-item" 
        :class="{ active: activeTab === 'notification' }"
        @click="switchTab('notification')"
      >
        <div class="nav-icon">🔔</div>
        <span class="nav-text">通知</span>
      </div>
      <div 
        class="nav-item" 
        :class="{ active: activeTab === 'message' }"
        @click="switchTab('message')"
      >
        <div class="nav-icon">✉️</div>
        <span class="nav-text">私信</span>
        <span v-if="unreadCount > 0" class="unread-badge">{{ unreadCount }}</span>
      </div>

    </div>

    <!-- 右侧内容区域 -->
    <div class="main-content">
      <!-- 通知页面 -->
      <div v-if="activeTab === 'notification'" class="notification-page">
        <!-- 标题栏 -->
        <div class="content-header">
          <h2>全部通知({{ notifications.length }})</h2>
        </div>

        <!-- 通知列表 -->
        <div class="notification-list">
          <div v-if="notifications.length === 0" class="empty-state">
            <el-empty description="暂无通知" />
          </div>
          
          <div 
            v-for="notification in notifications" 
            :key="notification.id" 
            class="notification-item"
            @click="openNotification(notification)"
          >
            <!-- 通知标题 -->
            <div class="notification-header">
              <h3 class="notification-title">{{ notification.title }}</h3>
              <div class="notification-badge" v-if="notification.isImportant">🔴</div>
            </div>
            
            <!-- 通知内容 -->
            <div class="notification-content">
              <p class="notification-text">{{ notification.content }}</p>
              <div class="view-more">
                <a href="#" class="view-all-link">[查看全部]</a>
              </div>
            </div>
            
            <!-- 通知元信息 -->
            <div class="notification-meta">
              <span class="notification-source">来自: {{ notification.source }}</span>
              <span class="notification-date">{{ formatDate(notification.date) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 私信页面 -->
      <div v-if="activeTab === 'message'" class="message-page">
        <!-- 私信标题栏 -->
        <div class="content-header">
          <h2>私信消息</h2>
          <button class="new-message-btn" @click="showNewMessageDialog = true">
            <span class="btn-icon">✏️</span>
            发送私信
          </button>
        </div>

        <!-- 私信列表 -->
        <div class="message-list">
          <div v-if="messages.length === 0" class="empty-state">
            <el-empty description="暂无私信" />
          </div>
          
          <div 
            v-for="message in messages" 
            :key="message.id" 
            class="message-item"
            :class="{ unread: !message.isRead }"
            @click="openMessage(message)"
          >
            <!-- 头像 -->
            <div class="message-avatar">
              <img 
                v-if="message.senderAvatar" 
                :src="message.senderAvatar" 
                :alt="message.senderName"
                class="avatar-img"
              />
              <div v-else class="avatar-placeholder">
                {{ message.senderName.charAt(0) }}
              </div>
            </div>
            
            <!-- 消息内容 -->
            <div class="message-content">
              <div class="message-header">
                <h4 class="sender-name">{{ message.senderName }}</h4>
                <span class="message-time">{{ formatTime(message.timestamp) }}</span>
              </div>
              <p class="message-preview">{{ message.content }}</p>
            </div>
            
            <!-- 未读标识 -->
            <div v-if="!message.isRead" class="unread-indicator"></div>
          </div>
        </div>
      </div>
    </div>

    <!-- 发送私信对话框 -->
    <el-dialog 
      v-model="showNewMessageDialog" 
      title="发送私信" 
      width="500px"
      :before-close="closeNewMessageDialog"
    >
      <div class="new-message-form">
        <div class="form-group">
          <label>收件人:</label>
          <el-select 
            v-model="newMessage.recipientId" 
            placeholder="选择收件人"
            filterable
            style="width: 100%"
          >
            <el-option
              v-for="user in userList"
              :key="user.id"
              :label="user.realName || user.username"
              :value="user.id"
            />
          </el-select>
        </div>
        
        <div class="form-group">
          <label>主题:</label>
          <el-input 
            v-model="newMessage.subject" 
            placeholder="输入消息主题"
            maxlength="50"
            show-word-limit
          />
        </div>
        
        <div class="form-group">
          <label>内容:</label>
          <el-input 
            v-model="newMessage.content" 
            type="textarea" 
            :rows="4"
            placeholder="输入消息内容"
            maxlength="500"
            show-word-limit
          />
        </div>
      </div>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="closeNewMessageDialog">取消</el-button>
          <el-button type="primary" @click="sendMessage" :loading="sending">
            发送
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 私信详情对话框 -->
    <el-dialog 
      v-model="showMessageDetail" 
      :title="currentMessage?.subject || '私信详情'" 
      width="600px"
      :before-close="closeMessageDetail"
    >
      <div v-if="currentMessage" class="message-detail">
        <div class="message-info">
          <div class="info-row">
            <span class="label">发件人:</span>
            <span class="value">{{ currentMessage.senderName }}</span>
          </div>
          <div class="info-row">
            <span class="label">时间:</span>
            <span class="value">{{ formatTime(currentMessage.timestamp) }}</span>
          </div>
        </div>
        
        <div class="message-body">
          <p>{{ currentMessage.content }}</p>
        </div>
        
        <div class="message-actions">
          <el-button type="primary" @click="replyMessage">回复</el-button>
          <el-button @click="deleteLocalMessage">删除</el-button>
            </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch, onBeforeUnmount } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
// import webSocketService from '@/utils/websocket-stomp.js'
import { getStudentMessages, markMessageAsRead, deleteMessage, getUnreadMessageCount, getStudentNotifications, markNotificationAsRead, getUnreadNotificationCount } from '@/api/notification.js'

// 当前激活的标签页
const activeTab = ref('notification')

// 通知数据
const notifications = ref([])

// 私信数据
const messages = ref([
  {
    id: 1,
    senderId: 101,
    senderName: '张老师',
    senderAvatar: null,
    subject: '关于作业提交的问题',
    content: '同学你好，我看到你的作业还没有提交，请问是遇到了什么困难吗？如果有问题可以随时联系我。',
    timestamp: Date.now() - 3600000, // 1小时前
    isRead: false
  },
  {
    id: 2,
    senderId: 102,
    senderName: '李助教',
    senderAvatar: null,
    subject: '课程资料更新通知',
    content: '本周的课程资料已经更新，包括新的练习题和参考答案，请及时下载查看。',
    timestamp: Date.now() - 7200000, // 2小时前
    isRead: true
  },
  {
    id: 3,
    senderId: 103,
    senderName: '王教授',
    senderAvatar: null,
    subject: '学术讨论邀请',
    content: '下周三下午有一个关于人工智能在教育中应用的学术讨论会，如果你感兴趣的话可以参加。',
    timestamp: Date.now() - 86400000, // 1天前
    isRead: true
  }
])

// 用户列表（用于选择收件人）
const userList = ref([
  { id: 101, realName: '张老师', username: 'zhang_teacher' },
  { id: 102, realName: '李助教', username: 'li_assistant' },
  { id: 103, realName: '王教授', username: 'wang_professor' },
  { id: 104, realName: '陈老师', username: 'chen_teacher' },
  { id: 105, realName: '刘助教', username: 'liu_assistant' }
])

// 对话框状态
const showNewMessageDialog = ref(false)
const showMessageDetail = ref(false)
const currentMessage = ref(null)
const sending = ref(false)

// 新消息表单
const newMessage = ref({
  recipientId: '',
  subject: '',
  content: ''
})

// 计算未读消息数量
const unreadCount = computed(() => {
  return messages.value.filter(msg => !msg.isRead).length
})

// 切换标签页
const switchTab = (tab) => {
  console.log('切换标签页:', tab)
  activeTab.value = tab
  console.log('当前标签页:', activeTab.value)
  
  // 添加路由调试信息
  console.log('当前路由路径:', window.location.pathname)
  console.log('当前路由hash:', window.location.hash)
}

// 格式化日期
const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

// 格式化时间
const formatTime = (timestamp) => {
  const now = Date.now()
  const diff = now - timestamp
  
  if (diff < 60000) { // 1分钟内
    return '刚刚'
  } else if (diff < 3600000) { // 1小时内
    return `${Math.floor(diff / 60000)}分钟前`
  } else if (diff < 86400000) { // 1天内
    return `${Math.floor(diff / 3600000)}小时前`
  } else {
    return new Date(timestamp).toLocaleDateString('zh-CN')
  }
}

// 打开通知详情
const openNotification = async (notification) => {
  // 标记通知为已读
  try {
    const studentId = localStorage.getItem('studentId') || 1
    await markNotificationAsRead(notification.id, studentId)
    console.log('通知已标记为已读:', notification.id)
  } catch (error) {
    console.error('标记通知已读失败:', error)
  }
  
  // 显示通知详情（可以扩展为弹窗显示完整内容）
  ElMessage.info(`查看通知: ${notification.title}`)
}

// 打开私信详情
const openMessage = async (message) => {
  currentMessage.value = message
  showMessageDetail.value = true
  
  // 标记为已读
  if (!message.isRead) {
    try {
      await markMessageAsRead(message.id)
      message.isRead = true
    } catch (error) {
      console.error('标记已读失败:', error)
    }
  }
}

// 关闭私信详情
const closeMessageDetail = () => {
  showMessageDetail.value = false
  currentMessage.value = null
}

// 关闭发送私信对话框
const closeNewMessageDialog = () => {
  showNewMessageDialog.value = false
  // 重置表单
  newMessage.value = {
    recipientId: '',
    subject: '',
    content: ''
  }
}

// 发送私信
const sendMessage = async () => {
  if (!newMessage.value.recipientId || !newMessage.value.subject || !newMessage.value.content) {
    ElMessage.warning('请填写完整信息')
    return
  }
  
  sending.value = true
  
  try {
    // 模拟发送
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    // 添加到消息列表（模拟）
    const recipient = userList.value.find(u => u.id === newMessage.value.recipientId)
    const newMsg = {
      id: Date.now(),
      senderId: 100, // 当前用户ID
      senderName: '我',
      senderAvatar: null,
      subject: newMessage.value.subject,
      content: newMessage.value.content,
      timestamp: Date.now(),
      isRead: true
    }
    
    messages.value.unshift(newMsg)
    
    ElMessage.success('私信发送成功')
    closeNewMessageDialog()
  } catch (error) {
    ElMessage.error('发送失败，请重试')
  } finally {
    sending.value = false
  }
}

// 回复私信
const replyMessage = () => {
  if (currentMessage.value) {
    newMessage.value.recipientId = currentMessage.value.senderId
    newMessage.value.subject = `回复: ${currentMessage.value.subject}`
    newMessage.value.content = ''
    
    showMessageDetail.value = false
    showNewMessageDialog.value = true
  }
}

// 删除私信
const deleteLocalMessage = async () => {
  try {
    await ElMessageBox.confirm('确定要删除这条私信吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    if (currentMessage.value) {
      // 调用API删除私信
      try {
        await deleteMessage(currentMessage.value.id)
        // 从本地列表中移除
        const index = messages.value.findIndex(msg => msg.id === currentMessage.value.id)
        if (index > -1) {
          messages.value.splice(index, 1)
        }
        ElMessage.success('删除成功')
        closeMessageDetail()
      } catch (error) {
        ElMessage.error('删除失败，请重试')
        console.error('删除私信失败:', error)
      }
    }
  } catch {
    // 用户取消删除
  }
}

// 获取通知数据
const fetchNotifications = async () => {
  try {
    const studentId = localStorage.getItem('studentId') || 1
    console.log('获取通知数据，学生ID:', studentId)
    const response = await getStudentNotifications(studentId)
    console.log('通知API响应:', response)
    
    // 检查响应数据结构
    if (response && response.data && response.data.data) {
      console.log('通知数据:', response.data.data)
      
      // 处理API返回的数据格式
      const processedNotifications = response.data.data.map(notification => {
        // 处理时间格式 - 后端返回的是数组格式 [年, 月, 日, 时, 分, 秒]
        let formattedDate = new Date().toISOString().split('T')[0] // 默认今天
        if (notification.sendTime) {
          if (Array.isArray(notification.sendTime)) {
            // 数组格式: [2025, 9, 1, 18, 0] -> new Date(2025, 8, 1, 18, 0) 注意月份要减1
            const [year, month, day, hour = 0, minute = 0, second = 0] = notification.sendTime
            const date = new Date(year, month - 1, day, hour, minute, second)
            formattedDate = date.toISOString().split('T')[0]
          } else {
            // 字符串格式
            formattedDate = new Date(notification.sendTime).toISOString().split('T')[0]
          }
        }
        
        return {
          id: notification.id,
          title: notification.title,
          content: notification.content,
          source: notification.senderName || '系统',
          date: formattedDate,
          isImportant: notification.isImportant === 1
        }
      })
      
      console.log('处理后的通知数据:', processedNotifications)
      notifications.value = processedNotifications
    } else {
      console.log('通知响应数据为空或格式不正确')
      notifications.value = []
    }
  } catch (error) {
    ElMessage.error('获取通知失败')
    console.error('获取通知失败:', error)
    notifications.value = []
  }
}

// 获取私信数据
const fetchMessages = async () => {
  try {
    const studentId = localStorage.getItem('studentId') || 1
    console.log('获取私信数据，学生ID:', studentId)
    const response = await getStudentMessages(studentId)
    console.log('API响应:', response)
    
    // 检查响应数据结构 - 数据在 response.data.data 中
    if (response && response.data && response.data.data) {
      console.log('response.data.data类型:', typeof response.data.data)
      console.log('response.data.data是否为数组:', Array.isArray(response.data.data))
      console.log('response.data.data内容:', response.data.data)
      
      // 确保data是数组
      const messageArray = Array.isArray(response.data.data) ? response.data.data : []
      console.log('messageArray长度:', messageArray.length)
      
      // 处理API返回的数据格式
      const processedMessages = messageArray.map(message => {
        console.log('处理消息:', message)
        
        // 处理时间格式 - 后端返回的是数组格式 [年, 月, 日, 时, 分, 秒]
        let timestamp = Date.now() // 默认当前时间
        if (message.sendTime) {
          if (Array.isArray(message.sendTime)) {
            // 数组格式: [2025, 9, 1, 18, 0] -> new Date(2025, 8, 1, 18, 0) 注意月份要减1
            const [year, month, day, hour = 0, minute = 0, second = 0] = message.sendTime
            timestamp = new Date(year, month - 1, day, hour, minute, second).getTime()
          } else {
            // 字符串格式
            timestamp = new Date(message.sendTime).getTime()
          }
        }
        
        return {
          ...message,
          timestamp: timestamp,
          // 确保isRead是布尔值
          isRead: message.isRead === 1
        }
      })
      
      console.log('处理后的私信数据:', processedMessages)
      messages.value = processedMessages
      console.log('messages.value设置后:', messages.value)
      console.log('messages.value长度:', messages.value.length)
    } else {
      console.log('响应数据为空或格式不正确')
      messages.value = []
    }
  } catch (error) {
    ElMessage.error('获取私信失败')
    console.error('获取私信失败:', error)
    messages.value = []
  }
}

// 创建watch监听器的停止函数
let stopWatch = null

onMounted(() => {
  fetchNotifications()
  fetchMessages()
  
  // 监听messages数组变化
  stopWatch = watch(messages, (newMessages) => {
    console.log('messages数组发生变化:', newMessages)
    console.log('messages数组长度:', newMessages.length)
  }, { deep: true })
  
  // 暂时注释掉WebSocket连接，等后端WebSocket配置完成后再启用
  // const studentId = localStorage.getItem('studentId') || 1
  // webSocketService.connect(studentId, 'student')
  
  // 监听私信接收事件
  // webSocketService.on('private_message_received', (data) => {
  //   // 将新私信添加到列表
  //   const newMessage = {
  //     id: data.messageId || Date.now(),
  //     senderId: data.senderId,
  //     senderName: data.senderName || '老师',
  //     senderAvatar: data.senderAvatar,
  //     subject: data.subject || '新私信',
  //     content: data.content || '您有一条新的私信',
  //     timestamp: Date.now(),
  //     isRead: false
  //   }
  //   
  //   messages.value.unshift(newMessage)
  //   
  //   // 更新未读数量显示
  //   // 这里可以触发未读数量的重新计算
  // })
  // 
  // 监听通知接收事件
  // webSocketService.on('notification_received', (data) => {
  //   // 将新通知添加到列表
  //   const newNotification = {
  //     id: data.notificationId || Date.now(),
  //     title: data.title || '新通知',
  //     content: data.content || '您有一条新的通知',
  //     source: data.source || '系统',
  //     date: new Date().toISOString().split('T')[0],
  //     isImportant: data.isImportant || false
  //   }
  //   
  //   notifications.value.unshift(newNotification)
  // })
})

// 组件卸载时清理监听器
onBeforeUnmount(() => {
  if (stopWatch) {
    stopWatch()
    console.log('清理messages监听器')
  }
})
</script>

<style scoped>
.notification-container {
  display: flex;
  height: 100vh;
  background-color: #f5f5f5;
}

/* 左侧导航栏 */
.sidebar {
  width: 200px;
  background-color: #fff;
  border-right: 1px solid #e0e0e0;
  padding: 20px 0;
  box-shadow: 2px 0 4px rgba(0, 0, 0, 0.1);
}

.nav-item {
  display: flex;
  align-items: center;
  padding: 15px 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  border-left: 4px solid transparent;
  position: relative;
}

.nav-item:hover {
  background-color: #f8f9fa;
}

.nav-item.active {
  background-color: #e3f2fd;
  border-left-color: #2196f3;
}

.nav-item.active .nav-text {
  color: #2196f3;
  font-weight: 600;
}

.nav-icon {
  font-size: 18px;
  margin-right: 12px;
  width: 24px;
  text-align: center;
}

.nav-text {
  font-size: 14px;
  color: #333;
  font-weight: 500;
  flex: 1;
}

.unread-badge {
  background-color: #f44336;
  color: white;
  font-size: 12px;
  padding: 2px 6px;
  border-radius: 10px;
  min-width: 20px;
  text-align: center;
  font-weight: 600;
}

/* 右侧内容区域 */
.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  background-color: #fff;
  box-shadow: none;
}

.content-header {
  padding: 20px 30px;
  border-bottom: 1px solid #e0e0e0;
  background-color: #fff;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.content-header h2 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #333;
}

.new-message-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.new-message-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.btn-icon {
  font-size: 16px;
}

/* 通知页面 */
.notification-page {
  display: flex;
  flex-direction: column;
  height: 100%;
}

/* 私信页面 */
.message-page {
  display: flex;
  flex-direction: column;
  height: 100%;
}

/* 通知列表 */
.notification-list {
  flex: 1;
  overflow-y: auto;
  padding: 0;
}

/* 私信列表 */
.message-list {
  flex: 1;
  overflow-y: auto;
  padding: 0;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 400px;
}

.notification-item {
  padding: 20px 30px;
  border-bottom: 1px solid #f0f0f0;
  transition: background-color 0.3s ease;
  cursor: pointer;
}

.notification-item:hover {
  background-color: #fafafa;
}

.notification-item:last-child {
  border-bottom: none;
}

/* 私信项 */
.message-item {
  padding: 20px 30px;
  border-bottom: 1px solid #f0f0f0;
  transition: all 0.3s ease;
  cursor: pointer;
  display: flex;
  align-items: flex-start;
  gap: 15px;
  position: relative;
}

.message-item:hover {
  background-color: #fafafa;
}

.message-item.unread {
  background-color: #f0f8ff;
}

.message-item.unread:hover {
  background-color: #e6f3ff;
}

.message-item:last-child {
  border-bottom: none;
}

.message-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  overflow: hidden;
  flex-shrink: 0;
}

.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: 600;
}

.message-content {
  flex: 1;
  min-width: 0;
}

.message-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.sender-name {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.message-time {
  font-size: 12px;
  color: #999;
  font-weight: 400;
}

.message-preview {
  margin: 0;
  font-size: 14px;
  color: #666;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.unread-indicator {
  width: 8px;
  height: 8px;
  background-color: #f44336;
  border-radius: 50%;
  position: absolute;
  top: 20px;
  right: 20px;
}

/* 通知标题 */
.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 10px;
}

.notification-title {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #333;
  line-height: 1.4;
  flex: 1;
  margin-right: 10px;
}

.notification-badge {
  font-size: 12px;
  flex-shrink: 0;
}

/* 通知内容 */
.notification-content {
  margin-bottom: 15px;
}

.notification-text {
  margin: 0 0 10px 0;
  font-size: 14px;
  color: #666;
  line-height: 1.6;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.view-more {
  margin-top: 8px;
}

.view-all-link {
  color: #2196f3;
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
}

.view-all-link:hover {
  text-decoration: underline;
}

/* 通知元信息 */
.notification-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  color: #999;
}

.notification-source {
  font-weight: 500;
}

.notification-date {
  font-weight: 400;
}

/* 发送私信表单 */
.new-message-form {
  padding: 20px 0;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #333;
}

/* 私信详情 */
.message-detail {
  padding: 20px 0;
}

.message-info {
  background-color: #f8f9fa;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.info-row {
  display: flex;
  margin-bottom: 8px;
}

.info-row:last-child {
  margin-bottom: 0;
}

.info-row .label {
  font-weight: 600;
  color: #666;
  width: 80px;
  flex-shrink: 0;
}

.info-row .value {
  color: #333;
}

.message-body {
  background-color: #fff;
  padding: 20px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  margin-bottom: 20px;
}

.message-body p {
  margin: 0;
  font-size: 14px;
  line-height: 1.6;
  color: #333;
}

.message-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

/* 滚动条样式 */
.notification-list::-webkit-scrollbar,
.message-list::-webkit-scrollbar {
  width: 6px;
}

.notification-list::-webkit-scrollbar-track,
.message-list::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.notification-list::-webkit-scrollbar-thumb,
.message-list::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.notification-list::-webkit-scrollbar-thumb:hover,
.message-list::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .notification-container {
    flex-direction: column;
  }
  
  .sidebar {
    width: 100%;
    height: auto;
    border-right: none;
    border-bottom: 1px solid #e0e0e0;
  }
  
  .nav-item {
    padding: 12px 20px;
  }
  
  .content-header {
    padding: 15px 20px;
    flex-direction: column;
    gap: 15px;
    align-items: flex-start;
  }
  
  .notification-item,
  .message-item {
    padding: 15px 20px;
  }
  
  .message-item {
    flex-direction: column;
    gap: 10px;
  }
  
  .message-avatar {
    width: 40px;
    height: 40px;
  }
  
  .unread-indicator {
    top: 15px;
    right: 15px;
  }
}
</style>
