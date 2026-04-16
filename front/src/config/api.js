// API配置文件
const config = {
    // 开发环境
    development: {
        baseURL: '/',  // 使用相对路径，让Vite代理生效
        timeout: 10000
    },
    // 生产环境
    production: {
        baseURL: '/api',  // 添加 /api 前缀，让Nginx代理生效
        timeout: 15000
    }
}

// 根据当前环境选择配置
const env = import.meta.env.MODE || 'development'
const currentConfig = config[env]

export default currentConfig
