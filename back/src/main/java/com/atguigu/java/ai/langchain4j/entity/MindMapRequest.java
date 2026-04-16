package com.atguigu.java.ai.langchain4j.entity;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "思维导图生成请求")
public class MindMapRequest {

    @Schema(description = "文件名称")
    private String fileName;
    
    @Schema(description = "文档内容")
    private String documentContent;
    
    @Schema(description = "导图类型：hierarchical、radial、concept、flowchart")
    private String mapType;
}