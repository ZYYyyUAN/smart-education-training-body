import { createApp, provide, ref } from 'vue'
import App from './App.vue'
import './index.css'
import ElementPlus from 'element-plus'
import '/node_modules/element-plus/dist/index.css'
import router from './router'
import { loadFull } from 'tsparticles'
import Particles from "vue3-particles"
import 'element-plus/dist/index.css'
import Vue3Spline from 'vue3-spline'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'

// 🔧 Three.js 重复导入修复 + 扩展程序错误过滤
// 在应用启动前统一初始化 Three.js，避免重复导入警告
if (typeof window !== 'undefined') {
  // 拦截 Three.js 重复导入警告
  const originalWarn = console.warn
  const originalError = console.error
  
  console.warn = function(...args) {
    const message = args.map(arg => {
      if (typeof arg === 'object' && arg !== null) {
        try {
          return JSON.stringify(arg)
        } catch (e) {
          // 如果遇到循环引用，返回对象的类型和构造函数名
          return `[${arg.constructor?.name || 'Object'}]`
        }
      }
      return String(arg)
    }).join(' ')
    if (message.includes('Multiple instances of Three.js')) {
      console.log('🔧 Three.js 重复导入警告已被拦截和修复')
      return // 不显示警告
    }
    originalWarn.apply(console, args)
  }
  
  // 拦截扩展程序相关错误
  console.error = function(...args) {
    const message = args.map(arg => {
      if (typeof arg === 'object' && arg !== null) {
        try {
          return JSON.stringify(arg)
        } catch (e) {
          // 如果遇到循环引用，返回对象的类型和构造函数名
          return `[${arg.constructor?.name || 'Object'}]`
        }
      }
      return String(arg)
    }).join(' ')
    // 过滤语雀扩展程序错误
    if (message.includes('yuque.com') || 
        message.includes('browser_extension') ||
        message.includes('获取指令失败') ||
        message.includes('request error')) {
      console.log('🔧 已拦截浏览器扩展程序错误，不影响应用功能')
      return
    }
    originalError.apply(console, args)
  }
  
  // 拦截全局未捕获的Promise错误
  window.addEventListener('unhandledrejection', (event) => {
    const error = event.reason
    const errorMessage = error?.message || error?.toString() || ''
    
    // 扩展程序相关错误关键词
    const extensionErrorKeywords = [
      'AbortError',
      'message channel closed',
      'yuque.com',
      'Could not establish connection',
      'Receiving end does not exist',
      'content-all.js',
      'content-app',
      'browser_extension',
      'chrome-extension'
    ]
    
    // 检查是否是扩展程序错误
    const isExtensionError = extensionErrorKeywords.some(keyword => 
      errorMessage.includes(keyword)
    )
    
    if (isExtensionError) {
      console.log('🔧 已拦截浏览器扩展程序Promise错误:', errorMessage.substring(0, 100) + '...')
      event.preventDefault() // 阻止错误显示
      return false
    }
  })
  
  // 拦截全局错误事件
  window.addEventListener('error', (event) => {
    const errorMessage = event.message || event.error?.message || ''
    const filename = event.filename || ''
    
    // 检查是否是扩展程序错误
    if (filename.includes('chrome-extension://') || 
        filename.includes('content-all.js') ||
        filename.includes('content-app') ||
        errorMessage.includes('Could not establish connection') ||
        errorMessage.includes('Receiving end does not exist')) {
      
      console.log('🔧 已拦截浏览器扩展程序脚本错误')
      event.preventDefault()
      return false
    }
  })
  
  // 预加载 Three.js 以确保单一实例
  try {
    import('three').then(THREE => {
      window.THREE_INSTANCE = THREE
      console.log('✅ Three.js 统一实例已初始化')
    })
  } catch (e) {
    console.log('⚠️ Three.js 预加载失败，但不影响功能')
  }
}
// 全局变量 用户id 和用户token
import { createPinia } from 'pinia';
const pinia = createPinia();
const app = createApp(App)
// app.component('Particles', Particles)
//引入echarts
import * as echarts from 'echarts'
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
    app.component(key, component)
  }
  
app.config.globalProperties.$echarts = echarts

app.use(pinia);
app.use(ElementPlus)
app.use(Particles)
app.use(router)
app.use(Vue3Spline)


// 应用启动时的登录检查和挂载
router.isReady().then(() => {
  try {
    const token = localStorage.getItem('token')
    const path = window.location.pathname || '/'
    const isPublic = path === '/' || path.startsWith('/loginIndex')
    const looksLikeJwt = token && token.split('.').length === 3
    if (!isPublic && !looksLikeJwt) {
      router.replace('/loginIndex/userLogin')
    }
  } catch (e) {}
  app.mount('#app')
})
