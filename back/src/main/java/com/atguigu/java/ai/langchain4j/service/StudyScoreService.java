package com.atguigu.java.ai.langchain4j.service;

import java.util.List;
import java.util.Map;

/**
 * 学习积分计算服务
 * 积分规则：练习次数*4 + 登录天数*2 + 连续登录奖励（每5天额外+10分）
 */
public interface StudyScoreService {
    
    /**
     * 计算指定学生的学习积分
     * @param studentId 学生ID
     * @return 学习积分
     */
    int calculateStudyScore(Long studentId);
    
    /**
     * 更新指定学生的学习积分
     * @param studentId 学生ID
     * @return 更新后的学习积分
     */
    int updateStudyScore(Long studentId);
    
    /**
     * 批量更新所有学生的学习积分
     * @return 更新的学生数量
     */
    int updateAllStudentsScore();
    
    /**
     * 获取学习积分排行榜（按课程）
     * @param courseId 课程ID
     * @return 排行榜数据
     */
    List<Map<String, Object>> getLeaderboardByCourse(Long courseId);

    /**
     * 获取全站总排行榜（所有学生，按 study_score 降序）
     */
    List<Map<String, Object>> getOverallLeaderboard(int limit);
}
