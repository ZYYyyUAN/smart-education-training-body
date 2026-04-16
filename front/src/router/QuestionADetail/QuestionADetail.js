import QuestionADetail from "../../views/course/QuestionDetail.vue";
const routes = [
    {
      path: "/question/:id",
      name: "QuestionADetail",
      component: QuestionADetail,
      props:true,
    }
  ]; 

export default routes;