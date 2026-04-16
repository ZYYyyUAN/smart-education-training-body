// 为了统一学生端头部，顶层 /my_school 改为重定向到二级路由 /student/my_school
const routes = [
  {
    path: "/my_school",
    redirect: "/student/my_school"
  }
]; 

export default routes;