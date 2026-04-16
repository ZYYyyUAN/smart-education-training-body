package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

@Data
public class EvaluateRequest2 {
    Long memoryId;
    private String content;
    private String standardAnswer;     // 前端传回来的标准答案
    private String answer;  // 学生答案
}
