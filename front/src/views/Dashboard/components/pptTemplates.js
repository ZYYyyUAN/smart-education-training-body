// PPT模板数据
export const pptTemplates = [
  // 专业PPT模板
  {
    id: 'cat-theme-ppt',
    name: '黑白猫猫PPT模板',
    scene: 'education',
    style: 'cute',
    category: '教育培训',
    preview: '🐱',
    description: '可爱的黑白猫主题PPT模板，适用于教育培训、教师说课、家长会等场景',
    thumbnail: 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/4738fc6a-8fa3-4f48-a8bd-62004e99f8b0%20%281%29.pptx',
    downloadUrl: 'https://xiaozhi6667.oss-cn-beijing.aliyuncs.com/xiaozhi/resources/4738fc6a-8fa3-4f48-a8bd-62004e99f8b0%20%281%29.pptx',
    slides: [
      { 
        title: '封面页', 
        content: '黑白猫猫',
        preview: '/src/assets/ppt/cat/h1.png',
        description: '可爱的黑白猫主题封面，包含五个不同图案的卡通猫',
        color: '#3b82f6',
        details: '标题：黑白猫猫 | 功能：教育培训、教师说课、家长会',
        isImage: true
      },
      { 
        title: '目录页', 
        content: '目录',
        preview: '/src/assets/ppt/cat/h2.png',
        description: '清晰的目录结构，左侧目录标题，右侧四个内容块',
        color: '#10b981',
        details: '左侧：目录标题 + 点击添加标题 | 右侧：四个猫头图标内容块',
        isImage: true
      },
      { 
        title: '内容页1', 
        content: '点击添加标题',
        preview: '/src/assets/ppt/cat/h3.png',
        description: '带尾巴的黑色猫咪和天使光环猫咪，适合内容展示',
        color: '#f59e0b',
        details: '右上角：带尾巴的黑色猫咪 | 左侧：带光环的天使猫咪',
        isImage: true
      },
      { 
        title: '内容页2', 
        content: '点击添加标题',
        preview: '/src/assets/ppt/cat/h4.png',
        description: '阴阳猫图案设计，两只猫形成太极图，创意十足',
        color: '#8b5cf6',
        details: '左侧：阴阳猫太极图 | 右侧：标题、小鱼图标和文本',
        isImage: true
      },
      { 
        title: '总结页', 
        content: '要点总结',
        preview: '/src/assets/ppt/cat/h5.png',
        description: '简洁的总结页面设计，突出要点',
        color: '#ef4444',
        details: '要点总结布局，清晰明了',
        isImage: true
      }
    ]
  }
]

// 模板场景分类
export const templateScenes = [
  { id: 'all', name: '全部场景', icon: '🌟' },
  { id: 'education', name: '教育培训', icon: '🎓' }
]

// 模板风格分类
export const templateStyles = [
  { id: 'all', name: '全部风格', icon: '✨' },
  { id: 'cute', name: '可爱风格', icon: '🐱' }
]

// 根据场景和风格筛选模板
export const filterTemplates = (scene = 'all', style = 'all') => {
  return pptTemplates.filter(template => {
    const sceneMatch = scene === 'all' || template.scene === scene
    const styleMatch = style === 'all' || template.style === style
    return sceneMatch && styleMatch
  })
}
