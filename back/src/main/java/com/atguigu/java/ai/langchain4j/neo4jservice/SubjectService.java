package com.atguigu.java.ai.langchain4j.neo4jservice;

import com.atguigu.java.ai.langchain4j.neo4jentity.Chapter;
import com.atguigu.java.ai.langchain4j.neo4jentity.Subject;
import com.atguigu.java.ai.langchain4j.neo4jentity.SubjectGraphDTO;
import com.atguigu.java.ai.langchain4j.repository.SubjectRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class SubjectService {

    private final SubjectRepository subjectRepository;

    public SubjectService(SubjectRepository subjectRepository) {
        this.subjectRepository = subjectRepository;
    }

    public Optional<SubjectGraphDTO> getSubjectGraph(String name) {
        System.out.println("查询的name参数: " + name);
        return subjectRepository.findFullGraphByName(name);
    }
    public Optional<Subject> getSubjectOnlyByName(String name) {
        System.out.println("查询的name参数: " + name);
        return subjectRepository.findSubjectOnlyByName(name);
    }
    public List<Chapter> getChaptersBySubjectName(String name) {
        return subjectRepository.findChaptersBySubjectName(name);
    }

}
