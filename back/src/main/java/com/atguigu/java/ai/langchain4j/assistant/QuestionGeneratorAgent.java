package com.atguigu.java.ai.langchain4j.assistant;

import dev.langchain4j.service.UserMessage;
import dev.langchain4j.service.V;
import dev.langchain4j.service.spring.AiService;

import static dev.langchain4j.service.spring.AiServiceWiringMode.EXPLICIT;

/**
 * 题目生成AI助手
 */
@AiService(
    wiringMode = EXPLICIT,
    chatModel = "qwenChatModel"
)
public interface QuestionGeneratorAgent {
    
    /**
     * 根据知识点生成题目
     */
    @UserMessage("""
    请根据以下要求生成考核题目：
    
    课程信息：
    - 课程ID：{{courseId}}
    - 课程名称：{{courseName}}
    
    知识点要求：
    {{knowledgePoints}}
    
    生成要求：
    - 题目数量：{{questionCount}}
    - 题型分布：{{questionTypeDistribution}}
    - 难度分布：{{difficultyDistribution}}
    - 预估答题时间：{{estimatedTimeMinutes}}分钟
    
    请严格按照以下JSON格式返回生成的题目，不要加```json
    
    👉 重要：选择题的选项必须直接写在content字段中，格式如下：
    题目内容
    A. 选项A内容
    B. 选项B内容  
    C. 选项C内容
    D. 选项D内容
    
    {
      "questions": [
        {
          "type": "题目类型(choice/short_answer/programming)",
          "content": "题目内容（选择题需包含A、B、C、D选项）",
          "answer": "题目答案",
          "knowledgePoint": "关联知识点",
          "difficultyLevel": "难度等级(easy/medium/hard)",
          "estimatedTimeMinutes": 预估答题时间,
          "tags": "题目标签，用逗号分隔"
        }
      ],
      "generationSummary": {
        "totalQuestions": 总题目数,
        "typeDistribution": {"choice": 选择题数, "short_answer": 简答题数, "programming": 编程题数},
        "difficultyDistribution": {"easy": 简单题数, "medium": 中等题数, "hard": 困难题数},
        "knowledgePointCoverage": ["覆盖的知识点1", "覆盖的知识点2"]
      },
      "qualityAssessment": {
        "overallScore": 总体质量评分(0-100),
        "difficultyBalance": 难度平衡性,
        "knowledgeCoverage": 知识点覆盖率,
        "suggestions": "优化建议"
      }
    }
    """)
    String generateQuestions(@V("courseId") Long courseId,
                           @V("courseName") String courseName,
                           @V("knowledgePoints") String knowledgePoints,
                           @V("questionCount") Integer questionCount,
                           @V("questionTypeDistribution") String questionTypeDistribution,
                           @V("difficultyDistribution") String difficultyDistribution,
                           @V("estimatedTimeMinutes") Integer estimatedTimeMinutes);
    
    /**
     * 生成单个题目
     */
    @UserMessage("""
    请根据以下要求生成一个考核题目：
    
    知识点：{{knowledgePoint}}
    题目类型：{{questionType}}
    难度等级：{{difficultyLevel}}
    预估答题时间：{{estimatedTimeMinutes}}分钟
    
    请严格按照以下JSON格式返回：
    {
      "type": "题目类型",
      "content": "题目内容",
      "answer": "题目答案",
      "knowledgePoint": "关联知识点",
      "difficultyLevel": "难度等级",
      "estimatedTimeMinutes": 预估答题时间,
      "tags": "题目标签",
      "options": ["选项A", "选项B", "选项C", "选项D"],
      "explanation": "题目解析",
      "qualityScore": 质量评分(0-100)
    }
    """)
    String generateSingleQuestion(@V("knowledgePoint") String knowledgePoint,
                                @V("questionType") String questionType,
                                @V("difficultyLevel") String difficultyLevel,
                                @V("estimatedTimeMinutes") Integer estimatedTimeMinutes);
}
