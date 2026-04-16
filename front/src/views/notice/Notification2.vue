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
        <el-form :model="newMessage" label-width="80px">
          <el-form-item label="收件人">
            <el-select 
              v-model="newMessage.recipientId" 
              placeholder="请选择收件人"
              style="width: 100%"
            >
              <el-option
                v-for="user in userList"
                :key="user.id"
                :label="user.realName"
                :value="user.id"
              />
            </el-select>
          </el-form-item>
          
          <el-form-item label="主题">
            <el-input 
              v-model="newMessage.subject" 
              placeholder="请输入消息主题"
              maxlength="50"
              show-word-limit
            />
          </el-form-item>
          
          <el-form-item label="内容">
            <el-input 
              v-model="newMessage.content" 
              type="textarea" 
              :rows="4"
              placeholder="请输入消息内容"
              maxlength="500"
              show-word-limit
            />
          </el-form-item>
        </el-form>
      </div>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="closeNewMessageDialog">取消</el-button>
          <el-button type="primary" @click="sendMessage" :loading="sending">发送</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 私信详情对话框 -->
    <el-dialog 
      v-model="showMessageDetail" 
      title="私信详情" 
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
import { ref, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

// 当前激活的标签页
const activeTab = ref('notification')

// 通知数据
const notifications = ref([
  {
    id: 1,
    title: '【重要提醒】期末考试成绩录入截止提醒',
    content: '各位老师：期末考试成绩录入系统将于本周五晚上24:00关闭，请各位老师及时完成成绩录入工作。如有特殊情况需要延期，请提前联系教务处。成绩录入完成后，请务必进行二次核对，确保数据准确性。',
    source: '教务处',
    date: '2025-05-31',
    isImportant: true
  },
  {
    id: 2,
    title: '【教学通知】下学期课程安排确认通知',
    content: '各位老师：下学期课程安排已初步确定，请各位老师登录教务系统查看并确认自己的课程安排。如有调整需求，请在规定时间内提交申请。课程安排确认后将不再接受调整申请。',
    source: '教务处',
    date: '2025-05-29',
    isImportant: false
  },
  {
    id: 3,
    title: '【系统通知】教学平台功能更新公告',
    content: '为了提升教学体验，我们对教学平台进行了功能更新。新增了智能批改功能，可以自动批改选择题和填空题，提高批改效率。同时优化了学生成绩分析功能，提供更详细的学习数据统计。',
    source: '教学平台',
    date: '2025-05-28',
    isImportant: false
  },
  {
    id: 4,
    title: '【会议通知】教学工作会议通知',
    content: '定于本周三下午2:00在会议室A召开教学工作会议，请各位老师准时参加。会议内容包括：本学期教学工作总结、下学期教学计划讨论、教学改革方案研讨等。',
    source: '教学办公室',
    date: '2025-05-27',
    isImportant: true
  },
  {
    id: 5,
    title: '【培训通知】新教学技术培训通知',
    content: '为提高教师信息化教学能力，学校将举办新教学技术培训。培训内容包括：在线教学平台使用、多媒体课件制作、教学数据分析等。培训时间为下周二全天，地点在计算机实验室。',
    source: '教师发展中心',
    date: '2025-05-26',
    isImportant: false
  }
])

// 私信数据
const messages = ref([
  {
    id: 1,
    senderId: 101,
    senderName: '张同学',
    senderAvatar: null,
    subject: '关于作业提交的问题',
    content: '老师您好，我在提交作业时遇到了一些问题，想请教一下您。作业要求中提到的格式要求我不是很理解，能否请您详细说明一下？',
    timestamp: Date.now() - 3600000, // 1小时前
    isRead: false
  },
  {
    id: 2,
    senderId: 102,
    senderName: '李同学',
    senderAvatar: null,
    subject: '课程资料下载问题',
    content: '老师，我在下载本周的课程资料时发现链接无法访问，请问是否有其他方式可以获取这些资料？',
    timestamp: Date.now() - 7200000, // 2小时前
    isRead: true
  },
  {
    id: 3,
    senderId: 103,
    senderName: '王同学',
    senderAvatar: null,
    subject: '请假申请',
    content: '老师，我因为身体原因需要请假，预计下周才能返校上课。我会及时补上落下的课程内容。',
    timestamp: Date.now() - 86400000, // 1天前
    isRead: true
  }
])

// 用户列表（用于选择收件人）
const userList = ref([
  { id: 101, realName: '张同学', username: 'zhang_student' },
  { id: 102, realName: '李同学', username: 'li_student' },
  { id: 103, realName: '王同学', username: 'wang_student' },
  { id: 104, realName: '陈同学', username: 'chen_student' },
  { id: 105, realName: '刘同学', username: 'liu_student' }
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
  activeTab.value = tab
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
const openNotification = (notification) => {
  ElMessage.info(`查看通知: ${notification.title}`)
}

// 打开私信详情
const openMessage = (message) => {
  currentMessage.value = message
  showMessageDetail.value = true
  
  // 标记为已读
  if (!message.isRead) {
    message.isRead = true
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
  newMessage.value = {
    recipientId: '',
    subject: '',
    content: ''
  }
}

// 发送私信
const sendMessage = async () => {
  if (!newMessage.value.recipientId) {
    ElMessage.warning('请选择收件人')
    return
  }
  
  if (!newMessage.value.subject.trim()) {
    ElMessage.warning('请输入消息主题')
    return
  }
  
  if (!newMessage.value.content.trim()) {
    ElMessage.warning('请输入消息内容')
    return
  }
  
  sending.value = true
  
  try {
    // 模拟发送消息
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    // 添加到消息列表
    const recipient = userList.value.find(u => u.id === newMessage.value.recipientId)
    const newMsg = {
      id: Date.now(),
      senderId: 1, // 当前教师ID
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

// 回复消息
const replyMessage = () => {
  if (currentMessage.value) {
    newMessage.value.recipientId = currentMessage.value.senderId
    newMessage.value.subject = `回复: ${currentMessage.value.subject}`
    closeMessageDetail()
    showNewMessageDialog.value = true
  }
}

// 删除本地消息
const deleteLocalMessage = async () => {
  try {
    await ElMessageBox.confirm('确认删除这条私信吗？', '提示', {
      type: 'warning',
      confirmButtonText: '确定',
      cancelButtonText: '取消'
    })
    
    const index = messages.value.findIndex(msg => msg.id === currentMessage.value.id)
    if (index > -1) {
      messages.value.splice(index, 1)
      ElMessage.success('删除成功')
      closeMessageDetail()
    }
  } catch {
    // 用户取消删除
  }
}

// 获取通知数据
const fetchNotifications = async () => {
  try {
    // 这里可以调用实际的API
    console.log('获取通知数据')
  } catch (error) {
    ElMessage.error('获取通知失败')
    console.error('获取通知失败:', error)
  }
}

// 获取私信数据
const fetchMessages = async () => {
  try {
    // 这里可以调用实际的API
    console.log('获取私信数据')
  } catch (error) {
    ElMessage.error('获取私信失败')
    console.error('获取私信失败:', error)
  }
}

onMounted(() => {
  fetchNotifications()
  fetchMessages()
})
</script>

<style scoped>
.notification-container {
  display: flex;
  height: 100vh;
  background: #ffffff;
}

/* 左侧导航栏 */
.sidebar {
  width: 200px;
  background: #ffffff;
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
  background: #f8f9fa;
  transform: translateX(5px);
}

.nav-item.active {
  background: #e3f2fd;
  border-left-color: #2196f3;
  color: #2196f3;
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
}

.unread-badge {
  position: absolute;
  right: 15px;
  top: 50%;
  transform: translateY(-50%);
  background: #ff4757;
  color: white;
  font-size: 12px;
  padding: 2px 6px;
  border-radius: 10px;
  min-width: 18px;
  text-align: center;
}

/* 右侧内容区域 */
.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  margin: 20px;
  border-radius: 20px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.content-header {
  padding: 20px 30px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
  background: rgba(255, 255, 255, 0.8);
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
  background: #2196f3;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 25px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(33, 150, 243, 0.3);
}

.new-message-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(33, 150, 243, 0.4);
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
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
}

.notification-item:hover {
  background: rgba(102, 126, 234, 0.05);
  transform: translateX(5px);
}

.notification-item:last-child {
  border-bottom: none;
}

/* 私信项 */
.message-item {
  padding: 20px 30px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
  display: flex;
  align-items: flex-start;
  gap: 15px;
  position: relative;
}

.message-item:hover {
  background: rgba(102, 126, 234, 0.05);
  transform: translateX(5px);
}

.message-item.unread {
  background: rgba(102, 126, 234, 0.1);
}

.message-item.unread:hover {
  background: rgba(102, 126, 234, 0.15);
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
  background: #2196f3;
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
  position: absolute;
  right: 20px;
  top: 50%;
  transform: translateY(-50%);
  width: 8px;
  height: 8px;
  background: #ff4757;
  border-radius: 50%;
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
  color: #667eea;
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

/* 对话框样式 */
.new-message-form {
  padding: 20px 0;
}

.message-detail {
  padding: 20px 0;
}

.message-info {
  margin-bottom: 20px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
}

.info-row {
  display: flex;
  margin-bottom: 8px;
}

.info-row:last-child {
  margin-bottom: 0;
}

.label {
  font-weight: 600;
  color: #333;
  width: 80px;
  flex-shrink: 0;
}

.value {
  color: #666;
}

.message-body {
  margin-bottom: 20px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
  line-height: 1.6;
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
    border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  }
  
  .nav-item {
    padding: 12px 20px;
  }
  
  .content-header {
    padding: 15px 20px;
  }
  
  .notification-item,
  .message-item {
    padding: 15px 20px;
  }
}
</style>
