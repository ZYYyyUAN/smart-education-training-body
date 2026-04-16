package com.atguigu.java.ai.langchain4j.entity;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 文档问答请求实体
 */
@Data
@Schema(description = "文档问答请求")
public class QaRequest {

    @Schema(description = "问题内容")
    private String question;
    
    @Schema(description = "文档内容")
    private String documentContent;
    
    @Schema(description = "文件名称")
    private String fileName;
    
    @Schema(description = "问题上下文，可选")
    private String context;
}