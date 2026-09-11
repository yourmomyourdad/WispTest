@echo off
setlocal EnableDelayedExpansion
title Scramjet Browser Installer + Launcher

echo ==========================================
echo     SCRAMJET + CLOUDFLARE INSTALLER
echo ==========================================
echo.

REM ==========================================
REM Configuration
REM ==========================================

set "PORT=8081"
set "SCRAMJET_DIR=%~dp0Scramjet-App"
set "TEMP_DIR=%TEMP%\scramjet-installer"
set "CF_LOG=%TEMP%\scramjet-cloudflare.log"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

REM ==========================================
REM Check / Install Node.js
REM ==========================================

echo Checking Node.js...

where node >nul 2>&1

if errorlevel 1 (
    echo Node.js not found.
    echo Installing Node.js...

    winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements

    if errorlevel 1 (
        echo.
        echo ERROR: Node.js installation failed.
        pause
        exit /b 1
    )

    echo.
    echo Node.js installed!
    echo.

    REM Refresh PATH
    set "PATH=%PATH%;C:\Program Files\nodejs"
)

node --version
npm --version

echo.

REM ==========================================
REM Check / Install Cloudflared
REM ==========================================

echo Checking cloudflared...

where cloudflared >nul 2>&1

if errorlevel 1 (
    echo cloudflared not found.
    echo Installing cloudflared...

    winget install Cloudflare.cloudflared --accept-source-agreements --accept-package-agreements

    if errorlevel 1 (
        echo.
        echo ERROR: cloudflared installation failed.
        pause
        exit /b 1
    )

    echo.
    echo cloudflared installed!
    echo.

    REM Refresh PATH
    set "PATH=%PATH%;C:\Program Files\cloudflared"
)

cloudflared --version

echo.

REM ==========================================
REM Download Scramjet-App if missing
REM ==========================================

if exist "%SCRAMJET_DIR%\package.json" (
    echo Scramjet-App already exists.
    echo Skipping download.
    echo.
    goto INSTALL_DEPS
)

echo Scramjet-App not found.
echo Downloading official Scramjet-App...

set "ZIP=%TEMP_DIR%\Scramjet-App.zip"

powershell -NoProfile -Command ^
"$ProgressPreference='SilentlyContinue'; Invoke-WebRequest 'https://github.com/MercuryWorkshop/Scramjet-App/archive/refs/heads/main.zip' -OutFile '%ZIP%'"

if errorlevel 1 (
    echo.
    echo ERROR: Failed to download Scramjet-App.
    pause
    exit /b 1
)

echo Download complete!
echo Extracting...

powershell -NoProfile -Command ^
"Expand-Archive -Force '%ZIP%' '%TEMP_DIR%\extract'"

if errorlevel 1 (
    echo.
    echo ERROR: Failed to extract Scramjet-App.
    pause
    exit /b 1
)

REM GitHub creates Scramjet-App-main
move "%TEMP_DIR%\extract\Scramjet-App-main" "%SCRAMJET_DIR%" >nul

if not exist "%SCRAMJET_DIR%\package.json" (
    echo.
    echo ERROR: Scramjet-App extraction failed.
    pause
    exit /b 1
)

echo Scramjet-App downloaded!
echo.

REM ==========================================
REM Install Scramjet dependencies
REM ==========================================

:INSTALL_DEPS

echo ==========================================
echo Installing Scramjet dependencies
echo ==========================================
echo.

cd /d "%SCRAMJET_DIR%"

call npm install

if errorlevel 1 (
    echo.
    echo ERROR: npm install failed.
    pause
    exit /b 1
)

echo.
echo Dependencies installed!
echo.

REM ==========================================
REM Start Scramjet
REM ==========================================

echo ==========================================
echo Starting Scramjet
echo ==========================================
echo.

echo Using port %PORT%.

REM Make PORT available to Scramjet
set "PORT=%PORT%"

start "" /b cmd /c "cd /d ""%SCRAMJET_DIR%"" && set ""PORT=%PORT%"" && npm start"

REM ==========================================
REM Wait for Scramjet
REM ==========================================

echo Waiting for Scramjet...

:WAIT_SCRAMJET

powershell -NoProfile -Command ^
"try { ^
    $r=Invoke-WebRequest -UseBasicParsing 'http://127.0.0.1:%PORT%/' -TimeoutSec 2; ^
    if($r.StatusCode -ge 200 -and $r.StatusCode -lt 500){exit 0}else{exit 1} ^
} catch {exit 1}"

if not errorlevel 1 goto SCRAMJET_READY

timeout /t 1 /nobreak >nul
goto WAIT_SCRAMJET


:SCRAMJET_READY

echo Scramjet is ready!
echo.

REM ==========================================
REM Start Cloudflare Tunnel
REM ==========================================

echo ==========================================
echo Starting Cloudflare tunnel
echo ==========================================
echo.

del "%CF_LOG%" >nul 2>&1

start "" /b cmd /c "cloudflared tunnel --protocol http2 --url http://127.0.0.1:%PORT% > ""%CF_LOG%"" 2>&1"

REM ==========================================
REM Wait for Cloudflare URL
REM ==========================================

echo Waiting for Cloudflare URL...

set "URL="

:WAIT_CLOUDFLARE

for /f "delims=" %%A in ('powershell -NoProfile -Command "$x=Get-Content -Raw -ErrorAction SilentlyContinue '%CF_LOG%'; if($x -match 'https://[a-zA-Z0-9-]+\.trycloudflare\.com'){ $Matches[0] }"') do (
    set "URL=%%A"
)

if defined URL goto DONE

timeout /t 1 /nobreak >nul
goto WAIT_CLOUDFLARE


:DONE

cls

echo ==========================================
echo                  DONE! :D
echo ==========================================
echo.
echo Here's your URL:
echo.
echo %URL%
echo.
echo Keep this window open!
echo.

pause
