package com.atguigu.java.ai.langchain4j.entity;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;

@Data
public class AiEvaluationResult {

    private Integer score;         // AI 评出的得分
    private Boolean isCorrect;     // 是否正确
    private String errorReason;    // 错误原因（如果有）

    // 用于从 AI 返回的 JSON 字符串中解析成实体对象
    public static AiEvaluationResult parse(String aiResponse) {
        try {
            // 去掉 Markdown 代码块标记
            String cleaned = aiResponse
                    .replaceAll("(?s)```json", "")  // 去除 ```json
                    .replaceAll("(?s)```", "")       // 去除 ```
                    .trim();

            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(cleaned, AiEvaluationResult.class);
        } catch (Exception e) {
            // 打日志，方便调试
            System.err.println("AI评分解析失败，原始内容：\n" + aiResponse);
            e.printStackTrace();

            // 默认兜底：如果 AI 返回内容非标准格式，使用默认值
            AiEvaluationResult fallback = new AiEvaluationResult();
            fallback.setScore(60); // 默认60分
            fallback.setIsCorrect(false);
            fallback.setErrorReason("AI评分解析失败");
            return fallback;
        }
    }
}