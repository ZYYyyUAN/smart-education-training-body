package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.AssignmentSubmissionDetail;
import com.atguigu.java.ai.langchain4j.entity.QuestionBank;
import com.atguigu.java.ai.langchain4j.mapper.AssignmentSubmissionDetailMapper;
import com.atguigu.java.ai.langchain4j.mapper.QuestionBankMapper;
import com.atguigu.java.ai.langchain4j.service.AssignmentSubmissionDetailService;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class AssignmentSubmissionDetailServiceImpl implements AssignmentSubmissionDetailService {

    @Autowired
    private AssignmentSubmissionDetailMapper detailMapper;
    @Autowired
    private QuestionBankMapper questionBankMapper;
    public void saveDetail(AssignmentSubmissionDetail detail) {
        detailMapper.insert(detail);
    }
    @Override
    public void saveDetails(List<AssignmentSubmissionDetail> details) {
        details.forEach(detail -> detailMapper.insert(detail));
    }

    @Override
    public List<AssignmentSubmissionDetail> getDetailsBySubmissionId(Long submissionId) {
        // 参数校验
        if (submissionId == null) {
            throw new IllegalArgumentException("提交ID不能为空");
        }

        // 1. 查询基础提交详情
        QueryWrapper<AssignmentSubmissionDetail> query = new QueryWrapper<>();
        query.eq("submission_id", submissionId);
        List<AssignmentSubmissionDetail> details = detailMapper.selectList(query);

        if (details.isEmpty()) {
            return Collections.emptyList();
        }

        // 2. 提取所有questionId（去重）
        Set<Long> questionIds = details.stream()
                .map(AssignmentSubmissionDetail::getQuestionId)
                .filter(Objects::nonNull) // 过滤掉null值
                .collect(Collectors.toSet());

        // 3. 查询题目信息并建立映射
        if (!questionIds.isEmpty()) {
            // 使用循环查询单个题目，避免批量查询的参数绑定问题
            Map<Long, QuestionBank> questionMap = new HashMap<>();
            for (Long questionId : questionIds) {
                QuestionBank question = questionBankMapper.selectById(questionId);
                if (question != null) {
                    questionMap.put(questionId, question);
                }
            }

            // 4. 填充题目相关信息
            details.forEach(detail -> {
                if (detail.getQuestionId() != null) {
                    QuestionBank question = questionMap.get(detail.getQuestionId());
                    if (question != null) {
                        detail.setContent(question.getContent());
                        detail.setType(question.getType());
                        detail.setAnswer(question.getAnswer());
                        detail.setKnowledgePoint(question.getKnowledgePoint());
                    }
                }
            });
        }

        return details;
    }
}
