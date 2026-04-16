import { defineStore } from 'pinia'

export const useGeneratedQuestionsStore = defineStore('generatedQuestions', {
  state: () => ({
    list: [], // 生成的题目数组
    meta: { courseId: null, categoryId: null }
  }),
  actions: {
    setAll(list, meta) {
      this.list = Array.isArray(list) ? list : []
      this.meta = meta || { courseId: null, categoryId: null }
    },
    clear() {
      this.list = []
      this.meta = { courseId: null, categoryId: null }
    }
  }
})


