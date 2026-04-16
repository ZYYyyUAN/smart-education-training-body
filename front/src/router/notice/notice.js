import Notification from "../../views/notice/Notification.vue";
import TeacherLayout from "../../layouts/TeacherLayout.vue";
import Notice2 from "../../views/notice/Notification2.vue";

const routes = [
    {
      path: "/notice",
      name: "notice",
      component: Notification,
    },
    {
      path: "/notice2",
      component: TeacherLayout,
      children: [
        {
          path: "",
          name: "notice2",
          component: Notice2
        }
      ]
    },
  ]; 

export default routes;