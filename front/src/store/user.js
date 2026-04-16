// src/stores/user.js
import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    currentUser: (() => {
      try { return JSON.parse(localStorage.getItem('currentUser') || 'null') } catch { return null }
    })()
  }),
  getters: {
    isLoggedIn: (state) => !!state.token,
    currentUserId: (state) => state.currentUser?.id
  },
  actions: {
    setToken(newToken) {
      console.log('🔧 setToken调用:', {
        新token: newToken,
        token类型: typeof newToken,
        token长度: newToken?.length,
        当前token: this.token
      });
      
      this.token = newToken
      if (newToken) {
        localStorage.setItem('token', newToken)
        console.log('✅ token已保存到localStorage:', localStorage.getItem('token') ? '成功' : '失败');
      } else {
        localStorage.removeItem('token')
        console.log('🗑️ token已从localStorage移除');
      }
    },
    clearToken() {
      this.setToken('')
    },
    setUser(user) {
      this.currentUser = user || null
      if (user) localStorage.setItem('currentUser', JSON.stringify(user))
      else localStorage.removeItem('currentUser')
    },
    logout() {
      this.setToken('')
      this.setUser(null)
    }
  }
})
