package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.PracticeLog;
import com.atguigu.java.ai.langchain4j.entity.PracticeLogVO;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface PracticeLogMapper {

    @Select("""
    SELECT q.knowledge_point
    FROM practice_log p
    JOIN question_bank q ON p.question_id = q.id
    WHERE p.student_id = #{studentId} AND p.is_correct = 0
    GROUP BY q.knowledge_point
    ORDER BY MAX(p.submitted_at) DESC
    """)
    List<String> findWeakPoints(@Param("studentId") Long studentId);

    @Select("""
    SELECT 
        q.knowledge_point as knowledgePoint,
        COUNT(CASE WHEN p.is_correct = 0 THEN 1 END) as errorCount,
        COUNT(CASE WHEN p.is_correct = 1 THEN 1 END) as correctCount,
        COUNT(CASE WHEN p.is_correct = 0 THEN 1 END) as wrongCount,
        ROUND(COUNT(CASE WHEN p.is_correct = 1 THEN 1 END) * 100.0 / COUNT(*), 2) as accuracyRate
    FROM practice_log p
    JOIN question_bank q ON p.question_id = q.id
    WHERE p.student_id = #{studentId} AND q.course_id = #{courseId}
    GROUP BY q.knowledge_point
    HAVING COUNT(CASE WHEN p.is_correct = 0 THEN 1 END) > 0
    ORDER BY wrongCount DESC, accuracyRate ASC
    LIMIT #{limit}
    """)
    List<Map<String, Object>> getWeakPointsRanking(@Param("studentId") Long studentId, @Param("courseId") Long courseId, @Param("limit") Integer limit);

    @Select("""
    SELECT 
        prd.knowledge_point as knowledgePoint,
        COUNT(CASE WHEN prd.is_correct = 0 THEN 1 END) as errorCount,
        COUNT(CASE WHEN prd.is_correct = 1 THEN 1 END) as correctCount,
        COUNT(CASE WHEN prd.is_correct = 0 THEN 1 END) as wrongCount,
        ROUND(COUNT(CASE WHEN prd.is_correct = 1 THEN 1 END) * 100.0 / COUNT(*), 2) as accuracyRate
    FROM practice_record_detail prd
    JOIN practice_record pr ON prd.practice_record_id = pr.id
    WHERE pr.student_id = #{studentId} AND pr.course_id = #{courseId}
    GROUP BY prd.knowledge_point
    HAVING COUNT(CASE WHEN prd.is_correct = 0 THEN 1 END) > 0
    ORDER BY wrongCount DESC, accuracyRate ASC
    LIMIT #{limit}
    """)
    List<Map<String, Object>> getWeakPointsRankingFromPracticeRecord(@Param("studentId") Long studentId, @Param("courseId") Long courseId, @Param("limit") Integer limit);

    @Select("""
    SELECT p.*, q.knowledge_point
    FROM practice_log p
    JOIN question_bank q ON p.question_id = q.id
    WHERE p.student_id = #{studentId} AND q.course_id = #{courseId}
    ORDER BY p.submitted_at DESC
    """)
    List<PracticeLog> findByStudentAndCourse(@Param("studentId") Long studentId, @Param("courseId") Long courseId);

    void insert(PracticeLog log);
    @Select("""
        SELECT
            pl.id AS logId,
            qb.content AS questionContent,
            pl.answer_text AS studentAnswer,
            pl.is_correct AS isCorrect,
            pl.error_reason AS errorReason,
            pl.score,
            pl.submitted_at AS submittedAt
        FROM practice_log pl
        JOIN question_bank qb ON pl.question_id = qb.id
        WHERE pl.student_id = #{studentId}
        ORDER BY pl.submitted_at DESC
    """)
    List<PracticeLogVO> getPracticeLogsByStudentId(@Param("studentId") Long studentId);

    @Select("SELECT * FROM practice_log WHERE id = #{id}")
    PracticeLog selectById(Long id);
    
    @Select("""
        SELECT 
            -- 汇总两张来源表：practice_log 与 practice_record_detail/practice_record
            (
              SELECT COUNT(*) FROM practice_log 
              WHERE student_id = #{studentId}
            ) 
            + (
              SELECT COUNT(*) 
              FROM practice_record_detail prd
              JOIN practice_record pr ON prd.practice_record_id = pr.id
              WHERE pr.student_id = #{studentId}
            )                                   AS totalQuestions,
            (
              SELECT COUNT(*) FROM practice_log 
              WHERE student_id = #{studentId}
                AND (is_correct = 1 OR is_correct = TRUE)
            )
            + (
              SELECT COUNT(*) 
              FROM practice_record_detail prd
              JOIN practice_record pr ON prd.practice_record_id = pr.id
              WHERE pr.student_id = #{studentId}
                AND prd.is_correct = 1
            )                                   AS correctQuestions
    """)
    Map<String, Object> getQuestionStatsByStudentId(@Param("studentId") Long studentId);
}
