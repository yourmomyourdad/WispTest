@echo off
setlocal

title Scramjet Browser Launcher

echo ==========================================
echo       SCRAMJET + CLOUDFLARE LAUNCHER
echo ==========================================
echo.

REM ------------------------------------------
REM Configuration
REM ------------------------------------------

set "PORT=8081"
set "SCRAMJET_DIR=%~dp0Scramjet-App"
set "CF_LOG=%TEMP%\scramjet-cloudflare.log"

REM ------------------------------------------
REM Check Node.js
REM ------------------------------------------

where node >nul 2>&1
if errorlevel 1 (
    echo Node.js is not installed.
    echo Please install Node.js first.
    pause
    exit /b 1
)

REM ------------------------------------------
REM Check Scramjet
REM ------------------------------------------

if not exist "%SCRAMJET_DIR%\package.json" (
    echo ERROR: Scramjet-App was not found.
    echo Expected:
    echo %SCRAMJET_DIR%
    pause
    exit /b 1
)

REM ------------------------------------------
REM Install dependencies
REM ------------------------------------------

echo Installing Scramjet dependencies...
cd /d "%SCRAMJET_DIR%"
call npm install

if errorlevel 1 (
    echo.
    echo ERROR: npm install failed.
    pause
    exit /b 1
)

REM ------------------------------------------
REM Start Scramjet
REM ------------------------------------------

echo.
echo Starting Scramjet on port %PORT%...

set "PORT=%PORT%"

start "" /b cmd /c "cd /d ""%SCRAMJET_DIR%"" && npm start"

REM ------------------------------------------
REM Wait for Scramjet
REM ------------------------------------------

echo Waiting for Scramjet...

:WAIT_SCRAMJET

powershell -NoProfile -Command ^
"try { ^
    $r = Invoke-WebRequest -UseBasicParsing http://127.0.0.1:%PORT%/ -TimeoutSec 2; ^
    if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 500) { exit 0 } else { exit 1 } ^
} catch { exit 1 }"

if not errorlevel 1 goto SCRAMJET_READY

timeout /t 1 /nobreak >nul
goto WAIT_SCRAMJET


:SCRAMJET_READY

echo Scramjet is ready!
echo.

REM ------------------------------------------
REM Start Cloudflare
REM ------------------------------------------

echo Starting Cloudflare tunnel...

del "%CF_LOG%" >nul 2>&1

start "" /b cmd /c "cloudflared tunnel --protocol http2 --url http://127.0.0.1:%PORT% > ""%CF_LOG%"" 2>&1"

REM ------------------------------------------
REM Wait for Cloudflare URL
REM ------------------------------------------

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
