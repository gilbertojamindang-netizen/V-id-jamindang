#Requires -RunAsAdministrator
$ErrorActionPreference = 'SilentlyContinue'

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   CLOUD/VM DETECTION BYPASS - STARTING" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. KILL & DISABLE VMWARE PROCESSES (Hardcore)
Write-Host "[1] Scrubbing VMware artifacts..." -ForegroundColor Yellow
$vmProcs = @('vmtoolsd','vmware-tray','vmware-authd','vmware-usbarbitrator64','vmware-hostd','vmnetdhcp','vmnetnatd','vmware-cmd','vmware-vdiskmanager')
foreach ($p in $vmProcs) { taskkill /f /im "$p.exe" >$null 2>&1 }
Stop-Service *vmware* -Force >$null 2>&1
Set-Service *vmware* -StartupType Disabled >$null 2>&1

# 2. SPOOF MAC ADDRESS (Registry Level)
Write-Host "[2] Spoofing MAC addresses..." -ForegroundColor Yellow
$adapters = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}
foreach ($adapter in $adapters) {
    # Random MAC (02:... para valid local MAC)
    $newMac = "02" + ((1..5 | ForEach-Object { "{0:X2}" -f (Get-Random -Minimum 0 -Maximum 255) }) -join "")
    Set-NetAdapter -Name $adapter.Name -MacAddress $newMac -Confirm:$false >$null 2>&1
    Write-Host "    Spoofed MAC on $($adapter.Name) to $newMac" -ForegroundColor Green
}

# 3. SPOOF WMI HARDWARE SERIALS (SMBIOS)
Write-Host "[3] Spoofing WMI Serials (BIOS/Baseboard)..." -ForegroundColor Yellow
$fakeSerial = "PF" + (Get-Random -Minimum 100000 -Maximum 999999)
$fakeModel = "Default string"
$fakeManuf = "System manufacturer"

# Ito yung ini-edit natin sa registry para hindi makita ng anti-cheat na VMware
$regPath = "HKLM:\HARDWARE\DESCRIPTION\System\BIOS"
if (Test-Path $regPath) {
    Set-ItemProperty -Path $regPath -Name "SystemManufacturer" -Value $fakeManuf -Type String
    Set-ItemProperty -Path $regPath -Name "SystemProductName" -Value $fakeModel -Type String
    Set-ItemProperty -Path $regPath -Name "BaseBoardManufacturer" -Value $fakeManuf -Type String
    Set-ItemProperty -Path $regPath -Name "BaseBoardProduct" -Value $fakeModel -Type String
    Set-ItemProperty -Path $regPath -Name "BaseBoardSerialNumber" -Value $fakeSerial -Type String
    Write-Host "    WMI Serials spoofed." -ForegroundColor Green
}

# 4. SPOOF DISK SERIALS
Write-Host "[4] Spoofing Disk Serials..." -ForegroundColor Yellow
$disks = Get-WmiObject Win32_DiskDrive
foreach ($disk in $disks) {
    $regDisk = "HKLM:\SYSTEM\CurrentControlSet\Enum\SCSI\$($disk.PNPDeviceID)"
    # Disk serial sa registry
    $diskPath = "HKLM:\SYSTEM\CurrentControlSet\Services\disk\Enum"
    if (Test-Path $diskPath) {
        Set-ItemProperty -Path $diskPath -Name "0" -Value "SCSI\Disk&Ven_VBOX&Prod_HARDDISK" -Type String >$null 2>&1
    }
}

# 5. CLEAN REGISTRY TRACES
Write-Host "[5] Wiping VM Registry keys..." -ForegroundColor Yellow
Remove-Item "HKLM:\SOFTWARE\VMware, Inc." -Recurse -Force >$null 2>&1
Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Services\VMTools" -Recurse -Force >$null 2>&1
Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Enum\IDE" -Recurse -Force >$null 2>&1
Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Enum\SCSI" -Recurse -Force >$null 2>&1
Remove-Item "HKLM:\HARDWARE\DEVICEMAP\Scsi" -Recurse -Force >$null 2>&1
Write-Host "    Registry clean." -ForegroundColor Green

# 6. CLEAN EVENT LOGS (Para walang bakas ng VM boot)
Write-Host "[6] Clearing Event Logs..." -ForegroundColor Yellow
wevtutil el | Foreach-Object { wevtutil cl "$_" >$null 2>&1 }
Write-Host "    Logs wiped." -ForegroundColor Green

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   DONE. REBOOT PARA MAG-TAKE EFFECT." -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
pause