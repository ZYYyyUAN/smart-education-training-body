package com.atguigu.java.ai.langchain4j.bean;

import lombok.Data;

@Data
public class ChatForm {
private Long memoryId;//对话id
private String message;//用户问题
private Long courseId;// 课程ID（用于按课程切换知识库命名空间）
}