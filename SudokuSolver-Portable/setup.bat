@echo off
echo ========================================
echo   Sudoku Solver - Setup for New PC
echo ========================================
echo.

:: Check for Java
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Java is not installed!
    echo Please install JDK 11 or higher from: https://adoptium.net/
    echo.
    pause
    exit /b 1
)
echo [OK] Java found

:: Check for XAMPP/Tomcat
if exist "C:\xampp\tomcat\webapps" (
    set TOMCAT_DIR=C:\xampp\tomcat
    echo [OK] XAMPP Tomcat found
) else if exist "C:\apache-tomcat-9.0.89\webapps" (
    set TOMCAT_DIR=C:\apache-tomcat-9.0.89
    echo [OK] Tomcat found
) else (
    echo [INFO] Tomcat not found. Downloading...
    powershell -Command "Invoke-WebRequest 'https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89-windows-x64.zip' -OutFile '%TEMP%\tomcat.zip'"
    powershell -Command "Expand-Archive '%TEMP%\tomcat.zip' -DestinationPath 'C:\' -Force"
    del "%TEMP%\tomcat.zip"
    set TOMCAT_DIR=C:\apache-tomcat-9.0.89
    echo [OK] Tomcat installed
)

:: Stop Tomcat if running
call "%TOMCAT_DIR%\bin\shutdown.bat" 2>nul
timeout /t 3 /nobreak >nul

:: Deploy the app
echo [DEPLOY] Installing Sudoku Solver...
if exist "%TOMCAT_DIR%\webapps\sudoku" rmdir /s /q "%TOMCAT_DIR%\webapps\sudoku"
if exist "%TOMCAT_DIR%\webapps\sudoku.war" del /q "%TOMCAT_DIR%\webapps\sudoku.war"

:: Copy either the folder or WAR
if exist "sudoku-app" (
    xcopy /e /i /q "sudoku-app" "%TOMCAT_DIR%\webapps\sudoku"
    echo [OK] App folder deployed
) else if exist "sudoku.war" (
    copy /y "sudoku.war" "%TOMCAT_DIR%\webapps\sudoku.war"
    echo [OK] WAR file deployed
)

:: Start Tomcat
echo [START] Starting Tomcat...
call "%TOMCAT_DIR%\bin\startup.bat"

:: Wait and open browser
timeout /t 10 /nobreak >nul
start http://localhost:8080/sudoku

echo.
echo ========================================
echo   Sudoku Solver is running!
echo   URL: http://localhost:8080/sudoku
echo ========================================
echo.
echo To stop: "%TOMCAT_DIR%\bin\shutdown.bat"
echo.
pause