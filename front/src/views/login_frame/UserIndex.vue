<!-- 进入网站第一个页面 -->
<template>
    <div class="container">
        <LoginNav></LoginNav>
        <IndexMain :imgUrl="imgUrl"></IndexMain>
        <LoginFloor></LoginFloor>
    </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import LoginNav from './components/LoginNav.vue'
import LoginFloor from '../../components/TotalFloor.vue'
import IndexMain from '../../components/IndexMain.vue'

let imgUrl = reactive({
    type: 1,
    style1: ' background: url(../../src/assets/images/oras.png); background-size: cover;',
    style2: ' background: url(../../src/assets/images/out.png);background-size: cover;',
    style3: '  background: url(../../src/assets/images/preview.png) no-repeat; background-size: cover;'
})
</script>

<style scoped>
.container {
    display: flex;
    flex-direction: column;
}
</style>