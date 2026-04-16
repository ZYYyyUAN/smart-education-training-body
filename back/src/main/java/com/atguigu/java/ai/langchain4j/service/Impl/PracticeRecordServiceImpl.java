package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.PracticeRecord;
import com.atguigu.java.ai.langchain4j.mapper.PracticeRecordMapper;
import com.atguigu.java.ai.langchain4j.service.PracticeRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * 练习记录服务实现类
 */
@Service
public class PracticeRecordServiceImpl implements PracticeRecordService {
    
    @Autowired
    private PracticeRecordMapper practiceRecordMapper;
    
    @Override
    public int countByStudentId(Long studentId) {
        try {
            // 真正查询数据库中的练习记录数量
            return practiceRecordMapper.countPracticeRecordsByStudentId(studentId, null, null, null);
        } catch (Exception e) {
            System.err.println("统计学生练习次数失败: " + e.getMessage());
            return 0;
        }
    }
    
    @Override
    public List<PracticeRecord> getByStudentId(Long studentId) {
        try {
            // 真正查询数据库中的练习记录
            return practiceRecordMapper.getPracticeRecordsByStudentId(studentId, 0, 1000, null, null, null, null);
        } catch (Exception e) {
            System.err.println("查询学生练习记录失败: " + e.getMessage());
            return new ArrayList<>();
        }
    }
    
    @Override
    public int countByStudentIdAndCourseId(Long studentId, Long courseId) {
        try {
            // 真正查询数据库中该学生在指定课程的练习次数
            return practiceRecordMapper.countPracticeRecordsByStudentId(studentId, courseId.toString(), null, null);
        } catch (Exception e) {
            System.err.println("统计学生课程练习次数失败: " + e.getMessage());
            return 0;
        }
    }
}
