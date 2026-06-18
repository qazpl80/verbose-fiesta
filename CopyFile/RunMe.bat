@echo off
setlocal
title File Copier — Setup

:: ================================================================
::  SETUP SCRIPT
::  Registers FileCopier.bat or Watcher.bat with Task Scheduler
::  so they run automatically.
::
::  MUST be run as Administrator.
:: ================================================================

:: Check for Administrator privileges
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  [ERROR] This script must be run as Administrator.
    echo.
    echo  Right-click Setup.bat and choose "Run as administrator".
    echo.
    pause
    exit /b 1
)

set "SCRIPT_DIR=%~dp0"
set "COPIER=%SCRIPT_DIR%FileCopier.bat"
set "WATCHER=%SCRIPT_DIR%Watcher.bat"

:MainMenu
cls
echo.
echo  ================================================
echo   File Copier — Setup
echo  ================================================
echo.
echo   [1]  Run FileCopier on every PC login (startup)
echo   [2]  Run Watcher on every PC login (program trigger)
echo   [3]  Run FileCopier ONCE right now (test it)
echo   [4]  Show currently registered tasks
echo   [5]  Remove all File Copier tasks
echo   [6]  Exit
echo.
set /p "CHOICE=  Select an option [1-6]: "

if "%CHOICE%"=="1" goto :SetupStartup
if "%CHOICE%"=="2" goto :SetupWatcher
if "%CHOICE%"=="3" goto :RunNow
if "%CHOICE%"=="4" goto :ShowTasks
if "%CHOICE%"=="5" goto :RemoveTasks
if "%CHOICE%"=="6" exit /b
goto :MainMenu


:: ----------------------------------------------------------------
:SetupStartup
:: Register FileCopier.bat to run at every user login
:: ----------------------------------------------------------------
echo.
if not exist "%COPIER%" (
    echo  [ERROR] FileCopier.bat not found in: %SCRIPT_DIR%
    pause
    goto :MainMenu
)

schtasks /create ^
    /tn "FileCopier_Startup" ^
    /tr "\"%COPIER%\"" ^
    /sc ONLOGON ^
    /rl HIGHEST ^
    /f >nul 2>&1

if %ERRORLEVEL%==0 (
    echo  [OK] Task created: FileCopier.bat will run on every login.
) else (
    echo  [ERROR] Could not create task ^(error %ERRORLEVEL%^).
)
pause
goto :MainMenu


:: ----------------------------------------------------------------
:SetupWatcher
:: Register Watcher.bat to run at every user login
:: ----------------------------------------------------------------
echo.
if not exist "%WATCHER%" (
    echo  [ERROR] Watcher.bat not found in: %SCRIPT_DIR%
    pause
    goto :MainMenu
)

echo  Before continuing, make sure you have set TARGET_PROCESS
echo  inside Watcher.bat to the program you want to watch for.
echo.
set /p "CONFIRM=  Continue? [Y/N]: "
if /i "%CONFIRM%" NEQ "Y" goto :MainMenu

schtasks /create ^
    /tn "FileCopier_Watcher" ^
    /tr "\"%WATCHER%\"" ^
    /sc ONLOGON ^
    /rl HIGHEST ^
    /f >nul 2>&1

if %ERRORLEVEL%==0 (
    echo.
    echo  [OK] Task created: Watcher.bat will run on every login.
    echo       It will monitor for your target program in the background.
) else (
    echo.
    echo  [ERROR] Could not create task ^(error %ERRORLEVEL%^).
)
pause
goto :MainMenu


:: ----------------------------------------------------------------
:RunNow
:: Run FileCopier immediately for testing
:: ----------------------------------------------------------------
echo.
echo  Running FileCopier.bat now...
echo.
call "%COPIER%"
goto :MainMenu


:: ----------------------------------------------------------------
:ShowTasks
:: Display any registered File Copier tasks
:: ----------------------------------------------------------------
echo.
echo  ---- Registered File Copier Tasks ----
echo.
schtasks /query /tn "FileCopier_Startup" 2>nul || echo  FileCopier_Startup : not registered
echo.
schtasks /query /tn "FileCopier_Watcher" 2>nul || echo  FileCopier_Watcher : not registered
echo.
pause
goto :MainMenu


:: ----------------------------------------------------------------
:RemoveTasks
:: Delete all registered File Copier tasks
:: ----------------------------------------------------------------
echo.
set "REMOVED=0"

schtasks /delete /tn "FileCopier_Startup" /f >nul 2>&1
if %ERRORLEVEL%==0 ( echo  [OK] Removed: FileCopier_Startup  & set /a REMOVED+=1 ) ^
else ( echo  [--] Not found: FileCopier_Startup )

schtasks /delete /tn "FileCopier_Watcher" /f >nul 2>&1
if %ERRORLEVEL%==0 ( echo  [OK] Removed: FileCopier_Watcher  & set /a REMOVED+=1 ) ^
else ( echo  [--] Not found: FileCopier_Watcher )

echo.
echo  Done. Removed %REMOVED% task(s).
pause
goto :MainMenu
