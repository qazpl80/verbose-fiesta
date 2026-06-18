@echo off
setlocal EnableDelayedExpansion
title File Copier — Watcher

:: ================================================================
::  WATCHER SCRIPT
::  Polls for a target program. When it starts running,
::  FileCopier.bat is triggered automatically.
::  Runs FileCopier once per launch (not continuously while open).
::
::  HOW TO USE:
::    1. Set TARGET_PROCESS below to the program's .exe name
::    2. Run this script (or let Setup.bat launch it on startup)
::    3. Leave it minimized in the background — press Ctrl+C to stop
:: ================================================================

:: ----------------------------------------------------------------
::  CONFIGURATION
:: ----------------------------------------------------------------

:: The .exe name of the program to watch for (case-insensitive)
:: Examples: chrome.exe  notepad.exe  code.exe  steam.exe
set "TARGET_PROCESS=notepad.exe"

:: How often to check if the program is running (seconds)
set "CHECK_INTERVAL=5"

:: ----------------------------------------------------------------
::  END OF CONFIGURATION
:: ----------------------------------------------------------------

:: Resolve path to FileCopier.bat (same folder as this script)
set "SCRIPT_DIR=%~dp0"
set "COPIER=%SCRIPT_DIR%FileCopier.bat"

if not exist "%COPIER%" (
    echo  [ERROR] FileCopier.bat not found at: %COPIER%
    echo  Make sure both scripts are in the same folder.
    pause
    exit /b 1
)

echo.
echo  ================================================
echo   File Copier — Watcher Mode
echo  ================================================
echo   Watching for : %TARGET_PROCESS%
echo   Poll interval: every %CHECK_INTERVAL% seconds
echo   Press Ctrl+C to stop watching.
echo  ================================================
echo.

set "WAS_RUNNING=0"

:WatchLoop
    tasklist /FI "IMAGENAME eq %TARGET_PROCESS%" 2>nul | find /I "%TARGET_PROCESS%" >nul

    if %ERRORLEVEL%==0 (
        :: Process IS currently running
        if "%WAS_RUNNING%"=="0" (
            echo  [%TIME%] %TARGET_PROCESS% launched — starting File Copier...
            set "WAS_RUNNING=1"
            call "%COPIER%"
            echo  [%TIME%] File Copier finished. Watching for next launch...
        )
    ) else (
        :: Process is NOT running — reset so it fires again next launch
        if "%WAS_RUNNING%"=="1" (
            echo  [%TIME%] %TARGET_PROCESS% closed. Ready for next launch.
            set "WAS_RUNNING=0"
        )
    )

    timeout /T %CHECK_INTERVAL% /NOBREAK >nul
goto :WatchLoop
