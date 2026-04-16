<template>
  <div class="course-page" :class="currentTheme">
    <!-- 风格切换器 -->
    <ThemeSwitcher @theme-change="handleThemeChange" />
    
    <div class="header">
      <!-- 顶部GIF图片覆盖在头部栏上 -->
      <!-- <div class="top-gif-container">
        <img 
          src="../../assets/images/星星_ 月亮_ 幻想_ 夜空_ 空间_爱给网_aigei_com.gif" 
          alt="顶部装饰" 
          class="top-gif"
        />
      </div> -->
    <!-- 添加返回按钮 -->
      <el-button type="primary" @click="goBack">返回</el-button> 
      <div class="header-center">
        <h1 class="course-title">{{ course.courseName || '嵌入式开发进阶' }}</h1>
      </div>
      <div class="header-right">
        <div class="course-code">课程ID：{{ course.id || '101' }}</div>
      </div>
    </div>
    <!-- 只在非简约风格下显示卡通图片 -->
    <img v-if="currentTheme !== 'minimal'" src="../../assets/images/绘制卡通画.png" alt="绘制卡通图" class="katong">
    <img v-if="currentTheme !== 'minimal'" src="../../assets/images/hua.png" alt="绘制卡通图" class="katong2">
    <div class="main-content">
      <div class="sidebar">
        <nav class="course-nav">
          <ul>
            <li
              v-for="item in navItems"
              :key="item.name"
              :class="{ active: activeNav === item.name }"
              @click="handleNavChange(item.name)"
            >
              <span class="nav-icon">
                <img :src="item.icon" alt="icon" class="nav-icon-img" />
              </span>
              <span class="nav-text">{{ item.text }}</span>
            </li>
          </ul>
        </nav>

        <div class="progress-container">
          <div class="progress-label">学习进度</div>
          <div class="progress-bar">
            <div class="progress-fill" :style="{ width: progress + '%' }"></div>
          </div>
          <div class="progress-percent">{{ progress }}%</div>
        </div>
        <el-button type="success" @click="goToStudySpace" class="k2">点击进入我的学习空间</el-button>
      </div>

      <div class="content-area">
        <el-skeleton :loading="loading" animated>
          <template #default>
           <div class="content-section">
              <div v-if="activeNav === 'knowledge-graph'" style="display: flex; gap: 20px;">
                <div style="flex: 2; height: 600px; position: relative;">  <!-- 添加position: relative -->
              <KnowledgeGraph 
                :data="knowledgeTreeData" 
                @nodeClick="handleNodeClick"
              />
              <el-button 
                class="view-detail-btn"
                type="primary" 
                size="small"
                @click="showFullscreenGraph"
              >
                查看详情
              </el-button>
              </div>
                  <!-- 全屏知识图谱弹窗 -->
                <el-dialog
              v-model="fullscreenGraphVisible"
              fullscreen
              :title="course.courseName + ' - 知识图谱'"
              :destroy-on-close="true"
              @opened="handleGraphDialogOpened"
              >
                  <div style="height: calc(100vh - 120px);">
                    <KnowledgeGraph 
                      :data="knowledgeTreeData" 
                      @nodeClick="handleNodeClick"
                      :fullscreen="true"
                    />
                  </div>
                  <template #footer>
                    <el-button @click="fullscreenGraphVisible = false">关闭</el-button>
                  </template>
                </el-dialog>
                
                <!-- 知识点详情面板 -->
              <el-dialog
              v-model="nodeDialogVisible"
              width="60%"
              :title="selectedNode?.name || '知识点详情'"
              top="10vh"
              :destroy-on-close="true"
              >
              <div v-if="selectedNode">
                <div class="mastery-progress">
                  <div class="progress-info">
                    <span>当前掌握度</span>
                    <span>{{ mastery.current }}%</span>
                  </div>
                  <el-progress 
                    :percentage="mastery.current" 
                    :stroke-width="8"
                    :show-text="false"
                  />
                  <div class="progress-history">
                    <span>历史最高: {{ mastery.highest }}%</span>
                  </div>
                  <el-button 
                    type="primary" 
                    size="small" 
                    style="margin-top: 10px;"
                    @click="improveMastery"
                  >
                    提升掌握度
                  </el-button>
                </div>
                
                <div class="knowledge-description">
                  <h4>知识点描述</h4>
                  <p>{{ selectedNode.description || '暂无描述信息' }}</p>
                </div>
                
                <div class="knowledge-resources">
                  <h4>知识点资源 ({{ nodeResources.length }})</h4>
                  <div class="resource-list">
                    <div
                      v-for="(res, index) in nodeResources"
                      :key="index"
                      class="resource-item"
                    >
                      <span class="resource-name">{{ res.name }}</span>
                      <el-tag v-if="res.required" type="danger" size="small">必学</el-tag>
                      <el-button size="small" @click="openResource(res)">查看</el-button>
                    </div>
                  </div>
                  <el-button type="text" @click="showMoreResources">查看更多</el-button>
                </div>
              </div>
              </el-dialog>
              </div>

              <div v-if="activeNav === 'chat'" class="chat-container">
                <WeChatGroupChat 
                  :courseId="route.query.id"
                  :courseName="course.courseName"
                  :currentUser="currentUser"
                  :currentUserId="store.currentUser?.id"
                />
              </div>
        
            <!-- 在content-section中替换原有的学习资源表格 -->
              <div v-if="activeNav === 'learning-resources'">
                <div class="resource-header">
                  <el-input
                    v-model="searchQuery"
                    placeholder="请输入关键字"
                    style="width: 200px; margin-right: 10px;"
                  />
                  <el-radio-group v-model="filterStatus">
                    <el-radio-button label="all">全部</el-radio-button>
                  </el-radio-group>
                </div>

                <div class="resource-list-container">
                  <div class="resource-category">
                    <h3>课件({{ filteredResources.length }})</h3>
                    <div 
                v-for="resource in filteredResources" 
                :key="resource.id"
                class="resource-item"
                @click="viewResource(resource)"
              >
                        <span class="resource-name">{{ resource.fileName }}</span>
                        <div class="resource-actions">
                          <el-button 
                            type="primary" 
                            size="small" 
                            @click.stop="download(resource.filePath)"
                          >
                            下载
                          </el-button>
                        </div>
                      </div>
                  </div>
                </div>
              </div>

              <div v-if="activeNav === 'discussions'">
                <div class="qa-panel">
                  <!-- 顶部操作栏 -->
                  <div class="qa-header">
                    <div class="qa-title">
                      <h2>💬 课程讨论区</h2>
                      <p class="qa-subtitle">与同学们一起交流学习心得</p>
                    </div>
                    <button class="ask-btn" @click="openAskPopup">
                      <span class="ask-icon">✏️</span>
                      发布问题
                    </button>
                  </div>

                  <!-- 分类标签 -->
                  <div class="qa-tabs">
                    <div 
                      class="tab-item" 
                      :class="{ active: activeTab === 'others' }"
                      @click="activeTab = 'others'"
                    >
                      <span class="tab-icon">👥</span>
                      别人的提问
                      <span class="tab-count">{{ otherQuestions.length }}</span>
                    </div>
                    <div 
                      class="tab-item" 
                      :class="{ active: activeTab === 'mine' }"
                      @click="activeTab = 'mine'"
                    >
                      <span class="tab-icon">👤</span>
                      我的提问
                      <span class="tab-count">{{ myQuestions.length }}</span>
                    </div>
                  </div>

                  <!-- 问题列表 -->
                  <div class="question-list">
                    <div
                      class="question-item"
                      v-for="(item, index) in currentQuestions.slice(0, 4)"
                      :key="index"
                    >
                      <router-link class="question-link" :to="{ name: 'QuestionADetail', params: { id: item.id }, query: { courseId: route.query.id, activeNav: activeNav } }">
                        <div class="question-header">
                          <div class="question-title">{{ item.content }}</div>
                          <div class="question-badge" v-if="String(item.userId) === String(useUserStore().currentUserId)">我的</div>
                        </div>
                        <div class="question-meta">
                          <span class="user-info">
                            <span class="user-avatar">{{ item.userName?.charAt(0) || 'U' }}</span>
                            {{ item.userName }} · {{ item.userUniversity }}
                          </span>
                          <span class="question-time">{{ formatQuestionTime(item.createTime) }}</span>
                        </div>
                        <div class="question-stats">
                          <span class="stat-item">
                            <span class="stat-icon">💬</span>
                            {{ item.answerCount || 0 }} 条回答
                          </span>
                          <span class="stat-item" v-if="item.attachments && item.attachments.length">
                            <span class="stat-icon">📎</span>
                            {{ item.attachments.length }} 个附件
                          </span>
                        </div>
                        <!-- 显示附件预览 -->
                        <div v-if="item.attachments && item.attachments.length" class="attachments-preview">
                          <div v-for="file in item.attachments.slice(0, 3)" :key="file.id" class="attachment-item">
                            <span class="file-icon">{{ getFileIconEmoji(file.fileName) }}</span>
                            <span class="file-name">{{ file.fileName }}</span>
                          </div>
                          <span v-if="item.attachments.length > 3" class="more-files">
                            还有 {{ item.attachments.length - 3 }} 个文件...
                          </span>
                        </div>
                      </router-link>
                    </div>
                    
                    <!-- 空状态 -->
                    <div v-if="currentQuestions.length === 0" class="empty-state">
                      <div class="empty-icon">🤔</div>
                      <h3>{{ activeTab === 'mine' ? '还没有发布过问题' : '暂时没有其他问题' }}</h3>
                      <p>{{ activeTab === 'mine' ? '点击上方按钮发布你的第一个问题吧！' : '快来发布第一个问题吧！' }}</p>
                    </div>
                  </div>
                  <div class="more-bar" v-if="currentQuestions.length > 4">
                    <el-button type="primary" text @click="goAllQuestions">查看更多</el-button>
                  </div>
                  <div class="popup" v-if="showPopup">
                    <div class="popup-inner">
                      <h3>话题</h3>
                      <textarea
                        v-model="newQuestion.content"
                        placeholder="写下你的问题，以问号结尾"
                      ></textarea>
                      <el-form-item label="附加文件">
                        <el-select
                          v-model="selectedResourceIds"
                          multiple
                          placeholder="请选择要附加的课程资源"
                          style="width: 100%"
                        >
                          <el-option
                            v-for="res in courseResources"
                            :key="res.id"
                            :label="res.fileName"
                            :value="res.id"
                          />
                        </el-select>
                        <div v-if="selectedResourceIds.length" style="margin-top: 10px;">
                          <h4>已选择文件：</h4>
                          <ul style="list-style: none; padding: 0;">
                            <li v-for="id in selectedResourceIds" :key="id" class="file-item">
                              <a
                                :href="getResourceById(id).filePath"
                                target="_blank"
                                class="file-link"
                              >
                                <span class="file-icon">📄</span>
                                {{ getResourceById(id).fileName }}
                              </a>
                              <el-button 
                                type="text" 
                                @click="removeSelectedResource(id)"
                                class="delete-btn"
                              >
                                删除
                              </el-button>
                            </li>
                          </ul>
                        </div>
                      </el-form-item>
                      <button class="submit-btn" @click="submitQuestion">立即发布</button>
                      <button class="close-btn" @click="showPopup = false">关闭</button>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 学习任务 -->
              <div v-if="activeNav === 'learning-tasks'" class="tasks-container">
                <div class="tasks-header">
                  <div class="header-left">
                    <h2 class="page-title">🧭 学习任务</h2>
                    <p class="page-subtitle">按优先级和截止时间高效管理你的学习计划</p>
                  </div>
                  <div class="header-right">
                    <el-button type="primary" @click="openTaskCreator" class="action-btn">
                      <span class="btn-icon">➕</span> 新建任务
                    </el-button>
                  </div>
                </div>

                <div class="task-filter-bar">
                  <el-input v-model="taskFilterQuery" placeholder="搜索任务标题/标签" clearable style="width: 220px" />
                  <el-select v-model="taskPriority" placeholder="优先级" style="width: 140px">
                    <el-option label="全部优先级" value="all" />
                    <el-option label="高" value="high" />
                    <el-option label="中" value="medium" />
                    <el-option label="低" value="low" />
                  </el-select>
                  <el-date-picker
                    v-model="taskDateRange"
                    type="daterange"
                    range-separator="至"
                    start-placeholder="开始日期"
                    end-placeholder="结束日期"
                    style="width: 280px"
                  />
                  <el-button @click="resetTaskFilters">重置</el-button>
                </div>

                <div class="task-stats">
                  <div class="stat-card">
                    <div class="stat-number">{{ taskStats.total }}</div>
                    <div class="stat-label">总任务</div>
                  </div>
                  <div class="stat-card warning">
                    <div class="stat-number">{{ taskStats.todo }}</div>
                    <div class="stat-label">待学习</div>
                  </div>
                  <div class="stat-card info">
                    <div class="stat-number">{{ taskStats.inProgress }}</div>
                    <div class="stat-label">学习中</div>
                  </div>
                  <div class="stat-card success">
                    <div class="stat-number">{{ taskStats.done }}</div>
                    <div class="stat-label">已完成</div>
                  </div>
                </div>

                <div class="kanban" v-loading="taskLoading">
                  <div class="kanban-column">
                    <div class="kanban-title">⏳ 待学习</div>
                    <div class="kanban-list">
                      <div
                        v-for="task in tasksByStatus.todo"
                        :key="task.id"
                        class="task-card"
                        @click="openTask(task)"
                      >
                        <div class="task-header">
                          <div class="task-title">
                            <span class="task-icon">{{ taskTypeIcon(task.type) }}</span>
                            {{ task.title }}
                          </div>
                          <el-tag :type="getPriorityTagType(task.priority)" size="small">{{ priorityText(task.priority) }}</el-tag>
                        </div>
                        <div class="task-meta">
                          <span class="due" :class="{ danger: dueDaysLeft(task) <= 1 }">截止：{{ formatDueLabel(task) }}</span>
                          <span class="tags" v-if="task.tags && task.tags.length">#{{ task.tags.join(' #') }}</span>
                        </div>
                        <el-progress :percentage="task.progress" :stroke-width="6" :show-text="false" />
                        <div class="task-actions">
                          <el-button size="small" type="primary" @click.stop="startOrContinueTask(task)">开始</el-button>
                          <el-button size="small" @click.stop="moveTask(task, 'in_progress')">移至学习中</el-button>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="kanban-column">
                    <div class="kanban-title">📚 学习中</div>
                    <div class="kanban-list">
                      <div
                        v-for="task in tasksByStatus.in_progress"
                        :key="task.id"
                        class="task-card"
                        @click="openTask(task)"
                      >
                        <div class="task-header">
                          <div class="task-title">
                            <span class="task-icon">{{ taskTypeIcon(task.type) }}</span>
                            {{ task.title }}
                          </div>
                          <el-tag :type="getPriorityTagType(task.priority)" size="small">{{ priorityText(task.priority) }}</el-tag>
                        </div>
                        <div class="task-meta">
                          <span class="due" :class="{ danger: dueDaysLeft(task) <= 1 }">截止：{{ formatDueLabel(task) }}</span>
                          <span class="tags" v-if="task.tags && task.tags.length">#{{ task.tags.join(' #') }}</span>
                        </div>
                        <el-progress :percentage="task.progress" :stroke-width="6" />
                        <div class="task-actions">
                          <el-button size="small" type="primary" @click.stop="startOrContinueTask(task)">继续</el-button>
                          <el-button size="small" type="success" @click.stop="markTaskDone(task)">完成</el-button>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="kanban-column">
                    <div class="kanban-title">✅ 已完成</div>
                    <div class="kanban-list">
                      <div
                        v-for="task in tasksByStatus.done"
                        :key="task.id"
                        class="task-card done"
                        @click="openTask(task)"
                      >
                        <div class="task-header">
                          <div class="task-title">
                            <span class="task-icon">{{ taskTypeIcon(task.type) }}</span>
                            {{ task.title }}
                          </div>
                          <el-tag type="success" size="small">已完成</el-tag>
                        </div>
                        <div class="task-meta">
                          <span class="due">完成于：{{ formatDate(task.completedAt) || '刚刚' }}</span>
                          <span class="tags" v-if="task.tags && task.tags.length">#{{ task.tags.join(' #') }}</span>
                        </div>
                        <el-progress :percentage="100" :stroke-width="6" :show-text="false" />
                        <div class="task-actions">
                          <el-button size="small" @click.stop="moveTask(task, 'in_progress')">移回学习中</el-button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <el-drawer v-model="taskDrawerVisible" :with-header="true" size="40%" :title="selectedTask?.title || '任务详情'">
                  <div v-if="selectedTask" class="task-detail">
                    <div class="detail-row">
                      <span>优先级：</span>
                      <el-tag :type="getPriorityTagType(selectedTask.priority)">{{ priorityText(selectedTask.priority) }}</el-tag>
                    </div>
                    <div class="detail-row">
                      <span>截止时间：</span>
                      <span>{{ formatDueLabel(selectedTask) }}</span>
                    </div>
                    <div class="detail-row" v-if="selectedTask.tags && selectedTask.tags.length">
                      <span>标签：</span>
                      <div>
                        <el-tag v-for="(t, i) in selectedTask.tags" :key="i" size="small" style="margin-right: 6px">#{{ t }}</el-tag>
                      </div>
                    </div>
                    <div class="detail-desc">
                      <h4>说明</h4>
                      <p>{{ selectedTask.description || '暂无描述' }}</p>
                    </div>
                    <div class="detail-progress">
                      <h4>进度</h4>
                      <el-progress :percentage="selectedTask.progress" />
                    </div>
                    <div class="detail-actions">
                      <el-button type="primary" @click="startOrContinueTask(selectedTask)">开始/继续</el-button>
                      <el-button type="success" @click="markTaskDone(selectedTask)" :disabled="selectedTask.status === 'done'">标记完成</el-button>
                    </div>
                  </div>
                </el-drawer>
              </div>

              <!-- 小组教学 -->
              <div v-if="activeNav === 'group-teaching'" class="groups-container">
                <div class="groups-header">
                  <div class="header-left">
                    <h2 class="page-title">👥 小组教学</h2>
                    <p class="page-subtitle">组队协作学习，实时推进小组进度</p>
                  </div>
                  <div class="header-right">
                    <el-button type="primary" @click="openGroupCreator" class="action-btn">
                      <span class="btn-icon">➕</span> 新建小组
                    </el-button>
                  </div>
                </div>

                <div class="group-filter-bar">
                  <el-input v-model="groupFilterQuery" placeholder="搜索小组名称/标签" clearable style="width: 220px" />
                  <el-select v-model="groupView" placeholder="视图" style="width: 160px">
                    <el-option label="全部小组" value="all" />
                    <el-option label="我参与的" value="mine" />
                  </el-select>
                  <el-button @click="resetGroupFilters">重置</el-button>
                </div>

                <div class="group-stats">
                  <div class="stat-card">
                    <div class="stat-number">{{ groupStats.total }}</div>
                    <div class="stat-label">小组总数</div>
                  </div>
                  <div class="stat-card info">
                    <div class="stat-number">{{ groupStats.mine }}</div>
                    <div class="stat-label">我参与</div>
                  </div>
                  <div class="stat-card success">
                    <div class="stat-number">{{ groupStats.avgMembers }}</div>
                    <div class="stat-label">平均成员数</div>
                  </div>
                </div>

                <div class="group-grid" v-loading="groupLoading">
                  <div 
                    v-for="g in filteredGroups" 
                    :key="g.id" 
                    class="group-card"
                    @click="openGroup(g)"
                  >
                    <div class="group-card-header">
                      <div class="group-title">
                        <span class="group-icon">👤</span>
                        {{ g.name }}
                      </div>
                      <div class="group-tags" v-if="g.tags && g.tags.length">
                        <el-tag v-for="(t,i) in g.tags" :key="i" size="small" style="margin-left: 6px">#{{ t }}</el-tag>
                      </div>
                    </div>
                    <div class="group-meta">
                      <div class="meta-item">
                        <span class="meta-label">组长</span>
                        <span class="meta-value">{{ g.leader }}</span>
                      </div>
                      <div class="meta-item">
                        <span class="meta-label">成员</span>
                        <span class="meta-value">{{ g.members?.length || 0 }}</span>
                      </div>
                      <div class="meta-item">
                        <span class="meta-label">下次会议</span>
                        <span class="meta-value">{{ formatMeetingLabel(g) }}</span>
                      </div>
                    </div>
                    <el-progress :percentage="g.progress || 0" :stroke-width="8" />
                    <div class="group-actions">
                      <el-button size="small" type="primary" @click.stop="enterGroup(g)">进入小组</el-button>
                      <el-button size="small" @click.stop="openGroup(g)">详情</el-button>
                    </div>
                  </div>
                </div>

                <!-- 小组详情抽屉 -->
                <el-drawer v-model="groupDrawerVisible" :with-header="true" size="40%" :title="selectedGroup?.name || '小组详情'">
                  <div v-if="selectedGroup" class="group-detail">
                    <div class="detail-row"><span>组长：</span><strong>{{ selectedGroup.leader }}</strong></div>
                    <div class="detail-row">
                      <span>成员：</span>
                      <div class="member-chips">
                        <el-tag v-for="(m,i) in selectedGroup.members" :key="i" type="info" size="small" style="margin: 4px">{{ m }}</el-tag>
                      </div>
                    </div>
                    <div class="detail-row"><span>下次会议：</span>{{ formatMeetingLabel(selectedGroup) }}</div>
                    <div class="detail-row" v-if="selectedGroup.tags && selectedGroup.tags.length">
                      <span>标签：</span>
                      <div>
                        <el-tag v-for="(t,i) in selectedGroup.tags" :key="i" size="small" style="margin-right: 6px">#{{ t }}</el-tag>
                      </div>
                    </div>
                    <div class="detail-desc">
                      <h4>简介</h4>
                      <p>{{ selectedGroup.description || '暂无描述' }}</p>
                    </div>
                    <div class="detail-progress">
                      <h4>进度</h4>
                      <el-progress :percentage="selectedGroup.progress || 0" />
                    </div>
                    <div class="detail-actions">
                      <el-button type="primary" @click="scheduleMeeting(selectedGroup)">发起会议</el-button>
                      <el-button @click="goToGroupChat(selectedGroup)">打开群聊</el-button>
                    </div>
                  </div>
                </el-drawer>

                <!-- 新建小组对话框 -->
                <el-dialog v-model="createGroupVisible" title="新建小组" width="420px">
                  <el-form label-width="80px">
                    <el-form-item label="小组名称">
                      <el-input v-model="createGroupForm.name" placeholder="输入小组名称" />
                    </el-form-item>
                    <el-form-item label="标签">
                      <el-select v-model="createGroupForm.tags" multiple filterable allow-create default-first-option placeholder="输入或选择标签">
                        <el-option v-for="opt in ['报告','实践','讨论','复习']" :key="opt" :label="opt" :value="opt" />
                      </el-select>
                    </el-form-item>
                  </el-form>
                  <template #footer>
                    <el-button @click="createGroupVisible = false">取消</el-button>
                    <el-button type="primary" @click="createGroup">创建</el-button>
                  </template>
                </el-dialog>
              </div>

              <!-- 作业考试 -->
              <div v-if="activeNav === 'assignments'" class="assignments-container">
                <!-- 头部统计 -->
                <div class="assignments-header">
                  <div class="header-left">
                    <h2 class="page-title">📋 作业考试</h2>
                    <p class="page-subtitle">管理你的课程作业和考试</p>
                  </div>
                  <div class="header-stats">
                    <div class="stat-item">
                      <div class="stat-number">{{ incompleteAssignments.length }}</div>
                      <div class="stat-label">待完成</div>
                    </div>
                    <div class="stat-item">
                      <div class="stat-number">{{ completedAssignments.length }}</div>
                      <div class="stat-label">已完成</div>
                    </div>
                  </div>
                </div>

                <!-- 筛选工具栏 -->
                <div class="assignment-toolbar">
                  <div class="toolbar-left">
                    <el-radio-group v-model="assignmentFilterTab" size="large" class="filter-tabs">
                      <el-radio-button label="incomplete">
                        <span class="tab-icon">⏳</span>
                        未完成
                      </el-radio-button>
                      <el-radio-button label="completed">
                        <span class="tab-icon">✅</span>
                        已完成
                      </el-radio-button>
                    </el-radio-group>
                  </div>
                  <div class="toolbar-right">
                    <el-date-picker
                      v-model="assignmentDateRange"
                      type="daterange"
                      range-separator="至"
                      start-placeholder="开始日期"
                      end-placeholder="结束日期"
                      size="default"
                      class="date-filter"
                    />
                    <el-button size="default" type="default" @click="resetAssignmentFilters" class="reset-btn">
                      <span class="btn-icon">🔄</span>
                      重置
                    </el-button>
                  </div>
                </div>

                <!-- 作业列表 -->
                <div class="assignment-list">
                  <el-empty 
                    v-if="pagedAssignments.length === 0" 
                    :description="assignmentFilterTab==='completed' ? '暂无已完成作业' : '暂无未完成作业'"
                    class="empty-state"
                  />

                  <div class="assignment-grid">
                    <div
                      v-for="item in pagedAssignments"
                      :key="item.assignmentId"
                      class="assignment-card"
                      :class="[assignmentFilterTab==='completed' ? 'done' : 'todo', item.isExam ? 'exam' : 'assignment']"
                    >
                      <div class="card-header">
                        <div class="card-title">
                          <span class="title-icon">{{ item.isExam ? '🧪' : (assignmentFilterTab==='completed' ? '📝' : '📋') }}</span>
                          {{ item.title }}
                        </div>
                        <div class="card-status">
                          <el-tag :type="item.isExam ? 'danger' : 'info'" effect="light" size="small" class="kind-tag">
                            {{ item.isExam ? '考试' : '作业' }}
                          </el-tag>
                          <el-tag :type="assignmentFilterTab==='completed' ? 'success' : 'warning'" effect="light" size="small">
                            {{ assignmentFilterTab==='completed' ? '已完成' : '未完成' }}
                          </el-tag>
                          <!-- 显示截止状态 -->
                          <el-tag v-if="!item.submitted && isOverdue(item)" 
                            type="danger" effect="light" size="small" class="overdue-tag">
                            已截止
                          </el-tag>
                          <el-tag v-if="assignmentFilterTab==='completed' && item.score !== null && item.score !== undefined" 
                            type="info" effect="light" size="small" class="score-tag">
                            {{ item.score }}分
                          </el-tag>
                        </div>
                      </div>
                      
                      <div class="card-content">
                        <div class="time-info">
                          <span class="time-label">{{ assignmentFilterTab==='completed' ? '提交时间' : '截止时间' }}：</span>
                          <span class="time-value">{{ safeFormatDate(assignmentFilterTab==='completed' ? item.submittedAt : item.dueDate) }}</span>
                        </div>
                        <div class="description" v-if="item.description">
                          {{ item.description }}
                        </div>
                      </div>
                      
                      <div class="card-actions">
                        <el-button 
                          v-if="assignmentFilterTab==='completed'" 
                          type="primary" 
                          @click="goToFinishHomeworkWithMeta(item)"
                          class="action-btn"
                        >
                          <span class="btn-icon">👁️</span>
                          查看详情
                        </el-button>
                        <el-button 
                          v-else-if="!isOverdue(item)"
                          type="primary" 
                          @click="goToHomework(item.assignmentId)"
                          class="action-btn"
                        >
                          <span class="btn-icon">✏️</span>
                          去完成
                        </el-button>
                        <el-button 
                          v-else
                          type="info" 
                          disabled
                          class="action-btn"
                        >
                          <span class="btn-icon">⏰</span>
                          已截止
                        </el-button>
                      </div>
                    </div>
                  </div>

                  <!-- 分页器 -->
                  <div v-if="pagedTotal > pageSize" class="assignment-pagination">
                    <el-pagination
                      :current-page="currentPage"
                      @current-change="(p)=> currentPage = p"
                      :page-size="pageSize"
                      layout="prev, pager, next, jumper"
                      :total="pagedTotal"
                      background
                      class="pagination-custom"
                    />
                  </div>
                </div>
              </div>
            </div>

            
            <div class="info-sidebar">
              <div class="instructor-card">
                <div class="instructor-avatar">
                  <img v-if="instructor?.avatar" :src="instructor.avatar" alt="教师头像" style="width:100%;height:100%;border-radius:50%;object-fit:cover;" />
                  <template v-else>
                    {{ (instructor?.name || '教师')?.charAt(0) }}
                  </template>
                </div>
                <div class="instructor-details">
                  <strong>{{ instructor?.name || '教师' }}</strong><br />
                  <small>{{ instructor?.title || '教师' }}</small>
                </div>
              </div>

              <div class="course-info-card">
                <div class="course-info-header">
                  <div class="course-info-icon">📚</div>
                  <h4>课程信息</h4>
                </div>
                
                <div class="course-cover" v-if="course.courseImage">
                  <img
                    :src="course.courseImage.trim()"
                    alt="课程封面"
                    class="course-image"
                  />
                  <div class="course-cover-overlay">
                    <span class="course-status">进行中</span>
                  </div>
                </div>
                
                <div class="course-info-list">
                  <div class="info-item">
                    <div class="info-icon">📅</div>
                    <div class="info-content">
                      <span class="info-label">开课时间</span>
                      <span class="info-value">{{ formatDate(course.createdAt) }}</span>
                    </div>
                  </div>
                  
                  <div class="info-item">
                    <div class="info-icon">🆔</div>
                    <div class="info-content">
                      <span class="info-label">课程ID</span>
                      <span class="info-value">{{ course.id }}</span>
                    </div>
                  </div>
                  
                  <div class="info-item">
                    <div class="info-icon">🎯</div>
                    <div class="info-content">
                      <span class="info-label">教学目标</span>
                      <span class="info-value">{{ course.teachingGoal || '暂无' }}</span>
                    </div>
                  </div>
                  
                  <div class="info-item">
                    <div class="info-icon">📋</div>
                    <div class="info-content">
                      <span class="info-label">教学原则</span>
                      <span class="info-value">{{ course.teachingPrinciple || '暂无' }}</span>
                    </div>
                  </div>
                  
                  <div class="info-item">
                    <div class="info-icon">📖</div>
                    <div class="info-content">
                      <span class="info-label">课程背景</span>
                      <span class="info-value">{{ course.courseBackground || '暂无' }}</span>
                    </div>
                  </div>
                </div>
                
                <div class="course-stats">
                  <div class="stat-card">
                    <div class="stat-number">{{ chapterCount }}</div>
                    <div class="stat-label">章节</div>
                  </div>
                  <div class="stat-card">
                    <div class="stat-number">{{ studentCount }}</div>
                    <div class="stat-label">学生</div>
                  </div>
                  <div class="stat-card">
                    <div class="stat-number">4.8</div>
                    <div class="stat-label">评分</div>
                  </div>
                </div>
              </div>
            </div>
          </template>
        </el-skeleton>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted,computed, watch } from 'vue'
import ResourcePreview from '../ResoursePreview/ResourcePreview.vue'
import { useRoute } from 'vue-router'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user.js'
import axios from 'axios'
import KnowledgeGraph from '../knowlwdge_graph/KnowledgeGraph.vue'
import WeChatGroupChat from './components/WeChatGroupChat.vue'
import ThemeSwitcher from '@/components/ThemeSwitcher.vue'
import { ElMessage } from 'element-plus' 
import IconLearningResources from '@/assets/images/大单元学历案.png'
import IconLearningTasks from '@/assets/images/学校 (1).png'
import IconDiscussions from '@/assets/images/观察记录.png'
import IconAssignments from '@/assets/images/考试备课.png'
import IconGroupTeaching from '@/assets/images/学习尺笔.png'
import IconKnowledgeGraph from '@/assets/images/最强大脑.png'
import IconChat from '@/assets/images/科技科学.png'

// 注册组件
const components = {
  ThemeSwitcher
}
const route = useRoute()
const loading = ref(true)
// 从localStorage恢复上次选中的导航状态，如果没有则使用URL参数或默认值
const getInitialActiveNav = () => {
  const courseId = route.query.id || route.params.id
  const savedNav = localStorage.getItem(`course_nav_${courseId}`)
  return savedNav || route.query.activeNav || 'learning-resources'
}

const activeNav = ref(getInitialActiveNav())

// 处理导航切换并保存状态
const handleNavChange = (navName) => {
  activeNav.value = navName
  const courseId = route.query.id || route.params.id
  localStorage.setItem(`course_nav_${courseId}`, navName)
}

const chapterCount = ref(0)
const studentCount = ref(0)
const progress = ref(0)
const course = ref({})
const instructor = ref({ name: '', title: '教师', avatar: '' })
const resources = ref([])
const store = useUserStore()

// 主题管理
const currentTheme = ref('minimal')

// 主题切换处理函数
const handleThemeChange = (theme) => {
  currentTheme.value = theme
  ElMessage.success(`已切换到${getThemeName(theme)}风格`)
}

// 获取主题名称
const getThemeName = (theme) => {
  const themeNames = {
    cartoon: '卡通风',
    minimal: '简约风'
  }
  return themeNames[theme] || '简约风'
}
const currentUser = (store.currentUser?.realName || store.currentUser?.username || '匿名用户')
const activeTab = ref('others') // 当前选中的标签页
const previewUrl = ref('')
const previewVisible = ref(false)
const knowledgeTreeData = ref({    
    "id": 101,
    "name": "嵌入式开发进阶",
    "children": [
        {
            "id": 1,
            "name": "嵌入式系统概述",
            "children": [
                {
                    "id": 1,
                    "name": "嵌入式系统定义",
                    "children": null
                },
                {
                    "id": 2,
                    "name": "嵌入式系统分类",
                    "children": null
                }
            ]
        },
        {
            "id": 2,
            "name": "嵌入式处理器架构",
            "children": [
                {
                    "id": 3,
                    "name": "处理器架构类型",
                    "children": null
                },
                {
                    "id": 4,
                    "name": "存储器结构",
                    "children": null
                }
            ]
        },
        {
            "id": 3,
            "name": "嵌入式软件开发",
            "children": [
                {
                    "id": 5,
                    "name": "嵌入式操作系统",
                    "children": null
                },
                {
                    "id": 6,
                    "name": "交叉编译工具链",
                    "children": null
                },
                {
                    "id": 7,
                    "name": "调试与仿真",
                    "children": null
                }
            ]
        },
        {
            "id": 4,
            "name": "实时操作系统",
            "children": [
                {
                    "id": 8,
                    "name": "实时操作系统内核",
                    "children": null
                },
                {
                    "id": 9,
                    "name": "任务调度",
                    "children": null
                },
                {
                    "id": 10,
                    "name": "中断管理",
                    "children": null
                }
            ]
        },
        {
            "id": 5,
            "name": "嵌入式系统通信",
            "children": [
                {
                    "id": 11,
                    "name": "串口通信",
                    "children": null
                },
                {
                    "id": 12,
                    "name": "总线通信",
                    "children": null
                },
                {
                    "id": 13,
                    "name": "无线通信基础",
                    "children": null
                }
            ]
        },
        {
            "id": 6,
            "name": "嵌入式系统调试与测试",
            "children": [
                {
                    "id": 14,
                    "name": "硬件调试工具",
                    "children": null
                },
                {
                    "id": 15,
                    "name": "软件调试技术",
                    "children": null
                },
                {
                    "id": 16,
                    "name": "测试方法",
                    "children": null
                }
            ]
        }
    ]}) // 这是后端返回的课程 → 章节 → 知识点树

const questions = ref([])

const nodeDialogVisible = ref(false)

const router = useRouter()  // 初始化路由实例
const selectedNode = ref(null)
const expandPanel = ref(true)
const mastery = ref({
  current: 0,
  highest: 0
})
const nodeResources = ref([])

// 添加全屏状态
const fullscreenGraphVisible = ref(false)
const knowledgeGraph = ref(null)


const searchQuery = ref('')
const filterStatus = ref('all')
const previewResource = ref(null)

const sourcePreview = null
const showPopup = ref(false)
const newQuestion = ref({ content: '' })
const courseResources = ref([]) // 课程资源列表
const selectedResourceIds = ref([]) // 选中的资源id

// ======= 学习任务状态 =======
const taskLoading = ref(false)
const tasks = ref([])
const taskFilterQuery = ref('')
const taskPriority = ref('all') // all | high | medium | low
const taskDateRange = ref(null) // [start, end]
const taskDrawerVisible = ref(false)
const selectedTask = ref(null)

function normalizeTaskList(list) {
  if (!Array.isArray(list)) return []
  return list.map((t, idx) => ({
    id: t.id ?? idx + 1,
    title: t.title ?? '未命名任务',
    type: t.type ?? 'reading',
    priority: t.priority ?? 'medium',
    status: t.status ?? 'todo',
    dueAt: t.dueAt ?? t.due_date ?? null,
    tags: Array.isArray(t.tags) ? t.tags : [],
    progress: typeof t.progress === 'number' ? t.progress : (t.status === 'done' ? 100 : 0),
    description: t.description ?? '' ,
    completedAt: t.completedAt ?? null
  }))
}

const mockTasks = () => ([
  { id: 1, title: '阅读第1章：计算机网络概述', type: 'reading', priority: 'high', status: 'todo', dueAt: new Date(Date.now() + 86400000).toISOString(), tags: ['阅读','基础'], progress: 0 },
  { id: 2, title: '观看课程视频：TCP/IP模型', type: 'video', priority: 'medium', status: 'in_progress', dueAt: new Date(Date.now() + 2*86400000).toISOString(), tags: ['视频'], progress: 40 },
  { id: 3, title: '小测验：网络层与路由', type: 'quiz', priority: 'high', status: 'todo', dueAt: new Date(Date.now() + 3*86400000).toISOString(), tags: ['测验'], progress: 0 },
  { id: 4, title: '实践：抓包分析HTTP请求', type: 'practice', priority: 'high', status: 'in_progress', dueAt: new Date(Date.now() + 4*86400000).toISOString(), tags: ['实践','Wireshark'], progress: 60 },
  { id: 5, title: '复习：数据链路层', type: 'reading', priority: 'low', status: 'todo', dueAt: new Date(Date.now() + 5*86400000).toISOString(), tags: ['复习'], progress: 0 },
  { id: 6, title: '完成作业：第2章课后题', type: 'quiz', priority: 'medium', status: 'done', dueAt: new Date(Date.now() - 86400000).toISOString(), tags: ['作业'], progress: 100, completedAt: new Date().toISOString() }
])

const loadTasks = async () => {
  taskLoading.value = true
  try {
    const courseId = route.query.id
    const studentId = useUserStore().currentUserId
    const res = await axios.get('/api/xiaozhi/student/tasks', { params: { courseId, studentId } })
    if (res.data && res.data.code === 200 && Array.isArray(res.data.data)) {
      tasks.value = normalizeTaskList(res.data.data)
    } else {
      tasks.value = mockTasks()
    }
  } catch (e) {
    tasks.value = mockTasks()
  } finally {
    taskLoading.value = false
  }
}

const taskPriorityOrder = { high: 0, medium: 1, low: 2 }

const filteredTasks = computed(() => {
  const q = taskFilterQuery.value.trim().toLowerCase()
  const inRange = (dueAt) => {
    if (!taskDateRange.value || taskDateRange.value.length !== 2) return true
    const [start, end] = taskDateRange.value
    const d = parseFlexibleDate(dueAt)
    if (!d) return true
    return d.getTime() >= new Date(start).getTime() && d.getTime() <= new Date(end).getTime()
  }
  return tasks.value.filter(t => {
    const matchQ = !q || t.title.toLowerCase().includes(q) || (t.tags || []).some(tag => tag.toLowerCase().includes(q))
    const matchP = taskPriority.value === 'all' || t.priority === taskPriority.value
    const matchD = inRange(t.dueAt)
    return matchQ && matchP && matchD
  })
})

const tasksByStatus = computed(() => {
  const sorted = [...filteredTasks.value].sort((a, b) => {
    const pa = taskPriorityOrder[a.priority] ?? 9
    const pb = taskPriorityOrder[b.priority] ?? 9
    if (pa !== pb) return pa - pb
    const da = parseFlexibleDate(a.dueAt)?.getTime() ?? Infinity
    const db = parseFlexibleDate(b.dueAt)?.getTime() ?? Infinity
    return da - db
  })
  return {
    todo: sorted.filter(t => t.status === 'todo'),
    in_progress: sorted.filter(t => t.status === 'in_progress'),
    done: sorted.filter(t => t.status === 'done')
  }
})

const taskStats = computed(() => ({
  total: filteredTasks.value.length,
  todo: filteredTasks.value.filter(t => t.status === 'todo').length,
  inProgress: filteredTasks.value.filter(t => t.status === 'in_progress').length,
  done: filteredTasks.value.filter(t => t.status === 'done').length
}))

function resetTaskFilters() {
  taskFilterQuery.value = ''
  taskPriority.value = 'all'
  taskDateRange.value = null
}

function openTaskCreator() {
  ElMessage.info('任务创建功能开发中...')
}

function openTask(task) {
  selectedTask.value = task
  taskDrawerVisible.value = true
}

function taskTypeIcon(type) {
  switch (type) {
    case 'reading': return '📖'
    case 'video': return '🎬'
    case 'quiz': return '📝'
    case 'practice': return '💡'
    default: return '📌'
  }
}

function getPriorityTagType(priority) {
  if (priority === 'high') return 'danger'
  if (priority === 'medium') return 'warning'
  return 'info'
}

function priorityText(priority) {
  if (priority === 'high') return '高'
  if (priority === 'medium') return '中'
  if (priority === 'low') return '低'
  return '-'
}

function dueDaysLeft(task) {
  const d = parseFlexibleDate(task.dueAt)
  if (!d) return Infinity
  const ms = d.getTime() - Date.now()
  return Math.ceil(ms / (1000 * 60 * 60 * 24))
}

function formatDueLabel(task) {
  const d = parseFlexibleDate(task.dueAt)
  if (!d) return '未设置'
  const days = dueDaysLeft(task)
  if (days < 0) return `已过期 ${Math.abs(days)} 天`
  if (days === 0) return '今天'
  if (days === 1) return '明天'
  return d.toLocaleString('zh-CN', { month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' })
}

function startOrContinueTask(task) {
  ElMessage.success(`已开始：${task.title}`)
  if (task.status === 'todo') task.status = 'in_progress'
  task.progress = Math.min(100, (task.progress || 0) + 10)
}

function moveTask(task, status) {
  if (!['todo', 'in_progress', 'done'].includes(status)) return
  task.status = status
  if (status !== 'done' && task.progress === 100) task.progress = 90
}

function markTaskDone(task) {
  task.status = 'done'
  task.progress = 100
  task.completedAt = new Date().toISOString()
  ElMessage.success('已完成')
}

// ======= 小组教学状态与方法 =======
const groupLoading = ref(false)
const groups = ref([])
const groupFilterQuery = ref('')
const groupView = ref('all') // all | mine
const groupDrawerVisible = ref(false)
const selectedGroup = ref(null)
const createGroupVisible = ref(false)
const createGroupForm = ref({ name: '', tags: [] })

const mockGroups = () => ([
  { id: 1, name: 'TCP/IP研究组', leader: '张政', members: ['张政','李雷','韩梅梅'], tags: ['报告','讨论'], nextMeetingAt: new Date(Date.now()+36e5*26).toISOString(), progress: 45, description: '围绕TCP/IP模型展开研讨与案例分析' },
  { id: 2, name: '网络安全实践队', leader: '王强', members: ['王强','小李','小王','小赵'], tags: ['实践'], nextMeetingAt: new Date(Date.now()+36e5*72).toISOString(), progress: 70, description: '渗透测试与安全基线检查实操' },
  { id: 3, name: '期末复习突击队', leader: '刘一', members: ['刘一','陈二','张三'], tags: ['复习'], nextMeetingAt: new Date(Date.now()+36e5*12).toISOString(), progress: 20, description: '按知识点分工复盘错题' }
])

const loadGroups = async () => {
  groupLoading.value = true
  try {
    const courseId = route.query.id
    const res = await axios.get('/api/xiaozhi/groups', { params: { courseId } })
    if (res.data && res.data.code === 200 && Array.isArray(res.data.data)) {
      groups.value = res.data.data
    } else {
      groups.value = mockGroups()
    }
  } catch (e) {
    groups.value = mockGroups()
  } finally {
    groupLoading.value = false
  }
}

const myName = currentUser

const filteredGroups = computed(() => {
  const q = groupFilterQuery.value.trim().toLowerCase()
  return groups.value.filter(g => {
    const inMine = groupView.value === 'all' || (g.members || []).includes(myName)
    const matchQ = !q || g.name.toLowerCase().includes(q) || (g.tags || []).some(t => t.toLowerCase().includes(q))
    return inMine && matchQ
  })
})

const groupStats = computed(() => {
  const total = filteredGroups.value.length
  const mine = filteredGroups.value.filter(g => (g.members || []).includes(myName)).length
  const avgMembers = total === 0 ? 0 : Math.round(filteredGroups.value.reduce((s, g) => s + (g.members?.length || 0), 0) / total)
  return { total, mine, avgMembers }
})

function openGroup(group) {
  selectedGroup.value = group
  groupDrawerVisible.value = true
}

function openGroupCreator() {
  createGroupVisible.value = true
}

function createGroup() {
  const name = createGroupForm.value.name.trim()
  if (!name) return ElMessage.warning('请输入小组名称')
  groups.value.unshift({
    id: Math.max(0, ...groups.value.map(g => g.id || 0)) + 1,
    name,
    leader: myName,
    members: [myName],
    tags: createGroupForm.value.tags || [],
    nextMeetingAt: null,
    progress: 0,
    description: ''
  })
  createGroupForm.value = { name: '', tags: [] }
  createGroupVisible.value = false
  ElMessage.success('小组创建成功')
}

function formatMeetingLabel(group) {
  const d = parseFlexibleDate(group.nextMeetingAt)
  if (!d) return '未安排'
  return d.toLocaleString('zh-CN', { month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' })
}

function enterGroup(group) {
  ElMessage.info(`进入小组：${group.name}`)
}

function scheduleMeeting(group) {
  ElMessage.success('会议功能开发中...')
}

function goToGroupChat(group) {
  ElMessage.success('已打开群聊（示例）')
}

function resetGroupFilters() {
  groupFilterQuery.value = ''
  groupView.value = 'all'
}

// 获取课程资源
const fetchCourseResources = async () => {
  const courseId = route.query.id
  try {
    const res = await axios.get('/api/xiaozhi/teacher/resources', {
      params: { courseId }
    })
    if (res.data.code === 200) {
      courseResources.value = res.data.data
    }
  } catch (e) {
    console.error('获取课程资源失败', e)
  }
}

// 根据id获取资源对象
const getResourceById = (id) => {
  return courseResources.value.find(r => r.id === id) || {}
}

// 打开提问弹窗
const openAskPopup = () => {
  showPopup.value = true
  fetchCourseResources()
}

const goToStudySpace = () => {
  const courseId = route.query.id;
  router.push({
    path: '/study_space',
    query: { courseId: courseId }
  });
};



const viewResource = (resource) => {
  router.push({
    name: 'resource',
    params: { id: resource.id },
    query: { courseId: route.query.id } // 从当前路由获取courseId
  });
};

// 获取问题数据的异步函数
const fetchQuestions = async () => {
  try {
    const courseId = route.query.id
    const response = await axios.get('/api/questions', {
      params: { courseId }
    })
    if (response.data.code === 200) {
      questions.value = response.data.data
    }
  } catch (error) {
    console.error('获取问题列表失败:', error)
  }
}

// 删除选中的资源
const removeSelectedResource = (id) => {
  const index = selectedResourceIds.value.indexOf(id)
  if (index > -1) {
    selectedResourceIds.value.splice(index, 1)
  }
}

const submitQuestion = async () => {
  if (newQuestion.value.content.trim()) {
    try {
      const courseId = route.query.id
      const selectedResources = selectedResourceIds.value.map(id => getResourceById(id))
      
      const requestData = {
        courseId: parseInt(courseId),
        userId: useUserStore().currentUserId,
        content: newQuestion.value.content,
        attachmentUrls: selectedResources.map(res => res.filePath || ''),
        attachmentNames: selectedResources.map(res => res.fileName || '')
      }
      
      const response = await axios.post('/api/questions', requestData)
      if (response.data.code === 200) {
        // 重新获取问题列表
        await fetchQuestions()
        newQuestion.value.content = ''
        selectedResourceIds.value = []
        showPopup.value = false
        ElMessage.success('问题发布成功')
      } else {
        ElMessage.error(response.data.message || '问题发布失败')
      }
    } catch (error) {
      console.error('发布问题失败:', error)
      ElMessage.error('问题发布失败')
    }
  }
}

// 计算过滤后的资源
const filteredResources = computed(() => {
  return resources.value.filter(resource => {
    // 搜索过滤
    const matchesSearch = resource.fileName.toLowerCase().includes(searchQuery.value.toLowerCase())
    
    return matchesSearch
  })
})

// 计算我的问题和其他人的问题
const myQuestions = computed(() => {
  const uid = useUserStore().currentUserId
  return questions.value.filter(q => String(q.userId) === String(uid))
})

const otherQuestions = computed(() => {
  const uid = useUserStore().currentUserId
  return questions.value.filter(q => String(q.userId) !== String(uid))
})

// 计算当前显示的问题列表
const currentQuestions = computed(() => {
  return activeTab.value === 'mine' ? myQuestions.value : otherQuestions.value
})

function goAllQuestions() {
  router.push({ name: 'CourseQuestionsAll', query: { courseId: route.query.id } })
}

// 格式化问题时间
const formatQuestionTime = (timeData) => {
  if (!timeData) return '未知时间'
  
  try {
    const date = new Date(timeData)
    if (isNaN(date.getTime())) return '未知时间'
    
    const now = new Date()
    const diff = now - date
    const minutes = Math.floor(diff / (1000 * 60))
    const hours = Math.floor(diff / (1000 * 60 * 60))
    const days = Math.floor(diff / (1000 * 60 * 60 * 24))
    
    if (minutes < 1) return '刚刚'
    if (minutes < 60) return `${minutes}分钟前`
    if (hours < 24) return `${hours}小时前`
    if (days < 7) return `${days}天前`
    
    return date.toLocaleDateString('zh-CN')
  } catch (e) {
    return '未知时间'
  }
}

// 获取文件图标
const getFileIconEmoji = (filename) => {
  const ext = filename.split('.').pop().toLowerCase()
  if (['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'].includes(ext)) return '🖼️'
  if (['mp4', 'avi', 'mov', 'mkv', 'webm'].includes(ext)) return '🎞️'
  if (['pdf'].includes(ext)) return '📄'
  if (['doc', 'docx'].includes(ext)) return '📃'
  if (['ppt', 'pptx'].includes(ext)) return '📊'
  if (['xls', 'xlsx'].includes(ext)) return '📈'
  if (['zip', 'rar', '7z'].includes(ext)) return '🗜️'
  if (['txt', 'md', 'csv', 'log'].includes(ext)) return '📑'
  if (['exe', 'msi', 'bat', 'sh'].includes(ext)) return '💻'
  if (['mp3', 'wav', 'ogg'].includes(ext)) return '🎵'
  return '📎'
}

// 打开资源预览
const openResourcePreview = (resource) => {
  previewResource.value = resource
}

// 关闭资源预览
const closeResourcePreview = () => {
  previewResource.value = null
}
const goBack = () => {
  // 跳转到/my_school路由
  router.push('/my_school')  
}

const handleGraphDialogOpened = () => {
  // 弹窗打开后稍微延迟执行 resize
  setTimeout(() => {
    knowledgeGraph.value?.resize()
  }, 100)
}
const showFullscreenGraph = () => {
  fullscreenGraphVisible.value = true
}

// === 知识图谱节点查找和高亮相关函数 ===
function findNodeById(tree, pathId) {
  if (typeof pathId === 'string' && pathId.includes('-')) {
    const pathParts = pathId.split('-').map(part => parseInt(part));
    let currentNode = tree;
    for (let i = 0; i < pathParts.length; i++) {
      const targetId = pathParts[i];
      if (currentNode.id === targetId && i === pathParts.length - 1) {
        return currentNode;
      }
      if (currentNode.id === targetId && i < pathParts.length - 1) {
        if (!currentNode.children) return null;
        continue;
      }
      if (!currentNode || !currentNode.children) return null;
      const foundChild = currentNode.children.find(child => child.id === targetId);
      if (!foundChild) return null;
      currentNode = foundChild;
    }
    return currentNode;
  } else {
    const realId = parseInt(pathId);
    if (Array.isArray(tree)) {
      for (const node of tree) {
        if (node.id === realId) return node;
        if (node.children) {
          const found = findNodeById(node.children, realId);
          if (found) return found;
        }
      }
    } else if (tree && typeof tree === 'object') {
      if (tree.id === realId) return tree;
      if (tree.children) {
        const found = findNodeById(tree.children, realId);
        if (found) return found;
      }
    }
    return null;
  }
}

function extractNodeAndChildren(node) {
  if (!node) return null;
  return {
    id: node.id,
    name: node.name,
    children: node.children && node.children.length > 0
      ? node.children.map(child => extractNodeAndChildren(child))
      : null
  };
}

function findParentNode(tree, targetPathId) {
  if (typeof targetPathId === 'string' && targetPathId.includes('-')) {
    const pathParts = targetPathId.split('-').map(part => parseInt(part));
    if (pathParts.length === 1) return null;
    const parentPathParts = pathParts.slice(0, -1);
    const parentPathId = parentPathParts.join('-');
    return findNodeById(tree, parentPathId);
  }
  return null;
}

function findNodeAndRelatedIds(tree, targetPathId) {
  const relatedIds = new Set();
  let targetId;
  if (typeof targetPathId === 'string' && targetPathId.includes('-')) {
    targetId = parseInt(targetPathId.split('-').pop());
  } else {
    targetId = parseInt(targetPathId);
  }
  const targetNode = findNodeById(tree, targetPathId);
  if (!targetNode) return [];
  relatedIds.add(targetNode.id);
  if (targetNode.children) {
    targetNode.children.forEach(child => {
      relatedIds.add(child.id);
      if (child.children) {
        child.children.forEach(grandChild => {
          relatedIds.add(grandChild.id);
        });
      }
    });
  }
  function findParentAndSiblings(node, parent = null) {
    if (node.id === targetId) {
      if (parent) {
        relatedIds.add(parent.id);
        if (parent.children) {
          parent.children.forEach(sibling => {
            relatedIds.add(sibling.id);
          });
        }
      }
      return true;
    }
    if (node.children) {
      for (const child of node.children) {
        if (findParentAndSiblings(child, node)) {
          return true;
        }
      }
    }
    return false;
  }
  if (tree.children) {
    tree.children.forEach(child => {
      findParentAndSiblings(child, tree);
    });
  }
  return Array.from(relatedIds);
}
// === END ===

const handleNodeClick = (shallowNode) => {
  try {
    const realNode = findNodeById(knowledgeTreeData.value, shallowNode.id);
    if (!realNode) {
      ElMessage.error('未找到完整节点');
      return;
    }
    const filteredNode = extractNodeAndChildren(realNode);
    const parentNode = findParentNode(knowledgeTreeData.value, shallowNode.id);
    const relatedIds = findNodeAndRelatedIds(knowledgeTreeData.value, shallowNode.id);
    let graphData;
    if (parentNode) {
      graphData = {
        id: parentNode.id,
        name: parentNode.name,
        children: [
          {
            id: realNode.id,
            name: realNode.name,
            children: realNode.children
          }
        ]
      };
    } else {
      const directChildren = realNode.children ? realNode.children.map(child => ({
        id: child.id,
        name: child.name,
        children: null
      })) : [];
      graphData = {
        id: realNode.id,
        name: realNode.name,
        children: directChildren
      };
    }
    router.push({
      name: 'knowledge-detail',
      query: {
        node: JSON.stringify(filteredNode),
        graphData: JSON.stringify(graphData),
        highlightIds: JSON.stringify(relatedIds),
        courseId: route.query.id,
        courseName: course.value.courseName || '计算机网络原理'
      }
    });
  } catch (error) {
    ElMessage.error('知识点跳转失败');
  }
};


const fetchKnowledgeDetail = async (nodeId) => {
  try {
    // 这里应该是API请求，示例中使用模拟数据
    const res = await axios.get('/api/knowledge/detail', { params: { nodeId } })
    
    // 模拟数据 - 实际应该使用API返回的数据
    mastery.value = {
      current: Math.floor(Math.random() * 100),
      highest: Math.floor(Math.random() * 100)
    }
    
    nodeResources.value = [
      { id: 1, name: '软件调试技术基础.pdf', required: true },
      { id: 2, name: '调试案例分析.docx', required: false },
      { id: 3, name: '调试工具使用指南.pdf', required: true }
    ]
  } catch (error) {
    console.error('获取知识点详情失败', error)
  }
}

const improveMastery = () => {
  // 提升掌握度的逻辑
  mastery.value.current = Math.min(100, mastery.value.current + 10)
  if (mastery.value.current > mastery.value.highest) {
    mastery.value.highest = mastery.value.current
  }
}

const openResource = (resource) => {
  // 打开资源的逻辑
  console.log('打开资源:', resource)
}

const showMoreResources = () => {
  // 显示更多资源的逻辑
  console.log('显示更多资源')
}


const loadKnowledgeTree = async () => {
  const res = await axios.get('/api/graph/course', {
    params: { courseId: route.query.id }
  })
 
    knowledgeTreeData.value = res.data
    console.log(knowledgeTreeData.value)

}

const navItems = [
  { name: 'learning-resources', text: '学习资源', icon: IconLearningResources },
  { name: 'learning-tasks', text: '学习任务', icon: IconLearningTasks },
  { name: 'discussions', text: '问答讨论', icon: IconDiscussions },
  { name: 'assignments', text: '作业考试', icon: IconAssignments },
  { name: 'group-teaching', text: '小组教学', icon: IconGroupTeaching },
  { name: 'knowledge-graph', text: '智慧知识图谱', icon: IconKnowledgeGraph },
  { name: 'chat', text: '群聊', icon: IconChat }
]

const loadResources = async () => {
  const courseId = route.query.id
  try {
    const res = await axios.get('/api/xiaozhi/teacher/resources', {
      params: { courseId }
    })
    if (res.data.code === 200) {
      resources.value = res.data.data
    }
  } catch (e) {
    console.error('获取资源失败', e)
  }
}

const loadCourseInfo = async () => {
  const id = route.query.id
  try {
    const res = await axios.get('/api/xiaozhi/teacher/course', {
      params: {id }
    })
    if (res.data.code === 200) {
      course.value = res.data.data
      // 根据课程中的 teacherId 拉取教师真实信息
      const tid = course.value?.teacherId || course.value?.teacher_id
      if (tid) {
        try {
          const u = await axios.get(`/api/xiaozhi/user/${tid}`)
          const user = u.data?.data || {}
          instructor.value = {
            // 优先使用真实姓名，其次使用可能的驼峰字段，最后兜底为账号名
            name: user.real_name || user.realName || user.username || instructor.value.name || '教师',
            title: '教授',
            // 兼容下划线/驼峰两种头像字段
            avatar: user.avatar_url || user.avatarUrl || ''
          }
        } catch (e) {
          // 保底：从 SQL 的示例可知 teacherId=2 为张磊
          if (!instructor.value.name) {
            instructor.value.name = '张磊'
          }
        }
      }
    }
  } catch (e) {
    console.error('获取课程信息失败', e)
  }
}

onMounted(async () => {
  // 加载保存的主题
  const savedTheme = localStorage.getItem('course-theme')
  if (savedTheme && ['cartoon', 'business', 'minimal'].includes(savedTheme)) {
    currentTheme.value = savedTheme
  }
  
  await Promise.all([loadResources(), loadCourseInfo(), loadTasks(), loadGroups()])
  progress.value = 55
  loading.value = false
  loadKnowledgeTree()
  fetchQuestions() // 加载问题列表
  fetchAssignments()   // 加载作业列表
  fetchExams()         // 加载考试列表
  await Promise.all([loadChapterCount(), loadStudentCount()])
})

// 监听导航切换，当切换到问答讨论时重新加载问题列表
watch(activeNav, (newNav) => {
  if (newNav === 'discussions') {
    fetchQuestions()
  }
  if (newNav === 'assignments') {
    fetchAssignments()
    fetchExams()
  }
  if (newNav === 'learning-tasks' && tasks.value.length === 0) {
    loadTasks()
  }
  if (newNav === 'group-teaching' && groups.value.length === 0) {
    loadGroups()
  }
})

const download = (url) => {
  window.open(url, '_blank')
}

function previewFile(url) {
  previewUrl.value = url
  previewVisible.value = true
}

function closePreview() {
  previewVisible.value = false
  previewUrl.value = ''
}

function isPdf(url) {
  return url.toLowerCase().endsWith('.pdf')
}

function getOfficePreviewUrl(url) {
  return `https://view.officeapps.live.com/op/view.aspx?src=${encodeURIComponent(url)}`
}

function formatDate(dateStr) {
  if (!dateStr) return '未知'
  const d = parseFlexibleDate(dateStr)
  if (!d) return '未知'
  return d.toLocaleDateString()
}

// 更稳健的时间解析：兼容 [Y,M,D,h,m,(s)]、{year,month,day,hour,minute}、字符串/时间戳

// 加载真实章节数量（基于课程ID）
const loadChapterCount = async () => {
  try {
    const courseId = route.query.id
    // 优先使用已存在的教师端章节接口
    const res = await axios.get('/api/xiaozhi/teacher/chapters', { params: { courseId } })
    const list = res.data?.data || res.data || []
    chapterCount.value = Array.isArray(list) ? list.length : 0
  } catch (e) {
    console.error('获取章节数量失败', e)
    chapterCount.value = 0
  }
}

// 加载真实学生数量（基于课程ID）
const loadStudentCount = async () => {
  try {
    const courseId = route.query.id
    const rs = await axios.get('/api/xiaozhi/teacher/course/students', { params: { courseId } })
    const students = rs.data?.data || []
    studentCount.value = Array.isArray(students) ? students.length : 0
  } catch (e) {
    console.error('获取学生数量失败', e)
    studentCount.value = 0
  }
}
function toDateFromArray(arr) {
  const [year, month, day, hour = 0, minute = 0, second = 0] = arr || []
  if (!year || !month || !day) return null
  return new Date(year, month - 1, day, hour, minute, second)
}

function parseFlexibleDate(value) {
  if (!value) return null
  // 数组形式：[年, 月, 日, 时, 分, (秒)] 或 [单元素包装]
  if (Array.isArray(value)) {
    if (value.length === 1) return parseFlexibleDate(value[0])
    if (value.length >= 3 && value.every(v => typeof v === 'number')) {
      return toDateFromArray(value)
    }
  }
  // 对象形式：{ year, month, day, hour?, minute?, second? }
  if (typeof value === 'object' && value.year && value.month && value.day) {
    const { year, month, day, hour = 0, minute = 0, second = 0 } = value
    return new Date(year, month - 1, day, hour, minute, second)
  }
  // 其他情况：交给 Date 解析
  const d = new Date(value)
  return isNaN(d.getTime()) ? null : d
}

// 更稳健的时间格式化，兼容 LocalDate/字符串/时间戳
function safeFormatDate(value) {
  const d = parseFlexibleDate(value)
  if (!d) return '未知'
  try {
    return d.toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch (e) {
    console.error('日期格式化错误:', e, value)
    return '未知'
  }
}

// ======= 作业考试逻辑 =======
const assignments = ref([]) // 全部作业（含提交状态）
const exams = ref([]) // 当前课程考试（含提交状态）
// 详情页改为新页面路由，不再使用弹窗

const fetchAssignments = async () => {
  try {
    const studentId = useUserStore().currentUserId
    const res = await axios.get('/xiaozhi/student/assignments', { params: { studentId } })
    if (res.data.code === 200) {
      assignments.value = Array.isArray(res.data.data) ? res.data.data : []
    }
  } catch (e) {
    console.error('获取作业列表失败', e)
  }
}

const fetchExams = async () => {
  try {
    const studentId = useUserStore().currentUserId
    const cid = parseInt(route.query.id)
    console.log('获取考试列表 - studentId:', studentId, 'courseId:', cid)
    const res = await axios.get('/xiaozhi/student/exams', { params: { studentId, courseId: cid } })
    console.log('考试API响应:', res.data)
    if (res.data.code === 200) {
      const list = Array.isArray(res.data.data) ? res.data.data : []
      console.log('考试列表数据:', list)
      // 统一字段命名，便于与作业合并展示
      exams.value = list.map(e => ({
        assignmentId: e.examId,
        courseId: e.courseId,
        title: e.title,
        description: e.description,
        dueDate: e.examDate,
        submitted: !!e.submitted,
        submittedAt: e.submittedAt,
        score: e.score,
        isExam: true
      }))
      console.log('处理后的考试数据:', exams.value)
    }
  } catch (e) {
    console.error('获取考试列表失败', e)
  }
}

const assignmentsInThisCourse = computed(() => {
  const cid = parseInt(route.query.id)
  const asg = assignments.value
    .filter(a => parseInt(a.courseId) === cid)
    .map(a => ({ ...a, isExam: false }))
  return asg
})

const itemsInThisCourse = computed(() => {
  // 合并作业与考试
  return [...assignmentsInThisCourse.value, ...exams.value]
})

const completedAssignments = computed(() => itemsInThisCourse.value.filter(a => a.submitted))
const incompleteAssignments = computed(() => itemsInThisCourse.value.filter(a => !a.submitted))

// 判断作业是否已截止
const isOverdue = (item) => {
  if (!item.dueDate) return false
  const dueDate = parseFlexibleDate(item.dueDate)
  if (!dueDate) return false
  const today = new Date()
  today.setHours(0, 0, 0, 0) // 设置为今天的开始时间
  return dueDate < today
}

const goToHomework = (assignmentId) => {
  const item = itemsInThisCourse.value.find(it => it.assignmentId === assignmentId)
  if (item?.isExam) {
    router.push({ name: 'ExamConfirm', params: { id: assignmentId } })
    return
  }
  router.push({ name: 'homework', params: { id: assignmentId } })
}

const goToFinishHomework = (assignmentId) => {
  const item = itemsInThisCourse.value.find(it => it.assignmentId === assignmentId)
  if (item?.isExam) {
    router.push({ name: 'ExamConfirm', params: { id: assignmentId } })
    return
  }
  router.push({ name: 'finishhomework', params: { id: assignmentId } })
}

// 过滤、时间范围与分页
const assignmentFilterTab = ref('incomplete') // incomplete | completed
const assignmentDateRange = ref(null) // [start, end]
const pageSize = 6
const currentPage = ref(1)

const filteredByTab = computed(() => assignmentFilterTab.value === 'completed' ? completedAssignments.value : incompleteAssignments.value)

const filteredByDate = computed(() => {
  const list = filteredByTab.value
  if (!assignmentDateRange.value || assignmentDateRange.value.length !== 2) return list
  const [start, end] = assignmentDateRange.value
  const startTime = new Date(start).getTime()
  const endTime = new Date(end).getTime()
  return list.filter(it => {
    const timeSrc = assignmentFilterTab.value === 'completed' ? it.submittedAt : it.dueDate
    const d = parseFlexibleDate(timeSrc)
    if (!d) return false
    const t = d.getTime()
    return t >= startTime && t <= endTime
  })
})

const pagedTotal = computed(() => filteredByDate.value.length)
const pagedAssignments = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  return filteredByDate.value.slice(start, start + pageSize)
})

function resetAssignmentFilters() {
  assignmentFilterTab.value = 'incomplete'
  assignmentDateRange.value = null
  currentPage.value = 1
}

function goToFinishHomeworkWithMeta(item) {
  // 直接跳转详情页即可；如需传更多信息可放到 query
  router.push({ name: 'finishhomework', params: { id: item.assignmentId } })
}
</script>
<style scoped>
.course-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  transition: all 0.3s ease;
}

/* 卡通风主题 (保持原有设计) - 不添加额外样式，保持原有设计 */



/* 简约风主题 - 极简主义设计，保持与卡通风相同的布局 */
.course-page.minimal {
  background: linear-gradient(135deg, #f8f9fa, #e9ecef);
}

.course-page.minimal .header {
  background: linear-gradient(135deg, #ffffff, #f8f9fa);
  color: #333;
  border-radius: 20px;
  padding: 20px;
  margin-bottom: 30px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
  border: 2px solid #e5e5e5;
}

.course-page.minimal .sidebar {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(248, 250, 252, 0.8));
  border-radius: 25px;
  box-shadow: 0 15px 50px rgba(0, 0, 0, 0.08);
  border: 2px solid #e5e5e5;
}

.course-page.minimal .content-section {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95), rgba(248, 250, 252, 0.9));
  border-radius: 25px;
  box-shadow: 0 15px 50px rgba(0, 0, 0, 0.08);
  border: 2px solid #e5e5e5;
}

.course-page.minimal .course-nav li:hover,
.course-page.minimal .course-nav li.active {
  background: linear-gradient(135deg, rgba(0, 0, 0, 0.05), rgba(0, 0, 0, 0.02));
  border-color: #d0d0d0;
  transform: translateX(4px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
}


/* 进度条主题化 - 卡通风保持原有样式 */

.course-page.minimal .progress-fill {
  background: linear-gradient(135deg, #333333, #666666);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* 按钮主题化 - 卡通风保持原有样式 */

.course-page.minimal .el-button--primary {
  background: linear-gradient(135deg, #333333, #666666);
  color: #fff;
  border: none;
  border-radius: 20px;
  font-weight: 600;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* 卡片主题化 - 卡通风保持原有样式 */

.course-page.minimal .assignment-card,
.course-page.minimal .stat-card {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(248, 250, 252, 0.8));
  border-radius: 20px;
  border: 2px solid #e5e5e5;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
}

/* 文字颜色主题化 - 卡通风和商务风保持原有样式 */

/* 响应式设计 */
@media (max-width: 768px) {
  .course-page {
    padding: 10px;
  }
  
  .main-content {
    flex-direction: column;
    gap: 15px;
  }
  
  .sidebar {
    width: 100%;
    order: 2;
  }
  
  .content-area {
    order: 1;
  }
  
  .theme-switcher {
    top: 10px;
    right: 10px;
  }
  
  .theme-button {
    width: 40px;
    height: 40px;
    font-size: 16px;
  }
  
  .course-page.cartoon .header,
  .course-page.minimal .header {
    padding: 15px;
    margin-bottom: 15px;
  }
  
  .course-page.cartoon .sidebar,
  .course-page.minimal .sidebar {
    padding: 15px;
  }
  
  .course-page.cartoon .content-section,
  .course-page.minimal .content-section {
    padding: 20px;
  }
}

@media (max-width: 480px) {
  .course-page {
    padding: 5px;
  }
  
  .theme-switcher {
    top: 5px;
    right: 5px;
  }
  
  .theme-button {
    width: 35px;
    height: 35px;
    font-size: 14px;
  }
  
  .course-nav li {
    padding: 12px 15px;
  }
  
  .nav-icon-img {
    width: 18px;
    height: 18px;
  }
}

.header {
  border-bottom: 1px solid #e0e0e0;
  padding-bottom: 10px;
  margin-bottom: 20px;
}

.main-content {
  display: flex;
  gap: 20px;
}

.sidebar {
  width: 340px; 
  flex-shrink: 0;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(248, 250, 252, 0.8));
  border-radius: 20px;
  padding: 24px;
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.08);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.course-nav ul {
  list-style: none;
  padding: 0;
}

.course-nav li {
  padding: 16px 20px;
  cursor: pointer;
  border-radius: 12px;
  transition: all 0.3s ease;
  margin-bottom: 8px;
  border: 1px solid transparent;
  position: relative;
  overflow: hidden;
}

.course-nav li::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
  transition: left 0.5s ease;
}

.course-nav li:hover::before {
  left: 100%;
}

.course-nav li.active,
.course-nav li:hover {
  background: linear-gradient(135deg, rgba(64, 158, 255, 0.1), rgba(100, 177, 255, 0.05));
  border-color: rgba(64, 158, 255, 0.3);
  transform: translateX(4px);
  box-shadow: 0 4px 16px rgba(64, 158, 255, 0.15);
}

.nav-icon-img {
  width: 22px;
  height: 22px;
  object-fit: contain;
  vertical-align: middle;
  margin-right: 8px;
}

.progress-container {
  margin-top: 30px;
  text-align: center;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.8), rgba(248, 250, 252, 0.6));
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.progress-label {
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 12px;
  font-size: 16px;
}

.progress-bar {
  background: linear-gradient(135deg, #f1f5f9, #e2e8f0);
  height: 12px;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
  margin-bottom: 8px;
}

.progress-fill {
  background: linear-gradient(135deg, #409eff, #66b1ff);
  height: 100%;
  transition: width 0.5s ease;
  border-radius: 8px;
  position: relative;
  overflow: hidden;
}

.progress-fill::after {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0% { left: -100%; }
  100% { left: 100%; }
}

.progress-percent {
  font-weight: 700;
  color: #409eff;
  font-size: 18px;
}

.content-area {
  flex: 1;
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}

.content-section {
  flex: 2;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95), rgba(248, 250, 252, 0.9));
  padding: 30px;
  border-radius: 20px;
  min-height: 300px;
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.08);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  transition: all 0.3s ease;
}

.chat-container {
  height: calc(100vh - 160px);
  display: flex;
}

.content-section:hover {
  transform: translateY(-2px);
  box-shadow: 0 16px 50px rgba(0, 0, 0, 0.12);
}

.empty-state {
  text-align: center;
  color: #888;
  margin-top: 60px;
}

.empty-icon {
  font-size: 40px;
  margin-bottom: 10px;
}

.info-sidebar {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* 作业考试美化样式 */
.assignments-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.assignments-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.assignment-card {
  background: white;
  border-radius: 12px;
  padding: 16px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  border: 1px solid rgba(255, 255, 255, 0.3);
  position: relative;
  overflow: hidden;
}
.assignment-card.assignment { border-left: 6px solid #409eff; }
.assignment-card.exam { border-left: 6px solid #f56c6c; }

.assignment-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(135deg, #409eff, #66b1ff);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.assignment-card.todo::before {
  background: linear-gradient(135deg, #e6a23c, #f7ba2a);
}

.assignment-card.done::before {
  background: linear-gradient(135deg, #67c23a, #85ce61);
}

.assignment-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
}

.assignment-card:hover::before {
  opacity: 1;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.card-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  color: #2c3e50;
  flex: 1;
}

.title-icon {
  font-size: 18px;
}

.card-status {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}

.score-tag {
  font-weight: 600;
}

.overdue-tag {
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
  color: white;
  border: none;
  animation: pulse 2s infinite;
  font-weight: 600;
}

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.7; }
  100% { opacity: 1; }
}

.card-content {
  margin-top: 12px;
}

.time-info {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
  padding: 8px 12px;
  background: linear-gradient(135deg, rgba(64, 158, 255, 0.05), rgba(100, 177, 255, 0.02));
  border-radius: 8px;
}

.time-label {
  font-size: 12px;
  color: #6c757d;
  font-weight: 500;
}

.time-value {
  font-size: 13px;
  color: #2c3e50;
  font-weight: 600;
}

.description {
  font-size: 14px;
  color: #5f6b7a;
  line-height: 1.5;
  padding: 8px 0;
  border-top: 1px solid rgba(0, 0, 0, 0.05);
}

.card-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
  padding-top: 12px;
  border-top: 1px solid rgba(0, 0, 0, 0.05);
}

.action-btn {
  background: linear-gradient(135deg, #409eff, #66b1ff);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 8px 16px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 6px;
}

.action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(64, 158, 255, 0.3);
}

.btn-icon {
  font-size: 14px;
}

.empty-state {
  padding: 60px 20px;
  text-align: center;
}

.pagination-custom {
  display: flex;
  justify-content: center;
  margin-top: 24px;
  padding: 16px;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 12px;
  backdrop-filter: blur(10px);
}

@media (max-width: 992px) {
  .assignments-grid {
    grid-template-columns: 1fr;
  }
}

.instructor-card,
.course-info-card {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(248, 250, 252, 0.8));
  padding: 24px;
  border-radius: 16px;
  text-align: center;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  transition: all 0.3s ease;
}

.instructor-card:hover,
.course-info-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.12);
}

.instructor-avatar {
  width: 60px;
  height: 60px;
  background: linear-gradient(135deg, #409eff, #66b1ff);
  color: #fff;
  font-size: 28px;
  border-radius: 50%;
  margin: 0 auto 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8px 24px rgba(64, 158, 255, 0.3);
  transition: all 0.3s ease;
}

.instructor-avatar:hover {
  transform: scale(1.1);
  box-shadow: 0 12px 32px rgba(64, 158, 255, 0.4);
}

/* 课程信息卡片美化 */
.course-info-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 2px solid rgba(64, 158, 255, 0.1);
}

.course-info-icon {
  font-size: 24px;
  background: linear-gradient(135deg, #409eff, #66b1ff);
  color: white;
  width: 40px;
  height: 40px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
}

.course-info-header h4 {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
  color: #2c3e50;
}

/* 课程封面 */
.course-cover {
  position: relative;
  margin-bottom: 20px;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.course-image {
  width: 100%;
  height: 120px;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.course-cover:hover .course-image {
  transform: scale(1.05);
}

.course-cover-overlay {
  position: absolute;
  top: 8px;
  right: 8px;
}

.course-status {
  background: linear-gradient(135deg, #00c093, #00a085);
  color: white;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  box-shadow: 0 2px 8px rgba(0, 192, 147, 0.3);
}

/* 课程信息列表 */
.course-info-list {
  margin-bottom: 20px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid rgba(64, 158, 255, 0.1);
  transition: all 0.3s ease;
}

.info-item:last-child {
  border-bottom: none;
}

.info-item:hover {
  background: linear-gradient(135deg, rgba(64, 158, 255, 0.05), rgba(100, 177, 255, 0.02));
  border-radius: 8px;
  padding-left: 8px;
  padding-right: 8px;
  margin-left: -8px;
  margin-right: -8px;
}

.info-icon {
  font-size: 18px;
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, rgba(64, 158, 255, 0.1), rgba(100, 177, 255, 0.05));
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.info-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.info-label {
  font-size: 12px;
  color: #6c757d;
  font-weight: 500;
}

.info-value {
  font-size: 14px;
  color: #2c3e50;
  font-weight: 600;
  line-height: 1.4;
}

/* 课程统计 */
.course-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin-top: 20px;
}

.stat-card {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.8), rgba(248, 250, 252, 0.6));
  border-radius: 12px;
  padding: 16px;
  text-align: center;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.3);
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(64, 158, 255, 0.15);
  background: linear-gradient(135deg, rgba(64, 158, 255, 0.1), rgba(100, 177, 255, 0.05));
}

.stat-number {
  font-size: 20px;
  font-weight: 700;
  color: #409eff;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 12px;
  color: #6c757d;
  font-weight: 500;
}

/* 全局动画效果 */
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

@keyframes slideInLeft {
  from {
    opacity: 0;
    transform: translateX(-30px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slideInRight {
  from {
    opacity: 0;
    transform: translateX(30px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

/* 应用动画 */
.course-page {
  animation: fadeInUp 0.8s ease-out;
}

.sidebar {
  animation: slideInLeft 0.8s ease-out 0.2s both;
}

.content-section {
  animation: fadeInUp 0.8s ease-out 0.4s both;
}

.info-sidebar {
  animation: slideInRight 0.8s ease-out 0.6s both;
}

/* 学习任务模块样式 */
.tasks-container .tasks-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.tasks-container .page-title {
  font-size: 22px;
  font-weight: 700;
  color: #2c3e50;
  margin: 0;
}

.tasks-container .page-subtitle {
  margin: 4px 0 0 0;
  color: #7f8c8d;
  font-size: 13px;
}

.task-filter-bar {
  display: flex;
  gap: 12px;
  align-items: center;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(248, 250, 252, 0.8));
  border-radius: 12px;
  padding: 14px;
  margin: 12px 0 16px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.06);
}

.task-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 16px;
}

.task-stats .stat-card {
  background: white;
  border-radius: 12px;
  padding: 14px;
  text-align: center;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.6);
}

.task-stats .stat-card .stat-number {
  font-size: 20px;
  font-weight: 800;
  color: #409eff;
}

.task-stats .stat-card .stat-label {
  font-size: 12px;
  color: #6c757d;
}

.task-stats .stat-card.success .stat-number { color: #67c23a; }
.task-stats .stat-card.info .stat-number { color: #909399; }
.task-stats .stat-card.warning .stat-number { color: #e6a23c; }

.kanban {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.kanban-column {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95), rgba(248, 250, 252, 0.9));
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: 14px;
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.06);
  padding: 14px;
}

.kanban-title {
  font-weight: 700;
  color: #2c3e50;
  margin-bottom: 8px;
}

.kanban-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.task-card {
  background: white;
  border-radius: 12px;
  padding: 12px;
  border: 1px solid #eef2f7;
  box-shadow: 0 4px 18px rgba(0,0,0,0.06);
  cursor: pointer;
  transition: transform .2s ease, box-shadow .2s ease;
}

.task-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 26px rgba(0,0,0,0.08);
}

.task-card.done { opacity: 0.85; }

.task-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 6px; }
.task-title { display: flex; align-items: center; gap: 8px; font-weight: 600; color: #2c3e50; }
.task-icon { font-size: 18px; }

.task-meta { display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px; color: #6b7280; font-size: 12px; }
.task-meta .due { color: #6b7280; }
.task-meta .due.danger { color: #e53935; font-weight: 600; }
.task-meta .tags { font-style: italic; color: #909399; }

.task-actions { display: flex; gap: 8px; justify-content: flex-end; margin-top: 10px; }

@media (max-width: 992px) {
  .kanban { grid-template-columns: 1fr; }
  .task-stats { grid-template-columns: repeat(2, 1fr); }
}


/* 小组教学样式 */
.groups-container .groups-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.groups-container .page-title {
  font-size: 22px;
  font-weight: 700;
  color: #2c3e50;
  margin: 0;
}

.groups-container .page-subtitle {
  margin: 4px 0 0 0;
  color: #7f8c8d;
  font-size: 13px;
}

.group-filter-bar {
  display: flex;
  gap: 12px;
  align-items: center;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(248, 250, 252, 0.8));
  border-radius: 12px;
  padding: 14px;
  margin: 12px 0 16px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.06);
}

.group-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin-bottom: 16px;
}

.group-stats .stat-card {
  background: white;
  border-radius: 12px;
  padding: 14px;
  text-align: center;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.6);
}

.group-stats .stat-card .stat-number {
  font-size: 20px;
  font-weight: 800;
  color: #409eff;
}

.group-stats .stat-card .stat-label {
  font-size: 12px;
  color: #6c757d;
}

.group-stats .stat-card.success .stat-number { color: #67c23a; }
.group-stats .stat-card.info .stat-number { color: #909399; }

.group-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 16px;
}

.group-card {
  background: white;
  border-radius: 12px;
  padding: 14px;
  border: 1px solid #eef2f7;
  box-shadow: 0 4px 18px rgba(0,0,0,0.06);
  cursor: pointer;
  transition: transform .2s ease, box-shadow .2s ease;
}

.group-card:hover { transform: translateY(-2px); box-shadow: 0 10px 26px rgba(0,0,0,0.08); }

.group-card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px; }
.group-title { display: flex; align-items: center; gap: 8px; font-weight: 600; color: #2c3e50; }
.group-icon { font-size: 18px; }

.group-meta { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; margin: 8px 0 10px; }
.meta-item { background: #f8fafc; border: 1px solid #eef2f7; border-radius: 8px; padding: 8px; text-align: center; }
.meta-label { display: block; font-size: 11px; color: #9aa4b2; }
.meta-value { font-size: 13px; color: #2c3e50; font-weight: 600; }

.group-actions { display: flex; gap: 8px; justify-content: flex-end; margin-top: 10px; }

.group-detail .detail-row { margin-bottom: 10px; color: #34495e; }
.member-chips { display: flex; flex-wrap: wrap; }

@media (max-width: 992px) {
  .group-grid { grid-template-columns: 1fr; }
  .group-stats { grid-template-columns: 1fr 1fr; }
}

/* 顶部GIF样式 */
.top-gif-container {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 1;
  pointer-events: none;
}

.top-gif {
  width: 100%;
  height: 100%;
  object-fit: cover;
  opacity: 0.3;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .main-content {
    flex-direction: column;
  }
  .sidebar {
    width: 100%;
  }
  .content-area {
    flex-direction: column;
  }
  .info-sidebar {
    width: 100%;
  }
  
  .top-gif {
    max-width: 100%;
  }
}
/* 预览区域样式 */
.preview-container {
  margin-top: 20px;
  border: 1px solid #ccc;
  border-radius: 6px;
  padding: 10px;
  background: #fff;
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
  font-weight: bold;
  font-size: 16px;
}
.header {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 2px solid rgba(64, 158, 255, 0.1);
  padding: 50px 0;
  margin-bottom: 30px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.8), rgba(240, 248, 255, 0.6));
  border-radius: 16px;
  padding: 50px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
  backdrop-filter: blur(10px);
  z-index: 2;
}

.header-center {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
}

.header-right {
  display: flex;
  align-items: center;
}

.course-title {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  color: #2c3e50;
  text-align: center;
}

.course-code {
  font-size: 14px;
  color: #666;
  background: rgba(64, 158, 255, 0.1);
  padding: 6px 12px;
  border-radius: 20px;
  font-weight: 500;
}

.header-image img {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 8px;
}

.header-title {
  display: flex;
  flex-direction: column;
}
/* 新增样式 */
.knowledge-detail-panel {
  flex: 1;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 16px;
  height: 600px;
  overflow-y: auto;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 8px;
  border-bottom: 1px solid #eee;
}

.panel-header h3 {
  margin: 0;
  color: #333;
}

.mastery-progress {
  margin-bottom: 20px;
  padding: 16px;
  background: #f9f9f9;
  border-radius: 8px;
}

.progress-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 14px;
}

.progress-history {
  margin-top: 8px;
  font-size: 12px;
  color: #666;
  text-align: right;
}

.knowledge-description {
  margin-bottom: 20px;
  padding: 16px;
  background: #f9f9f9;
  border-radius: 8px;
}

.knowledge-description h4 {
  margin-top: 0;
  margin-bottom: 12px;
  color: #333;
}

.knowledge-description p {
  margin: 0;
  color: #666;
  line-height: 1.6;
}

.knowledge-resources {
  padding: 16px;
  background: #f9f9f9;
  border-radius: 8px;
}

.knowledge-resources h4 {
  margin-top: 0;
  margin-bottom: 12px;
  color: #333;
}

.resource-list {
  margin-bottom: 12px;
}

.resource-item {
  display: flex;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid #eee;
}

.resource-name {
  flex: 1;
  margin-right: 12px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* 响应式调整 */
@media (max-width: 992px) {
  .knowledge-detail-panel {
    flex: 1;
    min-width: 300px;
  }
}

@media (max-width: 768px) {
  .knowledge-detail-panel {
    width: 100%;
    margin-top: 20px;
  }
}

/* 添加查看详情按钮样式 */
.view-detail-btn {
  position: absolute;
  right: 20px;
  top: 20px;
  z-index: 10;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}
/* 知识图谱容器 */
.graph-container {
  flex: 2;
  height: 600px;
  position: relative;  /* 关键设置 */
  border: 1px solid #eee;
  border-radius: 8px;
  background-color: #f9f9f9;
}

/* 查看详情按钮 */
.view-detail-btn {
  position: absolute;
  right: 20px;
  top: 20px;
  z-index: 10;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  background-color: #409eff;
  color: white;
  border: none;
}

.view-detail-btn:hover {
  background-color: #66b1ff;
}
.course-page {
  max-width: 1900px;
  margin: 0 auto;
  padding: 20px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95), rgba(240, 248, 255, 0.9)),
              url('../../assets/images/login-background.jpg') center/cover no-repeat;
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}
.card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
  padding: 20px;
}
.el-button {
  border-radius: 12px !important;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.2);
  transition: all 0.3s ease;
  border: 1px solid rgba(255, 255, 255, 0.3);
  backdrop-filter: blur(10px);
}

.el-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(64, 158, 255, 0.3);
}
.resource-item {
  background: #f5f8ff;
  padding: 10px 12px;
  border-radius: 6px;
  margin-bottom: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.course-nav li.active {
  background: linear-gradient(to right, #409eff, #66b1ff);
  color: white;
  font-weight: bold;
  transition: all 0.3s;
}
/* 添加以下样式 */
.resource-header {
  display: flex;
  align-items: center;
  margin-bottom: 24px;
  padding: 20px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(248, 250, 252, 0.8));
  border-radius: 16px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.resource-list-container {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(248, 250, 252, 0.8));
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.resource-category h3 {
  margin-top: 0;
  color: #333;
  padding-bottom: 10px;
  border-bottom: 1px solid #eee;
}

.resource-item {
  display: flex;
  align-items: center;
  padding: 16px 20px;
  margin-bottom: 12px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.8), rgba(248, 250, 252, 0.6));
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
}

.resource-item:hover {
  background: linear-gradient(135deg, rgba(64, 158, 255, 0.1), rgba(100, 177, 255, 0.05));
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(64, 158, 255, 0.15);
  border-color: rgba(64, 158, 255, 0.3);
}

.resource-name {
  flex: 1;
  margin-left: 15px;
  font-size: 14px;
}

.resource-actions {
  margin-left: 15px;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .resource-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .resource-item {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .resource-name {
    margin: 10px 0;
  }
  
  .resource-actions {
    align-self: flex-end;
  }
}


.k2{
  position: relative;
  top:30px;
  left: 70px;
}


.qa-panel {
  background: white;
  padding: 24px;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
  width: 100%;
  max-width: 800px;
  margin: 0 auto;
  box-sizing: border-box;
}

/* 顶部操作栏 */
.qa-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 2px solid #f0f0f0;
}

.qa-title h2 {
  margin: 0 0 4px 0;
  font-size: 24px;
  font-weight: 700;
  color: #2c3e50;
}

.qa-subtitle {
  margin: 0;
  font-size: 14px;
  color: #7f8c8d;
}

.ask-btn {
  background: linear-gradient(135deg, #00c093, #00a085);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(0, 192, 147, 0.3);
}

.ask-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 192, 147, 0.4);
}

.ask-icon {
  font-size: 16px;
}

/* 分类标签 */
.qa-tabs {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
  padding: 4px;
  background: #f8f9fa;
  border-radius: 12px;
}

.tab-item {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 16px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
  font-size: 14px;
  color: #6c757d;
  transition: all 0.3s ease;
  position: relative;
}

.tab-item.active {
  background: white;
  color: #00c093;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.tab-icon {
  font-size: 16px;
}

.tab-count {
  background: #e9ecef;
  color: #6c757d;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.tab-item.active .tab-count {
  background: #00c093;
  color: white;
}

/* 问题列表 */
.question-list {
  margin-bottom: 20px;
}

.question-item {
  border: 1px solid #e9ecef;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 16px;
  transition: all 0.3s ease;
  background: white;
}

.question-item:hover {
  border-color: #00c093;
  box-shadow: 0 4px 16px rgba(0, 192, 147, 0.1);
  transform: translateY(-2px);
}

.question-link {
  text-decoration: none;
  color: inherit;
  display: block;
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.question-title {
  font-weight: 600;
  font-size: 16px;
  color: #2c3e50;
  line-height: 1.4;
  flex: 1;
  margin-right: 12px;
}

.question-badge {
  background: linear-gradient(135deg, #00c093, #00a085);
  color: white;
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
}

.question-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #6c757d;
}

.user-avatar {
  width: 24px;
  height: 24px;
  background: linear-gradient(135deg, #00c093, #00a085);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 600;
}

.question-time {
  font-size: 12px;
  color: #adb5bd;
}

.question-stats {
  display: flex;
  gap: 16px;
  margin-bottom: 12px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  color: #6c757d;
}

.stat-icon {
  font-size: 14px;
}

/* 附件预览 */
.attachments-preview {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #f1f3f4;
}

.attachment-item {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 10px;
  background: #f8f9fa;
  border-radius: 6px;
  font-size: 12px;
  color: #6c757d;
}

.file-icon {
  font-size: 14px;
}

.file-name {
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.more-files {
  font-size: 12px;
  color: #adb5bd;
  font-style: italic;
}

/* 空状态 */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #6c757d;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 16px;
  display: block;
}

.empty-state h3 {
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 600;
  color: #495057;
}

.empty-state p {
  margin: 0;
  font-size: 14px;
  color: #adb5bd;
}
.popup {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}
.popup-inner {
  background: white;
  padding: 24px;
  border-radius: 12px;
  width: 400px;
  box-shadow: 0 0 20px rgba(0, 0, 0, 0.2);
}
.popup-inner textarea {
  width: 100%;
  height: 100px;
  margin-bottom: 12px;
  padding: 8px;
  border-radius: 8px;
  border: 1px solid #ccc;
  font-size: 14px;
}
.submit-btn,
.close-btn {
  width: 100%;
  padding: 10px;
  margin-top: 10px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
}
.submit-btn {
  background: #00c093;
  color: white;
}
.close-btn {
  background: #ccc;
  color: #333;
}
.question-link {
  text-decoration: none;    /* 去掉下划线 */
  color: inherit;           /* 继承父元素颜色（可选） */
}

.question-link:hover {
  text-decoration: none;
}



.delete-btn:hover {
  color: #d32f2f;
}

/* 附件相关样式 */
.attachment-info {
  color: #409eff;
  font-size: 12px;
}

.attachments-preview {
  margin-top: 8px;
  padding: 8px;
  background: #f8f9fa;
  border-radius: 4px;
  border-left: 3px solid #409eff;
}

.attachment-item {
  display: flex;
  align-items: center;
  margin-bottom: 4px;
  font-size: 12px;
  color: #666;
}

.attachment-item:last-child {
  margin-bottom: 0;
}

.attachment-item .file-icon {
  margin-right: 4px;
  font-size: 14px;
}

.attachment-item .file-name {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.more-files {
  font-size: 11px;
  color: #999;
  font-style: italic;
}

/* 弹窗中的文件选择样式 */
.file-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
  padding: 8px;
  background-color: #f9f9f9;
  border-radius: 6px;
  transition: background-color 0.3s ease;
}

.file-item:hover {
  background-color: #f0f8ff;
}

.file-link {
  display: flex;
  align-items: center;
  flex: 1;
  font-size: 14px;
  color: #4caf50;
  text-decoration: none;
  transition: color 0.3s ease;
}

.file-link:hover {
  color: #ff4081;
}

.file-icon {
  margin-right: 8px;
  font-size: 16px;
}

.delete-btn {
  margin-left: 10px;
  color: #ff4081;
  transition: color 0.3s ease;
}

.assignments-container {
  margin-top: 20px;
  padding: 20px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(248, 250, 252, 0.8));
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.assignments-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.header-left {
  display: flex;
  flex-direction: column;
}

.page-title {
  font-size: 24px;
  font-weight: 700;
  color: #2c3e50;
}

.page-subtitle {
  font-size: 14px;
  color: #7f8c8d;
}

.header-stats {
  display: flex;
  gap: 16px;
}

.stat-item {
  display: flex;
  flex-direction: column;
}

.stat-number {
  font-size: 20px;
  font-weight: 700;
  color: #409eff;
}

.stat-label {
  font-size: 12px;
  color: #6c757d;
}

.assignment-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 16px;
}

.toolbar-left {
  display: flex;
  gap: 16px;
}

.filter-tabs {
  display: flex;
  gap: 12px;
}

.tab-icon {
  font-size: 16px;
}

.toolbar-right {
  display: flex;
  gap: 12px;
}

.date-filter {
  width: 200px;
}

.reset-btn {
  background: #ccc;
  color: #333;
  border: none;
  border-radius: 8px;
  padding: 8px 16px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.reset-btn:hover {
  background: #999;
  color: white;
}

.assignment-list {
  margin-top: 20px;
}

.assignment-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 16px;
}

.assignment-card {
  background: white;
  border-radius: 12px;
  padding: 16px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.card-title {
  display: flex;
  align-items: center;
  gap: 8px;
}

.title-icon {
  font-size: 16px;
}

.card-status {
  display: flex;
  align-items: center;
  gap: 8px;
}

.card-content {
  margin-top: 12px;
}

.time-info {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
}

.time-label {
  font-size: 12px;
  color: #6c757d;
}

.time-value {
  font-size: 14px;
  color: #2c3e50;
}

.description {
  font-size: 14px;
  color: #5f6b7a;
}

.card-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}

.action-btn {
  background: linear-gradient(135deg, #409eff, #66b1ff);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 8px 16px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(0, 192, 147, 0.3);
}

.action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 192, 147, 0.4);
}

.pagination-custom {
  display: flex;
  justify-content: center;
  margin-top: 16px;
}
.katong{
  width: 180px;
  height: 180px;
  position: absolute;
  top:10px;
  z-index: 111;
  left: 150px;
  opacity: 0;
  animation: floatInLeft 0.9s ease-out forwards;
  will-change: transform, opacity;
}
.katong2{
  width: 180px;
  height: 180px;
  position: absolute;
  top:10px;
  z-index: 111;
  left: 1350px;
  opacity: 0;
  animation: floatInRight 0.9s ease-out 0.1s forwards;
  will-change: transform, opacity;
}
@keyframes floatInLeft {
  from {
    opacity: 0;
    transform: translateY(-16px) translateX(-16px) scale(0.96);
    filter: saturate(0.9);
  }
  to {
    opacity: 1;
    transform: translateY(0) translateX(0) scale(1);
    filter: saturate(1);
  }
}

@keyframes floatInRight {
  from {
    opacity: 0;
    transform: translateY(-16px) translateX(16px) scale(0.96);
    filter: saturate(0.9);
  }
  to {
    opacity: 1;
    transform: translateY(0) translateX(0) scale(1);
    filter: saturate(1);
  }
}

/* ================= Cartoon Theme (layout unchanged) ================= */
.course-page {
  background: #fdfdfc;
}

/* 手绘边框与纸张质感 */
.sidebar,
.content-section,
.course-info-card,
.resource-list-container,
.resource-header,
.progress-container,
.knowledge-detail-panel,
.graph-container,
.instructor-card {
  background: #fff8f2;
  border: 2px solid #2b2b2b;
  border-radius: 16px;
  box-shadow: 4px 4px 0 #2b2b2b;
}

/* 侧栏菜单卡通化 */
.course-nav li {
  border: 2px solid #2b2b2b;
  background: #fff;
}
.course-nav li.active,
.course-nav li:hover {
  background: #ffe8a3;
  border-color: #2b2b2b;
  box-shadow: 3px 3px 0 #2b2b2b;
}
.nav-icon-img { filter: saturate(1.2) contrast(1.05); }

/* Header 手绘标题条 */
.header {
  background: #cdf3ff;
  border: 2px solid #2b2b2b;
  box-shadow: 4px 4px 0 #2b2b2b;
  padding: 50px !important;
}
.header h1 { color: #1f2a44; text-shadow: 2px 2px 0 #fff; }

/* 卡通按钮 */
.el-button {
  border: 2px solid #2b2b2b !important;
  box-shadow: 3px 3px 0 #2b2b2b !important;
}
.el-button--primary {
  background: #ffd166;
  color: #2b2b2b;
}
.el-button--primary:hover { background: #ffc042; }

/* 进度条卡通化 */
.progress-bar { height: 12px; border: 2px solid #2b2b2b; background: #fff; }
.progress-fill { background: repeating-linear-gradient(45deg, #95d5b2 0 10px, #74c69d 10px 20px); }

/* 卡片图片圆角与描边 */
.course-image { border: 3px solid #2b2b2b; border-radius: 12px; }

/* 资源条目卡通化 */
.resource-item {
  border: 2px solid #2b2b2b;
  background: #fffef2;
  box-shadow: 2px 2px 0 #2b2b2b;
}
</style>
