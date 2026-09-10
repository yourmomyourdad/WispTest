@echo off
setlocal
title Wisp Server Installer

echo ==============================
echo       Wisp Server Installer
echo ==============================
echo.

REM ==========================================
REM Check WinGet
REM ==========================================

where winget >nul 2>&1

if errorlevel 1 (
    echo ERROR: WinGet is not installed.
    echo.
    pause
    exit /b 1
)

REM ==========================================
REM Install Node.js if needed
REM ==========================================

echo Checking Node.js...
echo.

if exist "C:\Program Files\nodejs\node.exe" (
    echo Node.js is already installed.
) else (
    echo Installing Node.js LTS...
    winget install --id OpenJS.NodeJS.LTS --exact ^
        --accept-source-agreements ^
        --accept-package-agreements
)

REM ==========================================
REM Install cloudflared if needed
REM ==========================================

echo.
echo Checking cloudflared...
echo.

if exist "C:\Program Files (x86)\cloudflared\cloudflared.exe" (
    echo cloudflared is already installed.
) else (
    echo Installing cloudflared...
    winget install --id Cloudflare.cloudflared --exact ^
        --accept-source-agreements ^
        --accept-package-agreements
)

REM ==========================================
REM Refresh PATH for this script
REM ==========================================

echo.
echo Refreshing PATH...
echo.

set "PATH=C:\Program Files\nodejs;C:\Program Files (x86)\cloudflared;%PATH%"

REM ==========================================
REM Verify Node
REM ==========================================

echo.
echo Checking Node.js...
echo.

if not exist "C:\Program Files\nodejs\node.exe" (
    echo ERROR: Node.js could not be found.
    echo.
    pause
    exit /b 1
)

node --version
npm --version

REM ==========================================
REM Verify cloudflared
REM ==========================================

echo.
echo Checking cloudflared...
echo.

if not exist "C:\Program Files (x86)\cloudflared\cloudflared.exe" (
    echo ERROR: cloudflared could not be found.
    echo.
    pause
    exit /b 1
)

cloudflared --version

REM ==========================================
REM Install Wisp dependencies
REM ==========================================

echo.
echo ==============================
echo Installing Wisp dependencies
echo ==============================
echo.

call npm install

if errorlevel 1 (
    echo.
    echo ERROR: npm install failed.
    echo.
    pause
    exit /b 1
)

REM ==========================================
REM Finished
REM ==========================================

echo.
echo ==============================
echo   Installation Complete! :D
echo ==============================
echo.
echo Node.js:    OK
echo cloudflared: OK
echo Wisp:       OK
echo.
echo Double-click start-wisp.bat to start Wisp.
echo.

pause
endlocal
