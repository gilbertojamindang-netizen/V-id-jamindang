@echo off
title ANTI-IDLE GUARD
echo Anti-Idle is running. Do not close this window.
:loop
:: Gumagalaw yung mouse pataas-baba ng 1 pixel para hindi ma-detect na idle
powershell -Command "$p = [System.Windows.Forms.Cursor]::Position; [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($p.X+1, $p.Y+1); [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($p.X, $p.Y)"
:: Pumipindot ng Caps Lock / Scroll Lock para hindi mag-sleep
powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.SendKeys('{SCROLLLOCK}'); $wsh.SendKeys('{SCROLLLOCK}')"
:: Hintay ng 60 seconds bago ulitin
timeout /t 60 /nobreak >nul
goto loop