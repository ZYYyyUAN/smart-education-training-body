<template>
  <div class="qa-all">
    <div class="header">
      <div class="title-wrap">
        <div class="title">课程问答</div>
        <div class="subtitle">共 {{ currentQuestions.length }} 条</div>
      </div>
      <el-button @click="goBack" type="primary" plain round>
        返回课程
      </el-button>
    </div>

    <div class="qa-tabs">
      <button 
        class="tab-item" 
        :class="{ active: activeTab === 'others' }" 
        @click="switchTab('others')">
        <span>别人的提问</span>
        <span class="pill">{{ otherQuestions.length }}</span>
      </button>
      <button 
        class="tab-item" 
        :class="{ active: activeTab === 'mine' }" 
        @click="switchTab('mine')">
        <span>我的提问</span>
        <span class="pill">{{ myQuestions.length }}</span>
      </button>
    </div>

    <div v-if="pagedQuestions.length" class="question-list">
      <router-link
        v-for="item in pagedQuestions"
        :key="item.id"
        class="question-card"
        :to="{ name: 'QuestionADetail', params: { id: item.id }, query: { courseId: route.query.courseId } }"
      >
        <div class="q-head">
          <div class="q-title">{{ item.content }}</div>
          <span class="tag tag-mine" v-if="String(item.userId) === String(userId)">我的</span>
        </div>
        <div class="q-meta">
          <div class="q-author">
            <span class="avatar">{{ (item.userName || 'U').slice(0,1) }}</span>
            <span class="name">{{ item.userName || '未知用户' }}</span>
            <span class="dot">·</span>
            <span class="univ">{{ item.userUniversity || '未知学校' }}</span>
          </div>
          <div class="q-time">{{ formatQuestionTime(item.createTime) }}</div>
        </div>
      </router-link>
    </div>
    <div v-else class="empty">
      暂无数据
    </div>

    <div class="pager">
      <el-pagination
        background
        layout="prev, pager, next"
        :page-size="pageSize"
        :total="currentQuestions.length"
        :current-page.sync="currentPage"
      />
    </div>
  </div>
  </template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'
import { useUserStore } from '@/store/user.js'

const route = useRoute()
const router = useRouter()
const userId = useUserStore().currentUserId

const questions = ref([])
const activeTab = ref('others')
const pageSize = 10
const currentPage = ref(1)

const courseId = computed(() => route.query.courseId)

const fetchQuestions = async () => {
  const res = await axios.get('/api/questions', { params: { courseId: courseId.value } })
  if (res.data?.code === 200) questions.value = res.data.data || []
}

const myQuestions = computed(() => questions.value.filter(q => String(q.userId) === String(userId)))
const otherQuestions = computed(() => questions.value.filter(q => String(q.userId) !== String(userId)))
const currentQuestions = computed(() => activeTab.value === 'mine' ? myQuestions.value : otherQuestions.value)

const pagedQuestions = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  return currentQuestions.value.slice(start, start + pageSize)
})

const formatQuestionTime = (t) => {
  const d = new Date(t)
  return isNaN(d) ? '未知时间' : d.toLocaleString()
}

const goBack = () => router.push({ path: '/course', query: { id: courseId.value } })

function switchTab(tab) {
  if (activeTab.value !== tab) {
    activeTab.value = tab
    currentPage.value = 1
  }
}

onMounted(fetchQuestions)
</script>

<style scoped>
.qa-all { padding: 28px; max-width: 960px; margin: 0 auto; }
.header { display:flex; justify-content: space-between; align-items: center; margin-bottom: 18px; }
.title-wrap { display:flex; align-items: baseline; gap:12px; }
.title { font-size: 24px; font-weight: 700; color:#1f2937; }
.subtitle { font-size: 12px; color:#9ca3af; padding-top: 6px; }

.qa-tabs { display:flex; gap:10px; margin: 14px 0 18px; }
.tab-item { 
  padding:8px 14px; border-radius: 999px; cursor: pointer; 
  background:#f3f4f6; color:#374151; border:1px solid #e5e7eb; 
  display:flex; align-items:center; gap:8px; transition: .2s; 
}
.tab-item .pill{ background:#fff; border:1px solid #e5e7eb; padding:0 8px; border-radius:999px; font-size:12px; }
.tab-item:hover { background:#eef2ff; color:#3b82f6; border-color:#c7d2fe; }
.tab-item.active { background:#3b82f6; color:#fff; border-color:#3b82f6; }
.tab-item.active .pill{ background:#2563eb; color:#fff; border-color:transparent; }

.question-list { display:flex; flex-direction:column; gap:12px; }
.question-card { 
  display:block; text-decoration:none; color:inherit; 
  background:#fff; border:1px solid #e5e7eb; border-radius:12px; 
  padding:14px 16px; transition:.2s; box-shadow:0 1px 2px rgba(0,0,0,.03);
}
.question-card:hover { transform: translateY(-1px); box-shadow:0 8px 24px rgba(0,0,0,.06); border-color:#d1d5db; }
.q-head { display:flex; align-items:center; justify-content:space-between; gap:10px; margin-bottom:8px; }
.q-title { font-weight:600; color:#111827; line-height:1.4; }
.tag { font-size:12px; padding:2px 8px; border-radius:999px; border:1px solid #dbeafe; background:#eff6ff; color:#2563eb; }
.q-meta { display:flex; align-items:center; justify-content:space-between; color:#6b7280; font-size:12px; }
.q-author { display:flex; align-items:center; gap:8px; }
.avatar { width:22px; height:22px; border-radius:50%; background:#e5e7eb; display:flex; align-items:center; justify-content:center; font-size:12px; color:#374151; }
.name { font-weight:600; }
.dot { opacity:.6; }
.univ { }
.q-time { }

.empty { text-align:center; color:#9ca3af; padding:40px 0; }
.pager { display:flex; justify-content:center; margin-top:18px; }
</style>
