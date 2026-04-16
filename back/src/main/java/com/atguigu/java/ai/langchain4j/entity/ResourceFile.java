package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.util.Date;

@Data
@TableName("resource_file")
public class ResourceFile {
    private Long id;
    
    @TableField("course_id")
    private Long courseId;
    
    @TableField("teacher_id")
    private Long teacherId;
    
    @TableField("file_name")
    private String fileName;
    
    @TableField("file_path")
    private String filePath;
    
    @TableField("uploaded_at")
    private Date uploadedAt;
    
    @TableField("download_count")
    private Integer downloadCount;
    
    @TableField("is_ingested")
    private Boolean isIngested;
}