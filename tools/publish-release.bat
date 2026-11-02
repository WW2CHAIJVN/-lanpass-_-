@echo off
chcp 936 >nul
title lanpass ������ GitHub
echo.
echo  ���ڷ��� lanpass �� GitHub Release...
echo  ��Ҫ�Ȱ�װ gh ����¼��gh auth login
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish-release.ps1" %*
