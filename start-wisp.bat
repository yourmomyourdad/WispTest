@echo off
setlocal EnableDelayedExpansion

title Scramjet Browser

set "PORT=8081"
set "BASE=%~dp0"
set "SCRAMJET=%BASE%Scramjet-App"
set "ZIP=%BASE%scramjet.zip"

echo ==========================================
echo          SCRAMJET BROWSER
echo ==========================================
echo.

echo Checking Node.js...

where node >nul 2>&1
if errorlevel 1 (
    echo Node.js not found.
    echo Installing Node.js...
    winget install --id OpenJS.NodeJS.LTS --exact --accept-source-agreements --accept-package-agreements

    if errorlevel 1 (
        echo.
        echo ERROR: Node.js installation failed.
        pause
        exit /b 1
    )

    echo Node.js installed!
    echo.
)

node --version
npm --version
echo.

echo Checking cloudflared...

where cloudflared >nul 2>&1
if errorlevel 1 (
    echo cloudflared not found.
    echo Installing cloudflared...
    winget install --id Cloudflare.cloudflared --exact --accept-source-agreements --accept-package-agreements

    if errorlevel 1 (
        echo.
        echo ERROR: cloudflared installation failed.
        pause
        exit /b 1
    )

    echo cloudflared installed!
    echo.
)

cloudflared --version
echo.

echo Checking Scramjet-App...

if not exist "%SCRAMJET%\package.json" (
    echo Scramjet-App not found.
    echo Downloading Scramjet-App...
    echo.

    powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest 'https://github.com/MercuryWorkshop/Scramjet-App/archive/refs/heads/main.zip' -OutFile '%ZIP%'"

    if errorlevel 1 (
        echo.
        echo ERROR: Failed to download Scramjet-App.
        pause
        exit /b 1
    )

    echo Download complete.
    echo Extracting...

    powershell -NoProfile -Command "Expand-Archive -Path '%ZIP%' -DestinationPath '%BASE%' -Force"

    if errorlevel 1 (
        echo.
        echo ERROR: Failed to extract Scramjet-App.
        pause
        exit /b 1
    )

    if exist "%BASE%Scramjet-App-main" (
        rename "%BASE%Scramjet-App-main" "Scramjet-App"
    )

    del "%ZIP%" >nul 2>&1

    echo Scramjet-App downloaded!
) else (
    echo Scramjet-App already exists.
)

echo.

echo ==========================================
echo       INSTALLING DEPENDENCIES
echo ==========================================
echo.

cd /d "%SCRAMJET%"

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

echo ==========================================
echo          STARTING SCRAMJET
echo ==========================================
echo.

echo Starting Scramjet on port %PORT%...

start "" /b cmd /c "set PORT=%PORT%&&cd /d ""%SCRAMJET%""&&npm start"

echo Waiting for Scramjet...

:WAIT_SCRAMJET

powershell -NoProfile -Command "try { $r=Invoke-WebRequest -UseBasicParsing 'http://127.0.0.1:%PORT%/' -TimeoutSec 2; if($r.StatusCode -ge 200 -and $r.StatusCode -lt 500){exit 0}else{exit 1} } catch {exit 1}"

if not errorlevel 1 goto SCRAMJET_READY

timeout /t 1 /nobreak >nul
goto WAIT_SCRAMJET

:SCRAMJET_READY

echo.
echo Scramjet is ready!
echo.

echo ==========================================
echo        STARTING CLOUDFLARE TUNNEL
echo ==========================================
echo.

cloudflared tunnel --protocol http2 --url http://127.0.0.1:%PORT%

echo.
echo Cloudflare tunnel stopped.
echo.
pause
