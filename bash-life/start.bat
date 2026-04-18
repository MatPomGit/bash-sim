@echo off
chcp 65001 >nul 2>&1
REM ============================================================
REM  bash-life – uruchamiacz Windows
REM  Kliknij dwukrotnie ten plik, aby uruchomić symulację.
REM
REM  Wymaga zainstalowanego interpretera Bash:
REM    • Git for Windows  – https://gitforwindows.org/
REM    • WSL (Windows Subsystem for Linux)
REM    • Cygwin           – https://www.cygwin.com/
REM    • MSYS2            – https://www.msys2.org/
REM ============================================================

cd /d "%~dp0"

REM --- Git for Windows (Git Bash) ---
if exist "%ProgramFiles%\Git\bin\bash.exe" (
    "%ProgramFiles%\Git\bin\bash.exe" bash_life.sh
    goto end
)

if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" (
    "%ProgramFiles(x86)%\Git\bin\bash.exe" bash_life.sh
    goto end
)

REM --- Lokalny Git Bash obok skryptu ---
if exist "%~dp0git\bin\bash.exe" (
    "%~dp0git\bin\bash.exe" bash_life.sh
    goto end
)

REM --- Bash w zmiennej PATH (WSL, Cygwin, MSYS2 itp.) ---
where bash >nul 2>&1
if %errorlevel%==0 (
    bash bash_life.sh
    goto end
)

REM --- Nie znaleziono Bash ---
echo.
echo  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo  Nie znaleziono interpretera Bash.
echo.
echo  Aby uruchomic symulacje, zainstaluj jeden z ponizszych:
echo    * Git for Windows : https://gitforwindows.org/
echo    * WSL             : https://learn.microsoft.com/windows/wsl/install
echo    * Cygwin          : https://www.cygwin.com/
echo    * MSYS2           : https://www.msys2.org/
echo  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo.

:end
pause
