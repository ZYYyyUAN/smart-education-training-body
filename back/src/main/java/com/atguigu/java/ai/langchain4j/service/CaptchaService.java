package com.atguigu.java.ai.langchain4j.service;

import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class CaptchaService {
    private static class Entry { String code; long expireAt; }
    private final Map<String, Entry> store = new ConcurrentHashMap<>();
    private static final long EXPIRE_MS = 5 * 60 * 1000;

    public void storeCaptcha(String key, String code) {
        Entry e = new Entry();
        e.code = code;
        e.expireAt = Instant.now().toEpochMilli() + EXPIRE_MS;
        store.put(key, e);
    }

    public boolean validate(String key, String input) {
        Entry e = store.remove(key);
        if (e == null) return false;
        if (Instant.now().toEpochMilli() > e.expireAt) return false;
        return e.code != null && e.code.equalsIgnoreCase(input);
    }
}
