@echo off
title BUAT USER + ADMIN
color 0a
echo ========================================
echo       BUAT USER + ADMIN
echo ========================================
echo.

set /p "user=Masukkan Username: "
set /p "pass=Masukkan Password: "

if "%user%"=="" (
    echo [!] Username kosong.
    pause
    exit /b
)

echo.
echo [+] Membuat user: %user%
net user "%user%" "%pass%" /add
if errorlevel 1 (
    echo [!] Gagal buat user. Mungkin sudah ada atau password invalid.
    goto done
)

echo [+] Menambahkan ke Administrator...
net localgroup Administrators "%user%" /add
if errorlevel 1 (
    echo [!] Gagal tambah admin. Pastikan CMD run as Administrator.
    goto done
)

echo [+] Password tidak pernah expired...
wmic useraccount where "name='%user%'" set PasswordExpires=false >nul 2>&1

echo.
echo ========================================
echo        USER BERHASIL DIBUAT
echo ========================================
echo Username : %user%
echo Password : %pass%
echo Admin    : YES
echo ========================================
echo.

:done
pause
endlocal