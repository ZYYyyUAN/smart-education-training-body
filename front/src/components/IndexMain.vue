<script setup>
import { reactive, ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus';
import CaseNotes from '../views/case_notes/CaseNotes.vue'
import Student from '../views/student/Student.vue'
import Teacher from '../views/teacher/Teacher.vue'
import { Edit, Reading, Setting } from '@element-plus/icons-vue'
// import * as THREE from 'three' // 已注释掉，Three.js 代码未使用
import SplineBac from '../views/my_school/SplineBac.vue'
const router = useRouter()
const route = useRoute()
const urlProps = defineProps({
    imgUrl: {}
})

const particlesOptions = reactive({
  fullScreen: { enable: true },
  background: { color: "#00000000" },
  particles: {
    number: { value: 70 },
    color: { value: "#00ffff" },
    shape: { type: "circle" },
    opacity: {
      value: 0.4,
      random: false
    },
    size: {
      value: 3,
      random: true
    },
    links: {
      enable: true,
      distance: 120,
      color: "#00ffff",
      opacity: 0.2,
      width: 1
    },
    move: {
      enable: true,
      speed: 1.6,
      direction: "none",
      outModes: "out"
    }
  },
  detectRetina: true
})

// onMounted(() => {
//   const canvas = document.querySelector('.three-overlay-cube')
//   const scene = new THREE.Scene()

//   const camera = new THREE.PerspectiveCamera(
//     75,
//     canvas.clientWidth / canvas.clientHeight,
//     0.1,
//     1000
//   )
//   camera.position.z = 2

//   const renderer = new THREE.WebGLRenderer({ canvas, alpha: true })
//   renderer.setSize(canvas.clientWidth, canvas.clientHeight)
//   renderer.setPixelRatio(window.devicePixelRatio)

//   const geometry = new THREE.BoxGeometry()
//   const material = new THREE.MeshStandardMaterial({ color: 0x00aaff })
//   const cube = new THREE.Mesh(geometry, material)
//   scene.add(cube)

//   const light = new THREE.DirectionalLight(0xffffff, 1)
//   light.position.set(1, 1, 1).normalize()
//   scene.add(light)

//   const animate = () => {
//     requestAnimationFrame(animate)
//     cube.rotation.x += 0.01
//     cube.rotation.y += 0.01
//     renderer.render(scene, camera)
//   }

//   animate()
// })
const imgUrl = reactive(urlProps.imgUrl)
const toStudent = () => checkLoginAndRedirect('student');
const toTeacher = () => checkLoginAndRedirect('teacher');
const toAdmin = () => checkLoginAndRedirect('admin');

const checkLoginAndRedirect = (targetRole) => {
  const userInfoStr = localStorage.getItem('userInfo');
  if (!userInfoStr) {
    ElMessage.warning('您还未登录哦，请先登录');
    router.push('/loginIndex/userLogin');
    return;
  }

  const userInfo = JSON.parse(userInfoStr);

  if (userInfo.role !== targetRole) {
    ElMessage.warning('您无权限访问该模块');
    return;
  }

  // 展示欢迎语（可选）
  const name = userInfo.realName || userInfo.username;
  let roleText = '用户';
  if (userInfo.role === 'student') roleText = '同学';
  else if (userInfo.role === 'teacher') roleText = '老师';
  else if (userInfo.role === 'admin') roleText = '管理员';
  
  ElMessage.success(`欢迎回来，${name}${roleText}！`);

  // 正常跳转
  if (targetRole === 'student') {
    router.push({ path: '/student' });
  } else if (targetRole === 'teacher') {
    router.push({ path: '/teacher' });
  } else if (targetRole === 'admin') {
    router.push({ path: '/admin' });
  }
};

</script>

<template>
  
  <!-- <SplineBac :scene="{url:'https://prod.spline.design/VXwvUCucezeKhYSq/scene.splinecode'}"></SplineBac> -->
     <Particles id="tsparticles" :options="particlesOptions" />
    <div class="main">
        
        <div class="left">
            <div class="color"></div>
            <div class="mian_title">智教实训通</div>
            <div class="main_text">
                用开源大模型驱动，为教学实训打造智能备课、实时练导与学情洞察的全流程赋能平台 。
            </div>
<div class="button-container">
  <div class="image-button">
    <button class="overlay-btn" @click="toStudent">
      <el-icon><Edit /></el-icon>
      学生端
    </button>
  </div>

  <div class="image-button">
    <button class="overlay-btn" @click="toTeacher">
      <el-icon><Reading /></el-icon>
      教师端
    </button>
  </div>

  <div class="image-button">
    <button class="overlay-btn" @click="toAdmin">
      <el-icon><Setting /></el-icon>
      管理端
    </button>
  </div>
</div>
            <div
                class="fun"
                style="margin-top: 20px; margin-left: 40px"
                v-if="imgUrl.type == 1"
            >

            </div>
            <div class="fun" style="margin-top: 20px; margin-left: 40px" v-else>
                <el-button color="#0000ff" round @click="toCaseNotes"
                    >查看病例记录</el-button
                >
            </div>
        </div>
      <div class="right">
<iframe src='https://my.spline.design/genkubgreetingrobot-HpGy5dyHQzOTmN75UeBjksiV/' frameborder='0' width='100%' height='100%'></iframe>
</div>

    </div>
</template>

<style scoped>
/* 实现图片淡入 */
@keyframes pictureIn {
    0% {
        opacity: 0;
    }
    50% {
        opacity: 0.5;
    }
    100% {
        opacity: 1;
    }
}

/* 中间左侧 */
.main {
    display: flex;
}
.left {
    margin-left: 30px;
    position: relative;
    display: flex;
    flex-direction: column;
    justify-content: center;
    width: 52%;
}

.color {
    position: absolute;
    left: -20px;
    top: 200px;
    width: 750.62px;
    height: 253.66px;
    opacity: 1;
    transform: rotate(37.57deg);
    background: linear-gradient(
        90deg,
        rgba(240, 0, 240, 0.15) 0%,
        rgba(0, 128, 255, 0.15) 45.84%,
        rgba(21, 0, 255, 0.15) 100%
    );
    filter: blur(100px);
}

.mian_title {
    color: #ffffff;
    font-size: 50px;
    font-weight: 700;
    margin-bottom: 20px;
    margin-left: 40px;
}

.main_text {
     color: #ffffff;
    width: 520px;
    font-size: 17px;
    line-height: 30px;
    margin-left: 40px;
}

.right {
    width: 700px;
    height: 700px;
    position: relative;
}
.img_1 {
    position: absolute;
    animation: pictureIn 1.3s linear;
    left: -20px;
    top: 12px;
    width: 320px;
    height: 320px;
    opacity: 1;
    border-radius: 16px;
    border: 12px solid rgba(255, 255, 255, 1);
    box-shadow: 20px 25px 39px rgba(24, 49, 84, 0.14);
}
.img_2 {
    margin-left: 50px;
    margin-top: 80px;
    left: 80px;
    top: 40px;
    width: 520px;
    height: 600px;
    opacity: 1;
    border-radius: 32px;
}
.img_3 {
    animation: pictureIn 1.5s ease-in-out;
    position: absolute;
    left: 286px;
    top: 387px;
    width: 365px;
    height: 200px;
    opacity: 1;
    border-radius: 16px;

    border: 12px solid rgba(255, 255, 255, 1);
    box-shadow: 20px 25px 39px rgba(24, 49, 84, 0.14);
}


.button-container {
  display: flex;
  gap: 20px;
  margin-top: 150px;
  margin-left: 40px;
  position: relative;
  z-index: 1;
}

.image-button {
  width: 300px;
  height: 300px;
  border: none;
  border-radius: 45px;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  background-size: cover;
  background-position: center;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  will-change: transform, box-shadow;
}

.image-button:hover {
  transform: translateY(-5px) scale(1.02);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
}

/* 删除下面重复的 .an1 到 .an4 定义 */

.spline-container {
  position: absolute;
  right: 0;
  bottom: 0;
  width: 480px;
  height: 480px;
  z-index: 0;
  pointer-events: auto;
  border-radius: 24px;
  overflow: hidden;
}

.three-overlay-cube {
  position: absolute;
  bottom: 30px;
  left: 30px;
  width: 200px;
  height: 200px;
  z-index: 2;
  pointer-events: none;
}
.particles-bg {
  position: absolute;
  width: 100%;
  height: 100vh;
  z-index: 0;
  top: 0;
  left: 0;
  pointer-events: none;
  overflow: hidden;
}
/* 修改 image-button 为相对定位 */
.image-button {
  position: relative;
  width: 200px;
  height: 200px;
  border-radius: 16px;
  overflow: hidden;
  background-size: cover;
  background-position: center;
}

/* 覆盖按钮放在图片上 */
.overlay-btn {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background-color: #007bff;
  color: #fff;
  width: 300px;
  height: 300px;
  font-size: 16px;
  border: none;
  border-radius: 16px;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  transition: background-color 0.3s, transform 0.3s;

}

.overlay-btn:hover {
  background-color: #0056b3;
  transform: translate(-50%, -52%) scale(1.05);
}

.el-icon {
   font-size: 36px; /* 加大图标大小 */
  margin-bottom: 12px;
}
.overlay-btn {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: linear-gradient(to right, #4facfe, #00f2fe); /* 渐变蓝 */
  color: #fff;
  width: 180px;
  height: 180px;
  font-size: 16px;
  font-weight: 500;
  border: none;
  border-radius: 24px;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8px 20px rgba(0, 128, 255, 0.3);
  transition: background-color 0.3s ease, transform 0.3s ease;
      font-size: 33px; /* 加大按钮文字 */
  font-weight: 600;
}

.overlay-btn:hover {
  background: linear-gradient(to right, #00c6ff, #0072ff); /* 深一点的渐变 */
  transform: translate(-50%, -52%) scale(1.05);
}

.el-icon {
  font-size: 38px;
  margin-bottom: 8px;
}

</style>
