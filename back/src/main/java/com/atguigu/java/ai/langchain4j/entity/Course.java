package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("course")
public class Course {
    @TableId(type = IdType.AUTO) // 强制使用数据库自增
    private Long id;
    private String courseName;
    private String courseImage;
    private String teachingGoal;
    private String teachingPrinciple;
    private String courseBackground;
    private String description;
    private Long teacherId;
    private String courseIntro;
    private LocalDateTime createdAt;
}
