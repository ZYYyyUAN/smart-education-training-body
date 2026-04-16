import axios from 'axios'

// 题目生成API
export const questionGeneratorAPI = {
  // 生成题目
  generateQuestions(data) {
    return axios.post('/question-generator/generate', data)
  },

  // 生成单个题目
  generateSingleQuestion(data) {
    return axios.post('/question-generator/generate-single', data)
  },

  // 保存题目到题库
  saveQuestions(data) {
    return axios.post('/question-generator/save', data)
  },

  // 获取题库分类
  getCategories() {
    return axios.get('/question-generator/categories')
  },

  // 按分类分页获取题目（教师端）
  pageQuestionsByCategory(params) {
    // params: { categoryId, page, pageSize }
    return axios.get('/xiaozhi/teacher/question/pageByCategory', { params })
  },

  // 按分类获取题目列表（教师端）
  listQuestionsByCategory(categoryId) {
    return axios.get('/xiaozhi/teacher/question/listByCategory', { params: { categoryId } })
  },

  // 创建题库分类
  createCategory(data) {
    return axios.post('/question-generator/categories', data)
  },

  // 更新题库分类
  updateCategory(id, data) {
    return axios.put(`/question-generator/categories/${id}`, data)
  },

  // 删除题库分类
  deleteCategory(id) {
    return axios.delete(`/question-generator/categories/${id}`)
  }
}
