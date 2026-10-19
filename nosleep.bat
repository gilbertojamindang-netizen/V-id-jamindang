@echo off
echo Disabling sleep and hibernate...
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0
powercfg /hibernate off
echo.
echo [OK] Cloud PC will never sleep.
pause