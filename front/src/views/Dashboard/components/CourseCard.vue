<template>
  <el-card class="course-card" shadow="hover" :body-style="{ padding: '0px' }">
    <!-- 顶部图片或渐变背景 -->
    <div class="card-top">
      <img :src="image" alt="课程封面" @error="onImgError" />
    </div>

    <!-- 底部白色内容区 -->
    <div class="card-bottom">
      <h3>{{ title }}</h3>
      <p>{{ subtitle }}</p>
      <div class="card-links">
        <el-link type="primary" :underline="true" @click.prevent="handleDesignClick">智能教学设计 →</el-link>
      </div>
    </div>
  </el-card>
</template>

<script setup>
const props = defineProps({
  id: Number,
  title: String,
  subtitle: String,
  image: String
})

const emit = defineEmits(['design'])

function onImgError(event) {
  event.target.src = '/default-course.jpg' // 设置默认图片路径
}

// 点击智能教学设计时，抛出事件并传课程数据给父组件
function handleDesignClick() {
  emit('design', {
    id: props.id,
    title: props.title,
    subtitle: props.subtitle,
    image: props.image
  })
}
</script>

<style scoped>
.course-card {
  border-radius: 20px;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  cursor: pointer;
  height: 320px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  background: #ffffff;
  border: 1px solid #e2e8f0;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
  position: relative;
}

.course-card:hover {
  transform: translateY(-8px) scale(1.02);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  border-color: #3b82f6;
}

.card-top {
  width: 100%;
  height: 140px;
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  position: relative;
  z-index: 2;
}

.card-top img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.course-card:hover .card-top img {
  transform: scale(1.05);
}

.card-bottom {
  background: #ffffff;
  color: #1e293b;
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  flex: 1;
  position: relative;
  z-index: 2;
}

.card-bottom h3 {
  margin: 0;
  font-size: 1.2rem;
  font-weight: 700;
  color: #1e293b;
  line-height: 1.3;
}

.card-bottom p {
  margin: 0;
  font-size: 0.9rem;
  color: #64748b;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  line-height: 1.5;
}

.card-links {
  display: flex;
  justify-content: flex-start;
  margin-top: auto;
  padding-top: 0.5rem;
}

.card-links .el-link {
  font-weight: 600;
  font-size: 0.9rem;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  color: white !important;
  text-decoration: none;
  transition: all 0.3s ease;
  border: none;
}

.card-links .el-link:hover {
  transform: translateX(4px);
  box-shadow: 0 4px 15px rgba(59, 130, 246, 0.4);
}

/* 添加一些装饰性元素 */
.course-card::after {
  content: '';
  position: absolute;
  top: 1rem;
  right: 1rem;
  width: 8px;
  height: 8px;
  background: #3b82f6;
  border-radius: 50%;
  z-index: 3;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 0.6;
    transform: scale(1);
  }
  50% {
    opacity: 1;
    transform: scale(1.2);
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .course-card {
    height: 280px;
  }
  
  .card-top {
    height: 120px;
  }
  
  .card-bottom {
    padding: 1rem;
  }
  
  .card-bottom h3 {
    font-size: 1.1rem;
  }
}
</style>
