@echo off
setlocal EnableDelayedExpansion
title Scramjet Browser

cd /d "%~dp0"

set "PATH=C:\Program Files\nodejs;C:\Program Files (x86)\cloudflared;%PATH%"

echo ==========================================
echo          Starting Scramjet Browser
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

if not exist "C:\Program Files\nodejs\node.exe" (
    echo ERROR: Node.js is not installed.
    echo.
    pause
    exit /b 1
)

if not exist "C:\Program Files (x86)\cloudflared\cloudflared.exe" (
    echo ERROR: cloudflared is not installed.
    echo.
    pause
    exit /b 1
)

echo Starting Scramjet...
echo.

cd /d "%~dp0Scramjet-App"

start "Scramjet-App" cmd /k "cd /d ""%~dp0Scramjet-App"" && npm start"

echo Waiting for Scramjet to start...

:WAIT
timeout /t 1 /nobreak >nul

curl -s http://127.0.0.1:8080/ >nul 2>&1

if errorlevel 1 (
    goto WAIT
)

echo.
echo Scramjet is running!
echo.

echo ==========================================
echo       Starting Cloudflare Tunnel
echo ==========================================
echo.
echo Your public browser URL will appear below.
echo Keep this window open!
echo.

cloudflared.exe tunnel --url http://127.0.0.1:8080

pause
