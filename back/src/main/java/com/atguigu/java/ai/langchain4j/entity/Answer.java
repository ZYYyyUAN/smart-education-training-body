package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@TableName("answer")
public class Answer implements Serializable {

    @TableId(type = IdType.AUTO)
    private Integer id;

    private Integer questionId;

    private Integer userId;

    private String content;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    // 关联字段，不映射到数据库
    @TableField(exist = false)
    private String userName;

    @TableField(exist = false)
    private String userUniversity;
} 