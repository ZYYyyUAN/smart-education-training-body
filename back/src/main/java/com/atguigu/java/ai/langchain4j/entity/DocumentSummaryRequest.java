package com.atguigu.java.ai.langchain4j.entity;

import lombok.Data;

/**
 * 文档摘要请求实体
 */
@Data
public class DocumentSummaryRequest {
    
    /**
     * 文件名
     */
    private String fileName;
    
    /**
     * 文档内容
     */
    private String content;
}
