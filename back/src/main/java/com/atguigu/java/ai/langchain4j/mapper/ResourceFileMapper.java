package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.ResourceFile;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ResourceFileMapper extends BaseMapper<ResourceFile> {
    // 可选：自定义查询（用于多表联查或更复杂逻辑）
}
