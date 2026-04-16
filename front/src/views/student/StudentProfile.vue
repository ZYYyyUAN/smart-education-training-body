  <template>
  <div class="profile-page">
    <!-- 1) 个人信息概览 -->
    <section class="section">
      <el-card shadow="hover" class="card">
        <div class="overview">
          <div class="left">
            <div class="avatar-wrap">
              <el-avatar :size="72" :src="avatarUrl" @error="onAvatarError">{{ nameInitial }}</el-avatar>
              <div v-if="profile.gender" class="gender-badge" :class="profile.gender">
                <el-icon v-if="profile.gender==='male'"><Male /></el-icon>
                <el-icon v-else-if="profile.gender==='female'"><Female /></el-icon>
              </div>
            </div>
            <div class="base">
              <div class="row name">{{ profile.name }}</div>
              <div class="row minor">{{ profile.major }} · {{ profile.grade }}</div>
              <div class="actions">
                <el-button size="small" @click="onEditAvatar">修改头像</el-button>
                <el-button size="small" @click="onEditNickname">修改昵称</el-button>
              </div>
            </div>
          </div>
          <div class="right stats">
            <div class="points-help" @click="pointsHelpVisible = true">对学习积分有疑问？</div>
            <div class="stat">
              <div class="num">{{ recentStudyDays }}天</div>
              <div class="label">近7天学习</div>
            </div>
            <div class="stat">
              <div class="num">{{ totalPractices }}</div>
              <div class="label">累计完成练习</div>
            </div>
            <div class="stat">
              <div class="num">{{ studyPoints }}</div>
              <div class="label">学习积分</div>
            </div>
            <div class="stat progress">
              <div class="label">平均正确率</div>
              <div class="accuracy-display">
                <span class="accuracy-value">{{ avgAccuracy }}%</span>
                <el-progress :percentage="avgAccuracy" :stroke-width="12" status="success" />
              </div>
            </div>
            <div class="stat">
              <div class="num">{{ lastLogin }}</div>
              <div class="label">最近登录</div>
            </div>
          </div>
        </div>
        <div class="quick" v-if="false">
          <el-button type="primary" @click="go('practice')">在线练习</el-button>
          <el-button @click="go('qa')">实时答疑</el-button>
          <el-button @click="go('report')">学习报告</el-button>
          <el-button @click="go('resources')">资源中心</el-button>
        </div>
        <input ref="fileInputRef" type="file" accept="image/*" @change="handleAvatarSelected" style="display:none" />
      </el-card>
    </section>

    <!-- 学习积分规则弹窗 -->
    <el-dialog v-model="pointsHelpVisible" width="420px" title="学习积分规则" :show-close="true">
      <div>
        <ul style="margin:0; padding-left: 16px; line-height: 1.8;">
          <li>做一次练习：+4 分</li>
          <li>登录一天：+2 分（按有记录的日期去重）</li>
          <li>连续登录奖励：每满 5 天额外 +10 分，可叠加</li>
        </ul>
        <p style="margin-top:8px;color:#666;font-size:12px;">注：本页面实时按上述规则计算显示。</p>
      </div>
      <template #footer>
        <el-button type="primary" @click="pointsHelpVisible=false">知道了</el-button>
      </template>
    </el-dialog>

    <!-- 筛选栏：学习成就 / 学情分析 -->
    <section class="section">
      <div class="filter-bar">
        <div class="segmented" role="tablist" aria-label="profile-filter">
          <button
            class="seg-item"
            :class="{ active: activeTab==='achievements' }"
            role="tab"
            aria-selected="activeTab==='achievements'"
            @click="activeTab='achievements'"
          >学习成就</button>
          <button
            class="seg-item"
            :class="{ active: activeTab==='analysis' }"
            role="tab"
            aria-selected="activeTab==='analysis'"
            @click="activeTab='analysis'"
          >学情分析</button>
          <button
            class="seg-item"
            :class="{ active: activeTab==='leaderboard' }"
            role="tab"
            aria-selected="activeTab==='leaderboard'"
            @click="activeTab='leaderboard'"
          >学习排行榜</button>
          <span class="seg-ink" :style="inkStyle"></span>
        </div>
      </div>
    </section>

    <!-- 学情分析（移至头像区域下方） -->
    <section class="section" v-if="activeTab==='analysis'">
      <el-card shadow="hover" class="card">
        <div class="card-title">学情分析</div>
        <div class="assessment-container">
          <div
            class="report-card"
            :class="{ 'card-hover': isHovered }"
            @mouseenter="isHovered = true"
            @mouseleave="isHovered = false"
          >
            <!-- 科目选择区域 -->
            <div class="subject-selector">
              <el-form label-width="100px">
                <el-form-item label="选择科目">
                  <el-select 
                    v-model="selectedSubject" 
                    placeholder="请选择要分析的科目"
                    @change="handleSubjectChange"
                  >
                    <el-option
                      v-for="course in selectedCourses"
                      :key="course.id"
                      :label="course.courseName"
                      :value="course.id"
                    />
                  </el-select>
                </el-form-item>
              </el-form>
            </div>

            <!-- 动态装饰元素 -->
            <div class="decoration-corner top-left"></div>
            <div class="decoration-corner top-right"></div>
            <div class="decoration-corner bottom-left"></div>
            <div class="decoration-corner bottom-right"></div>

            <!-- 报告内容区域边框 -->
            <div class="report-content-border">
              <div class="content-highlight"></div>

              

              <div class="floating-dots">
                <span v-for="n in 12" :key="n" :style="getDotStyle(n)"></span>
              </div>

              <!-- 动态展示内容 -->
              <div v-if="showReport" class="report-content">
                <h3 class="report-title">{{ selectedSubjectName }}学情分析报告</h3>
                <div class="report-meta">
                  <p><strong>学生ID：</strong> {{ analysisResult.studentId || profile.studentId }}</p>
                  <p><strong>课程ID：</strong> {{ selectedSubject }}</p>
                </div>
                
                <el-divider></el-divider>
                
                <div class="knowledge-analysis">
                  <h4>📚 知识点掌握情况</h4>
                  <p>{{ analysisResult.knowledgeAnalysis }}</p>
                </div>
                
                <el-divider></el-divider>
                
                <div class="suggestions">
                  <h4>💡 教学建议</h4>
                  <p>{{ analysisResult.teachingSuggestion }}</p>
                </div>
              </div>
              
              <!-- 未生成前的提示-->
              <div v-else class="report-placeholder">
                <p>点击按钮生成你的专属个人评价</p>
              </div>
            </div> 

            <!-- 按钮组 -->
            <div class="button-group bottom-buttons">
              <el-button
                type="primary"
                class="action-btn plan-btn"
                @click="generateReport"
                @mouseenter="hoverButton('plan')"
                @mouseleave="resetButton"
                :disabled="false"
                :loading="isGenerating"
              >
                <i class="el-icon-timer"></i>
                <span>生成学情分析</span>
                <div class="btn-underline" :class="{ active: activeBtn === 'plan' }"></div>
              </el-button>
            </div>
          </div>
        </div>
      </el-card>
    </section>

    <!-- 2) 学习进度追踪（已隐藏） -->
    <section class="section grid-2" v-if="false">
      <el-card shadow="hover" class="card">
        <div class="card-title">课程学习进度</div>
        <el-table :data="courseProgress" size="small" border>
          <el-table-column prop="courseName" label="课程名称" min-width="180" />
          <el-table-column prop="teacher" label="授课教师" width="120" />
          <el-table-column prop="weeks" label="开课周次" width="120" />
          <el-table-column label="进度" min-width="220">
            <template #default="scope">
              <div class="progress-row">
                <el-progress :percentage="scope.row.progress" :stroke-width="10" />
                <el-button link type="primary" @click="viewCourse(scope.row)">详情</el-button>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="latestChapter" label="最新学习章节" min-width="220" />
        </el-table>
      </el-card>

      <el-card shadow="hover" class="card">
        <div class="card-title">专项技能提升</div>
        <div class="radar">
          <div v-for="s in skills" :key="s.name" class="skill">
            <div class="skill-header">
              <span class="name">{{ s.name }}</span>
              <span class="val">{{ s.value }}%</span>
            </div>
            <div class="bar">
              <div class="fill" :style="{ width: s.value + '%' }"></div>
            </div>
          </div>
          <div class="hint">点击技能可查看练习记录与建议</div>
        </div>
      </el-card>
    </section>

    <!-- 3) 实时练习与错题管理 -->
    <section class="section grid-2" v-if="false">
      <el-card shadow="hover" class="card">
        <div class="card-title">近期练习记录</div>
        <el-timeline>
          <el-timeline-item v-for="(r, i) in recentPractices" :key="i" :timestamp="r.time" :type="r.tagType">
            <div class="practice-item">
              <div class="title">{{ r.type }} · {{ r.name }}</div>
              <div class="meta">{{ r.time }} | {{ r.score }}分</div>
              <el-tag size="small" :type="r.statusType">{{ r.status }}</el-tag>
            </div>
          </el-timeline-item>
        </el-timeline>
      </el-card>

      <el-card shadow="hover" class="card">
        <div class="card-title tabs">
          <span>错题本</span>
          <el-input v-model="wrong.filters.keyword" placeholder="按课程/知识点筛选" size="small" style="width:220px" />
        </div>
        <div class="wrong-list">
          <div v-for="w in filteredWrongList" :key="w.id" class="wrong-item">
            <div class="wrong-title">【{{ w.course }}】{{ w.point }} - {{ w.title }}</div>
            <div class="wrong-actions">
              <el-button size="small" @click="viewWrong(w)">查看详情</el-button>
              <el-button size="small" type="primary" @click="retryWrong(w)">再练一次</el-button>
            </div>
          </div>
        </div>
      </el-card>
    </section>

    <!-- 4) 在线学习助手 -->
    <section class="section grid-2" v-if="false">
      <el-card shadow="hover" class="card">
        <div class="card-title">智能答疑</div>
        <div class="assistant">
          <el-input v-model="assistant.question" placeholder="有问题？问助手（可输入文字/粘贴图片链接）" clearable />
          <el-button type="primary" @click="askAssistant">提问</el-button>
        </div>
        <div class="qa-history">
          <div v-for="q in assistant.history" :key="q.id" class="qa-item" @click="openQA(q)">
            <div class="q">Q：{{ q.title }}</div>
            <div class="time">{{ q.time }}</div>
          </div>
        </div>
      </el-card>

      <el-card shadow="hover" class="card">
        <div class="card-title">个性化练习推荐</div>
        <div class="reco-list">
          <div v-for="rec in recommendations" :key="rec.id" class="reco-item">
            <div class="reco-info">
              <div class="title">{{ rec.title }}</div>
              <div class="reason">{{ rec.reason }}</div>
              <div class="meta">{{ rec.type }} · {{ rec.level }}</div>
            </div>
            <el-button type="success" size="small" @click="startRec(rec)">开始练习</el-button>
          </div>
        </div>
      </el-card>
    </section>

    <!-- 5) 学习资源中心 -->
    <section class="section" v-if="false">
      <el-card shadow="hover" class="card">
        <div class="card-title resources">
          <span>学习资源中心</span>
          <div class="tools">
            <el-input v-model="resources.keyword" placeholder="关键词搜索" size="small" style="width:240px" />
            <el-button size="small" @click="toggleFavOnly">{{ resources.onlyFav ? '全部' : '我的收藏' }}</el-button>
          </div>
        </div>
        <div class="res-grid">
          <div v-for="res in filteredResources" :key="res.id" class="res-item">
            <div class="res-icon">📄</div>
            <div class="res-main">
              <div class="name">{{ res.name }}</div>
              <div class="meta">{{ res.course }} · {{ res.type }}</div>
            </div>
            <div class="res-actions">
              <el-button link type="primary" @click="previewRes(res)">预览</el-button>
              <el-button link @click="downloadRes(res)">下载</el-button>
              <el-button link type="warning" @click="toggleFav(res)">{{ res.fav ? '取消收藏' : '收藏' }}</el-button>
            </div>
          </div>
        </div>
      </el-card>
    </section>

    <!-- 勋章墙 -->
    <section class="section" v-if="activeTab==='achievements'">
      <el-card shadow="hover" class="card">
        <div class="card-title">勋章墙</div>
        <div class="medal-wall">
          <div v-for="m in medals" :key="m.id" class="medal-item" :class="{ locked: !m.unlocked }" :title="m.unlocked ? ('已解锁 · ' + m.desc) : ('待解锁 · ' + m.desc)" @click="openMedal(m)">
            <img :src="m.img" :alt="m.name" />
            <div class="medal-name">{{ m.name }}</div>
            <div class="medal-tip" v-if="!m.unlocked">待解锁</div>
          </div>
        </div>
        <div class="chart-legend">当前连续登录：{{ consecutiveLoginDays }} 天</div>
      </el-card>
    </section>

    <!-- 勋章3D展示弹窗 -->
    <el-dialog v-model="medalDialog.visible" width="480px" :show-close="true" class="medal-dialog" :title="medalDialog.medal?.name || '勋章'">
      <div class="medal-stage" @mousemove="onMedalMove" @mouseleave="onMedalLeave" @touchmove.passive="onMedalTouch">
        <div class="medal-card" :style="{ transform: medalTransform }">
          <img class="medal-large" :src="medalDialog.medal?.img" :alt="medalDialog.medal?.name" />
          <div class="medal-shine"></div>
        </div>
      </div>
      <div class="medal-meta">
        <div class="medal-title">{{ medalDialog.medal?.name }}</div>
        <div class="medal-desc">{{ medalDialog.medal?.desc }}</div>
        <div class="medal-state" :class="{ unlocked: medalDialog.medal?.unlocked }">{{ medalDialog.medal?.unlocked ? '已解锁' : '待解锁' }}</div>
      </div>
      <template #footer>
        <el-button @click="medalDialog.visible=false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 学习打卡墙（上移到数据统计前） -->
    <section class="section" v-if="activeTab==='achievements'">
      <el-card shadow="hover" class="card">
        <div class="card-title">学习打卡墙（近一年）</div>
        <div class="calendar-grid">
          <div v-for="(d, i) in calendar" :key="i" class="cell" :title="`${d.date}：${d.count} 次`" :style="{ background: colorFor(d.count) }"></div>
        </div>
        <div class="chart-legend">颜色越深表示当天登录次数越多</div>
      </el-card>
    </section>

    <!-- 6) 学习数据统计（保留：近7天登录折线图与练习统计） -->
    <section class="section grid-2" v-if="activeTab==='achievements'">
      <el-card shadow="hover" class="card">
        <div class="card-title">近7天学习情况</div>
        <div id="loginChart" class="chart-container"></div>
        <div class="chart-legend">显示近7天的登录次数和学习活跃度</div>
      </el-card>

      <el-card shadow="hover" class="card">
        <div class="card-title">练习统计</div>
        <div id="practiceChart" class="chart-container"></div>
        <div class="chart-legend">累计练习次数和平均正确率</div>
      </el-card>
    </section>

    <!-- 学习排行榜 -->
    <section class="section" v-if="activeTab==='leaderboard'">
      <el-card shadow="hover" class="card leaderboard-card">
        <div class="card-title">学习排行榜</div>
        <div class="course-chip-bar" aria-label="按课程筛选排行榜" role="group">
          <button
            class="chip"
            :class="{ active: leaderboardCourseId === 'overall' }"
            @click="selectLeaderboardCourse('overall')"
            title="总榜（所有课程）"
          >
            <span class="dot all"></span>
            <span class="text">全部</span>
          </button>
          <!-- <button
            class="chip"
            :class="{ active: !leaderboardCourseId || leaderboardCourseId === '' }"
            @click="selectLeaderboardCourse('')"
            title="全部课程"
          >
            <span class="dot all"></span>
            <span class="text">全部</span>
          </button> -->
          <div class="chip-scroller">
            <button
              class="chip"
              v-for="course in selectedCourses"
              :key="course.id"
              :class="{ active: leaderboardCourseId === course.id }"
              @click="selectLeaderboardCourse(course.id)"
              :title="course.courseName || course.name"
            >
              <span class="dot"></span>
              <span class="text">{{ (course.courseName || course.name) || '课程' }}</span>
            </button>
          </div>
        </div>
        <div class="leaderboard">
          <div class="podium">
            <div class="podium-item second">
              <div class="medal silver">2</div>
              <div class="avatar"><img :src="leaderboardTop[1]?.avatar" alt="2" /></div>
              <div class="name">{{ leaderboardTop[1]?.name || '-' }}</div>
              <div class="score">{{ leaderboardTop[1]?.score ?? '-' }}</div>
              <div class="pedestal"></div>
            </div>
            <div class="podium-item first">
              <div class="medal gold">1</div>
              <div class="avatar"><img :src="leaderboardTop[0]?.avatar" alt="1" /></div>
              <div class="name">{{ leaderboardTop[0]?.name || '-' }}</div>
              <div class="score">{{ leaderboardTop[0]?.score ?? '-' }}</div>
              <div class="pedestal"></div>
            </div>
            <div class="podium-item third">
              <div class="medal bronze">3</div>
              <div class="avatar"><img :src="leaderboardTop[2]?.avatar" alt="3" /></div>
              <div class="name">{{ leaderboardTop[2]?.name || '-' }}</div>
              <div class="score">{{ leaderboardTop[2]?.score ?? '-' }}</div>
              <div class="pedestal"></div>
            </div>
          </div>
          <div class="rank-table">
            <div class="thead">
              <div class="col rank">排名</div>
              <div class="col nick">昵称</div>
              <div class="col fire">学习积分</div>
            </div>
            <div class="row" v-for="(item, idx) in leaderboardRest" :key="item.id || idx">
              <div class="col rank">{{ item.rank }}</div>
              <div class="col nick">{{ item.name }}</div>
              <div class="col fire">
                <span class="fire-ico">🔥</span>
                {{ item.score }}
              </div>
            </div>
          </div>
        </div>
      </el-card>
    </section>

    <!-- 打卡墙（原位置隐藏） -->
    <section class="section" v-if="false">
      <el-card shadow="hover" class="card">
        <div class="card-title">学习打卡墙（近一年）</div>
        <div class="calendar-grid">
          <div v-for="(d, i) in calendar" :key="i" class="cell" :title="`${d.date}：${d.count} 次`" :style="{ background: colorFor(d.count) }"></div>
        </div>
        <div class="chart-legend">颜色越深表示当天登录次数越多</div>
      </el-card>
    </section>

    

    <!-- 8) 详细学习数据统计 -->
    <section class="section grid-2" v-if="false">
      <el-card shadow="hover" class="card">
        <div class="card-title">近30天正确率趋势</div>
        <div class="line-chart">
          <div class="line" v-for="(p, i) in accuracyTrend" :key="i" :style="{ height: p + '%'}"></div>
        </div>
        <div class="trend-legend">峰值：{{ maxAccuracy.day }}（{{ maxAccuracy.val }}%） · 谷值：{{ minAccuracy.day }}（{{ minAccuracy.val }}%）</div>
      </el-card>

      <el-card shadow="hover" class="card">
        <div class="card-title">知识点掌握情况与高频错误</div>
        <div class="bars">
          <div v-for="k in knowledgeMastery" :key="k.name" class="bar-item" @click="openPoint(k)">
            <div class="label">{{ k.name }}</div>
            <div class="bar"><div class="fill" :style="{ width: k.value + '%' , background: k.value >= 80 ? '#22c55e' : (k.value < 60 ? '#ef4444' : '#f59e0b') }"></div></div>
            <div class="val">{{ k.value }}%</div>
          </div>
        </div>
        <div class="top-errors">
          <div class="err" v-for="e in topErrorPoints" :key="e.name">
            <div class="ename">❗{{ e.name }}</div>
            <div class="rec">推荐：{{ e.recommend }}</div>
          </div>
        </div>
      </el-card>
    </section>
  </div>
  
</template>

<script setup>
import { computed, ref, onMounted, watch, nextTick } from 'vue'
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { Male, Female } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import { useUserStore } from '@/store/user'
// 顶部筛选栏状态：achievements | analysis
const activeTab = ref('achievements')
const inkStyle = computed(() => {
  const map = { achievements: 0, analysis: 1, leaderboard: 2 }
  const index = map[activeTab.value] ?? 0
  return {
    width: '33.3333%',
    transform: `translateX(${index * 100}%)`
  }
})

// 基础信息（从数据库获取）
const profile = ref({
  name: '',
  studentId: '',
  major: '',
  grade: '',
  avatar: '',
  gender: ''
})
const nameInitial = computed(() => profile.value.name?.charAt(0) || '学')
const avatarUrl = computed(() => {
  const u = profile.value.avatar || ''
  if (!u) return ''
  try {
    // 若包含未编码的中文/空格，统一编码
    return decodeURI(u) === u ? encodeURI(u) : u
  } catch { return u }
})
const onAvatarError = () => { profile.value.avatar = '' }

// 性别判断函数
const getGenderValue = (gender, sex) => {
  const genderValue = (gender || sex || '').toString().toLowerCase()
  if (genderValue.includes('女') || genderValue === 'female' || genderValue === 'f' || genderValue === '1') return 'female'
  if (genderValue.includes('男') || genderValue === 'male' || genderValue === 'm' || genderValue === '0') return 'male'
  return ''
}

// 从数据库获取用户信息
const loadUserProfile = async () => {
  try {
    // 优先使用Pinia store中的用户信息，但如果没有性别信息则调用API
    const store = useUserStore()
    if (store.currentUser) {
      const userData = store.currentUser
      
      // 如果Pinia中有性别信息，直接使用
      if (userData.gender || userData.sex) {
        profile.value = {
          name: userData.realName || userData.real_name || userData.username || '未知用户',
          studentId: userData.id?.toString() || '未知学号',
          major: userData.school || '未设置学校',
          grade: userData.className || userData.class || '未设置班级',
          avatar: userData.avatarUrl || '',
          gender: getGenderValue(userData.gender, userData.sex)
        }
        
        // 确保头像同步到本地存储，供群聊使用
        if (userData.avatarUrl) {
          localStorage.setItem('studentAvatarUrl', userData.avatarUrl)
          console.log('已从Pinia同步学生头像到本地存储:', userData.avatarUrl)
        }
        return
      } else {
      }
    }
    
    // 如果Pinia没有数据，则使用localStorage和API
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    
    if (user?.id) {
      // 从后端获取用户详细信息
      const response = await axios.get(`/api/xiaozhi/user/${user.id}`)
      if (response.data.code === 200) {
        const userData = response.data.data
        profile.value = {
          name: userData.realName || userData.real_name || userData.username || '未知用户',
          studentId: userData.id?.toString() || '未知学号',
          major: userData.school || '未设置学校',
          grade: userData.className || userData.class || '未设置班级',
          avatar: userData.avatarUrl || userData.avatar_url || '',
          gender: getGenderValue(userData.gender, userData.sex)
        }
        
        // 确保头像同步到本地存储，供群聊使用
        if (userData.avatarUrl || userData.avatar_url) {
          const avatarUrl = userData.avatarUrl || userData.avatar_url
          localStorage.setItem('studentAvatarUrl', avatarUrl)
          console.log('已从API同步学生头像到本地存储:', avatarUrl)
        }
      } else {
        // 如果后端接口不存在，使用本地存储的基本信息
        profile.value = {
          name: user.realName || user.real_name || user.username || '未知用户',
          studentId: user.id?.toString() || '未知学号',
          major: user.school || '未设置学校',
          grade: user.className || user.class || '未设置班级',
          avatar: user.avatarUrl || '',
          gender: (user.gender || user.sex || '').toString().toLowerCase().includes('女') ? 'female' : ((user.gender || user.sex || '').toString().toLowerCase().includes('男') ? 'male' : '')
        }
      }
    } else {
      // 如果没有用户信息，显示默认值
      profile.value = {
        name: '请先登录',
        studentId: '未知',
        major: '未设置',
        grade: '未设置',
        avatar: '',
        gender: ''
      }
    }
  } catch (error) {
    console.error('获取用户信息失败:', error)
    // 使用本地存储的基本信息作为备选
    try {
      const raw = localStorage.getItem('currentUser')
      const user = raw ? JSON.parse(raw) : null
      if (user) {
        profile.value = {
          name: user.realName || user.real_name || user.username || '未知用户',
          studentId: user.id?.toString() || '未知学号',
          major: user.school || '未设置学校',
          grade: user.className || user.class || '未设置班级',
          avatar: user.avatarUrl || '',
          gender: (user.gender || user.sex || '').toString().toLowerCase().includes('女') ? 'female' : ((user.gender || user.sex || '').toString().toLowerCase().includes('男') ? 'male' : '')
        }
      }
    } catch (e) {
      console.error('解析本地用户信息失败:', e)
    }
  }
}

// 加载学习统计数据
const loadStudyStats = async () => {
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    
    if (user?.id) {
      // 从后端获取学习统计数据
      const response = await axios.get(`/api/xiaozhi/student/stats/${user.id}`)
      if (response.data.code === 200) {
        const stats = response.data.data
        recentStudyDays.value = stats.recentStudyDays || 0
        totalPractices.value = stats.totalPractices || 0
        avgAccuracy.value = stats.avgAccuracy || 0
        lastLogin.value = stats.lastLogin || '未记录'
        // 直接使用后端返回的学习积分
        studyPoints.value = Number(stats.studyPoints ?? stats.points ?? stats.score ?? 0)
        // 缓存数据，供切换标签后重绘
        statsCache.value = {
          loginData: stats.loginData || [],
          totalPractices: stats.totalPractices || 0,
          avgAccuracy: stats.avgAccuracy || 0
        }
        
        // 初始化图表
        initCharts(stats)
      }
    }
  } catch (error) {
    console.error('获取学习统计数据失败:', error)
    // 使用默认值
    recentStudyDays.value = 0
    totalPractices.value = 0
    avgAccuracy.value = 0
    lastLogin.value = '未记录'
    studyPoints.value = 0
  }
}

// 初始化图表
const initCharts = (stats) => {
  // 初始化登录图表（折线图）
  initLoginChart(stats.loginData || [])
  
  // 初始化练习图表（柱状图）
  initPracticeChart(stats.totalPractices || 0, stats.avgAccuracy || 0)
}

// 初始化登录图表（折线图）
const initLoginChart = (loginData) => {
  const chartDom = document.getElementById('loginChart')
  if (!chartDom) return
  
  const myChart = echarts.init(chartDom)
  
  const option = {
    tooltip: {
      trigger: 'axis',
      formatter: function(params) {
        const data = params[0]
        return `${data.name}<br/>登录次数: ${data.value}次`
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: loginData.map(item => item.date)
    },
    yAxis: {
      type: 'value',
      minInterval: 1
    },
    series: [
      {
        name: '登录次数',
        type: 'line',
        smooth: true,
        data: loginData.map(item => item.loginCount),
        itemStyle: {
          color: '#3b82f6'
        },
        areaStyle: {
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(59, 130, 246, 0.3)' },
              { offset: 1, color: 'rgba(59, 130, 246, 0.1)' }
            ]
          }
        }
      }
    ]
  }
  
  myChart.setOption(option)
  
  // 保存图表实例以便后续更新
  loginChartInstance.value = myChart
}

// 初始化练习图表（柱状图）
const initPracticeChart = (totalPractices, avgAccuracy) => {
  const chartDom = document.getElementById('practiceChart')
  if (!chartDom) return
  
  const myChart = echarts.init(chartDom)
  
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: ['练习次数', '正确率']
    },
    yAxis: [
      {
        type: 'value',
        name: '次数',
        position: 'left'
      },
      {
        type: 'value',
        name: '百分比',
        position: 'right',
        axisLabel: {
          formatter: '{value}%'
        }
      }
    ],
    series: [
      {
        name: '练习次数',
        type: 'bar',
        data: [totalPractices, 0],
        itemStyle: {
          color: '#10b981'
        },
        yAxisIndex: 0
      },
      {
        name: '正确率',
        type: 'bar',
        data: [0, avgAccuracy],
        itemStyle: {
          color: '#f59e0b'
        },
        yAxisIndex: 1
      }
    ]
  }
  
  myChart.setOption(option)
  
  // 保存图表实例以便后续更新
  practiceChartInstance.value = myChart
}

// 加载课程进度数据
const loadCourseProgress = async () => {
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    
    if (user?.id) {
      // 从后端获取课程进度数据
      const response = await axios.get(`/api/xiaozhi/student/courses/${user.id}`)
      if (response.data.code === 200) {
        courseProgress.value = response.data.data || []
      }
    }
  } catch (error) {
    console.error('获取课程进度数据失败:', error)
    // 使用空数组作为默认值
    courseProgress.value = []
  }
}

// 加载技能掌握数据
const loadSkillsData = async () => {
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    
    if (user?.id) {
      // 从后端获取技能掌握数据
      const response = await axios.get(`/api/xiaozhi/student/skills/${user.id}`)
      if (response.data.code === 200) {
        skills.value = response.data.data || []
      }
    }
  } catch (error) {
    console.error('获取技能掌握数据失败:', error)
    // 使用空数组作为默认值
    skills.value = []
  }
}

// 加载近期练习数据
const loadRecentPractices = async () => {
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    
    if (user?.id) {
      // 从后端获取近期练习数据
      const response = await axios.get(`/api/xiaozhi/student/practices/${user.id}`)
      if (response.data.code === 200) {
        recentPractices.value = response.data.data || []
      }
    }
  } catch (error) {
    console.error('获取近期练习数据失败:', error)
    // 使用空数组作为默认值
    recentPractices.value = []
  }
}

// 加载错题本数据
const loadWrongQuestions = async () => {
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    
    if (user?.id) {
      // 从后端获取错题本数据
      const response = await axios.get(`/api/xiaozhi/student/wrong-questions/${user.id}`)
      if (response.data.code === 200) {
        wrong.value.list = response.data.data || []
      }
    }
  } catch (error) {
    console.error('获取错题本数据失败:', error)
    // 使用空数组作为默认值
    wrong.value.list = []
  }
}

// 加载智能助手数据
const loadAssistantData = async () => {
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    
    if (user?.id) {
      // 从后端获取智能助手数据
      const response = await axios.get(`/api/xiaozhi/student/assistant/${user.id}`)
      if (response.data.code === 200) {
        assistant.value.history = response.data.data || []
      }
    }
  } catch (error) {
    console.error('获取智能助手数据失败:', error)
    // 使用空数组作为默认值
    assistant.value.history = []
  }
}

// 加载个性化推荐数据
const loadRecommendations = async () => {
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    
    if (user?.id) {
      // 从后端获取个性化推荐数据
      const response = await axios.get(`/api/xiaozhi/student/recommendations/${user.id}`)
      if (response.data.code === 200) {
        recommendations.value = response.data.data || []
      }
    }
  } catch (error) {
    console.error('获取个性化推荐数据失败:', error)
    // 使用空数组作为默认值
    recommendations.value = []
  }
}

// 加载资源中心数据
const loadResources = async () => {
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    
    if (user?.id) {
      // 从后端获取资源中心数据
      const response = await axios.get(`/api/xiaozhi/student/resources/${user.id}`)
      if (response.data.code === 200) {
        resources.value.list = response.data.data || []
      }
    }
  } catch (error) {
    console.error('获取资源中心数据失败:', error)
    // 使用空数组作为默认值
    resources.value.list = []
  }
}

// 加载正确率趋势数据
const loadAccuracyTrend = async () => {
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    
    if (user?.id) {
      // 从后端获取正确率趋势数据
      const response = await axios.get(`/api/xiaozhi/student/accuracy-trend/${user.id}`)
      if (response.data.code === 200) {
        accuracyTrend.value = response.data.data || []
      }
    }
  } catch (error) {
    console.error('获取正确率趋势数据失败:', error)
    // 使用空数组作为默认值
    accuracyTrend.value = []
  }
}

// 加载知识点掌握数据
const loadKnowledgeMastery = async () => {
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    
    if (user?.id) {
      // 从后端获取知识点掌握数据
      const response = await axios.get(`/api/xiaozhi/student/knowledge-mastery/${user.id}`)
      if (response.data.code === 200) {
        knowledgeMastery.value = response.data.data?.mastery || []
        topErrorPoints.value = response.data.data?.errorPoints || []
      }
    }
  } catch (error) {
    console.error('获取知识点掌握数据失败:', error)
    // 使用空数组作为默认值
    knowledgeMastery.value = []
    topErrorPoints.value = []
  }
}

// (此处移除重复定义，统一保留文件后部的打卡墙实现)

// 选择并上传头像
const fileInputRef = ref(null)
const onEditAvatar = () => {
  if (!fileInputRef.value) return
  fileInputRef.value.click()
}

const handleAvatarSelected = async (e) => {
  const file = e.target.files && e.target.files[0]
  if (!file) return
  try {
    const form = new FormData()
    form.append('file', file)
    // 复用后端已有上传接口，返回 OSS URL 在 message 字段
    const { data } = await axios.post('/api/xiaozhi/teacher/image', form, { headers: { 'Content-Type': 'multipart/form-data' } })
    const rawUrl = data?.data || data?.message || ''
    const url = rawUrl ? ((() => { try { return decodeURI(rawUrl) === rawUrl ? encodeURI(rawUrl) : rawUrl } catch { return rawUrl } })()) : ''
    if (!url) throw new Error('上传失败')
    
    // 更新profile中的头像
    profile.value.avatar = url
    
    // 更新本地存储
    try { localStorage.setItem('studentAvatarUrl', url) } catch {}
    
    // 更新Pinia store中的用户信息
    const store = useUserStore()
    if (store.currentUser) {
      store.currentUser.avatarUrl = url
      console.log('已更新Pinia store中的学生头像:', url)
    }
    
    // 同步保存到后端 user.avatar_url
    try {
      const raw = localStorage.getItem('currentUser')
      const user = raw ? JSON.parse(raw) : null
      if (user?.id) {
        await axios.post('/api/xiaozhi/user/avatar', { userId: user.id, avatarUrl: url })
        // 刷新本地用户对象，便于其它页面使用
        user.avatarUrl = url
        localStorage.setItem('currentUser', JSON.stringify(user))
      }
    } catch (e) {
      console.warn('后端头像保存失败（不影响前端显示）', e)
    }
    
    // 触发头像更新事件，通知其他组件
    try { 
      window.dispatchEvent(new CustomEvent('student-avatar-updated', { detail: url }))
    } catch {}
    
    ElMessage.success('头像已更新并同步到群聊')
  } catch (err) {
    console.error('头像上传失败:', err)
    ElMessage.error('头像上传失败，请重试')
  } finally {
    if (fileInputRef.value) fileInputRef.value.value = ''
  }
}

// 初始化：加载用户信息和头像
onMounted(async () => {
  // 加载用户基本信息
  await loadUserProfile()
  
  // 加载学习统计数据
  await loadStudyStats()
  
  // 加载课程进度数据
  // await loadCourseProgress()
   
  // 加载技能掌握数据
  // await loadSkillsData()
   
  // 加载近期练习数据
  // await loadRecentPractices()
   
  // 加载错题本数据
  // await loadWrongQuestions()
   
  // 加载智能助手数据
  // await loadAssistantData()
   
  // 加载个性化推荐数据
  // await loadRecommendations()
   
  // 加载资源中心数据
  // await loadResources()
   
  // 加载正确率趋势数据
  // await loadAccuracyTrend()
   
  // 加载知识点掌握数据
  // await loadKnowledgeMastery()
  
  // 加载打卡墙
  await loadCalendar()
  
  // 初始化学情分析模块：加载已选课程
  await loadSelectedCourses()

  // 加载学习排行榜
  await loadLeaderboard()
  
  // 如果loadUserProfile没有设置头像，则使用本地存储的头像
  if (!profile.value.avatar) {
    try {
      const local = localStorage.getItem('studentAvatarUrl')
      if (local) {
        profile.value.avatar = decodeURI(local) === local ? encodeURI(local) : local
      } else {
        const raw = localStorage.getItem('currentUser')
        const user = raw ? JSON.parse(raw) : null
        if (user?.avatarUrl) {
          const u = user.avatarUrl
          profile.value.avatar = decodeURI(u) === u ? encodeURI(u) : u
        }
      }
    } catch {}
  }
  
  console.log('学生端个人信息页面头像初始化完成:', profile.value.avatar)
})

// 学情分析模块相关函数
const hoverButton = (type) => {
  activeBtn.value = type
}

const resetButton = () => {
  activeBtn.value = null
}

const getDotStyle = (index) => {
  const dot = dotPositions.value[index - 1]
  if (!dot) {
    return {
      left: '50%',
      top: '50%',
      width: '4px',
      height: '4px',
      animationDelay: '0s'
    }
  }
  return {
    left: `${dot.x}%`,
    top: `${dot.y}%`,
    width: `${dot.size}px`,
    height: `${dot.size}px`,
    animationDelay: `${dot.delay}s`
  }
}

const handleSubjectChange = () => {
  const course = selectedCourses.value.find(c => c.id === selectedSubject.value)
  selectedSubjectName.value = course ? (course.courseName || course.name || '') : ''
}

// 生成学情分析报告
const generateReport = async () => {
  if (!selectedSubject.value) {
    ElMessage.warning('请先选择要分析的科目')
    return
  }

  try {
    isGenerating.value = true
    showReport.value = false
    
    // 调用学情分析接口
    const response = await axios.post('/api/xiaozhi/teacher/student', {
      studentId: useUserStore().currentUserId,
      courseId: selectedSubject.value
    }, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    })

    if (response.data) {
      analysisResult.value = {
        knowledgeAnalysis: response.data.knowledgeAnalysis || '暂无分析结果',
        teachingSuggestion: response.data.teachingSuggestion || '暂无教学建议'
      }
      showReport.value = true
      ElMessage.success('学情分析报告生成成功')
    } else {
      ElMessage.error('获取分析结果失败')
    }
  } catch (error) {
    console.error('生成报告失败:', error)
    ElMessage.error('生成报告失败，请稍后再试')
  } finally {
    isGenerating.value = false
  }
}

// 加载已选课程（与 my_school 页面保持一致）
const loadSelectedCourses = async () => {
  try {
    const res = await axios.get('/xiaozhi/student/my-courses', {
      params: { studentId: useUserStore().currentUserId }
    })
    if (res.data.code === 200) {
      selectedCourses.value = res.data.data || []
    } else {
      ElMessage.error(res.data.message || '获取已选课程失败')
      selectedCourses.value = []
    }
  } catch (err) {
    console.error('获取课程失败:', err)
    ElMessage.error('网络异常，请稍后再试')
    selectedCourses.value = []
  }
}

// 概览统计（从数据库获取或使用默认值）
const recentStudyDays = ref(0)
const totalPractices = ref(0)
const avgAccuracy = ref(0)
const lastLogin = ref('')
const studyPoints = ref(0)

// 图表实例引用
const loginChartInstance = ref(null)
const practiceChartInstance = ref(null)
// 图表数据缓存，便于切换回“学习成就”时重绘
const statsCache = ref({ loginData: [], totalPractices: 0, avgAccuracy: 0 })

// 监听筛选栏切换，返回“学习成就”时重绘图表
watch(activeTab, async (tab) => {
  if (tab === 'achievements') {
    await nextTick()
    try {
      initLoginChart(statsCache.value.loginData || [])
      initPracticeChart(statsCache.value.totalPractices || 0, statsCache.value.avgAccuracy || 0)
    } catch (e) {
      // 忽略单次渲染错误
    }
  }
})

// 学习排行榜数据
const leaderboard = ref([])
const leaderboardCourseId = ref('overall')
const leaderboardTop = computed(() => leaderboard.value.slice(0, 3))
const leaderboardRest = computed(() => leaderboard.value.slice(3))

const loadLeaderboard = async () => {
  try {
    let res
    if (leaderboardCourseId.value === 'overall') {
      res = await axios.get('/api/xiaozhi/student/leaderboard/overall', { params: { limit: 100 } })
    } else {
      res = await axios.get('/api/xiaozhi/student/leaderboard', {
        params: {
          studentId: useUserStore().currentUserId,
          courseId: leaderboardCourseId.value || undefined
        }
      })
    }
    if (res.data?.code === 200 && Array.isArray(res.data.data)) {
      leaderboard.value = normalizeLeaderboard(res.data.data)
    } else {
      leaderboard.value = getMockLeaderboard()
    }
  } catch (e) {
    leaderboard.value = getMockLeaderboard()
  }
}

const onLeaderboardCourseChange = () => {
  loadLeaderboard()
}

const selectLeaderboardCourse = (id) => {
  if (leaderboardCourseId.value === id) return
  leaderboardCourseId.value = id
  onLeaderboardCourseChange()
}

const normalizeLeaderboard = (arr) => {
  try {
    const list = (arr || []).map((it, i) => ({
      id: it.id || i,
      rank: it.rank || i + 1,
      name: it.name || it.username || '同学',
      score: Number(it.score ?? it.points ?? it.totalPractices ?? 0),
      avatar: it.avatarUrl || it.avatar_url || ''
    }))
    return list.sort((a, b) => b.score - a.score).map((it, i) => ({ ...it, rank: i + 1 }))
  } catch { return [] }
}

const getMockLeaderboard = () => {
  const names = ['张同学','李同学','王同学','赵同学','钱同学','孙同学','周同学','吴同学','郑同学','冯同学','陈同学','褚同学']
  const list = Array.from({ length: 14 }).map((_, i) => ({
    id: i + 1,
    rank: i + 1,
    name: names[i % names.length],
    score: Math.floor(12000 - i * (500 + Math.random() * 300)),
    avatar: ''
  }))
  return list
}

// 学情分析模块相关变量
const isHovered = ref(false)
const activeBtn = ref(null)
const showReport = ref(false)
const selectedSubject = ref('')
const isGenerating = ref(false)
const analysisResult = ref({
  knowledgeAnalysis: '',
  teachingSuggestion: ''
})
const selectedCourses = ref([])
const selectedSubjectName = ref('')

// 浮动点位置 - 立即初始化
const dotPositions = ref([])
// 立即初始化浮动点位置
for (let i = 0; i < 12; i++) {
  dotPositions.value.push({
    x: Math.random() * 90 + 5,
    y: Math.random() * 90 + 5,
    size: Math.random() * 4 + 2,
    delay: Math.random() * 2
  })
}

// 课程学习进度（从数据库获取）
const courseProgress = ref([])

// 技能掌握（从数据库获取）
const skills = ref([])

// 近期练习（从数据库获取）
const recentPractices = ref([])

// 错题本（从数据库获取）
const wrong = ref({
  filters: { keyword: '' },
  list: []
})
const filteredWrongList = computed(() => {
  const q = wrong.value.filters.keyword.trim()
  if (!q) return wrong.value.list
  return wrong.value.list.filter(w => (w.course + w.point + w.title).includes(q))
})

// 智能助手（从数据库获取）
const assistant = ref({
  question: '',
  history: []
})

// 个性化推荐（从数据库获取）
const recommendations = ref([])

// 资源中心（从数据库获取）
const resources = ref({
  keyword: '',
  onlyFav: false,
  list: []
})
const filteredResources = computed(() => {
  let arr = resources.value.list
  if (resources.value.keyword) {
    const q = resources.value.keyword.toLowerCase()
    arr = arr.filter(r => r.name.toLowerCase().includes(q))
  }
  if (resources.value.onlyFav) arr = arr.filter(r => r.fav)
  return arr
})

// 正确率趋势（从数据库获取）
const accuracyTrend = ref([])
const maxAccuracy = computed(() => {
  const val = Math.max(...accuracyTrend.value)
  const day = `第${accuracyTrend.value.indexOf(val) + 1}天`
  return { val, day }
})
const minAccuracy = computed(() => {
  const val = Math.min(...accuracyTrend.value)
  const day = `第${accuracyTrend.value.indexOf(val) + 1}天`
  return { val, day }
})

const knowledgeMastery = ref([])
const topErrorPoints = ref([])

// 打卡墙数据（近一年）
const calendar = ref([])
const colorFor = (count) => {
  // 绿色梯度：0=灰，>=1 浅绿，>=4 中绿，>=8 深绿，>=12 更深
  if (count >= 12) return '#166534'    // 深
  if (count >= 8)  return '#15803d'
  if (count >= 4)  return '#22c55e'
  if (count >= 1)  return '#86efac'
  return '#e5e7eb'                     // 无记录
}

const loadCalendar = async () => {
  try {
    const raw = localStorage.getItem('currentUser')
    const user = raw ? JSON.parse(raw) : null
    if (!user?.id) return
    const { data } = await axios.get(`/api/xiaozhi/student/stats/calendar/${user.id}`)
    if (data.code === 200 && Array.isArray(data.data)) {
      calendar.value = data.data
      // 计算连续登录天数
      consecutiveLoginDays.value = computeConsecutiveLoginDays(calendar.value)
    }
  } catch (e) {
    calendar.value = []
  }
}

// actions (占位)
const go = (key) => {}
// onEditAvatar 已实现（触发文件选择）
const onEditNickname = () => {}
const viewCourse = (row) => {}
const viewWrong = (w) => {}
const retryWrong = (w) => {}
const askAssistant = () => {}
const openQA = (q) => {}
const startRec = (rec) => {}
const previewRes = (res) => {}
const downloadRes = (res) => {}
const toggleFav = (res) => { res.fav = !res.fav }
const toggleFavOnly = () => { resources.value.onlyFav = !resources.value.onlyFav }

// 勋章墙逻辑
const consecutiveLoginDays = ref(0)
const medalPerfectWeekImg = new URL('@/assets/images/完美周.png', import.meta.url).href
const medal18Img = new URL('@/assets/images/直上18楼.png', import.meta.url).href
const medalEarlyBirdImg = new URL('@/assets/images/笨鸟先飞.png', import.meta.url).href
const medalDiligentImg = new URL('@/assets/images/勤能补拙.png', import.meta.url).href
const medalNightOwlImg = new URL('@/assets/images/夙兴夜寐.png', import.meta.url).href
const medals = computed(() => [
  { id: 'perfect_week', name: '完美周', img: medalPerfectWeekImg, unlocked: consecutiveLoginDays.value >= 7, desc: '连续7天登录' },
  { id: 'eighteen_floors', name: '直上十八楼', img: medal18Img, unlocked: consecutiveLoginDays.value >= 18, desc: '连续18天登录' },
  { id: 'early_bird', name: '笨鸟先飞', img: medalEarlyBirdImg, unlocked: totalPractices.value >= 50, desc: '练习次数≥50' },
  { id: 'diligent', name: '勤能补拙', img: medalDiligentImg, unlocked: totalPractices.value >= 200, desc: '练习次数≥200' },
  { id: 'night_owl', name: '夙兴夜寐', img: medalNightOwlImg, unlocked: totalPractices.value >= 500, desc: '练习次数≥500' }
])

const computeConsecutiveLoginDays = (arr) => {
  try {
    const active = new Set((arr || []).filter(it => it && it.count > 0 && it.date).map(it => it.date))
    const ONE_DAY = 24 * 60 * 60 * 1000
    const pad = (n) => (n < 10 ? '0' + n : '' + n)
    const fmt = (d) => `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
    let d = new Date()
    let cnt = 0
    while (true) {
      const key = fmt(d)
      if (active.has(key)) {
        cnt++
        d = new Date(d.getTime() - ONE_DAY)
      } else {
        break
      }
    }
    return cnt
  } catch {
    return 0
  }
}

// 学习积分现在由后端统一计算和管理，前端不再需要计算逻辑

// 勋章3D预览逻辑
const medalDialog = ref({ visible: false, medal: null })
const tilt = ref({ x: 0, y: 0 })
const medalTransform = computed(() => `rotateX(${tilt.value.y}deg) rotateY(${tilt.value.x}deg)`)
const openMedal = (m) => { medalDialog.value = { visible: true, medal: m } }
const onMedalMove = (e) => {
  const rect = e.currentTarget.getBoundingClientRect()
  const px = (e.clientX - rect.left) / rect.width
  const py = (e.clientY - rect.top) / rect.height
  tilt.value = { x: (px - 0.5) * 20, y: -(py - 0.5) * 20 }
}
const onMedalLeave = () => { tilt.value = { x: 0, y: 0 } }
const onMedalTouch = (e) => {
  if (!e.touches?.length) return
  const t = e.touches[0]
  const rect = e.currentTarget.getBoundingClientRect()
  const px = (t.clientX - rect.left) / rect.width
  const py = (t.clientY - rect.top) / rect.height
  tilt.value = { x: (px - 0.5) * 20, y: -(py - 0.5) * 20 }
}

// 学习积分说明弹窗
const pointsHelpVisible = ref(false)
</script>

<style scoped>
.profile-page { display: flex; flex-direction: column; gap: 16px; }
.section { display: block; }
.grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.card { border-radius: 12px; }
.card-title { font-weight: 600; margin-bottom: 12px; }

.points-help { position: absolute; right: 0; top: -22px; font-size: 12px; color: #3b82f6; cursor: pointer; user-select: none; }
.points-help:hover { text-decoration: underline; }

.filter-bar { display: flex; justify-content: center; margin: 0 0 8px 0; }
.segmented {
  position: relative;
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  width: 360px;
  background: #f3f4f6;
  border-radius: 999px;
  padding: 4px;
  box-shadow: inset 0 1px 2px rgba(0,0,0,.05);
}
.seg-item {
  position: relative;
  z-index: 1;
  border: none;
  background: transparent;
  padding: 10px 16px;
  border-radius: 999px;
  font-weight: 600;
  color: #374151;
  cursor: pointer;
  transition: color .2s ease;
}
.seg-item.active { color: #ffffff; }
.seg-item:not(.active):hover { color: #111827; }
.seg-ink {
  position: absolute;
  z-index: 0;
  top: 4px;
  left: 4px;
  width: calc(33.3333% - 0px);
  height: calc(100% - 8px);
  background: #409eff;
  border-radius: 999px;
  box-shadow: 0 4px 12px rgba(64,158,255,.35);
  transition: transform .25s ease;
}

.overview { display: flex; justify-content: space-between; align-items: center; gap: 16px; }
.overview .left { display: flex; align-items: center; gap: 14px; }
.avatar-wrap { position: relative; display: inline-block; }
.gender-badge { position: absolute; right: -6px; bottom: -6px; width: 24px; height: 24px; border-radius: 50%; display: grid; place-items: center; box-shadow: 0 2px 6px rgba(0,0,0,.15); }
.gender-badge.male { background: #dbeafe; color: #1d4ed8; }
.gender-badge.female { background: #ffe4e6; color: #db2777; }
.overview .base .row { line-height: 22px; }
.overview .name { font-size: 18px; font-weight: 700; }
.overview .sid { font-size: 13px; color: #888; margin-left: 8px; }
.overview .minor { color: #666; }
.overview .actions { margin-top: 6px; display: flex; gap: 8px; }
.overview .stats { position: relative; display: grid; grid-template-columns: repeat(5, minmax(120px, 1fr)); gap: 12px; align-items: center; }
.overview .stat { background: #f8fafc; padding: 10px 12px; border-radius: 10px; text-align: center; }
.overview .stat .num { font-size: 18px; font-weight: 700; }
.overview .stat .label { font-size: 12px; color: #666; margin-top: 4px; }
.overview .stat.progress { text-align: left; }
.overview .stat .accuracy-display { display: flex; flex-direction: column; gap: 8px; }
.overview .stat .accuracy-value { 
    font-size: 18px; 
    font-weight: 700; 
    color: #22c55e; 
    text-align: center; 
    margin-bottom: 4px; 
}

.quick { margin-top: 12px; display: flex; gap: 10px; }

.progress-row { display: flex; align-items: center; gap: 8px; }

.radar { display: flex; flex-direction: column; gap: 10px; }
.skill .skill-header { display: flex; justify-content: space-between; align-items: center; }
.skill .name { font-weight: 600; }
.skill .bar { height: 10px; background: #eef2f7; border-radius: 6px; overflow: hidden; }
.skill .fill { height: 100%; background: #22c55e; }
.hint { color: #888; font-size: 12px; margin-top: 6px; }

.practice-item .title { font-weight: 600; }
.practice-item .meta { color: #666; font-size: 12px; margin: 4px 0; }

.tabs { display: flex; align-items: center; justify-content: space-between; }
.wrong-list { display: flex; flex-direction: column; gap: 12px; max-height: 320px; overflow: auto; }
.wrong-item { display: flex; justify-content: space-between; align-items: center; gap: 10px; background: #f8fafc; padding: 10px 12px; border-radius: 8px; }
.wrong-title { font-weight: 600; }

.assistant { display: flex; gap: 8px; }
.qa-history { margin-top: 12px; display: grid; gap: 8px; }
.qa-item { padding: 8px 10px; border: 1px dashed #dbeafe; border-radius: 8px; cursor: pointer; display: flex; justify-content: space-between; }
.qa-item .q { font-weight: 600; }
.qa-item .time { color: #888; font-size: 12px; }

.reco-list { display: flex; flex-direction: column; gap: 10px; }
.reco-item { display: flex; justify-content: space-between; align-items: center; background: #f8fafc; padding: 10px 12px; border-radius: 8px; }
.reco-info .title { font-weight: 600; }
.reco-info .reason { color: #666; font-size: 12px; }

.resources { display: flex; align-items: center; justify-content: space-between; }
.res-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 12px; }
.res-item { display: flex; align-items: center; gap: 10px; background: #f8fafc; padding: 10px 12px; border-radius: 8px; }
.res-icon { font-size: 20px; }
.res-main .name { font-weight: 600; }
.res-main .meta { font-size: 12px; color: #666; }
.res-actions { margin-left: auto; display: flex; gap: 10px; }

.line-chart { display: grid; grid-template-columns: repeat(30, 1fr); align-items: end; height: 160px; gap: 2px; background: linear-gradient(to top, #f8fafc, transparent); border-radius: 8px; padding: 6px; }
.line-chart .line { background: #3b82f6; border-radius: 2px; }
.trend-legend { margin-top: 8px; color: #666; font-size: 12px; }

.chart-container { height: 300px; width: 100%; }
.chart-legend { margin-top: 8px; color: #666; font-size: 12px; text-align: center; }

/* 学习排行榜样式 */
.leaderboard-card { overflow: hidden; }
.leaderboard { background: linear-gradient(180deg, #e6f0ff 0%, #eef6ff 100%); border-radius: 12px; padding: 12px; max-width: 800px; margin: 0 auto; }
.course-chip-bar { display:flex; align-items:center; gap:8px; background: rgba(255,255,255,.6); border: 1px solid #e5e7eb; border-radius: 999px; padding: 6px; margin-bottom: 10px; box-shadow: inset 0 1px 0 rgba(255,255,255,.8); backdrop-filter: blur(4px); }
.chip-scroller { display:flex; gap:6px; overflow:auto; padding: 2px 2px 2px 0; scrollbar-width: none; }
.chip-scroller::-webkit-scrollbar { height: 0; }
.chip { border: none; background: #ffffff; color:#374151; padding: 6px 12px; border-radius: 999px; display:flex; align-items:center; gap:8px; cursor:pointer; transition: all .15s ease; box-shadow: 0 2px 6px rgba(0,0,0,.06); white-space: nowrap; }
.chip:hover { transform: translateY(-1px); box-shadow: 0 4px 10px rgba(0,0,0,.08); }
.chip.active { background: #2563eb; color:#fff; box-shadow: 0 6px 14px rgba(37,99,235,.25); }
.chip .text { font-weight: 600; font-size: 13px; }
.chip .dot { width: 8px; height: 8px; border-radius: 50%; background: linear-gradient(180deg, #60a5fa, #1d4ed8); box-shadow: 0 0 0 2px rgba(37,99,235,.15); }
.chip .dot.all { background: linear-gradient(180deg, #a7f3d0, #10b981); box-shadow: 0 0 0 2px rgba(16,185,129,.15); }
.podium { position: relative; display: grid; grid-template-columns: 1fr 1.2fr 1fr; gap: 0; align-items: end; justify-items: center; margin: 14px 0 20px; }
.podium-item { position: relative; width: 90%; max-width: 220px; background: #fff; border-radius: 16px; text-align: center; padding: 16px 10px 36px; box-shadow: 0 10px 24px rgba(0,0,0,.12); z-index: 1; }
.podium-item.first { z-index: 3; transform: translateY(-16px) scale(1.04); }
.podium-item.second { z-index: 2; transform: translateY(0) scale(0.98); }
.podium-item.third { z-index: 2; transform: translateY(4px) scale(0.96); }
.medal { display: inline-block; background: #ffedd5; color: #f97316; font-weight: 800; padding: 2px 8px; border-radius: 999px; font-size: 14px; margin-bottom: 6px; }
.medal.gold { background: #ffe8a3; color: #b45309; }
.medal.silver { background: #e5e7eb; color: #374151; }
.medal.bronze { background: #fed7aa; color: #9a3412; }
.podium-item .avatar { width: 76px; height: 76px; border-radius: 50%; overflow: hidden; margin: 6px auto; background: #f3f4f6; display: grid; place-items: center; box-shadow: 0 6px 12px rgba(0,0,0,.08); }
.podium-item .avatar img { width: 100%; height: 100%; object-fit: cover; }
.podium-item .name { font-weight: 700; margin-top: 4px; }
.podium-item .score { color: #2563eb; font-weight: 800; margin-top: 2px; }
.podium-item .pedestal { position: absolute; left: 10%; right: 10%; bottom: 0; height: 28px; border-radius: 10px; background: linear-gradient(180deg, #e0ecff, #c2d8ff); box-shadow: inset 0 2px 0 rgba(255,255,255,.8), 0 -4px 12px rgba(0,0,0,.06); }
.rank-table { background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 14px rgba(0,0,0,.06); }
.rank-table .thead, .rank-table .row { display: grid; grid-template-columns: 70px 1fr 110px; align-items: center; padding: 10px 14px; }
.rank-table .thead { background: #2563eb; color: #fff; font-weight: 700; }
.rank-table .row { border-top: 1px solid #eef2f7; background: #fff; }
.rank-table .col.rank { text-align: left; }
.rank-table .col.nick { padding-left: 8px; }
.rank-table .col.fire { text-align: right; font-weight: 700; color: #ef4444; }
.fire-ico { margin-right: 6px; }

/* 勋章墙样式 */
.medal-wall { 
  display: grid; 
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); 
  gap: 12px; 
  align-items: start; 
}
.medal-item { 
  position: relative; 
  background: #f8fafc; 
  border-radius: 10px; 
  padding: 10px; 
  text-align: center; 
}
.medal-item img { 
  width: 120px; 
  height: 120px; 
  object-fit: contain; 
  display: block; 
  margin: 0 auto; 
}
.medal-name { margin-top: 6px; font-weight: 600; }
.medal-tip { position: absolute; top: 8px; right: 8px; font-size: 12px; color: #999; }
.medal-item.locked img { filter: grayscale(0.9) contrast(0.9); opacity: 0.7; }

.medal-dialog :deep(.el-dialog__header) { border-bottom: none; }
.medal-stage { perspective: 900px; padding: 8px 0; }
.medal-card { width: 100%; height: 300px; display: grid; place-items: center; transform-style: preserve-3d; transition: transform .2s ease; position: relative; }
.medal-large { width: 260px; height: 260px; object-fit: contain; filter: drop-shadow(0 12px 24px rgba(0,0,0,.25)); }
.medal-shine { position: absolute; inset: 0; background: radial-gradient(120px 80px at 20% 10%, rgba(255,255,255,.25), transparent 60%), linear-gradient(120deg, rgba(255,255,255,.06), transparent 40%); mix-blend-mode: screen; pointer-events: none; }
.medal-meta { text-align: center; margin-top: 6px; }
.medal-title { font-weight: 700; }
.medal-desc { color: #666; font-size: 13px; margin-top: 4px; }
.medal-state { margin-top: 6px; font-weight: 600; color: #999; }
.medal-state.unlocked { color: #22c55e; }

/* 打卡墙样式 */
.calendar-grid {
  display: grid;
  /* 竖排：一列显示周一到周日，从上到下，再从左到右按周推进 */
  grid-auto-flow: column;
  grid-template-rows: repeat(7, 12px);
  grid-auto-columns: 12px;
  gap: 3px;
  width: 1000px;
  padding: 8px;
  background: #f8fafc;
  border-radius: 8px;
  /* 去除右侧大空白：让容器按内容宽度收缩并靠左 */
  width: max-content;
  /* 居中显示 */
  margin: 0 auto;
}
.calendar-grid .cell { width: 12px; height: 12px; border-radius: 2px; }

.bars { display: flex; flex-direction: column; gap: 8px; }
.bar-item { display: grid; grid-template-columns: 120px 1fr 48px; align-items: center; gap: 8px; }
.bar-item .label { color: #333; }
.bar-item .bar { height: 12px; background: #eef2f7; border-radius: 6px; overflow: hidden; }
.bar-item .fill { height: 100%; background: #22c55e; }
.bar-item .val { text-align: right; color: #333; }

.top-errors { margin-top: 10px; display: grid; gap: 8px; }
.top-errors .err { background: #fff7ed; border: 1px solid #ffedd5; padding: 8px 10px; border-radius: 8px; }
.top-errors .ename { font-weight: 600; }
.top-errors .rec { font-size: 12px; color: #92400e; }

@media (max-width: 1024px) { .grid-2 { grid-template-columns: 1fr; } }

/* 学情分析模块样式 */
.assessment-container {
  width: 100%;
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
  perspective: 1000px;
}

.report-card {
  border: 1px solid #e0e0e0;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  padding: 30px;
  background: #ffffff;
  position: relative;
  overflow: hidden;
  transition: all 0.3s ease;
  transform-style: preserve-3d;
}

.card-hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
}

/* 装饰角 */
.decoration-corner {
  position: absolute;
  width: 60px;
  height: 60px;
  border-width: 2px;
  border-style: solid;
  opacity: 0.1;
  transition: all 0.3s ease;
}

.decoration-corner.top-left {
  top: 0;
  left: 0;
  border-right: none;
  border-bottom: none;
  border-color: #409EFF;
  border-top-left-radius: 12px;
}

.decoration-corner.top-right {
  top: 0;
  right: 0;
  border-left: none;
  border-bottom: none;
  border-color: #67C23A;
  border-top-right-radius: 12px;
}

.decoration-corner.bottom-left {
  bottom: 0;
  left: 0;
  border-right: none;
  border-top: none;
  border-color: #E6A23C;
  border-bottom-left-radius: 12px;
}

.decoration-corner.bottom-right {
  bottom: 0;
  right: 0;
  border-left: none;
  border-top: none;
  border-color: #F56C6C;
  border-bottom-right-radius: 12px;
}

.report-card:hover .decoration-corner {
  opacity: 0.3;
}

/* 按钮组样式 */
.button-group {
  display: flex;
  gap: 15px;
  margin-bottom: 25px;
  flex-wrap: wrap;
  justify-content: center;
  position: relative;
  z-index: 2;
}

.bottom-buttons {
  margin-top: 25px;
  margin-bottom: 0;
}

/* 按钮样式 */
.action-btn {
  border-radius: 24px;
  padding: 12px 24px;
  position: relative;
  overflow: hidden;
  transition: all 0.3s ease;
  border: none;
  background: #f5f7fa;
  color: #606266;
  display: flex;
  align-items: center;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
}

.action-btn i {
  margin-right: 8px;
  font-size: 16px;
}

.action-btn:hover {
  background: #409EFF;
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
}

.btn-underline {
  position: absolute;
  bottom: 0;
  left: 50%;
  width: 0;
  height: 2px;
  background: #409EFF;
  transition: all 0.3s ease;
  transform: translateX(-50%);
}

.btn-underline.active {
  width: 80%;
}

/* 报告内容样式 */
.report-content-border {
  position: relative;
  min-height: 200px;
  border: 2px dashed #e0e0e0;
  border-radius: 8px;
  padding: 20px;
  margin: 20px 0;
  background: #fafafa;
}

.content-highlight {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(45deg, transparent 30%, rgba(64, 158, 255, 0.1) 50%, transparent 70%);
  animation: shimmer 2s infinite;
  pointer-events: none;
}

@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

.floating-dots {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  pointer-events: none;
}

.floating-dots span {
  position: absolute;
  background: #409EFF;
  border-radius: 50%;
  animation: float 3s infinite ease-in-out;
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
}

.report-content {
  position: relative;
  z-index: 1;
}

.report-title {
  font-size: 24px;
  font-weight: 700;
  color: #333;
  margin-bottom: 20px;
  text-align: center;
}

.report-meta {
  margin-bottom: 20px;
}

.report-meta p {
  margin: 5px 0;
  color: #666;
}

.knowledge-analysis,
.suggestions {
  margin: 20px 0;
}

.knowledge-analysis h4,
.suggestions h4 {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin-bottom: 10px;
}

.knowledge-analysis p,
.suggestions p {
  line-height: 1.6;
  color: #555;
  text-align: justify;
}

.report-placeholder {
  text-align: center;
  color: #999;
  font-size: 16px;
  padding: 40px 20px;
}

/* 提示条已移除 */

/* 科目选择器样式 */
.subject-selector {
  margin-bottom: 20px;
}

.subject-selector .el-form-item {
  margin-bottom: 0;
}

/* 淡入动画 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>


