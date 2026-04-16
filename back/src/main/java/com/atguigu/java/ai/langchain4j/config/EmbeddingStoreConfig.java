package com.atguigu.java.ai.langchain4j.config;

import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.store.embedding.EmbeddingStore;
import dev.langchain4j.store.embedding.pinecone.PineconeEmbeddingStore;
import dev.langchain4j.store.embedding.pinecone.PineconeServerlessIndexConfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.beans.factory.annotation.Value;

import java.util.function.Function;

@Configuration
public class EmbeddingStoreConfig {
    
    @Autowired
    private EmbeddingModel embeddingModel;
    
    @Value("${pinecone.apiKey:pcsk_2KTmEq_5ZnpriWvb83DfoJ1QXrXs8awaYnNmDJb94x3eCN7KomXfc2Gra2vL4f2e7wXw3x}")
    private String pineconeApiKey;
    
    @Value("${pinecone.index:xiaozhi}")
    private String pineconeIndex;
    
    @Value("${pinecone.cloud:AWS}")
    private String pineconeCloud;
    
    @Value("${pinecone.region:us-east-1}")
    private String pineconeRegion;
    
    @Bean
    public EmbeddingStore<TextSegment> embeddingStore() {
        // 全局默认 store（可用于通用检索），命名空间可按需设置
        return PineconeEmbeddingStore.builder()
            .apiKey(pineconeApiKey)
            .index(pineconeIndex)
            .nameSpace("global")
            .createIndex(PineconeServerlessIndexConfig.builder()
                .cloud(pineconeCloud)
                .region(pineconeRegion)
                .dimension(embeddingModel.dimension())
                .build())
            .build();
    }
    
    @Bean
    public Function<String, EmbeddingStore<TextSegment>> embeddingStoreFactory() {
        return (namespace) -> PineconeEmbeddingStore.builder()
            .apiKey(pineconeApiKey)
            .index(pineconeIndex)
            .nameSpace(namespace)
            .createIndex(PineconeServerlessIndexConfig.builder()
                .cloud(pineconeCloud)
                .region(pineconeRegion)
                .dimension(embeddingModel.dimension())
                .build())
            .build();
    }
    
}