package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.*;
import com.atguigu.java.ai.langchain4j.mapper.AnswerMapper;
import com.atguigu.java.ai.langchain4j.mapper.QuestionAttachmentMapper;
import com.atguigu.java.ai.langchain4j.mapper.QuestionMapper;
import com.atguigu.java.ai.langchain4j.service.QuestionDiscussionService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class QuestionDiscussionServiceImpl extends ServiceImpl<QuestionMapper, Question> implements QuestionDiscussionService {

    @Autowired
    private QuestionMapper questionMapper;

    @Autowired
    private QuestionAttachmentMapper attachmentMapper;

    @Autowired
    private AnswerMapper answerMapper;

    @Override
    public List<Question> getQuestionsByCourseId(Integer courseId) {
        return questionMapper.selectQuestionsByCourseId(courseId);
    }

    @Override
    public boolean createQuestion(CreateQuestionRequest request) {
        // 创建问题
        Question question = new Question();
        question.setCourseId(request.getCourseId());
        question.setUserId(request.getUserId());
        question.setContent(request.getContent());
        question.setCreateTime(LocalDateTime.now()); // 手动设置创建时间
        
        boolean success = save(question);
        if (!success) {
            return false;
        }

        // 保存附件
        if (request.getAttachmentUrls() != null && !request.getAttachmentUrls().isEmpty()) {
            for (int i = 0; i < request.getAttachmentUrls().size(); i++) {
                QuestionAttachment attachment = new QuestionAttachment();
                attachment.setQuestionId(question.getId());
                attachment.setFileUrl(request.getAttachmentUrls().get(i));
                attachment.setFileName(request.getAttachmentNames() != null && i < request.getAttachmentNames().size() 
                    ? request.getAttachmentNames().get(i) : "附件" + (i + 1));
                attachmentMapper.insert(attachment);
            }
        }

        return true;
    }

    @Override
    public QuestionDetailDTO getQuestionDetail(Integer questionId) {
        // 获取问题信息
        Question question = getById(questionId);
        if (question == null) {
            return null;
        }

        // 获取用户信息
        Question questionWithUser = questionMapper.selectQuestionsByCourseId(question.getCourseId())
                .stream()
                .filter(q -> q.getId().equals(questionId))
                .findFirst()
                .orElse(question);

        // 获取附件
        List<QuestionAttachment> attachments = attachmentMapper.selectByQuestionId(questionId);

        // 获取回答
        List<Answer> answers = answerMapper.selectAnswersByQuestionId(questionId);

        // 组装DTO
        QuestionDetailDTO dto = new QuestionDetailDTO();
        dto.setId(question.getId());
        dto.setCourseId(question.getCourseId());
        dto.setUserId(question.getUserId());
        dto.setContent(question.getContent());
        dto.setCreateTime(question.getCreateTime());
        dto.setUserName(questionWithUser.getUserName());
        dto.setUserUniversity(questionWithUser.getUserUniversity());
        dto.setAttachments(attachments);
        dto.setAnswers(answers);

        return dto;
    }

    @Override
    public boolean createAnswer(CreateAnswerRequest request) {
        Answer answer = new Answer();
        answer.setQuestionId(request.getQuestionId());
        answer.setUserId(request.getUserId());
        answer.setContent(request.getContent());
        answer.setCreateTime(LocalDateTime.now()); // 手动设置创建时间
        
        return answerMapper.insert(answer) > 0;
    }
} 