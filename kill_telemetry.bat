@echo off
title TELEMETRY KILLER
echo Killing Windows Telemetry & Cloud Spying Services...

:: Windows Telemetry
sc stop DiagTrack >nul 2>&1
sc config DiagTrack start= disabled >nul 2>&1
sc stop dmwappushservice >nul 2>&1
sc config dmwappushservice start= disabled >nul 2>&1

:: Cloud/VM specific tools
sc stop "vmicheartbeat" >nul 2>&1
sc stop "vmicvss" >nul 2>&1
sc stop "vmicshutdown" >nul 2>&1
sc stop "vmicexchange" >nul 2>&1

:: Block telemetry IPs (Basic)
netsh advfirewall firewall add rule name="Block MS Telemetry" dir=out action=block remoteip=13.89.179.0/24,13.89.179.10,13.89.179.11 >nul 2>&1

echo [+] Telemetry and Spying services killed.
pause