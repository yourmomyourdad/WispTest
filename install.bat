@echo off
setlocal
title Scramjet + Wisp Installer

cd /d "%~dp0"

echo ==========================================
echo      Scramjet + Wisp Installer
echo ==========================================
echo.

REM ------------------------------------------
REM Check Node.js
REM ------------------------------------------

if not exist "C:\Program Files\nodejs\node.exe" (
    echo ERROR: Node.js is not installed.
    echo Please install Node.js LTS first.
    echo.
    pause
    exit /b 1
)

set "PATH=C:\Program Files\nodejs;%PATH%"

echo Node.js:
node --version
echo.

REM ------------------------------------------
REM Check cloudflared
REM ------------------------------------------

if not exist "C:\Program Files (x86)\cloudflared\cloudflared.exe" (
    echo Installing cloudflared...

    winget install --id Cloudflare.cloudflared --exact ^
        --accept-source-agreements ^
        --accept-package-agreements

    if errorlevel 1 (
        echo ERROR: cloudflared installation failed.
        pause
        exit /b 1
    )
)

set "PATH=C:\Program Files (x86)\cloudflared;%PATH%"

echo cloudflared:
cloudflared --version
echo.

REM ------------------------------------------
REM Download Scramjet-App
REM ------------------------------------------

if exist "Scramjet-App\package.json" (
    echo Scramjet-App already exists.
    echo Skipping download.
    echo.
) else (

    echo Downloading Scramjet-App...
    echo.

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Invoke-WebRequest -Uri 'https://github.com/MercuryWorkshop/Scramjet-App/archive/refs/heads/main.zip' -OutFile 'scramjet.zip'"

    if errorlevel 1 (
        echo ERROR: Failed to download Scramjet-App.
        pause
        exit /b 1
    )

    echo Extracting Scramjet-App...

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Expand-Archive -Path 'scramjet.zip' -DestinationPath '.' -Force"

    if errorlevel 1 (
        echo ERROR: Failed to extract Scramjet-App.
        pause
        exit /b 1
    )

    if exist "Scramjet-App" rmdir /s /q "Scramjet-App"

    rename "Scramjet-App-main" "Scramjet-App"

    del "scramjet.zip"

    echo Scramjet-App downloaded!
    echo.
)

REM ------------------------------------------
REM Install Scramjet dependencies
REM ------------------------------------------

cd /d "%~dp0Scramjet-App"

echo ==========================================
echo Installing Scramjet dependencies
echo ==========================================
echo.

call npm install

if errorlevel 1 (
    echo.
    echo ERROR: npm install failed.
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Installation Complete! :D
echo ==========================================
echo.
echo Scramjet-App is ready.
echo.
echo Double-click start-wisp.bat to launch it.
echo.

pause
