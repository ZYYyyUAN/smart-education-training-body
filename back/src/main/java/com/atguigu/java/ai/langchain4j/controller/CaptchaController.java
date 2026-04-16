package com.atguigu.java.ai.langchain4j.controller;

import com.atguigu.java.ai.langchain4j.service.CaptchaService;
import com.google.code.kaptcha.Producer;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.UUID;

@RestController
@RequestMapping("/captcha")
public class CaptchaController {
    @Autowired
    private Producer kaptchaProducer;
    @Autowired
    private CaptchaService captchaService;

    @GetMapping(value = "/image", produces = "image/png")
    public void image(HttpServletResponse response) throws IOException {
        String text = kaptchaProducer.createText();
        BufferedImage image = kaptchaProducer.createImage(text);
        String key = "CAPTCHA-" + UUID.randomUUID();
        captchaService.storeCaptcha(key, text);
        Cookie c = new Cookie("CAPTCHA_KEY", key);
        c.setPath("/");
        c.setHttpOnly(false);
        c.setMaxAge(300);
        response.addCookie(c);
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        ImageIO.write(image, "png", response.getOutputStream());
    }
}
