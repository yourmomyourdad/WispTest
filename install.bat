@echo off
title Wisp Server Setup

echo ==============================
echo       Wisp Server Setup
echo ==============================
echo.
echo Installing dependencies...
echo.

npm install

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Installation failed.
    echo Make sure Node.js is installed.
    echo.
    pause
    exit /b 1
)

echo.
echo ==============================
echo Installation complete! :D
echo ==============================
echo.
echo You can now run start-wisp.bat
echo.

pause
