@echo off
title PANIC BUTTON
color 0c
echo Wiping traces...

:: 1. Clear Windows Event Logs (System, Security, App)
wevtutil el | findstr /v "EventLog" > "%temp%\logs.txt"
for /f "delims=" %%a in (%temp%\logs.txt) do wevtutil cl "%%a" >nul 2>&1
del "%temp%\logs.txt" /f /q

:: 2. Clear Recent Docs & Run history
del /f /s /q "%APPDATA%\Microsoft\Windows\Recent\*.*" >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f >nul 2>&1

:: 3. Clear Temp folders
del /f /s /q "%TEMP%\*.*" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*.*" >nul 2>&1

:: 4. Self-destruct
echo Y | del "%~f0"
exit