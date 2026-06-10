package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.assistant.XiaozhiAgent;
import com.atguigu.java.ai.langchain4j.entity.LessonPlan;
import com.atguigu.java.ai.langchain4j.entity.ResourceFile;
import com.atguigu.java.ai.langchain4j.entity.Course;
import com.atguigu.java.ai.langchain4j.mapper.ResourceMapper;
import com.atguigu.java.ai.langchain4j.service.CourseService;
import com.atguigu.java.ai.langchain4j.service.ResourceService;
import com.atguigu.java.ai.langchain4j.util.AliyunOssUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import dev.langchain4j.data.document.Document;
import dev.langchain4j.data.document.parser.apache.pdfbox.ApachePdfBoxDocumentParser;
import dev.langchain4j.data.document.splitter.DocumentSplitters;
import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.store.embedding.EmbeddingStore;
import dev.langchain4j.store.embedding.EmbeddingStoreIngestor;
import org.springframework.beans.factory.annotation.Autowired;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Flux;

import com.atguigu.java.ai.langchain4j.entity.StructuredLessonPlan;
import com.atguigu.java.ai.langchain4j.entity.KnowledgeDoc;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.function.Function;

@Service
public class ResourceServiceImpl implements ResourceService {
    private static final Logger log = LoggerFactory.getLogger(ResourceServiceImpl.class);
    @Autowired
    private ResourceMapper resourceMapper;
    @Autowired
    private CourseService courseService;

    @Autowired
    private XiaozhiAgent xiaozhiAgent;

    @Autowired
    private AliyunOssUtil aliyunOssUtil;

    @Autowired
    private EmbeddingModel embeddingModel;

    @Autowired(required = false)
    private Function<String, EmbeddingStore<TextSegment>> embeddingStoreFactory;


    public void uploadFile(MultipartFile file, Long courseId, Long teacherId, String type) {
        String ossUrl;
        try {
            // 1. 上传文件至 OSS
            ossUrl = aliyunOssUtil.uploadFile(file);
        } catch (IOException e) {
            throw new RuntimeException("文件上传失败", e);
        }

        // 2. 写入数据库
        ResourceFile res = new ResourceFile();
        res.setCourseId(courseId);
        res.setTeacherId(teacherId);
        res.setFileName(file.getOriginalFilename());
        res.setFilePath(ossUrl);
        res.setUploadedAt(new Date());
        resourceMapper.insertResource(res);
    }

    @Override
    public void ingestResource(Long resourceId) {
        ResourceFile res = resourceMapper.selectById(resourceId);
        if (res == null) {
            throw new RuntimeException("资源不存在: " + resourceId);
        }
        Long courseId = res.getCourseId();
        String fileName = res.getFileName();
        String fileUrl = res.getFilePath();

        // 若 knowledge_doc 已存在同一 file_path，视为已入库，直接返回
        try {
            int exists = resourceMapper.countKnowledgeByFilePath(fileUrl);
            if (exists > 0) {
                log.info("知识库已存在该资源，跳过入库: resourceId={}, filePath={}", resourceId, fileUrl);
                return;
            }
        } catch (Exception ignore) {}

        // 支持 PDF 与 DOCX 的向量化（远程拉取到本地临时文件）
        File tempFile = null;
        try {
            tempFile = File.createTempFile("ingest_", "_" + (fileName == null ? "file" : fileName));
            aliyunOssUtil.downloadToFile(fileUrl, tempFile);

            String lower = (fileName == null ? fileUrl : fileName).toLowerCase();
            Document document;
            if (lower.endsWith(".pdf")) {
                document = new ApachePdfBoxDocumentParser().parse(new FileInputStream(tempFile));
            } else if (lower.endsWith(".docx")) {
                // 解析 DOCX 为纯文本
                try (XWPFDocument doc = new XWPFDocument(new FileInputStream(tempFile))) {
                    StringBuilder sb = new StringBuilder();
                    for (XWPFParagraph p : doc.getParagraphs()) {
                        if (p != null) {
                            String t = p.getText();
                            if (t != null && !t.isEmpty()) {
                                sb.append(t).append('\n');
                            }
                        }
                    }
                    String text = sb.toString().trim();
                    if (text.isEmpty()) {
                        log.info("DOCX 文档内容为空，跳过向量化: id={}, name={}", resourceId, fileName);
                        return;
                    }
                    document = Document.from(text);
                }
            } else {
                log.info("暂不支持该文件类型向量化，已跳过: id={}, name={}", resourceId, fileName);
                return;
            }

            String namespace = "course-" + courseId;
            try {
                Course course = courseService.getCourseById(courseId);
                if (course != null && course.getCourseName() != null && !course.getCourseName().isEmpty()) {
                    String safe = course.getCourseName().trim().toLowerCase()
                            .replaceAll("[^a-z0-9\\-_]+", "-")
                            .replaceAll("-+", "-")
                            .replaceAll("^-|-$", "");
                    if (!safe.isEmpty()) namespace = safe;
                }
            } catch (Exception ignore) {}
            if (embeddingStoreFactory == null) {
                throw new RuntimeException("Pinecone embeddingStoreFactory 不可用（pinecone.enabled=false），无法入库资源");
            }
            EmbeddingStore<TextSegment> store = embeddingStoreFactory.apply(namespace);

            EmbeddingStoreIngestor
                    .builder()
                    .embeddingStore(store)
                    .embeddingModel(embeddingModel)
                    .documentSplitter(DocumentSplitters.recursive(3000, 100))  // 添加文档分割器，解决输入长度限制问题
                    .build()
                    .ingest(Collections.singletonList(document));

            // 记录到 knowledge_doc，用于前端标记“已加入”
            try {
                KnowledgeDoc doc = new KnowledgeDoc();
                doc.setCourseId(courseId);
                doc.setFileName(fileName);
                doc.setFilePath(fileUrl);
                doc.setFileSize((int) (tempFile.length()));
                resourceMapper.insertKnowledge(doc);
            } catch (Exception e) {
                log.warn("记录 knowledge_doc 失败（不影响入库结果）: resourceId={}", resourceId, e);
            }
        } catch (Exception e) {
            log.error("资源入库知识库失败: resourceId={}, error={}", resourceId, e.toString(), e);
            throw new RuntimeException("资源入库知识库失败: " + e.getMessage(), e);
        } finally {
            if (tempFile != null) try { tempFile.delete(); } catch (Exception ignore) {}
        }
    }

    public Flux<String> generateLessonPlan(String outline) {
        return xiaozhiAgent.generateLessonPlanStream(outline);
    }

    @Override
    public StructuredLessonPlan generateLessonPlanStructured(String outline) throws Exception {
        String raw = xiaozhiAgent.generateLessonPlanJson(outline);
        String json = sanitizeJson(raw);
        ObjectMapper mapper = new ObjectMapper();
        try {
            return mapper.readValue(json, StructuredLessonPlan.class);
        } catch (Exception e) {
            // 再次尝试：截取花括号并做补全
            int s = json.indexOf('{');
            String slice = s >= 0 ? json.substring(s) : json;
            slice = balanceBracesAndTrim(slice);
            // 去除尾随逗号
            slice = slice.replaceAll(",\\s*([}\\]])", "$1");
            return mapper.readValue(slice, StructuredLessonPlan.class);
        }
    }

    private String sanitizeJson(String str) {
        if (str == null) return "{}";
        String s = str.trim();
        // 去掉markdown 包裹
        s = s.replaceAll("```json", "").replaceAll("```", "");
        // 只保留从第一个{开始的内容
        int idx = s.indexOf('{');
        if (idx >= 0) s = s.substring(idx);
        // 如果没有结尾大括号，后续会补齐
        return balanceBracesAndTrim(s);
    }

    private String balanceBracesAndTrim(String s) {
        if (s == null) return "{}";
        String text = s.trim();
        int open = 0, close = 0;
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            if (c == '{') open++;
            else if (c == '}') close++;
        }
        StringBuilder sb = new StringBuilder(text);
        while (open > close) { sb.append('}'); close++; }
        return sb.toString();
    }

    public void saveLessonPlan(LessonPlan plan) {
        resourceMapper.insertLessonPlan(plan);
    }

    @Override
    public List<ResourceFile> getResourcesByCourseId(Long courseId) {
        QueryWrapper<ResourceFile> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("course_id", courseId);
        return resourceMapper.selectList(queryWrapper);
    }
    @Override
    public List<ResourceFile> getResourcesByTeacherId(Long teacherId) {
        LambdaQueryWrapper<ResourceFile> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ResourceFile::getTeacherId, teacherId);
        return resourceMapper.selectList(wrapper);
    }
    public int deleteResourceById(Long id) {
        // 例如调用资源DAO删除，返回是否删除成功
        return resourceMapper.deleteById(id);
    }

    @Override
    public ResourceFile getById(Long id) {
        return resourceMapper.selectById(id);
    }

    @Override
    public int countKnowledgeByFilePath(String filePath) {
        return resourceMapper.countKnowledgeByFilePath(filePath);
    }

    @Override
    public List<ResourceFile> getAllResources() {
        return resourceMapper.selectList(null);
    }

    @Override
    public void incrementDownloadCount(Long resourceId) {
        ResourceFile file = resourceMapper.selectById(resourceId);
        if (file != null) {
            file.setDownloadCount((file.getDownloadCount() == null ? 0 : file.getDownloadCount()) + 1);
            resourceMapper.updateById(file);
        }
    }

    @Override
    public void markAsIngested(Long resourceId) {
        // 管理端入库：只更新数据库标记，不进行实际向量化入库
        resourceMapper.updateIngestedStatus(resourceId);
    }

    @Override
    public void cancelIngested(Long resourceId) {
        // 管理端取消入库：将is_ingested设置为false
        resourceMapper.cancelIngestedStatus(resourceId);
    }

    @Override
    public void updateFileName(Long resourceId, String fileName) {
        resourceMapper.updateFileName(resourceId, fileName);
    }

}