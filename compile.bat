@echo off
REM =========================================================
REM Compile all Java files for Library Management System
REM Tomcat 10+ (Jakarta Servlet API) + MySQL Connector
REM =========================================================

REM Paths
set "SRC=src"
set "CLASSES=WebApp\WEB-INF\classes"
set "MYSQL_LIB=WebApp\WEB-INF\lib\mysql-connector-j-9.4.0.jar"
set "SERVLET_LIB=C:\Program Files\Apache Software Foundation\Tomcat 10.1\lib\jakarta.servlet-api-5.0.0.jar"

REM Create classes folder if it doesn't exist
if not exist "%CLASSES%" mkdir "%CLASSES%"

REM Find all .java files and save to sources.txt
dir /b /s "%SRC%\*.java" > sources.txt

REM Compile all Java files
javac -d "%CLASSES%" -cp "%MYSQL_LIB%;%SERVLET_LIB%" @sources.txt

REM Cleanup
del sources.txt

echo ========================================================
echo Compilation complete! All .class files are in %CLASSES%
echo ========================================================
pause
