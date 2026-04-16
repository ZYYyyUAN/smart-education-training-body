package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@TableName("assignment_submission_detail")
public class AssignmentSubmissionDetail implements Serializable {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long submissionId;
    private Long questionId;
    private String answerText;
    private Integer score;
    private Boolean isCorrect;
    private String errorReason;

    // 以下字段不映射到数据库，用于返回题目完整信息
    @TableField(exist = false)
    private String content;  // 题目内容
    @TableField(exist = false)
    private String type;     // 题目类型
    @TableField(exist = false)
    private String answer;   // 正确答案
    @TableField(exist = false)
    private String knowledgePoint;  // 知识点
    @TableField(exist = false)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime submittedAt;  // 提交时间
}
