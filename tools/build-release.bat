@echo off
chcp 936 >nul
title lanpass ������а�
echo.
echo  ���ڴ�� lanpass ���а�...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build-release.ps1" %*
