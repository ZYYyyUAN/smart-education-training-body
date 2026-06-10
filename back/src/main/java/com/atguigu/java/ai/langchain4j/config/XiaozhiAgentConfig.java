package com.atguigu.java.ai.langchain4j.config;
import dev.langchain4j.data.segment.TextSegment;
import com.atguigu.java.ai.langchain4j.store.MongoChatMemoryStore;

import dev.langchain4j.memory.chat.ChatMemoryProvider;
import dev.langchain4j.memory.chat.MessageWindowChatMemory;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.rag.content.retriever.ContentRetriever;
import dev.langchain4j.rag.content.retriever.EmbeddingStoreContentRetriever;
import dev.langchain4j.store.embedding.EmbeddingStore;

import java.util.Collections;
import java.util.List;
import java.util.function.Function;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


@Configuration
public class XiaozhiAgentConfig {
    @Autowired
    private MongoChatMemoryStore mongoChatMemoryStore;
    @Autowired(required = false)
    private EmbeddingStore<TextSegment> embeddingStore;
    @Autowired(required = false)
    private Function<String, EmbeddingStore<TextSegment>> embeddingStoreFactory;
    @Autowired
    private EmbeddingModel embeddingModel;

    @Bean
    ChatMemoryProvider chatMemoryProviderXiaozhi() {
        return memoryId -> MessageWindowChatMemory.builder()
            .id(memoryId)
            .maxMessages(4)
            .chatMemoryStore(mongoChatMemoryStore)
            .build();
    }

    @Bean
    @ConditionalOnProperty(name = "pinecone.enabled", havingValue = "true", matchIfMissing = true)
    ContentRetriever contentRetrieverXiaozhiPincone() {
        return EmbeddingStoreContentRetriever
            .builder()
            .embeddingModel(embeddingModel)
            .embeddingStore(embeddingStore)
            .maxResults(3)
            .minScore(0.7)
            .build();
    }

    @Bean
    @ConditionalOnProperty(name = "pinecone.enabled", havingValue = "true", matchIfMissing = true)
    public Function<String, ContentRetriever> courseContentRetrieverFactory() {
        return (namespace) -> EmbeddingStoreContentRetriever
            .builder()
            .embeddingModel(embeddingModel)
            .embeddingStore(embeddingStoreFactory.apply(namespace))
            .maxResults(3)
            .minScore(0.7)
            .build();
    }

    @Bean("contentRetrieverXiaozhiPincone")
    @ConditionalOnProperty(name = "pinecone.enabled", havingValue = "false")
    ContentRetriever pineconeDisabledRetriever() {
        return (query) -> Collections.emptyList();
    }

    @Bean("courseContentRetrieverFactory")
    @ConditionalOnProperty(name = "pinecone.enabled", havingValue = "false")
    public Function<String, ContentRetriever> pineconeDisabledRetrieverFactory() {
        return (namespace) -> (query) -> Collections.emptyList();
    }
}