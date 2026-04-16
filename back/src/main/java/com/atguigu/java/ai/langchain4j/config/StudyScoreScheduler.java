package com.atguigu.java.ai.langchain4j.config;

import com.atguigu.java.ai.langchain4j.service.StudyScoreService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * 学习积分定时更新任务
 * 每天凌晨2点自动更新所有学生的学习积分
 */
@Slf4j
@Component
public class StudyScoreScheduler {

    @Autowired
    private StudyScoreService studyScoreService;

    /**
     * 每天凌晨2点执行一次
     * 更新所有学生的学习积分
     */
    @Scheduled(cron = "0 0 2 * * ?")
    public void updateAllStudentsScore() {
        try {
            log.info("开始执行定时任务：更新所有学生学习积分");
            int updatedCount = studyScoreService.updateAllStudentsScore();
            log.info("定时任务完成：成功更新 {} 名学生的学习积分", updatedCount);
        } catch (Exception e) {
            log.error("定时更新学习积分失败", e);
        }
    }

    /**
     * 每小时执行一次
     * 检查并更新积分（可选，用于测试）
     */
    // @Scheduled(fixedRate = 3600000) // 每小时执行一次
    public void hourlyUpdateCheck() {
        try {
            log.debug("执行小时检查：更新所有学生学习积分");
            int updatedCount = studyScoreService.updateAllStudentsScore();
            log.debug("小时检查完成：更新了 {} 名学生的学习积分", updatedCount);
        } catch (Exception e) {
            log.error("小时检查更新学习积分失败", e);
        }
    }
}
