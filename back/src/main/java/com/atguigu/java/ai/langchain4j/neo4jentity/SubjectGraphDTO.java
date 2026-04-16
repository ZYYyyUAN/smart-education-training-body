package com.atguigu.java.ai.langchain4j.neo4jentity;

import lombok.Data;

import java.util.List;
@Data

public class SubjectGraphDTO {
    private final Subject subject;
    private final List<Chapter> chapters;
    private final List<KnowledgePoint> knowledgePoints;

    public SubjectGraphDTO(Subject subject, List<Chapter> chapters, List<KnowledgePoint> knowledgePoints) {
        this.subject = subject;
        this.chapters = chapters;
        this.knowledgePoints = knowledgePoints;
    }

    public Subject getSubject() { return subject; }
    public List<Chapter> getChapters() { return chapters; }
    public List<KnowledgePoint> getKnowledgePoints() { return knowledgePoints; }
}
