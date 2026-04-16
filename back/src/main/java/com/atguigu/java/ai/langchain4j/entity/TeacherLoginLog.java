package com.atguigu.java.ai.langchain4j.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@TableName("teacher_login_log")
public class TeacherLoginLog implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("teacher_id")
    private Long teacherId;

    @TableField("login_time")
    private LocalDateTime loginTime;

    public TeacherLoginLog() {}

    public TeacherLoginLog(Long teacherId) {
        this.teacherId = teacherId;
        // 移除手动设置时间，让自动填充处理
    }
}
