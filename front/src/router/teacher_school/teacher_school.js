// src/router/teacher_school/create_course.js
import TeacherLayout from "@/layouts/TeacherLayout.vue"
import Dashboard from "@/views/Dashboard/Dashboard.vue"
import MainPanel from "@/views/Dashboard/components/MainPanel.vue"
import CourseQuery from "@/views/Dashboard/components/CourseQuery.vue"
import CourseCreate from "@/views/Dashboard/components/CreateCourse.vue"
import StudentManager from "@/views/Dashboard/components/StudentManager.vue"
import HomeworkOverview from "@/views/Dashboard/components/HomeworkOverview.vue"
import AddWork from "@/views/Dashboard/components/AddWork.vue"
import HomeworkDashboard from "@/views/Dashboard/components/HomeworkDashboard.vue"
import ExamDashboard from "@/views/Dashboard/components/ExamDashboard.vue"
import ResourceDashboard from "../../views/Dashboard/components/ResourceDashboard.vue"
import TeacherGroupChat from "@/views/teacher_chat/TeacherGroupChat.vue"
import TeacherProfile from "@/views/teacher/TeacherProfile.vue"
import GeneratedExam from "@/views/Dashboard/components/GeneratedExam.vue"
import AutoExamPreview from "@/views/Dashboard/components/AutoExamPreview.vue"
// import AutoPPTGenerator from "@/views/Dashboard/components/AutoPPTGenerator.vue"
import ChapterManager from "@/views/Dashboard/components/ChapterManager.vue"
import DesignTools from "@/views/Dashboard/components/DesignTools.vue"
import AutoExamGenerator from "@/views/Dashboard/components/AutoExamGenerator.vue"
import QuestionGenerator from "@/views/Dashboard/components/QuestionGenerator.vue"
import QuestionBankBrowser from "@/views/Dashboard/components/QuestionBankBrowser.vue"
import QuestionBankList from "@/views/Dashboard/components/QuestionBankList.vue"
import GeneratedQuestionsView from "@/views/Dashboard/components/GeneratedQuestionsView.vue"
const AIAssistant = () => import('@/views/teacher/AIAssistantPage.vue')
const routes = [
  {
    path: "/teacher_school",
    component: TeacherLayout,
    children: [
      {
        path: "",
        component: Dashboard,
        children: [
          {
            path: "", // 默认子路由（即 /teacher_school）
            name: "MainPanel",
            component: MainPanel
          },
          {
            path: "query", // /teacher_school/create
            name: "QueryCourse",
            component: CourseQuery
          },
          {
            path: "create", // /teacher_school/query
            name: "CreateCourse",
            component: CourseCreate
          },
          {
            path: "manager", // /teacher_school/manager
            name: "StudentManager",
            component: StudentManager
          },
          {
            path: "homework", // /teacher_school/homework
            name: "HomeworkOverview",
            component: HomeworkOverview
          },
          {
            path: "addwork", // /teacher_school/addwork
            name: "AddWork",
            component: AddWork
          },
          {
            path: "homework-dashboard",
            name: "HomeworkDashboard",
            component: HomeworkDashboard
          },
          {
            path: "exam-dashboard",
            name: "ExamDashboard",
            component: ExamDashboard
          },
          {
            path: "chapter/:courseId",
            name: "ChapterManager",
            component: ChapterManager,
            props: true
          },
          {
            path: 'create-homework',
            name: 'CreateHomework',
            component: () => import('@/views/Dashboard/components/CreateHomework.vue')
          },
          {
            path: 'create-exam',
            name: 'CreateExam',
            component: () => import('@/views/Dashboard/components/CreateExam.vue')
          },
          {
            path: 'design-tools',
            name: 'DesignTools',
            component: DesignTools
          },
          {
            path: 'auto-exam-generator',
            name: 'AutoExamGenerator',
            component: AutoExamGenerator
          },
          {
            path: 'question-generator',
            name: 'QuestionGenerator',
            component: QuestionGenerator
          },
          {
            path: 'question-bank',
            name: 'QuestionBankList',
            component: QuestionBankList
          },
          {
            path: 'question-bank/view',
            name: 'QuestionBankBrowser',
            component: QuestionBankBrowser
          },
          {
            path: 'generated-result',
            name: 'GeneratedQuestionsView',
            component: GeneratedQuestionsView
          },
          {
            path: 'aiTeach',
            name: "aiTeach",
            component: () => import('@/views/Dashboard/components/aiTeach.vue')
          },
          {
            path: 'ai-assistant',
            name: 'AIAssistant',
            component: AIAssistant
          },
          {
            path: 'aiGeneratedExam',
            name: 'aiGeneratedExam',
            component: GeneratedExam
          },
          {
            path: 'auto-exam-preview',
            name: 'AutoExamPreview',
            component: AutoExamPreview
          },
          {
            path: "resourcedashboard",
            name: "ResourceDashboard",
            component: ResourceDashboard
          },
          // {
          //   path: "auto-ppt",
          //   name: "AutoPPTGenerator",
          //   component: AutoPPTGenerator
          // },
          {
            path: "group-chat",
            name: "TeacherGroupChat",
            component: TeacherGroupChat
          }
        ]
      },
      {
        path: "profile",
        name: "TeacherProfile",
        component: TeacherProfile
      }
    ]
  }
]

export default routes