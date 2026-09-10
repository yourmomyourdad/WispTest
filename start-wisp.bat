@echo off
setlocal
title Wisp Server + Cloudflare Tunnel

echo ==============================
echo       Starting Wisp...
echo ==============================
echo.

start "Wisp Server" cmd /k "npm start"

timeout /t 3 /nobreak >nul

echo ==============================
echo   Starting Cloudflare Tunnel
echo ==============================
echo.
echo Waiting for Cloudflare URL...
echo.

cloudflared tunnel --url http://localhost:5001 2>&1 | powershell -Command "$input | ForEach-Object { if ($_ -match 'https://[a-zA-Z0-9-]+\.trycloudflare\.com') { Write-Host ''; Write-Host '================================'; Write-Host '       WISP PUBLIC URL'; Write-Host '================================'; Write-Host $Matches[0]; Write-Host ''; Write-Host 'WSS URL:'; Write-Host ($Matches[0] -replace '^https://','wss://'); Write-Host '================================'; } else { Write-Host $_ } }"

pause
