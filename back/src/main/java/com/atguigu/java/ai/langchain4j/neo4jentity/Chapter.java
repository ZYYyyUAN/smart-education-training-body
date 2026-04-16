package com.atguigu.java.ai.langchain4j.neo4jentity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.neo4j.core.schema.Node;
import org.springframework.data.neo4j.core.schema.Property;
import org.springframework.data.neo4j.core.schema.Relationship;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Node("Chapter")
public class Chapter {
    @Id
    private String id;

    private String name;

    @Property("order")
    private Integer chapterOrder; // 改名避免关键字冲突

    @Relationship(type = "HAS_KNOWLEDGE_POINT", direction = Relationship.Direction.OUTGOING)
    private List<KnowledgePoint> knowledgePoints;
}
