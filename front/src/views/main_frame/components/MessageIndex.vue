<script setup>
import http from '../../../api/http.js'
import { ElMessage } from 'element-plus'
import axios from 'axios'
import { onMounted, reactive, ref } from 'vue'
let input_top = reactive([
    {
        text: '姓名',
        type: 'text',
        value: 'hahahadang',
        name: 'username'
    },
    {
        text: '邮箱',
        type: 'email',
        value: '19158658956',
        name: 'email'
    },
    {
        text: '年龄',
        type: 'number',
        value: 20,
        name: 'age'
    },
    {
        text: '地址',
        type: 'text',
        value: '西南石油大学',
        name: 'address'
    },
    {
        text: '手机号',
        type: 'tel',
        value: '19913865782',
        name: 'tel'
    }
])
let userMessage = reactive({})
// 获取个人信息
const getUserData = () => {
    http.get({
        url: '/users/getByIdentity'
    }).then((res) => {
        userMessage = res.data.data
        console.log('用户个人信息获取', res.data)
        // 渲染页面
        input_top.forEach((item, index) => {
            item.value = userMessage[item.name]
        })
    })
}

// messagePost上传个人信息
const messagePost = () => {
    const transformedInput = input_top.reduce((acc, obj) => {
        acc[obj.name] = obj.value
        return acc
    }, {})

    console.log(transformedInput)
    http.put({
        url: '/users/update',
        data: transformedInput
    })
        .then((res) => {
            ElMessage({
                dangerouslyUseHTMLString: true,
                showClose: true,
                message: '<div class="tip">个人信息提交成功</div>',
                type: 'success'
            })
            console.log('个人信息提交成功', res.data)
        })
        .catch((err) => {
            ElMessage.error('Error during API request:', error)
        })
    // axios({
    //     method:'post',
    //     url: 'http://localhost:3001/message/upload',
    //     data: userMessage
    // }).then((res) => {
    //     console.log('个人信息提交成功', res.data)
    // })
}
onMounted(() => {
    getUserData()
})
</script>

<template>
    <div class="container">
        <div class="img_1"></div>
        <div>
            <div class="img_2"></div>
        </div>

        <div class="bottom">
            <div class="title">个人信息</div>
            <div class="text">在这里可以查看和修改个人信息</div>
            <div class="input_top">
                <div
                    class="input_item"
                    v-for="(item, index) in input_top"
                    :key="index"
                >
                    <div class="input_text">{{ item.text }}</div>
                    <input :type="item.type" v-model="item.value" />
                </div>
            </div>
            <div>
                <el-button
                    type="primary"
                    class="upload_button"
                    @click="messagePost"
                    >提交</el-button
                >
            </div>
        </div>
    </div>
</template>

<style scoped>
/* 隐藏number类型input的默认样式 */
input[type='number']::-webkit-inner-spin-button,
input[type='number']::-webkit-outer-spin-button {
    -webkit-appearance: none;
    margin: 0;
}

.img_1 {
    margin-left: 95%;
    margin-bottom: 90px;
    transform: translateX(-1100px);
    background-image: url(https://img.js.design/assets/img/658329eeeffe80cb508f2fed.png);
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    width: 1000px;
    height: 400px;
    opacity: 1;
    border-radius: 50px;
    box-shadow: inset 0 0 20px 20px rgba(255, 255, 255); /* 内阴影，模糊半径为10px */
}

.img_2 {
    margin: 0 auto;
    width: 85%;
    height: 650px;
    border-radius: 32px;
    background-image: url(https://img.js.design/assets/img/658329ee7c6c4a259addfa56.png);
    background-size: cover;
    background-position: 0 -50px;
    background-repeat: no-repeat;
}
.title {
    margin-top: 90px;
    font-size: 56px;
    font-weight: 700;
    color: rgba(29, 33, 41, 1);
    text-align: center;
}

.text {
    margin-top: 20px;
    font-size: 18px;
    font-weight: 400;
    color: rgba(29, 33, 41, 1);
    text-align: center;
}
.input_top {
    width: 45%;
    margin: 0 auto;
    margin-top: 55px;
    text-align: center;
    display: flex;
    justify-content: space-between;
    flex-wrap: wrap;
}
.input_item {
    width: 40%;
    display: flex;
    flex-direction: column;
}
.input_text {
    margin: 20px 0;
    font-size: 20px;
    font-weight: 550;
    color: rgb(51, 57, 70);
    text-align: left;
    vertical-align: top;
}

.input_item input {
    font-size: 20px;
    width: 100%;
    height: 48px;
    padding-left: 20px;
    border: none; /* 去除边框 */
}

.input_item input:focus {
    border-radius: 48px;
    background: rgba(255, 255, 255, 1);
    border: 1px solid rgba(0, 0, 0, 0.3);
}

.upload_button {
    margin-top: 80px;
    margin-left: 50%;
    transform: translateX(-360px);
    width: 720px;
    height: 52px;
    border-radius: 52px;
}
</style>
