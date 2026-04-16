/**
 * 番茄钟路由配置
 */

export default {
  path: '/pomodoro',
  name: 'Pomodoro',
  component: () => import('@/views/pomodoro/pomodoro.vue'),
  meta: {
    title: '番茄钟',
    icon: 'fas fa-clock',
    requiresAuth: false, // 设置为 true 如果需要登录
    description: '番茄钟学习助手 - 25分钟专注学习 + 5分钟放松休息',
    keywords: '番茄钟,学习计时器,专注力,时间管理'
  },
  children: [
    {
      path: '',
      name: 'PomodoroMain',
      component: () => import('@/views/pomodoro/pomodoro.vue'),
      meta: {
        title: '番茄钟主页',
        description: '开始你的专注学习之旅'
      }
    },
    {
      path: 'statistics',
      name: 'PomodoroStatistics',
      component: () => import('@/views/pomodoro/PomodoroStatistics.vue'),
      meta: {
        title: '学习统计',
        description: '查看学习数据和进度分析'
      }
    },
    {
      path: 'settings',
      name: 'PomodoroSettings',
      component: () => import('@/views/pomodoro/PomodoroSettings.vue'),
      meta: {
        title: '番茄钟设置',
        description: '自定义番茄钟参数和偏好'
      }
    }
  ]
};

