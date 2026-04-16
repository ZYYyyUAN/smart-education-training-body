package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.entity.KnowledgeGraphNodeDTO;
import com.atguigu.java.ai.langchain4j.service.KnowledgeGraphService;
import org.apache.ibatis.annotations.Param;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/graph")
public class KnowledgeGraphController {

    @Autowired
    private KnowledgeGraphService knowledgeGraphService;

    @GetMapping("/course")
    public ResponseEntity<KnowledgeGraphNodeDTO> getKnowledgeGraph(@RequestParam("courseId") Long courseId) {
        KnowledgeGraphNodeDTO graph = knowledgeGraphService.buildKnowledgeGraph(courseId);
        return ResponseEntity.ok(graph);
    }
}
