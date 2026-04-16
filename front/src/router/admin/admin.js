import AdminDashboard from '../../views/admin/AdminDashboard.vue'
import AdminHome from '../../views/admin/AdminHome.vue'

const adminRoutes = [
  {
    path: '/admin',
    component: AdminDashboard,
    children: [
      {
        path: '',
        name: 'AdminHome',
        component: AdminHome
      },
      {
        path: 'users',
        name: 'AdminUsers',
        component: () => import('../../views/admin/UserManagement.vue')
      },
      {
        path: 'roles',
        name: 'AdminRoles',
        component: () => import('../../views/admin/AdminHome.vue') // Placeholder
      },
      {
        path: 'config',
        name: 'AdminConfig',
        component: () => import('../../views/admin/AdminHome.vue') // Placeholder
      },
      {
        path: 'logs',
        name: 'AdminLogs',
        component: () => import('../../views/admin/AdminHome.vue') // Placeholder
      },
      {
        path: 'student-analysis',
        name: 'StudentAnalysis',
        component: () => import('../../views/admin/StudentAnalysis.vue')
      }
    ]
  }
]

export default adminRoutes
