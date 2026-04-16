package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 考试结果实体
 */
@Data
@TableName("exam_result")
public class ExamResult {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long examId;
    
    private Long studentId;
    
    private Integer totalQuestions;
    
    private Integer correctAnswers;
    
    private Integer wrongAnswers;
    
    private Double score;
    
    private String status; // submitted, graded, reviewed
    
    private String aiFeedback; // AI批阅反馈
    
    private LocalDateTime submittedAt;
    
    private LocalDateTime gradedAt;
    
    private LocalDateTime createdAt;
}
