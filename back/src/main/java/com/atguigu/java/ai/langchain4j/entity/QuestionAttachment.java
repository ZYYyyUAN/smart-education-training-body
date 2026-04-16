package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;

@Data
@TableName("question_attachment")
public class QuestionAttachment implements Serializable {

    @TableId(type = IdType.AUTO)
    private Integer id;

    private Integer questionId;

    private String fileUrl;

    private String fileName;
} 