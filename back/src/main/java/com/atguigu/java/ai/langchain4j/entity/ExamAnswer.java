package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 考试答案记录实体
 */
@Data
@TableName("exam_answer")
public class ExamAnswer {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long examResultId;
    
    private Long questionId;
    
    private String studentAnswer;
    
    private String correctAnswer;
    
    private Boolean isCorrect;
    
    private Double score;
    
    private String aiFeedback; // AI对这道题的批阅反馈
    
    private LocalDateTime createdAt;
}
