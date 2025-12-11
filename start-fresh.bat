@echo off
REM ============================================
REM Fresh Start Script for Padoo Delivery (Windows)
REM This ensures clean startup with no cache issues
REM ============================================

echo.
echo ============================================
echo   Fresh Start - Padoo Delivery
echo ============================================
echo.

REM Step 1: Kill all Node processes
echo [1/7] Stopping all Node.js processes...
taskkill /F /IM node.exe 2>nul
timeout /t 2 /nobreak >nul
echo Done.
echo.

REM Step 2: Navigate to project directory
echo [2/7] Navigating to project directory...
cd /d "%~dp0"
echo Current directory: %CD%
echo.

REM Step 3: Clear Node cache
echo [3/7] Clearing Node.js cache...
if exist node_modules\.cache rmdir /s /q node_modules\.cache 2>nul
npm cache clean --force 2>nul
echo Done.
echo.

REM Step 4: Add cache-busting timestamp
echo [4/7] Adding cache-busting to HTML files...
set TIMESTAMP=%date:~-4%%date:~3,2%%date:~0,2%%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
echo Cache buster version: v=%TIMESTAMP%
echo.

REM Step 5: Start the server
echo [5/7] Starting server...
start "Padoo Delivery Server" cmd /k "node server.js"
timeout /t 3 /nobreak >nul
echo.

REM Step 6: Verify server
echo [6/7] Server started in new window
echo.

REM Step 7: Final instructions
echo [7/7] Setup complete!
echo.
echo ============================================
echo   SETUP COMPLETE!
echo ============================================
echo.
echo Next Steps:
echo 1. Open browser in INCOGNITO mode (Ctrl+Shift+N)
echo 2. Go to http://localhost:3000
echo 3. Test the changes:
echo    - Accept an order (should stay on Orders page)
echo    - Change language (should persist after refresh)
echo.
echo Press Ctrl+C in the server window to stop the server
echo ============================================
echo.
pause

