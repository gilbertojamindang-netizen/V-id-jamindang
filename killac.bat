@echo off
:: EAC
sc stop "EasyAntiCheat" >nul 2>&1
sc config "EasyAntiCheat" start= disabled >nul 2>&1
taskkill /f /im EasyAntiCheat.exe >nul 2>&1
taskkill /f /im EasyAntiCheat_EOS.exe >nul 2>&1
:: BattlEye
sc stop "BEService" >nul 2>&1
sc config "BEService" start= disabled >nul 2>&1
taskkill /f /im BEService.exe >nul 2>&1
taskkill /f /im BEService_x64.exe >nul 2>&1
echo [OK] Anti-cheat services stopped.
pause