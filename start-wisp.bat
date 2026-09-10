@echo off
setlocal EnableDelayedExpansion

title Scramjet Browser

cd /d "%~dp0"

set "PATH=C:\Program Files\nodejs;C:\Program Files (x86)\cloudflared;%PATH%"

echo Starting Scramjet...
echo.

if not exist "Scramjet-App\package.json" (
    echo ERROR: Scramjet-App is not installed.
    echo Run install.bat first.
    pause
    exit /b 1
)

cd /d "%~dp0Scramjet-App"

start /b "" npm start > "%TEMP%\scramjet.log" 2>&1

echo Waiting for Scramjet...

:WAIT
timeout /t 1 /nobreak >nul
curl -s http://127.0.0.1:8080/ >nul 2>&1

if errorlevel 1 goto WAIT

echo Scramjet started!
echo.
echo Starting Cloudflare...

start /b "" cloudflared.exe tunnel --url http://127.0.0.1:8080 > "%TEMP%\cloudflare.log" 2>&1

echo Waiting for public URL...

:URLWAIT
timeout /t 1 /nobreak >nul

set "URL="

for /f "tokens=*" %%A in ('findstr /r /c:"https://[a-zA-Z0-9-]*\.trycloudflare\.com" "%TEMP%\cloudflare.log"') do (
    set "LINE=%%A"
)

for /f "tokens=*" %%A in ('powershell -NoProfile -Command "$x = Get-Content '%TEMP%\cloudflare.log' -Raw; if ($x -match 'https://[a-zA-Z0-9-]+\.trycloudflare\.com') { $Matches[0] }"') do (
    set "URL=%%A"
)

if not defined URL goto URLWAIT

cls

echo.
echo ==========================================
echo                 DONE! :D
echo ==========================================
echo.
echo Here's your URL:
echo.
echo    !URL!
echo.
echo ==========================================
echo.
echo Keep this window open!
echo.
echo Your Scramjet browser is ready.
echo.

pause
