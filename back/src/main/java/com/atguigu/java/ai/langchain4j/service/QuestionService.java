package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.*;

import java.util.List;

public interface QuestionService {
    List<QuestionBank> generateQuestions(QuestionGenerateRequest request);

    Result<?> create(QuestionBank question);

    Result<?> update(QuestionBank question);

    Result<?> delete(Long id);

    // 支持强制删除：先清理引用再删题目
    Result<?> forceDelete(Long id);

    Result<QuestionBank> getById(Long id);

    Result<List<QuestionBank>> listByCourse(Long courseId);

    QuestionBank selectById(Long questionId);

    List<QuestionDto> generateQuestionsByRequirement(QuestionRequestDto request);

    List<Long> saveGeneratedQuestions(SaveQuestionsRequestDto request); // 批量保存

    List<QuestionDto> getByCreateId(Long createdBy);

    void saveBatch(List<QuestionBank> questionList);

   List<QuestionBank> list();

   PageResponse<QuestionBank> page(int page, int pageSize);

   List<QuestionBank> getQuestionsByExamId(Long examId);

   List<QuestionBank> listByCategory(Long categoryId);

   PageResponse<QuestionBank> pageByCategory(Long categoryId, int page, int pageSize);
   
   List<QuestionBank> getQuestionsByIds(List<Long> ids);
}
