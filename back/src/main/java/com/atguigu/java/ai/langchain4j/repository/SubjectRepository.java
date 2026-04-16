package com.atguigu.java.ai.langchain4j.repository;

import com.atguigu.java.ai.langchain4j.neo4jentity.Chapter;
import com.atguigu.java.ai.langchain4j.neo4jentity.Subject;
import com.atguigu.java.ai.langchain4j.neo4jentity.SubjectGraphDTO;
import org.springframework.data.repository.query.Param;

import org.springframework.data.neo4j.repository.Neo4jRepository;
import org.springframework.data.neo4j.repository.query.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
@Repository
public interface SubjectRepository extends Neo4jRepository<Subject, String> {

    @Query("""
MATCH (s:Subject {name: $name})
OPTIONAL MATCH (s)-[:HAS_CHAPTER]->(c:Chapter)
OPTIONAL MATCH (c)-[:HAS_KNOWLEDGE_POINT]->(k:KnowledgePoint)
RETURN s, collect(distinct c), collect(distinct k)
""")
    Optional<SubjectGraphDTO> findFullGraphByName(@Param("name") String name);


    @Query("MATCH (s:Subject {name: $name}) RETURN s")
    Optional<Subject> findSubjectOnlyByName(@Param("name") String name);

    @Query("""
MATCH (s:Subject {name: $name})-[:HAS_CHAPTER]->(c:Chapter)
RETURN c {
  .id, 
  .name, 
  chapterOrder: c.order,
  knowledgePoints: [(c)-[:HAS_KNOWLEDGE_POINT]->(kp) | kp { .id, .name, .detail }]
} AS chapter
""")
    List<Chapter> findChaptersBySubjectName(@Param("name") String name);

}
