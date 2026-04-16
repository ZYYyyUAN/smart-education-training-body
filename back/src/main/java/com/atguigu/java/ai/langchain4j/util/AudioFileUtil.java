package com.atguigu.java.ai.langchain4j.util;

import java.io.FileOutputStream;
import java.io.IOException;

public class AudioFileUtil {

    /**
     * 把字节数组写成文件
     * @param audioBytes 音频数据
     * @param filePath 输出文件路径，如 "output.mp3"
     */
    public static void saveToFile(byte[] audioBytes, String filePath) throws IOException {
        try (FileOutputStream fos = new FileOutputStream(filePath)) {
            fos.write(audioBytes);
            fos.flush();
        }
    }
}
