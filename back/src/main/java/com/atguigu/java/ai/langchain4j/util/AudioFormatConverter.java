package com.atguigu.java.ai.langchain4j.util;

import javax.sound.sampled.*;
import java.io.*;

public class AudioFormatConverter {

    /**
     * 将音频文件转换为标准 PCM 格式：16kHz、16bit、mono
     * @param sourceFile 原始音频文件
     * @param targetFile 输出的 PCM 文件（.wav）
     * @throws Exception 转换失败异常
     */
    public static void convertToPcm(File sourceFile, File targetFile) throws Exception {
        // 获取音频输入流
        AudioInputStream sourceStream = AudioSystem.getAudioInputStream(sourceFile);
        AudioFormat sourceFormat = sourceStream.getFormat();

        // 目标格式：PCM_SIGNED，16kHz，16bit，单声道
        AudioFormat targetFormat = new AudioFormat(
                AudioFormat.Encoding.PCM_SIGNED,
                16000,
                16,
                1,
                2,
                16000,
                false
        );

        // 转换流
        AudioInputStream pcmStream = AudioSystem.getAudioInputStream(targetFormat, sourceStream);

        // 写入 WAV 格式输出
        AudioSystem.write(pcmStream, AudioFileFormat.Type.WAVE, targetFile);

        // 关闭资源
        sourceStream.close();
        pcmStream.close();
    }

    public static void main(String[] args) {
        try {
            File input = new File("input_audio.webm");   // 支持 webm、mp3、wav 等
            File output = new File("output_audio.wav");   // 统一转换为 PCM WAV 格式

            convertToPcm(input, output);
            System.out.println("✅ 音频转换成功：" + output.getAbsolutePath());
        } catch (Exception e) {
            System.err.println("❌ 音频转换失败: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
