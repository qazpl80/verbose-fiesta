@echo off
setlocal EnableDelayedExpansion
title File Copier

:: ================================================================
::  FILE COPIER SCRIPT
::  Edit the CONFIGURATION section below to set your copy jobs.
::  Each job can be a single file OR an entire folder.
:: ================================================================

:: ----------------------------------------------------------------
::  CONFIGURATION — Add/edit your copy jobs here
:: ----------------------------------------------------------------

:: Total number of copy jobs
set TOTAL_JOBS=3

:: --- Job 1: Single file example ---
::set "SOURCE[1]=C:\Users\YourName\Documents\report.docx"
::set "DEST[1]=D:\Backup\Documents\report.docx"

:: --- Job 2: Entire folder example ---
::set "SOURCE[2]=C:\Users\YourName\Projects\"
::set "DEST[2]=D:\Backup\Projects\"

:: --- Job 3: Another file example ---
::set "SOURCE[3]=C:\Users\YourName\Pictures\photo.jpg"
::set "DEST[3]=D:\Backup\Pictures\photo.jpg"

:: To add more jobs:
::   1. Increase TOTAL_JOBS by 1
::   2. Add a new set "SOURCE[N]=..." and set "DEST[N]=..." block

:: ----------------------------------------------------------------
::  END OF CONFIGURATION — Do not edit below this line
:: ----------------------------------------------------------------

set PASS=0
set FAIL=0
set SKIP=0

echo.
echo  ================================================
echo   File Copier — Running %TOTAL_JOBS% job(s)
echo  ================================================
echo.

for /L %%i in (1,1,%TOTAL_JOBS%) do (
    call :ProcessJob %%i "!SOURCE[%%i]!" "!DEST[%%i]!"
)

echo  ================================================
echo   Done  ^|  Copied: %PASS%   Skipped: %SKIP%   Failed: %FAIL%
echo  ================================================
echo.
pause
exit /b 0


:: ----------------------------------------------------------------
:ProcessJob  %1=job#  %2=source  %3=destination
:: ----------------------------------------------------------------
set "JOB_NUM=%~1"
set "SRC=%~2"
set "DST=%~3"

echo  [Job %JOB_NUM%] Source : %SRC%
echo  [Job %JOB_NUM%] Dest   : %DST%

:: Verify source exists
if not exist "%SRC%" (
    echo  [Job %JOB_NUM%] WARNING: Source not found — skipping.
    set /a SKIP+=1
    echo.
    exit /b
)

:: Route to folder or file handler
if exist "%SRC%\" (
    call :CopyFolder "%SRC%" "%DST%"
) else (
    call :CopyFile "%SRC%" "%DST%"
)
echo.
exit /b


:: ----------------------------------------------------------------
:CopyFile  %1=source file  %2=destination file
:: ----------------------------------------------------------------
set "SRC_F=%~1"
set "DST_F=%~2"

if exist "%DST_F%" (
    echo.
    set /p "YN=  [!] File already exists at destination. Overwrite? [Y/N]: "
    if /i "!YN!" NEQ "Y" (
        echo  [SKIPPED]
        set /a SKIP+=1
        exit /b
    )
)

:: Create destination directory if it doesn't exist
for %%P in ("%DST_F%") do (
    if not exist "%%~dpP" mkdir "%%~dpP" >nul 2>&1
)

copy /Y "%SRC_F%" "%DST_F%" >nul 2>&1
if %ERRORLEVEL%==0 (
    echo  [OK] File copied successfully.
    set /a PASS+=1
) else (
    echo  [ERROR] Failed to copy file. Check paths and permissions.
    set /a FAIL+=1
)
exit /b


:: ----------------------------------------------------------------
:CopyFolder  %1=source folder  %2=destination folder
:: ----------------------------------------------------------------
set "SRC_D=%~1"
set "DST_D=%~2"

if exist "%DST_D%" (
    echo.
    set /p "YN=  [!] Destination folder already exists. Overwrite contents? [Y/N]: "
    if /i "!YN!" NEQ "Y" (
        echo  [SKIPPED]
        set /a SKIP+=1
        exit /b
    )
)

:: /E  = copy all subdirectories including empty ones
:: /IS = include same files (overwrite)
:: /IT = include tweaked files
:: /NFL /NDL /NJH /NJS = suppress verbose output
robocopy "%SRC_D%" "%DST_D%" /E /IS /IT /NFL /NDL /NJH /NJS >nul 2>&1

:: Robocopy exit codes 0-7 are all success/informational
if %ERRORLEVEL% LEQ 7 (
    echo  [OK] Folder copied successfully.
    set /a PASS+=1
) else (
    echo  [ERROR] Folder copy failed (robocopy code: %ERRORLEVEL%).
    set /a FAIL+=1
)
exit /b
