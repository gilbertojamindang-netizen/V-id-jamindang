#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   NEW LOCAL USER CREATOR" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# --- INPUTS ---
$Username = Read-Host "Enter new username"
if ([string]::IsNullOrWhiteSpace($Username)) {
    Write-Host "[!] Username cannot be empty." -ForegroundColor Red
    exit 1
}

$Password = Read-Host "Enter password" -AsSecureString
$Confirm  = Read-Host "Confirm password" -AsSecureString

$p1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
$p2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Confirm))

if ($p1 -ne $p2) {
    Write-Host "[!] Passwords do not match." -ForegroundColor Red
    exit 1
}

$MakeAdmin = Read-Host "Add to Administrators? (Y/N)"
$HideLogin = Read-Host "Hide from login screen? (Y/N)"

# --- CREATE USER ---
Write-Host ""
Write-Host "[1] Creating user '$Username'..." -ForegroundColor Yellow

$existing = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "    user already exists — updating password instead." -ForegroundColor DarkYellow
    Set-LocalUser -Name $Username -Password $Password
} else {
    New-LocalUser -Name $Username -Password $Password `
        -FullName $Username -Description "Local account" -PasswordNeverExpires | Out-Null
    Write-Host "    created." -ForegroundColor Green
}

# --- GROUP MEMBERSHIP ---
if ($MakeAdmin -match '^[Yy]') {
    Write-Host "[2] Adding to Administrators..." -ForegroundColor Yellow
    Add-LocalGroupMember -Group "Administrators" -Member $Username -ErrorAction SilentlyContinue
    Write-Host "    done." -ForegroundColor Green
} else {
    Write-Host "[2] Adding to Users (standard)..." -ForegroundColor Yellow
    Add-LocalGroupMember -Group "Users" -Member $Username -ErrorAction SilentlyContinue
}

# --- HIDE FROM LOGIN ---
if ($HideLogin -match '^[Yy]') {
    Write-Host "[3] Hiding from login screen..." -ForegroundColor Yellow
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
    New-ItemProperty -Path $regPath -Name $Username -Value 0 -PropertyType DWord -Force | Out-Null
    Write-Host "    hidden (still available via 'Other user')." -ForegroundColor Green
}

# --- VERIFY ---
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   USER CREATED" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
$u = Get-LocalUser -Name $Username
$groups = (Get-LocalGroup | Where-Object { (Get-LocalGroupMember -Group $_.Name -ErrorAction SilentlyContinue).Name -match "\\$Username$" } | Select-Object -ExpandProperty Name) -join ", "
Write-Host " Username : $Username"  -ForegroundColor White
Write-Host " Enabled  : $($u.Enabled)" -ForegroundColor White
Write-Host " Groups   : $groups"   -ForegroundColor White
Write-Host " Hidden   : $(if ($HideLogin -match '^[Yy]') {'YES'} else {'NO'})" -ForegroundColor White
Write-Host ""
Write-Host "Undo commands:" -ForegroundColor DarkGray
Write-Host "  Remove-LocalUser -Name '$Username'" -ForegroundColor DarkGray
Write-Host "  Remove-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList' -Name '$Username'" -ForegroundColor DarkGray
Write-Host ""
pause