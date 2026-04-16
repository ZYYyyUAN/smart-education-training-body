package com.atguigu.java.ai.langchain4j.service;

import org.apache.poi.xwpf.usermodel.*;
import org.openxmlformats.schemas.wordprocessingml.x2006.main.*;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigInteger;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Word文档导出服务
 * 
 * 该服务负责将AI生成的学情分析报告导出为格式规范的Word文档（.docx格式）。
 * 使用Apache POI技术生成文档，支持：
 * - 标题、段落、列表的自动格式化
 * - 字体、字号、颜色的设置
 * - 页面边距和页面大小的配置
 * - 首行缩进、段落间距等排版设置
 * - 智能识别AI分析内容中的标题、段落、列表等格式
 * 
 * @author 张政
 * @date 2024
 */
@Service
public class WordExportService {

    /**
     * 生成学情分析报告Word文档
     * 
     * 将AI生成的学情分析内容转换为格式规范的Word文档。
     * 文档包含：
     * - 报告标题和学生基本信息
     * - 生成时间
     * - 结构化的分析内容（自动识别标题、段落、列表等格式）
     * - 页脚信息
     * 
     * 文档格式说明：
     * - 页面大小：A4（210mm × 297mm）
     * - 页边距：上、右、下各1英寸，左1.25英寸
     * - 标题：黑体、16号、蓝色、加粗
     * - 正文：宋体、12号、黑色、首行缩进
     * - 列表项：左缩进、宋体、12号
     * 
     * @param studentName 学生姓名，用于生成文件名和文档内容
     * @param analysisContent AI分析内容，支持【标题】格式的章节标题，自动识别段落和列表
     * @return Word文档的字节数组，可直接用于HTTP响应
     * @throws IOException 文件生成异常
     */
    public byte[] generateLearningAnalysisReport(String studentName, String analysisContent) throws IOException {
        // 创建Word文档对象
        XWPFDocument document = new XWPFDocument();
        
        // 设置页面边距和页面大小
        CTDocument1 ctDocument = document.getDocument();
        CTBody body = ctDocument.getBody();
        if (!body.isSetSectPr()) {
            body.addNewSectPr();
        }
        CTSectPr sectPr = body.getSectPr();
        if (!sectPr.isSetPgSz()) {
            sectPr.addNewPgSz();
        }
        CTPageSz pageSize = sectPr.getPgSz();
        // A4宽度：210mm = 11906 twips（单位：twips，1英寸=1440 twips）
        pageSize.setW(BigInteger.valueOf(11906));
        // A4高度：297mm = 16838 twips
        pageSize.setH(BigInteger.valueOf(16838));
        
        // 设置页边距（单位：twips）
        if (!sectPr.isSetPgMar()) {
            sectPr.addNewPgMar();
        }
        CTPageMar pageMar = sectPr.getPgMar();
        pageMar.setTop(BigInteger.valueOf(1440));   // 上边距 1英寸
        pageMar.setRight(BigInteger.valueOf(1440)); // 右边距 1英寸
        pageMar.setBottom(BigInteger.valueOf(1440)); // 下边距 1英寸
        pageMar.setLeft(BigInteger.valueOf(1800));   // 左边距 1.25英寸
        
        // 1. 文档标题（居中、加粗、22号字体）
        XWPFParagraph titlePara = document.createParagraph();
        titlePara.setAlignment(ParagraphAlignment.CENTER);
        XWPFRun titleRun = titlePara.createRun();
        titleRun.setText("学生学情分析报告");
        titleRun.setBold(true);
        titleRun.setFontSize(22);
        titleRun.setFontFamily("宋体");
        
        // 添加空行
        document.createParagraph();
        
        // 2. 学生基本信息（学生姓名和生成时间）
        XWPFParagraph infoPara = document.createParagraph();
        XWPFRun infoRun = infoPara.createRun();
        infoRun.setText("学生姓名：" + studentName);
        infoRun.setFontSize(12);
        infoRun.setFontFamily("宋体");
        
        XWPFParagraph datePara = document.createParagraph();
        XWPFRun dateRun = datePara.createRun();
        dateRun.setText("生成时间：" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy年MM月dd日 HH:mm")));
        dateRun.setFontSize(12);
        dateRun.setFontFamily("宋体");
        
        // 添加分隔线（灰色、10号字体）
        XWPFParagraph dividerPara = document.createParagraph();
        XWPFRun dividerRun = dividerPara.createRun();
        dividerRun.setText("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        dividerRun.setFontSize(10);
        dividerRun.setColor("808080");
        
        // 添加空行
        document.createParagraph();
        
        // 3. 分析内容 - 智能分段处理
        // 先按【标题】分割成不同章节，支持AI分析报告中的章节标题格式
        String[] sections = analysisContent.split("【");
        
        // 遍历每个章节，智能识别格式并生成对应的Word段落
        for (int sectionIndex = 0; sectionIndex < sections.length; sectionIndex++) {
            String section = sections[sectionIndex].trim();
            if (section.isEmpty()) {
                continue;
            }
            
            // 检查是否包含标题（以】结尾或包含】）
            if (section.contains("】")) {
                // 分离标题和内容
                String[] titleContent = section.split("】", 2);
                String titleText = titleContent[0].trim();
                String contentText = titleContent.length > 1 ? titleContent[1].trim() : "";
                
                // 添加标题段落（每个标题前都有较大间距）
                if (sectionIndex > 0) {
                    // 章节之间添加空行，增强可读性
                    document.createParagraph();
                }
                
                // 创建章节标题段落（黑体、16号、蓝色、加粗）
                XWPFParagraph sectionTitlePara = document.createParagraph();
                sectionTitlePara.setSpacingBefore(600); // 标题前间距（单位：twips）
                sectionTitlePara.setSpacingAfter(200);  // 标题后间距
                sectionTitlePara.setIndentationFirstLine(0);
                
                XWPFRun sectionTitleRun = sectionTitlePara.createRun();
                sectionTitleRun.setText("【" + titleText + "】");
                sectionTitleRun.setBold(true);
                sectionTitleRun.setFontSize(16);
                sectionTitleRun.setFontFamily("黑体");
                sectionTitleRun.setColor("1F4E78"); // 蓝色
                
                // 处理标题后的内容
                if (!contentText.isEmpty()) {
                    // 先按换行符分割
                    String[] contentLines = contentText.split("\n");
                    
                    // 如果没有换行符或只有一行，尝试按句号、问号、感叹号等智能分段
                    // 这样可以将长段落自动分割为多个句子，提高可读性
                    if (contentLines.length == 1 && contentText.length() > 100) {
                        // 按句号、问号、感叹号分割（保留标点）
                        contentLines = contentText.split("([。！？]\\s*)");
                    }
                    
                    // 处理每一行内容
                    for (String contentLine : contentLines) {
                        String trimmedContent = contentLine.trim();
                        if (trimmedContent.isEmpty()) {
                            continue;
                        }
                        
                        // 检查是否是列表项（格式：数字. 内容）
                        if (trimmedContent.matches("\\d+\\.[^\\d].*")) {
                            // 列表项：左缩进、无首行缩进
                            XWPFParagraph listPara = document.createParagraph();
                            listPara.setSpacingBefore(100);
                            listPara.setSpacingAfter(100);
                            listPara.setIndentationFirstLine(0);
                            listPara.setIndentationLeft(400); // 左缩进
                            
                            XWPFRun listRun = listPara.createRun();
                            listRun.setText(trimmedContent);
                            listRun.setFontSize(12);
                            listRun.setFontFamily("宋体");
                            listRun.setColor("000000");
                        } else {
                            // 正文段落：首行缩进、宋体、12号
                            XWPFParagraph contentPara = document.createParagraph();
                            contentPara.setSpacingBefore(0);
                            contentPara.setSpacingAfter(200);
                            contentPara.setIndentationFirstLine(600); // 首行缩进（2个字符）
                            
                            XWPFRun contentRun = contentPara.createRun();
                            contentRun.setText(trimmedContent);
                            contentRun.setFontSize(12);
                            contentRun.setFontFamily("宋体");
                            contentRun.setColor("000000");
                        }
                    }
                }
            } else {
                // 没有标题的内容（可能是开头部分）
                String[] contentLines = section.split("\n");
                for (String contentLine : contentLines) {
                    String trimmedContent = contentLine.trim();
                    if (trimmedContent.isEmpty()) {
                        continue;
                    }
                    
                    // 创建正文段落
                    XWPFParagraph contentPara = document.createParagraph();
                    contentPara.setSpacingBefore(0);
                    contentPara.setSpacingAfter(200);
                    contentPara.setIndentationFirstLine(600); // 首行缩进
                    
                    XWPFRun contentRun = contentPara.createRun();
                    contentRun.setText(trimmedContent);
                    contentRun.setFontSize(12);
                    contentRun.setFontFamily("宋体");
                    contentRun.setColor("000000");
                }
            }
        }
        
        // 4. 页脚（右对齐、灰色、斜体、10号字体）
        document.createParagraph();
        document.createParagraph();
        XWPFParagraph footerPara = document.createParagraph();
        footerPara.setAlignment(ParagraphAlignment.RIGHT);
        XWPFRun footerRun = footerPara.createRun();
        footerRun.setText("—— 智能教育系统自动生成");
        footerRun.setFontSize(10);
        footerRun.setFontFamily("宋体");
        footerRun.setColor("808080"); // 灰色
        footerRun.setItalic(true); // 斜体
        
        // 将文档转换为字节数组，用于HTTP响应
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        document.write(outputStream);
        document.close();
        
        return outputStream.toByteArray();
    }
}
