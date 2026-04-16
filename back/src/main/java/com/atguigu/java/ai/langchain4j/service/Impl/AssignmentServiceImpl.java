package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.*;
import com.atguigu.java.ai.langchain4j.mapper.AssignmentMapper;
import com.atguigu.java.ai.langchain4j.mapper.AssignmentQuestionMapper;
import com.atguigu.java.ai.langchain4j.mapper.QuestionBankMapper;
import com.atguigu.java.ai.langchain4j.service.AssignmentService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
public class AssignmentServiceImpl implements AssignmentService {
    @Autowired
    private AssignmentMapper assignmentMapper;
    @Autowired
    private AssignmentQuestionMapper assignmentQuestionMapper;
    @Autowired
    private QuestionBankMapper questionBankMapper;
    public void createAssignment(AssignmentForm form) {
        Assignment assignment = new Assignment();
        assignment.setTeacherId(form.getTeacherId());
        assignment.setCourseId(form.getCourseId());
        assignment.setTitle(form.getTitle());
        assignment.setDescription(form.getDescription());
        assignment.setDueDate(form.getDueDate()); // 👈 设置截止时间
        assignmentMapper.insert(assignment);

        // 只有当题目ID列表不为空时才插入关联关系
        if (form.getQuestionIds() != null && !form.getQuestionIds().isEmpty()) {
            assignmentQuestionMapper.insertBatch(assignment.getId(), form.getQuestionIds());
        }
    }
    public List<Assignment> getAssignmentsByTeacherId(Long teacherId) {
        // 这里假设你用MyBatis或JPA查询
        return assignmentMapper.selectByTeacherId(teacherId);
    }


    @Override
    public Result<?> deleteAssignment(Long assignmentId) {
        // 使用存储过程删除作业（先删除关联提交记录和题目，再删除作业记录）
        assignmentMapper.deleteAssignmentByProcedure(assignmentId);
        return Result.ok("删除成功");
    }

    @Override
    public Result<?> updateAssignment(AssignmentForm form) {
        Assignment assignment = new Assignment();
        BeanUtils.copyProperties(form, assignment);
        assignment.setId(form.getId()); // 记得前端要传 ID！
        assignmentMapper.updateById(assignment);

        // 更新题目：先删再加
        assignmentQuestionMapper.deleteByAssignmentId(assignment.getId());
        if (form.getQuestionIds() != null && !form.getQuestionIds().isEmpty()) {
            assignmentQuestionMapper.insertBatch(assignment.getId(), form.getQuestionIds());
        }
        return Result.ok("修改成功");
    }

    @Override
    public List<Assignment> getAssignmentsByCourse(Long courseId) {
        return assignmentMapper.selectByCourseId(courseId);
    }

    @Override
    public AssignmentDetailDTO getAssignmentDetail(Long assignmentId) {
        Assignment assignment = assignmentMapper.selectById(assignmentId);
        List<QuestionBank> questions = questionBankMapper.selectByAssignmentId(assignmentId);
        return new AssignmentDetailDTO(assignment, questions);
    }

    public List<AssignmentWithStatusDTO> getAssignmentsByStudentId(Long studentId) {
        return assignmentMapper.selectAssignmentsWithSubmissionStatus(studentId);
    }
    @Override
    public List<Assignment> getUpcomingAssignments(Long studentId, int daysAhead) {
        return assignmentMapper.selectUpcomingAssignments(studentId, daysAhead);
    }

    @Override
    public Result<?> updateAssignmentForAdmin(AdminAssignmentUpdateForm form) {
        Assignment assignment = new Assignment();
        BeanUtils.copyProperties(form, assignment);
        assignment.setId(form.getId());
        assignmentMapper.updateById(assignment);
        // 注意：管理端更新不涉及题目，只更新基本信息
        return Result.ok("作业更新成功");
    }

    @Override
    public List<AssignmentOverviewDTO> getAllAssignmentsOverview() {
        return assignmentMapper.selectAllAssignmentsOverview();
    }

    @Override
    public List<AssignmentOverviewDTO> getAssignmentsOverviewByTeacherId(Long teacherId) {
        return assignmentMapper.selectOverviewByTeacherId(teacherId);
    }

    @Override
    public List<AssignmentOverviewDTO> getAssignmentsOverviewByCourseId(Long courseId) {
        return assignmentMapper.selectOverviewByCourseId(courseId);
    }

    @Override
    public List<AssignmentOverviewDTO> getAssignmentsOverviewByStudentId(Long studentId) {
        return assignmentMapper.selectOverviewByStudentId(studentId);
    }

}
