import StudentLayout from "../../layouts/StudentLayout.vue";
import Student from "../../views/student/Student.vue";
const StudentProfile = () => import("../../views/student/StudentProfile.vue");

const routes = [
  {
    path: "/student",
    component: StudentLayout,
    children: [
      { path: "", name: "student", component: Student },
      { path: "profile", name: "student_profile", component: StudentProfile },
      { path: "my_school", name: "student_my_school", component: () => import("../../views/my_school/my_school.vue") },
      { path: "notice", name: "student_notice", component: () => import("../../views/notice/Notification.vue") }
    ]
  }
]; 

export default routes;