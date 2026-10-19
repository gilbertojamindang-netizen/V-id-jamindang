@echo off
:: Kopyahin yung cmd.exe sa temp tapos palitan pangalan
copy "C:\Windows\System32\cmd.exe" "%TEMP%\svchost.exe" /y >nul 2>&1
:: I-run yung watchdog via disguised exe (need mo palitan yung path)
start "" /min "%TEMP%\svchost.exe" /c "C:\path\to\your\watchdog.bat"