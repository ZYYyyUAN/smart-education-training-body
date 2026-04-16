import AiReader from "../../views/ai_reader/ai_reader.vue";
const AiReaderView = () => import("../../views/ai_reader/ai_reader_view.vue");

const routes = [
  {
    path: "/ai_reader",
    name: "ai_reader",
    component: AiReader,
  },
  {
    path: "/ai_reader/view/:id",
    name: "ai_reader_view",
    component: AiReaderView,
    props: true,
  },
];

export default routes;


