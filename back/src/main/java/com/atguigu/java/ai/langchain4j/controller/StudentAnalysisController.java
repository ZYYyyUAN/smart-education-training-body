package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.entity.SysClass;
import com.atguigu.java.ai.langchain4j.entity.User;
import com.atguigu.java.ai.langchain4j.entity.Result;
import com.atguigu.java.ai.langchain4j.entity.AssignmentSubmissionDetail;
import com.atguigu.java.ai.langchain4j.entity.ExamSubmissionDetail;
import com.atguigu.java.ai.langchain4j.service.ClassAnalysisService;
import com.atguigu.java.ai.langchain4j.service.WordExportService;
import com.atguigu.java.ai.langchain4j.assistant.XiaozhiAgent;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

/**
 * 学情信息管理控制器
 * 
 * 该控制器负责处理学情信息管理模块的所有HTTP请求，包括：
 * - 班级信息查询和管理
 * - 学生信息查询和管理
 * - 学情数据统计和分析
 * - AI智能学情分析
 * - 学情分析报告导出
 * 
 * @author 张政
 * @date 2024
 */
@RestController
@RequestMapping("/class")
@CrossOrigin
public class StudentAnalysisController {

    /** 学情分析服务，提供班级和学生数据的查询、统计功能 */
    @Autowired
    private ClassAnalysisService classAnalysisService;

    /** AI助手，提供智能学情分析功能 */
    @Autowired
    private XiaozhiAgent xiaozhiAgent;

    /** Word文档导出服务，用于生成学情分析报告 */
    @Autowired
    private WordExportService wordExportService;

    /**
     * 获取所有班级列表
     * 
     * @return 包含所有班级信息的Result对象
     */
    @GetMapping("/list")
    public Result<List<SysClass>> listClasses() {
        return Result.ok(classAnalysisService.getAllClasses());
    }

    /**
     * 获取班级概览信息
     * 
     * 该功能展示班级的基本统计信息，包括：
     * - 班级总人数
     * - 平均学习积分
     * - 优秀率（学习积分>=100的学生比例）
     * - 班级名称和教师信息
     * - 班级科目分布（各课程的学生数量）
     * 
     * @param classId 班级ID
     * @return 包含班级概览统计信息的Result对象
     */
    @GetMapping("/{classId}/overview")
    public Result<Map<String, Object>> getClassOverview(@PathVariable Long classId) {
        return Result.ok(classAnalysisService.getClassOverview(classId));
    }

    /**
     * 获取指定班级的所有学生列表
     * 
     * @param classId 班级ID
     * @return 包含该班级所有学生信息的Result对象
     */
    @GetMapping("/{classId}/students")
    public Result<List<User>> getStudents(@PathVariable Long classId) {
        return Result.ok(classAnalysisService.getStudentsByClassId(classId));
    }

    /**
     * 获取学生详细信息
     * 
     * 返回学生的完整学情数据，包括：
     * - 登录记录趋势（最近7天的登录次数）
     * - 作业提交记录（包含标题、课程信息、成绩等）
     * - 考试记录（包含标题、课程信息、成绩等）
     * - 作业成绩趋势（用于柱状图展示）
     * - 考试成绩趋势（用于柱状图展示）
     * - 可选课程列表（用于前端筛选）
     * 
     * @param studentId 学生ID
     * @return 包含学生详细学情信息的Result对象
     */
    @GetMapping("/student/{studentId}/details")
    public Result<Map<String, Object>> getStudentDetails(@PathVariable Long studentId) {
        return Result.ok(classAnalysisService.getStudentDetails(studentId));
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
     * @param submissionId 作业提交ID
     * @return 包含作业作答详情的Result对象
     */
    @GetMapping("/assignment/{submissionId}/details")
    public Result<List<AssignmentSubmissionDetail>> getAssignmentDetails(@PathVariable Long submissionId) {
        return Result.ok(classAnalysisService.getAssignmentDetails(submissionId));
    }

    /**
     * 获取考试提交的详细作答信息
     * 
     * 返回指定考试提交的所有题目作答详情，包括：
     * - 题目ID、正确答案
     * - 学生答案、是否正确、得分
     * - AI反馈信息（如果有）
     * 
     * @param submissionId 考试提交ID
     * @return 包含考试作答详情的Result对象
     */
    @GetMapping("/exam/{submissionId}/details")
    public Result<List<ExamSubmissionDetail>> getExamDetails(@PathVariable Long submissionId) {
        return Result.ok(classAnalysisService.getExamDetails(submissionId));
    }

    /**
     * 从班级中移除单个学生
     * 
     * 将指定学生的class_id设置为null，使其脱离该班级。
     * 移除前会验证学生是否确实在该班级中。
     * 
     * @param classId 班级ID
     * @param request 请求体，包含studentId字段
     * @return 操作结果，成功返回提示信息，失败返回错误信息
     */
    @PostMapping("/{classId}/remove-student")
    public Result<String> removeStudentFromClass(@PathVariable Long classId, @RequestBody Map<String, Long> request) {
        Long studentId = request.get("studentId");
        if (studentId == null) {
            return Result.error("学生ID不能为空");
        }
        
        boolean success = classAnalysisService.removeStudentFromClass(classId, studentId);
        if (success) {
            return Result.ok("学生已成功移出班级");
        } else {
            return Result.error("移除失败，学生可能不在该班级");
        }
    }

    /**
     * 批量从班级中移除学生
     * 
     * 一次性将多个学生从班级中移除，提高操作效率。
     * 
     * @param classId 班级ID
     * @param request 请求体，包含studentIds字段（学生ID列表）
     * @return 操作结果，成功返回移除的学生数量，失败返回错误信息
     */
    @PostMapping("/{classId}/batch-remove-students")
    public Result<String> batchRemoveStudents(@PathVariable Long classId, @RequestBody Map<String, List<Long>> request) {
        List<Long> studentIds = request.get("studentIds");
        if (studentIds == null || studentIds.isEmpty()) {
            return Result.error("学生ID列表不能为空");
        }
        
        boolean success = classAnalysisService.batchRemoveStudentsFromClass(classId, studentIds);
        if (success) {
            return Result.ok("已成功移除 " + studentIds.size() + " 名学生");
        } else {
            return Result.error("批量移除失败");
        }
    }

    /**
     * 获取可添加到班级的学生列表
     * 
     * 返回所有未加入任何班级的学生，或者不在当前班级的学生。
     * 用于在添加学生到班级时提供可选学生列表。
     * 
     * @param classId 班级ID
     * @return 包含可添加学生列表的Result对象
     */
    @GetMapping("/{classId}/available-students")
    public Result<List<User>> getAvailableStudents(@PathVariable Long classId) {
        return Result.ok(classAnalysisService.getAvailableStudents(classId));
    }

    /**
     * 批量添加学生到班级
     * 
     * 将多个学生同时添加到指定班级，批量更新学生的class_id字段。
     * 
     * @param classId 班级ID
     * @param request 请求体，包含studentIds字段（学生ID列表）
     * @return 操作结果，成功返回添加的学生数量，失败返回错误信息
     */
    @PostMapping("/{classId}/add-students")
    public Result<String> addStudentsToClass(@PathVariable Long classId, @RequestBody Map<String, List<Long>> request) {
        List<Long> studentIds = request.get("studentIds");
        if (studentIds == null || studentIds.isEmpty()) {
            return Result.error("学生ID列表不能为空");
        }
        
        boolean success = classAnalysisService.addStudentsToClass(classId, studentIds);
        if (success) {
            return Result.ok("已成功添加 " + studentIds.size() + " 名学生");
        } else {
            return Result.error("添加学生失败");
        }
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
     * @param request 请求体，包含studentId字段
     * @return 操作结果，包含success、message等字段，如果学生已在其他班级，还会包含className字段
     */
    @PostMapping("/{classId}/add-student-by-id")
    public Result<Map<String, Object>> addStudentById(@PathVariable Long classId, @RequestBody Map<String, Long> request) {
        Long studentId = request.get("studentId");
        if (studentId == null) {
            return Result.error("学生ID不能为空");
        }
        
        Map<String, Object> result = classAnalysisService.addStudentById(classId, studentId);
        if ((Boolean) result.get("success")) {
            return Result.ok(result);
        } else {
            return Result.error((String) result.get("message"));
        }
    }

    /**
     * 获取班级作业完成率
     * 
     * 计算指定班级在指定课程（或所有课程）的作业完成率。
     * 完成率 = (已提交作业数) / (作业总数 × 选课学生数) × 100%
     * 
     * 如果courseId为null，则计算所有课程的平均完成率。
     * 
     * @param classId 班级ID
     * @param courseId 课程ID，可选参数，为null时计算所有课程
     * @return 包含完成率、总作业数、总学生数、已提交数等信息的Result对象
     */
    @GetMapping("/{classId}/homework-completion-rate")
    public Result<Map<String, Object>> getHomeworkCompletionRate(
            @PathVariable Long classId,
            @RequestParam(required = false) Long courseId) {
        return Result.ok(classAnalysisService.getHomeworkCompletionRate(classId, courseId));
    }

    /**
     * 获取班级考试完成率
     * 
     * 计算指定班级在指定课程（或所有课程）的考试完成率。
     * 完成率 = (已提交考试数) / (考试总数 × 选课学生数) × 100%
     * 
     * 如果courseId为null，则计算所有课程的平均完成率。
     * 
     * @param classId 班级ID
     * @param courseId 课程ID，可选参数，为null时计算所有课程
     * @return 包含完成率、总考试数、总学生数、已提交数等信息的Result对象
     */
    @GetMapping("/{classId}/exam-completion-rate")
    public Result<Map<String, Object>> getExamCompletionRate(
            @PathVariable Long classId,
            @RequestParam(required = false) Long courseId) {
        return Result.ok(classAnalysisService.getExamCompletionRate(classId, courseId));
    }

    /**
     * 获取班级作业平均成绩
     * 
     * 计算指定班级在指定课程（或所有课程）的作业平均成绩。
     * 如果courseId为null，则计算所有课程的平均成绩。
     * 
     * @param classId 班级ID
     * @param courseId 课程ID，可选参数，为null时计算所有课程
     * @return 包含平均成绩、提交数量等信息的Result对象
     */
    @GetMapping("/{classId}/homework-average-score")
    public Result<Map<String, Object>> getHomeworkAverageScore(
            @PathVariable Long classId,
            @RequestParam(required = false) Long courseId) {
        return Result.ok(classAnalysisService.getHomeworkAverageScore(classId, courseId));
    }

    /**
     * 获取班级考试平均成绩
     * 
     * 计算指定班级在指定课程（或所有课程）的考试平均成绩。
     * 如果courseId为null，则计算所有课程的平均成绩。
     * 
     * @param classId 班级ID
     * @param courseId 课程ID，可选参数，为null时计算所有课程
     * @return 包含平均成绩、提交数量等信息的Result对象
     */
    @GetMapping("/{classId}/exam-average-score")
    public Result<Map<String, Object>> getExamAverageScore(
            @PathVariable Long classId,
            @RequestParam(required = false) Long courseId) {
        return Result.ok(classAnalysisService.getExamAverageScore(classId, courseId));
    }

    /**
     * AI智能学情分析
     * 
     * 基于qwen-plus大模型对学生的学习情况进行全面、深入的智能分析。
     * 分析维度包括：
     * 1. 学习行为分析：登录频率、活跃度、学习习惯、参与度
     * 2. 成绩表现分析：作业和考试成绩趋势、波动原因、与平均水平对比
     * 3. 知识掌握情况：知识薄弱点识别、掌握较好的知识点、理解深度评估
     * 4. 学习问题诊断：潜在问题识别、错误类型分析、学习态度评估
     * 5. 个性化教学建议：针对性改进建议、学习方法推荐、学习计划制定
     * 
     * 该方法使用流式响应（Flux），实时返回AI分析结果，提升用户体验。
     * 
     * @param studentId 学生ID
     * @return 流式返回AI分析结果，内容格式化为结构化的分析报告
     */
    @GetMapping(value = "/student/{studentId}/ai-analysis", produces = "text/plain;charset=UTF-8")
    public Flux<String> analyzeStudentLearning(@PathVariable Long studentId) {
        // 获取学生学情分析所需的所有数据
        // 包括：学生基本信息、登录记录趋势、作业成绩趋势、考试成绩趋势、作业作答详情、考试作答详情
        Map<String, Object> analysisData = classAnalysisService.getStudentAnalysisData(studentId);
        
        // 提取数据，如果数据为空则使用默认值
        String studentName = (String) analysisData.get("studentName");
        Integer studyScore = (Integer) analysisData.get("studyScore");
        String loginTrend = (String) analysisData.get("loginTrend");
        String homeworkTrend = (String) analysisData.get("homeworkTrend");
        String examTrend = (String) analysisData.get("examTrend");
        String homeworkDetails = (String) analysisData.get("homeworkDetails");
        String examDetails = (String) analysisData.get("examDetails");
        
        // 调用AI助手进行学情分析，返回流式数据
        return xiaozhiAgent.analyzeStudentLearning(
            studentName != null ? studentName : "未知学生",
            studyScore != null ? studyScore : 0,
            loginTrend != null ? loginTrend : "无登录记录",
            homeworkTrend != null ? homeworkTrend : "无作业记录",
            examTrend != null ? examTrend : "无考试记录",
            homeworkDetails != null ? homeworkDetails : "无作业作答详情",
            examDetails != null ? examDetails : "无考试作答详情"
        );
    }

    /**
     * 导出学情分析报告为Word文档
     * 
     * 将AI生成的学情分析报告导出为格式规范的Word文档（.docx格式）。
     * 文档包含：
     * - 报告标题和学生基本信息
     * - 生成时间
     * - 结构化的分析内容（自动识别标题、段落、列表等格式）
     * - 页脚信息
     * 
     * 文档使用Apache POI技术生成，支持：
     * - 标题、段落、列表的自动格式化
     * - 字体、字号、颜色的设置
     * - 页面边距和页面大小的配置
     * - 首行缩进、段落间距等排版设置
     * 
     * @param studentId 学生ID
     * @param request 请求体，必须包含analysisContent字段（AI分析的内容）
     * @return Word文档的字节数组响应，文件名为"学生姓名_学情分析报告.docx"
     * @throws IOException 文件生成异常
     */
    @PostMapping("/student/{studentId}/export-report")
    public ResponseEntity<byte[]> exportLearningAnalysisReport(
            @PathVariable Long studentId,
            @RequestBody Map<String, String> request) {
        try {
            // 获取学生信息，用于生成文件名
            Map<String, Object> studentData = classAnalysisService.getStudentAnalysisData(studentId);
            String studentName = (String) studentData.get("studentName");
            if (studentName == null || studentName.isEmpty()) {
                studentName = "未知学生";
            }
            
            // 获取AI分析内容，如果为空则返回错误
            String analysisContent = request.get("analysisContent");
            if (analysisContent == null || analysisContent.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }
            
            // 调用Word导出服务生成文档
            byte[] wordBytes = wordExportService.generateLearningAnalysisReport(studentName, analysisContent);
            
            // 设置HTTP响应头，指定文件下载
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
            // 对文件名进行URL编码，支持中文文件名
            String fileName = URLEncoder.encode(studentName + "_学情分析报告.docx", StandardCharsets.UTF_8);
            headers.setContentDispositionFormData("attachment", fileName);
            headers.setContentLength(wordBytes.length);
            
            return ResponseEntity.ok()
                    .headers(headers)
                    .body(wordBytes);
                    
        } catch (IOException e) {
            // 文件生成异常，返回服务器错误
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        } catch (Exception e) {
            // 其他异常，返回请求错误
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }
}
