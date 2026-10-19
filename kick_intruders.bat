@echo off
title ANTI-SPY / KICK INTRUDERS
color 0C
echo ==========================================
echo       KICKING UNAUTHORIZED VIEWERS
echo ==========================================
echo.

:: 1. KILL COMMON REMOTE ACCESS TOOLS
echo [1] Killing remote monitoring tools...
taskkill /f /im TeamViewer.exe >nul 2>&1
taskkill /f /im AnyDesk.exe >nul 2>&1
taskkill /f /im RustDesk.exe >nul 2>&1
taskkill /f /im vncserver.exe >nul 2>&1
taskkill /f /im winvnc.exe >nul 2>&1
taskkill /f /im mstsc.exe >nul 2>&1
taskkill /f /im AeroAdmin.exe >nul 2>&1
taskkill /f /im Supremo.exe >nul 2>&1
echo     Remote tools killed.

:: 2. LOG OFF OTHER ACTIVE USERS (Kung may naka-RDP sayo)
echo [2] Logging off other sessions...
:: I-save muna current session ID mo
for /f "tokens=3" %%a in ('query session %USERNAME% ^| findstr /i "Active"') do set "MY_ID=%%a"
:: I-log off lahat ng ibang active session
for /f "skip=1 tokens=1,2" %%i in ('query session ^| findstr /i "Active"') do (
    if not "%%i"=="%MY_ID%" (
        echo     Kicking out session ID: %%i
        logoff %%i >nul 2>&1
    )
)

:: 3. DISABLE RDP (Remote Desktop)
echo [3] Disabling Windows RDP...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f >nul 2>&1
sc config TermService start= disabled >nul 2>&1
netsh advfirewall firewall add rule name="Block RDP Inbound" dir=in action=block protocol=TCP localport=3389 >nul 2>&1
echo     RDP disabled & port 3389 blocked.

:: 4. DISABLE ADMIN SHARES (Para hindi ka mabuksan ng ibang PC sa network)
echo [4] Blocking Admin Shares (C$, ADMIN$)...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v AutoShareWks /t REG_DWORD /d 0 /f >nul 2>&1
net share C$ /delete >nul 2>&1
net share ADMIN$ /delete >nul 2>&1
echo     Admin shares hidden.

:: 5. BLOCK PC FROM BEING PINGED (Stealth Mode sa Network)
echo [5] Blocking ICMP (Ping)...
netsh advfirewall firewall add rule name="Block ICMP Ping" protocol=icmpv4:8,any dir=in action=block >nul 2>&1
echo     PC is now invisible to ping sweeps.

echo.
echo ==========================================
echo     DONE. IKAW NA LANG ANG MAY ACCESS.
echo ==========================================
pause