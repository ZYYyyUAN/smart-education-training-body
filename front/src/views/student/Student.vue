<template>
  <div class="app" :class="{ 'dark-mode': isDark }">
    <!-- 公共头部已由 StudentLayout 提供，这里去掉重复头部 -->

    <main class="main-content">
      <Carousel />



      <div class="promo-section">
        <div class="promo-content">
          <h2>🌟Hi~ {{ currentUserName }}同学，快来打造你的专属学习空间</h2>
          <p>个性化推荐 · 智能随练 · 实时反馈</p>
          <ul class="features">
            <li>✅ 大模型驱动的智能题目推荐</li>
            <li>✅ AI 纠错与讲解</li>
            <li>✅ 教师可视化学情分析</li>
          </ul>
          <button class="cta-btn">立即体验智能教学 ➜</button>
        </div>
        
        <!-- 机器人图片 -->
        <div class="robot-overlay">
          <div class="robot-image-wrapper">
            <img src="@/assets/images/设计机器人版本 (1).png" alt="智能学习机器人" class="robot-image" />
          </div>
        </div>
      </div>


    </main>

  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { computed } from 'vue'
import Carousel from '../../components/Carousel.vue'

const router = useRouter()

// 退出登录
const onLogout = () => {
  try {
    localStorage.removeItem('token')
    localStorage.removeItem('currentUser')
  } catch (e) {}
  router.replace('/')
}

// 获取当前用户名
const currentUserName = computed(() => {
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    return user?.realName || user?.username || '同学'
  } catch {
    return '同学'
  }
})
</script>

<style>
:root {
  --bg-color: #f4f6fc;
  --text-color: #222;
  --primary-color: #1e3a8a;
  --secondary-color: #64748b;
}

.dark-mode {
  --bg-color: #121826;
  --text-color: #f1f5f9;
  --primary-color: #3b82f6;
  --secondary-color: #94a3b8;
}

.app {
  min-height: 100vh;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background-color: var(--bg-color);
  color: var(--text-color);
  transition: background 0.3s, color 0.3s;
}



/* 机器人图片 */
.robot-overlay {
  position: absolute;
  top: 20px;
  right: 20px;
  z-index: 15;
  pointer-events: none;
}

.robot-image-wrapper {
  position: relative;
}

.robot-image {
  width: 280px;
  height: 230px;
  object-fit: contain;
  border-radius: 16px;
}






/* 推广区 */
.promo-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
  border-radius: 20px;
  padding: 2rem 3rem;
  margin-top: 2rem;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
  gap: 2rem;
  position: relative;
}

.promo-content {
  max-width: 60%;
  z-index: 1;
  margin-right: 120px;
  position: relative;
}

.promo-content h2 {
  font-size: 2.2rem;
  background: linear-gradient(135deg, var(--primary-color), #3b82f6, #8b5cf6);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 1rem;
  line-height: 1.3;
  font-weight: 700;
  letter-spacing: -0.5px;
  text-shadow: 0 2px 4px rgba(30, 58, 138, 0.1);
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
  padding-left: 1.5rem;
  font-weight: 500;
  transition: all 0.3s ease;
}

.features li::before {
  content: '✨';
  position: absolute;
  left: 0;
  top: 0;
  font-size: 1rem;
}

.cta-btn {
  background: linear-gradient(135deg, #2563eb, #3b82f6);
  color: #fff;
  padding: 1rem 2rem;
  font-weight: 600;
  border: none;
  border-radius: 12px;
  font-size: 1.1rem;
  cursor: pointer;
  transition: transform 0.2s ease;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

.cta-btn:hover {
  transform: translateY(-2px);
}





/* 响应式设计 */
@media (max-width: 900px) {
  .promo-section {
    flex-direction: column;
    text-align: center;
    padding: 2rem;
  }
  
  .promo-content {
    max-width: 100%;
    margin-right: 0;
    margin-bottom: 1.5rem;
  }
  
  .robot-overlay {
    position: static;
    margin: 0 auto;
  }
  
  .robot-image {
    width: 200px;
    height: 160px;
  }
}

@media (max-width: 768px) {
  .promo-content h2 {
    font-size: 1.8rem;
  }
  
  .cta-btn {
    padding: 0.8rem 1.5rem;
  }
}

@media (max-width: 480px) {
  .promo-section {
    padding: 1.5rem 1rem;
  }
  
  .promo-content h2 {
    font-size: 1.5rem;
  }
  
  .robot-image {
    width: 160px;
    height: 130px;
  }
}

</style>
