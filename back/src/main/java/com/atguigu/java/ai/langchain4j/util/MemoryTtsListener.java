package com.atguigu.java.ai.langchain4j.util;

import cn.xfyun.model.response.TtsResponse;
import cn.xfyun.service.tts.AbstractTtsWebSocketListener;
import okhttp3.Response;
import okhttp3.WebSocket;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;

public class MemoryTtsListener extends AbstractTtsWebSocketListener {

    private final ByteArrayOutputStream outputStream;
    private final Object lock;

    public MemoryTtsListener(ByteArrayOutputStream outputStream, Object lock) throws FileNotFoundException {
        // 必须传入非null文件路径或者null，若父类有写文件逻辑传null可防止文件写入
        super(new File("tmp_" + System.currentTimeMillis() + ".pcm")); // 传入一个临时文件名
        this.outputStream = outputStream;
        this.lock = lock;
    }

    /**
     * 合成成功回调，接收一块音频数据
     */
    @Override
    public void onSuccess(byte[] bytes) {
        if (bytes != null && bytes.length > 0) {
            try {
                outputStream.write(bytes);
                System.out.println("TTS数据写入，当前缓冲大小：" + outputStream.size());
            } catch (IOException e) {
                System.err.println("写入音频数据失败：" + e.getMessage());
                e.printStackTrace();
            }
        }
    }

    /**
     * 连接失败回调
     */
    @Override
    public void onFail(WebSocket webSocket, Throwable throwable, Response response) {
        System.err.println("TTS连接失败: " + throwable.getMessage());
        notifyLock();
    }

    /**
     * 业务失败回调（例如文本超长等）
     */
    @Override
    public void onBusinessFail(WebSocket webSocket, TtsResponse ttsResponse) {
        System.err.println("TTS业务失败: " + ttsResponse);
        notifyLock();
    }

    /**
     * 连接关闭回调，代表语音合成完成
     */

    public void onClosed() {
        System.out.println("TTS连接已关闭，语音合成完成");

        notifyLock();
    }

    /**
     * 唤醒等待线程
     */
    private void notifyLock() {
        synchronized (lock) {
            lock.notify();
        }
    }
}
