@echo off
setlocal

title Scramjet Browser

cd /d "%~dp0"

set "PATH=C:\Program Files\nodejs;C:\Program Files (x86)\cloudflared;%PATH%"

echo ==========================================
echo              SCRAMJET BROWSER
echo ==========================================
echo.

echo Checking Node.js...

if not exist "C:\Program Files\nodejs\node.exe" (
    echo Installing Node.js...
    winget install --id OpenJS.NodeJS.LTS --exact --accept-source-agreements --accept-package-agreements
)

set "PATH=C:\Program Files\nodejs;%PATH%"

echo Node.js:
node --version
echo.

echo Checking cloudflared...

if not exist "C:\Program Files (x86)\cloudflared\cloudflared.exe" (
    echo Installing cloudflared...
    winget install --id Cloudflare.cloudflared --exact --accept-source-agreements --accept-package-agreements
)

set "PATH=C:\Program Files (x86)\cloudflared;%PATH%"

echo cloudflared:
cloudflared --version
echo.

if not exist "Scramjet-App\package.json" (
    echo Downloading Scramjet-App...

    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://github.com/MercuryWorkshop/Scramjet-App/archive/refs/heads/main.zip' -OutFile 'scramjet.zip'"

    powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path 'scramjet.zip' -DestinationPath '.' -Force"

    if exist "Scramjet-App" rmdir /s /q "Scramjet-App"

    rename "Scramjet-App-main" "Scramjet-App"

    del "scramjet.zip"
)

echo Scramjet-App ready.
echo.

cd /d "%~dp0Scramjet-App"

echo Installing dependencies...
call npm install

if errorlevel 1 (
    echo.
    echo ERROR: npm install failed.
    pause
    exit /b 1
)

echo.
echo Dependencies ready.
echo.

echo Starting Scramjet...

start "" /b npm start

timeout /t 5 /nobreak >nul

echo.
echo Starting Cloudflare tunnel...
echo.
echo ==========================================
echo        YOUR PUBLIC URL WILL APPEAR
echo              BELOW THIS LINE
echo ==========================================
echo.

cloudflared.exe tunnel --url http://127.0.0.1:8080

pause
