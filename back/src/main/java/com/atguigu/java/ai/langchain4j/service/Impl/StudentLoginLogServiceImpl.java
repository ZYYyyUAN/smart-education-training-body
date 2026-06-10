package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.StudentLoginLog;
import com.atguigu.java.ai.langchain4j.mapper.StudentLoginLogMapper;
import com.atguigu.java.ai.langchain4j.service.StudentLoginLogService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Slf4j
@Service
public class StudentLoginLogServiceImpl implements StudentLoginLogService {

    @Autowired
    private StudentLoginLogMapper studentLoginLogMapper;

    @Override
    public List<StudentLoginLog> getLoginLogsByStudentIdAndDateRange(Long studentId, LocalDate start, LocalDate end) {
        return new ArrayList<>();
    }

    @Override
    public List<Map<String, Object>> getLoginStatsByStudentId(Long studentId, int days) {
        try {
            log.debug("getLoginStats, studentId={}, days={}", studentId, days);

            LocalDate refDate = resolveReferenceDate(studentId);
            List<Map<String, Object>> result = buildDateFramework(refDate, days);

            List<Map<String, Object>> dbStats = studentLoginLogMapper.getLoginStatsLast7Days(studentId);
            Map<LocalDate, Integer> lookup = indexByDate(dbStats);

            for (int i = 0; i < result.size(); i++) {
                LocalDate resultDate = refDate.minusDays(days - 1 - i);
                Integer count = lookup.get(resultDate);
                if (count != null) {
                    result.get(i).put("loginCount", count);
                }
            }

            log.debug("login stats result: {}", result);
            return result;
        } catch (Exception e) {
            log.error("getLoginStats failed", e);
            return new ArrayList<>();
        }
    }

    private LocalDate resolveReferenceDate(Long studentId) {
        String lastLogin = studentLoginLogMapper.getLastLoginTimeByStudentId(studentId);
        if (lastLogin != null && !lastLogin.isEmpty()) {
            try {
                return LocalDate.parse(lastLogin.split(" ")[0]);
            } catch (Exception e) {
                log.debug("parse last login time failed, using now: {}", e.getMessage());
            }
        }
        return LocalDate.now();
    }

    private List<Map<String, Object>> buildDateFramework(LocalDate refDate, int days) {
        List<Map<String, Object>> result = new ArrayList<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MM-dd");
        for (int i = days - 1; i >= 0; i--) {
            LocalDate date = refDate.minusDays(i);
            Map<String, Object> dayData = new HashMap<>();
            dayData.put("date", date.format(fmt));
            dayData.put("dayOfWeek", date.getDayOfWeek().getDisplayName(
                    java.time.format.TextStyle.SHORT, Locale.CHINESE));
            dayData.put("loginCount", 0);
            result.add(dayData);
        }
        return result;
    }

    private Map<LocalDate, Integer> indexByDate(List<Map<String, Object>> dbStats) {
        Map<LocalDate, Integer> map = new HashMap<>();
        for (Map<String, Object> row : dbStats) {
            try {
                LocalDate date = toLocalDate(row.get("login_date"));
                Integer count = toInt(row.get("login_count"));
                if (date != null && count != null) {
                    map.put(date, count);
                }
            } catch (Exception e) {
                log.debug("process db row failed: {}", e.getMessage());
            }
        }
        return map;
    }

    private static LocalDate toLocalDate(Object obj) {
        if (obj instanceof LocalDate) return (LocalDate) obj;
        if (obj instanceof java.sql.Date) return ((java.sql.Date) obj).toLocalDate();
        if (obj instanceof java.sql.Timestamp) return ((java.sql.Timestamp) obj).toLocalDateTime().toLocalDate();
        if (obj instanceof String) return LocalDate.parse((String) obj);
        return null;
    }

    private static Integer toInt(Object obj) {
        if (obj instanceof Number) return ((Number) obj).intValue();
        if (obj instanceof String) return Integer.parseInt((String) obj);
        return null;
    }

    @Override
    public String getLastLoginTimeByStudentId(Long studentId) {
        try {
            String lastLoginTime = studentLoginLogMapper.getLastLoginTimeByStudentId(studentId);
            return lastLoginTime != null ? lastLoginTime : "2025-01-27 14:30";
        } catch (Exception e) {
            log.error("getLastLoginTime failed", e);
            return "2025-01-27 14:30";
        }
    }

    @Override
    public int countLoginsByStudentIdAndDateRange(Long studentId, LocalDate startDate, LocalDate endDate) {
        try {
            List<Map<String, Object>> stats = studentLoginLogMapper.getLoginStatsByDateRange(studentId, startDate, endDate);
            int total = 0;
            for (Map<String, Object> stat : stats) {
                total += ((Number) stat.get("login_count")).intValue();
            }
            return total;
        } catch (Exception e) {
            log.error("countLogins failed", e);
            return 0;
        }
    }
}
