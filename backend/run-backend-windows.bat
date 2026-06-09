@echo off
setlocal
cd /d "%~dp0"
echo.
echo ========================================
echo JogjaSplorasi Backend Quick Start
echo ========================================
echo.
echo Perintah ini akan menjalankan:
echo 1. npm install
echo 2. prisma generate
echo 3. prisma db push
echo 4. seed data destinasi + 200 soal kuis
echo 5. backend dev server
echo.
call npm run dev:full
if errorlevel 1 goto error
exit /b 0

:error
echo.
echo Backend startup failed.
echo Pastikan PostgreSQL sudah aktif dan DATABASE_URL di backend\.env benar.
echo Jika memakai Docker, jalankan Docker Desktop terlebih dahulu.
exit /b 1
