#Requires -RunAsAdministrator
Write-Host "Spoofing Hardware IDs for Trial Reset..." -ForegroundColor Cyan

# 1. Spoof MAC Address
$adapters = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}
foreach ($adapter in $adapters) {
    $newMac = "02" + ((1..5 | ForEach-Object { "{0:X2}" -f (Get-Random -Minimum 0 -Maximum 255) }) -join "")
    Set-NetAdapter -Name $adapter.Name -MacAddress $newMac -Confirm:$false >$null 2>&1
    Write-Host "MAC Spoofed: $($adapter.Name) -> $newMac"
}

# 2. Clear Cloud PC registry caches
Remove-Item "HKCU:\Software\NetEase" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "HKCU:\Software\NVIDIA Corporation" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "HKCU:\Software\Shadow" -Recurse -Force -ErrorAction SilentlyContinue

# 3. Clear Machine GUID
$newGuid = [guid]::NewGuid().ToString()
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography" -Name "MachineGuid" -Value $newGuid
Write-Host "Machine GUID reset to: $newGuid" -ForegroundColor Green