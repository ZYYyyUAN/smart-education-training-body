import ResourcePreview from "../../views/ResoursePreview/ResourcePreview.vue";

const routes = [
    {
      path: "/resource/:id",
      name: "resource",
      component: ResourcePreview,
    }
  ]; 

export default routes;