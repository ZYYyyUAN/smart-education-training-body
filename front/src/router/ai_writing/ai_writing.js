export default [
  {
    path: '/ai_writing',
    name: 'AiWriting',
    component: () => import('@/views/ai_writing/ai_writing.vue'),
    meta: {
      title: 'AI写作助手',
      requiresAuth: true
    }
  },
  {
    path: '/ai_writing/result',
    name: 'AiWritingResult',
    component: () => import('@/views/ai_writing/ai_writing_result.vue'),
    meta: {
      title: 'AI写作结果',
      requiresAuth: true
    }
  }
]