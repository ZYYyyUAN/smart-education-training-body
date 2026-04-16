package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.neo4jentity.Chapter;
import com.atguigu.java.ai.langchain4j.neo4jentity.Subject;
import com.atguigu.java.ai.langchain4j.neo4jentity.SubjectGraphDTO;
import com.atguigu.java.ai.langchain4j.neo4jservice.SubjectService;
import io.swagger.v3.oas.annotations.Operation;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/subjects")
public class SubjectController {

    private final SubjectService subjectService;

    public SubjectController(SubjectService subjectService) {
        this.subjectService = subjectService;
    }

    @Operation(summary = "查找某一科目下的所有章节对应知识图谱")
    @GetMapping("/graph")
    public Optional<SubjectGraphDTO> getSubjectGraph(@RequestParam("name") String name) {
        return subjectService.getSubjectGraph(name);
    }
    @Operation(summary = "查找某一科目")
    @GetMapping("/graph/only")
    public Optional<Subject> getSubjectOnlyByName(@RequestParam("name") String name) {
        return subjectService.getSubjectOnlyByName(name);
    }
    @Operation(summary = "查找某一科目下的章节")
    @GetMapping("/chapters")
    public List<Chapter> getChapters(@RequestParam("name") String name) {
        return subjectService.getChaptersBySubjectName(name);
    }

}
