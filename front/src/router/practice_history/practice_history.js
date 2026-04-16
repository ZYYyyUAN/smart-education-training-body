import PracticeHistory from '@/views/practice_history/practice_history.vue'

const practice_history = [
  {
    path: '/practice_history',
    name: 'PracticeHistory',
    component: PracticeHistory,
    meta: {
      title: '历史练习记录',
      requiresAuth: true
    }
  }
]

export default practice_history 