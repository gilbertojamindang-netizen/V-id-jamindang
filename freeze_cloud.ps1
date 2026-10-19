#Requires -RunAsAdministrator
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class VFreeze {
 [DllImport("ntdll.dll")] public static extern uint NtSuspendProcess(IntPtr h);
 [DllImport("ntdll.dll")] public static extern uint NtResumeProcess(IntPtr h);
}
"@

# Palitan mo ito ng exact process name ng cloud PC na gamit mo
# e.g., "uuyc", "GameViewer", "Shadow", "GFN"
$TargetName = "uuyc" 

$proc = Get-Process -Name $TargetName -ErrorAction SilentlyContinue
if ($proc) {
    [VFreeze]::NtSuspendProcess($proc.Handle)
    Write-Host "[!] $TargetName FROZEN. Timer paused." -ForegroundColor Yellow
    Write-Host "Press any key to UNFREEZE and resume..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    [VFreeze]::NtResumeProcess($proc.Handle)
    Write-Host "`n[+] $TargetName RESUMED." -ForegroundColor Green
} else {
    Write-Host "[-] $TargetName not found. Check if app is running." -ForegroundColor Red
}