package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.*;
import java.util.List;

public interface QuestionDiscussionService {

    /**
     * 获取课程下所有问答讨论
     */
    List<Question> getQuestionsByCourseId(Integer courseId);

    /**
     * 创建新问题
     */
    boolean createQuestion(CreateQuestionRequest request);

    /**
     * 获取问题详情及所有回答
     */
    QuestionDetailDTO getQuestionDetail(Integer questionId);

    /**
     * 创建回答
     */
    boolean createAnswer(CreateAnswerRequest request);
} 