package com.atguigu.java.ai.langchain4j.entity;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * 结构化教学计划返回体
 */
public class StructuredLessonPlan {

    @JsonProperty("教学目标")
    private String objective;

    @JsonProperty("知识点分布")
    private String knowledgeDistribution;

    @JsonProperty("教学时间安排")
    private String schedule;

    @JsonProperty("教学建议")
    private String suggestions;

    @JsonProperty("结语")
    private String closing;

    public String getObjective() { return objective; }
    public void setObjective(String objective) { this.objective = objective; }

    public String getKnowledgeDistribution() { return knowledgeDistribution; }
    public void setKnowledgeDistribution(String knowledgeDistribution) { this.knowledgeDistribution = knowledgeDistribution; }

    public String getSchedule() { return schedule; }
    public void setSchedule(String schedule) { this.schedule = schedule; }

    public String getSuggestions() { return suggestions; }
    public void setSuggestions(String suggestions) { this.suggestions = suggestions; }

    public String getClosing() { return closing; }
    public void setClosing(String closing) { this.closing = closing; }
}



