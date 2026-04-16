/**
 * WebSocket库加载配置
 * 确保STOMP和SockJS库正确加载
 */

// 检查库是否已加载
export function checkWebSocketLibs() {
  if (typeof SockJS === 'undefined') {
    console.error('SockJS库未加载，请检查index.html中的CDN引用')
    return false
  }
  
  if (typeof Stomp === 'undefined') {
    console.error('STOMP库未加载，请检查index.html中的CDN引用')
    return false
  }
  
  console.log('WebSocket库加载成功')
  return true
}

// 获取STOMP客户端
export function getStompClient() {
  if (typeof Stomp === 'undefined') {
    throw new Error('STOMP库未加载')
  }
  return Stomp
}

// 获取SockJS客户端
export function getSockJSClient() {
  if (typeof SockJS === 'undefined') {
    throw new Error('SockJS库未加载')
  }
  return SockJS
}

// 初始化WebSocket库
export function initWebSocketLibs() {
  try {
    // 禁用STOMP调试日志
    if (typeof Stomp !== 'undefined') {
      Stomp.debug = null
    }
    
    console.log('WebSocket库初始化成功')
    return true
  } catch (error) {
    console.error('WebSocket库初始化失败:', error)
    return false
  }
}
