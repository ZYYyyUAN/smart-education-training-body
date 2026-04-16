package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.AssignmentSubmission;
import com.atguigu.java.ai.langchain4j.entity.SubmitAssignmentRequest;

public interface AssignmentSubmissionService {
    Long saveSubmission(SubmitAssignmentRequest request);

    Long getSubmissionIdByAssignmentId(Long assignmentId);
    
    AssignmentSubmission getSubmissionById(Long submissionId);
}
