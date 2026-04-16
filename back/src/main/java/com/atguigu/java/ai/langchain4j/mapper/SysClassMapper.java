package com.atguigu.java.ai.langchain4j.mapper;

import com.atguigu.java.ai.langchain4j.entity.SysClass;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/**
 * 班级Mapper接口
 * 
 * 该接口提供班级信息的数据访问方法，用于学情信息管理模块。
 * 继承MyBatis-Plus的BaseMapper，提供基础的CRUD操作。
 * 
 * @author 张政
 * @date 2024
 */
@Mapper
public interface SysClassMapper extends BaseMapper<SysClass> {
}
