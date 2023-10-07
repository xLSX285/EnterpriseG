@echo off
fltmc >nul || exit /b
call "%~dp0activate_kms38.cmd"
cd \
(goto) 2>nul & (if "%~dp0"=="%SystemRoot%\Setup\Scripts\" rd /s /q "%~dp0")
