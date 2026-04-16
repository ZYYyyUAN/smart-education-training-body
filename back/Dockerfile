# 使用完整的JDK镜像
FROM openjdk:17

# 设置工作目录
WORKDIR /app

# 复制JAR文件
COPY java-ai-langchain4j-1.0-SNAPSHOT.jar app.jar

# 暴露端口
EXPOSE 8080

# 设置环境变量
ENV SPRING_PROFILES_ACTIVE=prod

# 启动应用
CMD ["java", "-jar", "app.jar"]
