@echo off
echo 正在启动Spring Boot应用...
echo.

REM 检查Maven是否安装
mvn -version >nul 2>&1
if errorlevel 1 (
    echo 错误: Maven未安装或未配置到PATH环境变量
    echo 请先安装Maven并配置环境变量
    pause
    exit /b 1
)

echo Maven版本检查通过
echo.

REM 清理并编译项目
echo 正在清理和编译项目...
call mvn clean compile
if errorlevel 1 (
    echo 编译失败，请检查项目配置
    pause
    exit /b 1
)

echo 编译成功
echo.

REM 启动Spring Boot应用
echo 正在启动Spring Boot应用...
echo 应用将在 http://localhost:8080 启动
echo 按 Ctrl+C 停止应用
echo.

call mvn spring-boot:run

pause

