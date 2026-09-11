@echo off
setlocal EnableDelayedExpansion

title Scramjet Browser

cd /d "%~dp0"

echo ==========================================
echo          SCRAMJET BROWSER
echo ==========================================
echo.

REM ==========================================
REM Node.js
REM ==========================================

echo Checking Node.js...

if not exist "C:\Program Files\nodejs\node.exe" (
    echo Node.js not found.
    echo Installing Node.js LTS...
    echo.

    winget install --id OpenJS.NodeJS.LTS --exact ^
        --accept-source-agreements ^
        --accept-package-agreements

    if errorlevel 1 (
        echo.
        echo ERROR: Node.js installation failed.
        pause
        exit /b 1
    )
)

set "PATH=C:\Program Files\nodejs;%PATH%"

echo Node.js:
node --version
echo.

REM ==========================================
REM cloudflared
REM ==========================================

echo Checking cloudflared...

if not exist "C:\Program Files (x86)\cloudflared\cloudflared.exe" (
    echo cloudflared not found.
    echo Installing cloudflared...
    echo.

    winget install --id Cloudflare.cloudflared --exact ^
        --accept-source-agreements ^
        --accept-package-agreements

    if errorlevel 1 (
        echo.
        echo ERROR: cloudflared installation failed.
        pause
        exit /b 1
    )
)

set "PATH=C:\Program Files (x86)\cloudflared;%PATH%"

echo cloudflared:
cloudflared --version
echo.

REM ==========================================
REM Download Scramjet-App
REM ==========================================

if not exist "Scramjet-App\package.json" (

    echo ==========================================
    echo Downloading Scramjet-App...
    echo ==========================================
    echo.

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Invoke-WebRequest -Uri 'https://github.com/MercuryWorkshop/Scramjet-App/archive/refs/heads/main.zip' -OutFile 'scramjet.zip'"

    if errorlevel 1 (
        echo.
        echo ERROR: Failed to download Scramjet-App.
        pause
        exit /b 1
    )

    echo Extracting...

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Expand-Archive -Path 'scramjet.zip' -DestinationPath '.' -Force"

    if errorlevel 1 (
        echo.
        echo ERROR: Failed to extract Scramjet-App.
        pause
        exit /b 1
    )

    if exist "Scramjet-App" (
        rmdir /s /q "Scramjet-App"
    )

    rename "Scramjet-App-main" "Scramjet-App"

    del "scramjet.zip"

    echo Scramjet-App downloaded!
    echo.
) else (
    echo Scramjet-App already exists.
    echo.
)

REM ==========================================
REM Install dependencies
REM ==========================================

cd /d "%~dp0Scramjet-App"

echo ==========================================
echo Installing dependencies...
echo ==========================================
echo.

call npm install

if errorlevel 1 (
    echo.
    echo ERROR: npm install failed.
    pause
    exit /b 1
)

echo.
echo Dependencies ready!
echo.

REM ==========================================
REM Start Scramjet
REM ==========================================

echo ==========================================
echo Starting Scramjet...
echo ==========================================
echo.

start "" /b cmd /c "npm start > "%TEMP%\scramjet.log" 2>&1"

echo Waiting for Scramjet...

:WAIT_SCRAMJET

timeout /t 1 /nobreak >nul

curl -s http://127.0.0.1:8080/ >nul 2>&1

if errorlevel 1 goto WAIT_SCRAMJET

echo Scramjet is ready!
echo.

REM ==========================================
REM Start Cloudflare
REM ==========================================

echo ==========================================
echo Starting Cloudflare tunnel...
echo ==========================================
echo.

start "" /b cmd /c "cloudflared.exe tunnel --url http://127.0.0.1:8080 > "%TEMP%\scramjet-cloudflare.log" 2>&1"

echo Waiting for public URL...

:WAIT_URL

timeout /t 1 /nobreak >nul

set "URL="

for /f "delims=" %%A in ('powershell -NoProfile -Command "$x=Get-Content -Raw $env:TEMP\scramjet-cloudflare.log; if($x -match 'https://[a-zA-Z0-9-]+\.trycloudflare\.com'){$Matches[0]}"') do (
    set "URL=%%A"
)

if not defined URL goto WAIT_URL

REM ==========================================
REM DONE
REM ==========================================

cls

echo.
echo ==========================================
echo                 DONE! :D
echo ==========================================
echo.
echo Here's your URL:
echo.
echo     !URL!
echo.
echo ==========================================
echo.
echo Your Scramjet browser is running!
echo.
echo Keep this window open.
echo.

pause
