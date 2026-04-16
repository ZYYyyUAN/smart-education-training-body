package com.atguigu.java.ai.langchain4j.service;

import cn.xfyun.api.TtsClient;
import com.atguigu.java.ai.langchain4j.assistant.XiaozhiAgent;
import com.atguigu.java.ai.langchain4j.config.AudioWebSocketHandler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

import java.io.File;
import java.io.FileOutputStream;

@Service
public class VoiceChatService {

    @Autowired
    private RtasrService rtasrService;

    @Autowired
    private XiaozhiAgent xiaozhiAgent;
    @Autowired
    private TtsService ttsService; // 注入你写好的 TTS 语音合成服务
    @Autowired
    private AudioWebSocketHandler audioWebSocketHandler;

    public void handleSingleVoiceChat(Long memoryId,String userMessage) throws Exception {
        if (userMessage == null || userMessage.trim().isEmpty()) {
            System.out.println("⚠️ 用户没有说话，结束对话。");
            return;
        }

        System.out.println("🤖 智能体正在思考...");
        Flux<String> responseFlux = xiaozhiAgent.chat3(memoryId, userMessage);
        StringBuilder assistantReply = new StringBuilder();

        responseFlux.toStream().forEach(part -> {
            System.out.print(part);
            assistantReply.append(part);
        });

        System.out.println("\n🚀 AI回复完成，开始合成：" + assistantReply);

        try {
            byte[] audioBytes = ttsService.synthesizeToBytes(assistantReply.toString());
            System.out.println("✅ 合成完成，音频大小：" + audioBytes.length + " 字节");

            // ✅ 推送给前端播放
            audioWebSocketHandler.sendAudioToClients(audioBytes);
        } catch (Exception e) {
            System.err.println("❌ 合成失败：" + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("✅ 单轮语音对话结束。");
    }

}
