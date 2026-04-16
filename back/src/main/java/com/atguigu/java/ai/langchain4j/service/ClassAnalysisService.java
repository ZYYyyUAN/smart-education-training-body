package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.SysClass;
import com.atguigu.java.ai.langchain4j.entity.User;
import com.atguigu.java.ai.langchain4j.entity.AssignmentSubmissionDetail;
import com.atguigu.java.ai.langchain4j.entity.ExamSubmissionDetail;
import java.util.List;
import java.util.Map;

/**
 * 学情信息管理服务接口
 * 
 * 该接口定义了学情信息管理模块的所有业务方法，包括：
 * - 班级信息查询和管理
 * - 学生信息查询和管理
 * - 学情数据统计和分析
 * - AI智能学情分析数据准备
 * 
 * @author 张政
 * @date 2024
 */
public interface ClassAnalysisService {
    /**
     * 获取所有班级列表
     * 
     * @return 所有班级的列表
     */
    List<SysClass> getAllClasses();
    
    /**
     * 根据班级ID获取该班级的所有学生
     * 
     * @param classId 班级ID
     * @return 该班级的学生列表
     */
    List<User> getStudentsByClassId(Long classId);
    
    /**
     * 获取班级概览信息
     * 
     * 返回班级的基本统计信息，包括：
     * - 班级总人数
     * - 平均学习积分
     * - 优秀率（学习积分>=100的学生比例）
     * - 班级名称和教师信息
     * - 班级科目分布（各课程的学生数量）
     * 
     * @param classId 班级ID
     * @return 包含班级概览统计信息的Map
     */
    Map<String, Object> getClassOverview(Long classId);
    
    /**
     * 获取学生详细信息
     * 
     * 返回学生的完整学情数据，包括：
     * - 登录记录趋势（最近7天）
     * - 作业提交记录（包含标题、课程信息、成绩等）
     * - 考试记录（包含标题、课程信息、成绩等）
     * - 作业成绩趋势（用于柱状图展示）
     * - 考试成绩趋势（用于柱状图展示）
     * - 可选课程列表（用于前端筛选）
     * 
     * @param studentId 学生ID
     * @return 包含学生详细学情信息的Map
     */
    Map<String, Object> getStudentDetails(Long studentId);
    
    /**
     * 获取作业提交的详细作答信息
     * 
     * @param submissionId 作业提交ID
     * @return 作业作答详情列表
     */
    List<AssignmentSubmissionDetail> getAssignmentDetails(Long submissionId);
    
    /**
     * 获取考试提交的详细作答信息
     * 
     * @param submissionId 考试提交ID
     * @return 考试作答详情列表
     */
    List<ExamSubmissionDetail> getExamDetails(Long submissionId);
    
    /**
     * 从班级中移除单个学生
     * 
     * @param classId 班级ID
     * @param studentId 学生ID
     * @return 操作是否成功
     */
    boolean removeStudentFromClass(Long classId, Long studentId);
    
    /**
     * 批量从班级中移除学生
     * 
     * @param classId 班级ID
     * @param studentIds 学生ID列表
     * @return 操作是否成功
     */
    boolean batchRemoveStudentsFromClass(Long classId, List<Long> studentIds);
    
    /**
     * 获取可添加到班级的学生列表
     * 
     * 返回所有未加入任何班级的学生，或者不在当前班级的学生。
     * 
     * @param classId 班级ID
     * @return 可添加的学生列表
     */
    List<User> getAvailableStudents(Long classId);
    
    /**
     * 批量添加学生到班级
     * 
     * @param classId 班级ID
     * @param studentIds 学生ID列表
     * @return 操作是否成功
     */
    boolean addStudentsToClass(Long classId, List<Long> studentIds);
    
    /**
     * 通过学生ID添加单个学生到班级
     * 
     * 添加前会进行验证：
     * 1. 检查学生是否存在
     * 2. 检查学生角色是否为"student"
     * 3. 检查学生是否已在其他班级
     * 
     * @param classId 班级ID
     * @param studentId 学生ID
     * @return 包含操作结果的Map，包含success、message等字段
     */
    Map<String, Object> addStudentById(Long classId, Long studentId);
    
    /**
     * 计算班级在指定课程的作业完成率
     * @param classId 班级ID
     * @param courseId 课程ID，如果为null则计算所有课程
     * @return 包含完成率等信息的Map
     */
    Map<String, Object> getHomeworkCompletionRate(Long classId, Long courseId);
    
    /**
     * 计算班级在指定课程的考试完成率
     * @param classId 班级ID
     * @param courseId 课程ID，如果为null则计算所有课程
     * @return 包含完成率等信息的Map
     */
    Map<String, Object> getExamCompletionRate(Long classId, Long courseId);
    
    /**
     * 计算班级在指定课程的作业平均成绩
     * @param classId 班级ID
     * @param courseId 课程ID，如果为null则计算所有课程
     * @return 包含平均成绩等信息的Map
     */
    Map<String, Object> getHomeworkAverageScore(Long classId, Long courseId);
    
    /**
     * 计算班级在指定课程的考试平均成绩
     * @param classId 班级ID
     * @param courseId 课程ID，如果为null则计算所有课程
     * @return 包含平均成绩等信息的Map
     */
    Map<String, Object> getExamAverageScore(Long classId, Long courseId);
    
    /**
     * 获取学生学情分析所需的所有数据
     * @param studentId 学生ID
     * @return 包含登录记录、作业成绩趋势、考试成绩趋势、作业考试作答详情等数据的Map
     */
    Map<String, Object> getStudentAnalysisData(Long studentId);
}
