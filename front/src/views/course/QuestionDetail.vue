<template>
    <div class="question-detail-wrapper">
      <!-- 粒子背景 -->
      <Particles id="particles-bg" :options="particlesOptions" />
  
      <!-- 顶部栏 -->
      <header class="top-bar">
        <el-button link @click="goBack" class="back-btn">
          <el-icon><ArrowLeft /></el-icon> 返回
        </el-button>
        <h2>📝 问题详情</h2>
      </header>
  
      <!-- 问题详情卡片 -->
      <el-card class="section-card question-info animate-slide">
        <div class="title">🎯 {{ detail.content }}</div>
        <div class="meta">
          <el-icon><User /></el-icon>
          {{ detail.userName }} · {{ detail.userUniversity }}
        </div>
                 <div class="meta" v-if="detail.attachments?.length">
           <el-icon><Document /></el-icon>
           <ul class="file-list">
             <li v-for="(file, i) in detail.attachments" :key="i" class="file-item" @click="showFileDialog(file)">
               <span class="file-icon">{{ getFileIconEmoji(file.fileName) }}</span>
               <span class="file-name">{{ file.fileName }}</span>
             </li>
           </ul>
         </div>
      </el-card>
      
      

      <!-- 回答展示 -->
      <el-card class="section-card answer-section animate-fade">
        <template v-if="detail.answers?.length">
          <h4>💡 回答列表：</h4>
          <el-timeline>
            <el-timeline-item
              v-for="(reply, idx) in detail.answers"
              :key="idx"
              type="success"
              :timestamp="`回答 #${idx + 1} · ${reply.userName} · ${formatTime(reply.createTime)}`"
            >
              <div class="answer-content">{{ reply.content }}</div>
            </el-timeline-item>
          </el-timeline>
        </template>
        <template v-else>
          <div class="empty-state">
            <img src="https://cdn.jsdelivr.net/gh/dufu1991/vue-empty@main/empty.png" width="100" />
            <p>暂无回答 😥</p>
          </div>
        </template>
      </el-card>

         <!-- 回复框 -->
    <el-card class="section-card reply-box animate-slide">
      <el-input
        v-model="newReply"
        type="textarea"
        rows="4"
        placeholder="💬 请输入你的回复..."
      />
      <el-button
        type="primary"
        @click="submitReply"
        class="submit-btn"
        :disabled="!newReply.trim()"
      >
        🚀 提交回复
      </el-button>
    </el-card>
  </div>
</template>

  <script setup>
  import { ref, onMounted, onUnmounted, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { ElDialog } from 'element-plus'
import { reactive } from 'vue'
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { ArrowLeft, User, Document } from '@element-plus/icons-vue'
  // 使用 Vue Router 的 `useRoute` 获取当前路由信息
  const route = useRoute();
  const router = useRouter();
  const detail = ref({});
const newReply = ref('');
  const questions = [
  {
    id: 1,
    title: 'Vue 如何实现双向绑定？',
    user: '李雷',
    school: '清华大学',
    files:[
    { url: 'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?filename=dog.png', name: 'dog.png' },
    { url: 'http://localhost:3001/uploads/1754215413717-MySQL.mp4', name: 'mysql.mp4' }],
    
    answers: ['使用 v-model 实现组件与数据的绑定', '原理是语法糖 + 响应式']
  },
  {
    id: 2,
    title: 'Vue 的生命周期有哪些？',
    user: '韩梅梅',
    school: '北京大学',
    files:[
    { url: 'http://localhost:3001/uploads/1754217014531-Quartus II 13.0æ modelsimè¿è¡ä»¿ç(ç¨èªå¸¦ä»¿çå¨).pdf', name: '实验.pdf' },
    { url: 'http://localhost:3001/uploads/1754215196185-å±å¹æªå¾ 2025-06-04 104710.png', name: '模拟.png' },
    { url: 'http://localhost:3001/pdfs/1754352044865-å¤§ä½ä¸å¸ç½®åå®¹.pdf', name: '软工.pptx' },
    { url: 'http://localhost:3001/pdfs/1754364367756-éæ±åæè¯´æä¹¦-å¤§ä½ä¸åè.pdf', name: '用户需求.docx'}],

    answers: ['mounted、updated、unmounted 等']
  }
]
 

const getFileIconEmoji = (filename) => {
  const ext = filename.split('.').pop().toLowerCase()
  if (['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'].includes(ext)) return '🖼️'     // 图片
  if (['mp4', 'avi', 'mov', 'mkv', 'webm'].includes(ext)) return '🎞️'           // 视频
  if (['pdf'].includes(ext)) return '📄'                                         // PDF
  if (['doc', 'docx'].includes(ext)) return '📃'                                  // Word 文档
  if (['ppt', 'pptx'].includes(ext)) return '📊'                                  // PPT
  if (['xls', 'xlsx'].includes(ext)) return '📈'                                  // Excel
  if (['zip', 'rar', '7z'].includes(ext)) return '🗜️'                            // 压缩包
  if (['txt', 'md', 'csv', 'log'].includes(ext)) return '📑'                     // 文本类
  if (['exe', 'msi', 'bat', 'sh'].includes(ext)) return '💻'                     // 可执行或脚本
  if (['mp3', 'wav', 'ogg'].includes(ext)) return '🎵'                            // 音频
  return '📎'                                                                    // 其他
}



const showFileDialog = (file) => {
  console.log('点击的文件:', file)
  console.log('文件路径:', file.fileUrl || file.filePath)
  console.log('文件名:', file.fileName)
  
  // 检查文件路径是否有效
  const filePath = file.fileUrl || file.filePath
  if (!filePath) {
    ElMessage.error('文件路径无效')
    return
  }
  
  // 跳转到文件预览页面
  router.push({
    name: 'filePreview',
    params: { 
      questionId: detail.value.id,
      fileId: file.id || 0
    },
    query: { 
      fileName: file.fileName,
      fileUrl: filePath,
      courseId: route.query.courseId,
      activeNav: route.query.activeNav
    }
  })
}



const goBack = () => {
  // 从当前路由的query参数中获取课程ID，如果没有则使用默认值
  const courseId = route.query.courseId || '102'
  // 从当前路由的query参数中获取之前选中的模块，如果没有则使用默认值
  const activeNav = route.query.activeNav || 'learning-resources'
  router.push({
    name: 'course',
    query: { 
      id: courseId,
      activeNav: activeNav
    }
  })
}

const formatTime = (timeData) => {
  if (!timeData) return '未知时间';
  
  // 如果是数组格式 [year, month, day, hour, minute, second]
  if (Array.isArray(timeData)) {
    if (timeData.length < 6) return '未知时间';
    const [year, month, day, hour, minute, second] = timeData;
    return `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')} ${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
  }
  
  // 如果是字符串格式
  if (typeof timeData === 'string') {
    try {
      const date = new Date(timeData);
      if (isNaN(date.getTime())) return '未知时间';
      return date.toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch (e) {
      return '未知时间';
    }
  }
  
  // 如果是时间戳
  if (typeof timeData === 'number') {
    try {
      const date = new Date(timeData);
      if (isNaN(date.getTime())) return '未知时间';
      return date.toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch (e) {
      return '未知时间';
    }
  }
  
  // 如果是Date对象
  if (timeData instanceof Date) {
    return timeData.toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    });
  }
  
  return '未知时间';
}

const fetchQuestionDetail = async (id) => {
  try {
    const response = await axios.get('/api/questions/answers', {
      params: { questionId: id }
    })
    if (response.data.code === 200) {
      detail.value = response.data.data
      
      // 调试信息：查看问题详情和附件
      console.log('问题详情:', detail.value)
      if (detail.value.attachments && detail.value.attachments.length > 0) {
        console.log('附件列表:', detail.value.attachments)
        detail.value.attachments.forEach((attachment, index) => {
          console.log(`附件 ${index + 1}:`, {
            fileName: attachment.fileName,
            fileUrl: attachment.fileUrl,
            fileType: attachment.fileName ? attachment.fileName.split('.').pop().toLowerCase() : 'unknown'
          })
        })
      }
    } else {
      ElMessage.error(response.data.message || '未找到该问题')
      router.back()
    }
  } catch (error) {
    console.error('获取问题详情失败:', error)
    ElMessage.error('获取问题详情失败')
    router.back()
  }
}

// const fetchQuestionDetail = async (id) => {
//   try {
//     const response = await axios.get(`/api/question/detailAnswer?id=${id}`)
//     detail.value = response
//   } catch (error) {
//     console.error('获取题目详情失败:', error)
//     ElMessage.error('获取题目详情失败')
//     router.back()
//   }
// }
//返回一个这样结构的数据
// {
//     id: 2,
//     title: 'Vue 的生命周期有哪些？',
//     user: '韩梅梅',
//     school: '北京大学',
//     fileName:[
//     { url: 'http://xxx.com/a.pdf', name: 'a.pdf' },
//     { url: 'http://xxx.com/b.png', name: 'b.png' }],
//     answers: ['mounted、updated、unmounted 等']
// }

onMounted(() => {
  const questionId = parseInt(route.params.id)
  fetchQuestionDetail(questionId)
})

// 提交回复（并保存至数据库）
const submitReply = async () => {
  const content = newReply.value.trim();
  if (!content) {
    ElMessage.error('回复内容不能为空');
    return;
  }

  try {
    const requestData = {
      questionId: detail.value.id,
      userId: 1, // 这里应该从用户状态获取实际用户ID
      content: content
    };

    const response = await axios.post('/api/questions/createAnswer', requestData);
    if (response.data.code === 200) {
      // 重新获取问题详情以显示新的回答
      await fetchQuestionDetail(detail.value.id);
      
      // 清空输入框
      newReply.value = '';
      
      ElMessage.success('回答发布成功');
    } else {
      ElMessage.error(response.data.message || '回答发布失败');
    }
  } catch (error) {
    console.error('提交失败：', error);
    ElMessage.error('提交失败，请稍后重试');
  }
};

const particlesOptions = {
  background: {
    color: { value: "#fdfbff" }
  },
  fpsLimit: 60,
  particles: {
    color: { value: "#ffb6c1" },
    links: {
      enable: true,
      color: "#ffb6c1",
      distance: 100,
      opacity: 0.5,
    },
    move: {
      enable: true,
      speed: 1,
    },
    size: {
      value: { min: 1, max: 5 }
    },
    opacity: {
      value: 0.5,
    }
  }
};

  </script>
   
<style scoped>
@import url('https://fonts.googleapis.com/css2?family=ZCOOL+KuaiLe&display=swap');

.question-detail-wrapper {
  font-family: 'ZCOOL KuaiLe', cursive;
  max-width: 900px;
  margin: 0 auto;
  padding: 20px;
  position: relative;
  z-index: 1;
}

/* 粒子背景 */
#particles-bg {
  position: fixed;
  top: 0;
  left: 0;
  z-index: 0;
  width: 100%;
  height: 100%;
}

/* 顶部栏样式 */
.top-bar {
  width: 100vw;
  padding: 14px 20px;
  position: sticky;
  top: 0;
  z-index: 10;
  display: flex;
  align-items: center;
  gap: 12px;
}

.top-bar h2 {
  font-size: 20px;
  margin: 0;
  flex: 1;
  text-align: center;
}

.back-btn {
  position: absolute;
  left: 16px;
  top: 14px;
}

/* 卡片样式 */
.section-card {
  margin-bottom: 20px;
  border-radius: 20px;
  border: none;
  background: #fff5f8;
  box-shadow: 0 4px 12px rgba(255, 182, 193, 0.3);
  transition: all 0.3s ease;
  position: relative;
  z-index: 2;
}

.question-info .title {
  font-size: 20px;
  font-weight: bold;
  margin-bottom: 10px;
  color: #d6336c;
}

.meta {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #555;
  margin-top: 6px;
}

/* 空状态 */
.empty-state {
  text-align: center;
  color: #aaa;
  padding: 20px 0;
  font-style: italic;
}

/* 回复输入 */
.reply-box textarea {
  font-size: 14px;
  border-radius: 12px;
  background-color: #fff0f5;
}

.submit-btn {
  margin-top: 10px;
  border-radius: 20px;
  background: linear-gradient(to right, #ff9a9e, #fad0c4);
  border: none;
  color: #fff;
  font-weight: bold;
}

/* 动画 */
.animate-fade {
  animation: fadeIn 0.7s ease-in;
}

.animate-slide {
  animation: slideIn 0.8s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: scale(0.97);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.file-preview-list {
  list-style: none;
  padding: 0;
}

.file-preview-list li {
  padding: 10px;
  background-color: #fdf6ec;
  border: 1px dashed #f4b860;
  border-radius: 12px;
  margin-bottom: 10px;
  box-shadow: 2px 2px 5px rgba(250, 180, 80, 0.1);
  font-family: 'Comic Sans MS', 'Cute Font', sans-serif;
}



ul li:hover {
  background-color: #fff0c1 !important;
  transition: 0.2s;
}

.file-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.file-item {
  display: flex;
  align-items: center;
  padding: 8px 10px;
  margin-bottom: 6px;
  background-color: #f4f6f8;
  border-radius: 6px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.file-item:hover {
  background-color: #e0e6ed;
}

.file-icon {
  font-size: 20px;
  margin-right: 8px;
}

.file-name {
  font-size: 14px;
  color: #333;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.answer-content {
  padding: 12px;
  background-color: #f8f9fa;
  border-radius: 8px;
  border-left: 4px solid #409eff;
  margin-top: 8px;
  line-height: 1.6;
  color: #333;
}



</style>