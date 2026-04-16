package com.atguigu.java.ai.langchain4j.util;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;
import java.util.stream.Collectors;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;

public class FileUtil {

    // 获取唯一文件名：uuid_原始文件名
    public static String generateUniqueFileName(String originalFileName) {
        String uuid = UUID.randomUUID().toString().replace("-", "");
        return uuid + "_" + originalFileName;
    }

    // 保存文件到指定路径（如：/upload/）
    public static String saveFile(MultipartFile file, String uploadDir) throws IOException {
        // 创建目录（如果不存在）
        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        // 生成新文件名
        String newFileName = generateUniqueFileName(file.getOriginalFilename());
        File dest = new File(dir, newFileName);

        // 保存文件
        file.transferTo(dest);

        // 返回相对路径或绝对路径（根据项目需求）
        return dest.getAbsolutePath(); // 或 dest.getPath();
    }

    // 获取当前时间字符串
    public static String getCurrentTimestamp() {
        return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
    }
    public static String extractTextFromFile(MultipartFile file) throws Exception {
        String filename = file.getOriginalFilename();
        if (filename == null) throw new IllegalArgumentException("文件名为空");

        if (filename.endsWith(".txt")) {
            // 自动探测TXT编码（兼容GBK/GB2312/UTF-8），默认UTF-8
            byte[] bytes = file.getBytes();
            String charset = detectCharset(bytes);
            return new String(bytes, java.nio.charset.Charset.forName(charset));
        } else if (filename.endsWith(".docx")) {
            try (XWPFDocument doc = new XWPFDocument(file.getInputStream())) {
                return doc.getParagraphs().stream()
                        .map(XWPFParagraph::getText)
                        .collect(Collectors.joining("\n"));
            }
        } else if (filename.endsWith(".pdf")) {
            try (PDDocument document = PDDocument.load(file.getInputStream())) {
                PDFTextStripper stripper = new PDFTextStripper();
                return stripper.getText(document);
            }
        } else {
            throw new IllegalArgumentException("不支持的文件类型：" + filename);
        }
    }

    // 简易编码探测（BOM优先，其次UTF-8校验，最后回退GBK）
    private static String detectCharset(byte[] bytes) {
        if (bytes.length >= 3 && (bytes[0] & 0xFF) == 0xEF && (bytes[1] & 0xFF) == 0xBB && (bytes[2] & 0xFF) == 0xBF) {
            return "UTF-8";
        }
        // 试图按UTF-8解码并回编，若一致则认为UTF-8
        try {
            String s = new String(bytes, StandardCharsets.UTF_8);
            if (s.getBytes(StandardCharsets.UTF_8).length == bytes.length) {
                return "UTF-8";
            }
        } catch (Exception ignored) {}
        // 常见国标编码
        return "GBK";
    }

}
