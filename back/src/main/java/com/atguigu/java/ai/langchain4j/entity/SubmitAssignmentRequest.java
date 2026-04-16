package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

import java.util.List;

@Data
public class SubmitAssignmentRequest {

    private Long assignmentId;   // 作业ID
    private Long studentId;      // 学生ID

    private List<Detail> details;  // 每道题的作答明细

    @Data
    public static class Detail {
        private Long questionId;     // 题目ID（关联 question_bank）
        private String answerText;   // 学生填写的答案
    }
}
