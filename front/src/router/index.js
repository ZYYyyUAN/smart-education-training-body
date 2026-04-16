import { createRouter, createWebHistory } from 'vue-router'
import mainFrame from './main_frame/mainFrame.js'
import caseNotes from './case_notes/caseNotes.js'
import indexLogin from './index&login/index_login.js'
import student from './student/student.js'
import mySchool from './my_school/my_school.js'
import Course from './course/course.js'
import aiChat from './ai_chat/aiChat.js'
import Homework from './homework/homework.js'
import teacher from './teacher/teacher.js'
import teacherSchool from './teacher_school/teacher_school.js'
import notice from './notice/notice.js'
import resource from './resource/resource.js'
import study from './study_space/study_space.js'
import ai_practice from './ai_practice/ai_practice.js'
import ai_practice_2 from './ai_practice_2/ai_practice_2.js'
import ai_practice_3 from './ai_practice_3/ai_practice_3.js'
import ai_reader from './ai_reader/ai_reader.js'
import ai_writing from './ai_writing/ai_writing.js'
import practice_report from './practice_report/practice_report.js'
import practice_history from './practice_history/practice_history.js'
import QuestionADetail from './QuestionADetail/QuestionADetail.js'
import pomodoro from './pomodoro/pomodoro.js'
import admin from './admin/admin.js'
import weakPointPractice from '@/views/weak_point_practice/weak_point_practice.vue'
import KnowledgeDetail from '@/views/knowlwdge_graph/KnowledgeDetail.vue'
const QuestionDetail = () => import('@/views/QuestionDetail/QuestionDetail.vue')
const GenerateSimilar = () => import('@/views/GenerateSimilar/GenerateSimilar.vue')
const FilePreview = () => import('@/views/course/FilePreview.vue')
const StudentDetail = () => import('@/views/Dashboard/components/StudentDetail.vue')

const router = createRouter({
  // 使用import.meta.env替代process.env
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    ...mainFrame,
    ...caseNotes,
    ...indexLogin,
    ...student,
    ...mySchool,
    ...Course,
     ...aiChat,
    ...Homework,
    ...teacher,
    ...teacherSchool,
    ...notice,
    ...resource,
    ...study,
    ...ai_reader,
    ...ai_writing,
    ...ai_practice,
    ...ai_practice_2,
    ...ai_practice_3,
    ...practice_report,
    ...practice_history,
    ...QuestionADetail,
    ...admin,
    pomodoro,
    { path: '/detail/:id', name: 'QuestionDetail', component: QuestionDetail },
    { path: '/similar/:id', name: 'GenerateSimilar', component: GenerateSimilar },
    { path: '/file-preview/:questionId/:fileId', name: 'filePreview', component: FilePreview },
    { path: '/weak_point_practice', name: 'WeakPointPractice', component: weakPointPractice },
    { path: '/knowledge-detail', name: 'knowledge-detail', component: KnowledgeDetail },
    { path: '/knowledge-graph-detail/:id', name: 'knowledge-graph-detail', component: KnowledgeDetail },
    { path: '/student-detail/:studentId/:courseId', name: 'StudentDetail', component: StudentDetail }
  ]
})

// 临时禁用全局路由守卫，允许无登录访问

// 简单的全局路由守卫，未登录跳转登录页
router.beforeEach((to, from, next) => {
  const publicPrefixes = ['/loginIndex']
  // 根路径 '/' 作为公共首页放行
  if (to.path === '/' || publicPrefixes.some(p => to.path.startsWith(p))) {
    console.log(`[路由守卫] ✅ 公共页面放行: ${to.path}`)
    return next()
  }
  
  const token = localStorage.getItem('token')
  const looksLikeJwt = token && token.split('.').length === 3
  const isTempToken = token && token.startsWith('temp.') && token.endsWith('.token')
  
  // 详细调试日志
  console.log(`[路由守卫] 访问: ${to.path}`, {
    'token存在': !!token,
    'token长度': token?.length,
    'token片段': token?.split('.').length,
    'JWT格式': looksLikeJwt,
    '临时token': isTempToken,
    'token前缀': token?.substring(0, 20) + '...'
  })
  
  if (!looksLikeJwt && !isTempToken) {
    console.log(`[路由守卫] ❌ Token验证失败，重定向到登录页`)
    try { localStorage.removeItem('token') } catch(e) {}
    if (to.path !== '/loginIndex/userLogin') {
      return next({ path: '/loginIndex/userLogin', replace: true })
    }
  } else {
    console.log(`[路由守卫] ✅ Token验证通过，允许访问: ${to.path}`)
  }
  
  return next()
})

export default router