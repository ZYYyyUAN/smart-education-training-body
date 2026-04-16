<template>
  <div id="tsparticles" class="particles-container"></div>
</template>

<script setup>
import { onMounted } from 'vue'
import { loadSlim } from 'tsparticles-slim'

onMounted(async () => {
  try {
    // 确保容器元素存在
    const container = document.getElementById('tsparticles')
    if (!container) {
      console.error('找不到粒子容器元素')
      return
    }

    // 最简单的配置确保能工作
    await loadSlim("tsparticles", {
      particles: {
        number: {
          value: 80,
          density: {
            enable: true,
            area: 800
          }
        },
        color: {
          value: "#ffffff"
        },
        shape: {
          type: "circle"
        },
        opacity: {
          value: 0.5
        },
        size: {
          value: 3
        },
        links: {
          color: "#ffffff",
          distance: 150,
          enable: true
        },
        move: {
          enable: true,
          speed: 2
        }
      },
      interactivity: {
        events: {
          onHover: {
            enable: true,
            mode: "grab"
          }
        }
      }
    })
    
    console.log('粒子系统初始化成功')
  } catch (error) {
    console.error('粒子初始化失败:', error)
  }
})
</script>

<style>
.particles-container {
  position: fixed;
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  z-index: -1;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
}
</style>