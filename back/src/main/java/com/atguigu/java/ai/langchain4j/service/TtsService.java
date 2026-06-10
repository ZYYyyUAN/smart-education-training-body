package com.atguigu.java.ai.langchain4j.service;

import cn.xfyun.api.TtsClient;
import cn.xfyun.model.response.TtsResponse;
import cn.xfyun.service.tts.AbstractTtsWebSocketListener;
import okhttp3.Response;
import okhttp3.WebSocket;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.security.SignatureException;
import java.util.UUID;

@Service
public class TtsService {

    @Value("${xfyun.tts.app-id:${xfyun.app-id:e3d65130}}")
    private String appId;

    @Value("${xfyun.tts.api-key:8fbd66f51fb8cb80d24883bd0aad106e}")
    private String apiKey;

    @Value("${xfyun.tts.api-secret:N2FkN2U2MDY0Y2QzMTZlNTA1MjIwMDRl}")
    private String apiSecret;

    private TtsClient ttsClient;

    @PostConstruct
    public void init() throws SignatureException {
        this.ttsClient = new TtsClient.Builder()
                .vcn("x4_yezi")
                .signature(appId, apiKey, apiSecret)
                .build();
    }

    /**
     * 语音合成：输入文字，输出音频文件路径
     */
    public byte[] synthesizeToBytes(String text) throws Exception {
        System.out.println("✅ 开始合成" );
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        Object lock = new Object();
        Exception[] error = new Exception[1];

        ttsClient.send(text, new AbstractTtsWebSocketListener() {

            @Override
            public void onSuccess(byte[] bytes) {
                try {
                    outputStream.write(bytes);
                } catch (IOException e) {
                    error[0] = e;
                }
            }

            @Override
            public void onFail(WebSocket webSocket, Throwable throwable, Response response) {
                error[0] = new RuntimeException("TTS失败", throwable);
                synchronized (lock) { lock.notify(); }
            }

            @Override
            public void onBusinessFail(WebSocket webSocket, TtsResponse ttsResponse) {
                error[0] = new RuntimeException("TTS业务失败: " + ttsResponse);
                synchronized (lock) { lock.notify(); }
            }

            @Override
            public void onClosed(WebSocket webSocket, int code, String reason) {
                super.onClosed(webSocket, code, reason);
                synchronized (lock) {
                    lock.notify();
                }
            }

        });


        synchronized (lock) { lock.wait(); }
        System.out.println("✅ 合成成功，音频字节大小: " + outputStream.size());
        if (error[0] != null) throw error[0];
        return outputStream.toByteArray();
    }

}
