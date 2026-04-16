import Study from "../../views/study_space/study.vue";
import KnowledgeGraph from "../../views/study_space/KnowledgeGraph.vue";
import KnowledgeGraphDetail from "../../views/study_space/KnowledgeGraphDetail.vue";

const routes = [
  {
    path: "/study_space",
    name: "study_space",
    component: Study,
  },
  {
    path: "/knowledge-graph",
    name: "KnowledgeGraph",
    component: KnowledgeGraph,
  },
  {
    path: "/knowledge-graph-detail/:id",
    name: "KnowledgeGraphDetail",
    component: KnowledgeGraphDetail,
  }
];

export default routes;