<!-- 登陆注册页面 -->
<script setup>
import { useRouter, useRoute } from 'vue-router'
import LoginNav from './components/LoginNav.vue'
import TotalFloor from '../../components/TotalFloor.vue'
const router = useRouter()
const route = useRoute()
</script>

<template>
    <div class="login-page">
        <LoginNav></LoginNav>
        <router-view></router-view>
        <TotalFloor></TotalFloor>
    </div>
</template>

<style scoped>
</style>
