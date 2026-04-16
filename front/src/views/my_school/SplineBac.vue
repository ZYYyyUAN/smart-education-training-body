<script setup>
// Vue3Spline 已经在 main.js 中全局注册，无需重复导入
const props = defineProps(['scene'])
</script>
 
<template>
<div class="background-spline">
  <Vue3Spline :scene="scene"/>
</div>
</template>
 
<style scoped>
.background-spline {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: -1; /* Ensure it stays behind other content */
}
</style>