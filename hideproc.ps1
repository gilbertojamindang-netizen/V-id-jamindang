# I-hide ang process sa Task Manager
$ProcessName = "notepad" # <--- Palitan mo ito ng process na gusto mong itago
$proc = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
if ($proc) {
    $code = @"
    using System;
    using System.Runtime.InteropServices;
    public class HideMe {
        [DllImport("kernel32.dll")] public static extern IntPtr OpenProcess(uint p, bool i, int pid);
        [DllImport("ntdll.dll")] public static extern uint NtSetInformationProcess(IntPtr h, int c, ref int i, int l);
    }
"@
    Add-Type $code
    $h = [HideMe]::OpenProcess(0x1F0FFF, $false, $proc.Id)
    $hide = 1
    [HideMe]::NtSetInformationProcess($h, 29, [ref]$hide, 4)
    Write-Host "[+] $ProcessName is now hidden from Task Manager." -ForegroundColor Yellow
}