package com.atguigu.java.ai.langchain4j.util;
import com.aliyun.oss.OSS;
import com.aliyun.oss.OSSClientBuilder;
import com.atguigu.java.ai.langchain4j.config.AliyunOssProperties;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.util.UUID;

@Component
public class AliyunOssUtil {

    @Autowired
    private AliyunOssProperties ossProperties;

    public String uploadFile(MultipartFile file) throws IOException {
        // 生成带前缀的唯一文件名
        String fileName = ossProperties.getFileHost() + "/" + UUID.randomUUID() + "-" + file.getOriginalFilename();

        // 创建 OSS 客户端
        OSS ossClient = new OSSClientBuilder().build(
                ossProperties.getEndpoint(),
                ossProperties.getAccessKeyId(),
                ossProperties.getAccessKeySecret()
        );

        // 上传文件
        ossClient.putObject(ossProperties.getBucketName(), fileName, file.getInputStream());

        // 拼接可访问地址
        String url = "https://" + ossProperties.getBucketName() + "." + ossProperties.getEndpoint() + "/" + fileName;

        // 关闭 OSS 客户端
        ossClient.shutdown();

        return url;
    }

    public void downloadToFile(String ossUrl, java.io.File targetFile) throws IOException {
        // 截取 object key：URL = https://bucket.endpoint/objectKey
        String urlPrefix = "https://" + ossProperties.getBucketName() + "." + ossProperties.getEndpoint() + "/";
        if (!ossUrl.startsWith(urlPrefix)) {
            throw new IOException("OSS URL 格式不匹配: " + ossUrl);
        }
        String objectKey = ossUrl.substring(urlPrefix.length());

        OSS ossClient = new OSSClientBuilder().build(
                ossProperties.getEndpoint(),
                ossProperties.getAccessKeyId(),
                ossProperties.getAccessKeySecret()
        );

        try (InputStream in = ossClient.getObject(ossProperties.getBucketName(), objectKey).getObjectContent();
             java.io.FileOutputStream out = new java.io.FileOutputStream(targetFile)) {
            in.transferTo(out);
        } finally {
            ossClient.shutdown();
        }
    }
}
