import axios from 'axios'

// 发送通知给学生
export const sendNotificationToStudent = (data) => {
  return axios.post('/api/notifications/send', data)
}

// 获取学生的私信列表
export const getStudentMessages = (studentId) => {
  return axios.get(`/api/notifications/student/${studentId}/messages`)
}

// 标记私信为已读
export const markMessageAsRead = (messageId) => {
  return axios.put(`/api/notifications/messages/${messageId}/read`)
}

// 删除私信
export const deleteMessage = (messageId) => {
  return axios.delete(`/api/notifications/messages/${messageId}`)
}

// 获取未读私信数量
export const getUnreadMessageCount = (studentId) => {
  return axios.get(`/api/notifications/student/${studentId}/unread-count`)
}

// 获取学生的通知列表
export const getStudentNotifications = (studentId) => {
  return axios.get(`/api/notifications/student/${studentId}/notifications`)
}

// 标记通知为已读
export const markNotificationAsRead = (notificationId, userId) => {
  return axios.put(`/api/notifications/notifications/${notificationId}/read?userId=${userId}`)
}

// 获取学生未读通知数量
export const getUnreadNotificationCount = (studentId) => {
  return axios.get(`/api/notifications/student/${studentId}/notification-unread-count`)
}
