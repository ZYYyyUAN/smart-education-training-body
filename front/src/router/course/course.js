import Course from "../../views/course/course.vue";
import QuestionListAll from "../../views/course/QuestionListAll.vue";

const routes = [
    {
      path: "/course",
      name: "course",
      component: Course,
    },
    {
      path: "/course/questions",
      name: "CourseQuestionsAll",
      component: QuestionListAll,
    }
  ]; 

export default routes;