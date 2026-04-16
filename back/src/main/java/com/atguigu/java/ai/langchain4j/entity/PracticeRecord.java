package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
public class PracticeRecord {
    private Long id;
    private Long studentId;
    private Long courseId;
    private Integer totalQuestions;
    private Integer correctCount;
    private Integer wrongCount;
    private Integer unansweredCount;
    private Integer accuracyRate;
    private String practiceType;
    private LocalDateTime practiceDate;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    
    // 用于前端显示的题目详情
    private List<Map<String, Object>> questionDetails;
}
 