<script setup>
import UserLogin from './UserLogin.vue'
import UserRegister from './UserRegister.vue'
import { useRouter } from 'vue-router'

const router = useRouter()
function register() {
    router.push({ path: '/loginIndex/userRegister', component: UserRegister })
}

function login() {
    router.push({ path: '/loginIndex/userLogin', component: UserLogin })
}
</script>

<template>
    <el-header class="user-login-nav">

        <div class="user-actions">
            <button class="register" @click="register">注册</button>
            <button class="login" @click="login">登录</button>
        </div>
    </el-header>
</template>

<style scoped>
.user-login-nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 20px;
}

.system-title {
    font-size: 24px;
    font-weight: bold;
    color: #333;
     color: #fff;
}
.center {
    display: flex;
}

.user-actions {
    display: flex;
    gap: 10px;
    position: relative;
    left: 1500px;
     color: #fff;
}

.register,
.login {
    padding: 10px 20px;
    font-size: 13px;
    color: #fff;
    background-color: #0000ff;
    border: none;
    border-radius: 31px;
    cursor: pointer;
    transition: background-color 0.3s, transform 0.3s; /* 添加变换过渡 */
    box-shadow: 0 2px 4px rgba(0, 123, 255, 0.2); /* 添加阴影 */
    text-transform: uppercase; /* 文本大写 */
    letter-spacing: 0.5px; /* 字间距 */
    outline: none; /* 移除焦点轮廓 */
}
.login {
    color: #333;
    background-color: #fff;
}

.login:hover {
    background-color: #e6e1e1;
    transform: translateY(-2px); /* 悬停时上移 */
}

.register:hover {
    background-color: #057cfa;
    transform: translateY(-2px); /* 悬停时上移 */
}

.register:active,
.login:active {
    transform: translateY(0); /* 点击时回到原位 */
}
.user-login-nav {
  position: relative; /* 或 fixed */
  z-index: 9999;
}
</style>
