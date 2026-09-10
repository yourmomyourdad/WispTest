@echo off
title Wisp Server

echo ==============================
echo       Starting Wisp...
echo ==============================
echo.
echo Local Wisp address:
echo ws://localhost:5001/
echo.
echo If another device is connecting on the same network,
echo use the PC's local IP instead of localhost.
echo.

npm start

echo.
echo Wisp has stopped.
pause
