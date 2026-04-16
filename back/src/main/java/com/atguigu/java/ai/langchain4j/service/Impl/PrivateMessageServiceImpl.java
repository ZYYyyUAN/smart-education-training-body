package com.atguigu.java.ai.langchain4j.service.Impl;

import com.atguigu.java.ai.langchain4j.entity.PrivateMessage;
import com.atguigu.java.ai.langchain4j.mapper.PrivateMessageMapper;
import com.atguigu.java.ai.langchain4j.service.PrivateMessageService;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class PrivateMessageServiceImpl implements PrivateMessageService {
    
    @Autowired
    private PrivateMessageMapper privateMessageMapper;
    
    @Override
    public List<PrivateMessage> getMessagesByReceiverId(Long receiverId) {
        return privateMessageMapper.selectByReceiverId(receiverId);
    }
    
    @Override
    public Integer getUnreadCountByReceiverId(Long receiverId) {
        return privateMessageMapper.countUnreadByReceiverId(receiverId);
    }
    
    @Override
    public boolean markAsRead(Long messageId) {
        UpdateWrapper<PrivateMessage> updateWrapper = new UpdateWrapper<>();
        updateWrapper.eq("id", messageId)
                    .set("is_read", 1)
                    .set("read_time", LocalDateTime.now());
        return privateMessageMapper.update(null, updateWrapper) > 0;
    }
    
    @Override
    public boolean deleteMessage(Long messageId) {
        return privateMessageMapper.deleteById(messageId) > 0;
    }
    
    @Override
    public boolean sendMessage(PrivateMessage message) {
        message.setSendTime(LocalDateTime.now());
        message.setIsRead(0);
        message.setMessageType("private_message");
        message.setStatus("sent");
        return privateMessageMapper.insert(message) > 0;
    }
}
