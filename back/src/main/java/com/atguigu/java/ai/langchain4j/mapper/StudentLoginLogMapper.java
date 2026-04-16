package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.StudentLoginLog;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import java.time.LocalDateTime;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Mapper
public interface StudentLoginLogMapper extends BaseMapper<StudentLoginLog> {
    
    // 修改返回值类型为 String，并使用 MySQL 的 DATE_FORMAT 函数将时间转换为字符串
    @Select("SELECT DATE_FORMAT(login_time, '%Y-%m-%d %H:%i:%s') FROM student_login_log WHERE student_id = #{studentId} ORDER BY login_time DESC LIMIT 1")
    String getLastLoginTimeByStudentId(Long studentId);
    
    @Select("SELECT * FROM student_login_log WHERE student_id = #{studentId} AND login_time >= DATE_SUB(NOW(), INTERVAL 365 DAY)")
    List<Map<String, Object>> getCalendarLast365(Long studentId);

    // 补全 getLoginStatsLast7Days
    @Select("SELECT DATE_FORMAT(login_time, '%Y-%m-%d') as date, COUNT(*) as count FROM student_login_log WHERE student_id = #{studentId} AND login_time >= DATE_SUB(NOW(), INTERVAL 7 DAY) GROUP BY date")
    List<Map<String, Object>> getLoginStatsLast7Days(Long studentId);

    // 补全 getLoginStatsByDateRange
    @Select("SELECT DATE_FORMAT(login_time, '%Y-%m-%d') as date, COUNT(*) as count FROM student_login_log WHERE student_id = #{studentId} AND login_time BETWEEN #{startDate} AND #{endDate} GROUP BY date")
    List<Map<String, Object>> getLoginStatsByDateRange(Long studentId, LocalDate startDate, LocalDate endDate);
}
