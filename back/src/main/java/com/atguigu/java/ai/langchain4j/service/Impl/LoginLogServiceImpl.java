package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.StudentLoginLog;
import com.atguigu.java.ai.langchain4j.entity.TeacherLoginLog;
import com.atguigu.java.ai.langchain4j.mapper.StudentLoginLogMapper;
import com.atguigu.java.ai.langchain4j.mapper.TeacherLoginLogMapper;
import com.atguigu.java.ai.langchain4j.service.LoginLogService;
import com.atguigu.java.ai.langchain4j.service.StudyScoreService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class LoginLogServiceImpl implements LoginLogService {

    @Autowired
    private StudentLoginLogMapper studentLoginLogMapper;
    
    @Autowired
    private TeacherLoginLogMapper teacherLoginLogMapper;

    @Autowired
    private StudyScoreService studyScoreService;

    @Override
    public void recordStudentLogin(Long studentId) {
        try {
            StudentLoginLog loginLog = new StudentLoginLog();
            loginLog.setStudentId(studentId);
            loginLog.setLoginTime(java.time.LocalDateTime.now()); // 手动设置登录时间
            int result = studentLoginLogMapper.insert(loginLog);
            if (result > 0) {
                log.info("学生登录记录已保存，学生ID: {}, 登录时间: {}", studentId, loginLog.getLoginTime());

                // 自动更新学习积分
                try {
                    int newScore = studyScoreService.updateStudyScore(studentId);
                    log.info("登录记录保存后自动更新学习积分，学生ID: {}, 新积分: {}", studentId, newScore);
                } catch (Exception scoreError) {
                    log.warn("自动更新学习积分失败，学生ID: {}", studentId, scoreError);
                    // 不影响登录记录保存的主要流程
                }
            } else {
                log.warn("学生登录记录保存失败，返回结果: {}, 学生ID: {}", result, studentId);
            }
        } catch (Exception e) {
            log.error("保存学生登录记录失败，学生ID: {}", studentId, e);
        }
    }

    @Override
    public void recordTeacherLogin(Long teacherId) {
        try {
            TeacherLoginLog loginLog = new TeacherLoginLog();
            loginLog.setTeacherId(teacherId);
            loginLog.setLoginTime(java.time.LocalDateTime.now()); // 手动设置登录时间
            int result = teacherLoginLogMapper.insert(loginLog);
            if (result > 0) {
                log.info("老师登录记录已保存，老师ID: {}, 登录时间: {}", teacherId, loginLog.getLoginTime());
            } else {
                log.warn("老师登录记录保存失败，返回结果: {}, 老师ID: {}", result, teacherId);
            }
        } catch (Exception e) {
            log.error("保存老师登录记录失败，老师ID: {}", teacherId, e);
        }
    }
}
