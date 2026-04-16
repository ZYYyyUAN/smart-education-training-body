package com.atguigu.java.ai.langchain4j.assistant;
import dev.langchain4j.service.*;
import dev.langchain4j.service.spring.AiService;
import reactor.core.publisher.Flux;
import java.util.List;
import java.util.Map;

import static dev.langchain4j.service.spring.AiServiceWiringMode.EXPLICIT;
@AiService(
wiringMode = EXPLICIT,
        streamingChatModel = "qwenStreamingChatModel",
        chatModel = "qwenChatModel", // 👈 显式指定非流式模型
chatMemoryProvider = "chatMemoryProviderXiaozhi",
//        tools = "appointmentTools",
        contentRetriever = "contentRetrieverXiaozhiPincone")
public interface XiaozhiAgent {
@SystemMessage(fromResource = "xiaozhi-xuexi.txt")
Flux<String> chat(@MemoryId Long memoryId, @UserMessage String userMessage);

    // 直接使用已拼接好的提示词进行回答（不使用系统提示词）
    Flux<String> answerWithPrompt(@UserMessage String prompt);

    // 🎯 文档内容概括生成
    @UserMessage("""
请分析以下文档内容，生成一个详细的内容概括：

文件名：{{fileName}}
文档内容：{{content}}

要求：
1. 概括要全面、准确，突出文档的核心要点
2. 按照逻辑结构组织内容
3. 使用清晰的语言表达
4. 如果内容较长，可以分段概括
5. 请使用中文回答，确保输出内容清晰可读
6. 越精简越好
请开始分析并生成概括：
""")
    Flux<String> generateDocumentSummary(@V("fileName") String fileName, @V("content") String content);

    // 🎯 文档内容摘要生成
    @UserMessage("""
请为以下文档生成一个简洁的内容摘要：

文件名：{{fileName}}
文档内容：{{content}}

要求：
1. 摘要要简洁明了，突出关键信息
2. 保持原文的核心观点和重要细节
3. 使用精炼的语言，避免冗余
4. 摘要长度控制在原文的20%以内
5. 请使用中文回答，确保输出内容清晰可读

请生成摘要：
""")
    Flux<String> generateDocumentDigest(@V("fileName") String fileName, @V("content") String content);
    // 🎯 练习题目生成
    @UserMessage("""
请根据以下要求生成题目，并严格返回 JSON 格式的数组：

- 题型：{{type}}
- 知识点：{{weakPoints}}
- 数量：{{count}}

👉 重要：必须严格按照传入的题型参数生成题目！
- 如果type是"choice"，必须生成选择题，包含A、B、C、D四个选项
- 如果type是"short_answer"，必须生成简答题，不需要选项
- 如果type是"programming"，必须生成编程题

👉 JSON 数组中每个对象格式如下（必须完全符合）：

{
  "type": "{{type}}",
  "content": "题干内容，选择题要写上选项A、B、C、D",
  "answer": "标准答案",
  "knowledgePoint": "前面加上用户薄弱知识点："
}

请只返回 JSON，不要添加任何解释或前后缀。
""")
    String generatePracticeStructured(@V("weakPoints") String weakPoints,
                                      @V("type") String type,
                                      @V("count") int count);


    // 🎯 学生答案评测
    @UserMessage("""
以下是学生的作答内容，请进行评分与纠错：
题目：{{question}}
标准答案：{{standardAnswer}}
学生答案：{{answer}}
请判断学生答案是否正确，给出评分（百分制），指出错误并给出建议答案。
""")
    Flux<String> evaluatePractice(@MemoryId Long memoryId,
                                  @V("question") String question,
                                  @V("standardAnswer") String standardAnswer,
                                  @V("answer") String answer);
    @UserMessage("""
请以JSON对象格式输出评分结果，不要加```json，格式如下：
{"score": 数值, "feedback": "字符串反馈"}
字符串反馈不要太多100字以内就行，要求解析详细题目思路并且分析学生作答
以下是学生的作答内容：
题目：{{question}}
标准答案：{{standardAnswer}}
学生答案：{{answer}}

请判断学生答案是否正确，给出评分（百分制0-100），指出错误并给出建议答案。
""")
    String evaluatePracticeRawJson(
            @MemoryId Long memoryId,
            @V("question") String question,
            @V("standardAnswer") String standardAnswer,
            @V("answer") String answer
    );

    // 流式版本（保留兼容）
    @UserMessage("""
    这是课程的大纲内容：
    {{outline}}
    
    请根据大纲为这门课程生成教学计划，包含教学目标、知识点分布、教学时间安排。
    要求结构清晰，适合教师教学参考。不要生成json格式，然后多加点表情
    """)
    Flux<String> generateLessonPlanStream(@V("outline") String outline);

    // 结构化 JSON 版本（严格提示词 + 禁止代码块/额外文本）
    @UserMessage("""
    下面是课程大纲内容：
    {{outline}}

    任务：请基于该大纲，生成“教学计划”的 JSON 对象，必须严格只返回如下 5 个中文键，且顺序不限：
    {
      "教学目标": "分点描述教学目标，可用1. 2. 3. 编号或换行",
      "知识点分布": "按照章节或主题分组列出知识点，可用短标题+要点",
      "教学时间安排": "按课时/周次列出时间与主题，如 第1-2课时：xxx",
      "教学建议": "给出教学方法、工具与注意事项，可结合学情给建议",
      "结语": "简短收束与鼓励"
    }
    - 只返回 JSON 对象，不要任何解释、前后缀或代码块标记，不要使用 ```json 代码块。
    - 字段值可包含换行与编号，便于在前端渲染。
    """)
    String generateLessonPlanJson(@V("outline") String outline);
    @SystemMessage(fromResource = "timu.txt")
   String generateQuestions(String prompt);



    @UserMessage("""
请根据以下学生作答历史，总结该生的知识掌握情况与教学建议：
{{history}}
要求结构如下：
【知识掌握情况】xxx
【教学建议】xxx
""")
    String analyzeOverall(@V("history") String history);



    @UserMessage("""
以下是学生的作答内容，请进行评分与纠错：

题目：{{question}}
标准答案：{{standardAnswer}}
学生答案：{{answer}}

请判断学生答案是否正确，指出错误原因，并给出评分。

👉 请严格按照以下 JSON 格式返回，不要有多余解释或文字：

{
  "score": 80,
  "isCorrect": true,
  "errorReason": "略有表述不清，但核心内容正确"
}

- score：请给出 0 到 100 之间的整数分数。
- isCorrect：布尔类型，true 表示正确，false 表示错误。
- errorReason：如果答案错误，简要说明原因；若正确请写“无错误”。
""")
    String evaluatePracticeSync(@V("question") String question,
                                @V("answer") String answer,
                                @V("standardAnswer") String standardAnswer);
    // 🎯 返回结构化题目列表（便于后续保存入库）
    @UserMessage("""
请根据以下要求生成题目，并严格返回 JSON 格式的数组，不要带任何反引号，不要加上```json，就只返回json数组就行

- 题型：{{type}}
- 知识点：{{knowledgePoint}}
- 数量：{{count}}

👉 重要：必须严格按照传入的题型参数生成题目！
- 如果type是"choice"，必须生成选择题，包含A、B、C、D四个选项
- 如果type是"short_answer"，必须生成简答题，不需要选项
- 如果type是"programming"，必须生成编程题

👉 JSON 数组中每个对象格式如下（必须完全符合）：

{
  "type": "{{type}}",
  "content": "题干内容\nA. 选项A内容\nB. 选项B内容\nC. 选项C内容\nD. 选项D内容",
  "answer": "标准答案",
  "knowledgePoint": "所属知识点"
}

👉 重要：选择题的content必须包含完整的题目和选项，格式如下：
题目内容
A. 选项A内容
B. 选项B内容
C. 选项C内容
D. 选项D内容

请只返回 JSON，不要添加任何解释或前后缀。
""")
    String generateQuestionsByRequirement(@V("type") String type,
                                          @V("knowledgePoint") String knowledgePoint,
                                          @V("count") int count);


    @UserMessage("""
        请根据以下题目生成{{count}}道相似题目，保持相同的知识点和题型：
        原题：{{originalQuestion}}
        原题答案：{{originalAnswer}}
        知识点：{{knowledgePoint}}
        题型：{{questionType}}
        
        👉 重要：必须严格按照原题题型生成题目！
        - 如果原题是选择题，必须生成选择题，包含A、B、C、D四个选项
        - 如果原题是简答题，必须生成简答题，不需要选项
        - 如果原题是编程题，必须生成编程题
        
        👉 请严格按照以下JSON数组格式返回，不要有多余解释或文字：
        [
          {
            "type": "{{questionType}}",
            "content": "题干内容，选择题要写上选项A、B、C、D",
            "answer": "标准答案",
            "knowledgePoint": "知识点，必须与原题相同"
          },
          ...
        ]
        """)
    String generateSimilarQuestions(@V("originalQuestion") String originalQuestion,
                                    @V("originalAnswer") String originalAnswer,
                                    @V("knowledgePoint") String knowledgePoint,
                                    @V("questionType") String questionType,
                                    @V("count") int count);


    @SystemMessage(fromResource = "xiaozhi-xuexi2.txt")
    Flux<String> chat2(@MemoryId Long memoryId, @UserMessage String userMessage);
    
    @SystemMessage("你是校园心情助手。目标：以专业、温和的方式疏导同学情绪，并就学习进行轻松交流。风格：同理、积极、尊重，不过度说教。输出要求：每次回答不超过4句，优先给出1–2条可执行的小建议，并以一个简短的开放式问题结尾。边界：不提供医疗/心理诊断或法律建议，不讨论危险行为；如出现危机信号，请建议立即联系学校心理咨询中心或可信任的成年人。语言：使用自然、得体的中文。")
    Flux<String> chat3(@MemoryId Long memoryId, @UserMessage String userMessage);
    
    // 🎯 教师AI助手接口
    @SystemMessage("你是专业的教师AI助手，专门为教师提供教学支持。你的主要职责包括：\n" +
            "1. 课程规划与优化建议\n" +
            "2. 作业题目智能生成指导\n" +
            "3. 学生学习数据分析解读\n" +
            "4. 个性化教学策略建议\n" +
            "5. 教学资源推荐\n" +
            "6. 教学方法改进建议\n" +
            "7. 学生成绩分析指导\n" +
            "8. 课堂管理建议\n\n" +
            "回答要求：\n" +
            "- 专业、准确、实用\n" +
            "- 语言简洁明了\n" +
            "- 提供具体可操作的建议\n" +
            "- 结合教学实际经验\n" +
            "- 适当使用表情符号增加亲和力\n" +
            "- 每次回答控制在200字以内\n" +
            "- 如果问题超出教学范围，礼貌地引导到相关话题")
    Flux<String> teacherAssistant(@MemoryId Long memoryId, @UserMessage String userMessage);

    // ====== AI写作助手相关接口 ======
    
    // 🎯 AI识别 - 分析主题和内容要求
    @UserMessage("""
    请分析以下写作需求，提取关键信息并生成结构化分析结果：
    
    主题：{{topic}}
    内容要求：{{contentRequirement}}
    
    请按照以下JSON格式返回分析结果，不要添加任何解释或前后缀，不要在前面加```json：
    {
      "documentType": "识别出的文档类型（如：教学方案、课程大纲、学习总结等）",
      "targetAudience": "目标受众（如：学生、教师、家长等）",
      "keyPoints": ["关键要点1", "关键要点2", "关键要点3"],
      "suggestedStructure": "建议的文档结构类型",
      "estimatedWordCount": "预估字数范围",
      "writingStyle": "建议的写作风格（如：正式、学术、通俗易懂等）"
    }
    """)
    String analyzeWritingRequirement(@MemoryId Long memoryId, @V("topic") String topic, @V("contentRequirement") String contentRequirement);
    
    // 🎯 标题生成 - 根据分析结果生成大纲标题
    @UserMessage("""
    根据以下信息生成文档大纲标题：
    
    主题：{{topic}}
    文档类型：{{documentType}}
    关键要点：{{keyPoints}}
    内容要求：{{contentRequirement}}
    
    要求：
    1. 生成5-8个主要标题，形成完整的文档结构
    2. 标题要有逻辑性和层次性
    3. 符合{{documentType}}的常规结构
    4. 标题简洁明了，便于理解和编辑
    
    请严格按照以下JSON数组格式返回，不要添加任何解释或前后缀，不要在前面生成```json：
    [
      {
        "order": 1,
        "title": "标题内容",
        "description": "该部分的简要说明"
      },
      {
        "order": 2,
        "title": "标题内容",
        "description": "该部分的简要说明"
      }
    ]
    """)
    String generateOutlineTitles(@MemoryId Long memoryId,
                                @V("topic") String topic, 
                                @V("documentType") String documentType,
                                @V("keyPoints") String keyPoints,
                                @V("contentRequirement") String contentRequirement);
    
    // 🎯 全文生成 - 根据标题生成完整文档（流式）
    @UserMessage("""
    请根据以下信息生成完整的文档内容：
    
    主题：{{topic}}
    文档类型：{{documentType}}
    大纲标题（JSON格式）：{{outlineTitles}}
    内容要求：{{contentRequirement}}
    预估字数：{{estimatedWordCount}}
    写作风格：{{writingStyle}}
    
    🎯 重要要求：
    1. 必须严格按照大纲标题的order顺序生成内容，不得遗漏任何标题
    2. 每个标题都要作为文档的一级标题（使用 # 标题名称）
    3. 每个标题下必须生成不少于200字的详细内容
    4. 内容要与标题高度相关，体现标题的description要求
    5. 保持{{writingStyle}}的写作风格，内容专业准确
    6. 使用markdown格式，包括：标题(#)、段落、列表(-)等
    7. 总字数控制在{{estimatedWordCount}}范围内
    8. 各部分内容要有逻辑连贯性
    
    生成格式示例：
    # 第一个标题
    详细内容...
    
    # 第二个标题  
    详细内容...
    
    请严格按照大纲顺序生成完整文档：
    """)
    Flux<String> generateFullDocument(@MemoryId Long memoryId,
                                     @V("topic") String topic,
                                     @V("documentType") String documentType,
                                     @V("outlineTitles") String outlineTitles,
                                     @V("contentRequirement") String contentRequirement,
                                     @V("estimatedWordCount") String estimatedWordCount,
                                     @V("writingStyle") String writingStyle);
    
    // 🎯 单个标题内容生成 - 为特定标题生成详细内容
    @UserMessage("""
    请为以下标题生成详细内容：
    
    文档主题：{{topic}}
    当前标题：{{currentTitle}}
    标题描述：{{titleDescription}}
    上下文信息：{{contextInfo}}
    字数要求：{{wordCountRequirement}}
    
    要求：
    1. 内容要与标题高度匹配
    2. 保持专业性和准确性
    3. 内容结构清晰，有条理
    4. 字数控制在{{wordCountRequirement}}左右
    5. 可以包含适当的小标题和要点
    
    请生成该标题的详细内容：
    """)
    Flux<String> generateTitleContent(@V("topic") String topic,
                                     @V("currentTitle") String currentTitle,
                                     @V("titleDescription") String titleDescription,
                                     @V("contextInfo") String contextInfo,
                                     @V("wordCountRequirement") String wordCountRequirement);
    
    // 🎯 标题智能补充 - 根据已有标题智能补充新标题
    @UserMessage("""
    根据现有大纲结构，智能补充新的标题：
    
    文档主题：{{topic}}
    文档类型：{{documentType}}
    现有标题：{{existingTitles}}
    内容要求：{{contentRequirement}}
    
    要求：
    1. 分析现有标题结构，找出可能缺失的部分
    2. 建议3-5个补充标题
    3. 新标题要与现有结构协调
    4. 保持逻辑性和完整性
    
    请严格按照以下JSON数组格式返回建议标题：
    [
      {
        "suggestedOrder": 3,
        "title": "建议标题内容",
        "reason": "添加此标题的原因",
        "description": "该部分的简要说明"
      }
    ]
    """)
    String suggestAdditionalTitles(@V("topic") String topic,
                                  @V("documentType") String documentType,
                                  @V("existingTitles") String existingTitles,
                                  @V("contentRequirement") String contentRequirement);

    // ====== AI问答相关接口 ======
    
    // 🎯 基于文档内容的智能问答
    @UserMessage("""
    请基于以下文档内容回答用户的问题：
    
    文档内容：{{documentContent}}
    用户问题：{{question}}
    文档名称：{{fileName}}
    
    要求：
    1. 答案必须基于文档内容，不要编造信息
    2. 如果文档中没有相关信息，请明确说明
    3. 回答要准确、详细，有条理
    4. 使用中文回答，语言自然流畅
    5. 可以适当引用文档中的原文
    6. 如果问题涉及多个方面，请分点回答
    
    请开始回答：
    """)
    Flux<String> answerDocumentQuestion(@V("prompt")String prompt);
    
    // 🎯 基于文档的问答（结构化）
    @UserMessage("""
    基于文档内容回答问题：
    
    问题：{{question}}
    文档内容：{{documentContent}}
    文档名称：{{fileName}}
    
    要求：
    1. 请直接回答用户的问题，不要生成题目格式（如【题型】、【题干】、【答案】、【知识点】等）
    2. 你的任务是解答疑问和提供学习指导，不是出题
    3. 回答应该是对话式的，自然流畅的文本
    4. 答案必须基于文档内容，不要编造信息
    5. 如果文档中没有相关信息，请明确说明
    6. 回答要准确、详细，有条理
    7. 使用中文回答，语言自然流畅
    8. 可以适当引用文档中的原文
    9. 如果问题涉及多个方面，请分点回答
    
    请开始回答：
    """)
    Flux<String> answerDocumentBasedQuestion(@V("question") String question,
                                           @V("documentContent") String documentContent,
                                           @V("fileName") String fileName);
    
    // 🎯 生成快速问题建议
    @UserMessage("""
    基于以下信息生成4-6个快速问题建议：
    
    文档类型：{{documentType}}
    文档名称：{{fileName}}
    
    要求：
    1. 问题要有针对性，适合该文档类型
    2. 问题要有层次性，从浅到深
    3. 包含不同类型的问题（概括、分析、应用等）
    4. 每个问题前加上合适的emoji图标
    5. 问题要简洁明了，便于用户选择
    
    请严格按照以下JSON数组格式返回：
    ["📋 问题1", "🔍 问题2", "💡 问题3", "📊 问题4"]
    """)
    List<String> generateQuickQuestions(@V("documentType") String documentType, 
                                       @V("fileName") String fileName);
    
    // 🎯 问答历史分析
    @UserMessage("""
    请分析以下问答历史，总结用户的学习情况和关注点：
    
    问答历史：{{chatHistory}}
    文档名称：{{documentName}}
    
    要求：
    1. 分析用户主要关注的知识点
    2. 评估用户的理解程度
    3. 识别学习难点和疑惑点
    4. 提供针对性的学习建议
    5. 语言简洁明了，有条理
    
    分析格式：
    【主要关注点】xxx
    【理解程度】xxx
    【学习难点】xxx
    【学习建议】xxx
    """)
    String analyzeQaHistory(@V("chatHistory") List<Map<String, String>> chatHistory,
                           @V("documentName") String documentName);

    // ====== AI学习笔记相关接口 ======
    
    // 🎯 AI生成学习笔记
    @UserMessage("""
    请基于以下文档内容生成学习笔记：
    
    文档名称：{{fileName}}
    文档内容：{{documentContent}}
    
    要求：
    1. 结构清晰，层次分明
    2. 内容准确，重点突出
    3. 使用markdown格式
    4. 适当使用列表和标题
    5. 语言简洁易懂
    6. 生成综合性学习笔记，包含摘要、关键概念、重要知识点等
    
    请生成学习笔记：
    """)
    Flux<String> generateStudyNotes(@V("fileName") String fileName,
                                   @V("documentContent") String documentContent);
    
    // 🎯 AI优化笔记内容
    @UserMessage("""
    请优化以下学习笔记：
    
    笔记标题：{{title}}
    笔记内容：{{content}}
    优化类型：{{optimizationType}}
    
    根据优化类型进行相应处理：
    - structure: 优化结构和层次
    - language: 改进语言表达
    - content: 补充和完善内容
    - format: 优化格式和排版
    
    要求：
    1. 保持原有核心内容不变
    2. 提升可读性和逻辑性
    3. 使用恰当的markdown格式
    4. 突出重点内容
    
    请提供优化后的笔记：
    """)
    Flux<String> optimizeNotes(@V("title") String title,
                              @V("content") String content,
                              @V("optimizationType") String optimizationType);
    
    // 🎯 生成笔记摘要
    @UserMessage("""
    请为以下笔记生成简洁的摘要：
    
    笔记标题：{{title}}
    笔记内容：{{content}}
    
    要求：
    1. 摘要长度控制在100-200字
    2. 突出核心要点
    3. 语言简洁明了
    4. 保持逻辑性
    
    请生成摘要：
    """)
    String generateNotesSummary(@V("title") String title,
                               @V("content") String content);
    
    // 🎯 生成笔记标签
    @UserMessage("""
    请为以下笔记生成3-5个相关标签：
    
    笔记标题：{{title}}
    笔记内容：{{content}}
    
    要求：
    1. 标签要准确反映笔记内容
    2. 包含主题、类型、难度等维度
    3. 标签简洁明了，2-4个字
    4. 便于分类和检索
    
    请严格按照以下JSON数组格式返回：
    ["标签1", "标签2", "标签3"]
    """)
    List<String> generateNotesTags(@V("title") String title,
                                  @V("content") String content);
    
    // 🎯 提取知识点
    @UserMessage("""
    请从以下笔记中提取主要知识点：
    
    笔记标题：{{title}}
    笔记内容：{{content}}
    
    要求：
    1. 识别并列出3-8个主要知识点
    2. 每个知识点用简洁的语言描述
    3. 按重要性排序
    4. 使用项目符号格式
    
    提取格式：
    • 知识点1：描述
    • 知识点2：描述
    • 知识点3：描述
    """)
    String extractKnowledgePoints(@V("title") String title,
                                 @V("content") String content);
    
    // 🎯 笔记关联推荐
    @UserMessage("""
    基于以下笔记内容，推荐相关的学习内容和资源：
    
    笔记标题：{{title}}
    笔记内容：{{content}}
    
    要求：
    1. 推荐相关的学习主题
    2. 建议进一步学习的方向
    3. 推荐相关的学习资源类型
    4. 提供学习方法建议
    
    推荐格式：
    【相关主题】xxx
    【学习方向】xxx
    【推荐资源】xxx
    【学习建议】xxx
    """)
    String generateNotesRecommendations(@V("title") String title,
                                       @V("content") String content);
    
    // 🎯 笔记结构分析
    @UserMessage("""
    请分析以下笔记的结构和质量：
    
    笔记标题：{{title}}
    笔记内容：{{content}}
    
    要求：
    1. 分析笔记的结构合理性
    2. 评估内容的完整性
    3. 识别可改进的地方
    4. 提供优化建议
    
    分析格式：
    【结构分析】xxx
    【内容评估】xxx
    【改进建议】xxx
    """)
    String analyzeNotesStructure(@V("title") String title,
                                @V("content") String content);

    // ====== 思维导图相关接口 ======
    
    // 🎯 生成思维导图结构
    @UserMessage("""
    请基于以下文档内容生成思维导图结构：
    
    文档名称：{{fileName}}
    文档内容：{{documentContent}}
    导图类型：{{mapType}}
    
    根据导图类型生成相应结构：
    - hierarchical: 层次结构导图
    - radial: 放射状导图
    - concept: 概念导图
    - flowchart: 流程导图
    
    请严格按照以下JSON格式返回，不要添加任何解释或前后缀：
    {
      "name": "中心主题",
      "children": [
        {
          "name": "主分支1",
          "children": [
            {"name": "子节点1"},
            {"name": "子节点2"}
          ]
        },
        {
          "name": "主分支2",
          "children": [
            {"name": "子节点3"},
            {"name": "子节点4"}
          ]
        }
      ]
    }
    """)
    String generateMindMapStructure(@V("fileName") String fileName,
                                   @V("documentContent") String documentContent,
                                   @V("mapType") String mapType);
    
    // 🎯 优化思维导图结构
    @UserMessage("""
    请优化以下思维导图结构：
    
    当前结构：{{currentStructure}}
    优化类型：{{optimizationType}}
    
    根据优化类型进行处理：
    - balance: 平衡各分支的内容
    - detail: 增加详细信息
    - simplify: 简化结构
    - reorganize: 重新组织结构
    
    请返回优化后的JSON结构，格式与原结构保持一致。
    """)
    String optimizeMindMapStructure(@V("currentStructure") String currentStructure,
                                   @V("optimizationType") String optimizationType);
    
    // 🎯 生成节点详情
    @UserMessage("""
    请为思维导图节点生成详细说明：
    
    节点名称：{{nodeName}}
    节点上下文：{{nodeContext}}
    文档内容：{{documentContent}}
    
    要求：
    1. 基于文档内容解释该节点
    2. 提供相关的背景信息
    3. 说明与其他节点的关系
    4. 内容准确、简洁
    
    请生成节点详情：
    """)
    Flux<String> generateMindMapNodeDetails(@V("nodeName") String nodeName,
                                          @V("nodeContext") String nodeContext,
                                          @V("documentContent") String documentContent);
    
    // 🎯 扩展思维导图分支
    @UserMessage("""
    请扩展思维导图的指定分支：
    
    分支名称：{{branchName}}
    当前结构：{{currentStructure}}
    文档内容：{{documentContent}}
    
    要求：
    1. 基于文档内容为该分支添加2-4个子节点
    2. 子节点要与分支主题相关
    3. 保持逻辑性和层次性
    4. 返回扩展后的分支JSON结构
    
    请返回扩展后的分支结构：
    """)
    String expandMindMapBranch(@V("branchName") String branchName,
                              @V("currentStructure") String currentStructure,
                              @V("documentContent") String documentContent);
    
    // 🎯 生成思维导图摘要
    @UserMessage("""
    请基于思维导图结构生成内容摘要：
    
    思维导图结构：{{mindMapStructure}}
    文档名称：{{documentName}}
    
    要求：
    1. 概括思维导图的主要内容
    2. 突出关键节点和关系
    3. 语言简洁明了
    4. 长度控制在150-300字
    
    请生成摘要：
    """)
    String generateMindMapSummary(@V("mindMapStructure") String mindMapStructure,
                                 @V("documentName") String documentName);
    
    // 🎯 基于思维导图的学习建议
    @UserMessage("""
    请基于思维导图提供学习建议：
    
    思维导图结构：{{mindMapStructure}}
    学习者水平：{{learnerLevel}}
    文档内容：{{documentContent}}
    
    要求：
    1. 分析知识结构和难点
    2. 提供学习顺序建议
    3. 推荐学习方法
    4. 给出重点关注的节点
    
    建议格式：
    【学习路径】xxx
    【重点难点】xxx
    【学习方法】xxx
    【注意事项】xxx
    """)
    Flux<String> generateMindMapLearningSuggestions(@V("mindMapStructure") String mindMapStructure,
                                                   @V("learnerLevel") String learnerLevel,
                                                   @V("documentContent") String documentContent);
    
    // 🎯 分析思维导图节点关系
    @UserMessage("""
    请分析思维导图中节点之间的关联关系：
    
    思维导图结构：{{mindMapStructure}}
    
    要求：
    1. 识别重要的节点关联
    2. 分析知识点之间的逻辑关系
    3. 找出关键路径和依赖关系
    4. 提供关系优化建议
    
    分析格式：
    【主要关联】xxx
    【逻辑关系】xxx
    【关键路径】xxx
    【优化建议】xxx
    """)
    String analyzeMindMapRelationships(@V("mindMapStructure") String mindMapStructure);

    // ====== 相关资源推荐接口 ======
    
    // 🎯 智能推荐相关资源
    @UserMessage("""
    请基于以下文档信息推荐相关的学习资源：
    
    文档名称：{{fileName}}
    文档内容：{{documentContent}}
    资源类型：{{resourceType}}
    学科领域：{{subject}}
    
    要求：
    1. 推荐与文档内容相关的学习资源
    2. 包含不同类型的资源（文档、视频、练习等）
    3. 说明推荐理由
    4. 按相关性排序
    
    推荐格式：
    【推荐资源1】
    - 类型：xxx
    - 标题：xxx  
    - 推荐理由：xxx
    - 相关度：★★★★★
    
    【推荐资源2】
    - 类型：xxx
    - 标题：xxx
    - 推荐理由：xxx
    - 相关度：★★★★☆
    """)
    String recommendRelatedResources(@V("fileName") String fileName,
                                   @V("documentContent") String documentContent,
                                   @V("resourceType") String resourceType,
                                   @V("subject") String subject);
    
    // 🎯 生成资源搜索关键词
    @UserMessage("""
    请基于以下文档内容生成搜索关键词：
    
    文档内容：{{documentContent}}
    文档名称：{{fileName}}
    
    要求：
    1. 提取3-8个核心关键词
    2. 包含主题词、专业词汇、概念词
    3. 关键词要准确、具有代表性
    4. 适合用于资源搜索
    
    请严格按照以下JSON数组格式返回：
    ["关键词1", "关键词2", "关键词3"]
    """)
    List<String> generateResourceSearchKeywords(@V("documentContent") String documentContent,
                                               @V("fileName") String fileName);
    
    // 🎯 分析资源相关性
    @UserMessage("""
    请分析以下资源与文档的相关性：
    
    资源标题：{{resourceTitle}}
    资源描述：{{resourceDescription}}
    文档内容：{{documentContent}}
    
    要求：
    1. 评估资源与文档的相关程度
    2. 分析相关的知识点
    3. 说明资源的价值和用途
    4. 给出相关性评分（1-10分）
    
    分析格式：
    【相关性评分】x/10分
    【相关知识点】xxx
    【资源价值】xxx
    【使用建议】xxx
    """)
    String analyzeResourceRelevance(@V("resourceTitle") String resourceTitle,
                                   @V("resourceDescription") String resourceDescription,
                                   @V("documentContent") String documentContent);
    
    // 🎯 生成资源标签
    @UserMessage("""
    请为以下内容生成资源标签：
    
    文档内容：{{documentContent}}
    文档名称：{{fileName}}
    
    要求：
    1. 生成4-6个标签
    2. 包含学科、类型、难度、主题等维度
    3. 标签简洁明了
    4. 便于分类和检索
    
    请严格按照以下JSON数组格式返回：
    ["标签1", "标签2", "标签3"]
    """)
    List<String> generateResourceTags(@V("documentContent") String documentContent,
                                     @V("fileName") String fileName);
    
    // 🎯 评估资源质量
    @UserMessage("""
    请评估以下资源的质量：
    
    资源标题：{{resourceTitle}}
    资源内容：{{resourceContent}}
    资源类型：{{resourceType}}
    
    要求：
    1. 从内容质量、实用性、准确性等维度评估
    2. 给出综合评分（1-10分）
    3. 指出优点和不足
    4. 提供改进建议
    
    评估格式：
    【综合评分】x/10分
    【内容质量】xxx
    【实用性】xxx
    【优点】xxx
    【不足】xxx
    【改进建议】xxx
    """)
    String assessResourceQuality(@V("resourceTitle") String resourceTitle,
                                @V("resourceContent") String resourceContent,
                                @V("resourceType") String resourceType);
    
    // 🎯 资源分类建议
    @UserMessage("""
    请为以下资源建议合适的分类：
    
    资源标题：{{resourceTitle}}
    资源描述：{{resourceDescription}}
    
    要求：
    1. 分析资源的主要特征
    2. 建议主分类和子分类
    3. 说明分类依据
    4. 考虑多个分类维度
    
    分类建议格式：
    【主分类】xxx
    【子分类】xxx
    【分类依据】xxx
    【其他可能分类】xxx
    """)
    String suggestResourceCategorization(@V("resourceTitle") String resourceTitle,
                                        @V("resourceDescription") String resourceDescription);
    
    // 🎯 学习路径推荐
    @UserMessage("""
    请基于当前文档推荐学习路径：
    
    当前文档：{{currentDocument}}
    学习者水平：{{learnerLevel}}
    学科领域：{{subject}}
    
    要求：
    1. 分析当前学习状态
    2. 推荐后续学习内容
    3. 规划学习顺序
    4. 提供学习建议
    
    学习路径格式：
    【当前水平评估】xxx
    【前置知识】xxx
    【后续学习内容】xxx
    【学习顺序】xxx
    【学习建议】xxx
    """)
    String recommendLearningPath(@V("currentDocument") String currentDocument,
                                @V("learnerLevel") String learnerLevel,
                                @V("subject") String subject);

    // 🎯 AI智能学情分析
    @UserMessage("""
    请作为一位经验丰富的教育专家，对以下学生的学习情况进行全面、深入的AI智能分析。

    【学生基本信息】
    学生姓名：{{studentName}}
    学习积分：{{studyScore}}
    
    【登录记录趋势分析】
    {{loginTrend}}
    
    【作业成绩趋势分析】
    {{homeworkTrend}}
    
    【考试成绩趋势分析】
    {{examTrend}}
    
    【作业具体作答详情】
    {{homeworkDetails}}
    
    【考试具体作答详情】
    {{examDetails}}
    
    请从以下几个方面进行综合分析：
    
    1. **学习行为分析**
       - 登录频率和活跃度评估
       - 学习习惯分析（学习时间分布、学习持续性等）
       - 学习参与度评价
    
    2. **成绩表现分析**
       - 作业成绩趋势分析（进步/退步/稳定）
       - 考试成绩趋势分析
       - 成绩波动原因分析
       - 与班级平均水平的对比
    
    3. **知识掌握情况分析**
       - 根据作业和考试的具体作答情况，识别学生的知识薄弱点
       - 分析学生在哪些知识点上掌握较好，哪些需要加强
       - 评估学生的理解深度和应用能力
    
    4. **学习问题诊断**
       - 识别学习中的潜在问题（如：基础不牢、理解偏差、应用能力不足等）
       - 分析错误类型和错误原因
       - 评估学习态度和努力程度
    
    5. **个性化教学建议**
       - 针对性的学习改进建议
       - 推荐重点复习的知识点
       - 提供具体的学习方法和策略
       - 建议的学习计划和目标
    
    请以结构化的方式输出分析结果，使用以下格式：
    
    【学习行为评估】
    （分析学生的登录频率、学习活跃度、学习习惯等）
    
    【成绩表现分析】
    （分析成绩趋势、波动情况、与平均水平对比等）
    
    【知识掌握情况】
    （分析知识薄弱点、掌握较好的知识点、理解深度等）
    
    【学习问题诊断】
    （识别学习中的问题、错误类型、学习态度等）
    
    【个性化教学建议】
    （提供针对性的改进建议、学习方法、学习计划等）
    
    要求：
    1. 分析要客观、准确、深入
    2. 建议要具体、可操作、有针对性
    3. 语言要专业但易懂
    4. 重点关注学生的进步空间和改进方向
    5. 字数控制在800-1200字之间
    """)
    Flux<String> analyzeStudentLearning(@V("studentName") String studentName,
                                       @V("studyScore") Integer studyScore,
                                       @V("loginTrend") String loginTrend,
                                       @V("homeworkTrend") String homeworkTrend,
                                       @V("examTrend") String examTrend,
                                       @V("homeworkDetails") String homeworkDetails,
                                       @V("examDetails") String examDetails);
}