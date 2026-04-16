package com.atguigu.java.ai.langchain4j.assistant;

import dev.langchain4j.service.UserMessage;
import dev.langchain4j.service.V;
import dev.langchain4j.service.spring.AiService;

import static dev.langchain4j.service.spring.AiServiceWiringMode.EXPLICIT;

/**
 * 自动组卷AI助手
 */
@AiService(
    wiringMode = EXPLICIT,
    chatModel = "qwenChatModel"
)
public interface AutoExamAgent {
    
    /**
     * 智能组卷策略生成
     */
    @UserMessage("""
    请根据以下要求智能生成试卷配置和题目选择建议：
    
    课程信息：
    - 课程ID：{{courseId}}
    - 课程名称：{{courseName}}
    - 知识点列表：{{knowledgePoints}}
    
    组卷要求：
    - 总题数：{{totalQuestions}}
    - 题型分布：{{questionTypeDistribution}}
    - 难度分布：{{difficultyDistribution}}
    - 考试时长：{{timeLimit}}分钟
    
    现有题库统计：
    - 选择题：{{choiceCount}}道
    - 简答题：{{shortAnswerCount}}道  
    - 编程题：{{programmingCount}}道
    
    请严格按照以下JSON格式返回组卷建议：
    {
      "strategy": "组卷策略说明",
      "questionSelection": [
        {
          "questionId": 题目ID,
          "reason": "选择该题的原因",
          "difficulty": 难度等级,
          "estimatedTime": 预估答题时间,
          "knowledgePoint": "关联知识点"
        }
      ],
      "qualityAssessment": {
        "overallScore": 总体质量评分,
        "difficultyBalance": 难度平衡性,
        "knowledgeCoverage": 知识点覆盖率,
        "timeDistribution": 时间分布合理性
      },
      "suggestions": "优化建议"
    }
    """)
    String generateExamStrategy(@V("courseId") Long courseId,
                               @V("courseName") String courseName,
                               @V("knowledgePoints") String knowledgePoints,
                               @V("totalQuestions") Integer totalQuestions,
                               @V("questionTypeDistribution") String questionTypeDistribution,
                               @V("difficultyDistribution") String difficultyDistribution,
                               @V("timeLimit") Integer timeLimit,
                               @V("choiceCount") Integer choiceCount,
                               @V("shortAnswerCount") Integer shortAnswerCount,
                               @V("programmingCount") Integer programmingCount);
    
    /**
     * 基于选中知识点的智能组卷
     */
    @UserMessage("""
    请根据以下要求基于选中的知识点智能生成试卷：
    
    课程信息：
    - 课程ID：{{courseId}}
    - 课程名称：{{courseName}}
    
    选中的知识点：
    {{selectedKnowledgePoints}}
    
    组卷要求：
    - 试卷标题：{{examTitle}}
    - 试卷描述：{{examDescription}}
    - 总题数：{{totalQuestions}}
    - 题型分布：{{questionTypeDistribution}}
    - 难度分布：{{difficultyDistribution}}
    - 考试时长：{{timeLimit}}分钟
    - 生成策略：{{generationStrategy}}
    
    请严格按照以下JSON格式返回组卷结果：
    {
      "strategy": "基于选中知识点的组卷策略说明",
      "questionSelection": [
        {
          "questionId": 题目ID,
          "reason": "选择该题的原因",
          "difficulty": 难度等级,
          "estimatedTime": 预估答题时间,
          "knowledgePoint": "关联知识点",
          "aiSelectionReason": "AI选择该题的具体原因"
        }
      ],
      "knowledgePointCoverage": {
        "coveredPoints": ["已覆盖的知识点1", "已覆盖的知识点2"],
        "coverageRate": 知识点覆盖率百分比
      },
      "qualityAssessment": {
        "overallScore": 总体质量评分,
        "difficultyBalance": 难度平衡性,
        "knowledgeCoverage": 知识点覆盖率,
        "timeDistribution": 时间分布合理性
      },
      "suggestions": "优化建议"
    }
    """)
    String generateExamBySelectedKnowledge(@V("courseId") Long courseId,
                                         @V("courseName") String courseName,
                                         @V("selectedKnowledgePoints") String selectedKnowledgePoints,
                                         @V("examTitle") String examTitle,
                                         @V("examDescription") String examDescription,
                                         @V("totalQuestions") Integer totalQuestions,
                                         @V("questionTypeDistribution") String questionTypeDistribution,
                                         @V("difficultyDistribution") String difficultyDistribution,
                                         @V("timeLimit") Integer timeLimit,
                                         @V("generationStrategy") String generationStrategy);
    
    /**
     * 基于题库中的实际题目进行智能组卷
     */
    @UserMessage("""
    请根据以下要求从题库中选择题目进行智能组卷：
    
    课程信息：
    - 课程ID：{{courseId}}
    - 课程名称：{{courseName}}
    
    选中的知识点：
    {{selectedKnowledgePoints}}
    
    组卷要求：
    - 试卷标题：{{examTitle}}
    - 试卷描述：{{examDescription}}
    - 总题数：{{totalQuestions}}
    - 题型分布：{{questionTypeDistribution}}
    - 难度分布：{{difficultyDistribution}}
    - 考试时长：{{timeLimit}}分钟
    - 生成策略：{{generationStrategy}}
    
    可用题库数据：
    {{questionBankData}}
    
    重要说明：
    1. 必须从提供的题库数据中选择题目，不能生成新题目
    2. 如果题库中没有足够的题目，请说明原因并建议补充题库
    3. 严格按照要求的题型分布和难度分布选择题目
    4. 返回的JSON格式必须正确，不要包含markdown代码块
    
    请严格按照以下JSON格式返回组卷结果（不要包含```json标记）：
    {
      "strategy": "基于题库题目的组卷策略说明",
      "questionSelection": [
        {
          "questionId": 题目ID,
          "reason": "选择该题的原因",
          "difficulty": 难度等级(1-5),
          "estimatedTime": 预估答题时间(分钟),
          "knowledgePoint": "关联知识点",
          "aiSelectionReason": "AI选择该题的具体原因"
        }
      ],
      "knowledgePointCoverage": {
        "coveredPoints": ["已覆盖的知识点1", "已覆盖的知识点2"],
        "coverageRate": 知识点覆盖率百分比
      },
      "qualityAssessment": {
        "overallScore": 总体质量评分(0-100),
        "difficultyBalance": 难度平衡性评分(0-100),
        "knowledgeCoverage": 知识点覆盖率评分(0-100),
        "timeDistribution": 时间分布合理性评分(0-100)
      },
      "suggestions": "优化建议"
    }
    """)
    String generateExamFromQuestionBank(@V("courseId") Long courseId,
                                      @V("courseName") String courseName,
                                      @V("selectedKnowledgePoints") String selectedKnowledgePoints,
                                      @V("examTitle") String examTitle,
                                      @V("examDescription") String examDescription,
                                      @V("totalQuestions") Integer totalQuestions,
                                      @V("questionTypeDistribution") String questionTypeDistribution,
                                      @V("difficultyDistribution") String difficultyDistribution,
                                      @V("timeLimit") Integer timeLimit,
                                      @V("generationStrategy") String generationStrategy,
                                      @V("questionBankData") String questionBankData);
    
    /**
     * 试卷质量评估
     */
    @UserMessage("""
    请对以下试卷进行质量评估：
    
    试卷信息：
    - 试卷标题：{{examTitle}}
    - 总题数：{{totalQuestions}}
    - 题型分布：{{questionTypeDistribution}}
    - 知识点分布：{{knowledgePointDistribution}}
    - 难度分布：{{difficultyDistribution}}
    
    题目详情：
    {{questionDetails}}
    
    请严格按照以下JSON格式返回评估结果：
    {
      "overallScore": 总体评分(0-100),
      "difficultyBalance": 难度平衡性评分(0-100),
      "knowledgeCoverage": 知识点覆盖率评分(0-100),
      "timeDistribution": 时间分布合理性评分(0-100),
      "questionDiversity": 题目多样性评分(0-100),
      "strengths": ["优势1", "优势2"],
      "weaknesses": ["不足1", "不足2"],
      "suggestions": "具体优化建议"
    }
    """)
    String assessExamQuality(@V("examTitle") String examTitle,
                            @V("totalQuestions") Integer totalQuestions,
                            @V("questionTypeDistribution") String questionTypeDistribution,
                            @V("knowledgePointDistribution") String knowledgePointDistribution,
                            @V("difficultyDistribution") String difficultyDistribution,
                            @V("questionDetails") String questionDetails);
    
    /**
     * 智能调整试卷
     */
    @UserMessage("""
    请根据以下要求智能调整试卷：
    
    原试卷信息：
    - 试卷ID：{{examId}}
    - 当前题目：{{currentQuestions}}
    
    调整要求：
    - 调整类型：{{adjustmentType}}
    - 具体需求：{{adjustmentRequirements}}
    
    可选题目库：
    {{availableQuestions}}
    
    请严格按照以下JSON格式返回调整建议：
    {
      "adjustmentStrategy": "调整策略说明",
      "questionChanges": [
        {
          "action": "add/remove/replace",
          "questionId": 题目ID,
          "reason": "调整原因",
          "newOrder": 新顺序
        }
      ],
      "qualityImpact": "质量影响评估",
      "suggestions": "进一步优化建议"
    }
    """)
    String adjustExam(@V("examId") Long examId,
                     @V("currentQuestions") String currentQuestions,
                     @V("adjustmentType") String adjustmentType,
                     @V("adjustmentRequirements") String adjustmentRequirements,
                     @V("availableQuestions") String availableQuestions);
}
