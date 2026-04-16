import Finishhomework from "../../views/finishhomework/finishhomework.vue";
import homework from "../../views/homework/homework.vue";
import ExamConfirm from "@/views/exam/ExamConfirm.vue";
import TakeExam from "@/views/exam/TakeExam.vue";

const routes = [
    {
      path: "/homework/:id",  // 添加 :id 参数
      name: "homework",
      component: homework,
      props: true  // 启用props接收参数
    },
    {
      path: "/finishhomework/:id",
      name: "finishhomework",
      component: Finishhomework,
       props: true  // 启用props接收参数
    },
    {
      path: "/exam/confirm/:id",
      name: "ExamConfirm",
      component: ExamConfirm,
      props: true
    },
    {
      path: "/exam/take/:id",
      name: "TakeExam",
      component: TakeExam,
      props: true
    }
];

export default routes;