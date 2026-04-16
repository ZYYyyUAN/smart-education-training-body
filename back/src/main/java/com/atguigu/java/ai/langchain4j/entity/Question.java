package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

@Data
@TableName("question")
public class Question implements Serializable {

    @TableId(type = IdType.AUTO)
    private Integer id;

    private Integer courseId;

    private Integer userId;

    private String content;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    // 关联字段，不映射到数据库
    @TableField(exist = false)
    private String userName;

    @TableField(exist = false)
    private String userUniversity;

    @TableField(exist = false)
    private Integer answerCount;

    @TableField(exist = false)
    private List<QuestionAttachment> attachments;
} 