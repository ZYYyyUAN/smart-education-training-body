package com.atguigu.java.ai.langchain4j.entity.dto;

import lombok.Data;
import java.util.List;
import java.util.Map;

/**
 * 考试提交请求
 */
@Data
public class ExamSubmissionRequest {
    
    private Long examId;
    private Long studentId;
    private List<QuestionAnswer> answers;
    private Long submitTime; // 提交时间戳
    
    @Data
    public static class QuestionAnswer {
        private Long questionId;
        private String answer;
        private String questionType;
    }
}
