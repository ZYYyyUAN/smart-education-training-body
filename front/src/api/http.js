import axios from 'axios';
import { ElMessage } from 'element-plus'
import apiConfig from '../config/api.js'

// 🔐 Token验证工具函数
const validateToken = () => {
  const token = localStorage.getItem('token')
  if (!token) {
    console.log('⚠️ Token不存在')
    return false
  }
  
  // 检查JWT格式
  const parts = token.split('.')
  if (parts.length !== 3) {
    console.log('⚠️ Token格式错误，不是有效的JWT')
    localStorage.removeItem('token')
    return false
  }
  
  try {
    // 解析JWT payload检查过期时间
    // 添加base64填充以确保正确解码
    let base64Payload = parts[1]
    while (base64Payload.length % 4) {
      base64Payload += '='
    }
    
    const payload = JSON.parse(atob(base64Payload))
    const now = Math.floor(Date.now() / 1000)
    
    if (payload.exp && payload.exp < now) {
      console.log('⚠️ Token已过期')
      localStorage.removeItem('token')
      localStorage.removeItem('currentUser')
      return false
    }
    
    console.log('✅ Token验证通过')
    return true
  } catch (e) {
    console.log('⚠️ Token解析失败:', e.message)
    console.log('🔍 Token详情:', {
      token: token,
      parts: parts,
      part1: parts[0],
      part2: parts[1],
      part3: parts[2]
    })
    // 不要删除token，可能是解析问题而不是token本身的问题
    console.log('⚠️ 跳过token解析，但保留token用于后续请求')
    return true
  }
}

// 导出验证函数供其他模块使用
export { validateToken }


// 创建 axios 实例
const http = axios.create({
    baseURL: apiConfig.baseURL, // 使用配置文件中的baseURL
    timeout: apiConfig.timeout, // 设置超时时间
    withCredentials: true // 允许携带凭证（如Cookies）
});
// 添加请求拦截器
http.interceptors.request.use(
  config => {
    // 验证token有效性
    const token = localStorage.getItem('token')
    console.log('🔍 请求拦截器检查token:', {
      url: config.url,
      hasToken: !!token,
      tokenLength: token?.length,
      tokenFormat: token ? token.split('.').length : 0
    });
    
    if (validateToken()) {
      config.headers['Authorization'] = `Bearer ${token}`;
      console.log('🔐 已添加认证头到请求:', config.url)
    } else {
      console.log('⚠️ Token验证失败，发送未认证请求:', config.url)
    }
    
    console.log('Sending request to:', config.baseURL + config.url);
    console.log('Request config:', config);
    return config;
  },
  error => {
    // 对请求错误做些什么
    console.error('Request interceptor error:', error);
    return Promise.reject(error);
  }
);

// 兼容：很多组件直接使用 axios 默认实例，这里为全局 axios 也挂同样的拦截器
// 设置全局默认baseURL - 使用相对路径让Vite代理生效
axios.defaults.baseURL = '/'

axios.interceptors.request.use(
  cfg => {
    // 使用统一的token验证逻辑
    if (validateToken()) {
      const token = localStorage.getItem('token')
      cfg.headers = cfg.headers || {}
      cfg.headers['Authorization'] = `Bearer ${token}`
      console.log('🔐 全局axios已添加认证头:', cfg.url)
    } else {
      console.log('⚠️ 全局axios Token验证失败:', cfg.url)
    }
    return cfg
  },
  err => Promise.reject(err)
)

axios.interceptors.response.use(
  res => res,
  err => {
    if (err.response && err.response.status === 401) {
      console.log('🔐 检测到401未授权错误，正在处理...')
      console.log('当前token:', localStorage.getItem('token') ? '存在' : '不存在')
      console.log('请求URL:', err.config?.url)
      console.log('请求headers:', err.config?.headers)
      
      try { 
        localStorage.removeItem('token') 
        localStorage.removeItem('currentUser')
      } catch(e) {}
      
      ElMessage.error('登录已过期，请重新登录')
      
      // 延迟跳转到登录页，避免与当前调用栈冲突
      setTimeout(() => {
        if (window.location.pathname !== '/loginIndex/userLogin' && 
            window.location.pathname !== '/') {
          window.location.href = '/loginIndex/userLogin'
        }
      }, 1000)
    }
    return Promise.reject(err)
  }
)

// 添加响应拦截器
http.interceptors.response.use(
  response => {
    // 先获取响应数据
    const data = response.data;
    
    // 检查业务错误码
    if (data && (data.code === 500 || data.code === 400 || (data.code && data.code !== 200 && data.code !== 0))) {
      console.log('业务错误响应:', data);
      // 不要在这里显示错误消息，让具体的业务逻辑处理
      // 但仍然返回数据，让调用方决定如何处理
    }
    
    // 直接返回响应数据，而不是整个response对象
    return data;
  },
  error => {
    console.error('HTTP请求错误:', error);
    if (error.response && error.response.status === 401) {
      console.log('🔐 HTTP实例检测到401未授权错误')
      console.log('请求详情:', {
        url: error.config?.url,
        method: error.config?.method,
        headers: error.config?.headers,
        hasToken: !!localStorage.getItem('token')
      })
      
      ElMessage.error('登录已过期，请重新登录');
      try {
        localStorage.removeItem('token');
        localStorage.removeItem('currentUser');
      } catch(e) {}
      
      // 延迟跳转，避免重复跳转
      setTimeout(() => {
        if (window.location.pathname !== '/loginIndex/userLogin' && 
            window.location.pathname !== '/') {
          window.location.href = '/loginIndex/userLogin'
        }
      }, 1500)
    } else if (error.response) {
      ElMessage.error(`请求失败: ${error.response.status} - ${error.response.statusText}`);
    } else {
      ElMessage.error('网络请求失败，请检查网络连接');
    }
    return Promise.reject(error);
  }
);

// 封装 GET 请求
function get(options) {
  options.method = 'get';
    if (options.data) {
        options.params = options.data || {};
    delete options.data
   }
  console.log(options);
  return http(options);
}

// 封装 POST 请求
function post(options) {
  options.method = 'post';
  options.data = options.data || {};
  console.log(options);
  return http(options);
}

function put(options) {
  options.method = 'put';
  options.data = options.data || {};
  console.log(options);
  return http(options);
}

function del(options) {
  options.method = 'delete';
  console.log(options);
  return http(options);
}

export default { get, post, put, delete: del };