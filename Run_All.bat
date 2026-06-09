@echo off
cd /d "%~dp0"
setlocal enabledelayedexpansion

title JogjaSplorasi - Local Backend + Chrome

REM ============================================================
REM  JogjaSplorasi - One Click Runner
REM  Mode: Backend lokal + Flutter Web Chrome
REM  Letakkan file ini sejajar dengan pubspec.yaml
REM ============================================================

set "PROJECT_ROOT=%~dp0"
set "BACKEND_DIR=%PROJECT_ROOT%backend"
set "BACKEND_PORT=3000"
set "FLUTTER_WEB_PORT=5173"
set "BACKEND_BASE_URL=http://localhost:%BACKEND_PORT%/api"

echo ============================================================
echo   JogjaSplorasi - Local Backend + Flutter Chrome Runner
echo ============================================================
echo.
echo Project root : %PROJECT_ROOT%
echo Backend dir  : %BACKEND_DIR%
echo Backend URL  : %BACKEND_BASE_URL%
echo Flutter port : %FLUTTER_WEB_PORT%
if "%CURRENCY_KEY%"=="" (
    echo Kurs API     : ExchangeRate-API open access
) else (
    echo Kurs API     : ExchangeRate-API keyed endpoint
)
echo.

if not exist "%PROJECT_ROOT%pubspec.yaml" (
    echo [ERROR] pubspec.yaml tidak ditemukan.
    echo File BAT ini harus berada di root project Flutter.
    pause
    exit /b 1
)

if not exist "%BACKEND_DIR%\package.json" (
    echo [ERROR] backend\package.json tidak ditemukan.
    pause
    exit /b 1
)

where flutter >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Flutter tidak ditemukan di PATH.
    pause
    exit /b 1
)

where node >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Node.js tidak ditemukan di PATH.
    pause
    exit /b 1
)

where npm >nul 2>nul
if errorlevel 1 (
    echo [ERROR] npm tidak ditemukan di PATH.
    pause
    exit /b 1
)

echo [OK] Flutter, Node.js, dan npm ditemukan.
echo.

echo [1/6] Menyiapkan backend .env...

if not exist "%BACKEND_DIR%\.env" (
    echo Membuat backend\.env default development...
    (
        echo NODE_ENV=development
        echo PORT=%BACKEND_PORT%
        echo DATABASE_URL=postgresql://postgres:postgres@localhost:5432/jogjasplorasi?schema=public
        echo JWT_SECRET=local_dev_secret_change_this_32_chars_minimum
        echo JWT_EXPIRES_IN=7d
        echo CORS_ORIGIN=http://localhost:%FLUTTER_WEB_PORT%
        echo GEMINI_API_KEY=
    ) > "%BACKEND_DIR%\.env"
    echo [OK] backend\.env dibuat.
) else (
    echo [OK] backend\.env sudah ada, dilewati.
)

echo.

echo [2/6] Mengecek dependency backend...

if not exist "%BACKEND_DIR%\node_modules" (
    echo backend\node_modules belum ada. Menjalankan npm install...
    pushd "%BACKEND_DIR%"
    call npm install
    if errorlevel 1 (
        popd
        echo [ERROR] npm install backend gagal.
        pause
        exit /b 1
    )
    popd
    echo [OK] Dependency backend terinstall.
) else (
    echo [OK] backend\node_modules sudah ada, npm install dilewati.
)

echo.

echo [3/6] Menyiapkan Prisma Client...

pushd "%BACKEND_DIR%"
call npx prisma generate
if errorlevel 1 (
    echo [WARNING] npx prisma generate gagal.
) else (
    echo [OK] Prisma Client siap.
)

echo.
echo Mencoba sinkronisasi schema database development...
echo Jika PostgreSQL lokal belum menyala, bagian ini boleh gagal.
call npx prisma db push
if errorlevel 1 (
    echo [WARNING] prisma db push gagal.
    echo Pastikan PostgreSQL lokal aktif dan database "jogjasplorasi" tersedia.
) else (
    echo [OK] Database schema sudah disinkronkan.
)
popd

echo.

echo [4/6] Mengecek backend lokal di port %BACKEND_PORT%...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "try { $r = Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost:%BACKEND_PORT%/health' -TimeoutSec 3; exit 0 } catch { exit 1 }" >nul 2>nul

if errorlevel 1 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "$listener = Get-NetTCPConnection -LocalPort %BACKEND_PORT% -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1; if ($listener) { Write-Host $listener.OwningProcess; exit 0 } exit 1" > "%TEMP%\jogjasplorasi_backend_pid.txt" 2>nul

    if errorlevel 1 (
        echo Backend belum aktif. Menjalankan backend lokal di window baru...
        start "JogjaSplorasi Backend" cmd /k "cd /d "%BACKEND_DIR%" && npm run dev"

        echo Menunggu backend start...
        timeout /t 6 /nobreak >nul
    ) else (
        set /p BACKEND_BUSY_PID=<"%TEMP%\jogjasplorasi_backend_pid.txt"
        echo [WARNING] Port %BACKEND_PORT% sudah dipakai oleh PID !BACKEND_BUSY_PID!, tapi health backend tidak terdeteksi.
        echo Tutup proses/window lama tersebut atau ubah BACKEND_PORT jika API aplikasi tidak berjalan.
    )
) else (
    echo [OK] Backend sudah aktif, dipakai ulang.
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "try { $r = Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost:%BACKEND_PORT%/health' -TimeoutSec 3; exit 0 } catch { exit 1 }" >nul 2>nul

if errorlevel 1 (
    echo [WARNING] Backend belum terdeteksi di port %BACKEND_PORT%.
    echo Jika window backend masih loading, Flutter tetap akan dijalankan.
) else (
    echo [OK] Backend terdeteksi.
)

echo.

echo [5/6] Menyiapkan dependency Flutter...

echo Mencoba flutter pub get --offline terlebih dahulu...
call flutter pub get --offline
if errorlevel 1 (
    echo [WARNING] flutter pub get --offline gagal.
    echo Mencoba flutter pub get online...
    call flutter pub get
    if errorlevel 1 (
        echo [ERROR] flutter pub get gagal.
        echo Kemungkinan koneksi ke pub.dev bermasalah atau package belum ada di cache.
        pause
        exit /b 1
    )
)

echo [OK] Dependency Flutter siap.
echo.

echo [6/6] Menjalankan Flutter Web di Chrome...
echo.

call flutter run -d chrome ^
  --web-hostname=localhost ^
  --web-port=%FLUTTER_WEB_PORT% ^
  --dart-define=BACKEND_BASE_URL=%BACKEND_BASE_URL% ^
  --dart-define=CURRENCY_KEY=%CURRENCY_KEY% ^
  --dart-define=JOGJA_REAL_GLASS=false ^
  --dart-define=JOGJA_SENSOR_GESTURES=true

echo.
echo Flutter sudah berhenti.
echo Backend masih berjalan di window "JogjaSplorasi Backend".
echo Tutup window backend tersebut untuk menghentikan server.
echo.
pause
endlocal
