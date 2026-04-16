import TeacherLayout from "../../layouts/TeacherLayout.vue";
import Teacher from "../../views/teacher/Teacher.vue";

const routes = [
  {
    path: "/teacher",
    component: TeacherLayout,
    children: [
      {
        path: "",
        name: "teacher",
        component: Teacher,
      }
    ]
  }
]; 

export default routes;