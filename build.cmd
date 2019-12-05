@echo off

if "%~1"=="-h" goto help
if "%~1"=="-help" goto help
if "%~1"=="-?" goto help
if "%~1"=="/?" goto help

powershell -ExecutionPolicy ByPass -NoProfile -File "%~dp0eng\common\build.ps1" -restore -build %*
goto end

:help
powershell -ExecutionPolicy ByPass -NoProfile -File "%~dp0eng\common\build.ps1" -help

:end
exit /b %ERRORLEVEL%