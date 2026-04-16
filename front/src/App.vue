<template>
    <!-- <UserIndex></UserIndex> -->
    <!-- <UserLogin></UserLogin> -->
    <!-- <RecordIndex></RecordIndex> -->
    <!-- <router-view></router-view>-->
      <router-view v-slot="{ Component }">
    <transition name="fade" mode="out-in">
      <component :is="Component" />
    </transition>
  </router-view>
</template>

<script>
import MainFrame from './views/main_frame/MainFrame.vue'
export default {
    name: 'App',
    components: {
        MainFrame
    }
}
</script>
<style>
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.5s;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

/* 防止滚动条出现时页面偏移 */
html {
  overflow-y: scroll;
}

body {
  margin: 0;
  padding: 0;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

/* 亮色模式
body {
  background-color: #fff;
  color: #000;
  transition: background-color 0.3s, color 0.3s;
}

/* 暗色模式 */
/* html.dark body {
  background-color: #121212;
  color: #eee;
} */ 

</style>