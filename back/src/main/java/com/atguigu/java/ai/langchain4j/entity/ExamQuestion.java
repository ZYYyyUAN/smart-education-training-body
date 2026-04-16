package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("exam_question")
public class ExamQuestion {
    private Long id;
    private Long examId;
    private Long questionId;
}


