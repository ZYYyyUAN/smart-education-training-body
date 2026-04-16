package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.LessonPlan;
import com.atguigu.java.ai.langchain4j.entity.ResourceFile;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Flux;

import java.util.List;

public interface ResourceService {

    void uploadFile(MultipartFile file, Long courseId, Long teacherId, String type);

    // 新增：将已上传的资源加入向量知识库（Pinecone），按资源ID触发
    void ingestResource(Long resourceId);

    Flux<String> generateLessonPlan(String outline);

    // 新增：返回结构化教学计划
    com.atguigu.java.ai.langchain4j.entity.StructuredLessonPlan generateLessonPlanStructured(String outline) throws Exception;

    void saveLessonPlan(LessonPlan plan);
    List<ResourceFile> getResourcesByCourseId(Long courseId);

    List<ResourceFile> getResourcesByTeacherId(Long teacherId);

    int deleteResourceById(Long resourceId);

    ResourceFile getById(Long id);

    // 辅助：根据文件路径统计知识库是否存在（>0表示已加入）
    int countKnowledgeByFilePath(String filePath);

    List<ResourceFile> getAllResources();

    void incrementDownloadCount(Long resourceId);

    // 管理端入库：只更新数据库标记，不进行实际向量化入库
    void markAsIngested(Long resourceId);

    // 管理端取消入库：将is_ingested设置为false
    void cancelIngested(Long resourceId);

    // 修改文件名
    void updateFileName(Long resourceId, String fileName);
}
