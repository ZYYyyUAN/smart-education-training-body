package com.atguigu.java.ai.langchain4j.controller;

import com.alibaba.fastjson.JSON;
import com.atguigu.java.ai.langchain4j.assistant.XiaozhiAgent;
import com.atguigu.java.ai.langchain4j.bean.ChatForm;
import com.atguigu.java.ai.langchain4j.entity.*;
import com.atguigu.java.ai.langchain4j.entity.Result;
import com.atguigu.java.ai.langchain4j.service.*;
import com.atguigu.java.ai.langchain4j.mapper.ExamMapper;
import com.atguigu.java.ai.langchain4j.mapper.StudentLoginLogMapper;
import com.atguigu.java.ai.langchain4j.mapper.StudentMapper;
import com.atguigu.java.ai.langchain4j.mapper.UserMapper;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
// import com.openai.models.ChatModel;
// import dev.langchain4j.community.model.dashscope.QwenChatModel;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
// import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
// import org.springframework.util.StringUtils;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.openai.models.ChatModel;
import dev.langchain4j.community.model.dashscope.QwenChatModel;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.PathVariable;
import reactor.core.publisher.Flux;
import dev.langchain4j.rag.query.Query;
import dev.langchain4j.rag.content.Content;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.function.Function;


@Tag(name = "硅谷小智学生端")
@RestController
@RequestMapping("/xiaozhi/student")
@Slf4j
public class StudentController {
    
    @Autowired
    private StudentLoginLogService studentLoginLogService;
    @Autowired
    private StudentLoginLogMapper studentLoginLogMapper;
    @Autowired
    private ExamMapper examMapper;
    
    @Autowired
    private PracticeRecordService practiceRecordService;
    
    @Autowired
    private XiaozhiAgent xiaozhiAgent;

    @Autowired
    private PracticeService practiceService;
    @Autowired
    private StudentCourseService studentCourseService;
    @Autowired
    private AssignmentService assignmentService;
    @Autowired
    private QuestionService questionService;
    @Autowired
    private AssignmentSubmissionService submissionService;
    @Autowired
    private AssignmentSubmissionDetailService detailService;
    @Autowired
    private ExamService examService;

    @Autowired
    private java.util.function.Function<String, dev.langchain4j.rag.content.retriever.ContentRetriever> courseContentRetrieverFactory;
    @Autowired
    private CourseService courseService;
    @Autowired
    private StudentMapper studentMapper;

    @Autowired
    private StudyScoreService studyScoreService;

    @Autowired
    private UserMapper userMapper;


    @Operation(summary = "对话（可按课程检索）")
    @PostMapping(value = "/chat")
    public Flux<String> chat(@RequestBody ChatForm chatForm) {
        log.info("学生端对话, memoryId={}, courseId={}", chatForm.getMemoryId(), chatForm.getCourseId());
        // 直接调用代理，后续可根据courseId扩展至专用Agent
        return xiaozhiAgent.chat(chatForm.getMemoryId(), chatForm.getMessage());
    }

    @Operation(summary = "对话-按课程检索")
    @PostMapping(value = "/chat/by-course")
    public Flux<String> chatByCourse(@RequestBody ChatForm chatForm) {
        Long courseId = chatForm.getCourseId();
        String question = chatForm.getMessage();
        // 使用课程名作为命名空间（与资源入库时保持一致）
        String namespace = "course-" + (courseId == null ? "default" : courseId);
        if (courseId != null) {
            try {
                var course = courseService.getCourseById(courseId);
                if (course != null && course.getCourseName() != null && !course.getCourseName().isEmpty()) {
                    // 规范化课程名为命名空间（与ResourceServiceImpl.ingestResource保持一致）
                    String safe = course.getCourseName().trim().toLowerCase()
                            .replaceAll("[^a-z0-9\\-_]+", "-")
                            .replaceAll("-+", "-")
                            .replaceAll("^-|-$", "");
                    if (!safe.isEmpty()) {
                        namespace = safe;
                    }
                }
            } catch (Exception ignore) {}
        }

        // 1) 检索
        var retriever = courseContentRetrieverFactory.apply(namespace);
        java.util.List<Content> results = retriever.retrieve(Query.from(question));
        StringBuilder ctx = new StringBuilder();
        
        // 记录检索结果数量
        log.info("[COURSE-CHAT] 课程ID: {}, 命名空间: {}, 检索到 {} 条相关内容", courseId, namespace, results.size());
        
        for (Content c : results) {
            try {
                String text = c.textSegment().text();
                ctx.append(text).append("\n\n");
                log.debug("[COURSE-CHAT] 检索内容片段: {}", text.length() > 100 ? text.substring(0, 100) + "..." : text);
            } catch (Exception e) {
                log.warn("[COURSE-CHAT] 处理检索内容失败", e);
            }
        }
        
        // 如果没有检索到相关内容，添加默认的嵌入式开发知识
        if (ctx.length() == 0) {
            log.warn("[COURSE-CHAT] 未检索到相关内容，使用默认知识库");
            ctx.append("嵌入式开发进阶课程内容：\n");
            ctx.append("- ARM架构基础：了解ARM Cortex-M系列处理器架构特点\n");
            ctx.append("- Linux系统编程：掌握系统调用、文件操作、进程管理\n");
            ctx.append("- 硬件接口编程：GPIO、UART、SPI、I2C等接口的使用\n");
            ctx.append("- 驱动开发：字符设备驱动、平台设备驱动开发\n");
            ctx.append("- 交叉编译：使用arm-linux-gnueabihf工具链进行交叉编译\n");
            ctx.append("- 调试技术：GDB调试、JTAG调试、串口调试\n");
        }

        // 2) 课程名（数据库查）
        String courseName = "课程" + (courseId == null ? "" : ("#" + courseId));
        if (courseId != null) {
            try {
                var course = courseService.getCourseById(courseId);
                if (course != null && course.getCourseName() != null && !course.getCourseName().isEmpty()) {
                    courseName = course.getCourseName();
                }
            } catch (Exception ignore) {}
        }

        // 3) 通用提示词
        String template;
        try (java.io.InputStream in = java.util.Objects.requireNonNull(this.getClass().getClassLoader().getResourceAsStream("xiaozhi-course.txt"))) {
            template = new String(in.readAllBytes());
        } catch (java.io.IOException e) {
            template = "课程：{{courseName}}\n问题：{{question}}\n资料：\n{{context}}\n请作答：";
        }
        // 加一点更活泼的语气与表情，特别针对嵌入式开发
        String prompt = template
                .replace("{{courseName}}", courseName)
                .replace("{{question}}", question)
                .replace("{{context}}", ctx.toString())
                + "\n\n请用轻松友好的语气回答，适当加入快乐的表情符号如😀🎯💡🔧⚡，但不要影响专业性。"
                + "\n\n⚠️ 重要提醒："
                + "\n- 请直接回答学生的问题，不要生成题目格式（如【题型】、【题干】、【答案】、【知识点】等）"
                + "\n- 你的任务是解答疑问和提供学习指导，不是出题"
                + "\n- 回答应该是对话式的，自然流畅的文本"
                + "\n- 如果学生问的是嵌入式开发相关问题，请重点从以下角度回答："
                + "\n  1. 硬件层面：处理器架构、接口特性、电路原理"
                + "\n  2. 软件层面：编程语言、系统调用、驱动开发"
                + "\n  3. 实践层面：开发工具、调试方法、项目经验"
                + "\n  4. 学习路径：循序渐进的学习建议和资源推荐";

        // 3.5) 仅打印本次喂给大模型的最终上下文（单行简洁预览）
        if (log.isInfoEnabled()) {
            String preview = prompt.replaceAll("[\r\n]+", " ");
            if (preview.length() > 1200) preview = preview.substring(0, 1200) + "...[truncated]";
            log.info("[LLM-PROMPT][ns={}] memoryId={} len={} preview=\"{}\"", namespace, chatForm.getMemoryId(), prompt.length(), preview);
        }

        // 4) 生成
        return xiaozhiAgent.answerWithPrompt(prompt);
    }

    @Operation(summary = "从学生历史记录生成题目")
    @PostMapping("/generate/history")
    public Result<List<QuestionDto>> generatePractice(@RequestBody QuestionRequestDto request) {
        return Result.ok(practiceService.generatePracticeByHistory(request));
    }
    @Operation(summary = "评估学生作答")
    @PostMapping("/evaluate")
    public Flux<String> evaluatePractice(@RequestBody EvaluateRequest request) {
        Long memoryId = request.getMemoryId();
        Long questionId = request.getQuestionId();
        String answer = request.getAnswer();

        // 从题库中获取原题与标准答案
        QuestionBank question = questionService.selectById(questionId);
        if (question == null) {
            return Flux.just("题目不存在，请检查 questionId 是否正确。");
        }

        return xiaozhiAgent.evaluatePractice(
                memoryId,
                question.getContent(),
                question.getAnswer(),
                answer
        );
    }

    @Operation(summary = "评估学生作答优化版")
    @PostMapping("/evaluate2")
    public Mono<EvaluationResult> evaluatePractice2(@RequestBody EvaluateRequest2 request) {
        Long memoryId = request.getMemoryId();
        String content = request.getContent();
        String standardAnswer = request.getStandardAnswer();
        String answer = request.getAnswer();

        // 调用 AI 服务获取 JSON 字符串（注意：返回类型是 String，不是 Mono<String>）
        String jsonString = xiaozhiAgent.evaluatePracticeRawJson(memoryId, content, standardAnswer, answer);

        // 解析 JSON 字符串为 EvaluationResult 对象
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            EvaluationResult result = objectMapper.readValue(jsonString, EvaluationResult.class);
            return Mono.just(result); // 包装为 Mono 返回
        } catch (JsonProcessingException e) {
            return Mono.error(new RuntimeException("解析 JSON 失败: " + e.getMessage()));
        }
    }


    @PostMapping("/addCourse")
    @Operation(summary = "学生加入课程")
    public Result<?> addCourse(@RequestParam("studentId") Long studentId, @RequestParam("courseId") Long courseId) {
        boolean success = studentCourseService.joinCourse(studentId, courseId);
        return success ? Result.ok("加入课程成功！") : Result.error("加入失败：可能已加入或课程不存在！");
    }
    // ✅ 查看自己选的课程（前端传 studentId）
    @GetMapping("/my-courses")
    @Operation(summary = "查看自己选的课程")
    public Result<List<Course>> getMyCourses(@RequestParam("studentId") Long studentId) {
        return Result.ok(studentCourseService.getMyCourses(studentId));
    }

    // ✅ 退课（前端传 studentId 和 courseId）
    @Operation(summary = "退课")
    @DeleteMapping("/drop-course")
    public String dropCourse(@RequestParam("studentId") Long studentId, @RequestParam("courseId") Long courseId) {
        boolean success = studentCourseService.dropCourse(studentId, courseId);
        return success ? "退课成功" : "退课失败";
    }
    @Operation(summary = "查看自己的作业")
    @GetMapping("/assignments")
    public Result<List<AssignmentWithStatusDTO>> getMyAssignments(@RequestParam("studentId") Long studentId) {
        List<AssignmentWithStatusDTO> assignments = assignmentService.getAssignmentsByStudentId(studentId);
        return Result.ok(assignments);
    }


    // 学生提交作业接口示例
    @PostMapping("/submit")
    @Operation(summary = "学生提交作业")
    public Result<String> submit(@RequestBody SubmitAssignmentRequest request) {
        Long submissionId = submissionService.saveSubmission(request);
        return Result.ok("提交成功，提交ID: " + submissionId);
    }

    // 查询学生某次作业题目作答详情
    @GetMapping("/details")
    @Operation(summary = "查询学生某次作业题目作答详情")
    public Result<List<AssignmentSubmissionDetail>> getDetails(@RequestParam("assignmentId") Long assignmentId) {
        try {
            // 1. 获取作业基本信息
            AssignmentDetailDTO assignmentDetail = assignmentService.getAssignmentDetail(assignmentId);
            
            // 2. 获取提交ID和提交信息
            Long submissionId = submissionService.getSubmissionIdByAssignmentId(assignmentId);
            if (submissionId == null) {
                return Result.error("未找到该作业的提交记录");
            }
            
            // 3. 获取提交基本信息（包含提交时间）
            AssignmentSubmission submission = submissionService.getSubmissionById(submissionId);
            
            // 4. 获取提交详情
            List<AssignmentSubmissionDetail> details = detailService.getDetailsBySubmissionId(submissionId);
            
            // 5. 给每个详情添加提交时间信息
            if (submission != null) {
                details.forEach(detail -> {
                    detail.setSubmittedAt(submission.getSubmittedAt());
                });
            }
            
            // 6. 如果题目信息为空，从作业详情中补充
            if (assignmentDetail != null && assignmentDetail.getQuestions() != null) {
                Map<Long, QuestionBank> questionMap = assignmentDetail.getQuestions().stream()
                        .collect(Collectors.toMap(QuestionBank::getId, Function.identity()));
                
                details.forEach(detail -> {
                    if (detail.getQuestionId() != null && 
                        (detail.getContent() == null || detail.getContent().isEmpty())) {
                        QuestionBank question = questionMap.get(detail.getQuestionId());
                        if (question != null) {
                            detail.setContent(question.getContent());
                            detail.setType(question.getType());
                            detail.setAnswer(question.getAnswer());
                            detail.setKnowledgePoint(question.getKnowledgePoint());
                        }
                    }
                });
            }
            
            return Result.ok(details);
        } catch (Exception e) {
            log.error("获取作业详情失败", e);
            return Result.error("获取作业详情失败: " + e.getMessage());
        }
    }


    // 🧠 调用智能体生成题目（不保存）
    @PostMapping("/generate")
    @Operation(summary = "通过学生要求生成题目")
    public Result<List<QuestionDto>> generate(@RequestBody QuestionRequestDto request) {
        List<QuestionDto> questions = questionService.generateQuestionsByRequirement(request);
        return Result.ok(questions);
    }


    // 批量保存题目
    @PostMapping("/save")
    @Operation(summary = "保存学生生成的题目")
    public Result<List<Long>> save(@RequestBody SaveQuestionsRequestDto request) {
        return Result.ok(questionService.saveGeneratedQuestions(request));

    }
    @GetMapping("/upcoming")
    @Operation(summary = "重要提醒：作业+考试")
    public Result<Map<String, Object>> getUpcomingItems(
            @RequestParam("studentId") Long studentId,
            @RequestParam(value="days",defaultValue = "3") int days) {
        List<Assignment> assignments = assignmentService.getUpcomingAssignments(studentId, days);
        List<Exam> exams = examService.getUpcomingExams(studentId, days);
        Map<String, Object> map = new java.util.HashMap<>();
        map.put("assignments", assignments);
        map.put("exams", exams);
        return Result.ok(map);
    }
    @Autowired
    private PracticeLogService practiceLogService;
    @Operation(summary = "查询自己的答题记录")
    @GetMapping("/practice-log")
    public Result<List<PracticeLogVO>> getStudentPracticeLogs(@RequestParam("studentId")Long studentId) {
        List<PracticeLogVO> logs = practiceLogService.getLogsForStudent(studentId);
        return Result.ok(logs);
    }
    @PostMapping("similar/generate")
    @Operation(summary = "生成相似题目库")
    public ResponseEntity<List<QuestionSimilarDTO>> generateSimilarQuestion(@RequestBody GenerateSimilarRequest req) {
        // 获取原题
        QuestionBank question = practiceLogService.getQuestionById(req.getQuestionId());
        if (question == null) return ResponseEntity.badRequest().build();

        // 调用智能体生成相似题（可改为多道）
        String json = xiaozhiAgent.generateSimilarQuestions(
                question.getContent(),
                question.getAnswer(),
                question.getKnowledgePoint(),
                question.getType(),
                req.getCount()
        );

        // 转成对象返回
        List<QuestionSimilarDTO> list = JSON.parseArray(json, QuestionSimilarDTO.class);
        return ResponseEntity.ok(list);
    }
    /**
     * 2. 学生提交答案并评分
     */
//    @PostMapping("/submit")
//    public ResponseEntity<EvaluateResult> submitAndEvaluate(@RequestBody EvaluateRequest req) {
//        // 调用智能体同步评分
//        String resultJson = xiaozhiAgent.evaluatePracticeSync(
//                req.getQuestion().getContent(),
//                req.getAnswer(),
//                req.getQuestion().getAnswer()
//        );
//        EvaluateResult result = JSON.parseObject(resultJson, EvaluateResult.class);
//
//        // 保存记录
//        practiceLogService.saveSimilarPracticeLog(
//                req.getStudentId(),
//                req.getQuestion(),
//                req.getAnswer(),
//                result
//        );
//
//        return ResponseEntity.ok(result);
//    }
    @GetMapping("/practice/detail")
    @Operation(summary = "根据做题记录id查询每道做题记录")
    public Result<PracticeLogDetailVO> getPracticeLogDetail(@RequestParam("id") Long id) {
        PracticeLogDetailVO detail = practiceLogService.getPracticeLogDetail(id);
        return Result.ok(detail);
    }
    @Operation(summary = "相似题目评估学生作答")
    @PostMapping("/similar/evaluate")
    public Flux<String> SimilarevaluatePractice(@RequestParam("content")String content,@RequestParam("standardAnswer")String standardAnswer,@RequestParam("answer")String answer) {

        return xiaozhiAgent.evaluatePractice(
                1l,
               content,
                standardAnswer,
                answer
        );
    }
    @Operation(summary = "根据创建人ID获取题目列表")
    @GetMapping("/questions/by-creator")
    public Result<List<QuestionDto>> getAllQuestionsByCreator(
            @RequestParam("createdBy") Long createdBy) {
        return Result.ok(questionService.getByCreateId(createdBy));
    }

    @Operation(summary = "保存练习记录")
    @PostMapping("/savePracticeRecord")
    public Result<?> savePracticeRecord(@RequestBody PracticeRecordRequest request) {
        try {
            practiceLogService.savePracticeRecord(request);

            // 自动更新学习积分
            if (request.getStudentId() != null) {
                try {
                    int newScore = studyScoreService.updateStudyScore(request.getStudentId());
                    log.info("练习记录保存后自动更新学习积分，学生ID: {}, 新积分: {}", request.getStudentId(), newScore);
                } catch (Exception scoreError) {
                    log.warn("自动更新学习积分失败，学生ID: {}", request.getStudentId(), scoreError);
                    // 不影响练习记录保存的主要流程
                }
            }

            return Result.ok("练习记录保存成功");
        } catch (Exception e) {
            log.error("保存练习记录失败", e);
            return Result.error("保存练习记录失败: " + e.getMessage());
        }
    }

    @Operation(summary = "获取练习历史记录")
    @GetMapping("/getPracticeHistory")
    public Result<Map<String, Object>> getPracticeHistory(
            @RequestParam("studentId") Long studentId,
            @RequestParam(value = "page", defaultValue = "1") Integer page,
            @RequestParam(value = "size", defaultValue = "10") Integer size,
            @RequestParam(value = "courseId", required = false) String courseId,
            @RequestParam(value = "sortBy", defaultValue = "date-desc") String sortBy,
            @RequestParam(value = "startDate", required = false) String startDate,
            @RequestParam(value = "endDate", required = false) String endDate) {
        try {
            Map<String, Object> result = practiceLogService.getPracticeHistory(
                studentId, page, size, courseId, sortBy, startDate, endDate);
            return Result.ok(result);
        } catch (Exception e) {
            log.error("获取练习历史记录失败", e);
            return Result.error("获取练习历史记录失败: " + e.getMessage());
        }
    }

    @Operation(summary = "查询学生在课程下的考试（含提交状态）")
    @GetMapping("/exams")
    public Result<List<ExamWithStatusDTO>> getExamsByCourse(
            @RequestParam("studentId") Long studentId,
            @RequestParam("courseId") Long courseId) {
        return Result.ok(examService.getExamsWithStatus(studentId, courseId));
    }

    @Operation(summary = "获取考试信息")
    @GetMapping("/exam/{examId}")
    public Result<Exam> getExamInfo(@PathVariable("examId") Long examId) {
        try {
            Exam exam = examMapper.selectById(examId);
            if (exam == null) {
                return Result.error("考试不存在");
            }
            return Result.ok(exam);
        } catch (Exception e) {
            log.error("获取考试信息失败", e);
            return Result.error("获取考试信息失败: " + e.getMessage());
        }
    }

    @Operation(summary = "获取考试题目（按考试ID）")
    @GetMapping("/exam/questions")
    public Result<List<QuestionBank>> getExamQuestions(@RequestParam("examId") Long examId) {
        return Result.ok(questionService.getQuestionsByExamId(examId));
    }

    @Operation(summary = "获取错题排行榜")
    @GetMapping("/weakPointsRanking")
    public Result<List<Map<String, Object>>> getWeakPointsRanking(
            @RequestParam("studentId") Long studentId,
            @RequestParam("courseId") Long courseId,
            @RequestParam(value = "limit", defaultValue = "5") Integer limit) {
        try {
            // 优先使用practice_record_detail表的数据，如果没有数据则使用practice_log表
            List<Map<String, Object>> ranking = practiceLogService.getWeakPointsRankingFromPracticeRecord(studentId, courseId, limit);
            if (ranking == null || ranking.isEmpty()) {
                // 如果新表没有数据，回退到旧表
                ranking = practiceLogService.getWeakPointsRanking(studentId, courseId, limit);
            }
            return Result.ok(ranking);
        } catch (Exception e) {
            log.error("获取错题排行榜失败", e);
            return Result.error("获取错题排行榜失败: " + e.getMessage());
        }
    }

    @Operation(summary = "获取课程学习积分排行榜（从数据库study_score字段获取）")
    @GetMapping("/leaderboard")
    public Result<List<Map<String, Object>>> getCourseLeaderboard(
            @RequestParam(value = "courseId", required = false) Long courseId,
            @RequestParam(value = "studentId", required = false) Long studentId
    ) {
        try {
            // 若未传课程ID则返回空数组，前端会使用 mock 或全部课程逻辑
            if (courseId == null) {
                return Result.ok(new ArrayList<>());
            }

            // 使用StudyScoreService获取排行榜数据
            List<Map<String, Object>> ranking = studyScoreService.getLeaderboardByCourse(courseId);
            return Result.ok(ranking);
        } catch (Exception e) {
            log.error("获取课程学习积分排行榜失败", e);
            return Result.error("获取课程学习积分排行榜失败: " + e.getMessage());
        }
    }

    @Operation(summary = "获取全站总排行榜（所有学生，按学习积分降序）")
    @GetMapping("/leaderboard/overall")
    public Result<List<Map<String, Object>>> getOverallLeaderboard(
            @RequestParam(value = "limit", required = false, defaultValue = "100") Integer limit
    ) {
        try {
            List<Map<String, Object>> ranking = studyScoreService.getOverallLeaderboard(limit == null ? 100 : limit);
            return Result.ok(ranking);
        } catch (Exception e) {
            log.error("获取总排行榜失败", e);
            return Result.error("获取总排行榜失败: " + e.getMessage());
        }
    }

    @Operation(summary = "获取学生学习统计数据")
    @GetMapping("/stats/{studentId}")
    public Result<Map<String, Object>> getStudentStats(@PathVariable("studentId") Long studentId) {
        try {
            if (studentId == null) {
                return Result.error(400, "学生ID不能为空");
            }
            
            Map<String, Object> stats = new HashMap<>();
            
            // 1. 获取近七天登录数据
            List<Map<String, Object>> loginData = getStudentLoginData(studentId);
            stats.put("loginData", loginData);
            
            // 2. 获取累计练习次数
            int totalPractices = getTotalPractices(studentId);
            stats.put("totalPractices", totalPractices);
            
            // 3. 计算平均正确率
            double avgAccuracy = calculateAverageAccuracy(studentId);
            stats.put("avgAccuracy", avgAccuracy);
            
            // 4. 获取最近登录时间
            String lastLogin = getLastLoginTime(studentId);
            stats.put("lastLogin", lastLogin);
            
            // 5. 计算近七天学习天数
            int recentStudyDays = calculateRecentStudyDays(loginData);
            stats.put("recentStudyDays", recentStudyDays);
            
            // 6. 获取学习积分（从数据库）
            User user = userMapper.selectById(studentId);
            int studyScore = (user != null && user.getStudyScore() != null) ? user.getStudyScore() : 0;
            stats.put("studyPoints", studyScore);
            stats.put("points", studyScore);
            stats.put("score", studyScore);

            return Result.ok(stats);
        } catch (Exception e) {
            log.error("获取学生学习统计数据失败", e);
            return Result.error("获取统计数据失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取学生近七天登录数据
     */
    private List<Map<String, Object>> getStudentLoginData(Long studentId) {
        try {
            // 直接调用Service方法获取登录数据
            if (studentLoginLogService != null) {
                return studentLoginLogService.getLoginStatsByStudentId(studentId, 7);
            } else {
                log.warn("StudentLoginLogService未注入，使用默认数据");
                return getDefaultLoginData();
            }
        } catch (Exception e) {
            log.error("查询学生登录数据失败，使用默认值", e);
            return getDefaultLoginData();
        }
    }
    
    /**
     * 获取默认的登录数据（当Service不可用时）
     */
    private List<Map<String, Object>> getDefaultLoginData() {
        List<Map<String, Object>> result = new ArrayList<>();
        LocalDate today = LocalDate.now();
        
        // 生成近七天的日期
        for (int i = 6; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            Map<String, Object> dayData = new HashMap<>();
            dayData.put("date", date.format(DateTimeFormatter.ofPattern("MM-dd")));
            dayData.put("dayOfWeek", date.getDayOfWeek().getDisplayName(TextStyle.SHORT, Locale.CHINESE));
            dayData.put("loginCount", 0); // 默认值
            
            result.add(dayData);
        }
        
        return result;
    }
    
    /**
     * 获取学生累计练习次数
     */
    private int getTotalPractices(Long studentId) {
        try {
            // 直接调用Service方法获取练习次数
            if (practiceRecordService != null) {
                return practiceRecordService.countByStudentId(studentId);
            } else {
                log.warn("PracticeRecordService未注入，使用默认数据");
                return 0;
            }
        } catch (Exception e) {
            log.error("查询学生练习次数失败，使用默认值", e);
            return 0; // 出错时返回0
        }
    }
    
    /**
     * 计算学生平均正确率
     */
    private double calculateAverageAccuracy(Long studentId) {
        try {
            // 直接调用Service方法计算正确率
            if (practiceLogService != null) {
                return practiceLogService.calculateAccuracyByStudentId(studentId);
            } else {
                log.warn("PracticeLogService未注入，使用默认数据");
                return 0.0;
            }
        } catch (Exception e) {
            log.error("计算学生平均正确率失败，使用默认值", e);
            return 0.0; // 出错时返回0
        }
    }
    
    /**
     * 获取学生最近登录时间
     */
    private String getLastLoginTime(Long studentId) {
        try {
            // 直接调用Service方法获取最近登录时间
            if (studentLoginLogService != null) {
                return studentLoginLogService.getLastLoginTimeByStudentId(studentId);
            } else {
                log.warn("StudentLoginLogService未注入，使用默认数据");
                return "2025-01-27 14:30"; // 默认值
            }
        } catch (Exception e) {
            log.error("查询学生最近登录时间失败，使用默认值", e);
            return "2025-01-27 14:30"; // 默认值
        }
    }
    
    /**
     * 计算近七天学习天数
     */
    private int calculateRecentStudyDays(List<Map<String, Object>> loginData) {
        int studyDays = 0;
        for (Map<String, Object> day : loginData) {
            if ((Integer) day.get("loginCount") > 0) {
                studyDays++;
            }
        }
        return studyDays;
    }

    @Operation(summary = "获取学生近一年打卡墙数据")
    @GetMapping("/stats/calendar/{studentId}")
    public Result<List<Map<String, Object>>> getStudyCalendar(@PathVariable("studentId") Long studentId) {
        try {
            if (studentId == null) return Result.error(400, "学生ID不能为空");

            LocalDate end = LocalDate.now();
            LocalDate start = end.minusDays(364);

            // 查询近一年每天登录次数（完整日历）
            List<Map<String, Object>> rows = studentLoginLogMapper.getCalendarLast365(studentId);

            // 规范化输出：yyyy-MM-dd + count
            List<Map<String, Object>> calendar = new ArrayList<>();
            for (int i = 0; i < 365; i++) {
                LocalDate d = start.plusDays(i);
                int count = 0;
                for (Map<String, Object> r : rows) {
                    Object dateObj = r.get("login_date");
                    LocalDate rd;
                    if (dateObj instanceof java.sql.Date) rd = ((java.sql.Date) dateObj).toLocalDate();
                    else if (dateObj instanceof java.sql.Timestamp) rd = ((java.sql.Timestamp) dateObj).toLocalDateTime().toLocalDate();
                    else if (dateObj instanceof LocalDate) rd = (LocalDate) dateObj;
                    else if (dateObj instanceof String) rd = LocalDate.parse((String) dateObj);
                    else continue;
                    if (rd.equals(d)) { count = ((Number) r.get("login_count")).intValue(); break; }
                }
                Map<String, Object> item = new HashMap<>();
                item.put("date", d.toString());
                item.put("count", count);
                calendar.add(item);
            }
            return Result.ok(calendar);
        } catch (Exception e) {
            log.error("获取打卡墙数据失败", e);
            return Result.error("获取打卡墙失败: " + e.getMessage());
        }
    }

    @Operation(summary = "更新学生学习积分")
    @PostMapping("/update-score/{studentId}")
    public Result<Integer> updateStudentScore(@PathVariable("studentId") Long studentId) {
        try {
            int newScore = studyScoreService.updateStudyScore(studentId);
            return Result.ok(newScore);
        } catch (Exception e) {
            log.error("更新学生学习积分失败", e);
            return Result.error("更新学习积分失败: " + e.getMessage());
        }
    }

    @Operation(summary = "批量更新所有学生学习积分")
    @PostMapping("/update-all-scores")
    public Result<Integer> updateAllStudentsScore() {
        try {
            int updatedCount = studyScoreService.updateAllStudentsScore();
            return Result.ok(updatedCount);
        } catch (Exception e) {
            log.error("批量更新学生学习积分失败", e);
            return Result.error("批量更新学习积分失败: " + e.getMessage());
        }
    }

    /**
     * 计算活跃天数（有登录记录的天数）
     */
    private int calculateActiveDays(List<Map<String, Object>> loginData) {
        try {
            if (loginData == null || loginData.isEmpty()) {
                return 0;
            }

            // 统计有登录记录的天数
            int activeDays = 0;
            for (Map<String, Object> dayData : loginData) {
                Object loginCount = dayData.get("loginCount");
                if (loginCount != null) {
                    int count = ((Number) loginCount).intValue();
                    if (count > 0) {
                        activeDays++;
                    }
                }
            }
            return activeDays;
        } catch (Exception e) {
            log.error("计算活跃天数失败", e);
            return 0;
        }
    }

    /**
     * 计算连续登录奖励（每5天额外+10分）
     */
    private int calculateConsecutiveLoginBonus(List<Map<String, Object>> loginData) {
        try {
            if (loginData == null || loginData.isEmpty()) {
                return 0;
            }

            // 获取所有有登录记录的日期
            Set<String> activeDates = new HashSet<>();
            for (Map<String, Object> dayData : loginData) {
                Object loginCount = dayData.get("loginCount");
                if (loginCount != null) {
                    int count = ((Number) loginCount).intValue();
                    if (count > 0) {
                        String date = (String) dayData.get("date");
                        if (date != null) {
                            activeDates.add(date);
                        }
                    }
                }
            }

            if (activeDates.isEmpty()) {
                return 0;
            }

            // 按日期排序
            List<String> sortedDates = new ArrayList<>(activeDates);
            sortedDates.sort(String::compareTo);

            // 计算连续登录奖励
            int bonus = 0;
            int currentStreak = 0;

            for (String date : sortedDates) {
                // 这里简化处理，假设所有日期都是连续的
                // 实际应该检查日期是否真正连续
                currentStreak++;

                // 每5天给一次奖励
                if (currentStreak >= 5) {
                    bonus += (currentStreak / 5) * 10;
                    currentStreak = currentStreak % 5; // 重置计数器
                }
            }

            return bonus;
        } catch (Exception e) {
            log.error("计算连续登录奖励失败", e);
            return 0;
        }
    }

}