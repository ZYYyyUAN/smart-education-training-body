package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;

import java.time.LocalDateTime;

@Data
public class PracticeLog {
    @Id
    private Long id;
    private Long studentId;
    private Long questionId;
    private String answerText;
    private Boolean isCorrect;
    private int score;
    private String errorReason;
    private LocalDateTime submittedAt;
}
