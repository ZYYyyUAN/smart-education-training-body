import axios from 'axios'

// 自动组卷API
export const autoExamAPI = {
  // 智能组卷
  generateExam: (data) => {
    return axios.post('/api/auto-exam/generate', data)
  },

  // 快速组卷
  quickGenerate: (params) => {
    return axios.post('/api/auto-exam/quick-generate', null, { params })
  },

  // 预览试卷
  previewExam: (examId) => {
    return axios.get(`/api/auto-exam/preview/${examId}`)
  },

  // 调整试卷
  adjustExam: (examId, adjustmentType, requirements) => {
    return axios.post(`/api/auto-exam/adjust/${examId}`, null, {
      params: { adjustmentType, requirements }
    })
  },

  // 保存试卷
  saveExam: (examData) => {
    return axios.post('/api/auto-exam/save', examData)
  },

  // 发布试卷
  publishExam: (examId, teacherId) => {
    return axios.post(`/api/auto-exam/publish/${examId}`, null, {
      params: { teacherId }
    })
  },

  // 直接发布试卷
  publishExamDirect: (examData, teacherId, deadline) => {
    return axios.post('/api/auto-exam/publish-direct', examData, {
      params: { teacherId, deadline }
    })
  },

  // 获取组卷历史
  getGenerationHistory: (teacherId, page = 1, pageSize = 10) => {
    return axios.get('/api/auto-exam/history', {
      params: { teacherId, page, pageSize }
    })
  },

  // 获取配置列表
  getConfigList: (courseId, teacherId) => {
    return axios.get('/api/auto-exam/configs', {
      params: { courseId, teacherId }
    })
  },

  // 删除配置
  deleteConfig: (configId) => {
    return axios.delete(`/api/auto-exam/config/${configId}`)
  },

  // 更新配置
  updateConfig: (configId, data) => {
    return axios.put(`/api/auto-exam/config/${configId}`, data)
  },

  // 获取试卷统计
  getExamStats: (courseId) => {
    return axios.get(`/api/auto-exam/stats/${courseId}`)
  }
}

export default autoExamAPI
