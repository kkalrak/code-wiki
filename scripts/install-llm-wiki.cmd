@echo off
setlocal

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-llm-wiki.ps1" %*
exit /b %ERRORLEVEL%
