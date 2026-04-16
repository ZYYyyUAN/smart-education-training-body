// 模拟数据文件 - 用于前端开发和测试
// 当后端API不可用时，使用这些数据进行测试

// 课程数据
export const mockCourses = {
  101: {
    id: 101,
    courseName: '嵌入式开发进阶',
    description: '深入学习嵌入式系统开发技术，包括处理器架构、实时操作系统、通信协议等核心内容。',
    teacherId: 2,
    courseImage: 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/7c2d7145-f40d-40cf-ab21-1581a55c5ea3-p111.png',
    teachingGoal: '掌握嵌入式系统开发的核心技术，能够独立完成嵌入式项目的设计和开发。',
    teachingPrinciple: '理论与实践相结合，注重动手能力和项目经验的培养。',
    courseBackground: '随着物联网和智能设备的快速发展，嵌入式开发技术变得越来越重要。',
    courseIntro: '本课程将带领学生深入学习嵌入式系统开发的各个方面，从硬件架构到软件设计，从基础概念到实际应用。'
  },
  102: {
    id: 102,
    courseName: '计算机网络',
    description: '学习计算机网络的基本原理、协议体系和应用技术。',
    teacherId: 2,
    courseImage: 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/JiWang.png',
    teachingGoal: '使学生掌握计算机网络体系结构、关键协议原理及组网技术，具备网络设计、故障排查和安全防护的实践能力。',
    teachingPrinciple: '理论实践并重，以协议体系为核心，通过案例分析和实验操作培养解决实际网络问题的能力。',
    courseBackground: '计算机网络是现代信息社会的基础设施，掌握网络技术对各行各业都至关重要。',
    courseIntro: '本课程将系统介绍计算机网络的基本概念、协议原理和实际应用，帮助学生建立完整的网络知识体系。'
  }
}

// 章节数据
export const mockChapters = {
  101: [ // 嵌入式开发进阶课程的章节
    {
      id: 1,
      course_id: 101,
      chapter_title: '嵌入式系统概述',
      content: '本章介绍嵌入式系统的基本概念、特点、分类和应用领域。',
      created_at: '2025-01-01'
    },
    {
      id: 2,
      course_id: 101,
      chapter_title: '嵌入式处理器架构',
      content: '深入讲解ARM、MIPS等主流嵌入式处理器架构的特点和选型原则。',
      created_at: '2025-01-01'
    },
    {
      id: 3,
      course_id: 101,
      chapter_title: '嵌入式软件开发',
      content: '介绍嵌入式软件开发环境搭建、交叉编译、调试技术等核心技能。',
      created_at: '2025-01-01'
    },
    {
      id: 4,
      course_id: 101,
      chapter_title: '实时操作系统',
      content: '学习RTOS的基本概念、任务调度、中断处理等关键技术。',
      created_at: '2025-01-01'
    },
    {
      id: 5,
      course_id: 101,
      chapter_title: '嵌入式系统通信',
      content: '掌握串口、CAN总线、以太网等通信协议在嵌入式系统中的应用。',
      created_at: '2025-01-01'
    },
    {
      id: 6,
      course_id: 101,
      chapter_title: '嵌入式系统调试与测试',
      content: '学习JTAG调试、单元测试、集成测试等调试和测试技术。',
      created_at: '2025-01-01'
    }
  ],
  102: [ // 计算机网络课程的章节
    {
      id: 7,
      course_id: 102,
      chapter_title: '计算机网络概述',
      content: '介绍计算机网络的基本概念、发展历史、分类和拓扑结构。',
      created_at: '2025-01-01'
    },
    {
      id: 8,
      course_id: 102,
      chapter_title: '物理层',
      content: '学习传输介质、信号编码、物理层设备等物理层技术。',
      created_at: '2025-01-01'
    },
    {
      id: 9,
      course_id: 102,
      chapter_title: '数据链路层',
      content: '掌握帧格式、差错控制、流量控制等数据链路层技术。',
      created_at: '2025-01-01'
    },
    {
      id: 10,
      course_id: 102,
      chapter_title: '网络层',
      content: '深入学习IP协议、路由算法、网络层设备等网络层技术。',
      created_at: '2025-01-01'
    },
    {
      id: 11,
      course_id: 102,
      chapter_title: '传输层',
      content: '学习TCP协议、UDP协议、端口号等传输层技术。',
      created_at: '2025-01-01'
    },
    {
      id: 12,
      course_id: 102,
      chapter_title: '应用层',
      content: '掌握HTTP协议、FTP协议、DNS协议等应用层协议。',
      created_at: '2025-01-01'
    }
  ]
}

// 模拟API响应格式
export const createMockResponse = (data, message = 'success') => {
  return {
    code: 200,
    message: message,
    data: data
  }
}

// 模拟课程API
export const mockCourseAPI = (courseId) => {
  const course = mockCourses[courseId]
  if (course) {
    return createMockResponse(course)
  } else {
    return {
      code: 404,
      message: '课程不存在',
      data: null
    }
  }
}

// 模拟章节API
export const mockChaptersAPI = (courseId) => {
  const chapters = mockChapters[courseId]
  if (chapters) {
    return createMockResponse(chapters)
  } else {
    return {
      code: 404,
      message: '章节不存在',
      data: null
    }
  }
}
