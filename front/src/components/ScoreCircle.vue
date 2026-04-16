<template>
    <div class="score-circle">
      <el-progress
        :percentage="score"
        type="circle"
        :stroke-width="6"
        :color="circleColor"
        :format="format"
      />
    </div>
  </template>
  
  <script setup>
  import { computed } from 'vue'
  const props = defineProps({
    score: { type: Number, required: true }
  })
  
  const circleColor = computed(() => {
    if (props.score >= 80) return '#67C23A'
    if (props.score >= 50) return '#E6A23C'
    return '#F56C6C'
  })
  
  function format(percent) {
    return `${percent}分`
  }
  </script>
  
  <style scoped>
  .score-circle {
    width: 100px;
    margin: 10px;
  }
  </style>
  