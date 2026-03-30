@echo off

:: Auto-elevate to admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

setlocal

:: The custom_scripts folder sits next to this script
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "SOURCE=%SCRIPT_DIR%\custom_scripts"

:: Ask for IW8 mod directory
set /p "IW8_DIR=Enter IW8 mod directory (iw8-mod): "
set "IW8_DIR=%IW8_DIR:"=%"

:: Ask for S4 mod directory
set /p "S4_DIR=Enter S4 mod directory (s4-mod): "
set "S4_DIR=%S4_DIR:"=%"

:: Ask for IW9 mod directory
set "IW9_DIR="
set /p "IW9_DIR=Enter IW9 mod directory (optional, press Enter to skip): "
set "IW9_DIR=%IW9_DIR:"=%"

:: Create symlinks
mklink /D "%IW8_DIR%\custom_scripts" "%SOURCE%"
mklink /D "%S4_DIR%\custom_scripts" "%SOURCE%"
if defined IW9_DIR (
    mklink /D "%IW9_DIR%\custom_scripts" "%SOURCE%"
)

echo.
echo Done!
pause