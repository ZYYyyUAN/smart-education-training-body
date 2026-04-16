package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.Chapter;
import com.atguigu.java.ai.langchain4j.entity.Course;
import com.atguigu.java.ai.langchain4j.entity.KnowledgePoint;
import com.atguigu.java.ai.langchain4j.mapper.ChapterMapper;
import com.atguigu.java.ai.langchain4j.mapper.CourseMapper;
import com.atguigu.java.ai.langchain4j.mapper.KnowledgePointMapper;
import com.atguigu.java.ai.langchain4j.entity.KnowledgeGraphNodeDTO;

import com.atguigu.java.ai.langchain4j.service.KnowledgeGraphService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class KnowledgeGraphServiceImpl implements KnowledgeGraphService {

    @Autowired
    private CourseMapper courseMapper;

    @Autowired
    private ChapterMapper chapterMapper;

    @Autowired
    private KnowledgePointMapper knowledgePointMapper;

    @Override
    public KnowledgeGraphNodeDTO buildKnowledgeGraph(Long courseId) {
        Course course = courseMapper.selectById(courseId);
        if (course == null) {
            return null;
        }

        KnowledgeGraphNodeDTO root = new KnowledgeGraphNodeDTO();
        root.setId(course.getId());
        root.setName(course.getCourseName());

        List<Chapter> chapters = chapterMapper.selectByCourseId(courseId);
        List<KnowledgeGraphNodeDTO> chapterNodes = new ArrayList<>();

        for (Chapter chapter : chapters) {
            KnowledgeGraphNodeDTO chapterNode = new KnowledgeGraphNodeDTO();
            chapterNode.setId(chapter.getId());
            chapterNode.setName(chapter.getChapterTitle());

            List<KnowledgePoint> points = knowledgePointMapper.selectByChapterId(chapter.getId());
            List<KnowledgeGraphNodeDTO> pointNodes = points.stream().map(p -> {
                KnowledgeGraphNodeDTO pNode = new KnowledgeGraphNodeDTO();
                pNode.setId(Long.valueOf(p.getId()));
                pNode.setName(p.getTitle());
                return pNode;
            }).collect(Collectors.toList());

            chapterNode.setChildren(pointNodes);
            chapterNodes.add(chapterNode);
        }

        root.setChildren(chapterNodes);
        return root;
    }
}
