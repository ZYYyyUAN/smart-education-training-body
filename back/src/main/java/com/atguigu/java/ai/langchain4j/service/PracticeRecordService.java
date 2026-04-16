package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.PracticeRecord;
import java.util.List;

/**
 * 练习记录服务接口
 */
public interface PracticeRecordService {
    
    /**
     * 根据学生ID统计练习次数
     */
    int countByStudentId(Long studentId);
    
    /**
     * 根据学生ID查询练习记录
     */
    List<PracticeRecord> getByStudentId(Long studentId);
    
    /**
     * 根据学生ID和课程ID统计练习次数
     */
    int countByStudentIdAndCourseId(Long studentId, Long courseId);
}


