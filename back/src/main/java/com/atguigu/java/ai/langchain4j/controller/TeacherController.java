package com.atguigu.java.ai.langchain4j.controller;
import com.atguigu.java.ai.langchain4j.util.FileUtil;
import com.atguigu.java.ai.langchain4j.entity.*;
import com.atguigu.java.ai.langchain4j.service.*;
import com.atguigu.java.ai.langchain4j.util.AliyunOssUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.atguigu.java.ai.langchain4j.entity.Chapter;
import com.atguigu.java.ai.langchain4j.entity.KnowledgePoint;
import com.atguigu.java.ai.langchain4j.service.ChapterService;
import com.atguigu.java.ai.langchain4j.service.KnowledgePointService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Flux;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.Map;

@Tag(name = "硅谷小智教师端")
@RestController
@RequestMapping("/xiaozhi/teacher")
@Slf4j
public class TeacherController {

    @Autowired
    private ResourceService resourceService;
    @Autowired
    private QuestionService questionService;
    @Autowired
    private AnalysisService analysisService;
    @Autowired
    private CourseService courseService;
    @Autowired
    private AliyunOssUtil aliyunOssUtil;
    @Autowired
    private ChapterService chapterService;
    @Autowired
    private AssignmentService assignmentService;
    @Autowired
    private PracticeLogService practiceLogService;
    @Autowired
    private ExamService examService;

    @Operation(summary = "上传教案")
    @PostMapping("/upload")
    public Result<String> upload(@RequestParam("file") MultipartFile file,
                                    @RequestParam("courseId") Long courseId,
                                    @RequestParam("teacherId") Long teacherId,
                                    @RequestParam(name = "type",defaultValue = "resource") String type) {
        try {
            resourceService.uploadFile(file, courseId, teacherId, type);
            return Result.ok("文件上传成功");
        } catch (Exception e) {
            return Result.error("上传失败：" + e.getMessage());
        }
    }

    @Operation(summary = "将教学资源加入知识库（向量化入Pinecone）")
    @PostMapping("/resource/ingest")
    public ResponseEntity<?> ingestResource(@RequestParam("resourceId") Long resourceId) {
        try {
            resourceService.ingestResource(resourceId);
            return ResponseEntity.ok("已加入知识库");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("加入知识库失败：" + e.getMessage());
        }
    }
    @Operation(summary = "设计教学计划")
    @PostMapping(value = "/generate-plan", produces = "text/plain;charset=UTF-8")
    public Flux<String> generateLessonPlan(@RequestBody String outline) {
        return resourceService.generateLessonPlan(outline);
    }
    @Operation(summary = "保存教学计划")
    @PostMapping("/save-plan")
    public ResponseEntity<?> savePlan(@RequestBody LessonPlan plan) {
        resourceService.saveLessonPlan(plan);
        return ResponseEntity.ok("教学计划保存成功");
    }

    // ====== 章节与知识点 CRUD ======
    @Autowired
    private KnowledgePointService knowledgePointService;

    @Operation(summary = "根据课程ID获取章节列表")
    @GetMapping("/chapters")
    public Result<List<Chapter>> getChapters(@RequestParam("courseId") Long courseId) {
        try {
            return Result.ok(chapterService.getChaptersByCourseId(courseId));
        } catch (Exception e) {
            return Result.error("获取章节列表失败：" + e.getMessage());
        }
    }

    @Operation(summary = "创建章节")
    @PostMapping("/chapters")
    public Result<?> createChapter(@RequestBody Chapter chapter) {
        try {
            chapterService.addChapter(chapter);
            return Result.ok();
        } catch (Exception e) {
            return Result.error("创建章节失败：" + e.getMessage());
        }
    }

    @Operation(summary = "更新章节")
    @PutMapping("/chapters/{id}")
    public Result<?> updateChapter(@PathVariable("id") Long id, @RequestBody Chapter chapter) {
        try {
            chapter.setId(id);
            chapterService.updateChapter(chapter);
            return Result.ok();
        } catch (Exception e) {
            return Result.error("更新章节失败：" + e.getMessage());
        }
    }

    @Operation(summary = "删除章节")
    @DeleteMapping("/chapters/{id}")
    public Result<?> deleteChapter(@PathVariable("id") Long id) {
        try {
            chapterService.deleteChapter(id);
            return Result.ok();
        } catch (Exception e) {
            return Result.error("删除章节失败：" + e.getMessage());
        }
    }

    @Operation(summary = "根据章节ID获取知识点列表")
    @GetMapping("/knowledge-points")
    public Result<List<KnowledgePoint>> getKnowledgePoints(@RequestParam("chapterId") Long chapterId) {
        try {
            return Result.ok(knowledgePointService.getByChapterId(chapterId));
        } catch (Exception e) {
            return Result.error("获取知识点列表失败：" + e.getMessage());
        }
    }

    @Operation(summary = "创建知识点")
    @PostMapping("/knowledge-points")
    public Result<?> createKnowledgePoint(@RequestBody KnowledgePoint kp) {
        try {
            knowledgePointService.create(kp);
            return Result.ok();
        } catch (Exception e) {
            return Result.error("创建知识点失败：" + e.getMessage());
        }
    }

    @Operation(summary = "更新知识点")
    @PutMapping("/knowledge-points/{id}")
    public Result<?> updateKnowledgePoint(@PathVariable("id") Long id, @RequestBody KnowledgePoint kp) {
        try {
            kp.setId(id);
            knowledgePointService.update(kp);
            return Result.ok();
        } catch (Exception e) {
            return Result.error("更新知识点失败：" + e.getMessage());
        }
    }

    @Operation(summary = "删除知识点")
    @DeleteMapping("/knowledge-points/{id}")
    public Result<?> deleteKnowledgePoint(@PathVariable("id") Long id) {
        try {
            knowledgePointService.delete(id);
            return Result.ok();
        } catch (Exception e) {
            return Result.error("删除知识点失败：" + e.getMessage());
        }
    }

    @Operation(summary = "生成考核题目")
    @PostMapping("/generate-questions")
    public Result<List<QuestionBank>> generateQuestions(@RequestBody QuestionGenerateRequest request) {
        try {
            return Result.ok(questionService.generateQuestions(request));
        } catch (Exception e) {
            return Result.error("生成失败");
        }
    }
    @PostMapping("/save-questions")
    public Result saveGeneratedQuestion(@RequestBody SaveGeneratedQuestionsRequest request) {
        if (request.getQuestions() == null || request.getQuestions().isEmpty()) {
            return Result.error("题目列表不能为空");
        }

        // 批量设置 teacherId 和 courseId
        for (QuestionBank q : request.getQuestions()) {
            q.setCourseId(request.getCourseId());
            q.setCreatedBy(request.getTeacherId());
            q.setCreatedAt(LocalDateTime.now());
        }

        questionService.saveBatch(request.getQuestions());
        return Result.ok();
    }


    @Operation(summary = "学情分析")
    @PostMapping("/student")
    public StudentAnalysisReport analyzeStudentReport(@RequestParam("studentId") Long studentId, @RequestParam("courseId") Long courseId) {

        return analysisService.analyzeStudent(studentId, courseId);
    }
    @Operation(summary ="创建课程")
    @PostMapping("/createByAI")
    public ResponseEntity<?> createCourse(
            @RequestParam("courseName") String courseName,
            @RequestParam("courseImageFile") MultipartFile courseImageFile,
            @RequestParam(value = "teachingGoal", required = false) String teachingGoal,
            @RequestParam(value = "teachingPrinciple", required = false) String teachingPrinciple,
            @RequestParam(value = "courseBackground", required = false) String courseBackground,
            @RequestParam(value = "courseDescription", required = false) String courseDescription,
            @RequestParam("teacherId") Long teacherId
    ) {
        try {
            // 上传封面图
            String imageUrl = aliyunOssUtil.uploadFile(courseImageFile);

            // 封装 Course 实体
            Course course = new Course();
            course.setCourseName(courseName);
            course.setCourseImage(imageUrl);
            course.setTeachingGoal(teachingGoal);
            course.setTeachingPrinciple(teachingPrinciple);
            course.setCourseBackground(courseBackground);
            course.setDescription(courseDescription);
            course.setTeacherId(teacherId);
            course.setCreatedAt(LocalDateTime.now());

            boolean success = courseService.createCourse(course);
            return success ? ResponseEntity.ok("课程创建成功")
                    : ResponseEntity.status(500).body("课程创建失败");

        } catch (Exception e) {
            return ResponseEntity.status(500).body("课程创建失败：" + e.getMessage());
        }
    }

    @Operation(summary ="添加章节")
    @PostMapping("/add")
    public String addChapterLegacy(@RequestBody Chapter chapter) {
        chapterService.addChapter(chapter);
        return "章节添加成功";
    }

    // ======================== 课程相关 ========================

    @GetMapping("/courses")
    @Operation(summary = "查询所有课程")
    public Result<List<Course>> getAllCourses() {
        return Result.ok(courseService.getAllCourses());
    }

    @GetMapping("/course")
    @Operation(summary = "根据 ID 查询课程")
    public Result<Course> getCourseById(@RequestParam("id") Long id) {
        return Result.ok(courseService.getCourseById(id));
    }

    @PutMapping("/course/update")
    @Operation(summary = "更新课程")
    public Result<?> updateCourse(@RequestBody Course course) {
        courseService.updateCourse(course);
        return Result.ok("课程更新成功！");
    }

    @DeleteMapping("/course/delete")
    @Operation(summary = "删除课程")
    public Result<?> deleteCourse(@RequestParam("id") Long id) {
        courseService.deleteCourse(id);
        return Result.ok("课程删除成功！");
    }

    // ======================== 考试相关 ========================
    @PostMapping("/exam/create")
    @Operation(summary = "创建考试")
    public Result<?> createExam(@RequestBody com.atguigu.java.ai.langchain4j.entity.ExamForm form) {
        examService.createExam(form);
        return Result.ok("考试创建成功");
    }

    @PutMapping("/exam/update")
    @Operation(summary = "更新考试")
    public com.atguigu.java.ai.langchain4j.entity.Result<?> updateExam(@RequestBody com.atguigu.java.ai.langchain4j.entity.ExamForm form) {
        return examService.updateExam(form);
    }

    @DeleteMapping("/exam/delete")
    @Operation(summary = "删除考试")
    public com.atguigu.java.ai.langchain4j.entity.Result<?> deleteExam(@RequestParam("examId") Long examId) {
        return examService.deleteExam(examId);
    }

    @GetMapping("/exam/list")
    @Operation(summary = "根据课程ID查询考试")
    public com.atguigu.java.ai.langchain4j.entity.Result<List<com.atguigu.java.ai.langchain4j.entity.Exam>> listExams(@RequestParam("courseId") Long courseId) {
        return com.atguigu.java.ai.langchain4j.entity.Result.ok(examService.getExamsByCourse(courseId));
    }

    @GetMapping("/exams/by-teacher")
    @Operation(summary = "根据教师ID查询考试")
    public com.atguigu.java.ai.langchain4j.entity.Result<List<com.atguigu.java.ai.langchain4j.entity.Exam>> getExamsByTeacher(@RequestParam("teacherId") Long teacherId) {
        return com.atguigu.java.ai.langchain4j.entity.Result.ok(examService.getExamsByTeacherId(teacherId));
    }

    @GetMapping("/exams/overview")
    @Operation(summary = "考试概览（含完成人数/完成率）")
    public com.atguigu.java.ai.langchain4j.entity.Result<List<com.atguigu.java.ai.langchain4j.entity.ExamOverviewDTO>> getExamOverview(@RequestParam("teacherId") Long teacherId) {
        return com.atguigu.java.ai.langchain4j.entity.Result.ok(examService.getExamOverviewByTeacher(teacherId));
    }
    
    // ✅ 管理端更新考试（只更新基本信息，不包含题目）
    @PutMapping("/admin/exam/update")
    @Operation(summary = "管理端更新考试")
    public Result<?> updateExamForAdmin(@RequestBody com.atguigu.java.ai.langchain4j.entity.AdminExamUpdateForm form) {
        return examService.updateExamForAdmin(form);
    }
    
    // ✅ 获取所有考试概览（含完成人数/完成率）
    @GetMapping("/admin/exams/overview")
    @Operation(summary = "获取所有考试概览")
    public Result<List<com.atguigu.java.ai.langchain4j.entity.ExamOverviewDTO>> getAllExamsOverview() {
        return Result.ok(examService.getAllExamsOverview());
    }
    
    // ✅ 根据课程ID获取考试概览
    @GetMapping("/admin/exams/overview/by-course")
    @Operation(summary = "根据课程ID获取考试概览")
    public Result<List<com.atguigu.java.ai.langchain4j.entity.ExamOverviewDTO>> getExamsOverviewByCourse(@RequestParam("courseId") Long courseId) {
        return Result.ok(examService.getExamsOverviewByCourse(courseId));
    }
    
    // ✅ 根据教师ID获取考试概览（管理端用）
    @GetMapping("/admin/exams/overview/by-teacher")
    @Operation(summary = "根据教师ID获取考试概览（管理端用）")
    public Result<List<com.atguigu.java.ai.langchain4j.entity.ExamOverviewDTO>> getExamsOverviewByTeacher(@RequestParam("teacherId") Long teacherId) {
        return Result.ok(examService.getExamsOverviewByTeacher(teacherId));
    }
    
    @GetMapping("/questions/batch")
    @Operation(summary = "批量获取题目详情")
    public com.atguigu.java.ai.langchain4j.entity.Result<List<com.atguigu.java.ai.langchain4j.entity.QuestionBank>> getQuestionsBatch(@RequestParam("ids") String ids) {
        try {
            List<Long> questionIds = Arrays.stream(ids.split(","))
                    .map(String::trim)
                    .map(Long::valueOf)
                    .collect(Collectors.toList());
            List<com.atguigu.java.ai.langchain4j.entity.QuestionBank> questions = questionService.getQuestionsByIds(questionIds);
            return com.atguigu.java.ai.langchain4j.entity.Result.ok(questions);
        } catch (Exception e) {
            log.error("批量获取题目失败", e);
            return com.atguigu.java.ai.langchain4j.entity.Result.error("批量获取题目失败: " + e.getMessage());
        }
    }

    // ======================== 章节相关 ========================

    @GetMapping("/chapters-legacy")
    @Operation(summary = "【旧接口】根据课程 ID 查询章节列表")
    public Result<List<Chapter>> getChaptersByCourseIdLegacy(@RequestParam("courseId") Long courseId) {
        return Result.ok(chapterService.getChaptersByCourseId(courseId));
    }

    @GetMapping("/chapter-legacy")
    @Operation(summary = "【旧接口】根据 ID 查询章节")
    public Result<Chapter> getChapterByIdLegacy(@RequestParam("id") Long id) {
        return Result.ok(chapterService.getChapterById(id));
    }

    @PutMapping("/chapter/update-legacy")
    @Operation(summary = "【旧接口】更新章节")
    public Result<?> updateChapterLegacy(@RequestBody Chapter chapter) {
        chapterService.updateChapter(chapter);
        return Result.ok("章节更新成功！");
    }

    @DeleteMapping("/chapter/delete-legacy")
    @Operation(summary = "【旧接口】删除章节")
    public Result<?> deleteChapterLegacy(@RequestParam("id") Long id) {
        chapterService.deleteChapter(id);
        return Result.ok("章节删除成功！");
    }
    @PostMapping("/create-assignment")
    @Operation(summary = "教师创建作业")
    public Result<?> createAssignment(@RequestBody AssignmentForm form) {
        assignmentService.createAssignment(form);
        return Result.ok("作业创建成功");
    }
    // ✅ 删除作业（支持按作业ID删除）
    @DeleteMapping("/delete")
    @Operation(summary = "删除作业")
    public Result<?> deleteAssignment(@RequestParam("assignmentId") Long assignmentId) {
        return assignmentService.deleteAssignment(assignmentId);
    }

    // ✅ 修改作业（含修改基本信息和题目）
    @PutMapping("/update")
    @Operation(summary = "修改作业")
    public Result<?> updateAssignment(@RequestBody AssignmentForm form) {
        return assignmentService.updateAssignment(form);
    }

    // ✅ 管理端更新作业（只更新基本信息，不包含题目）
    @PutMapping("/admin/update-assignment")
    @Operation(summary = "管理端更新作业基本信息")
    public Result<?> updateAssignmentForAdmin(@RequestBody AdminAssignmentUpdateForm form) {
        return assignmentService.updateAssignmentForAdmin(form);
    }

    // ✅ 查询某课程的全部作业
    @GetMapping("/list")
    @Operation(summary = "查询课程下所有作业")
    public Result<List<Assignment>> listAssignments(@RequestParam("courseId") Long courseId) {
        return Result.ok(assignmentService.getAssignmentsByCourse(courseId));
    }
    
    // ✅ 获取所有作业概览（含完成人数/完成率）
    @GetMapping("/admin/assignments/overview")
    @Operation(summary = "获取所有作业概览")
    public Result<List<AssignmentOverviewDTO>> getAllAssignmentsOverview() {
        return Result.ok(assignmentService.getAllAssignmentsOverview());
    }
    
    // ✅ 根据教师ID获取作业概览
    @GetMapping("/admin/assignments/overview/by-teacher")
    @Operation(summary = "根据教师ID获取作业概览")
    public Result<List<AssignmentOverviewDTO>> getAssignmentsOverviewByTeacherId(@RequestParam("teacherId") Long teacherId) {
        return Result.ok(assignmentService.getAssignmentsOverviewByTeacherId(teacherId));
    }
    
    // ✅ 根据课程ID获取作业概览
    @GetMapping("/admin/assignments/overview/by-course")
    @Operation(summary = "根据课程ID获取作业概览")
    public Result<List<AssignmentOverviewDTO>> getAssignmentsOverviewByCourseId(@RequestParam("courseId") Long courseId) {
        return Result.ok(assignmentService.getAssignmentsOverviewByCourseId(courseId));
    }
    
    // ✅ 根据学生ID获取作业概览
    @GetMapping("/admin/assignments/overview/by-student")
    @Operation(summary = "根据学生ID获取作业概览")
    public Result<List<AssignmentOverviewDTO>> getAssignmentsOverviewByStudentId(@RequestParam("studentId") Long studentId) {
        return Result.ok(assignmentService.getAssignmentsOverviewByStudentId(studentId));
    }

    // ✅ 查询作业详情（含题目列表）
    @GetMapping("/detail")
    @Operation(summary = "查询作业详情")
    public Result<AssignmentDetailDTO> getAssignmentDetail(@RequestParam("assignmentId") Long assignmentId) {
        return Result.ok(assignmentService.getAssignmentDetail(assignmentId));
    }

    @Operation(summary = "创建题目")
    @PostMapping("/question/create")
    public Result<?> create(@RequestBody QuestionBank question) {
        return questionService.create(question);
    }

    @Operation(summary = "更新题目")
    @PutMapping("/question/update")
    public Result<?> update(@RequestBody QuestionBank question) {
        return questionService.update(question);
    }

    @Operation(summary = "删除题目")
    @DeleteMapping("/question/delete")
    public Result<?> delete(@RequestParam("id") Long id,
                            @RequestParam(value = "force", required = false, defaultValue = "false") boolean force) {
        if (force) {
            return questionService.forceDelete(id);
        }
        return questionService.delete(id);
    }

    @Operation(summary = "根据 ID 获取题目信息")
    @GetMapping("/question/get")
    public Result<QuestionBank> getById(@RequestParam("id") Long id) {
        return questionService.getById(id);
    }

    @Operation(summary = "根据课程 ID 获取题目列表")
    @GetMapping("/question/listByCourse")
    public Result<List<QuestionBank>> listByCourse(@RequestParam("courseId") Long courseId) {
        return questionService.listByCourse(courseId);
    }

    @Operation(summary = "根据题库分类获取题目列表")
    @GetMapping("/question/listByCategory")
    public Result<List<QuestionBank>> listByCategory(@RequestParam("categoryId") Long categoryId) {
        // 直接通过 mapper 查询更高效，这里走 service 扩展
        List<QuestionBank> list = questionService.listByCategory(categoryId);
        return Result.ok(list);
    }
    @Operation(summary = "获取所有题目")
    @GetMapping("/question/list")
    public Result<List<QuestionBank>> list() {
        return Result.ok(questionService.list());
    }

    @Operation(summary = "分页获取题目")
    @GetMapping("/question/page")
    public Result<PageResponse<QuestionBank>> pageQuestions(@RequestParam(name = "page", defaultValue = "1") int page,
                                                            @RequestParam(name = "pageSize", defaultValue = "10") int pageSize) {
        return Result.ok(questionService.page(page, pageSize));
    }

    @Operation(summary = "按题库分类分页获取题目")
    @GetMapping("/question/pageByCategory")
    public Result<PageResponse<QuestionBank>> pageQuestionsByCategory(@RequestParam("categoryId") Long categoryId,
                                                                      @RequestParam(name = "page", defaultValue = "1") int page,
                                                                      @RequestParam(name = "pageSize", defaultValue = "10") int pageSize) {
        return Result.ok(questionService.pageByCategory(categoryId, page, pageSize));
    }

    /**
     * 根据课程 ID 获取所有教学资源
     */
    @Operation(summary = "根据课程 ID 获取所有教学资源")
    @GetMapping("/resources")
    public Result<List<ResourceFile>> getCourseResources(@RequestParam("courseId") Long courseId) {
        List<ResourceFile> resources = resourceService.getResourcesByCourseId(courseId);
        return Result.ok(resources); // 假设你使用统一响应封装类 R
    }

    // 根据教师 ID 获取课程列表
    @Operation(summary = "根据教师ID获取课程")
    @GetMapping("/by-teacher")
    public List<Course> getCoursesByTeacherId(@RequestParam("teacherId") Long teacherId) {
        return courseService.getCoursesByTeacherId(teacherId);
    }

    @Operation(summary = "获取所有课程（管理端用）")
    @GetMapping("/courses/all")
    public Result<List<Course>> getAllCoursesList() {
        return Result.ok(courseService.getAllCourses());
    }

    // === 新增：根据课程ID获取学生列表（用于学生管理模块） ===
    @Operation(summary = "根据课程ID获取学生列表")
    @GetMapping("/course/students")
    public Result<List<Student>> getStudentsByCourse(@RequestParam("courseId") Long courseId) {
        try {
            List<Student> students = analysisService.getStudentsByCourseId(courseId);
            return Result.ok(students);
        } catch (Exception e) {
            return Result.error("获取学生列表失败：" + e.getMessage());
        }
    }
    
    @Operation(summary = "获取学生薄弱知识点")
    @GetMapping("/analysis/weak-points")
    public Result<List<Map<String, Object>>> getWeakKnowledgePoints(@RequestParam("studentId") Long studentId,
                                                                  @RequestParam("courseId") Long courseId) {
        try {
            List<Map<String, Object>> weakPoints = analysisService.getWeakKnowledgePoints(studentId, courseId);
            return Result.ok(weakPoints);
        } catch (Exception e) {
            return Result.error("获取薄弱知识点失败：" + e.getMessage());
        }
    }
    
    @Operation(summary = "获取学生作业得分情况")
    @GetMapping("/analysis/assignment-scores")
    public Result<List<Map<String, Object>>> getAssignmentScores(@RequestParam("studentId") Long studentId,
                                                               @RequestParam("courseId") Long courseId) {
        try {
            List<Map<String, Object>> scores = analysisService.getAssignmentScores(studentId, courseId);
            return Result.ok(scores);
        } catch (Exception e) {
            return Result.error("获取作业得分失败：" + e.getMessage());
        }
    }
    
    @Operation(summary = "获取学生作业详情")
    @GetMapping("/analysis/assignment-detail")
    public Result<List<Map<String, Object>>> getAssignmentDetail(@RequestParam("assignmentId") Long assignmentId,
                                                               @RequestParam("studentId") Long studentId) {
        try {
            List<Map<String, Object>> detail = analysisService.getAssignmentDetail(assignmentId, studentId);
            return Result.ok(detail);
        } catch (Exception e) {
            return Result.error("获取作业详情失败：" + e.getMessage());
        }
    }
    
    @Operation(summary = "获取课程下的所有知识点")
    @GetMapping("/analysis/course-knowledge-points")
    public Result<List<String>> getCourseKnowledgePoints(@RequestParam("courseId") Long courseId) {
        try {
            List<String> knowledgePoints = analysisService.getCourseKnowledgePoints(courseId);
            return Result.ok(knowledgePoints);
        } catch (Exception e) {
            return Result.error("获取课程知识点失败：" + e.getMessage());
        }
    }

    // === 新增：查询学生在课程下的知识点掌握聚合与雷达 ===
    @Operation(summary = "学生课程掌握概览")
    @GetMapping("/analysis/overview")
    public Result<StudentAnalysisReport> getStudentOverview(@RequestParam("studentId") Long studentId,
                                                            @RequestParam("courseId") Long courseId) {
        try {
            StudentAnalysisReport report = analysisService.analyzeStudent(studentId, courseId);
            return Result.ok(report);
        } catch (Exception e) {
            return Result.error("分析失败：" + e.getMessage());
        }
    }

    // === 新增：查询学生在课程下的作业列表（含得分） ===
    @Operation(summary = "学生课程作业列表")
    @GetMapping("/assignments/by-student")
    public Result<List<AssignmentWithStatusDTO>> getAssignmentsByStudent(@RequestParam Long studentId,
                                                                         @RequestParam Long courseId) {
        try {
            // 先取课程全部作业，再由 service 侧拼接该生得分/状态
            List<AssignmentWithStatusDTO> list = assignmentService.getAssignmentsByStudentId(studentId);
            return Result.ok(list);
        } catch (Exception e) {
            return Result.error("获取作业失败：" + e.getMessage());
        }
    }
    @Operation(summary = "上传课程大纲文件并生成教学计划（结构化JSON）")
    @PostMapping(value = "/generate-plan-by-file", produces = "application/json;charset=UTF-8")
    public Result<com.atguigu.java.ai.langchain4j.entity.StructuredLessonPlan> generatePlanByFile(@RequestParam("file") MultipartFile file) {
        try {
            String content = FileUtil.extractTextFromFile(file);
            return Result.ok(resourceService.generateLessonPlanStructured(content));
        } catch (Exception e) {
            return Result.error("文件处理失败：" + e.getMessage());
        }
    }


    @PostMapping("/image")
    public Result<String> uploadImage(@RequestParam("file") MultipartFile file) {
        try {
            String url = aliyunOssUtil.uploadFile(file);
            return Result.ok(url);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("上传失败：" + e.getMessage());
        }
    }

    @Operation(summary = "根据教师ID查询作业列表")
    @GetMapping("/assignments/by-teacher")
    public Result<List<Assignment>> getAssignmentsByTeacherId(@RequestParam("teacherId") Long teacherId) {
        List<Assignment> assignments = assignmentService.getAssignmentsByTeacherId(teacherId);
        return Result.ok(assignments);
    }
    @Operation(summary = "根据教师ID查询教学资源")
    @GetMapping("/resources/by-teacher")
    public Result<List<Map<String, Object>>> getResourcesByTeacherId(@RequestParam("teacherId") Long teacherId) {
        List<ResourceFile> list = resourceService.getResourcesByTeacherId(teacherId);
        return Result.ok(convertResourcesToMap(list));
    }

    @Operation(summary = "查询所有教学资源（管理端用）")
    @GetMapping("/resources/all")
    public Result<List<Map<String, Object>>> getAllResources() {
        List<ResourceFile> list = resourceService.getAllResources();
        // 调试日志：检查第一条数据的 downloadCount
        if (!list.isEmpty()) {
            ResourceFile first = list.get(0);
            log.info("第一条资源数据 - ID: {}, fileName: {}, downloadCount: {}", 
                first.getId(), first.getFileName(), first.getDownloadCount());
        }
        return Result.ok(convertResourcesToMap(list));
    }

    @Operation(summary = "增加下载次数")
    @PostMapping("/resource/download-count")
    public Result<?> incrementDownloadCount(@RequestParam("id") Long id) {
        resourceService.incrementDownloadCount(id);
        return Result.ok();
    }

    @Operation(summary = "管理端入库：标记资源为已入库（不进行实际向量化）")
    @PostMapping("/resource/admin/ingest")
    public Result<?> markResourceAsIngested(@RequestParam("id") Long id) {
        try {
            resourceService.markAsIngested(id);
            return Result.ok("资源已入库");
        } catch (Exception e) {
            return Result.error("标记失败：" + e.getMessage());
        }
    }

    @Operation(summary = "管理端取消入库：将资源标记为未入库（修改数据库字段）")
    @PostMapping("/resource/admin/cancel-ingest")
    public Result<?> cancelResourceIngested(@RequestParam("id") Long id) {
        try {
            resourceService.cancelIngested(id);
            return Result.ok("已取消入库");
        } catch (Exception e) {
            return Result.error("取消入库失败：" + e.getMessage());
        }
    }

    @Operation(summary = "修改资源文件名")
    @PutMapping("/resource/admin/update-name")
    public Result<?> updateResourceFileName(@RequestParam("id") Long id, @RequestParam("fileName") String fileName) {
        try {
            if (fileName == null || fileName.trim().isEmpty()) {
                return Result.error("文件名不能为空");
            }
            resourceService.updateFileName(id, fileName.trim());
            return Result.ok("文件名修改成功");
        } catch (Exception e) {
            return Result.error("修改失败：" + e.getMessage());
        }
    }

    private List<Map<String, Object>> convertResourcesToMap(List<ResourceFile> list) {
        java.util.ArrayList<java.util.Map<String, Object>> result = new java.util.ArrayList<>();
        for (ResourceFile r : list) {
            java.util.HashMap<String, Object> m = new java.util.HashMap<>();
            m.put("id", r.getId());
            m.put("courseId", r.getCourseId());
            m.put("teacherId", r.getTeacherId());
            m.put("fileName", r.getFileName());
            m.put("filePath", r.getFilePath());
            m.put("uploadedAt", r.getUploadedAt());
            m.put("downloadCount", r.getDownloadCount() == null ? 0 : r.getDownloadCount());
            m.put("isIngested", r.getIsIngested() != null && r.getIsIngested());
            // 简单模拟文件大小，实际上ResourceFile没存，或者需要去OSS查，这里暂时随机或为空
            m.put("fileSize", "未知"); 
            // 模拟文件类型
            String name = r.getFileName();
            String type = "OTHER";
            if (name != null && name.contains(".")) {
                type = name.substring(name.lastIndexOf(".") + 1).toUpperCase();
            }
            m.put("fileType", type);
            
            int cnt = 0;
            try { cnt = resourceService.countKnowledgeByFilePath(r.getFilePath()); } catch (Exception ignore) {}
            m.put("ingested", cnt > 0);
            result.add(m);
        }
        return result;
    }


    @Operation(summary = "根据教学资源ID删除教学资源")
    @DeleteMapping("/resource/delete")
    public Result<?> deleteResourceById(@RequestParam("id") Long resourceId) {
        try {
            resourceService.deleteResourceById(resourceId);
            return Result.ok("教学资源删除成功");

        } catch (Exception e) {
            return Result.error("删除失败：" + e.getMessage());
        }
    }
    @Operation(summary = "根据资源ID查询教学资源")
    @GetMapping("/resource")
    public Result<ResourceFile> getResourceById(@RequestParam("id") Long id) {
        try {
            ResourceFile resource = resourceService.getById(id);
            if (resource == null) {
                return Result.error("未找到对应的教学资源");
            }
            return Result.ok(resource);
        } catch (Exception e) {
            return Result.error("查询失败：" + e.getMessage());
        }
    }
    @Operation(summary = "创建课程群聊")
    @PostMapping("/create-group-chat")
    public Result<?> createGroupChat(@RequestParam Long courseId) {
        // 可以记录群聊是否已存在，或者记录创建时间等逻辑
        // 本系统中基于 WebSocket，课程创建后自动启用群聊，无需额外数据结构
        return Result.ok("已为课程 ID " + courseId + " 启用群聊功能（WebSocket）");
    }

}