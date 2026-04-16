package com.atguigu.java.ai.langchain4j.entity;

import com.atguigu.java.ai.langchain4j.entity.Assignment;
import com.atguigu.java.ai.langchain4j.entity.QuestionBank;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
public class AssignmentDetailDTO {
    private Assignment assignment;
    private List<QuestionBank> questions;
}
