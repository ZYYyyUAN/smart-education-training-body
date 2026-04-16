// // vite.config.js
// import { defineConfig } from 'vite'
// import vue from '@vitejs/plugin-vue'

// export default defineConfig({
//   plugins: [vue()],
//   server: {
//     proxy: {
//       '/api': {
//         target: 'http://localhost:8080',
//         changeOrigin: true,
//         rewrite: (path) => path.replace(/^\/api/, '')
//       }
//     }
//   }
// })
// vite.config.js
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'), // 配置 @ 指向 src 目录
      // 强制所有 Three.js 导入指向同一个实例
      'three': path.resolve(__dirname, './node_modules/three/build/three.module.js'),
      // 修复 jszip 默认导出问题
      'jszip': path.resolve(__dirname, './node_modules/jszip/dist/jszip.min.js'),
      // 修复 rgbcolor 默认导出问题
      'rgbcolor': path.resolve(__dirname, './node_modules/rgbcolor/index.js'),
      // 修复 raf 默认导出问题
      'raf': path.resolve(__dirname, './node_modules/raf/index.js')
    },
    dedupe: ['three'] // 去重 Three.js
  },
  optimizeDeps: {
    // 预构建 Three.js 以避免重复导入
    include: ['three', 'vue3-spline', 'dayjs', 'element-plus', 'jszip', 'docx-preview', 'crypto-js', 'file-saver', 'canvg', 'rgbcolor', 'raf'],
    // 强制预构建，避免运行时重复加载
    force: true
  },
  build: {
    rollupOptions: {
      external: [],
      output: {
        // 手动分块，将 Three.js 相关库打包到同一个 chunk
        manualChunks: (id) => {
          // 将所有包含 three 的模块打包到同一个 chunk
          if (id.includes('three') || id.includes('vue3-spline')) {
            return 'three-vendor'
          }
          // 将element-plus相关库单独打包
          if (id.includes('element-plus')) {
            return 'element-vendor'
          }
          // 将dayjs单独打包
          if (id.includes('dayjs')) {
            return 'dayjs-vendor'
          }
        }
      }
    },
    // 确保 commonjs 依赖正确处理
    commonjsOptions: {
      include: [/three/, /vue3-spline/, /dayjs/, /element-plus/, /jszip/, /docx-preview/, /crypto-js/, /file-saver/, /canvg/, /rgbcolor/, /raf/]
    }
  },
  define: {
    // 定义全局变量，避免重复实例化
    global: 'globalThis',
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      },
      '/auth': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/xiaozhi': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/graph': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/questions': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/ai-reader': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/question-generator': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/captcha': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/ai-qa': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/ai-notes': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/ai-notes-generation': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/mind-map': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/resources': {
        target: 'http://localhost:8080',
        changeOrigin: true
      }
    }
  }
})
