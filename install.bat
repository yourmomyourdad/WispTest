@echo off
setlocal
title Wisp Server Installer

echo ==============================
echo       Wisp Server Installer
echo ==============================
echo.

REM ==========================================
REM Check for WinGet
REM ==========================================

where winget >nul 2>&1

if %errorlevel% neq 0 (
    echo ERROR: WinGet is not installed.
    echo.
    echo Please install "App Installer" from Microsoft.
    echo Then run this installer again.
    echo.
    pause
    exit /b 1
)

REM ==========================================
REM Install Node.js
REM ==========================================

echo Installing Node.js LTS...
echo.

winget install --id OpenJS.NodeJS.LTS --exact ^
    --accept-source-agreements ^
    --accept-package-agreements

if %errorlevel% neq 0 (
    echo.
    echo Node.js installation returned an error.
    echo.
)

REM ==========================================
REM Install cloudflared
REM ==========================================

echo.
echo Installing Cloudflare Tunnel...
echo.

winget install --id Cloudflare.cloudflared --exact ^
    --accept-source-agreements ^
    --accept-package-agreements

if %errorlevel% neq 0 (
    echo.
    echo cloudflared installation returned an error.
    echo.
)

REM ==========================================
REM Refresh PATH
REM ==========================================

echo.
echo Refreshing environment variables...
echo.

for /f "tokens=2*" %%A in (
    'reg query "HKCU\Environment" /v Path 2^>nul'
) do set "USERPATH=%%B"

for /f "tokens=2*" %%A in (
    'reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul'
) do set "SYSTEMPATH=%%B"

set "PATH=%USERPATH%;%SYSTEMPATH%"

REM ==========================================
REM Check Node
REM ==========================================

echo.
echo Checking Node.js...
echo.

where node >nul 2>&1

if %errorlevel% neq 0 (
    echo ERROR: Node.js was installed but could not be found.
    echo.
    echo Please restart Windows and run this installer again.
    echo.
    pause
    exit /b 1
)

node --version
npm --version

REM ==========================================
REM Check cloudflared
REM ==========================================

echo.
echo Checking cloudflared...
echo.

where cloudflared >nul 2>&1

if %errorlevel% neq 0 (
    echo ERROR: cloudflared was installed but could not be found.
    echo.
    echo Please restart Windows and run this installer again.
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

if %errorlevel% neq 0 (
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
echo       Installation Complete!
echo ==============================
echo.
echo Everything is installed.
echo.
echo Double-click start-wisp.bat to start
echo the Wisp server and Cloudflare tunnel.
echo.

pause
endlocal
