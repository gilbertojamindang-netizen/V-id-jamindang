@echo off
setlocal enabledelayedexpansion
title VM Artifact Cleaner
echo ==========================================
echo   VM Cleanup - killing VMware artifacts
echo ==========================================
echo.

:: --- Stop + disable services ---
for %%S in ("VMTools" "VMware Tools" "vmware-usbarbitrator64" "VMnetDHCP" "VMware NAT Service" "VMware Authorization Service" "VMware Hostd") do (
    sc query %%~S >nul 2>&1
    if !errorlevel! equ 0 (
        echo [svc] stopping %%~S
        net stop %%~S /y >nul 2>&1
        sc config %%~S start= disabled >nul 2>&1
        echo [svc] disabled %%~S
    )
)
echo.

:: --- Kill processes ---
for %%P in (vmtoolsd.exe vmware-tray.exe vmware-authd.exe vmware-usbarbitrator64.exe vmware-hostd.exe vmnetdhcp.exe vmnetnatd.exe vmware-cmd.exe vmware-vdiskmanager.exe) do (
    taskkill /f /im %%P >nul 2>&1
    if !errorlevel! equ 0 (
        echo [proc] killed %%P
    )
)
echo.

:: --- Scrub registry ---
echo [reg] removing VMware keys...
reg delete "HKLM\SOFTWARE\VMware, Inc." /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\VMTools" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\vmware-usbarbitrator64" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\VMnetDHCP" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\VMware NAT Service" /f >nul 2>&1
echo [reg] done.
echo.

:: --- Verify ---
echo ==========================================
echo   Remaining VMware processes:
echo ==========================================
tasklist /fi "imagename eq vmtoolsd.exe" 2>nul | find /i "vmtoolsd" >nul && (
    echo [!] vmtoolsd STILL running
) || (
    echo [ok] vmtoolsd gone
)
tasklist /fi "imagename eq vmware-tray.exe" 2>nul | find /i "vmware-tray" >nul && (
    echo [!] vmware-tray STILL running
) || (
    echo [ok] vmware-tray gone
)

echo.
echo Done. Reboot para sure na wala nang leftover.
pause