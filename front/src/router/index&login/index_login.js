
import UserIndex from "../../views/login_frame/UserIndex.vue";
import LoginIndex from '../../views/login_frame/LoginIndex.vue'
import UserLogin from "../../views/login_frame/components/UserLogin.vue";
import UserRegister from "../../views/login_frame/components/UserRegister.vue";
const routes = [
    {
      path: "/",
      name: "userIndex",
      component: UserIndex,
    },
    {
        path: "/loginIndex",
        name: "LoginIndex",
        component: LoginIndex,
        redirect:'/loginIndex/userLogin',
        children: [
            {
                path: "/loginIndex/userLogin",
                name: 'userLogin',
                component: UserLogin,
            },{
                path: "/loginIndex/userRegister",
                name: 'userRegister',
                component: UserRegister,
            },
        ]
    }
  ]; 

export default routes;
