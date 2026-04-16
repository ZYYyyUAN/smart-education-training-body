<template>
  <div class="carousel-wrapper">
    <DynamicBackground />

  <div
    class="carousel-container"
    @mouseenter="pauseAutoPlay"
    @mouseleave="startAutoPlay"
    @touchstart="onTouchStart"
    @touchend="onTouchEnd"
  >
    <!-- 当前与上一张叠加，形成平滑交叉淡入淡出 -->
    <div
      class="slide current"
      v-if="currentSlide"
      :style="getSlideStyle(currentSlide)"
      :class="{ entering: isAnimating }"
    >
      <div class="slide-content" :class="getTextPositionClass()">
        <h2>{{ currentSlide.title }}</h2>
        <p>{{ currentSlide.subtitle }}</p>
      </div>
    </div>

    <div
      class="slide previous"
      v-if="previousSlide"
      :style="getSlideStyle(previousSlide)"
      :class="{ leaving: isAnimating }"
    >
      <div class="slide-content" :class="getPreviousTextPositionClass()">
        <h2>{{ previousSlide.title }}</h2>
        <p>{{ previousSlide.subtitle }}</p>
      </div>
    </div>

      <!-- 左右切换按钮 -->
      <button class="carousel-btn prev" @click="prevSlide">❮</button>
      <button class="carousel-btn next" @click="nextSlide">❯</button>

      <!-- 指示器 -->
      <div class="carousel-indicators">
        <button 
          v-for="(slide, index) in slides" 
          :key="index"
          class="indicator"
          :class="{ active: index === currentIndex }"
          @click="goToSlide(index)"
        ></button>
      </div>

    </div>
  </div>
</template>


<script setup>
import DynamicBackground from '@/components/DynamicBackground.vue'
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import s1 from '../assets/images/s1.png'
import s2 from '../assets/images/s2.png'
import s3 from '../assets/images/s3.png'

const slides = ref([
  {
    title: '自然语言交互式智能教学平台',
    subtitle: '通慧智教 AI赋能',
    image: s1
  },
  {
    title: '有温度、有感情的个性化教学',
    subtitle: '通慧智教 让学习更高效',
    image: s2
  },
  {
    title: '智能辅导 因材施教',
    subtitle: '通慧智教 您的学习伙伴',
    image: s3
  }
])

const AUTOPLAY_MS = 5000
const ANIM_MS = 700

const currentIndex = ref(0)
const previousIndex = ref(null)
const isAnimating = ref(false)
const touchStartX = ref(null)

const currentSlide = computed(() => slides.value[currentIndex.value])
const previousSlide = computed(() =>
  previousIndex.value === null ? null : slides.value[previousIndex.value]
)

const getSlideStyle = (slide) => ({ backgroundImage: `url(${slide.image})` })

// 获取文字位置类名 - 整个区域内移动，特定幻灯片位置固定
const getTextPositionClass = () => {
  // 第二个幻灯片(索引1)和第三个幻灯片(索引2)使用相同位置
  if (currentIndex.value === 1) {
    return `position-${getPositionForSlide(2)}`
  }
  return `position-${getPositionForSlide(currentIndex.value)}`
}

const getPreviousTextPositionClass = () => {
  if (previousIndex.value === null) return ''
  // 第二个幻灯片(索引1)和第三个幻灯片(索引2)使用相同位置
  if (previousIndex.value === 1) {
    return `position-${getPositionForSlide(2)}`
  }
  return `position-${getPositionForSlide(previousIndex.value)}`
}

// 根据幻灯片索引获取位置类
const getPositionForSlide = (index) => {
  const positions = [
    'pos-1', 'pos-2', 'pos-3', 'pos-4', 'pos-5', 'pos-6', 
    'pos-7', 'pos-8', 'pos-9', 'pos-10', 'pos-11', 'pos-12'
  ]
  return positions[index % positions.length]
}

let interval = null

const safeSwitch = (calcNextIndex) => {
  if (isAnimating.value) return
  isAnimating.value = true
  previousIndex.value = currentIndex.value
  currentIndex.value = calcNextIndex()
  setTimeout(() => {
    previousIndex.value = null
    isAnimating.value = false
  }, ANIM_MS)
}

const nextSlide = () => {
  safeSwitch(() => (currentIndex.value + 1) % slides.value.length)
}
const prevSlide = () => {
  safeSwitch(() => (currentIndex.value - 1 + slides.value.length) % slides.value.length)
}
const goToSlide = (index) => {
  if (index === currentIndex.value) return
  safeSwitch(() => index)
}

const clearTimer = () => interval && clearInterval(interval)
const startAutoPlay = () => {
  clearTimer()
  interval = setInterval(nextSlide, AUTOPLAY_MS)
}
const pauseAutoPlay = () => clearTimer()

const onVisibilityChange = () => {
  if (document.hidden) {
    pauseAutoPlay()
  } else {
    startAutoPlay()
  }
}

const onTouchStart = (e) => {
  touchStartX.value = e.changedTouches[0].clientX
  pauseAutoPlay()
}
const onTouchEnd = (e) => {
  const delta = e.changedTouches[0].clientX - (touchStartX.value ?? 0)
  if (Math.abs(delta) > 40) {
    delta < 0 ? nextSlide() : prevSlide()
  }
  startAutoPlay()
}

onMounted(() => {
  startAutoPlay()
  document.addEventListener('visibilitychange', onVisibilityChange)
})
onBeforeUnmount(() => {
  clearTimer()
  document.removeEventListener('visibilitychange', onVisibilityChange)
})
</script>



<style scoped>
.carousel-wrapper {
  position: relative;
  width: 100%;
  height: 65vh;
  overflow: hidden;
  border-radius: 24px;
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
  margin: 1rem 0;
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(139, 92, 246, 0.1));
}
.carousel-wrapper::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(45deg, rgba(255, 255, 255, 0.1), transparent);
  border-radius: 24px;
  z-index: 1;
  pointer-events: none;
}
.carousel-wrapper > * {
  position: relative;
  z-index: 2;
}
#tsparticles {
  position: absolute;
  top: 0;
  left: 0;
  z-index: 0;
  width: 100vw;
  height: 100vh;
}
.carousel-container {
  position: relative;
  width: 100%;
  height: 550px;
  overflow: hidden;
  border-radius: 24px;
  perspective: 1000px;
  transform-style: preserve-3d;
}

.carousel {
  display: relative;
  transition: transform 0.5s ease;
  height: 500px;
}

.slide {
  position: absolute;
  min-width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  border-radius: 24px;
  overflow: hidden;
  position: relative;
  will-change: transform, opacity, filter;
  backface-visibility: hidden;
  transform-style: preserve-3d;
}
.slide::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle at center, 
    transparent 30%, 
    rgba(0, 0, 0, 0.1) 60%, 
    rgba(0, 0, 0, 0.3) 100%);
  z-index: 1;
  pointer-events: none;
}
.current { z-index: 2; }
.previous { z-index: 1; }

/* 进入/离开动画（更自然的交叉淡入淡出） */
.current.entering { 
  animation: fadeInSmooth var(--anim-ms) cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards, 
             kenBurnsBg 6s ease-in-out forwards,
             slideInFromRight 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}
.previous.leaving { 
  animation: fadeOutSmooth var(--anim-ms) cubic-bezier(0.55, 0.06, 0.68, 0.19) forwards,
             slideOutToLeft 0.8s cubic-bezier(0.55, 0.06, 0.68, 0.19) forwards;
}

/* 为 CSS 动画提供变量 */
:root { --anim-ms: 700ms; }
/* 文字容器：整个区域自由移动设计 */
.slide-content {
  position: absolute;
  max-width: 350px;
  min-width: 280px;
  padding: 1.8rem 1.6rem;
  background: rgba(255, 255, 255, 0.08);
  backdrop-filter: blur(25px) saturate(200%);
  border: 1px solid rgba(255, 255, 255, 0.15);
  color: white;
  text-align: left;
  z-index: 2;
  border-radius: 20px;
  box-shadow: 
    0 8px 32px rgba(0, 0, 0, 0.3),
    inset 0 1px 0 rgba(255, 255, 255, 0.2);
  transition: all 2.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  opacity: 0;
  animation: floatIn 1.2s ease-out 0.3s forwards, gentleFloat 12s ease-in-out infinite 2s;
  transform: translateY(20px) scale(0.95);
}

/* 动态位置类 - 整个区域内自由移动 */
.slide-content.position-pos-1 {
  top: 8%;
  left: 5%;
  text-align: left;
}

.slide-content.position-pos-2 {
  top: 8%;
  left: 50%;
  transform: translateX(-50%);
  text-align: center;
}

.slide-content.position-pos-3 {
  top: 8%;
  right: 5%;
  text-align: right;
}

.slide-content.position-pos-4 {
  top: 30%;
  right: 8%;
  text-align: right;
}

.slide-content.position-pos-5 {
  top: 50%;
  right: 5%;
  transform: translateY(-50%);
  text-align: right;
}

.slide-content.position-pos-6 {
  top: 70%;
  right: 8%;
  text-align: right;
}

.slide-content.position-pos-7 {
  bottom: 8%;
  right: 5%;
  text-align: right;
}

.slide-content.position-pos-8 {
  bottom: 8%;
  left: 50%;
  transform: translateX(-50%);
  text-align: center;
}

.slide-content.position-pos-9 {
  bottom: 8%;
  left: 5%;
  text-align: left;
}

.slide-content.position-pos-10 {
  top: 70%;
  left: 8%;
  text-align: left;
}

.slide-content.position-pos-11 {
  top: 50%;
  left: 5%;
  transform: translateY(-50%);
  text-align: left;
}

.slide-content.position-pos-12 {
  top: 30%;
  left: 8%;
  text-align: left;
}

/* 悬浮效果 */
.slide-content:hover {
  transform: translateY(-10px) scale(1.05);
  box-shadow: 
    0 20px 60px rgba(0, 0, 0, 0.5),
    inset 0 1px 0 rgba(255, 255, 255, 0.4);
  animation-play-state: paused;
}
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
@keyframes fadeInSmooth {
  0% { 
    opacity: 0; 
    transform: scale(1.05) translateX(20px); 
    filter: blur(2px);
  }
  50% {
    opacity: 0.7;
    transform: scale(1.02) translateX(5px);
    filter: blur(1px);
  }
  100% { 
    opacity: 1; 
    transform: scale(1) translateX(0); 
    filter: blur(0);
  }
}
@keyframes fadeOutSmooth {
  0% { 
    opacity: 1; 
    transform: scale(1) translateX(0); 
    filter: blur(0);
  }
  50% {
    opacity: 0.5;
    transform: scale(0.98) translateX(-10px);
    filter: blur(1px);
  }
  100% { 
    opacity: 0; 
    transform: scale(0.95) translateX(-30px); 
    filter: blur(2px);
  }
}

/* 新增：滑入滑出动画 */
@keyframes slideInFromRight {
  0% {
    transform: translateX(100%) scale(0.9);
    opacity: 0;
  }
  60% {
    transform: translateX(-5%) scale(1.02);
    opacity: 0.8;
  }
  100% {
    transform: translateX(0) scale(1);
    opacity: 1;
  }
}

@keyframes slideOutToLeft {
  0% {
    transform: translateX(0) scale(1);
    opacity: 1;
  }
  40% {
    transform: translateX(5%) scale(0.98);
    opacity: 0.6;
  }
  100% {
    transform: translateX(-100%) scale(0.9);
    opacity: 0;
  }
}
@keyframes kenBurnsBg {
  0% { 
    background-size: 105%; 
    transform: scale(1.02);
  }
  100% { 
    background-size: 100%; 
    transform: scale(1);
  }
}

@keyframes floatIn {
  0% {
    transform: translateY(40px) scale(0.85) rotateX(15deg);
    opacity: 0;
    filter: blur(3px);
  }
  30% {
    transform: translateY(15px) scale(0.95) rotateX(5deg);
    opacity: 0.6;
    filter: blur(1px);
  }
  70% {
    transform: translateY(-5px) scale(1.02) rotateX(-2deg);
    opacity: 0.9;
    filter: blur(0.5px);
  }
  100% {
    transform: translateY(0) scale(1) rotateX(0deg);
    opacity: 1;
    filter: blur(0);
  }
}

@keyframes gentleFloat {
  0%, 100% {
    transform: translateX(0px) translateY(0px) rotate(0deg) scale(1);
  }
  12% {
    transform: translateX(40px) translateY(-35px) rotate(1.5deg) scale(1.02);
  }
  25% {
    transform: translateX(-30px) translateY(25px) rotate(0deg) scale(0.98);
  }
  37% {
    transform: translateX(50px) translateY(-20px) rotate(-1deg) scale(1.03);
  }
  50% {
    transform: translateX(-25px) translateY(40px) rotate(1deg) scale(0.99);
  }
  62% {
    transform: translateX(35px) translateY(-45px) rotate(-1.5deg) scale(1.01);
  }
  75% {
    transform: translateX(-40px) translateY(30px) rotate(0.5deg) scale(1.02);
  }
  87% {
    transform: translateX(45px) translateY(-25px) rotate(-0.8deg) scale(0.98);
  }
}

@keyframes expandLine {
  0% {
    transform: scaleX(0);
  }
  100% {
    transform: scaleX(1);
  }
}

@media (max-width: 1024px) {
  .slide-content {
    max-width: 350px;
    min-width: 280px;
    padding: 1.8rem 1.5rem;
  }
  .slide-content.position-pos-1,
  .slide-content.position-pos-9,
  .slide-content.position-pos-10,
  .slide-content.position-pos-11,
  .slide-content.position-pos-12 {
    left: 3%;
  }
  
  .slide-content.position-pos-3,
  .slide-content.position-pos-4,
  .slide-content.position-pos-5,
  .slide-content.position-pos-6,
  .slide-content.position-pos-7 {
    right: 3%;
  }
  
  .slide-content.position-pos-2,
  .slide-content.position-pos-8 {
    left: 50%;
    transform: translateX(-50%);
  }
  
  .slide-content.position-pos-1,
  .slide-content.position-pos-2,
  .slide-content.position-pos-3 {
    top: 6%;
  }
  
  .slide-content.position-pos-7,
  .slide-content.position-pos-8,
  .slide-content.position-pos-9 {
    bottom: 6%;
  }
  
  .slide-content.position-pos-4,
  .slide-content.position-pos-12 {
    top: 25%;
  }
  
  .slide-content.position-pos-5,
  .slide-content.position-pos-11 {
    top: 50%;
    transform: translateY(-50%);
  }
  
  .slide-content.position-pos-6,
  .slide-content.position-pos-10 {
    top: 75%;
  }
  .slide-content h2 {
    font-size: 1.9rem;
  }
}

@media (max-width: 768px) {
  .carousel-wrapper {
    height: 50vh;
    border-radius: 16px;
  }
  .carousel-container {
    height: 400px;
    border-radius: 16px;
  }
  .slide-content {
    position: static;
    max-width: calc(100% - 2rem);
    min-width: auto;
    margin: 1rem auto 2rem;
    padding: 1.5rem;
    border-radius: 16px;
    text-align: center;
    animation: mobileFloatIn 1s ease-out 0.3s forwards, gentleFloat 12s ease-in-out infinite 1.3s;
  }
  .slide-content.position-top-left,
  .slide-content.position-top-right,
  .slide-content.position-bottom-left,
  .slide-content.position-bottom-right {
    position: static;
    text-align: center;
  }
  .slide-content h2 {
    font-size: 1.6rem;
    margin-bottom: 0.8rem;
  }
  .slide-content h2::after {
    left: 50%;
    transform: translateX(-50%) scaleX(0);
    animation: expandLineCenter 0.8s ease-out 0.8s forwards;
  }
  .slide-content p {
    font-size: 0.9rem;
  }
  .carousel-btn {
    width: 45px;
    height: 45px;
    font-size: 1.4rem;
  }
  .prev {
    left: 1rem;
  }
  .next {
    right: 1rem;
  }
}

@keyframes mobileFloatIn {
  0% {
    transform: translateY(30px) scale(0.9);
    opacity: 0;
  }
  100% {
    transform: translateY(0) scale(1);
    opacity: 1;
  }
}

@keyframes expandLineCenter {
  0% {
    transform: translateX(-50%) scaleX(0);
  }
  100% {
    transform: translateX(-50%) scaleX(1);
  }
}

/* 移除遮罩 */
.slide::before {
  display: none;
}


.slide-content h2 {
  font-size: 2.2rem;
  margin-bottom: 1.2rem;
  font-weight: 700;
  color: #ffffff;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.5);
  letter-spacing: -0.3px;
  line-height: 1.3;
  position: relative;
}

.slide-content h2::after {
  content: '';
  position: absolute;
  bottom: -8px;
  left: 0;
  width: 60px;
  height: 3px;
  background: linear-gradient(90deg, #3b82f6, #8b5cf6);
  border-radius: 2px;
  animation: expandLine 0.8s ease-out 0.8s forwards;
  transform: scaleX(0);
  transform-origin: left;
}

.slide-content p {
  font-size: 1.1rem;
  opacity: 0.9;
  font-weight: 400;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4);
  letter-spacing: 0.3px;
  line-height: 1.6;
  color: rgba(255, 255, 255, 0.95);
}


.carousel-btn {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: white;
  padding: 1.2rem;
  cursor: pointer;
  font-size: 1.8rem;
  border-radius: 50%;
  z-index: 10;
  transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
  will-change: transform, background, box-shadow;
  opacity: 0.8;
}

.carousel-btn:hover {
  transform: translateY(-50%) scale(1.15) rotateY(5deg);
  background: rgba(255, 255, 255, 0.3);
  box-shadow: 0 15px 50px rgba(0, 0, 0, 0.25);
  border-color: rgba(255, 255, 255, 0.4);
  opacity: 1;
  filter: brightness(1.1);
}

.carousel-btn:active {
  transform: translateY(-50%) scale(1.05) rotateY(2deg);
  transition: all 0.1s cubic-bezier(0.4, 0, 0.2, 1);
}

.prev {
  left: 2.5rem;
}

.next {
  right: 2.5rem;
}

/* 指示器样式 */
.carousel-indicators {
  position: absolute;
  bottom: 2rem;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 0.8rem;
  z-index: 10;
}

.indicator {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  border: 2px solid rgba(255, 255, 255, 0.5);
  background: transparent;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  backdrop-filter: blur(10px);
}

.indicator:hover {
  transform: scale(1.2);
  border-color: rgba(255, 255, 255, 0.8);
  background: rgba(255, 255, 255, 0.2);
}

.indicator.active {
  background: rgba(255, 255, 255, 0.9);
  border-color: rgba(255, 255, 255, 1);
  transform: scale(1.3);
  box-shadow: 0 0 20px rgba(255, 255, 255, 0.5);
}

.indicator.active:hover {
  transform: scale(1.4);
  box-shadow: 0 0 25px rgba(255, 255, 255, 0.7);
}

</style>