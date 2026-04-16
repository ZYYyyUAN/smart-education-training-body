package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.Chapter;
import com.atguigu.java.ai.langchain4j.mapper.ChapterMapper;
import com.atguigu.java.ai.langchain4j.service.ChapterService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ChapterServiceImpl implements ChapterService {

    @Autowired
    private ChapterMapper chapterMapper;

    @Override
    public void addChapter(Chapter chapter) {
        chapterMapper.insert(chapter);
    }

    @Override
    public List<Chapter> getChaptersByCourseId(Long courseId) {
        return chapterMapper.findByCourseId(courseId);
    }

    @Override
    public Chapter getChapterById(Long id) {
        return chapterMapper.findById(id);
    }

    @Override
    public void updateChapter(Chapter chapter) {
        chapterMapper.update(chapter);
    }

    @Override
    public void deleteChapter(Long id) {
        chapterMapper.delete(id);
    }
}
