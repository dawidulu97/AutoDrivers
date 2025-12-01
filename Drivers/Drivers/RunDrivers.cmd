@echo off
:: Windows 11 Style Driver Installer
:: All files must be in Drivers subfolder
:: Created by Laptop Store IQ Developers

:: Configuration
SET "SCRIPT_DIR=%~dp0Drivers"
SET "FIRST_SCRIPT=%SCRIPT_DIR%\main_drivers.ps1"
SET "SECOND_SCRIPT=%SCRIPT_DIR%\autoinstall-intel.ps1"
SET "REPLACE_SCRIPT=%SCRIPT_DIR%\replaceDriver.ps1"
SET LOG_FOLDER=%TEMP%\DriverInstallerLogs

:: Create log folder with timestamp
SET "TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%"
SET "LOG1=%LOG_FOLDER%\DriverInstall1_%TIMESTAMP%.log"
SET "LOG2=%LOG_FOLDER%\DriverInstall2_%TIMESTAMP%.log"
SET "LOG3=%LOG_FOLDER%\DriverReplace_%TIMESTAMP%.log"

if not exist "%LOG_FOLDER%" mkdir "%LOG_FOLDER%"

:: Check if running as admin
NET FILE >NUL 2>&1
if %ERRORLEVEL% EQU 0 goto :IS_ADMIN

:: Windows 11 style elevation prompt
echo.
echo #######################################################
echo #
echo #   Laptop Store IQ - Driver Installation Center
echo #
echo #######################################################
echo.
echo This operation requires administrator privileges
echo.
powershell -Command "Start-Process cmd -ArgumentList '/c cd /d \"%~dp0\" && %~nx0' -Verb RunAs"
exit /b

:IS_ADMIN
:: Verify Drivers folder exists
if not exist "%SCRIPT_DIR%" (
    echo ERROR: Drivers folder not found at:
    echo %SCRIPT_DIR%
    pause
    exit /b 1
)

:: Phase 1: Main Driver Installation
if not exist "%FIRST_SCRIPT%" (
    echo ERROR: Main installer script not found:
    echo %FIRST_SCRIPT%
    pause
    exit /b 1
)

echo.
echo ====================================================
echo PHASE 1: MAIN DRIVER INSTALLATION
echo ====================================================
echo Log: %LOG1%
echo.

powershell -ExecutionPolicy Bypass -NoExit -WindowStyle Hidden -Command "Start-Transcript -Path '%LOG1%'; . '%FIRST_SCRIPT%'; Stop-Transcript"

:: Phase 2: Intel Components
if not exist "%SECOND_SCRIPT%" (
    echo WARNING: Intel installer script not found:
    echo %SECOND_SCRIPT%
    echo Skipping Intel components installation
    echo.
    goto :PHASE3
)

echo.
echo ====================================================
echo PHASE 2: INTEL COMPONENTS INSTALLATION
echo ====================================================
echo Log: %LOG2%
echo.

powershell -ExecutionPolicy Bypass -NoExit -WindowStyle Hidden -Command "Start-Transcript -Path '%LOG2%'; . '%SECOND_SCRIPT%'; Stop-Transcript"

:: Phase 3: Driver Replacement
:PHASE3
if not exist "%REPLACE_SCRIPT%" (
    echo WARNING: Driver replacement script not found:
    echo %REPLACE_SCRIPT%
    echo Skipping driver replacement
    echo.
    goto :DONE
)

echo.
echo ====================================================
echo PHASE 3: DRIVER REPLACEMENT
echo ====================================================
echo Log: %LOG3%
echo.

powershell -ExecutionPolicy Bypass -NoExit -WindowStyle Hidden -Command "Start-Transcript -Path '%LOG3%'; . '%REPLACE_SCRIPT%'; Stop-Transcript"

:DONE
echo.
echo ====================================================
echo INSTALLATION PROCESS COMPLETED
echo.
echo Laptop Store IQ Developers
echo ====================================================
echo.
echo Logs saved to: %LOG_FOLDER%
echo.
pause