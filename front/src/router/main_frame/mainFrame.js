import MainFrame from "../../views/main_frame/MainFrame.vue";
import MessageIndex from '../../views/main_frame/components/MessageIndex.vue'
import RecordIndex from '../../views/main_frame/components/RecordIndex.vue'
import UploadIndex from '../../views/main_frame/components/UploadIndex.vue'
const routes = [
    {
      path: "/mainFrame",
      name: "mainFrame",
        component: MainFrame,
        redirect:'/mainFrame/recordIndex',
        children:[
            {
                path: "/mainFrame/recordIndex",
                name: 'recordIndex',
                component: RecordIndex,
                
            },
             {
                path: "/mainFrame/messageIndex",
                name: 'messageIndex',
                component: MessageIndex
          }, {
                path: "/mainFrame/uploadIndex",
                name: 'uploadIndex',
                component: UploadIndex
          }
      ]
    }
  ];

export default routes;
