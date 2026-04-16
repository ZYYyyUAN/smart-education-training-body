package com.atguigu.java.ai.langchain4j.entity;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * AI问答聊天请求实体
 */
@Data
@Schema(description = "AI问答聊天请求")
public class QaChatRequest {

    @Schema(description = "问题内容")
    private String question;
    
    @Schema(description = "文档内容，可选")
    private String documentContent;
    
    @Schema(description = "文件名称，可选")
    private String fileName;
    
    @Schema(description = "会话ID，可选")
    private Long memoryId;
}