package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class QuestionDetailDTO {
    private Integer id;
    private Integer courseId;
    private Integer userId;
    private String content;
    private LocalDateTime createTime;
    private String userName;
    private String userUniversity;
    private List<QuestionAttachment> attachments;
    private List<Answer> answers;
} 