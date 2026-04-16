<script setup>
import { useRouter, useRoute } from 'vue-router'
// import RecordIndex from './components/RecordIndex.vue'
import TotalFloor from '../../components/TotalFloor.vue'
const router = useRouter()
const route = useRoute()
const showComponent = (component, item) => {
    // console.log(component)
    router.push({ name: component })
    // console.log(item)
}
const handleClick = (event) => {
    // console.log(event)

    // 删除active
    // 获取所有子元素li
    const liElements = document.querySelectorAll('.center li')
    // 遍历所有子元素li并删除active属性
    liElements.forEach((li) => {
        li.classList.remove('active')
    })
    event.target.classList.add('active')
}
</script>

<template>
    <div class="nav">
        <el-header class="user-login-nav">
            
            <ul class="center" @click="handleClick">
                <li @click="showComponent('recordIndex')" class="active">
                    历史记录
                </li>
                <li @click="showComponent('uploadIndex')">上传图片</li>
                <li @click="showComponent('messageIndex')">个人信息</li>
            </ul>
            <div class="user-actions"></div>
        </el-header>
        <!-- 这个是中间的三个操作 -->
    </div>
    <router-view></router-view>
    <TotalFloor></TotalFloor>
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
}
.center {
    display: flex;
}
.center li {
    padding: 0 10px;
    font-size: 16px;
    font-weight: 400;
    letter-spacing: 0px;
    line-height: 24px;
    color: rgba(29, 33, 41, 1);
    vertical-align: top;
}

.center li:hover {
    cursor: pointer;
    /* background-color: lightgray; 设置鼠标悬停时的背景色为浅灰色 */
    font-weight: bold; /* 设置鼠标悬停时的字体加粗 */
}
.user-actions {
    display: flex;
    gap: 10px;
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

.active {
    font-weight: 1000 !important;
}
</style>
