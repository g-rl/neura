@echo off

:: Auto-elevate to admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

setlocal

:: Get the directory this script lives in (the custom_scripts folder)
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: Ask for IW8 mod directory
set /p "IW8_DIR=Enter IW8 mod directory (iw8-mod): "
set "IW8_DIR=%IW8_DIR:"=%"

:: Ask for S4 mod directory
set /p "S4_DIR=Enter S4 mod directory (s4-mod): "
set "S4_DIR=%S4_DIR:"=%"

cls

:: Create symlinks directly inside the provided paths
mklink /D "%IW8_DIR%\custom_scripts" "%SCRIPT_DIR%"
mklink /D "%S4_DIR%\custom_scripts" "%SCRIPT_DIR%"

echo.
color 2
echo Done!
pause