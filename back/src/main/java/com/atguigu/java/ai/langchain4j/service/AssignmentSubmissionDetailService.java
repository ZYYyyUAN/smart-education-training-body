package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.AssignmentSubmissionDetail;

import java.util.List;

public interface AssignmentSubmissionDetailService {
    void saveDetails(List<AssignmentSubmissionDetail> details);
    List<AssignmentSubmissionDetail> getDetailsBySubmissionId(Long submissionId);

    void saveDetail(AssignmentSubmissionDetail detail);
}
