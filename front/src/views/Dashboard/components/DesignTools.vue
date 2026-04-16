<template>
  <div class="tools-wrapper">
    <el-page-header @back="goBack" content="智能教学设计 · 备课工具">
      <template #icon><el-icon><ArrowLeft /></el-icon></template>
    </el-page-header>

    <!-- 顶部英雄横幅 -->
    <div class="hero">
      <div class="hero-left">
        <div class="badge">为 {{ course.title || '本课程' }} 提效备课</div>
        <h1 class="hero-title">一站式备课工具集</h1>
        <p class="hero-sub">从大纲生成到智能组卷，全流程 AI 助力，提升课堂准备效率。</p>
        <div class="hero-actions">
          <el-button type="primary" size="large" @click="toAiTeach">立即开始</el-button>
          <el-button size="large" @click="toAutoPPT">试试生成PPT</el-button>
        </div>
      </div>
      <div class="hero-right">
        <img :src="course.image || placeholder" alt="课程封面" class="cover" />
      </div>
    </div>

    <!-- 工具网格 -->
    <div class="grid">
      <!-- <el-card class="tool tool-1" shadow="hover">
        <div class="tool-inner">
          <div class="icon">📑</div>
          <div class="content">
            <div class="title">PPT生成助手</div>
            <div class="desc">输入主题或大纲，一键生成精美PPT。</div>
          </div>
          <el-button type="primary" @click.stop="toAutoPPT">进入</el-button>
        </div>
      </el-card> -->

      <el-card class="tool tool-2" shadow="hover">
        <div class="tool-inner">
          <div class="icon">📘</div>
          <div class="content">
            <div class="title">生成教学大纲与考核</div>
            <div class="desc">上传教学大纲，自动生成教学目标、章节与题目。</div>
          </div>
          <el-button type="primary" @click.stop="toAiTeach">进入</el-button>
        </div>
      </el-card>

      <el-card class="tool tool-3" shadow="hover">
        <div class="tool-inner">
          <div class="icon">📝</div>
          <div class="content">
            <div class="title">智能组卷</div>
            <div class="desc">按知识点与题型快速组卷，支持一键生成。</div>
          </div>
          <el-button type="primary" @click.stop="toCreateExam">进入</el-button>
        </div>
      </el-card>

      <el-card class="tool tool-4" shadow="hover">
        <div class="tool-inner">
          <div class="icon">🎯</div>
          <div class="content">
            <div class="title">题目生成</div>
            <div class="desc">根据知识点自动生成考核题目，支持难度分级和分类管理。</div>
          </div>
          <el-button type="primary" @click.stop="toQuestionGenerator">进入</el-button>
        </div>
      </el-card>

      
    </div>
  </div>
  
</template>

<script setup>
import { reactive } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()

const course = reactive({
  id: route.query.courseId,
  title: route.query.title,
  subtitle: route.query.subtitle,
  image: route.query.image
})
const placeholder = 'https://dummyimage.com/240x180/edf2ff/1e293b&text=Course'

function goBack() {
  router.push({ name: 'MainPanel' })
}

function withQuery(name) {
  return {
    name,
    query: {
      courseId: course.id,
      title: course.title,
      subtitle: course.subtitle,
      image: course.image
    }
  }
}

function toAutoPPT() {
  router.push(withQuery('AutoPPTGenerator'))
}
function toAiTeach() {
  router.push(withQuery('aiTeach'))
}
function toCreateExam() {
  router.push(withQuery('AutoExamGenerator'))
}
function toQuestionGenerator() {
  router.push(withQuery('QuestionGenerator'))
}

</script>

<style scoped>
.tools-wrapper { padding: 16px; max-width: 1100px; margin: 0 auto; }

/* 英雄横幅 */
.hero {
  display: grid;
  grid-template-columns: 1.2fr 1fr;
  gap: 16px;
  padding: 18px;
  border-radius: 16px;
  background: linear-gradient(135deg, #eef2ff, #fdf2f8);
  border: 1px solid #e5e7eb;
  box-shadow: 0 10px 30px rgba(17, 24, 39, 0.06);
  margin: 12px 0 18px;
}
.hero-left { display: flex; flex-direction: column; justify-content: center; }
.badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 999px;
  background: #fff;
  color: #1e3a8a;
  font-weight: 700;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06);
  width: max-content;
}
.hero-title { margin: 8px 0 6px 0; font-size: 24px; color: #0f172a; }
.hero-sub { margin: 0 0 10px 0; color: #475569; }
.hero-actions { display: flex; gap: 10px; margin-top: 6px; }
.hero-right { display: flex; align-items: center; justify-content: center; }
.cover { width: 240px; height: 180px; border-radius: 14px; object-fit: cover; box-shadow: 0 8px 20px rgba(0,0,0,0.08); }

/* 工具网格 */
.grid { 
  display: grid; 
  grid-template-columns: repeat(2, 1fr); 
  gap: 16px; 
}

.tool { 
  border-radius: 16px; 
  padding: 0; 
  overflow: hidden; 
  border: 1px solid #eef2f7; 
  transition: transform .15s ease, box-shadow .15s ease; 
  background: linear-gradient(180deg, #ffffff, #fbfdff);
}
.tool:hover { transform: translateY(-3px); box-shadow: 0 16px 32px rgba(15, 23, 42, 0.08); }
.tool-1 .icon { background: linear-gradient(135deg, #60a5fa, #93c5fd); }
.tool-2 .icon { background: linear-gradient(135deg, #f59e0b, #fbbf24); }
.tool-3 .icon { background: linear-gradient(135deg, #34d399, #6ee7b7); }
.tool-4 .icon { background: linear-gradient(135deg, #a78bfa, #c4b5fd); }

.tool-inner { display: grid; grid-template-columns: 60px 1fr auto; align-items: center; gap: 12px; padding: 16px; }
.icon { 
  width: 48px; height: 48px; border-radius: 12px; 
  display: flex; align-items: center; justify-content: center; 
  font-size: 24px; color: #fff; box-shadow: 0 6px 14px rgba(0,0,0,0.08);
}
.content .title { font-weight: 700; color: #0f172a; }
.content .desc { color: #64748b; margin-top: 4px; }

@media (max-width: 900px) {
  .hero { grid-template-columns: 1fr; }
  .hero-right { order: -1; }
  .grid { grid-template-columns: 1fr; }
}
</style>

