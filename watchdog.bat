@echo off
title WATCHDOG - Do not close
color 0C
echo ==========================================
echo      WATCHDOG ACTIVE - MONITORING
echo ==========================================
echo.
echo Killing VM processes and keeping them dead...

:: Loop forever
:loop
:: 1. Kill VM Tools
taskkill /f /im vmtoolsd.exe >nul 2>&1
taskkill /f /im vmware-tray.exe >nul 2>&1
taskkill /f /im vmware-authd.exe >nul 2>&1
taskkill /f /im vmware-usbarbitrator64.exe >nul 2>&1

:: 2. Kill any attempt to shut down
taskkill /f /im shutdown.exe >nul 2>&1
taskkill /f /im reboot.exe >nul 2>&1

:: 3. Suspend any RPC shutdown attempts (optional, via sc)
sc stop RpcSs >nul 2>&1

:: Wait 2 seconds before checking again
timeout /t 2 /nobreak >nul

:: Loop back
goto loop