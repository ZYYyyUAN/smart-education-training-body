
<script setup>
import { reactive, onMounted } from 'vue'
import IndexMain from '../../../components/IndexMain.vue'
let imgUrl = reactive({
    type: 2,
    style1: ' background: url(https://img.js.design/assets/img/658329eea9191da08245d7c4.png); background-size: cover;',
    style2: ' background: url(https://img.js.design/assets/img/658329ee64fd351512d6f295.png) no-repeat center;',
    style3: '  background: url(https://img.js.design/assets/img/658329ee64fd351512d6f295.png) no-repeat; background-size: cover;'
})
</script>

<template>
    <IndexMain :imgUrl="imgUrl"></IndexMain>
</template>

<style scoped>
</style>
