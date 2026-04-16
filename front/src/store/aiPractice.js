import { defineStore } from 'pinia'

export const useAiPracticeStore = defineStore('aiPractice', {
  state: () => ({
    generatedQuestions: null
  }),
  actions: {
    setGeneratedQuestions(questions) {
      this.generatedQuestions = questions
    },
    clearGeneratedQuestions() {
      this.generatedQuestions = null
    }
  }
})