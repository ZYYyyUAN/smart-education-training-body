// AssignmentQuestion.java
package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

@Data
public class AssignmentQuestion {
    private Long id;
    private Long assignmentId;
    private Long questionId;
    private Integer sortOrder; // 题目在作业中的顺序，可选
}