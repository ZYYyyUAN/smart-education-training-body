package com.atguigu.java.ai.langchain4j.entity;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * AI笔记生成请求实体
 */
@Data
@Schema(description = "AI笔记生成请求")
public class NotesGenerateRequest {

    @Schema(description = "文件名称")
    private String fileName;
    
    @Schema(description = "文档内容")
    private String documentContent;
    
    @Schema(description = "生成选项，可选参数")
    private String options;
}