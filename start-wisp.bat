@echo off
setlocal
title Wisp Server + Cloudflare Tunnel

echo ==============================
echo       Wisp Server
echo ==============================
echo.

REM Make sure we're running from this .bat's folder
cd /d "%~dp0"

REM Add Node.js and cloudflared to PATH
set "PATH=C:\Program Files\nodejs;C:\Program Files (x86)\cloudflared;%PATH%"

REM ==========================================
REM Check Node.js
REM ==========================================

if not exist "C:\Program Files\nodejs\node.exe" (
    echo ERROR: Node.js is not installed.
    echo Please run install.bat first.
    echo.
    pause
    exit /b 1
)

REM ==========================================
REM Check Wisp dependency
REM ==========================================

if not exist "node_modules\@mercuryworkshop\wisp-js" (
    echo Wisp dependency not found.
    echo Installing dependencies...
    echo.

    call npm install

    if errorlevel 1 (
        echo.
        echo ERROR: npm install failed.
        echo.
        pause
        exit /b 1
    )
)

echo Wisp dependency found!
echo.

REM ==========================================
REM Check cloudflared
REM ==========================================

if not exist "C:\Program Files (x86)\cloudflared\cloudflared.exe" (
    echo ERROR: cloudflared is not installed.
    echo Please run install.bat first.
    echo.
    pause
    exit /b 1
)

REM ==========================================
REM Start Wisp
REM ==========================================

echo Starting Wisp...
echo.

start "Wisp Server" cmd /k "cd /d ""%~dp0"" && npm start"

timeout /t 3 /nobreak >nul

REM ==========================================
REM Start Cloudflare Tunnel
REM ==========================================

echo ==============================
echo   Cloudflare Tunnel
echo ==============================
echo.
echo Starting tunnel...
echo Waiting for public URL...
echo.

cloudflared.exe tunnel --url http://localhost:5001 2>&1 | powershell -Command "$input | ForEach-Object { if ($_ -match 'https://[a-zA-Z0-9-]+\.trycloudflare\.com') { $url=$Matches[0]; Write-Host ''; Write-Host '========================================'; Write-Host '        WISP PUBLIC ADDRESS'; Write-Host '========================================'; Write-Host $url; Write-Host ''; Write-Host '        WSS ADDRESS'; Write-Host '========================================'; Write-Host ($url -replace '^https://','wss://'); Write-Host '========================================'; Write-Host ''; } else { Write-Host $_ } }"

pause
