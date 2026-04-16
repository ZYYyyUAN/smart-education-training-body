import { ElMessage } from 'element-plus'

class WebSocketService {
  constructor() {
    this.ws = null
    this.reconnectAttempts = 0
    this.maxReconnectAttempts = 5
    this.reconnectInterval = 3000
    this.heartbeatInterval = null
    this.isConnected = false
    this.messageHandlers = new Map()
  }

  // 连接WebSocket
  connect(userId, userType = 'student') {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      return
    }

    const wsUrl = `/ws/notifications/${userType}/${userId}`
    
    try {
      this.ws = new WebSocket(wsUrl)
      this.setupEventHandlers()
    } catch (error) {
      console.error('WebSocket连接失败:', error)
      this.scheduleReconnect()
    }
  }

  // 设置事件处理器
  setupEventHandlers() {
    this.ws.onopen = () => {
      console.log('WebSocket连接已建立')
      this.isConnected = true
      this.reconnectAttempts = 0
      this.startHeartbeat()
      this.emit('connected')
    }

    this.ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data)
        this.handleMessage(data)
      } catch (error) {
        console.error('解析WebSocket消息失败:', error)
      }
    }

    this.ws.onclose = (event) => {
      console.log('WebSocket连接已关闭:', event.code, event.reason)
      this.isConnected = false
      this.stopHeartbeat()
      
      if (event.code !== 1000) { // 非正常关闭
        this.scheduleReconnect()
      }
    }

    this.ws.onerror = (error) => {
      console.error('WebSocket错误:', error)
      this.isConnected = false
    }
  }

  // 处理接收到的消息
  handleMessage(data) {
    console.log('收到WebSocket消息:', data)
    
    switch (data.type) {
      case 'private_message':
        this.handlePrivateMessage(data)
        break
      case 'notification':
        this.handleNotification(data)
        break
      case 'heartbeat':
        // 心跳响应，不需要特殊处理
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

  // 处理通知消息
  handleNotification(data) {
    ElMessage({
      message: data.title || '您有一条新的通知',
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
  send(data) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(data))
    } else {
      console.error('WebSocket未连接，无法发送消息')
    }
  }

  // 开始心跳
  startHeartbeat() {
    this.heartbeatInterval = setInterval(() => {
      if (this.isConnected) {
        this.send({ type: 'heartbeat', timestamp: Date.now() })
      }
    }, 30000) // 30秒发送一次心跳
  }

  // 停止心跳
  stopHeartbeat() {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval)
      this.heartbeatInterval = null
    }
  }

  // 计划重连
  scheduleReconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++
      console.log(`计划重连，第${this.reconnectAttempts}次尝试，${this.reconnectInterval}ms后重连`)
      
      setTimeout(() => {
        this.connect()
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
  emit(event, data) {
    // 这里可以使用事件总线或其他方式触发事件
    // 暂时使用console.log记录
    console.log(`事件触发: ${event}`, data)
  }

  // 断开连接
  disconnect() {
    if (this.ws) {
      this.ws.close(1000, '用户主动断开')
      this.ws = null
    }
    this.isConnected = false
    this.stopHeartbeat()
  }

  // 获取连接状态
  getConnectionStatus() {
    return this.isConnected
  }
}

// 创建单例实例
const webSocketService = new WebSocketService()

export default webSocketService
