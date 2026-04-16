package com.atguigu.java.ai.langchain4j.service;

import com.atguigu.java.ai.langchain4j.entity.Chapter;

import java.util.List;

public interface ChapterService {
    void addChapter(Chapter chapter);
    List<Chapter> getChaptersByCourseId(Long courseId);
    Chapter getChapterById(Long id);
    void updateChapter(Chapter chapter);
    void deleteChapter(Long id);
}
