package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.assistant.XiaozhiAgent;
import com.atguigu.java.ai.langchain4j.config.AudioWebSocketHandler;
import com.atguigu.java.ai.langchain4j.entity.LoginRequest;
import com.atguigu.java.ai.langchain4j.entity.OperationLog;
import com.atguigu.java.ai.langchain4j.service.CaptchaService;
import com.atguigu.java.ai.langchain4j.service.OperationLogService;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import com.atguigu.java.ai.langchain4j.entity.Result;

import com.atguigu.java.ai.langchain4j.entity.User;
import com.atguigu.java.ai.langchain4j.service.RtasrService;
import com.atguigu.java.ai.langchain4j.service.TtsService;
import com.atguigu.java.ai.langchain4j.service.UserService;
import com.atguigu.java.ai.langchain4j.service.VoiceChatService;
import com.atguigu.java.ai.langchain4j.util.JwtUtil;
import com.atguigu.java.ai.langchain4j.util.IatModelZhMain;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Flux;
import java.util.Map;

import java.io.File;
import java.io.InputStream;

@Tag(name = "用户登录与注册")
@RestController
@RequestMapping("/auth")
@Slf4j
public class AuthController {

    @Autowired
    private UserService userService;
    @Autowired
    private RtasrService rtasrService;
    @Autowired
    private XiaozhiAgent xiaozhiAgent;
    @Autowired
    private TtsService ttsService; // 注入你写好的 TTS 语音合成服务
    @Autowired
    private AudioWebSocketHandler audioWebSocketHandler;
    @Value("${xfyun.app-id}")
    private String appId;

    @Value("${xfyun.api-key}")
    private String apiKey;
    @Autowired
    private CaptchaService captchaService;
    
    @Autowired
    private OperationLogService operationLogService;
    @PostMapping("/register")
    public Result register(@RequestBody User user, HttpServletRequest request) {
        OperationLog.Status logStatus = OperationLog.Status.SUCCESS;
        String errorMessage = null;
        Long createdUserId = null;
        
        try {
            log.info("收到注册请求: {}", user);
            
            // 参数验证
            if (user == null || user.getUsername() == null || user.getPassword() == null) {
                logStatus = OperationLog.Status.FAILED;
                errorMessage = "注册参数不能为空";
                return Result.error(errorMessage);
            }
            
            boolean success = userService.register(user);
            if (success) {
                log.info("用户注册成功: {}", user.getUsername());
                createdUserId = user.getId();
                
                // 记录操作日志（注册时可能还没有登录用户，使用注册的用户信息）
                try {
                    String desc = String.format("新增用户: %s (ID: %d)", user.getUsername(), createdUserId);
                    operationLogService.logOperation(createdUserId, user.getUsername(), 
                            OperationLog.OperationType.CREATE, "user", createdUserId, desc, 
                            logStatus, errorMessage, request);
                } catch (Exception e) {
                    log.warn("记录操作日志失败", e);
                }
                
                return Result.ok("注册成功");
            } else {
                log.error("用户注册失败: {}", user.getUsername());
                logStatus = OperationLog.Status.FAILED;
                errorMessage = "注册失败，用户名可能已存在";
                
                // 记录失败的操作日志
                try {
                    String desc = String.format("新增用户失败: %s", user.getUsername());
                    operationLogService.logOperation(null, user.getUsername(), 
                            OperationLog.OperationType.CREATE, "user", null, desc, 
                            logStatus, errorMessage, request);
                } catch (Exception e) {
                    log.warn("记录操作日志失败", e);
                }
                
                return Result.error(errorMessage);
            }
        } catch (Exception e) {
            log.error("用户注册异常", e);
            logStatus = OperationLog.Status.FAILED;
            errorMessage = e.getMessage();
            
            // 记录异常的操作日志
            try {
                String username = user != null ? user.getUsername() : "未知";
                String desc = String.format("新增用户异常: %s", username);
                operationLogService.logOperation(null, username, 
                        OperationLog.OperationType.CREATE, "user", null, desc, 
                        logStatus, errorMessage, request);
            } catch (Exception ex) {
                log.warn("记录操作日志失败", ex);
            }
            
            return Result.error("注册失败：" + e.getMessage());
        }
    }

    @GetMapping("/test")
    public Result<String> test() {
        return Result.ok("CORS测试成功");
    }

    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody LoginRequest loginRequest, HttpServletRequest request) {
        try {
            log.info("🔍 收到登录请求: username=[{}], password_length=[{}], captcha=[{}]", 
                loginRequest.getUsername(), 
                loginRequest.getPassword() != null ? loginRequest.getPassword().length() : 0,
                loginRequest.getCaptcha());
            
            if (loginRequest.getUsername() == null || loginRequest.getPassword() == null) {
                log.warn("❌ 登录参数为空: username=[{}], password=[{}]", 
                    loginRequest.getUsername(), 
                    loginRequest.getPassword() != null ? "***" : "null");
                return Result.error("用户名和密码不能为空");
            }

            // 验证验证码（Kaptcha）
            String key = loginRequest.getCaptchaKey();
            log.info("🔍 验证码调试: captcha_key_from_request=[{}]", key);
            
            if (key == null || key.isBlank()) {
                // 也支持从Cookie读取
                if (request.getCookies() != null) {
                    log.info("🔍 尝试从Cookie读取验证码key，Cookie数量: {}", request.getCookies().length);
                    for (Cookie c : request.getCookies()) {
                        log.info("   Cookie: name=[{}], value=[{}]", c.getName(), c.getValue());
                        if ("CAPTCHA_KEY".equals(c.getName())) { 
                            key = c.getValue(); 
                            log.info("✅ 从Cookie获取到验证码key: [{}]", key);
                            break; 
                        }
                    }
                } else {
                    log.warn("❌ 请求中没有Cookie");
                }
            }
            
            log.info("🔍 验证验证码: key=[{}], captcha=[{}]", key, loginRequest.getCaptcha());
            boolean captchaValid = false;
            if (key != null) {
                captchaValid = captchaService.validate(key, loginRequest.getCaptcha());
                log.info("🔍 验证码验证结果: {}", captchaValid ? "✅ 通过" : "❌ 失败");
            } else {
                log.warn("❌ 验证码key为空");
            }
            
            if (key == null || !captchaValid) {
                log.warn("❌ 验证码验证失败，返回错误");
                return Result.error(401, "验证码错误或已过期");
            }
            
            log.info("✅ 验证码验证通过，开始用户名密码验证");
            User user = userService.loginWithLog(loginRequest.getUsername(), loginRequest.getPassword());
            if (user == null) {
                log.warn("❌ 用户名密码验证失败: username=[{}]", loginRequest.getUsername());
                return Result.error("用户名或密码错误");
            }
            
            log.info("用户登录成功: username={}, role={}, id={}", 
                user.getUsername(), user.getRole(), user.getId());
            
            String role = user.getRole() == null ? "user" : user.getRole();
            String token = JwtUtil.generateToken(user.getId(), user.getUsername(), role);
            
            Map<String, Object> payload = new java.util.HashMap<>();
            payload.put("token", token);
            payload.put("user", user);
            
            log.info("生成JWT Token成功: token={}", token.substring(0, Math.min(token.length(), 20)) + "...");
            return Result.ok(payload);
            
        } catch (Exception e) {
            log.error("登录异常: username={}", loginRequest.getUsername(), e);
            return Result.error("登录失败：" + e.getMessage());
        }
    }

//    @PostMapping("/recognize")
//    public ResponseEntity<String> recognize(@RequestParam("file") MultipartFile file) {
//        File tempFile = null;
//        try {
//            tempFile = File.createTempFile("audio_", ".pcm");
//            file.transferTo(tempFile);
//
//            IatModelZhMain iat = new IatModelZhMain(tempFile);
//            String result = iat.startRecognition();
//
//            return ResponseEntity.ok(result);
//        } catch (Exception e) {
//            e.printStackTrace();
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("{\"error\":\"识别失败\"}");
//        } finally {
//            if (tempFile != null && tempFile.exists()) {
//                tempFile.delete();
//            }
//        }
//    }


    @Autowired
    private VoiceChatService voiceChatService;

    @GetMapping("/start-voice-chat")
    public String startVoiceChat(@RequestParam("message") String message) {
        new Thread(() -> {
            try {
                voiceChatService.handleSingleVoiceChat(1001L, message);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }).start();
        return "🎤 单轮语音对话已开始（新线程）";
    }


    @PostMapping("/recognize")
    public String recognizeFromClient(@RequestParam("file") MultipartFile file,
                                      @RequestParam(value = "memoryId", required = false) Long memoryId) {
        try {
            // 将 MultipartFile 转为 InputStream 后，送入科大讯飞实时语音识别接口
            InputStream inputStream = file.getInputStream();

            String text = rtasrService.recognizeFromInputStream(inputStream); // 改造这个方法
            Flux<String> reply = xiaozhiAgent.chat2(memoryId != null ? memoryId : 1001L, text);

            StringBuilder fullReply = new StringBuilder();
            reply.toStream().forEach(fullReply::append);

            byte[] audioBytes = ttsService.synthesizeToBytes(fullReply.toString());
            audioWebSocketHandler.sendAudioToClients(audioBytes);

            return "✅ 完成识别 + 回复 + 合成";
        } catch (Exception e) {
            e.printStackTrace();
            return "❌ 处理失败：" + e.getMessage();
        }
    }


}
