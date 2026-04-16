package com.atguigu.java.ai.langchain4j.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 通用响应封装类
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Result<T> {
    private Integer code;   // 响应码
    private String message; // 响应消息
    private T data;         // 响应数据

    // 成功返回
    public static <T> Result<T> ok(T data) {
        return new Result<>(200, "操作成功", data);
    }

    public static Result<String> ok() {
        return new Result<>(200, "操作成功", null);
    }

    public static Result<String> ok(String message) {
        return new Result<>(200, message, null);
    }

    // 错误返回
    public static <T> Result<T> error(Integer code, String message) {
        return new Result<>(code, message, null);
    }

    public static <T> Result<T> error(String message) {
        return new Result<>(500, message, null);
    }
}
