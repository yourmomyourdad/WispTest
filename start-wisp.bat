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
    echo Run install.bat first.
    pause
    exit /b 1
)

if not exist "C:\Program Files\nodejs\node.exe" (
    echo ERROR: Node.js is not installed.
    pause
    exit /b 1
)

if not exist "C:\Program Files (x86)\cloudflared\cloudflared.exe" (
    echo ERROR: cloudflared is not installed.
    pause
    exit /b 1
)

cd /d "%~dp0Scramjet-App"

echo Starting Scramjet...
echo.

start "Scramjet" cmd /k "cd /d ""%~dp0Scramjet-App"" && npm start"

echo Waiting for Scramjet...

:WAIT
timeout /t 1 /nobreak >nul
curl -s http://127.0.0.1:8080/ >nul 2>&1

if errorlevel 1 goto WAIT

echo.
echo Scramjet is running!
echo.
echo ==========================================
echo        CLOUDFLARE PUBLIC URL
echo ==========================================
echo.

cloudflared.exe tunnel --url http://127.0.0.1:8080 2>&1 | powershell -NoProfile -Command ^
    "$input | ForEach-Object { ^
        Write-Host $_; ^
        if ($_ -match 'https://[a-zA-Z0-9-]+\.trycloudflare\.com') { ^
            Write-Host ''; ^
            Write-Host '========================================='; ^
            Write-Host '        SCRAMJET PUBLIC ADDRESS'; ^
            Write-Host '========================================='; ^
            Write-Host $Matches[0]; ^
            Write-Host '========================================='; ^
            Write-Host '' ^
        } ^
    }"

pause
