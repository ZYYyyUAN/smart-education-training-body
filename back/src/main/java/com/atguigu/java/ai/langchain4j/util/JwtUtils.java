//package com.atguigu.java.ai.langchain4j.util;
//
//import io.jsonwebtoken.*;
//import java.util.Date;
//
//public class JwtUtils {
//    private static final String SECRET_KEY = "MySuperSecretKey12345"; // 可自定义
//    private static final long EXPIRATION = 86400000L; // 1天（毫秒）
//
//    // 生成 Token
//    public static String generateToken(String userId) {
//        return Jwts.builder()
//                .setSubject(userId)
//                .setIssuedAt(new Date())
//                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION))
//                .signWith(SignatureAlgorithm.HS256, SECRET_KEY)
//                .compact();
//    }
//
//    // 解析 Token
//    public static Claims parseToken(String token) {
//        return Jwts.parser()
//                .setSigningKey(SECRET_KEY)
//                .parseClaimsJws(token)
//                .getBody();
//    }
//
//    // 是否过期
//    public static boolean isTokenExpired(String token) {
//        return parseToken(token).getExpiration().before(new Date());
//    }
//}
