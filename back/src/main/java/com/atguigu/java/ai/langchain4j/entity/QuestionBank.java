package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import org.springframework.data.annotation.Id;

import java.time.LocalDateTime;

@Data
@TableName("question_bank")
public class QuestionBank {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long courseId;
    private String type;  // 'choice','short_answer','programming'
    private String content;
    private String answer;
    private String knowledgePoint;
    private String difficultyLevel; // 'easy', 'medium', 'hard'
    private Long categoryId; // 题库分类ID
    private Integer estimatedTimeMinutes; // 预估答题时间(分钟)
    private String tags; // 题目标签，用逗号分隔
    private Boolean isAiGenerated; // 是否AI生成
    private String generationPrompt; // AI生成提示词
    private Double qualityScore; // 题目质量评分
    private Long createdBy;
    private LocalDateTime createdAt;
}
