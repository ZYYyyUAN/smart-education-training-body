package com.atguigu.java.ai.langchain4j.util;

import com.atguigu.java.ai.langchain4j.entity.QuestionBank;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class QuestionParser {

    public static List<QuestionBank> parse(String input, Long courseId) {
        List<QuestionBank> list = new ArrayList<>();

        // 预处理
        input = input.replaceAll("[\\r\\n\\t]+", " ")
                .replaceAll("\\s{2,}", " ")
                .trim();
        input = input.replaceAll("【\\s*", "【").replaceAll("\\s*】", "】");
        input = input.replaceAll("(\\d+)\\s*\\.\\s*", "$1. ");

        Pattern pattern = Pattern.compile("\\d+\\.\\s*【题型】.*?(?=\\d+\\.\\s*【题型】|$)", Pattern.DOTALL);
        Matcher matcher = pattern.matcher(input);

        while (matcher.find()) {
            String block = matcher.group().trim();

            QuestionBank qb = new QuestionBank();
            qb.setCourseId(courseId);
            qb.setCreatedAt(LocalDateTime.now());

            Matcher typeM = Pattern.compile("【题型】\\s*(.*?)\\s*【题干】", Pattern.DOTALL).matcher(block);
            if (typeM.find()) {
                String type = typeM.group(1).trim();
                if (type.contains("简答")) qb.setType("short_answer");
                else if (type.contains("选择")) qb.setType("choice");
                else if (type.contains("编程")) qb.setType("programming");
                else qb.setType("short_answer");
            }

            Matcher contentM = Pattern.compile("【题干】\\s*(.*?)\\s*【答案】", Pattern.DOTALL).matcher(block);
            if (contentM.find()) {
                qb.setContent(contentM.group(1).trim());
            }

            Matcher answerM = Pattern.compile("【答案】\\s*(.*?)\\s*【知识点】", Pattern.DOTALL).matcher(block);
            if (answerM.find()) {
                qb.setAnswer(answerM.group(1).trim());
            }

            Matcher kpM = Pattern.compile("【知识点】\\s*(.*)", Pattern.DOTALL).matcher(block);
            if (kpM.find()) {
                qb.setKnowledgePoint(kpM.group(1).trim());
            }

            if (qb.getContent() != null && qb.getAnswer() != null && qb.getType() != null) {
                list.add(qb);
                System.out.println("✅ 成功解析题目：" + qb.getContent());
            } else {
                System.out.println("⚠️ 丢弃无效题块：" + block);
            }
        }

        return list;
    }



}
