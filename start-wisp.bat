@echo off
setlocal EnableDelayedExpansion
setlocal

title Scramjet Browser
set "PORT=8081"
@@ -13,6 +13,7 @@ echo ==========================================
echo.

echo Checking Node.js...

if not exist "C:\Program Files\nodejs\node.exe" (
    echo Installing Node.js...
    winget install --id OpenJS.NodeJS.LTS --exact --accept-source-agreements --accept-package-agreements
@@ -25,6 +26,7 @@ node --version
echo.

echo Checking cloudflared...

if not exist "C:\Program Files (x86)\cloudflared\cloudflared.exe" (
    echo Installing cloudflared...
    winget install --id Cloudflare.cloudflared --exact --accept-source-agreements --accept-package-agreements
@@ -36,7 +38,6 @@ echo cloudflared:
cloudflared --version
echo.

REM Download Scramjet if necessary
if not exist "Scramjet-App\package.json" (
    echo Downloading Scramjet-App...

@@ -49,15 +50,11 @@ if not exist "Scramjet-App\package.json" (
    rename "Scramjet-App-main" "Scramjet-App"

    del "scramjet.zip"

    echo Scramjet-App downloaded!
    echo.
) else (
    echo Scramjet-App already exists.
    echo.
)

REM Install dependencies
echo Scramjet-App ready.
echo.

cd /d "%~dp0Scramjet-App"

echo Installing dependencies...
@@ -71,20 +68,24 @@ if errorlevel 1 (
)

echo.
echo Dependencies ready!
echo Dependencies ready.
echo.

REM Start Scramjet
echo Starting Scramjet...
start "" cmd /c "npm start"

REM Give it time to start
timeout /t 8 /nobreak >nul
start "" /b npm start

timeout /t 5 /nobreak >nul

REM Start Cloudflare
echo.
echo Starting Cloudflare tunnel...
echo.
echo ==========================================
echo        YOUR PUBLIC URL WILL APPEAR
echo              BELOW THIS LINE
echo ==========================================
echo.

cloudflared.exe tunnel --url http://127.0.0.1:8081 > "%TEMP%\scramjet-cloudflare.log" 2>&1
cloudflared.exe tunnel --url http://127.0.0.1:8081

pause
