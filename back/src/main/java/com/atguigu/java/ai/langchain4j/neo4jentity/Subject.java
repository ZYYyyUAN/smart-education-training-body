package com.atguigu.java.ai.langchain4j.neo4jentity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.neo4j.core.schema.*;
import java.util.List;
@Data
@NoArgsConstructor
@AllArgsConstructor
@Node("Subject")
public class Subject {
    @Id
    private String id;
    private String name;
    private String description;

    @Relationship(type = "HAS_CHAPTER", direction = Relationship.Direction.OUTGOING)
    private List<Chapter> chapters;

    // Getters, setters, constructor
}
