package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@TableName("user")
public class User implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String username;

    private String password;

    @TableField("real_name")
    private String realName;

    // 添加一个别名字段，用于接收前端数据
    @TableField(exist = false)
    private String real_name;

    private String email;

    /**
     * 角色（student / teacher / admin）
     */
    private String role;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createdAt;

    @TableField("last_login")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime lastLogin;

    private String sex;

    @TableField("`class`")
    private String className;

    @TableField("class_id")
    private Long classId;

    // 添加一个别名字段，用于接收前端数据（class是关键字，使用userClass作为字段名）
    @TableField(exist = false)
    @JsonProperty("class")
    private String userClass;

    private String school;

    /** 头像URL(阿里云OSS) */
    @TableField("avatar_url")
    private String avatarUrl;

    /** 学习积分 */
    @TableField("study_score")
    private Integer studyScore;
}
