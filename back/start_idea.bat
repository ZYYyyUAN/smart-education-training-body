@echo off
echo 正在为IDEA启动配置环境...
echo.

REM 设置Java环境变量
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.16.8-hotspot
echo Java环境已设置为: %JAVA_HOME%

REM 清理Maven缓存中的问题文件
echo 正在清理Maven缓存...
if exist "D:\apache-maven-3.9.5-bin\cangku\org\springframework\boot\spring-boot-websocket\4.0.0-M2" (
    rmdir /s /q "D:\apache-maven-3.9.5-bin\cangku\org\springframework\boot\spring-boot-websocket\4.0.0-M2"
    echo 已清理问题缓存文件
)

REM 清理并编译项目
echo 正在清理和编译项目...
call mvn clean compile
if errorlevel 1 (
    echo 编译失败，请检查项目配置
    pause
    exit /b 1
)

echo.
echo ========================================
echo 项目编译成功！
echo 现在您可以在IDEA中正常启动项目了
echo ========================================
echo.
echo 在IDEA中：
echo 1. 确保Project Structure中的JDK设置为Java 17
echo 2. 确保Maven设置正确
echo 3. 运行XiaozhiApp主类
echo.

pause 