package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.assistant.XiaozhiAgent;
import com.atguigu.java.ai.langchain4j.entity.AiEvaluationResult;
import com.atguigu.java.ai.langchain4j.entity.PracticeLog;
import com.atguigu.java.ai.langchain4j.entity.QuestionDto;
import com.atguigu.java.ai.langchain4j.entity.QuestionRequestDto;
import com.atguigu.java.ai.langchain4j.mapper.PracticeLogMapper;
import com.atguigu.java.ai.langchain4j.mapper.QuestionBankMapper;
import com.atguigu.java.ai.langchain4j.service.PracticeService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

import java.time.LocalDateTime;
import java.util.List;

@Service
@Slf4j
public class PracticeServiceImpl implements PracticeService {

    @Autowired
    private XiaozhiAgent xiaozhiAgent;

    @Autowired
    private PracticeLogMapper practiceLogMapper;

    @Autowired
    private QuestionBankMapper questionBankMapper;

    public List<QuestionDto> generatePracticeByHistory(QuestionRequestDto request) {
        List<String> weakPoints = practiceLogMapper.findWeakPoints(request.getStudentId());
        if (weakPoints.isEmpty()) {
            weakPoints = List.of("C语言基础", "嵌入式系统");
        }
        String joinedPoints = String.join("，", weakPoints);
        log.info("生成的 weakPoints: {}", joinedPoints);

        String json = xiaozhiAgent.generatePracticeStructured(joinedPoints, request.getQuestionType(), request.getCount());
        try {
            return new ObjectMapper().readValue(json, new TypeReference<List<QuestionDto>>() {});
        } catch (Exception e) {
            throw new RuntimeException("生成练习题解析失败: " + e.getMessage(), e);
        }
    }

    public Flux<String> evaluatePractice(Long memoryId, String question, String standardAnswer, String answer) {
        return xiaozhiAgent.evaluatePractice(memoryId, question, standardAnswer, answer);
    }


    public void saveLog(Long studentId, Long questionId, String answer, AiEvaluationResult eval) {
        PracticeLog log = new PracticeLog();
        log.setStudentId(studentId);
        log.setQuestionId(questionId);
        log.setAnswerText(answer);
        log.setScore(eval.getScore());
        log.setIsCorrect(eval.getIsCorrect());
        log.setErrorReason(eval.getErrorReason());
        practiceLogMapper.insert(log);
    }
}
