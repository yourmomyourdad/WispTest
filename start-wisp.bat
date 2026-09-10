@echo off
setlocal
title Scramjet Browser

cd /d "%~dp0"

set "PATH=C:\Program Files\nodejs;C:\Program Files (x86)\cloudflared;%PATH%"

echo ==========================================
echo          Starting Scramjet
echo ==========================================
echo.

if not exist "Scramjet-App\package.json" (
    echo ERROR: Scramjet-App is not installed.
    echo.
    echo Run install.bat first.
    echo.
    pause
    exit /b 1
)

cd /d "%~dp0Scramjet-App"

echo Starting Scramjet-App...
echo.

start "Scramjet-App" cmd /k "cd /d ""%~dp0Scramjet-App"" && npm start"

echo Waiting for Scramjet to start...
timeout /t 5 /nobreak >nul

echo.
echo ==========================================
echo       Starting Cloudflare Tunnel
echo ==========================================
echo.

cloudflared.exe tunnel --url http://localhost:8080
