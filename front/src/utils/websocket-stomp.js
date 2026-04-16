import { ElMessage } from 'element-plus'

/**
 * STOMP WebSocket服务
 * 用于连接后端的STOMP WebSocket端点
 */
class WebSocketStompService {
  constructor() {
    this.stompClient = null
    this.isConnected = false
    this.userId = null
    this.userType = null
    this.messageHandlers = new Map()
    this.reconnectAttempts = 0
    this.maxReconnectAttempts = 5
    this.reconnectInterval = 3000
  }

  // 连接到WebSocket服务器
  connect(userId, userType) {
    try {
      this.userId = userId
      this.userType = userType

      console.log(`开始连接WebSocket: userId=${userId}, userType=${userType}`)

      // 检查WebSocket库是否加载
      if (typeof SockJS === 'undefined' || typeof Stomp === 'undefined') {
        console.error('WebSocket库未加载，请检查index.html中的CDN引用')
        return
      }

      this.connectWithStomp()

    } catch (error) {
      console.error('WebSocket连接失败:', error)
      this.scheduleReconnect()
    }
  }

  // 使用STOMP连接
  connectWithStomp() {
    try {
      console.log('开始建立STOMP连接...')
      const socket = new SockJS('/ws')
      this.stompClient = Stomp.over(socket)

      // 禁用调试日志
      this.stompClient.debug = null

      this.stompClient.connect({},
        // 连接成功回调
        (frame) => {
          console.log('STOMP连接成功:', frame)
          this.isConnected = true
          this.reconnectAttempts = 0
          this.subscribeToNotifications()
          this.emit('connected')
        },
        // 连接失败回调
        (error) => {
          console.error('STOMP连接失败:', error)
          this.isConnected = false
          this.scheduleReconnect()
        }
      )

    } catch (error) {
      console.error('STOMP连接失败:', error)
      this.scheduleReconnect()
    }
  }

  // 订阅通知
  subscribeToNotifications() {
    if (!this.stompClient || !this.isConnected) {
      console.error('STOMP客户端未连接')
      return
    }

    try {
      // 订阅学生个人通知队列
      if (this.userType === 'student') {
        const subscriptionPath = `/queue/notifications/${this.userId}`
        console.log(`订阅通知队列: ${subscriptionPath}`)

        this.stompClient.subscribe(subscriptionPath, (message) => {
          try {
            console.log('收到STOMP消息:', message.body)
            const data = JSON.parse(message.body)
            this.handleMessage(data)
          } catch (error) {
            console.error('解析STOMP消息失败:', error)
          }
        })

        // 订阅系统通知主题
        this.stompClient.subscribe('/topic/system-notifications', (message) => {
          try {
            const data = JSON.parse(message.body)
            this.handleMessage(data)
          } catch (error) {
            console.error('解析系统通知失败:', error)
          }
        })

        console.log(`已订阅学生 ${this.userId} 的通知队列`)
      }

    } catch (error) {
      console.error('订阅通知失败:', error)
    }
  }

  // 处理接收到的消息
  handleMessage(data) {
    console.log('收到WebSocket消息:', data)

    switch (data.type) {
      case 'private_message':
        this.handlePrivateMessage(data)
        break
      case 'system_notification':
        this.handleSystemNotification(data)
        break
      default:
        console.log('未知消息类型:', data.type)
    }

    // 触发注册的消息处理器
    if (this.messageHandlers.has(data.type)) {
      this.messageHandlers.get(data.type).forEach(handler => {
        handler(data)
      })
    }
  }

  // 处理私信消息
  handlePrivateMessage(data) {
    console.log('处理私信消息:', data)

    // 播放语音提醒
    this.playVoiceNotification('您有一条新的私信，请尽快查收')

    // 显示消息提示
    ElMessage({
      message: '您有一条新的私信，请尽快查收',
      type: 'info',
      duration: 5000,
      showClose: true
    })

    // 触发私信更新事件
    this.emit('private_message_received', data)
  }

  // 处理系统通知
  handleSystemNotification(data) {
    ElMessage({
      message: data.title || '您有一条新的系统通知',
      type: 'info',
      duration: 5000,
      showClose: true
    })

    this.emit('notification_received', data)
  }

  // 播放语音提醒
  playVoiceNotification(text) {
    if ('speechSynthesis' in window) {
      const utterance = new SpeechSynthesisUtterance(text)
      utterance.lang = 'zh-CN'
      utterance.rate = 0.8
      utterance.pitch = 1.0
      speechSynthesis.speak(utterance)
    }
  }

  // 发送消息
  send(destination, data) {
    if (this.stompClient && this.isConnected) {
      this.stompClient.send(destination, {}, JSON.stringify(data))
    } else {
      console.error('WebSocket未连接，无法发送消息')
    }
  }

  // 计划重连
  scheduleReconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++
      console.log(`计划重连，第${this.reconnectAttempts}次尝试，${this.reconnectInterval}ms后重连`)

      setTimeout(() => {
        this.connect(this.userId, this.userType)
      }, this.reconnectInterval)
    } else {
      console.error('达到最大重连次数，停止重连')
    }
  }

  // 注册消息处理器
  on(messageType, handler) {
    if (!this.messageHandlers.has(messageType)) {
      this.messageHandlers.set(messageType, [])
    }
    this.messageHandlers.get(messageType).push(handler)
  }

  // 移除消息处理器
  off(messageType, handler) {
    if (this.messageHandlers.has(messageType)) {
      const handlers = this.messageHandlers.get(messageType)
      const index = handlers.indexOf(handler)
      if (index > -1) {
        handlers.splice(index, 1)
      }
    }
  }

  // 触发事件
  emit(eventType, data) {
    if (this.messageHandlers.has(eventType)) {
      this.messageHandlers.get(eventType).forEach(handler => {
        handler(data)
      })
    }
  }

  // 断开连接
  disconnect() {
    if (this.stompClient) {
      this.stompClient.disconnect()
    }
    this.isConnected = false
    console.log('WebSocket连接已断开')
  }

  // 获取连接状态
  getConnectionStatus() {
    return this.isConnected
  }
}

// 创建单例实例
const webSocketStompService = new WebSocketStompService()

// 导出默认实例
export default webSocketStompService
