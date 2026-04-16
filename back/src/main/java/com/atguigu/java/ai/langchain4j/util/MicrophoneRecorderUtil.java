package com.atguigu.java.ai.langchain4j.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sound.sampled.*;
import java.io.IOException;
import java.io.PipedOutputStream;

/**
 * 自动检测并适配音频格式的麦克风录音工具类
 */
public class MicrophoneRecorderUtil {

    private static final Logger logger = LoggerFactory.getLogger(MicrophoneRecorderUtil.class);

    // 常见音频格式尝试列表（采样率，采样位数，声道数，带符号，是否大端）
    private static final AudioFormat[] FORMATS_TO_TRY = new AudioFormat[]{
            new AudioFormat(16000, 16, 1, true, false),
            new AudioFormat(16000, 16, 2, true, false),
            new AudioFormat(44100, 16, 1, true, false),
            new AudioFormat(44100, 16, 2, true, false),
            new AudioFormat(8000, 16, 1, true, false),
            new AudioFormat(8000, 16, 2, true, false),
    };

    private volatile TargetDataLine targetDataLine;
    private volatile boolean recording;
    private volatile PipedOutputStream outputStream;
    private AudioFormat usedFormat;

    public synchronized void startRecording(PipedOutputStream outputStream) throws LineUnavailableException {
        if (outputStream == null) {
            throw new IllegalArgumentException("输出流不能为空");
        }
        if (recording || this.outputStream != null) {
            throw new IllegalStateException("已有录音任务在执行中");
        }
        this.outputStream = outputStream;

        // 找到第一个支持的格式
        usedFormat = findSupportedFormat();
        logger.info("使用的音频格式：采样率 {} Hz，采样位数 {}，声道数 {}，signed {}，bigEndian {}",
                (int) usedFormat.getSampleRate(),
                usedFormat.getSampleSizeInBits(),
                usedFormat.getChannels(),
                usedFormat.getEncoding() == AudioFormat.Encoding.PCM_SIGNED,
                usedFormat.isBigEndian());

        DataLine.Info info = new DataLine.Info(TargetDataLine.class, usedFormat);
        try {
            targetDataLine = (TargetDataLine) AudioSystem.getLine(info);
            targetDataLine.open(usedFormat);
            targetDataLine.start();
        } catch (LineUnavailableException e) {
            cleanupResources();
            throw e;
        }

        Thread captureThread = new Thread(this::captureAudio);
        captureThread.setUncaughtExceptionHandler((thread, throwable) -> {
            logger.error("录音线程异常", throwable);
            cleanupResources();
        });
        captureThread.start();
    }

    private AudioFormat findSupportedFormat() throws LineUnavailableException {
        for (AudioFormat format : FORMATS_TO_TRY) {
            DataLine.Info info = new DataLine.Info(TargetDataLine.class, format);
            if (AudioSystem.isLineSupported(info)) {
                return format;
            }
        }
        throw new LineUnavailableException("没有可用的录音格式，检查麦克风设备和驱动");
    }

    private void captureAudio() {
        recording = true;
        byte[] buffer = new byte[1280];

        while (recording) {
            int bytesRead = targetDataLine.read(buffer, 0, buffer.length);
            if (bytesRead > 0 && outputStream != null) {
                try {
                    outputStream.write(buffer, 0, bytesRead);
                    outputStream.flush();
                } catch (IOException e) {
                    logger.error("输出流写入异常", e);
                    break;
                }
            }
        }
        cleanupResources();
    }

    public synchronized void stopRecording() {
        recording = false;
    }

    private synchronized void cleanupResources() {
        try {
            if (targetDataLine != null && targetDataLine.isOpen()) {
                targetDataLine.stop();
                targetDataLine.close();
            }
            if (outputStream != null) {
                outputStream.close();
            }
        } catch (Exception e) {
            logger.error("资源清理异常", e);
        } finally {
            targetDataLine = null;
            outputStream = null;
        }
    }

    /**
     * 获取当前使用的音频格式（方便调用方知晓）
     */
    public AudioFormat getUsedFormat() {
        return usedFormat;
    }
}
