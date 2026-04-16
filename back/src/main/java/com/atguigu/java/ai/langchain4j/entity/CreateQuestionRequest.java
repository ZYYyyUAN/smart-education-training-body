package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;
import java.util.List;

@Data
public class CreateQuestionRequest {
    private Integer courseId;
    private Integer userId;
    private String content;
    private List<String> attachmentUrls; // 文件URL列表
    private List<String> attachmentNames; // 文件名列表
} 