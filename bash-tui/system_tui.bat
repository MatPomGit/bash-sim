@echo off
REM Uruchamia wersję Bash TUI w środowisku Windows (Git Bash).
setlocal

set "SCRIPT_DIR=%~dp0"
set "BASH_EXE="

REM Preferowana ścieżka: Git for Windows.
if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH_EXE=%ProgramFiles%\Git\bin\bash.exe"
if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" set "BASH_EXE=%ProgramFiles(x86)%\Git\bin\bash.exe"

if "%BASH_EXE%"=="" (
    echo [BLAD] Nie znaleziono interpretera Bash z Git for Windows.
    echo Zainstaluj Git for Windows: https://git-scm.com/download/win
    exit /b 1
)

"%BASH_EXE%" "%SCRIPT_DIR%system_tui.sh" %*
endlocal
