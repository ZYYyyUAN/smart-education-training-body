package com.atguigu.java.ai.langchain4j.neo4jentity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.neo4j.core.schema.*;
@Data
@NoArgsConstructor
@AllArgsConstructor
@Node("KnowledgePoint")
public class KnowledgePoint {
    @Id
    private String id;
    private String name;
    private String detail;

    // Getters, setters, constructor
}
