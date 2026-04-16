package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.Exam;
import com.atguigu.java.ai.langchain4j.entity.ExamForm;
import com.atguigu.java.ai.langchain4j.entity.AdminExamUpdateForm;
import com.atguigu.java.ai.langchain4j.mapper.ExamMapper;
import com.atguigu.java.ai.langchain4j.mapper.ExamQuestionMapper;
import com.atguigu.java.ai.langchain4j.service.ExamService;
import com.atguigu.java.ai.langchain4j.entity.Result;
import com.atguigu.java.ai.langchain4j.entity.ExamOverviewDTO;
import com.atguigu.java.ai.langchain4j.entity.ExamWithStatusDTO;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ExamServiceImpl implements ExamService {

    @Autowired
    private ExamMapper examMapper;
    @Autowired
    private ExamQuestionMapper examQuestionMapper;

    @Override
    public void createExam(ExamForm form) {
        Exam exam = new Exam();
        exam.setTeacherId(form.getTeacherId());
        exam.setCourseId(form.getCourseId());
        exam.setTitle(form.getTitle());
        exam.setDescription(form.getDescription());
        exam.setExamDate(form.getExamDate());
        exam.setDurationMinutes(form.getDurationMinutes());
        exam.setCreatedAt(LocalDateTime.now());
        examMapper.insert(exam);
        if (form.getQuestionIds() != null && !form.getQuestionIds().isEmpty()) {
            examQuestionMapper.insertBatch(exam.getId(), form.getQuestionIds());
        }
    }

    @Override
    public Result<?> updateExam(ExamForm form) {
        Exam exam = new Exam();
        BeanUtils.copyProperties(form, exam);
        examMapper.updateById(exam);
        examQuestionMapper.deleteByExamId(exam.getId());
        if (form.getQuestionIds() != null && !form.getQuestionIds().isEmpty()) {
            examQuestionMapper.insertBatch(exam.getId(), form.getQuestionIds());
        }
        return Result.ok();
    }

    @Override
    public Result<?> deleteExam(Long examId) {
        examMapper.deleteExamByProcedure(examId);
        return Result.ok("删除成功");
    }

    @Override
    public List<Exam> getExamsByCourse(Long courseId) {
        return examMapper.selectByCourseId(courseId);
    }

    @Override
    public List<Exam> getExamsByTeacherId(Long teacherId) {
        return examMapper.selectByTeacherId(teacherId);
    }

    @Override
    public List<ExamOverviewDTO> getExamOverviewByTeacher(Long teacherId) {
        return examMapper.selectOverviewByTeacher(teacherId);
    }

    @Override
    public List<Exam> getUpcomingExams(Long studentId, int days) {
        return examMapper.selectUpcomingByStudent(studentId, days);
    }

    @Override
    public List<ExamWithStatusDTO> getExamsWithStatus(Long studentId, Long courseId) {
        return examMapper.selectExamsWithStatus(studentId, courseId);
    }

    @Override
    public Result<?> updateExamForAdmin(AdminExamUpdateForm form) {
        Exam exam = new Exam();
        BeanUtils.copyProperties(form, exam);
        exam.setId(form.getId());
        examMapper.updateById(exam);
        return Result.ok("考试更新成功");
    }

    @Override
    public List<ExamOverviewDTO> getAllExamsOverview() {
        return examMapper.selectAllExamsOverview();
    }

    @Override
    public List<ExamOverviewDTO> getExamsOverviewByCourse(Long courseId) {
        return examMapper.selectOverviewByCourse(courseId);
    }

    @Override
    public List<ExamOverviewDTO> getExamsOverviewByTeacher(Long teacherId) {
        return examMapper.selectOverviewByTeacher(teacherId);
    }
}


