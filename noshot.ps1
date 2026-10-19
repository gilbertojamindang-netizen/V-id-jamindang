Add-Type @"
using System;
using System.Runtime.InteropServices;
public class AntiCapture {
    [DllImport("user32.dll")]
    public static extern uint SetWindowDisplayAffinity(IntPtr hWnd, uint dwAffinity);
}
"@

# 0x11 = WDA_EXCLUDEFROMCAPTURE (Hindi lalabas sa screenshots at screen recordings)
$Affinity = 0x11 

# Hahanapin lahat ng nakabukas na window para itago
Get-Process | Where-Object {$_.MainWindowHandle -ne 0} | ForEach-Object {
    [AntiCapture]::SetWindowDisplayAffinity($_.MainWindowHandle, $Affinity)
}
Write-Host "[+] Screenshots blocked. Magiging itim ang screen pag kinunan." -ForegroundColor Green