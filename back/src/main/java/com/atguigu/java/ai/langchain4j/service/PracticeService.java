package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.*;
import com.atguigu.java.ai.langchain4j.service.Impl.AssignmentSubmissionServiceImpl;
import com.baomidou.mybatisplus.extension.service.IService;
import reactor.core.publisher.Flux;

import java.util.List;

public interface PracticeService  {


    Flux<String> evaluatePractice(Long memoryId, String question, String answer, String standardAnswer);


    void saveLog(Long studentId, Long questionId, String studentAnswer, AiEvaluationResult eval);


    List<QuestionDto> generatePracticeByHistory(QuestionRequestDto request);

}
