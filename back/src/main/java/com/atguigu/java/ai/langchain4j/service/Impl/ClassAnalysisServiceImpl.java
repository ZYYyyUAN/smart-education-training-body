package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.*;
import com.atguigu.java.ai.langchain4j.mapper.*;
import com.atguigu.java.ai.langchain4j.service.ClassAnalysisService;
import com.atguigu.java.ai.langchain4j.service.AssignmentSubmissionDetailService;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 学情信息管理服务实现类
 * 
 * 该类实现了学情信息管理模块的所有业务逻辑，包括：
 * - 班级信息查询和统计
 * - 学生信息查询和管理
 * - 学情数据统计和分析（完成率、平均成绩等）
 * - AI智能学情分析数据准备
 * 
 * @author 张政
 * @date 2024
 */
@Service
public class ClassAnalysisServiceImpl implements ClassAnalysisService {

    /** 班级Mapper，用于班级信息查询 */
    @Autowired
    private SysClassMapper sysClassMapper;

    /** 用户Mapper，用于学生信息查询和管理 */
    @Autowired
    private UserMapper userMapper;

    /** 学生登录日志Mapper，用于查询学生登录记录 */
    @Autowired
    private StudentLoginLogMapper studentLoginLogMapper;

    /** 作业提交Mapper，用于查询作业提交记录和统计 */
    @Autowired
    private AssignmentSubmissionMapper assignmentSubmissionMapper;

    /** 考试提交Mapper，用于查询考试提交记录和统计 */
    @Autowired
    private ExamSubmissionMapper examSubmissionMapper;

    /** 考试结果Mapper，用于查询考试成绩 */
    @Autowired
    private ExamResultMapper examResultMapper;

    /** 作业提交详情Mapper，用于查询作业具体作答详情 */
    @Autowired
    private AssignmentSubmissionDetailMapper assignmentSubmissionDetailMapper;

    /** 作业提交详情服务，用于获取完整的作业作答详情 */
    @Autowired
    private AssignmentSubmissionDetailService assignmentSubmissionDetailService;

    /** 考试提交详情Mapper，用于查询考试具体作答详情 */
    @Autowired
    private ExamSubmissionDetailMapper examSubmissionDetailMapper;

    /** 考试答案Mapper，用于查询考试答案详情 */
    @Autowired
    private ExamAnswerMapper examAnswerMapper;

    /** 作业Mapper，用于查询作业信息 */
    @Autowired
    private AssignmentMapper assignmentMapper;

    /** 考试Mapper，用于查询考试信息 */
    @Autowired
    private ExamMapper examMapper;

    /** 课程Mapper，用于查询课程信息 */
    @Autowired
    private CourseMapper courseMapper;

    /** 学生选课Mapper，用于查询学生选课情况和统计 */
    @Autowired
    private StudentCourseMapper studentCourseMapper;

    /**
     * 获取所有班级列表
     * 
     * @return 所有班级的列表
     */
    @Override
    public List<SysClass> getAllClasses() {
        return sysClassMapper.selectList(null);
    }

    /**
     * 根据班级ID获取该班级的所有学生
     * 
     * 查询条件：
     * - class_id = 指定班级ID
     * - role = 'student'（只查询学生角色）
     * 
     * @param classId 班级ID
     * @return 该班级的学生列表
     */
    @Override
    public List<User> getStudentsByClassId(Long classId) {
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("class_id", classId);
        queryWrapper.eq("role", "student");
        return userMapper.selectList(queryWrapper);
    }

    /**
     * 获取班级概览信息
     * 
     * 计算并返回班级的基本统计信息：
     * 1. 班级总人数：统计该班级的学生数量
     * 2. 平均学习积分：计算所有学生学习积分的平均值
     * 3. 优秀率：学习积分>=100的学生比例
     * 4. 班级名称和教师信息
     * 5. 班级科目分布：统计每个课程的学生数量（通过student_course表关联查询）
     * 
     * @param classId 班级ID
     * @return 包含班级概览统计信息的Map，包含以下字段：
     *         - totalStudents: 班级总人数
     *         - averageScore: 平均学习积分（格式化字符串）
     *         - excellentRate: 优秀率（格式化百分比字符串）
     *         - className: 班级名称
     *         - teacherName: 教师姓名
     *         - courseDistribution: 科目分布列表，每个元素包含courseId、courseName、studentCount
     */
    @Override
    public Map<String, Object> getClassOverview(Long classId) {
        Map<String, Object> map = new HashMap<>();
        // 获取班级所有学生
        List<User> students = getStudentsByClassId(classId);

        // 1. 统计班级总人数
        map.put("totalStudents", students.size());

        // 2. 计算平均学习积分
        double totalScore = students.stream().mapToDouble(s -> s.getStudyScore() == null ? 0 : s.getStudyScore()).sum();
        double avgScore = students.isEmpty() ? 0 : totalScore / students.size();
        map.put("averageScore", String.format("%.1f", avgScore));

        // 3. 计算优秀率（学习积分>=100的学生比例）
        long excellentCount = students.stream().filter(s -> s.getStudyScore() != null && s.getStudyScore() >= 100).count();
        double excellentRate = students.isEmpty() ? 0 : (double) excellentCount / students.size() * 100;
        map.put("excellentRate", String.format("%.1f%%", excellentRate));

        // 4. 获取班级基本信息
        SysClass sysClass = sysClassMapper.selectById(classId);
        if (sysClass != null) {
            map.put("className", sysClass.getName());
            map.put("teacherName", "张老师");
        }

        // 5. 获取班级的科目分布（根据 student_course 表统计每个课程的学生数量）
        // 使用 SQL 直接查询，更高效，直接统计班级所有学生的选课情况
        List<Map<String, Object>> courseDistribution = studentCourseMapper.getCourseDistributionByClassId(classId);
        
        // 确保返回的数据格式统一
        if (courseDistribution == null) {
            courseDistribution = new ArrayList<>();
        }
        
        // 处理数据格式，确保字段类型正确
        for (Map<String, Object> courseInfo : courseDistribution) {
            // 确保 studentCount 是 Long 类型
            Object studentCountObj = courseInfo.get("studentCount");
            if (studentCountObj instanceof Number) {
                courseInfo.put("studentCount", ((Number) studentCountObj).longValue());
            }
        }
        
        map.put("courseDistribution", courseDistribution);

        return map;
    }

    /**
     * 获取学生详细信息
     * 
     * 返回学生的完整学情数据，包括：
     * 1. 登录记录趋势：最近7天的登录次数（用于折线图展示）
     * 2. 作业提交记录：包含作业标题、课程信息、提交时间、成绩、是否迟到等
     * 3. 考试记录：包含考试标题、课程信息、提交时间、成绩等
     * 4. 作业成绩趋势：所有作业的成绩列表（用于柱状图展示）
     * 5. 考试成绩趋势：所有考试的成绩列表（用于柱状图展示）
     * 6. 可选课程列表：学生参与的所有课程（用于前端筛选）
     * 
     * @param studentId 学生ID
     * @return 包含学生详细学情信息的Map，包含以下字段：
     *         - loginDates: 登录日期列表（最近7天，格式：MM-dd）
     *         - loginCounts: 对应日期的登录次数列表
     *         - assignments: 作业提交记录列表，每个元素包含id、title、courseId、courseName、submittedAt、score、isLate
     *         - exams: 考试记录列表，每个元素包含id、title、courseId、courseName、submittedAt、score
     *         - homeworkScores: 作业成绩列表（按时间正序）
     *         - homeworkLabels: 作业标签列表（用于图表展示）
     *         - examScores: 考试成绩列表（按时间正序）
     *         - courses: 可选课程列表，每个元素包含id、name
     */
    @Override
    public Map<String, Object> getStudentDetails(Long studentId) {
        Map<String, Object> result = new HashMap<>();

        // 1. 登录记录趋势（折线图数据）- 最近7天
        // 使用标准的 selectList 方法，不依赖自定义 Mapper 方法，确保稳定性
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(6); // 最近7天（包含今天）
        QueryWrapper<StudentLoginLog> loginQw = new QueryWrapper<>();
        loginQw.eq("student_id", studentId)
               .ge("login_time", startDate.atStartOfDay());
        
        List<StudentLoginLog> logs = studentLoginLogMapper.selectList(loginQw);

        // 按日期分组统计登录次数
        Map<String, Long> loginCounts = logs.stream()
            .collect(Collectors.groupingBy(
                log -> log.getLoginTime().toLocalDate().format(DateTimeFormatter.ofPattern("MM-dd")),
                Collectors.counting()
            ));

        // 构建完整的7天数据（即使某天没有登录也要显示0）
        List<String> dates = new ArrayList<>();
        List<Long> counts = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            String dateKey = startDate.plusDays(i).format(DateTimeFormatter.ofPattern("MM-dd"));
            dates.add(dateKey);
            counts.add(loginCounts.getOrDefault(dateKey, 0L));
        }
        result.put("loginDates", dates);
        result.put("loginCounts", counts);

        // 2. 作业提交记录（列表）- 包含标题和课程信息
        QueryWrapper<AssignmentSubmission> assignQw = new QueryWrapper<>();
        assignQw.eq("student_id", studentId).orderByDesc("submitted_at");
        List<AssignmentSubmission> assignmentSubmissions = assignmentSubmissionMapper.selectList(assignQw);
        
        // 为每个作业提交记录添加标题和课程信息
        List<Map<String, Object>> assignmentsWithInfo = new ArrayList<>();
        Set<Long> courseIds = new HashSet<>(); // 用于收集所有课程ID，后续用于生成课程筛选列表
        for (AssignmentSubmission submission : assignmentSubmissions) {
            Map<String, Object> assignmentInfo = new HashMap<>();
            assignmentInfo.put("id", submission.getId());
            assignmentInfo.put("submittedAt", submission.getSubmittedAt());
            assignmentInfo.put("score", submission.getScore());
            assignmentInfo.put("isLate", submission.getIsLate());
            
            // 查询作业信息，获取作业标题和课程ID
            Assignment assignment = assignmentMapper.selectById(submission.getAssignmentId());
            if (assignment != null) {
                assignmentInfo.put("title", assignment.getTitle());
                assignmentInfo.put("courseId", assignment.getCourseId());
                courseIds.add(assignment.getCourseId());
                
                // 查询课程信息，获取课程名称
                Course course = courseMapper.selectById(assignment.getCourseId());
                if (course != null) {
                    assignmentInfo.put("courseName", course.getCourseName());
                } else {
                    assignmentInfo.put("courseName", "未知课程");
                }
            } else {
                // 如果作业不存在，使用默认值
                assignmentInfo.put("title", "未知作业");
                assignmentInfo.put("courseId", null);
                assignmentInfo.put("courseName", "未知课程");
            }
            assignmentsWithInfo.add(assignmentInfo);
        }
        result.put("assignments", assignmentsWithInfo);

        // 3. 考试记录（列表）- 包含标题和课程信息
        // 使用 SQL JOIN 查询，直接从 exam_submission 关联 exam 和 course 表获取完整信息，提高查询效率
        List<Map<String, Object>> examsWithInfo = examSubmissionMapper.selectWithExamInfo(studentId);
        
        // 处理查询结果，统一字段名和格式
        for (Map<String, Object> examInfo : examsWithInfo) {
            // 统一字段名：examTitle -> title
            Object examTitle = examInfo.get("examTitle");
            if (examTitle != null && !examTitle.toString().trim().isEmpty()) {
                examInfo.put("title", examTitle);
            } else {
                examInfo.put("title", "未知考试");
            }
            examInfo.remove("examTitle"); // 移除临时字段
            
            // 确保 courseId 和 courseName 存在
            Object courseIdObj = examInfo.get("courseId");
            if (courseIdObj != null) {
                Long courseId = courseIdObj instanceof Long ? (Long) courseIdObj : Long.valueOf(courseIdObj.toString());
                examInfo.put("courseId", courseId);
                courseIds.add(courseId); // 收集课程ID
                
                // 如果 courseName 为空，设置为默认值
                Object courseName = examInfo.get("courseName");
                if (courseName == null || courseName.toString().trim().isEmpty()) {
                    examInfo.put("courseName", "未知课程");
                }
            } else {
                examInfo.put("courseId", null);
                examInfo.put("courseName", "未知课程");
            }
        }
        result.put("exams", examsWithInfo);
        
        // 获取所有课程列表用于前端筛选
        List<Map<String, Object>> courseList = new ArrayList<>();
        for (Long courseId : courseIds) {
            Course course = courseMapper.selectById(courseId);
            if (course != null) {
                Map<String, Object> courseInfo = new HashMap<>();
                courseInfo.put("id", course.getId());
                courseInfo.put("name", course.getCourseName());
                courseList.add(courseInfo);
            }
        }
        result.put("courses", courseList);

        // 4. 成绩历史数据（用于柱状图展示）
        // 作业成绩（按时间正序：从最早到最新）
        List<Integer> homeworkScores = assignmentsWithInfo.stream()
                .filter(a -> a.get("score") != null)
                .map(a -> (Integer) a.get("score"))
                .collect(Collectors.toList());
        Collections.reverse(homeworkScores); // 反转列表，使时间从早到晚
        result.put("homeworkScores", homeworkScores);
        // 作业标签（用于图表X轴显示）
        result.put("homeworkLabels", assignmentsWithInfo.stream()
                .filter(a -> a.get("score") != null)
                .map(a -> "A" + a.get("id"))
                .collect(Collectors.toList()));

        // 考试成绩（按时间正序：从最早到最新）
        List<Integer> examScores = examsWithInfo.stream()
                .filter(e -> e.get("score") != null)
                .map(e -> (Integer) e.get("score"))
                .collect(Collectors.toList());
        Collections.reverse(examScores); // 反转列表，使时间从早到晚
        result.put("examScores", examScores);
        
        return result;
    }

    /**
     * 获取作业提交的详细作答信息
     * 
     * 返回指定作业提交的所有题目作答详情，包括：
     * - 题目内容、类型、正确答案
     * - 学生答案、是否正确、得分
     * - 错误原因（如果有）
     * - 知识点信息
     * 
     * 该方法使用Service层方法，会自动填充题目信息，确保返回完整的数据。
     * 
     * @param submissionId 作业提交ID
     * @return 作业作答详情列表
     */
    @Override
    public List<AssignmentSubmissionDetail> getAssignmentDetails(Long submissionId) {
        // 使用 Service 方法获取详情，会自动填充题目信息（content, type, answer, knowledgePoint）
        return assignmentSubmissionDetailService.getDetailsBySubmissionId(submissionId);
    }

    /**
     * 获取考试提交的详细作答信息
     * 
     * 返回指定考试提交的所有题目作答详情。
     * 
     * @param submissionId 考试提交ID（exam_submission表的id）
     * @return 考试作答详情列表
     */
    @Override
    public List<ExamSubmissionDetail> getExamDetails(Long submissionId) {
        // submissionId 是 exam_submission 的 id，查询 exam_submission_detail 表
        QueryWrapper<ExamSubmissionDetail> qw = new QueryWrapper<>();
        qw.eq("submission_id", submissionId);
        return examSubmissionDetailMapper.selectList(qw);
    }

    /**
     * 从班级中移除单个学生
     * 
     * 移除前会验证学生是否确实在该班级中。
     * 移除操作是将学生的class_id设置为null，使其脱离该班级。
     * 
     * @param classId 班级ID
     * @param studentId 学生ID
     * @return 操作是否成功，如果学生不在该班级则返回false
     */
    @Override
    public boolean removeStudentFromClass(Long classId, Long studentId) {
        // 验证学生是否在该班级
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("id", studentId);
        queryWrapper.eq("class_id", classId);
        User student = userMapper.selectOne(queryWrapper);
        
        if (student == null) {
            return false; // 学生不在该班级
        }
        
        // 将学生的class_id设置为null，移出班级
        student.setClassId(null);
        int result = userMapper.updateById(student);
        
        return result > 0;
    }

    /**
     * 批量从班级中移除学生
     * 
     * 一次性将多个学生从班级中移除，提高操作效率。
     * 使用批量更新操作，将指定学生的class_id设置为null。
     * 
     * @param classId 班级ID
     * @param studentIds 学生ID列表
     * @return 操作是否成功，如果列表为空则返回false
     */
    @Override
    public boolean batchRemoveStudentsFromClass(Long classId, List<Long> studentIds) {
        if (studentIds == null || studentIds.isEmpty()) {
            return false;
        }
        
        // 批量更新：将指定学生的class_id设置为null
        UpdateWrapper<User> updateWrapper = new UpdateWrapper<>();
        updateWrapper.eq("class_id", classId);
        updateWrapper.in("id", studentIds);
        updateWrapper.set("class_id", null);
        
        int result = userMapper.update(null, updateWrapper);
        
        return result > 0;
    }

    /**
     * 获取可添加到班级的学生列表
     * 
     * 返回所有未加入任何班级的学生（class_id为null），或者不在当前班级的学生。
     * 用于在添加学生到班级时提供可选学生列表。
     * 
     * @param classId 班级ID
     * @return 可添加的学生列表
     */
    @Override
    public List<User> getAvailableStudents(Long classId) {
        // 查询所有学生角色且未加入任何班级的学生（class_id为null），或者不在当前班级的学生
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("role", "student");
        queryWrapper.and(wrapper -> 
            wrapper.isNull("class_id")
                .or()
                .ne("class_id", classId)
        );
        return userMapper.selectList(queryWrapper);
    }

    /**
     * 批量添加学生到班级
     * 
     * 将多个学生同时添加到指定班级，批量更新学生的class_id字段。
     * 
     * @param classId 班级ID
     * @param studentIds 学生ID列表
     * @return 操作是否成功，如果列表为空则返回false
     */
    @Override
    public boolean addStudentsToClass(Long classId, List<Long> studentIds) {
        if (studentIds == null || studentIds.isEmpty()) {
            return false;
        }
        
        // 批量更新：将指定学生的class_id设置为当前班级
        UpdateWrapper<User> updateWrapper = new UpdateWrapper<>();
        updateWrapper.in("id", studentIds);
        updateWrapper.eq("role", "student");
        updateWrapper.set("class_id", classId);
        
        int result = userMapper.update(null, updateWrapper);
        
        return result > 0;
    }

    /**
     * 通过学生ID添加单个学生到班级
     * 
     * 添加前会进行以下验证：
     * 1. 检查学生是否存在
     * 2. 检查学生角色是否为"student"
     * 3. 检查学生是否已在其他班级（如果已在其他班级，返回提示信息）
     * 
     * @param classId 班级ID
     * @param studentId 学生ID
     * @return 包含操作结果的Map，包含以下字段：
     *         - success: 操作是否成功（boolean）
     *         - message: 操作结果消息（String）
     *         - className: 如果学生已在其他班级，返回该班级名称（String，可选）
     */
    @Override
    public Map<String, Object> addStudentById(Long classId, Long studentId) {
        Map<String, Object> result = new HashMap<>();
        
        // 1. 检查学生是否存在
        User student = userMapper.selectById(studentId);
        if (student == null) {
            result.put("success", false);
            result.put("message", "学生不存在");
            return result;
        }
        
        // 2. 检查学生是否已经是学生角色
        if (!"student".equals(student.getRole())) {
            result.put("success", false);
            result.put("message", "该用户不是学生");
            return result;
        }
        
        // 3. 检查学生是否已在某个班级
        if (student.getClassId() != null) {
            // 查询学生所在的班级信息
            SysClass existingClass = sysClassMapper.selectById(student.getClassId());
            String className = existingClass != null ? existingClass.getName() : "未知班级";
            result.put("success", false);
            result.put("message", "该学生已经在" + className + "，请先将该学生从原班级移除再添加");
            result.put("className", className);
            return result;
        }
        
        // 4. 将学生添加到当前班级
        student.setClassId(classId);
        int updateResult = userMapper.updateById(student);
        
        if (updateResult > 0) {
            result.put("success", true);
            result.put("message", "添加成功");
        } else {
            result.put("success", false);
            result.put("message", "添加失败");
        }
        
        return result;
    }

    /**
     * 计算班级作业完成率
     * 
     * 完成率计算公式：完成率 = (已提交作业数) / (作业总数 × 选课学生数) × 100%
     * 
     * 如果courseId为null，则计算所有课程的平均完成率：
     * - 遍历班级所有学生的选课情况
     * - 对每个课程分别计算完成率
     * - 汇总所有课程的完成情况，计算总体完成率
     * 
     * @param classId 班级ID
     * @param courseId 课程ID，如果为null则计算所有课程的平均完成率
     * @return 包含完成率统计信息的Map，包含以下字段：
     *         - completionRate: 完成率（百分比，double类型）
     *         - totalAssignments: 作业总数（int类型）
     *         - totalStudents: 选课学生总数（int类型）
     *         - submittedCount: 已提交作业数（long类型）
     *         - denominator: 分母（作业总数 × 选课学生数，long类型）
     */
    @Override
    public Map<String, Object> getHomeworkCompletionRate(Long classId, Long courseId) {
        return calcCompletionRate(classId, courseId, "totalAssignments",
                cid -> assignmentMapper.selectCount(
                    new QueryWrapper<Assignment>().eq("course_id", cid)).intValue(),
                (clId, cId) -> assignmentSubmissionMapper.countSubmissionsByClassAndCourse(clId, cId),
                (clId, cId) -> getHomeworkCompletionRate(clId, cId));
    }

    /**
     * 计算班级考试完成率，公式及courseId=null聚合逻辑同作业完成率
     */
    @Override
    public Map<String, Object> getExamCompletionRate(Long classId, Long courseId) {
        return calcCompletionRate(classId, courseId, "totalExams",
                cid -> examMapper.selectCount(
                    new QueryWrapper<Exam>().eq("course_id", cid)).intValue(),
                (clId, cId) -> examSubmissionMapper.countSubmissionsByClassAndCourse(clId, cId),
                (clId, cId) -> getExamCompletionRate(clId, cId));
    }

    /**
     * 计算完成率通用逻辑：courseId==null 时遍历所有课程递归汇总，否则按单课程公式计算
     */
    private Map<String, Object> calcCompletionRate(Long classId, Long courseId,
            String itemCountKey,
            java.util.function.Function<Long, Integer> itemCountFn,
            java.util.function.BiFunction<Long, Long, Long> submissionCountFn,
            java.util.function.BiFunction<Long, Long, Map<String, Object>> recurseFn) {

        Map<String, Object> result = new HashMap<>();

        if (courseId == null) {
            List<Map<String, Object>> courseDistribution = studentCourseMapper.getCourseDistributionByClassId(classId);
            if (courseDistribution == null || courseDistribution.isEmpty()) {
                result.put("completionRate", 0.0);
                result.put(itemCountKey, 0);
                result.put("totalStudents", 0);
                result.put("submittedCount", 0);
                return result;
            }

            long totalDenominator = 0, totalSubmitted = 0;
            for (Map<String, Object> courseInfo : courseDistribution) {
                Long cId = ((Number) courseInfo.get("courseId")).longValue();
                Map<String, Object> courseRate = recurseFn.apply(classId, cId);
                totalDenominator += ((Number) courseRate.get("denominator")).longValue();
                totalSubmitted += ((Number) courseRate.get("submittedCount")).longValue();
            }

            double completionRate = totalDenominator > 0 ? (double) totalSubmitted / totalDenominator * 100 : 0.0;
            result.put("completionRate", completionRate);
            result.put(itemCountKey, courseDistribution.size());
            result.put("totalStudents", getStudentsByClassId(classId).size());
            result.put("submittedCount", totalSubmitted);
            result.put("denominator", totalDenominator);
            return result;
        }

        int itemCount = itemCountFn.apply(courseId);
        Long studentCount = nvl(studentCourseMapper.countStudentsByClassAndCourse(classId, courseId), 0L);

        if (studentCount == 0 || itemCount == 0) {
            result.put("completionRate", 0.0);
            result.put(itemCountKey, itemCount);
            result.put("totalStudents", studentCount.intValue());
            result.put("submittedCount", 0);
            result.put("denominator", 0);
            return result;
        }

        long denominator = (long) itemCount * studentCount;
        Long submittedCount = nvl(submissionCountFn.apply(classId, courseId), 0L);
        double completionRate = denominator > 0 ? (double) submittedCount / denominator * 100 : 0.0;

        result.put("completionRate", completionRate);
        result.put(itemCountKey, itemCount);
        result.put("totalStudents", studentCount.intValue());
        result.put("submittedCount", submittedCount);
        result.put("denominator", denominator);
        return result;
    }

    private static Long nvl(Long value, Long defaultVal) {
        return value != null ? value : defaultVal;
    }

    /**
     * 计算班级作业平均成绩
     * 
     * 计算指定班级在指定课程（或所有课程）的作业平均成绩。
     * 如果courseId为null，则计算所有课程的平均成绩。
     * 
     * @param classId 班级ID
     * @param courseId 课程ID，如果为null则计算所有课程
     * @return 包含平均成绩统计信息的Map，包含以下字段：
     *         - averageScore: 平均成绩（double类型）
     *         - submissionCount: 提交数量（long类型，用于参考）
     */
    @Override
    public Map<String, Object> getHomeworkAverageScore(Long classId, Long courseId) {
        Map<String, Object> result = new HashMap<>();
        
        // 计算作业平均成绩（通过Mapper的SQL查询，直接计算平均值）
        Double averageScore = assignmentSubmissionMapper.getAverageScoreByClassAndCourse(classId, courseId);
        
        if (averageScore == null) {
            result.put("averageScore", 0.0);
            result.put("submissionCount", 0);
        } else {
            result.put("averageScore", averageScore);
            // 获取提交数量用于参考
            Long submissionCount = assignmentSubmissionMapper.countSubmissionsByClassAndCourse(classId, courseId);
            result.put("submissionCount", submissionCount != null ? submissionCount : 0);
        }
        
        return result;
    }

    /**
     * 计算班级考试平均成绩
     * 
     * 计算指定班级在指定课程（或所有课程）的考试平均成绩。
     * 如果courseId为null，则计算所有课程的平均成绩。
     * 
     * @param classId 班级ID
     * @param courseId 课程ID，如果为null则计算所有课程
     * @return 包含平均成绩统计信息的Map，包含以下字段：
     *         - averageScore: 平均成绩（double类型）
     *         - submissionCount: 提交数量（long类型，用于参考）
     */
    @Override
    public Map<String, Object> getExamAverageScore(Long classId, Long courseId) {
        Map<String, Object> result = new HashMap<>();
        
        // 计算考试平均成绩（通过Mapper的SQL查询，直接计算平均值）
        Double averageScore = examSubmissionMapper.getAverageScoreByClassAndCourse(classId, courseId);
        
        if (averageScore == null) {
            result.put("averageScore", 0.0);
            result.put("submissionCount", 0);
        } else {
            result.put("averageScore", averageScore);
            // 获取提交数量用于参考
            Long submissionCount = examSubmissionMapper.countSubmissionsByClassAndCourse(classId, courseId);
            result.put("submissionCount", submissionCount != null ? submissionCount : 0);
        }
        
        return result;
    }

    /**
     * 获取学生学情分析所需的所有数据
     * 
     * 该方法收集学生的所有学情数据，用于AI智能学情分析。
     * 收集的数据包括：
     * 1. 学生基本信息：姓名、学习积分
     * 2. 登录记录趋势：最近30天的登录记录，按日期统计登录次数
     * 3. 作业成绩趋势：所有作业的提交记录和成绩，计算平均成绩
     * 4. 考试成绩趋势：所有考试的记录和成绩，计算平均成绩
     * 5. 作业具体作答详情：最近5次作业的详细作答情况，包括题目、答案、得分、错误原因等
     * 6. 考试具体作答详情：最近3次考试的详细作答情况，包括题目、答案、得分、AI反馈等
     * 
     * 所有数据都格式化为文本字符串，便于AI模型理解和分析。
     * 
     * @param studentId 学生ID
     * @return 包含所有学情分析数据的Map，包含以下字段：
     *         - studentName: 学生姓名（String）
     *         - studyScore: 学习积分（Integer）
     *         - loginTrend: 登录记录趋势文本（String，格式化的文本描述）
     *         - homeworkTrend: 作业成绩趋势文本（String，格式化的文本描述）
     *         - examTrend: 考试成绩趋势文本（String，格式化的文本描述）
     *         - homeworkDetails: 作业作答详情文本（String，格式化的文本描述）
     *         - examDetails: 考试作答详情文本（String，格式化的文本描述）
     */
    @Override
    public Map<String, Object> getStudentAnalysisData(Long studentId) {
        Map<String, Object> result = new HashMap<>();

        User student = userMapper.selectById(studentId);
        if (student == null) return result;

        result.put("studentName", student.getRealName() != null ? student.getRealName() : student.getUsername());
        result.put("studyScore", student.getStudyScore() != null ? student.getStudyScore() : 0);
        result.put("loginTrend", buildLoginTrend(studentId));

        List<AssignmentSubmission> submissions = querySubmissions(studentId);
        result.put("homeworkTrend", buildHomeworkTrend(submissions));
        result.put("homeworkDetails", buildHomeworkDetails(submissions));

        List<ExamResult> examResults = queryExamResults(studentId);
        result.put("examTrend", buildExamTrend(examResults));
        result.put("examDetails", buildExamDetails(examResults));

        return result;
    }

    private String buildLoginTrend(Long studentId) {
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(29);
        QueryWrapper<StudentLoginLog> qw = new QueryWrapper<>();
        qw.eq("student_id", studentId)
          .ge("login_time", startDate.atStartOfDay())
          .orderByAsc("login_time");
        List<StudentLoginLog> logs = studentLoginLogMapper.selectList(qw);

        StringBuilder sb = new StringBuilder("最近30天登录记录：\n");
        if (logs.isEmpty()) {
            sb.append("无登录记录\n");
            return sb.toString();
        }
        Map<String, Long> counts = logs.stream()
            .collect(Collectors.groupingBy(
                log -> log.getLoginTime().toLocalDate().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")),
                Collectors.counting()));
        counts.forEach((date, count) -> sb.append(date).append(": ").append(count).append("次\n"));
        sb.append("总计登录天数：").append(counts.size()).append("天\n");
        return sb.toString();
    }

    private List<AssignmentSubmission> querySubmissions(Long studentId) {
        QueryWrapper<AssignmentSubmission> qw = new QueryWrapper<>();
        qw.eq("student_id", studentId).orderByAsc("submitted_at");
        return assignmentSubmissionMapper.selectList(qw);
    }

    private String buildHomeworkTrend(List<AssignmentSubmission> submissions) {
        StringBuilder sb = new StringBuilder("作业成绩趋势：\n");
        if (submissions.isEmpty()) {
            sb.append("暂无作业提交记录\n");
            return sb.toString();
        }
        for (AssignmentSubmission s : submissions) {
            Assignment a = assignmentMapper.selectById(s.getAssignmentId());
            sb.append(a != null ? a.getTitle() : "未知作业")
              .append(" - 提交时间：")
              .append(s.getSubmittedAt() != null
                  ? s.getSubmittedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "未知")
              .append(" - 成绩：")
              .append(s.getScore() != null ? s.getScore() : "未评分")
              .append("分\n");
        }
        double avg = submissions.stream()
            .filter(s -> s.getScore() != null)
            .mapToInt(AssignmentSubmission::getScore).average().orElse(0.0);
        sb.append("作业平均成绩：").append(String.format("%.1f", avg)).append("分\n");
        return sb.toString();
    }

    private String buildHomeworkDetails(List<AssignmentSubmission> submissions) {
        List<AssignmentSubmission> recent = submissions.stream()
            .sorted((a, b) -> b.getSubmittedAt().compareTo(a.getSubmittedAt()))
            .limit(5).collect(Collectors.toList());

        StringBuilder sb = new StringBuilder("最近作业作答详情：\n");
        if (recent.isEmpty()) {
            sb.append("暂无作业作答记录\n");
            return sb.toString();
        }
        for (AssignmentSubmission s : recent) {
            Assignment a = assignmentMapper.selectById(s.getAssignmentId());
            sb.append("\n【作业】").append(a != null ? a.getTitle() : "未知作业").append("\n");

            List<AssignmentSubmissionDetail> details = getAssignmentDetails(s.getId());
            if (details.isEmpty()) {
                sb.append("  无详细作答记录\n");
            } else {
                for (AssignmentSubmissionDetail d : details) {
                    sb.append("  题目：").append(d.getContent() != null ? d.getContent() : "未知题目").append("\n");
                    sb.append("  学生答案：").append(d.getAnswerText() != null ? d.getAnswerText() : "未作答").append("\n");
                    sb.append("  正确答案：").append(d.getAnswer() != null ? d.getAnswer() : "未知").append("\n");
                    sb.append("  是否正确：").append(Boolean.TRUE.equals(d.getIsCorrect()) ? "正确" : "错误").append("\n");
                    sb.append("  得分：").append(d.getScore() != null ? d.getScore() : 0).append("分\n");
                    if (d.getErrorReason() != null && !d.getErrorReason().isEmpty()) {
                        sb.append("  错误原因：").append(d.getErrorReason()).append("\n");
                    }
                    sb.append("\n");
                }
            }
        }
        return sb.toString();
    }

    private List<ExamResult> queryExamResults(Long studentId) {
        QueryWrapper<ExamResult> qw = new QueryWrapper<>();
        qw.eq("student_id", studentId).orderByAsc("created_at");
        return examResultMapper.selectList(qw);
    }

    private String buildExamTrend(List<ExamResult> examResults) {
        StringBuilder sb = new StringBuilder("考试成绩趋势：\n");
        if (examResults.isEmpty()) {
            sb.append("暂无考试记录\n");
            return sb.toString();
        }
        for (ExamResult r : examResults) {
            Exam exam = examMapper.selectById(r.getExamId());
            sb.append(exam != null ? exam.getTitle() : "未知考试")
              .append(" - 考试时间：")
              .append(r.getCreatedAt() != null
                  ? r.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "未知")
              .append(" - 成绩：")
              .append(r.getScore() != null ? r.getScore() : "未评分")
              .append("分\n");
        }
        double avg = examResults.stream()
            .filter(e -> e.getScore() != null)
            .mapToDouble(ExamResult::getScore).average().orElse(0.0);
        sb.append("考试平均成绩：").append(String.format("%.1f", avg)).append("分\n");
        return sb.toString();
    }

    private String buildExamDetails(List<ExamResult> examResults) {
        List<ExamResult> recent = examResults.stream()
            .sorted((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()))
            .limit(3).collect(Collectors.toList());

        StringBuilder sb = new StringBuilder("最近考试作答详情：\n");
        if (recent.isEmpty()) {
            sb.append("暂无考试作答记录\n");
            return sb.toString();
        }
        for (ExamResult r : recent) {
            Exam exam = examMapper.selectById(r.getExamId());
            sb.append("\n【考试】").append(exam != null ? exam.getTitle() : "未知考试").append("\n");
            sb.append("  总分：").append(r.getScore() != null ? r.getScore() : 0).append("分\n");

            QueryWrapper<ExamAnswer> answerQw = new QueryWrapper<>();
            answerQw.eq("exam_result_id", r.getId());
            List<ExamAnswer> answers = examAnswerMapper.selectList(answerQw);

            if (answers.isEmpty()) {
                sb.append("  无详细作答记录\n");
            } else {
                for (ExamAnswer a : answers) {
                    sb.append("  题目ID：").append(a.getQuestionId()).append("\n");
                    sb.append("  学生答案：").append(a.getStudentAnswer() != null ? a.getStudentAnswer() : "未作答").append("\n");
                    sb.append("  正确答案：").append(a.getCorrectAnswer() != null ? a.getCorrectAnswer() : "未知").append("\n");
                    sb.append("  是否正确：").append(Boolean.TRUE.equals(a.getIsCorrect()) ? "正确" : "错误").append("\n");
                    sb.append("  得分：").append(a.getScore() != null ? a.getScore() : 0).append("分\n");
                    if (a.getAiFeedback() != null && !a.getAiFeedback().isEmpty()) {
                        sb.append("  AI反馈：").append(a.getAiFeedback()).append("\n");
                    }
                    sb.append("\n");
                }
            }
        }
        return sb.toString();
    }
}
