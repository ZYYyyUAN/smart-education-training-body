package com.atguigu.java.ai.langchain4j.config;

import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.store.embedding.EmbeddingStore;
import dev.langchain4j.store.embedding.pinecone.PineconeEmbeddingStore;
import jakarta.annotation.PostConstruct;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.util.StringUtils;

import java.util.function.Function;

@Configuration
public class EmbeddingStoreConfig {

    @Value("${pinecone.apiKey}")
    private String pineconeApiKey;

    @Value("${pinecone.index:xiaozhi}")
    private String pineconeIndex;

    @Value("${pinecone.enabled:true}")
    private boolean pineconeEnabled;

    @PostConstruct
    void validate() {
        if (!pineconeEnabled) return;
        if (!StringUtils.hasText(pineconeApiKey)) {
            throw new IllegalStateException(
                "\n============================================================\n" +
                "  Pinecone API Key 未配置！\n" +
                "  Pinecone 是本项目的核心强依赖，启动被终止。\n\n" +
                "  请在以下位置之一配置 pinecone.apiKey：\n" +
                "  1. 环境变量: export PINECONE_API_KEY=<your-key>\n" +
                "  2. application.properties: pinecone.apiKey=<your-key>\n" +
                "  3. application-prod.properties: pinecone.apiKey=${PINECONE_API_KEY}\n" +
                "     (并通过环境变量 PINECONE_API_KEY 注入实际值)\n\n" +
                "  本地开发若无需 Pinecone，可设置: pinecone.enabled=false\n" +
                "============================================================"
            );
        }
    }

    @Bean
    @ConditionalOnProperty(name = "pinecone.enabled", havingValue = "true", matchIfMissing = true)
    public EmbeddingStore<TextSegment> embeddingStore() {
        return PineconeEmbeddingStore.builder()
            .apiKey(pineconeApiKey)
            .index(pineconeIndex)
            .nameSpace("global")
            .build();
    }

    @Bean
    @ConditionalOnProperty(name = "pinecone.enabled", havingValue = "true", matchIfMissing = true)
    public Function<String, EmbeddingStore<TextSegment>> embeddingStoreFactory() {
        return (namespace) -> PineconeEmbeddingStore.builder()
            .apiKey(pineconeApiKey)
            .index(pineconeIndex)
            .nameSpace(namespace)
            .build();
    }

}
