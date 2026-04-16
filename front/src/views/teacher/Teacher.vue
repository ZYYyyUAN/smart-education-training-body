<template>
  <div class="teacher-home" :class="{ 'dark-mode': isDark }">
    <!-- 头部由 TeacherLayout 提供，这里不再渲染本地头部 -->
    <main class="main-content">
      <Carousel />

      <div class="promo-section">
        <div class="promo-content">
          <h2>🌟Hi~ {{ currentTeacherName }}老师，打造您的专属智能教学空间</h2>
          <p>AI赋能教学 · 智慧课堂 · 数据驱动</p>
          <ul class="features">
          <li data-icon="📊">智能学情分析与可视化报告</li>
          <li data-icon="🎯">个性化教学内容推荐</li>
          <li data-icon="🤖">AI助教与自动答疑系统</li>
          <li data-icon="📈">实时教学效果反馈</li>
        </ul>
          <button class="cta-btn">开启智慧教学之旅 ➜</button>
        </div>
        
        <!-- 教师专属装饰图片 -->
        <div class="teacher-illustration">
          <div class="teacher-image-wrapper">
            <img src="@/assets/images/设计机器人版本 (1).png" alt="智能教学助手" class="teacher-image" />
            <div class="teacher-glow"></div>
            <div class="floating-elements">
              <div class="floating-icon icon-1">📚</div>
              <div class="floating-icon icon-2">🎓</div>
              <div class="floating-icon icon-3">💡</div>
              <div class="floating-icon icon-4">📊</div>
              <div class="floating-icon icon-5">🚀</div>
            </div>
          </div>
        </div>
      </div> -->

      <!-- <div class="chat-section">
        <ChatBox />
      </div> -->
    </main>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import Carousel from '../../components/Carousel.vue'
import ChatBox from '../../components/chatbox.vue'

const isDark = ref(false)

// 获取当前教师名
const currentTeacherName = computed(() => {
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    return user?.realName || user?.username || ''
  } catch {
    return ''
  }
})
</script>

<style scoped>
:root {
  --bg-color: #f4f6fc;
  --text-color: #222;
  --primary-color: #1e3a8a;
  --secondary-color: #64748b;
  --header-bg: #fff;
  --card-bg: #fff;
  --hover-bg: #f1f5f9;
  --border-radius: 12px;
  --teacher-primary: #059669;
  --teacher-secondary: #0d9488;
}

.dark-mode {
  --bg-color: #121826;
  --text-color: #f1f5f9;
  --primary-color: #3b82f6;
  --secondary-color: #94a3b8;
  --header-bg: #1e293b;
  --card-bg: #1f2937;
  --hover-bg: #334155;
  --teacher-primary: #10b981;
  --teacher-secondary: #14b8a6;
}

.teacher-home {
  min-height: 100vh;
  background: #f8fafc;
  background-attachment: fixed;
}

/* 广告推广区 */
.promo-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #ffffff;
  border-radius: 32px;
  padding: 3rem 4rem;
  margin-top: 2rem;
  box-shadow: 
    0 20px 60px rgba(0, 0, 0, 0.1),
    0 8px 25px rgba(0, 0, 0, 0.08),
    inset 0 1px 0 rgba(255, 255, 255, 0.7);
  gap: 3rem;
  position: relative;
  overflow: visible;
  border: 1px solid rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
}

.promo-section::before {
  content: "";
  position: absolute;
  width: 200px;
  height: 200px;
  background: radial-gradient(circle at center, rgba(0, 0, 0, 0.02), transparent);
  border-radius: 50%;
  top: -50px;
  left: -70px;
  z-index: 0;
  animation: float 6s ease-in-out infinite;
}
.promo-section::after {
  content: "";
  position: absolute;
  width: 150px;
  height: 150px;
  background: radial-gradient(circle at center, rgba(220, 252, 231, 0.4), transparent);
  border-radius: 50%;
  bottom: -40px;
  right: -60px;
  z-index: 0;
  animation: float 6s ease-in-out infinite reverse;
}

.promo-content {
  max-width: 60%;
  z-index: 1;
  margin-right: 120px;
  position: relative;
}

.promo-content h2 {
  font-size: 2.1rem;
  background: linear-gradient(135deg, #10b981, #059669, #0d9488, #0891b2);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 1rem;
  line-height: 1.3;
  font-weight: 800;
  letter-spacing: -0.5px;
  text-shadow: 0 2px 8px rgba(5, 150, 105, 0.2);
}

.promo-content p {
  font-size: 1.2rem;
  color: var(--secondary-color);
  margin-bottom: 1.5rem;
  font-weight: 500;
  letter-spacing: 0.3px;
  opacity: 0.9;
}

.features {
  list-style: none;
  padding: 0;
  margin: 1.5rem 0;
  display: flex;
  flex-direction: column;
  gap: 0.8rem;
}

.features li {
  font-size: 1rem;
  color: var(--text-color);
  position: relative;
  padding-left: 2rem;
  font-weight: 500;
  transition: all 0.3s ease;
}

.features li::before {
  content: attr(data-icon);
  position: absolute;
  left: 0;
  top: 0;
  font-size: 1rem;
  animation: sparkle 2s ease-in-out infinite;
}

.features li:hover {
  transform: translateX(8px);
  color: var(--teacher-primary);
}

.cta-btn {
  background: linear-gradient(135deg, #10b981, #059669, #0d9488, #0891b2);
  color: #fff;
  padding: 1rem 2.2rem;
  font-weight: 700;
  border: none;
  border-radius: 20px;
  font-size: 1.15rem;
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
  box-shadow: 0 8px 25px rgba(16, 185, 129, 0.4);
  backdrop-filter: blur(10px);
}

.cta-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.6s ease;
}

.cta-btn:hover {
  transform: translateY(-4px) scale(1.03);
  box-shadow: 0 15px 40px rgba(16, 185, 129, 0.5);
  background: linear-gradient(135deg, #0891b2, #0d9488, #059669, #10b981);
}

.cta-btn:hover::before {
  left: 100%;
}

.cta-btn:active {
  transform: translateY(-1px) scale(0.98);
}

/* 教师专属装饰 */
.teacher-illustration {
  position: absolute;
  top: 20px;
  right: 20px;
  z-index: 15;
  pointer-events: none;
  transform: perspective(1200px) rotateY(-12deg) rotateX(3deg);
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.teacher-illustration:hover {
  transform: perspective(1200px) rotateY(-8deg) rotateX(1deg) scale(1.08);
}

.teacher-image-wrapper {
  position: relative;
  z-index: 2;
}

.teacher-image {
  width: 320px;
  height: 270px;
  object-fit: contain;
  filter: drop-shadow(0 15px 35px rgba(0, 0, 0, 0.25)) 
          drop-shadow(0 5px 15px rgba(16, 185, 129, 0.1));
  animation: teacherFloat 5s ease-in-out infinite;
  transition: all 0.4s ease;
  border-radius: 24px;
}

.teacher-image:hover {
  filter: drop-shadow(0 20px 40px rgba(0, 0, 0, 0.3)) 
          drop-shadow(0 8px 25px rgba(16, 185, 129, 0.2));
}

.teacher-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 200px;
  height: 200px;
  background: radial-gradient(circle, rgba(16, 185, 129, 0.3), rgba(13, 148, 136, 0.2), transparent);
  border-radius: 50%;
  animation: glowPulse 4s ease-in-out infinite;
  z-index: -1;
  filter: blur(3px);
}

.floating-elements {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.floating-icon {
  position: absolute;
  font-size: 1.5rem;
  animation: iconFloat 4s ease-in-out infinite;
  opacity: 0.8;
}

.icon-1 {
  top: 15%;
  left: 10%;
  animation-delay: 0s;
}

.icon-2 {
  top: 50%;
  right: 15%;
  animation-delay: 0.8s;
}

.icon-3 {
  bottom: 25%;
  left: 20%;
  animation-delay: 1.6s;
}

.icon-4 {
  top: 35%;
  right: 25%;
  animation-delay: 2.4s;
}

.icon-5 {
  bottom: 15%;
  right: 10%;
  animation-delay: 3.2s;
}

.chat-section {
  background: var(--card-bg);
  border-radius: 24px;
  padding: 2rem;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
}

/* ChatBox 浮动窗口（如果启用） */
.chat-float-panel {
  position: fixed;
  top: 90px;
  right: 30px;
  width: 420px;
  height: 80vh;
  background-color: var(--card-bg);
  box-shadow: -4px 0 24px rgba(0, 0, 0, 0.1);
  border-radius: var(--border-radius);
  z-index: 999;
  overflow: hidden;
  padding: 1rem;
}

/* 动画关键帧 */
@keyframes teacherFloat {
  0%, 100% {
    transform: translateY(0px) rotate(0deg);
  }
  33% {
    transform: translateY(-8px) rotate(1deg);
  }
  66% {
    transform: translateY(-12px) rotate(-1deg);
  }
}

@keyframes glowPulse {
  0%, 100% {
    opacity: 0.4;
    transform: translate(-50%, -50%) scale(1);
  }
  50% {
    opacity: 0.7;
    transform: translate(-50%, -50%) scale(1.15);
  }
}

@keyframes iconFloat {
  0%, 100% {
    transform: translateY(0px) scale(1);
    opacity: 0.6;
  }
  50% {
    transform: translateY(-20px) scale(1.3);
    opacity: 1;
  }
}

@keyframes float {
  0%, 100% {
    transform: translateY(0px) scale(1);
    opacity: 0.6;
  }
  50% {
    transform: translateY(-20px) scale(1.3);
    opacity: 1;
  }
}

@keyframes gradientShift {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}

@keyframes sparkle {
  0%, 100% {
    transform: scale(1) rotate(0deg);
    opacity: 1;
  }
  50% {
    transform: scale(1.2) rotate(180deg);
    opacity: 0.8;
  }
}

/* 动画 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .main-content {
    padding: 1.5rem 0;
    max-width: 96vw;
  }
  
  .promo-section {
    padding: 2rem 2.5rem;
    gap: 2rem;
  }
  
  .teacher-image {
    width: 280px;
    height: 230px;
  }
}

@media (max-width: 900px) {
  .promo-section {
    flex-direction: column;
    text-align: center;
    padding: 2.5rem 2rem;
  }
  
  .promo-content {
    max-width: 100%;
    margin-right: 0;
    margin-bottom: 2rem;
  }
  
  .teacher-illustration {
    position: static;
    transform: none;
    margin: 0 auto;
  }
  
  .teacher-image {
    width: 250px;
    height: 200px;
  }
}

@media (max-width: 768px) {
  .main-content {
    padding: 1rem 0;
    max-width: 98vw;
  }
  
  .promo-section {
    border-radius: 20px;
    padding: 2rem 1.5rem;
    margin-top: 1rem;
  }
  
  .promo-content h2 {
    font-size: 1.8rem;
  }
  
  .promo-content p {
    font-size: 1rem;
  }
  
  .features {
    gap: 0.6rem;
  }
  
  .features li {
    font-size: 0.9rem;
    padding-left: 1.5rem;
  }
  
  .cta-btn {
    padding: 0.8rem 1.5rem;
    font-size: 1rem;
  }
  
  .teacher-image {
    width: 200px;
    height: 160px;
  }
  
  .chat-section {
    padding: 1.5rem;
    border-radius: 16px;
  }
}

@media (max-width: 480px) {
  .main-content {
    padding: 0.8rem 0;
    max-width: 100vw;
  }
  
  .promo-section {
    padding: 1.5rem 1rem;
    border-radius: 16px;
  }
  
  .promo-content h2 {
    font-size: 1.5rem;
    line-height: 1.4;
  }
  
  .features li {
    font-size: 0.85rem;
  }
  
  .cta-btn {
    padding: 0.7rem 1.2rem;
    font-size: 0.9rem;
    border-radius: 16px;
  }
  
  .teacher-image {
    width: 180px;
    height: 140px;
  }
}
</style>
