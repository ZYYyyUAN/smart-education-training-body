package com.atguigu.java.ai.langchain4j.config;
import dev.langchain4j.data.segment.TextSegment;
import com.atguigu.java.ai.langchain4j.store.MongoChatMemoryStore;
 
import dev.langchain4j.memory.chat.ChatMemoryProvider;
import dev.langchain4j.memory.chat.MessageWindowChatMemory;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.rag.content.retriever.ContentRetriever;
import dev.langchain4j.rag.content.retriever.EmbeddingStoreContentRetriever;
import dev.langchain4j.store.embedding.EmbeddingStore;
 
import java.util.function.Function;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

 

@Configuration
public class XiaozhiAgentConfig {
@Autowired
private MongoChatMemoryStore mongoChatMemoryStore;
    @Autowired
    private EmbeddingStore<TextSegment> embeddingStore;
    @Autowired
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
    ContentRetriever contentRetrieverXiaozhiPincone() {
        // 默认使用全局 store；支持基于 ThreadLocal 命名空间切换
        return EmbeddingStoreContentRetriever
            .builder()
            .embeddingModel(embeddingModel)
            .embeddingStore(embeddingStore)
            .maxResults(3)
            .minScore(0.7)
            .build();
    }

    // 提供一个按课程命名空间创建的检索器工厂（供控制器按需使用）
    @Bean
    public Function<String, ContentRetriever> courseContentRetrieverFactory() {
        return (namespace) -> EmbeddingStoreContentRetriever
            .builder()
            .embeddingModel(embeddingModel)
            .embeddingStore(embeddingStoreFactory.apply(namespace))
            .maxResults(3)
            .minScore(0.7)
            .build();
    }
}